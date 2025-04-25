//
//  ZCCheckTypeView.m
//  SobotKit
//
//  Created by 张新耀 on 2019/9/4.
//  Copyright © 2019 zhichi. All rights reserved.
//  这个类要使用级联的UI样式

#import "ZCCheckTypeView.h"
#define cellIdentifier @"ZCCheckTypeViewCell"
#import "ZCPageSheetView.h"
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClient.h>
#import "ZCUIKitTools.h"
#import "ZCCheckTypeViewCell.h"
typedef NS_ENUM(NSInteger, ZCButtonClickTag) {
    BUTTON_BACK   = 1, // 返回
    BUTTON_CLOSE  = 2, // 关闭(未使用)
    BUTTON_UNREAD = 3, // 未读消息
    BUTTON_MORE   = 4, // 清空历史记录
    BUTTON_TURNROBOT = 5,// 切换机器人
    BUTTON_EVALUATION =6,// 评价
    BUTTON_TEL   = 7,// 拨打电话
};


@interface ZCCheckTypeView ()<UITableViewDelegate,UITableViewDataSource>{
    
}
@property(nonatomic,strong)UITableView *listTable;
@property(nonatomic,strong)UIView *topView;
@property(nonatomic,strong)UIButton *backButton;
@property(nonatomic,strong)UIButton *moreButton;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong) NSMutableArray *searchArray;
@property(nonatomic,strong)UITextField *searchField;
@property(nonatomic,strong)UIScrollView *topScrollView;
@property(nonatomic,strong)UIView *headerView;
// 是否显示滑块
@property(nonatomic,assign)BOOL isShowScrollView;
// 滑块数据源
@property(nonatomic,strong)NSMutableArray *sorceArray;
// 无结果
@property(nonatomic,strong)UILabel *labNullResult;
@property(nonatomic,strong)NSLayoutConstraint *linePB;
// 顶部动态高
@property(nonatomic,assign)CGFloat topViewH;
@end

@implementation ZCCheckTypeView


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        self.userInteractionEnabled = YES;
        self.autoresizesSubviews = YES;
        self.clipsToBounds = YES;
        self.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
        [self createTableView];
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.userInteractionEnabled = YES;
        [self createTableView];
    }
    return self;
}



-(void)createTableView{
    self.topViewH = 52;
    _listTable = [[UITableView alloc]initWithFrame:CGRectMake(0, self.topViewH, ScreenWidth, 0) style:UITableViewStylePlain];
    _listTable.delegate = self;
    _listTable.dataSource = self;
    [_listTable registerClass:[ZCCheckTypeViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self addSubview:_listTable];
    _listTable.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _listTable.autoresizesSubviews = YES;
    _listTable.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
    // 关闭安全区域，否则UITableViewCell横屏时会是全屏的宽
    NSString *version = [UIDevice currentDevice].systemVersion;
    if (version.doubleValue >= 11.0) {
        [_listTable setInsetsContentViewsToSafeArea:NO];
    }
    if (iOS7) {
        _listTable.backgroundView = nil;
    }
    [_listTable setSeparatorColor:UIColor.clearColor];
    _listTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, CGFLOAT_MIN)];
//    [self setTableSeparatorInset];
    if(_listArray == nil){
        _listArray = [[NSMutableArray alloc] init];
    }
    // 先创建列表后创建头部
    [self createTitleView];
    // 没有搜索结果的
       _labNullResult = [[UILabel alloc] init];
       _labNullResult.textAlignment = NSTextAlignmentCenter;
       _labNullResult.textColor = UIColorFromModeColor(SobotColorTextSub);
       _labNullResult.backgroundColor = UIColorFromKitModeColor(SobotColorBgMain);
       _labNullResult.backgroundColor = UIColor.clearColor;
       _labNullResult.text = SobotLocalString(@"无结果");
       _labNullResult.font = SobotFont14;
       [self.listTable addSubview:_labNullResult];
       [self.listTable addConstraint:sobotLayoutEqualCenterY(0,_labNullResult,self.listTable)];
       [self.listTable addConstraint:sobotLayoutEqualCenterX(0,_labNullResult,self.listTable)];
       [self.listTable addConstraint:sobotLayoutEqualWidth(ScreenWidth, _labNullResult, NSLayoutRelationEqual)];
       [self.listTable addConstraint:sobotLayoutEqualHeight(ScreenHeight *0.8 - 52 - self.headerView.frame.size.height, _labNullResult, NSLayoutRelationEqual)];
       _labNullResult.hidden = YES;
}

