//
//  ZCServiceDetailVC.m
//  SobotKit
//
//  Created by lizh on 2022/9/16.
//

#import "ZCServiceDetailVC.h"
#import <WebKit/WebKit.h>
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClient.h>
#import "ZCUIKitTools.h"
@interface ZCServiceDetailVC ()<WKNavigationDelegate>{

}

@property(nonatomic,strong) UIView *serviceBtnBgView;
@property(nonatomic,strong) WKWebView *webView;
@property(nonatomic,strong) NSString *htmlStr;
@property(nonatomic,strong) UILabel *titleLab;
@property(nonatomic,strong) UIButton *telButton;
@property(nonatomic,strong) NSLayoutConstraint *telBtnEW;
@property(nonatomic,strong) NSLayoutConstraint *titleLabPT;
@property(nonatomic,strong) NSLayoutConstraint *webViewMT;
@property(nonatomic,strong) NSLayoutConstraint *titleLabPL;
@property(nonatomic,strong) NSLayoutConstraint *titleLabPR;
@property(nonatomic,strong) NSLayoutConstraint *wkPL;
@property(nonatomic,strong) NSLayoutConstraint *wkPR;

@end

@implementation ZCServiceDetailVC
#pragma mark - 返回事件
-(void)buttonClick:(UIButton *)sender{
    if (sender.tag == SobotButtonClickBack) {
        if (self.navigationController) {
            [self.navigationController popViewControllerAnimated:NO];
        }else{
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [ZCUIKitTools zcgetLightGrayDarkBackgroundColor];
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }
    [self createVCTitleView];
    [self updateNavOrTopView];
    [self createSubviews];
    [self loadData];
}


#pragma mark -- 添加子控件
-(void)createSubviews{
    // 构建 联系客服和联系热线按钮
    _serviceBtnBgView = [[UIView alloc]init];
    _serviceBtnBgView.backgroundColor = UIColorFromKitModeColor(SobotColorBgSub2Dark1);
    [self.view addSubview:_serviceBtnBgView];
    [self createHelpCenterButtons:10 sView:_serviceBtnBgView];
    [self.view addConstraint:sobotLayoutPaddingBottom(0, _serviceBtnBgView, self.view)];
    [self.view addConstraint:sobotLayoutPaddingLeft(0, _serviceBtnBgView, self.view)];
    [self.view addConstraint:sobotLayoutEqualHeight(80, _serviceBtnBgView, NSLayoutRelationEqual)];
    [self.view addConstraint:sobotLayoutPaddingRight(0, _serviceBtnBgView, self.view)];
    
    // 上部
    _titleLab = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.view addSubview:iv];
        iv.textColor = [ZCUIKitTools zcgetscTopTextColor];
        iv.numberOfLines = 0;
        iv.font = SobotFont20;
        iv.text = sobotConvertToString(_questionTitle);
        self.titleLabPR = sobotLayoutPaddingRight(-10, iv, self.view);
        self.titleLabPL = sobotLayoutPaddingLeft(10, iv, self.view);
        [self.view addConstraint:self.titleLabPR];
        [self.view addConstraint:self.titleLabPL];
        self.titleLabPT = sobotLayoutPaddingTop(NavBarHeight + 20, iv, self.view);
        [self.view addConstraint:self.titleLabPT];
        iv;
    });
    
    _webView = ({
        //创建网页配置对象
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        // 创建设置对象
        WKPreferences *preference = [[WKPreferences alloc]init];
        // 设置字体大小(最小的字体大小)
        preference.minimumFontSize = 14;
        // 设置偏好设置对象
        config.preferences = preference;
        // 自适应屏幕宽度js
        NSString *jSString = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
        WKUserScript *wkUserScript = [[WKUserScript alloc] initWithSource:jSString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        [config.userContentController addUserScript:wkUserScript];
        WKWebView *iv = [[WKWebView alloc]initWithFrame:CGRectMake(0, 120, ScreenWidth, 300) configuration:config];
        [self.view addSubview:iv];
        iv.navigationDelegate = self;
        [iv setOpaque:NO];
        iv.backgroundColor = [ZCUIKitTools zcgetLightGrayBackgroundColor];
        [self.view addConstraint:sobotLayoutMarginTop(12, iv, self.titleLab)];
        self.wkPL = sobotLayoutPaddingLeft(0, iv, self.view);
        self.wkPR = sobotLayoutPaddingRight(0, iv, self.view);
        [self.view addConstraint:self.wkPR];
        [self.view addConstraint:self.wkPL];
        [self.view addConstraint:sobotLayoutMarginBottom(-1, iv, self.serviceBtnBgView)];
        iv;
    });

}

