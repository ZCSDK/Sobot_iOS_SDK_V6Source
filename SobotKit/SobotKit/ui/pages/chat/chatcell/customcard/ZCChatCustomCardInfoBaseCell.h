//
//  ZCChatCustomCardInfoBaseCell.h
//  SobotKit
//
//  Created by zhangxy on 2023/6/13.
//

#import "ZCChatBaseCell.h"
#import <SobotCommon/SobotCommon.h>

@protocol ZCChatCustomCardInfoBaseCellDelegate <NSObject>

-(void)onCollectionItemMenuClick:(SobotChatCustomCardMenu *) menu index:(NSIndexPath *) index message:(SobotChatMessage *) model;

@end

NS_ASSUME_NONNULL_BEGIN

/// 自定义卡片内容基类
/// 定义卡片事件，基础操作控件
@interface ZCChatCustomCardInfoBaseCell : UICollectionViewCell

@property (nonatomic,strong)  NSIndexPath *indexPath;
@property (nonatomic,strong)  SobotChatMessage *message;
@property (nonatomic,strong)  SobotChatCustomCardInfo *cardModel;
@property (nonatomic,weak)  id<ZCChatCustomCardInfoBaseCellDelegate> delegate;

@property (strong, nonatomic) UIView *bgView; //背景
@property (strong, nonatomic) SobotImageView *posterView;// 图片
@property (strong, nonatomic) UILabel *labTitle; //标题
@property (strong, nonatomic) UILabel *labDesc; // 描述
@property (strong, nonatomic) UILabel *labTips; //提示
@property (strong, nonatomic) UILabel *priceTip;// 商品价格标签
// 订单时不显示
@property (strong, nonatomic) SobotButton *btnSend; //发送按钮

-(void)createViews;

- (void)configureCellWithData:(SobotChatCustomCardInfo *) model message:(SobotChatMessage *)message;

-(void)menuButtonClick:(SobotButton *) btn;

@end
NS_ASSUME_NONNULL_END
