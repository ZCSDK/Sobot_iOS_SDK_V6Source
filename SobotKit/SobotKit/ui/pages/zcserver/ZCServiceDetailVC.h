//
//  ZCServiceDetailVC.h
//  SobotKit
//
//  Created by lizh on 2022/9/16.
//

#import <SobotKit/SobotKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZCServiceDetailVC : SobotClientBaseController
@property (nonatomic,copy) NSString *docId;
@property (nonatomic,copy) NSString *appId;
@property (nonatomic,copy) NSString *questionTitle;
@property(nonatomic,strong) void (^OpenZCSDKTypeBlock)(SobotClientBaseController *object);
@property (nonatomic,strong) ZCKitInfo *kitInfo;
@end

NS_ASSUME_NONNULL_END
