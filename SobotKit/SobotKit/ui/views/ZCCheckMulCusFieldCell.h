//
//  ZCCheckMulCusFieldCell.h
//  SobotKit
//
//  Created by lizh on 2025/1/10.
//

#import <UIKit/UIKit.h>
#import "ZCUIKitTools.h"
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClient.h>
NS_ASSUME_NONNULL_BEGIN
// **编辑cell的间距**
// 左右间距 16
#define  EditCellHSpec 16
// 标题行高 22
#define  EditCellTitleH 22
// 单行高度 72
#define  EditCellBGH 72
// 多行高度 112
#define  EditCellMBGH 112
// 标题上间距 12 和下间距 12
#define  EditCellPT 12
// 组件之间的上下间距 4
#define  EditCellMT 4

@interface ZCCheckMulCusFieldCell : UITableViewCell
@property (nonatomic,strong) UILabel *labelName;
@property (nonatomic,strong) UIImageView *iconImg;
@property(nonatomic,strong) NSDictionary *tempDict;
-(void)initDataToView:(ZCOrderCusFieldsDetailModel *)model isSel:(BOOL)isSel isNext:(BOOL)isNext;
@end

NS_ASSUME_NONNULL_END
