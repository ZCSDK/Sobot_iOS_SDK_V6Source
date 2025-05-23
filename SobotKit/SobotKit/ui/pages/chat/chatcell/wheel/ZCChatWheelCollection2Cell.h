//
//  ZCChatWheelCollection2Cell.h
//  SobotKit
//
//  Created by zhangxy on 2022/9/29.
//

#import <UIKit/UIKit.h>
#import <SobotCommon/SobotCommon.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZCChatWheelCollection2Cell : UICollectionViewCell


@property (nonatomic,strong)  NSIndexPath *indexPath;

@property (strong, nonatomic) UIView *bgView; //背景
@property (strong, nonatomic) SobotImageView *posterView;// 图片
@property (strong, nonatomic) UILabel *labTitle; //标题
@property (strong, nonatomic) UILabel *labDesc; // 要素内容
@property (strong, nonatomic) UILabel *labTag; // 标签 （eg 电影评分,距离）


- (void)configureCellWithPostURL:(NSDictionary *)model message:(SobotChatMessage *)message;

@end

NS_ASSUME_NONNULL_END
