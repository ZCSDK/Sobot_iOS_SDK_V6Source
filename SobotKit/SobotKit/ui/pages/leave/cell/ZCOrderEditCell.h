//
//  ZCOrderEditCell.h
//  SobotKit
//
//  Created by lizh on 2022/9/14.
//

#import "ZCOrderCreateCell.h"
#import "ZCUIPlaceHolderTextView.h"
NS_ASSUME_NONNULL_BEGIN

@interface ZCOrderEditCell : ZCOrderCreateCell
@property (nonatomic,strong) ZCUIPlaceHolderTextView *textContent;
@end

NS_ASSUME_NONNULL_END
