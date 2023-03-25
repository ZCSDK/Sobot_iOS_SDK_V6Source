//
//  ItemView.m
//  CollectionViewDemo
//
//  Created by on 2017/6/18.
//  Copyright © 2017年 . All rights reserved.
//

#import "ZCItemView.h"
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClient.h>
#import "ZCUIKitTools.h"

// 一行中最3列
#define MaxCols 2

@interface ZCItemView(){
    CGFloat maxHeight;
}

@end
@implementation ZCItemView

-(void)layoutSubviews{
    [super layoutSubviews];
    self.userInteractionEnabled = YES;
}

-(CGFloat)getHeightWithArray:(NSArray *)titles{
    return maxHeight;
}

-(void)InitDataWithArray:(NSArray *)titles{
    [self InitDataWithArray:titles withCheckLabels:nil];
}

-(void)InitDataWithArray:(NSArray *)titles withCheckLabels:(NSString *)labels{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    int tagI = 100;
    NSArray *checksArr = @[];
    if(sobotConvertToString(labels).length > 0){
        checksArr = [sobotConvertToString(labels) componentsSeparatedByString:@","];
    }
    
    CGFloat spaceX = 10;
    CGFloat startX = 20;
    CGFloat spaceY = 20;
    CGFloat btnW =self.frame.size.width - startX * 2;
    
    CGFloat y = 0;
    CGFloat x = startX;
    
    // 3.0.1开始，使用动态宽度
    for (int index=0;index<titles.count;index ++) {
        NSString *title = titles[index];
        CGSize size = [title sizeWithFont:SobotFont14];
        CGFloat iw = size.width + 32;
        CGFloat ih = 36;
        if(iw > btnW){
            iw = btnW;
            ih = 34 + 16;
        }
        if(iw < (btnW-spaceX)/2){
            iw = (btnW-spaceX)/2;
        }
        UIButton *titleBT= [UIButton buttonWithType:UIButtonTypeCustom];
        [titleBT setTitleEdgeInsets:UIEdgeInsetsMake(0, 16, 0, 16)];
        titleBT.frame = CGRectMake(x, y, iw, ih);
        titleBT.titleLabel.numberOfLines = 0;
        [titleBT setTitle:title forState:UIControlStateNormal];
        titleBT.layer.cornerRadius = ih /2;
        titleBT.layer.borderWidth = 0.75f;
        if([SobotUITools getSobotThemeMode] == SobotThemeMode_Dark){
            titleBT.layer.borderColor = UIColorFromKitModeColor(SobotColorBgMainDark2).CGColor;
            [titleBT setTitleColor:UIColorFromKitModeColor(SobotColorTextSub) forState:UIControlStateNormal];
            [titleBT setTitleColor:[ZCUIKitTools zcgetTextNolColor] forState:UIControlStateHighlighted];
            [titleBT setTitleColor:[ZCUIKitTools zcgetTextNolColor] forState:UIControlStateSelected];
        }else{
            titleBT.layer.borderColor = [UIColor whiteColor].CGColor;
            [titleBT setTitleColor:[ZCUIKitTools zcgetRobotBtnBgColor] forState:UIControlStateNormal];
            [titleBT setTitleColor:UIColorFromKitModeColor(SobotColorWhite) forState:UIControlStateHighlighted];
            [titleBT setTitleColor:UIColorFromKitModeColor(SobotColorWhite) forState:UIControlStateSelected];
        }
        titleBT.layer.masksToBounds=YES;
        [titleBT.titleLabel setFont:SobotFont14];
        [titleBT setBackgroundImage:[SobotImageTools sobotImageWithColor:[ZCUIKitTools zcgetCommentItemButtonBgColor]] forState:UIControlStateNormal];
        [titleBT setBackgroundImage:[SobotImageTools sobotImageWithColor:[ZCUIKitTools zcgetRobotBtnBgColor]] forState:UIControlStateSelected];
        [titleBT setBackgroundImage:[SobotImageTools sobotImageWithColor:[ZCUIKitTools zcgetRobotBtnBgColor]] forState:UIControlStateHighlighted];
        tagI = tagI + 1;
        titleBT.tag = tagI;
        [self  addSubview:titleBT];
        [titleBT addTarget:self action:@selector(Click:) forControlEvents:UIControlEventTouchUpInside];
        CGRect f = titleBT.frame;
        
        if((index+1) < titles.count){
            NSString * nextTitle = titles[index + 1];
            // 剩余宽度
            CGFloat nextWidth = btnW + startX - CGRectGetMaxX(f) - spaceX;
            // 下一个宽度
            CGFloat fontWidth = [nextTitle sizeWithFont:SobotFont14].width + 32;
            if(nextWidth < fontWidth){
                y = y + ih + spaceY;
                x = startX;
            }else{
                x = CGRectGetMaxX(f) + spaceX;
            }
        }else{
            // 获取最大高度
            maxHeight = y + ih;
        }
        if(checksArr.count > 0 && [checksArr containsObject:title]){
            [self Click:titleBT];
        }
    }
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
