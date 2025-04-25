//
//  ZCAskCusFieldView.m
//  SobotKit
//
//  Created by lizh on 2024/11/11.
//

#import "ZCAskCusFieldView.h"
#define cellIdentifier @"ZCUITableViewCell"
#import "ZCPageSheetView.h"
#import "ZCUICore.h"
#import "ZCUIKitTools.h"
//#define ZCSheetTitleHeight 52
// 默认顶部标题高度52 单行行高22 ，上下间距15 多行动态高度
@interface ZCAskCusFieldView ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,UITextFieldDelegate>{
    NSMutableDictionary *checkDict;
    // 屏幕宽高
    CGFloat                     viewWidth;
    CGFloat                     viewHeigth;
    CGPoint contentoffset;// 记录list的偏移量
    CGFloat sfY ;
}
@property(nonatomic,strong) UITableView *listTable;
@property(nonatomic,strong) NSMutableArray *mulArr;
@property(nonatomic,strong) NSMutableArray *searchArray;
@property(nonatomic,strong)UIView *topView;
@property(nonatomic,strong)UIButton *backButton;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UITextField *searchField;
@property(nonatomic,strong)UILabel *labNullResult;
// 键盘的高度
@property(nonatomic,assign)CGFloat keyboardH;
//顶部提交文案的整体高度
@property(nonatomic,assign)CGFloat TopViewH;
@end

@implementation ZCAskCusFieldView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
        self.autoresizesSubviews = YES;
        [self createTableView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self createTableView];
    }
    return self;
}

-(void)createTableView{
    [self createTitleView];
    _listTable = [[UITableView alloc]initWithFrame:CGRectMake(0, self.TopViewH, ScreenWidth, 0) style:UITableViewStylePlain];
    _listTable.delegate = self;
    _listTable.dataSource = self;
    [self addSubview:_listTable];
    [_listTable setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark1)];
    UIView * bgview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    _listTable.tableFooterView = bgview;
    _listTable.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_listTable setSeparatorColor:UIColor.clearColor];
//    [_listTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    // 关闭安全区域，否则UITableViewCell横屏时会是全屏的宽
    NSString *version = [UIDevice currentDevice].systemVersion;
    if (version.doubleValue >= 11.0) {
        [_listTable setInsetsContentViewsToSafeArea:NO];
    }
    checkDict  = [NSMutableDictionary dictionaryWithCapacity:0];
    if(_listArray == nil){
        _listArray = [[NSMutableArray alloc] init];
    }
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHideKeyboard)];
    gestureRecognizer.numberOfTapsRequired = 1;
    gestureRecognizer.cancelsTouchesInView = NO;
   gestureRecognizer.delegate = self;
    [_listTable addGestureRecognizer:gestureRecognizer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    _labNullResult = [[UILabel alloc] init];
    _labNullResult.textAlignment = NSTextAlignmentCenter;
    _labNullResult.textColor = UIColorFromModeColor(SobotColorTextSub);
    _labNullResult.backgroundColor = UIColor.clearColor;
    _labNullResult.text = SobotLocalString(@"无结果");
    _labNullResult.font = SobotFont14;
    [self.listTable addSubview:_labNullResult];
    [self.listTable addConstraint:sobotLayoutEqualCenterY(0,_labNullResult,self.listTable)];
    [self.listTable addConstraint:sobotLayoutEqualCenterX(0,_labNullResult,self.listTable)];
    _labNullResult.hidden = YES;
    
}

