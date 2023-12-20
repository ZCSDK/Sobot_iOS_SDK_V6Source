//
//  ZCChatCustomCardSingleCell.m
//  SobotKit
//
//  Created by zhangxy on 2023/6/13.
//

#import "ZCChatCustomCardSingleCell.h"
#import "ZCUICore.h"

@interface ZCChatCustomCardSingleCell()<UIGestureRecognizerDelegate>{
    NSString *morelink;
    
}

@property(nonatomic,strong) NSLayoutConstraint *layoutImageWidth;
@property(nonatomic,strong) NSLayoutConstraint *layoutImageLeft;
@property(nonatomic,strong) NSLayoutConstraint *layoutImageBottom;

@property(nonatomic,strong) NSLayoutConstraint *layoutSendBottom;
@property(nonatomic,strong) NSLayoutConstraint *layoutSendWidth;

@property(nonatomic,strong) NSLayoutConstraint *layoutBtnsBottom;

@property (strong, nonatomic) UIView *bgView; //
@property (strong, nonatomic) UIView *buttonsView; //

@property (nonatomic,strong) SobotImageView *logoView;
@property (strong, nonatomic) UILabel *labTitle; //标题
@property (strong, nonatomic) UILabel *labDesc; //标题
@property (strong, nonatomic) UILabel *labTag; //标题
@property (strong, nonatomic) SobotButton *btnSend;
@property (strong, nonatomic) UIButton *tapBtn;
@property (copy,nonatomic)NSString *linkUrl;
@property (strong ,nonatomic) UILabel *priceTip;// 商品价格标签
@property (strong,nonatomic) SobotChatMessage *msg;
@end

@implementation ZCChatCustomCardSingleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self createViews];
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self createViews];
        //设置点击事件
        [self.contentView addConstraint:sobotLayoutPaddingTop(ZCChatPaddingVSpace, self.bgView, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingVSpace, self.bgView, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-ZCChatPaddingVSpace, self.bgView, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(-ZCChatMarginVSpace, self.bgView, self.contentView)];
        
        
        [self.bgView addConstraint:sobotLayoutPaddingLeft(0, self.tapBtn, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.tapBtn, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingBottom(0, self.tapBtn, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingTop(0, self.tapBtn, self.bgView)];
        
        [self.bgView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingVSpace, self.buttonsView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatPaddingVSpace, self.buttonsView, self.bgView)];
        _layoutBtnsBottom = sobotLayoutPaddingBottom(-ZCChatPaddingVSpace, self.buttonsView, self.bgView);
        [self.bgView addConstraint:_layoutBtnsBottom];
        
        
        _layoutImageBottom = sobotLayoutMarginBottom(-ZCChatPaddingVSpace, self.logoView, self.buttonsView);
        _layoutImageBottom.priority = UILayoutPriorityDefaultHigh;
        _layoutImageWidth = sobotLayoutEqualWidth(76, self.logoView, NSLayoutRelationEqual);
        _layoutImageLeft = sobotLayoutPaddingLeft(ZCChatPaddingVSpace, self.logoView, self.bgView);
        [self.bgView addConstraint:_layoutImageWidth];
        [self.bgView addConstraint:sobotLayoutEqualHeight(76, self.logoView, NSLayoutRelationEqual)];
        [self.bgView addConstraint:_layoutImageLeft];
        [self.bgView addConstraint:_layoutImageBottom];
        [self.bgView addConstraint:sobotLayoutPaddingTop(ZCChatPaddingVSpace, self.logoView, self.bgView)];
        
        [self.bgView addConstraint: sobotLayoutPaddingTop(ZCChatPaddingVSpace, self.labTitle, self.bgView)];
        [self.bgView addConstraint:sobotLayoutMarginLeft(ZCChatMarginVSpace, self.labTitle, self.logoView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-12, self.labTitle, self.bgView)];
        
        [self.bgView addConstraint: sobotLayoutMarginTop(ZCChatCellItemSpace-1, self.labDesc, self.labTitle)];
        [self.bgView addConstraint:sobotLayoutMarginLeft(ZCChatMarginVSpace, self.labDesc, self.logoView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-12, self.labDesc, self.bgView)];
        
        
        _layoutSendBottom = sobotLayoutMarginBottom(-ZCChatPaddingVSpace, self.btnSend, self.buttonsView);
        _layoutSendBottom.priority = UILayoutPriorityDefaultLow;
        _layoutSendWidth = sobotLayoutEqualWidth(80, self.btnSend, NSLayoutRelationEqual);
        [self.bgView addConstraint:_layoutSendWidth];
         [self.bgView addConstraint:sobotLayoutEqualHeight(32, self.btnSend, NSLayoutRelationEqual)];
        [self.bgView addConstraint:_layoutSendBottom];
        [self.bgView addConstraint:sobotLayoutMarginTop(ZCChatPaddingVSpace, self.btnSend, self.labDesc)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatPaddingHSpace, self.btnSend, self.bgView)];
        
        [self.bgView addConstraint:sobotLayoutMarginTop(ZCChatCellItemSpace+2, self.priceTip, self.labDesc)];
        [self.bgView addConstraint:sobotLayoutEqualHeight(30, self.priceTip, NSLayoutRelationEqual)];
        [self.bgView addConstraint:sobotLayoutMarginLeft(ZCChatMarginVSpace, self.priceTip, self.logoView)];
//        [self.bgView addConstraint:sobotLayoutMarginRight(-2, self.priceTip, self.labTag)];
        [self.bgView addConstraint:sobotLayoutEqualWidth(13, self.priceTip, NSLayoutRelationEqual)];
        
        [self.bgView addConstraint: sobotLayoutMarginTop(ZCChatCellItemSpace, self.labTag, self.labDesc)];
        [self.bgView addConstraint:sobotLayoutEqualHeight(30, self.labTag, NSLayoutRelationEqual)];
        [self.bgView addConstraint:sobotLayoutMarginLeft(0, self.labTag, self.priceTip)];
        [self.bgView addConstraint:sobotLayoutMarginRight(-12, self.labTag, self.btnSend)];

        
    }
    return self;
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//    if ([touch.view isKindOfClass:[UIButton class]]  || [touch.view isKindOfClass:[UITableView class]]  ||[NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
//        //判断如果点击的是tableView的cell，就把手势给关闭了
//        return NO;//关闭手势
//    }
//    //否则手势存在
//    return YES;
//}


