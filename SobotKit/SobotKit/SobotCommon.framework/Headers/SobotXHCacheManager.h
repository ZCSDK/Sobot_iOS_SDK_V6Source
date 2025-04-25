//
//  XHCacheManager.h
//  XHImageViewer
//
//  Created by 曾 宪华 on 14-2-18.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SobotXHCacheManager : NSObject

// instancetype
+ (instancetype)shareCacheManager;
+ (instancetype)cacheManagerWithIdentifier:(NSString *)identifier;
// mineType 后缀名，不添加默认没有
+ (instancetype)cacheManagerWithIdentifier:(NSString *)identifier type:(NSString *)mineType;



// file/url to uer
+ (void)limitNumberOfCacheFiles:(NSInteger)numberOfCacheFiles;
- (void)limitNumberOfCacheFiles:(NSInteger)numberOfCacheFiles;

+ (void)removeCacheForURL:(NSURL *)url;
- (void)removeCacheForURL:(NSURL *)url;

+ (void)removeCacheDirectory;
- (void)removeCacheDirectory;

// NSData caching
+ (void)storeData:(NSData *)data forURL:(NSURL *)url storeMemoryCache:(BOOL)storeMemoryCache;
- (void)storeData:(NSData *)data forURL:(NSURL *)url storeMemoryCache:(BOOL)storeMemoryCache;

+ (NSData *)localCachedDataWithURL:(NSURL *)url;
- (NSData *)localCachedDataWithURL:(NSURL *)url;

+ (NSData *)dataWithURL:(NSURL *)url storeMemoryCache:(BOOL)storeMemoryCache;
- (NSData *)dataWithURL:(NSURL *)url storeMemoryCache:(BOOL)storeMemoryCache;

+ (BOOL)existsDataForURL:(NSURL *)url;
- (BOOL)existsDataForURL:(NSURL *)url;
+ (NSURL *)existsDataForURLToLocalPath:(NSURL *)url;
- (NSURL *)existsDataForURLToLocalPath:(NSURL *)url;

// UIImage caching
+ (void)storeMemoryCacheWithImage:(UIImage *)image forURL:(NSURL *)url;
- (void)storeMemoryCacheWithImage:(UIImage *)image forURL:(NSURL *)url;

+ (UIImage *)imageWithURL:(NSURL *)url storeMemoryCache:(BOOL)storeMemoryCache;
- (UIImage *)imageWithURL:(NSURL *)url storeMemoryCache:(BOOL)storeMemoryCache;

@end