-(void)setCusModel:(SobotFormNodeRespVosModel *)cusModel{
    _cusModel = cusModel;
    _listArray = _cusModel.customFieldArr;
    self.titleLabel.text = _cusModel.fieldName;
    
#pragma mark -- 这里是动态高度计算
    CGFloat th = [SobotUITools getHeightContain:sobotConvertToString(_cusModel.fieldName) font:SobotFont16 Width:viewWidth-32];
    if (th <= 22) {
        th = 22 + 30;
    }else{
        th = th +30;
    }
    self.TopViewH = th;
   
    CGRect topViewF = self.topView.frame;
    topViewF.size.height = th;
    self.topView.frame = topViewF;
    CGRect titleLabelF = self.titleLabel.frame;
    titleLabelF.size.height = th;
    self.titleLabel.frame = titleLabelF;
    
    [_listTable reloadData];
    CGRect f = self.listTable.frame;
    f.origin.y = th;
    f.size.height = _listArray.count * 54;
    
    float footHeight = 0;
//    if(!sobotIsNull(_cusModel) && _cusModel.fieldType == 7){
//        footHeight = 10 + 44 + 10;
//    }else{
//        footHeight = 0;
//    }
    // 如果支持模糊搜索或最大高度限制
    if(f.size.height > ScreenHeight * 0.8){
        f.size.height = ScreenHeight * 0.8 - 52 - footHeight;
    }
    _listTable.frame = f;
    [self setFrame:CGRectMake(0, 0, ScreenWidth, f.size.height + self.TopViewH)];
     self.superview.frame = CGRectMake(0, ScreenHeight - CGRectGetMaxY(self.frame), self.frame.size.width, CGRectGetMaxY(self.frame));
    sfY = self.superview.frame.origin.y;
    // 询前表单都显示
    if(_searchArray == nil){
        _searchArray = [[NSMutableArray alloc] init];
        _searchArray = _listArray;
    }
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 36+12+8)];
//    [headerView setBackgroundColor:UIColorFromKitModeColor(SobotColorBgSub2Dark1)];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    headerView.userInteractionEnabled = YES;
    _listTable.tableHeaderView = headerView;
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 12, ScreenWidth - 32, 36)];
    [bgImageView setBackgroundColor:UIColorFromKitModeColor(SobotColorBgF5)];
    bgImageView.layer.cornerRadius = 4.0f;
    bgImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    bgImageView.layer.masksToBounds = YES;
    [headerView addSubview:bgImageView];
    
    UIImageView *searchIcon = [[UIImageView alloc] initWithImage:[SobotUITools getSysImageByName:@"zcicon_serach"]];
    [searchIcon setFrame:CGRectMake(13, 11.5, 12.5, 12.5)];
    [searchIcon setBackgroundColor:UIColor.clearColor];
    searchIcon.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [bgImageView addSubview:searchIcon];
    
    _searchField = [[UITextField alloc] initWithFrame:CGRectMake(50, 12, ScreenWidth - 50-16, 36)];
    [_searchField setBackgroundColor:UIColor.clearColor];
    [_searchField setTextAlignment:NSTextAlignmentLeft];
    [_searchField setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
    [_searchField setPlaceholder:SobotKitLocalString(@"请输入")];
    _searchField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchField.userInteractionEnabled = YES;
    [_searchField setBorderStyle:UITextBorderStyleNone];
    _searchField.returnKeyType = UIReturnKeySearch;
    _searchField.delegate = self;
    [_searchField addTarget:self action:@selector(searchTextChanged:) forControlEvents:UIControlEventEditingChanged];
    if([[[UIDevice currentDevice] systemVersion] doubleValue] >= 13.0){
        [_searchField setValue:UIColorFromKitModeColor(SobotColorTextSub1) forKeyPath:@"placeholderLabel.textColor"];
        [_searchField setValue:SobotFont14 forKeyPath:@"placeholderLabel.font"];
    }
    else{
        [_searchField setValue:UIColorFromKitModeColor(SobotColorTextSub1) forKeyPath:@"_placeholderLabel.textColor"];
        [_searchField setValue:SobotFont14 forKeyPath:@"_placeholderLabel.font"];
    }
    [headerView addSubview:_searchField];

}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat th = [SobotUITools getHeightContain:sobotConvertToString(_cusModel.fieldName) font:SobotFont16 Width:viewWidth-32];
    if (th <= 22) {
        th = 22 + 30;
    }else{
        th = th +30;
    }
    self.TopViewH = th;
   
    CGRect topViewF = self.topView.frame;
    topViewF.size.height = th;
    self.topView.frame = topViewF;
    CGRect titleLabelF = self.titleLabel.frame;
    titleLabelF.size.height = th;
    self.titleLabel.frame = titleLabelF;
    
    if (self.keyboardH > 0) {
        
    }else{
        CGRect f = self.listTable.frame;
        f.size.height = _listArray.count * 54 + 56;
        float footHeight = 0;
//        if(!sobotIsNull(_cusModel) && _cusModel.fieldType == 7){
//            footHeight = 10 + 44 + 10;
//        }else{
//            footHeight = 0;
//        }
        // 如果支持模糊搜索或最大高度限制
        if (f.size.height >ScreenHeight * 0.8) {
            f.size.height = ScreenHeight * 0.8;
        }
        f.origin.y = self.TopViewH;
        int direction = [SobotUITools getCurScreenDirection];
           CGFloat spaceX = 0;
           CGFloat LW = self.frame.size.width;
           // iphoneX 横屏需要单独处理
           if(direction > 0){
               LW = self.frame.size.width - XBottomBarHeight;
           }
           if(direction == 2){
               spaceX = XBottomBarHeight;
           }
        f.origin.x = spaceX;
        f.size.width = LW;
       _listTable.frame = f;
        [_listTable reloadData];
        [self setFrame:CGRectMake(0, 0, ScreenWidth, f.size.height + self.TopViewH +XBottomBarHeight)];// (sobotIsIPhoneX()?34:0)
        self.superview.frame = CGRectMake(0, ScreenHeight - CGRectGetMaxY(self.frame), self.frame.size.width, CGRectGetMaxY(self.frame));
        sfY = self.superview.frame.origin.y;
        [self addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadii:CGSizeMake(8, 8) withView:self.topView];
        [self addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadii:CGSizeMake(8, 8) withView:self];
    }
}


