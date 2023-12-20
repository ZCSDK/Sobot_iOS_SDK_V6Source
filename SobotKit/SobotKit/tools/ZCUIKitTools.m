//
//  ZCUIKitTools.m
//  SobotKit
//
//  Created by zhangxy on 2022/9/1.
//

#import "ZCUIKitTools.h"
#import "ZCUICore.h"
#import <SobotChatClient/SobotChatClientDefines.h>
#import <SobotCommon/SobotCommon.h>
@implementation ZCUIKitTools

+(SobotThemeMode ) getZCThemeStyle{
    if([ZCUICore getUICore].kitInfo.themeStyle > 0){
        [SobotCache shareSobotCache].themeMode = [ZCUICore getUICore].kitInfo.themeStyle;
    }
    
    return [SobotUITools getSobotThemeMode];
}


+(ZCKitInfo *)getZCKitInfo{
    return [ZCUICore getUICore].kitInfo;
}

+(BOOL) zcgetOpenRecord{
    ZCKitInfo * configModel = [self getZCKitInfo];
    if (configModel!= nil) {
        return configModel.isOpenRecord;
    }
    return YES;
}

+(NSString *) zcgetTelRegular{
    ZCKitInfo * configModel = [self getZCKitInfo];
    if (configModel!= nil && sobotConvertToString(configModel.telRegular).length > 0) {
        return configModel.telRegular;
    }
    return @"0+\\d{2}-\\d{8}|0+\\d{2}-\\d{7}|0+\\d{3}-\\d{8}|0+\\d{3}-\\d{7}|1+[34578]+\\d{9}|\\+\\d{2}1+[34578]+\\d{9}|400\\d{7}|400-\\d{3}-\\d{4}|\\d{11}|\\d{10}|\\d{8}|\\d{7}";
}


+(NSString *)zcgetUrlRegular{
    NSString*urlRegex = ([ZCUICore getUICore].kitInfo!=nil && [ZCUICore getUICore].kitInfo.urlRegular!=nil && [ZCUICore getUICore].kitInfo.urlRegular.length>0) ? [ZCUICore getUICore].kitInfo.urlRegular:@"(https?|ftp|file)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]";
    return urlRegex;
}

+ (int)IntervalDay:(NSString *)filePath
{
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    // [SobotLog logDebug:@"create date:%@",[attributes fileModificationDate]];
    NSString *dateString = [NSString stringWithFormat:@"%@",[attributes fileModificationDate]];
    
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    
    NSDate *formatterDate = [inputFormatter dateFromString:dateString];
    
    // 矫正时区
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: formatterDate];
    NSDate *localeDate = [formatterDate  dateByAddingTimeInterval: interval];
    
    unsigned int unitFlags = NSDayCalendarUnit;
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *d = [cal components:unitFlags fromDate:localeDate toDate:[NSDate date] options:0];
    
    
    // [SobotLog logDebug:@"%d,%d,%d,%d",[d year],[d day],[d hour],[d minute]];
    
    int result = (int)d.day;
    
    //    return 0;
    return result;
}


#define imageVALIDMINUTES 3
#define voiceVALIDMINUTES 3
+(BOOL)imageIsValid:(NSString *)filePath{
    if ([self IntervalDay:filePath] < imageVALIDMINUTES) { //VALIDDAYS = 有效时间分钟
        return YES;
    }
    return NO;
}

+(BOOL)videoIsValid:(NSString *)filePath{
    if ([self IntervalDay:filePath] < voiceVALIDMINUTES) { //VALIDDAYS = 有效时间分钟
        return YES;
    }
    return NO;
}
+(UIColor *)getNotifitionTopViewBgColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.notificationTopViewBgColor && ![self useDefaultThemeColor]) {
        return configModel.notificationTopViewBgColor;
    }
    return UIColorFromKitModeColor(SobotColorYellowLight); // UIColorFromRGB(noticBgColor);
}


+(UIColor *)zcgetTopViewBgColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.topViewBgColor && ![self useDefaultThemeColor]) {
        return configModel.topViewBgColor;
    }
    return UIColorFromKitModeColor(SobotColorBanner); // UIColorFromRGB(noticBgColor);
}

+(UIColor *)zcgetLeaveTitleTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.leaveTitleTextColor && ![self useDefaultThemeColor]) {
        return configModel.leaveTitleTextColor;
    }
    return UIColorFromKitModeColor(SobotColorWhite); // UIColorFromRGB(noticBgColor);
}

+(UIColor *)getNotifitionTopViewLabelColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.notificationTopViewLabelColor && ![self useDefaultThemeColor]) {
        return configModel.notificationTopViewLabelColor;
    }
    return UIColorFromKitModeColor(SobotColorYellowDark);
}
+(BOOL) zcgetPhotoLibraryBgImage{
    ZCKitInfo * configModel = [self getZCKitInfo];
    if (configModel!= nil) {
        return configModel.isSetPhotoLibraryBgImage;
    }
    return NO;
}

+(UIFont *)zcgetTitleFont{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.titleFont!=nil){
        return configModel.titleFont;
    }
    return SobotFontBold18;
}

+(UIFont *)zcgetSubTitleFont{
    
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.subTitleFont!=nil){
        return configModel.subTitleFont;
    }
    return SobotFontBold14;
    
}

