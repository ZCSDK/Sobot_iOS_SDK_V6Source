//
//  ZCChatController.h
//  SobotChatClient
//
//  Created by zhangxy on 2022/8/30.
//

#import <SobotKit/SobotClientBaseController.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZCChatControllerDelegate <NSObject>

@optional
/**
 点击留言跳转到用户自己留言页面，SDK将不在处理留言
 @param tipMsg 提示语
 */
-(void)openLeaveMsgClick:(NSString*)tipMsg;

@end


@interface ZCChatController : SobotClientBaseController

// 留言代理
@property (nonatomic,assign) id<ZCChatControllerDelegate> chatdelegate;

@end

NS_ASSUME_NONNULL_END
