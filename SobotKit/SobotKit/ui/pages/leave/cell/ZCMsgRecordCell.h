//
//  ZCMsgRecordCell.h
//  SobotKit
//
//  Created by lizh on 2022/9/7.
//

#import <UIKit/UIKit.h>
#import <SobotChatClient/SobotChatClient.h>
NS_ASSUME_NONNULL_BEGIN

@interface ZCMsgRecordCell : UITableViewCell

-(void)initWithDict:(ZCRecordListModel*)model with:(CGFloat) width;
@end

NS_ASSUME_NONNULL_END
