//
//  ZCKitInitInfo.m
//  SobotKit
//
//  Created by zhangxy on 15/11/13.
//  Copyright © 2015年 zhichi. All rights reserved.
//

#import "ZCKitInfo.h"
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClient.h>
#import <objc/runtime.h>

@implementation ZCKitInfo

-(id)init{
    self=[super init];
    if(self){
        _isShowTansfer = YES;
        _isOpenRecord  = YES;
        _ishidesBottomBarWhenPushed = YES;
        _leaveCompleteCanReply = YES;
        _useDefaultDarkTheme = YES;
    }
    return self;
}

-(void)setIsUseImagesxcassets:(BOOL)isUseImagesxcassets{
    _isUseImagesxcassets = isUseImagesxcassets;
//    [SobotCache shareSobotCache].isUseImagesxcassets = _isUseImagesxcassets;
}

-(void)setThemeStyle:(NSInteger)themeStyle{
    _themeStyle = themeStyle;
    if(themeStyle >0){
        [SobotCache shareSobotCache].themeMode = themeStyle;
    }
}

-(void)setTelRegular:(NSString *)telRegular{
    _telRegular = telRegular;
    [[NSUserDefaults standardUserDefaults] setObject:sobotConvertToString(_telRegular) forKey:@"sobot_telRegular"];
}

-(void)setUrlRegular:(NSString *)urlRegular{
    _urlRegular = urlRegular;
    [[NSUserDefaults standardUserDefaults] setObject:sobotConvertToString(_urlRegular) forKey:@"sobot_urlRegular"];
}

-(id)jsonValueToDict:(NSDictionary *)dict{
    if(self){
        @try {
            for (NSString *key in [self properties]) {
                if (dict[key]) {
                    if(sobotIsNull(dict[key])){
                        [self setValue:@"" forKey:key];
                    }else{
                        [self setValue:dict[key] forKey:key];
                    }
                }
            }
            
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
    return self;
}


- (NSArray *)properties
{
    unsigned int outCount = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    
    NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:outCount];
    for (int i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *name = property_getName(property);
        [arrayM addObject:[NSString stringWithUTF8String:name]];
    }
    free(properties);
    
    return arrayM;
}
@end


@implementation ZCProductInfo

-(id)init{
    self=[super init];
    if(self){
        
    }
    return self;
}

@end

@implementation ZCOrderGoodsModel

+(NSString *)getOrderStatusMsg:(int)status{
    NSString *str = @"";//ZCSTLocalString(@"其它");
    switch (status) {
        case 1:
        str = SobotKitLocalString(@"待付款");
        break;
      case 2:
        str = SobotKitLocalString(@"待发货");
        break;
        case 3:
        str = SobotKitLocalString(@"运输中");
        break;
        case 4:
        str = SobotKitLocalString(@"派送中");
        break;
        case 5:
        str = SobotKitLocalString(@"已完成");
        break;
        case 6:
        str = SobotKitLocalString(@"待评价");
            break;
        case 7:
        str = SobotKitLocalString(@"已取消");
            break;
        default:
            break;
    }
    return str;
}



@end
