//
//  ZCChatMessageInfoRichTextView.m
//  SobotKit
//
//  Created by lizh on 2023/11/23.
//

#import "ZCChatMessageInfoRichTextView.h"
@interface ZCChatMessageInfoRichTextView()<SobotEmojiLabelDelegate,SobotXHImageViewerDelegate,UIGestureRecognizerDelegate>

@property(nonatomic,strong)UIView *contentView;

@property(nonatomic,strong)UIView *lastView;
@end

@implementation ZCChatMessageInfoRichTextView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        self.userInteractionEnabled = YES;
        [self layoutSubViewUI];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self layoutSubViewUI];
    }
    return self;
}

-(void)layoutSubViewUI{
    _contentView = ({
        UIView *iv = [[UIView alloc]init];
        [self addSubview:iv];
        iv.backgroundColor = UIColor.clearColor;
        [self addConstraint:sobotLayoutPaddingTop(0, iv, self)];
        [self addConstraint:sobotLayoutPaddingLeft(0, iv, self)];
        [self addConstraint:sobotLayoutPaddingRight(0, iv, self)];
        [self addConstraint:sobotLayoutPaddingBottom(0, iv, self)];
        iv;
    });
}

-(CGFloat)dataToView:(SobotChatMessage *)model{
    CGFloat viewH = 0;
    _lastView = nil;
    [_contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (int i=0;i<model.richModel.richList.count;i++) {
        SobotChatRichContent *item =  model.richModel.richList[i];
        SobotMessageType type = item.type;
        // 0文本,1图片,2音频,3视频,4文件,5对象
        NSString *msg = sobotConvertToString(item.msg);
        if([@"<br>" isEqual:sobotTrimString(msg)] || [@"<br/>" isEqual:msg]){
            continue;
        }
        if(type == 0){
            if(model.senderType == 0 && model.richModel.richList.count == 1){
                if(sobotConvertToString(model.richModel.content).length > 0){
                    item.msg = sobotConvertToString(model.richModel.content);
                    item.attr = nil;
                }
            }
            int showType = [sobotConvertToString(item.showType) intValue];
            CGFloat itemH = [self addText:item view:_contentView maxWidth:ScreenWidth - 42*2 showType:showType lastMsg:i == (model.richModel.richList.count-1) model:model];
            viewH = viewH + itemH + 10;
        }
        // 图片和视频
        if(type == 1 || type == 3){
            // 2：音频，3：视频，4：文件
            if(!sobotIsUrl(msg,[ZCUIKitTools zcgetUrlRegular])){
                continue;
            }
            SobotImageView *imgView = [[SobotImageView alloc] init];
            [imgView setContentMode:UIViewContentModeScaleAspectFill];
            [imgView.layer setCornerRadius:4.0f];
            [imgView.layer setMasksToBounds:YES];
            if(type == 3){
                [imgView loadWithURL:[NSURL URLWithString:sobotConvertToString(item.snapshot)] placeholer:SobotKitGetImage(@"zcicon_default_goods_1") showActivityIndicatorView:NO];
            }else{
                [imgView loadWithURL:[NSURL URLWithString:msg] placeholer:SobotKitGetImage(@"zcicon_default_goods_1") showActivityIndicatorView:NO];
            }
            UITapGestureRecognizer *tapGesturer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgTouchUpInside:)];
            imgView.userInteractionEnabled=YES;
            [imgView addGestureRecognizer:tapGesturer];
            [_contentView addSubview:imgView];
            [_contentView addConstraint:sobotLayoutPaddingRight(-42, imgView, _contentView)];
            [_contentView addConstraint:sobotLayoutPaddingLeft(42, imgView, _contentView)];
            [_contentView addConstraint:sobotLayoutEqualHeight(200, imgView, NSLayoutRelationEqual)];
           
            if(type == 3){
                [imgView loadWithURL:[NSURL URLWithString:@"https://img.sobot.com/chat/common/res/83f5636f-51b7-48d6-9d63-40eba0963bda.png"] placeholer:SobotKitGetImage(@"zcicon_default_goods_1") showActivityIndicatorView:NO];
                // 设置一个特殊的tag，不支持点击查看大图
                imgView.tag = 101;
                SobotButton *_playButton = [SobotButton buttonWithType:UIButtonTypeCustom];
                _playButton.obj = item;
                [_playButton setImage:SobotKitGetImage(@"zcicon_video_play") forState:0];
                [_playButton setBackgroundColor:UIColor.clearColor];
                [_contentView addSubview:_playButton];
                [_playButton addTarget:self action:@selector(fileUrlClick:) forControlEvents:UIControlEventTouchUpInside];
                
                [_contentView addConstraints:sobotLayoutSize(30, 30, _playButton, NSLayoutRelationEqual)];
                [_contentView addConstraint:sobotLayoutEqualCenterX(0, _playButton, imgView)];
                [_contentView addConstraint:sobotLayoutEqualCenterY(0, _playButton, imgView)];
            }
            if(_lastView){
                [_contentView addConstraint:sobotLayoutMarginTop(10, imgView, _lastView)];
            }else{
                [_contentView addConstraint:sobotLayoutPaddingTop(10, imgView, _contentView)];
            }
            _lastView = imgView;
            
            viewH = viewH + 200 + 10;
        }
        // 文件和音频
        if(type == 4 || type == 2) {
            // 文件
            UIView *bgView = [[UIView alloc]init];
            bgView.backgroundColor = UIColorFromModeColor(SobotColorBgMainDark3);
            bgView.layer.cornerRadius = 4;
//            bgView.layer.masksToBounds = YES;
            [_contentView addSubview:bgView];
            [_contentView addConstraint:sobotLayoutEqualHeight(70, bgView, NSLayoutRelationEqual)];
            [_contentView addConstraint:sobotLayoutPaddingLeft(42, bgView, _contentView)];
            [_contentView addConstraint:sobotLayoutPaddingRight(-42, bgView, _contentView)];
            
            
            SobotImageView *icon = [[SobotImageView alloc]init];
            if (type == 2) {
                [icon setImage:[ZCUIKitTools getFileIcon:@"" fileType:4]];
            }else if (type == 4){
                [icon setImage:[ZCUIKitTools getFileIcon:sobotConvertToString(item.msg) fileType:0]];
            }
            [bgView addSubview:icon];
            [bgView addConstraint:sobotLayoutPaddingTop(15, icon, bgView)];
            [bgView addConstraint:sobotLayoutPaddingLeft(15, icon, bgView)];
            [bgView addConstraints:sobotLayoutSize(34,40, icon, NSLayoutRelationEqual)];
            
            UILabel *titleLab = [[UILabel alloc]init];
            titleLab.font = SobotFontBold14;
            titleLab.textColor = UIColorFromModeColor(SobotColorTextMain);;
            titleLab.numberOfLines = 1;
            [bgView addSubview:titleLab];
            titleLab.text = sobotConvertToString(item.name);
            
            [bgView addConstraint:sobotLayoutPaddingTop(15, titleLab, bgView)];
            [bgView addConstraint:sobotLayoutMarginLeft(10, titleLab, icon)];
            [bgView addConstraint:sobotLayoutEqualHeight(20, titleLab,NSLayoutRelationEqual)];
            [bgView addConstraint:sobotLayoutPaddingRight(-15, titleLab, bgView)];
            
            UILabel *sizeLab = [[UILabel alloc]init];
            sizeLab.font = SobotFont12;
            sizeLab.textColor =UIColorFromModeColor(SobotColorTextSub);
            sizeLab.text = sobotConvertToString(item.fileSize);
            [bgView addSubview:sizeLab];
            [bgView addConstraint:sobotLayoutMarginTop(ZCChatCellItemSpace, sizeLab, titleLab)];
            [bgView addConstraint:sobotLayoutMarginLeft(10, sizeLab, icon)];
            [bgView addConstraint:sobotLayoutPaddingRight(-15, sizeLab, bgView)];
            
            SobotButton *objBtn = [SobotButton buttonWithType:UIButtonTypeCustom];
            [objBtn setBackgroundColor:[UIColor clearColor]];
            objBtn.obj = item;
            bgView.userInteractionEnabled = YES;
            [bgView addSubview:objBtn];
            [objBtn addTarget:self action:@selector(fileUrlClick:) forControlEvents:UIControlEventTouchUpInside];
            [bgView addConstraint:sobotLayoutPaddingLeft(0, objBtn, bgView)];
            [bgView addConstraint:sobotLayoutPaddingRight(0, objBtn, bgView)];
            [bgView addConstraint:sobotLayoutEqualHeight(70, objBtn, NSLayoutRelationEqual)];
            [bgView addConstraint:sobotLayoutPaddingTop(0, objBtn, bgView)];
            if(_lastView){
                [_contentView addConstraint:sobotLayoutMarginTop(10, bgView, _lastView)];
            }else{
                [_contentView addConstraint:sobotLayoutPaddingTop(10, bgView, _contentView)];
            }
            
            // 添加阴影
            NSArray<CALayer *> *subLayers = bgView.layer.sublayers;
            NSArray<CALayer *> *removedLayers = [subLayers filteredArrayUsingPredicate:
            [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                return [evaluatedObject isKindOfClass:[CAShapeLayer class]];
            }]];
            [removedLayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj removeFromSuperlayer];
             }];
            bgView.layer.masksToBounds = NO;
            bgView.layer.backgroundColor = [ZCUIKitTools zcgetChatBackgroundColor].CGColor;
            bgView.layer.cornerRadius = 8;
            bgView.layer.shadowColor = [ZCUIKitTools zcgetChatBottomLineColor].CGColor;
            bgView.layer.shadowOffset = CGSizeMake(0,1);
            bgView.layer.shadowOpacity = 1;
            bgView.layer.shadowRadius = 4;
            
            
            _lastView = bgView;
            viewH = viewH + 70 + 10;
        }
    }
    if(!sobotIsNull(_lastView)){
        [_contentView addConstraint:sobotLayoutPaddingBottom(-10, _lastView, _contentView)];
    }
