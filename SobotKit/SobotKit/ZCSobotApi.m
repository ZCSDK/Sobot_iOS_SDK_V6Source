//
//  ZCSobotApi.m
//  SobotKit
//
//  Created by zhangxy on 2022/8/29.
//

#import "ZCSobotApi.h"
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClient.h>
#import "ZCChatController.h"
#import "ZCUICore.h"
#import "ZCServiceCentreVC.h"
#import "ZCUIChatListController.h"
#import "ZCMsgDetailsVC.h"
#import "ZCLeaveMsgController.h"
@implementation ZCSobotApi

+(void)initSobotSDK:(NSString *)appkey result:(void (^)(id _Nonnull))resultBlock{
    [self initSobotSDK:appkey host:@"" result:resultBlock];
}

+(void)initSobotSDK:(NSString *) appkey host:(NSString *) apiHost result:(void (^)(id object))resultBlock{
    [[ZCLibClient getZCLibClient] initSobotSDK:appkey host:apiHost result:^(int code, id object) {
        resultBlock(object);
    }];
//    [SobotCache shareSobotCache].sobotCacheEntity.bundleName = @"SobotKit";
    
    [ZCSobotApi synchronizeLanguage:[ZCLibClient getZCLibClient].libInitInfo.absolute_language write:NO result:nil];
}

+(void)getVisitorConfigInfo:(void (^)(id object,int code))resultBlock{
    if ([@"" isEqualToString:sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.app_key)] && [@"" isEqualToString:sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.customer_code)]) {
        if(resultBlock){
            resultBlock(@"没有app_key",-1);
        }
        return;
    }
    // 判断初始化结果
    if(![[ZCLibClient getZCLibClient] getInitState]){
        if(resultBlock){
            resultBlock(@"没有初始化或初始化失败，请先执行initSobotSDK",-1);
        }
        return;
    }
    [ZCLibServer getVisitorHelpConfig:sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.app_key) partnerId:sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.partnerid) start:^(NSString * _Nonnull urlString) {
        
    } success:^(NSDictionary * _Nonnull dict, ZCNetWorkCode sendCode) {
        if([ZCPlatformTools sharedInstance].visitorConfig!=nil){
            if(resultBlock){
                resultBlock([ZCPlatformTools sharedInstance].visitorConfig,0);
            }
        }else{
            if(resultBlock){
                resultBlock(@"load fail",-2);
            }
        }
    } failed:^(NSString * _Nonnull errorMessage, ZCNetWorkCode errorCode) {
        if(resultBlock){
            resultBlock(@"load fail",-2);
        }
    } finish:^(NSString * _Nonnull jsonString) {
       
    }];
}

//  打开会话页面
+(void)openZCChat:(ZCKitInfo *)info with:(UIViewController *)byController pageBlock:(void (^)(id _Nonnull, ZCPageStateType))pageClick{
    if(byController==nil || ![byController isKindOfClass:[UIViewController class]]){
        if(pageClick){
            pageClick(@"没有启动类byController",-1);
        }
        return;
    }
    if(info == nil){
        if(pageClick){
            pageClick(@"没有配置UI类info",-1);
        }
        return;
    }
    
    if ([@"" isEqualToString:sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.app_key)] && [@"" isEqualToString:sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.customer_code)]) {
        if(pageClick){
            pageClick(@"没有app_key",-1);
        }
        return;
    }
    // 判断初始化结果
    if(![[ZCLibClient getZCLibClient] getInitState]){
        if(pageClick){
            pageClick(@"没有初始化或初始化失败，请先执行initSobotSDK",-1);
        }
        return;
    }
    // 同步回调
    [[ZCUICore getUICore] setPageLoadBlock:pageClick];
    
    [[ZCUICore getUICore] setKitInfo:info];
    ZCChatController *chat = [[ZCChatController alloc] init];
     chat.hidesBottomBarWhenPushed = [ZCUICore getUICore].kitInfo.ishidesBottomBarWhenPushed;
     if(byController.navigationController==nil){
         UINavigationController * navc = [[UINavigationController alloc]initWithRootViewController: chat];
         navc.modalPresentationStyle = UIModalPresentationOverFullScreen;
         // 设置动画效果
         [byController presentViewController:navc animated:YES completion:^{

         }];
     }else{
         [byController.navigationController pushViewController:chat animated:YES];
     }
     //清理过期日志 v2.7.9
     [SobotLog cleanCache];
}

+(void)setMessageLinkClick:(BOOL (^)(ZCLinkClickType, NSString * _Nonnull, id _Nullable))messagelinkBlock{
    if (messagelinkBlock != nil) {
        [[ZCUICore getUICore] setLinkClickBlock:messagelinkBlock];
    }
}