+(UIFont *)zcgetTitleGoodsFont{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.goodsTitleFont) {
        return configModel.goodsTitleFont;
    }
    return SobotFontBold14;
}


+(UIFont *)zcgetGoodsDetFont{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel !=nil && configModel.goodsDetFont) {
        return configModel.goodsDetFont;
    }
    return SobotFont14;
}


+(UIFont *)zcgetListKitTitleFont{
    
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.listTitleFont!=nil){
        return configModel.listTitleFont;
    }
    return SobotFont14;
}
+(UIFont *)zcgetListKitDetailFont{
    
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.listDetailFont!=nil){
        return configModel.listDetailFont;
    }
    return SobotFont12;
}


+(UIFont *)zcgetListKitTimeFont{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.listTimeFont!=nil){
        return configModel.listTimeFont;
    }
    return SobotFont11;
}
+(UIFont *)zcgetKitChatFont{
    
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.chatFont!=nil){
        return configModel.chatFont;
    }
    return SobotFont14;
}

+(UIFont *)zcgetVoiceButtonFont{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.voiceButtonFont!=nil){
        return configModel.voiceButtonFont;
    }
    return SobotFont15;
}


+(UIFont *)zcgetscTopTextFont{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.scTopTextFont && ![self useDefaultThemeColor]) {
        return configModel.scTopTextFont;
    }
    return SobotFontBold17;
}

+(UIColor *)zcgetscTopTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.scTopTextColor && ![self useDefaultThemeColor]) {
        return configModel.scTopTextColor;
    }
    return UIColorFromKitModeColor(SobotColorTextMain);
}

// 暗黑模式时，是否使用自定义颜色
+(BOOL) useDefaultThemeColor{
    if([self getZCKitInfo]!=nil && [self getZCThemeStyle] == SobotThemeMode_Dark && [self getZCKitInfo].useDefaultDarkTheme){
        return YES;
    }
    return NO;
}

+(void)zcModelStringToAttributeString:(id) model{
    SobotChatMessage *temModel = model;
    if(![temModel isKindOfClass:[SobotChatMessage class]]){
        return;
    }
    
    /*
    if(sobotConvertToString([temModel getModelDisplayText]).length > 0){
        [ZCUITools attributedStringByHTML:[temModel getModelDisplayText] textColor:textColor linkColor:linkColor result:^(NSMutableAttributedString *attr) {
            temModel.displayAttr = attr;
        }];
    }
     */
    
    if(sobotConvertToString([temModel getModelDisplaySugestionText]).length > 0  && temModel.displaySugestionattr==nil){
        UIColor *textColor = [self zcgetRightChatTextColor];
        UIColor *linkColor = [self zcgetChatRightlinkColor];
        if(temModel.senderType > 0){
            textColor = [self zcgetLeftChatTextColor];
            linkColor = [self zcgetChatLeftLinkColor];
        }
        [self attributedStringByHTML:[temModel getModelDisplaySugestionText] textColor:textColor linkColor:linkColor result:^(NSMutableAttributedString *attr,NSString *htmlText) {
            NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle setLineSpacing:12.0];
            [attr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attr length])];

            temModel.displaySugestionattr = attr;
        }];
    }
}
/******************************************************
 自定义颜色开始
 */

/// 系统背景色
+(UIColor *)zcgetChatBackgroundColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.chatBgColor!=nil){
        return configModel.chatBgColor;
    }
    return UIColorFromKitModeColor(SobotColorBgMainDark1);
}

///  设置导航栏颜色
+(UIColor *)zcgetNavBackGroundColorWithSize:(CGSize)size{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.topViewBgColor!=nil && ![self useDefaultThemeColor]){
        return configModel.topViewBgColor;
    }
    NSMutableArray *colors = [NSMutableArray array];
    if(configModel !=nil && configModel.sobotColor_title_bar_left_bg && ![self useDefaultThemeColor]){
        UIColor *colorItem = [SobotImageTools colorWithHexString:configModel.sobotColor_title_bar_left_bg alpha:1];
        [colors addObject:(__bridge id)colorItem.CGColor];
    }
    
    if(configModel !=nil && configModel.sobot_color_title_bar_right_bg && ![self useDefaultThemeColor]){
        UIColor *colorItem = [SobotImageTools colorWithHexString:configModel.sobot_color_title_bar_right_bg alpha:1];
        [colors addObject:(__bridge id)colorItem.CGColor];
    }
    if(colors.count > 0){
        return [SobotImageTools gradientColorWithSize:size colorArr:colors];
    }
    
    // 用户没有设置取 PC端的设置值
    if (sobotConvertToString([[ZCUICore getUICore] getLibConfig].topBarColor).length > 0) {
        NSString *colorStr = [[ZCUICore getUICore] getLibConfig].topBarColor;
//        colorStr = @"#2DB4F9,#272EDC,#ff33cc,#cc0033";// 测试数据
        NSArray *colorStrArray = [colorStr componentsSeparatedByString:@","];
        if (!sobotIsNull(colorStrArray)) {
            for (NSString *colorName in colorStrArray) {
                UIColor *colorItem = [SobotImageTools colorWithHexString:colorName alpha:1];
                [colors addObject:(__bridge id)colorItem.CGColor];
            }
            UIColor *bgColor = [SobotImageTools gradientColorWithSize:size colorArr:colors];
            return bgColor;
        }
    }
    
    UIColor *colorItemLeft = [SobotImageTools colorWithHexString:@"#4ADABE" alpha:1];
    [colors addObject:(__bridge id)colorItemLeft.CGColor];
    
    UIColor *colorItemRight = [SobotImageTools colorWithHexString:@"#0DAEAF" alpha:1];
    [colors addObject:(__bridge id)colorItemRight.CGColor];
    return [SobotImageTools gradientColorWithSize:size colorArr:colors];
}

