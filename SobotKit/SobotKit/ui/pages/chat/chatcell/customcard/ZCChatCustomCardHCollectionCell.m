//
//  ZCChatCustomCardCollectionCell.m
//  SobotKit
//
//  Created by zhangxy on 2023/6/8.
//

#import "ZCChatCustomCardHCollectionCell.h"
#import "ZCChatBaseCell.h"

@interface ZCChatCustomCardHCollectionCell()

@property (strong, nonatomic) NSLayoutConstraint *layoutBtnWidth;
@property (strong, nonatomic) NSLayoutConstraint *layoutBtnTop;
@property (strong, nonatomic) UIView *btnViews;

@end

@implementation ZCChatCustomCardHCollectionCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addConstraints:sobotLayoutPaddingWithAll(0, 0, 0, 0, self.bgView, self.contentView)];

        self.bgView.layer.backgroundColor = [ZCUIKitTools zcgetChatBackgroundColor].CGColor;
        self.bgView.layer.cornerRadius = 8;
        self.bgView.layer.shadowColor = [ZCUIKitTools zcgetChatBottomLineColor].CGColor;
        self.bgView.layer.shadowOffset = CGSizeMake(0,1);
        self.bgView.layer.shadowOpacity = 1;
        self.bgView.layer.shadowRadius = 8;
        self.posterView.layer.cornerRadius = 0;
        self.posterView.contentMode = UIViewContentModeScaleAspectFill;
        [self.bgView addConstraint:sobotLayoutEqualHeight(140, self.posterView, NSLayoutRelationEqual)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(0, self.posterView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.posterView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingTop(0, self.posterView, self.bgView)];
        
        [self.bgView addConstraint:sobotLayoutMarginTop(ZCChatPaddingVSpace, self.labTitle, self.posterView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-12, self.labTitle, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingVSpace, self.labTitle, self.bgView)];
        
        [self.bgView addConstraint:sobotLayoutMarginTop(ZCChatCellItemSpace-1, self.labDesc, self.labTitle)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingVSpace, self.labDesc, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-12, self.labDesc, self.bgView)];
        
        [self.bgView addConstraint:sobotLayoutEqualHeight(12, self.priceTip, NSLayoutRelationEqual)];
        [self.bgView addConstraint:sobotLayoutPaddingBottom(-1, self.priceTip, self.labTips)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingVSpace,self.priceTip,self.bgView)];
        
        [self.bgView addConstraint:sobotLayoutEqualHeight(17, self.labTips, NSLayoutRelationEqual)];
        [self.bgView addConstraint:sobotLayoutMarginTop(ZCChatPaddingVSpace, self.labTips, self.labDesc)];
        [self.bgView addConstraint:sobotLayoutMarginLeft(0, self.labTips, self.priceTip)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-12, self.labTips, self.bgView)];
        
        
        self.btnSend.hidden = YES;
        _layoutBtnTop = sobotLayoutMarginTop(16, self.btnViews, self.labTips);
        [self.bgView addConstraint:_layoutBtnTop];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingVSpace, self.btnViews, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatPaddingVSpace, self.btnViews, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingBottom(-ZCChatPaddingVSpace, self.btnViews,self.bgView)];
        
        
    }
    return self;
}

-(void)createViews{
    [super createViews];
    _btnViews = ({
        UIView *iv = [[UIView alloc] init];
        [iv setBackgroundColor:UIColor.clearColor];
        [self.bgView addSubview:iv];
        iv;
    });
    
}

-(void)prepareForReuse{
    [super prepareForReuse];
    self.posterView.image = nil;
}

