//
//  SobotRichtTextTools.m
//  SobotKit
//
//  Created by zhangxy on 2024/12/27.
//

#import "SobotRichtTextTools.h"
#import "ZCUIKitTools.h"
#import <CommonCrypto/CommonDigest.h>
#import <SobotCommon/SobotXHCacheManager.h>


#define TEST_MAX_FILE_EXTENSION_LENGTH (NAME_MAX - CC_MD5_DIGEST_LENGTH * 2 - 1)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
static inline NSString * _Nonnull kTempFileNameForKey(NSString * _Nullable key) {
    const char *str = key.UTF8String;
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
                          r[11], r[12], r[13], r[14], r[15]];
    return filename;
}
#pragma clang diagnostic pop

@implementation SobotRichtTextTools

// 计算高度
+ (CGFloat)heightForAttr:(NSAttributedString *)attr width:(CGFloat)width {
    CGSize contextSize = [attr boundingRectWithSize:(CGSize){width, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    return contextSize.height;
}

// 设置行高
+ (NSAttributedString*)addLineHeight:(CGFloat)lineHeight attr:(NSAttributedString*)attr {
    [attr enumerateAttribute:NSParagraphStyleAttributeName inRange:NSMakeRange(0, attr.length) options:(NSAttributedStringEnumerationLongestEffectiveRangeNotRequired) usingBlock:^(NSMutableParagraphStyle *style, NSRange range, BOOL * _Nonnull stop) {
        NSAttributedString *att = [attr attributedSubstringFromRange:range];
        // 忽略 table 标签
        if (![[att description] containsString:@"NSTextTableBlock"]) {
            style.lineSpacing = 8;
        }
    }];
    return attr;
}




+ (NSAttributedString*)htmlToAttr:(NSString *) html {
    NSData *data = [html dataUsingEncoding:NSUnicodeStringEncoding];
    NSDictionary *options = @{
        NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType
    };
    
    NSAttributedString *attr = [[NSAttributedString alloc] initWithData:data
                                                                options:options
                                                     documentAttributes:NULL
                                                                  error:nil];
    return attr;
}

+ (NSArray *)getHtmlImgUrls:(NSString *) text{
    NSString *pattern = @"<\\s*img\\s+[^>]*?src\\s*=\\s*[\'\"](.*?)[\'\"]\\s*(alt=[\'\"](.*?)[\'\"])?[^>]*?\\/?\\s*>";
    NSRegularExpression *regexImg = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray<NSTextCheckingResult *> *matches = [regexImg matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    
    
    NSMutableArray *imgs = [NSMutableArray array];
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match rangeAtIndex:1];
        NSString *imageUrl = [text substringWithRange:matchRange];
        [imgs addObject:imageUrl];
    }
    return imgs;
}


+ (NSString*)addImgStyle:(CGFloat)width text:(NSString *) text {
    NSString *html = [NSString stringWithFormat:@"<head><style>body%@img{width:%f !important;height:auto}</head></style>%@",@"{font-size:16px;}",width,text];
    
    //            直接删除img标签
    //            NSString *pattern = @"<img[^>]*>";
    //            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    //            NSString *resultString = [regex stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, self.length) withTemplate:@""];
    
    
    // 使用占位图
    
    NSString *pattern = @"<\\s*img\\s+[^>]*?src\\s*=\\s*[\'\"](.*?)[\'\"]\\s*(alt=[\'\"](.*?)[\'\"])?[^>]*?\\/?\\s*>";
    NSRegularExpression *regexImg = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *fileUrl = [[NSBundle mainBundle] URLForResource:@"zclaunch_default" withExtension:@"png"].absoluteString;
    
    NSString *replacement =[NSString stringWithFormat:@"<img src=\"%@\">", fileUrl];
    
    html = [regexImg stringByReplacingMatchesInString:html options:0 range:NSMakeRange(0, text.length) withTemplate:replacement];
    
    html = [self searchUrlAndTel:html];
    
    //    [self searchHtmlUrl:html];
    //  [self searchHtmlTel:html];
    return html;
}

+ (void)asyncHtmlToAttr:(NSString *) text result:(void(^)( NSAttributedString * _Nullable attr,  NSArray * _Nullable imgUrls, BOOL finish))block {
    
    NSString *pattern = @"<\\s*img\\s+[^>]*?src\\s*=\\s*[\'\"](.*?)[\'\"]\\s*(alt=[\'\"](.*?)[\'\"])?[^>]*?\\/?\\s*>";
    NSRegularExpression *regexImg = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray<NSTextCheckingResult *> *matches = [regexImg matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    
    if (matches.count==0) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSAttributedString *att = [self htmlToAttr:text];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) {
                    block(att, nil, YES);
                }
            });
        });
        return;
    }
    
    NSMutableArray *imgs = [NSMutableArray array];
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match rangeAtIndex:1];
        NSString *imageUrl = [text substringWithRange:matchRange];
        [imgs addObject:imageUrl];
    }
    
    
    dispatch_group_t group = dispatch_group_create();

    NSString *key = [self storeKeyForUrl:imgs.firstObject];
