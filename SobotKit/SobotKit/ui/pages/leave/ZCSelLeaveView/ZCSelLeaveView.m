//
//  ZCSelLeaveView.m
//  SobotKit
//
//  Created by lizhihui on 2019/2/19.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCSelLeaveView.h"
#import <SobotCommon/SobotCommon.h>
#import "ZCUIKitTools.h"

@interface ZCSelLeaveView(){
    CGFloat viewWidth;
    CGFloat viewHeight;
    NSMutableArray *listArray;
    int _msgId;
    NSInteger isExist;// 记录关闭留言的模式
}
@property (nonatomic,strong) UIView * backGroundView;
@property(nonatomic,strong) UIScrollView *scrollView;

@end

@implementation ZCSelLeaveView

-(ZCSelLeaveView*)initActionSheet:(NSMutableArray *)array WithView:(UIView *)view MsgID:(int)msgId IsExist:(NSInteger) isExist{
    self = [super init];
    if (self) {
        viewWidth = view.frame.size.width;
        viewHeight = ScreenHeight;
        _msgId = msgId;
        if (!listArray) {
            listArray = [[NSMutableArray alloc]init];
        }
        listArray = array;
        self.frame = CGRectMake(0, 0, viewWidth, viewHeight);
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.autoresizesSubviews = YES;
        self.backgroundColor = UIColorFromModeColorAlpha(SobotColorBlack, 0.6);
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareViewDismiss:)];
        [self addGestureRecognizer:tapGesture];
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews{
    CGFloat bw=viewWidth;
    self.backGroundView = [[UIView alloc] initWithFrame:CGRectMake((viewWidth - bw) / 2.0, viewHeight, bw, 0)];
    self.backGroundView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
    self.backGroundView.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
    self.backGroundView.layer.masksToBounds = YES;
    [self addSubview:self.backGroundView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, bw, 60)];
    [titleLabel setText:SobotKitLocalString(@"请选择要留言的业务")];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    self.backGroundView.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
    [titleLabel setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
    [titleLabel setFont:SobotFontBold17];
    [self.backGroundView addSubview:titleLabel];

    // 线条
     UIView *topline = [[UIView alloc]initWithFrame:CGRectMake(0, 60, viewWidth, 0.5)];
     topline.backgroundColor = [ZCUIKitTools zcgetCommentButtonLineColor];
     topline.autoresizingMask = UIViewAutoresizingFlexibleWidth;
     [self.backGroundView addSubview:topline];
    
    // 左上角的删除按钮
    UIButton *cannelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cannelButton setFrame:CGRectMake(viewWidth - 40, (60 - 30)/2, 30,30)];
    cannelButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [cannelButton setImage:[SobotUITools getSysImageByName:@"zcicon_sf_close"] forState:UIControlStateNormal];
    cannelButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cannelButton addTarget:self action:@selector(tappedCancel) forControlEvents:UIControlEventTouchUpInside];
    [self.backGroundView addSubview:cannelButton];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 61, bw, 0)];
    self.scrollView.showsVerticalScrollIndicator=YES;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.scrollView.bounces = NO;
    [self.backGroundView addSubview:self.scrollView];
    
    CGFloat x=20;
    CGFloat y=20;
    CGFloat itemH = 36;
    CGFloat itemW = (bw-50)/2.0f;
    
    for (int i=0; i<listArray.count; i++) {
        UIButton *itemView = [self addItemView:listArray[i] withX:x withY:y withW:itemW withH:itemH];
        itemView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin;
        [itemView setBackgroundColor:[UIColor whiteColor]];
        itemView.userInteractionEnabled = YES;
        itemView.tag = i;
        [itemView addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
        if(i%2==1){
            x = 20;
            y = y + itemH + 20;
        }else if(i%2==0){
            x = itemW + 30;
        }
        [self.scrollView addSubview:itemView];
    }
    
    int index = listArray.count%2==0?round(listArray.count/2):round(listArray.count/2)+1;
    CGFloat h = index*(itemH) + (index + 1) * 20;
    if(h > viewHeight*0.6){
        h = viewHeight*0.6;
    }
    [self.scrollView setFrame:CGRectMake(0, 61, bw, h)];
    [self.scrollView setContentSize:CGSizeMake(bw, index*itemH + (index+1)*20)];
    
    [UIView animateWithDuration:0.25f animations:^{
        [self->_backGroundView setFrame:CGRectMake(self->_backGroundView.frame.origin.x, self->viewHeight - CGRectGetMaxY(self->_scrollView.frame)- XBottomBarHeight - 20,self->_backGroundView.frame.size.width, CGRectGetMaxY(self->_scrollView.frame)+XBottomBarHeight + 20)];
    } completion:^(BOOL finished) {
        
    }];
}
-(void)addBorderWithColor:(UIColor *)color isBottom:(BOOL) isBottom with:(UIView *) view{
    CGFloat borderWidth = 0.75f;
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    if(isBottom){
        border.frame = CGRectMake(0, view.frame.size.height - borderWidth, self.frame.size.width, borderWidth);
    }else{
        border.frame = CGRectMake(view.frame.size.width - borderWidth,0, borderWidth, self.frame.size.height);
    }
    border.name=@"border";
    [view.layer addSublayer:border];
}

