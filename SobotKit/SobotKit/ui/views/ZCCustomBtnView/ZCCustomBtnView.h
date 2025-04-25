//
//  ZCCustomBtnView.h
//  SobotKit
//
//  Created by lizh on 2025/3/9.
//

#import <UIKit/UIKit.h>
#import "ZCUIKitTools.h"
#import <SobotCommon/SobotCommon.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZCCustomBtnView : UIView

@property (strong, nonatomic) UIImageView *iconImg;
@property (strong,nonatomic) UILabel *titleLab;
@property (strong,nonatomic) UIButton *clickBtn;
@property (strong,nonatomic) UIView *bgView;
// 图片和文字之间的间距
@property (nonatomic,assign) CGFloat labL;
// 图片高度
@property(nonatomic,assign) CGFloat iconH;
// 图宽度
@property(nonatomic,assign) CGFloat iconW;
// 文本右边距
@property(nonatomic,assign) CGFloat labR;
// 图片的左边距
@property(nonatomic,assign) CGFloat iconL;
// 整个按钮的最大高度
@property(nonatomic,assign) CGFloat btnHeight;
// 按钮的最小宽度
@property(nonatomic,assign) CGFloat cminWidth;

@property(nonatomic,strong) UIFont *titleFont;

@property(nonatomic,strong) UIColor *titleColor;

@property(nonatomic,strong) NSLayoutConstraint *layoutBtnH;

// 是否显示边线
@property(nonatomic,assign) BOOL *isShowBored;
-(void)initWithTitle:(NSString *)title img:(UIImage*)img supView:(UIView*)supView;

-(void)initWithTitle:(NSString *)title img:(UIImage*)img iconL:(CGFloat)iconL iconH:(CGFloat)iconH iconW:(CGFloat)iconW  titleFont:(UIFont*)font titleColor:(UIColor*)titleColor btnHeight:(CGFloat)btnHeight labL:(CGFloat)labL supView:(UIView*)supView;
@end

NS_ASSUME_NONNULL_END