+(UIColor *)zcgetRobotBackGroundColorWithSize:(CGSize)size{
    if (sobotConvertToString([[ZCUICore getUICore] getLibConfig].rebotTheme).length > 0) {
        NSString *colorStr = [[ZCUICore getUICore] getLibConfig].rebotTheme;
//        colorStr = @"#2DB4F9,#272EDC,#ff33cc,#cc0033";// 测试数据
        NSArray *colorStrArray = [colorStr componentsSeparatedByString:@","];
        if (!sobotIsNull(colorStrArray)) {
            NSMutableArray *colors = [NSMutableArray array];
            for (NSString *colorName in colorStrArray) {
                UIColor *colorItem = [SobotImageTools colorWithHexString:colorName alpha:1];
                [colors addObject:(__bridge id)colorItem.CGColor];
            }
            UIColor *bgColor = [SobotImageTools gradientColorWithSize:size colorArr:colors];
            return bgColor;
        }
    }
    return [ZCUIKitTools zcgetButtonThemeBgColor];
}

#pragma mark - 设置主题按钮的背景颜色
+(UIColor *)zcgetServerConfigBtnBgColor{
    if (sobotConvertToString([[ZCUICore getUICore] getLibConfig].rebotTheme).length > 0) {
        NSString *colorStr = [[ZCUICore getUICore] getLibConfig].rebotTheme;
        NSArray *colorStrArray = [colorStr componentsSeparatedByString:@","];
        if (!sobotIsNull(colorStrArray)) {
            // 只取最后一个颜色值
            NSString *colorstr = [colorStrArray lastObject];
            UIColor *colorItem = [SobotImageTools colorWithHexString:colorstr alpha:1];
            return colorItem;
        }
    }
    return UIColorFromModeColor(SobotColorTheme);// 默认主题色
}

+(UIColor *)zcgetRobotBtnTitleColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.robotBtnTitleColor!=nil){
        return configModel.robotBtnTitleColor;
    }
    return UIColorFromKitModeColor(SobotColorWhite);
}

+(UIColor *)zcgetTopViewTextColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.topViewTextColor!=nil){
        return configModel.topViewTextColor;
    }
    return UIColorFromKitModeColor(SobotColorWhite);
}

+(UIColor *)zcgetTextNolColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.textNolColor!=nil){
        return configModel.textNolColor;
    }
    return UIColorFromKitModeColor(SobotColorTextNav);
}


+(UIColor *)zcgetChatBottomLineColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.chatBgBottomLineColor!=nil){
        return configModel.chatBgBottomLineColor;
    }
    return UIColorFromKitModeColor(SobotColorBgLine);
}

+(UIColor *)zcgetChatBgBottomColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.chatBgBottomColor!=nil){
        return configModel.chatBgBottomColor;
    }
    return UIColorFromKitModeColor(SobotColorBgMainDark2);
}

+(UIColor *)zcgetLeaveSubmitImgColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.leaveSubmitBtnImgColor!=nil && ![self useDefaultThemeColor]){
        return configModel.leaveSubmitBtnImgColor;
    }
    return [ZCUIKitTools zcgetServerConfigBtnBgColor];// UIColorFromKitModeColor(SobotColorTheme);
}

+(UIColor *)zcgetLeaveSubmitTextColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.leaveSubmitBtnTextColor!=nil && ![self useDefaultThemeColor]){
        return configModel.leaveSubmitBtnTextColor;
    }
    return UIColorFromKitModeColor(SobotColorTextWhite);
}

/// 系统背景色
+(UIColor *)zcgetLightGrayBackgroundColor{
    return UIColorFromKitModeColor(SobotColorBgSub);
}

+(UIColor *)zcgetLightGrayDarkBackgroundColor{
    return UIColorFromKitModeColor(SobotColorBgSub2Dark1);
}

+(UIColor *)zcgetTextPlaceHolderColor{
    return UIColorFromKitModeColor(SobotColorTextSub1);
}

+(UIColor *)zcgetMsgRecordCellBgColor{
    return UIColorFromKitModeColor(SobotColorBgMainDark1);
}

+(UIColor *)zcgetCommentButtonLineColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.chatBgBottomLineColor!=nil && ![self useDefaultThemeColor]){
        return configModel.chatBgBottomLineColor;
    }
    return UIColorFromKitModeColor(SobotColorBgLine);
}


+(UIColor *)zcgetCommentItemButtonBgColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.commentItemButtonBgColor!=nil && ![self useDefaultThemeColor]){
        return configModel.commentItemButtonBgColor;
    }
    return UIColorFromKitModeColor(SobotColorBgSub);
}


+(UIColor *)zcgetCommentItemSelButtonBgColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.commentItemButtonSelBgColor!=nil && ![self useDefaultThemeColor]){
        return configModel.commentItemButtonSelBgColor;
    }
    return UIColorFromKitModeColor(SobotColorTheme); // UIColorFromRGB(BgTitleColor);
}

