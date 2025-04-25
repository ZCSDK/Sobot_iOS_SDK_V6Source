//
//  ZCLeaveDetailCell.h
//  SobotKit
//
//  Created by lizh on 2022/9/8.
//

#import <UIKit/UIKit.h>
#import <SobotChatClient/SobotChatClient.h>
NS_ASSUME_NONNULL_BEGIN

@interface ZCLeaveDetailCell : UITableViewCell

-(void)initWithData:(ZCRecordListDetailModel *)model IndexPath:(NSUInteger)row count:(int) count;

-(void)setShowDetailClickCallback:(void (^)(ZCRecordListDetailModel *model ,NSString *urlStr))detailClickBlock;
@end

NS_ASSUME_NONNULL_END
