//
//  EmojiBoardView.m
//  SobotApp
//
//  Created by 张新耀 on 15/9/15.
//  Copyright (c) 2015年 com.sobot.chat. All rights reserved.
//

#import "EmojiBoardView.h"
#import <SobotChatClient/SobotChatClient.h>

#import "ZCUIKitTools.h"

@interface EmojiBoardView()
{
    CGFloat w;
    CGFloat vH;
}
@end

@implementation EmojiBoardView



-(id)initWithBoardHeight:(CGFloat ) height pW:(CGFloat) pw{
    w = pw;
    self = [super init];
    if (self) {
        self.userInteractionEnabled=YES;
        self.backgroundColor = UIColorFromModeColor(SobotColorBgMainDark1);
        
//        _faceMap = [ZCUITools allExpressionArray];
//        if(_faceMap==nil){
//            _faceMap = @[];
//        }
        
        [self setEmojiArray];
        
        //表情盘
        faceView = [[UIScrollView alloc]init];
        faceView.pagingEnabled = YES;
        faceView.showsHorizontalScrollIndicator = NO;
        faceView.showsVerticalScrollIndicator = NO;
        faceView.delegate = self;
        faceView.backgroundColor = UIColor.clearColor;
        //添加键盘View
        [self addSubview:faceView];
        
        //添加PageControl
        facePageControl = [[UIPageControl alloc]init];
        [facePageControl addTarget:self
                            action:@selector(pageChange:)
                  forControlEvents:UIControlEventValueChanged];
        facePageControl.pageIndicatorTintColor=[UIColor lightGrayColor];
        facePageControl.currentPageIndicatorTintColor=[UIColor darkGrayColor];
        facePageControl.currentPage = 0;
        [self addSubview:facePageControl];
        
        
        
        [self addConstraint:sobotLayoutPaddingLeft(0, faceView, self)];
        [self addConstraint:sobotLayoutMarginBottom(0, faceView, facePageControl)];
        [self addConstraint:sobotLayoutPaddingRight(0, faceView, self)];
        [self addConstraint:sobotLayoutPaddingTop(0, faceView, self)];
    
        
        [self addConstraint:sobotLayoutEqualHeight(20, facePageControl, NSLayoutRelationLessThanOrEqual)];
        [self addConstraint:sobotLayoutPaddingLeft(0, facePageControl, self)];
        [self addConstraint:sobotLayoutPaddingBottom(0, facePageControl, self)];
        [self addConstraint:sobotLayoutPaddingRight(0, facePageControl, self)];
        
        
//        UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [sendButton setBackgroundColor:[ZCUITools zcgetChatBackgroundColor]];
//        [sendButton.layer setCornerRadius:3.0f];
//        [sendButton.layer setMasksToBounds:YES];
//        [sendButton setTitle:@"发送" forState:UIControlStateNormal];
//        [sendButton.titleLabel setFont:ZCUIFont12];
//        [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [sendButton setFrame:CGRectMake(width-70, height-35, 50, 25)];
//        [sendButton addTarget:self action:@selector(sendEmoji) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:sendButton];
        
//        [self addItemsViewWithHeight:height];
    }
    
    return self;
}

-(void)setEmojiArray{
    _faceMap = @[@"😃",@"😄",@"😁",@"😆",@"😅",@"🤣",@"😂",@"🙂",@"😉",@"😊",@"😇",@"😍",@"🤩",@"😘",@"😚",@"😙",@"😋",@"😜",@"😝",@"🤗",@"🤭",@"🤔",@"🤐",@"😑",@"😏",@"😒",@"😌",@"😔",@"😷",@"🤒",@"😵",@"🤠",@"😎",@"🤓",@"😳",@"😨",@"😰",@"😥",@"😢",@"😭",@"😱",@"😖",@"😣",@"😓",@"😠",@"👋",@"👌",@"✌",@"🤟",@"👍",@"👏",@"🤝",@"🙏",@"💪",@"🙇‍♀️",@"🐮",@"🌹",@"🥀",@"💋",@"❤️",@"💔",@"⭐",@"🎉",@"🍺",@"🎁"];
}

-(void)refreshItemsView:(CGFloat)emojiHeight{
    [self addItemsViewWithHeight:emojiHeight];
}

