//
//  SobotClientBaseController.m
//  SobotChatClient
//
//  Created by zhangxy on 2022/8/30.
//

#import "SobotClientBaseController.h"
#import <SobotChatClient/SobotChatClientCache.h>
#import <SobotCommon/SobotCommon.h>
#import "ZCUIKitTools.h"
#import "ZCUICore.h"
@interface SobotClientBaseController ()
{
    CGFloat viewWidth;
    CGFloat viewHeight;
    UIInterfaceOrientation fromOrientation;
}
@end

@implementation SobotClientBaseController


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:YES animated:NO];
    if([ZCUICore getUICore].PageLoadBlock){
        [ZCUICore getUICore].PageLoadBlock(self,ZCPageStateViewShow);
    }
}
#pragma mark - 横竖屏
//是否允许切换
-(BOOL)shouldAutorotate{
    return YES;
}

#pragma mark - 设置是否仅支持横屏还是竖屏
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([ZCUICore getUICore].kitInfo.isShowPortrait) {
        return UIInterfaceOrientationMaskPortrait;
    }else if ([ZCUICore getUICore].kitInfo.isShowLandscape) {
        return UIInterfaceOrientationMaskLandscape;
    }else{
        return UIInterfaceOrientationMaskAll;
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


#pragma mark - 横竖屏切换
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        if([ZCUICore getUICore].kitInfo.isShowPortrait){
            [self forceChangeForward];
            return;
        }
    }else{
        if([ZCUICore getUICore].kitInfo.isShowLandscape){
            [self forceChangeForward];
            return;
        }
    }
    [self orientationChanged];
    // 切换的方法必须调用
    [self viewDidLayoutSubviews];
}

