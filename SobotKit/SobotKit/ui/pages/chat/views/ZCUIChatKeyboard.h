//
//  ZCUIChatKeyboard.h
//  SobotKit
//
//  Created by zhangxy on 2022/9/1.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SobotChatClient/SobotChatClient.h>
#import <SobotCommon/SobotCommon.h>
#import "ZCUIPlaceHolderTextView.h"

#define BottomHeight 59

#define ZCConnectBottomHeight 64

NS_ASSUME_NONNULL_BEGIN

/**
 *   ZCKeyboardStatus   ENUM
 */
typedef NS_ENUM(NSUInteger,ZCKeyboardViewStatus){
    ZCKeyboardStatusWaiting        = 1,           // 转人工、+ 、输入框、排队中...
    ZCKeyboardStatusUser,                // 人工键盘样式
    ZCKeyboardStatusRobot,               // 机器人键盘样式
    ZCKeyboardStatusNewSession           // 新会话键盘样式
};

@interface ZCUIChatKeyboard : NSObject

@property (nonatomic , assign) ZCKeyboardViewStatus curKeyboardStatus;

/** 聊天页底部View（输入框，按钮的父类） */
@property (nonatomic,strong) UIView     * _Nonnull zc_bottomView;
@property (nonatomic,strong) ZCUIPlaceHolderTextView * _Nonnull zc_chatTextView;

// 重新链接view，留言/重建会话/评价
@property (nonatomic,strong) UIView     * _Nullable zc_reConnectView;

//@property (nonatomic,strong) UIButton * _Nullable btnConnectUser;
@property (nonatomic,strong) UIButton * _Nullable btnMore;
@property (nonatomic,strong) UIButton * _Nullable btnVoice;
@property (nonatomic,strong) UIButton * _Nullable btnFace;

/**
 *  初始化聊天页面中的底部输入框区域UI
 *
 *  @param unitView  聊天VC的View
 *  @param listTable 聊天的tableview
 *
 */
-(id)initConfigView:(UIView *)unitView table:(UITableView *)listTable;

/**
 *  通过初始化信息设置键盘以及相应的操作
 *
 *  @param config 配置信息model
 */
-(void)setInitConfig:(ZCLibConfig *)config;


/// 更改键盘状态
/// @param status 显示状态
-(void)setKeyboardMenuByStatus:(ZCKeyboardViewStatus )status;

/// 屏幕旋转时，隐藏键盘
-(void)hideKeyboard;

-(void)removeKeyboardObserver;

// 是否正则录音
-(BOOL) isKeyboardRecord;

@end

NS_ASSUME_NONNULL_END
