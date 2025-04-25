//
//  SobotUITools.h
//  SobotOnline
//
//  Created by zhangxy on 2020/8/5.
//  Copyright © 2020 sobot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger,SobotThemeMode){
    SobotThemeMode_Default    = 0, // 默认，跟随系统
    SobotThemeMode_Dark       = 1, // 暗黑模式
    SobotThemeMode_Light      = 2, // 亮色模式
};

typedef NS_ENUM(NSInteger, SobotGradientChangeDirection) {
    SobotGradientChangeDirectionLevel, //水平渐变
    SobotGradientChangeDirectionVertical, // 垂直渐变
    SobotGradientChangeDirectionUpwardDiagonalLine, // 向下对角线渐变
    SobotGradientChangeDirectionDownDiagonalLine, //向上对角线渐变
};

// buttonTag == -1:取消，0确定
typedef void(^SobotAlertViewBlock)(NSInteger buttonTag);

NS_ASSUME_NONNULL_BEGIN

/// 获取颜色、图片、权限判断等
@interface SobotUITools : NSObject


/// 默认
+(SobotThemeMode ) getSobotThemeMode;

/// 根据bundle中的string文件的key获取color
/// @param hexColorKey  颜色的key，比如，Sobotline.bundle/dark.color--SobotColor.string文件中定义
+(UIColor *)getSobotThemeModeColor:(NSString *)hexColorKey;
+(UIColor *)getSobotThemeModeColor:(NSString *)hexColorKey bundleName:(NSString *)bundleName;


/// 根据bundle中的string文件的key获取color
/// @param hexColorKey  颜色的key，比如，Sobotline.bundle/dark.color--SobotColor.string文件中定义
/// @param alpha 指定透明度
+(UIColor *)getSobotThemeModeColor:(NSString *)hexColorKey alpha:(CGFloat) alpha bundleName:(NSString *)bundleName;


/// 获取
/// @param hexColor  直接设置如#FFFFFF颜色值
/// @param alpha  指定透明度
+ (UIColor *)getSobotThemeModeByHexAlpha:(NSString *)hexColor alpha:(CGFloat) alpha;



// 获取RGB和Alpha
+ (NSArray *)getSobotRGBWithColor:(UIColor *)color;
 
// 改变UIColor的Alpha
+ (UIColor *)getSobotNewColorWith:(UIColor *)color alpha:(CGFloat )alpha;

// 读取图片资源
+(UIImage *)getSysImageByName:(NSString *)imageName;
+(UIImage *)getSysImageByName:(NSString *)imageName bundleName:(NSString *) bundleName;
// 读取图片资源
+(UIImage *)getSysImageByName:(NSString *)imageName bundle:(NSBundle * __nullable) budle;

// 设置国际化RTL适配坐标
+(void)setRTLFrame:(UIView *)view;


/// 是否为竖屏
+(BOOL) sobotIsPortrait;

// 获取当前最上层Window和VC
+(UIWindow *)getCurWindow;
+ (UIViewController *)getCurrentVC;



/// 创建View
+(UIButton *)createZCButton;
+(UIImageView *)createZCImageView;
+(UILabel *)createZCLabel;
+(UIView *)createZCView;
+(UITableView *) createTableWithView:(UIView *) superView delegate:(id) delegate;
+(UITableView *) createTableWithView:(UIView *) superView delegate:(id) delegate style:(UITableViewStyle) style;
+(UITableView *) createNormalTableWithView:(UIView *)superView delegate:(id)delegate;
+(UITableView *) createNormalTableWithView:(UIView *)superView delegate:(id)delegate style:(UITableViewStyle) style;

/**
 *  设置UITableView分割线空隙
 */
+(void)setTableSeparatorInset:(UITableView *)tableView;


/// 权限
//检查是否有相册的权限
+(void)isHasPhotoLibraryAuthorization:(void(^)(BOOL))result;


//检测是否有相机的权限
+(BOOL)isHasCaptureDeviceAuthorization;

// 检查是否有录音权限
+(void)isOpenVoicePermissions:(void(^)(BOOL))result;


/**
 获取录音设置 war格式
 @returns 录音设置
 */
+ (NSDictionary*)getAudioRecorderSettingDict;


/**
 *  创建提示框
 *
 *  @param title        标题
 *  @param message      提示内容
 *  @param cancelTitle  取消按钮(无操作,为nil则只显示一个按钮)
 *  @param confirm      点击按钮的回调(取消按钮的Index是 -1)
 */
