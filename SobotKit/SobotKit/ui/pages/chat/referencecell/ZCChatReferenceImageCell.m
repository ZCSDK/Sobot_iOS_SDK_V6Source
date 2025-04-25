//
//  ZCChatReferenceImageCell.m
//  SobotKit
//
//  Created by zhangxy on 2023/11/16.
//

#import "ZCChatReferenceImageCell.h"
#import "ZCPieChartView.h"
#import "ZCVideoPlayer.h"

@interface ZCChatReferenceImageCell()<SobotXHImageViewerDelegate>{
}


@property(nonatomic,strong) SobotImageView *ivPicture;
@property(nonatomic,strong) SobotButton *btnPlay;
@property(nonatomic,strong) ZCPieChartView *pieChartView;
@property(nonatomic,strong) UIView *playBgView;

@property(nonatomic,strong)NSLayoutConstraint *ivPictureEH;
@property(nonatomic,strong)NSLayoutConstraint *ivPictureEW;

@end

@implementation ZCChatReferenceImageCell



-(void)layoutSubViewUI{
    [super layoutSubViewUI];
    
    self.viewContent.backgroundColor = UIColor.clearColor;
    // 移除viewcontent的所有子view
    [self.viewContent.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _ivPicture = ({
        SobotImageView *iv = [[SobotImageView alloc] init];
        [iv setContentMode:UIViewContentModeScaleAspectFill];
        [iv.layer setMasksToBounds:YES];
        [iv setBackgroundColor:[ZCUIKitTools zcgetLeftChatColor]];
        iv.layer.cornerRadius = 2.0f;
        iv.layer.masksToBounds = YES;
        [self.viewContent addSubview:iv];
        
        //设置点击事件
        UITapGestureRecognizer *tapGesturer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgTouchUpInside:)];
        iv.userInteractionEnabled=YES;
        [iv addGestureRecognizer:tapGesturer];
        
        [self.viewContent addConstraint:sobotLayoutPaddingTop(0, iv, self.viewContent)];
        [self.viewContent addConstraint:sobotLayoutPaddingLeft(0, iv, self.viewContent)];
        [self.viewContent addConstraint:sobotLayoutPaddingBottom(0, iv, self.viewContent)];
        self.ivPictureEW = sobotLayoutEqualWidth(71, iv, NSLayoutRelationEqual);
        self.ivPictureEH = sobotLayoutEqualHeight(40, iv, NSLayoutRelationEqual);
        [self.viewContent addConstraint:self.ivPictureEH];
        [self.viewContent addConstraint:self.ivPictureEW];
        iv;
    });
    
    _playBgView = ({
        UIView *iv = [[UIView alloc]init];
        [self.viewContent addSubview:iv];
        [self.viewContent addConstraint:sobotLayoutPaddingTop(0, iv, self.viewContent)];
        [self.viewContent addConstraint:sobotLayoutPaddingLeft(0, iv, self.viewContent)];
        [self.viewContent addConstraint:sobotLayoutPaddingRight(0, iv, self.viewContent)];
        [self.viewContent addConstraint:sobotLayoutPaddingBottom(0, iv, self.viewContent)];
        iv.hidden = YES;
        iv;
    });
        
    _btnPlay = ({
        SobotButton *iv = [SobotButton buttonWithType:UIButtonTypeCustom];
        [iv setImage:SobotKitGetImage(@"zcicon_video_play") forState:0];
        [iv setBackgroundColor:UIColor.clearColor];
        [self.viewContent addSubview:iv];
        [iv addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        iv.hidden = YES;
        [self.viewContent addConstraints:sobotLayoutSize(14, 14, iv, NSLayoutRelationEqual)];
        [self.viewContent addConstraint:sobotLayoutEqualCenterX(0, iv, _ivPicture)];
        [self.viewContent addConstraint:sobotLayoutEqualCenterY(0, iv, _ivPicture)];
        iv;
    });
    
  
    _pieChartView = ({
        ZCPieChartView *iv = [[ZCPieChartView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
        [iv setBackgroundColor:UIColorFromModeColorAlpha(SobotColorBlack, 0.6)];
        [self.viewContent addSubview:iv];
        iv.hidden = YES;
        
        [self.viewContent addConstraints:sobotLayoutSize(14, 14, iv, NSLayoutRelationEqual)];
        [self.viewContent addConstraint:sobotLayoutEqualCenterX(0, iv, _ivPicture)];
        [self.viewContent addConstraint:sobotLayoutEqualCenterY(0, iv, _ivPicture)];
        
        iv;
    });
}
-(void)dataToView:(SobotChatMessage *)message{
    [super dataToView:message];
    
//    message.richModel.content = @"https://www.sobot.com/images/new-logo-4d3578bd95.png";
    self.ivPictureEW.constant = 40;
    self.ivPictureEH.constant = 40;
    if(message.msgType == SobotMessageTypeVideo){
        // 视频
        self.ivPictureEW.constant = 71;
        self.ivPictureEH.constant = 40;
        self.playBgView.hidden = NO;
        self.btnPlay.hidden = NO;
        if(sobotConvertToString(message.richModel.url).length > 0){
            _btnPlay.obj = @{@"msg":sobotConvertToString(message.richModel.url)};
        }else{
            _btnPlay.obj = @{@"msg":sobotConvertToString(message.richModel.content)};
        }
    }
    
    // 判断图片来源，本地或网络
    if(sobotCheckFileIsExsis(message.richModel.content)){
        NSString *path = message.richModel.content;
        if (message.msgType == SobotMessageTypeVideo) {
            path = message.richModel.snapshot;
        }
        UIImage *localImage=[UIImage imageWithContentsOfFile:path];

        //发送状态，1 开始发送，2发送失败，0，发送完成
        if(message.sendStatus == 1){
            _pieChartView.hidden = NO;
            if(_pieChartView){
                [_pieChartView updatePercent:message.progress*100 animation:NO];
            }
            _ivPicture.userInteractionEnabled = NO;
        }
        [_ivPicture setImage:localImage];
    }else{
        if (message.msgType == SobotMessageTypeVideo) {
            [_ivPicture loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(message.richModel.snapshot)] placeholer:SobotKitGetImage(@"zcicon_default_goods_1")  showActivityIndicatorView:NO completionBlock:^(UIImage * _Nonnull image, NSURL * _Nonnull url, NSError * _Nonnull error) {
                if(!error){
                    [self->_ivPicture hideLoadingView];
                }
            }];
        }else{
            self.ivPictureEH.constant = 40;
            self.ivPictureEW.constant = 40;
            self.playBgView.hidden = YES;
            self.btnPlay.hidden = YES;
            [_ivPicture loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(message.richModel.content)] placeholer:SobotKitGetImage(@"zcicon_default_goods_1")  showActivityIndicatorView:NO completionBlock:^(UIImage * _Nonnull image, NSURL * _Nonnull url, NSError * _Nonnull error) {
                if(!error){
                    [self->_ivPicture hideLoadingView];
                }
            }];
        }
    }
    [self showContent:@"" view:_ivPicture btm:nil isMaxWidth:NO customViewWidth:self.ivPictureEW.constant];
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

-(void)viewEvent:(ZCChatReferenceCellEvent)type state:(int)state obj:(id)obj{
    if(type == ZCChatReferenceCellEventOpen){
        [self imgTouchUpInside:nil];
    }
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

@end