-(void)tapAction{
    if (sobotConvertToString(self.linkUrl).length > 0) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
            [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeOpenURL text:sobotConvertToString(self.linkUrl)  obj:sobotConvertToString(self.linkUrl)];
        }
    }
}


-(void)createViews{
    _bgView = ({
        UIView *iv = [[UIView alloc] init];
        iv.layer.masksToBounds = NO;
        iv.layer.borderWidth = 1.0f;
        iv.layer.shadowColor = [ZCUIKitTools zcgetChatBottomLineColor].CGColor;
        iv.layer.shadowOpacity = 0.9;
        iv.layer.shadowRadius = 8;
        iv.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        [iv setBackgroundColor:[ZCUIKitTools zcgetChatBackgroundColor]];
        iv.layer.cornerRadius = 8.0f;
        iv.layer.borderColor = [ZCUIKitTools zcgetLeftChatColor].CGColor;
        [self.contentView addSubview:iv];
//        iv.backgroundColor = UIColor.blueColor;
        iv;
    });
    
    
    _logoView = ({
        SobotImageView *iv = [[SobotImageView alloc] init];
        iv.layer.masksToBounds = YES;
        iv.contentMode = UIViewContentModeScaleAspectFill;
        //设置点击事件
        iv.userInteractionEnabled=YES;
        iv.layer.cornerRadius = 4.0f;
        iv.layer.masksToBounds = YES;
        [self.bgView addSubview:iv];
        iv;
    });
    
    _labTitle = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        iv.numberOfLines = 1;
//        [iv setFont:SobotFontBold14];
        [iv setFont:[ZCUIKitTools  zcgetTitleGoodsFont]];
        [self.bgView addSubview:iv];
        iv;
    });
    
    
    _labDesc = ({
        UILabel *iv = [[UILabel alloc] init];
        iv.numberOfLines = 2;
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:UIColorFromKitModeColor(SobotColorTextSub1)];
        [iv setFont:SobotFont12];
        [self.bgView addSubview:iv];
        iv;
    });
    
    _tapBtn = ({
        UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
        [iv setBackgroundColor:UIColor.clearColor];
        [iv setTitle:@"" forState:UIControlStateNormal];
        [self.bgView addSubview:iv];
        [iv addTarget:self action:@selector(tapAction) forControlEvents:UIControlEventTouchUpInside];
        iv;
    });
    
    _btnSend = ({
        SobotButton *iv = [SobotButton buttonWithType:UIButtonTypeCustom];
//        [iv setBackgroundColor:[ZCUIKitTools zcgetBgBannerColor]];
        iv.layer.borderWidth = 0;
        iv.backgroundColor = [ZCUIKitTools zcgetGoodSendBtnColor];
        [iv setTitleColor:[ZCUIKitTools zcgetGoodsSendColor] forState:0];
        [iv.titleLabel setFont:SobotFont14];
        iv.layer.cornerRadius = 16;
        iv.layer.masksToBounds = YES;
        [iv setTitle:SobotKitLocalString(@"发送") forState:0];
        iv.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        iv.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
        [iv addTarget:self action:@selector(sendButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgView addSubview:iv];
        iv;
    });
    
    _labTag = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:[ZCUIKitTools zcgetPricetTagTextColor]];
        iv.numberOfLines = 1;
        [iv setFont:SobotFontBold16];
        [self.bgView addSubview:iv];
        iv;
    });

    _priceTip = ({
        UILabel *iv = [[UILabel alloc]init];
        [iv setTextAlignment:NSTextAlignmentRight];
        [iv setTextColor:[ZCUIKitTools zcgetPricetTagTextColor]];
        iv.numberOfLines = 1;
        [iv setFont:SobotFont12];
        [self.bgView addSubview:iv];
        iv;
    });
    
    _buttonsView = ({
        UIView *iv = [[UIView alloc] init];
        [self.bgView addSubview:iv];
        iv;
    });

}

