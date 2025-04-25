//
//  ZCSkillGroup3Cell.h
//  SobotKit
//
//  Created by lizh on 2025/1/22.
//

#import <UIKit/UIKit.h>
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClient.h>
NS_ASSUME_NONNULL_BEGIN

@protocol ZCSkillGroup3CellDelegate <NSObject>
@optional
-(void)jumpGroupModel:(ZCLibSkillSet *)model;
@end

@interface ZCSkillGroup3Cell : UITableViewCell
-(void)initDataToView:(ZCLibSkillSet *) model;
@property(nonatomic,weak) id<ZCSkillGroup3CellDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
