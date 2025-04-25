//
//  SobotOrderRegionEntity.m
//  SobotOrderSDK
//
//  Created by zhangxy on 2024/3/26.
//

#import "ZCLeaveRegionEntity.h"

@implementation ZCLeaveRegionEntity
-(id)initWithMyDict:(NSDictionary *)dict{
    self=[super initWithMyDict:dict];
    if(self){
        _curId = sobotConvertToString(dict[@"id"]);
    }
    return self;
}
@end
