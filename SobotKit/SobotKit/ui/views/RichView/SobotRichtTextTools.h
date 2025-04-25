//
//  SobotRichtTextTools.h
//  SobotKit
//
//  Created by zhangxy on 2024/12/27.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SobotRichtTextTools : NSObject

// 计算高度
+ (CGFloat)heightForAttr:(NSAttributedString *)attr width:(CGFloat)width;

// 设置行高
+ (NSAttributedString*)addLineHeight:(CGFloat)lineHeight attr:(NSAttributedString*)attr;



/// 转换html文本为attrstring
/// - Parameter html: html description
+ (NSAttributedString*)htmlToAttr:(NSString *) html;


/// 获取富文本中的图片
/// - Parameter html: html description
+ (NSArray *)getHtmlImgUrls:(NSString *) html;


/**
 此处是异步加载所有图片，单个展示没有问题
 列表展示需要：提供同步方法提前生成NSAttributedString，然后异步下载图片
 */
+ (void)asyncHtmlToAttr:(NSString *) text result:(void(^)( NSAttributedString * _Nullable attr,  NSArray * _Nullable imgUrls, BOOL finish))block;



/// 如果已经有attr了，可以直接获取图片
/// - Parameters:
///   - text: 原始文本，用于下载完图片，从新生成attr
///   - att: 已经生成的attr
///   - block: 下载完成的回调
+ (void)downloadAttrImages:(NSString *) text attr:(NSAttributedString *) att result:(void(^)( NSAttributedString * _Nullable attr,  NSArray * _Nullable imgUrls, BOOL finish))block;


/// 给富文本添加图片的宽和字体格式
/// - Parameters:
///   - width: 内容的宽度，用于计算高和设置图片高度
///   - text: text description
+ (NSString*)addImgStyle:(CGFloat)width text:(NSString *) text;


/// 验证路径是否已经base64
/// - Parameter imageUrl: imageUrl description
+ (BOOL)isBase64Url:(NSString *) imageUrl;

// 中间转一道，不直接使用url作为 sdwebimage的key
+ (NSString*)storeKeyForUrl:(NSString *) imgUrl;


/// 下载单独图片
/// - Parameters:
///   - src: 图片路径
///   - block: block description
+ (void)downloadImageIfNeeded:(NSString *) src result:(void(^)(NSURL *fileURL))block;


/// 获取图片的本地路径，可能为空
/// - Parameter imageUrl: imageUrl description
+ (NSURL*)fileURLForImageKey:(NSString *) imageUrl;



/// 查询替换url
/// - Parameter html: 要替换的内容
+ (NSString *)searchHtmlUrl:(NSString *)html;

/// 查询替换电话
/// - Parameter html: 要替换的内容
+ (NSString *)searchHtmlTel:(NSString *)html;

/// 查询替换电话和url
/// - Parameter html: 要替换的内容
+(NSString *)searchUrlAndTel:(NSString *) html;

@end

NS_ASSUME_NONNULL_END
