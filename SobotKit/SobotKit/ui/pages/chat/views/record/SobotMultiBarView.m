//
//  SobotMultiBarView.m
//  SobotKit
//
//  Created by zhangxy on 2025/2/21.
//

#import "SobotMultiBarView.h"

@implementation SobotMultiBarView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 初始化默认值
        _amplitude = 10.0;
        _frequency = 1.0;
        _phase = 0.0;
    }
    return self;
}

/**
 线条波动
 */
//- (void)drawRect:(CGRect)rect {
//    [super drawRect:rect];
//    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    if (!context) return;
//    
//    CGFloat width = CGRectGetWidth(rect);
//    CGFloat height = CGRectGetHeight(rect);
//    
//    // 设置绘制属性
//    CGContextSetLineWidth(context, 2.0);
//    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
//    
//    // 开始路径
//    CGContextMoveToPoint(context, 0, height / 2);
//    
//    for (CGFloat x = 0; x < width; x++) {
//        CGFloat y = self.amplitude * sin((x / width) * self.frequency * 2 * M_PI + self.phase) + height / 2;
//        CGContextAddLineToPoint(context, x, y);
//    }
//    
//    // 绘制路径
//    CGContextStrokePath(context);
//}

/**
 柱形波动
 */
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) return;
    
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    
    CGFloat barWidth = 6;
    
    // 计算每个柱子的宽度和间距
    CGFloat barNum = width / barWidth;
    
    for (CGFloat x = 0; x < barNum; x++) {
        CGFloat fx = x * barWidth;
        CGFloat y = self.amplitude * sin((fx / width) * self.frequency * 2 * M_PI + self.phase) + height / 2;
        
        // 计算柱子的高度
        CGFloat barHeight = height - fabs(height- y)*2;
        
        // 设置绘制属性
        CGContextSetFillColorWithColor(context, UIColor.blackColor.CGColor);
        
        // 绘制柱状图
        CGRect barRect = CGRectMake(fx, (height - barHeight)/2, barWidth - 4, barHeight);
        CGContextFillRect(context, barRect);
    }
}

@end
