//
//  ZCChatAiCustomCardPage.m
//  SobotKit
//
//  Created by lizh on 2025/3/20.
//

#import "ZCChatAiCustomCardPage.h"

#import "ZCChatAiCustomCardPageCell.h"
#import <SobotCommon/SobotCommon.h>
#import "ZCUIKitTools.h"
#import "ZCPageSheetView.h"
#import "ZCChatAiCardView.h"
@interface ZCChatAiCustomCardPage()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>{
    CGFloat viewWidth;
    CGFloat viewHeight;
    NSMutableArray *listArray;
}

@property (nonatomic,strong) UIView * backGroundView;
@property(nonatomic,strong) UIScrollView *scrollView;
@property(nonatomic,strong)SobotTableView *listView;
@property(nonatomic,strong)NSLayoutConstraint *listViewH;
@property(nonatomic,strong)SobotChatCustomCard *cardModel;

@property(nonatomic,strong)UILabel *titleLabel;
// 按钮动态高度
@property(nonatomic,assign)CGFloat topViewH;
@end


@implementation ZCChatAiCustomCardPage

-(ZCChatAiCustomCardPage*)initActionSheet:(NSMutableArray *)array WithView:(UIView *)view cardModel:(SobotChatCustomCard*)cardModel{
    self = [super init];
    if (self) {
        _cardModel = cardModel;
        viewWidth = view.frame.size.width;
        viewHeight = ScreenHeight;
        _topViewH = 52;
        if (!listArray) {
           listArray = [[NSMutableArray alloc]init];
        }
        listArray = cardModel.customCards;
        self.frame = CGRectMake(0, 0, ScreenWidth, viewHeight);
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.autoresizesSubviews = YES;
        self.backgroundColor = UIColorFromKitModeColorAlpha(SobotColorBlack, 0.6);
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareViewDismiss:)];
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
        [self createSubviews];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didRotate:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)didRotate:(NSNotification *)notification {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
        viewWidth = ScreenWidth;
        viewHeight = ScreenHeight;
        // 横屏
//        NSLog(@"横屏");
    } else if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown) {
        // 竖屏
//        NSLog(@"竖屏");
        viewWidth = ScreenWidth;
        viewHeight = ScreenHeight;
    }
}

#pragma mark --更新数据
-(void)updataPage{
    self.titleLabel.text = sobotConvertToString(_cardModel.cardGuide); //SobotKitLocalString(@"更多信息");
    [_listView reloadData];
    CGRect f = self.listView.frame;
    f.size.height = listArray.count * 40; // 间距40
    float footHeight = 0;
    
    // 如果支持模糊搜索或最大高度限制
    if(f.size.height > ScreenHeight * 0.8){
        f.size.height = ScreenHeight * 0.8 - 52;
    }
    _listView.frame = f;
    [self setFrame:CGRectMake(0, 0, self.frame.size.width, f.size.height + 52 + footHeight + XBottomBarHeight)];
     self.superview.frame = CGRectMake(0, ScreenHeight - CGRectGetMaxY(self.frame), self.frame.size.width, CGRectGetMaxY(self.frame));
//   增加 高度为 20 的尾视图
    UIView * btnFootView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
    btnFootView.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
    btnFootView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _listView.tableFooterView = btnFootView;
    [self setFrame:CGRectMake(0, 0, ScreenWidth, f.size.height + 52 + (sobotIsIPhoneX()?34:0))];
    [ZCUIKitTools addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadii:CGSizeMake(8, 8)  withView:self.backGroundView];
}
#pragma mark -- 构建子视图
-(void)createSubviews{
    CGFloat bw = ScreenWidth;
    CGFloat th = [SobotUITools getHeightContain:sobotConvertToString(_cardModel.cardGuide) font:SobotFont16 Width:viewWidth-32];
    if (th <= 22) {
        th = 22 + 30;
    }else{
        th = th +30;
    }
    self.topViewH = th;
    // 默认先给一个高度
    self.backGroundView = [[UIView alloc] initWithFrame:CGRectMake((viewWidth - bw) / 2.0, viewHeight, bw, self.topViewH+0.5+XBottomBarHeight)];
    self.backGroundView.frame = CGRectMake(0, viewHeight, bw, self.topViewH+0.5+XBottomBarHeight);
    self.backGroundView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
    self.backGroundView.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
    self.backGroundView.layer.masksToBounds = YES;
    [self addSubview:self.backGroundView];
        
    UILabel *titleLabel = [[UILabel alloc] init];
   [titleLabel setText:sobotConvertToString(_cardModel.cardGuide)];
   titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
   [titleLabel setTextAlignment:NSTextAlignmentCenter];
   self.backGroundView.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
   [titleLabel setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
   [titleLabel setFont:SobotFontBold16];
   titleLabel.numberOfLines = 0;
   [self.backGroundView addSubview:titleLabel];
   [self.backGroundView addConstraint:sobotLayoutPaddingLeft(16, titleLabel, self.backGroundView)];
   [self.backGroundView addConstraint:sobotLayoutPaddingRight(-16, titleLabel, self.backGroundView)];
   [self.backGroundView addConstraint:sobotLayoutPaddingTop(0, titleLabel, self.backGroundView)];
   [self.backGroundView addConstraint:sobotLayoutEqualHeight(th, titleLabel, NSLayoutRelationGreaterThanOrEqual)];

   UIView *topline1 = [[UIView alloc]init];
   topline1.backgroundColor = UIColorFromKitModeColor(SobotColorBgTopLine);
   [titleLabel addSubview:topline1];
   [titleLabel addConstraint:sobotLayoutPaddingLeft(-16, topline1, titleLabel)];
   [titleLabel addConstraint:sobotLayoutPaddingRight(16, topline1, titleLabel)];
   [titleLabel addConstraint:sobotLayoutPaddingBottom(0, topline1, titleLabel)];
   [titleLabel addConstraint:sobotLayoutEqualHeight(0.5, topline1, NSLayoutRelationEqual)];
    
    // 列表
    _listView = (SobotTableView *)[SobotUITools createTableWithView:self.backGroundView delegate:self];
    [_listView registerClass:[ZCChatAiCustomCardPageCell class] forCellReuseIdentifier:@"ZCChatAiCustomCardPageCell"];
    [self.backGroundView addConstraint:sobotLayoutMarginTop(0, _listView, titleLabel)];
    [self.backGroundView addConstraint:sobotLayoutPaddingBottom(-XBottomBarHeight, self.listView, self.backGroundView)];
    [self.backGroundView addConstraint:sobotLayoutPaddingLeft(0, self.listView, self.backGroundView)];
    [self.backGroundView addConstraint:sobotLayoutPaddingRight(0, self.listView, self.backGroundView)];
    self.listViewH = sobotLayoutEqualHeight(0, self.listView, NSLayoutRelationEqual);
    [self.backGroundView addConstraint:self.listViewH];
    _listView.backgroundColor = [UIColor clearColor];
    _listView.separatorColor = UIColorFromKitModeColor(SobotColorBgF5);
//    _listView.estimatedRowHeight = 0;
    _listViewH.constant = CGFLOAT_MAX;
    _listView.estimatedSectionHeaderHeight = 0;
    _listView.estimatedSectionFooterHeight = 0;
    _listView.separatorColor = UIColor.clearColor;
//    [_listView reloadData];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self.listView layoutIfNeeded];
    CGRect lf = self.listView.frame;
    lf.size.height = self.listView.contentSize.height;// 20间距是哪里的
    if (lf.size.height >viewHeight*0.8 - self.topViewH -XBottomBarHeight) {
        self.listViewH.constant = viewHeight*0.8 - self.topViewH -XBottomBarHeight;
    }else{
        if (self.topViewH +XBottomBarHeight + lf.size.height <250) {
            self.listViewH.constant = 250;
        }else{
            self.listViewH.constant = lf.size.height;
        }
    }
    self.listView.frame = lf;
    [UIView animateWithDuration:0.25f animations:^{
        [self->_backGroundView setFrame:CGRectMake(self->_backGroundView.frame.origin.x, self->viewHeight - XBottomBarHeight-self.topViewH-self.listViewH.constant,self->_backGroundView.frame.size.width, XBottomBarHeight + self.topViewH + self.listViewH.constant)];
    } completion:^(BOOL finished) {
        
    }];
    
    [ZCUIKitTools addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadii:CGSizeMake(8, 8) withView:self.backGroundView];
}

#pragma mark -- tabelView 代理事件
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc]init];
    headerView.frame = CGRectMake(0, 0, ScreenWidth, 11);
    headerView.backgroundColor = UIColor.clearColor;
    return headerView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 11;
    }
    return 0;
}

