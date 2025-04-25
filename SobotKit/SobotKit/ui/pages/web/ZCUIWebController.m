//
//  ZCUIWebController.m
//  SobotKit
//
//  Created by zhangxy on 15/11/12. zcicon_titlebar_back_normal
//  Copyright © 2015年 zhichi. All rights reserved.
//

#import "ZCUIWebController.h"
#import <WebKit/WebKit.h>
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClient.h>
#import "ZCUIKitTools.h"
#import "ZCUICore.h"
#import <objc/runtime.h>
/**
 *  PageClickTag ENUM
 */
typedef NS_ENUM(NSInteger, PageClickTag) {
    /** 返回 */
    BUTTON_WEB_BACK      = 1,
    /** 刷新 */
    BUTTON_REREFRESH = 2,
};


@interface ZCUIWebController ()<WKNavigationDelegate>{
    NSString *pageURL;
    WKWebView *_webView;
    BOOL  navBarHide;
    //    NSString *_htmlString;
}

@property (nonatomic, strong) UIBarButtonItem *backBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *forwardBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *refreshBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *stopBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *refreshButtonItem;
@property (nonatomic, strong) UIBarButtonItem *urlCopyButtonItem;

@property(nonatomic,strong) NSString *htmlString;

@end

@implementation ZCUIWebController


- (void)viewDidLoad {
    [super viewDidLoad];

    [self createVCTitleView];
    [self updateNavOrTopView];
    _webView = [[WKWebView alloc]init];
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc]init];
        WKPreferences *preference = [[WKPreferences alloc]init];
        preference.javaScriptEnabled = YES;
        preference.javaScriptCanOpenWindowsAutomatically = YES;
        config.preferences = preference;
    CGFloat nah = NavBarHeight;
    if(self.navigationController && !self.navigationController.navigationBarHidden){
        nah = 0;
    }
    _webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, nah, ScreenWidth, ScreenHeight -44 -XBottomBarHeight -nah) configuration:config];
    _webView.navigationDelegate = self;
    [_webView setOpaque:NO];
    _webView.backgroundColor = [ZCUIKitTools zcgetLightGrayBackgroundColor];
    [self.view addSubview:_webView];
    
    [self.view addConstraint:sobotLayoutPaddingTop(nah, _webView, self.view)];
    [self.view addConstraint:sobotLayoutPaddingLeft(0, _webView, self.view)];
    [self.view addConstraint:sobotLayoutPaddingRight(0, _webView, self.view)];
//    [self.view addConstraint:sobotLayoutEqualWidth(ScreenWidth, _webView, NSLayoutRelationEqual)];
    [self.view addConstraint:sobotLayoutPaddingBottom(-44 -XBottomBarHeight , _webView, self.view)];
    
    [self checkTxtEncode];
    [self updateToolbarItems];
    [_webView addObserver:self forKeyPath:@"URL"options:NSKeyValueObservingOptionNew context:nil];
}
//KVO监听进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == _webView) {
//        [self.progressView setAlpha:1.0f];
//        BOOL animated = self.wkWebView.estimatedProgress > self.progressView.progress;
//        [self.progressView setProgress:self.wkWebView.estimatedProgress animated:animated];

        // Once complete, fade out UIProgressView
        if(_webView.estimatedProgress >= 1.0f) {
//            [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
//                [self.progressView setAlpha:0.0f];
//            } completion:^(BOOL finished) {
//                [self.progressView setProgress:0.0f animated:NO];
//            }];
        }
    }
    else if([keyPath isEqualToString:@"URL"] && object == _webView)
    {
//        [self updateNavigationItems:self.wkWebView.URL.absoluteString];
        NSLog(@"url == %@",_webView.URL.absoluteString);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self updateToolbarItems];
        });
        
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

/**
 *  暂时不使用
 */