-(void)loadData{
    [ZCLibServer getHelpDocByDocIdWith:self.appId DocId:self.docId start:^{
        
    } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
        if (dict) {
            NSDictionary * dataDic = dict[@"data"];
            if ([dataDic isKindOfClass:[NSDictionary class]] && dataDic != nil) {
                [self->_webView loadHTMLString:sobotConvertToString(dict[@"data"][@"answerDesc"]) baseURL:nil];
                //                    [webView loadHTMLString:sobotConvertToString(@"<a href=\"https://www.baidu.com\" >智齿</a>") baseURL:nil];
                self->_titleLab.text = sobotConvertToString(dict[@"data"][@"questionTitle"]);
            }
        }
    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
        
    }];
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
        self.title = SobotKitLocalString(@"问题详情");
    }else{
        self.moreButton.hidden = YES;
        self.titleLabel.hidden = NO;
        self.backButton.hidden = NO;
        self.bottomLine.hidden = YES;
        self.titleLabel.text = SobotKitLocalString(@"问题详情");
    }
}

// 适配iOS 13以上的横竖屏切换
-(void)viewSafeAreaInsetsDidChange{
    [super viewSafeAreaInsetsDidChange];
    UIEdgeInsets e = self.view.safeAreaInsets;
    if (self.titleLabPT) {
        [self.view removeConstraint:self.titleLabPT];
    }
    if (self.titleLabPL) {
        [self.view removeConstraint:self.titleLabPL];
    }
    if (self.titleLabPR) {
        [self.view removeConstraint:self.titleLabPR];
    }
    if (self.wkPL) {
        [self.view removeConstraint:self.wkPL];
    }
    if (self.wkPR) {
        [self.view removeConstraint:self.wkPR];
    }
    if(e.left > 0){
        // 横屏
        if (self.navigationController.navigationBarHidden || self.topView) {
            self.titleLabPT = sobotLayoutPaddingTop(NavBarHeight+20, self.titleLab, self.view);
        }else{
            self.titleLabPT = sobotLayoutPaddingTop(e.top+20, self.titleLab, self.view);
        }

    }else{
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
        self.titleLabPT = sobotLayoutPaddingTop(TY +20, self.titleLab, self.view);
    }
    self.titleLabPL = sobotLayoutPaddingLeft(e.left+10, self.titleLab, self.view);
    self.titleLabPR = sobotLayoutPaddingRight(-e.right-10, self.titleLab, self.view);
    self.wkPR = sobotLayoutPaddingRight(-e.right, self.webView, self.view);
    self.wkPL = sobotLayoutPaddingLeft(e.left, self.webView, self.view);
    [self.view addConstraint:self.wkPR];
    [self.view addConstraint:self.wkPL];
    [self.view addConstraint:self.titleLabPL];
    [self.view addConstraint:self.titleLabPR];
    self.titleLabPT.priority = 1000;
    [self.view addConstraint:self.titleLabPT];
    // 横竖屏更新导航栏渐变色
    [self updateCenterViewBgColor];
}


