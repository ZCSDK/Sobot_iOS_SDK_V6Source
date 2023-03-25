//
//  ZCServiceCentreVC.h
//  SobotKit
//
//  Created by lizh on 2022/9/26.
//

#import <SobotKit/SobotKit.h>
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClient.h>
NS_ASSUME_NONNULL_BEGIN

@interface ZCServiceCentreVC : SobotClientBaseController
@property (nonatomic,assign) BOOL isPush;// 是否是push 进来的
// 留言代理
@property(nonatomic,assign) id<ZCChatControllerDelegate> chatdelegate;
@property(nonatomic,strong) void (^OpenZCSDKTypeBlock)(SobotClientBaseController *object);
@property(nonatomic,strong) ZCKitInfo *kitInfo;

/**
 *  初始化
 *
 *  @param info
 *
 *  @return ZCServiceCentreVC
 */
-(id)initWithInitInfo:(ZCKitInfo *)info;
@end

NS_ASSUME_NONNULL_END
