//
//  ZCTurnRobotView.m
//  SobotKit
//
//  Created by lizhihui on 2018/5/24.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import "ZCTurnRobotView.h"
#import <SobotCommon/SobotCommon.h>
#import "ZCUIChatKeyboard.h"
#import "ZCUIKitTools.h"
@interface ZCTurnRobotView(){
    CGFloat viewWidth;
    CGFloat viewHeight;
    NSMutableArray *listArray;
    ZCUIChatKeyboard *_keyboardView;
    int _robotid;
}

@property (nonatomic,strong) UIView * backGroundView;
@property(nonatomic,strong) UIScrollView *scrollView;

@end

@implementation ZCTurnRobotView

-(ZCTurnRobotView*)initActionSheet:(NSMutableArray *)array WithView:(UIView *)view RobotId:(int)robotId{
    self = [super init];
    if (self) {
        viewWidth = view.frame.size.width;
        viewHeight = ScreenHeight;
        _robotid = robotId;
        listArray = array;
        if (!listArray) {
            listArray = [[NSMutableArray alloc]init];
        }
        self.frame = CGRectMake(0, 0, viewWidth, viewHeight);
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.autoresizesSubviews = YES;
        self.backgroundColor = UIColorFromKitModeColorAlpha(SobotColorBlack, 0.6);
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
    self.backGroundView.autoresizesSubviews = YES;
    self.backGroundView.backgroundColor =  UIColorFromKitModeColor(SobotColorBgMainDark1);
    [self addSubview:self.backGroundView];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 18, bw -44*2, 24)];
    [titleLabel setText:SobotKitLocalString(@"请选择要咨询的业务")];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setBackgroundColor: UIColorFromKitModeColor(SobotColorBgMainDark1)];
    [titleLabel setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
    [titleLabel setFont:SobotFontBold17];
    titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.backGroundView addSubview:titleLabel];
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel.frame) + 18, bw, 0.5)];
    lineView.backgroundColor = [ZCUIKitTools zcgetCommentButtonLineColor];
    lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.backGroundView addSubview:lineView];

    
    
    // 左上角的删除按钮
    UIButton *cannelButton = [[UIButton alloc]init];
    [cannelButton setFrame:CGRectMake(self.frame.size.width - 44 , 8, 44,44)];
    [cannelButton setImage:[SobotUITools getSysImageByName:@"zcicon_sf_close"] forState:UIControlStateNormal];
    cannelButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    [cannelButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    cannelButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [cannelButton addTarget:self action:@selector(tappedCancel) forControlEvents:UIControlEventTouchUpInside];
    [self.backGroundView addSubview:cannelButton];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 60, bw, 0)];
    self.scrollView.showsVerticalScrollIndicator=YES;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.scrollView.bounces = NO;
    self.scrollView.backgroundColor = UIColor.clearColor;
    [self.backGroundView addSubview:self.scrollView];
    
    CGFloat x= 20;
    CGFloat y= 20;
    
    CGFloat itemH = 36;
    CGFloat itemW = (bw-50)/2.0f;
    
    int index = listArray.count%2==0?round(listArray.count/2):round(listArray.count/2)+1;
    CGFloat maxh = 0;
    for (int i=0; i<listArray.count; i++) {
        
        ZCLibRobotSet *skillmodel = listArray[i];
        ZCLibRobotSet *nextModel;
        if ( i%2 == 0) {
            // 处理样式0
            if (i+1 <listArray.count) {
                nextModel = listArray[i+1];
//                nextModel.operationRemark = @"数量肯定福利卡吉机啦科技大理发卡进啦说法科机啦科技大理发卡进啦说法科机啦科技大理发卡进啦说法科利丁粉开机啦科技大理发卡进啦说法科技拉胯动静分离卡萨丁理发";
            }
            CGFloat leftH = [self getItemMaxHWith:skillmodel withW:itemW];
            CGFloat rightH = 0;
            if (!sobotIsNull(nextModel)) {
                rightH = [self getItemMaxHWith:nextModel withW:itemW];
            }
            itemH = leftH >rightH ? leftH :rightH;
            maxh = maxh + itemH + 20;
        }
        
        UIButton *itemView = [self addItemView:listArray[i] withX:x withY:y withW:itemW withH:itemH];

        itemView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
        [itemView setBackgroundColor:[UIColor whiteColor]];
        itemView.userInteractionEnabled = YES;
        itemView.tag = i;
        [itemView addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
        if(i%2==1){
            x = 20;
            y = y + itemH + 20;
        }else if(i%2==0){
            x = itemW + 20 + 10;
        }
        [self.scrollView addSubview:itemView];
    }
//    CGFloat h = index*(itemH) + (index + 1) * 20;
    CGFloat h = maxh;
    if(h > viewHeight*0.6){
        h = viewHeight*0.6;
    }
    [self.scrollView setFrame:CGRectMake(0, 60, bw, h)];
//    [self.scrollView setContentSize:CGSizeMake(bw, index*itemH + (index+1)*20)];
    [self.scrollView setContentSize:CGSizeMake(bw, maxh)];
    
    [UIView animateWithDuration:0.25f animations:^{
        [self.backGroundView setFrame:CGRectMake(self.backGroundView.frame.origin.x, self->viewHeight - h - 60 - XBottomBarHeight - 20 ,self.backGroundView.frame.size.width, h + 60 + XBottomBarHeight + 20)];
    } completion:^(BOOL finished) {
//
    }];
//    self.backGroundView.hidden = YES;
    
}

