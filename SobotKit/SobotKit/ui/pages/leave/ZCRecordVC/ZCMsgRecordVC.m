//
//  ZCMsgRecordVC.m
//  SobotKit
//
//  Created by lizh on 2025/3/9.
//

#import "ZCMsgRecordVC.h"
#import "ZCMsgRecordView.h"
#import "ZCUIKitTools.h"
#import <SobotCommon/SobotCommon.h>
#import "ZCMsgDetailsVC.h"
@interface ZCMsgRecordVC ()
{
    CGFloat viewWidth;
    CGFloat viewHeight;
}
@property (nonatomic,strong) ZCMsgRecordView *mesRecordView;//留言记录
@end

@implementation ZCMsgRecordVC

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }
    [self.mesRecordView loadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    viewWidth = self.view.frame.size.width;
    viewHeight = self.view.frame.size.height;
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }
    
    // 处理异常
    [self createVCTitleView];
    [self updateNavOrTopView];

    if(!self.navigationController.navigationBarHidden){
        self.title = SobotKitLocalString(@"留言记录");
    }else{
        self.titleLabel.text = SobotKitLocalString(@"留言记录");
    }
    // 获取用户初始化配置参数  添加子页面
    [self customLayoutSubviewsWith:[ZCUICore getUICore].kitInfo];
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

    self.title = SobotKitLocalString(@"留言记录");
    self.titleLabel.text = SobotKitLocalString(@"留言记录");
    CGFloat viewHeigth = viewHeight;
    // 添加滑动控件
    CGFloat scrollHeight = viewHeigth - TY - XBottomBarHeight;
    // 留言记录
    _mesRecordView = [[ZCMsgRecordView alloc] initWithFrame:CGRectMake(0, TY, viewWidth, scrollHeight) withController:self];
    [self.view addSubview:_mesRecordView];
    __weak ZCMsgRecordVC *safeSelf = self;
    [_mesRecordView updataWithHeight:scrollHeight viewWidth:self.view.frame.size.width];
    _mesRecordView.jumpMsgDetailBlock = ^(ZCRecordListModel *model) {
        ZCMsgDetailsVC * detailVC = [[ZCMsgDetailsVC alloc]init];
        detailVC.ticketId = model.ticketId;
//        detailVC.leaveMsgController = safeSelf;
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

#pragma mark - 顶部按钮点击事件
-(void)buttonClick:(UIButton *)sender{
    if(sender){
        if(sender.tag == SobotButtonClickBack){
            [self goBack];
        }
    }
}

#pragma mark -  layoutsubviews 重新设置高度
-(void)viewSafeAreaInsetsDidChange{
    [super viewSafeAreaInsetsDidChange];
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
    CGRect page2F = self.mesRecordView.frame;
    page2F.origin.y = TY;
    page2F.size.height = H;
    page2F.size.width = ScreenWidth;
    [self.mesRecordView setFrame:page2F];
    // 横竖屏更新导航栏渐变色
    [self updateTopViewBgColor];
}


#pragma mark - 更新导航栏
-(void)updateNavOrTopView{
    // 统计 系统导航栏上面的按钮
    NSMutableArray *rightItem = [NSMutableArray array];
    NSMutableDictionary *navItemSource = [NSMutableDictionary dictionary];
    [rightItem addObject:@(SobotButtonClickBack)];
    NSString *backimg = @"zcicon_titlebar_back_normal";
//    if ( [[ZCLibClient getZCLibClient].libInitInfo.absolute_language  hasPrefix: @"ar"]) {
//        backimg = @"zcicon_titlebar_back_normal_ar";
//    }
    [navItemSource setObject:@{@"img":backimg,@"imgsel":sobotConvertToString([ZCUICore getUICore].kitInfo.topBackNolImg)} forKey:@(SobotButtonClickBack)];
    // 更新系统导航栏的按钮
    self.navItemsSource = navItemSource;
//    [self setLeftTags:rightItem rightTags:@[] titleView:nil];
    
    if ([ZCUIKitTools getSobotIsRTLLayout]) {
        [self setLeftTags:@[] rightTags:rightItem titleView:nil];
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
        self.moreButton.hidden = YES;
        self.titleLabel.hidden = NO;
        self.backButton.hidden = NO;
        self.bottomLine.hidden = YES;
        // 这里需要 设置自定义titleView 选项卡
//        [self createTabbarItemView];
    }
}


@end
