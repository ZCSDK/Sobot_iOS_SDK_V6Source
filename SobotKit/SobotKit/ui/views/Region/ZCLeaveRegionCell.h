//
//  ZCLeaveRegionCell.h
//  SobotOrderSDK
//
//  Created by zhangxy on 2024/3/26.
//

#import <UIKit/UIKit.h>
#import "ZCLeaveRegionEntity.h"
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClient.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZCLeaveRegionCell : UITableViewCell



@property (strong, nonatomic) UILabel *labName;
@property (strong, nonatomic) UILabel *labCheck;
@property (strong, nonatomic) UIImageView *imgArrow;
@property (strong, nonatomic) UIView *lineView;


@property (strong, nonatomic) ZCOrderCusFiledsModel *fieldModel;
@property (strong, nonatomic) NSString *searchText;

@property (strong, nonatomic) ZCLeaveRegionEntity *checkModel;

// 设置图片的主题色
@property (strong, nonatomic) UIColor *imgColor;
-(void)initDataToView:(ZCLeaveRegionEntity *) entity;


@end

NS_ASSUME_NONNULL_END