//    if(imgs.firstObject && ![[SDImageCache sharedImageCache].diskCache containsDataForKey:key]) {
    if(imgs.firstObject && ![[SobotXHCacheManager cacheManagerWithIdentifier:@"sobot" type:@".png"] existsDataForURL:[NSURL URLWithString:key]]) {
        
        dispatch_group_enter(group);

        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            直接删除img标签
//            NSString *pattern = @"<img[^>]*>";
//            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
//            NSString *resultString = [regex stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, self.length) withTemplate:@""];

            
            // 使用占位图
            NSString *fileUrl = [[NSBundle mainBundle] URLForResource:@"zclaunch_default" withExtension:@"png"].absoluteString;
            
            NSString *replacement =[NSString stringWithFormat:@"<img src=\"%@\">", fileUrl];

            NSString *resultString = [regexImg stringByReplacingMatchesInString:text options:0 range:NSMakeRange(0, text.length) withTemplate:replacement];
            
            NSAttributedString *att = [self htmlToAttr:resultString];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) {
                    block(att, nil, NO);
                }
                dispatch_group_leave(group);
            });
        });
    }
    
    __block NSString *html = text;
    for (NSInteger i=0; i<imgs.count; i++) {
        NSString *imageUrl = imgs[i];
        //        让base64图片直接加载
        //        BOOL isBase64Url = [imageUrl hasPrefix:@"data:image/"];
        //        if (isBase64Url) continue;
        
        dispatch_group_enter(group);
        [self downloadImageIfNeeded:imageUrl result:^(NSURL *URL) {
            if (URL) {
                NSArray *matches = [regexImg matchesInString:html options:0 range:NSMakeRange(0, html.length)];
                NSRange matchRange = [matches[i] rangeAtIndex:1];
                html = [html stringByReplacingOccurrencesOfString:imageUrl withString:URL.absoluteString options:NSCaseInsensitiveSearch range:matchRange];
            }
            dispatch_group_leave(group);
        }];
    }
    
    
    dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
        NSAttributedString *att = [self htmlToAttr:html];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block(att, imgs, YES);
            }
        });
    });
}



+ (void)downloadAttrImages:(NSString *) text attr:(NSAttributedString *) att result:(void(^)( NSAttributedString * _Nullable attr,  NSArray * _Nullable imgUrls, BOOL finish))block {
    
    NSString *pattern = @"<\\s*img\\s+[^>]*?src\\s*=\\s*[\'\"](.*?)[\'\"]\\s*(alt=[\'\"](.*?)[\'\"])?[^>]*?\\/?\\s*>";
    NSRegularExpression *regexImg = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray<NSTextCheckingResult *> *matches = [regexImg matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    
    if (matches.count==0) {
        if (block) {
            block(att, @[], YES);
        }
        return;
    }
    
    NSMutableArray *imgs = [NSMutableArray array];
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match rangeAtIndex:1];
        NSString *imageUrl = [text substringWithRange:matchRange];
        [imgs addObject:imageUrl];
    }
    
    
    dispatch_group_t group = dispatch_group_create();

    
    __block NSString *html = text;
    for (NSInteger i=0; i<imgs.count; i++) {
        NSString *imageUrl = imgs[i];
        //        让base64图片直接加载
        //        BOOL isBase64Url = [imageUrl hasPrefix:@"data:image/"];
        //        if (isBase64Url) continue;
        
        dispatch_group_enter(group);
        [self downloadImageIfNeeded:imageUrl result:^(NSURL *URL) {
            if (URL) {
                NSArray *matches = [regexImg matchesInString:html options:0 range:NSMakeRange(0, html.length)];
                NSRange matchRange = [matches[i] rangeAtIndex:1];
                html = [html stringByReplacingOccurrencesOfString:imageUrl withString:URL.absoluteString options:NSCaseInsensitiveSearch range:matchRange];
            }
            dispatch_group_leave(group);
        }];
    }
    
    
    dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
        NSAttributedString *att = [self htmlToAttr:html];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block(att, imgs, YES);
            }
        });
    });
}

