//
//  SobotSatisfactionView.h
//  SobotKit
//  评价页面
//  Created by zhangxy on 2023/8/11.
//

#import <UIKit/UIKit.h>
#import <SobotChatClient/SobotChatClient.h>


/**
 * RobotChangeTag ENUM
 */
typedef NS_ENUM(NSInteger, SobotSatisfactionType) {
    /** 人工 */
    SobotSatisfactionTypeManual = 0,
    /** 机器人 */
    SobotSatisfactionTypeRobot = 1,
    /** 留言 业务和人工一样 */
    SobotSatisfactionTypeLeave = 2,
    /** AI机器人 */
    SobotSatisfactionTypeAiAgent = 3,
};

/**
 * RobotChangeTag ENUM
 */
typedef NS_ENUM(NSInteger, SobotSatisfactionFromSrouce) {
    /** 底部加号触发,包含导航menu */
    SobotSatisfactionFromSrouceAdd = 0,
    /** 新会话触发 */
    SobotSatisfactionFromSrouceNewSession,
    /** 邀评 */
    SobotSatisfactionFromSrouceInvite,
    /** 留言 */
    SobotSatisfactionFromSrouceLeave,
    /**返回**/
    SobotSatisfactionFromSrouceBack,
    /**关闭，包含自定义菜单关闭**/
    SobotSatisfactionFromSrouceClose,
};

// 启动评价页面的必要参数
@interface SobotSatisfactionParams : NSObject


// 当前展示样式
@property (nonatomic,assign) SobotSatisfactionType  showType;


// 是从哪里触发，内部不使用，仅返回结果后外部使用
@property (nonatomic,assign) SobotSatisfactionFromSrouce fromSource;

// 当前评价的对象名称,请你对xxx进行评价
@property (nonatomic,strong) NSString * _Nullable serviceName;

/**
 *   txtFlag;//评价文本框开关  0 关闭  1 开启 （仅工单详情页面触发评价时使用）
 */
@property (nonatomic,assign) BOOL  textFlag;

// 用户ID
@property (nonatomic,strong) NSString * _Nullable uid;
@property (nonatomic,strong) NSString * _Nullable ticketld;


// 评价完人工是否结束会话
@property (nonatomic, assign) BOOL isCloseAfterEvaluation;

// 如果是邀评过来，使用
// 当前显示星星，0是未选择
@property (nonatomic, assign) int rating;

// 如果是邀评过来，使用
// (0)-未解决 (1)-解决 (-1)-不选中
@property (nonatomic, assign) int invateQuestionFlag;

/**
 ....
 是否必填
 是否默认
 是否可选
 .....
 
 */

@end


NS_ASSUME_NONNULL_BEGIN

@class SobotSatisfactionParams;



@interface SobotSatisfactionView : UIView



/// 创建 评价页面
/// @param params 评价params
/// @param config zclibconfig
/// @param view 暂未使用
-(SobotSatisfactionView *)initActionSheetWith:(SobotSatisfactionParams *)params config:(ZCLibConfig *)config cView:(UIView * _Nullable)view;


/**
 当前页面点击时间
 type:
    0: 点击关闭
    1: 提交成功
    -1：暂不评价
 inParams:接入的入参
 outParams:提交的内容
 */
@property(nonatomic,copy) void (^onSatisfactionClickBlock)(int type,SobotSatisfactionParams *inParams,NSMutableDictionary *_Nullable outParams,id _Nullable result);


/**
 *  显示弹出层
 */
- (void)showSatisfactionView:(UIView * _Nullable) superView;


/**
 *  关闭弹出层
 */
- (void)dismissView;


@end

NS_ASSUME_NONNULL_END