//    [self layoutIfNeeded];
//    CGRect f = self.lastView.frame;
//    SLog(@"计算的高度：-----%@", NSStringFromCGRect(f));
//    return f.size.height + f.origin.y;
    SLog(@"计算的高度：-----%f", viewH);
    return viewH;
}

#pragma mark -- 超链卡片点击事件
-(void)urlTextClick:(SobotButton*)sender{
    NSString *url = (NSString*)(sender.obj);
    if(self.delegate && [self.delegate respondsToSelector:@selector(onViewEvent:dict:obj:)]){
        [self.delegate onViewEvent:ZCChatMessageInfoViewEventOpenUrl dict:@{} obj:sobotConvertToString(url)];
    }
}

// richlist 文件打开方式是web
-(void)fileUrlClick:(SobotButton*)sender{
    SobotChatRichContent *item = (SobotChatRichContent *)(sender.obj);
    if(self.delegate && [self.delegate respondsToSelector:@selector(onViewEvent:dict:obj:)]){
        [self.delegate onViewEvent:ZCChatMessageInfoViewEventOpenUrl dict:@{} obj:sobotConvertToString(item.msg)];
    }
}

#pragma mark -- 手势冲突的代理
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[SobotButton class]] || [touch.view isMemberOfClass:[SobotEmojiLabel class]] ){
        return NO;
    }
    return YES;
}

