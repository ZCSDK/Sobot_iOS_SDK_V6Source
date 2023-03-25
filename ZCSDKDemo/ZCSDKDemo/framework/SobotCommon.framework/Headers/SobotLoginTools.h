//
//  SobotLoginTools.h
//  SobotUI
//
//  Created by zhangxy on 2022/11/22.
//

#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>
#import "SobotLoginEntity.h"

NS_ASSUME_NONNULL_BEGIN

/// 登录
@interface SobotLoginTools : NSObject

/**
 *  单例
 *
 *  @return ZZLibNetworkTools创建的对象
 */
+(SobotLoginTools *) shareSobotLoginTools;

-(void)config:(NSString *) apiHost accessTokenHost:(NSString *) achost version:(NSString *)sdkVersion;

-(SobotLoginEntity *) getLoginInfo;

-(BOOL) isLogin;
-(BOOL) checkSupportV6;
-(NSString *)getTempId;
-(NSString *)getToken;
-(NSString *)getAccessToken;
-(NSString *)getServiceEmail;




/// 执行APP登录接口
/// - Parameters:
///   - loginAcount: 用户名
///   - loginPwd: 密码
///   - version: app版本
///   - loginStatue: 当前登录状态
///   - resultBlock: 结果
-(void)doAppLogin:(NSString *  _Nullable)loginAcount pwd:(NSString *  _Nullable)loginPwd appVersin:(NSString *)version status:(int) loginStatue result:(void (^)(NSInteger code, NSDictionary * _Nullable, NSString * _Nullable))resultBlock;

/// 登录
/// - Parameters:
///   - loginAcount: 账号
///   - loginPwd: 如果当前已经登录，不要传此参数
///   - token: 如果此参数不为空，并且loginPwd为空，会默认登录成功，直接获取用户信息
///   - resultBlock: 登录结果
-(void)doLogin:(NSString *  _Nullable)loginAcount pwd:(NSString *  _Nullable)loginPwd token:(NSString *  _Nullable)token result:(void (^)(NSInteger code, NSDictionary * _Nullable, NSString * _Nullable))resultBlock;


/// 获取登录信息
/// - Parameter resultBlock: 如果判断当前支持V6，会自动获取accessToken
-(void)getLoginUserInfo:(void (^)(NSInteger code,NSDictionary * _Nullable dict,NSString * _Nullable msg))resultBlock;


/// 获取当前的accesToken
/// - Parameters:
///   - token: 需要先登录成功
///   - resultBlock: 获取结果
-(void)getAccessToken:(NSString *) token result:(void(^)(NSInteger code,NSDictionary * _Nullable dict,NSString * _Nullable msg)) resultBlock;


/// 退出登录
/// - Parameters:
///   - loginUser: 当前账号
///   - resultBlock: 结果
-(void)logOut:(NSString *)loginUser result:(void(^)(NSInteger code,NSDictionary * _Nullable dict,NSString * _Nullable msg)) resultBlock;


@end

NS_ASSUME_NONNULL_END
