//
//  ZCUICore.h
//  SobotKit
//
//  Created by zhangxy on 2022/8/30.
//

#import <Foundation/Foundation.h>
#import <SobotKit/ZCKitInfo.h>
#import <SobotKit/SobotClientBaseController.h>
#import <SobotChatClient/SobotChatClient.h>
#import <SobotCommon/SobotCommon.h>
// 链接点击类型
typedef NS_ENUM(NSInteger,ZCLinkClickType) {
    ZCLinkClickTypeURL    = 0,
    ZCLinkClickTypeAppLet, // 小程序
};


typedef NS_ENUM(NSInteger,ZCTurnType) {
    ZCTurnType_KeyWord                 = 1,  // 关键字转人工
    ZCTurnType_KeyWordNoGroup,               // 关键字转人工,直接转
    ZCTurnType_KeyWordSmart,                // 智能转人工，静默转
    ZCTurnType_CellGroupClick,              // 点击关键字cell 中技能组
    ZCTurnType_BtnClick,                    // 点击转人工按钮
    ZCTurnType_BtnClickUpOrDown,            // 点击转人工，踩或赞
    ZCTurnType_RepeatOrMood,                // 重复提问转人工 z或者 情绪负向转人工
    ZCTurnType_InitBeConnected,             // 初始化已经是人工
    ZCTurnType_InitOnUserType,              // 初始化仅人工或人工优先
    ZCTurnType_CustomKeyWord,               // 客户自定义关键字转人工，不出转人工按钮，在ZCLibInitInfo中配置
    ZCTurnType_OffMessageAdmin,            // 转接到发送过离线消息的客服
};

typedef NS_ENUM(NSInteger,ZCShowStatus) {
    ZCShowStatusWaiting          = 1,  // 排队
    ZCShowStatusUnRead           = 2,  // 有未读消息
    ZCShowStatusAddMessage       = 3,  // 新增了一条消息
    ZCShowStatusChangedTitle     = 4,  // 更新标题,如果为空就显示原始文案
    ZCShowStatusRobotStyle       = 5,  // 机器人模式
    ZCShowStatusUserStyle        = 6,  // 人工模式
    ZCShowStatusReConnected      = 7,  // 重新接入  新会话
    ZCShowStatusMessageChanged   = 8,  // 消息列表更新
    ZCShowStatusConnecting       = 9,  // 链接中
    ZCShowStatusConnectSuc       = 10,  // 链接成功
    ZCShowStatusConnectFail      = 11,  // 链接失败
    ZCShowStatusOpenNewWindow    = 12,  // 打开新窗口
    ZCShowStatusSatisfaction     = 13,  // 点击新会话键盘 中的满意度按钮 去评价
    ZCShowStatusLeaveMsgPage     = 14,  // 点击新会话键盘 中的留言按钮 去留言
    ZCShowStatusCompleteNoMore   = 15,  // 获取消息完成,并且没有更多数据
    ZCShowStatusStartMessages    = 16,  // 开始获取历史消息
    ZCShowStatusCloseSkillSet    = 17,  // 关闭技能组
    ZCShowStatusConnectingUser   = 18,  // 开始转人工
    ZCShowStatusConnectFinished  = 20,  // 转人工完成,(不保证转成功)
    
    /** 用户长时间不说话提醒 */
    ZCShowNSTimerUserTimeOut     = 21,
    
    /** 客服长时间不说话提醒 */
    ZCShowNSTimerAdminTimeOut    = 22,
    
    /** 添加评价页面 */
    ZCShowCustomActionSheet      = 23,
    
    /** 设置键盘样式 */
    ZCSetKeyBoardStatus          = 24,
    
    /**  刷新 listTabel*/
    ZCSetListTabelRoad           = 25,
    
    ZCShowStatusGoBack           = 26,// 返回到启动页面结束会话
    
    ZCTurnRobotFramChange        = 27,  // 多机器人切换按钮位置发生改变时
        
    ZCShowTurnRobotBtn           = 29, // 是否显示多机器人切换按钮
    
    ZCShowStatusRefreshing       = 32,// 刷新进度条
    
    
    ZCShowTextHeightChanged      = 33,// 输入框高度变化了
    
    
    ZCShowLeaveEditViewWithTempleteId      = 34,// 多轮会话触发留言，以底部弹出方式显示
    ZCShowStatusLeaveOpenWithClose     = 35,  // 仅人工去留言，然后关闭
    ZCShowStatusOpenAskTable     = 36,  // 训前表单
    ZCShowStatusReConnectClick      = 37,  // 重新接入  新会话
};