-(void)buttonClick:(UIButton *) btn{
    if(btn.tag == BUTTON_BACK){
        if(_parentView!=nil){
            _parentView.hidden = NO;
            [(ZCPageSheetView *)self.superview.superview showSheet:_parentView.frame.size.height animation:NO block:^{
                [self removeFromSuperview];
            }];
        }
    }
    if(btn.tag == BUTTON_MORE){
        [(ZCPageSheetView *)self.superview.superview  dissmisPageSheet];
    }
}
    
-(void)setListArray:(NSMutableArray *)listArray{
    if (!sobotIsNull(listArray)) {
        if (sobotIsNull(_listArray)) {
            _listArray = [NSMutableArray array];
        }
        if (sobotIsNull(_sorceArray)) {
            _searchArray = [NSMutableArray array];
        }
        for (ZCLibTicketTypeModel *model in listArray) {
            [_listArray addObject:model];
            [_searchArray addObject:model];
        }
    }
//    _listArray = listArray;
//    _searchArray = [NSMutableArray arrayWithArray:listArray];
//    CGRect f = self.listTable.frame;
//    f.size.height = _listArray.count * 38;
    CGFloat scale = 0.8;
    if(isLandspace){
        scale = 0.5;
    }
//    if(f.size.height > ScreenHeight * scale){
//        f.size.height = ScreenHeight * scale;
//    }
//    _listTable.frame = f;
    [self.listTable reloadData];
    // 直接设置最大值
    CGFloat h = ScreenHeight *scale;
    [self setFrame:CGRectMake(0, 0, self.frame.size.width, h)];
    self.superview.frame = CGRectMake(0, ScreenHeight - h, self.frame.size.width, h);
    if([_typeId isEqual:@"-1"]){
        _backButton.hidden = YES;
    }
}


-(void)layoutSubviews{
    [super layoutSubviews];
    CGRect f = self.listTable.frame;
//    f.size.height = _listArray.count * 38;
    CGFloat scale = 0.8;
   if(isLandspace){
       scale = 0.5;
   }
//   if(f.size.height > ScreenHeight * scale){
//       f.size.height = ScreenHeight * scale;
//   }
    f.size.height = ScreenHeight *scale - XBottomBarHeight - ZCSheetTitleHeight;
//   f.origin.y = ZCSheetTitleHeight;
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
   [self.listTable reloadData];
//    CGFloat h = f.size.height + ZCSheetTitleHeight + XBottomBarHeight;
    CGFloat h = ScreenHeight *scale;
    [self setFrame:CGRectMake(0, 0, self.frame.size.width, h)];
    self.superview.frame = CGRectMake(0, ScreenHeight - h, self.frame.size.width, h);
    [self addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadii:CGSizeMake(8, 8) withView:self.topView];
    [self addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadii:CGSizeMake(8, 8) withView:self];
}


//设置分割线间距
//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    if((indexPath.row+1) < _listArray.count){
//        [self setTableSeparatorInset];
//    }
//}


//-(void)viewDidLayoutSubviews{
//    [self setTableSeparatorInset];
//}

#pragma mark UITableView delegate Start
// 返回section数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


// 返回section下得行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_searchArray==nil){
        return 0;
    }
    return _searchArray.count;
}

// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZCCheckTypeViewCell *cell = (ZCCheckTypeViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[ZCCheckTypeViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    if (sobotIsNull(_searchArray)&&_searchArray.count >0) {
        if(_searchArray.count < indexPath.row){
            return cell;
        }
    }
    ZCLibTicketTypeModel *model = [_searchArray objectAtIndex:indexPath.row];
    BOOL isNext = NO;
    BOOL isSel = NO;
    if([model.nodeFlag intValue] == 1){
        // 有下一级
        isNext = YES;
    }else{
        if (!sobotIsNull(_selTypeId) && [_selTypeId containsString:sobotConvertToString(model.typeId)]) {
            isSel = YES;
        }
    }
        // 查看是否选中
    [cell initDataToView:model isSel:isSel isNext:isNext];
    return cell;
//    if(_listArray.count < indexPath.row){
//        return cell;
//    }
//    cell.frame = CGRectMake(0, 0, self.listTable.frame.size.width, 38);
//    [cell setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark1)];
//    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
//    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
//    [imageView setContentMode:UIViewContentModeScaleAspectFit];
//    [cell.contentView addSubview:imageView];
//    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 8, self.listTable.frame.size.width - 50, 22)];
//    textLabel.font = SobotFont14;
//    textLabel.textColor = UIColorFromKitModeColor(SobotColorTextMain);
//    [cell.contentView addSubview:textLabel];
//    
//    ZCLibTicketTypeModel *model=[_listArray objectAtIndex:indexPath.row];
//    textLabel.text = model.typeName;
//    CGRect imgf = imageView.frame;
//    if([model.nodeFlag intValue] == 1){
//        imageView.image =  [SobotUITools getSysImageByName:@"zcicon_arrow_right_record"];
//        imgf.size = CGSizeMake(7, 12);
//    }
//    imgf.origin.x = self.listTable.frame.size.width - imgf.size.width - 15;
//    imgf.origin.y = (38 - imgf.size.height)/2;
//    imageView.frame = imgf;
   
}

// 是否显示删除功能
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

// 删除清理数据
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    editingStyle = UITableViewCellEditingStyleDelete;
}


// table 行的高度 动态高
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 38.0f;
//}

// table 行的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(_listArray==nil || _listArray.count<indexPath.row){
        return;
    }
    ZCLibTicketTypeModel *model = [_listArray objectAtIndex:indexPath.row];
    if([model.nodeFlag intValue] == 1){
        if (_sorceArray == nil) {
            _sorceArray = [NSMutableArray array];
        }
        // 这里逻辑替换不再跳页处理，只在本月切换数据 展示下一级数据
        NSMutableArray *cutArray = [NSMutableArray array];
        for (ZCOrderCusFieldsDetailModel *item in _listArray) {
            [cutArray addObject:item];
        }
        NSDictionary *sorceDict = @{
            @"level":[NSString stringWithFormat:@"%d",model.typeLevel],
            @"dataName":sobotConvertToString(model.typeName),
            @"cutShowArr":cutArray,
            @"dataId":sobotConvertToString(model.typeId)
        };
        [self.sorceArray addObject:sorceDict];
        
        // 同步下一级的数据
        self.typeId = model.typeId;
        [_listArray removeAllObjects];
        _listArray = [NSMutableArray arrayWithArray:model.items];
        self.searchArray = [NSMutableArray arrayWithArray:model.items];
        self.searchField.text = @"";
        // 切换回显滑块
        [self changeScrollViewItems];
        [self.listTable reloadData];
        
//        ZCCheckTypeView *typeVC = [[ZCCheckTypeView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0)];
//        typeVC.typeId = model.typeId;
//        typeVC.pageTitle = model.typeName;
//        typeVC.orderTypeCheckBlock =  _orderTypeCheckBlock;
//        typeVC.parentView = self;
//        typeVC.listArray = model.items;
//        [self.superview addSubview:typeVC];
//        [(ZCPageSheetView *)self.superview.superview showSheet:typeVC.frame.size.height animation:NO block:^{
//            self.hidden = YES;
//        }];
    }else{
        if(_orderTypeCheckBlock){
            _orderTypeCheckBlock(model);
        }
    }
}

#pragma mark UITableView delegate end

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
    [_listTable setSeparatorColor : [ZCUIKitTools zcgetCommentButtonLineColor]];
}

