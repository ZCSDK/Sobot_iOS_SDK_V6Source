//
//  ZCCheckCusFieldView.m
//  SobotKit
//
//  Created by 张新耀 on 2019/9/4.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCCheckCusFieldView.h"
#define cellIdentifier @"ZCUITableViewCell"
#import "ZCPageSheetView.h"
#import "ZCUICore.h"
#import "ZCUIKitTools.h"
//#define ZCSheetTitleHeight 52
#define zcSheetCellH 48
@interface ZCCheckCusFieldView ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableDictionary *checkDict;
    // 屏幕宽高
    CGFloat                     viewWidth;
    CGFloat                     viewHeigth;
}
@property(nonatomic,strong) UITableView *listTable;
@property(nonatomic,strong) NSMutableArray *mulArr;
@property(nonatomic,strong) NSMutableArray *searchArray;
@property(nonatomic,strong)UIView *topView;
@property(nonatomic,strong)UIButton *backButton;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UITextField *searchField;
// 顶部动态高 默认52
@property(nonatomic,assign)CGFloat topViewH;
@end

@implementation ZCCheckCusFieldView

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
    self.topViewH = 52;
    [self createTitleView];
    _listTable = [[UITableView alloc]initWithFrame:CGRectMake(0, self.topViewH, ScreenWidth, 0) style:UITableViewStylePlain];
    _listTable.delegate = self;
    _listTable.dataSource = self;
    [self addSubview:_listTable];
    [_listTable setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark1)];
    UIView * bgview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    _listTable.tableFooterView = bgview;
    _listTable.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_listTable setSeparatorColor:UIColor.clearColor];
    [_listTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    // 关闭安全区域，否则UITableViewCell横屏时会是全屏的宽
    NSString *version = [UIDevice currentDevice].systemVersion;
    if (version.doubleValue >= 11.0) {
        [_listTable setInsetsContentViewsToSafeArea:NO];
    }
    [self setTableSeparatorInset];
    checkDict  = [NSMutableDictionary dictionaryWithCapacity:0];
    if(_listArray == nil){
        _listArray = [[NSMutableArray alloc] init];
    }
}

// 新版行高48

