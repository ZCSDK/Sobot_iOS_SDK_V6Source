//
//  RatingViewController.m
//  RatingController
//
//  Created by Ajay on 2/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ZCUIRatingView.h"
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClientCache.h>
#import "ZCUIKitTools.h"
@interface ZCUIRatingView()

@end

@implementation ZCUIRatingView

-(void)setImagesDeselected:(NSString *)unselectedImage partlySelected:(NSString *)partlySelectedImage fullSelected:(NSString *)fullSelectedImage andDelegate:(id<RatingViewDelegate>)d{
    [self setImagesDeselected:unselectedImage partlySelected:partlySelectedImage fullSelected:fullSelectedImage count:5 andDelegate:d];
}

-(void)setImagesDeselected:(NSString *)deselectedImage
			partlySelected:(NSString *)halfSelectedImage
			  fullSelected:(NSString *)fullSelectedImage
                     count:(int)count andDelegate:(id<RatingViewDelegate>)d{
    unselectedImage = [SobotUITools getSysImageByName:deselectedImage];// [UIImage imageNamed:deselectedImage];
    partlySelectedImage =  halfSelectedImage == nil ? unselectedImage : [SobotUITools getSysImageByName:halfSelectedImage]; //[UIImage imageNamed:halfSelectedImage];
    fullySelectedImage = [SobotUITools getSysImageByName:fullSelectedImage]; //[UIImage imageNamed:fullSelectedImage];
	viewDelegate = d;
	
	height= 29;
//    if(height > self.frame.size.height){
//        height = self.frame.size.height;
//    }
    _starView = [[NSMutableArray alloc] init];
    starRating = 0;
    lastRating = 0;
    CGFloat space = 0;
    CGFloat y = 0;
    if(count == 2){
        [self createSatisfieViews:2];
        height = 64;
    }else{
        if(count > 5){
            // 增加0
            count = count + 1;
            UILabel *lab1 = [self createLabel:0 title:SobotKitLocalString(@"非常不满意")];
            UILabel *lab2 = [self createLabel:self.frame.size.width/2 title:SobotKitLocalString(@"非常满意")];
            [self addSubview:lab1];
            [self addSubview:lab2];
            [lab2 setTextAlignment:NSTextAlignmentRight];
            y = 25;
            space =  5;
        }
        
        width=  self.frame.size.width/count;
        int n = 0;
        
        if(count > 6){
            width = self.frame.size.width / 6;
        }
        for (int i=1; i<=count; i++) {
            UIView *ss = nil;
            if(count > 5){
                ss = [self createLabel:(i-1)*width title:[NSString stringWithFormat:@"%d",i - 1]];
                [ss setFrame:CGRectMake((i-1)*width-n*width + (n>0?width/2:0), y, width-10, height)];
                [ss setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMain)];
                [(UILabel *)ss setTextColor:[ZCUIKitTools getNotifitionTopViewLabelColor]];
                ((UILabel *)ss).layer.cornerRadius = 4;
                ((UILabel *)ss).layer.borderColor = UIColorFromKitModeColor(SobotColorBgLine).CGColor;
                ((UILabel *)ss).layer.borderWidth = 1.0f;
                ((UILabel *)ss).textAlignment = NSTextAlignmentCenter;
                ((UILabel *)ss).layer.masksToBounds = YES;
                ((UILabel *)ss).font = [ZCUIKitTools zcgetKitChatFont];
                if(i == 6){
                    y = y + 10+height;
                    n = 6;
                }
            }else{
                ss = [[UIImageView alloc] initWithImage:unselectedImage];
                [ss setContentMode:UIViewContentModeScaleAspectFit];
                [ss setFrame:CGRectMake((i-1)*width,         y, width, height)];
            }
            
            [ss setUserInteractionEnabled:YES];
            ss.tag = 100+i;
            UITapGestureRecognizer * tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
            [ss addGestureRecognizer:tap1];
            [self addSubview:ss];
            [_starView addObject:ss];
        }
    }
	CGRect frame = [self frame];
	frame.size.width = width * count;
	frame.size.height = height + y;
	[self setFrame:frame];
}