-(void)initDataToView:(SobotChatMessage *)message time:(NSString *)showTime{
    [super initDataToView:message time:showTime];
    self.ivHeader.image = nil;
    self.lblNickName.text = @"";
    self.msg = message;
    SobotChatCustomCardInfo *info = [self.cardModel.customCards firstObject];
    _labTitle.text = sobotConvertToString(info.customCardName);
    _labDesc.text = sobotConvertToString(info.customCardDesc);
    _labTag.text = sobotConvertToString(info.customCardAmount);
    _priceTip.text = sobotConvertToString(info.customCardAmountSymbol);
    _linkUrl = sobotConvertToString(info.customCardLink);
    if(sobotConvertToString(info.customCardThumbnail).length > 0){
        _layoutImageLeft.constant = ZCChatPaddingVSpace;
        _layoutImageWidth.constant = 76;
        _layoutImageWidth.constant = 76;
        [_logoView loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(info.customCardThumbnail)] placeholer:SobotKitGetImage(@"zcicon_default_goods_1")  showActivityIndicatorView:YES];
        _layoutImageBottom.priority = UILayoutPriorityDefaultHigh;
        _layoutSendBottom.priority = UILayoutPriorityDefaultLow;
    }else{
        _logoView.hidden = YES;
        _layoutImageLeft.constant = ZCChatPaddingVSpace - ZCChatCellItemSpace;
        _layoutImageWidth.constant = 0;
        _layoutImageWidth.constant = 0;
        _layoutImageBottom.priority = UILayoutPriorityDefaultLow;
        _layoutSendBottom.priority = UILayoutPriorityDefaultHigh;
    }
    [self createItemCusButton];
    

    [self.bgView layoutIfNeeded];
    [self setChatViewBgState:CGSizeMake(self.maxWidth,CGRectGetMaxY(_btnSend.frame))];
    
    self.ivBgView.backgroundColor = UIColor.clearColor;
}



