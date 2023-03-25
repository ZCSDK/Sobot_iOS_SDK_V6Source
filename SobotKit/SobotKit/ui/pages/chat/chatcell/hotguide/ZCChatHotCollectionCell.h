//
//  ZCChatHotCollectionCell.h
//  SobotKit
//
//  Created by zhangxy on 2022/9/21.
//

#import <UIKit/UIKit.h>
#import <SobotCommon/SobotCommon.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZCChatHotCollectionCell : UICollectionViewCell
@property (nonatomic,strong)  NSIndexPath *indexPath;


- (void)configureCellWithPostURL:(NSDictionary *)model message:(SobotChatMessage *)message;

@end

NS_ASSUME_NONNULL_END
