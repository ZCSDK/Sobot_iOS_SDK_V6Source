//
//  ZCChatStepOnCell.h
//  SobotKit
//
//  Created by lizh on 2024/4/3.
//

#import <UIKit/UIKit.h>
#import <SobotCommon/SobotCommon.h>
#import "ZCUIKitTools.h"
#import "ZCUICore.h"
#import <SobotChatClient/SobotChatClient.h>
NS_ASSUME_NONNULL_BEGIN

@protocol ZCChatStepOnCellDelegate <NSObject>

@optional
-(void)commitRealuateTagInfo:(NSString*)tagId tipStr:(NSString*)tipStr text:(NSString *)text msg:(SobotChatMessage *)msg answer:(NSString*)answer realuateTagLan:(NSString*)realuateTagLan realuateSubmitWordLan:(NSString *)realuateSubmitWordLan;

// 更新内容高度 刷新约束
-(void)updataHeight:(CGFloat)contentH;

-(void)setListViewScrollHeight:(CGFloat)H;

@end

@interface ZCChatStepOnCell : UIView
// init方法
+(ZCChatStepOnCell *)createViewWithMaxWidth:(CGFloat)maxWidth tempMsg:(SobotChatMessage*)tempMsg isRight:(BOOL)isRight delegate:(id)delegate;

@property(nonatomic,weak) id<ZCChatStepOnCellDelegate>delegate;

//@property(nonatomic,strong) UIView *topBgView;// 渐变主题色

/**
 *  最大宽度
 */
@property (nonatomic,assign) CGFloat  maxWidth;
@property(nonatomic,strong) SobotChatMessage *tempMessage;
-(void)layoutSubViewUI;

/// 添加页面到View
/// - Parameters:
///   - message: 当前显示的消息
-(void)dataToView:(SobotChatMessage*)tempMsg;

@end

NS_ASSUME_NONNULL_END
