//
//  ZCVideoPlayer.h
//  SobotKit
//
//  Created by zhangxy on 2018/11/30.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SobotVideoPlayer : UIView

@property(nonatomic,assign) BOOL autoRepeatPlay;

@property(nonatomic,copy) NSString *bundleName;//公共组件没有图片资源包的时候，从其他SDK资源包获取，不传默认取common中的图片

//@property(nonatomic,copy) NSString *bundleName;// 公共组件没有图片资源包的时候 从其他SDK资源包获取，不传默认取common中的图片

- (instancetype)initWithFrame:(CGRect)frame withShowInView:(UIView *)bgView url:(NSURL *)url Image:(UIImage *)image;

@property (copy, nonatomic) NSURL *videoUrl;

- (void)stopPlayer;

-(void)showControlsView;

@end

NS_ASSUME_NONNULL_END