-(SobotEmojiLabel *) createRichLabel{
    SobotEmojiLabel *tempRichLabel = [[SobotEmojiLabel alloc] initWithFrame:CGRectZero];
    tempRichLabel.numberOfLines = 0;
    tempRichLabel.font = [UIFont systemFontOfSize:14];
    tempRichLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    tempRichLabel.textColor = [UIColor whiteColor];
    tempRichLabel.backgroundColor = [UIColor clearColor];
    tempRichLabel.isNeedAtAndPoundSign = NO;
    tempRichLabel.disableEmoji = NO;
    tempRichLabel.lineSpacing = 3;
    tempRichLabel.verticalAlignment = 0;
    return tempRichLabel;
}

-(CGFloat)addText:(SobotChatRichContent *)item view:(UIView *) superView maxWidth:(CGFloat ) cMaxWidth showType:(int )showType lastMsg:(BOOL )isLast model:(SobotChatMessage *)model{
    NSMutableAttributedString *attrString = item.attr;
    NSString *text = sobotConvertToString(item.msg);
    
    // 最后一行过滤所有换行，不是最后一行过滤一个换行
    if(isLast){
        while ([text hasSuffix:@"\n"]){
            text = [text substringToIndex:text.length - 1];
            while ([text hasSuffix:@" "]){
                text = [text substringToIndex:text.length - 1];
            }
        }
        while ([text hasSuffix:@"<br>"]){
            text = [text substringToIndex:text.length - 4];
            while ([text hasSuffix:@" "]){
                text = [text substringToIndex:text.length - 1];
            }
        }
        
        while ([text hasSuffix:@" "]){
            text = [text substringToIndex:text.length - 1];
        }
    }
    if(text.length == 0){
        return 0;
    }
    
    SobotEmojiLabel *tipLabel = [self createRichLabel];
    tipLabel.font = SobotFont18;
    tipLabel.delegate = self;
    UIColor *linkColor = [ZCUIKitTools zcgetChatLeftLinkColor];
    if(model.sendType == 0){
        linkColor = [ZCUIKitTools zcgetChatRightlinkColor];
    }
    [tipLabel setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
    [tipLabel setLinkColor:linkColor];
    tipLabel.textAlignment = NSTextAlignmentLeft;
    [superView addSubview:tipLabel];
    
    if(!sobotIsNull(item.name) && sobotConvertToString(item.name).length > 0 && sobotIsUrl(text,[ZCUIKitTools zcgetUrlRegular])){
        [tipLabel setText:[SobotHtmlCore filterHTMLTag:sobotConvertToString(item.name)]];
        [tipLabel addLinkToURL:[NSURL URLWithString:sobotConvertToString(text)] withRange:NSMakeRange(0, [SobotHtmlCore filterHTMLTag:sobotConvertToString(item.name)].length)];
    }else{
        if(!sobotIsNull(attrString)){
            [self setDisplayAttributedString:attrString label:tipLabel guide:NO model:model];
        }else{
            // 最后一行过滤所有换行，不是最后一行过滤一个换行
            if(isLast){
                while ([text hasSuffix:@"\n"]){
                    text = [text substringToIndex:text.length - 1];
                }
            }
            text = [SobotHtmlCore filterHTMLTag:text];
            if(model.sendType != 0){
                text = [ZCUIKitTools removeAllHTMLTag:text];
            }
            tipLabel.text = text;
        }
    }
    CGSize s2 = [tipLabel preferredSizeWithMaxWidth:cMaxWidth];
    
    [_contentView addConstraint:sobotLayoutPaddingLeft(42, tipLabel, _contentView)];
    [_contentView addConstraint:sobotLayoutPaddingRight(-42, tipLabel, _contentView)];
    if(_lastView){
        [_contentView addConstraint:sobotLayoutMarginTop(10, tipLabel, _lastView)];
    }else{
        [_contentView addConstraint:sobotLayoutPaddingTop(10, tipLabel, _contentView)];
    }
   
    if (sobotIsUrl(text, [ZCUIKitTools zcgetUrlRegular]) && showType == 1) {
        // 显示超链卡片
        superView.userInteractionEnabled = YES;
        tipLabel.hidden = YES;
        CGSize links = CGSizeMake(cMaxWidth, 78);
        SobotView *linkBgView = [[SobotView alloc]init];
        linkBgView.layer.cornerRadius = 4;
        linkBgView.layer.masksToBounds = YES;
        linkBgView.backgroundColor = UIColorFromModeColor(SobotColorBgMainDark3);
        [superView addSubview:linkBgView];
        
        linkBgView.objTag = text;
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(doLongPress:)];
        linkBgView.userInteractionEnabled = YES;
        [linkBgView addGestureRecognizer:longPress];
        
        // 覆盖上面的明文链接
        [_contentView addConstraint:sobotLayoutPaddingTop(0, linkBgView, tipLabel)];
        [_contentView addConstraint:sobotLayoutPaddingLeft(42,linkBgView, _contentView)];
        [_contentView addConstraint:sobotLayoutPaddingRight(-42, linkBgView, _contentView)];
        [_contentView addConstraint:sobotLayoutEqualHeight(78, linkBgView, NSLayoutRelationEqual)];
        
        SobotButton *btn = [SobotButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundColor:[UIColor clearColor]];
        [linkBgView addSubview:btn];
        [btn addTarget:self action:@selector(urlTextClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.obj = text;
        [linkBgView addConstraints:sobotLayoutPaddingWithAll(0, 0, 0, 0, btn, linkBgView)];
        
        UILabel *linktitleLab = [[UILabel alloc]init];
        linktitleLab.font = SobotFontBold14;
        linktitleLab.text = SobotKitLocalString(@"解析中...");
        linktitleLab.textColor = UIColorFromModeColor(SobotColorTextMain);;
        [linkBgView addSubview:linktitleLab];
        linktitleLab.numberOfLines = 1;
        [superView addConstraint:sobotLayoutEqualHeight(20, linktitleLab, NSLayoutRelationEqual)];
        NSLayoutConstraint *rightTitle = sobotLayoutPaddingRight(-15, linktitleLab, linkBgView);
        [linkBgView addConstraint:rightTitle];
        [linkBgView addConstraint:sobotLayoutPaddingLeft(15, linktitleLab, linkBgView)];
        [linkBgView addConstraint:sobotLayoutPaddingTop(12, linktitleLab, linkBgView)];
        
        SobotImageView *icon = [[SobotImageView alloc]init];
        [icon loadWithURL:[NSURL URLWithString:@""] placeholer:SobotKitGetImage(@"zcicon_url_icon") showActivityIndicatorView:NO];
        [linkBgView addSubview:icon];
        [superView addConstraints:sobotLayoutSize(34,34, icon, NSLayoutRelationEqual)];
        [linkBgView addConstraint:sobotLayoutPaddingRight(-15, icon, linkBgView)];
        
        NSLayoutConstraint *iconTop = sobotLayoutMarginTop(ZCChatCellItemSpace, icon, linktitleLab);
        [linkBgView addConstraint:iconTop];
        
        // 超链链接
        UILabel *linkdescLab = [[UILabel alloc]init];
        linkdescLab.font = SobotFont12;
        linkdescLab.textColor = UIColorFromModeColor(SobotColorTextSub);
        linkdescLab.numberOfLines = 2;
        [linkBgView addSubview:linkdescLab];
        [linkBgView addConstraint:sobotLayoutPaddingLeft(15, linkdescLab, linkBgView)];
        
        NSLayoutConstraint *descTop = sobotLayoutMarginTop(ZCChatCellItemSpace, linkdescLab, linktitleLab);

        [linkBgView addConstraint:descTop];
        [linkBgView addConstraint:sobotLayoutMarginRight(-ZCChatCellItemSpace, linkdescLab, icon)];
        
        [self setLinkValues:text titleLabel:linktitleLab desc:linkdescLab imgView:icon superView:superView linkBgView:linkBgView name:sobotConvertToString(item.name)];
        [self getLinkValues:text name:sobotConvertToString(item.name) result:^(NSString * _Nonnull title, NSString * _Nonnull desc, NSString * _Nonnull iconUrl) {
            if(title.length > 0){
                linktitleLab.text = sobotConvertToString(title);
                linkdescLab.text = sobotConvertToString(desc);
//                self->_linkLayoutHeight.constant = 78;
                [icon loadWithURL:[NSURL URLWithString:sobotConvertToString(iconUrl)] placeholer:SobotKitGetImage(@"zcicon_url_icon") showActivityIndicatorView:NO];
            }else{
                linktitleLab.text = sobotConvertToString(text);
                linkdescLab.hidden = YES;
                descTop.constant = 0;
//                self->_linkLayoutHeight.constant = 60;
                [linkBgView removeConstraint:iconTop];
                [linkBgView addConstraint:sobotLayoutPaddingTop(0, icon, linktitleLab)];
                [linkBgView removeConstraint:rightTitle];
                [linkBgView addConstraint:sobotLayoutMarginRight(-15, linktitleLab, icon)];
                [icon loadWithURL:[NSURL URLWithString:sobotConvertToString(iconUrl)] placeholer:SobotKitGetImage(@"zcicon_url_icon") showActivityIndicatorView:NO];
            }
        }];
        
        // 添加阴影
        NSArray<CALayer *> *subLayers = linkBgView.layer.sublayers;
        NSArray<CALayer *> *removedLayers = [subLayers filteredArrayUsingPredicate:
        [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            return [evaluatedObject isKindOfClass:[CAShapeLayer class]];
        }]];
        [removedLayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperlayer];
         }];
        linkBgView.layer.masksToBounds = NO;
        linkBgView.layer.backgroundColor = [ZCUIKitTools zcgetChatBackgroundColor].CGColor;
        linkBgView.layer.cornerRadius = 8;
        linkBgView.layer.shadowColor = [ZCUIKitTools zcgetChatBottomLineColor].CGColor;
        linkBgView.layer.shadowOffset = CGSizeMake(0,1);
        linkBgView.layer.shadowOpacity = 1;
        linkBgView.layer.shadowRadius = 4;
               
        _lastView = linkBgView;
        return 78;
    }
    
    _lastView = tipLabel;
    return s2.height;
}

