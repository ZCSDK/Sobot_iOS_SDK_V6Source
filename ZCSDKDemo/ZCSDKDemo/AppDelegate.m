//
//  AppDelegate.m
//  SobotChatClientSDKTest
//
//  Created by zhangxy on 2022/8/29.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <SobotKit/SobotKit.h>
#import <UserNotifications/UserNotifications.h>
#import "ZCGuideHomeController.h"
#import "ZCGuideData.h"

#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface AppDelegate ()<UIApplicationDelegate,UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC = rootVC;
    while ([currentVC presentedViewController]) {
        // 视图是被presented出来的
        currentVC = [currentVC presentedViewController];
    }
    if ([currentVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        currentVC = [(UITabBarController *)currentVC selectedViewController];
    }
    if ([currentVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        currentVC = [(UINavigationController *)currentVC visibleViewController];
    }
    return currentVC;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window{
    if(_clientstate == 1){
        return UIInterfaceOrientationMaskPortrait;
    }
    if(_clientstate == 2){
        return UIInterfaceOrientationMaskLandscape;
    }
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[ZCLibClient getZCLibClient] setReceivedBlock:^(id message, int nleft, NSDictionary *object) {
        NSLog(@"接收到消息：%@ -- %d",message,nleft);
    }];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

    //设置全局状态栏字体颜色为白色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = UIColor.whiteColor;
    UITabBarController * tabBarController = [[UITabBarController alloc]init];
    self.window.rootViewController = tabBarController;
    ViewController * viewController = [[ViewController alloc]init];
    [self setTabBarItem:viewController.tabBarItem Title:@"产品介绍" withTitleSize:10.0f andFoneName:@"Helvetica Neue" selectedImage:@"root_menu3_sel" withTitleColor:SobotColorFromRGB(0x39B9C2) unselectedImage:@"root_menu1_nor" withTitleColor:SobotColorFromRGB(0x8B98AD)];
    UINavigationController * navc1 = [[UINavigationController alloc]initWithRootViewController:viewController];
    
    ZCGuideHomeController *guideVC = [[ZCGuideHomeController alloc]init];
    [self setTabBarItem:guideVC.tabBarItem Title:@"功能设置" withTitleSize:10.0f andFoneName:@"Helvetica Neue" selectedImage:@"root_menu4_sel" withTitleColor:SobotColorFromRGB(0x39B9C2) unselectedImage:@"root_menu2_nor" withTitleColor:SobotColorFromRGB(0x8B98AD)];
    UINavigationController * navc4 = [[UINavigationController alloc]initWithRootViewController:guideVC];
    guideVC.title = @"功能设置";
    
//    UINavigationBar * bar2 = [UINavigationBar appearance];
//    bar2.barTintColor = SobotColorFromRGB(0xffffff);// 0x39B9C2

    [UITabBar appearance].translucent = YES;
    tabBarController.viewControllers = @[navc1,navc4];
//    tabBar.viewControllers = @[navc1,navc2,navc3];
    [[UITabBar appearance] setBackgroundColor:SobotColorFromRGB(0xffffff)];
    if ([[UIDevice currentDevice].systemVersion doubleValue]>=15.0) {
        UITabBarAppearance *tabbarAppearance = [[UITabBarAppearance alloc] init];
        tabbarAppearance.backgroundColor = SobotColorFromRGB(0xffffff);
        tabBarController.tabBar.scrollEdgeAppearance = tabbarAppearance;
        tabBarController.tabBar.standardAppearance = tabbarAppearance;
        // 设置选中文字颜色 iOS13 中对应的label的属性 textColorFollowsTintColor 默认为true  iOS13之前的版本默认false
        tabBarController.tabBar.tintColor = SobotColorFromRGB(0x39B9C2);
    }
    [self.window makeKeyWindow];
//    ------------      -------------------
    if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")){
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if( !error ){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                });

            }
        }];
    }else{
        [self registerPush:application];
    }
    
    // 设置推送是否是测试环境，测试环境将使用开发证书
    [[ZCLibClient getZCLibClient] setAutoNotification:YES];
//    [[ZCLibClient getZCLibClient] setReceivedBlock:^(id message, int nleft, NSDictionary *object) {
//        NSLog(@"ssss%@ -- %d",message,nleft);
//    }];
    NSLog(@"version ==== %@",[ZCSobotApi getVersion]);
    // 错误日志收集
    [ZCSobotApi setZCLibUncaughtExceptionHandler];
    // 设置切换到后台自动断开长连接，不会影响APP后台挂起时长
    // 进入前台会自动重连，断开期间消息会发送apns推送
    return YES;
}

