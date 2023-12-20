//
//  ZCChatDetailViewCell.m
//  SobotKit
//
//  Created by lizh on 2023/11/17.
//

#import "ZCChatDetailViewCell.h"
#import <SobotChatClient/SobotChatClient.h>
#import "ZCVideoPlayer.h"
#import "SobotFileButton.h"
#import "ZCUIKitTools.h"
#define itemImgHeight 200
#define itemIVideoHeight 200
#define itemSp 10
#define itemLeftSp 42
@interface  ZCChatDetailViewCell()<SobotEmojiLabelDelegate,SobotXHImageViewerDelegate>
{
    UIView *lastView;
    SobotChatMessage *msgModel;
}

@property(nonatomic,strong)UIView *modelView;// 消息内容

@end

@implementation ZCChatDetailViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self createItemsView];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self createItemsView];
    }
    return self;
}

-(void)createItemsView{
    _modelView = ({
        UIView *iv = [[UIView alloc]init];
        iv.backgroundColor = UIColor.yellowColor;
        [self.contentView addSubview:iv];
        [self.contentView addConstraint:sobotLayoutPaddingTop(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(0, iv, self.contentView)];
        iv;
    });
}


-(void)initWithDataModel:(SobotChatMessage*)model{
    msgModel = model;
    [self.modelView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for(UIView *v in self.modelView.subviews){
        [v removeFromSuperview];
    }
    
    // 创建消息体View;
    [self updateMsgViewWith:model];
}

#pragma mark - 更新msgModeView
-(void)updateMsgViewWith:(SobotChatMessage*)megModel{
   CGFloat viewH = [self addRichView:megModel width:ScreenWidth-itemLeftSp*2 with:self.modelView];
    for (UIView *view in self.modelView.subviews) {
        if([view isKindOfClass:[SobotEmojiLabel class]]){
            ((SobotEmojiLabel *)view).delegate = self;
        }else if([view isKindOfClass:[SobotImageView class]]){
            UIGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgTouchUpInside:)];
            [view addGestureRecognizer:tap];
            view.userInteractionEnabled = YES;
        }
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(updateContentHeight:)]){
        [self.delegate updateContentHeight:viewH];
    }
    if(lastView){
        [_modelView addConstraint:sobotLayoutPaddingBottom(-10, lastView, _modelView)];
    }
    
    
}

