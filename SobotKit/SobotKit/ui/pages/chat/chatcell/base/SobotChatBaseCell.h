//
//  SobotChatBaseCell.h
//  SobotKit
//  聊天底层父类，处理时间和内部的外边距
//  Created by zhangxy on 2025/1/17.
//

#import <UIKit/UIKit.h>
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClient.h>
#import "ZCUIKitTools.h"
#import "ZCUICore.h"


// 气泡外部间隔
#define SobotChatMarginHSpace 16
#define SobotChatMarginVSpace 12

// 气泡内容四周的边距
#define SobotChatPaddingVSpace 12
#define SobotChatPaddingHSpace 16

NS_ASSUME_NONNULL_BEGIN

@interface SobotChatBaseCell : UITableViewCell

/**
 *  显示时间
 */
@property (nonatomic,strong) UILabel *lblTime;

/**
 所有内容，均添加到editView中
 此view的上下左右边界父类确定
 */
@property (nonatomic,strong) UIView  *chatView;

// 内容部分左右间距
@property (nonatomic,strong) NSLayoutConstraint  *layoutChatViewPL;
@property (nonatomic,strong) NSLayoutConstraint  *layoutChatViewPR;



/**
 *  当前展示的消息体
 */
@property (nonatomic,strong) SobotChatMessage         *tempModel;

/**
 *  是否是右边
 */
@property (nonatomic,assign) BOOL                     isRight;
@property (nonatomic,assign) BOOL                     isShowHeader;

/**
 *  最大宽度
 */
@property (nonatomic,assign) CGFloat                  maxWidth;

/**
 *  页面的宽度
 */
@property (nonatomic,assign) CGFloat                  viewWidth;


-(void)createItemsView;


-(void)initDataToView:(SobotChatMessage *) message time:(NSString *) showTime;

@end

NS_ASSUME_NONNULL_END
