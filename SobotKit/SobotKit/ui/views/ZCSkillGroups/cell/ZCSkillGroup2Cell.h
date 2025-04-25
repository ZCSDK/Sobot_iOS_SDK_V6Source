//
//  ZCSkillGroup2Cell.h
//  SobotKit
//
//  Created by lizh on 2025/1/22.
//

#import <UIKit/UIKit.h>
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClient.h>
NS_ASSUME_NONNULL_BEGIN

@protocol ZCSkillGroup2CellDelegate <NSObject>
@optional
-(void)jumpGroupModel:(ZCLibSkillSet *)model;
// 获取最终的高度
-(void)getMaxH:(CGFloat)maxH;
@end

@interface ZCSkillGroup2Cell : UITableViewCell

@property(nonatomic,weak) id<ZCSkillGroup2CellDelegate>delegate;

-(void)initDataToView:(NSMutableArray *)listArray;

@end

NS_ASSUME_NONNULL_END
