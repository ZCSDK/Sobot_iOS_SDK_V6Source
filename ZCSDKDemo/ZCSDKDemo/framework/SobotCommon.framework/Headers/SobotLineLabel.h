//
//  SobotLineLabel.h
//  SobotChatClientSDKTest
//
//  Created by zhangxy on 2025/3/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SobotLineLabel : UILabel
// 行高属性
@property (nonatomic, assign) CGFloat lineHeight;

// 计算基线偏移量，不设置默认2
// 除以 4 是一个经验值，适用于大多数情况。如果文本仍然没有对齐，可以尝试调整除数（例如除以 2 或 3）。
@property (nonatomic, assign) CGFloat baselineMultiplier;


// 设置文本并应用行高
- (void)setText:(NSString *)text withLineHeight:(CGFloat)lineHeight;

@end

NS_ASSUME_NONNULL_END
