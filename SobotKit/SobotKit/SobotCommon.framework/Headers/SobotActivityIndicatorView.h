//
//  SobotActivityIndicatorView.h
//  SobotCommon
//
//  Created by zhangxy on 2025/3/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SobotActivityIndicatorView : UIImageView

// 启动动画
- (void)startLoadingAnimation;

// 停止动画
- (void)stopLoadingAnimation;

@end

NS_ASSUME_NONNULL_END
