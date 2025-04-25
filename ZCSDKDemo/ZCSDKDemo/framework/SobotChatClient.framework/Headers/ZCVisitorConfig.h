//
//  ZCVisitorConfig.h
//  SobotKit
//
//  Created by zhangxy on 2024/9/25.
//

#import <UIKit/UIKit.h>
#import <SobotCommon/SobotCommon.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZCVisitorConfig : SobotBaseEntity

/**
 用于判断
 */
@property (nonatomic,strong) NSString *app_key;
@property (nonatomic,strong) NSString *partnerId;


@property (nonatomic,strong) NSString *rebotTheme;
@property (nonatomic,strong) NSString *topBarColor;
@property (nonatomic,strong) NSString *hotlineName;
@property (nonatomic,strong) NSString *hotlineTel;

@end

NS_ASSUME_NONNULL_END
