//
//  ZCOrderOnlyEditCell.h
//  SobotKit
//
//  Created by lizh on 2022/9/13.
//
#import <UIKit/UIKit.h>
#import "ZCOrderCreateCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZCOrderOnlyEditCell : ZCOrderCreateCell

@property (nonatomic,strong) UITextField *fieldContent;

@property (nonatomic,strong) UIImageView *imgArrow;

@end

NS_ASSUME_NONNULL_END