-(void)setLinkValues:(NSString *) urlMsg titleLabel:(UILabel *)titleLab desc:(UILabel *) linkLab imgView:(SobotImageView *) icon superView:(UIView*)superView linkBgView:(UIView*)linkBgView name:(NSString *)name{
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
            if (sobotConvertToString(title).length == 0) {
                if (sobotConvertToString(name).length >0) {
                    title = sobotConvertToString(name);
                }else{
                    title = sobotConvertToString(urlMsg);
                }
            }
            if (sobotConvertToString(desc).length == 0) {
                desc = sobotConvertToString(urlMsg);
            }
            
                [SobotCache addObject:data forKey:[NSString stringWithFormat:@"%@%@",Sobot_CacheURLHeader,sobotConvertToString(urlMsg)]];
                titleLab.text = sobotConvertToString(title);
                linkLab.text = sobotConvertToString(desc);
                if (sobotConvertToString(desc).length == 0) {
                    linkLab.text = sobotConvertToString(urlMsg);
                }
            [icon loadWithURL:[NSURL URLWithString:imgUrl] placeholer:SobotKitGetImage(@"zcicon_url_icon") showActivityIndicatorView:NO];
//            }
        }
    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
//        [SobotHtmlCore websiteFilter:sobotConvertToString(urlMsg) result:^(NSString * _Nonnull url, NSString * _Nonnull iconUrl, NSString * _Nonnull title, NSString * _Nonnull desc, NSDictionary * _Nullable dict) {
//            titleLab.text = sobotConvertToString(title);
//            linkLab.text = sobotConvertToString(desc);
//
//            if (sobotConvertToString(desc).length == 0) {
//                linkLab.text = sobotConvertToString(urlMsg);
//            }
//
//            if(sobotConvertToString(title).length > 0){
//                [SobotCache addObject:@{@"title":title,@"desc":desc,@"imgUrl":iconUrl} forKey:[NSString stringWithFormat:@"%@%@",Sobot_CacheURLHeader,sobotConvertToString(urlMsg)]];
//            }
//        }];
    }];
}