-(void)buttonClick:(UIButton *) btn{
    if(btn.tag == BUTTON_BACK){
        if (self.backBlock) {
            self.backBlock(@"back");
        }
        [(ZCPageSheetView *)self.superview.superview  dissmisPageSheet];
    }
}

-(void)searchTextChanged:(UITextField *) field{
    NSString *text = field.text;
    if(sobotConvertToString(text).length > 0){
        NSMutableArray *resultArr = [[NSMutableArray alloc] init];
        for (ZCOrderCusFieldsDetailModel *model in _searchArray) {
            NSString *lowerMainString = [model.dataName lowercaseString];
            NSString *lowerSearchString = [text lowercaseString];
            if ([lowerMainString containsString:sobotConvertToString(lowerSearchString)]) {
                [resultArr addObject:model];
            }
        }
        self.listArray = resultArr;
        [_listTable reloadData];
        
        if(resultArr.count > 0){
            _labNullResult.hidden = YES;
        }else{
            _labNullResult.hidden = NO;
        }
    }else{
        self.labNullResult.hidden = YES;
        self.listArray = self.searchArray;
        [_listTable reloadData];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"点击了搜索");
    [self hideKeyboard];
    return YES;
}

#pragma mark -- tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _listArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if(_listArray.count < indexPath.row){
        return cell;
    }
    [cell.contentView setFrame:CGRectMake(0, 0, self.listTable.frame.size.width, 40)];
//    [cell setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark1)];
    [cell setBackgroundColor:UIColor.clearColor];
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [cell.contentView addSubview:imageView];
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.font = SobotFont14;
    textLabel.textColor = UIColorFromKitModeColor(SobotColorTextMain);
    [cell.contentView addSubview:textLabel];
    [textLabel setFrame:CGRectMake(12+ 16, 4, self.listTable.frame.size.width - (16+12)*2-50, 36)];
    ZCOrderCusFieldsDetailModel *model = [_listArray objectAtIndex:indexPath.row];
    if (self.searchField.text.length >0) {
        textLabel.attributedText = [self getOtherColorString:sobotConvertToString(self.searchField.text) Color:[ZCUIKitTools zcgetServerConfigBtnBgColor] withString:model.dataName];
    }else{
        textLabel.text = model.dataName;
    }
    
    CGRect imgf = imageView.frame;
    imgf.size = CGSizeMake(20, 20);
    if (!sobotIsNull(_cusModel) && _cusModel.fieldType  == 7) {
        if (model.isChecked) {
            imageView.image =  [SobotUITools getSysImageByName:@"zcicon_app_moreselected_sel"];
        }else{
            imageView.image =  [SobotUITools getSysImageByName:@"zcicon_app_moreselected_nol"];
        }
        imgf.origin.x = self.listTable.frame.size.width - imgf.size.width - 15;
        imgf.origin.y = (54 - imgf.size.height)/2;
    }else{
        if([model.dataId isEqual:_cusModel.fieldSaveValue]){
            imageView.image = [SobotUITools getSysImageByName:@"zcicon_ordertype_sel"];
        }
        imgf.origin.x = self.listTable.frame.size.width - imgf.size.width - 15;
        imgf.origin.y = (40 - imgf.size.height)/2;
    }
    imageView.frame = imgf;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    ZCOrderCusFieldsDetailModel *model = [_listArray objectAtIndex:indexPath.row];
    if(_cusModel.fieldType  != 7){
        if(_orderCusFiledCheckBlock){
            _orderCusFiledCheckBlock(model,_mulArr);
        }
        [(ZCPageSheetView *)self.superview.superview  dissmisPageSheet];
    }else{
        // 复选框
        if(model.isChecked){
            model.isChecked = NO;
            [_mulArr removeObject:model];
        }else{
            model.isChecked = YES;
            [_mulArr addObject:model];
        }
        [_listTable reloadData];
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if(_searchField){
        [_searchField resignFirstResponder];
    }
}

