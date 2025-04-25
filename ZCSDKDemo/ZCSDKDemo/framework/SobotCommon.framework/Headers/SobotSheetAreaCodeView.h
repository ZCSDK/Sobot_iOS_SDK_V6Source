//
//  SobotSheetAreaCodeView.h
//  SobotCommon
//  选择手机区号组件，需要配置翻译“区号”，需要添加颜色SobotColorBgSub2Dark2
//  Created by zhangxy on 2024/6/30.
//


/**
 数据必须包含title
 用例：
 SobotSheetAreaCodeView *areaCodeView = [[SobotSheetAreaCodeView alloc] initAlterView:SobotLocalString(@"区号")];
 areaCodeView.listArray = self.timeZoneArray;
 areaCodeView.checkItem = self.checkTimeZone;
 areaCodeView.showType = 0;
 [areaCodeView hideTypeView];
 if(self.btnBgColor!=nil){
     [areaCodeView.btnCommit setBackgroundColor:self.btnBgColor];
 }
 if(self.btnTitleColor){
     [areaCodeView.btnCommit setTitleColor:self.btnTitleColor forState:0];
 }
 [areaCodeView showInView:nil];
 
 [areaCodeView setChooseResultBlock:^(id  _Nullable item, NSString * _Nonnull names, NSString * _Nonnull ids) {
     SLog(@"当前选择:%@", item);
 }];
 */
#import "SobotSheetSelectView.h"

NS_ASSUME_NONNULL_BEGIN

@interface SobotSheetAreaCodeView : SobotSheetSelectView

// 0、仅显示title,1:显示左phone_code和右title
@property(nonatomic,assign) int cellDataType;
@property(nonatomic,strong) UIColor *customColor;

@end

NS_ASSUME_NONNULL_END
