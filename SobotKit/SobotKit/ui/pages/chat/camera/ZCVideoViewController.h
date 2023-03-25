//
//  ZCVideoViewController.h
//  SobotKit
//
//  Created by zhangxy on 2018/11/30.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import <SobotKit/SobotClientBaseController.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZCVideoViewController : SobotClientBaseController

@property (copy, nonatomic) void (^operationResultBlock)(id item);

@end

NS_ASSUME_NONNULL_END