-(void)getLinkValues:(NSString *) link name:(NSString *)name result:(void(^)(NSString *title,NSString *desc,NSString *icon)) block{
    NSDictionary *item = [SobotCache getLocalParamter:[NSString stringWithFormat:@"%@%@",Sobot_CacheURLHeader,sobotConvertToString(link)]];
    if(!sobotIsNull(item) && item.count > 0){
        if(block){
            block(sobotConvertToString(item[@"title"]),sobotConvertToString(item[@"desc"]),sobotConvertToString([item objectForKey:@"imgUrl"]));
        }
        return;
    }
    
    [ZCLibServer getHtmlAnalysisWithURL:sobotConvertToString(link) start:^(NSString *url){
        
    } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
        if (!sobotIsNull(dict)) {
            NSDictionary *data = [dict objectForKey:@"data"];
            NSString *title = sobotConvertToString([data objectForKey:@"title"]);
            NSString *desc = sobotConvertToString([data objectForKey:@"desc"]);
            NSString *imgUrl = sobotConvertToString([data objectForKey:@"imgUrl"]);
            if(title.length > 0 || imgUrl.length >0){
                if (sobotConvertToString(title).length == 0) {
                    if (sobotConvertToString(name).length >0) {
                        title = sobotConvertToString(name);
                    }else{
                        title = sobotConvertToString(link);
                    }
                }
                if (sobotConvertToString(desc).length == 0) {
                    desc = sobotConvertToString(link);
                }
                NSDictionary *dataDic = @{@"title":sobotConvertToString(title),
                                          @"desc":sobotConvertToString(desc),
                                          @"imgUrl":sobotConvertToString(imgUrl),
                };
                [SobotCache addObject:dataDic forKey:[NSString stringWithFormat:@"%@%@",Sobot_CacheURLHeader,sobotConvertToString(link)]];
            }
//            if(self.delegate && [self.delegate respondsToSelector:@selector(updateLoadData)]){
//                [self.delegate updateLoadData];
//            }
            [self layoutIfNeeded];
        }
    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
        NSString *title = name;
        NSString *desc = link;
        if(name.length == 0){
            title = link;
            desc = @"";
        }
        NSDictionary *dataDic = @{@"title":sobotConvertToString(title),
                                  @"desc":sobotConvertToString(desc),
                                  @"imgUrl":@""
        };
        
        [SobotCache addObject:dataDic forKey:[NSString stringWithFormat:@"%@%@",Sobot_CacheURLHeader,sobotConvertToString(link)]];
//        if(self.delegate && [self.delegate respondsToSelector:@selector(updateLoadData)]){
//            [self.delegate updateLoadData];
//        }
        [self layoutIfNeeded];
//        // 解析失败了
    }];
}

