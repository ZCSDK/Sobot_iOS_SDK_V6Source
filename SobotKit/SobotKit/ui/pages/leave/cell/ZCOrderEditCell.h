//
//  ZCOrderEditCell.h
//  SobotKit
//
//  Created by lizh on 2022/9/14.
//  多行文本

#import "ZCOrderCreateCell.h"
#import "ZCUIPlaceHolderTextView.h"
#import "ZCUITextView.h"
NS_ASSUME_NONNULL_BEGIN

@interface ZCOrderEditCell : ZCOrderCreateCell
//@property (nonatomic,strong) ZCUIPlaceHolderTextView *textContent;
@property (nonatomic,strong) ZCUITextView *textContent;
@end

NS_ASSUME_NONNULL_END
