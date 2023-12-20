//
//  SobotSatisfactionItemView.m
//  SobotKit
//
//  Created by zhangxy on 2023/8/21.
//

#import "SobotSatisfactionItemView.h"
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClient.h>
#import "ZCUIKitTools.h"


// 一行中最3列
#define MaxCols 2

@interface SobotSatisfactionItemView(){
    UIView *lastView;
    
    NSArray *titleArr;
    NSString *labelArr;
    // 是否横屏
    BOOL isMulMode;
}

@end

@implementation SobotSatisfactionItemView


-(instancetype)init{
    self = [super init];
    if (self) {
        
        self.backgroundColor = UIColor.clearColor;
    }
    return self;
}


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        self.userInteractionEnabled = YES;
    }
    return self;
}

-(CGFloat)getHeight{
    if(lastView){
        [lastView sizeToFit];
        return CGRectGetMaxY(lastView.frame);
    }
    return 0;
}

-(void)clearData{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self layoutIfNeeded];
}

-(void)refreshData:(NSArray *)titles{
    [self refreshData:titles withCheckLabels:nil];
}

#pragma mark 横竖屏适配
-(void)viewOrientationChange{
    if(titleArr!=nil){
        labelArr = [self getSeletedTitle];
        [self refreshData:titleArr withCheckLabels:labelArr];
    }
}
// 适配iOS 13以上的横竖屏切换
// 横竖屏切换时，需要重新画
-(void)safeAreaInsetsDidChange{
    
    UIEdgeInsets e = self.safeAreaInsets;
    
    if(e.left > 0 || e.right > 0){
        // 横屏
        SLog(@"执行了横屏:l:%f-r:%f", e.left,e.right);
        if(!isMulMode && titleArr!=nil){
            labelArr = [self getSeletedTitle];
            [self refreshData:titleArr withCheckLabels:labelArr];
        }
    }else{
        // 竖屏
        SLog(@"执行了竖屏:t:%f-b:%f", e.top,e.bottom);
        if(isMulMode && titleArr!=nil){
            labelArr = [self getSeletedTitle];
            [self refreshData:titleArr withCheckLabels:labelArr];
        }
    }
}


