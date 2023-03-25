//
//  ViewController.m
//  SobotKitFrameworkTest
//
//  Created by zhangxy on 15/11/21.
//  Copyright © 2015年 zhichi. All rights reserved.
//

#import "ViewController.h"
#import <SobotKit/SobotKit.h>

#import "AppDelegate.h"
#import "ZCProductView.h"
#import "EntityConvertUtils.h"
#import "ZCGuideData.h"

@interface ViewController ()<ZCProductViewDelegate,ZCChatControllerDelegate,ZCReceivedMessageDelegate>{
   
}

@property (nonatomic,assign) BOOL isCanUseSideBack;

@property (nonatomic,strong) UIScrollView * scrollView; // 背景

@property (nonatomic,strong) UILabel * titleLab;//

@property (nonatomic,strong) UILabel * detailLab;

@property (nonatomic,strong) UIImageView * bgImg;// 背景图

@property (nonatomic,strong) ZCProductView *productView;



@end

@implementation ViewController

#pragma mark - lifeCycle
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    self.hidesBottomBarWhenPushed = NO;
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController setToolbarHidden:YES animated:NO];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:SobotFont16,NSForegroundColorAttributeName:SobotColorFromRGB(0x3D4966)}];
#pragma mark -- iOS 15.0 导航栏设置
    NSDictionary *dic = @{NSForegroundColorAttributeName : [UIColor whiteColor],
                          NSFontAttributeName : [UIFont systemFontOfSize:18 weight:UIFontWeightMedium]};
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *barApp = [UINavigationBarAppearance new];
        barApp.backgroundColor = [UIColor whiteColor];
        barApp.shadowColor = [UIColor whiteColor];
        barApp.titleTextAttributes = dic;
        self.navigationController.navigationBar.scrollEdgeAppearance = barApp;
        self.navigationController.navigationBar.standardAppearance = barApp;
    }else{
//        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.titleTextAttributes = dic;
    }
    if ([ZCLibClient getZCLibClient].libInitInfo.absolute_language.length > 0 && ([[ZCLibClient getZCLibClient].libInitInfo.absolute_language hasPrefix:@"ar"] || [[ZCLibClient getZCLibClient].libInitInfo.absolute_language hasPrefix:@"he"])) {
        [UITabBar appearance].semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorFromRGB(0xEFF3FA);
    [self setUpUI];
    [self setTitleView];
}

#pragma mark -- 获取最后一条消息  前提需要先初始化
-(void)lastMsgClick:(UIButton *)sender{
    
    // 前提再次初始化完成之后调用
    
    [ZCLibClient getZCLibClient].autoCloseConnect = YES;
    [[ZCLibClient getZCLibClient] checkIMConnected];
    [[ZCLibClient getZCLibClient] checkIMObserverWithRegister];
    // 获取之前的会话记录
    [ZCSobotApi getLastMessageInfo:^(ZCPlatformInfo * _Nonnull info, SobotChatMessage * _Nonnull message, int code) {
        
    }];
    
    // 通道构建成功后 监听消息
    [[ZCLibClient getZCLibClient] setReceivedBlock:^(id message, int nleft, NSDictionary *object) {
        NSLog(@"ssss%@ -- %d",message,nleft);
    }];
}

-(IBAction)buttonClick:(UIButton *)sender{
    self.extendedLayoutIncludesOpaqueBars = true; //Push 黑边和这个参数有关系
    
    if(![[ZCLibClient getZCLibClient] getInitState]){
        [[ZCGuideData getZCGuideData] showAlertTips:@"请设置appkey后初始化,功能设置->基础参数配置" vc:self];
        return;
    }
    
    [self initTestSDK];
}