#pragma mark - 创建子控件
-(CGFloat)addRichView:(SobotChatMessage*)megModel width:(CGFloat)maxWidth with:(UIView*)superView{
    CGFloat ViewH = 0;
    NSLog(sobotConvertToString(@"消息类型 %zd"),megModel.msgType);
    // 根据model的同类型，不同子view
    if(megModel.msgType==1){
        // 单个图片  按产品逻辑是不会有的，先预留
        if(superView){
            SobotImageView *imgView = [[SobotImageView alloc] init];
            [imgView setContentMode:UIViewContentModeScaleAspectFill];
            [imgView.layer setCornerRadius:4.0f];
            [imgView.layer setMasksToBounds:YES];
            [imgView loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(megModel.richModel.content)] placeholer:SobotKitGetImage(@"zcicon_default_goods_1")  showActivityIndicatorView:YES];
            [superView addSubview:imgView];
            if (sobotIsNull(lastView)) {
                [superView addConstraint:sobotLayoutPaddingTop(10, imgView, superView)];
            }else{
                [superView addConstraint:sobotLayoutMarginTop(10, imgView, lastView)];
            }
            [superView addConstraint:sobotLayoutPaddingLeft(42, imgView, superView)];
            [superView addConstraint:sobotLayoutEqualHeight(itemImgHeight, imgView, NSLayoutRelationEqual)];
            [superView addConstraint:sobotLayoutPaddingRight(-42, imgView, superView)];
            ViewH = ViewH + itemImgHeight + 10;
            lastView = imgView;
        }
    }else if (megModel.msgType == SobotMessageTypeVideo){
        // 单个视频 按产品逻辑是不会有的，先预留
        if(superView){
            SobotImageView *imgView = [[SobotImageView alloc] init];
            [imgView setContentMode:UIViewContentModeScaleAspectFill];
            [imgView.layer setCornerRadius:4.0f];
            [imgView.layer setMasksToBounds:YES];
            [imgView loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(megModel.richModel.content)] placeholer:SobotKitGetImage(@"zcicon_default_goods_1")  showActivityIndicatorView:YES];
            [superView addSubview:imgView];
            if (sobotIsNull(lastView)) {
                [superView addConstraint:sobotLayoutPaddingTop(10, imgView, superView)];
            }else{
                [superView addConstraint:sobotLayoutMarginTop(10, imgView, lastView)];
            }
            [superView addConstraint:sobotLayoutPaddingLeft(itemLeftSp, imgView, superView)];
            [superView addConstraint:sobotLayoutEqualHeight(itemIVideoHeight, imgView, NSLayoutRelationEqual)];
            [superView addConstraint:sobotLayoutPaddingRight(-itemLeftSp, imgView, superView)];
            
            UIView *holdView = [[UIView alloc]init];
            holdView.backgroundColor = [UIColor clearColor];
            [imgView addSubview:holdView];
            [imgView addConstraint:sobotLayoutPaddingTop(0, holdView, imgView)];
            [imgView addConstraint:sobotLayoutPaddingLeft(0, holdView, imgView)];
            [imgView addConstraint:sobotLayoutPaddingRight(0, holdView, imgView)];
            [imgView addConstraint:sobotLayoutPaddingBottom(0, holdView, imgView)];
            
            // 播放按钮
            SobotButton *playButton = [SobotButton buttonWithType:UIButtonTypeCustom];
            [playButton setImage:[UIImage imageNamed:@"zcicon_video_play"] forState:0];
            [playButton setBackgroundColor:UIColor.clearColor];
            [playButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
            [imgView addSubview:playButton];
            playButton.obj = sobotConvertToString(megModel.richModel.richmoreurl);
            [imgView addConstraint:sobotLayoutEqualWidth(30, playButton, NSLayoutRelationEqual)];
            [imgView addConstraint:sobotLayoutEqualHeight(30, playButton, NSLayoutRelationEqual)];
            [imgView addConstraint:sobotLayoutEqualCenterX(0, playButton, imgView)];
            [imgView addConstraint:sobotLayoutEqualCenterY(0, playButton, imgView)];
            ViewH = ViewH + itemIVideoHeight + itemSp;
            lastView = imgView;
        }
    }else if(megModel.msgType==2){
        if (superView) {
            //录音 搞成单个音频
            UIView *fileBgView = [[UIView alloc]init];
            [superView addSubview:fileBgView];
            fileBgView.layer.cornerRadius = 0.5;
            fileBgView.layer.borderWidth = 0.5;
            fileBgView.layer.masksToBounds = YES;
            fileBgView.layer.borderColor = UIColorFromKitModeColor(@"0xD9D9D9").CGColor;
            if (sobotIsNull(lastView)) {
                [superView addConstraint:sobotLayoutPaddingTop(10, fileBgView, superView)];
            }else{
                [superView addConstraint:sobotLayoutMarginTop(10, fileBgView, lastView)];
            }
            [superView addConstraint:sobotLayoutEqualHeight(70, fileBgView, NSLayoutRelationEqual)];
            [superView addConstraint:sobotLayoutPaddingLeft(itemLeftSp, fileBgView, superView)];
            [superView addConstraint:sobotLayoutPaddingRight(-itemLeftSp, fileBgView, superView)];
            
            // 文件图标
            SobotImageView *iconImg = [[SobotImageView alloc]init];
            [fileBgView addSubview:iconImg];
            [fileBgView addConstraint:sobotLayoutPaddingTop(15, iconImg, fileBgView)];
            [fileBgView addConstraint:sobotLayoutPaddingLeft(15, iconImg, fileBgView)];
            [fileBgView addConstraint:sobotLayoutEqualWidth(40, iconImg, NSLayoutRelationEqual)];
            [fileBgView addConstraint:sobotLayoutEqualHeight(40, iconImg, NSLayoutRelationEqual)];
            
            [iconImg setImage:[SobotUITools getFileIcon:@"" fileType:4]];
            
            UILabel *fileName = [[UILabel alloc]init];
            [fileBgView addSubview:fileName];
            fileName.text = sobotConvertToString(megModel.richModel.fileSize);
            fileName.textColor = UIColorFromKitModeColor(SobotColorTextMain);
            fileName.font = SobotFontBold12;
            fileName.numberOfLines = 1;
            [fileBgView addConstraint:sobotLayoutPaddingTop(15, fileName, fileBgView)];
            [fileBgView addConstraint:sobotLayoutPaddingRight(-15, fileName, fileBgView)];
            [fileBgView addConstraint:sobotLayoutMarginLeft(10, fileName, iconImg)];
            
            UILabel *sizeLab = [[UILabel alloc]init];
            [fileBgView addSubview:sizeLab];
            sizeLab.text = sobotConvertToString(megModel.richModel.fileSize);
            sizeLab.textColor = UIColorFromKitModeColor(SobotColorTextSub);
            sizeLab.font = SobotFont10;
            sizeLab.numberOfLines = 1;
            [fileBgView addConstraint:sobotLayoutMarginTop(7, sizeLab, fileName)];
            [fileBgView addConstraint:sobotLayoutMarginLeft(10, sizeLab, iconImg)];
            [fileBgView addConstraint:sobotLayoutPaddingRight(-15, sizeLab, fileBgView)];
            
            
            SobotFileButton *objBtn = [SobotFileButton buttonWithType:UIButtonTypeCustom];
            [objBtn setBackgroundColor:[UIColor clearColor]];
            objBtn.objTag = megModel;
            [fileBgView addSubview:objBtn];
            [fileBgView addConstraint:sobotLayoutPaddingTop(0, objBtn, fileBgView)];
            [fileBgView addConstraint:sobotLayoutPaddingLeft(0, objBtn, fileBgView)];
            [fileBgView addConstraint:sobotLayoutPaddingRight(0, objBtn, fileBgView)];
            [fileBgView addConstraint:sobotLayoutPaddingBottom(0, objBtn, fileBgView)];
            [objBtn addTarget:self action:@selector(fileClick:) forControlEvents:UIControlEventTouchUpInside];
            ViewH = ViewH + 70 + itemSp;
            lastView = fileBgView;
        }
    }else if(megModel.msgType==4){
        if (superView) {
            // 文件
            UIView *fileBgView = [[UIView alloc]init];
            [superView addSubview:fileBgView];
            fileBgView.layer.cornerRadius = 0.5;
            fileBgView.layer.borderWidth = 0.5;
            fileBgView.layer.masksToBounds = YES;
            fileBgView.layer.borderColor = UIColorFromKitModeColor(@"0xD9D9D9").CGColor;
            if (sobotIsNull(lastView)) {
                [superView addConstraint:sobotLayoutPaddingTop(10, fileBgView, superView)];
            }else{
                [superView addConstraint:sobotLayoutMarginTop(10, fileBgView, lastView)];
            }
            [superView addConstraint:sobotLayoutEqualHeight(70, fileBgView, NSLayoutRelationEqual)];
            [superView addConstraint:sobotLayoutPaddingLeft(itemLeftSp, fileBgView, superView)];
            [superView addConstraint:sobotLayoutPaddingRight(-itemLeftSp, fileBgView, superView)];
            
            // 文件图标
            SobotImageView *iconImg = [[SobotImageView alloc]init];
            [fileBgView addSubview:iconImg];
            [fileBgView addConstraint:sobotLayoutPaddingTop(15, iconImg, fileBgView)];
            [fileBgView addConstraint:sobotLayoutPaddingLeft(15, iconImg, fileBgView)];
            [fileBgView addConstraint:sobotLayoutEqualWidth(40, iconImg, NSLayoutRelationEqual)];
            [fileBgView addConstraint:sobotLayoutEqualHeight(40, iconImg, NSLayoutRelationEqual)];
            [iconImg setImage:[ZCUIKitTools getFileIcon:msgModel.richModel.url fileType:(int)megModel.richModel.fileType]];
            
            UILabel *fileName = [[UILabel alloc]init];
            [fileBgView addSubview:fileName];
            fileName.text = sobotConvertToString(megModel.richModel.fileName);
            fileName.textColor = UIColorFromKitModeColor(SobotColorTextMain);
            fileName.font = SobotFontBold12;
            fileName.numberOfLines = 1;
            [fileBgView addConstraint:sobotLayoutPaddingTop(15, fileName, fileBgView)];
            [fileBgView addConstraint:sobotLayoutPaddingRight(-15, fileName, fileBgView)];
            [fileBgView addConstraint:sobotLayoutMarginLeft(10, fileName, iconImg)];
            
            UILabel *sizeLab = [[UILabel alloc]init];
            [fileBgView addSubview:sizeLab];
            sizeLab.text = sobotConvertToString(megModel.richModel.fileSize);
            sizeLab.textColor = UIColorFromKitModeColor(SobotColorTextSub);
            sizeLab.font = SobotFont10;
            sizeLab.numberOfLines = 1;
            [fileBgView addConstraint:sobotLayoutMarginTop(7, sizeLab, fileName)];
            [fileBgView addConstraint:sobotLayoutMarginLeft(10, sizeLab, iconImg)];
            [fileBgView addConstraint:sobotLayoutPaddingRight(-15, sizeLab, fileBgView)];
            
            
            SobotFileButton *objBtn = [SobotFileButton buttonWithType:UIButtonTypeCustom];
            [objBtn setBackgroundColor:[UIColor clearColor]];
            objBtn.objTag = megModel;
            [fileBgView addSubview:objBtn];
            [fileBgView addConstraint:sobotLayoutPaddingTop(0, objBtn, fileBgView)];
            [fileBgView addConstraint:sobotLayoutPaddingLeft(0, objBtn, fileBgView)];
            [fileBgView addConstraint:sobotLayoutPaddingRight(0, objBtn, fileBgView)];
            [fileBgView addConstraint:sobotLayoutPaddingBottom(0, objBtn, fileBgView)];
            [objBtn addTarget:self action:@selector(fileClick:) forControlEvents:UIControlEventTouchUpInside];
            ViewH = ViewH + 70 + itemSp;
            lastView = fileBgView;
        }
    }else if(megModel.msgType==5 && megModel.richModel.type == 2){
        // 位置
    }else if(megModel.msgType==0){
        if (superView) {
            // 纯文本
            SobotEmojiLabel *lblTextMsg = [[SobotEmojiLabel alloc] initWithFrame:CGRectZero];
            lblTextMsg.numberOfLines = 0;
            lblTextMsg.font = SobotFont16;
            lblTextMsg.delegate = self;
            lblTextMsg.lineBreakMode = NSLineBreakByTruncatingTail;
            lblTextMsg.textColor = UIColorFromKitModeColor(SobotColorTextMain);
            lblTextMsg.backgroundColor = [UIColor clearColor];
            lblTextMsg.isNeedAtAndPoundSign = NO;
            lblTextMsg.disableEmoji = NO;
            lblTextMsg.lineSpacing = 3.0f;
            lblTextMsg.verticalAlignment = SobotAttributedLabelVerticalAlignmentCenter;
            [superView addSubview:lblTextMsg];
            
            NSString *text = [self filterSpecialHTML:megModel.richModel.content];
            NSMutableDictionary *dict = [lblTextMsg getTextADict:text];
            if(dict){
                text = dict[@"text"];
            }
            text = @"方法一:禁用全局侧滑返回手势 可以在你的应用程序的整个导航控制器中禁用侧滑返回手势。 Swift 代码示例: // 在导航控制器的根视图控制器中 overridefuncviewDidLoad(){super.viewDidLoad()self.navigationController?.interactivePopGestureRecognizer?.isEnabled=false} Objective-C 代码示例: // 在导航控制器的根视图控制器中 -(void)viewDidLoad{[super viewDidLoad];self.navigationController.interactivePopGestureRecognizer.enabled=NO;}方法二:在特定视图控制器中禁用侧滑返回手势 如果你只想在特定的视图控制器中禁用侧滑返回手势,可以在这些视图控制器的 viewDidLo...更多";
//            if(megModel.displayMsgAttr!=nil){
//                [self setDisplayAttributedString:megModel.displayMsgAttr label:lblTextMsg guide:NO];
//            }else{
                lblTextMsg.text = text;
                if(dict){
                    NSArray *arr = dict[@"arr"];
                    // 添加链接样式
                    for (NSDictionary *item in arr) {
                        NSString *text = item[@"htmlText"];
                        int loc = [item[@"realFromIndex"] intValue];
                        // 一定要在设置text文本之后设置
                        [lblTextMsg addLinkToURL:[NSURL URLWithString:item[@"url"]] withRange:NSMakeRange(loc, text.length)];
                    }
                }
//            }
                        
            CGSize size =  [lblTextMsg sizeThatFits:CGSizeMake(ScreenWidth -itemLeftSp*2, CGFLOAT_MAX)];
            NSLog(@"%f",ScreenWidth);
            if (lastView == nil) {
                [superView addConstraint:sobotLayoutPaddingTop(10, lblTextMsg, superView)];
            }else{
                [superView addConstraint:sobotLayoutMarginTop(10, lblTextMsg, lastView)];
            }
            [superView addConstraint:sobotLayoutPaddingLeft(itemLeftSp, lblTextMsg, superView)];
            [superView addConstraint:sobotLayoutPaddingRight(-itemLeftSp, lblTextMsg, superView)];
            lastView = lblTextMsg;
            ViewH = ViewH + itemSp + size.height;
        }
    }else if(megModel.msgType==5 && megModel.richModel.type == SobotMessageRichJsonTypeOrder){
        // 订单卡片
    }else if(megModel.msgType==5 && megModel.richModel.type == SobotMessageRichJsonTypeGoods){
        // 商品卡片
    }else if (megModel.msgType == 5 && megModel.richModel.type == SobotMessageRichJsonTypeApplet){
        // 小程序卡片
        UIView *cardView = [[UIView alloc]init];
        cardView.layer.cornerRadius = 5.0;
        cardView.layer.masksToBounds = YES;
        cardView.backgroundColor = UIColorFromKitModeColor(SobotColorBgWhite);
        [superView addSubview:cardView];
        cardView.layer.borderWidth = 1;
        cardView.layer.borderColor = UIColorFromKitModeColor(SobotColorBgLine).CGColor;
        if (sobotIsNull(lastView)) {
            [superView addConstraint:sobotLayoutPaddingTop(10, cardView, superView)];
        }else{
            [superView addConstraint:sobotLayoutMarginTop(10, cardView, lastView)];
        }
        [superView addConstraint:sobotLayoutEqualWidth(226, cardView, NSLayoutRelationEqual)];
        [superView addConstraint:sobotLayoutPaddingLeft(itemLeftSp, cardView, superView)];
        UILabel *cardTitleLab = [[UILabel alloc]init];
        [cardTitleLab setTextAlignment:NSTextAlignmentLeft];
        [cardTitleLab setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16]];
        [cardTitleLab setTextColor:UIColorFromModeColor(SobotColorTextMain)]; // 0x515a7c
        [cardTitleLab setBackgroundColor:[UIColor clearColor]];
        cardTitleLab.numberOfLines = 0;
        cardTitleLab.text = sobotConvertToString(msgModel.richModel.richContent.title);
        [cardView addSubview:cardTitleLab];
        [cardView addConstraint:sobotLayoutPaddingTop(10, cardTitleLab, cardView)];
        [cardView addConstraint:sobotLayoutPaddingLeft(10, cardTitleLab, cardView)];
        [cardView addConstraint:sobotLayoutPaddingRight(-10, cardTitleLab, cardView)];
        
        SobotImageView *thumbView = [[SobotImageView alloc]init];
        [thumbView setBackgroundColor:UIColorFromKitModeColor(@"0xCDD9EA")];
        thumbView.contentMode = UIViewContentModeScaleToFill;
        [cardView addSubview:thumbView];
        [thumbView loadWithURL:[NSURL URLWithString:sobotConvertToString(msgModel.richModel.richContent.logo)] placeholer:[UIImage imageNamed:@""] showActivityIndicatorView:NO];
        [cardView addConstraint:sobotLayoutMarginTop(10, thumbView, cardTitleLab)];
        [cardView addConstraint:sobotLayoutPaddingLeft(0, thumbView, cardView)];
        [cardView addConstraint:sobotLayoutPaddingRight(0, thumbView, cardView)];
        [cardView addConstraint:sobotLayoutEqualHeight(180, thumbView, NSLayoutRelationEqual)];
        
        UIView *cardlineView = [[UIView alloc]init];
        cardlineView.backgroundColor = UIColorFromModeColor(SobotColorBgLine);
        [cardView addSubview:cardlineView];
        [cardView addConstraint:sobotLayoutMarginTop(1, cardlineView, thumbView)];
        [cardView addConstraint:sobotLayoutPaddingLeft(5, cardlineView, cardView)];
        [cardView addConstraint:sobotLayoutPaddingRight(-5, cardlineView, cardView)];
        [cardView addConstraint:sobotLayoutEqualHeight(0.5, cardlineView, NSLayoutRelationEqual)];
        
        SobotImageView *appletIcon = [[SobotImageView alloc]init];
        [appletIcon setBackgroundColor:[UIColor clearColor]];
        [cardView addSubview:appletIcon];
        [appletIcon loadWithURL:[NSURL URLWithString:@""] placeholer:[UIImage imageNamed:@"zcicon_applet"] showActivityIndicatorView:NO];
        [cardView addConstraint:sobotLayoutMarginTop(7, appletIcon, cardlineView)];
        [cardView addConstraint:sobotLayoutEqualWidth(12, appletIcon, NSLayoutRelationEqual)];
        [cardView addConstraint:sobotLayoutEqualHeight(12, appletIcon, NSLayoutRelationEqual)];
        [cardView addConstraint:sobotLayoutPaddingLeft(10, appletIcon, cardView)];
        
        // 小程序
        UILabel *carstipLab = [[UILabel alloc]init];
        carstipLab.font = [UIFont systemFontOfSize:12];
        carstipLab.textColor = UIColorFromModeColor(SobotColorTextSub);
        [cardView addSubview:carstipLab];
        carstipLab.text = SobotKitLocalString(@"小程序");
        [cardView addConstraint:sobotLayoutEqualCenterY(0, carstipLab, appletIcon)];
        [cardView addConstraint:sobotLayoutMarginLeft(5, carstipLab, appletIcon)];
        [cardView addConstraint:sobotLayoutPaddingRight(-10, carstipLab, cardView)];
        [cardView addConstraint:sobotLayoutPaddingBottom(-5, carstipLab, cardView)];
        ViewH = ViewH + 200;
        lastView = cardView;
    }else if (megModel.msgType == 5 && megModel.richModel.type == SobotMessageRichJsonTypeArticle){
        // 文章
        UIView *articleView = [[UIView alloc]init];
        if (superView) {
            [superView addSubview:articleView];
            if (sobotIsNull(lastView)) {
                [superView addConstraint:sobotLayoutPaddingTop(10, articleView, superView)];
            }else{
                [superView addConstraint:sobotLayoutMarginTop(10, articleView, lastView)];
            }
            [superView addConstraint:sobotLayoutEqualWidth(226, articleView, NSLayoutRelationEqual)];
            [superView addConstraint:sobotLayoutPaddingLeft(itemLeftSp, articleView, superView)];
            
            // 图片
            SobotImageView *logoView = [[SobotImageView alloc]init];
            [articleView addSubview:logoView];
            [articleView addConstraint:sobotLayoutPaddingTop(0, logoView, articleView)];
            [articleView addConstraint:sobotLayoutPaddingLeft(0, logoView, articleView)];
            [articleView addConstraint:sobotLayoutPaddingRight(0, logoView, articleView)];
            if (sobotConvertToString(msgModel.richModel.richContent.snapshot).length > 0) {
                // 有图片
                [articleView addConstraint:sobotLayoutEqualHeight(137, logoView, NSLayoutRelationEqual)];
            }else{
                [articleView addConstraint:sobotLayoutEqualHeight(0, logoView, NSLayoutRelationEqual)];
            }
            
            // 标题
            UILabel *articelTitleLab = [[UILabel alloc]init];
            [articleView addSubview:articelTitleLab];
            [articelTitleLab setTextAlignment:NSTextAlignmentLeft];
            [articelTitleLab setFont:SobotFont14];
            [articelTitleLab setTextColor:UIColorFromKitModeColor(@"0x0DAEAF")]; // 0x515a7c
            [articelTitleLab setBackgroundColor:[UIColor clearColor]];
            articelTitleLab.numberOfLines = 1;
            articelTitleLab.text = sobotConvertToString(msgModel.richModel.richContent.title);
            [articleView addConstraint:sobotLayoutMarginTop(12, articelTitleLab, logoView)];
            [articleView addConstraint:sobotLayoutPaddingLeft(15, articelTitleLab, articleView)];
            [articleView addConstraint:sobotLayoutPaddingRight(-15, articelTitleLab, articleView)];
           
            // 描述
            UILabel *descLab = [[UILabel alloc]init];
            [articleView addSubview:descLab];
            descLab.textColor = UIColorFromModeColor(SobotColorTextMain);
            descLab.font = [UIFont systemFontOfSize:14];
            descLab.numberOfLines = 2;
            descLab.lineBreakMode = NSLineBreakByTruncatingTail;
            descLab.text = sobotConvertToString(msgModel.richModel.richContent.desc);
            [articleView addConstraint:sobotLayoutMarginTop(5, descLab, articelTitleLab)];
            [articleView addConstraint:sobotLayoutPaddingLeft(15, descLab, articleView)];
            [articleView addConstraint:sobotLayoutPaddingRight(-15, descLab, articleView)];

            //线条
            UIView *artLineView = [[UIView alloc]init];
            [articleView addSubview:artLineView];
            artLineView.backgroundColor = UIColorFromModeColor(SobotColorBgLine);
            [articleView addConstraint:sobotLayoutMarginTop(12, artLineView, descLab)];
            [articleView addConstraint:sobotLayoutPaddingLeft(15, artLineView, articleView)];
            [articleView addConstraint:sobotLayoutPaddingRight(-15, artLineView, articleView)];
            [articleView addConstraint:sobotLayoutEqualHeight(1, artLineView, NSLayoutRelationEqual)];
            
            
            SobotImageView *nextView = [[SobotImageView alloc]init];
            [nextView setBackgroundColor:[UIColor clearColor]];
            [nextView setContentMode:UIViewContentModeScaleAspectFill];
            [nextView setImage:[UIImage imageNamed:@"zcicon_arrow_reply"]];
            [articleView addSubview:nextView];
            [articleView addConstraint:sobotLayoutPaddingRight(-15, nextView, articleView)];
            [articleView addConstraint:sobotLayoutMarginTop(10, nextView, artLineView)];
            [articleView addConstraint:sobotLayoutEqualHeight(9, nextView, NSLayoutRelationEqual)];
            [articleView addConstraint:sobotLayoutEqualWidth(5, nextView, NSLayoutRelationEqual)];
            
            SobotEmojiLabel *lookMoreLab = [[SobotEmojiLabel alloc] initWithFrame:CGRectZero];
            [articleView addSubview:lookMoreLab];
            lookMoreLab.numberOfLines = 1;
            lookMoreLab.font = SobotFont14;
            lookMoreLab.delegate = self;
            lookMoreLab.lineBreakMode = NSLineBreakByTruncatingTail;
            lookMoreLab.textColor = UIColorFromModeColor(SobotColorTextMain);
            lookMoreLab.isNeedAtAndPoundSign = NO;
            lookMoreLab.disableEmoji = NO;
            lookMoreLab.lineSpacing = 3.0f;
            [articleView addConstraint:sobotLayoutMarginRight(-5,lookMoreLab, nextView)];
            [articleView addConstraint:sobotLayoutEqualCenterY(0, lookMoreLab, nextView)];
            [articleView addConstraint:sobotLayoutPaddingLeft(15, lookMoreLab, nextView)];
            [articleView addConstraint:sobotLayoutPaddingBottom(-10, lookMoreLab, articleView)];
            
            SobotFileButton *fileBtn = [SobotFileButton buttonWithType:UIButtonTypeCustom];
            [fileBtn setBackgroundColor:[UIColor clearColor]];
            fileBtn.objTag = sobotConvertToString(msgModel.richModel.richContent.richMoreUrl);
            [articleView addSubview:fileBtn];
            [fileBtn addTarget:self action:@selector(articelClick:) forControlEvents:UIControlEventTouchUpInside];
            [articleView addConstraint:sobotLayoutPaddingLeft(0, fileBtn, articleView)];
            [articleView addConstraint:sobotLayoutPaddingRight(0, fileBtn, articleView)];
            [articleView addConstraint:sobotLayoutPaddingTop(0, fileBtn, articleView)];
            [articleView addConstraint:sobotLayoutPaddingBottom(0, fileBtn, articleView)];
            
            ViewH = ViewH + 200;
            lastView = articleView;
        }
    }else if(megModel.msgType==15){
        // 多伦不做引用
//        if (megModel.richModel.multiModel.templateIdType == 0){
//           
//        }else if (megModel.richModel.multiModel.templateIdType == 1){
//           
//        }else if (megModel.richModel.multiModel.templateIdType == 2){
//            
//        }else if (megModel.richModel.multiModel.templateIdType == 3){
//           
//        }else if (megModel.richModel.multiModel.templateIdType == 5){
//        
//        }else if (megModel.richModel.multiModel.templateIdType == 4){
//            
//        }
    }else{
        
        for (int i=0;i<msgModel.richModel.richList.count;i++) {
            SobotChatRichContent *item =  msgModel.richModel.richList[i];
            SobotMessageType type = item.type;
            // 0文本,1图片,2音频,3视频,4文件,5对象
            NSString *msg = sobotConvertToString(item.msg);
            if([@"<br>" isEqual:sobotTrimString(msg)] || [@"<br/>" isEqual:msg]){
                continue;
            }
            
            if(type == 0){
                if(msgModel.sendType == 0 && msgModel.richModel.richList.count == 1){
                    item.msg = sobotConvertToString(msgModel.richModel.content);
                    item.attr = nil;
                }
                int showType = [sobotConvertToString(item.showType) intValue];
              CGFloat itemH = [self addText:item view:superView maxWidth:ScreenWidth -42*2 showType:showType lastMsg:i == (msgModel.richModel.richList.count-1)];
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
                    [imgView loadWithURL:[NSURL URLWithString:sobotConvertToString(item.snapshot)] placeholer:SobotKitGetImage(@"zcicon_default_goods_1")];
                }else{
                    [imgView loadWithURL:[NSURL URLWithString:msg] placeholer:SobotKitGetImage(@"zcicon_default_goods_1")];
                }
                UITapGestureRecognizer *tapGesturer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgTouchUpInside:)];
                imgView.userInteractionEnabled=YES;
                [imgView addGestureRecognizer:tapGesturer];
                [superView addSubview:imgView];
                [superView addConstraint:sobotLayoutPaddingRight(-itemLeftSp, imgView, superView)];
                [superView addConstraint:sobotLayoutPaddingLeft(itemLeftSp, imgView, superView)];
                [superView addConstraint:sobotLayoutEqualHeight(itemImgHeight, imgView, NSLayoutRelationEqual)];
               
                if(type == 3){
                    [imgView loadWithURL:[NSURL URLWithString:@"https://img.sobot.com/chat/common/res/83f5636f-51b7-48d6-9d63-40eba0963bda.png"] placeholer:SobotKitGetImage(@"zcicon_default_goods_1")];
                    // 设置一个特殊的tag，不支持点击查看大图
                    imgView.tag = 101;
                    SobotButton *_playButton = [SobotButton buttonWithType:UIButtonTypeCustom];
                    _playButton.obj = item;
                    [_playButton setImage:SobotKitGetImage(@"zcicon_video_play") forState:0];
                    [_playButton setBackgroundColor:UIColor.clearColor];
                    [superView addSubview:_playButton];
                    [_playButton addTarget:self action:@selector(fileUrlClick:) forControlEvents:UIControlEventTouchUpInside];
                    
                    [superView addConstraints:sobotLayoutSize(30, 30, _playButton, NSLayoutRelationEqual)];
                    [superView addConstraint:sobotLayoutEqualCenterX(0, _playButton, imgView)];
                    [superView addConstraint:sobotLayoutEqualCenterY(0, _playButton, imgView)];
                }
                
                if(lastView){
                    [superView addConstraint:sobotLayoutMarginTop(10, imgView, lastView)];
                }else{
                    [superView addConstraint:sobotLayoutPaddingTop(10, imgView, superView)];
                }
                lastView = imgView;
                ViewH = ViewH + itemIVideoHeight + 10;
            }
            // 文件和音频
            if(type == 4 || type == 2) {
                // 文件
                UIView *bgView = [[UIView alloc]init];
                bgView.backgroundColor = UIColorFromModeColor(SobotColorBgMainDark3);
                bgView.layer.cornerRadius = 4;
                bgView.layer.masksToBounds = YES;
                [superView addSubview:bgView];
                [superView addConstraint:sobotLayoutEqualHeight(70, bgView, NSLayoutRelationEqual)];
                [superView addConstraint:sobotLayoutPaddingLeft(itemLeftSp, bgView, superView)];
                [superView addConstraint:sobotLayoutPaddingRight(-itemLeftSp, bgView, superView)];
                
                
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
                
                SobotFileButton *objBtn = [SobotFileButton buttonWithType:UIButtonTypeCustom];
                [objBtn setBackgroundColor:[UIColor clearColor]];
                objBtn.objTag = item;
                bgView.userInteractionEnabled = YES;
                [bgView addSubview:objBtn];
                [objBtn addTarget:self action:@selector(fileUrlClick:) forControlEvents:UIControlEventTouchUpInside];
                [bgView addConstraint:sobotLayoutPaddingLeft(0, objBtn, bgView)];
                [bgView addConstraint:sobotLayoutPaddingLeft(0, objBtn, bgView)];
                [bgView addConstraint:sobotLayoutEqualHeight(70, objBtn, NSLayoutRelationEqual)];
                [bgView addConstraint:sobotLayoutPaddingTop(0, objBtn, bgView)];
                
                if(lastView){
                    [superView addConstraint:sobotLayoutMarginTop(10, bgView, lastView)];
                }else{
                    [superView addConstraint:sobotLayoutPaddingTop(10, bgView, superView)];
                }
                lastView = bgView;
                ViewH = ViewH + 70 + 10;
            }
        }
    }
    return ViewH;
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
    __weak ZCChatDetailViewCell *weakSelf = self;
    
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


