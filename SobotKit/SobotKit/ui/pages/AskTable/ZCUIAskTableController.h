//
//  ZCUIAskTableController.h
//  SobotKit
//
//  Created by lizh on 2022/9/15.
//

#import <SobotKit/SobotKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^TrunServerBlock)(BOOL isback);

@interface ZCUIAskTableController : SobotClientBaseController

@property (nonatomic,copy) TrunServerBlock trunServerBlock;
@property (nonatomic,strong) NSMutableDictionary *dict;
@property (nonatomic,assign) BOOL isclearskillId;// 点击返回清理掉 记录的技能组ID
@end

NS_ASSUME_NONNULL_END