-(BOOL)orientationChanged{
    BOOL isChange = NO;
    if ([SobotUITools getCurScreenDirection] == 0 || [ZCUICore getUICore].kitInfo.isShowPortrait) {
        CGFloat c = viewWidth;
        if(viewWidth > viewHeight){
            viewWidth = viewHeight;
            viewHeight = c;
            isChange = YES;
        }
    }else{
        CGFloat c = viewHeight;
        if(viewWidth < viewHeight){
            viewHeight = viewWidth;
            viewWidth = c;
            isChange = YES;
        }
    }
    return isChange;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.bundleName = ChatClientBundelName;
    
    if (![ZCUICore getUICore].kitInfo.isCloseSystemRTL) {
        if(sobotGetSystemDoubleVersion() >= 9.0){
            if(sobotIsRTLLayout()){
                [UIView appearance].semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
                [UISearchBar appearance].semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
                [self.navigationController.navigationBar setSemanticContentAttribute:UISemanticContentAttributeForceRightToLeft];
            }else{
                [UIView appearance].semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
                [UISearchBar appearance].semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
                [self.navigationController.navigationBar setSemanticContentAttribute:UISemanticContentAttributeForceLeftToRight];
            }
        }
    }
    viewWidth = self.view.frame.size.width;
    viewHeight = self.view.frame.size.height;
    if([ZCUICore getUICore].kitInfo.isShowPortrait || [ZCUICore getUICore].kitInfo.isShowLandscape){
        [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActiveNotification:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    [self forceChangeForward];
}


-(void)viewDidDisappear:(BOOL)animated{
     [self configSupportedInterfaceOrientations:0];
}

-(void)forceChangeForward{
    if([ZCUICore getUICore].kitInfo.isShowPortrait){
        fromOrientation = [UIApplication sharedApplication].statusBarOrientation;
        [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationPortrait;

        UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
        if (fromOrientation != UIInterfaceOrientationPortrait || deviceOrientation!=UIDeviceOrientationPortrait) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
            [self interfaceOrientation:UIInterfaceOrientationPortrait];
        }
    }else if([ZCUICore getUICore].kitInfo.isShowLandscape){
        fromOrientation = [UIApplication sharedApplication].statusBarOrientation;
        if (fromOrientation != UIInterfaceOrientationLandscapeRight && fromOrientation != UIInterfaceOrientationLandscapeLeft) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
            [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
        }
    }
}

-(void)applicationDidBecomeActiveNotification:(UIApplication *) application{
    [self forceChangeForward];
}

// 横竖屏切换触发
- (void)orientChange:(NSNotification *)notification{
    if([self orientationChanged]){
        // 切换的方法必须调用
        [self viewDidLayoutSubviews];
    }
}
/** 控制旋转 */
- (void)configSupportedInterfaceOrientations:(int)number
{
    id appDel = [[UIApplication sharedApplication] delegate];
    SEL sel_clientstate = NSSelectorFromString(@"setClientstate:");
    if ([appDel respondsToSelector:sel_clientstate]) {
        (((void (*)(id, SEL, NSUInteger))[appDel methodForSelector:sel_clientstate])(appDel, sel_clientstate, number));
    }
}

#pragma mark - 设置强制横竖屏
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation {
    if (sobotGetSystemDoubleVersion()>=16) {
        @try {
           
            UIInterfaceOrientationMask val = UIInterfaceOrientationMaskPortrait;
            NSLog(@"***************************** val %ld**************************",val);
            if(orientation == UIInterfaceOrientationPortrait){
                [self configSupportedInterfaceOrientations:1];
                val = UIInterfaceOrientationMaskPortrait;
            }else if(orientation == UIInterfaceOrientationLandscapeLeft){
                [self configSupportedInterfaceOrientations:2];
                val = UIInterfaceOrientationMaskLandscapeLeft;
            }else if(orientation == UIInterfaceOrientationLandscapeRight){
                [self configSupportedInterfaceOrientations:2];
                val = UIInterfaceOrientationMaskLandscapeRight;
            }else if(orientation == UIInterfaceOrientationMaskLandscape){
                [self configSupportedInterfaceOrientations:2];
                val = UIInterfaceOrientationMaskLandscape;
            }else{
                [self configSupportedInterfaceOrientations:0];
            }
            if (@available(iOS 16.0, *)) {
//                [self setNeedsUpdateOfSupportedInterfaceOrientations];
//                NSArray *array = [[[UIApplication sharedApplication] connectedScenes] allObjects];
//                UIWindowScene *ws = (UIWindowScene *)array[0];
//                UIWindowSceneGeometryPreferencesIOS *geometryPreferences = [[UIWindowSceneGeometryPreferencesIOS alloc] init];
//                geometryPreferences.interfaceOrientations = val;
//
//                [ws requestGeometryUpdateWithPreferences:geometryPreferences
//                                            errorHandler:^(NSError * _Nonnull error) {
//                    //业务代码
//                    SLog(@"调用了Block%@",error);
//                }];
                
//                NSArray *array = [[[UIApplication sharedApplication] connectedScenes] allObjects];
//                UIWindowScene *ws = (UIWindowScene *)array[0];
//                Class GeometryPreferences = NSClassFromString(@"UIWindowSceneGeometryPreferencesIOS");
//                id geometryPreferences = [[GeometryPreferences alloc]init];
//                [geometryPreferences setValue:@(val) forKey:@"interfaceOrientations"];
//                SLog(@"调用了requestGeometryUpdateWithPreferences:\n%@\nws:%@",geometryPreferences,ws);
//                SEL sel_method = NSSelectorFromString(@"requestGeometryUpdateWithPreferences:errorHandler:");
//                void (^ErrorBlock)(NSError *err) = ^(NSError *err){
//                    SLog(@"调用了Block%@",err);
//                };
//                if ([ws respondsToSelector:sel_method]) {
//                    (((void (*)(id, SEL,id,id))[ws methodForSelector:sel_method])(ws, sel_method,geometryPreferences,ErrorBlock));
//                }
            } else {
                // Fallback on earlier versions
            }
        } @catch (NSException *exception) {

        } @finally {
            
        }
    }else{
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            SEL selector             = NSSelectorFromString(@"setOrientation:");
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setTarget:[UIDevice currentDevice]];
            [invocation setArgument:&orientation atIndex:2];
            [invocation invoke];
        }
    }
}

#pragma mark - 横竖屏 end //////////////////////////////////////////////////////