-(void)setPreModel:(ZCOrderCusFiledsModel *)preModel{
    _preModel = preModel;
    _listArray = _preModel.detailArray;
    self.titleLabel.text = _preModel.fieldName;
    [_listTable reloadData];
    
    CGFloat th = [SobotUITools getHeightContain:sobotConvertToString(self.titleLabel.text) font:SobotFont16 Width:viewWidth-32];
    if (th <= 22) {
        th = 22 + 30;
    }else{
        th = th +30;
    }
    self.topViewH = th;
   
    CGRect topViewF = self.topView.frame;
    topViewF.size.height = th;
    self.topView.frame = topViewF;
    CGRect titleLabelF = self.titleLabel.frame;
    titleLabelF.size.height = th;
    
    
    CGRect f = self.listTable.frame;
    f.size.height = _listArray.count * zcSheetCellH;
    float footHeight = 0;
    if(!sobotIsNull(_preModel) && [_preModel.fieldType intValue] == 7){
        footHeight = 10 + 44 + 10;
    }else{
        footHeight = 0;
    }
    // 如果支持模糊搜索或最大高度限制
    if(f.size.height > ScreenHeight * 0.6 || [preModel.queryFlag intValue] == 1 ||[_preModel.fieldType intValue] == 7){
        f.size.height = ScreenHeight * 0.6;
    }
    f.origin.y = self.topViewH;
    _listTable.frame = f;
    [self setFrame:CGRectMake(0, 0, self.frame.size.width, f.size.height + self.topViewH + footHeight + XBottomBarHeight)];
     self.superview.frame = CGRectMake(0, ScreenHeight - CGRectGetMaxY(self.frame), self.frame.size.width, CGRectGetMaxY(self.frame));
    
    if(!sobotIsNull(_preModel) && [_preModel.fieldType intValue] == 7){
        _mulArr = [NSMutableArray arrayWithCapacity:0];
        for (ZCOrderCusFieldsDetailModel *model in _preModel.detailArray) {
            if (model.isChecked) {
                [_mulArr addObject:model];
            }
        }
        float margin = 0;
        if (![ZCUICore getUICore].kitInfo.navcBarHidden) {
            margin = 64;
        }
        UIView * btnFootView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(f), ScreenWidth, 64 + 20 )];
        btnFootView.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
        btnFootView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
        btnFootView.userInteractionEnabled = YES;
        
        // 区尾添加提交按钮 2.7.1改版
        UIButton * commitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [commitBtn setTitle:SobotKitLocalString(@"确定") forState:UIControlStateNormal];
        [commitBtn setTitle:SobotKitLocalString(@"确定") forState:UIControlStateSelected];
        [commitBtn setBackgroundColor:[ZCUIKitTools zcgetLeaveSubmitImgColor]];
        commitBtn.frame = CGRectMake(16,10, ScreenWidth- 16*2, 40);
        commitBtn.tag = BUTTON_MORE;
        [commitBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        commitBtn.layer.masksToBounds = YES;
        commitBtn.layer.cornerRadius = 4;
        commitBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        commitBtn.titleLabel.font = SobotFont17;
        [btnFootView addSubview:commitBtn];
        [self addSubview:btnFootView];
        
//        2.8.0 增加 线
//        UIView *lineView = [[UIView alloc]init];
//        lineView.frame = CGRectMake(0, 0, ScreenWidth, 0.5);
//        lineView.backgroundColor = UIColorFromKitModeColor(SobotColorBgTopLine);
//        lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//        [btnFootView addSubview:lineView];
        
    }
    else{
//       单选 增加 高度为 20 的尾视图
        UIView * btnFootView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
        btnFootView.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
        btnFootView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        UIView *lineView = [[UIView alloc]init];
        lineView.frame = CGRectMake(0, 0, ScreenWidth, 0.5);
//        lineView.backgroundColor =[ZCUIKitTools zcgetCommentButtonLineColor];
        lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [btnFootView addSubview:lineView];
        _listTable.tableFooterView = btnFootView;
        [self setFrame:CGRectMake(0, 0, ScreenWidth, f.size.height + self.topViewH + (sobotIsIPhoneX()?34:0))];
    }
    
    
    // 2.8.0添加搜索
    if([_preModel.queryFlag intValue] == 1){
        if(_searchArray == nil){
            _searchArray = [[NSMutableArray alloc] init];
            _searchArray = _listArray;
        }
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 56)];
//        [headerView setBackgroundColor:UIColorFromKitModeColor(SobotColorBgSub2Dark1)];
        headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        headerView.userInteractionEnabled = YES;
        _listTable.tableHeaderView = headerView;
        
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 12, ScreenWidth - 32, 36)];
        [bgImageView setBackgroundColor:UIColorFromKitModeColor(SobotColorBgSub)];
        bgImageView.layer.cornerRadius = 4.0f;
        bgImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        bgImageView.layer.masksToBounds = YES;
        [headerView addSubview:bgImageView];
        
        UIImageView *searchIcon = [[UIImageView alloc] initWithImage:[SobotUITools getSysImageByName:@"zcicon_serach"]];
        [searchIcon setFrame:CGRectMake(13, 10, 16, 16)];
        [searchIcon setBackgroundColor:UIColor.clearColor];
        searchIcon.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [bgImageView addSubview:searchIcon];
        
        _searchField = [[UITextField alloc] initWithFrame:CGRectMake(54, 11.5, ScreenWidth - 85, 36)];
        [_searchField setBackgroundColor:UIColor.clearColor];
        [_searchField setTextAlignment:NSTextAlignmentLeft];
        [_searchField setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
        [_searchField setPlaceholder:SobotKitLocalString(@"请输入")];
        _searchField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _searchField.userInteractionEnabled = YES;
        [_searchField setBorderStyle:UITextBorderStyleNone];
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
    
    [self addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadii:CGSizeMake(8, 8) withView:self.topView];
    [self addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadii:CGSizeMake(8, 8) withView:self];
}