-(void) addItemsViewWithHeight:(CGFloat)height{
    if(vH == height){
        return;
    }
    
    vH = height;
    
    for (UIView *item in faceView.subviews) {
        [item removeFromSuperview];
    }
    
    CGFloat width=SobotViewWidth(self);
    CGFloat EmojiWidth  = 44;
    CGFloat EmojiHeight = 48; // 2.8.4以前版本高度为44
    int columns         = width/EmojiWidth;
    // 当宽度无法除尽时，表情居中
    CGFloat itemX       = (width - columns * EmojiWidth)/2;
    
    int allSize         = (int)_faceMap.count;
    int rows            = (height-20)/EmojiHeight;
    int pageSize        = rows * columns-2;
    int pageNum         = (allSize%pageSize==0) ? (allSize/pageSize) : (allSize/pageSize+1);
    
    
    if(pageNum > 1){
        faceView.contentSize = CGSizeMake(pageNum * width, height-26);// 原固定高度 190
        facePageControl.numberOfPages = pageNum;
    }else{
        facePageControl.hidden = YES;
    }
    
    for(int i=0; i< pageNum; i++){
        //删除键
        UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
        [back setTitle:@"" forState:UIControlStateNormal];
        [back setImage:SobotKitGetImage(@"zcicon_emoji_del") forState:UIControlStateNormal];
        [back setImage:SobotKitGetImage(@"zcicon_emoji_del_press") forState:UIControlStateSelected];
        [back setImage:SobotKitGetImage(@"zcicon_emoji_del_press") forState:UIControlStateHighlighted];
        [back setBackgroundColor:[UIColor clearColor]];
        //        [back setImage:[UIImage imageNamed:@"del_emoji_normal"] forState:UIControlStateNormal];
        //        [back setImage:[UIImage imageNamed:@"del_emoji_select"] forState:UIControlStateSelected];
        [back addTarget:self action:@selector(backFace) forControlEvents:UIControlEventTouchUpInside];
        back.frame = CGRectMake(itemX+i*width + (columns-2)*EmojiWidth, EmojiHeight * (rows-1)+8, EmojiWidth, EmojiHeight);
        [back setImageEdgeInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
        [back.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [faceView addSubview:back];
        
        //发送键
        UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [sendButton setTitle:SobotKitLocalString(@"发送") forState:UIControlStateNormal];
        [sendButton.titleLabel setFont:SobotFont14];
        [sendButton.layer setCornerRadius:4.0f];
        [sendButton.layer setMasksToBounds:YES];
//        [sendButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_emoji_send"] forState:UIControlStateNormal];
//        [sendButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_emoji_send_press"] forState:UIControlStateSelected];
//        [sendButton setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_emoji_send_press"] forState:UIControlStateHighlighted];
//        [sendButton setBackgroundColor:[UIColor clearColor]];
        // 更改更随主题色
        [sendButton setBackgroundImage:[SobotImageTools sobotImageWithColor:[ZCUIKitTools zcgetLeaveSubmitImgColor]] forState:UIControlStateNormal];
        [sendButton setBackgroundImage:[SobotImageTools sobotImageWithColor:[ZCUIKitTools zcgetLeaveSubmitImgColor]] forState:UIControlStateHighlighted];
        [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sendButton setImageEdgeInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
        //        [back setImage:[UIImage imageNamed:@"del_emoji_normal"] forState:UIControlStateNormal];
        //        [back setImage:[UIImage imageNamed:@"del_emoji_select"] forState:UIControlStateSelected];
        [sendButton addTarget:self action:@selector(sendEmoji) forControlEvents:UIControlEventTouchUpInside];
        [sendButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        sendButton.frame = CGRectMake(itemX+i*width + (columns-1)*EmojiWidth+1, EmojiHeight * (rows-1)+8+7, 42, 30);
        [faceView addSubview:sendButton];
        
        for (int j=0; j<pageSize; j++) {
//            NSDictionary *faceDict = [_faceMap objectAtIndex:i*pageSize+j];
            NSString *emojiString = [_faceMap objectAtIndex:i*pageSize+j];
//            NSString *text = [emojiString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            EmojiButton *faceButton = [EmojiButton buttonWithType:UIButtonTypeCustom];
            
            faceButton.buttonIndex = i*pageSize+j;
//            faceButton.faceTag=faceDict[@"KEY"];
//            faceButton.faceString=faceDict[@"KEY"];
//            [faceButton setTitle:faceKey forState:UIControlStateNormal];
            [faceButton setTitleColor:UIColorFromModeColor(SobotColorTextMain) forState:0];
            faceButton.faceString = emojiString;
            [faceButton.titleLabel setFont:[UIFont fontWithName:@"AppleColorEmoji" size:29.0]];
            [faceButton setUserInteractionEnabled:YES];
            [faceButton addTarget:self
                           action:@selector(faceButton:)
                 forControlEvents:UIControlEventTouchUpInside];
            
            //计算每一个表情按钮的坐标和在哪一屏
            CGFloat x = i * width + (j%columns) * EmojiWidth+itemX;
            
            CGFloat y = 8;
            if(j>=columns){
                y = (j / columns) * EmojiHeight + 8;
            }
            
            faceButton.frame = CGRectMake( x, y, EmojiWidth, EmojiHeight);
            [faceButton setImageEdgeInsets:UIEdgeInsetsMake(7, 7, 7, 7)];
//            [faceButton setImage:[ZCUITools zcuiGetExpressionBundleImage:[NSString stringWithFormat:@"%@.png",faceDict[@"VALUE"]]]
//                        forState:UIControlStateNormal];
            [faceButton setBackgroundColor:[UIColor clearColor]];
            [faceButton setTitle:emojiString forState:0];
            
            [faceView addSubview:faceButton];
            
            if((i*pageSize+j+1)>=allSize){
                break;
            }
        }
    }
}

//停止滚动的时候
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    [facePageControl setCurrentPage:faceView.contentOffset.x / w];
    // 更新页码
    [facePageControl updateCurrentPageDisplay];
}

- (void)pageChange:(id)sender {
    
    [faceView setContentOffset:CGPointMake(facePageControl.currentPage * w, 0) animated:YES];
    [facePageControl setCurrentPage:facePageControl.currentPage];
}

- (void)faceButton:(id)sender {
    EmojiButton *btn = (EmojiButton*)sender;
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(onEmojiItemClick:faceName:index:)]){
        [self.delegate onEmojiItemClick:btn.faceTag faceName:btn.faceString index:btn.buttonIndex];
    }
}

- (void)backFace{
    if(self.delegate && [self.delegate respondsToSelector:@selector(emojiAction:)]){
        [self.delegate emojiAction:EmojiActionDel];
    }
}

- (void)sendEmoji{
    if(self.delegate && [self.delegate respondsToSelector:@selector(emojiAction:)]){
        [self.delegate emojiAction:EmojiActionSend];
    }
}

@end