-(void)configureCellWithData:(SobotChatCustomCardInfo *)model message:(SobotChatMessage *)message{
    [super configureCellWithData:model message:message];
    [self createItemCusButton];
    
    // 订单时显示
    if(message.richModel.customCard.cardType == 0){
        NSString *unitStr = SobotKitLocalString(@"件");
        NSString *goodsStr = SobotKitLocalString(@"商品");
        NSString *totalStr = SobotKitLocalString(@"合计");
        NSString *total = [NSString stringWithFormat:@"%@%@%@  %@ %@%@",model.customCardCount,unitStr,goodsStr,totalStr,model.customCardAmountSymbol,model.customCardAmount];
        [self.labTips setText:total];
        [self.labDesc setText:model.customCardDesc];
        self.labDesc.numberOfLines = 2;
        self.labDesc.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.labTips setTextColor:UIColorFromKitModeColor(SobotColorTextSub1)];
        [self.labDesc setTextColor:UIColorFromKitModeColor(SobotColorTextSub1)];
        [self.priceTip setText:@""];
        self.labTips.font = SobotFont14;
        self.priceTip.font = SobotFont12;
    }
    if(message.richModel.customCard.cardType == 1){
        self.labTips.font = SobotFontBold16;
        self.priceTip.font = SobotFont12;
        [self.labTips setText:sobotConvertToString(model.customCardAmount)];
        [self.priceTip setText:sobotConvertToString(model.customCardAmountSymbol)];
    }
    [self.labDesc setTextColor:UIColorFromModeColor(SobotColorTextSub1)];
    
    
    if(message.senderType!=0){
            NSArray<CALayer *> *subLayers = self.bgView.layer.sublayers;
            NSArray<CALayer *> *removedLayers = [subLayers filteredArrayUsingPredicate:
             
            [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                return [evaluatedObject isKindOfClass:[CAShapeLayer class]];
            }]];
            [removedLayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj removeFromSuperlayer];
             }];
        self.bgView.layer.masksToBounds = NO;
            self.bgView.layer.backgroundColor = [ZCUIKitTools zcgetChatBackgroundColor].CGColor;
            self.bgView.layer.cornerRadius = 8;
            self.bgView.layer.shadowColor = [ZCUIKitTools zcgetChatBottomLineColor].CGColor;
            self.bgView.layer.shadowOffset = CGSizeMake(0,1);
            self.bgView.layer.shadowOpacity = 1;
            self.bgView.layer.shadowRadius = 4;
        
        _layoutBtnTop.constant = 16;
        }else{
            _layoutBtnTop.constant = 0;
            NSArray<CALayer *> *subLayers = self.bgView.layer.sublayers;
            NSArray<CALayer *> *removedLayers = [subLayers filteredArrayUsingPredicate:
             
            [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                return [evaluatedObject isKindOfClass:[CAShapeLayer class]];
            }]];
            [removedLayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj removeFromSuperlayer];
             }];

            self.bgView.layer.cornerRadius = 8;
            self.bgView.layer.borderColor = [ZCUIKitTools zcgetChatBottomLineColor].CGColor;
            self.bgView.layer.borderWidth = 1.0f;
            self.bgView.layer.masksToBounds = YES;
        }
    
    dispatch_async(dispatch_get_main_queue(), ^{
           UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.posterView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(8,8)];
           //创建 layer
           CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
           maskLayer.frame = self.posterView.bounds;
           //赋值
           maskLayer.path = maskPath.CGPath;
           self.posterView.layer.mask = maskLayer;
       });
    
}

-(void)menuButton:(SobotButton *) btn{
    SobotChatCustomCardMenu *menu = (SobotChatCustomCardMenu*)btn.obj;
    if(menu.menuType == 1){
        btn.enabled = NO;
        menu.isUnEnabled = YES;
    }
    [super menuButtonClick:btn];
}



