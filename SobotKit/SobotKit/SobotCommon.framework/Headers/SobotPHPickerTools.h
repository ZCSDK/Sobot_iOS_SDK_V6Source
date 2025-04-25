//
//  SobotPHPickerTools.h
//  SobotCommon
//
//  Created by zhangxy on 2024/2/4.
//

#import <Foundation/Foundation.h>
#import "SobotImagePickerTools.h"
#import <PhotosUI/PhotosUI.h>
#import <SobotCommon/SobotCommon.h>

NS_ASSUME_NONNULL_BEGIN

/**
 filePath ,
 type,
 duration,
 conver
 */
typedef void(^SobotPHPickerMediaSaveBlock)(NSInteger type,NSDictionary  * _Nullable item,int index,NSInteger allCount);

// 当前选中对象变化
@protocol SobotPickerSelectProtocol <NSObject>
- (void)customSelectAssets:(NSMutableArray *)assets;
@end

@class SobotCustomAlbumModel;

@interface SobotPHPickerTools : NSObject

+(SobotPHPickerTools *) shareSobotPHPickerTools;

/** 系统相册相机图片 */
@property (nonatomic,strong) UIImagePickerController * _Nullable zc_imagepicker;


@property (assign, nonatomic) NSInteger selectCount; // 选择图片的数量
@property (assign, nonatomic) NSInteger limitMaxNumber; // 限制选择数量
@property (assign, nonatomic) BOOL singleSelected; // 单选
@property (strong, nonatomic) NSMutableArray *saveSelectPics; // 已选择的对象
@property (strong, nonatomic) SobotPHPickerMediaSaveBlock saveMediaFileBlock;


@property (nonatomic,strong) NSString * _Nullable imageNameChoose;
@property (nonatomic,strong) NSString * _Nullable imageNameChooseChecked;
@property (nonatomic,strong) NSString * _Nullable imageNamePlay;




-(void)openPhotoByType:(SobotImagePickerType) type onlyPhoto:(BOOL)onlyPicture byUIImagePickerController:(nonnull UIViewController *)by_controller block:(nonnull SobotPHPickerMediaSaveBlock)saveFileBlock;



/// 保存选中的内容到本地，通过saveMediaFileBlock 回调单个执行
-(void)saveSelectedFiles;
-(void)exitPickerVC;

-(void)clearSelected;

/// 处理图片方向
/// - Parameter originImage: 原始图片
- (UIImage *)fixOrientation:(UIImage *) originImage;

// 获取相册
+(NSMutableArray *)getAllAlbumInfo:(PHAssetMediaType) selectMediaType result:(void(^)(NSMutableArray  * _Nullable items)) resultBlock;


// 获取相册所有图片的信息
+ (NSArray *)getAssetWithCollection:(PHAssetCollection *)collection;

+ (NSArray *)getAllAsset;

+(void)phassetToImage:(UIImageView *)imageView Asset:(PHAsset *)asset result:(void(^)(UIImage * _Nullable result, NSDictionary * _Nullable info)) resultBlock;



/// 设置UITableView和UICollection的savearea
/// - Parameters:
///   - sv: 需要设置的view
///   - isUse: 是否使用
+ (void)adaptationSafeAreaWith:(UIScrollView *)sv useArea:(NSInteger)isUse;

@end


@interface SobotCustomAlbumModel : SobotBaseEntity

@property (assign, nonatomic) BOOL isPlaying;
@property (assign, nonatomic) BOOL select;
@property (assign, nonatomic) NSInteger number;
@property (strong, nonatomic) PHAsset *asset;
@property (strong, nonatomic) UIImage *image; // 缩略图
@property (strong, nonatomic) UIImage *originalImage; // 原图

@end

NS_ASSUME_NONNULL_END
