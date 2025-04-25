//
//  ZCChatRichCell.m
//  SobotKit
//
//  Created by zhangxy on 2022/9/15.
//

#import "ZCChatRichCell.h"
#import "ZCUIKitTools.h"
#import <SobotChatClient/SobotChatClient.h>
#import "SobotHtmlFilter.h"
#import <SobotCommon/SobotXHCacheManager.h>
#define MidImageHeight 110

@interface ZCChatRichCell(){
    
}

// 聊天气泡里面的内容
@property(nonatomic,strong) UIView *chatConentView;
@property(nonatomic,strong) NSLayoutConstraint *layoutBottom;
@property(nonatomic,strong) NSLayoutConstraint *layoutHeight;
@property(nonatomic,strong) NSLayoutConstraint *layoutWidth;
@property(nonatomic,strong) UIView *lastView;
@property(nonatomic,strong) NSLayoutConstraint *linkLayoutHeight;

@property(nonatomic,strong) SobotImageView *loadView;
@property(nonatomic,strong) NSLayoutConstraint *loadViewH;
@property(nonatomic,strong) NSLayoutConstraint *loadViewW;
@end
@implementation ZCChatRichCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}



-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _chatConentView = [[UIView alloc] init];
        [self.contentView addSubview:_chatConentView];
        _chatConentView.userInteractionEnabled = YES;
        [self.contentView addConstraint:sobotLayoutPaddingTop(ZCChatPaddingVSpace, _chatConentView, self.ivBgView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingHSpace, _chatConentView, self.ivBgView)];
        _layoutBottom = sobotLayoutMarginBottom(-ZCChatCellItemSpace, _chatConentView, self.lblSugguest);
        [self.contentView addConstraint:_layoutBottom];
        _layoutWidth = sobotLayoutEqualWidth(0, _chatConentView, NSLayoutRelationEqual);
        [self.contentView addConstraint:_layoutWidth];
//        [self createLoadView];
    }
    return self;
}

-(void)createLoadView{
    _loadView = ({
        SobotImageView *iv = [[SobotImageView alloc] init];
        [_chatConentView addSubview:iv];
        [_chatConentView addConstraint:sobotLayoutEqualCenterY(0, iv, _chatConentView)];
        self.loadViewW = sobotLayoutEqualWidth(19, iv, NSLayoutRelationEqual);
        [_chatConentView addConstraint:self.loadViewW];
        self.loadViewH = sobotLayoutEqualHeight(3.5, iv, NSLayoutRelationEqual);
        [_chatConentView addConstraint:self.loadViewH];
        [_chatConentView addConstraint:sobotLayoutPaddingLeft(0, iv, _chatConentView)];
        NSBundle *sBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"SobotKit" ofType:@"bundle"]];
        NSString  *filePath = [sBundle pathForResource:@"Light/zcicon_writering_animate" ofType:@"gif"];
        NSData  *imageData = [NSData dataWithContentsOfFile:filePath];
        [iv setImage:[SobotImageTools sobotAnimatedGIFWithData:imageData]];
        iv;
    });
}