-(void)createItemCusButton{
    [_btnViews.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    int currentMenuCounts = 0;
    // 发送出去的不添加按钮
    if(self.cardModel.customMenus.count > 0 && self.message.senderType!=0){
        SobotButton *preButton = nil;
        for(int i=0;i<self.cardModel.customMenus.count ; i ++ ){
            SobotChatCustomCardMenu *menu = self.cardModel.customMenus[i];
            if(menu.menuType == 0 && menu.menuLinkType == 1){
                // 是跳转链接 并且是客服跳转类型，SDK不展示
                continue;
            }
            currentMenuCounts ++;
            SobotButton *btn = (SobotButton *)[SobotUITools createZCButton];
            [btn setTitle:sobotConvertToString(menu.menuName) forState:0];
            btn.titleEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 16);
            btn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            btn.obj = menu;
            btn.tag = i;
            btn.enabled = YES;
            [btn setBackgroundColor:UIColor.clearColor];
            [btn addTarget:self action:@selector(menuButton:) forControlEvents:UIControlEventTouchUpInside];
            // 发送
            if(currentMenuCounts == 1){
                btn.layer.borderWidth = 0;
                btn.backgroundColor = [ZCUIKitTools zcgetGoodSendBtnColor];
                [btn setTitleColor:[ZCUIKitTools zcgetGoodsSendColor] forState:0];
            }else{
                btn.layer.borderColor = [ZCUIKitTools zcgetCommentButtonLineColor].CGColor;
                [btn setTitleColor:[ZCUIKitTools zcgetChatTextViewColor] forState:0];
                btn.layer.borderWidth = .75f;
            }
            btn.layer.cornerRadius = 16.0f;
            [btn.titleLabel setFont:SobotFont14];
            [btn addTarget:self action:@selector(menuButton:) forControlEvents:UIControlEventTouchUpInside];
            [_btnViews addSubview:btn];
            
            if(menu.menuType == 1 && (menu.isUnEnabled || self.message.isHistory)){
                // 确认按钮 历史记录和点击一次变成置灰不可点
                btn.enabled = NO;
                [btn setTitleColor:[ZCUIKitTools zcgetTextPlaceHolderColor] forState:UIControlStateNormal];
            }
            if(menu.menuType == 2 && self.message.isHistory){
                btn.enabled = NO;
                [btn setTitleColor:[ZCUIKitTools zcgetTextPlaceHolderColor] forState:UIControlStateNormal];
            }
            if(currentMenuCounts == 1 && menu.menuType != 0 && self.message.isHistory){
                btn.enabled = NO;
                [btn setTitleColor:[ZCUIKitTools zcgetGoodsSendColor] forState:0];
                [btn setBackgroundColor:UIColorFromModeColorAlpha(SobotColorTheme, 0.3)];
            }
            
            [_btnViews addConstraint:sobotLayoutEqualHeight(32, btn, NSLayoutRelationEqual)];
            if(preButton ==nil){
                [_btnViews addConstraint:sobotLayoutPaddingTop(0, btn, _btnViews)];
                [_btnViews addConstraint:sobotLayoutPaddingLeft(0, btn, _btnViews)];
                [_btnViews addConstraint:sobotLayoutPaddingRight(0, btn, _btnViews)];
            }
            else{
                [_btnViews addConstraint:sobotLayoutMarginTop(10, btn, preButton)];
                [_btnViews addConstraint:sobotLayoutPaddingLeft(0, btn, _btnViews)];
                [_btnViews addConstraint:sobotLayoutPaddingRight(0, btn, _btnViews)];
            }
            preButton = btn;
        }
       
        // 这里需要知道两个条件，一个是最外层 最大的个数据 ，另个是当前按钮的个数 0 1 2 3 并设置底部的约束值
        if(currentMenuCounts != self.maxCustomMenus){
            if(preButton != nil){
                [_btnViews addConstraint:sobotLayoutPaddingBottom(-42*(self.maxCustomMenus-currentMenuCounts), preButton, _btnViews)];
            }
        }else{
            if(preButton != nil){
                [_btnViews addConstraint:sobotLayoutPaddingBottom(0, preButton, _btnViews)];
            }
        }
        
    }
}


@end