-(void)createItemCusButton{
    [self.buttonsView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    SobotChatCustomCardInfo *info = [self.cardModel.customCards firstObject];
    
    if(info.customMenus.count <= 1){
        _layoutBtnsBottom.constant = 0;
        _layoutSendWidth.constant = 80;
        _btnSend.hidden = NO;
    }else{
        _btnSend.hidden = YES;
        _layoutSendWidth.constant = 0;
        _layoutBtnsBottom.constant = -ZCChatPaddingVSpace;
        // 计算、横竖显示
        CGFloat maxItemWidth = (self.viewWidth - ZCChatMarginHSpace * 2 - ZCChatMarginVSpace * 2)/ info.customMenus.count;
        BOOL isHorzontical = YES;
        for(int i=0;i<info.customMenus.count ; i ++ ){
            SobotChatCustomCardMenu *menu = info.customMenus[i];
            CGFloat iw = [SobotUITools getWidthContain:sobotConvertToString(menu.menuName) font:SobotFont14 Height:21];
            if(iw > maxItemWidth){
                isHorzontical = NO;
                break;
            }
        }
        SobotButton *preButton = nil;
        int currentCount = 0;
        for(int i=0;i<info.customMenus.count ; i ++ ){
            SobotChatCustomCardMenu *menu = info.customMenus[i];
            if(menu.menuType == 0 && menu.menuLinkType == 1){
                // 是跳转链接 并且是客服跳转类型，SDK不展示
                continue;
            }
            currentCount ++;
            SobotButton *btn = (SobotButton *)[SobotUITools createZCButton];
            [btn setTitle:sobotConvertToString(menu.menuName) forState:0];
            btn.obj = menu;
            btn.tag = i;
            btn.enabled = YES;
            [btn setBackgroundColor:UIColor.clearColor];
            btn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            btn.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
            [btn addTarget:self action:@selector(menuButton:) forControlEvents:UIControlEventTouchUpInside];
            // 发送
            if(currentCount == 1){
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
            [self.buttonsView addSubview:btn];
            
            if(menu.menuType == 1 && (menu.isUnEnabled || self.tempModel.isHistory)){
                // 确认按钮 历史记录和点击一次变成置灰不可点
                btn.enabled = NO;
                [btn setTitleColor:[ZCUIKitTools zcgetTextPlaceHolderColor] forState:UIControlStateNormal];
            }
            if(menu.menuType == 2 && self.tempModel.isHistory){
                btn.enabled = NO;
                [btn setTitleColor:[ZCUIKitTools zcgetTextPlaceHolderColor] forState:UIControlStateNormal];
            }
            if(currentCount == 1 && menu.menuType != 0 && self.tempModel.isHistory){
                btn.enabled = NO;
                [btn setTitleColor:[ZCUIKitTools zcgetGoodsSendColor] forState:0];
                [btn setBackgroundColor:UIColorFromModeColorAlpha(SobotColorTheme, 0.3)];
            }
            
            if(isHorzontical){
                [self.buttonsView addConstraint:sobotLayoutPaddingTop(ZCChatMarginVSpace, btn, self.buttonsView)];
                [self.buttonsView addConstraint:sobotLayoutEqualHeight(32, btn, NSLayoutRelationEqual)];
                if(sobotIsNull(preButton)){
                    [self.buttonsView addConstraint:sobotLayoutPaddingLeft(0, btn, self.buttonsView)];
                    [self.buttonsView addConstraint:sobotLayoutPaddingBottom(0, btn, self.buttonsView)];
                }else{
                    [self.buttonsView addConstraint:sobotLayoutMarginLeft(11, btn, preButton)];
                    [self.buttonsView addConstraint:sobotLayoutPaddingBottom(0, btn, self.buttonsView)];
                }
            }else{
                [self.buttonsView addConstraint:sobotLayoutEqualHeight(32, btn, NSLayoutRelationEqual)];
                if(sobotIsNull(preButton)){
                    [self.buttonsView addConstraint:sobotLayoutPaddingTop(0, btn, self.buttonsView)];
                    [self.buttonsView addConstraint:sobotLayoutPaddingLeft(0, btn, self.buttonsView)];
                    [self.buttonsView addConstraint:sobotLayoutPaddingRight(0, btn, self.buttonsView)];
                }
                else{
                    [self.buttonsView addConstraint:sobotLayoutMarginTop(10, btn, preButton)];
                    [self.buttonsView addConstraint:sobotLayoutPaddingLeft(0, btn, self.buttonsView)];
                    [self.buttonsView addConstraint:sobotLayoutPaddingRight(0, btn, self.buttonsView)];
                }
            }
            preButton = btn;
        }
        if(isHorzontical){
            if(!sobotIsNull(preButton)){
                [self.buttonsView addConstraint:sobotLayoutPaddingRight(0, preButton, self.buttonsView)];
            }
            [self.buttonsView addConstraints:sobotLayoutEqualWidthSubView(10, self.buttonsView.subviews.firstObject, self.buttonsView.subviews)];
        }else{
            if(!sobotIsNull(preButton)){
                [self.buttonsView addConstraint:sobotLayoutPaddingBottom(0, preButton, self.buttonsView)];
            }
        }
    }
}

-(void)menuButton:(SobotButton *)btn{
//    SobotChatCustomCardInfo *info = [self.cardModel.customCards firstObject];
    btn.tag = 0;
    SobotChatCustomCardMenu *menu = (SobotChatCustomCardMenu*)btn.obj;
    if(menu.menuType == 1){
        btn.enabled = NO;
        menu.isUnEnabled = YES;
    }
    [super menuButton:btn];
}



-(void)sendButtonClick:(SobotButton *) btn{
    [self menuButton:btn];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
