//
//  ZCUIAskSelectionView.m
//  SobotKit
//
//  Created by lizh on 2024/11/7.
//

#import "ZCUIAskSelectionView.h"
#define cellIdentifier @"ZCUITableViewCell"
#import "ZCPageSheetView.h"
#import "ZCUICore.h"
#import "ZCUIKitTools.h"
#define ZCSheetTitleH 52

@interface ZCUIAskSelectionView ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableDictionary *checkDict;
    // 屏幕宽高
    CGFloat                     viewWidth;
    CGFloat                     viewHeigth;
}
@property(nonatomic,strong) UITableView *listTable;
@property(nonatomic,strong) NSMutableArray *mulArr;
@property(nonatomic,strong)UIView *topView;
@property(nonatomic,strong)UIButton *backButton;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UITextField *searchField;

@end
@implementation ZCUIAskSelectionView

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
    _listTable = [[UITableView alloc]initWithFrame:CGRectMake(0, ZCSheetTitleHeight +12, ScreenWidth, 0) style:UITableViewStylePlain];
    _listTable.delegate = self;
    _listTable.dataSource = self;
    [self addSubview:_listTable];
    [_listTable setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark1)];
    UIView * bgview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    _listTable.tableFooterView = bgview;
    _listTable.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_listTable setSeparatorColor:[ZCUIKitTools zcgetCommentButtonLineColor]];
    [_listTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    // 关闭安全区域，否则UITableViewCell横屏时会是全屏的宽
    NSString *version = [UIDevice currentDevice].systemVersion;
    if (version.doubleValue >= 11.0) {
        [_listTable setInsetsContentViewsToSafeArea:NO];
    }
    
//    [self setTableSeparatorInset];
    checkDict  = [NSMutableDictionary dictionaryWithCapacity:0];
    if(_listArray == nil){
        _listArray = [[NSMutableArray alloc] init];
    }
    _listTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    _listTable.separatorColor = [UIColor clearColor];
}

-(void)setTitle:(NSString *)title{
    if (sobotConvertToString(title).length >0) {
        self.titleLabel.text = sobotConvertToString(title);
    }
}

-(void)updataPage{
    self.titleLabel.text = SobotKitLocalString(@"请选择");
    [_listTable reloadData];
    CGRect f = self.listTable.frame;
    f.size.height = _listArray.count * 40; // 间距40
    float footHeight = 0;
    
    // 如果支持模糊搜索或最大高度限制
    if(f.size.height > ScreenHeight * 0.8){
        f.size.height = ScreenHeight * 0.8 - 52;
    }
    _listTable.frame = f;
    [self setFrame:CGRectMake(0, 0, self.frame.size.width, f.size.height + ZCSheetTitleH + footHeight + XBottomBarHeight)];
     self.superview.frame = CGRectMake(0, ScreenHeight - CGRectGetMaxY(self.frame), self.frame.size.width, CGRectGetMaxY(self.frame));
//   增加 高度为 20 的尾视图
    UIView * btnFootView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
    btnFootView.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
    btnFootView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    UIView *lineView = [[UIView alloc]init];
//    lineView.frame = CGRectMake(0, 0, ScreenWidth, 0.5);
//    lineView.backgroundColor =[ZCUIKitTools zcgetCommentButtonLineColor];
//    lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    [btnFootView addSubview:lineView];
    _listTable.tableFooterView = btnFootView;
    [self setFrame:CGRectMake(0, 0, ScreenWidth, f.size.height + ZCSheetTitleH + (sobotIsIPhoneX()?34:0))];
    
    
    // 添加搜索
    if(_searchArray == nil){
        _searchArray = [[NSMutableArray alloc] init];
        _searchArray = _listArray;
    }
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 36 + 24)];
//    [headerView setBackgroundColor:UIColorFromKitModeColor(SobotColorBgSub2Dark1)];
    [headerView setBackgroundColor:UIColor.clearColor];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    headerView.userInteractionEnabled = YES;
    _listTable.tableHeaderView = headerView;
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 12, ScreenWidth - 32, 36)];
    [bgImageView setBackgroundColor:UIColorFromKitModeColor(SobotColorBgSub)];
    bgImageView.layer.cornerRadius = 4.0f;
    bgImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    bgImageView.layer.masksToBounds = YES;
    headerView.userInteractionEnabled = YES;
    [headerView addSubview:bgImageView];
    
    UIImageView *searchIcon = [[UIImageView alloc] initWithImage:[SobotUITools getSysImageByName:@"zcicon_serach"]];
    [searchIcon setFrame:CGRectMake(13, 11, 12.5, 12.5)];
    [searchIcon setBackgroundColor:UIColor.clearColor];
    searchIcon.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [bgImageView addSubview:searchIcon];
    
    _searchField = [[UITextField alloc] initWithFrame:CGRectMake(48, 12 , ScreenWidth - 32 -34 , 36)];
    [_searchField setBackgroundColor:UIColor.clearColor];
    [_searchField setTextAlignment:NSTextAlignmentLeft];
    [_searchField setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
    [_searchField setPlaceholder:SobotKitLocalString(@"请输入")];
    _searchField.font = SobotFont14;
    _searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _searchField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchField.userInteractionEnabled = YES;
    [_searchField setBorderStyle:UITextBorderStyleNone];
    [_searchField addTarget:self action:@selector(searchTextChanged:) forControlEvents:UIControlEventEditingChanged];
    if([[[UIDevice currentDevice] systemVersion] doubleValue] >= 13.0){
        [_searchField setValue:UIColorFromKitModeColor(SobotColorTextSub1) forKeyPath:@"placeholderLabel.textColor"];
        [_searchField setValue:SobotFont14 forKeyPath:@"placeholderLabel.font"];
    }
    else{
        [_searchField setValue:UIColorFromKitModeColor(SobotColorTextSub) forKeyPath:@"_placeholderLabel.textColor"];
        [_searchField setValue:SobotFont14 forKeyPath:@"_placeholderLabel.font"];
    }
    [headerView addSubview:_searchField];
    
    [self addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadii:CGSizeMake(8, 8) withView:self.topView];
    [self addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadii:CGSizeMake(8, 8) withView:self];
}