-(void)initDataToView:(SobotChatMessage *) message time:(NSString *) showTime{
    [super initDataToView:message time:showTime];
    _lastView = nil;
    _loadView.hidden = YES;
    [_chatConentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGSize s = [self addRichView:message width:self.maxWidth with:_chatConentView msgLabel:nil];
    if(_lastView){
        [_chatConentView addConstraint:sobotLayoutPaddingBottom(0, _lastView, _chatConentView)];
        [_chatConentView layoutIfNeeded];
        s.height = CGRectGetMaxY(_lastView.frame);
    }
    if(s.width > (self.maxWidth)){
        s.width = self.maxWidth;
    }else{
        // 最大宽度应该+20，chatContentView，需要留有左右边距
        s.width = s.width;
    }
    
//    if (sobotConvertToString(message.aiAgentCid).length >0) {
//        if (s.width == 0) {
//        [self createLoadView];
//            _lastView.hidden = NO;
//            s.width = 19;
//            _loadViewW.constant = 19;
//            _loadViewH.constant = 3.5;
//            s.height = 22;
//        }else{
//            _loadView.hidden = YES;
//            _loadViewW.constant = 0;
//            _loadViewH.constant = 0;
//        }
//    }
    
    // 需要设置宽度，否则无法点击
    _layoutWidth.constant = s.width;
    if(s.height == 0){
        _layoutBottom.constant = 0;
    }
    
    [_chatConentView layoutIfNeeded];
    [self setChatViewBgState:s];
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
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark - 创建子控件
-(CGSize )addRichView:(SobotChatMessage *) model width:(CGFloat ) maxWidth with:(UIView *) superView msgLabel:(SobotEmojiLabel *) richLabel{
//    CGFloat lineSpace = [ZCUIKitTools zcgetChatLineSpacing];
    CGFloat imgHeight = MidImageHeight;
    // 自己发送的消息，当前认定为敏感信息
    if(model.includeSensitive > 0 && model.senderType == 0){
        return [self getAuthSensitiveView:model width:maxWidth with:superView msgLabel:richLabel];
    }
    
    // 记录实际最大宽度
    CGFloat contentWidth = 0;
    
    if(sobotIsNull(model) || sobotIsNull(model.richModel) || sobotIsNull(model.richModel.richList) || (model.richModel.richList !=nil && [model.richModel.richList isKindOfClass:[NSArray class]] && model.richModel.richList.count == 0)){
        #pragma mark 标题+内容
        NSString *text = @"";
        if(!self.isRight){
            if (!sobotIsNull(model)&& !sobotIsNull(model.richModel) && !sobotIsNull(model.richModel.richContent) && model.richModel.richContent.templateId == 4 && model.displayMsgAttr==nil) {
                text = sobotConvertToString([model getModelDisplayText:YES]);
            }else{
                text = sobotConvertToString([model getModelDisplayText]);
            }
            // 3.0.9兼容旧版本机器人语音显示空白问题
            if(sobotConvertToString(text).length == 0 && sobotConvertToString(model.richModel.msgtranslation).length > 0){
                text = sobotConvertToString(model.richModel.msgtranslation);
            }
        }else{
            text = sobotConvertToString(model.richModel.content);
        }
        
        if(text.length > 0){
            SobotChatRichContent *content = [[SobotChatRichContent alloc] init];
            // 这里不再过滤html标签，展示纯文本的数据  也就是用户侧发送内容都是纯文本的消息展示 有html标签展示html标签
            if(self.isRight){
                // 如果是人机问答接口的
                content.msg = text;
//                content.attr = nil; // 不再做html格式转换
            }else{
                content.msg = text;
                content.attr = model.displayMsgAttr;
            }
            // 这里需要处理 最大宽度 maxWidth
            contentWidth = [self addText:content view:_chatConentView maxWidth:maxWidth showType:1 lastMsg:YES];
        }
    }else{
        // {type:0,1,2,3,msg:}
        // 富文本数组:0：文本，1：图片，2：音频，3：视频，4：文件
        if([[ZCLibClient sobotGetSDKChannel] isEqual:@"ZhiChiSobotUni"]){
            NSString *msg = [self getUniDisplayString:model.richModel.richList];
            SobotChatRichContent *content = [[SobotChatRichContent alloc] init];
            content.msg = msg;
            CGFloat contentWidth1 = [self addText:content view:_chatConentView maxWidth:maxWidth showType:1 lastMsg:YES];
            if(contentWidth < contentWidth1){
                contentWidth = contentWidth1;
            }
        }else{
            for (int i=0;i<model.richModel.richList.count;i++) {
                SobotChatRichContent *item =  model.richModel.richList[i];
                SobotMessageType type = item.type;
                // 0文本,1图片,2音频,3视频,4文件,5对象
                NSString *msg = sobotConvertToString(item.msg);
                if([@"<br>" isEqual:sobotTrimString(msg)] || [@"<br/>" isEqual:msg]){
                    continue;
                }
                
                if(type == 0){
                    if(self.isRight && model.richModel.richList.count == 1){
                        item.msg = sobotConvertToString(model.richModel.content);
                        item.attr = nil;
                    }
                    int showType = [sobotConvertToString(item.showType) intValue];
                    CGFloat contentWidth1 = [self addText:item view:_chatConentView maxWidth:maxWidth showType:showType lastMsg:i == (model.richModel.richList.count-1)];
                    if(contentWidth < contentWidth1){
                        contentWidth = contentWidth1;
                    }
                }
                // 图片和视频
                if(type == 1 || type == 3){
                    // 2：音频，3：视频，4：文件
                    if(!sobotIsUrl(msg,[ZCUIKitTools zcgetUrlRegular])){
                        continue;
                    }
                    
                    if(contentWidth < maxWidth){
                        contentWidth = maxWidth;
                    }
                    
                    SobotImageView *imgView = [[SobotImageView alloc] init];
                    [imgView setContentMode:UIViewContentModeScaleAspectFill];
//                    [imgView.layer setCornerRadius:4.0f];
//                    [imgView.layer setMasksToBounds:YES];
                    UITapGestureRecognizer *tapGesturer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgTouchUpInside:)];
                    imgView.userInteractionEnabled=YES;
                    [imgView addGestureRecognizer:tapGesturer];
                    [superView addSubview:imgView];
                    NSLayoutConstraint *layoutImgH = sobotLayoutEqualHeight(imgHeight, imgView, NSLayoutRelationEqual);
                    [superView addConstraint:sobotLayoutEqualWidth(maxWidth, imgView, NSLayoutRelationEqual)];
                    [superView addConstraint:layoutImgH];
                    [superView addConstraint:sobotLayoutPaddingLeft(0, imgView, superView)];
                    [imgView setBackgroundColor:UIColorFromKitModeColor(SobotColorBgTopLine)];
                    if(_lastView){
                        [superView addConstraint:sobotLayoutMarginTop(ZCChatCellItemSpace*2, imgView, _lastView)];
                    }else{
                        [superView addConstraint:sobotLayoutPaddingTop(0, imgView, superView)];
                    }
                    
                    if(type == 3){
                        NSString *imgUrl = sobotConvertToString(item.snapshot);
                        if (imgUrl.length == 0) {
                            imgUrl = sobotConvertToString(item.videoImgUrl);
                        }
                        if (imgUrl.length == 0) {
                            // 网络占位图
                            imgUrl = @"https://img.sobot.com/chat/common/res/83f5636f-51b7-48d6-9d63-40eba0963bda.png";
                        }
                        UIImage *cacheImage = [SobotXHCacheManager imageWithURL:[NSURL URLWithString:sobotConvertToString(imgUrl)] storeMemoryCache:YES];
                        if (!sobotIsNull(cacheImage)) {
                            [imgView setImage:cacheImage];
                            [self resizeImageFrame:imgView layout:layoutImgH maxW:maxWidth img:cacheImage isSend:NO];
                        }else{
                            if ([[ZCUICore getUICore] isHasUserWithUrl:sobotConvertToString(imgUrl)]) {
                                [self setMaxPlacHoldImgMaxW:maxWidth imgView:imgView layout:layoutImgH isShow:YES];
                            }else{
                                [imgView loadWithURL:[NSURL URLWithString:sobotConvertToString(imgUrl)] placeholer:nil showActivityIndicatorView:YES completionBlock:^(UIImage * _Nonnull image, NSURL * _Nonnull url, NSError * _Nonnull error) {
                                    if (sobotIsNull(image)) {
                                        [[ZCUICore getUICore] addUrlToTempImageArray:sobotConvertToString(imgUrl)];
                                        
                                    }
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [[NSNotificationCenter defaultCenter] postNotificationName:@"SOBOTCHATPHOTCELLUPDATE" object:nil userInfo:@{@"indexPath":self.indexPath}];
                                    });
                                }];
                            }
                                
                        }
                    }else{
                       // 先看缓存有没有
                    UIImage *cacheImage = [SobotXHCacheManager imageWithURL:[NSURL URLWithString:msg] storeMemoryCache:YES];
                    if (!sobotIsNull(cacheImage)) {
                        [imgView setImage:cacheImage];
                        [self resizeImageFrame:imgView layout:layoutImgH maxW:maxWidth img:cacheImage isSend:NO];
                    }else{
                        if ([[ZCUICore getUICore] isHasUserWithUrl:sobotConvertToString(msg)]) {
                            [self setMaxPlacHoldImgMaxW:maxWidth imgView:imgView layout:layoutImgH isShow:YES];
                        }else{
                            [imgView loadWithURL:[NSURL URLWithString:msg] placeholer:nil showActivityIndicatorView:YES completionBlock:^(UIImage * _Nonnull image, NSURL * _Nonnull url, NSError * _Nonnull error) {
                                if (sobotIsNull(image)) {
                                    [[ZCUICore getUICore] addUrlToTempImageArray:sobotConvertToString(msg)];
                                    
                                }
                                dispatch_async(dispatch_get_main_queue(), ^{
//                                    NSLog(@"加载完了 去刷新通知 url= %@",url);
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"SOBOTCHATPHOTCELLUPDATE" object:nil userInfo:@{@"indexPath":self.indexPath}];
                                });
                            }];
                        }
                    }
                    }
                    _lastView = imgView;
                    
                    if(type == 3){
//                        [imgView loadWithURL:[NSURL URLWithString:@"https://img.sobot.com/chat/common/res/83f5636f-51b7-48d6-9d63-40eba0963bda.png"] placeholer:SobotKitGetImage(@"zcicon_default_goods_1") showActivityIndicatorView:NO completionBlock:^(UIImage * _Nonnull image, NSURL * _Nonnull url, NSError * _Nonnull error) {
//                            dispatch_async(dispatch_get_main_queue(), ^{
//                                [self resizeImageFrame:imgView layout:layoutImgH maxW:maxWidth img:image isSend:NO];
//                            });
//                        }];
                        // 设置一个特殊的tag，不支持点击查看大图
                        imgView.tag = 101;
                        SobotButton *_playButton = [SobotButton buttonWithType:UIButtonTypeCustom];
                        _playButton.obj = item;
                        [_playButton setImage:SobotKitGetImage(@"zcicon_video_play") forState:0];
                        [_playButton setBackgroundColor:UIColor.clearColor];
                        [superView addSubview:_playButton];
                        [_playButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
                        
                        [superView addConstraints:sobotLayoutSize(30, 30, _playButton, NSLayoutRelationEqual)];
                        [superView addConstraint:sobotLayoutEqualCenterX(0, _playButton, imgView)];
                        [superView addConstraint:sobotLayoutEqualCenterY(0, _playButton, imgView)];
                    }
                }
                // 文件和音频
                if(type == 4 || type == 2) {
                    CGSize s = CGSizeMake(maxWidth, 70);
                    if(contentWidth < s.width){
                        contentWidth = s.width;
                    }
                    // 文件
                    UIView *bgView = [[UIView alloc]init];
                    bgView.backgroundColor = UIColorFromModeColor(SobotColorBgMainDark3);
                    bgView.layer.cornerRadius = 4;
                    bgView.layer.masksToBounds = YES;
                    [superView addSubview:bgView];
                    
                    [superView addConstraint:sobotLayoutPaddingLeft(0, bgView, superView)];
                    [superView addConstraints:sobotLayoutSize(s.width, s.height, bgView, NSLayoutRelationEqual)];
                    if(_lastView){
                        [superView addConstraint:sobotLayoutMarginTop(ZCChatCellItemSpace*2, bgView, _lastView)];
                    }else{
                        [superView addConstraint:sobotLayoutPaddingTop(0, bgView, superView)];
                    }
                    _lastView = bgView;
                    
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
                    titleLab.font = SobotFont14;
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
                    [objBtn addTarget:self action:@selector(urlClick:) forControlEvents:UIControlEventTouchUpInside];
                    [bgView addConstraint:sobotLayoutPaddingLeft(0, objBtn, bgView)];
                    [bgView addConstraint:sobotLayoutPaddingLeft(0, objBtn, bgView)];
                    [bgView addConstraints:sobotLayoutSize(s.width, s.height, objBtn, NSLayoutRelationEqual)];
                }
            }
        }
    }
    
    return CGSizeMake(contentWidth, CGRectGetMaxY(_lastView.frame));
}


