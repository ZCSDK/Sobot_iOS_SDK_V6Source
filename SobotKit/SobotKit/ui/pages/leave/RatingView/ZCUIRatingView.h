//
//  RatingViewController.h
//  RatingController
//
//  Created by Ajay on 2/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  RatingViewDelegate 
 */
@protocol RatingViewDelegate<NSObject>

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

/**
 *  评级打分页面
 */
@interface ZCUIRatingView : UIView {
    /**
     *  unselectedImage     没有选择时的图片
     *  partlySelectedImage 部分选择时的图片
     *  fullySelectedImage  全部选择时的图片
     */
	UIImage *unselectedImage, *partlySelectedImage, *fullySelectedImage;
    
    /**
     *  代理
     */
	id<RatingViewDelegate> viewDelegate;

	float starRating, lastRating;
	float height, width; // of each image of the star!
}

// 存储星星或分数
@property (nonatomic, strong) NSMutableArray *starView;

/**
 *  设置图片
 *
 *  @param unselectedImage     没有选择时的图片
 *  @param partlySelectedImage 部分选择时的图片
 *  @param fullSelectedImage   全部选择时的图片
 *  @param d                   代理
 */
-(void)setImagesDeselected:(NSString *)unselectedImage partlySelected:(NSString *)partlySelectedImage 
			  fullSelected:(NSString *)fullSelectedImage andDelegate:(id<RatingViewDelegate>)d;
-(void)setImagesDeselected:(NSString *)unselectedImage partlySelected:(NSString *)partlySelectedImage
              fullSelected:(NSString *)fullSelectedImage count:(int) count  andDelegate:(id<RatingViewDelegate>)d;

/**
 *  显示等级
 *
 *  @param rating  等级
 */
-(void)displayRating:(float)rating;

/**
 *  等级
 *
 *  @return 评级等级
 */
-(float)rating;

@end