+(UIColor *)zcgetSatisfactionColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.satisfactionTextColor && ![self useDefaultThemeColor]) {
        return configModel.satisfactionTextColor;
    }
    return UIColorFromModeColor(SobotColorTextMain);
}

+(UIColor *)zcgetSatisfactionBgSelectedColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.satisfactionSelectedBgColor && ![self useDefaultThemeColor]) {
        return configModel.satisfactionSelectedBgColor;
    }
    return UIColorFromModeColor(SobotColorBgMainDark2);
}

+(UIColor *)zcgetGoodSendBtnColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if(configModel!=nil && configModel.goodSendBtnColor!=nil && ![self useDefaultThemeColor]){
        return configModel.goodSendBtnColor;
    }
    return [ZCUIKitTools zcgetServerConfigBtnBgColor];
}


#pragma mark - 设置按钮的主题色
+(UIColor *)zcgetButtonThemeBgColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if(configModel!=nil && configModel.goodSendBtnColor!=nil && ![self useDefaultThemeColor]){
        return configModel.commentItemButtonBgColor;
    }
    return UIColorFromModeColor(SobotColorTheme);
}

+(UIColor *)zcgetScoreExplainTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.scoreExplainTextColor&& ![self useDefaultThemeColor]) {
        return configModel.scoreExplainTextColor;
    }
    return UIColorFromModeColor(SobotColorYellow); 
}

+(UIColor *)zcgetPricetTagTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if(configModel !=nil && configModel.pricetTagTextColor && ![self useDefaultThemeColor]){
        return configModel.pricetTagTextColor;
    }
    return UIColorFromModeColor(SobotColorTextPricetTag);
}

+(UIColor *)zcgetSubmitEvaluationButtonColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.submitEvaluationColor!=nil && ![self useDefaultThemeColor]){
        return configModel.submitEvaluationColor;
    }
    return UIColorFromModeColor(SobotColorWhite);
}

+(UIColor *)zcgetCommentCommitButtonColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.commentCommitButtonColor!=nil && ![self useDefaultThemeColor]){
        return configModel.commentCommitButtonColor;
    }
    return UIColorFromModeColor(SobotColorTheme);
}

// 2.8.0
/**
 *  文件查看 ImgProgress 背景颜色
 */
+(UIColor *)zcgetDocumentLookImgProgressColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.documentLookImgProgressColor!=nil && ![self useDefaultThemeColor]){
        return configModel.documentLookImgProgressColor;
    }
    return  UIColorFromKitModeColor(SobotColorTheme) ;//UIColorFromRGB(BgTitleColor);
}

/**
 *  文件查看 ImgProgress 背景颜色
 */
+(UIColor *)zcgetDocumentBtnDownColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.documentBtnDownColor!=nil && ![self useDefaultThemeColor]){
        return configModel.documentBtnDownColor;
    }
    return UIColorFromKitModeColor(SobotColorTheme);//UIColorFromRGB(BgTitleColor);
}

+(UIColor *)zcgetServiceNameTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.serviceNameTextColor && ![self useDefaultThemeColor]) {
        return configModel.serviceNameTextColor;
    }
    return UIColorFromKitModeColor(SobotColorTextSub); //UIColorFromRGB(TextNameColor);
}

+(UIColor *)zcgetTimeTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.timeTextColor && ![self useDefaultThemeColor]) {
        return configModel.timeTextColor;
    }
    return UIColorFromKitModeColor(SobotColorTextSub);
}

+(UIColor *) zcgetBgBannerColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.topViewBgColor!=nil && ![self useDefaultThemeColor]){
        return configModel.topViewBgColor;
    }
    return UIColorFromKitModeColor(SobotColorBanner);
}

+(UIColor *)zcgetChatTextViewColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.chatTextViewColor!=nil && ![self useDefaultThemeColor]){
        return configModel.chatTextViewColor;
    }
    return UIColorFromKitModeColor(SobotColorTextMain);
}



+(UIColor *)zcgetGoodsSendColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel !=nil && configModel.goodsSendTextColor && ![self useDefaultThemeColor]) {
        return configModel.goodsSendTextColor;
    }
    return UIColorFromKitModeColor(SobotColorTextWhite);
}

/// 获取留言提交成功页面背景色
+(UIColor *)zcgetLeaveSuccessViewBgColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel!= nil && configModel.leaveSuccessViewBgColor != nil  && ![self useDefaultThemeColor]) {
        return configModel.leaveSuccessViewBgColor;
    }
    return UIColorFromKitModeColor(SobotColorBgSub);
}

+(UIColor *)zcgetChatLeftLinkColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.chatLeftLinkColor && ![self useDefaultThemeColor]) {
        return configModel.chatLeftLinkColor;
    }
    if (sobotConvertToString([[ZCUICore getUICore] getLibConfig].msgClickColor).length > 0) {
        return [SobotImageTools colorWithHexString:sobotConvertToString([[ZCUICore getUICore] getLibConfig].msgClickColor) alpha:1];
    }
    return UIColorFromKitModeColor(SobotColorTextLink);
}

+(UIColor *)zcgetRightChatTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.rightChatTextColor && ![self useDefaultThemeColor]) {
        return configModel.rightChatTextColor;
    }
    return UIColorFromKitModeColor(SobotColorTextWhite);
}

+(UIColor *)zcgetChatRightSelBgColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.rightChatSelectedColor && ![self useDefaultThemeColor]) {
        return configModel.rightChatSelectedColor;
    }
    return UIColorFromKitModeColor(SobotColorTextSub1); //UIColorFromRGB(BgVideoCellSelColor);
}

+(UIColor *)zcgetChatRightlinkColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.chatRightLinkColor && ![self useDefaultThemeColor]) {
        return configModel.chatRightLinkColor;
    }
    if (sobotConvertToString([[ZCUICore getUICore] getLibConfig].msgClickColor).length > 0) {
        return [SobotImageTools colorWithHexString:sobotConvertToString([[ZCUICore getUICore] getLibConfig].msgClickColor) alpha:1];
    }
    return UIColorFromKitModeColor(SobotColorTextLinkRight);
}

+(NSString *)getHexStringByColor:(UIColor *) color{
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    int rgb = (int)(r * 255.0f)<<16 | (int)(g * 255.0f)<<8 | (int)(b * 255.0f)<<0;
    return [NSString stringWithFormat:@"%06x", rgb];
}

+(UIColor *)zcgetLeftChatColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.leftChatColor!=nil && ![self useDefaultThemeColor]){
        return configModel.leftChatColor;
    }
    return UIColorFromKitModeColor(SobotColorBgSub);
}

+(UIColor *)zcgetChatLeftSelBgColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.leftChatSelectedColor!=nil && ![self useDefaultThemeColor]){
        return configModel.leftChatSelectedColor;
    }
    return UIColorFromKitModeColor(SobotColorTextSub1);
}

+(UIColor *)zcgetRightChatColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.rightChatColor!=nil && ![self useDefaultThemeColor]){
        return configModel.rightChatColor;
    }
    // 用户没有设置走渐变色
    if (sobotConvertToString([[ZCUICore getUICore] getLibConfig].rebotTheme).length > 0) {
        NSString *colorStr = [[ZCUICore getUICore] getLibConfig].rebotTheme;
        NSArray *colorStrArray = [colorStr componentsSeparatedByString:@","];
        if (!sobotIsNull(colorStrArray)) {
            // 只取最后一个颜色值
            NSString *colorstr = [colorStrArray lastObject];
            UIColor *colorItem = [SobotImageTools colorWithHexString:colorstr alpha:1];
            return colorItem;
        }
    }
    return UIColorFromModeColor(SobotColorTheme);// 默认主题色
//    return UIColorFromKitModeColor(SobotColorTheme);
}

#pragma mark -- 设置右边气泡颜色
+(UIColor *)zcgetRightChatColorWithSize:(CGSize)size{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.rightChatColor!=nil && ![self useDefaultThemeColor]){
        return configModel.rightChatColor;
    }
    if (sobotConvertToString([[ZCUICore getUICore] getLibConfig].rebotTheme).length > 0) {
        NSString *colorStr = [[ZCUICore getUICore] getLibConfig].rebotTheme;
//        colorStr = @"#2DB4F9,#272EDC,#ff33cc,#cc0033";// 测试数据
        NSArray *colorStrArray = [colorStr componentsSeparatedByString:@","];
        if (!sobotIsNull(colorStrArray)) {
            NSMutableArray *colors = [NSMutableArray array];
            for (NSString *colorName in colorStrArray) {
                UIColor *colorItem = [SobotImageTools colorWithHexString:colorName alpha:1];
                [colors addObject:(__bridge id)colorItem.CGColor];
            }
            UIColor *bgColor = [SobotImageTools gradientColorWithSize:size colorArr:colors ];
            return bgColor;
        }
    }
    return UIColorFromModeColor(SobotColorTheme);// 默认主题色
}

// 复制选中的背景色
+(UIColor *)zcgetRightChatSelectdeColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.rightChatSelectedColor!=nil && ![self useDefaultThemeColor]){
        return configModel.rightChatSelectedColor;
    }
    return UIColorFromKitModeColor(SobotColorTextSub1);
}

+(UIColor *)zcgetRightChatVoiceTextBgColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.videoConversionBgColor!=nil && ![self useDefaultThemeColor]){
        return configModel.videoConversionBgColor;
    }
    return UIColorFromKitModeColor(SobotColorBgSub);
}

+(UIColor *)zcgetRightChatVoiceTextColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.videoConversionTextColor!=nil && ![self useDefaultThemeColor]){
        return configModel.videoConversionTextColor;
    }
    return UIColorFromKitModeColor(SobotColorTextMain);
}


+(UIColor *)zcgetLeftChatSelectedColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.leftChatSelectedColor!=nil && ![self useDefaultThemeColor]){
        return configModel.leftChatSelectedColor;
    }
    return UIColorFromKitModeColor(SobotColorTextSub1);
}
+(UIColor *)zcgetChatRightVideoSelBgColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.videoCellBgSelColor && ![self useDefaultThemeColor]) {
        return configModel.videoCellBgSelColor;
    }
    return UIColorFromKitModeColor(SobotColorTheme); //UIColorFromRGB(BgVideoCellSelColor);
}

+(UIColor *)zcgetLeftChatTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.leftChatTextColor && ![self useDefaultThemeColor]) {
        return configModel.leftChatTextColor;
    }
    return UIColorFromKitModeColor(SobotColorTextMain);
}

