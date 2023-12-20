//
//  ZCChatReferenceRichCell.m
//  SobotKit
//
//  Created by zhangxy on 2023/11/24.
//

#import "ZCChatReferenceRichCell.h"
#import "ZCVideoPlayer.h"

@interface  ZCChatReferenceRichCell()<SobotXHImageViewerDelegate>

// 富文本图片、视频、音频、超链接
@property(nonatomic,strong) SobotButton *btnPlay;
@property (nonatomic,strong) SobotImageView *ivPicture;

// 链接和文章
@property (nonatomic,strong) SobotImageView *imgLeft;   // 文章图片在左边
@property (strong, nonatomic) UILabel *labTitle; //链接标题，文章名称
@property (strong, nonatomic) UILabel *labDesc; //链接描述,文件大小
@property (nonatomic,strong) SobotImageView *imgRight;  // 链接图片再右边


@property (strong, nonatomic) NSLayoutConstraint *layoutLeftW;
@property (strong, nonatomic) NSLayoutConstraint *layoutLeftH;
// 整个view的高度
@property (strong, nonatomic) NSLayoutConstraint *layoutLeftTop;

@property (strong, nonatomic) NSLayoutConstraint *layoutRightTop;
@property (strong, nonatomic) NSLayoutConstraint *layoutRightW;
@property (strong, nonatomic) NSLayoutConstraint *layoutRightH;

@property (strong, nonatomic) NSLayoutConstraint *layoutTitleTop;
@property (strong, nonatomic) NSLayoutConstraint *layoutTitleL;
@property (strong, nonatomic) NSLayoutConstraint *layoutTitleR;

@property (strong, nonatomic) NSLayoutConstraint *layoutDescTop;
@property (strong, nonatomic) NSLayoutConstraint *layoutDescBtm;

@property (strong, nonatomic) NSLayoutConstraint *layoutPictureH;
@property (strong, nonatomic) NSLayoutConstraint *layoutPictureW;

@end

@implementation ZCChatReferenceRichCell

-(void)layoutSubViewUI{
    [super layoutSubViewUI];
    // 移除viewcontent的所有子view
    [self.viewContent.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.viewContent.layer.masksToBounds = YES;
    self.viewContent.layer.cornerRadius = 2.0f;
    
    _ivPicture = ({
        SobotImageView *iv = [[SobotImageView alloc] init];
        [iv setContentMode:UIViewContentModeScaleAspectFill];
        [iv.layer setMasksToBounds:YES];
        [iv setBackgroundColor:UIColorFromKitModeColorAlpha(SobotColorWhite, 0.14)];
        iv.layer.cornerRadius = 4.0f;
        iv.layer.masksToBounds = YES;
        [self.viewContent addSubview:iv];
        iv.userInteractionEnabled = YES;
        
        [self.viewContent addConstraint:sobotLayoutPaddingTop(0, iv, self.viewContent)];
        [self.viewContent addConstraint:sobotLayoutPaddingLeft(0, iv, self.viewContent)];
        _layoutPictureH = sobotLayoutEqualHeight(70, iv, NSLayoutRelationEqual);
        [self.viewContent addConstraint:_layoutPictureH];
        [self.viewContent addConstraint:sobotLayoutEqualWidth(70, iv, NSLayoutRelationEqual)];
        iv;
    });
    _btnPlay = ({
        SobotButton *iv = [SobotButton buttonWithType:UIButtonTypeCustom];
        [iv setImage:SobotKitGetImage(@"zcicon_video_play") forState:0];
        [iv setBackgroundColor:UIColor.clearColor];
        [self.viewContent addSubview:iv];
        iv.hidden = YES;
        [self.viewContent addConstraints:sobotLayoutSize(70, 70, iv, NSLayoutRelationEqual)];
        [self.viewContent addConstraint:sobotLayoutEqualCenterX(0, iv, _ivPicture)];
        [self.viewContent addConstraint:sobotLayoutEqualCenterY(0, iv, _ivPicture)];
//        iv.imageView.contentMode = UIViewContentModeScaleAspectFill;
        iv;
    });
    
    
    _imgLeft = ({
        SobotImageView *iv = [[SobotImageView alloc] init];
        iv.layer.masksToBounds = YES;
        iv.contentMode = UIViewContentModeScaleAspectFill;
        iv.layer.cornerRadius = 4.0f;
        //设置点击事件
//        iv.userInteractionEnabled=YES;
        [self.viewContent addSubview:iv];
        _layoutLeftW = sobotLayoutEqualWidth(21, iv, NSLayoutRelationEqual);
        _layoutLeftH = sobotLayoutEqualHeight(25, iv, NSLayoutRelationEqual);
        _layoutLeftTop = sobotLayoutMarginTop(10, iv, self.ivPicture);
        [self.viewContent addConstraint:_layoutLeftH];
        [self.viewContent addConstraint:_layoutLeftW];
        [self.viewContent addConstraint:_layoutLeftTop];
        [self.viewContent addConstraint:sobotLayoutPaddingLeft(10, iv, self.viewContent)];
        iv;
    });
    
    
    _imgRight = ({
        SobotImageView *iv = [[SobotImageView alloc] init];
        iv.layer.masksToBounds = YES;
        iv.contentMode = UIViewContentModeScaleAspectFill;
        iv.layer.cornerRadius = 4.0f;
        //设置点击事件
//        iv.userInteractionEnabled=YES;
        [self.viewContent addSubview:iv];
        _layoutRightW = sobotLayoutEqualWidth(20, iv, NSLayoutRelationEqual);
        _layoutRightH = sobotLayoutEqualHeight(20, iv, NSLayoutRelationEqual);
        _layoutRightTop = sobotLayoutMarginTop(10, iv, self.ivPicture);
        [self.viewContent addConstraint:_layoutRightW];
        [self.viewContent addConstraint:_layoutRightH];
        [self.viewContent addConstraint:sobotLayoutPaddingRight(-10, iv, self.viewContent)];
        [self.viewContent addConstraint:_layoutRightTop];
        iv;
    });
    
    _labTitle = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
//        iv.userInteractionEnabled=YES;
        iv.font = SobotFontBold14;
        iv.textColor = UIColorFromModeColor(SobotColorTextMain);
        iv.numberOfLines = 1;
        [self.viewContent addSubview:iv];
        _layoutTitleTop = sobotLayoutMarginTop(10, iv, self.ivPicture);
        [self.viewContent addConstraint:_layoutTitleTop];
        _layoutTitleL = sobotLayoutMarginLeft(0, iv, self.imgLeft);
        _layoutTitleR = sobotLayoutMarginRight(0, iv, self.imgRight);
        [self.viewContent addConstraint:_layoutTitleL];
        [self.viewContent addConstraint:_layoutTitleR];
        iv;
    });
    
    _labDesc = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
