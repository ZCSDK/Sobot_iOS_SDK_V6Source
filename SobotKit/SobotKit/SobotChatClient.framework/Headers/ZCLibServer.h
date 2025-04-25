//
//  ZCLibServer.h
//  SobotChatClient
//
//  Created by zhangxy on 2022/8/30.
//

#import <Foundation/Foundation.h>
#import <SobotChatClient/SobotChatClientDefines.h>
#import <SobotChatClient/SobotMessageDefines.h>
#import <SobotChatClient/ZCLibConfig.h>
NS_ASSUME_NONNULL_BEGIN

typedef void(^SobotKitResultBlock)(ZCNetWorkCode code,id _Nullable obj,NSDictionary *_Nullable dict,NSString *_Nullable jsonString);

/// <#Description#>
@interface ZCLibServer : NSObject

/// 查询appkey企业配置信息
/// @param appkey 当前appkey
/// @param resultBlock 结果 非0，全是失败
+(void)configSobotSDK:(NSString *) appkey result:(void (^)(ZCNetWorkCode status,NSString *errorMessage))resultBlock;

/// 启动智齿客服接口
/// @param successBlock 成功
/// @param errorBlock 接口失败
/// @param appIdIncorrectBlock 参数异常(未初始化[configSobotSDK]/appkey错误)
+(void)initSobotChat:(void (^)(ZCLibConfig *config))successBlock
               error:(void (^)(ZCNetWorkCode status,NSString *errorMessage))errorBlock
      appIdIncorrect:(void (^)(NSString *appId))appIdIncorrectBlock;



/// 转人工
/// @param parameters 转人工参数
/// @param _config 初始化对象
/// @param startBlock 开始
/// @param resultBlock 结束，根据code判断是否成功
+(void)connectOnlineCustomer:(ZCLibOnlineCustomerParams *) parameters
                      config:(ZCLibConfig *) _config
                       start:(void(^)(NSString *url))startBlock
                      result:(void (^)(NSDictionary *result, ZCConnectUserStatusCode code)) resultBlock;



/// 查询技能组
/// @param _config 初始化对象
/// @param startBlock 开始
/// @param successBlock 成功
/// @param failedBlock 失败
+(void)getGroupList:(ZCLibConfig *)_config
             start:(void (^)(NSString *))startBlock
           success:(void (^)(NSMutableArray *, ZCNetWorkCode code))successBlock
             failed:(void (^)(NSString *, ZCNetWorkCode code))failedBlock;

/// 确认消息
/// @param params ack参数
/// @param resultBlock 结果
+(void)ack:(NSDictionary *) params result:(void (^)(ZCNetWorkCode code,id _Nullable message))resultBlock;


/// 生成本地消息Id
/// @param cid 当前cid
+(NSString *)getLocalMsgId:(NSString *) cid;

/// 轮训消息
/// @param config 参数
/// @param resultBlock 结果
/// @param finishBlock 完成
+(void)loopMsg:(ZCLibConfig *) config result:(void (^)(ZCNetWorkCode code,id _Nullable message))resultBlock finish:(void (^)(id _Nullable message))finishBlock;


+ (void)initLeaveMsgConfig:(NSString *)groupId
                       uid:(NSString *)uid
                     error:(void (^)(ZCNetWorkCode status,NSString *errorMessage))errorBlock
                   success:(void(^)(NSString *msgLeaveTxt,NSString *msgLeaveContentTxt,NSString *leaveExplain)) successBlock;

/// 留言获取自定义字段
/// @param params  参数uid
/// @param resultBlock 结果
/// @param finishBlock 完成
+(void)postTemplateFieldInfoWithParams:(NSDictionary*) params
                                result:(void (^)(ZCNetWorkCode code,id _Nullable message,id object,NSDictionary *dict))resultBlock
                                finish:(void (^)(id _Nullable message))finishBlock;

/// 提交留言
/// @param params  参
/// @param resultBlock 结果
/// @param finishBlock 完成
+(void)sendLeaveMessage:(NSMutableDictionary *) params
                 config:(ZCLibConfig *) config
                  start:(void(^)(NSString *url,NSDictionary *paramters)) startBlock
            resultBlock:(SobotKitResultBlock)resultBlock
                 finish:(void(^)(id response,NSData  *data)) finishBlock;


/// 提交留言
/// @param config  参
/// @param startBlock  开始
/// @param successBlock 结果
/// @param failedBlock 完成
+(void)postUserTicketInfoListWithConfig:(ZCLibConfig*)config
                                  start:(void (^)(NSString *url,NSDictionary *params))startBlock
                                success:(void(^)(NSDictionary *dict,NSMutableArray * itemArray,ZCNetWorkCode sendCode)) successBlock
                                 failed:(void(^)(NSString *errorMessage,ZCNetWorkCode errorCode)) failedBlock;


