//
//  ZCChatReferenceCell.h
//  SobotKit
//
//  Created by zhangxy on 2023/11/16.
//

#import <UIKit/UIKit.h>
#import <SobotCommon/SobotCommon.h>
#import "ZCUIKitTools.h"
#import "ZCUICore.h"
#import <SobotChatClient/SobotChatClient.h>


typedef enum : NSUInteger {
    ZCChatReferenceCellEventOpen, // 整个view点击
    ZCChatReferenceCellEventOpenURL,// 点击超链
    ZCChatReferenceCellEventCloseKeyboard,// 关闭键盘
    ZCChatReferenceCellEventOpenFileToDocment,// 使用系统的控件打开文件
    ZCChatReferenceCellEventPlayVoice,// 播放声音
    ZCChatReferenceCellEventOpenLocation,// 打开定位
    ZCChatReferenceCellEventAppletAction,// 点击小程序的事件
} ZCChatReferenceCellEvent;

/// 页面代理事件
@protocol ZCChatReferenceCellDelegate <NSObject>


/// 页面点击事件
/// - Parameters:
///   - model: 当前显示的消息体
///   - type: 事件类型
///   - state: 状态，缺损值
///   - obj: 预留参数，缺损值
-(void)onReferenceCellEvent:(SobotChatMessage * _Nullable) model type:(ZCChatReferenceCellEvent) type state:(int) state obj:(id _Nullable) obj;

@end

NS_ASSUME_NONNULL_BEGIN

@interface ZCChatReferenceCell : UIView

+(ZCChatReferenceCell *)createViewUseFactory:(SobotChatMessage *)message mainModel:(SobotChatMessage *) parentMessage maxWidth:(CGFloat)maxWidth;

/**
 *  最大宽度
 */
@property (nonatomic,assign) CGFloat  maxWidth;
@property(nonatomic,strong) SobotChatMessage *parentMessage;
@property(nonatomic,assign) BOOL isRight;

@property(nonatomic,strong) SobotChatMessage *tempMessage;

@property(nonatomic,strong) id<ZCChatReferenceCellDelegate> delegate;

@property(nonatomic,strong) UIView *viewLeftLine;
@property(nonatomic,strong) UILabel *labName;
@property(nonatomic,strong) UILabel *labTopText;
@property(nonatomic,strong) UIView *viewContent;
@property(nonatomic,strong) UILabel *labBottomText;


-(void)layoutSubViewUI;

/// 添加页面到View
/// - Parameters:
///   - message: 当前显示的消息
-(void)dataToView:(SobotChatMessage *) message;




/// 执行页面代理事件
/// - Parameters:
///   - type: 事件类型
///   - state: 预留参数，缺损值
///   - obj:预留参数，缺损值
-(void)viewEvent:(ZCChatReferenceCellEvent)type state:(int) state obj:(id _Nullable) obj;

/// 子类调用
/// - Parameters:
///   - topText: 顶部文字
///   - customView: 中间自定义View，（此处仅仅是做判断，子类调用事件时已经添加到viewContent中）
///   - bottomText: 底部文字
-(void)showContent:(NSString * _Nullable) topText view:(UIView * _Nullable) customView btm:(NSString *_Nullable) bottomText isMaxWidth:(BOOL)isMaxWidth customViewWidth:(CGFloat)width;

// 获取添加内容的最大宽度
-(CGFloat)getContenMaxWidth;
@end

NS_ASSUME_NONNULL_END
