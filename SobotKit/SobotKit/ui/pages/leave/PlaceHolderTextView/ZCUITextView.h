//
//  ZCUITextView.h
//  SobotKit
//
//  Created by lizh on 2025/1/13.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <SobotCommon/SobotCommon.h>
NS_ASSUME_NONNULL_BEGIN

@interface ZCUITextView : UITextView
{
    NSString *placeholder;
    UIColor *placeholderColor;
}
@property (nonatomic,retain)SobotEmojiLabel *placeHolderLabel;

/**
 *  占位文字的字体大小
 */
@property (nonatomic,strong) UIFont *placeholederFont;

/**
 *  占位文字
 */
@property(nonatomic, strong) NSString  *placeholder;
/**
 *  占位页面link颜色
 */
@property(nonatomic, retain) UIColor *placeholderLinkColor;
/**
 *  占位页面背景颜色
 */
@property(nonatomic, retain) UIColor *placeholderColor;

/**
 *  <#Description#>
 *
 *  @param notification 通知
 */
-(void)textChanged:(NSNotification*)notification;

/**
 *  设置行间距
 */
@property (nonatomic,assign) int LineSpacing;

@property (nonatomic,assign) int type; // 1.占位文字要设置 文字颜色

@property (nonatomic,assign) BOOL isAddLink;//不设置超链
//起始间距
//@property (nonatomic,assign) CGFloat sx;
@end

NS_ASSUME_NONNULL_END
