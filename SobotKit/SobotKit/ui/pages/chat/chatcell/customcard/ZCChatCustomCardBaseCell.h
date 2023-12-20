//
//  ZCChatCustomCardBaseCell.h
//  SobotKit
//
//  Created by zhangxy on 2023/6/12.
//
#import <UIKit/UIKit.h>
#import <SobotCommon/SobotCommon.h>
#import "ZCChatBaseCell.h"

NS_ASSUME_NONNULL_BEGIN


/// 自定义卡片基类
/// 事件、基础操作类
@interface ZCChatCustomCardBaseCell : ZCChatBaseCell

@property(nonatomic,strong)SobotChatCustomCard *cardModel;

@property(nonatomic,strong) NSMutableArray *listArray;


-(void)menuButton:(SobotButton *) btn;

-(void)menuItemClickButton:(SobotChatCustomCardMenu *) menu tag:(int ) tag;

@end

NS_ASSUME_NONNULL_END