+ (BOOL)isBase64Url:(NSString *) imageUrl {
    return [imageUrl hasPrefix:@"data:image/"];
}

// 中间转一道，不直接使用url作为 sdwebimage的key
+ (NSString*)storeKeyForUrl:(NSString *) imgUrl {
    // 重新命名图片url,不带后缀
    NSString *key = kTempFileNameForKey(imgUrl);
    
    // 随便加个后缀，对图片格式无影响。无后缀 <img src="file:///xxxx"> 加载不出图片。
    key = [key stringByAppendingString:@".png"];
    return key;
}

+ (void)downloadImageIfNeeded:(NSString *) src result:(void(^)(NSURL *fileURL))block {
    
    NSString *key = [self storeKeyForUrl:src];
   
    NSURL *fileURL = [self fileURLForImageKey:key];
    if (fileURL) {
        if (block) {
            block(fileURL);
        }
        return;
    }
    
    BOOL isBase64Url = [self isBase64Url:src];
    if (isBase64Url) {
        NSString *base64 = [src componentsSeparatedByString:@"base64,"].lastObject;
        NSData *data = [[NSData alloc] initWithBase64EncodedString:base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
        if (data) {
//            [[SDImageCache sharedImageCache] storeImageDataToDisk:data forKey:key];
            [[SobotXHCacheManager cacheManagerWithIdentifier:@"sobot" type:@".png"] storeData:data forURL:fileURL storeMemoryCache:YES];
        }
        
        NSURL *URL = [self fileURLForImageKey:key];
        if (block) {
            block(URL);
        }
        
    } else if ([src hasPrefix:@"http"]) {
        [SobotImageView dataWithContentsOfURL:[NSURL URLWithString:src] completionBlock:^(NSURL * _Nonnull url, NSData * _Nonnull imageData, NSError * _Nonnull error) {
            NSURL *storeURL = [NSURL URLWithString:key];
            if (imageData) {
                [[SobotXHCacheManager cacheManagerWithIdentifier:@"sobot" type:@".png"] storeData:imageData forURL:storeURL storeMemoryCache:YES];
//                UIImage *image = [SobotUIImageLoader sobotImageWithData:imageData];
//                if (image)
//                    [SobotXHCacheManager storeMemoryCacheWithImage:image forURL:storeURL];
            }
            
            NSURL *URL = [self fileURLForImageKey:key];
            if (block) {
                block(URL);
            }
        }];
//        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:self] completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
//            if (data) {
//                [[SDImageCache sharedImageCache] storeImageDataToDisk:data forKey:key];
//            }
//            NSURL *URL = [key fileURLForImageKey];
//            if (block) {
//                block(URL);
//            }
//        }];
    } else {
        if (block) {
            block(nil);
        }
    }
}

+ (NSURL*)fileURLForImageKey:(NSString *) imageUrl {
    if([[SobotXHCacheManager cacheManagerWithIdentifier:@"sobot" type:@".png"] existsDataForURL:[NSURL URLWithString:imageUrl]]){
        return [[SobotXHCacheManager cacheManagerWithIdentifier:@"sobot" type:@".png"] existsDataForURLToLocalPath:[NSURL URLWithString:imageUrl]];
    }
    
//    if([[SDImageCache sharedImageCache].diskCache containsDataForKey:imageUrl]) {
//        NSString *path = [[SDImageCache sharedImageCache] cachePathForKey:imageUrl];
//        return [NSURL fileURLWithPath:path];
//    }
    return nil;
}



+ (NSString *)searchHtmlUrl:(NSString *)html{
//    NSString *html1 = @"<div>\n"
//    "  <p>这是一个链接：http://example1.com</p>\n"
//    "  <a href=\"http://example.com\">http://example.com</a>\n"
//    "  <img src=\"http://example.com/image.jpg\" alt=\"Image\"/>\n"
//    "  <span>这是另一个链接：https://example2.org</span>\n"
//    "</div>";
    
    NSError *error = nil;
    NSString *pattern = @"(?!href=[\"']|src=[\"']|<a[^>]*>|<img[^>]*>)(https?://[\\w\\-]+(\\.[\\w\\-]+)+([\\w\\-.,@?^=%&:/~+#]*[\\w\\-@?^=%&/~+#])?)(?![\"']|.*?</a>|.*?/>)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    
    if (error) {
        NSLog(@"Error creating regex: %@", error);
        return html;
    }
    
    NSString *modifiedHtml = [regex stringByReplacingMatchesInString:html options:0 range:NSMakeRange(0, html.length) withTemplate:@"<a href=\"$1\">$1</a>"];
    
    NSLog(@"Modified HTML: %@", modifiedHtml);
    return modifiedHtml;
    
}

+ (NSString *)searchHtmlTel:(NSString *)html1{
    NSString *html = @"<div>\n"
    "日前网络流传一张文件图片，显示为深圳市规划和自然资源局关于停止执行《关于按照国家政策执行住宅户型比例要求的通知》的通知：18612345678 想，\n主要内容为<a href=\"tel:18633345678\">18633345678</a>，我是测试url：https://www.baidu.com，深规土[2010]668号文</p>\n"
//    "<a href=\"tel:18633345678\">18633345678</a>"
//    "  <span>联系电话：28612345678 嘴还，主要内容为，我是测试url：https://www.baidu.com，深规土[2010]668号文</span>\n"
//    "  <a href=\"tel:098-765-4321\">098-765-4321</a>\n"
//    "  <span>客服热线：1112223333</span>\n"
//    "  <span>客服热线：38612345678</span>\n"
//    "  <span>客服热线：http://example.com/666-789-0123</span>\n"
//    "  <a href=\"http://example.com/contact?phone=456-789-0123\">Contact Us</a>\n"
    " <p><img src=\"https://t7.baidu.com/it/u=2168645659,3174029352&fm=193&f=GIF\"></p><h3 class=\"emh3\">相关报道</h3><p>　　<a href=\"https://finance.eastmoney.com/a/202403263024233657.html\" target=\"_blank\" rel=\"noopener\" data-mce-href=\"https://finance.eastmoney.com/a/202403263024233657.html\"><strong>深圳楼市重磅！“70/90政策”取消？记者求证！</strong></a></p>"
    "</div>";
    
    html = [html stringByReplacingOccurrencesOfString:@"<a" withString:@"\n<a"];
    html = [html stringByReplacingOccurrencesOfString:@"</a>" withString:@"\n</a>"];
    NSError *error = nil;
    // 不是a标签中的电话号码
    NSString *pattern = @"(?!<a[^>]*>)\\b(\\d{3}-\\d{3}-\\d{4}|\\d{11}|\\d{10})\\b(?!.*?</a>)";
    
    // 不是连接和a标签中的电话
    pattern = @"(?!href=[\"']|<a[^>]*>|\\S*://|src=[\"'])\\b(\\d{3}-\\d{3}-\\d{4}|\\d{11}|\\d{10})\\b(?!.*?</a>|[\"']|.*?>)";
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    
    if (error) {
        NSLog(@"Error creating regex: %@", error);
        return html;
    }
    
    NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:html options:0 range:NSMakeRange(0, html.length)];
    
    NSMutableArray<NSString *> *phoneNumbers = [NSMutableArray array];
    
    for (NSTextCheckingResult *match in matches) {
        NSRange range = [match rangeAtIndex:1];
        NSString *phoneNumber = [html substringWithRange:range];
        [phoneNumbers addObject:phoneNumber];
    }
    
    NSLog(@"Phone numbers: %@", phoneNumbers);
    
    html = [regex stringByReplacingMatchesInString:html options:0 range:NSMakeRange(0, html.length) withTemplate:@"<a href=\"tel:$1\">$1</a>"];
    NSLog(@"替换后：\n%@",html);
    return html;
}


