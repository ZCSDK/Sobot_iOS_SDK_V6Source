//
//  SobotHtmlFilter.m
//  SobotCommon
//
//  Created by lizh on 2022/9/6.
//

#import "SobotHtmlFilter.h"
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClientCache.h>
#import "ZCUIKitTools.h"
#import "ZCUICore.h"
@implementation SobotHtmlFilter

+(NSMutableAttributedString *) setHtml:(NSString *)text attrs:(NSMutableArray *) attrs view:(UILabel *) label  textColor:(UIColor*)textColor textFont:(UIFont*)textFont linkColor:(UIColor*)linkColor lineSpacing:(CGFloat)lineSpacing{
    __block NSMutableAttributedString  *str = nil;
    str = [[NSMutableAttributedString alloc] initWithString:text];
    // 先处理 ZCMLEmojiLabel 正则的匹配
    if ([label isKindOfClass:[SobotEmojiLabel class]]) {
        [label setTextColor:textColor];
        [((SobotEmojiLabel *)label) setLinkColor:linkColor];
        [((SobotEmojiLabel *)label) setText:str];
        str =[[NSMutableAttributedString alloc] initWithAttributedString:((SobotEmojiLabel *)label).attributedText];
    }
    [str addAttribute:NSFontAttributeName value:textFont range:NSMakeRange(0, str.length)];
    [str addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, str.length)];
    NSRange rangeB;
    NSRange rangeI;
    for (NSDictionary *item in attrs) {
        NSRange range = NSMakeRange([item[@"location"] intValue], [item[@"len"] intValue]);
        
        // 2.7.8 防止闪退
        NSUInteger strLength = range.location + range.length;
        BOOL isOK = NO;
        if (strLength<=str.length && str.length>range.location) {
            isOK = YES;
        }
        
        if([item[@"tag"] isEqual:@"B"]){
            if (isOK) {
                [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:textFont.pointSize weight:UIFontWeightBold] range:range];
                if (rangeI.location != NSNotFound) {
                    if (range.length == rangeI.length && range.location == rangeI.location ) {
                        CGAffineTransform matrix =  CGAffineTransformMake(1, 0, tanf(10 * (CGFloat)M_PI / 180), 1, 0, 0);
                        UIFont *font = [UIFont boldSystemFontOfSize:textFont.pointSize];
                        UIFontDescriptor *desc = [UIFontDescriptor fontDescriptorWithName:font.fontName matrix:matrix];
                        [str addAttribute:NSFontAttributeName value:[UIFont fontWithDescriptor:desc size:textFont.pointSize] range:range];
                    }
                }
                rangeB = range;
            }
        }
        
        if([item[@"tag"] isEqual:@"A"]){
            if(isOK){
                [str addAttribute:NSForegroundColorAttributeName value:linkColor range:range];
                if([label isKindOfClass:[SobotEmojiLabel class]]){
                    if(linkColor!=nil && ( CGColorEqualToColor(linkColor.CGColor,UIColorFromKitModeColor(SobotColorYellow).CGColor) || [SobotLocalString(@"留言") isEqual:item[@"href"]]|| [SobotLocalString(@"更新") isEqual:item[@"href"]])){
                        //加下划线
                        [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:range];
                        if ([SobotLocalString(@"留言") isEqual:item[@"href"]] || [SobotLocalString(@"更新") isEqual:item[@"href"]]) {
                             [str addAttribute:NSForegroundColorAttributeName value:[ZCUIKitTools zcgetRightChatColor] range:range];
                        }
                    }
                    [((SobotEmojiLabel *)label) addLinkToURL:[NSURL URLWithString:item[@"href"]] withRange:range];
                }else{
                    [str addAttribute:NSLinkAttributeName value:[NSURL URLWithString:item[@"href"]] range:range];
                }
            }
        }
        if([item[@"tag"] isEqual:@"I"]){
            if (isOK) {
                rangeI = range;
                CGAffineTransform matrix =  CGAffineTransformMake(1, 0, tanf(10 * (CGFloat)M_PI / 180), 1, 0, 0);
                UIFont *font = [UIFont systemFontOfSize:textFont.pointSize];
                
                if (rangeB.location != NSNotFound) {
                    if (rangeB.length == range.length && rangeB.location == range.location) {
                        font = [UIFont boldSystemFontOfSize:textFont.pointSize];
                    }
                }
                UIFontDescriptor *desc = [UIFontDescriptor fontDescriptorWithName:font.fontName matrix:matrix];
                [str addAttribute:NSFontAttributeName value:[UIFont fontWithDescriptor:desc size:textFont.pointSize] range:range];
            }
        }
        if([item[@"tag"] isEqual:@"IMG"]){
        }
    }
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing =  lineSpacing;//[ZCUIKitTools zcgetChatLineSpacing];
    if(SobotKitIsRTLLayout){
        [paragraphStyle setAlignment:NSTextAlignmentRight];
    }
    NSRange range = NSMakeRange(0, str.length);
    [str addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
    label.attributedText = str;
    return str;
}


