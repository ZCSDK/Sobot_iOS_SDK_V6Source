//
//  ZCTurnRobotCell.h
//  SobotKit
//
//  Created by lizh on 2025/1/22.
//

#import <UIKit/UIKit.h>
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClient.h>
NS_ASSUME_NONNULL_BEGIN

@interface ZCTurnRobotCell : UITableViewCell
-(void)initDataToView:(ZCLibRobotSet *) model;
@end

NS_ASSUME_NONNULL_END
