//
//  ZCChatShowDetailView.h
//  SobotKit
//
//  Created by zhangxy on 2023/11/23.
//

#import <UIKit/UIKit.h>
#import <SobotCommon/SobotCommon.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZCChatShowDetailView : UIView

-(ZCChatShowDetailView *)initChatDetailViewWithModel:(SobotChatMessage *)model obj:(id _Nullable) obj;

//- (void)showInView:(UIView *)view;

#pragma mark -- 关闭页面
- (void)dismissView;

@end

NS_ASSUME_NONNULL_END
