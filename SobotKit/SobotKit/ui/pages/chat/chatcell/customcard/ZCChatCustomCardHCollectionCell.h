//
//  ZCChatCustomCardCollectionCell.h
//  SobotKit
//
//  Created by zhangxy on 2023/6/8.
//

#import <UIKit/UIKit.h>
#import "ZCChatCustomCardInfoBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZCChatCustomCardHCollectionCell : ZCChatCustomCardInfoBaseCell

@property (nonatomic,assign)int maxCustomMenus;// 当前最外层的最多按钮个数
@end

NS_ASSUME_NONNULL_END
