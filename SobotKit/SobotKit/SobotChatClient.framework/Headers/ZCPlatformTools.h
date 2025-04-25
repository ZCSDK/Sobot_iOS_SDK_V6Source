//
//  ZCPlatformTools.h
//  SobotChatClient
//
//  Created by zhangxy on 2022/8/30.
//

#import <Foundation/Foundation.h>
#import <SobotChatClient/ZCLibConfig.h>
#import <SobotChatClient/ZCVisitorConfig.h>
#import <SobotCommon/SobotCommon.h>
NS_ASSUME_NONNULL_BEGIN

@class ZCPlatformInfo;

@interface ZCPlatformTools : NSObject


+ (instancetype)sharedInstance;


/**
 访客配置
 */
@property (nonatomic,strong) ZCVisitorConfig *_Nullable visitorConfig;


// 留言记录状态
@property(nonatomic,strong) NSMutableDictionary *_Nullable orderStatusDict;
-(NSString *)getOrderStatus:(int ) status;

/**
 根据statusCode获取显示类型
 状态类别 1-新建，2-受理中 3-等待客户回复 4-暂停 5-已解决 6 已关闭 7 已删除
 */
-(UIColor *)getOrderStatusTypeBgColor:(int ) status bg:(BOOL) isBgColor;

-(UIColor *)getOrderStatusTypeTextColor:(int ) status;
/// 离线消息开关，1:开; 0:关,
/// 临时存储使用
@property (nonatomic,assign) BOOL isOfflineMsgConnect;

/// 离线消息的客服ID，当id不为空是，说明当前客户发送了离线消息，需要直接转人工
/// 临时存储使用
@property (nonatomic,strong) NSString *offlineMsgAdminId;

/**
 获取平台咨询过的商户列表

 本地获取，主线程执行即可
 @return 商户列表
 */
-(NSMutableArray *) getPlatformList:(NSString *) partnerid;


/**
 删除商家信息,本地永久删除
 
 @param appkey 商户APPKEY
 @param partnerid 用户标识
 */
-(void)deletePlatformByAppKey:(NSString *) appkey user:(NSString *) partnerid;



-(ZCPlatformInfo *)getPlatformInfo:(NSString *) appkey partnerid:(NSString *) partnerid;
-(void)savePlatformInfo:(ZCPlatformInfo *)platformInfo;

//////////////////////////////////////////
-(ZCPlatformInfo *)getPlatformInfo;
-(SobotChatMessage *)getWaitingMessage;
-(NSString *)getPlatformUserId;


/**
 获取当前商户消息列表

 @param appkey 具体商户APPKEY
 @return 最新消息列表
 */
-(NSMutableArray *)getMessageForAppkey:(NSString *) appkey partnerid:(NSString *)partnerid;



/**
 退出登录时调用
 */
-(void)cleanCacheData;


/**
 初始化失败时清理

 @param appkey
 @param partnerid
 */
-(void)cleanCacheDataByAppkey:(NSString *) appkey partnerid:(NSString *) partnerid;
+(void)cleanLocalParamterByPrefix:(NSString *) prefix;

-(NSString *)getPlatformUserId;

/**
 判断当前初始化条件是否改变
 
 @return YES 需要从新初始化，NO不需要重新初始化
 */
+(BOOL) checkInitParameterChanged;
+(NSString *) getCheckConfigMsg;


// 检查是否拥有留言功能
+(BOOL) checkLeaveMessageModule;


+(NSMutableDictionary *)getMessageDict:(NSDictionary *) message type:(SobotMessageType ) type richType:(SobotMessageRichJsonType) richType robot:(BOOL) robotAnswer;
/// 创建消息对象
/// @param isSender 是否为发送者，如果不是就是机器人或客服
/// @param type 消息类型
/// @param richType 富文本类型，type=5时生效
/// @param action 提示语
/// @param message 普通消息@{content:xxx}
/// @param libConfig 创建对象需要的基础信息
///
+(SobotChatMessage *)createLocalMessage:(BOOL) isSender messageType:(SobotMessageType) type richType:(SobotMessageRichJsonType )richType action:(SobotMessageActionType ) action message:(NSDictionary * _Nullable ) message robot:(BOOL)robotAnswer config:(ZCLibConfig *) libConfig;


+(NSString *)getLastMessage:(SobotChatMessage *) chatMsg urlRegular:(NSString *)urlRegular;
/**
 *  获取提示语实际内容
 *
 *  @param action 类型
 *  @param content  文本内容
 *  @return 提示语
 */
+(NSString *)getTipMsg:(SobotMessageActionType)action content:(NSString*)content;

@end

@interface ZCPlatformInfo : NSObject

@property (nonatomic,strong) NSString *listId;
@property (nonatomic,strong) NSString *platformId;
@property (nonatomic,strong) NSString *partnerid;
@property (nonatomic,strong) NSString *app_key;
@property (nonatomic,strong) NSString *companyId;
@property (nonatomic,strong) NSString *platformName;
@property (nonatomic,strong) NSString *avatar;
@property (nonatomic,strong) NSString *lastDate;
@property (nonatomic,strong) NSString *lastMsg;
@property (nonatomic,assign) int       unRead;
@property (nonatomic,strong) NSString *uid;
@property (nonatomic,strong) NSString *puid;
@property (nonatomic,strong) NSString *lastCid;
@property (nonatomic,strong) NSString *configJson;
@property (nonatomic,strong) NSString * customer_code;// 对应的商户appkey

// 临时数据
@property (nonatomic,assign) BOOL isSendToRobot;
@property (nonatomic,assign) BOOL isSendToUser;
@property (nonatomic,assign) BOOL isPjRobot;
@property (nonatomic,assign) BOOL isPjUser;
@property (nonatomic,strong) NSString *groupId;
@property (nonatomic,strong) NSString *groupName;
@property (nonatomic,strong) NSString     *checkInitKey;
@property (nonatomic,strong) ZCLibConfig  *config;
@property (nonatomic,strong) SobotChatMessage *  _Nullable waitingMessage;
@property (nonatomic,strong) NSMutableArray  * _Nullable messageArr;

/** 保存历史记录的cid列表 */
@property(nonatomic, strong) NSMutableArray * _Nullable cidsArray;


@end
NS_ASSUME_NONNULL_END