-(void)resizeImageFrame:(SobotImageView *) imgView layout:(NSLayoutConstraint *) layoutH maxW:(CGFloat )maxW img:(UIImage *)imgData isSend:(BOOL)isSend{
    if(!self || !imgView ){
        return;
    }
    UIImage *img = imgData;
    if(img){
//        if(maxW > self.maxWidth - ZCChatPaddingHSpace*2){
//            maxW = self.maxWidth - ZCChatPaddingHSpace*2;
//        }
        
        CGSize s = img.size;
        CGFloat w = s.width;
        CGFloat h = s.height;
        if(s.width < maxW){
            w = maxW;
            h = maxW * s.height / s.width;
        }
        
        if(s.width > maxW){
            w = maxW;
            h = maxW * s.height / s.width;
        }
        
        
        layoutH.constant = h;
        
//        CGSize size = CGSizeMake(maxW + ZCChatPaddingHSpace*2, CGRectGetMaxY(_lastView.frame));
        
        // 需要设置宽度，否则无法点击
//        _layoutWidth.constant = maxW + ZCChatPaddingHSpace*2;
    }
}

-(void)setMaxPlacHoldImgMaxW:(CGFloat )maxW imgView:(UIImageView *)imgView layout:(NSLayoutConstraint *) layoutH isShow:(BOOL)isShow{
    if(maxW > self.maxWidth - ZCChatPaddingHSpace*2){
        maxW = self.maxWidth - ZCChatPaddingHSpace*2;
    }
    if (isShow) {
        UIImageView *plView = [[UIImageView alloc]init];
        [imgView addSubview:plView];
        [plView setImage:SobotKitGetImage(@"zcicon_default_placeholer_image")];
        [imgView addConstraints:sobotLayoutSize(50, 40, plView, NSLayoutRelationEqual)];
        [imgView addConstraint:sobotLayoutEqualCenterX(0, plView, imgView)];
        [imgView addConstraint:sobotLayoutEqualCenterY(0, plView, imgView)];
    }
//    CGFloat w = maxW;
    CGFloat h = MidImageHeight;
    layoutH.constant = h;
//    [_chatConentView layoutIfNeeded];
//    [self.contentView layoutIfNeeded];
    CGSize size = CGSizeMake(maxW + ZCChatPaddingHSpace*2, CGRectGetMaxY(_lastView.frame));
    // 需要设置宽度，否则无法点击
    _layoutWidth.constant = size.width;
    [_chatConentView layoutIfNeeded];
    [self setChatViewBgState:size];
}