-(void)setDisplayAttributedString:(NSMutableAttributedString *) attr label:(UILabel *) label guide:(BOOL)isGuide model:(SobotChatMessage*)msgModel{

    UIColor *linkColor = [ZCUIKitTools zcgetChatLeftLinkColor];
    if(msgModel.sendType == 0){
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
            [attributedString addAttribute:NSForegroundColorAttributeName value:UIColorFromKitModeColor(SobotColorTextMain) range:range];
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

/**
 *  点击查看大图
 */
-(void) imgTouchUpInside:(UITapGestureRecognizer *)recognizer{
    UIImageView *picTempView = (UIImageView*)recognizer.view;
    CGRect f = [picTempView convertRect:picTempView.bounds toView:nil];
    UIImageView *bgView = [[UIImageView alloc] init];
    [bgView setImage:[self sobotImageWithColor:UIColor.blackColor]];
    // 设置尖角
    [bgView setFrame:f];
    CALayer *layer              = bgView.layer;
    layer.frame                 = (CGRect){{0,0},bgView.layer.frame.size};
        
    SobotImageView *newPicView = [[SobotImageView alloc] init];
    newPicView.image = picTempView.image;
    newPicView.frame = f;
    newPicView.layer.masksToBounds = NO;
    newPicView.layer.mask = layer;
    CALayer *calayer = newPicView.layer.mask;
    [newPicView.layer.mask removeFromSuperlayer];
   
    SobotXHImageViewer *xh = [[SobotXHImageViewer alloc]initWithImageViewersobotHxWillDismissWithSelectedViewBlock:^(SobotXHImageViewer *imageViewer, UIImageView *selectedView) {
        
    } sobotHxDidDismissWithSelectedViewBlock:^(SobotXHImageViewer *imageViewer, UIImageView *selectedView) {
        selectedView.layer.mask = calayer;
        [selectedView setNeedsDisplay];
        [selectedView removeFromSuperview];
    } sobotHxDidChangeToImageViewBlock:^(SobotXHImageViewer *imageViewer, UIImageView *selectedView) {
        
    }];
        
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    [photos addObject:newPicView];
    xh.delegate = self;
    xh.disableTouchDismiss = NO;
    [xh showWithImageViews:photos selectedView:newPicView];
}

- (UIImage *)sobotImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}



- (void)touchesEnded:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
}