-(void)createTitleView{
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, self.TopViewH)];
    [self.topView setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark1)];
    self.topView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_topView setAutoresizesSubviews:YES];
    [self addSubview:self.topView];
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16,0, _topView.frame.size.width- 32, self.TopViewH)];
    [self.titleLabel setFont:SobotFont16];
    self.titleLabel.numberOfLines = 0;
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.titleLabel setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.titleLabel setAutoresizesSubviews:YES];
    
//    self.backButton=[UIButton buttonWithType:UIButtonTypeCustom];
//    [self.backButton setFrame:CGRectMake(_topView.frame.size.width-64, 0, 64, ZCSheetTitleHeight)];
//    [self.backButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
//    [self.backButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
//    [self.backButton setContentEdgeInsets:UIEdgeInsetsZero];
//    [self.backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
//    [self.backButton setAutoresizesSubviews:YES];
//    [self.backButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
//    [self.backButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
//    [self.backButton setImage:[SobotUITools getSysImageByName:@"zcicon_sf_close"] forState:UIControlStateNormal];
//    [self.backButton setImage:[SobotUITools getSysImageByName:@"zcicon_sf_close"] forState:UIControlStateHighlighted];
//    [self.topView addSubview:self.backButton];
//    self.backButton.tag = BUTTON_BACK;
//    [self.backButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self.topView addSubview:self.backButton];
    [self.topView addSubview:self.titleLabel];
    UIView *bottomLine = [[UIView alloc]init];
    bottomLine.backgroundColor = UIColorFromKitModeColor(SobotColorBgTopLine);
    [bottomLine setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.topView addSubview:bottomLine];
    [self.topView addConstraint:sobotLayoutPaddingBottom(0, bottomLine, self.topView)];
    [self.topView addConstraint:sobotLayoutPaddingLeft(0, bottomLine, self.topView)];
    [self.topView addConstraint:sobotLayoutPaddingRight(0, bottomLine, self.topView)];
    [self.topView addConstraint:sobotLayoutEqualHeight(0.5, bottomLine, NSLayoutRelationEqual)];
}

-(NSMutableAttributedString *)getOtherColorString:(NSString *)string Color:(UIColor *)Color withString:(NSString *)originalString
{
    NSMutableString *temp = [NSMutableString stringWithString:sobotConvertToString(originalString)];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:temp];
    if (string.length) {
        NSRange range = [temp rangeOfString:string];
        [str addAttribute:NSForegroundColorAttributeName value:Color range:range];
        return str;
    }
    return str;
}

/**
 *  设置部分圆角(绝对布局)
 *
 *  @param corners 需要设置为圆角的角 UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerAllCorners
 *  @param radii   需要设置的圆角大小 例如 CGSizeMake(20.0f, 20.0f)
 */
- (void)addRoundedCorners:(UIRectCorner)corners
                withRadii:(CGSize)radii withView:(UIView *) view {
    view.layer.masksToBounds = YES;
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:corners cornerRadii:radii];
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    
    view.layer.mask = shape;
}
/**
 *  设置部分圆角(相对布局)
 *
 *  @param corners 需要设置为圆角的角 UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerAllCorners
 *  @param radii   需要设置的圆角大小 例如 CGSizeMake(20.0f, 20.0f)
 *  @param rect    需要设置的圆角view的rect
 */
- (void)addRoundedCorners:(UIRectCorner)corners
                withRadii:(CGSize)radii
                 viewRect:(CGRect)rect withView:(UIView *) view {
    
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:radii];
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    
    view.layer.mask = shape;
}


