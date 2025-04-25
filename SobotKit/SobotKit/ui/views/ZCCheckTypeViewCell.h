//
//  ZCCheckTypeViewCell.h
//  SobotKit
//
//  Created by lizh on 2025/1/14.
// 问题分类也做成级联的新版UI样式

#import <UIKit/UIKit.h>
#import "ZCUIKitTools.h"
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClient.h>
NS_ASSUME_NONNULL_BEGIN

@interface ZCCheckTypeViewCell : UITableViewCell
@property (nonatomic,strong) UILabel *labelName;
@property (nonatomic,strong) UIImageView *iconImg;
@property(nonatomic,strong) NSDictionary *tempDict;
-(void)initDataToView:(ZCLibTicketTypeModel *)model isSel:(BOOL)isSel isNext:(BOOL)isNext;
@end

NS_ASSUME_NONNULL_END