-(void)createTitleView{
    // 去掉左右按钮
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, self.topViewH)];
    self.topView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.topView setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark1)];
    [self addSubview:self.topView];
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16,0, _topView.frame.size.width- 16*2, self.topViewH)];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.titleLabel setFont:[ZCUIKitTools zcgetscTopTextFont]];
    [self.titleLabel setTextColor:[ZCUIKitTools zcgetscTopTextColor]];
    self.titleLabel.text = SobotKitLocalString(@"选择分类");
    self.titleLabel.numberOfLines = 0;
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
    [self.titleLabel setAutoresizesSubviews:YES];
    [self.topView addSubview:self.titleLabel];
    // 新版UI 不显示返回
//    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.backButton setFrame:CGRectMake(20, 0, 64, ZCSheetTitleHeight)];
//    [self.backButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
//    [self.backButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
//    [self.backButton setImage:[SobotUITools getSysImageByName:@"zcicon_scback_gray"] forState:UIControlStateNormal];
//    [self.backButton setImage:[SobotUITools getSysImageByName:@"zcicon_scback_gray"] forState:UIControlStateHighlighted];
//    [self.backButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 20)];
//    [self.backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
//    [self.backButton setAutoresizesSubviews:YES];
//    self.backButton.tag = BUTTON_BACK;
//    [self.backButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self.topView addSubview:self.backButton];
    
    // 关闭按钮保留
//    self.moreButton=[UIButton buttonWithType:UIButtonTypeCustom];
//    [self.moreButton setFrame:CGRectMake(_topView.frame.size.width-64, 0, 64, ZCSheetTitleHeight)];
//    [self.moreButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
//    [self.moreButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
//    [self.moreButton setContentEdgeInsets:UIEdgeInsetsZero];
//    [self.moreButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
//    [self.moreButton setAutoresizesSubviews:YES];
//    [self.moreButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
//    [self.moreButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
//    [self.moreButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
//    [self.moreButton setImage:[SobotUITools getSysImageByName:@"zcicon_sf_close"] forState:UIControlStateNormal];
//    [self.moreButton setImage:[SobotUITools getSysImageByName:@"zcicon_sf_close"] forState:UIControlStateHighlighted];
//    self.moreButton.tag = BUTTON_MORE;
//    [self.moreButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
//
//    self.moreButton=[UIButton buttonWithType:UIButtonTypeCustom];
//   [self.moreButton setFrame:CGRectMake(_topView.frame.size.width-64-16, 0, 64, ZCSheetTitleHeight)];
//   [self.moreButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
//   [self.moreButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
//   [self.moreButton setContentEdgeInsets:UIEdgeInsetsZero];
//   [self.moreButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
//   [self.moreButton setAutoresizesSubviews:YES];
//   
//   UIImage *originalImage = [SobotUITools getSysImageByName:@"zcion_sheet_close"];
//   CGSize newSize = CGSizeMake(14, 14);  // 调整图片为更大尺寸
//   UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
//   [originalImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
//   UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
//   UIGraphicsEndImageContext();
//   [self.moreButton setImage:resizedImage forState:UIControlStateNormal];
//   [self.moreButton setImage:resizedImage forState:UIControlStateHighlighted];
//   self.moreButton.tag = BUTTON_MORE;
//   [self.moreButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
//   [self.topView addSubview:self.moreButton];
    
    
    CGFloat th = [SobotUITools getHeightContain:SobotKitLocalString(@"选择分类") font:SobotFont16 Width:ScreenWidth-32];
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
    self.titleLabel.frame = titleLabelF;
    
    CGRect listF = self.listTable.frame;
    listF.origin.y = th;
    self.listTable.frame = listF;
    
    UIView *bottomLine = [[UIView alloc]init];
    bottomLine.backgroundColor = UIColorFromKitModeColor(SobotColorBgTopLine);
    [bottomLine setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.topView addSubview:bottomLine];
    [self.topView addConstraint:sobotLayoutPaddingBottom(0, bottomLine, self.topView)];
    [self.topView addConstraint:sobotLayoutPaddingLeft(0, bottomLine, self.topView)];
    [self.topView addConstraint:sobotLayoutPaddingRight(0, bottomLine, self.topView)];
    [self.topView addConstraint:sobotLayoutEqualHeight(0.5, bottomLine, NSLayoutRelationEqual)];
    
    // 搜索相关 区头
    if(_searchArray == nil){
        // 展示的View
        _searchArray = [[NSMutableArray alloc]init];
    }
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 56)];
    self.headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.headerView.userInteractionEnabled = YES;
    _listTable.tableHeaderView = self.headerView;
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 12, ScreenWidth - 32, 36)];
    [bgImageView setBackgroundColor:UIColorFromKitModeColor(SobotColorBgSub)];
    bgImageView.layer.cornerRadius = 4.0f;
    bgImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    bgImageView.layer.masksToBounds = YES;
    [self.headerView addSubview:bgImageView];
    
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
    [self.headerView addSubview:_searchField];
    
    //级联新增滚动视图
    _topScrollView = [[UIScrollView alloc]init];
    _topScrollView.backgroundColor = UIColor.clearColor;
    _topScrollView.showsVerticalScrollIndicator  = NO;
    _topScrollView.showsHorizontalScrollIndicator = NO;
    _topScrollView.bounces = NO;
    _topScrollView.frame = CGRectMake(16, 48, ScreenWidth-16*2, 0);
    _topScrollView.contentSize = CGSizeMake(0, ScreenWidth);
    _topScrollView.scrollEnabled = YES;
    [self.headerView addSubview:_topScrollView];
    
    // 底部还有一根线条