#pragma mark - 机器人切换弹窗样式 获取最终高度
-(CGFloat)getItemMaxHWith:(ZCLibRobotSet *)model withW:(CGFloat)w{
    UILabel *itemName = [[UILabel alloc] initWithFrame:CGRectZero];
    [itemName setFont:SobotFont14];
    [itemName setText:sobotConvertToString(model.operationRemark)];
    itemName.numberOfLines = 0;
    // 单个的高度
    [itemName setFrame:CGRectMake(8, 8, w-2*8, 36)];
    [itemName sizeToFit];
    CGRect NF = itemName.frame;
    if (NF.size.height >(36 -2*8)) {
        return NF.size.height + 2*8;
    }
    return 36;
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


-(UIButton *)addItemView:(ZCLibRobotSet *) model withX:(CGFloat )x withY:(CGFloat) y withW:(CGFloat) w withH:(CGFloat) h{
    UIButton *itemView = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w,h)];
    [itemView setFrame:CGRectMake(x, y, w, h)];
    
    [itemView setTitleColor:[ZCUIKitTools zcgetThemeToWhiteColor] forState:UIControlStateNormal];
    [itemView setTitleColor:[ZCUIKitTools zcgetTextNolColor] forState:UIControlStateHighlighted];
    [itemView setTitleColor:[ZCUIKitTools zcgetTextNolColor] forState:UIControlStateSelected];
    [itemView setBackgroundImage:[SobotImageTools sobotImageWithColor:UIColorFromKitModeColor(SobotColorBgSub)] forState:UIControlStateNormal];
    [itemView setBackgroundImage:[SobotImageTools sobotImageWithColor:[ZCUIKitTools zcgetServerConfigBtnBgColor]] forState:UIControlStateHighlighted];
    [itemView setBackgroundImage:[SobotImageTools sobotImageWithColor:[ZCUIKitTools zcgetServerConfigBtnBgColor]] forState:UIControlStateSelected];
    itemView.titleLabel.numberOfLines = 0;
    
    itemView.titleLabel.font = SobotFontBold14;
    itemView.titleLabel.textColor = UIColorFromKitModeColor(SobotColorTextMain);
//    itemView.layer.cornerRadius = h/2;
    itemView.layer.cornerRadius = 18;
    itemView.layer.masksToBounds = YES;
    
//    if ([model.operationRemark hasPrefix:@"是大方"]) {
//        model.operationRemark = @"数量肯定福利卡吉机啦科技大理发卡进啦说法科机啦科技大理发卡进啦说法科机啦科技大理发卡进啦说法科利丁粉开机啦科技大理发卡进啦说法科技拉胯动静分离卡萨丁理发";
//    }
    
    [itemView setTitle:sobotConvertToString(model.operationRemark) forState:UIControlStateNormal];
    [itemView setTitle:sobotConvertToString(model.operationRemark) forState:UIControlStateHighlighted];
    itemView.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    // 默认选中的颜色是主题色 或者 接口返回的颜色 ，选中的颜色是白色
    [itemView setTitleColor:[ZCUIKitTools zcgetServerConfigBtnBgColor] forState:UIControlStateNormal];
    [itemView setTitleColor:[ZCUIKitTools zcgetRobotBtnTitleColor] forState:UIControlStateHighlighted];
    [itemView setTitleColor:[ZCUIKitTools zcgetRobotBtnTitleColor] forState:UIControlStateSelected];
    
    if ([sobotConvertToString(model.robotFlag) intValue] == _robotid) {
        itemView.selected = YES;
    }
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
    [UIView animateWithDuration:0.25f animations:^{
        [self.backGroundView setFrame:CGRectMake(_backGroundView.frame.origin.x,viewHeight ,self.backGroundView.frame.size.width,self.backGroundView.frame.size.height)];
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
    
    if (_robotSetClickBlock) {
        _robotSetClickBlock(nil);
    }
    // 点击取消的时候设置键盘样式 关闭加载动画
    [_keyboardView setKeyboardMenuByStatus:ZCKeyboardStatusRobot];
}

-(void)itemClick:(UIButton *)sender{
    ZCLibRobotSet * model = listArray[sender.tag];
    if (_robotSetClickBlock) {
        _robotSetClickBlock(model);
    }
    [self tappedCancel];
}

@end