/**
 *  获取用户留言记录详情页接口 2.7.1 新增
 *  ticketld  工单id
 *  dict : {
 *  partnerid
 *  uid
 *  companyId
 * }
 *
 **/
+(void)postUserDealTicketinfoListWith:(NSDictionary *)dict
                             ticketld:(NSString *)ticketld
                                start:(void (^)(void))startBlock
                              success:(void(^)(NSDictionary *dict,NSMutableArray * itemArray,ZCNetWorkCode sendCode)) successBlock
                               failed:(void(^)(NSString *errorMessage,ZCNetWorkCode errorCode)) failedBlock;


/// 获取留言最后一条回复
/// @param params <#params description#>
/// @param startBlock <#startBlock description#>
/// @param successBlock <#successBlock description#>
/// @param failedBlock <#failedBlock description#>
+(void)getLastReplyLeaveMessage:(NSMutableDictionary *)params start:(void (^)())startBlock success:(void (^)(NSDictionary *, NSMutableArray *, ZCNetWorkCode))successBlock failed:(void (^)(NSString *, ZCNetWorkCode))failedBlock;


+(void)downFileWithURL:(NSString *)url
                 start:(void (^)(NSString *url))startBlock
               success:(void (^)(NSData * data))successBlock
              progress:(void (^)(float progress))progressBlock
                  fail:(void (^)(ZCNetWorkCode code))failBlock;

/**
 *   设置留言回复已读状态
 *  @param  params          回复字典
 *  @{@"ticketId":@"工单编号",
 *  @"partnerId":@"对接id",
 *  @"companyId":@"公司id"}
 *  @param  startBlock     开始请求的回调
 *  @param  successBlock   请求成功的回调
 *  @param  failedBlock    请求失败的回调
 */
+(void)updateUserTicketReplyInfo:(NSMutableDictionary *)params
                           start:(void (^)(void))startBlock
                         success:(void(^)(NSDictionary *dict,ZCNetWorkCode sendCode)) successBlock
                          failed:(void(^)(NSString *errorMessage,ZCNetWorkCode errorCode)) failedBlock;


/**
 *   获取 留言模板基础配置 2.7.1新增
 *  @param  config        初始化对象
 *  @param  params          回复字典
 *  @{@"ticketId":@"工单编号",
 *  @"replyContent":@"回复内容",
 *  @"fileStr":@"附件路径，多个附件中间以分号分隔",
 *  @"companyId":@"公司id"}
 *  @param  startBlock     开始请求的回调
 *  @param  successBlock   请求成功的回调
 *  @param  failedBlock    请求失败的回调
 */
+(void)replyLeaveMessage:(ZCLibConfig*)config
             replayParam:(NSDictionary *)params
                   start:(void (^)(void))startBlock
                 success:(void(^)(NSDictionary *dict,NSMutableArray * itemArray,ZCNetWorkCode sendCode)) successBlock
                  failed:(void(^)(NSString *errorMessage,ZCNetWorkCode errorCode)) failedBlock;

/**
 @parma filePath:文件路径
 @parma commanyId: 企业编号
 */
+(void)fileUploadForLeave:(NSString *) filePath
                config:(ZCLibConfig *) libConfig
                    start:(void(^)(void))startBlock
                  success:(void(^)(NSString *fileURL,ZCNetWorkCode code)) successBlock
                     fail:(void(^)(ZCNetWorkCode errorCode)) failBlock;


/**
 *   获取 留言模板基础配置 2.7.1新增
 *  @param  uid          用户ID
 *  @param  templateld          留言模板id
 *  @param  startBlock     开始请求的回调
 *  @param  successBlock   请求成功的回调
 *  @param  failedBlock    请求失败的回调
 */
+(void)postMsgTemplateConfigWithUid:(NSString *)uid
                         Templateld:(NSString *)templateld
                              start:(void (^)(void))startBlock
                            success:(void(^)(NSDictionary *dict,NSMutableArray * typeArr,ZCNetWorkCode sendCode)) successBlock
                             failed:(void(^)(NSString *errorMessage,ZCNetWorkCode errorCode)) failedBlock;


/// 获取 选择留言模版
/// @param config config description
/// @param uid uid description
/// @param groupId groupId description
/// @param startBlock startBlock description
/// @param successBlock successBlock description
/// @param failBlock failBlock description
+(void)getWsTemplateList:(ZCLibConfig *)config
                            uid:(NSString*)uid
                        groupId:(NSString *)groupId
                          start:(void (^)(void))startBlock
                        success:(void(^)(NSDictionary *dict,NSMutableArray *typeArr,ZCNetWorkCode sendCode)) successBlock
                           fail:(void(^)(NSString *errorMsg,ZCNetWorkCode errorCode)) failBlock;


/**
 *   提交询前表单的接口
 *   @param   uid           用户ID
 *    @param  params        用户自定义字段
 *   @param  successBlock   请求成功的回调
 *   @param  failedBlock    请求失败的回调
 *   @param  startBlock  请求开始的回调
 */
