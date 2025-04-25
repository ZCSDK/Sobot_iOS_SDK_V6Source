//
//  ZCLanguageView.h
//  SobotKit
//
//  Created by lizh on 2024/10/16.
//

#import <UIKit/UIKit.h>
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClient.h>
#import <SobotChatClient/ZCLanguageModel.h>
NS_ASSUME_NONNULL_BEGIN

@interface ZCLanguageView : UIView
@property (nonatomic,assign) BOOL isPush;
@property (nonatomic, strong)  void(^orderCusFiledCheckBlock) (ZCLanguageModel *model,NSMutableArray *arr);
@property(nonatomic,strong) NSMutableArray *listArray;
@property(nonatomic,strong) NSMutableArray *searchArray;
-(void)updataPage;
@end

NS_ASSUME_NONNULL_END
