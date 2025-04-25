//
//  ZCChatAiCustomCardPage.h
//  SobotKit
//
//  Created by lizh on 2025/3/20.
//

#import <UIKit/UIKit.h>

#import <SobotChatClient/SobotChatClient.h>
typedef void(^AiCustomCardPageClickBlock)(SobotChatMessage *megModel,SobotChatCustomCard *itemModel ,SobotChatCustomCardInfo *model ,SobotChatCustomCardMenu *menu,int type);

NS_ASSUME_NONNULL_BEGIN

@interface ZCChatAiCustomCardPage : UIView

@property (nonatomic,copy) AiCustomCardPageClickBlock orderSetClickBlock;
@property (nonatomic,assign) BOOL isHistory;
@property(nonatomic,strong) SobotChatMessage *megModel;
-(ZCChatAiCustomCardPage*)initActionSheet:(NSMutableArray *)array WithView:(UIView *)view cardModel:(SobotChatCustomCard*)cardModel;

- (void)showInView:(UIView *)view;

- (void)tappedCancel:(BOOL) isClose;

-(void)updataPage;
@end

NS_ASSUME_NONNULL_END