+(void)setZCViewControllerBackClick:(void (^)(id currentVC,ZCPageCloseType type))backBlock{
    [self setFunctionClickListener:backBlock];
}
+(void)setFunctionClickListener:(void (^)(id _Nonnull, ZCPageCloseType))backBlock{
    if (backBlock != nil) {
        [[ZCUICore getUICore] setZCViewControllerCloseBlock:backBlock];
    }
}

// 打开客户中心页面
+ (void)openZCServiceCenter:(ZCKitInfo *) info
                         with:(UIViewController *) byController
                onItemClick:(void (^)(SobotClientBaseController *object))itemClickBlock {
    
    if(byController==nil){
        return;
    }
    if(info == nil){
        return;
    }
    
    if ([@"" isEqualToString:sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.app_key)] && [@"" isEqualToString:sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.customer_code)]) {
        return;
    }
    
    [ZCSobotApi getVisitorConfigInfo:^(id  _Nonnull object, int code) {
        ZCServiceCentreVC *chat=[[ZCServiceCentreVC alloc] initWithInitInfo:info];
        [chat setOpenZCSDKTypeBlock:itemClickBlock];
        chat.hidesBottomBarWhenPushed = [ZCUICore getUICore].kitInfo.ishidesBottomBarWhenPushed;
        chat.kitInfo = info;
        if(byController.navigationController==nil){
            chat.isPush = NO;
            UINavigationController * navc = [[UINavigationController alloc]initWithRootViewController: chat];
            navc.modalPresentationStyle = UIModalPresentationOverFullScreen;
            // 设置动画效果
            [byController presentViewController:navc animated:YES completion:^{
                
            }];
        }else{
            chat.isPush = YES;
            [byController.navigationController pushViewController:chat animated:YES];
        }
    }];
}

// 打开消息中心页面
+ (void)openZCChatListView:(ZCKitInfo *)info with:(UIViewController *)byController onItemClick:(void (^)(SobotClientBaseController *object,ZCPlatformInfo *info))itemClickBlock {
    
    if(byController==nil){
        return;
    }
    if(info == nil){
        return;
    }
    
    [ZCSobotApi getVisitorConfigInfo:^(id  _Nonnull object, int code) {
        ZCUIChatListController *chat=[[ZCUIChatListController alloc] init];
        chat.hidesBottomBarWhenPushed = [ZCUICore getUICore].kitInfo.ishidesBottomBarWhenPushed;
        chat.kitInfo = info;
        [chat setOnItemClickBlock:itemClickBlock];
        chat.byController = byController;
        if(byController.navigationController==nil){
            UINavigationController * navc = [[UINavigationController alloc]initWithRootViewController:chat];
            // 设置动画效果
            navc.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [byController presentViewController:navc animated:YES completion:^{
                
            }];
        }else{
            [byController.navigationController pushViewController:chat animated:YES];
        }
    }];
}

+(void)getLeaveTemplateById:(NSString *) templateId result:(void(^)(NSDictionary *rdict,NSMutableArray * rtypeArr,int code)) resultBlcok{
    ZCLibConfig *config = [[ZCPlatformTools sharedInstance] getPlatformInfo].config;
    // 加载基础模板接口
    [ZCLibServer postMsgTemplateConfigWithUid:config.uid  Templateld:sobotConvertToString(templateId) start:^{
        
    } success:^(NSDictionary * _Nonnull dict, NSMutableArray * _Nonnull typeArr, ZCNetWorkCode sendCode) {
        if(resultBlcok){
            resultBlcok(dict,typeArr,0);
        }
    } failed:^(NSString * _Nonnull errorMessage, ZCNetWorkCode errorCode) {
        if(resultBlcok){
            resultBlcok(@{},@[],1);
        }
    }];
    
}

