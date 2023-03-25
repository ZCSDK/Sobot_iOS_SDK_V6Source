//
//  ZCChatController.m
//  SobotChatClient
//
//  Created by zhangxy on 2022/8/30.
//

#import "ZCChatController.h"
#import "ZCUICore.h"
#import "ZCChatView.h"
#import "ZCLeaveMsgController.h"
#import "ZCUICore.h"
#import "ZCUIAskTableController.h"
#import "ZCUIEvaluateView.h"
#import <SobotChatClient/SobotChatClient.h>
#import "ZCTitleView.h"
#import "ZCUIKitTools.h"
#import "ZCUIWebController.h"
#import <SobotCommon/SobotCommon.h>
@interface ZCChatController ()<ZCChatViewDelegate,SobotActionSheetViewDelegate>
@property(nonatomic,strong) ZCChatView *chatView;
@property(nonatomic,strong) ZCTitleView *titleView;

@property (nonatomic,strong)NSLayoutConstraint *listR;
@property (nonatomic,strong)NSLayoutConstraint *listB;
@property (nonatomic,strong)NSLayoutConstraint *listY;
@property (nonatomic,strong)NSLayoutConstraint *listL;

@end

@implementation ZCChatController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [ZCUICore getUICore].kitInfo.navcBarHidden = YES;
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [ZCUIKitTools zcgetChatBackgroundColor];
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }
    // 统一使用common的方式先创建导航栏控件
    [self createVCTitleView];
    // 更新 系统导航栏或者自定义导航栏 自定义的使用的是本地的
    [self updateNavOrTopView];
    _chatView = [[ZCChatView alloc] init];
    _chatView.backgroundColor = [ZCUIKitTools zcgetChatBackgroundColor];
    _chatView.delegate = self;
    [self.view addSubview:_chatView];
    self.listB = sobotLayoutPaddingBottom(-XBottomBarHeight, self.chatView, self.view);
    self.listL = sobotLayoutPaddingLeft(0, self.chatView, self.view);
    self.listR = sobotLayoutPaddingRight(0, self.chatView, self.view);
    if(self.navigationController && sobotIsNull(self.topView)){
        // 当translucent属性为YES的时候，vc的view的坐标从导航栏的左上角开始；
//        当translucent属性为NO的时候，vc的view的坐标从导航栏的左下角开始；
        if (self.navigationController.navigationBar.translucent) {
            self.listY = sobotLayoutPaddingTop(NavBarHeight, self.chatView, self.view);
        }else{
            self.listY = sobotLayoutPaddingTop(0, self.chatView, self.view);
        }
    }else{
        self.listY = sobotLayoutPaddingTop(NavBarHeight, self.chatView, self.view);
    }
    [self.view addConstraint:self.listY];
    [self.view addConstraint:self.listB];
    [self.view addConstraint:self.listL];
    [self.view addConstraint:self.listR];
    //    // 执行一次，确定chatView的大小
    [_chatView layoutIfNeeded];
    
    // 加载实际view内容
    [_chatView loadDataToView];
    
//    [self.titleView setNickTitle:@"客服昵称" companyTitle:@"北京智齿博创科技有限公司" title:@"" image:@""];    
}


// 适配iOS 13以上的横竖屏切换
-(void)viewSafeAreaInsetsDidChange{
    [super viewSafeAreaInsetsDidChange];
    UIEdgeInsets e = self.view.safeAreaInsets;
    [self.view removeConstraint:self.listB];
    [self.view removeConstraint:self.listL];
    [self.view removeConstraint:self.listR];
    [self.view removeConstraint:self.listY];
    if(self.titleViewEH){
        [self.topView removeConstraint:self.titleViewEH];
    }
    if(e.left > 0){
        CGFloat y ;
        if ([ZCUICore getUICore].kitInfo.navcBarHidden || self.topView) {
            y = NavBarHeight;
            self.listY = sobotLayoutPaddingTop(y, _chatView, self.view);
        }else{
            self.listY = sobotLayoutPaddingTop(e.top, _chatView, self.view);
        }
        self.listL = sobotLayoutPaddingLeft(e.left, _chatView, self.view);
        self.listR = sobotLayoutPaddingRight(-e.right, _chatView, self.view);
        self.listB = sobotLayoutPaddingBottom(-e.bottom, _chatView, self.view);
        self.titleViewEH = sobotLayoutEqualHeight(32, _titleView, NSLayoutRelationEqual);
    }else{
        CGFloat y ;
        if(self.navigationController && self.topView==nil){
            if (self.navigationController.navigationBar.translucent) {
                y = NavBarHeight;
            }else{
                y = 0;
            }
        }else{
            y = NavBarHeight;
        }
        self.listY = sobotLayoutPaddingTop(y, _chatView, self.view);
        self.listL = sobotLayoutPaddingLeft(0, _chatView, self.view);
        self.listR = sobotLayoutPaddingRight(0, _chatView, self.view);
        self.listB = sobotLayoutPaddingBottom(-e.bottom, _chatView, self.view);
        self.titleViewEH = sobotLayoutEqualHeight(44, _titleView, NSLayoutRelationEqual);
    }
    [self.view addConstraint:self.listL];
    [self.view addConstraint:self.listR];
    [self.view addConstraint:self.listB];
    [self.view addConstraint:self.listY];

    // 横竖屏更新导航栏渐变色
    [self updateTopViewBgColor];
    if (_titleView) {
        [_titleView setlayout:e.left > 0 ? YES: NO];
    }
    [self.topView addConstraint:self.titleViewEH];
}


