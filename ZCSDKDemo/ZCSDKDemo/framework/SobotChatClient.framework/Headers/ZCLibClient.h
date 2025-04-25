//
//  ZCLibClient.h
//  SobotChatClient
//
//  Created by zhangxy on 2022/8/29.
//

#import <Foundation/Foundation.h>
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/ZCLibInitInfo.h>


// 当前用户会话状态
typedef NS_ENUM(NSInteger,ZCServerConnectStatus) {
    ZCServerConnectOffline    = 0, // 当前会话已经结束
    ZCServerConnectRobot      = 1, // 机器人
    ZCServerConnectArtificial = 2, // 人工接入成功
    ZCServerConnectWaiting    = 3  // 仅人工的排队
};


/**
 *
 *  消息回调
 *
 */
@protocol ZCReceivedMessageDelegate <NSObject>

@optional
//未读消息数获取
-(void)onReceivedMessage:(id _Nullable) message unRead:(int) nleft obj:(id _Nullable) object;


@optional
/// 当前链接的实施状态
/// @param status status description
-(void)currentConnectStatus:(id _Nullable) message status:(ZCServerConnectStatus) status obj:(id _Nullable) object;

@end

/**
 *  未读消息数，block方式获取
 *
 *  @param message 当前消息
 *  @param nleft   未读消息数
 */
typedef void(^ReceivedMessageBlock)(id _Nullable message,int nleft,NSDictionary * _Nullable object);


typedef void(^ZCServerConnectBlock)(id _Nullable message,ZCServerConnectStatus status,NSDictionary * _Nullable object);




typedef void(^TurnServiceBlock)(SobotChatMessage *_Nullable model, NSInteger turnType);



/**
 初始化配置类
 */
@interface ZCLibClient : NSObject

+(ZCLibClient *_Nonnull) getZCLibClient;

/// 初始化功能配置属性
@property (nonatomic,strong) ZCLibInitInfo *_Nullable libInitInfo;



// 同ZCKitInfo中的配置有同等效力，不会覆盖
@property (nonatomic,strong) id<ZCReceivedMessageDelegate> _Nullable delegate;
// block方式配置
@property (nonatomic,strong) ReceivedMessageBlock         _Nullable receivedBlock;

@property (nonatomic,strong) ZCServerConnectBlock         _Nullable serverConnectBlock;

/**
 *
 *
 * 自定义转人工回调事件
 * 拦截SDK 转人工事件 用于跳转到自己的app页面动态处理转人工 配置技能组id 商品信息等参数
 *
 *
 ***/
@property (nonatomic,strong)  TurnServiceBlock   _Nullable turnServiceBlock;


/**
 推送的token
 每次启动应用都需要重新设置
 */
@property (nonatomic,strong) NSData     * _Nullable token;



/// 可直接设置字符串，NSdata可不设置
@property (nonatomic,strong) NSString     * _Nullable deviceToken;

/**
 平台标识，仅电商版本需要
 */
@property (nonatomic,strong) NSString     * _Nullable platformUnionCode;
/**
 测试模式，
 根据此设置调用的推送证书，默认NO
 NO ,调用生产环境
 YES，测试环境
 */
@property (nonatomic,assign) BOOL isDebugMode;


/**
 自动提醒消息
 说明：如果开启自动提醒消息，当没有在智齿聊天页面的时候，都会主动把消息作为本地通知展示
 */
@property (nonatomic,assign) BOOL autoNotification;

/**
 退出道后台，自动关闭长连接，默认NO
 说明：如果设置YES，退出后台立即关闭通道，不影响应用后台挂起时长
 */
@property (nonatomic,assign) BOOL autoCloseConnect;

/**
 *  记录当前是否可以显示转人工按钮（记录机器人未知回复的次数已达到，在一次有效的会话中）
 */
@property (nonatomic,assign) BOOL isShowTurnBtn;


// 初始化，验证企业配置
-(void)initSobotSDK:(NSString *_Nonnull) appkey host:(NSString * _Nullable)apiHost;
// code=0成功，非0失败
-(void)initSobotSDK:(NSString *_Nonnull) appkey host:(NSString * _Nullable)apiHost result:(void (^_Nullable)(int code,id _Nullable object))resultBlock;

-(BOOL) getInitState;

-(NSString *_Nonnull)getCurApiHost;


/**
 @note 检查当前消息通道是否建立，没有就重新建立
 如果调用 closeIMConnection 后，可调用此方法重新建立链接
 */
-(void)checkIMConnected;


/**
 @note 关闭当前消息通道，使其不再接受消息
 */
-(void)closeIMConnection;

/**
 移除IM所有监听，可能会影响应用在后台存活时长，如果调用此方法后需要checkIMObserverWithCreate重新激活
 网络监听 ZCNotification_NetworkChange
 UIApplicationDidBecomeActiveNotification
 UIApplicationDidEnterBackgroundNotification
 */
-(void)removeIMAllObserver;

/**
 检查当前监听是否被移除，如果移除就重新注册
 */
-(void)checkIMObserverWithRegister;


+(void) closeAndoutZCServer:(BOOL) isClosePush;

// 是否为电商版本
+(BOOL) isPlatformUnion;


// 当前版本
+(NSString *_Nonnull)sobotGetSDKVersion;

// 当前渠道
+(NSString *_Nonnull)sobotGetSDKChannel;


-(void)postConnectStatus:(ZCServerConnectStatus ) status msg:(NSString *_Nullable) result obj:(id _Nullable) obj;


-(NSString *_Nonnull)getLastMessage;

+(NSString *_Nonnull) readLogFileDateString:(NSString *_Nullable) dateString;


/// 当前正在使用的语言
/// 不能获取default_language配置，次配置会在实际使用失败时生效
+(NSString *_Nonnull)getCurUseLanguagePreHeader;

/**
 获取未读消息数
 
 @return 未读消息数(进入智齿聊天页面会清空)
 */
-(int) getUnReadMessage;

/**
 清空用户下的所有未读消息(本地清空)

 @param partnerid 接入的用户ID
 */
-(void) clearUnReadNumber:(NSString *_Nullable) partnerid;

@end
