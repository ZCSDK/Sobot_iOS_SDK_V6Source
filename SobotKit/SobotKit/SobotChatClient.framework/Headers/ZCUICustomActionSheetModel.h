//
//  ZCUICustomActionSheetModel.h
//  SobotChatClient
//
//  Created by lizh on 2022/9/19.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, SatisfactionType) {
    
    /** 返回按钮*/
    SatisfactionTypeBack = 1,
    
    /** 关闭按钮 */
    SatisfactionTypeClose,
    
    /** 点击按钮 */
    SatisfactionTypeKeyboard,
    
    
    /*** 人工客服主动邀请评价***/
    SatisfactionTypeInvite,
    
    /**** 留言详情页面 评价本次服务 *****/
    SatisfactionTypeLeaveReply,
};

NS_ASSUME_NONNULL_BEGIN

@interface ZCUICustomActionSheetModel : NSObject

/**
 *   txtFlag;//评价文本框开关  0 关闭  1 开启 （仅工单详情页面触发评价时使用）
 */
@property (nonatomic,assign) BOOL  textFlag;

/**
 *  ticketld 工单id 仅工单详情页面触发评价时使用
 */
@property (nonatomic,copy) NSString * ticketld;

/**
 *  星评 和星评说明   例如 5星： 非常满意
 */
@property (nonatomic,strong) NSArray * ticketScoreInfooList;

/**
 *  评价类型，当前是机器人还是人工评价
 *   1.机器人的评价返回关闭
 *   2机器人评价(点击底部评价按钮）
 *   3人工客服评价 返回关闭
 *   4 人工客服评价 （点击底部评价按钮）
 *   5人工客服主动邀请评价
 *   6 留言详情页面 评价本次服务
 */
@property (nonatomic,assign) SatisfactionType type ;

// 客服或者机器人的昵称
@property (nonatomic,copy) NSString *name;

// 是否为评价人工
@property (nonatomic, assign) BOOL isEvalutionAdmin;


// 用户ID
@property (nonatomic,copy) NSString *uid;

// 评价完人工是否结束会话
@property (nonatomic, assign) BOOL isCloseAfterEvaluation;

// 是否刷新客服主动邀请评价的满意度cell
@property (nonatomic, assign) BOOL IsAddServerSatifaction;

// 默认几星
@property (nonatomic, assign) int rating;

// 邀请评价记录 是否已解决,-1未选择,0未解决，1已解决，
@property (nonatomic, assign) int isResolve;

@property(nonatomic,assign)BOOL isOpenProblemSolving;// 是否开启 已解决 未解决


@property(nonatomic,assign)BOOL isOpenDefaultStar;// 是否默认选中星星


@end

NS_ASSUME_NONNULL_END