// 链接点击
- (void)SobotEmojiLabel:(SobotEmojiLabel*)emojiLabel didSelectLink:(NSString*)link withType:(SobotEmojiLabelLinkType)type{
   [self doClickURL:link text:@""];
}

// 链接点击
-(void)doClickURL:(NSString *)url text:(NSString * )htmlText{
    if(url){
        url=[url stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        // 用户引导说辞的分类的点击事件
        NSString *leaveUpMsg = [NSString stringWithFormat:@"%@ %@",SobotKitLocalString(@"您的留言状态有"),SobotKitLocalString(@"更新")];
        leaveUpMsg = [leaveUpMsg stringByReplacingOccurrencesOfString:@" " withString:@" "];// 处理特殊空格国际化下字符串不相同的问题
        if ([sobotConvertToString(htmlText) hasSuffix:SobotKitLocalString(@"留言")] || [@"sobot://leavemessage" isEqual:url]) {
//            [self turnLeverMessageVC];
        }else if ([leaveUpMsg isEqual:url] || [SobotKitLocalString(@"更新") isEqual:url]){
//            [self turnLeverMsgRecordVC];
        }else if([url hasPrefix:@"sobot://newsessionchat"]){
//            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
//                [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeNewSession text:@"" obj:@""];
//            }
        }else if([url hasPrefix:@"sobot://insterTrunMsg"]){
//            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
//                [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeInsterTurn text:@"" obj:@""];
//            }
        }else if([url hasPrefix:@"sobot://resendleavemessage"]){
//            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
//                [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemResendLeaveMsg text:@"" obj:@""];
//            }
        }else if([url hasPrefix:@"sobot://continueWaiting"]){
//            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
//                [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemContinueWaiting text:@"" obj:@""];
//            }
        }else if([url hasPrefix:@"sobot://showallsensitive"]){
//            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
//                [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemShowallsensitive text:@"" obj:@""];
//            }
        }else if([url hasPrefix:@"sobot:"]){
//            int index = [[url stringByReplacingOccurrencesOfString:@"sobot://" withString:@""] intValue];
//            
//            if(index > 0 && self.tempModel.robotAnswer.suggestionList.count>=index){
//                if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
//                    [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemChecked text:@"" obj:self.tempModel.robotAnswer.suggestionList[index-1]];
//                }
//                return;
//            }
//            
//            if(index > 0 && self.tempModel.richModel.richContent.interfaceRetList.count>=index){
//                
//                // 单独处理对象
//                NSDictionary * dict = @{@"requestText": self.tempModel.richModel.richContent.interfaceRetList[index-1][@"title"],
//                                        @"question":[self getQuestion:self.tempModel.richModel.richContent.interfaceRetList[index-1]],
//                                        @"questionFlag":@"2",
//                                        @"title":self.tempModel.richModel.richContent.interfaceRetList[index-1][@"title"],
//                                        @"ishotguide":@"0"
//                                        };
//                if ([self getZCLibConfig].isArtificial) {
//                    dict = @{@"title":self.tempModel.richModel.richContent.interfaceRetList[index-1][@"title"],@"ishotguide":@"0"};
//                }
//                
//                if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
//                    [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemGuide text:@"" obj:dict];
//                }
//            }
            
            
        }else if ([url hasPrefix:@"robot:"]){
            // 处理 机器人回复的 技能组点选事件
            
//          3.0.8 如果当前 已转人工 ， 不可点击
//            if([self getZCLibConfig].isArtificial){
//                return;
//            }
//            
//            int index = [[url stringByReplacingOccurrencesOfString:@"robot://" withString:@""] intValue];
//            if(index > 0 && self.tempModel.robotAnswer.groupList.count>=index){
//                if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
//                    [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeGroupItemChecked text:@"" obj:[NSString stringWithFormat:@"%d",index-1]];
//                }
//            }
        }else if([url hasPrefix:@"zc_refresh_newdata"]){
//            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
//                [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeNewDataGroup text:@"" obj:url];
//            }
        }else{
            // 超链点击事件
            if(self.delegate && [self.delegate respondsToSelector:@selector(onViewEvent:dict:obj:)]){
                [self.delegate onViewEvent:ZCChatMessageInfoViewEventOpenUrl dict:@{} obj:sobotConvertToString(url)];
            }
        }
    }
}
@end
