//
//  ZCLeaveDetailHeaderCell.h
//  SobotKit
//
//  Created by lizh on 2025/1/16.
//

#import <UIKit/UIKit.h>
#import <SobotChatClient/SobotChatClient.h>
NS_ASSUME_NONNULL_BEGIN
typedef void(^HeaderBlock)(ZCRecordListModel*model,BOOL isOpen);
@interface ZCLeaveDetailHeaderCell : UITableViewCell

@property(nonatomic,copy)HeaderBlock headerBlock;
-(void)initWithData:(ZCRecordListModel *)model IndexPath:(NSUInteger)row isOpen:(BOOL)isOpen;

@end

NS_ASSUME_NONNULL_END
