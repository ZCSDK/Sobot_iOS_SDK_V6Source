//
//  ZCChatAiCardView.h
//  SobotKit
//
//  Created by lizh on 2025/3/21.
//

#import <UIKit/UIKit.h>
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClient.h>
NS_ASSUME_NONNULL_BEGIN

@protocol ZCChatAiCardViewDelegate <NSObject>

@optional
// type 1 点击卡片  2 点击了菜单按钮  3.点击了自定义按钮// type 1 点击卡片  2 点击了菜单按钮  3.点击了自定义按钮
-(void)clickType:(int)type obj:(NSObject *)obj Menu:(SobotChatCustomCardMenu*)menu;
@optional
- (void)buttonStateChanged:(UIButton *)sender;
@end

@interface ZCChatAiCardView : UIView
@property(nonatomic,strong)SobotChatCustomCardInfo *cardModel;
@property(nonatomic,weak)id<ZCChatAiCardViewDelegate>delegate;
-(ZCChatAiCardView*)initWithDict:(SobotChatCustomCardInfo* )dict maxW:(CGFloat)maxW supView:(UIView *)supView lastView:(UIView*)lastView isHistory:(BOOL)isHistory isUnBtn:(BOOL)isUnBtn;
@end

NS_ASSUME_NONNULL_END