-(void)updateTopViewBgColor{
    // 修改背景色的代码放到主线程中操作，防止使用系统导航栏，首次初始化完成之后，刷新不及时问题
        if (!self.navigationController.navigationBarHidden) {
            // 设置导航条颜色
            [self.navigationController.navigationBar setBarTintColor:[ZCUIKitTools zcgetNavBackGroundColorWithSize:CGSizeMake(ScreenWidth, NavBarHeight)]];
    #pragma mark -- iOS 15.0 导航栏设置
            if (@available(iOS 15.0, *)) {
                UINavigationBarAppearance *barApp = [UINavigationBarAppearance new];
                [barApp configureWithOpaqueBackground];
                barApp.backgroundColor = [ZCUIKitTools zcgetNavBackGroundColorWithSize:CGSizeMake(ScreenWidth, NavBarHeight)];
                barApp.shadowColor = [ZCUIKitTools zcgetNavBackGroundColorWithSize:CGSizeMake(ScreenWidth, NavBarHeight)];
                self.navigationController.navigationBar.scrollEdgeAppearance = barApp;
                self.navigationController.navigationBar.standardAppearance = barApp;
                self.titleLabel.textColor = [ZCUIKitTools zcgetTopViewTextColor];
            }
        }else{
            // 更新自定义View
            [self.topView setBackgroundColor:[ZCUIKitTools zcgetNavBackGroundColorWithSize:CGSizeMake(ScreenWidth, NavBarHeight)]];
            self.titleLabel.textColor = [ZCUIKitTools zcgetTopViewTextColor];
        }

    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (!self.navigationController.navigationBarHidden) {
//            // 设置导航条颜色
//            [self.navigationController.navigationBar setBarTintColor:[ZCUIKitTools zcgetNavBackGroundColorWithSize:CGSizeMake(ScreenWidth, NavBarHeight)]];
//    #pragma mark -- iOS 15.0 导航栏设置
//            if (@available(iOS 15.0, *)) {
//                UINavigationBarAppearance *barApp = [UINavigationBarAppearance new];
//                barApp.backgroundColor = [ZCUIKitTools zcgetNavBackGroundColorWithSize:CGSizeMake(ScreenWidth, NavBarHeight)];
//                barApp.shadowColor = [ZCUIKitTools zcgetNavBackGroundColorWithSize:CGSizeMake(ScreenWidth, NavBarHeight)];
//                self.navigationController.navigationBar.scrollEdgeAppearance = barApp;
//                self.navigationController.navigationBar.standardAppearance = barApp;
//                self.titleLabel.textColor = [ZCUIKitTools zcgetTopViewTextColor];
//            }
//        }else{
//            // 更新自定义View
//            [self.topView setBackgroundColor:[ZCUIKitTools zcgetNavBackGroundColorWithSize:CGSizeMake(ScreenWidth, NavBarHeight)]];
//            self.titleLabel.textColor = [ZCUIKitTools zcgetTopViewTextColor];
//        }
//    });
}

#pragma mark - 设置帮助中心导航栏颜色
-(void)updateCenterViewBgColor{
    if (!self.navigationController.navigationBarHidden) {
        // 设置导航条颜色
        [self.navigationController.navigationBar setBarTintColor:[ZCUIKitTools zcgetNavBackGroundColorWithSize:CGSizeMake(ScreenWidth, NavBarHeight)]];
        [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[ZCUIKitTools zcgetTopViewTextColor]}];
#pragma mark -- iOS 15.0 导航栏设置
        if (@available(iOS 15.0, *)) {
            UINavigationBarAppearance *barApp = [UINavigationBarAppearance new];
            barApp.backgroundColor = [ZCUIKitTools zcgetNavBackGroundColorWithSize:CGSizeMake(ScreenWidth, NavBarHeight)];
            barApp.shadowColor = [ZCUIKitTools zcgetNavBackGroundColorWithSize:CGSizeMake(ScreenWidth, NavBarHeight)];
            NSDictionary *dic = @{NSForegroundColorAttributeName : [ZCUIKitTools zcgetTopViewTextColor],
                                              NSFontAttributeName : [UIFont systemFontOfSize:18 weight:UIFontWeightMedium]};
                    
            barApp.titleTextAttributes = dic;
            self.navigationController.navigationBar.scrollEdgeAppearance = barApp;
            self.navigationController.navigationBar.standardAppearance = barApp;
        }
    }else{
        // 更新自定义View
        [self.topView setBackgroundColor:[ZCUIKitTools zcgetNavBackGroundColorWithSize:CGSizeMake(ScreenWidth, NavBarHeight)]];
        self.titleLabel.textColor = [ZCUIKitTools zcgetTopViewTextColor];
    }
}

// 设置导航栏按钮
-(void)setNavigationBarLeft:(NSArray *__nullable)leftTags right:(NSArray *__nullable)rightTags{
    [self setNavigationBarLeft:leftTags right:rightTags setBarStyle:NO];
}



-(void)createVCTitleView{
    if(self.navigationController && !self.navigationController.navigationBarHidden){
        self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
        [self updateNavOrTopView];
    }else{
        [self createCustomTitleView];
    }
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
    }
}

@end
