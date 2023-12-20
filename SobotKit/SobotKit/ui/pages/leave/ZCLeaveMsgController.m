//
//  ZCLeaveMsgController.m
//  SobotKit
//
//  Created by lizh on 2022/9/5.
//

#import "ZCLeaveMsgController.h"
#import "ZCUIKitTools.h"
#import <SobotCommon/SobotCommon.h>
#import "ZCLeaveEditView.h"
#import "ZCMsgRecordView.h"
#import "ZCMsgDetailsVC.h"
@interface ZCLeaveMsgController ()<UIGestureRecognizerDelegate,UIScrollViewDelegate>
{
    CGRect scFrame  ;
    // 链接点击
    void (^LinkedClickBlock) (NSString *url);
    // 呼叫的电话号码
    NSString *callURL;
    NSMutableArray *imageURLArr;
    CGPoint contentoffset;// 记录list的偏移量
    UIView *btnBgView; // 选项卡
    int  btnTag; // 当前选中的选项卡下标
    UIView *lineView; // 选项卡下面的线条
    UIView * lmsView;// 留言成功后 提示页面
    CGFloat viewWidth;
    CGFloat viewHeight;
    UIInterfaceOrientation fromOrientation;
    CGFloat scrollviewWidth;
    int currentIndex;// 记录当前选中的页面
}

// 留言选项卡
@property (nonatomic,strong) UIButton *leftBtn;
// 留言记录
@property (nonatomic,strong) UIButton *rightBtn;
@property (nonatomic,strong) UIScrollView *mainScrollView;
// 留言编辑view
@property (nonatomic,strong) ZCLeaveEditView *leaveEditView;// 留言编辑页面
@property (nonatomic,strong) ZCMsgRecordView *mesRecordView;//留言记录
@end

@implementation ZCLeaveMsgController


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.mesRecordView loadData];
    // 当从 “您的留言状态有 更新” 进入留言页面 只显示留言记录刷新时 设置选中留言记录页面
    if (self.selectedType == 2) {
        [self itemsClick:self.rightBtn];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [ZCUIKitTools zcgetLightGrayDarkBackgroundColor];
    viewWidth = self.view.frame.size.width;
    viewHeight = self.view.frame.size.height;
//    [ZCUICore getUICore].kitInfo.navcBarHidden = YES;
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }
    [self createVCTitleView];
    [self updateNavOrTopView];

    if(!self.navigationController.navigationBarHidden){
        self.title = SobotKitLocalString(@"留言");
        if (self.selectedType == 2) {
             self.title = SobotKitLocalString(@"留言记录");
        }
    }else{
        self.titleLabel.text = SobotKitLocalString(@"留言");
        if (self.selectedType == 2) {
            self.titleLabel.text = SobotKitLocalString(@"留言记录");
        }
    }
    // 添加选项卡
    [self createTabbarItemView];
    // 获取用户初始化配置参数  添加子页面
    [self customLayoutSubviewsWith:[ZCUICore getUICore].kitInfo];
    
    if([ZCPlatformTools checkLeaveMessageModule]){
        [SobotUITools showAlert:SobotKitLocalString(@"由于服务到期，该功能已关闭。") message:nil cancelTitle:nil viewController:self confirm:^(NSInteger buttonTag) {
            [self goBack];
        } buttonTitles:@[SobotKitLocalString(@"确定")], nil];
    }
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    CGFloat TY = 0;
    if(self.navigationController && sobotIsNull(self.topView)){
        // 当translucent属性为YES的时候，vc的view的坐标从导航栏的左上角开始；
//        当translucent属性为NO的时候，vc的view的坐标从导航栏的左下角开始；
        if (self.navigationController.navigationBar.translucent) {
            TY = NavBarHeight;
        }else{
            TY = 0;
        }
    }else{
        TY = NavBarHeight;
    }
    if (self.ticketShowFlag != 1) {
        btnBgView.hidden = YES;
        self.title = SobotKitLocalString(@"留言记录");
        self.titleLabel.text = SobotKitLocalString(@"留言记录");
//        currentIndex = 1;
    }
    
    // 刷新留言
    [self.leaveEditView refreshViewData];
    
    // 1.获取当前的页面
    NSInteger index = (NSInteger)(btnTag - 2001);
    // 2.计算偏移量
    CGPoint offSetPoint = CGPointMake(index *_mainScrollView.bounds.size.width, 0);
    // 3。将偏移量赋值给scrollerView
    [_mainScrollView setContentOffset:offSetPoint animated:YES];
    // 横竖屏切换的时候重新布局 标题页面
    [self createTabbarItemView];
}