#pragma mark - 视频播放
-(void)playVideo:(SobotButton *)btn{
    NSString *btnUrl = sobotConvertToString(btn.obj);
    NSURL *fileurl = [NSURL URLWithString:btnUrl];
    if(![btnUrl hasPrefix:@"http"]){
        fileurl = [NSURL fileURLWithPath:btnUrl];
    }
    ZCVideoPlayer *player = [[ZCVideoPlayer alloc] initWithFrame:sobotGetCurWindow().bounds withShowInView:sobotGetCurWindow() url:fileurl Image:nil];
    [player showControlsView];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(closeDetailView)]){
        [self.delegate closeDetailView];
    }
}

#pragma mark - 打开文件
-(void)fileClick:(SobotFileButton*)sender{
    SobotChatMessage *model = (SobotChatMessage*)(sender.objTag);
    if([ZCUICore getUICore].detailViewBlock){
        [ZCUICore getUICore].detailViewBlock(model, ZCChatCellClickTypeOpenFile, nil);
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(closeDetailView)]){
        [self.delegate closeDetailView];
    }
}

// richlist 文件打开方式是web
-(void)fileUrlClick:(SobotFileButton*)sender{
    SobotChatRichContent *item = (SobotChatRichContent *)(sender.objTag);
    if([ZCUICore getUICore].detailViewBlock){
        [ZCUICore getUICore].detailViewBlock(nil, ZCChatCellClickTypeOpenURL, sobotConvertToString(item.msg));
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(closeDetailView)]){
        [self.delegate closeDetailView];
    }
}

