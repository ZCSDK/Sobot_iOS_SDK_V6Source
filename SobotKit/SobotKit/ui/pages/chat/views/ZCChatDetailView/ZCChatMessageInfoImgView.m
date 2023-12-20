//
//  ZCChatMessageInfoImgView.m
//  SobotKit
//
//  Created by lizh on 2023/11/23.
//

#import "ZCChatMessageInfoImgView.h"
@interface ZCChatMessageInfoImgView()<SobotXHImageViewerDelegate>
@property(nonatomic,strong)SobotImageView *imgView;
@property(nonatomic,strong)SobotChatMessage *msgModel;
@property(nonatomic,strong)SobotButton *playButton;
@property(nonatomic,strong)UIView *holdView;
@end

@implementation ZCChatMessageInfoImgView

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
    
    _imgView = ({
        SobotImageView *iv = [[SobotImageView alloc] init];
        [iv setContentMode:UIViewContentModeScaleAspectFill];
        [iv.layer setCornerRadius:4.0f];
        [iv.layer setMasksToBounds:YES];
        [self addSubview:iv];
        [self addConstraint:sobotLayoutPaddingTop(0, iv, self)];
        [self addConstraint:sobotLayoutPaddingLeft(42, iv, self)];
        [self addConstraint:sobotLayoutPaddingRight(-42, iv, self)];
        [self addConstraint:sobotLayoutEqualHeight(200, iv, NSLayoutRelationEqual)];
        [self addConstraint:sobotLayoutPaddingBottom(0, iv, self)];
        iv;
    });
    
    _holdView = ({
        UIView *iv = [[UIView alloc]init];
        iv.backgroundColor = [UIColor clearColor];
        [self addSubview:iv];
        [self addConstraint:sobotLayoutPaddingTop(0, iv, self)];
        [self addConstraint:sobotLayoutPaddingLeft(0, iv, self)];
        [self addConstraint:sobotLayoutPaddingRight(0, iv, self)];
        [self addConstraint:sobotLayoutPaddingBottom(0, iv, self)];
        iv.hidden = YES;
        iv;
    });
    
    _playButton = ({
        SobotButton *iv = [SobotButton buttonWithType:UIButtonTypeCustom];
        [iv setImage:[UIImage imageNamed:@"zcicon_video_play"] forState:0];
        [iv setBackgroundColor:UIColor.clearColor];
        [iv addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:iv];
        [self addConstraint:sobotLayoutEqualWidth(30, iv, NSLayoutRelationEqual)];
        [self addConstraint:sobotLayoutEqualHeight(30, iv, NSLayoutRelationEqual)];
        [self addConstraint:sobotLayoutEqualCenterX(0, iv, self)];
        [self addConstraint:sobotLayoutEqualCenterY(0, iv, self)];
        iv.hidden = YES;
        iv;
    });
    

}

-(CGFloat ) dataToView:(SobotChatMessage *)model{
    self.msgModel = model;
    if(model.msgType == SobotMessageTypePhoto){
        [_imgView loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(model.richModel.content)] placeholer:SobotKitGetImage(@"zcicon_default_goods_1")  showActivityIndicatorView:YES];
        _holdView.hidden = YES;
        _playButton.hidden = YES;
    }else{
        [_imgView loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(model.richModel.content)] placeholer:SobotKitGetImage(@"zcicon_default_goods_1")  showActivityIndicatorView:YES];
        _playButton.obj = sobotConvertToString(model.richModel.richmoreurl);
        _holdView.hidden = NO;
        _playButton.hidden = NO;
    }
    
    // 先更新约束 在获取高度
    [self layoutIfNeeded];
    CGRect f = self.imgView.frame;
    return f.size.height + f.origin.y;
}

#pragma mark - 视频播放
-(void)playVideo:(SobotButton *)btn{
    NSString *btnUrl = sobotConvertToString(btn.obj);
    NSURL *fileurl = [NSURL URLWithString:btnUrl];
    if(![btnUrl hasPrefix:@"http"]){
        fileurl = [NSURL fileURLWithPath:btnUrl];
    }    
    if(self.delegate && [self.delegate respondsToSelector:@selector(onViewEvent:dict:obj:)]){
        [self.delegate onViewEvent:ZCChatMessageInfoViewEventOpenVideo dict:@{} obj:sobotConvertToString(fileurl)];
    }
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
@end
