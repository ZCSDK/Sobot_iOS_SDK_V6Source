//
//  SobotButtonUpDown.h
//  SobotCommon
//
//  Created by zhangxy on 2022/7/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SobotButtonUpDown : UIButton

// 1 图片在下，2 图片在上，
@property (nonatomic,assign) int type;
@property (nonatomic,assign) CGFloat imgW;
@property (nonatomic,assign) CGFloat imgH;

@property (nonatomic,assign) CGFloat space; // 图片和文字间距
@property (nonatomic,assign) CGFloat outSpace; // 图片和文字外边界
@end

NS_ASSUME_NONNULL_END