#pragma mark -- 布局子视图 mainScrollView 和 编辑页面、记录
- (void)customLayoutSubviewsWith:(ZCKitInfo *)zcKitInfo{
    // 屏蔽橡皮筋功能
    self.automaticallyAdjustsScrollViewInsets = NO;
//    // 计算Y值
    CGFloat TY = 0;
    if(self.navigationController && sobotIsNull(self.topView)){
        // 当translucent属性为YES的时候，vc的view的坐标从导航栏的左上角开始；
//        当translucent属性为NO的时候，vc的view的坐标从导航栏的左下角开始；
        if (self.navigationController.navigationBar.translucent) {
            TY = NavBarHeight;
        }else{
            TY = 0;
        }
    }else{
        TY = NavBarHeight;
    }
    if (self.ticketShowFlag != 1) {
        btnBgView.hidden = YES;
        self.title = SobotKitLocalString(@"留言记录");
        self.titleLabel.text = SobotKitLocalString(@"留言记录");
        currentIndex = 1;
    }
    CGFloat viewHeigth = viewHeight;
    // 添加滑动控件
    CGFloat scrollHeight = viewHeigth - TY - XBottomBarHeight;
    _mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, TY, ScreenWidth, scrollHeight)];
    [_mainScrollView setContentSize:CGSizeMake(ScreenWidth*2 , scrollHeight)];
    _mainScrollView.pagingEnabled = YES;
    _mainScrollView.delegate = self;
    _mainScrollView.userInteractionEnabled = YES;
    _mainScrollView.scrollEnabled = NO;
    _mainScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _mainScrollView.autoresizesSubviews = YES;
    [self.view addSubview:_mainScrollView];
   
    _leaveEditView = [[ZCLeaveEditView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, scrollHeight) withController:self];
    [_mainScrollView addSubview:_leaveEditView];
    _leaveEditView.ticketTitleShowFlag = _ticketTitleShowFlag;
    _leaveEditView.tickeTypeFlag = _tickeTypeFlag;
    _leaveEditView.typeArr = _typeArr;
    _leaveEditView.ticketTypeId = _ticketTypeId;
    _leaveEditView.msgTmp = _msgTmp;
    _leaveEditView.msgTxt = _msgTxt;
    _leaveEditView.templateldIdDic = _templateldIdDic;
    _leaveEditView.emailFlag = _emailFlag;
    _leaveEditView.emailShowFlag = _emailShowFlag;
    _leaveEditView.telFlag = _telFlag;
    _leaveEditView.telShowFlag = _telShowFlag;
    _leaveEditView.enclosureFlag = _enclosureFlag;
    _leaveEditView.enclosureShowFlag = _enclosureShowFlag;
    _leaveEditView.coustomArr = _coustomArr;
    __weak ZCLeaveMsgController *safeSelf = self;
    [_leaveEditView setPageChangedBlock:^(id  _Nonnull object, int code) {
        //code==1 添加成功,code == 2点击完成，跳转页面
        if(code == 3001 && self->_selectedType!=2){
            [safeSelf goBack];
        }
        if(code == 3002){
            [safeSelf itemsClick:safeSelf.rightBtn];
        }
    }];
    [_leaveEditView loadCustomFields];
    
    // 留言记录
    _mesRecordView = [[ZCMsgRecordView alloc] initWithFrame:CGRectMake(viewWidth, 0, viewWidth, scrollHeight) withController:self];
    [_mainScrollView addSubview:_mesRecordView];
    [_mesRecordView updataWithHeight:scrollHeight viewWidth:self.view.frame.size.width];
    _mesRecordView.jumpMsgDetailBlock = ^(ZCRecordListModel *model) {
        ZCMsgDetailsVC * detailVC = [[ZCMsgDetailsVC alloc]init];
        detailVC.ticketId = model.ticketId;
        detailVC.leaveMsgController = safeSelf;
        detailVC.companyId = sobotConvertToString([SobotCache getLocalParamter:Sobot_CompanyId]);
        if (safeSelf.navigationController!= nil) {
            [safeSelf.navigationController pushViewController:detailVC animated:YES];
        }else{
            UINavigationController * navc = [[UINavigationController alloc]initWithRootViewController: detailVC];
            // 设置动画效果
            navc.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [safeSelf presentViewController:navc animated:YES completion:^{

            }];
        }
    };
}
#pragma mark - 顶部选项卡
-(void)createTabbarItemView{
    
    CGFloat Y = 20;
    if (self.navigationController.navigationBarHidden) {
        Y = sobotIsIPhoneX()?40:20;
    }
    if(self.topView!=nil){
        Y = NavBarHeight - 44;
    }
    
    NSMutableArray * titleArr = [NSMutableArray arrayWithCapacity:0];
    [titleArr addObject:SobotKitLocalString(@"请您留言")];
    [titleArr addObject:SobotKitLocalString(@"留言记录")];
    NSMutableArray * tagArr = [NSMutableArray arrayWithCapacity:0];
    [tagArr addObject:@"2001"];
    [tagArr addObject:@"2002"];
    [self createBtnItem:titleArr withTags:tagArr Y:Y];
    if (self.ticketShowFlag == 0) {
        return;
    }
    if(self.navigationController.navigationBarHidden){
        [self.topView addSubview:btnBgView];
        self.titleLabel.hidden = YES;
        [self.topView addConstraint:sobotLayoutPaddingBottom(0,btnBgView, self.topView)];
        [self.topView addConstraint:sobotLayoutPaddingLeft(64, btnBgView, self.topView)];
        [self.topView addConstraint:sobotLayoutPaddingRight(-64, btnBgView, self.topView)];
        [self.topView addConstraint:sobotLayoutEqualHeight(44, btnBgView, NSLayoutRelationEqual)];
//        [self.topView addConstraint:sobotLayoutEqualCenterY(0, btnBgView, self.topView)];
    }else{
         self.navigationItem.titleView = btnBgView;
    }
}
#pragma mark - 创建顶部选项卡
-(void)createBtnItem:(NSMutableArray *)titleArr withTags:(NSMutableArray *)tagArr Y:(CGFloat)Y{
    if (btnBgView!= nil) {
        [btnBgView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    CGFloat maxWidth = ScreenWidth - 64*2;
    btnBgView = [[UIView alloc]initWithFrame:CGRectMake(64, Y, maxWidth, 44)];
    btnBgView.backgroundColor = [UIColor clearColor];
    if (sobotIsNull(self.topView)) {
        // 系统导航栏 会根据内容大小去布局
        UILabel *topView = [[UILabel alloc]init];
        topView.numberOfLines = 0;
        topView.text = @"                                                                                                                                                                    ";
        topView.textColor = [UIColor clearColor];
        [btnBgView addSubview:topView];
        topView.backgroundColor = [UIColor clearColor];
        [btnBgView addConstraint:sobotLayoutPaddingTop(0, topView, btnBgView)];
        [btnBgView addConstraint:sobotLayoutPaddingLeft(0, topView, btnBgView)];
        [btnBgView addConstraint:sobotLayoutPaddingRight(0, topView, btnBgView)];
        [btnBgView addConstraint:sobotLayoutEqualHeight(44, topView, NSLayoutRelationEqual)];
        [btnBgView addConstraint:sobotLayoutPaddingBottom(0, topView, btnBgView)];
    }
    
    CGFloat BW = maxWidth/2;
    CGFloat BH = 21;
    CGFloat BX = 0;
    for (int i = 0; i< titleArr.count; i++) {
        int tag = [tagArr[i] intValue];
        if(i==1){
            BX = maxWidth - BW;
        }else{
            BX = 0;
        }
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = tag;
        [btn setTitle:titleArr[i] forState:UIControlStateNormal];
        [btn setTitle:titleArr[i] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(itemsClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.titleLabel.font = [ZCUIKitTools zcgetSubTitleFont];;
        [btn setTitleColor:[ZCUIKitTools zcgetLeaveTitleTextColor] forState:UIControlStateNormal];
        [btn setTitleColor:[ZCUIKitTools zcgetLeaveTitleTextColor] forState:UIControlStateHighlighted];
        [btn setTitleColor:[ZCUIKitTools zcgetLeaveTitleTextColor] forState:UIControlStateSelected];
        btn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [btnBgView addSubview:btn];
        if(i == 0 ){
//            [btnBgView addConstraint:sobotLayoutPaddingBottom(-5, btn, btnBgView)];
            [btnBgView addConstraint:sobotLayoutEqualWidth(BW-8, btn, NSLayoutRelationEqual)];
            [btnBgView addConstraint:sobotLayoutEqualHeight(BH, btn, NSLayoutRelationEqual)];
            [btnBgView addConstraint:sobotLayoutEqualCenterX(-BW/2, btn, btnBgView)];
            [btnBgView addConstraint:sobotLayoutEqualCenterY(0, btn, btnBgView)];
        }else{
//            [btnBgView addConstraint:sobotLayoutPaddingBottom(-5, btn, btnBgView)];
            [btnBgView addConstraint:sobotLayoutEqualWidth(BW -8, btn, NSLayoutRelationEqual)];
            [btnBgView addConstraint:sobotLayoutEqualHeight(BH, btn, NSLayoutRelationEqual)];
            [btnBgView addConstraint:sobotLayoutEqualCenterX(BW/2 +8, btn, btnBgView)];
            [btnBgView addConstraint:sobotLayoutEqualCenterY(0, btn, btnBgView)];
        }
        
        if (i == 0) {
            self.leftBtn = btn;
        }else if(i == 1){
            self.rightBtn = btn;
        }
        if(btnTag == tag){
            btn.selected = YES;
        }else if(btnTag == 0 && i == 0){
            btn.selected = YES;
        }
//        [SobotUITools setRTLFrame:btn];
    }
    btnTag = [[tagArr firstObject] intValue];
    lineView = [[UIView alloc]initWithFrame:CGRectMake(11, 41-5, 20, 3)];
    lineView.backgroundColor = [ZCUIKitTools zcgetLeaveTitleTextColor];//[ZCUIKitTools zcgetServerConfigBtnBgColor];
    lineView.layer.cornerRadius = 1.5f;
    lineView.layer.masksToBounds = YES;
    [btnBgView addSubview:lineView];
    [btnBgView addConstraint:sobotLayoutEqualHeight(3, lineView, NSLayoutRelationEqual)];
    [btnBgView addConstraint:sobotLayoutEqualWidth(20, lineView, NSLayoutRelationEqual)];
    [btnBgView addConstraint:sobotLayoutPaddingBottom(-2, lineView, btnBgView)];
    [btnBgView addConstraint:sobotLayoutEqualCenterX(-BW/2, lineView, btnBgView)];
}
#pragma mark - 留言记录和留言编辑点击事件页面切换
-(void) itemsClick:(UIButton *)sender{
    [self hideKeyBoard];
    if(lmsView!=nil){
        lmsView.hidden = YES;
    }
//    if (btnTag == sender.tag) {
//        return;
//    }
    if(sender.tag == self.rightBtn.tag){
        [_mesRecordView loadData];
        currentIndex = 1;
    }
    if(sender.tag == self.leftBtn.tag){
        _leftBtn.selected = YES;
        _rightBtn.selected = NO;
        currentIndex = 0;
    }else{
        _leftBtn.selected = NO;
        _rightBtn.selected = YES;
    }
    CGRect LF = lineView.frame;
    LF.origin.x = sender.frame.origin.x + sender.frame.size.width/2 - 10;
    lineView.frame = LF;
    btnTag = (int)sender.tag;
    [self.navigationItem.titleView setNeedsDisplay];
    // 1.获取当前的页面
    NSInteger index = (NSInteger)(sender.tag - 2001);
    // 2.计算偏移量
    CGPoint offSetPoint = CGPointMake(index *_mainScrollView.bounds.size.width, 0);
    // 3。将偏移量赋值给scrollerView
    [_mainScrollView setContentOffset:offSetPoint animated:YES];
}

#pragma mark - 顶部按钮点击事件
-(void)buttonClick:(UIButton *)sender{
    if(sender){
        if(sender.tag == SobotButtonClickBack){
            [self.leaveEditView destoryViews];
            self.leaveEditView = nil;
            [self goBack];
        }
    }
}

#pragma mark -  layoutsubviews 重新设置高度
-(void)viewSafeAreaInsetsDidChange{
    [super viewSafeAreaInsetsDidChange];
    scrollviewWidth = self.view.frame.size.width;
    viewHeight = self.view.frame.size.height;
    UIEdgeInsets e = self.view.safeAreaInsets;

    CGFloat TY = 0;
    if(self.navigationController && sobotIsNull(self.topView)){
        if (self.navigationController.navigationBar.translucent) {
            TY = NavBarHeight;
        }else{
            TY = 0;
        }
    }else{
        TY = NavBarHeight;
    }
    CGFloat H = viewHeight - TY - XBottomBarHeight;
    CGRect page1F = self.leaveEditView.frame;
    CGRect page2F = self.mesRecordView.frame;
    CGRect scrollviewF = self.mainScrollView.frame;
    page1F.size.height = H;
    page2F.size.height = H;
    scrollviewF.size.height = H;
    scrollviewF.origin.y = TY;
    scrollviewWidth = scrollviewWidth - (e.left>0 ? e.left*2 : 0);
    scrollviewF.size.width = scrollviewWidth;
    scrollviewF.origin.x = e.left > 0 ? e.left : 0;
    [self.mainScrollView setFrame:scrollviewF];
    page1F.size.width = scrollviewWidth;
    page1F.origin.x = 0;
    page2F.size.width = scrollviewWidth;
    page2F.origin.x = scrollviewWidth;
    [self.leaveEditView setFrame:page1F];
    [self.mesRecordView setFrame:page2F];
    [self.mainScrollView setContentSize:CGSizeMake(scrollviewWidth*2, 0)];
    
    // 重新布局顶部选项卡
    [self createTabbarItemView];

    // 横竖屏更新导航栏渐变色
    [self updateTopViewBgColor];
    // 解决约束 比frame设置慢的问题
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self->currentIndex == 0) {
            [self itemsClick:self.leftBtn];
        }else{
            [self itemsClick:self.rightBtn];
        }
    });
    
//    if (self.leaveEditView.successView != nil) {
//        [self.leaveEditView removeAddLeaveMsgSuccessView];
//    }
}


#pragma mark - 更新导航栏
-(void)updateNavOrTopView{
    // 统计 系统导航栏上面的按钮
    NSMutableArray *rightItem = [NSMutableArray array];
    NSMutableDictionary *navItemSource = [NSMutableDictionary dictionary];
    [rightItem addObject:@(SobotButtonClickBack)];
    [navItemSource setObject:@{@"img":@"zcicon_titlebar_back_normal",@"imgsel":sobotConvertToString([ZCUICore getUICore].kitInfo.topBackNolImg)} forKey:@(SobotButtonClickBack)];
    // 更新系统导航栏的按钮
    self.navItemsSource = navItemSource;
    [self setLeftTags:rightItem rightTags:@[] titleView:nil];
    if (!self.navigationController.navigationBarHidden) {
        if([ZCUIKitTools getZCThemeStyle] == SobotThemeMode_Light){
            if(sobotGetSystemDoubleVersion() >= 13){
                self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
                self.navigationController.toolbar.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
            }
        }
    }else{
        self.moreButton.hidden = YES;
        self.titleLabel.hidden = NO;
        self.backButton.hidden = NO;
        self.bottomLine.hidden = YES;
        // 这里需要 设置自定义titleView 选项卡
        [self createTabbarItemView];
    }
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

-(void)dealloc{
    NSLog(@" 留言页面 dealloc ----");
}


@end