// 打开留言页面
+ (void)openLeave:(int ) showRecored kitinfo:(ZCKitInfo *)kitInfo with:(UIViewController *)byController onItemClick:(void (^)(NSString *msg,int code))CloseBlock {
    
    [ZCUICore getUICore].kitInfo = kitInfo;

    [ZCSobotApi checkConfig:^(NSString *msg, int code) {
        if(code == 0){

            ZCLeaveMsgController *leaveMessageVC = [[ZCLeaveMsgController alloc]init];
            leaveMessageVC.hidesBottomBarWhenPushed = YES;
            leaveMessageVC.isExitSDK = NO;
        //    leaveMessageVC.isShowToat = isShow;
        //    leaveMessageVC.tipMsg = msg;
            leaveMessageVC.isNavOpen = (byController.navigationController!=nil ? YES: NO);
            leaveMessageVC.ticketShowFlag = 1;

            ZCLibConfig *config = [[ZCPlatformTools sharedInstance] getPlatformInfo].config;
            leaveMessageVC.enclosureShowFlag = config.enclosureShowFlag;
            leaveMessageVC.ticketContentShowFlag = YES;// 默认显示
            leaveMessageVC.enclosureFlag = config.enclosureFlag;
            leaveMessageVC.telFlag = config.telFlag;
            leaveMessageVC.emailFlag = config.emailFlag;
            leaveMessageVC.telShowFlag = config.telShowFlag;
            leaveMessageVC.emailShowFlag =  config.emailShowFlag;
            leaveMessageVC.msgTmp =  config.msgTmp;
            leaveMessageVC.msgTxt = config.msgTxt;

            [leaveMessageVC setBackRefreshPageblock:^(id  _Nonnull object) {
                if(CloseBlock){
                    CloseBlock(@"关闭留言页面",0);
                }
            }];


            if(showRecored > 0){
                // 直接跳转到 留言记录、
                leaveMessageVC.selectedType = 2;
                leaveMessageVC.ticketShowFlag  = (showRecored == 1)?0:1;
            }

            if(sobotConvertToString(kitInfo.leaveTemplateId).length > 0){
                leaveMessageVC.templateldIdDic = @{@"templateId":kitInfo.leaveTemplateId,@"templateName":@""};
                [self getLeaveTemplateById:kitInfo.leaveTemplateId result:^(NSDictionary *dict, NSMutableArray *typeArr, int code) {
                    if(code == 0){
                        leaveMessageVC.tickeTypeFlag = [ sobotConvertToString( dict[@"data"][@"item"][@"ticketTypeFlag"] )intValue];
                        leaveMessageVC.ticketTypeId = sobotConvertToString( dict[@"data"][@"item"][@"ticketTypeId"]);
                        leaveMessageVC.telFlag = [sobotConvertToString( dict[@"data"][@"item"][@"telFlag"]) boolValue];
                        leaveMessageVC.telShowFlag = [sobotConvertToString(dict[@"data"][@"item"][@"telShowFlag"]) boolValue];
                        leaveMessageVC.emailFlag = [sobotConvertToString(dict[@"data"][@"item"][@"emailFlag"]) boolValue];
                        leaveMessageVC.emailShowFlag = [sobotConvertToString(dict[@"data"][@"item"][@"emailShowFlag"]) boolValue];
                        leaveMessageVC.enclosureFlag = [sobotConvertToString(dict[@"data"][@"item"][@"enclosureFlag"]) boolValue];
                        leaveMessageVC.enclosureShowFlag = [sobotConvertToString(dict[@"data"][@"item"][@"enclosureShowFlag"]) boolValue];
                //            leaveMessageVC.ticketShowFlag = [sobotConvertToString(dict[@"data"][@"item"][@"ticketShowFlag"]) intValue];
                        leaveMessageVC.ticketShowFlag = 1;
                        leaveMessageVC.ticketTitleShowFlag = [sobotConvertToString(dict[@"data"][@"item"][@"ticketTitleShowFlag"]) boolValue];
                        leaveMessageVC.ticketContentShowFlag = [sobotConvertToString(dict[@"data"][@"item"][@"ticketContentShowFlag"]) boolValue];
                        if (sobotConvertToString(dict[@"data"][@"item"][@"ticketContentShowFlag"]).length == 0) {
                            leaveMessageVC.ticketContentShowFlag = YES;
                        }
                        leaveMessageVC.ticketContentFillFlag = [sobotConvertToString(dict[@"data"][@"item"][@"ticketContentFillFlag"]) boolValue];

                        leaveMessageVC.msgTmp = sobotConvertToString(dict[@"data"][@"item"][@"msgTmp"]);
                        leaveMessageVC.msgTxt = sobotConvertToString(dict[@"data"][@"item"][@"msgTxt"]);
                        if (typeArr.count) {
                            if (leaveMessageVC.typeArr == nil) {
                                leaveMessageVC.typeArr = [NSMutableArray arrayWithCapacity:0];
                                leaveMessageVC.typeArr = typeArr;
                            }
                        }
                        if(byController.navigationController==nil || byController.navigationController.viewControllers.count == 1){
                            UINavigationController * navc = [[UINavigationController alloc]initWithRootViewController: leaveMessageVC];
                            // 设置动画效果
                            navc.modalPresentationStyle = UIModalPresentationOverFullScreen;
                            [byController presentViewController:navc animated:YES completion:^{

                            }];
                        }else{
                            [byController.navigationController pushViewController:leaveMessageVC animated:YES];
                        }
                    } else {

                        if (CloseBlock) {

                            CloseBlock(@"获取留言模版失败",1);
                        }
                    }
                }];
            }else{
                if(byController.navigationController==nil || byController.navigationController.viewControllers.count == 1){
                    UINavigationController * navc = [[UINavigationController alloc]initWithRootViewController: leaveMessageVC];
                    // 设置动画效果
                    navc.modalPresentationStyle = UIModalPresentationOverFullScreen;
                    [byController presentViewController:navc animated:YES completion:^{

                    }];
                }else{
                    [byController.navigationController pushViewController:leaveMessageVC animated:YES];
                }
            }
        }else{
            if(CloseBlock){
                CloseBlock(msg,code);
            }
        }
    }];
    
}