+(void)postAskTabelWithUid:(NSString *)uid
                     Parms:(NSMutableDictionary *) params
                     start:(void (^)(void))startBlock
                   success:(void(^)(NSDictionary *dict,ZCNetWorkCode sendCode)) successBlock
                    failed:(void(^)(NSString *errorMessage,ZCNetWorkCode errorCode)) failedBlock;



/// 查询快捷菜单
/// @param config 初始化对象
/// @param startBlock 开始
/// @param successBlock 成功
/// @param failBlock 失败
+(void)getLableInfoList:(ZCLibConfig*)config
            opportunity:(NSString *) opportunity
                  start:(void(^)(NSString *url))startBlock
                success:(void(^)(NSDictionary *dict,ZCMessageSendCode sendCode)) successBlock
                   fail:(void(^)(NSString * errorMsg,ZCMessageSendCode errorCode)) failBlock;

/// 4.1.8新增接口，当切换快捷菜单时添加统计数据
+(void)addLabelShowTriggerCount:(ZCLibConfig*)config
                   menuPlanId:(NSString *) menuPlanId
                  start:(void(^)(NSString *url))startBlock
                success:(void(^)(NSDictionary *dict,ZCMessageSendCode sendCode)) successBlock
                         fail:(void(^)(NSString * errorMsg,ZCMessageSendCode errorCode)) failBlock;


/// 
/// 4.1.8新增接口，本地添加快捷菜单列表，机器人默认，人工模式，如果前两组都没有数据，显示兜底进入会话列表
/// @param config 当前初始化对象
/// @param startBlock 开始
/// @param successBlock 成功
/// @param failBlock 失败
+(void)getLabelInfoListNew:(ZCLibConfig*)config
                  start:(void(^)(NSString *url))startBlock
                success:(void(^)(NSDictionary *dict,ZCMessageSendCode sendCode)) successBlock
                      fail:(void(^)(NSString * errorMsg,ZCMessageSendCode errorCode)) failBlock;

/// 自定义标签点击次数
/// @param config 初始化对象
/// @param menuId 当前id
/// @param startBlock 开始
/// @param successBlock 成功
/// @param failBlock 结束
+(void)uploadLableInfoClick:(ZCLibConfig*)config
                     menuId:(NSString *) menuId
                  start:(void(^)(NSString *url))startBlock
                success:(void(^)(NSDictionary *dict,ZCMessageSendCode sendCode)) successBlock
                       fail:(void(^)(NSString * errorMsg,ZCMessageSendCode errorCode)) failBlock;
/**
 *   获取省市县 接口
 */
+(void)getAddressWithLevel:(int)level
             nextaddressId:(NSString *)addId
                     start:(void (^)(void))startBlock
                   success:(void(^)(NSDictionary *dict,ZCNetWorkCode sendCode)) successBlock
                    failed:(void(^)(NSString *errorMessage,ZCNetWorkCode errorCode)) failedBlock;

/**
 *  获取 询前表单自定义字段数据
 *   @param  uid   用户id
 *   @param  startBlock     开始请求的回调
 *   @param  successBlock   请求成功的回调
 *   @param  failedBlock    请求失败的回调
 **/
+(void)getAskTabelWithUid:(NSString *)uid
                        start:(void (^)(void))startBlock
                      success:(void(^)(NSDictionary *dict,ZCNetWorkCode sendCode)) successBlock
                       failed:(void(^)(NSString *errorMessage,ZCNetWorkCode errorCode)) failedBlock;


/// 新版询前表单
/// @param uid 用户ID
/// @param cid 会话ID
/// @param companyId 公司ID
/// @param schemeId 询前表单方案ID
/// @param language 多语言
/// @param startBlock startBlock description
/// @param successBlock successBlock description
/// @param failedBlock failedBlock description
+(void)postAskTableWithUid:(NSString *)uid
                       cid:(NSString *)cid
                 companyId:(NSString *)companyId
                  schemeId:(NSString *)schemeId
                  language:(NSString *)language
                     start:(void (^)(void))startBlock
                   success:(void(^)(NSDictionary *dict,ZCNetWorkCode sendCode)) successBlock
                    failed:(void(^)(NSString *errorMessage,ZCNetWorkCode errorCode)) failedBlock;

#pragma mark 继续排队
//新接口继续排队按钮点击
+(void)continueWaiting:(ZCLibConfig *) config
             start:(void (^)(NSString *url))startBlock
           success:(void(^)(NSDictionary *dict,ZCNetWorkCode sendCode)) successBlock
                failed:(void(^)(NSString *errorMessage,ZCNetWorkCode errorCode)) failedBlock;

