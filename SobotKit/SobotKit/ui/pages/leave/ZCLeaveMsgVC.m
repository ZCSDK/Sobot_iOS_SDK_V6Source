//
//  ZCLeaveMsgVC.m
//  SobotKit
//
//  Created by lizh on 2022/9/26.
//

#import "ZCLeaveMsgVC.h"
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClient.h>
#import "ZCUIKitTools.h"
#import "ZCUIPlaceHolderTextView.h"
#import "SobotHtmlFilter.h"
#import "ZCUIWebController.h"
#import "ZCUITextView.h"
#import "ZCUITextView.h"
@interface ZCLeaveMsgVC ()<SobotEmojiLabelDelegate,UITextFieldDelegate,UITextViewDelegate>
{
    NSString *callURL;
    CGPoint contentoffset;// 记录list的偏移量
    UILabel *detailLab ;  // 问题描述
}
@property (nonatomic,strong) SobotEmojiLabel *tipLab;

@property (nonatomic,strong) UIScrollView *scrollView;

@property (nonatomic,strong) UIButton *commitBtn;

@property (nonatomic,strong) UILabel *label;

@property (nonatomic,strong) UIView *lineView1;

@property (nonatomic,strong) UIView *lineView2;

@property (nonatomic,strong) UIView *headerView;

@property (nonatomic,strong) UILabel *askTipLab;

@property (nonatomic,strong) ZCUITextView *textDesc;

@property (nonatomic,strong) UIView *lineView;

@property (nonatomic,strong)NSLayoutConstraint *commitBtnPB;

//内容视图
@property (nonatomic,strong) UIView *bgConentView;

@property(nonatomic,strong) NSLayoutConstraint *bgContentW;

@property(nonatomic,strong) NSLayoutConstraint *bgContentH;

@property(nonatomic,strong) NSLayoutConstraint *scrollViewPT;
@end

@implementation ZCLeaveMsgVC

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }
    self.view.backgroundColor = [ZCUIKitTools zcgetLightGrayDarkBackgroundColor];
    [self createVCTitleView];
    [self updateNavOrTopView];
    [self createItemView];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [self.view addGestureRecognizer:tap];    
    if([ZCPlatformTools checkLeaveMessageModule]){
        [SobotUITools showAlert:SobotKitLocalString(@"由于服务到期，该功能已关闭。") message:nil cancelTitle:SobotKitLocalString(@"确定") titleArray:nil viewController:self confirm:^(NSInteger buttonTag) {
            if (self.navigationController) {
                [self.navigationController popViewControllerAnimated:NO];
            }else{
                [self dismissViewControllerAnimated:NO completion:nil];
            }
        }];
    }
}

