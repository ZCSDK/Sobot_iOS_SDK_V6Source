//
//  SobotRatingView.h
//  SobotKit
//
//  Created by zhangxy on 2023/8/21.
//

#import <UIKit/UIKit.h>
/**
 *  RatingViewDelegate
 */
@protocol SobotRatingViewDelegate<NSObject>

/**
 *  打分改变 代理方法
 *
 *  @param newRating 判断是否给5星好评
 */
-(void)ratingChanged:(float)newRating;


/**
 仅点击变更的值

 @param newRating
 */
@optional
-(void)ratingChangedWithTap:(float)newRating;

@end

NS_ASSUME_NONNULL_BEGIN

@interface SobotRatingView : UIView

// 是否满屏
@property(nonatomic,assign) BOOL isFullWidth;

// 是否左对齐
@property(nonatomic,assign) BOOL alignLeft;

-(void)setImagesDeselected:(NSString *)deselectedImage
              fullSelected:(NSString *)fullSelectedImage
                     count:(int)count showLRTip:(BOOL) isShowLRTip andDelegate:(id<SobotRatingViewDelegate>) delegate;

/**
 *  显示等级
 *
 *  @param rating  等级
 */
-(void)displayRating:(float)rating;


// 不显示任何控件
-(void)clearViews;
-(void)viewOrientationChange;

/**
 *  等级
 *
 *  @return 评级等级
 */
-(float)rating;


@end

NS_ASSUME_NONNULL_END
