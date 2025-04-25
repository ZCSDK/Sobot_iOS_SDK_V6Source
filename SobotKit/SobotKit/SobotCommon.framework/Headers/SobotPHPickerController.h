//
//  SobotPHPickerController.h
//  SobotCommon
//
//  Created by zhangxy on 2024/2/21.
//

#import <SobotCommon/SobotCommon.h>

NS_ASSUME_NONNULL_BEGIN


/// 选择相册资源页面
@interface SobotPHPickerController : SobotBaseController

// 下标从1开始
@property (assign, nonatomic) BOOL onlyPicker;

@end

NS_ASSUME_NONNULL_END
