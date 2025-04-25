//
//  ZCLibMessageConstants.h
//  ZCLibLib
//
//  Created by zhangxy on 15/10/22.
//  Copyright © 2015年 ZCLib. All rights reserved.
//

#import <SobotCommon/SobotCommon.h>

#define SobotReceiveNewMessage @"SobotReceiveNewMessage"
#define SobotTcpConnectedChanged @"SobotTcpConnectedChanged"
#define SobotAiagentAsking @"SobotAiagentAsking"
#define SobotAiagentAskEnd @"SobotAiagentAskEnd"
/**
 *  @enum 智齿连接业务状态码
 */
typedef NS_ENUM(NSInteger, ZCConnectStatusCode) {
    /**
     *  连接失败。
     */
    ZCConnectStatusCode_FAIL = -1,
    /**
     *  本地调用传入参数错误。
     */
    ZCConnectStatusCode_INVALID_ARGUMENT = -1000,
    /**
     *  其它地方登陆了
     */
    ZCConnectStatusCode_OFFLINE_BY_OTHER_CLIENT = 6,
    /**
     *  链接人工成功
     */
    ZCConnectStatusCode_SUCCESS = 200,
    
    
    /**
     *  连接中
     */
    ZCConnectStatusCode_START = 201,
};


/**
 *  @enum 智齿连接业务状态码
 */
typedef NS_ENUM(NSInteger, ZCConnectUserStatusCode) {
    
    /** * 人工服务连接失败，已重新连接。 */
    ZCConnectUserServerFailed = -1,
    
    /** * 连接失败, 排队中。 */
    ZCConnectUserOfWaiting = 0,

    /** * 连接成功。 */
    ZCConnectUserSuccess = 1,
    
    /** * 没有客服在线。 */
    ZCConnectUserNoAdmin = 2,
    
    /** * 用户被拉黑 */
    ZCConnectUserBeBlock = 3,
    
    /** * 用户已经转人工无需再次请求 */
    ZCConnectUserBeConnected = 4,
    
    // 机器人超时下线，转人工
    ZCConnectUserRobotTimeout = 5,
    
    //如果设置指定客服的id。并且设置不是必须转入，服务器返回status=6.这个时候要设置receptionistId为null
        //为null以后继续转人工逻辑。如果技能组开启就弹技能组，如果技能组没有开启，就直接转人工
    ZCConnectUserNextTry = 6,
    
    /**  排队达到阀值 */
    ZCConnectUserWaitingThreshold = 7
    
};

/**下推消息类型*/
typedef NS_ENUM(NSInteger,ZCReceivedMessageType) {
    ZCReceivedMessageUnKonw         = -1,// 未知类型
    ZCReceiVedMessageNotice         = -2,// 通告不置顶
    ZCReceivedMessageLeaveMessage   = -3,// 留言回显信息
    ZCReceiVedMessageDefault        = 0, // 普通消息
    ZCReceivedMessageNews           = 202,// 新消息
    ZCReceivedMessageOnline         = 200,// 接入人工成功
    ZCReceivedMessageWaiting        = 201,// 排队
    ZCReceivedMessageTansfer        = 210,// 转接
    ZCReceivedMessageChatLock       = 213,// 会话锁定
    ZCReceivedMessageChatWarning    = 215,// 诈骗词告警
    ZCReceivedMessageChatReadMsg    = 217,// 客服已读消息
    ZCReceivedMessageChatAdminTipWord    = 2151,// 排队离线提醒
    ZCReceivedMessageChatWartingOutTips    = 2155,// 排队离线提醒
    ZCReceivedMessageOfflineUnknown = 2040,// 未识别原因下线
    ZCReceivedMessageOfflineByAdmin = 2041,// 管理员下线
    ZCReceivedMessageOfflineByClose = 2042,// 管理员移除用户
    ZCReceivedMessageOfflineBeBlack = 2043,// 被拉入黑名单，不重新接入
    ZCReceivedMessageOfflineToLong  = 2044,// 长时间未说话,2049用户被下线
    ZCReceivedMessageOfflineToWaiting  = 2049,// 排队超时离线
    ZCReceivedMessageToNewWindow    = 2046,// 打开新窗口
    ZCReceivedMessageConfirm        = 301,// 消息确认
    ZCReceivedMessageEvaluation     = 209,// 客服主动推送评价
    ZCReceivedMessageEvaluationByClose     = 2099,// 客服主动推送评价
    ZCReceivedMessageRevertMsg      = 211,// 消息撤回
    ZCReceivedMessageLockType_1      = 2131,// 会话锁定
    ZCReceivedMessageLockType_2      = 2132,// 会话解锁
    ZCReceivedMessageTransferTips     = 301,// 转接提示语
    /**
     * 用户排队超时离线提醒,继续排队
     */
    ZCReceivedMessageWaitingContinueTips = 101,
    ZCReceivedMessageWaitingContinueMsg = 102
};


typedef void(^onZCConnectBlock)(ZCConnectStatusCode code);

typedef void(^onZCReceiveMessageBlock)(SobotChatMessage *message,int num,id obj);

@protocol ZCReceiveMessageDelegate <NSObject>

/**
 *  消息接收
 *
 *  @param message 下发消息
 *  @param num     未读消息，暂时未使用
 *  @param obj     预留对象
 */
-(void)onReceivedMessage:(SobotChatMessage *) message unReaded:(int) num object:(id)obj showType:(ZCReceivedMessageType) type;

/**
 *  连接状态变化
 *
 *  @param status 智齿连接业务状态码
 */
-(void)onConnectStatusChanged:(ZCConnectStatusCode) status;

@end
