//
//  ZCUIAskTableView.h
//  SobotKit
//
//  Created by lizh on 2024/11/6.
//  询前表单弹窗页面

#import <UIKit/UIKit.h>
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClient.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^TrunServerBlock)(BOOL isback);
@interface ZCUIAskTableView : UIView
@property (nonatomic,assign) BOOL isPush;
//@property (nonatomic, strong)  void(^orderCusFiledCheckBlock) (ZCLanguageModel *model,NSMutableArray *arr);

// 当前展示的自定义字段的集合
@property(nonatomic,strong) NSMutableArray *listArray;
// 所有的自定义字段集合
@property(nonatomic,strong)NSMutableArray *coustomArr;
// 全部的数据
@property(nonatomic,strong)NSDictionary *dict;

@property (nonatomic,copy) TrunServerBlock trunServerBlock;

@property (nonatomic,assign) BOOL isclearskillId;// 点击返回清理掉 记录的技能组ID
// 刷新页面高度
-(void)updataPage;
@end

NS_ASSUME_NONNULL_END
