//
//  ZCChatTextCell.m
//  SobotKit
//
//  Created by zhangxy on 2022/9/15.
//

#import "ZCChatTextCell.h"
#import "ZCChatReferenceCell.h"

@interface ZCChatTextCell()<ZCChatReferenceCellDelegate>{
    NSLayoutConstraint *layoutWidth;
    NSLayoutConstraint *layoutBgWidth;
    UIView *_lastView;
}

@property(nonatomic,strong) UIView *refrenceView;
@property(nonatomic,strong) SobotEmojiLabel *lblMessage;
@property(nonatomic,strong) UIView *linkBgView;
@property(nonatomic,strong) NSLayoutConstraint *linkBgViewEH;
@property(nonatomic,strong) NSLayoutConstraint *layoutHeight;

@property(nonatomic,strong) NSLayoutConstraint *layoutReferenceW;
@property(nonatomic,strong) NSLayoutConstraint *layoutMessageTop;

@end

@implementation ZCChatTextCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self createItemViews];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self createItemViews];
    }
    return self;
}

-(void)createItemViews{
    _refrenceView = [[UIView alloc] init];
    [self.contentView addSubview:_refrenceView];
    // 不设置优先级，会有警告
//    NSLayoutConstraint *layoutRR = sobotLayoutPaddingRight(-ZCChatPaddingHSpace, _refrenceView, self.ivBgView);
//    layoutRR.priority = UILayoutPriorityDefaultLow;
    
    _layoutReferenceW = sobotLayoutEqualWidth(240, self.refrenceView, NSLayoutRelationEqual);
    _layoutReferenceW.priority = UILayoutPriorityDefaultHigh;
    [self.contentView addConstraint:_layoutReferenceW];
    [self.contentView addConstraints:sobotLayoutPaddingView(ZCChatPaddingVSpace, 0, ZCChatPaddingHSpace, 0, _refrenceView, self.ivBgView)];
    
    _lblMessage = [ZCChatBaseCell createRichLabel:self];
//    _lblMessage.delegate = self;
    [self.contentView addSubview:_lblMessage];
    layoutWidth = sobotLayoutEqualWidth(0, _lblMessage, NSLayoutRelationEqual);
    _layoutHeight = sobotLayoutEqualHeight(0, _lblMessage, NSLayoutRelationEqual);
    [self.contentView addConstraint:layoutWidth];
    [self.contentView addConstraint:_layoutHeight];
    [self.contentView addConstraint:sobotLayoutMarginBottom(-ZCChatCellItemSpace, _lblMessage, self.lblSugguest)];
    // 修改原有代码，顶部约束添加到refrenceView上
//    [self.contentView addConstraints:sobotLayoutPaddingView(ZCChatPaddingVSpace, 0, ZCChatPaddingHSpace, 0, _lblMessage, self.ivBgView)];
    [self.contentView addConstraints:sobotLayoutPaddingView(0, 0, ZCChatPaddingHSpace, 0, _lblMessage, self.ivBgView)];
    _layoutMessageTop = sobotLayoutMarginTop(0, _lblMessage, self.refrenceView);
    [self.contentView addConstraint:_layoutMessageTop];
    
    _linkBgView = [[UIView alloc]init];
    _linkBgView.layer.cornerRadius = 4;
    _linkBgView.layer.masksToBounds = YES;
    _linkBgView.backgroundColor = UIColorFromModeColor(SobotColorBgMainDark3);
    [self.contentView addSubview:_linkBgView];
    // 覆盖上面的明文链接
    [self.contentView addConstraint:sobotLayoutPaddingTop(0, _linkBgView, _lblMessage)];
    layoutBgWidth = sobotLayoutEqualWidth(240, _linkBgView, NSLayoutRelationEqual);
    [self.contentView addConstraint:layoutBgWidth];
    self.linkBgViewEH = sobotLayoutEqualHeight(78, _linkBgView, NSLayoutRelationEqual);
    [self.contentView addConstraint:self.linkBgViewEH];
    [self.contentView addConstraint:sobotLayoutPaddingLeft(0,_linkBgView, _lblMessage)];
    _linkBgView.hidden = YES;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(doLongPress:)];
    self.lblMessage.userInteractionEnabled = YES;
    [self.lblMessage addGestureRecognizer:longPress];
    
    self.linkBgView.userInteractionEnabled = YES;
    [self.linkBgView addGestureRecognizer:longPress];

}


