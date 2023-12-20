//
//  ZCUILoading.m
//  SobotKit
//
//  Created by lizhihui on 15/11/11.
//  Copyright © 2015年 zhichi. All rights reserved.
//

#import "ZCUILoading.h"
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClient.h>
#import "ZCUIKitTools.h"
@interface ZCUILoading()
{
    UIActivityIndicatorView *activityView;
}
@property(strong,nonatomic) void(^refreshBlock)(UIButton *v);
@end


@implementation ZCUILoading
static  ZCUILoading *_zcuiLoading = nil;
// 单例
+ (ZCUILoading*)shareZCUILoading{
    static  dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(_zcuiLoading==nil){
            _zcuiLoading = [[self alloc] init];
        }
    });
    return _zcuiLoading;
}



#pragma mark -- show
- (void)showAddToSuperView:(UIView*)SuperView style:(BOOL) isLargeWhite{
    if(_zcuiLoading){
        for (UIView *v in _zcuiLoading.subviews) {
            [v removeFromSuperview];
        }
    }
    
    // 将ZCUILoading添加到传进来的父视图SuperView
    [SuperView addSubview:_zcuiLoading];
    [SuperView addConstraints:sobotLayoutPaddingWithAll(0, 0, 0, 0, _zcuiLoading, SuperView)];
//    _zcuiLoading.frame = CGRectMake(0, 0, SuperView.frame.size.width,SuperView.frame.size.height);
    [_zcuiLoading setBackgroundColor:[UIColor clearColor]];
//    [_zcuiLoading setAutoresizesSubviews:YES];
//    [_zcuiLoading setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    if(isLargeWhite){
        activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }else{
        activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    [_zcuiLoading addSubview:activityView];
    [_zcuiLoading addConstraints:sobotLayoutSize(40, 40, activityView, NSLayoutRelationEqual)];
    [_zcuiLoading addConstraint:sobotLayoutEqualCenterX(0, activityView, _zcuiLoading)];
    [_zcuiLoading addConstraint:sobotLayoutEqualCenterY(0, activityView, _zcuiLoading)];
    
//    [activityView setFrame:CGRectMake(0, 0, 40, 40)];
    [activityView setBackgroundColor:[UIColor clearColor]];
//    [activityView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin];
    [activityView startAnimating];
//    [activityView setCenter:CGPointMake(_zcuiLoading.bounds.size.width/2, _zcuiLoading.bounds.size.height/2)];
    
    
}

#pragma mark -- dismiss

// 消失
- (void)dismiss{
    if(activityView){
        [activityView stopAnimating];
        [activityView removeFromSuperview];
    }
    for (UIView *v in _zcuiLoading.subviews) {
        [v removeFromSuperview];
    }
    // 移除所有子视图
    [self removeFromSuperview];
}



#pragma mark -- 加载失败的占位页面
- (void)createPlaceholderView:(NSString *)title image:(UIImage *)image withView:(UIView *)SuperView action:(void (^)(UIButton *button)) clickblock{
    if(_zcuiLoading){
        for (UIView *v in _zcuiLoading.subviews) {
            [v removeFromSuperview];
        }
    }
    
    [SuperView addSubview:_zcuiLoading];
    [SuperView addConstraints:sobotLayoutPaddingWithAll(0, 0, 0, 0, _zcuiLoading, SuperView)];
    [_zcuiLoading setBackgroundColor:[ZCUIKitTools zcgetChatBackgroundColor]];
    
    
    UIImageView *icon = [[UIImageView alloc]initWithImage:[SobotUITools getSysImageByName:@"zcicon_networkfail"]];
    if(image){
        [icon setImage:image];
    }
    [_zcuiLoading addSubview:icon];
    [icon setContentMode:UIViewContentModeCenter];
  
    
    [_zcuiLoading addConstraints:sobotLayoutSize(55, 76, icon, NSLayoutRelationEqual)];
    [_zcuiLoading addConstraint:sobotLayoutEqualCenterX(0, icon, _zcuiLoading)];
    [_zcuiLoading addConstraint:sobotLayoutEqualCenterY(-150, icon, _zcuiLoading)];
    
    CGFloat y= CGRectGetMaxY(icon.frame) + 10;

    if(title){
        UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectZero];
        [lblTitle setText:title];
        [lblTitle setFont:SobotFont14];
        lblTitle.numberOfLines = 0;
        [lblTitle setTextAlignment:NSTextAlignmentCenter];
        lblTitle.textColor = UIColorFromKitModeColor(SobotColorTextSub);
        [lblTitle setBackgroundColor:[UIColor clearColor]];
        lblTitle.userInteractionEnabled = YES;
        [self addSubview:lblTitle];
        
        [_zcuiLoading addConstraint:sobotLayoutPaddingLeft(10, lblTitle, _zcuiLoading)];
        [_zcuiLoading addConstraint:sobotLayoutPaddingRight(-10, lblTitle, _zcuiLoading)];
        [_zcuiLoading addConstraint:sobotLayoutMarginTop(10, lblTitle, icon)];
         
        y = y+25;
        
        if(clickblock){
            _refreshBlock = clickblock;
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:SobotKitLocalString(@"重新加载") forState:0];
            [btn setTitleColor:UIColorFromKitModeColor(SobotColorTextLink) forState:0];
            [btn.titleLabel setFont:SobotFont16];
            [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
            [btn addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            
            [_zcuiLoading addConstraint:sobotLayoutPaddingLeft(10, btn, _zcuiLoading)];
            [_zcuiLoading addConstraint:sobotLayoutPaddingRight(-10, btn, _zcuiLoading)];
            [_zcuiLoading addConstraint:sobotLayoutMarginTop(25, btn, lblTitle)];
            
        }
    }
    
}


-(void)refresh:(UIButton *) btn{
//    NSLog(@"点击了");
    if(_refreshBlock){
        _refreshBlock(btn);
    }
}

@end
