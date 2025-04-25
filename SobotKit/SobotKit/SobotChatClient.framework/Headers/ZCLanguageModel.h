//
//  ZCLanguageModel.h
//  SobotChatClient
//
//  Created by lizh on 2024/10/16.
//

#import <SobotCommon/SobotCommon.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZCLanguageModel : SobotBaseEntity
@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSString *code;
@property(nonatomic,assign)int lan;

//{
//    "code": 1,
//    "data": [
//        {
//            "name": "简体中文",
//            "code": "zh",
//            "lan": 0
//        },
//        {
//            "name": "繁體中文",
//            "code": "en",
//            "lan": 1
//        },

@end

NS_ASSUME_NONNULL_END