#pragma mark - 文件点击事件
-(void)flieClickAction:(SobotButton *)sender{
    NSDictionary *item = (NSDictionary *)(sender.obj);
    
    if ([sobotConvertToString([item objectForKey:@"type"]) intValue] == 4) {
        self.tempModel.richModel.richmoreurl = sobotConvertToString([item objectForKey:@"msg"]);
        self.tempModel.richModel.url = sobotConvertToString([item objectForKey:@"msg"]);
        self.tempModel.richModel.fileSize = sobotConvertToString([item objectForKey:@"fileSize"]);
        self.tempModel.richModel.fileName = sobotConvertToString([item objectForKey:@"name"]);
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
            [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeOpenFile text:sobotConvertToString([item objectForKey:@"msg"]) obj:sobotConvertToString([item objectForKey:@"msg"])];
        }
    }else if([sobotConvertToString([item objectForKey:@"type"]) intValue] == 2){
        if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
            [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeOpenAudio text:sobotConvertToString([item objectForKey:@"msg"]) obj:sobotConvertToString([item objectForKey:@"msg"])];
        }
    }
}


-(NSString *)getUniDisplayString:(NSArray *) arr{
    NSString *text = @"";
    for (int i=0;i<arr.count;i++) {
        NSDictionary *item =  arr[i];
//        int type = [item[@"type"] intValue];
        
        NSString *msg = sobotConvertToString(item[@"msg"]);
        msg = [SobotHtmlCore filterHTMLTag:msg];
        msg = [ZCUIKitTools removeAllHTMLTag:msg];
        
        text = [NSString stringWithFormat:@"%@%@",text,msg];
    }
    while ([text hasPrefix:@"\n"]){
        text = [text substringFromIndex:1];
    }
    
    if ([text hasSuffix:@"\n"]){
        text = [text substringToIndex:text.length - 1];
    }
    return text;
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
//    text = @"阿伺服电机暗室逢灯时代峰峻卡算法发生客户水电费看哈世纪东方哈开个会电饭锅SDK啊就是导航饭卡是否打开拉黑速度快发货撒地方哈弗卡的很国风大赏咖啡馆哈第三方是否打开哈士大夫哈里斯的国风大赏时代峰峻奥克斯的附近啊是的发伺服电机是打发时间大法师打发";
    CGFloat contentWidth = maxWidth - 20;
    if(!richLabel){
        richLabel = [ZCChatBaseCell createRichLabel];
    }
    [superView addSubview:richLabel];
    [richLabel setTextColor:UIColorFromModeColor(SobotColorTextSub)];
    [richLabel setText:text];
    CGSize s = [richLabel preferredSizeWithMaxWidth:contentWidth - 20];
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

-(CGFloat )addText:(SobotChatRichContent *)item view:(UIView *) superView maxWidth:(CGFloat ) cMaxWidth showType:(int )showType lastMsg:(BOOL )isLast{
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
    
    SobotEmojiLabel *tipLabel = [ZCChatBaseCell createRichLabel];
    tipLabel.delegate = self;
    UIColor *textColor = [ZCUIKitTools zcgetLeftChatTextColor];
    UIColor *linkColor = [ZCUIKitTools zcgetChatLeftLinkColor];
    if([self isRight]){
        textColor = [ZCUIKitTools zcgetRightChatTextColor];
        linkColor = [ZCUIKitTools zcgetChatRightlinkColor];
    }
    [tipLabel setTextColor:textColor];
    [tipLabel setLinkColor:linkColor];
    if([ZCUIKitTools getSobotIsRTLLayout]){
        tipLabel.textAlignment = NSTextAlignmentRight;
    }else{
        tipLabel.textAlignment = NSTextAlignmentLeft;
    }
    [superView addSubview:tipLabel];
    
    if(!sobotIsNull(item.name) && sobotConvertToString(item.name).length > 0 && sobotIsUrl(text,[ZCUIKitTools zcgetUrlRegular])){
//        if(sobotIsUrl(item.name, [ZCUIKitTools zcgetUrlRegular])){
//            item.name = [[NSString stringWithFormat:@"\%@",item.name] uppercaseString];
//        }
        [tipLabel setText:[SobotHtmlCore filterHTMLTag:sobotConvertToString(item.name)]];
        [tipLabel addLinkToURL:[NSURL URLWithString:sobotConvertToString(text)] withRange:NSMakeRange(0, [SobotHtmlCore filterHTMLTag:sobotConvertToString(item.name)].length)];
    }else{
        if(!sobotIsNull(attrString) && !self.isRight){
            [self setDisplayAttributedString:attrString label:tipLabel guide:NO];
        }else{
            // 最后一行过滤所有换行，不是最后一行过滤一个换行
            if(isLast){
                while ([text hasSuffix:@"\n"]){
                    text = [text substringToIndex:text.length - 1];
                }
            }
            text = [SobotHtmlCore filterHTMLTag:text];
            if(!self.isRight){
                text = [ZCUIKitTools removeAllHTMLTag:text];
            }
            tipLabel.text = text;
        }
    }
    CGSize s2 = [tipLabel preferredSizeWithMaxWidth:cMaxWidth];
    
    [superView addConstraints:sobotLayoutSize(s2.width, s2.height, tipLabel, NSLayoutRelationEqual)];
    [superView addConstraint:sobotLayoutPaddingLeft(0,tipLabel, superView)];
    if(_lastView){
        [superView addConstraint:sobotLayoutMarginTop(ZCChatCellItemSpace*2, tipLabel, _lastView)];
    }else{
        [superView addConstraint:sobotLayoutPaddingTop(0, tipLabel, superView)];
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
        [superView addConstraint:sobotLayoutPaddingTop(0, linkBgView, tipLabel)];
//        [superView addConstraint:sobotLayoutMarginTop([ZCUIKitTools zcgetChatLineSpacing], linkBgView, tipLabel)];
        [superView addConstraint:sobotLayoutPaddingLeft(0,linkBgView, superView)];
        
        _linkLayoutHeight = sobotLayoutEqualHeight(90, linkBgView, NSLayoutRelationEqual);
        [superView addConstraint:sobotLayoutEqualWidth(links.width, linkBgView, NSLayoutRelationEqual)];
        [superView addConstraint:_linkLayoutHeight];
        
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
        [superView addConstraint:sobotLayoutEqualHeight(22, linktitleLab, NSLayoutRelationEqual)];
        NSLayoutConstraint *rightTitle = sobotLayoutPaddingRight(-15, linktitleLab, linkBgView);
        [linkBgView addConstraint:rightTitle];
        [linkBgView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingVSpace, linktitleLab, linkBgView)];
        [linkBgView addConstraint:sobotLayoutPaddingTop(12, linktitleLab, linkBgView)];
        
        SobotImageView *icon = [[SobotImageView alloc]init];
        [icon loadWithURL:[NSURL URLWithString:@""] placeholer:SobotKitGetImage(@"zcicon_url_icon") showActivityIndicatorView:NO];
        [linkBgView addSubview:icon];
        [superView addConstraints:sobotLayoutSize(40,40, icon, NSLayoutRelationEqual)];
        [linkBgView addConstraint:sobotLayoutPaddingRight(-ZCChatPaddingVSpace, icon, linkBgView)];
        
        NSLayoutConstraint *iconTop = sobotLayoutMarginTop(ZCChatCellItemSpace, icon, linktitleLab);
        [linkBgView addConstraint:iconTop];
//        [linkBgView addConstraint:sobotLayoutPaddingBottom(-12, icon, linkBgView)];// 去掉多余约束
        
        // 超链链接
        UILabel *linkdescLab = [[UILabel alloc]init];
        linkdescLab.font = SobotFont12;
        linkdescLab.textColor = UIColorFromModeColor(SobotColorTextSub);
        linkdescLab.numberOfLines = 2;
        [linkBgView addSubview:linkdescLab];
        [superView addConstraint:sobotLayoutEqualHeight(20, linktitleLab, NSLayoutRelationGreaterThanOrEqual)];
        [linkBgView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingVSpace, linkdescLab, linkBgView)];
        
        NSLayoutConstraint *descTop = sobotLayoutMarginTop(ZCChatCellItemSpace, linkdescLab, linktitleLab);

        [linkBgView addConstraint:descTop];
        [linkBgView addConstraint:sobotLayoutMarginRight(-ZCChatCellItemSpace, linkdescLab, icon)];
        
        [self setLinkValues:text titleLabel:linktitleLab desc:linkdescLab imgView:icon superView:superView linkBgView:linkBgView name:sobotConvertToString(item.name)];
//        [self setLinkValues:text titleLabel:linktitleLab desc:linkdescLab imgView:icon];
        
        [self getLinkValues:text name:sobotConvertToString(item.name) result:^(NSString * _Nonnull title, NSString * _Nonnull desc, NSString * _Nonnull iconUrl) {
            if(title.length > 0){
                linktitleLab.text = sobotConvertToString(title);
                linkdescLab.text = sobotConvertToString(desc);
                self->_linkLayoutHeight.constant = 90;
                [icon loadWithURL:[NSURL URLWithString:sobotConvertToString(iconUrl)] placeholer:SobotKitGetImage(@"zcicon_url_icon") showActivityIndicatorView:NO];
            }else{
                linktitleLab.text = sobotConvertToString(text);
                linkdescLab.hidden = YES;
                descTop.constant = 0;
                self->_linkLayoutHeight.constant = 64;
                [linkBgView removeConstraint:iconTop];
                [linkBgView addConstraint:sobotLayoutPaddingTop(0, icon, linktitleLab)];
                
                [linkBgView removeConstraint:rightTitle];
                [linkBgView addConstraint:sobotLayoutMarginRight(-15, linktitleLab, icon)];
                
                [icon loadWithURL:[NSURL URLWithString:sobotConvertToString(iconUrl)] placeholer:SobotKitGetImage(@"zcicon_url_icon") showActivityIndicatorView:NO];
            }
        }];
        
      
        if(cMaxWidth < links.width){
            cMaxWidth = links.width;
        }
        _lastView = linkBgView;
        
        return cMaxWidth;
    }
    
    _lastView = tipLabel;
    
    return s2.width;
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
//            if (sobotConvertToString([data objectForKey:@"title"]).length == 0 &&
//                sobotConvertToString([data objectForKey:@"desc"]).length == 0 &&
//                sobotConvertToString([data objectForKey:@"imgUrl"]).length == 0) {
//
//            }else{
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
            [icon loadWithURL:[NSURL URLWithString:imgUrl] placeholer:SobotKitGetImage(@"zcicon_url_icon") showActivityIndicatorView:YES];
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

