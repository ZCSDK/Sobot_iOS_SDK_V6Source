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
    if ( [SobotUITools getCurScreenDirection] == 0) {
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

-(void)forceChangeForward{
    if([ZCUICore getUICore].kitInfo.isShowPortrait){
        fromOrientation = [UIApplication sharedApplication].statusBarOrientation;
        if (fromOrientation != UIInterfaceOrientationPortrait) {
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

#pragma mark - 设置强制横竖屏
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector             = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
//        int val                  = orientation;
        [invocation setArgument:&orientation atIndex:2];
        [invocation invoke];
    }
}

#pragma mark - 横竖屏 end //////////////////////////////////////////////////////


-(void)updateTopViewBgColor{
    if (!self.navigationController.navigationBarHidden) {
        // 设置导航条颜色
        [self.navigationController.navigationBar setBarTintColor:[ZCUIKitTools zcgetNavBackGroundColorWithSize:CGSizeMake(ScreenWidth, NavBarHeight)]];
#pragma mark -- iOS 15.0 导航栏设置
        if (@available(iOS 15.0, *)) {
            UINavigationBarAppearance *barApp = [UINavigationBarAppearance new];
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
}

#pragma mark - 设置帮助中心导航栏颜色
-(void)updateCenterViewBgColor{
    if (!self.navigationController.navigationBarHidden) {
        // 设置导航条颜色
        [self.navigationController.navigationBar setBarTintColor:[ZCUIKitTools zcgetscTopBgColorWithSize:CGSizeMake(ScreenWidth, NavBarHeight)]];
#pragma mark -- iOS 15.0 导航栏设置
        if (@available(iOS 15.0, *)) {
            UINavigationBarAppearance *barApp = [UINavigationBarAppearance new];
            barApp.backgroundColor = [ZCUIKitTools zcgetscTopBgColorWithSize:CGSizeMake(ScreenWidth, NavBarHeight)];
            barApp.shadowColor = [ZCUIKitTools zcgetscTopBgColorWithSize:CGSizeMake(ScreenWidth, NavBarHeight)];
            self.navigationController.navigationBar.scrollEdgeAppearance = barApp;
            self.navigationController.navigationBar.standardAppearance = barApp;
            self.titleLabel.textColor = [ZCUIKitTools zcgetTopViewTextColor];
        }
    }else{
        // 更新自定义View
        [self.topView setBackgroundColor:[ZCUIKitTools zcgetscTopBgColorWithSize:CGSizeMake(ScreenWidth, NavBarHeight)]];
        self.titleLabel.textColor = [ZCUIKitTools zcgetTopViewTextColor];
    }
}

@end
