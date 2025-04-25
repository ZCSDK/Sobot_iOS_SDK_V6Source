//
//  ZCShadowBorderView.h
//  SobotKit
//
//  Created by zhangxy on 2024/12/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZCShadowBorderView : UIView

// [ZCUIKitTools zcgetNavBackGroundColorWithSize:self.bounds.size];
@property(nonatomic,strong) UIColor *topBgColor;

// [ZCUIKitTools zcgetChatBackgroundColor];
@property(nonatomic,strong) UIColor *contentBgColor;

// 设置阴影的类型，默认 上下左右都有  1 上面不要阴影
@property (nonatomic,assign) int shadowLayerType;
@end

NS_ASSUME_NONNULL_END