// 直接启动
- (void)initTestSDK{
    NSLog(@"version:%@",[ZCSobotApi getVersion]);
    ZCLibInitInfo *initInfo = [ZCGuideData getZCGuideData].libInitInfo;
//    initInfo.partnerid = @"zxy";
//    initInfo.service_mode = 3;
    [ZCLibClient getZCLibClient].libInitInfo = initInfo;
    
    ZCKitInfo *kitInfo = [ZCGuideData getZCGuideData].kitInfo;
//    kitInfo.isOpenActiveUser = YES;
//    kitInfo.unWordsCount = @"10";
//    kitInfo.isShowTansfer = NO;
//    kitInfo.isShowCloseSatisfaction =  YES;
//    kitInfo.isShowReturnTips = YES;
//    kitInfo.isCloseAfterEvaluation = YES;
//    kitInfo.hideMenuSatisfaction = YES;
//    kitInfo.isOpenRecord = NO;
    
    
    
    [ZCSobotApi setMessageLinkClick:^BOOL(ZCLinkClickType type, NSString * _Nonnull linkUrl, id  _Nullable object) {
        NSLog(@"messageLinkClick。。。%@",linkUrl);
        //        当收到link = sobot://sendlocation 调用智齿接口发送位置信息
        //        当收到link = sobot://openlocation?latitude=xx&longitude=xxx&address=xxx 可根据自己情况处理相关业务
        if( [linkUrl hasPrefix:@"sobot://sendlocation"]){
            //发送坐标点
//                UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 2.0);
//                [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
//                UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//                UIGraphicsEndImageContext();
//
//                NSData * imageData =UIImageJPEGRepresentation(image, 0.75f);
//                NSString * fname = [NSString stringWithFormat:@"/sobot/image100%ld.jpg",(long)[NSDate date].timeIntervalSince1970];
//                CheckPathAndCreate(GetDocumentsFilePath(@"/sobot/"));
//                NSString *fullPath = GetDocumentsFilePath(fname);
//                [imageData writeToFile:fullPath atomically:YES];
//
//                // 发送位置信息
//                [ZCSobot sendLocation:@{
//                                        @"lat":@"40.001693",
//                                        @"lng":@"116.353276",
//                                        @"localLabel":@"北京市海淀区学清路38号金码大厦",
//                                        @"localName":@"云景四季餐厅",
//                                        @"file":fullPath}];
            
            
            return YES;
        }else if([linkUrl hasPrefix:@"sobot://openlocation"]){
            // 解析经度、纬度、地址：latitude=xx&longitude=xxx&address=xxx
            // 跳转到地图的位置
//                NSLog(link);
            // 测试打开地图 高德网页版
            NSString *urlString = @"";
            urlString = [[NSString stringWithFormat:@"http://uri.amap.com/marker?position=%@,%@&name=%@&coordinate=gaode&src=%@&callnative=0",@116.353276,@40.001693,@"北京市海淀区学清路38号金码大厦A座23层金码大酒店",@"智齿SDK"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlString]];
            
            return YES;
        }else if ([linkUrl hasPrefix:@"sobot://sendOrderMsg"]){
            ZCOrderGoodsModel *model = [ZCOrderGoodsModel new];
            model.orderStatus = 1;
            model.createTime = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]*1000*1000];
            model.goodsCount = @"3";
            model.orderUrl  = @"https://www.sobot.com";
            model.orderCode = @"1000234242342345";
            model.goods =@[@{@"name":@"商品名称",@"pictureUrl":@"http://pic25.nipic.com/20121112/9252150_150552938000_2.jpg"},@{@"name":@"商品名称",@"pictureUrl":@"http://pic31.nipic.com/20130801/11604791_100539834000_2.jpg"}];
            
            
            model.totalFee = @"4890";
            [ZCSobotApi sendOrderGoodsInfo:model resultBlock:^(NSString * _Nonnull msg, int code) {
                
            }];
            
            return YES;
        }
        else if([linkUrl hasPrefix:@"sobot://sendProductInfo"]) {
            ZCProductInfo *productInfo = [ZCProductInfo new];
            
            //                productInfo.thumbUrl = ZCUserDefaultsGetValue(@"goods_IMG");
            //                productInfo.title = ZCUserDefaultsGetValue(@"goods_Title");
            //                productInfo.desc = ZCUserDefaultsGetValue(@"goods_SENDMGS");
            //                productInfo.label = ZCUserDefaultsGetValue(@"glabel_Text");
            //                productInfo.link = ZCUserDefaultsGetValue(@"gPageUrl_Text");
            
            productInfo.thumbUrl = @"https://static.sobot.com/chat/admins/assets/images/logo.png";
            productInfo.title = @"标题标题标题标题标题标题";
            productInfo.desc = @"描述描述描述描述描述描述";
            productInfo.label = @"标签标签标签标签标签标签标签";
            productInfo.link = @"www.baidu.com";
            //                uiInfo.productInfo = productInfo;
            [ZCSobotApi sendProductInfo:productInfo resultBlock:^(NSString * _Nonnull msg, int code) {
                
            }];
            return YES;
        }
        
        return NO;
    }];
    
    
    // 监听点击事件,可拦截点击事件
