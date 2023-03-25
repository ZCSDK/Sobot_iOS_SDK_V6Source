//
//  ZCMsgDetailsVC.h
//  SobotKit
//
//  Created by lizh on 2022/9/7.
//

#import <SobotKit/SobotKit.h>
#import "ZCLeaveMsgController.h"
#import <SobotChatClient/SobotChatClient.h>
NS_ASSUME_NONNULL_BEGIN

@interface ZCMsgDetailsVC : SobotClientBaseController
@property (nonatomic,copy) NSString *ticketId; // 工单id
@property (nonatomic,copy) NSString *companyId; // 工单id
@property (nonatomic,strong) ZCLeaveMsgController *leaveMsgController;
@end

NS_ASSUME_NONNULL_END
