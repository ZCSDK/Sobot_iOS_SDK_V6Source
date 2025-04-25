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

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
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
    [self updateNavOrTopView];
}


#pragma mark -- 添加子控件
-(void)createSubviews{
    // 构建 联系客服和联系热线按钮
    _serviceBtnBgView = [self createBtmView:YES];
    
    // 上部
    _titleLab = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.view addSubview:iv];
        iv.textColor = [ZCUIKitTools zcgetscTopTextColor];
        iv.backgroundColor = UIColor.clearColor;
        iv.numberOfLines = 0;
        iv.font = SobotFontBold16;
        iv.text = sobotConvertToString(_questionTitle);
        self.titleLabPR = sobotLayoutPaddingRight(-16, iv, self.view);
        self.titleLabPL = sobotLayoutPaddingLeft(16, iv, self.view);
        [self.view addConstraint:self.titleLabPR];
        [self.view addConstraint:self.titleLabPL];
        self.titleLabPT = sobotLayoutPaddingTop(NavBarHeight + 16, iv, self.view);
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
        NSString *jSString = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);\
var style = document.createElement('style');\
style.type = 'text/css';\
style.innerHTML = '* { padding:0px;margin:0px; }';\
document.head.appendChild(style);";
        WKUserScript *wkUserScript = [[WKUserScript alloc] initWithSource:jSString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        [config.userContentController addUserScript:wkUserScript];
        WKWebView *iv = [[WKWebView alloc]initWithFrame:CGRectZero configuration:config];
        [self.view addSubview:iv];
        iv.navigationDelegate = self;
        [iv setOpaque:NO];
//        iv.backgroundColor = [ZCUIKitTools zcgetLightGrayBackgroundColor];
        iv.backgroundColor = [ZCUIKitTools zcgetLightGrayDarkBackgroundColor];
        [self.view addConstraint:sobotLayoutMarginTop(16, iv, self.titleLab)];
        self.wkPL = sobotLayoutPaddingLeft(16, iv, self.view);
        self.wkPR = sobotLayoutPaddingRight(-16, iv, self.view);
        [self.view addConstraint:self.wkPR];
        [self.view addConstraint:self.wkPL];
        [self.view addConstraint:sobotLayoutMarginBottom(-16, iv, self.serviceBtnBgView)];
        

        iv;
    });
    
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.automaticallyAdjustsScrollViewInsets = NO;

    if(@available(iOS 11.0, *)) {
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}

-(void)loadData{
    [ZCLibServer getHelpDocByDocIdWith:self.appId DocId:self.docId start:^{
        
    } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
        if (dict) {
            NSDictionary * dataDic = dict[@"data"];
            if ([dataDic isKindOfClass:[NSDictionary class]] && dataDic != nil) {
                NSString *textHtml = sobotConvertToString(dict[@"data"][@"answerDesc"]);
                textHtml = [textHtml stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
                textHtml = [textHtml stringByReplacingOccurrencesOfString:@"<P>" withString:@""];
                textHtml = [textHtml stringByReplacingOccurrencesOfString:@"</P>" withString:@"<br/>"];
                textHtml = [textHtml stringByReplacingOccurrencesOfString:@"</p>" withString:@"<br/>"];
                [self->_webView loadHTMLString:textHtml baseURL:nil];
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
            self.titleLabPT = sobotLayoutPaddingTop(NavBarHeight+16, self.titleLab, self.view);
        }else{
            self.titleLabPT = sobotLayoutPaddingTop(e.top+16, self.titleLab, self.view);
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
    self.titleLabPL = sobotLayoutPaddingLeft(e.left+16, self.titleLab, self.view);
    self.titleLabPR = sobotLayoutPaddingRight(-e.right-16, self.titleLab, self.view);
    self.wkPR = sobotLayoutPaddingRight(-e.right - 16, self.webView, self.view);
    self.wkPL = sobotLayoutPaddingLeft(e.left + 16, self.webView, self.view);
    [self.view addConstraint:self.wkPR];
    [self.view addConstraint:self.wkPL];
    [self.view addConstraint:self.titleLabPL];
    [self.view addConstraint:self.titleLabPR];
    self.titleLabPT.priority = 1000;
    [self.view addConstraint:self.titleLabPT];
    // 横竖屏更新导航栏渐变色
    [self updateTopViewBgColor];
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
    CGFloat screenW = ScreenWidth>ScreenHeight?ScreenHeight:ScreenWidth;
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
                       "document.getElementsByTagName('head')[0].appendChild(script);",screenW-16];// SCREEN_WIDTH是屏幕宽度
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
- (void)btmButtonClick:(UIButton *)sender{
    NSLog(@"点击了联系客服 %ld",(long)sender.tag);
    if(sender.tag == 1){
        if (self.OpenZCSDKTypeBlock) {
            self.OpenZCSDKTypeBlock(self);
        }else{
            [ZCSobotApi openZCChat:_kitInfo with:self pageBlock:^(id  _Nonnull object, ZCPageStateType type) {
                
            }];
        }
        return;
    }
    [super btmButtonClick:sender];
}

@end