+(UIColor *)zcgetThemeToWhiteColor{
    if([self getZCThemeStyle] == SobotThemeMode_Dark){
        return UIColorFromKitModeColor(SobotColorTextMain);
    }
    return UIColorFromKitModeColor(SobotColorTheme);
}

+(CGFloat )zcgetChatGuideLineSpacing{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.guideLineSpacing>0) {
        return configModel.guideLineSpacing;
    }
    return [self zcgetChatLineSpacing];
}

+(UIColor *)zcgetLineRichColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.LineRichColor && ![self useDefaultThemeColor]) {
        return configModel.LineRichColor;
    }
    return UIColorFromKitModeColor(SobotColorBgLine);
}

+(UIColor *)zcgetCommentPageButtonTextColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.commentButtonTextColor!=nil && ![self useDefaultThemeColor]){
        return configModel.commentButtonTextColor;
    }
    return UIColorFromKitModeColor(SobotColorTheme);
}

+(UIColor *)zcgetSatisfactionTextSelectedColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.satisfactionTextSelectedColor && ![self useDefaultThemeColor]) {
        return configModel.satisfactionTextSelectedColor;
    }
    return UIColorFromKitModeColor(SobotColorTextMain);
}

+(UIColor *)zcgetNoSatisfactionTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.noSatisfactionTextColor && ![self useDefaultThemeColor]) {
        return configModel.noSatisfactionTextColor;
    }
    return UIColorFromKitModeColor(SobotColorTextSub);
}

#pragma mark - 帮助中心导航栏颜色
+(UIColor *)zcgetscTopBgColorWithSize:(CGSize)size{
    ZCKitInfo *configModel = [self getZCKitInfo];
    NSMutableArray *colors = [NSMutableArray array];
    if(configModel !=nil && configModel.sobotColor_title_bar_left_bg && ![self useDefaultThemeColor]){
        UIColor *colorItem = [SobotImageTools colorWithHexString:configModel.sobotColor_title_bar_left_bg alpha:1];
        [colors addObject:(__bridge id)colorItem.CGColor];
    }else{
        UIColor *colorItem = [SobotImageTools colorWithHexString:@"#4ADABE" alpha:1];
        [colors addObject:(__bridge id)colorItem.CGColor];
    }
    if(configModel !=nil && configModel.sobot_color_title_bar_right_bg && ![self useDefaultThemeColor]){
        UIColor *colorItem = [SobotImageTools colorWithHexString:configModel.sobot_color_title_bar_right_bg alpha:1];
        [colors addObject:(__bridge id)colorItem.CGColor];
    }else{
        UIColor *colorItem = [SobotImageTools colorWithHexString:@"#0DAEAF" alpha:1];
        [colors addObject:(__bridge id)colorItem.CGColor];
    }
    UIColor *bgColor = [SobotImageTools gradientColorWithSize:size colorArr:colors];
    return bgColor;
}

+(CGFloat )zcgetChatLineSpacing{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.lineSpacing>0) {
        return configModel.lineSpacing;
    }
    return 5.0f;
}

//过滤html标签
+(NSString *)removeAllHTMLTag:(NSString *)html {
    NSScanner *theScanner;
    
    NSString *text = nil;
    
    theScanner = [NSScanner scannerWithString:html];
    
    while ([theScanner isAtEnd] == NO) {
        
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL] ;
        
        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text] ;
        
        
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        if([[NSString stringWithFormat:@"%@>", text] hasSuffix:@"/p>"]){
            html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@"\n"];
        }else{
            html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
        }
    }
    return html;
}

+(void) attributedStringByHTML:(NSString *)html textColor:(UIColor *) textColor linkColor:(UIColor *) linkColor result:(void (^)(NSMutableAttributedString *,NSString *htmlText))attrBlock
{
    if (!html || [html isKindOfClass:[NSString class]] == NO)
    {
      html = @"";
    }
    
    UIFont *font  = [ZCUIKitTools zcgetKitChatFont];
    if (!font || [font isKindOfClass:[UIFont class]] == NO)
    {
        font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    }

    // 解决 CoreText note: Client requested name ".SFUI-Regular" warning
    NSString *fontName = font.fontName;
    if([fontName hasSuffix:@"SFUI-Regular"]){
        fontName = @"TimesNewRomanPSMT";
    }

    html = [html stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
    if(linkColor && textColor){
        NSString *linkHexColor = [self getHexStringByColor:linkColor];
        NSString *textHexColor = [self getHexStringByColor:textColor];
        html = [NSString stringWithFormat:@"<html><head><style>body{ font-family:'%@'; font-size:%fpx;color:%@; margin:0px; padding:0px;}a{color:%@} a:hover{color:%@}</style></head><body>%@</body></html>", fontName, font.pointSize,textHexColor,linkHexColor,linkHexColor,html];
    }else{
        html = [NSString stringWithFormat:@"<html><head><style>body{ font-family:'%@'; font-size:%fpx; margin:0px; padding:0px;}</style></head><body>%@</body></html>", fontName, font.pointSize,html];
    }
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
////        NSDictionary * documentAttributes = nil;
        NSError      * error = nil;
        NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithData:[html dataUsingEncoding:NSUTF8StringEncoding] options:@{
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)} documentAttributes:nil error:&error];
//        dispatch_async(dispatch_get_main_queue(), ^{
            attrBlock((string && [string isKindOfClass:[NSMutableAttributedString class]]) ? string : nil,html);
