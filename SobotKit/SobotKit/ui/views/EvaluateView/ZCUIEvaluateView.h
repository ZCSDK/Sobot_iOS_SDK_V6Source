//
//  ZCUIEvaluateView.h
//  SobotKit
//
//  Created by lizh on 2022/9/19.
//

#import <UIKit/UIKit.h>
#import <SobotChatClient/SobotChatClient.h>
NS_ASSUME_NONNULL_BEGIN

/**
 * RobotChangeTag ENUM
 */
typedef NS_ENUM(NSInteger, RobotChangeTag) {
    /** 已解决 */
    RobotChangeTag1=1,
    /** 未解决 */
    RobotChangeTag2=2,
    /** 暂不评价 */
    RobotChangeTag3=3,
};

@protocol ZCUIEvaluateViewDelegate <NSObject>

@optional

-(void) actionSheetClickWithDic:(NSDictionary *)ModelDic;

/**
 *  感谢您的反馈
 */
- (void)thankFeedBack:(ZCUICustomActionSheetModel *)model;

/**
 *  不能连续创建 记录当前页面已销毁
 *  type:0,关闭页面，1点击关闭，2点击暂不评价
 */
-(void)dimissViews:(ZCUICustomActionSheetModel *)model type:(int) type;

@end

@interface ZCUIEvaluateView : UIView

@property(nonatomic,weak) id<ZCUIEvaluateViewDelegate> delegate;


/// 创建 评价页面
/// @param evaluateModel 评价model
/// @param config zclibconfig
/// @param view 将要添加在view上
-(ZCUIEvaluateView*)initActionSheetWith:(ZCUICustomActionSheetModel *)evaluateModel Cofig:(ZCLibConfig *)config cView:(UIView *)view;

/**
 *  显示弹出层
 *  @param  view  添加到指定的view
 */
- (void)showInView:(UIView *)view;


/**
 *  关闭弹出层
 */
- (void)dismissView;
@end

NS_ASSUME_NONNULL_END