+(void)authSendMessageSensitive:(ZCLibConfig *) config
                type:(NSInteger) type
             start:(void (^)(NSString * url))startBlock
           success:(void(^)(NSDictionary *dict,ZCNetWorkCode sendCode)) successBlock
                         failed:(void(^)(NSString *errorMessage,ZCNetWorkCode errorCode)) failedBlock;

#pragma mark 退出
+(void)loginOutPush:(void (^)(NSString *, NSString *,NSError *))resultBlock;
+(void)logOut:(ZCLibConfig *)config;


/// 查询热点问题引导语
/// @param _config <#_config description#>
/// @param params <#params description#>
/// @param startBlock <#startBlock description#>
/// @param successBlock <#successBlock description#>
/// @param failBlock <#failBlock description#>
+(void)getHotGuide:(ZCLibConfig *) _config
              Parms:(NSMutableDictionary *) params
              start:(void(^)(NSString *url )) startBlock
            success:(void(^)(SobotChatMessage *message,ZCMessageSendCode sendCode)) successBlock
              fail:(void(^)(SobotChatMessage *message,ZCMessageSendCode errorCode)) failBlock;


/// 常见问题引导语
/// @param _config 初始化返回
/// @param sessionPhase 会话阶段：1-会话开始，2-机器人会话开始，3-人工会话开始
/// @param startBlock <#startBlock description#>
/// @param successBlock <#successBlock description#>
/// @param failBlock <#failBlock description#>
+(void)getRobotGuide:(ZCLibConfig *)_config
        sessionPhase:(int )sessionPhase
               start:(void (^)(NSString *url))startBlock
             success:(void (^)(SobotChatMessage *msg, ZCMessageSendCode))successBlock
                fail:(void (^)(SobotChatMessage *msg, ZCMessageSendCode))failBlock;


/// 查询用户是否有新留言回复
/// @param config <#config description#>
/// @param startBlock <#startBlock description#>
/// @param successBlock <#successBlock description#>
/// @param failedBlock <#failedBlock description#>
+(void)checkUserTicketInfoWith:(ZCLibConfig*)config
                             start:(void (^)(NSString *url))startBlock
                           success:(void(^)(NSDictionary *dict,ZCNetWorkCode sendCode)) successBlock
                        failed:(void(^)(NSString *errorMessage,ZCNetWorkCode errorCode)) failedBlock;

/// 发送消息
/// @param sendParams 消息参数
/// @param msgType 当前发送消息类型
/// @param config 当前初始化对象
/// @param startBlock 开始
/// @param successBlock 成功
/// @param progressBlock 上传进度
/// @param failBlock 失败
+(void)sendMessage:(ZCLibSendMessageParams *)sendParams
           msgType:(SobotMessageType )msgType
            config:(ZCLibConfig *)config
             start:(void (^)(SobotChatMessage *message))startBlock
           success:(void (^)(SobotChatMessage *message, ZCNetWorkCode code))successBlock
          progress:(void (^)(SobotChatMessage *message))progressBlock
              fail:(void (^)(SobotChatMessage *message,NSString *errorMsg, ZCNetWorkCode code))failBlock;


/// 机器人评价
/// @param config 获取uid、cid、robotFlag
/// @param commentMessage 获取 docId 词条ID，docName 词条名称
/// @param status 反馈结果-顶/踩 1 顶 0 踩
/// @param startBlock 开始
/// @param successBlock 成功
/// @param failBlock 失败
+(void)rbAnswerComment:(ZCLibConfig *)config message:(SobotChatMessage *)commentMessage status:(int)status start:(void (^)(NSString *url))startBlock success:(void (^)(ZCNetWorkCode))successBlock fail:(void (^)(ZCNetWorkCode))failBlock;




/// 多伦触发留言节点，点击关闭和提交留言修改添加提醒消息
/// @param config 初始化对象
/// @param title 无用
/// @param msg 实际内容，iOS不适用
/// @param updateStatus (0表示插入 1表示更新)
/// @param msgId 消息id
/// @param deployId 留言模板id
/// @param startBlock 开始
/// @param successBlock 成功
/// @param failedBlock 失败
+(void)sendLoopTipActionMsg:(ZCLibConfig *) config
                title:(NSString*)title
                msg:(NSString*)msg
               updateStatus:(int) updateStatus // 0表示插入 1表示更新
                      msgId:(NSString *) msgId
                   deployId:(NSString *) deployId
             start:(void (^)(void))startBlock
           success:(void(^)(NSDictionary *dict,ZCNetWorkCode sendCode)) successBlock
                     failed:(void(^)(NSString *errorMessage,ZCNetWorkCode errorCode)) failedBlock;

/**
 *
 *   sdk保存发给用户的系统消息 (机器人点踩，触发转人工提示语 并发送给服务端保存)
 *
 **/