//    [ZCSobotApi setMessageLinkClick:^BOOL(NSString * _Nonnull link) {
//
//    }];
    
    kitInfo.isShowReturnTips = YES;
    kitInfo.leaveCompleteCanReply=NO;//留言完成后，是否 显示 回复按钮
    kitInfo.isShowCloseSatisfaction=YES;//导航栏关闭按钮关闭时，弹出满意度评价。
    kitInfo.isShowClose=YES;//导航栏右上角 是否显示 关闭按钮 默认不显示，关闭按钮，点击后无法监听后台消息
        //返回时是否开启满意度评价
        //    *  默认为NO 未开启
//    kitInfo.isOpenEvaluation=NO;//
    kitInfo.isCloseAfterEvaluation=YES;
    // 启动页面
//    [ZCSobotApi openZCChat:kitInfo with:self pageBlock:^(id  _Nonnull object, ZCPageBlockType type) {
//
//    }];
    
    [self enterSDKPageWithUiInfo:kitInfo];
    
}


#pragma mark - 进入帮助中心页面
- (void)enterSDKPageWithUiInfo:(ZCKitInfo *)uiInfo{
    [ZCSobotApi openZCServiceCenter:uiInfo with:self onItemClick:^(SobotClientBaseController * _Nonnull object) {
        [ZCSobotApi openZCChat:uiInfo with:self pageBlock:^(id  _Nonnull object, ZCPageStateType type) {
            
        }];
    }];
}




#pragma mark - delegate 消息回调
//监听消息
-(void)onReceivedMessage:(id) message unRead:(int) nleft obj:(id) object {
    
}

// 咨询状态切换，人工、机器人、离线
-(void)currentConnectStatus:(id)message status:(ZCServerConnectStatus)status obj:(id)object{
    
}


#pragma mark - 布局
-(void)setTitleView{
    
    UIImageView * titleimgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 72, 23)];
    titleimgView.image = [UIImage imageNamed:@"titleImg"];
    titleimgView.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = titleimgView;
    
    
    UIButton * rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(ScreenWidth - 90, NavBarHeight - 40, 80, 40);
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [rightBtn setTitle:@"联系我们" forState:UIControlStateNormal];
    rightBtn.titleEdgeInsets = UIEdgeInsetsMake(5, 15, 5, -5);
    [rightBtn setTitleColor:UIColorFromRGB(0x0DAEAF) forState:UIControlStateNormal];
    [rightBtn setTitleColor:UIColorFromRGB(0x0DAEAF) forState:UIControlStateHighlighted];
    [rightBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
 
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UIButton * leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, NavBarHeight - 40, 80, 40);
    leftBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [leftBtn setTitle:@"lastMsg" forState:UIControlStateNormal];
    leftBtn.titleEdgeInsets = UIEdgeInsetsMake(5, 15, 5, -5);
    [leftBtn setTitleColor:UIColorFromRGB(0x0DAEAF) forState:UIControlStateNormal];
    [leftBtn setTitleColor:UIColorFromRGB(0x0DAEAF) forState:UIControlStateHighlighted];
//    [rightBtn setTitleColor:UIColorFromRGB(0xF5F6F7) forState:0];
    [leftBtn addTarget:self action:@selector(lastMsgClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
//    self.navigationItem.leftBarButtonItem = leftItem;
}

-(void)setUpUI{
//    CGFloat XH = 0;
//    if (ZC_iPhoneX) {
//        XH = 34;
//    }

    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, NavBarHeight, ScreenWidth, ScreenHeight - NavBarHeight - 48 - (ZC_iPhoneX? 34 :0))];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.scrollEnabled = YES;
