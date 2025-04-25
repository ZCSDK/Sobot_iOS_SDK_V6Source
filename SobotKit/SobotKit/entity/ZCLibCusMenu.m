//
//  ZCLibCusMenu.m
//  SobotKit
//
//  Created by lizhihui on 2018/5/25.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import "ZCLibCusMenu.h"
#import <SobotCommon/SobotCommon.h>
@implementation ZCLibCusMenu

-(id)initWithMyDict:(NSDictionary *)dict{
    self=[super initWithMyDict:dict];
    if(self){
        @try {
            _title      = sobotConvertToString(dict[@"lableName"]);
            _url  = sobotConvertToString(dict[@"lableLink"]);
            _lableId = [sobotConvertToString(dict[@"lableId"]) integerValue];
            _imgName = sobotConvertToString(dict[@"imgName"]);
            _imgNamePress = sobotConvertToString(dict[@"imgNamePress"]);
            _paramFlag = sobotConvertToString([dict objectForKey:@"paramFlag"]);
            _menuid      = sobotConvertToString(dict[@"id"]);
            
            if(_menuType == ZCCusMenuTypeLeave){
                _imgName = @"icon_fast_leave";
            }else if(_menuType == ZCCusMenuTypeCloseChat){
                _imgName = @"icon_fast_close";
            }else if(_menuType == ZCCusMenuTypeOpenUrl){
                _imgName = @"icon_fast_link";
            }else if(_menuType == ZCCusMenuTypeConnectUser){
                _imgName = @"icon_fast_transfer";
            }else if(_menuType == ZCCusMenuTypeEvaluetion){
                _imgName = @"icon_fast_evalue";
            }else if(_menuType == ZCCusMenuTypeSendMessage){
                _imgName = @"icon_fast_chat";
            }else if(_menuType == ZCCusMenuTypeSendRobotMessage){
                _imgName = @"icon_fast_question";
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
    return self;
}

@end