//        iv.userInteractionEnabled=YES;
        iv.font = SobotFont12;
        iv.textColor = UIColorFromModeColor(SobotColorTextSub);
        [self.viewContent addSubview:iv];
        _layoutDescTop = sobotLayoutMarginTop(10, iv, self.labTitle);
        [self.viewContent addConstraint:_layoutDescTop];
        [self.viewContent addConstraint:sobotLayoutPaddingLeft(0, iv, self.labTitle)];
        [self.viewContent addConstraint:sobotLayoutPaddingRight(0, iv, self.labTitle)];
        _layoutDescBtm = sobotLayoutPaddingBottom(0, iv, self.viewContent);
        [self.viewContent addConstraint:_layoutDescBtm];
        iv;
    });
    
    self.viewContent.userInteractionEnabled=YES;
    //设置点击事件
    UITapGestureRecognizer *tapGesturer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bgViewClick:)];
    [self.ivPicture addGestureRecognizer:tapGesturer];
    
}

-(void)bgViewClick:(UITapGestureRecognizer *) tap{
    if(!self.ivPicture.hidden){
        [self imgTouchUpInside:nil];
    }else{
        [self viewEvent:ZCChatReferenceCellEventOpen state:0 obj:@""];
    }
}


-(void)dataToView:(SobotChatMessage *)message{
    [super dataToView:message];
    
    NSString *text1 = @"";
    NSString *text2 = @"";
    BOOL isAddViews = NO;
    CGFloat contentW = 0;
    _layoutLeftTop.constant = 0;
    _layoutRightTop.constant = 0;
    _layoutLeftH.constant = 0;
    _layoutLeftW.constant = 0;
    
    _layoutRightH.constant = 0;
    _layoutRightW.constant = 0;
    
    _layoutPictureH.constant = 0;
    _layoutPictureW.constant = 0;
    _layoutTitleTop.constant = 0;
    _btnPlay.hidden = YES;
    
    _layoutTitleTop.constant = 0;
    _layoutTitleL.constant = 0;
    _layoutTitleR.constant = 0;
    _layoutDescTop.constant = 0;
    _layoutDescBtm.constant = 0;
    
    self.viewContent.backgroundColor = UIColor.clearColor;
    self.viewContent.tag = 0;
    if(self.tempMessage.richModel.richList==nil || [self.tempMessage.richModel.richList isKindOfClass:[NSNull class]] ||![self.tempMessage.richModel.richList isKindOfClass:[NSMutableArray class]] || (self.tempMessage.richModel.richList !=nil && [self.tempMessage.richModel.richList isKindOfClass:[NSMutableArray class]] && self.tempMessage.richModel.richList.count == 0)){
        if(self.tempMessage.senderType == 0){
            if (!sobotIsNull(self.tempMessage.richModel) && !sobotIsNull(self.tempMessage.richModel.richContent) && self.tempMessage.richModel.richContent.templateId == 4 && self.tempMessage.displayMsgAttr==nil) {
                text1 = sobotConvertToString([self.tempMessage getModelDisplayText:YES]);
            }else{
                text1 = sobotConvertToString([self.tempMessage getModelDisplayText]);
            }
        }else{
            text1 = message.richModel.content;
        }
    }else{
        
#pragma mark 标题+内容
        for (int i=0;i<self.tempMessage.richModel.richList.count;i++) {
            SobotChatRichContent *item =  self.tempMessage.richModel.richList[i];
            SobotMessageType type = item.type;
            // 0文本,1图片,2音频,3视频,4文件,5对象
            if(type!=SobotMessageTypeText){
                isAddViews = YES;
                if(type == SobotMessageTypeVideo || type == SobotMessageTypePhoto){
                    if(type == SobotMessageTypePhoto){
                        if(!sobotIsUrl(sobotConvertToString(item.msg), [ZCUIKitTools zcgetUrlRegular])){
                            continue;
                        }
                    }
                    _layoutPictureH.constant = 40;
                    if(type == SobotMessageTypeVideo){
                        _layoutPictureW.constant = 70;
                        [_ivPicture loadWithURL:[NSURL URLWithString:sobotConvertToString(item.snapshot)] placeholer:SobotKitGetImage(@"zcicon_default_goods_1")];
                        _btnPlay.hidden = NO;
                    }else{
                        _layoutPictureW.constant = 40;
                        [_ivPicture loadWithURL:[NSURL URLWithString:sobotConvertToString(item.msg)] placeholer:SobotKitGetImage(@"zcicon_default_goods_1")];
                    }
                    if(sobotConvertToString(item.url).length > 0){
                        _btnPlay.obj = @{@"msg":sobotConvertToString(item.url)};
                    }else{
                        _btnPlay.obj = @{@"msg":sobotConvertToString(item.content)};
                    }
                    contentW = _layoutPictureW.constant;
                }else{
                    self.viewContent.backgroundColor = UIColorFromModeColorAlpha(SobotColorBgWhite, 0.14);
                    // 文章
                    _layoutTitleTop.constant = 10;
                    _layoutLeftTop.constant = 10;
                    _layoutTitleL.constant = 10;
                    
                    _layoutLeftW.constant = 21;
                    _layoutLeftH.constant = 25;
                    
                    _layoutTitleR.constant = 0;
                    
                    _layoutDescTop.constant = 2;
                    _layoutDescBtm.constant = -10;
                    
                    if (type == 2) {
                        [_imgLeft setImage:[ZCUIKitTools getFileIcon:@"" fileType:4]];
                    }else if (type == 4){
                        [_imgLeft setImage:[ZCUIKitTools getFileIcon:sobotConvertToString(item.msg) fileType:0]];
                        
                        if(self.parentMessage.sendType == 0){
                            // 右边
                            self.viewContent.backgroundColor = UIColorFromModeColorAlpha(SobotColorWhite, 0.14);
                        }else{
                            // 左边
                            self.viewContent.backgroundColor = UIColorFromModeColor(SobotColorWhite);
                        }
                    }
                    [_labTitle setText:sobotConvertToString(item.name)];
//                    [_labDesc setText:sobotConvertToString(item.fileSize)];
                    _labTitle.textColor = [ZCUIKitTools zcgetLeftChatTextColor];
                    if(self.isRight){
                        _labTitle.textColor = [ZCUIKitTools zcgetRightChatTextColor];
                    }
                    contentW = ScreenWidth;
                }
            }else{
                if ((sobotIsUrl(sobotConvertToString(item.msg), [ZCUIKitTools zcgetUrlRegular]) && [item.showType intValue] == 1) || (i==0 && sobotIsUrl(sobotConvertToString(item.msg), [ZCUIKitTools zcgetUrlRegular]) && self.tempMessage.richModel.richList.count == 1)) {
                    self.viewContent.backgroundColor = UIColorFromModeColorAlpha(SobotColorBgWhite, 0.14);
                    isAddViews = YES;
                    // 超链接
                    _layoutTitleTop.constant = 10;
                    _layoutDescTop.constant = 0;
                    _layoutRightTop.constant = 10;
                    
                    _layoutRightW.constant = 20;
                    _layoutRightH.constant = 20;
                    _layoutTitleR.constant = -10;
                    _layoutDescBtm.constant = -10;
                    
                    _labTitle.font = SobotFont13;
                    self.labTitle.textColor = [ZCUIKitTools zcgetLeftChatTextColor];
                    if(self.isRight){
                        self.labTitle.textColor = [ZCUIKitTools zcgetRightChatTextColor];
                    }
                    
                    if(self.parentMessage.sendType == 0){
                        // 右边
                        self.viewContent.backgroundColor = UIColorFromModeColorAlpha(SobotColorWhite, 0.14);
                    }else{
                        // 左边
                        self.viewContent.backgroundColor = UIColorFromModeColor(SobotColorWhite);
                    }
                    
                    _labTitle.text = SobotKitLocalString(@"解析中...");
                    [_imgRight loadWithURL:[NSURL URLWithString:@""] placeholer:SobotKitGetImage(@"zcicon_url_icon")];
                    contentW = ScreenWidth;
                    [self getLinkValues:sobotConvertToString(item.msg) name:sobotConvertToString(item.name) result:^(NSString * _Nonnull title, NSString * _Nonnull desc, NSString * _Nonnull iconUrl) {
                        if(title.length > 0){
                            self.labTitle.text = sobotConvertToString(title);
//                            self.labDesc.text = sobotConvertToString(desc);
                            [self.imgRight loadWithURL:[NSURL URLWithString:sobotConvertToString(iconUrl)] placeholer:SobotKitGetImage(@"zcicon_url_icon") showActivityIndicatorView:NO];
                        }else{
                            self.labTitle.text = sobotConvertToString(item.msg);
                            self.labDesc.text = @"";
                            
                            [self.imgRight loadWithURL:[NSURL URLWithString:sobotConvertToString(iconUrl)] placeholer:SobotKitGetImage(@"zcicon_url_icon") showActivityIndicatorView:NO];
                        }
                    }];
                    // 如果富文本之前已经有文本了，则直接结束循环
                    if(sobotConvertToString(text1).length > 0){
                        break;
                    }
                }
                
                // 如果text1已经存在，或者已经添加过卡片样式，则赋值给text2
                if(sobotConvertToString(text1).length > 0 || isAddViews){
                    text2 = sobotConvertToString(item.msg);
                    break;
                }else{
                    text1 = sobotConvertToString(item.msg);
                }
            }
        }
    }
    
    [self showContent:text1 view:(isAddViews ? self.viewContent : nil) btm:text2 isMaxWidth:contentW== ScreenWidth ? YES:NO customViewWidth:contentW];
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
            if(title.length > 0){
                NSDictionary *dataDic = @{@"title":sobotConvertToString(title),
                                          @"desc":sobotConvertToString(desc),
                                          @"imgUrl":sobotConvertToString(imgUrl),
                };
                [SobotCache addObject:dataDic forKey:[NSString stringWithFormat:@"%@%@",Sobot_CacheURLHeader,sobotConvertToString(link)]];
            }
            
            [[ZCUICore getUICore] addMessage:nil reload:YES];
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
        
        [[ZCUICore getUICore] addMessage:nil reload:YES];
    }];
}

