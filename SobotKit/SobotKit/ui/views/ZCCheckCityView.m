//
//  ZCCheckCityView.m
//  SobotKit
//
//  Created by 张新耀 on 2019/10/10.
//  Copyright © 2019 zhichi. All rights reserved.
//  城市也使用新版的UI级联处理  新版UI规则去掉左右按钮 只留标题

#import "ZCCheckCityView.h"
#import <SobotCommon/SobotCommon.h>
#define cellIdentifier @"ZCUITableViewCell"
#import "ZCPageSheetView.h"
#import "ZCUICore.h"
#import "ZCUIKitTools.h"
@interface ZCCheckCityView()<UITableViewDelegate,UITableViewDataSource>{
    // 屏幕宽高
    CGFloat                     viewWidth;
    CGFloat                     viewHeigth;
}
@property(nonatomic,strong)UITableView *listTable;
@property(nonatomic,strong)UIView *topView;
@property(nonatomic,strong)UIButton *backButton;
@property(nonatomic,strong)UIButton *moreButton;
@property(nonatomic,strong)UILabel *titleLabel;
@end

@implementation ZCCheckCityView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
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
        [self createTableView];
    }
    return self;
}

-(void)setLevle:(int)levle{
    _levle = levle;
    [self loadAddressData];
}

-(void)loadAddressData{
    NSString * addId = @"";
    switch (_levle) {
        case 1:
            
            break;
        case 2:
            addId = _proviceId;
            break;
        case 3:
            addId = _cityId;
            break;
        default:
            break;
    }
    
    [ZCLibServer getAddressWithLevel:_levle nextaddressId:addId start:^{
        
    } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
        NSArray * addressArr = [NSArray array];
        if (dict) {
            switch (self->_levle) {
                case 1:
                    addressArr = dict[@"data"][@"provinces"];
                    break;
                case 2:
                    addressArr = dict[@"data"][@"citys"];
                    break;
                case 3:
                    addressArr = dict[@"data"][@"areas"];
                    break;
                    
                default:
                    break;
            }
            
            for (NSDictionary * item in addressArr) {
                ZCAddressModel * model = [[ZCAddressModel alloc] initWithMyDict:item];
                if (self.levle ==3) {
                    model.provinceName = self.proviceName;
                    model.provinceId = self.proviceId;
                    model.cityId = self.cityId;
                    model.cityName = self.cityName;
                }else if(self.levle == 2){
                    model.provinceName = self.proviceName;
                    model.provinceId = self.proviceId;
                }
                [self->_listArray addObject:model];
            }
            [self reloadTabview];
        }
        
    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
        
    }];
}

-(void)reloadTabview{
    [_listTable reloadData];
}


