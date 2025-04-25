//
//  SobotRichView.h
//  SobotKit
//
//  Created by zhangxy on 2024/12/26.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SobotRichView : UIView

@property (strong, nonatomic) UITextView *textView;

@property (strong, nonatomic) void(^RefreshUIBlock)(NSAttributedString *_Nullable str,CGFloat height);

@property (strong, nonatomic) void(^TapClickBlock)(NSString *_Nullable url,NSString *_Nullable name);

/**
 如果imgWidth=0，默认是100%
 */
-(void)addAttrToView:(NSAttributedString *) text imgs:(NSArray *) imgs width:(CGFloat) width;
-(void)addTextToView:(NSString *) text imgWidth:(CGFloat) imgWidth;



@end

NS_ASSUME_NONNULL_END
