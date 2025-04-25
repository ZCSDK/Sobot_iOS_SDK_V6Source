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

@property (nonatomic,strong) NSLayoutConstraint *telBtnEW;
@property (nonatomic,strong) NSLayoutConstraint *telServiceEW;

@end

@implementation SobotClientBaseController


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.automaticallyAdjustsScrollViewInsets = YES;
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }
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
            if(SobotKitIsRTLLayout){
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
        [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[ZCUIKitTools zcgetTopViewTextColor]}];
#pragma mark -- iOS 15.0 导航栏设置
        if (@available(iOS 15.0, *)) {
            UINavigationBarAppearance *barApp = [UINavigationBarAppearance new];
            [barApp configureWithOpaqueBackground];
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
    NSMutableDictionary *navItemSource = [NSMutableDictionary dictionary];
    NSString *backImg = sobotConvertToString([ZCUICore getUICore].kitInfo.topBackSelImg);
    if(backImg.length == 0){
        backImg = @"zcicon_titlebar_back_normal";
    }
    [navItemSource setObject:@{@"img":backImg,@"imgsel":sobotConvertToString([ZCUICore getUICore].kitInfo.topBackSelImg)} forKey:@(SobotButtonClickBack)];
    // 更新系统导航栏的按钮
    self.navItemsSource = navItemSource;
    
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
    NSMutableArray *leftItems = [NSMutableArray array];
    NSMutableDictionary *navItemSource = [NSMutableDictionary dictionary];
    [leftItems addObject:@(SobotButtonClickBack)];
    [navItemSource setObject:@{@"img":@"zcicon_titlebar_back_normal",@"imgsel":sobotConvertToString([ZCUICore getUICore].kitInfo.topBackNolImg)} forKey:@(SobotButtonClickBack)];
    // 更新系统导航栏的按钮
    self.navItemsSource = navItemSource;
    if (![ZCUIKitTools getSobotIsRTLLayout]) {
        [self setLeftTags:leftItems rightTags:@[] titleView:nil];
    }else{
        [self setLeftTags:@[] rightTags:leftItems titleView:nil];
    }
    if (!self.navigationController.navigationBarHidden) {
        if([ZCUIKitTools getZCThemeStyle] == SobotThemeMode_Light){
            if(sobotGetSystemDoubleVersion() >= 13){
                if (@available(iOS 13.0, *)) {
                    self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
                    self.navigationController.toolbar.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }else{
        self.moreButton.hidden = YES;
        self.titleLabel.hidden = NO;
        self.backButton.hidden = NO;
        self.bottomLine.hidden = YES;
    }
}




/**
 横竖屏切换监听
 */
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        // 更新UIScrollView的子视图的约束
        
        // 强制更新布局
        if (self->_telBtnEW && self->_telServiceEW) {
            CGFloat itemW = (ScreenWidth - 32 - 8)/2;
            self->_telBtnEW.constant = itemW;
            
            self->_telServiceEW.constant = itemW;
        }
        
    } completion:nil];
}

-(UIView *)createBtmView:(BOOL) addTel{
    // 构建 联系客服和联系热线按钮
    UIView *serviceBtnBgView = [[UIView alloc]init];
    serviceBtnBgView.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
    [self.view addSubview:serviceBtnBgView];
    [self.view addConstraint:sobotLayoutPaddingBottom(0, serviceBtnBgView, self.view)];
    [self.view addConstraint:sobotLayoutPaddingLeft(0, serviceBtnBgView, self.view)];
    [self.view addConstraint:sobotLayoutPaddingRight(0, serviceBtnBgView, self.view)];
    
    [self createHelpCenterButtons:12 sView:serviceBtnBgView add:addTel];
    return serviceBtnBgView;
}