// 返回section数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [UIView new];
    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

// 返回section下得行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(listArray==nil){
        return 0;
    }
    return listArray.count;
}

// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SobotChatCustomCardInfo *model = listArray[indexPath.row];
    ZCChatAiCustomCardPageCell *cell = (ZCChatAiCustomCardPageCell*)[tableView dequeueReusableCellWithIdentifier:@"ZCChatAiCustomCardPageCell"];
    if (cell == nil) {
        cell = [[ZCChatAiCustomCardPageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatAiCustomCardPageCell"];
    }
    cell.aiCardPageCellBlock = ^(SobotChatCustomCardInfo * _Nonnull model, SobotChatCustomCardMenu * _Nonnull menu, int type) {
        if (type != 2) {
            if (self->_orderSetClickBlock) {
                self->_orderSetClickBlock(self->_megModel,self->_cardModel, model, menu, type);
            }
        }
        [self tappedCancel:YES];
    };
    cell.isHistory = _isHistory;
    [cell initDataToView:model];
    return cell;
}

// 是否显示删除功能
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}


// table 行的点击事件
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
////    ZCLibRobotSet * model = listArray[indexPath.row];
//    if (_orderSetClickBlock) {
//        _orderSetClickBlock(@{});
//    }
//    [self tappedCancel];
//}


- (void)showInView:(UIView *)view{
    [[SobotUITools getCurWindow] addSubview:self];
}

// 隐藏弹出层
- (void)shareViewDismiss:(UITapGestureRecognizer *) gestap{
    CGPoint point = [gestap locationInView:self];
    CGRect f=self.backGroundView.frame;
    if(point.x<f.origin.x || point.x>(f.origin.x+f.size.width) ||
       point.y<f.origin.y || point.y>(f.origin.y+f.size.height)){
        [self tappedCancel:YES];
    }
}

- (void)tappedCancel{
    [self tappedCancel:YES];
}


/**
 *  关闭弹出层
 */
- (void)tappedCancel:(BOOL) isClose{
    // 移除通知
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [UIView animateWithDuration:0.25f animations:^{
        [self.backGroundView setFrame:CGRectMake(_backGroundView.frame.origin.x,viewHeight ,self.backGroundView.frame.size.width,self.backGroundView.frame.size.height)];
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [(ZCPageSheetView *)self.superview.superview  dissmisPageSheet];
        if (finished) {
            [self removeFromSuperview];
        }
    }];
    
}

//-(void)itemClick:(UIButton *)sender{
////    ZCLibRobotSet * model = listArray[sender.tag];
//    if (_orderSetClickBlock) {
//        _orderSetClickBlock(@{});
//    }
//    [self tappedCancel];
//}

#pragma mark -- 手势冲突
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]){
        return NO;
    }
    return YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
