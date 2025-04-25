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
#import "ZCMsgRecordVC.h"
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
//@property (nonatomic,strong) ZCMsgRecordView *mesRecordView;//留言记录

@property(nonatomic,strong) NSLayoutConstraint *lineViewCX;
@end

@implementation ZCLeaveMsgController


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        [self.navigationController setNavigationBarHidden:YES animated:animated];
    }
//    [self.mesRecordView loadData];
//    // 当从 “您的留言状态有 更新” 进入留言页面 只显示留言记录刷新时 设置选中留言记录页面
//    if (self.selectedType == 2) {
//        [self itemsClick:self.rightBtn];
//    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1); 
    viewWidth = self.view.frame.size.width;
    viewHeight = self.view.frame.size.height;
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }
    [self createVCTitleView];
    [self updateNavOrTopView];

    if(!self.navigationController.navigationBarHidden){
        self.title = SobotKitLocalString(@"请您留言");
//        if (self.selectedType == 2) {
//             self.title = SobotKitLocalString(@"留言记录");
//        }
    }else{
        self.titleLabel.text = SobotKitLocalString(@"请您留言");
//        if (self.selectedType == 2) {
//            self.titleLabel.text = SobotKitLocalString(@"留言记录");
//        }
    }
    // 添加选项卡
//    [self createTabbarItemView];
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
    viewHeight = self.view.frame.size.height;
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
    
    CGFloat scrollHeight = viewHeight - TY - XBottomBarHeight;
    CGRect mainSF = _mainScrollView.frame;
    mainSF.size.height = scrollHeight;
    _mainScrollView.frame = mainSF;
    
    CGRect leaveEditF = _leaveEditView.frame;
    leaveEditF.size.height = scrollHeight;
    _leaveEditView.frame = leaveEditF;
    // 刷新留言
    [self.leaveEditView refreshViewData];
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
    CGFloat viewHeigth = viewHeight;
    // 添加滑动控件
    CGFloat scrollHeight = viewHeigth - TY - XBottomBarHeight;
    _mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, TY, ScreenWidth, scrollHeight)];
    [_mainScrollView setContentSize:CGSizeMake(ScreenWidth*1 , scrollHeight)];
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
    _leaveEditView.ticketContentFillFlag = _ticketContentFillFlag;
    _leaveEditView.ticketContentShowFlag = _ticketContentShowFlag;
    __weak ZCLeaveMsgController *safeSelf = self;
    [_leaveEditView setPageChangedBlock:^(id  _Nonnull object, int code) {
        //code==1 添加成功,code == 2点击完成，跳转页面
        if(code == 3001 && self->_selectedType!=2){
            [safeSelf goBack];
        }
        if(code == 3002){
//            [safeSelf itemsClick:safeSelf.rightBtn];
            [safeSelf openMsgRecordPage];
        }
    }];
    [_leaveEditView loadCustomFields];
}


#pragma mark - 留言记录和留言编辑点击事件页面切换
-(void) itemsClick:(UIButton *)sender{
    [self hideKeyBoard];
    if(lmsView!=nil){
        lmsView.hidden = YES;
    }
}
#pragma mark -- 前往留言记录
-(void)openMsgRecordPage{
    ZCMsgRecordVC *recordVC = [[ZCMsgRecordVC alloc]init];
    if (self.navigationController!= nil) {
        [self.navigationController pushViewController:recordVC animated:YES];
    }else{
        UINavigationController * navc = [[UINavigationController alloc]initWithRootViewController: recordVC];
        // 设置动画效果
        navc.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:navc animated:YES completion:^{

        }];
    }
}

#pragma mark - 顶部按钮点击事件
-(void)buttonClick:(UIButton *)sender{
    if(sender){
        if(sender.tag == SobotButtonClickBack){
            [self.leaveEditView destoryViews];
            self.leaveEditView = nil;
            if([ZCUICore getUICore].ZCViewControllerCloseBlock != nil){
                [ZCUICore getUICore].ZCViewControllerCloseBlock(self,ZC_CloseLeave);
            }
            [self goBack];
        }else if (sender.tag == SobotButtonClickRight){
            [self openMsgRecordPage];
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
    CGRect scrollviewF = self.mainScrollView.frame;
    page1F.size.height = H;
    scrollviewF.size.height = H;
    scrollviewF.origin.y = TY;
    scrollviewWidth = scrollviewWidth - (e.left>0 ? e.left*2 : 0);
    scrollviewF.size.width = scrollviewWidth;
    scrollviewF.origin.x = e.left > 0 ? e.left : 0;
    [self.mainScrollView setFrame:scrollviewF];
    page1F.size.width = scrollviewWidth;
    page1F.origin.x = 0;
    [self.leaveEditView setFrame:page1F];
    [self.mainScrollView setContentSize:CGSizeMake(scrollviewWidth*1, 0)];
    // 横竖屏更新导航栏渐变色
    [self updateTopViewBgColor];
    // 解决约束 比frame设置慢的问题
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        if (self->currentIndex == 0) {
//            [self itemsClick:self.leftBtn];
//        }else{
//            [self itemsClick:self.rightBtn];
//        }
//    });
    
    if (self.leaveEditView.successView != nil) {
        [self.leaveEditView removeAddLeaveMsgSuccessView];
    }
}


#pragma mark - 更新导航栏
-(void)updateNavOrTopView{
    // 统计 系统导航栏上面的按钮
    NSMutableArray *rightItem = [NSMutableArray array];
    NSMutableDictionary *navItemSource = [NSMutableDictionary dictionary];
    [rightItem addObject:@(SobotButtonClickBack)];
    [navItemSource setObject:@{@"img":@"zcicon_titlebar_back_normal",@"imgsel":sobotConvertToString([ZCUICore getUICore].kitInfo.topBackNolImg)} forKey:@(SobotButtonClickBack)];
    [navItemSource setObject:@{@"img":@"zcicon_leave_more",@"imgsel":@"zcicon_leave_more"} forKey:@(SobotButtonClickRight)];
    // 更新系统导航栏的按钮
    self.navItemsSource = navItemSource;
    if ([ZCUIKitTools getSobotIsRTLLayout]) {
        [self setLeftTags:@[@(SobotButtonClickRight)] rightTags:rightItem titleView:nil];
    }else{
        [self setLeftTags:rightItem rightTags:@[@(SobotButtonClickRight)] titleView:nil];
    }
    if (!self.navigationController.navigationBarHidden) {
        if([ZCUIKitTools getZCThemeStyle] == SobotThemeMode_Light){
            if(sobotGetSystemDoubleVersion() >= 13){
                self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
                self.navigationController.toolbar.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
            }
        }
    }else{
        self.moreButton.hidden = NO;
        self.titleLabel.hidden = NO;
        self.backButton.hidden = NO;
        self.bottomLine.hidden = YES;
        // 这里需要 设置自定义titleView 选项卡
//        [self createTabbarItemView];
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
