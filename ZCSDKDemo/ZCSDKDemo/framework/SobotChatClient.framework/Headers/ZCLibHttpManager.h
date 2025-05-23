//
//  HttpManager.h
//  SobotSDK
//
//  Created by 张新耀 on 15/8/4.
//  Copyright (c) 2015年 sobot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SobotChatClient/ZCLibHttpConstants.h>

/**
 *  网络请求管理
 */
@interface ZCLibHttpManager : NSObject


/**
 *  异步Get请求
 *
 *  @param stringURL 请求地址
 */
+(void)get:(NSString *) stringURL
     start:(StartBlock) startBlock
    finish:(FinishBlock) finishBlock
  complete:(CompleteBlock) completeBlock
      fail:(FailBlock) failBlock;

+(void)get:(NSString *) stringURL
     start:(StartBlock) startBlock
    finish:(FinishBlock) finishBlock
  complete:(CompleteBlock) completeBlock
      fail:(FailBlock) failBlock
  progress:(ProgressBlock) progressBlock;


/**
 *  异步post请求
 *
 *  @param stringURL 请求URL
 *  @param dict post参数，暂未处理文件
 */
+(void)post:(NSString *) stringURL
      param:(NSDictionary *) dict
    timeOut:(CGFloat) timeOut
      start:(StartBlock) startBlock
     finish:(FinishBlock) finishBlock
   complete:(CompleteBlock) completeBlock
       fail:(FailBlock) failBlock;

+(void)post:(NSString *) stringURL
      param:(NSDictionary *) dict
      start:(StartBlock) startBlock
     finish:(FinishBlock) finishBlock
   complete:(CompleteBlock) completeBlock
       fail:(FailBlock) failBlock
   progress:(ProgressBlock) progressBlock;

+(void)post:(NSString *) stringURL
      param:(NSDictionary *) dict
    timeOut:(CGFloat) timeOut
      start:(StartBlock) startBlock
     finish:(FinishBlock) finishBlock
   complete:(CompleteBlock) completeBlock
       fail:(FailBlock) failBlock
   progress:(ProgressBlock) progressBlock;


+(void)post:(NSString *) stringURL
      param:(NSDictionary *) dict
      model:(int)model
    timeOut:(CGFloat) timeOut
      start:(StartBlock) startBlock
     finish:(FinishBlock) finishBlock
   complete:(CompleteBlock) completeBlock
       fail:(FailBlock) failBlock
   progress:(ProgressBlock) progressBlock;

+(void)stream:(NSString *) stringURL
      param:(NSDictionary *) dict
    timeOut:(CGFloat) timeOut
      start:(StartBlock) startBlock
     finish:(FinishBlock) finishBlock
   complete:(CompleteBlock) completeBlock
       fail:(FailBlock) failBlock
     progress:(ProgressBlock) progressBlock;

+(ZCLibHttpManager *) getZCHttpManager;

// 取消 当前对应的文件上传的请求 删除缓存
-(void)cancelConnectMsgId:(NSString *)msgid;

// 关闭
-(void)closeConnectMsgId:(NSString *)msgid;

// 添加缓存
-(void)addCache:(NSDictionary*)dict URL:(NSString *)url Connect:(NSURLConnection*)connect MsgId:(NSString *)msgid;

@end
