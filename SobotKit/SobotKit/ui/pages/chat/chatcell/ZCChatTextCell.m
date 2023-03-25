//
//  ZCChatTextCell.m
//  SobotKit
//
//  Created by zhangxy on 2022/9/15.
//

#import "ZCChatTextCell.h"

@interface ZCChatTextCell(){
    NSLayoutConstraint *layoutWidth;
    NSLayoutConstraint *layoutHeight;
    NSLayoutConstraint *layoutBgWidth;
    UIView *_lastView;
}

@property(nonatomic,strong) SobotEmojiLabel *lblMessage;
@property(nonatomic,strong) UIView *linkBgView;
@property(nonatomic,strong) NSLayoutConstraint *linkBgViewEH;
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
    _lblMessage = [ZCChatBaseCell createRichLabel];
    [self.contentView addSubview:_lblMessage];
    layoutWidth = sobotLayoutEqualWidth(0, _lblMessage, NSLayoutRelationEqual);
    layoutHeight = sobotLayoutEqualHeight(0, _lblMessage, NSLayoutRelationEqual);
    [self.contentView addConstraint:layoutWidth];
    [self.contentView addConstraint:layoutHeight];
    [self.contentView addConstraint:sobotLayoutMarginBottom(-ZCChatCellItemSpace, _lblMessage, self.lblSugguest)];
    [self.contentView addConstraints:sobotLayoutPaddingView(ZCChatPaddingVSpace, 0, ZCChatPaddingHSpace, 0, _lblMessage, self.ivBgView)];
    
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
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(doLongPress:)];
    self.lblMessage.userInteractionEnabled = YES;
    [self.lblMessage addGestureRecognizer:longPress];
    
    self.linkBgView.userInteractionEnabled = YES;
    [self.linkBgView addGestureRecognizer:longPress];
    
}