-(void) checkTxtEncode{
    NSString *fileName = [pageURL lastPathComponent];
    if (fileName && [[fileName lowercaseString] hasSuffix:@".txt"])
    {
        NSData *attachmentData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:pageURL]];
        //txt分带编码和不带编码两种，带编码的如UTF-8格式txt，不带编码的如ANSI格式txt
        //不带的，可以依次尝试GBK和GBK编码
        NSString *aStr = [[NSString alloc] initWithData:attachmentData encoding:NSUTF8StringEncoding];
        if( !aStr){
            aStr= [[NSString alloc] initWithData:attachmentData encoding:0x80000632];
        }
        if (!aStr)
        {
            //用GBK编码不行,再用GB18030编码
            aStr = [[NSString alloc] initWithData:attachmentData encoding:0x80000631];
        }
        if(aStr){
            //通过html语言进行排版
            NSString* responseStr = [NSString stringWithFormat:
                                     @"<!DOCTYPE html>"
                                     "<HTML>"
                                     "<head>"
                                     "<title>Text View</title>"
                                     "<style>"
                                     "img{"
                                     "font-style:normal;"
                                     "width: auto;"
                                     "height:auto;"
                                     "max-height: 100%%;"
                                     "max-width: 100%%;"
                                     "}"
                                     "</style>"
                                     "</head>"
                                     "<BODY  style=\"FONT-SIZE: 36px;\">"
                                     "<pre>"
                                     "%@"
                                     "</pre>"
                                     "</BODY>"
                                     "</HTML>",
                                     aStr];
            
            [_webView loadHTMLString:responseStr baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
        }else{
            NSURL *url=[[ NSURL alloc ] initWithString:pageURL];
            [_webView loadRequest:[ NSURLRequest requestWithURL:url]];
        }
    }else if (sobotIsUrl(pageURL,@"")){
        NSURL *url=[[ NSURL alloc ] initWithString:pageURL];
        [_webView loadRequest:[ NSURLRequest requestWithURL:url]];
        
    }else{//富文本展示
        NSString* htmlString = [NSString stringWithFormat:
                                @"<!DOCTYPE html>"
                                "<html>"
                                "<head>"
                                "<meta charset=\"utf-8\">"
                                "<title></title>"
                                "<style>"
                                "img{"
                                "width: auto;"
                                "height:auto;"
                                "max-height: 100%%;"
                                "max-width: 100%%;"
                                "}"
                                "</style>"
                                "</head>"
                                "<body  style=\"FONT-SIZE: 36px;\">"
                                "%@"
                                "</body>"
                                "</html>",
                                self.htmlString];
        [_webView loadHTMLString:htmlString baseURL:nil];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    _webView = nil;
    _backBarButtonItem = nil;
    _forwardBarButtonItem = nil;
    _refreshBarButtonItem = nil;
    _stopBarButtonItem = nil;
    _refreshButtonItem = nil;
    _urlCopyButtonItem = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.navigationController setToolbarHidden:NO animated:animated];
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.navigationController setToolbarHidden:YES animated:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.navigationController setToolbarHidden:YES animated:animated];
    }
}

-(id)initWithURL:(NSString *)url{
    self=[super init];
    if(self){
        if (sobotIsUrl(url,@"")) {
            SLog(@"当前加载的链接 %@", url);
            pageURL=url;
        }else{
            self.htmlString = url;
            self.titleLabel.text = SobotKitLocalString(@"详细信息");
        }
    }
    return self;
}