-(void)layoutSubviews{
    [super layoutSubviews];
    CGRect f = self.listTable.frame;
    f.size.height = _listArray.count * 40;
    float footHeight = 0;

    // 如果支持模糊搜索或最大高度限制
    if(f.size.height > ScreenHeight * 0.8 ){
        f.size.height = ScreenHeight * 0.8-52;
    }
   f.origin.y = ZCSheetTitleH;
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
   [self setFrame:CGRectMake(0, 0, self.frame.size.width, f.size.height + ZCSheetTitleH + footHeight + XBottomBarHeight)];
    self.superview.frame = CGRectMake(0, ScreenHeight - CGRectGetMaxY(self.frame), self.frame.size.width, CGRectGetMaxY(self.frame));
    [self addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadii:CGSizeMake(8, 8) withView:self.topView];
    [self addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadii:CGSizeMake(8, 8) withView:self];
}


-(void)buttonClick:(UIButton *) btn{
    if(btn.tag == BUTTON_BACK){
        [(ZCPageSheetView *)self.superview.superview  dissmisPageSheet];
    }
    if(btn.tag == BUTTON_MORE){
        if(_orderCusFiledCheckBlock){
            _orderCusFiledCheckBlock(nil,_mulArr);
             [(ZCPageSheetView *)self.superview.superview  dissmisPageSheet];
        }
    }
}

-(void)searchTextChanged:(UITextField *) field{
    NSString *text = field.text;
    if(sobotConvertToString(text).length > 0){
        NSMutableArray *resultArr = [[NSMutableArray alloc] init];
        for (ZCLanguageModel *model in self.searchArray) {
            // 不区分大小写
            NSString *lowerMainString = [model.name lowercaseString];
            NSString *lowerSearchString = [text lowercaseString];
            if ([lowerMainString containsString:sobotConvertToString(lowerSearchString)]) {
                [resultArr addObject:model];
            }
        }
        self.listArray = resultArr;
        [_listTable reloadData];
    }else{
        self.listArray = self.searchArray;
        [_listTable reloadData];
    }
}


/**
 *  设置UITableView分割线空隙
 */
