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
    _webView.navigationDelegate = self;
    [_webView setOpaque:NO];
    _webView.backgroundColor = [ZCUIKitTools zcgetLightGrayBackgroundColor];
    [self.view addSubview:_webView];
    CGFloat nah = NavBarHeight;
    if(self.navigationController && !self.navigationController.navigationBarHidden){
        nah = 0;
    }
    [self.view addConstraint:sobotLayoutPaddingTop(nah, _webView, self.view)];
    [self.view addConstraint:sobotLayoutPaddingLeft(0, _webView, self.view)];
    [self.view addConstraint:sobotLayoutPaddingRight(0, _webView, self.view)];
//    [self.view addConstraint:sobotLayoutEqualWidth(ScreenWidth, _webView, NSLayoutRelationEqual)];
    [self.view addConstraint:sobotLayoutPaddingBottom(-44 -XBottomBarHeight , _webView, self.view)];
    
    [self checkTxtEncode];
    [self updateToolbarItems];
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
    // 如果是跳转一个新页面
    if (navigationAction.targetFrame == nil) {
        [webView loadRequest:navigationAction.request];
    }
    decisionHandler(WKNavigationActionPolicyAllow);
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
        [btn setImage:[SobotUITools getSysImageByName:@"zcicon_web_back"] forState:UIControlStateNormal];
        [btn setImage:[SobotUITools getSysImageByName:@"zcicon_web_back_pressed"] forState:UIControlStateHighlighted];
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
        [btn setImage:[SobotUITools getSysImageByName:@"zcicon_web_next"] forState:UIControlStateNormal];
        [btn setImage:[SobotUITools getSysImageByName:@"zcicon_web_next_pressed"] forState:UIControlStateHighlighted];
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
        [btn setImage:[SobotUITools getSysImageByName:@"zcicon_refreshbar_normal"] forState:UIControlStateNormal];
        [btn setImage:[SobotUITools getSysImageByName:@"zcicon_refreshbar_pressed"] forState:UIControlStateHighlighted];
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
        [btn setImage:[SobotUITools getSysImageByName:@"zcicon_web_copy_nols"] forState:UIControlStateNormal];
        [btn setImage:[SobotUITools getSysImageByName:@"zcicon_web_copy_press"] forState:UIControlStateHighlighted];
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
            [[SobotToast shareToast] showToast:SobotKitLocalString(@"复制成功！") duration:1.0f view:self.view position:SobotToastPositionCenter];
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
@end
