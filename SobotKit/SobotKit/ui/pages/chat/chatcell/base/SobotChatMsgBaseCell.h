//
//  SobotChatMsgBaseCell.h
//  SobotKit
//  显示标准消息的父类，此父类定义：头像、聊天气泡，顶、踩、转人工、发送状态、引导语、已读未读
//  Created by zhangxy on 2025/1/17.
//

#import "SobotChatBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface SobotChatMsgBaseCell : SobotChatBaseCell

/**
 聊天气泡，包含chatMsgView和lblSugguest两个直接子类
 */
@property (nonatomic,strong) UIView  *chatMsgBgView;

/**
 所有聊天内容添加到此view中
 */
@property (nonatomic,strong) UIView  *chatMsgView;
@property (nonatomic,strong) NSLayoutConstraint *layoutChatMsgLeft;
@property (nonatomic,strong) NSLayoutConstraint *layoutChatMsgRight;

/**
 聊天底部的引导语
 */
@property (nonatomic,strong) SobotEmojiLabel *lblSugguest;
// 当气泡高度不足时，使用此约束调节
// 比如 踩和赞在右侧，但是聊天内容仅一行时
@property (nonatomic,strong) NSLayoutConstraint *layoutSugguestHeight;

// 气泡底部：比如语音消息，超出气泡
@property (nonatomic,strong) NSLayoutConstraint *layoutBtmT;
@property (nonatomic,strong) UIView  *chatBtmView;

// 气泡底部：赞、踩、转人工
@property (nonatomic,strong) UIView  *chatBtmManualView;

// 气泡右边：赞、踩
@property (nonatomic,strong) UIView  *chatRightView;

// 气泡左边的：发送中，已读、未读
@property (nonatomic,strong) UIView  *chatLeftView;



+(SobotEmojiLabel *) createRichLabel;
+(SobotEmojiLabel *) createRichLabel:(id _Nullable) delegate;

@end

NS_ASSUME_NONNULL_END
