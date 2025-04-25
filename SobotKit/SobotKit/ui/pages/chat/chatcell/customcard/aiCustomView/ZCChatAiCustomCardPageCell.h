//
//  ZCChatAiCustomCardPageCell.h
//  SobotKit
//
//  Created by lizh on 2025/3/20.
//

#import <UIKit/UIKit.h>
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClient.h>
NS_ASSUME_NONNULL_BEGIN
typedef void(^AiCustomCardPageCellBlock)(SobotChatCustomCardInfo *model,SobotChatCustomCardMenu *menu,int type);

@interface ZCChatAiCustomCardPageCell : UITableViewCell

@property(nonatomic,copy)AiCustomCardPageCellBlock aiCardPageCellBlock;
@property (nonatomic , assign) BOOL isHistory;
-(void)initDataToView:(SobotChatCustomCardInfo *) model;
@end

NS_ASSUME_NONNULL_END
