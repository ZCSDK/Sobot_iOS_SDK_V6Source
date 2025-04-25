//
//  ZCOrderCheckCell.h
//  SobotKit
//
//  Created by lizh on 2022/9/14.
//  选择页面 + 时间 + 单选 + 地区
#import <UIKit/UIKit.h>
#import "ZCOrderCreateCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZCOrderCheckCell : ZCOrderCreateCell

@property (nonatomic,strong) UILabel *labelName;

@property (nonatomic,strong) UILabel *labelContent;

@property (nonatomic,strong) UIImageView *imgArrow;
@end

NS_ASSUME_NONNULL_END
