//
//  ZCUIChatListCell.h
//  SobotKit
//
//  Created by zhangxy on 2022/9/29.
//

#import <UIKit/UIKit.h>

#import <SobotChatClient/SobotChatClient.h>

@interface ZCUIChatListCell : UITableViewCell

/**
 *  显示时间
 */
@property (nonatomic,strong) UILabel                  *lblTime;

/**
 *  头像
 */
@property (nonatomic,strong) SobotImageView            *ivHeader;

/**
 *  名称
 */
@property (nonatomic,strong) UILabel                  *lblNickName;
@property (nonatomic,strong) UILabel                  *lblLastMsg;
@property (nonatomic,strong) UILabel                  *lblUnRead;

-(void)dataToView:(ZCPlatformInfo *) info;


@end