//    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.alwaysBounceHorizontal = NO;
//    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.pagingEnabled = NO;
    self.scrollView.bounces = NO;
    self.scrollView.userInteractionEnabled = YES;
    
    [self.view addSubview:self.scrollView];
    
    self.bgImg  = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
    [self.bgImg setBackgroundColor:[UIColor clearColor]];
    self.bgImg.image = [UIImage imageNamed:@"productBgImg"];
    [self.scrollView addSubview:self.bgImg];
    
    self.titleLab = [[UILabel alloc]initWithFrame:CGRectMake(20, 27, 150, 33)];
    self.titleLab.textAlignment = NSTextAlignmentLeft;
    self.titleLab.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:24];
    self.titleLab.text = @"智齿客服";
    [self.bgImg addSubview:self.titleLab];


    self.detailLab = [[UILabel alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(self.titleLab.frame) + 20, ScreenWidth - 40, 40)];
    self.detailLab.numberOfLines = 0;
    self.detailLab.textAlignment = NSTextAlignmentLeft;
    self.detailLab.textColor = UIColorFromRGB(0x3D4966);
    self.detailLab.font = [UIFont systemFontOfSize:14];
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc]initWithString:@"智齿客服是以人工智能整合云呼叫中心、机器人客服、人工在线客服、工单系统的全客服平台"];
    NSMutableParagraphStyle * paragraphstyle = [[NSMutableParagraphStyle alloc]init];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphstyle range:NSMakeRange(0, [@"智齿客服是以人工智能整合云呼叫中心、机器人客服、人工在线客服、工单系统的全客服平台" length])];
    [self.detailLab setAttributedText:attributedString];
    [self.bgImg addSubview:self.detailLab];

    CGRect bgimgF = self.bgImg.frame;
    bgimgF.size.height = CGRectGetMaxY(self.detailLab.frame) + 36;
    self.bgImg.frame= bgimgF;
    
    
    // 智能机器人。。。。
    
    NSMutableArray * arr = [NSMutableArray arrayWithCapacity:0];
    
    NSDictionary * dict1 = @{@"Img":@"home_Robot",
                            @"title":@"智能机器人",
                            @"detail":@"金牌客服永不离线，节省85%以上人力成本",
                            @"tag":@"0",
                            };
    NSDictionary * dict2 = @{@"Img":@"home_chat",
                             @"title":@"人工在线客服",
                             @"detail":@"把握每一次访问。专注线上转化，提升业绩",
                             @"tag":@"1",
                             };
    NSDictionary * dict3 = @{@"Img":@"home_call",
                             @"title":@"云呼叫中心",
                             @"detail":@"稳定强大的云呼叫中心，价格更低，效果更佳",
                             @"tag":@"2",
                             };
    NSDictionary * dict4 = @{@"Img":@"home_order",
                             @"title":@"工单系统",
                             @"detail":@"推动全公司协同处理客户问题，提升解决率",
                             @"tag":@"3",
                             };
    
    [arr addObject:dict1];
    [arr addObject:dict2];
    [arr addObject:dict3];
    [arr addObject:dict4];
    
    CGFloat itemH = CGRectGetMaxY(self.bgImg.frame) ;
    for (int i = 0; i<arr.count; i++) {
        _productView =[[ZCProductView alloc]initWithFrame:CGRectMake(20, itemH, ScreenWidth - 40, 140) WithDict:arr[i] WithSuperView:self.scrollView];
        _productView.delegate =  self;
        itemH = itemH + 150;
    }
    
    self.scrollView.contentSize = CGSizeMake(ScreenWidth, itemH + 20);

}

#pragma mark - 点击事件
-(void)buttonClickPassWord:(int)tag{
//    NSLog(@"点击了item");
    
    switch (tag) {
        case 0:{
            
        }
            break;
        case 1:{
            
            
        }
            break;
        case 2:{
            
            
        }
            break;
        case 3:{
            
        
        }
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, NavBarHeight, ScreenWidth, ScreenHeight - NavBarHeight - 48 - (ZC_iPhoneX? 34 :0))];
}


#pragma mark -- 处理首页面多次右滑页面卡死问题

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}


-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}



@end