#pragma mark --文章的点击事件
-(void)articelClick:(SobotFileButton *)sender{
    NSString *url = sobotConvertToString(sender.objTag);
    if (sobotConvertToString(url).length == 0) {
        return;
    }
    if([ZCUICore getUICore].detailViewBlock){
        [ZCUICore getUICore].detailViewBlock(nil, ZCChatCellClickTypeOpenURL, sobotConvertToString(url));
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(closeDetailView)]){
        [self.delegate closeDetailView];
    }
}

#pragma mark -- 超链卡片点击事件
-(void)urlTextClick:(SobotButton*)sender{
    NSString *url = (NSString*)(sender.obj);
    if([ZCUICore getUICore].detailViewBlock){
        [ZCUICore getUICore].detailViewBlock(nil, ZCChatCellClickTypeOpenURL, sobotConvertToString(url));
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(closeDetailView)]){
        [self.delegate closeDetailView];
    }
}

#pragma mark -- 超链点击事件
// 链接点击
- (void)SobotEmojiLabel:(SobotEmojiLabel*)emojiLabel didSelectLink:(NSString*)link withType:(SobotEmojiLabelLinkType)type{
   [self doClickURL:link text:@""];
}
// 链接点击
-(void)doClickURL:(NSString *)url text:(NSString * )htmlText{
    if(url){
        url=[url stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        if([ZCUICore getUICore].detailViewBlock){
            [ZCUICore getUICore].detailViewBlock(nil, ZCChatCellClickTypeOpenURL, sobotConvertToString(url));
        }
        if(self.delegate && [self.delegate respondsToSelector:@selector(closeDetailView)]){
            [self.delegate closeDetailView];
        }       
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark -- 过滤html标签
-(NSString *)filterSpecialHTML:(NSString *) text{
    NSMutableString *textString = [[NSMutableString alloc] initWithString:sobotConvertToString(text)];
    @try {
        [textString replaceOccurrencesOfString:@"<br />" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, textString.length)];
        [textString replaceOccurrencesOfString:@"<br/>;" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, textString.length)];
        [textString replaceOccurrencesOfString:@"<br>" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, textString.length)];
        [textString replaceOccurrencesOfString:@"&nbsp;" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, textString.length)];
        [textString replaceOccurrencesOfString:@"<p>" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, textString.length)];
        [textString replaceOccurrencesOfString:@"</p>" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, textString.length)];
        [textString replaceOccurrencesOfString:@"amp;" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, textString.length)];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
   
    return (NSString *) textString;
}

