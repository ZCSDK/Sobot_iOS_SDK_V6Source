//
//  SobotPhotoPreviewCell.h
//  SobotCommon
//
//  Created by zhangxy on 2024/6/19.
//

#import <UIKit/UIKit.h>

#import <SobotCommon/SobotCommon.h>

NS_ASSUME_NONNULL_BEGIN

@class SobotPhotoModel;

typedef void (^tapPlayVideoBlock)(BOOL isPlay,SobotPhotoModel *object,NSIndexPath *indexPath);


@interface SobotPhotoPreviewCell : UICollectionViewCell

@property (strong, nonatomic) SobotPhotoModel *dataModel;


@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) SobotImageView *imageView;

// 保存按钮
@property (strong, nonatomic) UIButton *btnSave;

@property (strong, nonatomic) UIButton *btnPlay;

@property (strong, nonatomic) NSIndexPath *indexPath; // 当前行

// type=1:保存，0点击页面
@property (strong, nonatomic) void(^TapClickPicBlock)(int type,SobotPhotoModel *object);
@property (strong, nonatomic) tapPlayVideoBlock playVideoBlock;

- (void)initWithObject:(id)object IndexPath:(NSIndexPath *)indexPath;


@end

@interface SobotPhotoModel : SobotBaseEntity

@property (assign, nonatomic) BOOL isPlaying;
@property (assign, nonatomic) BOOL select;
@property (assign, nonatomic) NSInteger number;
@property (assign, nonatomic) BOOL isVideo;
// 0:图片，1视频
@property (assign, nonatomic) int fileType;
// 图片地址
@property (strong, nonatomic) NSString *imageUrl;
@property (strong, nonatomic) NSString *vidoUrl;
@property (strong, nonatomic) NSString *fileName;

@property (strong, nonatomic) UIImage *image; // 缩略图

@end
NS_ASSUME_NONNULL_END
