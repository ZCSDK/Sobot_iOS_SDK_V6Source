//
//  ZCUIAskSelectionView.h
//  SobotKit
//
//  Created by lizh on 2024/11/7.
//  询前表单 单选页面

#import <UIKit/UIKit.h>
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClient.h>
#import <SobotChatClient/ZCLanguageModel.h>
NS_ASSUME_NONNULL_BEGIN

@interface ZCUIAskSelectionView : UIView
@property (nonatomic,assign) BOOL isPush;
@property (nonatomic, strong)  void(^orderCusFiledCheckBlock) (ZCLanguageModel *model,NSMutableArray *arr);
@property(nonatomic,strong) NSMutableArray *listArray;
@property(nonatomic,strong) NSMutableArray *searchArray;
-(void)updataPage;
-(void)setTitle:(NSString *)title;
@end

NS_ASSUME_NONNULL_END
