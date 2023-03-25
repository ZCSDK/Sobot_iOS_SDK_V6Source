//
//  SobotVoiceTools.h
//  SobotOnline
//
//  Created by zhangxy on 2020/9/2.
//  Copyright © 2020 sobot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,SobotAudioSessionCategory) {
    SobotAudioSessionCategoryPlayback = 0, // 扬声器
    SobotAudioSessionCategoryRecord = 1,   // 听筒
};

@interface SobotVoiceTools : NSObject

/**
 *  单例
 *
 *  @return SobotVoiceTools创建的对象
 */
+(SobotVoiceTools *)shareSobotVoiceTools;

/**
 *  播放声音
 *
 *  @param fileUrl     当前点击的model
 *  @param imageView 动画的view
 */
-(void)startWithModel:(NSString *)fileUrl view:(UIImageView *)imageView category:(SobotAudioSessionCategory)  category;


- (void)sotpPlayVoide;

@end

NS_ASSUME_NONNULL_END