-(IBAction)buttonClick:(UIButton *) sender{
    if(sender.tag == SobotButtonClickBack){
        if(self.navigationController != nil && self.navigationController.childViewControllers.count>1){
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 处理掉底部输入框的痕迹
            self.navigationController.toolbarHidden = YES;
        });
    }
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self updateToolbarItems];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self updateToolbarItems];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [webView evaluateJavaScript:@"document.title" completionHandler:^(NSString *currentURL, NSError * _Nullable error) {
        if (sobotConvertToString(currentURL).length >0) {
            //    NSLog(@"复制链接%@",currentURL);
            self.titleLabel.text = currentURL;
        }
    }];
    //设置颜色
    
    if (![ZCUICore getUICore].kitInfo.isCloseWKDarkMode) {
        if([ZCUIKitTools getZCThemeStyle] == SobotThemeMode_Dark){
            [webView evaluateJavaScript:@"document.getElementsByTagName('body')[0].style.webkitTextFillColor= '#D1D1D6'" completionHandler:nil];
            [webView evaluateJavaScript:@"document.body.style.backgroundColor='#262628'" completionHandler:nil];
            [webView evaluateJavaScript:@"document.getElementsByTagName('body')[0].style.background='#262628'"completionHandler:nil];
        }
    }
    [self updateToolbarItems];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if ([navigationAction.request.URL.scheme isEqualToString:@"tel"]) {
        NSURL *tel = navigationAction.request.URL;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 18) {
            [[UIApplication sharedApplication] openURL:tel options:@{} completionHandler:^(BOOL success) {
                    if (success) {
                        NSLog(@"URL successfully opened.");
                    } else {
                        NSLog(@"Failed to open URL.");
                    }
                }];
        }else{
            if ([[UIApplication sharedApplication] canOpenURL:tel]) {
                [[UIApplication sharedApplication] openURL:tel];
            }
        
        }
        decisionHandler(WKNavigationActionPolicyAllow);
    }else{
        // 如果是跳转一个新页面
        if (navigationAction.targetFrame == nil) {
            [webView loadRequest:navigationAction.request];
        }
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)updateToolbarItems {
    self.backBarButtonItem.enabled = _webView.canGoBack;
    self.forwardBarButtonItem.enabled = _webView.canGoForward;
    // 显示刷新的按钮
    UIBarButtonItem *refreshStopBarButtonItem =  self.refreshBarButtonItem  ;
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGFloat toolbarWidth = 250.0f;
        fixedSpace.width = 35.0f;
        NSArray *items;
        if (sobotConvertToString(pageURL).length == 0) {
            items = [NSArray arrayWithObjects:
            fixedSpace,
            refreshStopBarButtonItem,
            fixedSpace,
            self.backBarButtonItem,
            fixedSpace,
            self.forwardBarButtonItem,
            nil];
        }else{
            items = [NSArray arrayWithObjects:
            fixedSpace,
            refreshStopBarButtonItem,
            fixedSpace,
            self.backBarButtonItem,
            fixedSpace,
            self.forwardBarButtonItem,
            fixedSpace,
            self.urlCopyButtonItem,
            nil];
        }
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, toolbarWidth, 44.0f)];
        toolbar.items = items;
        if([ZCUIKitTools getZCThemeStyle] == SobotThemeMode_Dark){
            toolbar.barStyle = UIBarStyleBlack;
        }else{
            toolbar.barStyle = self.navigationController.navigationBar.barStyle;
        }
        toolbar.tintColor = self.navigationController.navigationBar.tintColor;
        self.navigationItem.rightBarButtonItems = items.reverseObjectEnumerator.allObjects;
    }else {
        NSArray *items;
        if (sobotConvertToString(pageURL).length == 0) {
            items = [NSArray arrayWithObjects:
            fixedSpace,
            self.backBarButtonItem,
            flexibleSpace,
            self.forwardBarButtonItem,
            flexibleSpace,
            refreshStopBarButtonItem,
            
            fixedSpace,
            nil];
        }else{
            items = [NSArray arrayWithObjects:
            fixedSpace,
            self.backBarButtonItem,
            flexibleSpace,
            self.forwardBarButtonItem,
            flexibleSpace,
            self.urlCopyButtonItem,
            flexibleSpace,
            refreshStopBarButtonItem,
            fixedSpace,
            nil];
        }
        if([ZCUIKitTools getZCThemeStyle] == SobotThemeMode_Dark){
            self.navigationController.toolbar.barStyle = UIBarStyleBlack;
        }else{
            self.navigationController.toolbar.barStyle = self.navigationController.navigationBar.barStyle;
        }
        self.navigationController.toolbar.tintColor = self.navigationController.navigationBar.tintColor;
        self.toolbarItems = items;
    }
}

- (UIBarButtonItem *)backBarButtonItem {
    if (!_backBarButtonItem) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 25, 25);
        UIImage *img = [SobotKitGetImage(@"zcicon_web_back") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [btn setImage:img forState:UIControlStateNormal];
        UIImage *imgpressed = [SobotKitGetImage(@"zcicon_web_back_pressed") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [btn setImage:imgpressed forState:UIControlStateHighlighted];
        btn.tintColor = [ZCUIKitTools zcgetServerConfigBtnBgColor];
        [btn setImage:[SobotUITools getSysImageByName:@"zcicon_web_back_disabled"] forState:UIControlStateDisabled];
        [btn addTarget:self action:@selector(goBackTapped:) forControlEvents:UIControlEventTouchUpInside];
        // 使用自定义的样式，解决系统样式不能修改背景色的问题
        _backBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
        _backBarButtonItem.width = 25.0f;
    }
    return _backBarButtonItem;
}

