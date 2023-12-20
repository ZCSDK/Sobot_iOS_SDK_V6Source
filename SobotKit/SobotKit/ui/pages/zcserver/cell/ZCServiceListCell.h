//
//  ZCServiceListCell.h
//  SobotKit
//
//  Created by lizh on 2022/9/27.
//

#import <UIKit/UIKit.h>
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClient.h>
#import "ZCUIKitTools.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZCServiceListCell : UITableViewCell

-(void)initWithModel:(ZCSCListModel *)model width:(CGFloat) tableWidth;

@end

NS_ASSUME_NONNULL_END