-(void)setTableSeparatorInset{
    UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, 0, ScreenWidth);
    if ([_listTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [_listTable setSeparatorInset:inset];
    }
    if ([_listTable respondsToSelector:@selector(setLayoutMargins:)]) {
        [_listTable setLayoutMargins:inset];
    }
    
}

//设置分割线间距
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    // 不要线条
//    if((indexPath.row+1) < _listArray.count){
        [self setTableSeparatorInset];
//    }
}

-(void)viewDidLayoutSubviews{
    [self setTableSeparatorInset];
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
    if(indexPath.row==_listArray.count-1){
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
        if([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
            [cell setPreservesSuperviewLayoutMargins:NO];
        }
    }
    if(_listArray.count < indexPath.row){
        return cell;
    }
    [cell.contentView setFrame:CGRectMake(0, 0, self.listTable.frame.size.width, 40)];
    [cell setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark1)];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [cell.contentView addSubview:imageView];
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.font = SobotFont14;
    textLabel.textColor = UIColorFromKitModeColor(SobotColorTextMain);
    [cell.contentView addSubview:textLabel];
    [textLabel setFrame:CGRectMake(28, 8, self.listTable.frame.size.width - 56, 22)];
    if ([ZCUIKitTools getSobotIsRTLLayout]) {
        textLabel.textAlignment = NSTextAlignmentRight;
    }else{
        textLabel.textAlignment = NSTextAlignmentLeft;
    }
    // 是否选中的
    ZCLanguageModel *model = [_listArray objectAtIndex:indexPath.row];
//    textLabel.text = model.name;
    if (!self.searchField.hidden && self.searchField.text.length >0) {
        textLabel.attributedText = [self getOtherColorString:self.searchField.text Color:UIColorFromModeColor(SobotColorTheme) withString:model.name];
    }
    CGRect imgf = imageView.frame;
    imgf.size = CGSizeMake(20, 20);
//    if([model.code isEqual:[[ZCUICore getUICore] getLibConfig].language]){
//        imageView.image = [SobotUITools getSysImageByName:@"zcicon_ordertype_sel"];
//    }
    imgf.origin.x = self.listTable.frame.size.width - imgf.size.width - 15;
    if ([ZCUIKitTools getSobotIsRTLLayout]) {
        imgf.origin.x = 15;
    }
    imgf.origin.y = (40 - imgf.size.height)/2;
    imageView.frame = imgf;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    ZCLanguageModel *model = [_listArray objectAtIndex:indexPath.row];
    if(_orderCusFiledCheckBlock){
        _orderCusFiledCheckBlock(model,_mulArr);
    }
    [(ZCPageSheetView *)self.superview.superview  dissmisPageSheet];
    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if(_searchField){
        [_searchField resignFirstResponder];
    }
}

-(void)createTitleView{
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ZCSheetTitleH)];
    [self.topView setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark1)];
    self.topView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_topView setAutoresizesSubviews:YES];
    [self addSubview:self.topView];
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16,0, _topView.frame.size.width-32, ZCSheetTitleH)];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.titleLabel setFont:SobotFontBold16];
    [self.titleLabel setTextColor:[ZCUIKitTools zcgetscTopTextColor]];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.titleLabel setAutoresizesSubviews:YES];
    
//    self.backButton=[UIButton buttonWithType:UIButtonTypeCustom];
//    [self.backButton setFrame:CGRectMake(_topView.frame.size.width-64, 0, 64, ZCSheetTitleH)];
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
    UIView *bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, ZCSheetTitleH -0.5, _topView.frame.size.width, 0.5)];
    bottomLine.backgroundColor = [ZCUIKitTools zcgetCommentButtonLineColor];
    [bottomLine setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.topView addSubview:bottomLine];
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

-(NSMutableAttributedString *)getOtherColorString:(NSString *)string Color:(UIColor *)Color withString:(NSString *)originalString
{
//    if(!self.isEditStatus){
//        // 展示状态，去掉尾部的*
//        originalString = [originalString stringByReplacingOccurrencesOfString:@"*" withString:@""];
//    }
    NSMutableString *temp = [NSMutableString stringWithString:sobotConvertToString(originalString)];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:temp];
    if (string.length) {
        NSRange range = [temp rangeOfString:string];
        [str addAttribute:NSForegroundColorAttributeName value:Color range:range];
        return str;
    }
    return str;
}
@end