//    UIView *lineView = [[UIView alloc]init];
//    lineView.backgroundColor = UIColorFromKitModeColor(SobotColorBgTopLine);
//    [self.headerView addSubview:lineView];
//    self.linePB = sobotLayoutPaddingBottom(0, lineView, self.headerView);
//    [self.headerView addConstraint:self.linePB];
//    [self.headerView addConstraint:sobotLayoutPaddingLeft(0, lineView , self.headerView)];
//    [self.headerView addConstraint:sobotLayoutPaddingRight(0, lineView, self.headerView)];
//    [self.headerView addConstraint:sobotLayoutEqualHeight(0.5, lineView, NSLayoutRelationEqual)];
    [self addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadii:CGSizeMake(8, 8) withView:self.topView];
    [self addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadii:CGSizeMake(8, 8) withView:self];
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

#pragma mark -- 搜索编辑事件
-(void)searchTextChanged:(UITextField *) field{
    NSString *text = field.text;
    if(sobotConvertToString(text).length > 0){
        NSMutableArray *resultArr = [[NSMutableArray alloc] init];
        for (ZCLibTicketTypeModel *model in _listArray) {
            NSString *lowerMainString = [model.typeName lowercaseString];
            NSString *lowerSearchString = [text lowercaseString];
            if ([lowerMainString containsString:sobotConvertToString(lowerSearchString)]) {
                [resultArr addObject:model];
            }
        }
        [self.searchArray removeAllObjects];
        self.searchArray = [NSMutableArray arrayWithArray:resultArr];
        if(resultArr.count > 0){
            _labNullResult.hidden = YES;
        }else{
            // 没有搜到数据，
            _labNullResult.hidden = NO;
        }
        [_listTable reloadData];
    }else{
        _labNullResult.hidden = YES;
        // 取全部的
        self.searchArray = [NSMutableArray arrayWithArray:self.listArray];
        [_listTable reloadData];
    }
}

#pragma mark --计算文本宽度 注意字号
-(CGFloat)getLabelTextWidthWith:(NSString *)tip{;
    UIFont *font = SobotFont14;
    CGSize maxSize = CGSizeMake(CGFLOAT_MAX, 22);  // 限制高度为一行
    CGRect textRect = [tip boundingRectWithSize:maxSize
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName: font}
                                         context:nil];
    return textRect.size.width;
}