+(void)insertSysMsg:(ZCLibConfig *) config
                title:(NSString*)title
                msg:(NSString*)msg
             start:(void (^)(NSString *url))startBlock
           success:(void(^)(NSDictionary *dict,ZCNetWorkCode sendCode)) successBlock
             failed:(void(^)(NSString *errorMessage,ZCNetWorkCode errorCode)) failedBlock;



/// 标记用户消息，是否已读
/// - Parameters:
///   - config: 当前会话
///   - msgIdArr: 要标记的msgId
///   - startBlock: 开始
///   - successBlock: 成功
///   - failedBlock: 失败
+(void)realMarkReadToAdmin:(ZCLibConfig *) config
                msgId:(NSMutableArray *)msgIdArr
             start:(void (^)(NSString *url))startBlock
           success:(void(^)(NSDictionary *dict,ZCNetWorkCode sendCode)) successBlock
                    failed:(void(^)(NSString *errorMessage,ZCNetWorkCode errorCode)) failedBlock;
    
/// 点击卡片自定义按钮事件
/// @param menu 按钮对象
/// @param config 当前初始化结果对象
/// @param successBlock 成功
/// @param failedBlock 失败
+(void)addCusCardMenuClick:(SobotChatCustomCardMenu *)menu
            config:(ZCLibConfig *)config
           success:(void (^)(ZCNetWorkCode code))successBlock
                      fail:(void (^)(NSString *errorMsg, ZCNetWorkCode code))failedBlock;

/// 正在输入接口
/// @param content 内容
/// @param config 初始化对象
/// @param successBlock 成功
/// @param failedBlock 失败
+(void)sendInputMessage:(NSString *)content
            config:(ZCLibConfig *)config
           success:(void (^)(ZCNetWorkCode code))successBlock
                   fail:(void (^)(NSString *errorMsg, ZCNetWorkCode code))failedBlock;

/// 查询cids
/// @param time 历史记录时间范围，单位分钟(例:100-表示从现在起前100分钟的会话)
/// @param uid 当前初始化用户uid
/// @param startBlock 开始
/// @param successBlock 成功
/// @param failedBlock 失败
+(void)getChatUserCids:(int)time
                   uid:(NSString *)uid
                 start:(void (^)(NSString *url, NSDictionary *paramters))startBlock
               success:(void (^)(NSDictionary *dict, ZCNetWorkCode))successBlock
                failed:(void (^)(NSString *errormsg, ZCNetWorkCode))failedBlock;


/// 根据cid查询聊天记录
/// @param cid cid
/// @param uid uid
/// @param startBlock 开始
/// @param successBlock 成功
/// @param failedBlock 失败
+(void)getHistoryMessages:(NSString *)cid
                  withUid:(NSString *) uid
                 currtCid:(NSString *)currtCid
                    start:(void (^)(NSString *url, NSDictionary *parameters))startBlock
                  success:(void (^)(NSMutableArray *messages, ZCNetWorkCode))successBlock
                   failed:(void (^)(NSString *errormsg, ZCNetWorkCode))failedBlock;



/// 查询电商版本会话记录
/// @param partnerid 用户id
/// @param startBlock 开始
/// @param successBlock 成功
/// @param failedBlock 失败
+(void)getPlatformMemberNews:(NSString *)partnerid
                       start:(void (^)(NSString *url))startBlock
                     success:(void (^)(NSMutableArray *arr,NSDictionary *item, ZCNetWorkCode))successBlock
                      failed:(void (^)(NSString *errorMsg, ZCNetWorkCode code))failedBlock;



/// 删除会话记录
/// @param listId 记录id
/// @param startBlock 开始
/// @param successBlock 成功
/// @param failedBlock 结束
+(void)delPlatformMemberByUser:(NSString *)listId
                         start:(void (^)(NSString *url))startBlock
                       success:(void (^)(NSDictionary *dict, ZCNetWorkCode code))successBlock
                        failed:(void (^)(NSString *errorMessage, ZCNetWorkCode code))failedBlock;

/**
     获取 分词联想接口
      @param config 初始化信息  用户uid
      @param params   机器人编号  问题
      @param startBlock 开始
      @param successBlock 成功
      @param failBlock 失败

 **/
+(void)getrobotGuess:(ZCLibConfig *)config
               Parms:(NSMutableDictionary *) params
               start:(void(^)(SobotChatMessage *message)) startBlock
             success:(void(^)(NSDictionary *dict,ZCMessageSendCode sendCode)) successBlock
                fail:(void(^)(NSString *errorMsg,ZCMessageSendCode errorCode)) failBlock;

/**
 *  获取机器人列表接口
 */
+(void)getrobotlist:(ZCLibConfig *)config
               start:(void (^)(void))startBlock
             success:(void(^)(NSDictionary *dict,ZCMessageSendCode sendCode)) successBlock
                fail:(void(^)(NSString *errorMsg,ZCMessageSendCode errorCode)) failBlock;

/**
 *  获取人工客服评价标签
 *  @parma uid 用户id
 *
 */
