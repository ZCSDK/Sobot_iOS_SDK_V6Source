//
//  ZCAutoListCell.h
//  SobotKit
//
//  Created by lizh on 2025/3/6.
//

#import <UIKit/UIKit.h>
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClient.h>
NS_ASSUME_NONNULL_BEGIN

@interface ZCAutoListCell : UITableViewCell
-(void)initDataToView:(NSString *) text attributedText:(NSAttributedString*)attributedText;
@end

NS_ASSUME_NONNULL_END