+(void)openRecordDetail:(NSString *)ticketId viewController:(UIViewController *) byController{
    ZCMsgDetailsVC * detailVC = [[ZCMsgDetailsVC alloc]init];
    detailVC.ticketId = sobotConvertToString(ticketId);
    detailVC.companyId = [ZCSobotApi getCommanyId];
    if (byController.navigationController!= nil) {
        [byController.navigationController pushViewController:detailVC animated:YES];
    }else{
        UINavigationController * navc = [[UINavigationController alloc]initWithRootViewController: detailVC];
        // 设置动画效果
        navc.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [byController presentViewController:navc animated:YES completion:^{

        }];
    }
}

+(void)openWebView:(NSString*)url viewController:(UIViewController *)byController{
    ZCUIWebController *webPage=[[ZCUIWebController alloc] initWithURL:sobotUrlEncodedString(url)];
    if (byController.navigationController!= nil) {
        [byController.navigationController pushViewController:webPage animated:YES];
    }else{
        UINavigationController * navc = [[UINavigationController alloc]initWithRootViewController: webPage];
        // 设置动画效果
        navc.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [byController presentViewController:navc animated:YES completion:^{
            
        }];
    }
}

+(NSString *)getCommanyId{
    return [SobotCache getLocalParamter:Sobot_CompanyId];
}

// 发送位置
+ (void)sendLocation:(NSDictionary *) locations resultBlock:(nonnull void (^)(NSString * _Nonnull, int))ResultBlock{
    if([[ZCUICore getUICore] getLibConfig].isArtificial){
        [[ZCUICore getUICore] sendMessage:locations[@"file"] type:SobotMessageTypeRichJson exParams:locations duration:@"" richType:SobotMessageRichJsonTypeLocation];
        if(ResultBlock){
            ResultBlock(@"执行了接口调用",0);
        }
    }else{
        if(ResultBlock){
            ResultBlock(@"当前是不是人工客服状态，不能给人工发送消息",1);
        }
    }
}

// 发送文字消息
+ (void)sendTextToUser:(NSString *)textMsg resultBlock:(nonnull void (^)(NSString * _Nonnull, int))ResultBlock{
    [self sendMessageToUser:textMsg type:SobotMessageTypeText richType:SobotMessageRichJsonTypeText resultBlock:ResultBlock];
}

+ (void)sendMessageToUser:(NSString *)textMsg type:(NSInteger ) msgType richType:(NSInteger)richType resultBlock:(nonnull void (^)(NSString * _Nonnull, int))ResultBlock {
    if([[ZCUICore getUICore] getLibConfig].isArtificial){
        [[ZCUICore getUICore] sendMessage:textMsg type:msgType exParams:nil duration:@"" richType:SobotMessageRichJsonTypeText];

        if(ResultBlock){
            ResultBlock(@"执行了接口调用",0);
        }
    }else{
        if(ResultBlock){
               ResultBlock(@"当前是不是人工客服状态，不能给人工发送消息",1);
        }
    }
}

// 发送订单卡片
+ (void)sendOrderGoodsInfo:(ZCOrderGoodsModel *)orderGoodsInfo resultBlock:(nonnull void (^)(NSString * _Nonnull, int))ResultBlock{
    if(orderGoodsInfo){
        // 仅人工时才可以发送
        if([[ZCUICore getUICore] getLibConfig].isArtificial){
            [[ZCUICore getUICore] sendOrderGoodsInfo:orderGoodsInfo resultBlock:ResultBlock];
        }else{
            if(ResultBlock){
                ResultBlock(@"当前是不是人工客服状态，不能给人工发送消息",1);
            }
        }


    }

}

// 发送商品卡片
+ (void)sendProductInfo:(ZCProductInfo *)productInfo resultBlock:(nonnull void (^)(NSString * _Nonnull, int))ResultBlock{

    if(productInfo){
        // 仅人工时才可以发送
        if([[ZCUICore getUICore] getLibConfig].isArtificial){
            [[ZCUICore getUICore] sendProductInfo:productInfo resultBlock:ResultBlock];
            
            if(ResultBlock){
                ResultBlock(@"执行了接口调用",0);
            }
        }else{
            if(ResultBlock){
                   ResultBlock(@"当前是不是人工客服状态，不能给人工发送消息",1);
            }
        }

    }

}

// 给机器人发送消息
+ (void)sendTextToRobot:(NSString *)textMsg{
    [[ZCUICore getUICore] sendMessage:textMsg type:SobotMessageTypeText exParams:nil duration:nil richType:SobotMessageRichJsonTypeText];
}