+ (void)satisfactionMessage:(NSString*) uid
                      start:(void(^)(void))startBlock
                    success:(void(^)(NSDictionary * messageArr,ZCNetWorkCode code)) successBlock
                       fail:(void(^)(NSString* msg, ZCNetWorkCode errorCode)) failedBlock;


/**
 *  获取大模型机器人评价标签
 *  @parma config uid/cid/templeteId/robotFlag
 */
+(void)satisfactionAiAgent:(ZCLibConfig *)config start:(void (^)(void))startBlock success:(void (^)(NSDictionary *, ZCNetWorkCode))successBlock fail:(void (^)(NSString *msg ,ZCNetWorkCode))failedBlock;

/// 查询链接的内容
/// @param url 要查询的url地址
/// @param startBlock 开始
/// @param successBlock 成功
/// @param failedBlock 失败
+(void)getHtmlAnalysisWithURL:(NSString *)url
                        start:(void (^)(NSString *url))startBlock
                      success:(void(^)(NSDictionary *dict,ZCNetWorkCode sendCode)) successBlock
                       failed:(void(^)(NSString *errorMessage,ZCNetWorkCode errorCode)) failedBlock;
    
/**
 *  提交工单评价 （工单详情页面触发评价）
 */
+(void)postAddTicketSatisfactionWith:(NSString*)uid
                                dict:(NSDictionary*)inParam
                               start:(void (^)(void))startBlock
                             success:(void(^)(NSDictionary *dict,ZCNetWorkCode sendCode)) successBlock
                              failed:(void(^)(NSString *errorMessage,ZCNetWorkCode errorCode)) failedBlock;

/**
 *  评价客户
 *
 *  @param params 参数说明
 cid 会话编号
 isresolve 是否解决问题，1是没有解决，0解决
 problem = 问题编号，没有传空 机器人：答非所问1 理解能力差2 问题不能回答3 不礼貌4  人工： 服务态度差,5  回答不及时,6 没解决问题,7 不礼貌,8
 source 分数（✨）
 suggest 描述
 type   0评价机器人，1评价人工
 userId 用户uid
 */
+(void)doComment:(NSMutableDictionary *) params result:(void (^)(ZCNetWorkCode code,int status,NSString *msg))resultBlock;



/**
 评价大模型机器人
 cid
 aiAgentCid
 robotFlag
 uid
 sourceEnum APP
 scoreFlag
 score
 labelIds array[string] 标签
 remark
 commentType评价类型， 0-邀请评价，1-主动评价

 solved 是否解决 0：未解决，1：已解决，-1：未选择

 scoreExplain 星级说明
 currentTime 当前时间
 companyId
 */
+(void)doCommentAiAgent:(NSMutableDictionary *)params result:(void (^)(ZCNetWorkCode, int, NSString *))resultBlock;



/**
 大模型机器人是否已经评价过
 */
+(void)isCommentAiAgent:(ZCLibConfig *)config result:(void (^)(ZCNetWorkCode, int, NSString *))resultBlock;


/**
 *  清空历史消息
 *  @param uid 用户id
 */
+(void)cleanHistoryMessage:(NSString *) uid
                   success:(void(^)(NSData *data)) successBlock
                      fail:(void(^)(ZCNetWorkCode errorCode)) failBlock;


/**
 * 留言转离线消息接口
 * uid ：用户id
 * content： 留言内容
 * msgType: 当是文件类型消息时，content为网络url
 * groupId : 技能组ID
 **/
+(void)getLeaveMsgWith:(NSString*)uid
               Content:(NSString *)content
               msgType:(SobotMessageType) msgType
               groupId:(NSString *)groupId
                 start:(void (^)(void))startBlock
               success:(void(^)(NSDictionary *dict,ZCNetWorkCode sendCode)) successBlock
                failed:(void(^)(NSString *errorMessage,ZCNetWorkCode errorCode)) failedBlock;

/**
 *  获取帮助中心分类列表数据 2.7.4 新增
 *  appid ：appkey
 *
 **/
+(void)getCategoryWith:(NSString*)appId
                             start:(void (^)(void))startBlock
                           success:(void(^)(NSDictionary *dict,ZCNetWorkCode sendCode)) successBlock
                            failed:(void(^)(NSString *errorMessage,ZCNetWorkCode errorCode)) failedBlock;


/**
 * 帮助中心  根据分类查询分类下的问题
 * appid ：appkey
 * categoryId： 分类id
 **/
+(void)getHelpDocByCategoryIdWith:(NSString*)appId
            CategoryId:(NSString *)categoryId
                 start:(void (^)(void))startBlock
               success:(void(^)(NSDictionary *dict,ZCNetWorkCode sendCode)) successBlock
                failed:(void(^)(NSString *errorMessage,ZCNetWorkCode errorCode)) failedBlock;

/**
 * 帮助中心  根据词条id查询词条详情
 * appid ：appkey
 * docId： 词条id
 **/