-(void)createTitleView{
    
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ZCSheetTitleHeight)];
    [self.topView setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark1)];
    [self.topView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self addSubview:self.topView];
        
    //    [self.topView addSubview:self.topImageView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16,0, _topView.frame.size.width- 32, ZCSheetTitleHeight)];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.titleLabel setFont:[ZCUIKitTools zcgetscTopTextFont]];
    [self.titleLabel setTextColor:[ZCUIKitTools zcgetscTopTextColor]];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.text = sobotConvertToString(_pageTitle);
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.titleLabel setAutoresizesSubviews:YES];
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setFrame:CGRectMake(20, 0, 64, ZCSheetTitleHeight)];
    [self.backButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.backButton setImage:[SobotUITools getSysImageByName:@"zcicon_scback_gray"] forState:UIControlStateNormal];
    [self.backButton setImage:[SobotUITools getSysImageByName:@"zcicon_scback_gray"] forState:UIControlStateHighlighted];
    [self.backButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 20)];
    [self.backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.backButton setAutoresizesSubviews:YES];
    [self.backButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    self.backButton.tag = BUTTON_BACK;
    [self.backButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.backButton.hidden = YES;
    
//    self.moreButton=[UIButton buttonWithType:UIButtonTypeCustom];
//    [self.moreButton setFrame:CGRectMake(_topView.frame.size.width-64, 0, 64, ZCSheetTitleHeight)];
//    [self.moreButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
//    [self.moreButton setContentEdgeInsets:UIEdgeInsetsZero];
//    [self.moreButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
//    [self.moreButton setAutoresizesSubviews:YES];
//    [self.moreButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
//    [self.moreButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
//    [self.moreButton setImage:[SobotUITools getSysImageByName:@"zcicon_sf_close"] forState:UIControlStateNormal];
//    [self.moreButton setImage:[SobotUITools getSysImageByName:@"zcicon_sf_close"] forState:UIControlStateHighlighted];
//    self.moreButton.tag = BUTTON_MORE;
//    [self.moreButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
//    [self.moreButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
//    [self.moreButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
   
    self.moreButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.moreButton setFrame:CGRectMake(_topView.frame.size.width-64-16, 0, 64, ZCSheetTitleHeight)];
    [self.moreButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.moreButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [self.moreButton setContentEdgeInsets:UIEdgeInsetsZero];
    [self.moreButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [self.moreButton setAutoresizesSubviews:YES];

    UIImage *originalImage = [SobotUITools getSysImageByName:@"zcion_sheet_close"];
    CGSize newSize = CGSizeMake(14, 14);  // 调整图片为更大尺寸
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [originalImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.moreButton setImage:resizedImage forState:UIControlStateNormal];
    [self.moreButton setImage:resizedImage forState:UIControlStateHighlighted];
    self.moreButton.tag = BUTTON_MORE;
    [self.moreButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.backButton];
//    [self.topView addSubview:self.moreButton];
    
    [self.topView addSubview:self.titleLabel];
    
    UIView *bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, ZCSheetTitleHeight -0.5, ScreenWidth, 0.5)];
    bottomLine.backgroundColor = UIColorFromKitModeColor(SobotColorBgTopLine);
    [bottomLine setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.topView addSubview:bottomLine];
}

-(void)setPageTitle:(NSString *)pageTitle{
    _pageTitle = pageTitle;
    self.titleLabel.text = sobotConvertToString(_pageTitle);
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

-(void)createTableView{
    [self createTitleView];
    
    _listTable = [[UITableView alloc]initWithFrame:CGRectMake(0, ZCSheetTitleHeight, ScreenWidth, ScreenHeight * 0.7) style:UITableViewStylePlain];
    _listTable.delegate = self;
    _listTable.dataSource = self;
    _listTable.layer.masksToBounds = YES;
    [_listTable setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark1)];
    [self addSubview:_listTable];
    
    if (iOS7) {
        _listTable.backgroundView = nil;
    }
    
    [_listTable setSeparatorColor:[ZCUIKitTools zcgetCommentButtonLineColor]];
    [_listTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    // 关闭安全区域，否则UITableViewCell横屏时会是全屏的宽
    NSString *version = [UIDevice currentDevice].systemVersion;
    if (version.doubleValue >= 11.0) {
        [_listTable setInsetsContentViewsToSafeArea:NO];
    }
//    [self setTableSeparatorInset];
    _listTable.separatorColor = UIColor.clearColor;
    
    UIView * bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    bgView.backgroundColor = [ZCUIKitTools zcgetCommentButtonLineColor];
    _listTable.tableFooterView = bgView;
    
    if(_listArray == nil){
        _listArray = [[NSMutableArray alloc] init];
    }
    [self setFrame:CGRectMake(0, 0, self.frame.size.width, _listTable.frame.size.height + ZCSheetTitleHeight + 20 + XBottomBarHeight)];
}


-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGRect f = self.listTable.frame;
    CGFloat scale = 0.7;
    if(isLandspace){
        scale = 0.5;
    }
    f.size.height = ScreenHeight * scale;
    
    f.origin.y = ZCSheetTitleHeight;
    int direction = [SobotUITools getCurScreenDirection];
    CGFloat spaceX = 0;
    CGFloat LW = ScreenWidth;
    // iphoneX 横屏需要单独处理
   if(direction > 0){
       LW = ScreenWidth - XBottomBarHeight;
   }
   if(direction == 2){
       spaceX = XBottomBarHeight;
   }
    f.origin.x = spaceX;
    f.size.width = LW;
   _listTable.frame = f;
   
   [self.listTable reloadData];
    
    CGFloat h = f.size.height + ZCSheetTitleHeight + XBottomBarHeight;
   [self setFrame:CGRectMake(0, 0, LW, h)];
    
    self.topView.frame = CGRectMake(0, 0, LW, ZCSheetTitleHeight);
    self.titleLabel.frame = CGRectMake(16,0, _topView.frame.size.width- 16*2, ZCSheetTitleHeight);
    self.superview.frame = CGRectMake(0, ScreenHeight - h, self.frame.size.width, h);
    
    [ZCUIKitTools addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadii:CGSizeMake(8, 8) withView:_topView];
    [ZCUIKitTools addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadii:CGSizeMake(8, 8) withView:self];
}