// 发送商品卡片
+ (void)sendCustomCardToRecord:(SobotChatCustomCard *)customCard resultBlock:(nonnull void (^)(NSString * _Nonnull, int))ResultBlock{
    if(customCard){
        [[ZCUICore getUICore] sendCusCardMessage:customCard type:0 isRobot:![ZCUICore getUICore].getLibConfig.isArtificial isFirst:NO];
    
        if(ResultBlock){
            ResultBlock(@"执行了接口调用",0);
        }
    }
}

// 发送商品卡片
+ (void)sendCustomCardToChat:(SobotChatCustomCard *)customCard resultBlock:(nonnull void (^)(NSString * _Nonnull, int))ResultBlock{
    if(customCard){
        [[ZCUICore getUICore] sendCusCardMessage:customCard type:1 isRobot:![ZCUICore getUICore].getLibConfig.isArtificial isFirst:NO];
        if(ResultBlock){
            ResultBlock(@"执行了接口调用",0);
        }
    }
}

// 同步用户信息
+ (void)synchronizationInitInfoToSDK:(void (^)(NSString *msg,int code))ResultBlock {
    if ([@"" isEqualToString:sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.app_key)] && [@"" isEqualToString:sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.customer_code)]) {
        if(ResultBlock){
            ResultBlock(@"appkey不能为空",1);
        }
        return;
    }
    ZCKitInfo *kitInfo = [ZCUICore getUICore].kitInfo;
    if (!kitInfo) {
        kitInfo = [ZCKitInfo new];
    }
    [ZCLibClient getZCLibClient].libInitInfo.isFirstEntry = 0;
    [[ZCUICore getUICore] doInitSDK:nil block:^(ZCInitStatus status, NSString * _Nullable message, ZCLibConfig * _Nullable confg) {
        if(status == ZCInitStatusLoadSuc){
            if(ResultBlock){
                ResultBlock(@"Success",0);
            }
        }else{
            if(ResultBlock){
                ResultBlock(message,1);
            }
        }
    }];
    
}

// 转人工自定义
+ (void)connectCustomerService:(SobotChatMessage *)message KitInfo:(ZCKitInfo*)uiInfo ZCTurnType:(NSInteger)turnType {
    if(uiInfo){
        [ZCUICore getUICore].kitInfo = uiInfo;
    }
    [[ZCUICore getUICore] doConnectUserService:message connectType:turnType];
}

+(void)getLastLeaveReplyMessage:(NSString *)partnerid resultBlock:(void (^)(NSDictionary * , NSMutableArray * , int))ResultBlock{
    if(sobotConvertToString(partnerid).length == 0){
        partnerid = [ZCSobotApi getUserUUID];
    }
    if(sobotConvertToString([ZCSobotApi getCommanyId]).length == 0){
        ResultBlock(@{@"msg":@"companyId is null"},nil,ZC_NETWORK_PARAMETER_FAIL);
        return;
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:sobotConvertToString([ZCSobotApi getCommanyId]) forKey:@"companyId"];
    [params setObject:sobotConvertToString(partnerid) forKey:@"partnerId"];
    [ZCLibServer getLastReplyLeaveMessage:params start:^{

    } success:^(NSDictionary *dict, NSMutableArray *itemArray, ZCNetWorkCode sendCode) {
        ResultBlock(dict,itemArray,(int)sendCode);

    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
        ResultBlock(@{@"msg":errorMessage},nil,(int)errorCode);
    }];
}

+(void)postLocalNotification:(NSString *)message dict:(NSDictionary *)userInfo{
    [SobotNotificationTools postLocalNotification:message dict:userInfo];
}

// 获取 SDK 版本号
+ (NSString *)getVersion {
   return  [ZCLibClient sobotGetSDKVersion];
}

// 获取渠道信息
+ (NSString *)getChannel {
    return [ZCLibClient sobotGetSDKChannel];
}

// 显示日志信息 默认不显示
+ (void)setShowDebug:(BOOL)isShowDebug {
    [SobotLog setDebug:isShowDebug];
}

+(void)setAutoMatchTimeZone:(BOOL)autoMatchTimeZone{
    [SobotCache addObject:[NSString stringWithFormat:@"%d",autoMatchTimeZone] forKey:@"ZCLocalAutoMatchTimeZone"];
}

+(BOOL)getPlatformIsArtificialWithAppkey:(NSString *)appkey Uid:(NSString*)uid{
    
    if ([appkey isEqualToString:[ZCUICore getUICore].getLibConfig.app_key] && [uid isEqualToString:[ZCUICore getUICore].getLibConfig.uid]) {
        if ([ZCUICore getUICore].getLibConfig.isArtificial) {
            return YES;
        }
    }
    return NO;
}