-(void)buttonClick:(UIButton *)sender{
    if(sender){
        if(sender.tag == SobotButtonClickClose){
            [self.chatView closeChatView:YES];
        }
        if(sender.tag == SobotButtonClickBack){
            // 返回提醒开关
            if ([ZCUICore getUICore].kitInfo.isShowReturnTips) {
                [self.view endEditing:YES];
                __weak ZCChatController *weakSelf = self;
               [SobotUITools showAlert:SobotKitLocalString(@"您是否要结束会话?") message:nil cancelTitle:SobotKitLocalString(@"暂时离开") titleArray:@[SobotKitLocalString(@"结束会话")] viewController:self  confirm:^(NSInteger buttonTag) {
                   if(buttonTag >= 0){
                       // 点击关闭，离线用户
                       [weakSelf.chatView closeChatView:YES];
                   }else{
                       [weakSelf.chatView closeChatView:NO];
                   }
               }];
                return;
            }else{
                [self.chatView closeChatView:NO];
            }
        }
        if (sender.tag == SobotButtonClickEvaluate) {
            // 评价
            [[ZCUICore getUICore] keyboardOnClickSatisfacetion:NO];
        }
        if (sender.tag == SobotButtonClickClose) {
            // 关闭
            [self.chatView closeChatView:YES];
        }
        if (sender.tag == SobotButtonClickTEL) {
            // 电话
            if([ZCUICore getUICore].ZCViewControllerCloseBlock != nil){
                [ZCUICore getUICore].ZCViewControllerCloseBlock(self,ZC_PhoneCustomerService);
            }
            NSString *phoneNumber = [NSString stringWithFormat:@"tel:%@",sobotConvertToString([ZCUICore getUICore].kitInfo.customTel)];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
        }
        if (sender.tag == SobotButtonClickRight) {
            // 删除历史记录
//            SobotActionSheetView *mysheet = [[SobotActionSheetView alloc]initWithDelegate:self title:@"" CancelTitle:SobotKitLocalString(@"取消") OtherTitles:SobotKitLocalString(@"清空聊天记录"), nil];
//            mysheet.selectIndex = 1;
//            [mysheet show];
            
            [SobotUITools showAlert:SobotKitLocalString(@"清空聊天记录") message:nil cancelTitle:SobotKitLocalString(@"取消") titleArray:@[SobotKitLocalString(@"确定")] viewController:self  confirm:^(NSInteger buttonTag) {
                if(buttonTag >= 0){
                    // 点击关闭，离线用户
                    [SobotUITools showAlert:nil message:SobotKitLocalString(@"清空记录将无法恢复,是否要清空历史记录？") cancelTitle:SobotKitLocalString(@"取消") viewController:nil confirm:^(NSInteger buttonTag) {
                        if(buttonTag == 0){
                            // 清空历史记录
                            [[ZCUICore getUICore].chatMessages removeAllObjects];
                            [self.chatView roadData];
                            [ZCLibServer cleanHistoryMessage:[self getZCIMConfig].uid success:^(NSData *data) {
                                
                            } fail:^(ZCNetWorkCode errorCode) {
                                
                            }];
                        }
                    } buttonTitles:SobotKitLocalString(@"清空"), nil];
                }
            }];            
        }
    }
}

/**
 更换标题
 */
-(void)onTitleChanged:(NSString *)title imageUrl:(NSString *)url nick:(NSString *)nick company:(NSString *)company topBarType:(int)topBarType{
    [self.titleView setNickTitle:nick companyTitle:company title:title image:url topBarType:topBarType];
}


- (void)onPageStatusChange:(BOOL)isArtificial{
    if(self.isArtificial == isArtificial){
        return;
    }
    self.isArtificial = isArtificial;
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }else{
//        [self setNavigationBarStyle];
        // 更新系统导航栏
    }
}