-(void)addBorderWithColor:(UIColor *)color with:(UIView *) view{
    CGFloat borderWidth = 0.75f;
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    border.frame = CGRectMake(0, 0, self.frame.size.width, borderWidth);
    border.name=@"border";
    [view.layer addSublayer:border];
}


-(UIButton *)addItemView:(ZCWsTemplateModel *) model withX:(CGFloat )x withY:(CGFloat) y withW:(CGFloat) w withH:(CGFloat) h{
    UIButton *itemView = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w,h)];
    [itemView setFrame:CGRectMake(x, y, w, h)];
    itemView.layer.cornerRadius = h/2;
    itemView.layer.masksToBounds = YES;
    [itemView.titleLabel setFont:SobotFont14];
    
    [itemView setTitleColor:[ZCUIKitTools zcgetThemeToWhiteColor] forState:UIControlStateNormal];
    [itemView setTitleColor:[ZCUIKitTools zcgetTextNolColor] forState:UIControlStateHighlighted];
    [itemView setTitleColor:[ZCUIKitTools zcgetTextNolColor] forState:UIControlStateSelected];
    [itemView setBackgroundImage:[SobotImageTools sobotImageWithColor:UIColorFromKitModeColor(SobotColorBgSub)] forState:UIControlStateNormal];
    [itemView setBackgroundImage:[SobotImageTools sobotImageWithColor:[ZCUIKitTools zcgetCommentButtonLineColor]] forState:UIControlStateSelected];
    [itemView setBackgroundImage:[SobotImageTools sobotImageWithColor:[ZCUIKitTools zcgetCommentButtonLineColor]] forState:UIControlStateHighlighted];
    // 设置文字长度 最多20个字 1行显示
    itemView.titleLabel.numberOfLines = 1;
    [itemView setTitle:sobotConvertToString(model.templateName) forState:UIControlStateNormal];
    [itemView setTitle:sobotConvertToString(model.templateName) forState:UIControlStateHighlighted];
    itemView.titleLabel.textAlignment = NSTextAlignmentCenter;
    return itemView;
}

- (void)showInView:(UIView *)view{
    [[SobotUITools getCurWindow] addSubview:self];
}

// 隐藏弹出层
- (void)shareViewDismiss:(UITapGestureRecognizer *) gestap{
    CGPoint point = [gestap locationInView:self];
    CGRect f=self.backGroundView.frame;
    if(point.x<f.origin.x || point.x>(f.origin.x+f.size.width) ||
       point.y<f.origin.y || point.y>(f.origin.y+f.size.height)){
        [self tappedCancel:YES];
    }
}

- (void)tappedCancel{
    [self tappedCancel:YES];
}

/**
 *  关闭弹出层
 */
- (void)tappedCancel:(BOOL) isClose{
    // 移除通知
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.backGroundView setFrame:CGRectMake(_backGroundView.frame.origin.x,viewHeight ,self.backGroundView.frame.size.width,self.backGroundView.frame.size.height)];
    [self removeFromSuperview];
}

-(void)itemClick:(UIButton *)sender{
    ZCWsTemplateModel * model = listArray[sender.tag];
    if (_msgSetClickBlock) {
        _msgSetClickBlock(model);
    }
    [self tappedCancel];
}


@end