-(void)initDataToView:(SobotChatMessage *) message time:(NSString *) showTime{
    [super initDataToView:message time:showTime];
    _lblMessage.text = @"";
    
#pragma mark 标题+内容
    NSString *text = @"";
    _linkBgViewEH.constant = 0;
    self->_layoutHeight.constant = 0;
    if(self.isRight){
        text = sobotConvertToString([message getModelDisplayText]);
    }else{
        text = sobotConvertToString([message getModelDisplayText:YES]);
    }
    
    // 3.0.9兼容旧版本机器人语音显示空白问题
    if(sobotConvertToString(text).length == 0 && sobotConvertToString(message.richModel.msgtranslation).length > 0){
        text = sobotConvertToString(message.richModel.msgtranslation);
    }
    
    
    CGSize s = CGSizeZero;
    CGFloat maxContentWidth = self.maxWidth;
    if(text.length > 0){
        if([self isRight]){
            [_lblMessage setTextColor:[ZCUIKitTools zcgetRightChatTextColor]];
            [_lblMessage setLinkColor:[ZCUIKitTools zcgetChatRightlinkColor]];
        }else{
            [_lblMessage setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
            [_lblMessage setLinkColor:[ZCUIKitTools zcgetChatLeftLinkColor]];
        }
        
        // 4.0.4版本去掉使用displayMsgAttr，直接使用setText，否则url，手机号不能根据正则识别
        if(!sobotIsNull(message.displayMsgAttr) && [text containsString:@"<"] && !self.isRight){
            [self setDisplayAttributedString:message.displayMsgAttr label:_lblMessage guide:NO];
        }else{
            // 最后一行过滤所有换行，不是最后一行过滤一个换行
            [_lblMessage setText:text];
        }
        s = [_lblMessage preferredSizeWithMaxWidth:maxContentWidth];
    }
    layoutWidth.constant = s.width;
    _layoutHeight.constant = s.height;
    
    CGFloat w = [self addText:text maxWidth:maxContentWidth];
    if(s.width < w){
        s.width = w;
    }
    _layoutMessageTop.constant = 0;
    // 开通了消息引用功能，并且有引用消息，显示
    if([[ZCUICore getUICore] getLibConfig].msgAppointFlag == 1 && self.tempModel.appointMessage!=nil && [self.tempModel.appointMessage isKindOfClass:[SobotChatMessage class]]){
        [self.refrenceView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        _layoutMessageTop.constant = 10;
        // 添加引用消息
        ZCChatReferenceCell *rview = [ZCChatReferenceCell createViewUseFactory:self.tempModel.appointMessage mainModel:self.tempModel maxWidth:self.maxWidth];
        rview.maxWidth = self.maxWidth;
        rview.delegate = self;
        // 未实现消息不展示
        if(!sobotIsNull(rview)){
            // 有引用消息时，显示最大宽度
//            s.width = maxContentWidth;
            CGFloat tempWidth = [rview getContenMaxWidth];
            if(tempWidth >s.width){
                s.width = tempWidth;
            }
            if(s.width > maxContentWidth){
                s.width = maxContentWidth;
            }
            
            _layoutReferenceW.constant = s.width;
            [self.refrenceView addSubview:rview];
//            [self.refrenceView addConstraints:sobotLayoutPaddingWithAll(0, 0, 0, 0, rview, self.refrenceView)];
            [self.refrenceView addConstraint:sobotLayoutPaddingTop(0, rview, self.refrenceView)];
            [self.refrenceView addConstraint:sobotLayoutPaddingLeft(0, rview, self.refrenceView)];
//            [self.refrenceView addConstraint:sobotLayoutPaddingRight(0, rview, self.refrenceView)];
            [self.refrenceView addConstraint:sobotLayoutEqualWidth(s.width, rview, NSLayoutRelationEqual)];
            [self.refrenceView addConstraint:sobotLayoutPaddingBottom(0, rview, self.refrenceView)];
            [self.refrenceView layoutIfNeeded];
        }
    }else{
        [self.refrenceView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    if(message.includeSensitive > 0 && message.senderType == 0){
        s = [self getAuthSensitiveView:message width:self.maxWidth with:_linkBgView];
        //        [_linkBgView addConstraint:sobotLayoutPaddingBottom(-ZCChatCellItemSpace, _lastView, _linkBgView)];
        _layoutHeight.constant = s.height;
    }
    
    [self setChatViewBgState:CGSizeMake(s.width, s.height)];
}

#pragma mark -- 引用cell的代理事件
-(void)onReferenceCellEvent:(SobotChatMessage * _Nullable) model type:(ZCChatReferenceCellEvent) type state:(int) state obj:(id _Nullable) obj{
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
        
        int index = 0;
        // 点击事件键盘都回收
        if(type == ZCChatReferenceCellEventCloseKeyboard){
            index = ZCChatCellClickTypeItemCloseKeyboard;
            [self.delegate cellItemClick:model type:index text:@"" obj:nil];
        }
        
        if(type == ZCChatReferenceCellEventOpenFileToDocment){
            index = ZCChatCellClickTypeOpenFile; // 打开文件
        }
        if(type == ZCChatReferenceCellEventPlayVoice){
            index = ZCChatCellClickTypePlayVoice;
        }
        if(type == ZCChatReferenceCellEventOpenLocation){
            index = ZCChatCellClickTypeItemOpenLocation;
        }
        if(type == ZCChatReferenceCellEventAppletAction){
            index = ZCChatCellClickTypeAppletAction;
        }
        if(type == ZCChatReferenceCellEventOpenURL){
            index = ZCChatCellClickTypeOpenURL;
        }
        [self.delegate cellItemClick:model type:index text:@"" obj:obj];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//- (void)SobotEmojiLabel:(SobotEmojiLabel*)emojiLabel didSelectLink:(NSString*)link withType:(SobotEmojiLabelLinkType)type{
//    [self doClickURL:link text:@""];
//}

-(CGFloat )addText:(NSString *)text maxWidth:(CGFloat ) cMaxWidth{
    _linkBgViewEH.constant = 0;
    _linkBgView.hidden = YES;
   
    if (sobotIsUrl(text, [ZCUIKitTools zcgetUrlRegular])) {
        _linkBgView.backgroundColor = UIColorFromModeColor(SobotColorBgMainDark3);
        _lblMessage.text = @"";
        layoutBgWidth.constant = cMaxWidth;
        _layoutHeight.constant = 78;
        _linkBgView.hidden = NO;
        [_linkBgView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        SobotButton *btn = [SobotButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundColor:[UIColor clearColor]];
        [self.linkBgView addSubview:btn];
        [btn addTarget:self action:@selector(urlTextClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.obj = text;
        [self.linkBgView addConstraints:sobotLayoutPaddingWithAll(0, 0, 0, 0, btn, self.linkBgView)];
        
        
        UILabel *linktitleLab = [[UILabel alloc]init];
        linktitleLab.font = SobotFontBold14;
        linktitleLab.text = SobotKitLocalString(@"解析中...");
        linktitleLab.textColor = UIColorFromModeColor(SobotColorTextMain);
        [self.linkBgView addSubview:linktitleLab];
        linktitleLab.numberOfLines = 1;
        [self.linkBgView addConstraint:sobotLayoutEqualHeight(20, linktitleLab, NSLayoutRelationEqual)];
        NSLayoutConstraint *rightTitle = sobotLayoutPaddingRight(-15, linktitleLab, self.linkBgView);
        [self.linkBgView addConstraint:rightTitle];
        [self.linkBgView addConstraint:sobotLayoutPaddingLeft(15, linktitleLab, self.linkBgView)];
        [self.linkBgView addConstraint:sobotLayoutPaddingTop(12, linktitleLab, self.linkBgView)];
        
        SobotImageView *icon = [[SobotImageView alloc]init];
        [icon loadWithURL:[NSURL URLWithString:@""] placeholer:SobotKitGetImage(@"zcicon_url_icon")];
        [self.linkBgView addSubview:icon];
        [self.linkBgView addConstraints:sobotLayoutSize(34,34, icon, NSLayoutRelationEqual)];
        [self.linkBgView addConstraint:sobotLayoutPaddingRight(-15, icon, self.linkBgView)];
        NSLayoutConstraint *iconTop = sobotLayoutMarginTop(ZCChatCellItemSpace, icon, linktitleLab);
        [self.linkBgView addConstraint:iconTop];
        NSLayoutConstraint *iocnMT = sobotLayoutMarginTop(1, icon, linktitleLab);
        iocnMT.priority = UILayoutPriorityDefaultHigh;
        [self.linkBgView addConstraint:iocnMT];// 处理约束警告
//        [self.linkBgView addConstraint:sobotLayoutPaddingBottom(-12, icon, self.linkBgView)];
        
        // 超链链接
        UILabel *linkdescLab = [[UILabel alloc]init];
        linkdescLab.font = SobotFont12;
        linkdescLab.textColor = UIColorFromModeColor(SobotColorTextSub);
        linkdescLab.numberOfLines = 2;
        [self.linkBgView addSubview:linkdescLab];
        [self.linkBgView addConstraint:sobotLayoutPaddingLeft(15, linkdescLab, self.linkBgView)];
        NSLayoutConstraint *descTop = sobotLayoutMarginTop(ZCChatCellItemSpace, linkdescLab, linktitleLab);
        [self.linkBgView addConstraint:descTop];
        [self.linkBgView addConstraint:sobotLayoutMarginRight(-ZCChatCellItemSpace, linkdescLab, icon)];

//        [self setLinkValues:text titleLabel:linktitleLab desc:linkdescLab imgView:icon];

        SobotWeakSelf(self);
        
        [self getLinkValues:text name:@"" result:^(NSString * _Nonnull title, NSString * _Nonnull desc, NSString * _Nonnull iconUrl) {
            SobotStrogSelf(self);
            if(title.length > 0){
               self.linkBgViewEH.constant = 78;
               self.layoutHeight.constant = 78;
                linktitleLab.text = sobotConvertToString(title);
                linkdescLab.text = sobotConvertToString(desc);

                [icon loadWithURL:[NSURL URLWithString:sobotConvertToString(iconUrl)] placeholer:SobotKitGetImage(@"zcicon_url_icon") showActivityIndicatorView:NO];
            }else{
                linktitleLab.text = sobotConvertToString(text);
                linkdescLab.hidden = YES;
                descTop.constant = 0;
                self->_linkBgViewEH.constant = 60;
                self->_layoutHeight.constant = 60;
                [self->_linkBgView removeConstraint:iconTop];
                [self->_linkBgView addConstraint:sobotLayoutPaddingTop(0, icon, linktitleLab)];
                
                [self->_linkBgView removeConstraint:rightTitle];
                [self->_linkBgView addConstraint:sobotLayoutMarginRight(-15, linktitleLab, icon)];
                
                [icon loadWithURL:[NSURL URLWithString:sobotConvertToString(iconUrl)] placeholer:SobotKitGetImage(@"zcicon_url_icon") showActivityIndicatorView:NO];
                
            }
        }];
        return cMaxWidth;
    }
    return 0;
}

#pragma mark - 超链的点击
-(void)urlClick:(SobotButton *)sender{
    SobotChatRichContent *item = (SobotChatRichContent *)(sender.obj);
    [self doClickURL:sobotConvertToString(item.msg) text:@""];
}

-(void)urlTextClick:(SobotButton *)sender{
    NSString *url = (NSString *)(sender.obj);
    [self doClickURL:sobotConvertToString(url) text:@""];
}




/// 仅支持文本
/// @param message  当前消息体
/// @param maxWidth  最大宽度
/// @param superView  要添加的父类
-(CGSize ) getAuthSensitiveView:(SobotChatMessage *) message width:(CGFloat ) maxWidth with:(UIView *) superView{
    CGFloat h = 10;
    CGFloat lineSpace = [ZCUIKitTools zcgetChatLineSpacing];
    NSString *text = sobotConvertToString([message getModelDisplayText]);
    if(self.isRight){
        text = sobotConvertToString([message getModelDisplayTextUnHtml]);
    }
    
    _lblMessage.text = @"";
    layoutBgWidth.constant = maxWidth;
    _layoutHeight.constant = h;
    _linkBgView.hidden = NO;
    [_linkBgView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSString *warningTips = sobotConvertToString(message.sentisiveExplain);
    if(superView){
        CGFloat contentWidth = maxWidth - 20;
        _linkBgView.backgroundColor = UIColor.clearColor;
       
        
        UIImageView *ivBg = [[UIImageView alloc] init];
        ivBg.layer.cornerRadius = 2.0f;
        ivBg.layer.masksToBounds = YES;
        ivBg.backgroundColor = UIColorFromModeColor(SobotColorBgMainDark1);
//        ivBg.backgroundColor = UIColorFromModeColor(SobotColorBgSub2Dark1);
//        ivBg.backgroundColor = UIColor.greenColor;
        [superView addSubview:ivBg];
        
        SobotEmojiLabel *msgLabel = [ZCChatBaseCell createRichLabel];
//        msgLabel.backgroundColor = UIColor.yellowColor;
        msgLabel.textColor = UIColorFromModeColor(SobotColorTextSub);
        [superView addSubview:msgLabel];
        
//        if(!sobotIsNull(message.displayMsgAttr)){
//            [self setDisplayAttributedString:message.displayMsgAttr label:msgLabel model:message guide:NO];
//        }else{
//            // 最后一行过滤所有换行，不是最后一行过滤一个换行
            [msgLabel setText:text];
//        }
        CGSize s = [msgLabel preferredSizeWithMaxWidth:contentWidth];
        BOOL isShowExport = NO;
        if(s.height > 60 && !message.showAllMessage){
            isShowExport = YES;
            s.height = 60;
        }
        
        [superView addConstraints:sobotLayoutSize(s.width, s.height, msgLabel, NSLayoutRelationEqual)];
        [superView addConstraint:sobotLayoutPaddingTop(10, msgLabel, superView)];
        [superView addConstraint:sobotLayoutPaddingLeft(10, msgLabel, superView)];
        
        [superView addConstraints:sobotLayoutSize(maxWidth, s.height+20, ivBg, NSLayoutRelationEqual)];
        [superView addConstraint:sobotLayoutPaddingTop(0, ivBg, superView)];
        [superView addConstraint:sobotLayoutPaddingLeft(0, ivBg, superView)];
        
        CGFloat space = 20;
        h = h + s.height + space;
        // 显示展示更多
        if(isShowExport){
            UIImageView *tipBg = [[UIImageView alloc] init];
            [superView addSubview:tipBg];

            SobotEmojiLabel *tipLabel = [ZCChatBaseCell createRichLabel];
            [superView addSubview:tipLabel];

            [superView addConstraints:sobotLayoutSize(maxWidth, 56, tipLabel, NSLayoutRelationEqual)];
            [superView addConstraint:sobotLayoutPaddingBottom(0, tipLabel, ivBg)];
            [superView addConstraint:sobotLayoutPaddingLeft(0, tipLabel, superView)];


            tipLabel.textAlignment = NSTextAlignmentCenter;
            [tipLabel setLinkColor:UIColorFromModeColor(SobotColorTheme)];
            [tipLabel setText:SobotKitLocalString(@"展开消息")];
            [tipLabel addLinkToURL:[NSURL URLWithString:@"sobot://showallsensitive"] withRange:NSMakeRange(0, SobotKitLocalString(@"展开消息").length)];
//            [tipLabel preferredSizeWithMaxWidth:contentWidth];
            [self viewBeizerRect:tipLabel.bounds view:tipLabel corner:UIRectCornerBottomLeft|UIRectCornerBottomRight cornerRadii:CGSizeMake(2, 2)];

            [self viewBeizerRect:tipBg.bounds view:tipBg corner:UIRectCornerBottomLeft|UIRectCornerBottomRight cornerRadii:CGSizeMake(2, 2)];

            CAGradientLayer *gradientLayer = [CAGradientLayer layer];
            gradientLayer.frame = tipLabel.bounds;
            // 设置渐变颜色数组
             gradientLayer.colors = @[(__bridge id)UIColorFromModeColorAlpha(SobotColorBgSub,0.5).CGColor,(__bridge id)UIColorFromModeColorAlpha(SobotColorBgSub,0.75).CGColor,(__bridge id)UIColorFromModeColor(SobotColorBgSub).CGColor];
            // 渐变颜色的区间分布
             gradientLayer.locations = @[@0.25,@0.5,@1];
            // 起始位置
             gradientLayer.startPoint = CGPointMake(0, 0);
            // 结束位置
             gradientLayer.endPoint = CGPointMake(0, 1);
            [tipBg.layer addSublayer:gradientLayer];

            space = space + 26;
        }

        SobotEmojiLabel *tipWLabel = [ZCChatBaseCell createRichLabel];
        [tipWLabel setTextColor:UIColorFromModeColor(SobotColorTextMain)];
        [tipWLabel setText:warningTips];
        [superView addSubview:tipWLabel];
        CGSize s1 = [tipWLabel preferredSizeWithMaxWidth:maxWidth];


        [superView addConstraints:sobotLayoutSize(s1.width, s1.height, tipWLabel, NSLayoutRelationEqual)];
        [superView addConstraint:sobotLayoutMarginTop(lineSpace, tipWLabel, ivBg)];
        [superView addConstraint:sobotLayoutPaddingLeft(0, tipWLabel, superView)];
        
        h = h + s1.height + lineSpace;
        
        UIButton *btn2 = [self createAuthButton:SobotKitLocalString(@"继续发送") type:2];
        [superView addSubview:btn2];

        [superView addConstraints:sobotLayoutSize(90, 30, btn2, NSLayoutRelationEqual)];
        [superView addConstraint:sobotLayoutMarginTop(lineSpace, btn2, tipWLabel)];
        [superView addConstraint:sobotLayoutPaddingRight(0, btn2, superView)];
        // 按钮
        if(message.includeSensitive == 2){
            SobotEmojiLabel *tipLabel2 = [ZCChatBaseCell createRichLabel];
            [tipLabel2 setTextColor:UIColorFromModeColor(SobotColorRed)];
            [tipLabel2 setText:SobotKitLocalString(@"您已拒绝发送此消息")];
            tipLabel2.textAlignment = NSTextAlignmentLeft;
            CGSize s2 = [tipLabel2 preferredSizeWithMaxWidth:contentWidth];
            if(s2.width > (contentWidth - 120)){
                s2.width = contentWidth - 120;
            }
            [superView addSubview:tipLabel2];

           [superView addConstraints:sobotLayoutSize(s2.width, 30, tipLabel2, NSLayoutRelationEqual)];
           [superView addConstraint:sobotLayoutMarginTop(lineSpace, tipLabel2, tipWLabel)];
           [superView addConstraint:sobotLayoutPaddingLeft(0, tipLabel2, superView)];



        }else{
            UIButton *btn1 = [self createAuthButton:SobotKitLocalString(@"拒绝") type:1];
            btn1.frame = CGRectMake(contentWidth - 120 - 60, h, 60, 30);
            [superView addSubview:btn1];
            [superView addConstraints:sobotLayoutSize(60, 30, btn1, NSLayoutRelationEqual)];
            [superView addConstraint:sobotLayoutMarginTop(lineSpace, btn1, tipWLabel)];
            [superView addConstraint:sobotLayoutMarginRight(-20, btn1, btn2)];
        }


        h = h + 30 + lineSpace;
        self.linkBgViewEH.constant = h;
        _layoutHeight.constant = h;
        _lastView = tipWLabel;
    }
    return CGSizeMake(maxWidth, h - lineSpace);
}



/// 设置圆角
-(void)viewBeizerRect:(CGRect)rect view:(UIView *)view corner:(UIRectCorner)corner cornerRadii:(CGSize)radii{
    UIBezierPath *maskPath= [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corner cornerRadii:radii];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame =view.bounds;
    maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
}

-(UIButton *)createAuthButton:(NSString *)title type:(NSInteger )type{
    UIButton *_btnTurnUser =[UIButton buttonWithType:UIButtonTypeCustom];
    [_btnTurnUser setTitle:title forState:UIControlStateNormal];
    
    _btnTurnUser.layer.cornerRadius = 15.0f;
    _btnTurnUser.layer.borderWidth = 0.75f;
    _btnTurnUser.layer.masksToBounds = YES;
    [_btnTurnUser.titleLabel setFont:SobotFont14];
    _btnTurnUser.tag = type;
    if(type == 1){
        _btnTurnUser.tag = 1;
        [_btnTurnUser setBackgroundColor:UIColorFromModeColor(SobotColorBgMainDark2)];
        _btnTurnUser.layer.borderColor = UIColorFromModeColor(SobotColorBgLine).CGColor;
        [_btnTurnUser setTitleColor:UIColorFromModeColor(SobotColorTextMain) forState:UIControlStateNormal];
    }else{
        _btnTurnUser.tag = 2;
        [_btnTurnUser setBackgroundColor:UIColorFromModeColor(SobotColorTheme)];
        _btnTurnUser.layer.borderColor = UIColorFromModeColor(SobotColorTheme).CGColor;
        [_btnTurnUser setTitleColor:UIColorFromModeColor(SobotColorTextWhite) forState:UIControlStateNormal];
        
    }
    [_btnTurnUser addTarget:self action:@selector(authSensitive:) forControlEvents:UIControlEventTouchUpInside];
    return _btnTurnUser;
}

-(void)authSensitive:(UIButton *) button{
    if(button.tag == 1){
        // 拒绝
        if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
            [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeRefuseSend text:nil obj:nil];
        }
    }else{
        // 继续发送
        if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
            [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeAgreeSend text:nil obj:nil];
        }
    }
}


//-(void)setDisplayAttributedString:(NSMutableAttributedString *) attr label:(UILabel *) label model:(SobotChatMessage *)curModel guide:(BOOL)isGuide{
//    UIColor *textColor = [ZCUIKitTools zcgetLeftChatTextColor];
//    UIColor *linkColor = [ZCUIKitTools zcgetChatLeftLinkColor];
//    if([self isRight]){
//        textColor = [ZCUIKitTools zcgetRightChatTextColor];
//        linkColor = [ZCUIKitTools zcgetChatRightlinkColor];
//    }
//    CGFloat lineSpace = [ZCUIKitTools zcgetChatLineSpacing]; // 调整行间距
//    if (isGuide) {
//        lineSpace = [ZCUIKitTools zcgetChatGuideLineSpacing]; // 调整行间距
//    }
//    label.attributedText = [ZCUIKitTools parseStringArtribute:attr linespace:lineSpace font:label.font textColor:textColor linkColr:linkColor];
//}
-(void)setDisplayAttributedString:(NSMutableAttributedString *) attr label:(UILabel *) label guide:(BOOL)isGuide{
    UIColor *textColor = [ZCUIKitTools zcgetLeftChatTextColor];
    UIColor *linkColor = [ZCUIKitTools zcgetChatLeftLinkColor];
    if(self.isRight){
        textColor = [ZCUIKitTools zcgetRightChatTextColor];
        linkColor = [ZCUIKitTools zcgetChatRightlinkColor];
    }
    NSMutableAttributedString* attributedString = [attr mutableCopy];
     
    [attributedString beginEditing];
    [attributedString enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0,attributedString.length) options:0 usingBlock:^(id value,NSRange range,BOOL *stop) {
        UIFont *font = value;
        // 替换固定默认文字大小
        if(font.pointSize == 15){
//            NSLog(@"----替换了字体");
            [attributedString removeAttribute:NSFontAttributeName range:range];
            [attributedString addAttribute:NSFontAttributeName value:label.font range:range];
        }
    }];
    [attributedString enumerateAttribute:NSForegroundColorAttributeName inRange:NSMakeRange(0,attributedString.length) options:0 usingBlock:^(id value,NSRange range,BOOL *stop) {
        UIColor *color = value;
        NSString *hexColor = [ZCUIKitTools getHexStringByColor:color];
//                                NSLog(@"***\n%@",hexColor);
        // 替换固定整体文字颜色
        if([@"ff0001" isEqual:hexColor]){
            [attributedString removeAttribute:NSForegroundColorAttributeName range:range];
            [attributedString addAttribute:NSForegroundColorAttributeName value:textColor range:range];
        }
        // 替换固定连接颜色
        if([@"ff0002" isEqual:hexColor]){
            [attributedString removeAttribute:NSForegroundColorAttributeName range:range];
            [attributedString addAttribute:NSForegroundColorAttributeName value:linkColor range:range];
        }
    }];
    
    //Hack for italic/skew effect to custom fonts
    __block NSMutableDictionary *rangeIDict = [[NSMutableDictionary alloc] init];
    [attributedString enumerateAttribute:NSParagraphStyleAttributeName inRange:NSMakeRange(0,attributedString.length) options:0 usingBlock:^(id value,NSRange range,BOOL *stop) {
         if (value) {
             NSMutableParagraphStyle *myStyle = (NSMutableParagraphStyle *)value;
             if (myStyle.minimumLineHeight == 101) {
                 // 保存加粗的标签位置，如果相同位置有斜体，需要设置为斜体加粗
                 [rangeIDict setObject:@"YES" forKey:NSStringFromRange(range)];
                 [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:label.font.pointSize weight:UIFontWeightBold] range:range];
             }
         }
     }];
    
    [attributedString enumerateAttribute:NSParagraphStyleAttributeName inRange:NSMakeRange(0,attributedString.length) options:0 usingBlock:^(id value,NSRange range,BOOL *stop) {
      
         if (value) {
      
             NSMutableParagraphStyle *myStyle = (NSMutableParagraphStyle *)value;
             if (myStyle.minimumLineHeight == 99) {
                 UIFont *textFont = label.font;
                 CGAffineTransform matrix =  CGAffineTransformMake(1, 0, tanf(10 * (CGFloat)M_PI / 180), 1, 0, 0);
                 UIFont *font = [UIFont systemFontOfSize:textFont.pointSize];
                 // 相同的位置，有加粗
                 if ([@"YES" isEqual:[rangeIDict objectForKey:NSStringFromRange(range)]]) {
                    font = [UIFont boldSystemFontOfSize:textFont.pointSize];
                 }
                 
                 NSString *fontName = font.fontName;
                 if([fontName hasSuffix:@"SFUI-Regular"]){
                     fontName = @"TimesNewRomanPSMT";
                 }
                 UIFontDescriptor *desc = [UIFontDescriptor fontDescriptorWithName:fontName matrix:matrix];
                 [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithDescriptor:desc size:textFont.pointSize] range:range];
             }
             
      
         }
     }];
    
    // 文本段落排版格式
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle alloc] init];
    textStyle.lineBreakMode = NSLineBreakByWordWrapping; // 结尾部分的内容以……方式省略
    if (isGuide) {
        textStyle.lineSpacing = [ZCUIKitTools zcgetChatGuideLineSpacing]; // 调整行间距
    }else{
        textStyle.lineSpacing = [ZCUIKitTools zcgetChatLineSpacing]; // 调整行间距
    }
    NSMutableDictionary *textAttributes = [[NSMutableDictionary alloc] init];
    // NSParagraphStyleAttributeName 文本段落排版格式
    [textAttributes setValue:textStyle forKey:NSParagraphStyleAttributeName];
    // 设置段落样式
    [attributedString addAttributes:textAttributes range:NSMakeRange(0, attributedString.length)];
    [attributedString endEditing];
    
    label.text = [attributedString copy];
}

@end
