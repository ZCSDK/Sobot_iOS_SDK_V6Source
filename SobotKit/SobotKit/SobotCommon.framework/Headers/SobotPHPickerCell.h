//
//  SobotPHPickerCell.h
//  SobotCommon
//
//  Created by zhangxy on 2024/2/21.
//

#import <UIKit/UIKit.h>
#import <SobotCommon/SobotCommon.h>
#import "SobotPHPickerTools.h"

NS_ASSUME_NONNULL_BEGIN

@interface SobotPHPickerCell : UICollectionViewCell

@property (strong, nonatomic) SobotCustomAlbumModel *dataModel;


@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIButton *btnMmark;

@property (strong, nonatomic) UIButton *btnPlay;

@property (strong, nonatomic) NSIndexPath *indexPath; // 当前行

@property (assign, nonatomic) NSInteger targetMark; // 0:列表 1:详情
typedef void (^tapSelectPicBlock)(SobotCustomAlbumModel *object);
typedef void (^tapPlayVideoBlock)(BOOL isPlay,SobotCustomAlbumModel *object,NSIndexPath *indexPath);
@property (strong, nonatomic) tapSelectPicBlock selectPicBlock;
@property (strong, nonatomic) tapPlayVideoBlock playVideoBlock;

- (void)initWithObject:(id)object IndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
