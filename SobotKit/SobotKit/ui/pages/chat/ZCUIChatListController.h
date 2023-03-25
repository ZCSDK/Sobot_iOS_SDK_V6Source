//
//  ZCUIChatListController.h
//  SobotKit
//
//  Created by zhangxy on 2022/9/29.
//

#import <SobotKit/SobotKit.h>
#import <SobotChatClient/SobotChatClient.h>
#import "ZCKitInfo.h"

@interface ZCUIChatListController : SobotClientBaseController

@property(nonatomic,strong) ZCKitInfo *kitInfo;

@property(nonatomic,strong) void (^OnItemClickBlock)(ZCUIChatListController *vc,ZCPlatformInfo *object);

@property (nonatomic,strong) UIViewController * byController; // 记录启动页面的导航状态


@end