//
+ (NSString *)getSystem {
   return sobotGetSystemVersion();
}

// 获取当前app的版本号
+ (NSString *)getAppVersion {
   return sobotGetAppVersion();
}

// 获取手机型号
+ (NSString *)getIPhoneType {
   return sobotGetIphoneType();
}

// 获取当前集成的app名称
+ (NSString *)getAppName {
   return sobotGetAppName();
}

// 获取用户的 UUID
+ (NSString *)getUserUUID {
    
    return [[SobotDeviceTools shareDeviceTools] getIOSUUID];
}

// 添加异常统计
+ (void)setZCLibUncaughtExceptionHandler {
    [ZCLibUncaughtExceptionHandler setDefaultHandler];
}

// 读取日志文件内容 保存最近的7天
+ (NSString *)readLogFileDateString:(NSString *) dateString {
    return [ZCLibClient readLogFileDateString:dateString];
}

+ (void)outCurrentUserZCLibInfo:(BOOL) isClosePush {
    [ZCLibClient closeAndoutZCServer:isClosePush];
}


// 获取最后一条消息
+ (NSString *)readLastMessage {
    return [[ZCLibClient getZCLibClient] getLastMessage];
}

+(void) getLastMessageInfo:(void (^)(ZCPlatformInfo * _Nullable, SobotChatMessage * _Nullable, int))resultBlock{
    ZCPlatformInfo *info1 = [[ZCPlatformTools sharedInstance] getPlatformInfo];
    if(resultBlock){
        resultBlock(info1,nil,0);
    }
    // 去初始化
    [self synchronizationInitInfoToSDK:^(NSString * _Nonnull msg, int code) {
        if(code == 0){
            ZCPlatformInfo *info = [[ZCPlatformTools sharedInstance] getPlatformInfo];

            [ZCLibServer getChatUserCids:0 uid:info.config.uid start:^(NSString * _Nonnull url, NSDictionary * _Nonnull paramters) {
                
            } success:^(NSDictionary * _Nonnull dict, ZCNetWorkCode code) {
                if(dict[@"data"] == nil){
                    if(resultBlock){
                        resultBlock(info,nil,-3);
                    }
                    return;
                }
                NSMutableArray *arr = [NSMutableArray arrayWithArray:dict[@"data"][@"cids"]] ;
                //先将当前正在会话的cid添加到cid列表中
                BOOL isHave = NO;
                if (arr !=nil && arr.count>0) {
                    for (NSString *cid in arr) {
                        if ([cid isEqualToString:info.config.cid] && sobotConvertToString(info.config.cid).length > 0) {
                            isHave = YES;
                        }
                    }
                }
                if (!isHave && arr !=nil ) {
                    [arr addObject:info.config.cid];
                }
                if(arr !=nil && [arr isKindOfClass:[NSMutableArray class]]  && arr.count > 0){
                    [self getLastHistoryMessage:arr info:info blcok:resultBlock];
                }else if (!sobotIsNull(arr) && arr.count == 0){
                    if(resultBlock){
                        resultBlock(info,nil,-3);
                    }
                }
            } failed:^(NSString * _Nonnull errormsg, ZCNetWorkCode code) {
                if(resultBlock){
                    resultBlock(info,nil,-2);
                }
            }];
        }
    }];
}

+(void)getLastHistoryMessage:(NSMutableArray *) cids info:(ZCPlatformInfo *) info blcok:(void (^)(ZCPlatformInfo * _Nonnull, SobotChatMessage * _Nonnull, int))resultBlock{
    
    [ZCLibServer getHistoryMessages:[cids lastObject] withUid:info.config.uid currtCid:[ZCUICore getUICore].getLibConfig.cid start:^(NSString * _Nonnull url, NSDictionary * _Nonnull parameters) {
        
    } success:^(NSMutableArray * _Nonnull messages, ZCNetWorkCode code) {
        if(resultBlock){
            if(messages.count > 0){
                SobotChatMessage *lastModel = [messages lastObject];
                if(lastModel){
                    
                    info.lastMsg = lastModel.richModel.content;
                    if(lastModel.richModel.type == SobotMessageRichJsonTypeGoods){
                        info.lastMsg = [NSString stringWithFormat:@"[%@]", SobotKitLocalString(@"商品")];
                    }
                    if(lastModel.richModel.type == SobotMessageRichJsonTypeOrder){
                        info.lastMsg = [NSString stringWithFormat:@"[%@]", SobotKitLocalString(@"订单")];
                    }
                    if(lastModel.msgType == SobotMessageTypeFile){
                        info.lastMsg = [NSString stringWithFormat:@"[%@]", SobotKitLocalString(@"文件")];
                    }
                    if(lastModel.msgType == SobotMessageTypeVideo){
                        info.lastMsg = [NSString stringWithFormat:@"[%@]", SobotKitLocalString(@"视频")];
                    }
                    if(lastModel.msgType == SobotMessageTypeSound){
                        info.lastMsg = [NSString stringWithFormat:@"[%@]", SobotKitLocalString(@"语音")];
                    }
                    if(lastModel.msgType == SobotMessageTypePhoto){
                        info.lastMsg = [NSString stringWithFormat:@"[%@]", SobotKitLocalString(@"图片")];
                    }
                    info.lastDate = lastModel.ts;
                    info.avatar = lastModel.senderFace;
                    info.platformName = lastModel.senderName;
                }
                resultBlock(info,lastModel,1);
            }else{
                [cids removeLastObject];
                if(cids.count > 0){
                    [self getLastHistoryMessage:cids info:info blcok:resultBlock];
                }else{
                    if(resultBlock){
                        resultBlock(info,nil,-4);
                    }
                }
            }
        }
    } failed:^(NSString * _Nonnull errormsg, ZCNetWorkCode) {
        if(resultBlock){
            resultBlock(info,nil,-1);
        }
    }];
}

