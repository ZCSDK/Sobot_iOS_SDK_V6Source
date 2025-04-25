//
//  ZCTitleView.h
//  SobotKit
//
//  Created by lizh on 2022/9/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface ZCTitleView : UIView


/**
 设置聊天页面顶部标题
 @param nickTitle 客服昵称
 @param imageUrl 图片地址(支持本地和网络地址) 企业的logo URL 或者 客服和机器人的头像
 @param companyTitle 企业名称
 */
-(void)setNickTitle:(NSString *)nickTitle companyTitle:(NSString*)companyTitle title:(NSString *)title image:(NSString *)imageUrl topBarType:(int)topBarType;

// 刷新UI是否是横屏
-(void)setlayout:(BOOL)landspace;

-(void)setLogoImgLayrightItem:(NSArray*)rightItem leftItem:(NSArray *)leftItem;
@end


NS_ASSUME_NONNULL_END