//        });
//    });
}


+(NSMutableAttributedString *_Nullable)parseStringArtribute:(NSMutableAttributedString *_Nonnull) attr linespace:(CGFloat )lineSpace font:(UIFont *_Nonnull) font textColor:(UIColor *_Nonnull) textColor linkColr:(UIColor *_Nonnull)linkColor{
    
    NSMutableAttributedString* attributedString = [attr mutableCopy];
     
    [attributedString beginEditing];
    [attributedString enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0,attributedString.length) options:0 usingBlock:^(id value,NSRange range,BOOL *stop) {
        UIFont *font = value;
        // 替换固定默认文字大小
        if(font.pointSize == 15){
//            NSLog(@"----替换了字体");
            [attributedString removeAttribute:NSFontAttributeName range:range];
            [attributedString addAttribute:NSFontAttributeName value:font range:range];
        }
    }];
    [attributedString enumerateAttribute:NSForegroundColorAttributeName inRange:NSMakeRange(0,attributedString.length) options:0 usingBlock:^(id value,NSRange range,BOOL *stop) {
        UIColor *color = value;
        NSString *hexColor = [ZCUIKitTools getHexStringByColor:color];
//                                NSLog(@"***\n%@",hexColor);
        // 替换固定整体文字颜色
        if([@"ff0001" isEqual:hexColor]){
            [attributedString removeAttribute:NSForegroundColorAttributeName range:range];
            [attributedString addAttribute:NSForegroundColorAttributeName value:textColor range:range];
        }
        // 替换固定连接颜色
        if([@"ff0002" isEqual:hexColor]){
            [attributedString removeAttribute:NSForegroundColorAttributeName range:range];
            [attributedString addAttribute:NSForegroundColorAttributeName value:linkColor range:range];
        }
    }];
    
    //Hack for italic/skew effect to custom fonts
    __block NSMutableDictionary *rangeIDict = [[NSMutableDictionary alloc] init];
    [attributedString enumerateAttribute:NSParagraphStyleAttributeName inRange:NSMakeRange(0,attributedString.length) options:0 usingBlock:^(id value,NSRange range,BOOL *stop) {
         if (value) {
             NSMutableParagraphStyle *myStyle = (NSMutableParagraphStyle *)value;
             if (myStyle.minimumLineHeight == 101) {
                 // 保存加粗的标签位置，如果相同位置有斜体，需要设置为斜体加粗
                 [rangeIDict setObject:@"YES" forKey:NSStringFromRange(range)];
                 [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:font.pointSize weight:UIFontWeightBold] range:range];
             }
         }
     }];
    
    [attributedString enumerateAttribute:NSParagraphStyleAttributeName inRange:NSMakeRange(0,attributedString.length) options:0 usingBlock:^(id value,NSRange range,BOOL *stop) {
      
         if (value) {
      
             NSMutableParagraphStyle *myStyle = (NSMutableParagraphStyle *)value;
             if (myStyle.minimumLineHeight == 99) {
                 UIFont *textFont = font;
                 CGAffineTransform matrix =  CGAffineTransformMake(1, 0, tanf(10 * (CGFloat)M_PI / 180), 1, 0, 0);
                 UIFont *font = [UIFont systemFontOfSize:textFont.pointSize];
                 // 相同的位置，有加粗
                 if ([@"YES" isEqual:[rangeIDict objectForKey:NSStringFromRange(range)]]) {
                    font = [UIFont boldSystemFontOfSize:textFont.pointSize];
                 }
                 NSString *fontName = font.fontName;
                 if([fontName hasSuffix:@"SFUI-Regular"]){
                     fontName = @"TimesNewRomanPSMT";
                 }
                 UIFontDescriptor *desc = [UIFontDescriptor fontDescriptorWithName:fontName matrix:matrix];
                 [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithDescriptor:desc size:textFont.pointSize] range:range];
             }
             
      
         }
     }];
    
    // 文本段落排版格式
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle alloc] init];
    textStyle.lineBreakMode = NSLineBreakByWordWrapping; // 结尾部分的内容以……方式省略
    textStyle.lineSpacing = lineSpace;
    NSMutableDictionary *textAttributes = [[NSMutableDictionary alloc] init];
    // NSParagraphStyleAttributeName 文本段落排版格式
    [textAttributes setValue:textStyle forKey:NSParagraphStyleAttributeName];
    // 设置段落样式
    [attributedString addAttributes:textAttributes range:NSMakeRange(0, attributedString.length)];
    [attributedString endEditing];
    
    return [attributedString copy];
}

+(int )changeFileType:(int) oldType{
    int newType = oldType;
    switch (oldType) {
        case 13:
            newType = 0;
            break;
        case 14:
            newType = 1;
            break;
        case 15:
            newType = 2;
            break;
        case 16:
            newType = 3;
            break;
        case 17:
            newType = 4;
            break;
        case 18:
            newType = 5;
            break;
        case 19:
            newType = 6;
            break;
        case 20:
            newType = 7;
            break;
        default:
            break;
    }
    return newType;
}