#pragma mark --423新版UI界面
-(void)createItemView{
    CGFloat y = 0;
    if (self.navigationController.navigationBarHidden) {
        y = NavBarHeight;
    }
    
    _scrollView = ({
        UIScrollView *iv =[[UIScrollView alloc]init];
        [self.view addSubview:iv];
        iv.showsHorizontalScrollIndicator = NO;
        iv.showsVerticalScrollIndicator = YES;
        iv.alwaysBounceVertical = NO;
        iv.alwaysBounceHorizontal = NO;
        iv.pagingEnabled = NO;
        iv.bounces = NO;
        iv.scrollEnabled = YES;
        iv.delegate = self;
        iv.userInteractionEnabled = YES;
        _scrollViewPT = sobotLayoutPaddingTop(y, iv, self.view);
        [self.view addConstraint:_scrollViewPT];
        [self.view addConstraint:sobotLayoutPaddingLeft(0, iv, self.view)];
        [self.view addConstraint:sobotLayoutPaddingRight(0, iv, self.view)];
        [self.view addConstraint:sobotLayoutPaddingBottom(0, iv, self.view)];
        [iv setContentSize:CGSizeMake(0, ScreenHeight-y)];
        iv;
    });
    
    _bgConentView = ({
        UIView *iv = [[UIView alloc]init];
        iv.backgroundColor = UIColor.clearColor;
        [_scrollView addSubview:iv];
        [_scrollView addConstraint:sobotLayoutPaddingLeft(0, iv, _scrollView)];
        [_scrollView addConstraint:sobotLayoutPaddingTop(0, iv, _scrollView)];
        self.bgContentW = sobotLayoutEqualWidth(ScreenWidth, iv, NSLayoutRelationEqual);
        [_scrollView addConstraint:self.bgContentW];
        [_scrollView addConstraint:sobotLayoutPaddingBottom(0, iv, _scrollView)];
        self.bgContentH = sobotLayoutEqualHeight(ScreenHeight-y, iv, NSLayoutRelationEqual);
        [_scrollView addConstraint:self.bgContentH];
        iv;
    });
    
    _headerView = ({
        UIView *iv = [[UIView alloc]init];
        [_bgConentView addSubview:iv];
        [_bgConentView addConstraint:sobotLayoutPaddingTop(0, iv, _bgConentView)];
        [_bgConentView addConstraint:sobotLayoutPaddingLeft(0, iv, _bgConentView)];
        [_bgConentView addConstraint:sobotLayoutPaddingRight(0, iv, _bgConentView)];
        iv.backgroundColor = UIColorFromKitModeColor(SobotColorHeaderBg);
        iv;
    });
    
    _tipLab = ({
        SobotEmojiLabel *iv = [[SobotEmojiLabel alloc]initWithFrame:CGRectZero];
        [self.headerView addSubview:iv];
        iv.font = SobotFont12;
        iv.numberOfLines = 0;
        iv.backgroundColor = [UIColor clearColor];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:UIColorFromKitModeColor(SobotColorHeaderText)];
        iv.isNeedAtAndPoundSign = NO;
        iv.disableEmoji = NO;
        iv.lineSpacing = 10.0f;
        [iv setLinkColor:[ZCUIKitTools zcgetChatLeftLinkColor]];
        iv.delegate = self;
        NSString *text = @"";
        if (_msgTxt !=nil && _msgTxt.length > 0) {
            text = sobotConvertToString(_msgTxt);
        }
         if(sobotConvertToString([ZCUICore getUICore].kitInfo.leaveMsgGuideContent).length > 0){
            text = SobotKitLocalString(sobotConvertToString([ZCUICore getUICore].kitInfo.leaveMsgGuideContent));
        }
        text = [SobotHtmlCore filterHTMLTag:text];
        
        [SobotHtmlCore filterHtml:text result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
            if (text1.length > 0 && text1 != nil) {
                iv.attributedText =   [SobotHtmlFilter setHtml:text1 attrs:arr view:iv textColor:UIColorFromKitModeColor(SobotColorHeaderText) textFont:[UIFont systemFontOfSize:14] linkColor:[ZCUIKitTools zcgetChatLeftLinkColor] lineSpacing:5];
            }else{
                iv.attributedText = [[NSAttributedString alloc] initWithString:@""];
            }
        }];
        [self.headerView addConstraint:sobotLayoutPaddingTop(10, iv, self.headerView)];
        [self.headerView addConstraint:sobotLayoutPaddingLeft(16, iv, self.headerView)];
        [self.headerView addConstraint:sobotLayoutPaddingRight(-16, iv, self.headerView)];
        [self.headerView addConstraint:sobotLayoutPaddingBottom(-10, iv, self.headerView)];
        
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            iv.textAlignment = NSTextAlignmentRight;
        }else{
            iv.textAlignment = NSTextAlignmentLeft;
        }
        iv;
    });
    
    _askTipLab = ({
        UILabel *iv = [[UILabel alloc]init];
        [_bgConentView addSubview:iv];
        iv.textColor = UIColorFromKitModeColor(SobotColorTextSub);
        iv.font = SobotFont14;
        iv.numberOfLines = 0;
        iv.text = SobotKitLocalString(@"*问题描述");
        [_bgConentView addConstraint:sobotLayoutMarginTop(12, iv, self.headerView)];
        [_bgConentView addConstraint:sobotLayoutPaddingLeft(16, iv, _bgConentView)];
        [_bgConentView addConstraint:sobotLayoutPaddingRight(-16, iv, _bgConentView)];
        [_bgConentView addConstraint:sobotLayoutEqualHeight(20, iv, NSLayoutRelationEqual)];
        iv.attributedText = [self getOtherColorString:@"*" Color:[UIColor redColor] withString:[NSString stringWithFormat:@"* %@",SobotKitLocalString(@"问题描述")]];
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            iv.textAlignment = NSTextAlignmentRight;
        }else{
            iv.textAlignment = NSTextAlignmentLeft;
        }
        iv;
    });
    
    _textDesc = ({
        ZCUITextView *iv = [[ZCUITextView alloc]init];
        iv.placeholder = SobotKitLocalString(@"请输入");
        [iv setPlaceholderColor:UIColorFromKitModeColor(SobotColorTextSub1)];
        [iv setFont:SobotFont14];
        [iv setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
        iv.delegate = self;
        iv.placeholederFont = SobotFont14;
        iv.layer.cornerRadius = 4.0f;
        iv.layer.masksToBounds = YES;
        [iv setBackgroundColor:UIColor.clearColor];
        [_bgConentView addSubview:iv];
                
        NSString *tmp = sobotConvertToString(self.msgTmp);
        tmp = [SobotHtmlCore filterHTMLTag:tmp];
        while ([tmp hasPrefix:@"\n"]) {
            tmp=[tmp substringWithRange:NSMakeRange(1, tmp.length-1)];
        }
        if(sobotConvertToString([ZCUICore getUICore].kitInfo.leaveContentPlaceholder).length > 0){
            tmp = SobotKitLocalString(sobotConvertToString([ZCUICore getUICore].kitInfo.leaveContentPlaceholder));
        }
        [SobotHtmlCore filterHtml:tmp result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
           iv.placeholder = text1;
           iv.placeholderLinkColor = UIColorFromKitModeColor(SobotColorTextSub1);
        }];
        [_bgConentView addConstraint:sobotLayoutMarginTop(0, iv, self.askTipLab)];
        [_bgConentView addConstraint:sobotLayoutPaddingLeft(16-7, iv, _bgConentView)];
        [_bgConentView addConstraint:sobotLayoutPaddingRight(-16+7, iv, _bgConentView)];
        [_bgConentView addConstraint:sobotLayoutEqualHeight(64, iv, NSLayoutRelationEqual)];
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            iv.textAlignment = NSTextAlignmentRight;
            // 获取UITextView的UITextRange
                UITextRange *textRange = [iv textRangeFromPosition:iv.beginningOfDocument toPosition:iv.endOfDocument];
            [iv setBaseWritingDirection:UITextWritingDirectionRightToLeft forRange:textRange];
        }else{
            iv.textAlignment = NSTextAlignmentLeft;
            // 获取UITextView的UITextRange
                UITextRange *textRange = [iv textRangeFromPosition:iv.beginningOfDocument toPosition:iv.endOfDocument];
            [iv setBaseWritingDirection:NSWritingDirectionLeftToRight forRange:textRange];
        }
        iv.tintColor = [ZCUIKitTools zcgetServerConfigBtnBgColor];
        iv;
    });
    
    _lineView = ({
        UIView *iv = [[UIView alloc]init];
        [_bgConentView addSubview:iv];
        iv.backgroundColor =UIColorFromKitModeColor(SobotColorBgTopLine);
        [_bgConentView addConstraint:sobotLayoutPaddingLeft(16, iv, _bgConentView)];
        [_bgConentView addConstraint:sobotLayoutPaddingRight(0, iv, _bgConentView)];
        [_bgConentView addConstraint:sobotLayoutEqualHeight(0.5, iv, NSLayoutRelationEqual)];
        [_bgConentView addConstraint:sobotLayoutMarginTop(12, iv, _textDesc)];
        iv;
    });
    
    
    _label = ({
        UILabel *iv = [[UILabel alloc] init];
        iv.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [iv setFont:SobotFont14];
        [iv setText:sobotConvertToString(_leaveExplain)];
        [iv setBackgroundColor:[UIColor clearColor]];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:UIColorFromKitModeColor(SobotColorTextSub1)];
        iv.numberOfLines = 0;
        [_bgConentView addSubview:iv];
        [_bgConentView addConstraint:sobotLayoutMarginTop(12, iv, self.lineView)];
        [_bgConentView addConstraint:sobotLayoutPaddingLeft(16, iv, _bgConentView)];
        [_bgConentView addConstraint:sobotLayoutPaddingRight(-16, iv, _bgConentView)];
        if(sobotConvertToString(_leaveExplain).length <= 0){
            iv.hidden = YES;
        }
        iv;
    });
    
    
    _commitBtn = ({
        UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
        [iv setTitle:SobotKitLocalString(@"提交") forState:UIControlStateNormal];
        [iv setTitle:SobotKitLocalString(@"提交") forState:UIControlStateSelected];
        [iv setTitleColor:[ZCUIKitTools zcgetRobotBtnTitleColor] forState:UIControlStateNormal];
        [iv setBackgroundColor:[ZCUIKitTools zcgetServerConfigBtnBgColor]];
        iv.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        iv.tag = BUTTON_MORE;
        [iv addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        iv.layer.masksToBounds = YES;
        iv.layer.cornerRadius = 4.0f;
        [_bgConentView addSubview:iv];
        self.commitBtnPB = sobotLayoutPaddingBottom(-XBottomBarHeight, iv, _bgConentView);
        [_bgConentView addConstraint:self.commitBtnPB];
        [_bgConentView addConstraint:sobotLayoutPaddingLeft(16, iv, _bgConentView)];
        [_bgConentView addConstraint:sobotLayoutPaddingRight(-16, iv, _bgConentView)];
        [_bgConentView addConstraint:sobotLayoutEqualHeight(40, iv, NSLayoutRelationEqual)];
        iv;
    });
   
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(NSMutableAttributedString *)getOtherColorString:(NSString *)string Color:(UIColor *)Color withString:(NSString *)originalString
{
    NSMutableString *temp = [NSMutableString stringWithString:sobotConvertToString(originalString)];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:temp];
    if (string.length) {
        NSRange range = [temp rangeOfString:string];
        [str addAttribute:NSForegroundColorAttributeName value:Color range:range];
        return str;
    }
    return str;
}