-(void)createSatisfieViews:(int) count{
    if(count == 2){
        UIView *centerV = [[UIView alloc] init];
        centerV.backgroundColor = UIColor.clearColor;
        [self addSubview:centerV];
        [self addConstraints:sobotLayoutSize(80, 1, centerV, NSLayoutRelationEqual)];
        [self addConstraint:sobotLayoutEqualCenterX(0, centerV, self)];
        
        [self addConstraint:sobotLayoutPaddingTop(0, centerV, self)];
        for(int index=1;index<=2;index++){
            
            UIButton *ss = [[UIButton alloc] init];
            [ss setContentMode:UIViewContentModeScaleAspectFit];
            ss.tag = 100+index;
            [self addSubview:ss];
            [ss addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addConstraints:sobotLayoutSize(32, 64, ss, NSLayoutRelationEqual)];
            if(index == 1){
                [self addConstraint:sobotLayoutMarginRight(0, ss, centerV)];
            }else{
                [self addConstraint:sobotLayoutMarginLeft(0, ss, centerV)];
            }
            [self addConstraint:sobotLayoutPaddingTop(0, ss, self)];
            
            [_starView addObject:ss];
            
            UILabel *lab = [[UILabel alloc] init];
            [lab setTextColor:UIColorFromKitModeColor(SobotColorTextSub)];
            lab.tag = 200+index;
            [lab setFont:[ZCUIKitTools zcgetListKitDetailFont]];
            [self addSubview:lab];
            
            [self addConstraint:sobotLayoutEqualCenterX(0, lab, ss)];
            [self addConstraint:sobotLayoutPaddingBottom(0, lab, ss)];
            [self addConstraint:sobotLayoutEqualHeight(20, lab, NSLayoutRelationEqual)];
            if(index == 1){
                [ss setImage:SobotKitGetImage(@"zcicon_satisfied") forState:UIControlStateNormal];
                [ss setImage:SobotKitGetImage(@"zcicon_satisfied_checked") forState:UIControlStateSelected];
                [ss setImage:SobotKitGetImage(@"zcicon_satisfied_checked") forState:UIControlStateHighlighted];
                [lab setText:SobotKitLocalString(@"满意")];
            }else{
                [ss setImage:SobotKitGetImage(@"zcicon_dissatisfied") forState:UIControlStateNormal];
                [ss setImage:SobotKitGetImage(@"zcicon_dissatisfied_checked") forState:UIControlStateSelected];
                [ss setImage:SobotKitGetImage(@"zcicon_dissatisfied_checked") forState:UIControlStateHighlighted];
                [lab setText:SobotKitLocalString(@"不满意")];
            }
            
            if(index == 1){
                [self addConstraint:sobotLayoutPaddingBottom(0, ss, self)];
            }
        }
    }
}


-(void)displayRating:(float)rating {
    for (UIView *ss in _starView) {
        int index = (int)ss.tag - 100;
        if([ss isKindOfClass:[UIImageView class]]){
            if(index<=rating){
                [(UIImageView *)ss setImage:fullySelectedImage];
            }else{
                [(UIImageView *)ss setImage:unselectedImage];
            }
        }else if([ss isKindOfClass:[UIButton class]]){
            UILabel *lab = [self viewWithTag:200+index];
            if(index == rating){
                [(UIButton *)ss setSelected:YES];
                [lab setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
            }else{
                [(UIButton *)ss setSelected:NO];
                [lab setTextColor:UIColorFromKitModeColor(SobotColorTextSub)];
            }
        }else{
            if(index<=rating){
                ((UILabel *)ss).layer.borderColor = [UIColor clearColor].CGColor;
                ((UILabel *)ss).layer.borderWidth = 0;
                [ss setBackgroundColor:UIColorFromKitModeColor(SobotColorYellow)];
                [(UILabel *)ss setTextColor:UIColorFromKitModeColor(SobotColorWhite)];
            }else{
                [(UILabel *)ss setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
                [ss setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMain)];
                ((UILabel *)ss).layer.borderColor = UIColorFromKitModeColor(SobotColorBgLine).CGColor;;
                ((UILabel *)ss).layer.borderWidth = 1;
            }
        }
        // 0.5分情况不考虑
//        if((rating*10)%5){
//[ss setImage:partlySelectedImage];
//        }
    }
	starRating = rating;
	lastRating = rating;
	[viewDelegate ratingChanged:rating];
}

//-(void) touchesBegan: (NSSet *)touches withEvent: (UIEvent *)event
//{
//    [super touchesBegan:touches withEvent:event];
//	[self touchesMoved:touches withEvent:event];
//}
//
//-(void) touchesMoved: (NSSet *)touches withEvent: (UIEvent *)event
//{
//    [super touchesMoved:touches withEvent:event];
//    
//	CGPoint pt = [[touches anyObject] locationInView:self];
//	int newRating = (int) (pt.x / width) + 1;
//	if (newRating < 1 || newRating > 5)
//		return;
//	
//	if (newRating != lastRating)
//    {
//        [self displayRating:newRating];
//    }else{
//        [self displayRating:newRating-1];
//    }
//}
//
//-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//    [super touchesEnded:touches withEvent:event];
//	[self touchesMoved:touches withEvent:event];
//}

- (void)tapAction:(UITapGestureRecognizer*)tap{
    [self displayRating:tap.view.tag-100];
    if(viewDelegate && [viewDelegate respondsToSelector:@selector(ratingChangedWithTap:)]){
        [viewDelegate ratingChangedWithTap:tap.view.tag-100];
    }
    
}

-(void)btnClick:(UIButton *) btn{
    [self displayRating:btn.tag-100];
    if(viewDelegate && [viewDelegate respondsToSelector:@selector(ratingChangedWithTap:)]){
        [viewDelegate ratingChangedWithTap:btn.tag-100];
    }
}



-(float)rating {
	return starRating;
}


-(UILabel *)createLabel:(CGFloat ) x title:(NSString *) text{
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, self.frame.size.width/2, 20)];
    [lab setTextColor:UIColorFromKitModeColor(SobotColorTextSub)];
    [lab setText:text];
    [lab setFont:[ZCUIKitTools zcgetListKitDetailFont]];
    return lab;
}
@end