#pragma mark - 联系客服
-(UIButton *)createHelpCenterButtons:(CGFloat ) y sView:(UIView *) superView add:(BOOL) isAddTel{
    CGFloat itemW =  (ScreenWidth - SobotSpace16 * 2 - 8)/2;
    
    
    NSString *telText = @"";
    if(sobotConvertToString([ZCUICore getUICore].kitInfo.helpCenterTel).length > 0 && sobotConvertToString([ZCUICore getUICore].kitInfo.helpCenterTelTitle).length > 0 && isAddTel){
        telText = sobotConvertToString([ZCUICore getUICore].kitInfo.helpCenterTelTitle);
    }else if(sobotConvertToString([ZCPlatformTools sharedInstance].visitorConfig.hotlineTel).length >0 && isAddTel){
        telText = sobotConvertToString([ZCPlatformTools sharedInstance].visitorConfig.hotlineName);
    }
    
    UIButton *serviceButton = [self createHelpCenterOpenButton];
    serviceButton.tag = 1;
    [superView addSubview:serviceButton];
    [superView addConstraint:sobotLayoutPaddingLeft(SobotSpace16, serviceButton, superView)];
    [superView addConstraint:sobotLayoutPaddingTop(y, serviceButton, superView)];
//    [superView addConstraint:sobotLayoutEqualHeight(40, serviceButton, NSLayoutRelationEqual)];
    
    
    
    if(sobotConvertToString(telText).length > 0){
        UIButton *_telButton = [self createHelpCenterOpenButton];
        _telButton.tag = 2;
        [superView addSubview:_telButton];
        [_telButton setTitle:telText forState:UIControlStateNormal];
        [_telButton setTitle:telText forState:UIControlStateHighlighted];
        [superView addConstraint:sobotLayoutPaddingRight(-SobotSpace16, _telButton, superView)];
        [superView addConstraint:sobotLayoutPaddingBottom(-12-XBottomBarHeight, _telButton, superView)];
//        [superView addConstraint:sobotLayoutEqualHeight(40, _telButton, NSLayoutRelationEqual)];
        
        
        CGFloat w1 = [SobotUITools getWidthContain:telText font:_telButton.titleLabel.font Height:22];
        CGFloat w2 = [SobotUITools getWidthContain:serviceButton.titleLabel.text font:serviceButton.titleLabel.font Height:22];
        
        if(w1 > itemW || w2 > itemW){
            [superView addConstraint:sobotLayoutPaddingRight(-SobotSpace16, serviceButton, superView)];
            
            [superView addConstraint:sobotLayoutMarginTop(8,_telButton, serviceButton)];
            [superView addConstraint:sobotLayoutPaddingLeft(SobotSpace16, _telButton, superView)];
        }else{
            [superView addConstraint:sobotLayoutPaddingTop(y, _telButton, superView)];
            
            _telBtnEW = sobotLayoutEqualWidth(itemW, _telButton, NSLayoutRelationEqual);
            _telServiceEW = sobotLayoutEqualWidth(itemW, serviceButton, NSLayoutRelationEqual);
            // 同一行显示
            [superView addConstraint:_telBtnEW];
            
            // 设置宽度
            [superView addConstraint:_telServiceEW];
        }
        [_telButton layoutIfNeeded];
        
    }else{
        [superView addConstraint:sobotLayoutPaddingRight(-SobotSpace16, serviceButton, superView)];
        [superView addConstraint:sobotLayoutPaddingBottom(-12-XBottomBarHeight, serviceButton, superView)];
    }
    return serviceButton;
}


#pragma mark - 在线客服按钮 和拨号按钮
-(UIButton *)createHelpCenterOpenButton{
    // 在线客服btn
    SobotButton *serviceBtn = [SobotButton buttonWithType:UIButtonTypeCustom];
    serviceBtn.autoHeight = YES;
//    serviceBtn.type = 5;
    [serviceBtn setTitle:SobotKitLocalString(@"在线客服") forState:UIControlStateNormal];
    [serviceBtn setTitle:SobotKitLocalString(@"在线客服") forState:UIControlStateHighlighted];
    [serviceBtn setTitleColor:UIColorFromKitModeColor(SobotColorTextMain) forState:UIControlStateNormal];
    [serviceBtn setTitleColor:UIColorFromKitModeColor(SobotColorTextMain) forState:UIControlStateHighlighted];
    serviceBtn.titleLabel.font = SobotFont16;
    [serviceBtn addTarget:self action:@selector(btmButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    serviceBtn.layer.borderColor = UIColorFromKitModeColor(SobotColorBorderLine).CGColor;
    serviceBtn.layer.borderWidth = 1.0f;
    serviceBtn.layer.cornerRadius = 4.0f;
    serviceBtn.layer.masksToBounds = YES;
    serviceBtn.titleLabel.numberOfLines = 0;
    // 　换行方式
    [serviceBtn.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [serviceBtn setBackgroundColor:UIColor.clearColor];
    [serviceBtn setContentEdgeInsets:UIEdgeInsetsMake(12, 20, 12, 20)];
    return serviceBtn;
}

#pragma mark - 联系客服 和 联系电话点击事件
-(void)btmButtonClick:(UIButton *)sender{
    NSLog(@"点击了联系客服 %ld",(long)sender.tag);
    if (sender.tag == 2) {
        NSString *link = sobotConvertToString([ZCUICore getUICore].kitInfo.helpCenterTel);
        if (link.length == 0) {
                // 看初始化接口是否有配置
            if (sobotConvertToString([ZCPlatformTools sharedInstance].visitorConfig.hotlineTel).length >0) {
                link = sobotConvertToString([ZCPlatformTools sharedInstance].visitorConfig.hotlineTel);
            }
        }
        if(![link hasSuffix:@"tel:"]){
            link = [NSString stringWithFormat:@"tel:%@",link];
        }
        //1.添加埋点
        if ([ZCUICore getUICore].ZCViewControllerCloseBlock) {
            // 添加事件通知
            [ZCUICore getUICore].ZCViewControllerCloseBlock(self,ZC_PhoneCustomerService);
        }
        
        // 是否拦截
        if([[ZCUICore getUICore] LinkClickBlock] == nil || ![ZCUICore getUICore].LinkClickBlock(ZCLinkClickTypeURL,link,self)){
            //2.先弹窗
//            [SobotUITools showAlert:nil message:[link stringByReplacingOccurrencesOfString:@"tel:" withString:@""] cancelTitle:SobotKitLocalString(@"取消") viewController:self confirm:^(NSInteger buttonTag) {
//                if(buttonTag>=0){
                    
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link] options:@{} completionHandler:^(BOOL res) {
                    
                }];
            } else {
                //3.拨号 iOS9 之后会直接弹窗
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
            }
//                }
//            } buttonTitles:SobotKitLocalString(@"呼叫"), nil];
        }
    }
}
@end