-(void)registerPush:(UIApplication *)application{
    // ios8后，需要添加这个注册，才能得到授权
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        //IOS8
        //创建UIUserNotificationSettings，并设置消息的显示类类型
        UIUserNotificationSettings *notiSettings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIRemoteNotificationTypeSound) categories:nil];
        
        [application registerUserNotificationSettings:notiSettings];
    } else{ // ios7
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert)];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)pToken{
    NSLog(@"---Token--%@", pToken);
    // 字符串
    NSString *deviceTokenString2 = [[[[pToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""]
                                         stringByReplacingOccurrencesOfString:@">" withString:@""]
                                        stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 13) {
        deviceTokenString2 = [self getHexStringFromData:pToken];
    }
    NSLog(@"字符串：%@", deviceTokenString2);
//    [[ZCLibClient getZCLibClient] setToken:pToken];  // 添加token
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    NSString *message = [[userInfo objectForKey:@"aps"]objectForKey:@"alert"];
    NSLog(@"userInfo == %@\n%@",userInfo,message);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"Regist fail%@",error);
}


// 本地的通知回调事件
- (void)application:(UIApplication *)application didReceiveLocalNotification:(nonnull UILocalNotification *)notification{
    NSLog(@"userInfo == %@",notification.userInfo);
}
//====================For iOS 10====================

-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    NSLog(@"Userinfo %@",notification.request.content.userInfo);
    //功能：可设置是否在应用内弹出通知
    completionHandler(UNNotificationPresentationOptionAlert);
}

//点击推送消息后回调
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^_Nonnull __strong)())completionHandler{
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if([userInfo[@"pushType"] hasPrefix:@"leavereply"]){
        UITabBarController *tab = (UITabBarController *)_window.rootViewController;
        UINavigationController *nav = tab.viewControllers[tab.selectedIndex];
        [ZCSobotApi openRecordDetail:userInfo[@"ticketId"] viewController:nav];
    }
    if([@"sobot" isEqual:userInfo[@"msgfrom"]]){
        [self openSDK];
    }
    NSLog(@"Userinfo %@",userInfo);
}

-(void)openSDK{
    // 进入聊天页面
    [ZCSobotApi openZCChat:[ZCGuideData getZCGuideData].kitInfo with:[self getCurrentVCFrom:_window.rootViewController] pageBlock:^(id  _Nonnull object, ZCPageStateType type) {
        if([object isKindOfClass:[ZCChatView class]] && type == ZCPageStateTypeChatLoadFinish){
            UITextView *tv = [((ZCChatView *)object) getChatTextView];
            if(tv){
                //                    tv.textColor  = UIColor.greenColor;
            }
        }
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    //   此方法已弃用 [ZCLibClient closeZCServer:NO];
    [[ZCLibClient getZCLibClient] removeIMAllObserver];
    [[ZCLibClient getZCLibClient] closeIMConnection];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //   此方法已弃用 [[ZCLibClient getZCLibClient] aginitIMChat];
    if([ZCLibClient getZCLibClient].libInitInfo.app_key == nil){
        [ZCLibClient getZCLibClient].libInitInfo.app_key = @"your app_key";
    }
    if([ZCLibClient getZCLibClient].libInitInfo.app_key != nil){
        [[ZCLibClient getZCLibClient] checkIMObserverWithRegister];
        [[ZCLibClient getZCLibClient] checkIMConnected];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


-(NSString *) getHexStringFromData:(NSData *) data{
    NSUInteger len = [data length];
    char *chars = (char *)[data bytes];
    NSMutableString *hexString = [[NSMutableString alloc] init];
    for (int i=0; i<len ; i ++ ) {
        [hexString appendString:[NSString stringWithFormat:@"%0.2hhx",chars[i]]];
    }
    return  hexString;
}

- (void)setTabBarItem:(UITabBarItem *)tabbarItem
                Title:(NSString *)title
        withTitleSize:(CGFloat)size
          andFoneName:(NSString *)foneName
        selectedImage:(NSString *)selectedImage
       withTitleColor:(UIColor *)selectColor
      unselectedImage:(NSString *)unselectedImage
       withTitleColor:(UIColor *)unselectColor{
    
    //设置图片
    tabbarItem = [tabbarItem initWithTitle:title image:[[UIImage imageNamed:unselectedImage]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:selectedImage]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];

    //未选中字体颜色
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:unselectColor,NSFontAttributeName:[UIFont fontWithName:foneName size:size]} forState:UIControlStateNormal];
    
    //选中字体颜色
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:selectColor,NSFontAttributeName:[UIFont fontWithName:foneName size:size]} forState:UIControlStateSelected];
}
@end
