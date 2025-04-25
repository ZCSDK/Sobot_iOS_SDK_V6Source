//
//  ZCOrderOnlyEditCell.h
//  SobotKit
//
//  Created by lizh on 2022/9/13.
//  单行文本输入 type 1 , 5 
#import <UIKit/UIKit.h>
#import "ZCOrderCreateCell.h"

// 限制方式  1禁止输入空格   2 禁止输入小数点  3 小数点后只允许2位  4 禁止输入特殊字符  5只允许输入数字 6最多允许输入字符  7判断邮箱格式  8判断手机格式
typedef enum _ZCEditLimitType {
    ZCEditLimitType_noPoint  = 0,
    ZCEditLimitType_onlyTwo,
    ZCEditLimitType_other,
    ZCEditLimitType_special
} ZCEditLimitType;

NS_ASSUME_NONNULL_BEGIN

@interface ZCOrderOnlyEditCell : ZCOrderCreateCell

@property (nonatomic,strong) UITextField *fieldContent;

@property (nonatomic,strong) UIImageView *imgArrow;

@end

NS_ASSUME_NONNULL_END
