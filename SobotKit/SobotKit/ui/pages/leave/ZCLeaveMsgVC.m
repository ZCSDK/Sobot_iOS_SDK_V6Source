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
@interface ZCLeaveMsgVC ()<SobotEmojiLabelDelegate,UITextFieldDelegate,UITextViewDelegate>
{
    NSString *callURL;
    CGPoint contentoffset;// 记录list的偏移量
    UILabel *detailLab ;  // 问题描述
}
@property(nonatomic,strong) ZCUIPlaceHolderTextView *textView;

@property (nonatomic,strong) SobotEmojiLabel *tipLab;

@property (nonatomic,strong) UIScrollView *scrollView;

@property (nonatomic,strong) UIButton *commitBtn;

@property (nonatomic,strong) UILabel *label;

@property (nonatomic,strong) UIView *lineView1;

@property (nonatomic,strong) UIView *lineView2;
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
    // 设置导航栏标题
//    [self setHeaderConfig];
//    // 布局子视图
//    [self layoutSubViewsUI];
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

#pragma mark - 子视图构建
-(void)layoutSubViewsUI{
//    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (!sobotIsNull(_scrollView)) {
        [_scrollView removeFromSuperview];
    }
    if (!sobotIsNull(_tipLab)) {
        [_tipLab removeFromSuperview];
    }
    if (!sobotIsNull(_textView)) {
        [_textView removeFromSuperview];
    }
    if (!sobotIsNull(_lineView2)) {
        [_lineView2 removeFromSuperview];
    }
    if (!sobotIsNull(_lineView1)) {
        [_lineView1 removeFromSuperview];
    }
    if (!sobotIsNull(_commitBtn)) {
        [_commitBtn removeFromSuperview];
    }
    if (!sobotIsNull(_label)) {
        [_label removeFromSuperview];
    }
    
    
    CGFloat y = 0;
    if (self.navigationController.navigationBarHidden) {
        y = NavBarHeight;
    }
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, y, ScreenWidth, ScreenHeight -NavBarHeight)];
    _scrollView.scrollEnabled = YES;
    _scrollView.pagingEnabled = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.bounces = NO;
    _scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_scrollView];
    
    CGFloat Y = 0;
    if (self.navigationController.navigationBarHidden) {
        Y = NavBarHeight;
    }
    
    _tipLab = [[SobotEmojiLabel alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    _tipLab.font = SobotFont14;
    _tipLab.numberOfLines = 0;
    _tipLab.backgroundColor = [UIColor clearColor];
    [_tipLab setTextAlignment:NSTextAlignmentLeft];
    [_tipLab setTextColor:UIColorFromKitModeColor(SobotColorTextSub)];
    _tipLab.numberOfLines = 0;
    _tipLab.isNeedAtAndPoundSign = NO;
    _tipLab.disableEmoji = NO;
    
    _tipLab.lineSpacing = 3.0f;
    [_tipLab setLinkColor:[ZCUIKitTools zcgetChatLeftLinkColor]];
    _tipLab.delegate = self;
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
           self->_tipLab.attributedText =   [SobotHtmlFilter setHtml:text1 attrs:arr view:self->_tipLab textColor:UIColorFromKitModeColor(SobotColorTextSub) textFont:[UIFont systemFontOfSize:14] linkColor:[ZCUIKitTools zcgetChatLeftLinkColor]];
        }else{
            self->_tipLab.attributedText = [[NSAttributedString alloc] initWithString:@""];
        }
    }];
    
    CGSize  labSize  =  [_tipLab preferredSizeWithMaxWidth:ScreenWidth-30];
    _tipLab.frame = CGRectMake(15, 12, labSize.width, labSize.height);
    [_scrollView addSubview:_tipLab];
       
    UIView * wbgView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_tipLab.frame) +12,ScreenWidth , 30 + 154 + 20)];
    wbgView.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark2);
    [_scrollView addSubview:wbgView];
    
    _textView = [[ZCUIPlaceHolderTextView alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(_tipLab.frame) + 40, ScreenWidth-40, 154)];
    _textView.type = 1;
    _textView.placeholder = @"";
    [_textView setPlaceholderColor:UIColorFromKitModeColor(SobotColorTextSub1)];
    [_textView setFont:SobotFont14];
    [_textView setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
    _textView.delegate = self;
    
    _textView.placeholederFont = SobotFont14;
    _textView.layer.cornerRadius = 4.0f;
    _textView.layer.masksToBounds = YES;
    [_textView setBackgroundColor:[ZCUIKitTools zcgetLeftChatColor]];
    [_textView setContentInset:UIEdgeInsetsMake( 7, 12, 15, 15)];
    NSString * tmp =   sobotConvertToString(self.msgTmp);
    tmp = [SobotHtmlCore filterHTMLTag:tmp];
    while ([tmp hasPrefix:@"\n"]) {
        tmp=[tmp substringWithRange:NSMakeRange(1, tmp.length-1)];
    }
    
    if(sobotConvertToString([ZCUICore getUICore].kitInfo.leaveContentPlaceholder).length > 0){
        tmp = SobotKitLocalString(sobotConvertToString([ZCUICore getUICore].kitInfo.leaveContentPlaceholder));
    }
    
    [SobotHtmlCore filterHtml:tmp result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
       self->_textView.placeholder = text1;
        self->_textView.placeholderLinkColor = UIColorFromKitModeColor(SobotColorTextSub1);
    }];
    [_scrollView addSubview:_textView];
    
    
    //    2.8.0 增加导航栏下面 细线
    _lineView1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)];
    _lineView1.backgroundColor = UIColorFromKitModeColor(SobotColorBgLine);
    [wbgView addSubview:_lineView1];
    
    //    2.8.0 增加导航栏下面 细线
    _lineView2 = [[UIView alloc]initWithFrame:CGRectMake(0, wbgView.frame.size.height , self.view.frame.size.width, 0.5)];
    _lineView2.backgroundColor = UIColorFromKitModeColor(SobotColorBgLine);
    [wbgView addSubview:_lineView2];
    
    int th = CGRectGetMaxY(wbgView.frame);
    if(sobotConvertToString(_leaveExplain).length > 0){
        _label=[[UILabel alloc] initWithFrame:CGRectMake(15, th + 10, ScreenWidth-30, 0)];
        _label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_label setFont:SobotFont14];
        [_label setText:sobotConvertToString(_leaveExplain)];
        [_label setBackgroundColor:[UIColor clearColor]];
        [_label setTextAlignment:NSTextAlignmentLeft];
        [_label setTextColor:UIColorFromKitModeColor(SobotColorTextSub)];
        _label.numberOfLines = 0;
        [_label sizeToFit];
        [_scrollView addSubview:_label];
        th = CGRectGetMaxY(_label.frame);
    }
    
    // 区尾添加提交按钮 2.7.1改版
    _commitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_commitBtn setTitle:SobotKitLocalString(@"提交") forState:UIControlStateNormal];
    [_commitBtn setTitle:SobotKitLocalString(@"提交") forState:UIControlStateSelected];
    [_commitBtn setTitleColor:[ZCUIKitTools zcgetLeaveSubmitTextColor] forState:UIControlStateNormal];
    [_commitBtn setTitleColor:[ZCUIKitTools zcgetLeaveSubmitTextColor] forState:UIControlStateHighlighted];
    [_commitBtn setBackgroundColor:[ZCUIKitTools zcgetServerConfigBtnBgColor]];
    _commitBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _commitBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
    _commitBtn.frame = CGRectMake(15, th + 20, ScreenWidth- 30, 44);
    _commitBtn.tag = BUTTON_MORE;
    [_commitBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    _commitBtn.layer.masksToBounds = YES;
    _commitBtn.layer.cornerRadius = 22.f;
    _commitBtn.titleLabel.font = SobotFont17;
    [_scrollView addSubview:_commitBtn];
    [_scrollView setContentSize:CGSizeMake(0, CGRectGetMaxY(_commitBtn.frame) + CGRectGetHeight(_commitBtn.frame))];
}

