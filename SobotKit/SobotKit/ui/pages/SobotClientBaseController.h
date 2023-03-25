//
//  SobotClientBaseController.h
//  SobotChatClient
//
//  Created by zhangxy on 2022/8/30.
//

#import <SobotCommon/SobotCommon.h>


/**ZCPageBlockType回调类型*/
typedef NS_ENUM(NSInteger,ZCPageStateType) {
    ZCPageStateTypeChatBack     = 1,// 点击返回
    ZCPageStateTypeChatLoadFinish = 2,// 加载界面完成，可对UI进行修改
    ZCPageStateTypeLeave      = 3,// 留言
};

typedef NS_ENUM(NSInteger, ZCButtonClickTag) {
    BUTTON_BACK   = 1, // 返回
    BUTTON_CLOSE  = 2, // 关闭(未使用)
    BUTTON_UNREAD = 3, // 未读消息
    BUTTON_MORE   = 4, // 清空历史记录
    BUTTON_TURNROBOT = 5,// 切换机器人
    BUTTON_EVALUATION =6,// 评价
    BUTTON_TEL   = 7,// 拨打电话
    BUTTON_SEND   = 8, // 清空历史记录
};

// 返回监听
typedef NS_ENUM(NSInteger,ZCPageCloseType) {
    ZC_CloseLeave       = 1, // 留言返回
    ZC_CloseChat        = 2, // 会话页面
    ZC_CloseHelpCenter  = 3, // 帮助中心
    ZC_CloseChatList  = 4, // 电商消息中心
    ZC_PhoneCustomerService  = 5, // 电话联系客服
};
NS_ASSUME_NONNULL_BEGIN

@interface SobotClientBaseController : SobotBaseController

// 更新导航栏背景色和渐变色
-(void)updateTopViewBgColor;

// 更新帮助中心导航栏渐变色
-(void)updateCenterViewBgColor;
@end

NS_ASSUME_NONNULL_END
