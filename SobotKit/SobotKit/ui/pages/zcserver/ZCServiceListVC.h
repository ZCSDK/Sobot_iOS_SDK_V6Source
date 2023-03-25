//
//  ZCServiceListVC.h
//  SobotKit
//
//  Created by lizh on 2022/9/27.
//

#import <SobotKit/SobotKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZCServiceListVC : SobotClientBaseController
@property (nonatomic,copy) NSString *titleName; // 标题
@property (nonatomic,copy) NSString *categoryId;// 分类id
@property (nonatomic,copy) NSString *appId;
@property(nonatomic,strong) void (^OpenZCSDKTypeBlock)(SobotClientBaseController *object);
@property (nonatomic,strong) ZCKitInfo *kitInfo;

@end

NS_ASSUME_NONNULL_END