//判断是否全是空格
- (BOOL)isEmpty:(NSString *)str {
    if (!str) {
        return true;
    } else {
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *trimedString = [str stringByTrimmingCharactersInSet:set];
        if ([trimedString length] == 0) {
            return true;
        } else {
            return false;
        }
    }
}


#pragma mark - 返回和提交接口调用事件
-(IBAction)buttonClick:(UIButton *) sender{
    if(sender.tag == SobotButtonClickBack){
        if (self.navigationController) {
            [self.navigationController popViewControllerAnimated:NO];
        }else{
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    }else if (sender.tag == BUTTON_MORE){
        if (_textDesc.text.length <=0 || [self isEmpty:sobotConvertToString(_textDesc.text)]) {
            [[SobotToast shareToast] showToast:SobotKitLocalString(@"请填写问题描述") duration:2 view:[UIApplication sharedApplication].keyWindow position:SobotToastPositionCenter];
            return;
        }
        __weak ZCLeaveMsgVC * saveSelf = self;
        [ZCLibServer getLeaveMsgWith:[[ZCUICore getUICore] getLibConfig].uid Content:_textDesc.text msgType:0 groupId:self.groupId start:^{
            
        } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
            if (dict) {
                if(!sobotIsNull(dict[@"data"])){
                    int status = [dict[@"data"][@"status"] intValue];
                    if(status == 0){
                        [[SobotToast shareToast] showToast:sobotConvertToString(dict[@"data"][@"msg"]) duration:1.0f view:saveSelf.view position:SobotToastPositionCenter];
                        return;
                    }
                }
                [[NSNotificationCenter defaultCenter]removeObserver:self];
                // 返回，发送留言消息
                if (saveSelf.passMsgBlock) {
                    saveSelf.passMsgBlock(saveSelf.textDesc.text);
                }
                if (saveSelf.navigationController) {
                    [saveSelf.navigationController popViewControllerAnimated:NO];
                }else{
                    [saveSelf dismissViewControllerAnimated:NO completion:nil];
                }
            }
        } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
            [[SobotToast shareToast] showToast:sobotConvertToString(errorMessage) duration:1.0f view:saveSelf.view position:SobotToastPositionCenter];
            NSLog(@"%@",errorMessage);
        }];
    }
}

