//
//  ZCChatWheelCollectionCell.h
//  SobotKit
//
//  Created by zhangxy on 2022/9/21.
//

#import <UIKit/UIKit.h>
#import <SobotCommon/SobotCommon.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZCChatWheelCollectionCell : UICollectionViewCell

@property (nonatomic,strong)  NSIndexPath *indexPath;

@property (strong, nonatomic) UIView *bgView; //背景
@property (strong, nonatomic) SobotImageView *posterView;// 图片
@property (strong, nonatomic) UILabel *labTitle; //标题
@property (strong, nonatomic) UILabel *labDesc; // 要素内容
@property (strong, nonatomic) UILabel *labTag; // 标签 （eg 电影评分）
@property (strong, nonatomic) UILabel *labLabel; //


- (void)configureCellWithPostURL:(NSDictionary *)model message:(SobotChatMessage *)message isMoreLine:(BOOL)isMoreLine;

@end

NS_ASSUME_NONNULL_END