#pragma mark -- 键盘显示
-(void)keyBoardWillShow:(NSNotification *) notification{
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat keyboardHeight = [[[notification userInfo] objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue].size.height;
    self.keyboardH = keyboardHeight;
    SLog(@"键盘的高度 %f",self.keyboardH);
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationDelegate:self];
    {
        //获取当前cell在tableview中的位置
//        CGRect rectintableview = [self->_listTable rectForRowAtIndexPath:self.indexPath];
//        //获取当前cell在屏幕中的位置
//        CGRect rectinsuperview = [self->_listTable convertRect:rectintableview fromView:[SobotUITools getCurWindow].rootViewController.view];
        
        
        CGRect cellRectInSuperview = [_searchField convertRect:_searchField.bounds toView:[UIApplication sharedApplication].keyWindow];

        
        // 假设 cell 是你当前的 UITableViewCell 或 UICollectionViewCell
//        CGRect cellRect = [_listTable rectForRowAtIndexPath:self.indexPath]; // 获取 cell 在 tableView 中的 rect
//        CGRect cellRectInSuperview = [_listTable convertRect:cellRect toView:[UIApplication sharedApplication].keyWindow]; // 转换到窗口的坐标系统
        NSLog(@"Cell 在屏幕中的位置: %@", NSStringFromCGRect(cellRectInSuperview));
        self->contentoffset = self->_listTable.contentOffset;
        // 获取键盘的高度  两者直接的差值
        // UI要求弹起 tableview 到铺满全屏的最大 80%
//        if (cellRectInSuperview.origin.y > (ScreenHeight - self->_keyboardH)) {
//            if(!isLandspace){
                // 这里通过偏移量 有问题，当只有一个元素 应该设置整体的高度
                self.superview.frame = CGRectMake(0, ScreenHeight - CGRectGetMaxY(self.frame), self.frame.size.width, CGRectGetMaxY(self.frame));
                CGRect sf = self.superview.frame;
//                sf.origin.y = sf.origin.y -(cellRectInSuperview.origin.y - (ScreenHeight - self->_keyboardH)+72);
//                sf.size.height = sf.size.height + (cellRectInSuperview.origin.y - (ScreenHeight - self->_keyboardH)+72);
//                self->contentoffset.y = (cellRectInSuperview.origin.y - (ScreenHeight - self->_keyboardH)+72);
//                self.superview.frame = sf;
                
                // 先获取之前的sy.y
                sf.origin.y = ScreenHeight*0.2;
                self.superview.frame = sf;
                self->contentoffset.y = (cellRectInSuperview.origin.y - (ScreenHeight - self->_keyboardH)+72);
                
                [self addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadii:CGSizeMake(8, 8) withView:self.topView];
                [self addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadii:CGSizeMake(8, 8) withView:self];
//            }
//        }
    }
    
    // commit animations
    [UIView commitAnimations];
}

//键盘隐藏
- (void)keyBoardWillHide:(NSNotification *)notification {
//    isKeyBoardShow = NO;
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView beginAnimations:@"bottomBarDown" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView commitAnimations];
    [UIView animateWithDuration:0.25 animations:^{
//        CGRect sf = self.superview.frame;
//        sf.origin.y = sf.origin.y + self->contentoffset.y;
//        sf.size.height = sf.size.height - self->contentoffset.y;
//        self.superview.frame = sf;
        [self setkeyboardHiddeFarme];
        [self addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadii:CGSizeMake(8, 8) withView:self.topView];
        [self addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadii:CGSizeMake(8, 8) withView:self];
    }];
}

#pragma mark - 回收键盘
-(void)tapHideKeyboard{
    if(!sobotIsNull(_searchField)){
        [_searchField resignFirstResponder];
    }
    if(contentoffset.x != 0 || contentoffset.y != 0){
//        // 隐藏键盘，还原偏移量
//        [_listTable setContentOffset:contentoffset];
        contentoffset.y = 0;
    }
    [self setkeyboardHiddeFarme];
}

-(void)setkeyboardHiddeFarme{
    CGRect sf = self.superview.frame;
    sf.origin.y = sfY;
    self.superview.frame = sf;
}

- (void)hideKeyboard {
    if(!sobotIsNull(_searchField)){
        [_searchField resignFirstResponder];
    }
    if(contentoffset.x != 0 || contentoffset.y != 0){
//        // 隐藏键盘，还原偏移量
//        [_listTable setContentOffset:contentoffset];
        contentoffset.y = 0;
    }
    [self setkeyboardHiddeFarme];
}

- (void)allHideKeyBoard
{
    [self endEditing:true];
    [self setkeyboardHiddeFarme];
}

-(BOOL) dismissAllKeyBoardInView:(UIView *)view
{
    if([view isFirstResponder])
    {
        [view resignFirstResponder];
        return YES;
    }
    for(UIView *subView in view.subviews)
    {
        if([self dismissAllKeyBoardInView:subView])
        {
            return YES;
        }
    }
    return NO;
}

#pragma mark - 手势冲突的代理
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIButton class]]){
        return NO;
    }
    return YES;
}

@end
