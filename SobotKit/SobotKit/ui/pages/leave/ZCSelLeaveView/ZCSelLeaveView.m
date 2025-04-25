//
//  ZCSelLeaveView.m
//  SobotKit
//
//  Created by lizhihui on 2019/2/19.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCSelLeaveView.h"
#import <SobotCommon/SobotCommon.h>
#import "ZCUIKitTools.h"
#import "ZCSelLeaveViewCell.h"

//#define topViewH  52
/**
 *   新版UI改版
 *   行高22 上下 8 区头8
 *    标题居中 动态高 52
 *    左右不要按钮 点击页面空白取消
 */
@interface ZCSelLeaveView()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>{
    CGFloat viewWidth;
    CGFloat viewHeight;
    NSMutableArray *listArray;
    int _msgId;
    NSInteger isExist;// 记录关闭留言的模式
}
@property (nonatomic,strong) UIView * backGroundView;
@property(nonatomic,strong) UIScrollView *scrollView;
@property(nonatomic,strong)SobotTableView *listView;
@property(nonatomic,strong)NSLayoutConstraint *listViewH;
// 按钮动态高度
@property(nonatomic,assign)CGFloat topViewH;
@end

@implementation ZCSelLeaveView

-(ZCSelLeaveView*)initActionSheet:(NSMutableArray *)array WithView:(UIView *)view MsgID:(int)msgId IsExist:(NSInteger) isExist{
    self = [super init];
    if (self) {
        viewWidth =  ScreenWidth;//view.frame.size.width;
        viewHeight = ScreenHeight;
        _topViewH = 52;
        _msgId = msgId;
        if (!listArray) {
            listArray = [[NSMutableArray alloc]init];
        }
        listArray = array;
        self.frame = CGRectMake(0, 0, viewWidth, viewHeight);
//        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
//        self.autoresizesSubviews = YES;
        self.backgroundColor = UIColorFromModeColorAlpha(SobotColorBlack, 0.6);
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

- (void)createSubviews{
    CGFloat th = [SobotUITools getHeightContain:SobotKitLocalString(@"请选择要留言的业务") font:SobotFont16 Width:viewWidth-32];
    if (th <= 22) {
        th = 22 + 30;
    }else{
        th = th +30;
    }
    self.topViewH = th;
    CGFloat bw=viewWidth;
    // 默认先给一个高度
    self.backGroundView = [[UIView alloc] initWithFrame:CGRectMake((viewWidth - bw) / 2.0, viewHeight, bw, self.topViewH + XBottomBarHeight +0.5)];
    self.backGroundView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
    self.backGroundView.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
    self.backGroundView.layer.masksToBounds = YES;
    [self addSubview:self.backGroundView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setText:SobotKitLocalString(@"请选择要留言的业务")];
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

//    UIView *topline1 = [[UIView alloc]init];
//   topline1.backgroundColor = UIColorFromKitModeColor(SobotColorBgTopLine);
//    [titleLabel addSubview:topline1];
//    [titleLabel addConstraint:sobotLayoutPaddingLeft(0, topline1, titleLabel)];
//    [titleLabel addConstraint:sobotLayoutPaddingRight(0, topline1, titleLabel)];
//    [titleLabel addConstraint:sobotLayoutPaddingBottom(0, topline1, titleLabel)];
//    [titleLabel addConstraint:sobotLayoutEqualHeight(0.5, topline1, NSLayoutRelationEqual)];
    
    // 线条
     UIView *topline = [[UIView alloc]init];
    topline.backgroundColor = UIColorFromKitModeColor(SobotColorBgTopLine);
    [self.backGroundView addSubview:topline];
    [self.backGroundView addConstraint:sobotLayoutMarginTop(0, topline, titleLabel)];
    [self.backGroundView addConstraint:sobotLayoutPaddingLeft(0, topline, self.backGroundView)];
    [self.backGroundView addConstraint:sobotLayoutPaddingRight(0, topline, self.backGroundView)];
    [self.backGroundView addConstraint:sobotLayoutEqualHeight(0.5, topline, NSLayoutRelationEqual)];
    
    // 列表
    _listView = (SobotTableView *)[SobotUITools createTableWithView:self.backGroundView delegate:self];
    [_listView registerClass:[ZCSelLeaveViewCell class] forCellReuseIdentifier:@"ZCSelLeaveViewCell"];
    _listView.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
//    _listView.rowHeight = UITableViewAutomaticDimension;
//    self.listB = sobotLayoutPaddingBottom(-XBottomBarHeight, self.listView, self.view);
//    self.listL = sobotLayoutPaddingLeft(0, self.listView, self.view);
//    self.listR = sobotLayoutPaddingRight(0, self.listView, self.view);
//    self.listY = sobotLayoutPaddingTop(TY, self.listView, self.view);

    [self.backGroundView addConstraint:sobotLayoutMarginTop(0, _listView, topline)];
    NSLayoutConstraint *listPB = sobotLayoutPaddingBottom(-XBottomBarHeight, self.listView, self.backGroundView);
    [self.backGroundView addConstraint:listPB];
    listPB.priority = UILayoutPriorityDefaultHigh;
    [self.backGroundView addConstraint:sobotLayoutPaddingLeft(0, self.listView, self.backGroundView)];
    [self.backGroundView addConstraint:sobotLayoutPaddingRight(0, self.listView, self.backGroundView)];
    self.listViewH = sobotLayoutEqualHeight(0, self.listView, NSLayoutRelationEqual);
    [self.backGroundView addConstraint:self.listViewH];
//    _listView.estimatedRowHeight = 0;
    self.listViewH.constant = CGFLOAT_MAX;
    _listView.estimatedSectionHeaderHeight = 0;
    _listView.estimatedSectionFooterHeight = 0;
//    _listView.backgroundColor = [UIColor clearColor];
//    _listView.frame = CGRectMake(0, 52, viewWidth, viewHeight*0.5);
    _listView.separatorColor = UIColor.clearColor;


    // 左上角的删除按钮
//    UIButton *cannelButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [cannelButton setFrame:CGRectMake(viewWidth - 40, (60 - 30)/2, 30,30)];
//    cannelButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
//    [cannelButton setImage:[SobotUITools getSysImageByName:@"zcicon_sf_close"] forState:UIControlStateNormal];
//    cannelButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    [cannelButton addTarget:self action:@selector(tappedCancel) forControlEvents:UIControlEventTouchUpInside];
//    [self.backGroundView addSubview:cannelButton];
    
//    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 61, bw, 0)];
//    self.scrollView.showsVerticalScrollIndicator=YES;
//    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    self.scrollView.bounces = NO;
//    [self.backGroundView addSubview:self.scrollView];
//    
//    CGFloat x=20;
//    CGFloat y=20;
//    CGFloat itemH = 36;
//    CGFloat itemW = (bw-50)/2.0f;
//    
//    CGFloat styleH1 = 20;// 记录格式1 的初始高度 和最终scrollView需要内容视图高度
//    for (int i=0; i<listArray.count; i++) {
//        ZCWsTemplateModel *skillmodel = listArray[i];
//        ZCWsTemplateModel *nextModel;
//        if ( i%2 == 0) {
//            // 处理样式0
//            if (i+1 <listArray.count) {
//                nextModel = listArray[i+1];
//            }
//            CGFloat leftH = [self getItemMaxHWith:skillmodel withW:itemW];
//            CGFloat rightH = 0;
//            if (!sobotIsNull(nextModel)) {
//                rightH = [self getItemMaxHWith:nextModel withW:itemW];
//            }
//            itemH = leftH >rightH ? leftH :rightH;
//            styleH1 =  styleH1 + itemH + 20;
//        }
//        UIButton *itemView = [self addItemView:listArray[i] withX:x withY:y withW:itemW withH:itemH];
//        itemView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin;
//        [itemView setBackgroundColor:[UIColor whiteColor]];
//        itemView.userInteractionEnabled = YES;
//        itemView.tag = i;
//        [itemView addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
//        if(i%2==1){
//            x = 20;
//            y = y + itemH + 20;
//        }else if(i%2==0){
//            x = itemW + 30;
//        }
//        [self.scrollView addSubview:itemView];
//    }
//    CGFloat h = styleH1;
//    if(h > viewHeight*0.6){
//        h = viewHeight*0.6;
//    }
//    [self.scrollView setFrame:CGRectMake(0, 61, bw, h)];
//    [self.scrollView setContentSize:CGSizeMake(bw, styleH1)];
    
    [_listView reloadData];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self.listView layoutIfNeeded];
    CGRect lf = self.listView.frame;
    lf.size.height = self.listView.contentSize.height;// 20间距是哪里的
    CGFloat listH = 0;
    if (lf.size.height >viewHeight*0.8 - self.topViewH -XBottomBarHeight) {
        listH = viewHeight*0.8 - self.topViewH -XBottomBarHeight;
    }else{
        if (self.topViewH +XBottomBarHeight + lf.size.height <250) {
            listH = 250;
        }else{
            listH = lf.size.height;
        }
    }
    [UIView animateWithDuration:0.25f animations:^{
        [self->_backGroundView setFrame:CGRectMake(self->_backGroundView.frame.origin.x, self->viewHeight - XBottomBarHeight-self.topViewH-listH,self->_backGroundView.frame.size.width, XBottomBarHeight + self.topViewH + listH)];
    } completion:^(BOOL finished) {
        self.listViewH.constant = listH;
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
    return 11;
}

// 返回section数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
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
    ZCWsTemplateModel *model = listArray[indexPath.row];
    ZCSelLeaveViewCell *cell = (ZCSelLeaveViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ZCSelLeaveViewCell"];
    if (cell == nil) {
        cell = [[ZCSelLeaveViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCSelLeaveViewCell"];
    }
    [cell initDataToView:model];
    return cell;
}


// table 行的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZCWsTemplateModel *model = listArray[indexPath.row];
    if (_msgSetClickBlock) {
        _msgSetClickBlock(model);
    }
    [self tappedCancel];
}

#pragma mark - 留言选择弹窗样式 获取最终高度
//-(CGFloat)getItemMaxHWith:(ZCWsTemplateModel *)model withW:(CGFloat)w{
//    UILabel *itemName = [[UILabel alloc] initWithFrame:CGRectZero];
//    [itemName setFont:SobotFont14];
//    [itemName setText:sobotConvertToString(model.templateName)];
//    itemName.numberOfLines = 0;
//    // 单个的高度
//    [itemName setFrame:CGRectMake(8, 8, w-2*8, 36)];
//    [itemName sizeToFit];
//    CGRect NF = itemName.frame;
//    if (NF.size.height >(36 -2*8)) {
//        return NF.size.height + 2*8;
//    }
//    return 36;
//}




//-(UIButton *)addItemView:(ZCWsTemplateModel *) model withX:(CGFloat )x withY:(CGFloat) y withW:(CGFloat) w withH:(CGFloat) h{
//    UIButton *itemView = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w,h)];
//    [itemView setFrame:CGRectMake(x, y, w, h)];
////    itemView.layer.cornerRadius = h/2;
//    itemView.layer.cornerRadius = 18;
//    itemView.layer.masksToBounds = YES;
//    [itemView.titleLabel setFont:SobotFont14];
//    
//    [itemView setTitleColor:[ZCUIKitTools zcgetThemeToWhiteColor] forState:UIControlStateNormal];
//    [itemView setTitleColor:[ZCUIKitTools zcgetTextNolColor] forState:UIControlStateHighlighted];
//    [itemView setTitleColor:[ZCUIKitTools zcgetTextNolColor] forState:UIControlStateSelected];
//    [itemView setBackgroundImage:[SobotImageTools sobotImageWithColor:UIColorFromKitModeColor(SobotColorBgSub)] forState:UIControlStateNormal];
//    [itemView setBackgroundImage:[SobotImageTools sobotImageWithColor:[ZCUIKitTools zcgetCommentButtonLineColor]] forState:UIControlStateSelected];
//    [itemView setBackgroundImage:[SobotImageTools sobotImageWithColor:[ZCUIKitTools zcgetCommentButtonLineColor]] forState:UIControlStateHighlighted];
//    // 设置文字长度 最多20个字 1行显示
//    itemView.titleLabel.numberOfLines = 1;
//    
////    [itemView setTitle:sobotConvertToString(model.templateName) forState:UIControlStateNormal];
////    [itemView setTitle:sobotConvertToString(model.templateName) forState:UIControlStateHighlighted];
//    itemView.titleLabel.textAlignment = NSTextAlignmentCenter;
//    // 设置选中的状态
////    if ([sobotConvertToString(model.robotFlag) intValue] == _msgId) {
////        itemView.selected = YES;
////    }
//    UILabel *tipLab = [[UILabel alloc]initWithFrame:CGRectMake(8, 0, w-2*8, h)];
//    [itemView addSubview:tipLab];
//    tipLab.numberOfLines = 0;
//    tipLab.textAlignment = NSTextAlignmentCenter;
//    tipLab.text = sobotConvertToString(model.templateName);
//    tipLab.font = SobotFont14;
//    tipLab.textColor = [ZCUIKitTools zcgetThemeToWhiteColor];
//    
//    return itemView;
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
    [self.backGroundView setFrame:CGRectMake(_backGroundView.frame.origin.x,viewHeight ,self.backGroundView.frame.size.width,self.backGroundView.frame.size.height)];
    [self removeFromSuperview];
}

-(void)itemClick:(UIButton *)sender{
    ZCWsTemplateModel * model = listArray[sender.tag];
    if (_msgSetClickBlock) {
        _msgSetClickBlock(model);
    }
    [self tappedCancel];
}

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