#pragma mark - WK代理事件
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    [[SobotToast shareToast] showProgress:@"" with:self.view];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [[SobotToast shareToast] dismisProgress];
    //重写contentSize,防止左右滑动
    CGSize size = webView.scrollView.contentSize;
    size.width= webView.scrollView.frame.size.width;
    webView.scrollView.contentSize= size;
    NSString *jsStr = [NSString stringWithFormat:@"var script = document.createElement('script');"
                       "script.type = 'text/javascript';"
                       "script.text = \"function ResizeImages() { "
                       "var myimg,oldwidth;"
                       "var maxwidth=%lf;" //缩放系数
                       "for(i=0;i <document.images.length;i++){"
                       "myimg = document.images[i];"
                       "if(myimg.width > maxwidth){"
                       "oldwidth = myimg.width;"
                       "myimg.width = maxwidth;"
                       "}"
                       "}"
                       "}\";"
                       "document.getElementsByTagName('head')[0].appendChild(script);",ScreenWidth-16];// SCREEN_WIDTH是屏幕宽度
    [webView evaluateJavaScript:jsStr completionHandler:nil];
    [webView evaluateJavaScript:@"ResizeImages();" completionHandler:nil];
    [webView evaluateJavaScript:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '100%'" completionHandler:nil];
    //设置颜色
    if([SobotUITools getSobotThemeMode] == SobotThemeMode_Dark){
        [webView evaluateJavaScript:@"document.getElementsByTagName('body')[0].style.webkitTextFillColor= '#FFFFFF'" completionHandler:nil];
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    [[SobotToast shareToast] dismisProgress];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    // 如果是跳转一个新页面
    if (navigationAction.targetFrame == nil) {
        [webView loadRequest:navigationAction.request];
    }
    NSString *urlString = [navigationAction.request.URL absoluteString];
    
    if (![urlString isEqualToString:@"about:blank"]) {
        if([[ZCUICore getUICore] LinkClickBlock] == nil || ![ZCUICore getUICore].LinkClickBlock(ZCLinkClickTypeURL,urlString,@{})){
            decisionHandler(WKNavigationActionPolicyAllow);
        }else{
            decisionHandler(WKNavigationActionPolicyCancel);
        }
    }else{
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

//获取宽度已经适配于webView的html。这里的原始html也可以通过js从webView里获取
- (NSString *)htmlAdjustWithPageWidth:(CGFloat )pageWidth
                                 html:(NSString *)html
{
    NSMutableString *str = [NSMutableString stringWithString:html];
    //计算要缩放的比例
    CGFloat initialScale = _webView.frame.size.width/pageWidth;
    //将</head>替换为meta+head
    NSString *stringForReplace = [NSString stringWithFormat:@"<meta name=\"viewport\" content=\" initial-scale=%f, minimum-scale=0.1, maximum-scale=2.0, user-scalable=yes\"></head>",initialScale];
    NSRange range =  NSMakeRange(0, str.length);
    //替换
    [str replaceOccurrencesOfString:@"</head>" withString:stringForReplace options:NSLiteralSearch range:range];
    return str;
}


#pragma mark - 联系客服 和 联系电话点击事件
-(void)openZCSDK:(UIButton *)sender{
    if(sender.tag == 1){
        if (self.OpenZCSDKTypeBlock) {
            self.OpenZCSDKTypeBlock(self);
        }else{
            [ZCSobotApi openZCChat:_kitInfo with:self pageBlock:^(id  _Nonnull object, ZCPageStateType type) {
                
            }];
        }
        return;
    }
    if (sender.tag == 2) {
        NSString *link = sobotConvertToString([ZCUICore getUICore].kitInfo.helpCenterTel);
        if(![link hasSuffix:@"tel:"]){
            link = [NSString stringWithFormat:@"tel:%@",link];
        }
        if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_9_x_Max) {
            [SobotUITools showAlert:nil message:[link stringByReplacingOccurrencesOfString:@"tel:" withString:@""] cancelTitle:SobotKitLocalString(@"取消") viewController:self confirm:^(NSInteger buttonTag) {
                if(buttonTag>=0){
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
                }
            } buttonTitles:SobotKitLocalString(@"呼叫"), nil];
        }else{
            if([ZCUICore getUICore].ZCViewControllerCloseBlock != nil){
                [ZCUICore getUICore].ZCViewControllerCloseBlock(self,ZC_PhoneCustomerService);
            }
            // 打电话
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
        }
    }
}

#pragma mark - 联系客服
-(UIButton *)createHelpCenterButtons:(CGFloat ) y sView:(UIView *) superView{
    CGFloat itemW =  (ScreenWidth - SobotNumber(24) - 20)/2;
    _telButton = [self createHelpCenterOpenButton];
    _telButton.tag = 2;
    [_telButton setTitle:sobotConvertToString([ZCUICore getUICore].kitInfo.helpCenterTelTitle) forState:UIControlStateNormal];
    [_telButton setTitle:sobotConvertToString([ZCUICore getUICore].kitInfo.helpCenterTelTitle) forState:UIControlStateHighlighted];
    [superView addSubview:_telButton];
    [superView addConstraint:sobotLayoutPaddingTop(y, _telButton, superView)];
    [superView addConstraint:sobotLayoutPaddingRight(SobotNumber(-12), _telButton, superView)];
    [superView addConstraint:sobotLayoutEqualHeight(44, _telButton, NSLayoutRelationEqual)];
    _telButton.hidden = YES;
    if(sobotConvertToString([ZCUICore getUICore].kitInfo.helpCenterTel).length > 0 && sobotConvertToString([ZCUICore getUICore].kitInfo.helpCenterTelTitle).length > 0){
        _telButton.hidden = NO;
        self.telBtnEW = sobotLayoutEqualWidth(itemW, _telButton, NSLayoutRelationEqual);
    }else{
        self.telBtnEW = sobotLayoutEqualWidth(0, _telButton, NSLayoutRelationEqual);
    }
    [superView addConstraint:self.telBtnEW];
    UIButton *serviceButton = [self createHelpCenterOpenButton];
    serviceButton.tag = 1;
    [superView addSubview:serviceButton];
    [superView addConstraint:sobotLayoutPaddingLeft(SobotNumber(12), serviceButton, superView)];
    [superView addConstraint:sobotLayoutPaddingTop(y, serviceButton, superView)];
    [superView addConstraint:sobotLayoutEqualHeight(44, serviceButton, NSLayoutRelationEqual)];
    if (!_telButton.hidden) {
        [superView addConstraint:sobotLayoutMarginRight(-20, serviceButton, _telButton)];
    }else{
        [superView addConstraint:sobotLayoutMarginRight(0, serviceButton, _telButton)];
    }
    return serviceButton;
}

#pragma mark - 在线客服按钮 和拨号按钮
-(UIButton *)createHelpCenterOpenButton{
    // 在线客服btn
    UIButton *serviceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    serviceBtn.type = 5;
    [serviceBtn setTitle:SobotKitLocalString(@"在线客服") forState:UIControlStateNormal];
    [serviceBtn setTitle:SobotKitLocalString(@"在线客服") forState:UIControlStateHighlighted];
    [serviceBtn setTitleColor:UIColorFromKitModeColor(SobotColorTextMain) forState:UIControlStateNormal];
    [serviceBtn setTitleColor:UIColorFromKitModeColor(SobotColorTextMain) forState:UIControlStateHighlighted];
    serviceBtn.titleLabel.font = SobotFontBold14;
    [serviceBtn addTarget:self action:@selector(openZCSDK:) forControlEvents:UIControlEventTouchUpInside];
    serviceBtn.layer.borderColor = UIColorFromKitModeColor(SobotColorBgLine).CGColor;
    serviceBtn.layer.borderWidth = 0.5f;
    serviceBtn.layer.cornerRadius = 22.0f;
    serviceBtn.layer.masksToBounds = YES;
    [serviceBtn setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark2)];
    [serviceBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 3)];
    [serviceBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 0)];
    [serviceBtn setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];
    [serviceBtn setAutoresizesSubviews:YES];
    return serviceBtn;
}
@end