+(NSMutableAttributedString *) setHtml:(NSString *)text attrs:(NSMutableArray *) attrs view:(UILabel *) label  textColor:(UIColor*)textColor textFont:(UIFont*)textFont linkColor:(UIColor*)linkColor{
    return [SobotHtmlFilter setHtml:text attrs:attrs view:label textColor:textColor textFont:textFont linkColor:linkColor lineSpacing:[ZCUIKitTools zcgetChatLineSpacing]];
}

+(NSMutableAttributedString *)setGuideHtml:(NSString *)text attrs:(NSMutableArray *) attrs view:(UILabel *) label  textColor:(UIColor*)textColor textFont:(UIFont*)textFont linkColor:(UIColor*)linkColor{
        __block NSMutableAttributedString  *str = nil;
        str = [[NSMutableAttributedString alloc] initWithString:text];
        // 先处理 ZCMLEmojiLabel 正则的匹配
        if ([label isKindOfClass:[SobotEmojiLabel class]]) {
            [label setTextColor:textColor];
            [((SobotEmojiLabel *)label) setLinkColor:linkColor];
            [((SobotEmojiLabel *)label) setText:str];
            str =[[NSMutableAttributedString alloc] initWithAttributedString:((SobotEmojiLabel *)label).attributedText];
        }
        [str addAttribute:NSFontAttributeName value:textFont range:NSMakeRange(0, str.length)];
        [str addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, str.length)];
        
        NSRange rangeB;
        NSRange rangeI;
        
        for (NSDictionary *item in attrs) {
            NSRange range = NSMakeRange([item[@"location"] intValue], [item[@"len"] intValue]);
            // 2.7.8 防止闪退
            NSUInteger strLength = range.location + range.length;
            BOOL isOK = NO;
            if (strLength<=str.length && str.length>range.location) {
                isOK = YES;
            }
            if([item[@"tag"] isEqual:@"B"]){
                if (isOK) {
                    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:textFont.pointSize weight:UIFontWeightBold] range:range];
                    if (rangeI.location != NSNotFound) {
                        if (range.length == rangeI.length && range.location == rangeI.location ) {
                            CGAffineTransform matrix =  CGAffineTransformMake(1, 0, tanf(10 * (CGFloat)M_PI / 180), 1, 0, 0);
                            UIFont *font = [UIFont boldSystemFontOfSize:textFont.pointSize];
                            UIFontDescriptor *desc = [UIFontDescriptor fontDescriptorWithName:font.fontName matrix:matrix];
                            [str addAttribute:NSFontAttributeName value:[UIFont fontWithDescriptor:desc size:textFont.pointSize] range:range];
                        }
                    }
                    rangeB = range;
                }
            }
            if([item[@"tag"] isEqual:@"A"]){
                if(isOK){
                    [str addAttribute:NSForegroundColorAttributeName value:linkColor range:range];
                    if([label isKindOfClass:[SobotEmojiLabel class]]){
                        if(linkColor!=nil && ( CGColorEqualToColor(linkColor.CGColor,UIColorFromKitModeColor(SobotColorYellow).CGColor) || [SobotLocalString(@"留言") isEqual:item[@"href"]]|| [SobotLocalString(@"更新") isEqual:item[@"href"]])){
                            //加下划线
                            [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:range];
                            if ([SobotLocalString(@"留言") isEqual:item[@"href"]] || [SobotLocalString(@"更新") isEqual:item[@"href"]]) {
                                 [str addAttribute:NSForegroundColorAttributeName value:[ZCUIKitTools zcgetRightChatColor] range:range];
                            }
                        }
                        [((SobotEmojiLabel *)label) addLinkToURL:[NSURL URLWithString:item[@"href"]] withRange:range];
                    }else{
                        [str addAttribute:NSLinkAttributeName value:[NSURL URLWithString:item[@"href"]] range:range];
                    }
                }
            }
            if([item[@"tag"] isEqual:@"I"]){
                if (isOK) {
                    rangeI = range;
                    CGAffineTransform matrix =  CGAffineTransformMake(1, 0, tanf(10 * (CGFloat)M_PI / 180), 1, 0, 0);
                    UIFont *font = [UIFont systemFontOfSize:textFont.pointSize];
                    if (rangeB.location != NSNotFound) {
                        if (rangeB.length == range.length && rangeB.location == range.location) {
                            font = [UIFont boldSystemFontOfSize:textFont.pointSize];
                        }
                    }
                    UIFontDescriptor *desc = [UIFontDescriptor fontDescriptorWithName:font.fontName matrix:matrix];
                    [str addAttribute:NSFontAttributeName value:[UIFont fontWithDescriptor:desc size:textFont.pointSize] range:range];
                }
            }
            if([item[@"tag"] isEqual:@"IMG"]){
                
            }
        }
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = [ZCUIKitTools zcgetChatGuideLineSpacing]; // 调整行间距
        NSRange range = NSMakeRange(0, str.length);
        [str addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
        label.attributedText = str;
        return str;
}


