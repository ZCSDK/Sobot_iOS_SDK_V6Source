//
//  ZCDocumentLookController.h
//  SobotKit
//
//  Created by zhangxy on 2018/11/9.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import <SobotKit/SobotKit.h>
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClient.h>
NS_ASSUME_NONNULL_BEGIN

@interface ZCDocumentLookController : SobotClientBaseController

@property (nonatomic,strong) SobotChatMessage *message;// 是否是push 进来的

@end

NS_ASSUME_NONNULL_END
