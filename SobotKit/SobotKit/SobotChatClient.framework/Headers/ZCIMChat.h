//
//  ZCIMChat.h
//  SobotChatClient
//
//  Created by zhangxy on 2022/8/31.
//

#import <Foundation/Foundation.h>
#import <SobotChatClient/SobotMessageDefines.h>
#import "ZCLibConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZCIMChat : NSObject

/**
 获取连接对象

 @return ZCIMChat
 */
+(ZCIMChat *)getZCIMChat;

// 初始化成功返回的对象
@property(nonatomic,strong) NSMutableArray       *wslinkbak;
// YES 为当前正在聊天页面
@property(nonatomic,assign) BOOL isChatPageActive;

// 接收消息回调
@property(nonatomic,weak) id<ZCReceiveMessageDelegate>  delegate;

-(void)onConnection:(NSString *)ipWithPort;

/**
 *  重新连接
 */
-(void)reConnectioned;

/**
 *  检查如果断开就重新连接
 */
-(void)checkConnected;
    
-(BOOL)isConnected;

/**
 *  关闭
 */
-(void)closeConnection;

/**
 移除所有监听
 */
-(void) removeAllObserver;

/**
 新增所有监听
 */
-(void)checkObserverAndAdd;

-(void)userOfflineByReciveType:(ZCReceivedMessageType ) type from:(BOOL )isServerMessage config:(ZCLibConfig *) _libConfig appkey:(NSString *) appkey;


// 轮训
-(void)startLoopRequest:(BOOL)isOnlyType;
-(void)startLoopRequest:(BOOL)isOnlyType config:(ZCLibConfig *) config;



-(void)setChatPageState:(BOOL) inChatView;
-(int) getUnReadNum;

@end

NS_ASSUME_NONNULL_END
