//
//  SobotMultiBarView.h
//  SobotKit
//
//  Created by zhangxy on 2025/2/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SobotMultiBarView : UIView

// 分贝转换为线性比例
@property (nonatomic, assign) CGFloat amplitude; // 波动幅度
@property (nonatomic, assign) CGFloat frequency; // 波动频率
@property (nonatomic, assign) CGFloat phase;    // 波动相位

@end

NS_ASSUME_NONNULL_END