+(void)getHelpDocByDocIdWith:(NSString*)appId
                       DocId:(NSString *)docId
                       start:(void (^)(void))startBlock
                     success:(void(^)(NSDictionary *dict,ZCNetWorkCode sendCode)) successBlock
                      failed:(void(^)(NSString *errorMessage,ZCNetWorkCode errorCode)) failedBlock;

/**
 *  获取留言转离线消息配置接口
 *
 *  @param successBlock         请求成功 返回  msgLeaveTxt、 msgLeaveContentTxt参数值
 *  @param errorBlock           请求失败，返回失败状态
 */
+(void)initLeaveMsgConfig:(NSString *)groupId
                       uid:(NSString *)uid
                     error:(void (^)(ZCNetWorkCode status,NSString *errorMessage))errorBlock
                   success:(void(^)(NSString *msgLeaveTxt,NSString *msgLeaveContentTxt,NSString *leaveExplain)) successBlock;



/// 延迟转人工排队时调用
/// @param content 发送内容
/// @param msgType 消息类型，当是图片，音频，视频，文件时，content为网络路径
/// @param config 当前初始化对象
/// @param errorBlock 失败
/// @param successBlock 成功
+ (void)sendAfterModeWithConnectWait:(NSString *)content msgType:(SobotMessageType) msgType
                       uid:(ZCLibConfig *)config
                     error:(void (^)(ZCNetWorkCode status,NSString *errorMessage))errorBlock
                             success:(void(^)(NSString *msgLeaveTxt,NSString *msgLeaveContentTxt,NSString *leaveExplain)) successBlock;




/// 查询是否可以发送自定义卡片
/// - Parameters:
///   - cardId: 卡片ID 唯一键
///   - cid: 当前会话ID
///   - startBlock: 开始
///   - successBlock: 成功
///   - failedBlock: 失败
+(void)checkCardSendRepeat:(NSString *) cardId
                cid:(NSString *)cid
             start:(void (^)(NSString *url))startBlock
           success:(void(^)(NSDictionary *dict,ZCNetWorkCode sendCode)) successBlock
                    failed:(void(^)(NSString *errorMessage,ZCNetWorkCode errorCode)) failedBlock;


/// 查询机器人点踩配置信息
/// @param uid 用户ID
/// @param robotFlag 机器人ID
/// @param startBlock startBlock description
/// @param successBlock successBlock description
/// @param failedBlock failedBlock description
+(void)getRobotRealuateConfigInfo:(NSString *)uid
                        robotFlag:(NSString *)robotFlag
                            start:(void (^)(NSString *url))startBlock
                          success:(void(^)(NSDictionary *dict,ZCNetWorkCode sendCode)) successBlock
                           failed:(void(^)(NSString *errorMessage,ZCNetWorkCode errorCode)) failedBlock;


/// 对点踩信息追加系统消息 或追加标签点踩原因
/// @param param 入参
/// @param startBlock startBlock description
/// @param successBlock successBlock description
/// @param failedBlock failedBlock description
+(void)postRobotOperation:(NSDictionary *)param
                    start:(void (^)(NSString *url))startBlock
                  success:(void(^)(NSDictionary *dict,ZCNetWorkCode sendCode)) successBlock
                   failed:(void(^)(NSString *errorMessage,ZCNetWorkCode errorCode)) failedBlock;



+(void)getLeaveRegionList:(NSString *) pid
                    start:(void(^)(NSString *urlString)) startBlock
                          success:(void(^)(NSDictionary *dict,ZCNetWorkCode sendCode))successBlock
                           failed:(void(^)(NSString *errorMessage,ZCNetWorkCode errorCode))failedBlock
                   finish:(void(^)(id response, NSData *data)) finishBlock;


/// 搜索地区
+(void)searchLeaveRegion:(NSString *)queryParam
           regionalLevel:(int )regionalLevel
                page:(int )pageNo
                         start:(void(^)(NSString *urlString)) startBlock
                       success:(void(^)(NSDictionary *dict,ZCNetWorkCode sendCode))successBlock
                        failed:(void(^)(NSString *errorMessage,ZCNetWorkCode errorCode))failedBlock
                  finish:(void(^)(NSString *jsonString)) finishBlock;



/// 查询访客配置信息
/// - Parameters:
///   - app_key: app_key description
///   - partnerid: partnerid description
///   - startBlock: startBlock description
///   - successBlock: successBlock description
///   - failedBlock: failedBlock description
///   - finishBlock: finishBlock description
+(void)getVisitorHelpConfig:(NSString *)app_key
          partnerId:(NSString *)partnerid
                        start:(void(^)(NSString *urlString)) startBlock
                      success:(void(^)(NSDictionary *dict,ZCNetWorkCode sendCode))successBlock
                       failed:(void(^)(NSString *errorMessage,ZCNetWorkCode errorCode))failedBlock
                     finish:(void(^)(NSString *jsonString)) finishBlock;




