//
//  SobotPHPickerPreviewController.h
//  SobotCommon
//
//  Created by zhangxy on 2024/2/21.
//

#import <SobotCommon/SobotCommon.h>
#import "SobotPHPickerTools.h"

NS_ASSUME_NONNULL_BEGIN



/// 图片预览
@interface SobotPHPickerPreviewController : SobotBaseController

// 下标从1开始
@property (assign, nonatomic) NSInteger curIndex;
@property (assign, nonatomic) BOOL isPreView;

@property (assign, nonatomic) NSMutableArray *allData;


@end

NS_ASSUME_NONNULL_END