#pragma mark - 键盘事件

-(void)keyBoardWillShow:(NSNotification *) notification{
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat keyboardHeight = [[[notification userInfo] objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue].size.height;
   
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationDelegate:self];
    {
//       self.commitBtnPB.constant = -XBottomBarHeight -keyboardHeight;
    }
    // commit animations
    [UIView commitAnimations];
}

//键盘隐藏
- (void)keyBoardWillHide:(NSNotification *)notification {
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView beginAnimations:@"bottomBarDown" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView commitAnimations];
    [UIView animateWithDuration:0.25 animations:^{
//        self.commitBtnPB.constant = -XBottomBarHeight;
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
    if ([ZCUIKitTools getSobotIsRTLLayout]) {
        [self setLeftTags:@[] rightTags:rightItem titleView:nil];
    }else{
        [self setLeftTags:rightItem rightTags:@[] titleView:nil];
    }
    if (!self.navigationController.navigationBarHidden) {
        if([ZCUIKitTools getZCThemeStyle] == SobotThemeMode_Light){
            if(sobotGetSystemDoubleVersion() >= 13){
                self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
                self.navigationController.toolbar.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
            }
        }
    }else{
//        self.moreButton.hidden = YES;
        self.titleLabel.hidden = NO;
        self.backButton.hidden = NO;
//        self.bottomLine.hidden = YES;
    }
}

// 设置页面头部导航相关View
-(void)setHeaderConfig{
    if(!self.navigationController.navigationBarHidden){
        if (self.navigationController.navigationBar.translucent) {
         self.navigationController.navigationBar.translucent = NO;
        }
        self.title = SobotKitLocalString(@"留言消息");
        if (![[ZCLibClient getZCLibClient].libInitInfo.absolute_language hasPrefix:@"zh-"]
            || !(sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.absolute_language).length == 0 && [sobotGetLanguagePrefix() hasPrefix:@"zh-"])){
            [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[ZCUIKitTools zcgetTitleFont],NSForegroundColorAttributeName:[ZCUIKitTools zcgetTopViewTextColor]}];
        }else{
            [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[ZCUIKitTools zcgetTitleFont],NSForegroundColorAttributeName:[ZCUIKitTools zcgetTopViewTextColor]}];
        }
    }else{
        self.titleLabel.text = SobotKitLocalString(@"留言消息");
        if (![[ZCLibClient getZCLibClient].libInitInfo.absolute_language hasPrefix:@"zh-"]
            || !(sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.absolute_language).length == 0 && [sobotGetLanguagePrefix() hasPrefix:@"zh-"])){
            self.titleLabel.font = [ZCUIKitTools zcgetTitleFont];
        }
    }
}

