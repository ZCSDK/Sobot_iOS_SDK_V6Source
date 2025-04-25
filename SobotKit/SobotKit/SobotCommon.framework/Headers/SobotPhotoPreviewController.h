//
//  SobotPhotoPreviewController.h
//  SobotCommon
//
//  Created by zhangxy on 2024/6/19.
//

#import <SobotCommon/SobotCommon.h>
#import <SobotCommon/SobotPhotoPreviewCell.h>

NS_ASSUME_NONNULL_BEGIN


/// 用法
// SobotPhotoModel *pm1 = [[SobotPhotoModel alloc] init];
//pm1.imageUrl = @"https://pics6.baidu.com/feed/50da81cb39dbb6fd3bc4e1ed12a58d16952b37e8.jpeg";
//pm1.isVideo = NO;
//
//SobotPhotoModel *pm2 = [[SobotPhotoModel alloc] init];
//pm2.imageUrl = @"";
//pm2.isVideo = YES;
//pm2.vidoUrl = @"https://img.sobot.com/mobile/sdk/sobot_sdk_demo_android.mp4";
//SobotPhotoModel *pm3 = [[SobotPhotoModel alloc] init];
//pm3.imageUrl = @"https://pics4.baidu.com/feed/f7246b600c338744d376ca604d8efff7d62aa08e.jpeg";
//pm3.isVideo = NO;
//
//NSMutableArray *photos = [[NSMutableArray alloc] initWithObjects:pm1,pm2,pm3, nil];
//
//SobotPhotoPreviewController *vc = [[SobotPhotoPreviewController alloc] init];
//vc.allData = photos;
//vc.curIndex = 2; // 默认显示第二个
/// 
@interface SobotPhotoPreviewController : SobotBaseController

// 下标从1开始
@property (assign, nonatomic) NSInteger curIndex;

// SobotPhotoModel 数组
@property (strong, nonatomic) NSMutableArray *allData;

@end

NS_ASSUME_NONNULL_END