+(int) zcLibmimeWithURLType:(NSString *)filePath
{
    filePath = sobotConvertToString(filePath);
    // 先从参入的路径的出URL
    NSURL *url = [NSURL fileURLWithPath:filePath];
    if ([filePath hasPrefix:@"file:///"]){
        url = [NSURL URLWithString:filePath];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    // 只有响应头中才有其真实属性 也就是MIME
    NSURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    NSString *mimeType = response.MIMEType;
    
    int type = 8;
    if([@"application/msword" isEqual:mimeType] || [@"application/vnd.ms-works" isEqual:mimeType] || [filePath hasSuffix:@".docx"] || [filePath hasSuffix:@".doc"]){
        type = 0;
    }else if([@"application/vnd.ms-powerpoint" isEqual:mimeType] || [filePath hasSuffix:@".ppt"] || [filePath hasSuffix:@".pptx"]){
        type = 1;
    }else if([@"application/vnd.ms-excel" isEqual:mimeType] || [@"application/vnd.ms-excel" isEqual:mimeType] || [filePath hasSuffix:@".xls"] || [filePath hasSuffix:@".xlsx"]){
        type = 2;
    }else if([@"application/pdf" isEqual:mimeType] || [filePath hasSuffix:@".pdf"]){
        type = 3;
    }else if([@"application/zip" isEqual:mimeType] || [@"application/rar" isEqual:mimeType]){
        type = 6;
    }else if([mimeType hasPrefix:@"audio"] || [filePath hasSuffix:@".mp3"]){
        type = 4;
    }else if([mimeType hasPrefix:@"video"] || [filePath hasSuffix:@".mp4"]){
        type = 5;
    }else if([@"text/plain" isEqual:mimeType] || [filePath hasSuffix:@".txt"]){
        type = 7;
    }
    return type;
}
+(UIImage *) getFileIcon:(NSString * ) filePath fileType:(int) type{
    type  = type>0 ? [self changeFileType:type] : [self zcLibmimeWithURLType:filePath];
    NSString *iconName = @"";
    if(type == 0){
        iconName = @"zcicon_file_word";
    }else if( type == 1 || type == 8){
        iconName = @"zcicon_file_ppt";
    }else if(type == 2 || type == 12){
        iconName = @"zcicon_file_excel";
    }else if(type == 3){
        iconName = @"zcicon_file_pdf";
    }else if(type == 6){
        iconName = @"zcicon_file_zip";
    }else if(type == 4){
        iconName = @"zcicon_file_mp3";
    }else if(type == 5){
        iconName = @"zcicon_file_mp4";
    }else if(type == 7){
        iconName = @"zcicon_file_txt";
    }else{
        iconName = @"zcicon_file_unknow";
    }
    
    return SobotKitGetImage(iconName);
}

+ (void)addTopBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth withView:(UIView *) view{
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(0, 0, view.frame.size.width, borderWidth);
    [view.layer addSublayer:border];
}

+ (void)addTopBorderWithColor:(UIColor *)color andWidth:(CGFloat)borderWidth andViewWidth:(CGFloat)viewWidth withView:(UIView *) view{
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(0, 0, viewWidth, borderWidth);
    [view.layer addSublayer:border];
}

+ (void)addBottomBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth withView:(UIView *) view {
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    border.frame = CGRectMake(0, view.frame.size.height - borderWidth, view.frame.size.width, borderWidth);
    border.name=@"border";
    [view.layer addSublayer:border];
}

+ (void)addBottomBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth andViewWidth:(CGFloat)viewWidth withView:(UIView *) view{
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    border.frame = CGRectMake(0, view.frame.size.height - borderWidth, viewWidth, borderWidth);
    border.name=@"border";
    [view.layer addSublayer:border];
}

+ (void)addLeftBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth  withView:(UIView *) view{
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(0, 0, borderWidth, view.frame.size.height);
    [view.layer addSublayer:border];
}

+ (void)addRightBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth  withView:(UIView *) view{
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(view.frame.size.width - borderWidth, 0, borderWidth, view.frame.size.height);
    [view.layer addSublayer:border];
}

+(CGFloat)getHeightContain:(NSString *)string font:(UIFont *)font Width:(CGFloat) width
{
    if(string==nil){
        return 0;
    }
    //转化为格式字符串
    NSAttributedString *astr = [[NSAttributedString alloc]initWithString:string attributes:@{NSFontAttributeName:font}];
    CGSize contansize=CGSizeMake(width, CGFLOAT_MAX);
    if(iOS7){
        CGRect rec = [astr boundingRectWithSize:contansize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
        return rec.size.height;
    }else{
//        CGSize s=[string sizeWithFont:font constrainedToSize:contansize lineBreakMode:NSLineBreakByCharWrapping];
        CGSize s=[string boundingRectWithSize:contansize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil].size;
        return s.height;
    }
}

+(CGFloat)getWidthContain:(NSString *)string font:(UIFont *)font Height:(CGFloat) height
{
    if(string==nil){
        return 0;
    }
    //转化为格式字符串
    NSAttributedString *astr = [[NSAttributedString alloc]initWithString:string attributes:@{NSFontAttributeName: font}];
    CGSize cs=CGSizeMake(CGFLOAT_MAX,height);
    if(!iOS7){
        CGSize s=[string sizeWithFont:font constrainedToSize:cs lineBreakMode:NSLineBreakByCharWrapping];
        return s.width;
    }else{
        CGRect rec = [astr boundingRectWithSize:cs options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
        CGSize size = rec.size;
        return size.width;
    }
}


@end