+ (void)showAlert:(NSString *__nullable)title
          message:(NSString *__nullable)message
      cancelTitle:(NSString *)cancelTitle
          confirm:(SobotAlertViewBlock)confirm;

/**
 *  创建提示框
 *
 *  @param title        标题
 *  @param message      提示内容
 *  @param cancelTitle  取消按钮(无操作,为nil则只显示一个按钮)
 *  @param titleArray   标题字符串数组(为nil,默认为"确定")
 *  @param vc           VC iOS8及其以后会用到
 *  @param confirm      点击按钮的回调(取消按钮的Index是 -1)
 */
+ (void)showAlert:(NSString *__nullable)title
          message:(NSString *__nullable)message
      cancelTitle:(NSString *)cancelTitle
       titleArray:(NSArray *__nullable)titleArray
   viewController:(UIViewController *__nullable)vc
          confirm:(SobotAlertViewBlock)confirm;

/**
 *  创建提示框(可变参数版)
 *
 *  @param title        标题
 *  @param message      提示内容
 *  @param cancelTitle  取消按钮(无操作,为nil则只显示一个按钮)
 *  @param vc           VC iOS8及其以后会用到
 *  @param confirm      点击按钮的回调(取消按钮的Index是 -1)
 *  @param buttonTitles 按钮(为nil,默认为"确定",传参数时必须以nil结尾，否则会崩溃)
 */
+ (void)showAlert:(NSString *__nullable)title
          message:(NSString *__nullable)message
      cancelTitle:(NSString *)cancelTitle
   viewController:(UIViewController *__nullable)vc
          confirm:(SobotAlertViewBlock)confirm
     buttonTitles:(NSString *)buttonTitles, ... NS_REQUIRES_NIL_TERMINATION;



/// 0上，1左，2右
+(int)getCurScreenDirection;


// 检测图片中的二维码,返回 一个URL 字符串，或者nil
+(id )sobotReadCoderURLStrDetectorWith:(UIImage *)image;

// 获取文件图标
+(UIImage *) getFileIcon:(NSString * ) filePath fileType:(int) type;

// 获取图片类型
+ (NSString *)getMimeWithString:(NSString *)string;

// 图片变灰
+ (UIImage*)getGrayImage:(UIImage*)sourceImage;



+(NSMutableAttributedString *) attributedStringByHTML:(NSString *)html textColor:(UIColor *) textColor linkColor:(UIColor *) linkColor;


+(CGSize )getSizeContain:(NSString *)string font:(UIFont *)font Width:(CGSize) size;
+(CGFloat)getHeightContain:(NSString *)string font:(UIFont *)font Width:(CGFloat) width;

+(CGFloat)getWidthContain:(NSString *)string font:(UIFont *)font Height:(CGFloat) height;


/// 设置文本的行间距，并返回最大高度
/// - Parameters:
///   - label: 控件UILabel
///   - text: 文本
///   - lineSpacing: 行间距
///   - maxWidth: 最大宽度
+ (CGFloat )setLabel:(UILabel *)label withText:(NSString *)text lineHeight:(CGFloat)lineSpacing width:(CGFloat) maxWidth;


+ (void ) sobotButon:(UIButton *) iv hSpace:(CGFloat ) spacing top:(CGFloat )imgTBSpace rtl:(BOOL )isRTL;

+(BOOL)getIsIphonX;



+ (UIColor *)colorBgGradientChangeWithSize:(CGSize)size
                                     direction:(SobotGradientChangeDirection)direction
                                    startColor:(UIColor *)startcolor
                                  endColor:(UIColor *)endColor;




+(UIImage*)sobotCreateImageWithColor:(UIColor*)color;



/// 重写布局superView的子view
/// 子view需要设置好内容
/// - Parameters:
///   - paddingInsets: 子view的外边距
///   - superView: superView
///   - subViews: 如果为nil，自动去superView.subviews
///   - maxWidth: 显示的最大宽度
///   - hspace: 子控件的左右间隔
///   - vspace: 子控件的上下间隔
+(UIView *)subViewsLineBreak:(UIEdgeInsets )paddingInsets view:(UIView *) superView subview:(NSArray * _Nullable) subViews maxWidth:(CGFloat )maxWidth hSpace:(CGFloat) hspace vSpace:(CGFloat) vspace;

// 获取最大的高度
+(CGFloat)getMaxHeightContain:(NSString *)string font:(UIFont *)font width:(CGFloat) width;
@end

NS_ASSUME_NONNULL_END
