//
//  ZCCustomBtnView.m
//  SobotKit
//
//  Created by lizh on 2025/3/9.
//

#import "ZCCustomBtnView.h"

@implementation ZCCustomBtnView

-(void)initWithTitle:(NSString *)title img:(UIImage*)img supView:(UIView*)supView{
    [self initWithTitle:title img:img iconL:16 iconH:self.iconH iconW:self.iconW titleFont:self.titleFont titleColor:self.titleColor btnHeight:self.btnHeight labL:4 supView:supView];
}

-(void)initWithTitle:(NSString *)title img:(UIImage*)img iconL:(CGFloat)iconL iconH:(CGFloat)iconH iconW:(CGFloat)iconW  titleFont:(UIFont*)font titleColor:(UIColor*)titleColor btnHeight:(CGFloat)btnHeight labL:(CGFloat)labL supView:(UIView*)supView{
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // 这里需要计算宽度
    NSString *tip = title;
    CGFloat w1 = [SobotUITools getWidthContain:tip font:font Height:btnHeight];
    // 左右间距
    w1 = w1 + 16*2 + labL + iconW;
    _bgView = ({
        UIView *iv = [[UIView alloc]init];
        [supView addSubview:iv];
        [supView addConstraint:sobotLayoutEqualCenterX(0, iv, supView)];
        [supView addConstraint:sobotLayoutEqualCenterY(0, iv, supView)];
        self.layoutBtnH = sobotLayoutEqualHeight(btnHeight, iv, NSLayoutRelationEqual);
        [supView addConstraint:self.layoutBtnH];
        [supView addConstraint:sobotLayoutEqualWidth(w1, iv, NSLayoutRelationEqual)];
        iv;
    });
    
    _iconImg = ({
        UIImageView *iv = [[UIImageView alloc] init];
        [_bgView addSubview:iv];
        iv.contentMode = UIViewContentModeScaleAspectFit;
        [iv setImage:img];
        [_bgView addConstraints:sobotLayoutSize(iconW, iconH, iv, NSLayoutRelationEqual)];
        [_bgView addConstraint:sobotLayoutPaddingLeft(iconL, iv, _bgView)];
        [_bgView addConstraint:sobotLayoutEqualCenterY(0, iv, _bgView)];
        iv;
    });
    
    _titleLab = ({
        UILabel *iv = [[UILabel alloc]init];
        [_bgView addSubview:iv];
        iv.textColor = titleColor;
        iv.font = _titleFont;
        iv.text = title;
        iv.numberOfLines = 1;
        iv.lineBreakMode = NSLineBreakByTruncatingTail;
        [_bgView addConstraint:sobotLayoutMarginLeft(labL, iv, _iconImg)];
        [_bgView addConstraint:sobotLayoutPaddingRight(-16, iv, _bgView)];
        [_bgView addConstraint:sobotLayoutPaddingTop(0, iv, _bgView)];
        [_bgView addConstraint:sobotLayoutPaddingBottom(0, iv, _bgView)];
        iv;
    });
}

@end