-(void)tapAction:(UITapGestureRecognizer *)sender{
    [self hideKeyboard];
}

#pragma mark -- 键盘滑动的高度

- (void) hideKeyboard {
    [_textDesc resignFirstResponder];
    [self allHideKeyBoard];
}

- (void)allHideKeyBoard
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

#pragma mark - 更新子视图
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self setHeaderConfig];
    [self updateContenView];
}

// 适配iOS 13以上的横竖屏切换
-(void)viewSafeAreaInsetsDidChange{
    [super viewSafeAreaInsetsDidChange];
    // 横竖屏更新导航栏渐变色
    [self updateTopViewBgColor];
}

#pragma mark -- 横竖屏切换时，重新设置宽高 + 滚动偏移量
-(void)updateContenView{
    CGFloat y = 0;
    if (self.navigationController.navigationBarHidden) {
        y = NavBarHeight;
    }
  
    self.bgContentW.constant = ScreenWidth;
    self.bgContentH.constant = ScreenHeight -NavBarHeight;
    CGFloat h = ScreenHeight-NavBarHeight;
//    if (ScreenWidth >ScreenHeight) {
//        [_label layoutIfNeeded];
//        // 获取实际高度
//        CGRect lf = _label.frame;
//        if (lf.size.height + lf.origin.y > ScreenHeight-NavBarHeight) {
//            h = ScreenHeight +(lf.size.height + lf.origin.y - ScreenHeight-NavBarHeight);
//        }
//    }
    self.scrollView.contentSize = CGSizeMake(ScreenWidth, h);
}
#pragma mark - 代理事件
- (void)SobotEmojiLabel:(SobotEmojiLabel*)emojiLabel didSelectLink:(NSString*)link withType:(SobotEmojiLabelLinkType)type{
    [self doClickURL:link text:@""];
}

