//
//  ZCOrderCusFieldsDetailModel.h
//  SobotChatClient
//
//  Created by lizh on 2022/9/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZCOrderCusFieldsDetailModel : NSObject
@property(nonatomic,strong) NSString *parentDataId;
@property (nonatomic,copy) NSString *dataId;
@property (nonatomic,copy) NSString *dataName; // 分类名称
@property (nonatomic,copy) NSString *fieldId; // 分类的ID
@property (nonatomic,copy) NSString *dataValue;
@property (nonatomic,assign) BOOL isChecked;// 是否选中
@property (nonatomic,assign) int level;// 数据层级 0 第一级
-(id)initWithMyDict:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
