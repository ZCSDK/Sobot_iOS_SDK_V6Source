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
typedef void(^SobotPickerMediaFinishBlock)(NSMutableArray  * _Nullable items);


@interface SobotPHImagePickerTools : NSObject

+(SobotPHImagePickerTools *) shareSobotPHImagePickerTools;

-(void)getPhotoByType:(SobotImagePickerType) type onlyPhoto:(BOOL)onlyPicture byUIImagePickerController:(nonnull UIViewController *)by_controller block:(nonnull SobotPickerMediaFinishBlock)finshBlock;

@end

NS_ASSUME_NONNULL_END