-(void)setDisplayAttributedString:(NSMutableAttributedString *) attr label:(UILabel *) label guide:(BOOL)isGuide{

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

-(CGFloat)addText:(SobotChatRichContent *)item view:(UIView *) superView maxWidth:(CGFloat ) cMaxWidth showType:(int )showType lastMsg:(BOOL )isLast{
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
    UIColor *linkColor = [ZCUIKitTools zcgetChatLeftLinkColor];
    if(msgModel.sendType == 0){
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
        if(!sobotIsNull(attrString) && msgModel.sendType != 0){
            [self setDisplayAttributedString:attrString label:tipLabel guide:NO];
        }else{
            // 最后一行过滤所有换行，不是最后一行过滤一个换行
            if(isLast){
                while ([text hasSuffix:@"\n"]){
                    text = [text substringToIndex:text.length - 1];
                }
            }
            text = [SobotHtmlCore filterHTMLTag:text];
            if(msgModel.sendType != 0){
                text = [ZCUIKitTools removeAllHTMLTag:text];
            }
            tipLabel.text = text;
        }
    }
    CGSize s2 = [tipLabel preferredSizeWithMaxWidth:cMaxWidth];
    
    [superView addConstraint:sobotLayoutPaddingLeft(itemLeftSp, tipLabel, superView)];
    [superView addConstraint:sobotLayoutPaddingRight(-itemLeftSp, tipLabel, superView)];
    if(lastView){
        [superView addConstraint:sobotLayoutMarginTop(10, tipLabel, lastView)];
    }else{
        [superView addConstraint:sobotLayoutPaddingTop(10, tipLabel, superView)];
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
        [superView addConstraint:sobotLayoutPaddingLeft(itemLeftSp,linkBgView, superView)];
        [superView addConstraint:sobotLayoutPaddingRight(-itemLeftSp, linkBgView, superView)];
        [superView addConstraint:sobotLayoutEqualHeight(78, linkBgView, NSLayoutRelationEqual)];
        
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
        [icon loadWithURL:[NSURL URLWithString:@""] placeholer:SobotKitGetImage(@"zcicon_url_icon")];
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
//        [self setLinkValues:text titleLabel:linktitleLab desc:linkdescLab imgView:icon];
        
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
               
        lastView = linkBgView;
        return 78;
    }
    
    lastView = tipLabel;
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
            if(title.length > 0){
                NSDictionary *dataDic = @{@"title":sobotConvertToString(title),
                                          @"desc":sobotConvertToString(desc),
                                          @"imgUrl":sobotConvertToString(imgUrl),
                };
                [SobotCache addObject:dataDic forKey:[NSString stringWithFormat:@"%@%@",Sobot_CacheURLHeader,sobotConvertToString(link)]];
            }
            if(self.delegate && [self.delegate respondsToSelector:@selector(updateLoadData)]){
                [self.delegate updateLoadData];
            }
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
        if(self.delegate && [self.delegate respondsToSelector:@selector(updateLoadData)]){
            [self.delegate updateLoadData];
        }
//        // 解析失败了
    }];
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
@end