// 检查当前消息通道是否建立，没有就重新建立
+ (void)checkIMConnected {
    [[ZCLibClient getZCLibClient] checkIMConnected];
}

// 关闭当前消息通道，使其不再接受消息
+ (void)closeIMConnection {
    [[ZCLibClient getZCLibClient] closeIMConnection];

}

// 清空用户下的所有未读消息(本地清空)
+ (void)clearUnReadNumber:(NSString *) partnerid {
   [[ZCLibClient getZCLibClient] clearUnReadNumber:partnerid];
}

// 获取未读消息数
+ (int)getUnReadMessage {
    return [[ZCLibClient getZCLibClient] getUnReadMessage];
}
+ (NSString *)getLastMessage {
    return [[ZCLibClient getZCLibClient] getLastMessage];

}

#pragma mark - Private method
+(void)checkConfig:(void (^)(NSString *,int code))ResultBlock{
    if ([@"" isEqualToString:sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.app_key)] && [@"" isEqualToString:sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.customer_code)]) {
        if(ResultBlock){
            ResultBlock(@"appkey不能为空",1);
        }
        return;
    }
        
    if(([[ZCPlatformTools sharedInstance] getPlatformInfo].config == nil) || ![[ZCLibClient getZCLibClient].libInitInfo.partnerid isEqual:[[ZCPlatformTools sharedInstance] getPlatformInfo].config.zcinitInfo.partnerid]){
        [self backgroundInitSDK:ResultBlock];
    }else{
        if(ResultBlock){
            ResultBlock(@"Success",0);
        }
    }
    
}


+(void)backgroundInitSDK:(void (^)(NSString *,int code))ResultBlock{
    if ([@"" isEqualToString:sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.app_key)] && [@"" isEqualToString:sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.customer_code)]) {
        if(ResultBlock){
            ResultBlock(@"appkey不能为空",1);
        }
        return;
    }
    ZCKitInfo *kitInfo = [ZCUICore getUICore].kitInfo;
    if (!kitInfo) {
        kitInfo = [ZCKitInfo new];
    }
    
    
    [[ZCUICore getUICore] doInitSDK:nil block:^(ZCInitStatus status, NSString * _Nullable message, ZCLibConfig * _Nullable confg) {
        if(status == ZCInitStatusLoadSuc){
            if(ResultBlock){
                ResultBlock(@"Success",0);
            }
        }else{
            if(ResultBlock){
                ResultBlock(@"Fail",1);
            }
        }
    }];
    
    
}


+(void)synchronizeLanguage:(NSString *) language write:(BOOL) isReWrite result:(nonnull void (^)(NSString * _Nonnull message, int code))ResultBlock{
    if(sobotConvertToString(language).length == 0){
        return;
    }
    
    // 本地文件无需同步
    NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"SobotKit" ofType:@"bundle"];
    bundlePath = [bundlePath stringByAppendingPathComponent:[NSString stringWithFormat:@"SobotLocalizable/%@", language]];
    // 本地bundle中存在文件，则不加载
    if([NSBundle bundleWithPath:bundlePath]){
        if(ResultBlock){
            ResultBlock(@"已存在，未同步",0);
        }
        return;
    }
    NSString *dataPath = sobotGetDocumentsFilePath([NSString stringWithFormat:@"/sobot/"]);
    // 创建目录
    sobotCheckPathAndCreate(dataPath);
    // 拼接完整的地址
    dataPath=[dataPath stringByAppendingString:[NSString stringWithFormat:@"/ios_%@_%@.json",[ZCLibClient sobotGetSDKVersion],language]];
    
    // 文件已经存在，并且不重写
    if(sobotCheckFileIsExsis(dataPath) && !isReWrite){
        if(ResultBlock){
            ResultBlock(@"已下载，未同步",0);
        }
        return;
    }
    
    NSString *serverUrl = [NSString stringWithFormat:@"https://img.sobot.com/mobile/multilingual/ios/ios_%@_%@.json",[[ZCLibClient sobotGetSDKVersion] substringToIndex:5],language];