#pragma mark - 获取config
-(ZCLibConfig *)getZCIMConfig{
    return [self getPlatformInfo].config;
}

-(ZCPlatformInfo *) getPlatformInfo{
    return [[ZCPlatformTools sharedInstance] getPlatformInfo];
}

#pragma mark - 清空历史记录事件
- (void)actionSheet:(SobotActionSheetView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 2) {
        [SobotUITools showAlert:nil message:SobotKitLocalString(@"清空记录将无法恢复,是否要清空历史记录？") cancelTitle:SobotKitLocalString(@"取消") viewController:nil confirm:^(NSInteger buttonTag) {
            if(buttonTag == 0){
                // 清空历史记录
                [[ZCUICore getUICore].chatMessages removeAllObjects];
//                _isNoMore = NO;
                [self.chatView roadData];
                [ZCLibServer cleanHistoryMessage:[self getZCIMConfig].uid success:^(NSData *data) {
                    
                } fail:^(ZCNetWorkCode errorCode) {
                    
                }];
            }
        } buttonTitles:SobotKitLocalString(@"清空"), nil];
    }
}

-(void) onBackFinish:(BOOL)isAction closeClick:(BOOL)isClose{
    if(isClose){
        [ZCLibClient closeAndoutZCServer:NO];
    }
    if(isAction){
        [_chatView backChatView];
        [self goBack];
    }
}

#pragma mark - 更新系统或者自定义导航栏
-(void)updateNavOrTopView{
    // 测试代码
//    [ZCUICore getUICore].kitInfo.isShowEvaluation = YES;
//    [ZCUICore getUICore].kitInfo.isShowTelIcon = YES;
//    [ZCUICore getUICore].kitInfo.isShowClose = YES;
    
    // 统计 系统导航栏上面的按钮
    NSMutableArray *rightItem = [NSMutableArray array];
    NSMutableDictionary *navItemSource = [NSMutableDictionary dictionary];
    [rightItem addObject:@(SobotButtonClickBack)];
    [navItemSource setObject:@{@"img":@"zcicon_titlebar_back_normal",@"imgsel":sobotConvertToString([ZCUICore getUICore].kitInfo.topBackNolImg)} forKey:@(SobotButtonClickBack)];
    if(![ZCUICore getUICore].kitInfo.hideNavBtnMore){
        [rightItem addObject:@(SobotButtonClickRight)];
        [navItemSource setObject:@{@"img":@"zcicon_btnmore",@"imgsel":@"zcicon_btnmore"} forKey:@(SobotButtonClickRight)];
    }
    if ([ZCUICore getUICore].kitInfo.isShowEvaluation || [ZCUICore getUICore].kitInfo.isShowTelIcon) {
        if ([ZCUICore getUICore].kitInfo.isShowEvaluation) {
            [rightItem addObject:@(SobotButtonClickEvaluate)];
            [navItemSource setObject:@{@"img":@"zcicon_evaluate",@"imgsel":@"zcicon_evaluate"} forKey:@(SobotButtonClickEvaluate)];
        }
        if([ZCUICore getUICore].kitInfo.isShowTelIcon){
            [rightItem addObject:@(SobotButtonClickTEL)];
            [navItemSource setObject:@{@"img":@"zccion_call_icon",@"imgsel":@"zccion_call_icon"} forKey:@(SobotButtonClickTEL)];
        }
    }
    if([ZCUICore getUICore].kitInfo.isShowClose){
        if (self.isArtificial) {
            [rightItem addObject:@(SobotButtonClickClose)];
            [navItemSource setObject:@{@"title":SobotKitLocalString(@"关闭")} forKey:@(SobotButtonClickClose)];
        }
    }
   
    [rightItem removeObject:@(SobotButtonClickBack)];
    // 更新系统导航栏的按钮
    self.navItemsSource = navItemSource;
    if (!self.navigationController.navigationBarHidden) {
        // 使用的是系统导航栏，这里要布局 titleView；
            CGFloat maxWidth = rightItem.count *40 + rightItem.count*15;
            CGFloat TX = 40 +15 ;// 默认返回按钮的宽度加间隙
            _titleView = [[ZCTitleView alloc] initWithFrame:CGRectMake(TX, 0, ScreenWidth - maxWidth, 44)];
                [self.titleView setAutoresizesSubviews:YES];
    }else{
           _titleView = [[ZCTitleView alloc]initWithFrame:CGRectMake(80, NavBarHeight-44, ScreenWidth-160, 44)];
    }
     [self setLeftTags:@[@(SobotButtonClickBack)]  rightTags:rightItem titleView:_titleView];
}
@end
