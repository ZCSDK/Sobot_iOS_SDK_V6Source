//
//  ZCAskCusFieldView.h
//  SobotKit
//
//  Created by lizh on 2024/11/11.
//

#import <UIKit/UIKit.h>
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClient.h>


NS_ASSUME_NONNULL_BEGIN
typedef void(^ZCAskCusFieldViewBcakBlock)(NSString *msg);
@interface ZCAskCusFieldView : UIView

@property (nonatomic,assign) BOOL isPush;
@property(nonatomic,strong) ZCOrderCusFiledsModel *preModel;
// 新版编辑model
@property(nonatomic,strong) SobotFormNodeRespVosModel *cusModel;
@property (nonatomic, strong)  void(^orderCusFiledCheckBlock) (ZCOrderCusFieldsDetailModel *model,NSMutableArray *arr);
@property(nonatomic,copy)ZCAskCusFieldViewBcakBlock backBlock;
@property(nonatomic,strong) NSMutableArray *listArray;

@end

NS_ASSUME_NONNULL_END