- (UIBarButtonItem *)forwardBarButtonItem {
    if (!_forwardBarButtonItem) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 25, 25);
        UIImage *img = [SobotKitGetImage(@"zcicon_web_next") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [btn setImage:img forState:UIControlStateNormal];
        UIImage *imgpressed = [SobotKitGetImage(@"zcicon_web_next_pressed") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [btn setImage:imgpressed forState:UIControlStateHighlighted];
        btn.tintColor = [ZCUIKitTools zcgetServerConfigBtnBgColor];
        [btn setImage:[SobotUITools getSysImageByName:@"zcicon_web_next_disabled"] forState:UIControlStateDisabled];
        [btn addTarget:self action:@selector(goForwardTapped:) forControlEvents:UIControlEventTouchUpInside];
        // 使用自定义的样式，解决系统样式不能修改背景色的问题
        _forwardBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
        _forwardBarButtonItem.width = 25.0f;
    }
    return _forwardBarButtonItem;
}

- (UIBarButtonItem *)refreshBarButtonItem {
    if (!_refreshBarButtonItem) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 25, 25);
        UIImage *img = [SobotKitGetImage(@"zcicon_refreshbar_normal") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [btn setImage:img forState:UIControlStateNormal];
        UIImage *imgpressed = [SobotKitGetImage(@"zcicon_refreshbar_pressed") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [btn setImage:imgpressed forState:UIControlStateHighlighted];
        btn.tintColor = [ZCUIKitTools zcgetServerConfigBtnBgColor];
        [btn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [btn setImage:[SobotUITools getSysImageByName:@"zcicon_refreshbar_pressed"] forState:UIControlStateDisabled];
        [btn addTarget:self action:@selector(reloadTapped:) forControlEvents:UIControlEventTouchUpInside];
        // 使用自定义的样式，解决系统样式不能修改背景色的问题
        _refreshBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
        _refreshBarButtonItem.width = 25.0f;
    }
    return _refreshBarButtonItem;
}

- (UIBarButtonItem *)urlCopyButtonItem {
    if (!_urlCopyButtonItem) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 25, 25);
        [btn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        UIImage *img = [SobotKitGetImage(@"zcicon_web_copy_nols") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [btn setImage:img forState:UIControlStateNormal];
        UIImage *imgpressed = [SobotKitGetImage(@"zcicon_web_copy_press") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        btn.tintColor = [ZCUIKitTools zcgetServerConfigBtnBgColor];
        [btn setImage:imgpressed forState:UIControlStateHighlighted];
        [btn setImage:[SobotUITools getSysImageByName:@"zcicon_web_copy_press"] forState:UIControlStateDisabled];
        [btn addTarget:self action:@selector(copyURL:) forControlEvents:UIControlEventTouchUpInside];
        // 使用自定义的样式，解决系统样式不能修改背景色的问题
        _urlCopyButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
        _urlCopyButtonItem.width = 25.0f;
    }
    return _urlCopyButtonItem;
}

#pragma mark - Target actions

- (void)goBackTapped:(UIBarButtonItem *)sender {
    [_webView goBack];
}

- (void)goForwardTapped:(UIBarButtonItem *)sender {
    [_webView goForward];
}

- (void)reloadTapped:(UIBarButtonItem *)sender {
    //v2.7.9 如果是通过htmlstring直接加载的页面无URL，不需要刷新
    if (sobotConvertToString(pageURL).length == 0) {
        return;
    }
    [_webView reload];
}

- (void)copyURL:(UIBarButtonItem *)sender{
    NSString *currentURL;
    [_webView evaluateJavaScript:@"document.location.href" completionHandler:^(NSString *currentURL, NSError * _Nullable error) {
        if (sobotConvertToString(currentURL).length >0) {
            //    NSLog(@"复制链接%@",currentURL);
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:sobotConvertToString(currentURL)];
            [[SobotToast shareToast] showToast:SobotKitLocalString(@"复制成功") duration:1.0f view:self.view position:SobotToastPositionCenter];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

// 适配iOS 13以上的横竖屏切换
-(void)viewSafeAreaInsetsDidChange{
    [super viewSafeAreaInsetsDidChange];
    // 横竖屏更新导航栏渐变色
    [self updateTopViewBgColor];
}



#pragma mark 以下是拦截选择文件相关事件处理
//- (void)gigi_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
//
//    //如果present的viewcontroller是UIDocumentMenuViewController
//    //类型，且代理是WKFileUploadPanel或UIWebFileUploadPanel
//    //进行拦截
//    if ([viewControllerToPresent isKindOfClass:[UIDocumentMenuViewController class]]) {
//        UIDocumentMenuViewController *dvc = (UIDocumentMenuViewController*)viewControllerToPresent;
//        NSLog(@"dvc.delegate\n%@",dvc.delegate);
//        if ([dvc.delegate isKindOfClass:NSClassFromString(@"WKFileUploadPanel")] || [dvc.delegate isKindOfClass:NSClassFromString(@"UIWebFileUploadPanel")]) {
//
////            self.isFileInputIntercept = YES;
////            [dvc.delegate documentMenuWasCancelled:dvc];
////
////            dispatch_async(dispatch_get_main_queue(), ^{
////                [self onFileInputIntercept];
////            });
////
////            return;
//        }
//    }
//    //正常情况下的present
//    [self gigi_presentViewController:viewControllerToPresent animated:flag completion:completion];
//}
//
//- (void)gigi_dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
//
//    //如果进行了拦截，禁止当前viewcontroller的dismiss
//    if (self.isFileInputIntercept) {
//        self.isFileInputIntercept = NO;
//        completion();
//        return;
//    }
//
//    //正常情况下viewcontroller的dismiss
//    [self gigi_dismissViewControllerAnimated:flag completion:^{
//        if (completion) {
//            completion();
//        }
//    }];
//}
//
//
//- (void)onFileInputIntercept {
//    if ([self respondsToSelector:@selector(onFileInputClicked)]) {
//        [self performSelector:@selector(onFileInputClicked)];
//    }
//}
//
//- (void)onFileInputClicked {
//
//}
//
//- (BOOL)isFileInputIntercept {
//    return [objc_getAssociatedObject(self, @selector(isFileInputIntercept)) boolValue];
//}
//
//- (void)setIsFileInputIntercept:(BOOL)boolValue {
//    objc_setAssociatedObject(self, @selector(isFileInputIntercept), @(boolValue), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//- (void)swizzlingViewWillAppear:(BOOL)animated {
////    _UIContextMenuActionsOnlyViewController
////    _UIResilientRemoteViewContainerViewController
//
//    [self swizzlingViewWillAppear:animated];
//    NSLog(@"当前即将打开%@",self);
//
//    if ([self isMemberOfClass:NSClassFromString(@"PHPickerViewController")] || [self isMemberOfClass:NSClassFromString(@"UIDocumentPickerViewController")]) {
//        [self configureRongCloudNavigation];
//    }
//}
//
//-(void)configureRongCloudNavigation{
//    NSLog(@"%@",self);
//    //点击系统相册弹出的控制器
//    if ([self isMemberOfClass:NSClassFromString(@"PUPhotoPickerHostViewController")]) {
//    }
//
//    //点击浏览弹出的控制器
//    if ([self isMemberOfClass:NSClassFromString(@"UIDocumentPickerViewController")]) {
//    }
//}
//+ (void)load {
//
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        Class class = [self class];
//        SEL originalSelector = @selector(dismissViewControllerAnimated:completion:);
//        SEL swizzledSelector = @selector(gigi_dismissViewControllerAnimated:completion:);
//        Method originalMethod = class_getInstanceMethod(class, originalSelector);
//        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
//        BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
//        if (success) {
//            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
//        } else {
//            method_exchangeImplementations(originalMethod, swizzledMethod);
//        }
//
//        originalSelector = @selector(presentViewController:animated:completion:);
//        swizzledSelector = @selector(gigi_presentViewController:animated:completion:);
//        originalMethod = class_getInstanceMethod(class, originalSelector);
//        swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
//        success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
//        if (success) {
//            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
//        } else {
//            method_exchangeImplementations(originalMethod, swizzledMethod);
//        }
//
//        //原本的willAppear方法
//            Method willAppearOriginal = class_getInstanceMethod([self class], @selector(viewWillAppear:));
//            //用于交换的willAppear方法
//            Method willAppearNew = class_getInstanceMethod([self class], @selector(swizzlingViewWillAppear:));
//            //交换
//            if (!class_addMethod([self class], @selector(viewWillAppear:), method_getImplementation(willAppearNew), method_getTypeEncoding(willAppearNew))) {
//                method_exchangeImplementations(willAppearOriginal, willAppearNew);
//            }
//    });
//}
@end