//- (void)textViewDidChange:(UITextView *)textView{
//    if (textView.text.length > 0) {
//        UITextRange *selectedRange = [textView markedTextRange];
//        NSString * newText = [textView textInRange:selectedRange]; //获取高亮部分
//        if(newText.length>0){
//            return;
//        }
//        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//        paragraphStyle.lineSpacing = 5;// 字体的行间距
//        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15],NSParagraphStyleAttributeName:paragraphStyle};
//        textView.attributedText = [[NSAttributedString alloc] initWithString:textView.text attributes:attributes];
//    }
//}

#pragma mark - 返回和提交接口调用事件
-(IBAction)buttonClick:(UIButton *) sender{
    if(sender.tag == SobotButtonClickBack){
        if (self.navigationController) {
            [self.navigationController popViewControllerAnimated:NO];
        }else{
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    }else if (sender.tag == BUTTON_MORE){
        if (_textView.text.length <=0) {
            [[SobotToast shareToast] showToast:SobotKitLocalString(@"请填写问题描述") duration:2 view:[UIApplication sharedApplication].keyWindow position:SobotToastPositionCenter];
            return;
        }
        __weak ZCLeaveMsgVC * saveSelf = self;
        [ZCLibServer getLeaveMsgWith:[[ZCUICore getUICore] getLibConfig].uid Content:_textView.text groupId:self.groupId start:^{
            
        } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
            if (dict) {
                if(!sobotIsNull(dict[@"data"])){
                    int status = [dict[@"data"][@"status"] intValue];
                    if(status == 0){
                        [[SobotToast shareToast] showToast:sobotConvertToString(dict[@"data"][@"msg"]) duration:1.0f view:saveSelf.view position:SobotToastPositionCenter];
                        return;
                    }
                }
                // 返回，发送留言消息
                if (saveSelf.passMsgBlock) {
                    saveSelf.passMsgBlock(saveSelf.textView.text);
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
            [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:SobotFont12,NSForegroundColorAttributeName:[ZCUIKitTools zcgetTopViewTextColor]}];
        }else{
            [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[ZCUIKitTools zcgetTitleFont],NSForegroundColorAttributeName:[ZCUIKitTools zcgetTopViewTextColor]}];
        }
    }else{
        self.titleLabel.text = SobotKitLocalString(@"留言消息");
        if (![[ZCLibClient getZCLibClient].libInitInfo.absolute_language hasPrefix:@"zh-"]
            || !(sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.absolute_language).length == 0 && [sobotGetLanguagePrefix() hasPrefix:@"zh-"])){
            self.titleLabel.font = SobotFont12;
        }
    }
}