//    NSLog(@"%@",serverUrl);
    // 下载，播放网络声音
//    https://img.sobot.com/mobile/multilingual/ios/ios_2.8.6_en_lproj.json
//    https://img.sobot.com/mobile/multilingual/ios/ios_2.8.6_en_proj.json
    [ZCLibServer downFileWithURL:serverUrl start:^(NSString * _Nonnull url) {
        
    } success:^(NSData * _Nonnull data) {
        if(data && data.length > 500){
            [data writeToFile:dataPath atomically:YES];
//            NSLog(@"%@",dataPath);
//            NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

            if(ResultBlock){
                ResultBlock(@"同步成功",0);
            }
        }else{
            if(ResultBlock){
                ResultBlock(@"同步失败，下载不完整",1);
            }
        }
    } progress:^(float progress) {
        
    } fail:^(ZCNetWorkCode code) {
        // 格式不对，不会执行正确的接口
        if(ResultBlock){
            ResultBlock(@"同步失败，下载异常",1);
        }
    }];
}

+(NSString *)getCurLanguagePreHeader{
    return [NSString stringWithFormat:@"%@_lproj",sobotGetLanguagePrefix()];
}


// 多语言测试方法
+(NSString *)checkZCSTLocalString:(NSString *)key{
    NSString *v = nil;
    NSString * sourcePath = @"";
    NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"SobotKit" ofType:@"bundle"];
    bundlePath = [bundlePath stringByAppendingPathComponent:@"SobotLocalizable"];
    
    if([ZCLibClient getZCLibClient].libInitInfo!=nil && [ZCLibClient getZCLibClient].libInitInfo.absolute_language!=nil){
        sourcePath = [bundlePath stringByAppendingPathComponent:[ZCLibClient getZCLibClient].libInitInfo.absolute_language];
        if(![NSBundle bundleWithPath:sourcePath]){
            sourcePath = @"";
            NSString *jsonPath = sobotGetDocumentsFilePath([NSString stringWithFormat:@"/sobot/ios_%@_%@.json",[ZCLibClient sobotGetSDKVersion],[ZCLibClient getZCLibClient].libInitInfo.absolute_language]);
            if(sobotCheckFileIsExsis(jsonPath)){
               NSData *data=[NSData dataWithContentsOfFile:jsonPath];
               NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
               if(dict && [[dict allKeys] containsObject:key]){
                   v = dict[key];
               }
            }
        }
    }
    if(v==nil && sourcePath.length == 0){
        // 跟随系统
        sourcePath = [bundlePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_lproj",sobotGetLanguagePrefix()]];
        if(![NSBundle bundleWithPath:sourcePath]){
            // 跟随系统不识别，默认
            if([ZCLibClient getZCLibClient].libInitInfo!=nil && [ZCLibClient getZCLibClient].libInitInfo.default_language!=nil){
                sourcePath = [bundlePath stringByAppendingPathComponent:[ZCLibClient getZCLibClient].libInitInfo.default_language];
            }else{
                sourcePath = [bundlePath stringByAppendingPathComponent:@"en_lproj"];
            }
        }
    }
    if(sourcePath.length > 0){
        NSBundle *resourceBundle = [NSBundle bundleWithPath:sourcePath];
        v = [resourceBundle localizedStringForKey:key value:@"" table:@"SobotLocalizable"];
    }
    return v==nil ? key : v;
}

+(NSString *)zcMd5Sign:(NSString *) sign{
    return sobotMd5(sign);
}

+(NSString *)zcGetCurrentTimes{
    return sobotGetCurrentTimes();
}

+(void)closeSobotPage{
    if ([ZCUICore getUICore].ZCClosePageBlock) {
        [ZCUICore getUICore].ZCClosePageBlock(ZCPageStateTypeUserClose);
    }
}

+(void)setAppletClickBlock:(BOOL(^)(SobotChatMessage *_Nonnull))appletBlock{
    if (appletBlock != nil) {
        [[ZCUICore getUICore] setAppletClickBlock:appletBlock];
    }
}

+(void)customLeavePageClickBlock:(BOOL(^)(NSDictionary *dict))leavePageBlock{
    if (leavePageBlock != nil) {
        [[ZCUICore getUICore] setCustomLeavePageBlock:leavePageBlock];
    }
}

+(void)setCustomLeavePageBlock:(BOOL(^)(NSDictionary * dict))leavePageBlock{
    if (leavePageBlock != nil) {
        [[ZCUICore getUICore] setCustomLeavePageBlock:leavePageBlock];
    }
}
@end