+(void) addChatTextToLabel:(UILabel *)label text:(NSString *)text chatLayout:(BOOL) isRight result:(nonnull void (^)(NSMutableAttributedString * _Nonnull))attrBlock{
    UIFont *textFont = [ZCUIKitTools zcgetKitChatFont];
    UIColor *textColor = [ZCUIKitTools zcgetLeftChatTextColor];
    UIColor *linkColor = [ZCUIKitTools zcgetChatLeftLinkColor];
    if(isRight){
        textColor = [ZCUIKitTools zcgetRightChatTextColor];
        linkColor = [ZCUIKitTools zcgetChatRightlinkColor];
    }
    
    return [self addTextToLabel:label text:text textColor:textColor textFont:textFont linkColor:linkColor result:attrBlock];
}

+(void) addTextToLabel:(UILabel *)label text:(NSString *)text textColor:(UIColor *)textColor textFont:(UIFont *)textFont linkColor:(UIColor *)linkColor  result:(void(^)(NSMutableAttributedString *attr)) attrBlock{
    
    [label setTextColor:textColor];
    if(sobotConvertToString(text).length == 0){
        return;
    }
    
    NSString *html = [self getFormatHTML:text textColor:textColor textFont:textFont linkColor:linkColor];
    // 先处理 ZCMLEmojiLabel 正则的匹配
    if ([label isKindOfClass:[SobotEmojiLabel class]]) {
        [((SobotEmojiLabel *)label) setLinkColor:linkColor];

        [((SobotEmojiLabel *)label) setText:[[NSAttributedString alloc] initWithData:[html dataUsingEncoding:NSUnicodeStringEncoding]
                                                                            options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,NSFontAttributeName:[UIFont systemFontOfSize:14], }
                                                                 documentAttributes:nil
                                                                              error:nil]];
    }
    else{
        label.attributedText = [[NSAttributedString alloc] initWithData:[html dataUsingEncoding:NSUnicodeStringEncoding]
                                                                       options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,NSFontAttributeName:[UIFont systemFontOfSize:10],NSForegroundColorAttributeName:UIColor.greenColor }
                                                            documentAttributes:nil
                                                                         error:nil];
    }
    if(attrBlock){
        attrBlock([label.attributedText mutableCopy]);
    }
}

+(NSString *) getFormatHTML:(NSString *) text  textColor:(UIColor *)textColor textFont:(UIFont *)textFont linkColor:(UIColor *)linkColor{
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
    
    // 追加样式
    NSString *html = @"<style>";
    if(textColor && textFont){
        html = [html stringByAppendingFormat:@"body{ font-family:'%@'; font-size:%fpx;color:%@; margin:0px; padding:0px;line-height:%fpx;}",textFont.fontName,textFont.pointSize,[ZCUIKitTools getHexStringByColor:textColor],[ZCUIKitTools zcgetChatLineSpacing]];
    }
    if(linkColor){
        html = [html stringByAppendingFormat:@"a{color:%@}",[ZCUIKitTools getHexStringByColor:linkColor]];
    }
    html = [html stringByAppendingString:@"</style>"];
    
    html = [html stringByAppendingString:text];
    return html;
}

+(NSMutableAttributedString *) createMutalText:(NSString *)text textColor:(UIColor *)textColor textFont:(UIFont *)textFont linkColor:(UIColor *)linkColor{
    // 追加样式
    NSString *html = [self getFormatHTML:text textColor:textColor textFont:textFont linkColor:linkColor];
    
    
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithData:[html dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType}  documentAttributes:nil error:nil];
    
    [attributedString beginEditing];
    
    // 文本段落排版格式
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle alloc] init];
    textStyle.lineBreakMode = NSLineBreakByWordWrapping; // 结尾部分的内容以……方式省略
    textStyle.lineSpacing = [ZCUIKitTools zcgetChatLineSpacing]; // 字体的行间
    
    NSMutableDictionary *textAttributes = [[NSMutableDictionary alloc] init];
    // NSParagraphStyleAttributeName 文本段落排版格式
    [textAttributes setValue:textStyle forKey:NSParagraphStyleAttributeName];
    // 设置段落样式
    [attributedString addAttributes:textAttributes range:NSMakeRange(0, attributedString.length)];
    
    [attributedString endEditing];
    return attributedString;
}
@end