#pragma mark -- 是否显示滑动模块
-(void)setScrollViewShow{
    CGRect tsf = _topScrollView.frame;
    CGRect headerF = self.headerView.frame;
    if (self.isShowScrollView) {
        tsf.size.height = 52;
        headerF.size.height = 52+48 +8;
        self.linePB.constant = -8;
    }else{
        self.linePB.constant = -8;
        tsf.size.height = 0;
        headerF.size.height = 56 +8;
    }
    self.headerView.frame = headerF;
    _topScrollView.frame = tsf;
    [self.listTable reloadData];
}
#pragma mark-- 清空输入，回收键盘
-(void)clearSearchView{
    self.searchField.text = @"";
    [_searchField resignFirstResponder];
    [self endEditing:YES];
    _labNullResult.hidden = YES;
    [self hideKeyBoard];
}
#pragma mark --滚动回收键盘
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self endEditing:YES];
    [self hideKeyBoard];
}

#pragma mark -- 全局回收键盘
- (void)hideKeyBoard
{
    for (UIWindow* window in [UIApplication sharedApplication].windows)
    {
        for (UIView* view in window.subviews)
        {
            [self dismissAllKeyBoardInView:view];
        }
    }
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

#pragma mark -- 点击返回上一级或某一级
-(void)backAction:(SobotButton *)sender{
    int tag = (int)sender.tag;
    NSDictionary *scoreDict = self.sorceArray[tag];
    int level = [sobotConvertToString([scoreDict objectForKey:@"level"]) intValue];
    // 这里是倒着来的，点击2级是要显示是3级的数据的
    if (level == 1 && tag == 0) {
        // 移除滚动条，恢复默认 清理缓存数据
        [self.sorceArray removeAllObjects];
        [_listArray removeAllObjects];
        [_searchArray removeAllObjects];
        _listArray = [scoreDict objectForKey:@"cutShowArr"];
        self.searchArray = [scoreDict objectForKey:@"cutShowArr"];
        [self clearSearchView];
        // 切换回显滑块
        [self changeScrollViewItems];
        [self.listTable reloadData];
    }else{
        [self clearSearchView];
        // 切换数据，清理缓存数据
        [_listArray removeAllObjects];
        _listArray = [scoreDict objectForKey:@"cutShowArr"];
        _searchArray = [scoreDict objectForKey:@"cutShowArr"];
//        self.parentDataId = [scoreDict objectForKey:@"dataId"];
        self.searchArray = _listArray;
#pragma mark --//移除下标之后的 注意这里的数据关系 先处理展示的数据，在移除scorllview的数据
        if (self.sorceArray && self.sorceArray.count >0) {
            if (tag <self.sorceArray.count) {
                [self.sorceArray removeObjectsInRange:NSMakeRange(tag, self.sorceArray.count -tag)];
            }
        }
        // 切换回显滑块
        [self changeScrollViewItems];
        [self.listTable reloadData];
    }
}

#pragma mark -- 添加滑动返回按钮集合
-(void)changeScrollViewItems{
    if (self.sorceArray.count > 0) {
        self.isShowScrollView = YES;
    }else{
        self.isShowScrollView = NO;
    }
    [self setScrollViewShow];
    if (self.sorceArray.count >0) {
        [self.topScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        CGFloat itemX = 0;
        CGFloat itemY = 15;
        CGFloat itemH = 22;
        CGFloat itemW = 0;
        for (int i = 0; i<self.sorceArray.count; i++) {
            NSDictionary *sorceDict = self.sorceArray[i];
            UIView *lastView =  [self createItemWith:sorceDict x:itemX y:itemY w:itemW h:itemH index:i];
            itemX = lastView.frame.origin.x + lastView.frame.size.width;
            if (lastView) {
                self.topScrollView.contentSize = CGSizeMake(lastView.frame.size.width + lastView.frame.origin.x, 22);
                if (itemX > self.topScrollView.frame.size.width) {
                    self.topScrollView.contentOffset = CGPointMake(itemX-self.topScrollView.frame.size.width, 0);
                }
            }
        }
    }
}

#pragma Mark构建每一个按钮
-(UIView *)createItemWith:(NSDictionary *)sorceDict x:(CGFloat)itemX y:(CGFloat)itemY w:(CGFloat)itemW h:(CGFloat)itemH index:(int)i{
    UIView *firstBgView;
    UIView *itemBgView;
    if (i == 0) {
        // 创建全部的按钮
        // 并且创建第一个数据
        firstBgView = [[UIView alloc]init];
        firstBgView.backgroundColor = UIColor.clearColor;
        [self.topScrollView addSubview:firstBgView];
        // 全部的lab
        UILabel *allTipLab = [[UILabel alloc]init];
        allTipLab.textColor = [ZCUIKitTools zcgetServerConfigBtnBgColor];
        allTipLab.font = SobotFont14;
        [firstBgView addSubview:allTipLab];
        // 计算文本的宽度
        CGFloat textW = [self getLabelTextWidthWith:SobotLocalString(@"全部")];
        allTipLab.text = SobotLocalString(@"全部");
        allTipLab.frame = CGRectMake(0, 0, textW, itemH);
        // 箭头
        UIImageView *firstIconImg = [[UIImageView alloc]init];
        firstIconImg.image = [[SobotUITools getSysImageByName:@"zcicon_arrow_right_record_small"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        firstIconImg.tintColor = [ZCUIKitTools zcgetServerConfigBtnBgColor];
        firstIconImg.frame = CGRectMake(textW+4, 2.5, 10, 18);
        [firstBgView addSubview:firstIconImg];
        // 首次之后的X值
        itemX = textW + 4 + 10 +4;
        firstBgView.frame = CGRectMake(0, itemY, itemX, itemH);
        //点击交互按钮
        SobotButton *firstClickBtn = [SobotButton buttonWithType:UIButtonTypeCustom];
        [firstBgView addSubview:firstClickBtn];
        firstClickBtn.obj = sorceDict;
        firstClickBtn.tag = i;
        [firstClickBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
        firstClickBtn.frame = CGRectMake(0, 0, itemX, itemH);
    }
    // 这里计算全部之后的数据
    itemBgView = [[UIView alloc]init];
    itemBgView.backgroundColor = UIColor.clearColor;
    itemBgView.frame = CGRectMake(itemX, itemY, 0, itemH);
    [self.topScrollView addSubview:itemBgView];
    // lab
    UILabel *tipLab = [[UILabel alloc]init];
    tipLab.textColor = [ZCUIKitTools zcgetServerConfigBtnBgColor];
    tipLab.font = SobotFont14;
    [itemBgView addSubview:tipLab];
    // 计算文本的宽度
    CGFloat textW = [self getLabelTextWidthWith:sobotConvertToString([sorceDict objectForKey:@"dataName"])];
    tipLab.text = sobotConvertToString([sorceDict objectForKey:@"dataName"]);
    tipLab.frame = CGRectMake(0, 0, textW, itemH);
    if (i == self.sorceArray.count -1) {
        // 最后一个显示灰色
        tipLab.textColor = UIColorFromKitModeColor(SobotColorTextSub1);
        // 没有箭头
    }else{
        // 有箭头
        UIImageView *iconImg = [[UIImageView alloc]init];
        iconImg.image = [[SobotUITools getSysImageByName:@"zcicon_arrow_right_record_small"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        iconImg.tintColor = [ZCUIKitTools zcgetServerConfigBtnBgColor];
        iconImg.frame = CGRectMake(textW+4, 2.5, 10, 18);
        [itemBgView addSubview:iconImg];
        // 计算完之后的X
        itemX = itemX + textW + 4 + 10 +4;
    }
    CGRect itemF = itemBgView.frame;
    itemF.size.width = textW + 4 + ((i== self.sorceArray.count-1)? 0 : 14);
    itemBgView.frame = itemF;
    if (i != self.sorceArray.count -1) {
        // 有箭头才有点击事件，没有箭头不要加
        SobotButton *clickBtn = [SobotButton buttonWithType:UIButtonTypeCustom];
        [itemBgView addSubview:clickBtn];
        clickBtn.obj = sorceDict;
        clickBtn.tag = i+1;
        [clickBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
        clickBtn.frame = CGRectMake(0, 0, itemF.size.width, itemF.size.height);
    }
    return itemBgView;
}

@end
