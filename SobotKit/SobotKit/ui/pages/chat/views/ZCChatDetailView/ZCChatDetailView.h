//
//  ZCChatDetailView.h
//  SobotKit
//
//  Created by lizh on 2023/11/17.
//

#import <UIKit/UIKit.h>
#import <SobotCommon/SobotCommon.h>
NS_ASSUME_NONNULL_BEGIN

@interface ZCChatDetailView : UIView

-(ZCChatDetailView *)initChatDetailViewWithModel:(SobotChatMessage *)model withView:(UIView *)view;

- (void)showInView:(UIView *)view;
- (void)closeSheetView;
- (void)updateChangeFrame:(CGFloat)y;
@end

NS_ASSUME_NONNULL_END