#pragma mark -- 播放视频
-(void)playVideo:(SobotButton*)sender{
    // 隐藏键盘
    if(self.delegate && [self.delegate respondsToSelector:@selector(onReferenceCellEvent:type:state:obj:)]){
        [self.delegate onReferenceCellEvent:self.tempMessage type:ZCChatReferenceCellEventCloseKeyboard state:0 obj:nil];
    }
    
//    SobotChatMessage *tempModel =  (SobotChatMessage*)sender.obj;
    NSDictionary *dict = (NSDictionary *)sender.obj;
    NSString *msg = sobotConvertToString([dict objectForKey:@"msg"]);
     msg =  sobotUrlEncodedString(msg);
    NSURL *url = [NSURL URLWithString:msg];
    // 如果是本地视频，需要使用下面方式创建NSURL
    if(sobotCheckFileIsExsis(msg)){
        url = [NSURL fileURLWithPath:msg];
    }
    ZCVideoPlayer *player = [[ZCVideoPlayer alloc] initWithFrame:sobotGetCurWindow().bounds withShowInView:sobotGetCurWindow() url:url Image:nil];
    [player showControlsView];
}

/**
 *  点击查看大图
 */
-(void) imgTouchUpInside:(UITapGestureRecognizer *)tap{
    if(self.tempMessage.msgType == SobotMessageTypeVideo){
        [self playVideo:_btnPlay];
        return;
    }
    // 隐藏键盘
    if(self.delegate && [self.delegate respondsToSelector:@selector(onReferenceCellEvent:type:state:obj:)]){
        [self.delegate onReferenceCellEvent:self.tempMessage type:ZCChatReferenceCellEventCloseKeyboard state:0 obj:nil];
    }
    
    UIImageView *picTempView = (UIImageView*)_ivPicture;
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