+(NSString *)searchUrlAndTel:(NSString *) html{
    NSString *html1 = @"<div>\n"
    "日前网络流传一张文件图片，显示为深圳市规划和自然资源局关于停止执行《关于按照国家政策执行住宅户型比例要求的通知》的通知：18612345678 想，\n主要内容为<a href=\"tel:18633345678\">18633345678</a>，我是测试url：https://www.baidu.com，深规土[2010]668号文</p>\n"
//    "<a href=\"tel:18633345678\">18633345678</a>"
//    "  <span>联系电话：28612345678 嘴还，主要内容为，我是测试url：https://www.baidu.com，深规土[2010]668号文</span>\n"
//    "  <a href=\"tel:098-765-4321\">098-765-4321</a>\n"
//    "  <span>客服热线：1112223333</span>\n"
//    "  <span>客服热线：38612345678</span>\n"
//    "  <span>客服热线：http://example.com/666-789-0123</span>\n"
//    "  <a href=\"http://example.com/contact?phone=456-789-0123\">Contact Us</a>\n"
    " <p><img src=\"https://t7.baidu.com/it/u=2168645659,3174029352&fm=193&f=GIF\"></p><h3 class=\"emh3\">相关报道</h3><p>　　<a href=\"https://finance.eastmoney.com/a/202403263024233657.html\" target=\"_blank\" rel=\"noopener\" data-mce-href=\"https://finance.eastmoney.com/a/202403263024233657.html\"><strong>深圳楼市重磅！“70/90政策”取消？记者求证！</strong></a></p>"
    "</div>";
    html = [html stringByAppendingString:html1];
    
    html = [html stringByReplacingOccurrencesOfString:@"<a" withString:@"\n<a"];
    html = [html stringByReplacingOccurrencesOfString:@"</a>" withString:@"\n</a>"];
    html = [html stringByReplacingOccurrencesOfString:@"<img" withString:@"\n<img"];
    html = [html stringByReplacingOccurrencesOfString:@"</p>" withString:@"\n</p>"];
    
    NSError *error = nil;
    NSString *pattern = @"(?!href=[\"']|src=[\"']|<a[^>]*>|<img[^>]*>)(https?://[\\w\\-]+(\\.[\\w\\-]+)+([\\w\\-.,@?^=%&:/~+#]*[\\w\\-@?^=%&/~+#])?)(?![\"']|.*?</a>|.*?>)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    
    if (!error) {
        html = [regex stringByReplacingMatchesInString:html options:0 range:NSMakeRange(0, html.length) withTemplate:@"<a href=\"$1\">$1</a>"];
    }
    
    
    NSString *telRegxStr = @"0+\\d{2}-\\d{8}|0+\\d{2}-\\d{7}|0+\\d{3}-\\d{8}|0+\\d{3}-\\d{7}|1+[34578]+\\d{9}|\\+\\d{2}1+[34578]+\\d{9}|400\\d{7}|400-\\d{3}-\\d{4}|\\d{11}|\\d{10}|\\d{8}|\\d{7}";
    
    pattern = [NSString stringWithFormat:@"(?!href=[\"']|<a[^>]*>|\\S*://|src=[\"'])\\b(%@)\\b(?!.*?</a>|[\"']|.*?>)",telRegxStr];
    NSRegularExpression *regexTel = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    
    if (!error) {
        html = [regexTel stringByReplacingMatchesInString:html options:0 range:NSMakeRange(0, html.length) withTemplate:@"<a href=\"$1\">$1</a>"];
    }
    html = [html stringByReplacingOccurrencesOfString:@"\n<a" withString:@"<a"];
    html = [html stringByReplacingOccurrencesOfString:@"\n</a>" withString:@"</a>"];
    html = [html stringByReplacingOccurrencesOfString:@"\n<img" withString:@"<img"];
    html = [html stringByReplacingOccurrencesOfString:@"\n</p>" withString:@"</p>"];
    return html;
}
@end
