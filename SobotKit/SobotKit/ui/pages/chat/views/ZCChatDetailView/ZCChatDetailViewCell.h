//
//  ZCChatDetailViewCell.h
//  SobotKit
//
//  Created by lizh on 2023/11/17.
//

#import <UIKit/UIKit.h>
#import <SobotCommon/SobotCommon.h>
#import "ZCChatBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZCChatDetailViewCellDelegate <NSObject>

@optional
-(void)btnClickType:(ZCChatCellClickType)type dict:(NSDictionary *)dict obj:(id)obj;

-(void)updateContentHeight:(CGFloat)height;

-(void)updateLoadData;// 刷新cell

-(void)closeDetailView;
@end

@interface ZCChatDetailViewCell : UITableViewCell

@property(nonatomic,weak) id<ZCChatDetailViewCellDelegate>delegate;

-(void)initWithDataModel:(SobotChatMessage*)model;

@end

NS_ASSUME_NONNULL_END