typedef NS_ENUM(NSInteger,ZCInitStatus) {
    ZCInitStatusLoading           = 1,  // 正在调用接口初始化
    ZCInitStatusLoadSuc           = 2,  // 初始化完成
    ZCInitStatusFail              = 3,  // 初始化失败
};


// 初始化信息过时信息
#define Sobot_ChatSDK_START_RECORD @"Sobot_ChatSDK_START_Record"


@protocol ZCUICoreDelegate <NSObject>

@optional
-(void)onPageStatusChanged:(ZCShowStatus )status message:(NSString * _Nullable) message obj:(id _Nullable) object;
// 仅打开讯前表单使用
-(void)onPageStatusChanged:(ZCShowStatus )status message:(NSString * _Nullable) message obj:(id _Nullable) object other:(NSDictionary * _Nullable) otherObj;


/**
 *  设置聊天页面的title
 */
-(void)setTitleName:(NSString * _Nullable)titleName;


/**
 *   聊天页面头部显示 连_Nullable接中。。。
 **/
-(void)showSoketConentStatus:(ZCConnectStatusCode)statusCode;

@end

@interface ZCUICore : NSObject

+(ZCUICore * _Nonnull)getUICore;

@property (nonatomic,copy) NSString *checkGroupId;
@property (nonatomic,copy) NSString *checkGroupName;
@property(nonatomic,assign) BOOL isShowForm;// 是否直接去转人工，不在查询询前表单的接口

@property(nonatomic,strong) NSMutableArray * cids;
@property(nonatomic,strong) NSMutableArray * _Nullable chatMessages;
@property(nonatomic,weak) id<ZCUICoreDelegate> _Nullable delegate;

// 是否已经执行过转人工，再发送消息的时候使用，YES时，说明已经转过人工了，但是未说过话不做真正的转人工调用
@property (nonatomic,assign) BOOL isAfterConnectUser;
@property(nonatomic,strong) SobotChatMessage * _Nullable lineModel;

@property(nonatomic,strong) SobotChatMessage * _Nullable afterModel;
@property(nonatomic,strong) SobotChatMessage * _Nullable recordModel;
@property(nonatomic,assign) BOOL isShowRobotHello; // 是否显示机器人欢迎语
@property(nonatomic,assign) BOOL isShowRobotGuide; // 是否显示机器人常见问题
@property(nonatomic,strong) ZCKitInfo     *_Nonnull kitInfo;
@property(nonatomic,strong) NSDictionary *satisfactionDict; // 评价选项
@property(nonatomic,assign) BOOL isOffline;
@property (nonatomic,assign) BOOL isOfflineBeBlack; // 是否是拉黑
// 结束会话之前是否为人工模式，方便评价时获取当前状态
@property(nonatomic,assign) BOOL isAdminServerBeforeCloseSession;
@property (nonatomic,assign) BOOL isEvaluationService; // 是否评价过人工
@property (nonatomic,assign) BOOL isEvaluationRobot; // 是否评价过机器人

@property (nonatomic,assign) BOOL isSendToUser;
@property (nonatomic,assign) BOOL isSendToRobot;

@property(nonatomic,copy) BOOL (^AppletClickBlock)(SobotChatMessage *model);

@property(nonatomic,copy) BOOL (^CustomLeavePageBlock)(NSDictionary *dict);
/** 未知说辞计数*/
@property (nonatomic, assign) NSUInteger unknownWordsCount;
@property(nonatomic,strong) NSString * _Nullable inviteSatisfactionCheckLabels; // 邀请评价已选择的标签

@property(nonatomic,copy) void (^ _Nullable ZCViewControllerCloseBlock)(id _Nullable object,ZCPageCloseType type);
@property(nonatomic,copy) BOOL (^ _Nullable LinkClickBlock)(ZCLinkClickType type,NSString * _Nullable linkUrl,id _Nullable object);