#pragma mark UITableView delegate Start
// 返回section数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

// 返回section下得行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_listArray==nil){
        return 0;
    }
    return _listArray.count;
}

// cell
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
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [cell.contentView addSubview:imageView];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 7, self.listTable.frame.size.width - 50, 22)];
    textLabel.font = SobotFont14;
    textLabel.textColor = UIColorFromKitModeColor(SobotColorTextMain);
    [cell.contentView addSubview:textLabel];
    [cell setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark1)];
    [cell setSelectionStyle:UITableViewScrollPositionNone];
    ZCAddressModel *model=[_listArray objectAtIndex:indexPath.row];
    
    switch (_levle) {
        case 1:
            textLabel.text = model.provinceName;
            break;
        case 2:
            textLabel.text = model.cityName;
            break;
        case 3:
            textLabel.text = model.areaName;
            break;
        default:
            break;
    }
    
    CGRect imgf = imageView.frame;
    if(self.levle != 3){
        imageView.image =  [SobotUITools getSysImageByName:@"zcicon_arrow_right_record"];
        imgf.size = CGSizeMake(7, 12);
    }
    
    if (self.levle == 1) {
        self.backButton.hidden = YES;
    }else{
        self.backButton.hidden = NO;

    }
    
    imgf.origin.x = self.listTable.frame.size.width - imgf.size.width - 15;
    imgf.origin.y = (54 - imgf.size.height)/2;
    imageView.frame = imgf;
    return cell;
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

// table 行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 36.0f;
}

// table 行的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(_listArray==nil || _listArray.count<indexPath.row){
        return;
    }
    ZCAddressModel *model = [_listArray objectAtIndex:indexPath.row];
    if (model.endFlag == 1 || self.levle == 3) {
        if(_orderTypeCheckBlock){
            _orderTypeCheckBlock(model);
        }
    }else{
        ZCCheckCityView *typeVC = [[ZCCheckCityView alloc] init];
        typeVC.orderTypeCheckBlock =  _orderTypeCheckBlock;
        typeVC.parentView = self;
        int count = 1;
        count  += self.levle;
        typeVC.pageTitle = _pageTitle;
        typeVC.proviceId = model.provinceId;
        typeVC.proviceName = model.provinceName;
        typeVC.cityName = model.cityName;
        typeVC.cityId = model.cityId;
        typeVC.levle = count;
        [self.superview addSubview:typeVC];
        [(ZCPageSheetView *)self.superview.superview showSheet:typeVC.frame.size.height animation:NO block:^{
            self.hidden = YES;
        }];
    }
}

//设置分割线间距
//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    if((indexPath.row+1) < _listArray.count){
//        UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, 0, 0);
//        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
//            [cell setSeparatorInset:inset];
//        }
//        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
//            [cell setLayoutMargins:inset];
//        }
//    }
//}

-(void)viewDidLayoutSubviews{
//    [self setTableSeparatorInset];
    [self.listTable reloadData];
}

#pragma mark UITableView delegate end

/**
 *  设置UITableView分割线空隙
 */
-(void)setTableSeparatorInset{
//    UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, 0, 0);
//    if ([_listTable respondsToSelector:@selector(setSeparatorInset:)]) {
//        [_listTable setSeparatorInset:inset];
//    }
//    
//    if ([_listTable respondsToSelector:@selector(setLayoutMargins:)]) {
//        [_listTable setLayoutMargins:inset];
//    }
}


@end