-(void)refreshData:(NSArray *)titles withCheckLabels:(NSString * _Nullable) labels{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    int tagI = 100;
    NSArray *checksArr = @[];
    if(sobotConvertToString(labels).length > 0){
        checksArr = [sobotConvertToString(labels) componentsSeparatedByString:@","];
    }
    
    CGFloat spaceX = 10;
    CGFloat spaceY = 20;
    CGFloat spaveXY = 0;
        
    
    [self sizeToFit];
    CGFloat maxWidth = CGRectGetWidth(self.frame) - spaveXY * 2;
    
    CGFloat ih = 36;
    lastView = nil;
    titleArr = titles;
    labelArr = labels;
    
    isMulMode = NO;
    // 如果当前宽大于高，说明是横屏
    if(ScreenWidth > ScreenHeight){
        isMulMode = YES;
    }
    
    CGFloat cw = 0;
    // 3.0.1开始，使用动态宽度
    for (int index=0;index<titles.count;index ++) {
        
        UIButton *titleBT= [UIButton buttonWithType:UIButtonTypeCustom];
        [titleBT setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
      
        titleBT.titleLabel.numberOfLines = 1;
        titleBT.layer.cornerRadius = ih /2;
        titleBT.layer.borderWidth = 0.75f;
        if([SobotUITools getSobotThemeMode] == SobotThemeMode_Dark){
            titleBT.layer.borderColor = UIColorFromKitModeColor(SobotColorBgMainDark2).CGColor;
            [titleBT setTitleColor:UIColorFromKitModeColor(SobotColorTextSub) forState:UIControlStateNormal];
            [titleBT setTitleColor:[ZCUIKitTools zcgetTextNolColor] forState:UIControlStateHighlighted];
            [titleBT setTitleColor:[ZCUIKitTools zcgetTextNolColor] forState:UIControlStateSelected];
        }else{
            titleBT.layer.borderColor = [UIColor whiteColor].CGColor;
            [titleBT setTitleColor:[ZCUIKitTools zcgetServerConfigBtnBgColor] forState:UIControlStateNormal];
            [titleBT setTitleColor:UIColorFromKitModeColor(SobotColorWhite) forState:UIControlStateHighlighted];
            [titleBT setTitleColor:UIColorFromKitModeColor(SobotColorWhite) forState:UIControlStateSelected];
        }
        titleBT.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        titleBT.layer.masksToBounds=YES;
        [titleBT.titleLabel setFont:SobotFont14];
        [titleBT setBackgroundImage:[SobotImageTools sobotImageWithColor:[ZCUIKitTools zcgetCommentItemButtonBgColor]] forState:UIControlStateNormal];
        [titleBT setBackgroundImage:[SobotImageTools sobotImageWithColor:[ZCUIKitTools zcgetServerConfigBtnBgColor]] forState:UIControlStateSelected];
        [titleBT setBackgroundImage:[SobotImageTools sobotImageWithColor:[ZCUIKitTools zcgetServerConfigBtnBgColor]] forState:UIControlStateHighlighted];
        
        
        tagI = tagI + 1;
        titleBT.tag = tagI;
        [self  addSubview:titleBT];
        [titleBT addTarget:self action:@selector(Click:) forControlEvents:UIControlEventTouchUpInside];
       
        NSString *title = titles[index];
        [titleBT setTitle:title forState:0];
        [titleBT sizeToFit];
        
        CGRect f = titleBT.frame;
        
        CGFloat iw = f.size.width + 32;
        if(iw > maxWidth){
            iw = maxWidth;
        }
        [self addConstraints:sobotLayoutSize(iw, ih, titleBT, NSLayoutRelationEqual)];
        
        if(lastView==nil){
            // 第一个，直接居左
            [self addConstraint:sobotLayoutPaddingTop(0, titleBT, self)];
            [self addConstraint:sobotLayoutPaddingLeft(spaveXY, titleBT, self)];
            cw = iw + spaceX;
        }else{
            [lastView sizeToFit];
            
            // 剩余宽度
            CGFloat nextWidth = maxWidth - cw;
            if(iw > nextWidth){
                cw = iw + spaceX;
                // 另起一行
                [self addConstraint:sobotLayoutMarginTop(spaceY, titleBT, lastView)];
                [self addConstraint:sobotLayoutPaddingLeft(spaveXY, titleBT, self)];
            }else{
                cw = cw + iw + spaceX;
                // 排后面
                [self addConstraint:sobotLayoutMarginLeft(spaceX, titleBT, lastView)];
                [self addConstraint:sobotLayoutPaddingTop(0, titleBT, lastView)];
            }
        }
        
        lastView = titleBT;
        if(checksArr.count > 0 && [checksArr containsObject:title]){
            [self Click:titleBT];
        }
    }
    
    [self addConstraint:sobotLayoutPaddingBottom(0, lastView, self)];
}

-(void)Click:(UIButton *)bt{
    bt.selected = !bt.selected;
    if (bt.selected) {
        if([SobotUITools getSobotThemeMode] == SobotThemeMode_Dark){
            bt.layer.borderColor = UIColorFromKitModeColor(SobotColorBgMainDark2).CGColor;
        }else{
            bt.layer.borderColor = [UIColor whiteColor].CGColor;
        }
    }else{
        if([SobotUITools getSobotThemeMode] == SobotThemeMode_Dark){
            bt.layer.borderColor = UIColorFromKitModeColor(SobotColorBgMainDark2).CGColor;
        }else{
            bt.layer.borderColor = [UIColor whiteColor].CGColor;
        }
    }
}

-(NSString *)getSeletedTitle{
   __block NSString *title = @"";
    for(UIView *objV in self.subviews){
        int tag=(int)objV.tag;
        if(tag>100 && tag<=107 && [objV isKindOfClass:[UIButton class]]){
            UIButton *btn=(UIButton *)objV;
            if(btn.selected){
                if(title.length == 0){
                    title = btn.titleLabel.text;
                }else{
                    title=[NSString stringWithFormat:@"%@,%@",title,btn.titleLabel.text];
                }
            }
        }
    }
    return title;
}

@end