// 链接点击
-(void)doClickURL:(NSString *)url text:(NSString * )htmlText{
    if(url){
        url=[url stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            if([url hasPrefix:@"tel:"] || sobotValidateMobileWithRegex(url, [ZCUIKitTools zcgetTelRegular])){
                callURL=url;
                [SobotUITools showAlert:nil message:[url stringByReplacingOccurrencesOfString:@"tel:" withString:@""] cancelTitle:SobotKitLocalString(@"取消") viewController:self confirm:^(NSInteger buttonTag) {
                    if(buttonTag>=0){
//                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callURL]];
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callURL] options:@{} completionHandler:^(BOOL res) {
                                        
                             }];
                    }
                } buttonTitles:SobotKitLocalString(@"呼叫"), nil];
            }else if([url hasPrefix:@"mailto:"] || sobotValidateEmail(url)){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            }else{
                if (![url hasPrefix:@"https"] && ![url hasPrefix:@"http"]) {
                    url = [@"http://" stringByAppendingString:url];
                }
                ZCUIWebController *webPage=[[ZCUIWebController alloc] initWithURL:sobotUrlEncodedString(url)];
                if(self.navigationController != nil ){
                    [self.navigationController pushViewController:webPage animated:YES];
                }else{
                    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:webPage];
                    nav.navigationBarHidden=YES;
                    nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
                    [self presentViewController:nav animated:YES completion:^{
                        
                    }];
                }
            }
        }
}

-(BOOL)openQQ:(NSString *)qq{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"mqq://im/chat?chat_type=wpa&uin=%@&version=1&src_type=web",qq]];
    if([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url];
        return NO;
    }
    else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://wpa.qq.com/msgrd?v=3&uin=%@&site=qq&menu=yes",qq]]];
        return YES;
    }
}


#pragma mark -  这个代理方法不能执行，会影响镜像的实现
//- (void)textViewDidChange:(UITextView *)textView{
//    if (textView.text.length == 0) {
//        return;
//    }
//    if (sobotGetSystemDoubleVersion()>=16.0) {
//        UITextRange *selectedRange = [textView markedTextRange];
//        NSString * newText = [textView textInRange:selectedRange]; //获取高亮部分
//        if(newText.length>0)
//            return;
//        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//        paragraphStyle.lineSpacing = 5;// 字体的行间距
//        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15],NSParagraphStyleAttributeName:paragraphStyle};
//        textView.attributedText = [[NSAttributedString alloc] initWithString:textView.text attributes:attributes];
//    }
//}

    
@end