-(void)tapAction:(UITapGestureRecognizer *)sender{
    [self hideKeyboard];
}

#pragma mark -- 键盘滑动的高度

- (void) hideKeyboard {
    [_textView resignFirstResponder];
    [self allHideKeyBoard];
    if(contentoffset.x != 0 || contentoffset.y != 0){
        // 隐藏键盘，还原偏移量
        [_scrollView setContentOffset:contentoffset];
    }
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
    [self layoutSubViewsUI];
    [self setHeaderConfig];
}

// 适配iOS 13以上的横竖屏切换
-(void)viewSafeAreaInsetsDidChange{
    [super viewSafeAreaInsetsDidChange];
    // 横竖屏更新导航栏渐变色
    [self updateTopViewBgColor];
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
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callURL]];
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


#pragma mark -
- (void)textViewDidChange:(UITextView *)textView{
    if (textView.text.length == 0) {
        return;
    }
    UITextRange *selectedRange = [textView markedTextRange];
    NSString * newText = [textView textInRange:selectedRange]; //获取高亮部分
    if(newText.length>0)
        return;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;// 字体的行间距
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15],NSParagraphStyleAttributeName:paragraphStyle};
    textView.attributedText = [[NSAttributedString alloc] initWithString:textView.text attributes:attributes];
}

    
@end