-(void)doInitSDK:(id<ZCUICoreDelegate>_Nullable) delegate block:(void(^_Nullable)(ZCInitStatus status,NSString * _Nullable message,ZCLibConfig *_Nullable confg)) resultBlock;

-(void)keyboardOnClick:(ZCShowStatus)status;

-(ZCLibConfig *_Nullable)getLibConfig;

-(BOOL)getRecordModel;

/// 处理 识别出的链接
/// @param viewController 当前控制器
- (void)dealWithLinkClickWithLick:(NSString * _Nullable)link viewController:(UIViewController * _Nullable)viewController;


// 状态切换后，自动添加欢迎语/引导语等信息
-(void)sendMessageWithConnectStatus:(ZCServerConnectStatus) status;

// 发送订单卡片
-(void)sendOrderGoodsInfo:(ZCOrderGoodsModel *_Nonnull)orderGoodsInfo resultBlock:(nonnull void (^)(NSString * _Nonnull, int code))ResultBlock;

// 发送商品卡片
-(void)sendProductInfo:(ZCProductInfo *_Nonnull)productInfo resultBlock:(nonnull void (^)(NSString * _Nonnull, int code))ResultBlock;
-(void)sendMessage:(NSString *_Nonnull) content type:(SobotMessageType) msgType exParams:(NSDictionary * _Nullable) dict duration:(NSString *_Nullable) duration;
-(void)sendMessage:(ZCLibSendMessageParams *_Nonnull) sendParams type:(SobotMessageType) msgType;

/// 添加本地消息到消息列表
/// @param action 提示类型
/// @param content 消息内容
/// @param msgType 消息类型
/// @param message 消息内容
-(SobotChatMessage *_Nullable)addMessageToList:(SobotMessageActionType) action content:(NSString * _Nullable) content type:(SobotMessageType )msgType dict:(NSDictionary * _Nullable) message;
-(void)addMessage:(SobotChatMessage *) message reload:(BOOL) isReload;


/// 移除指定类型消息
/// - Parameters:
///   - type: 消息类型
///   - action: 提示消息
-(void)removeListModelWithType:(SobotMessageType ) type tips:(SobotMessageActionType) action;

-(void)setInputListener:(UITextView *)textView;

// 获取历史记录，执行完成会调用delegate通知
-(void)getChatMessages;


/// 加载星级内容，成功以后，数据存在satisfactionDict中
/// @param loadResult 0成功，1失败
- (void)loadSatisfactionDictlock:(nonnull void (^)(int)) loadResult;


// 校验转人工参数，并执行转人工
-(void)checkUserServiceWithType:(ZCTurnType) type model:(SobotChatMessage *_Nullable) message;
// 直接执行转人工，不校验参数
-(void)doConnectUserService:(SobotChatMessage *_Nullable)msgModel connectType:(ZCTurnType) type;


/// 获取当前弹出的技能组
-(UIView * _Nullable)getGroupView;
-(void)dismissGroupView;

// 评价之前，检查是否可以触发评价
-(BOOL)checkSatisfacetion:(BOOL) isEvalutionAdmin type:(SatisfactionType ) type;
// 邀请评价是，有值了
-(BOOL)checkSatisfacetion:(BOOL) isEvalutionAdmin type:(SatisfactionType ) type rating:(int) rating resolve:(int) resolve;
// 邀请评价，提交
- (void)commitSatisfactionWithIsResolved:(int)isResolved Rating:(int)rating problem:(NSString *) problem scoreFlag:(float)scoreFlag;

// 去留言页面
-(void)goLeavePage;


// 打开留言页面
-(void)openLeaveOrRecoredVC:(int) isRecord dict:(NSDictionary *) dict;

// 取消发送文件
-(void)cancelSendFileMsg:(SobotChatMessage *)fileMsg;

/// 执行继续排队
/// @param tipsModel 调用方法
-(void)continueWaiting:(SobotChatMessage *_Nonnull)tipsModel;

-(void)destoryViewsData;


/// 处理评价事件
/// @param isBcak 是否是返回触发的评价
-(void)keyboardOnClickSatisfacetion:(BOOL)isBcak;
@end
