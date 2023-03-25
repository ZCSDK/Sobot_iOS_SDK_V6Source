//
//  ZCChatView.h
//  SobotKit
//
//  Created by zhangxy on 2022/8/30.
//

#import <UIKit/UIKit.h>
#import "ZCTitleView.h"
NS_ASSUME_NONNULL_BEGIN

@protocol ZCChatViewDelegate <NSObject>

@optional
// 头部点击事件，(返回/清理消息)
//-(void)topViewBtnClick:(ZCButtonClickTag )Tag;

// 标题改变
-(void)onTitleChanged:(NSString *)title imageUrl:(NSString *) url nick:(NSString *)nick company:(NSString *)company topBarType:(int)topBarType;

// 跳转留言
-(void)onLeaveMsgClick:(NSString*)tipMsg;

- (void)onPageStatusChange:(BOOL)isArtificial;

/// 返回页面
/// @param isAction 是否返回
/// @param isClose 返回是否结束会话
-(void)onBackFinish:(BOOL) isAction closeClick:(BOOL ) isClose;

// 更新导航栏颜色
-(void)updateTopViewBgColor;
@end

@interface ZCChatView : UIView

// 设置页面代理
@property (nonatomic,weak) id<ZCChatViewDelegate>delegate;

-(void)loadDataToView;

// 更新数据
-(void)roadData;


/// 是否为点击关闭按钮
/// @param isClose YES，点击关闭
-(void)closeChatView:(BOOL) isClose;

-(void)backChatView;

// 获取输入框 用户自定义
-(UITextView *)getChatTextView;
@end

NS_ASSUME_NONNULL_END