/// 回调前台，检测当前用户是否已经离线
/// - Parameters:
///   - config: 当前正在会话的初始化配置
///   - startBlock: 开始
///   - successBlock: 成功
///   - failedBlock: 失败
///   - finishBlock: 结束(本接口关注此回调即可)
+(void)checkUserOnlineStatus:(ZCLibConfig *)config
                        start:(void(^)(NSString *urlString)) startBlock
                      success:(void(^)(NSDictionary *dict,ZCNetWorkCode sendCode))successBlock
                       failed:(void(^)(NSString *errorMessage,ZCNetWorkCode errorCode))failedBlock
                      finish:(void(^)(NSString *jsonString)) finishBlock;


/// 获取多语言切换列表数据
/// - Parameters:
///   - config: 初始化配置
///   - startBlock: startBlock description
///   - successBlock: successBlock description
///   - failedBlock: failedBlock description
///   - finishBlock: finishBlock description
+(void)getLanguageList:(ZCLibConfig *)config
                        start:(void(^)(NSString *urlString)) startBlock
                      success:(void(^)(NSDictionary *dict,ZCNetWorkCode sendCode))successBlock
                       failed:(void(^)(NSString *errorMessage,ZCNetWorkCode errorCode))failedBlock
                      finish:(void(^)(NSString *jsonString)) finishBlock;


/// 切换语言之后重新获取初始化配置数据
/// - Parameters:
///   - language: 切换选中的语言
///   - uid: 用户ID
///   - startBlock: startBlock description
///   - successBlock: successBlock description
///   - failedBlock: failedBlock description
///   - finishBlock: finishBlock description
+(void)sendToAdminChooseLan:(NSString*)language
                        uid:(NSString *)uid
                        start:(void(^)(NSString *urlString)) startBlock
                      success:(void(^)(NSDictionary *dict,ZCNetWorkCode sendCode))successBlock
                       failed:(void(^)(NSString *errorMessage,ZCNetWorkCode errorCode))failedBlock
                      finish:(void(^)(NSString *jsonString)) finishBlock;


/// 新版询前表单
/// @param uid  访客Id
/// @param cid 会话Id
/// @param schemeId 询前表单方案Id
/// @param formData array[object (SubmitFormDataReqVo) {7}]
/// @param startBlock startBlock description
/// @param successBlock successBlock description
/// @param failedBlock failedBlock description
+(void)postNewAskTabelWithUid:(NSString *)uid
                          cid:(NSString *)cid
                     schemeId:(NSString*)schemeId
                     formData:(NSMutableArray *)formData
                     canvasId:(NSString *)canvasId
                        start:(void (^)(void))startBlock
                      success:(void(^)(NSDictionary *dict,ZCNetWorkCode sendCode)) successBlock
                       failed:(void(^)(NSString *errorMessage,ZCNetWorkCode errorCode)) failedBlock;




/// 工单状态列表，用于展示自定义工单状态
/// @param config 初始化对象，用户获取companyId
/// @param startBlock 开始
/// @param successBlock successBlock description
/// @param failedBlock failedBlock description
/// @param finishBlock finishBlock description
+(void)getOrderStatusList:(ZCLibConfig *)config
                        start:(void(^)(NSString *urlString)) startBlock
                      success:(void(^)(NSDictionary *dict,ZCNetWorkCode sendCode))successBlock
                       failed:(void(^)(NSString *errorMessage,ZCNetWorkCode errorCode))failedBlock
                   finish:(void(^)(NSString *jsonString)) finishBlock;


/// 查询大模型机器人点踩配置信息
/// @param companyId 企业ID
/// @param robotFlag 机器人ID
/// @param startBlock startBlock description
/// @param successBlock successBlock description
/// @param failedBlock failedBlock description
+(void)getAiRobotRealuateConfigInfo:(NSString *)companyId
                        robotFlag:(NSString *)robotFlag
                             config:(ZCLibConfig *)config
                            start:(void (^)(NSString *url))startBlock
                          success:(void(^)(NSDictionary *dict,ZCNetWorkCode sendCode)) successBlock
                           failed:(void(^)(NSString *errorMessage,ZCNetWorkCode errorCode)) failedBlock;


/// 大模型机器人点踩收集提交接口
/// @param param 入参
/// @param startBlock startBlock description
/// @param successBlock successBlock description
/// @param failedBlock failedBlock description
+(void)postAiAgentRobotAnswerComment:(NSDictionary *)param
                    start:(void (^)(NSString *url))startBlock
                  success:(void(^)(NSDictionary *dict,ZCNetWorkCode sendCode)) successBlock
                              failed:(void(^)(NSString *errorMessage,ZCNetWorkCode errorCode)) failedBlock;
@end

NS_ASSUME_NONNULL_END