-(void)initDataToView:(SobotChatMessage *) message time:(NSString *) showTime{
    [super initDataToView:message time:showTime];
    NSLog(@"isShowSenderFlag=== %d",message.isShowSenderFlag);
    NSLog(@"富文本消息的内容 %@",message.displayMsgAttr);
    _lblMessage.text = @"";
    
    #pragma mark 标题+内容
    NSString *text = @"";
    
    if (message.displayMsgAttr==nil) {
        text = sobotConvertToString([message getModelDisplayText:YES]);
    }else{
        text = sobotConvertToString([message getModelDisplayText]);
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
        if(!sobotIsNull(message.displayMsgAttr)){
            [self setDisplayAttributedString:message.displayMsgAttr label:_lblMessage model:message guide:NO];
        }else{
            // 最后一行过滤所有换行，不是最后一行过滤一个换行
            [_lblMessage setText:text];
        }
        s = [_lblMessage preferredSizeWithMaxWidth:maxContentWidth];
    }
    layoutWidth.constant = s.width;
    layoutHeight.constant = s.height;
    
    CGFloat w = [self addText:text maxWidth:maxContentWidth];
    if(s.width < w){
        s.width = w;
    }
    if(s.height > 24){
        s.width = self.maxWidth;
    }
    if(message.includeSensitive > 0 && message.senderType == 0){
        [_linkBgView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        CGSize s = [self getAuthSensitiveView:message width:self.maxWidth with:_linkBgView msgLabel:_lblMessage];
        [_linkBgView addConstraint:sobotLayoutPaddingBottom(-ZCChatCellItemSpace, _lastView, _linkBgView)];
        layoutHeight.constant = s.height;
    }
    
//    [_lblMessage layoutIfNeeded];
    [self setChatViewBgState:CGSizeMake(s.width, s.height)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(CGFloat )addText:(NSString *)text maxWidth:(CGFloat ) cMaxWidth{
    _linkBgView.hidden = YES;
    if (sobotIsUrl(text, [ZCUIKitTools zcgetUrlRegular])) {
        _lblMessage.text = @"";
        layoutBgWidth.constant = cMaxWidth;
        layoutHeight.constant = 78;
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
        linktitleLab.textColor = UIColorFromModeColor(SobotColorTextMain);;
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
        [self.linkBgView addConstraint:sobotLayoutPaddingBottom(-12, icon, self.linkBgView)];
        
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
        
        [self getLinkValues:text result:^(NSString * _Nonnull title, NSString * _Nonnull desc, NSString * _Nonnull iconUrl) {
            if(title.length > 0){
                linktitleLab.text = sobotConvertToString(title);
                linkdescLab.text = sobotConvertToString(desc);

                [icon loadWithURL:[NSURL URLWithString:sobotConvertToString(iconUrl)] placeholer:SobotKitGetImage(@"zcicon_url_icon") showActivityIndicatorView:NO];
            }else{
                linktitleLab.text = sobotConvertToString(text);
                linkdescLab.hidden = YES;
                descTop.constant = 0;
                
                layoutHeight.constant = 60;
                [_linkBgView removeConstraint:iconTop];
                [_linkBgView addConstraint:sobotLayoutPaddingTop(0, icon, linktitleLab)];
                
                [_linkBgView removeConstraint:rightTitle];
                [_linkBgView addConstraint:sobotLayoutMarginRight(-15, linktitleLab, icon)];
                
                [icon loadWithURL:[NSURL URLWithString:sobotConvertToString(iconUrl)] placeholer:SobotKitGetImage(@"zcicon_url_icon") showActivityIndicatorView:NO];
            }
        }];
        
        
        return cMaxWidth;
    }
    return 0;
}

-(void)setLinkValues:(NSString *) urlMsg titleLabel:(UILabel *)titleLab desc:(UILabel *) linkLab imgView:(SobotImageView *) icon{
    NSDictionary *item = [SobotCache getLocalParamter:[NSString stringWithFormat:@"%@%@",Sobot_CacheURLHeader,sobotConvertToString(urlMsg)]];
    if(!sobotIsNull(item) && item.count > 0){
        titleLab.text = sobotConvertToString(item[@"title"]);
        linkLab.text = sobotConvertToString(item[@"desc"]);

        NSString *imgUrl = sobotConvertToString([item objectForKey:@"imgUrl"]);
        if (sobotConvertToString(linkLab.text).length == 0) {
            linkLab.text = sobotConvertToString(urlMsg);
        }
        [icon loadWithURL:[NSURL URLWithString:sobotConvertToString(imgUrl)] placeholer:SobotKitGetImage(@"zcicon_url_icon") showActivityIndicatorView:NO];
        return;
    }
    
    [ZCLibServer getHtmlAnalysisWithURL:sobotConvertToString(urlMsg) start:^(NSString *url){
        
    } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
        if (!sobotIsNull(dict)) {
            NSDictionary *data = [dict objectForKey:@"data"];
            NSString *title = sobotConvertToString([data objectForKey:@"title"]);
            NSString *desc = sobotConvertToString([data objectForKey:@"desc"]);
            NSString *imgUrl = sobotConvertToString([data objectForKey:@"imgUrl"]);
            [SobotCache addObject:data forKey:[NSString stringWithFormat:@"%@%@",Sobot_CacheURLHeader,sobotConvertToString(urlMsg)]];
            
            titleLab.text = sobotConvertToString(title);
            linkLab.text = sobotConvertToString(desc);
            if (sobotConvertToString(desc).length == 0) {
                linkLab.text = sobotConvertToString(urlMsg);
            }
            [icon loadWithURL:[NSURL URLWithString:imgUrl] placeholer:SobotKitGetImage(@"zcicon_url_icon") showActivityIndicatorView:NO];
            
            if (sobotConvertToString(title).length == 0 &&
                sobotConvertToString(desc).length == 0 &&
                sobotConvertToString(imgUrl).length == 0) {
                [self.contentView removeConstraint:self->_linkBgViewEH];
                self->_linkBgViewEH = sobotLayoutEqualHeight(0,self->_linkBgView, NSLayoutRelationEqual);
                [self.contentView addConstraint:self->_linkBgViewEH];
            }
        }
    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
        [SobotHtmlCore websiteFilter:sobotConvertToString(urlMsg) result:^(NSString * _Nonnull url, NSString * _Nonnull iconUrl, NSString * _Nonnull title, NSString * _Nonnull desc, NSDictionary * _Nullable dict) {
            titleLab.text = sobotConvertToString(title);
            linkLab.text = sobotConvertToString(desc);
            
            if (sobotConvertToString(desc).length == 0) {
                linkLab.text = sobotConvertToString(urlMsg);
            }
            if(sobotConvertToString(title).length > 0){
                [SobotCache addObject:@{@"title":title,@"desc":desc,@"imgUrl":iconUrl} forKey:[NSString stringWithFormat:@"%@%@",Sobot_CacheURLHeader,sobotConvertToString(urlMsg)]];
            }
        }];
    }];
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
/// @param richLabel  要展示的label
-(CGSize ) getAuthSensitiveView:(SobotChatMessage *) message width:(CGFloat ) maxWidth with:(UIView *) superView msgLabel:(SobotEmojiLabel *) richLabel{
    CGFloat h = 10;
    CGFloat lineSpace = [ZCUIKitTools zcgetChatLineSpacing];
    NSString *text = sobotConvertToString([message getModelDisplayText]);
    CGFloat contentWidth = maxWidth - 20;
    if(!richLabel){
        richLabel = [ZCChatBaseCell createRichLabel];
    }
    [superView addSubview:richLabel];
    [richLabel setTextColor:UIColorFromModeColor(SobotColorTextSub)];
    if(!sobotIsNull(message.displayMsgAttr)){
        [self setDisplayAttributedString:message.displayMsgAttr label:richLabel model:message guide:NO];
    }else{
        // 最后一行过滤所有换行，不是最后一行过滤一个换行
        [richLabel setText:text];
    }
    CGSize s = [richLabel preferredSizeWithMaxWidth:contentWidth];
    BOOL isShowExport = NO;
    if(s.height > 60 && !message.showAllMessage){
        isShowExport = YES;
        s.height = 60;
    }
    h = h + s.height + 10 + lineSpace;
    if(contentWidth < s.width){
        contentWidth = s.width;
    }
    _lastView = richLabel;
    
    NSString *warningTips = sobotConvertToString(message.sentisiveExplain);
    if(superView){
        UIImageView *ivBg = [[UIImageView alloc] init];
        ivBg.layer.cornerRadius = 2.0f;
        ivBg.layer.masksToBounds = YES;
        ivBg.backgroundColor = UIColorFromModeColor(SobotColorBgSub2Dark1);
        [superView addSubview:ivBg];
        [superView addConstraints:sobotLayoutSize(contentWidth, h+26, ivBg, NSLayoutRelationEqual)];
        [superView addConstraint:sobotLayoutPaddingTop(0, ivBg, superView)];
        [superView addConstraint:sobotLayoutPaddingLeft(10, ivBg, superView)];
        
        [superView addSubview:richLabel];
        [superView addConstraints:sobotLayoutSize(s.width, s.height, richLabel, NSLayoutRelationEqual)];
        [superView addConstraint:sobotLayoutPaddingTop(10, richLabel, superView)];
        [superView addConstraint:sobotLayoutPaddingLeft(10, richLabel, superView)];
        
        CGFloat space = 20;
        // 显示展示更多
        if(isShowExport){
            UIImageView *ivBg = [[UIImageView alloc] init];
            [superView addSubview:ivBg];
            
            SobotEmojiLabel *tipLabel = [ZCChatBaseCell createRichLabel];
            [superView addSubview:tipLabel];
            
            [superView addConstraints:sobotLayoutSize(contentWidth, 56, richLabel, NSLayoutRelationEqual)];
            [superView addConstraint:sobotLayoutMarginTop(-20, tipLabel, richLabel)];
            [superView addConstraint:sobotLayoutPaddingLeft(0, richLabel, superView)];
            
            // 设置和tipLabel相同
            [superView addConstraints:sobotLayoutPaddingWithAll(0, 0, 0, 0, ivBg, tipLabel)];
            [tipLabel layoutIfNeeded];
            
            tipLabel.textAlignment = NSTextAlignmentCenter;
            [tipLabel setLinkColor:UIColorFromModeColor(SobotColorTheme)];
            [tipLabel setText:SobotKitLocalString(@"展开消息")];
            [tipLabel addLinkToURL:[NSURL URLWithString:@"sobot://showallsensitive"] withRange:NSMakeRange(0, SobotKitLocalString(@"展开消息").length)];
//            [tipLabel preferredSizeWithMaxWidth:contentWidth];
            [self viewBeizerRect:tipLabel.bounds view:tipLabel corner:UIRectCornerBottomLeft|UIRectCornerBottomRight cornerRadii:CGSizeMake(2, 2)];

            [self viewBeizerRect:ivBg.bounds view:ivBg corner:UIRectCornerBottomLeft|UIRectCornerBottomRight cornerRadii:CGSizeMake(2, 2)];

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
            [ivBg.layer addSublayer:gradientLayer];
            
            space = space + 26;
        }
        
        SobotEmojiLabel *tipLabel = [ZCChatBaseCell createRichLabel];
        [tipLabel setTextColor:UIColorFromModeColor(SobotColorTextMain)];
        [tipLabel setText:warningTips];
        [superView addSubview:tipLabel];
        CGSize s1 = [tipLabel preferredSizeWithMaxWidth:contentWidth];
     
        [superView addConstraints:sobotLayoutSize(s1.width, s1.height, tipLabel, NSLayoutRelationEqual)];
        [superView addConstraint:sobotLayoutMarginTop(space, tipLabel, richLabel)];
        [superView addConstraint:sobotLayoutPaddingLeft(0, tipLabel, superView)];
        
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
           [superView addConstraint:sobotLayoutMarginTop(lineSpace, tipLabel2, tipLabel)];
           [superView addConstraint:sobotLayoutPaddingLeft(0, tipLabel2, superView)];
               
        }else{
            UIButton *btn1 = [self createAuthButton:SobotKitLocalString(@"拒绝") type:1];
            btn1.frame = CGRectMake(contentWidth - 120 - 60, h, 60, 30);
            [superView addSubview:btn1];
            [superView addConstraints:sobotLayoutSize(60, 30, btn1, NSLayoutRelationEqual)];
            [superView addConstraint:sobotLayoutMarginTop(lineSpace, btn1, tipLabel)];
            [superView addConstraint:sobotLayoutPaddingLeft(contentWidth - 120 - 60, btn1, superView)];
        }
        UIButton *btn2 = [self createAuthButton:SobotKitLocalString(@"继续发送") type:2];
        btn2.frame = CGRectMake(contentWidth - 90, h, 90, 30);
        [superView addSubview:btn2];
        
        [superView addConstraints:sobotLayoutSize(90, 30, btn2, NSLayoutRelationEqual)];
        [superView addConstraint:sobotLayoutMarginTop(lineSpace, btn2, tipLabel)];
        [superView addConstraint:sobotLayoutPaddingLeft(contentWidth - 90, btn2, superView)];
        
        [btn2 layoutIfNeeded];
        
        _lastView = btn2;
    }
    return CGSizeMake(contentWidth, h - lineSpace);
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
        [_btnTurnUser setBackgroundColor:UIColorFromModeColor(SobotColorBgMainDark2)];
        _btnTurnUser.layer.borderColor = UIColorFromModeColor(SobotColorBgLine).CGColor;
        [_btnTurnUser setTitleColor:UIColorFromModeColor(SobotColorTextMain) forState:UIControlStateNormal];
    }else{
        [_btnTurnUser setBackgroundColor:UIColorFromModeColor(SobotColorTheme)];
        _btnTurnUser.layer.borderColor = UIColorFromModeColor(SobotColorTheme).CGColor;
        [_btnTurnUser setTitleColor:UIColorFromModeColor(SobotColorTextWhite) forState:UIControlStateNormal];
        
    }
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


-(void)setDisplayAttributedString:(NSMutableAttributedString *) attr label:(UILabel *) label model:(SobotChatMessage *)curModel guide:(BOOL)isGuide{
    UIColor *textColor = [ZCUIKitTools zcgetLeftChatTextColor];
    UIColor *linkColor = [ZCUIKitTools zcgetChatLeftLinkColor];
    if([self isRight]){
        textColor = [ZCUIKitTools zcgetRightChatTextColor];
        linkColor = [ZCUIKitTools zcgetChatRightlinkColor];
    }
    
    CGFloat lineSpace = [ZCUIKitTools zcgetChatLineSpacing]; // 调整行间距
    if (isGuide) {
        lineSpace = [ZCUIKitTools zcgetChatGuideLineSpacing]; // 调整行间距
    }
    
    
    label.attributedText = [ZCUIKitTools parseStringArtribute:attr linespace:lineSpace font:label.font textColor:textColor linkColr:linkColor];

}

@end