-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat th = [SobotUITools getHeightContain:sobotConvertToString(self.titleLabel.text) font:SobotFont16 Width:viewWidth-32];
        if (th <= 22) {
            th = 22 + 30;
        }else{
            th = th +30;
        }
        self.topViewH = th;
       
        CGRect topViewF = self.topView.frame;
        topViewF.size.height = th;
        self.topView.frame = topViewF;
        CGRect titleLabelF = self.titleLabel.frame;
        titleLabelF.size.height = th;
    
    CGRect f = self.listTable.frame;
    f.size.height = _listArray.count * zcSheetCellH;
    float footHeight = 0;
    if(!sobotIsNull(_preModel) && [_preModel.fieldType intValue] == 7){
        footHeight = 10 + 44 + 10;
    }else{
        footHeight = 0;
    }
    // 如果支持模糊搜索或最大高度限制
    if(f.size.height > ScreenHeight * 0.6 || [_preModel.queryFlag intValue] == 1 ){
        f.size.height = ScreenHeight * 0.6;
    }
   f.origin.y = th;
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
    [self setFrame:CGRectMake(0, 0, self.frame.size.width, f.size.height + self.topViewH + footHeight + XBottomBarHeight)];
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
        for (ZCOrderCusFieldsDetailModel *model in _searchArray) {
            NSString *lowerMainString = [model.dataName lowercaseString];
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
    UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, 0, 0);
    if ([_listTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [_listTable setSeparatorInset:inset];
    }
    if ([_listTable respondsToSelector:@selector(setLayoutMargins:)]) {
        [_listTable setLayoutMargins:inset];
    }
}

//设置分割线间距
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if((indexPath.row+1) < _listArray.count){
        [self setTableSeparatorInset];
    }
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
    return zcSheetCellH;
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
    [cell.contentView setFrame:CGRectMake(0, 0, self.listTable.frame.size.width, zcSheetCellH)];
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
    [textLabel setFrame:CGRectMake(16, (zcSheetCellH - 22)/2, self.listTable.frame.size.width - 50, 22)];
    if ([ZCUIKitTools getSobotIsRTLLayout]) {
        [textLabel setFrame:CGRectMake(50, (zcSheetCellH - 22)/2, self.listTable.frame.size.width - 50-16, 22)];
    }
    ZCOrderCusFieldsDetailModel *model = [_listArray objectAtIndex:indexPath.row];
    textLabel.text = model.dataName;
    CGRect imgf = imageView.frame;
    imgf.size = CGSizeMake(20, 20);
    if (!sobotIsNull(_preModel) && [_preModel.fieldType intValue] == 7) {
        if (model.isChecked) {
            UIImage *img = [[SobotUITools getSysImageByName:@"zcion_mor_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [imageView setImage:img];
            imageView.tintColor = [ZCUIKitTools zcgetServerConfigBtnBgColor];
        }else{
            // 没有选中不显示
            imageView.image =  [SobotUITools getSysImageByName:@""];
        }
        imgf.origin.x = self.listTable.frame.size.width - imgf.size.width - 16;
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            imgf.origin.x = 16;
        }
        imgf.origin.y = (zcSheetCellH - imgf.size.height)/2;
    }else{
        if([model.dataValue isEqual:_preModel.fieldSaveValue]){
            UIImage *img = [[SobotUITools getSysImageByName:@"zcion_mor_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [imageView setImage:img];
            imageView.tintColor = [ZCUIKitTools zcgetServerConfigBtnBgColor];
        }
        imgf.origin.x = self.listTable.frame.size.width - imgf.size.width - 16;
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            imgf.origin.x = 16;
        }
        imgf.origin.y = (zcSheetCellH - imgf.size.height)/2;
    }
    imageView.frame = imgf;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    ZCOrderCusFieldsDetailModel *model = [_listArray objectAtIndex:indexPath.row];
    if([_preModel.fieldType intValue] != 7){
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
    
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, self.topViewH)];
    [self.topView setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark1)];
    self.topView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_topView setAutoresizesSubviews:YES];
    [self addSubview:self.topView];
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16,0, _topView.frame.size.width- 32, self.topViewH)];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.titleLabel setFont:[ZCUIKitTools zcgetscTopTextFont]];
    [self.titleLabel setTextColor:[ZCUIKitTools zcgetscTopTextColor]];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.titleLabel setAutoresizesSubviews:YES];
    
//    self.backButton=[UIButton buttonWithType:UIButtonTypeCustom];
//    [self.backButton setFrame:CGRectMake(_topView.frame.size.width-64-16, 0, 64, ZCSheetTitleHeight)];
//    [self.backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
//    UIImage *originalImage = [SobotUITools getSysImageByName:@"zcion_sheet_close"];
//    CGSize newSize = CGSizeMake(14, 14);  // 调整图片为更大尺寸
//    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
//    [originalImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
//    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    [self.backButton setImage:resizedImage forState:UIControlStateNormal];
//    [self.backButton setImage:resizedImage forState:UIControlStateHighlighted];
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



@end
