//
//  SobotOrderRegionEntity.h
//  SobotOrderSDK
//
//  Created by zhangxy on 2024/3/26.
//

#import <SobotCommon/SobotCommon.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZCLeaveRegionEntity : SobotBaseEntity
@property(nonatomic,strong)NSString *curId; // 对应 "id": "101",
@property(nonatomic,strong)NSString *name;//": "110000",
@property(nonatomic,strong)NSString *pid;//": "北京市",
@property(nonatomic,assign)int level;//":1 #

@property(nonatomic,strong)NSString *province;//:"",
@property(nonatomic,strong)NSString *provinceCode;//":"",
@property(nonatomic,strong)NSString *city;//":"",
@property(nonatomic,strong)NSString *cityCode;//":""，
@property(nonatomic,strong)NSString *area;//":"",
@property(nonatomic,strong)NSString *areaCode;//":"",
@property(nonatomic,strong)NSString *street;//":"",
@property(nonatomic,strong)NSString *streetCode;//":""


@end

NS_ASSUME_NONNULL_END
