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
