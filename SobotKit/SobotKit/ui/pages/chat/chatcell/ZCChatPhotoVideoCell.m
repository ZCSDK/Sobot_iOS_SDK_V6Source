//
//  ZCChatPhotoVideoCell.m
//  SobotKit
//
//  Created by zhangxy on 2022/9/20.
//

#import "ZCChatPhotoVideoCell.h"
#import "ZCPieChartView.h"
#import <SobotCommon/SobotXHCacheManager.h>
#define ImageHeight 175

@interface ZCChatPhotoVideoCell()
@property(nonatomic,strong) SobotImageView *ivPicture;
@property(nonatomic,strong) SobotButton *btnPlay;
@property (nonatomic,strong) ZCPieChartView *pieChartView;
// 占位图
@property(nonatomic,strong) UIImageView *plImg;

@property (nonatomic,strong) NSLayoutConstraint *layoutPicHeight;
@property (nonatomic,strong) NSLayoutConstraint *layoutPicWidth;
@property (nonatomic,strong) NSLayoutConstraint *layoutPicBottom;
@property (nonatomic,strong) NSLayoutConstraint *layoutPicTop;
@property (nonatomic,strong) NSLayoutConstraint *layoutPicLeft;
@property (nonatomic,strong) NSLayoutConstraint *layoutPicRight;
@end

@implementation ZCChatPhotoVideoCell

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
    _ivPicture = ({
        SobotImageView *iv = [[SobotImageView alloc] init];
        [iv setContentMode:UIViewContentModeScaleAspectFill];
        [iv.layer setMasksToBounds:YES];
//        [iv setBackgroundColor:[ZCUIKitTools zcgetLeftChatColor]];
        [iv setBackgroundColor:UIColorFromKitModeColor(SobotColorBgTopLine)];
        iv.layer.cornerRadius = 4.0f;
        iv.layer.masksToBounds = YES;
        [self.contentView addSubview:iv];
        
        //设置点击事件
        UITapGestureRecognizer *tapGesturer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgTouchUpInside:)];
        iv.userInteractionEnabled=YES;
        [iv addGestureRecognizer:tapGesturer];
        
        _layoutPicHeight = sobotLayoutEqualHeight(ImageHeight, iv, NSLayoutRelationEqual);
        _layoutPicHeight.priority = UILayoutPriorityDefaultHigh;
        _layoutPicWidth = sobotLayoutEqualWidth(160, iv, NSLayoutRelationEqual);

        [self.contentView addConstraint:_layoutPicHeight];
        [self.contentView addConstraint:_layoutPicWidth];
        
        _layoutPicBottom = sobotLayoutMarginBottom(0, iv, self.lblSugguest);
        _layoutPicTop = sobotLayoutPaddingTop(0, iv, self.ivBgView);
        
    
        [self.contentView addConstraint:_layoutPicBottom];
        [self.contentView addConstraint:_layoutPicTop];
        
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            _layoutPicLeft = sobotLayoutPaddingLeft(0, iv, self.ivBgView);
            [self.contentView addConstraint:_layoutPicLeft];
        }else{
            _layoutPicRight = sobotLayoutPaddingRight(0, iv, self.ivBgView);
            [self.contentView addConstraint:_layoutPicRight];
        }
        iv;
    });
    
    _plImg = ({
        UIImageView *iv =[[UIImageView alloc]init];
        [_ivPicture addSubview:iv];
        [_ivPicture addConstraints:sobotLayoutSize(50, 40, iv, NSLayoutRelationEqual)];
        [_ivPicture addConstraint:sobotLayoutEqualCenterX(0, iv, _ivPicture)];
        [_ivPicture addConstraint:sobotLayoutEqualCenterY(0, iv, _ivPicture)];
        iv.hidden = YES;
        iv;
    });
    
        
    _btnPlay = ({
        SobotButton *iv = [SobotButton buttonWithType:UIButtonTypeCustom];
        [iv setImage:SobotKitGetImage(@"zcicon_video_play") forState:0];
        [iv setBackgroundColor:UIColor.clearColor];
        [iv addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:iv];
        iv.hidden = YES;
//        [self.contentView addConstraints:sobotLayoutSize(ImageHeight, ImageHeight, iv, NSLayoutRelationEqual)];
//        [self.contentView addConstraint:sobotLayoutEqualCenterX(0, iv, _ivPicture)];
//        [self.contentView addConstraint:sobotLayoutEqualCenterY(0, iv, _ivPicture)];
        [self.contentView addConstraints:sobotLayoutPaddingWithAll(0, 0, 0, 0, iv, self.ivPicture)];
        iv.imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        iv;
    });
  
    _pieChartView = ({
        ZCPieChartView *iv = [[ZCPieChartView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
//        [iv setBackgroundColor:UIColorFromModeColorAlpha(SobotColorBlack, 0.6)];
        [iv setBackgroundColor:UIColor.clearColor];
        [self.contentView addSubview:iv];
        iv.hidden = YES;
        
        [self.contentView addConstraints:sobotLayoutSize(45, 45, iv, NSLayoutRelationEqual)];
        [self.contentView addConstraint:sobotLayoutEqualCenterX(0, iv, _ivPicture)];
        [self.contentView addConstraint:sobotLayoutEqualCenterY(0, iv, _ivPicture)];
        
        
        iv;
    });
}

-(void)initDataToView:(SobotChatMessage *) message time:(NSString *) showTime{
    [super initDataToView:message time:showTime];
    
    // 先搞空
//    [_ivPicture loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(@"")] placeholer:SobotKitGetImage(@"zcicon_default_goods_1")  showActivityIndicatorView:NO];
    [_ivPicture setImage:nil];
    _plImg .hidden = YES;
    #pragma mark 标题+内容
    // 0,自己，1机器人，2客服
//    if(self.isRight){
//            // 处理右侧聊天气泡的 渐变色
//        [_ivPicture setBackgroundColor:[ZCUIKitTools zcgetRobotBackGroundColorWithSize:CGSizeMake(ImageHeight*2, ImageHeight)]];
////        }
//    }else{
//        [_ivPicture setBackgroundColor:[ZCUIKitTools zcgetLeftChatColor]];
//    }
    
    _pieChartView.hidden = YES;
    _btnPlay.hidden = YES;
    if(message.msgType == SobotMessageTypeVideo){
        // 视频
        _btnPlay.hidden = NO;
        if(sobotConvertToString(self.tempModel.richModel.url).length > 0){
            _btnPlay.obj = @{@"msg":sobotConvertToString(self.tempModel.richModel.url)};
        }else{
            _btnPlay.obj = @{@"msg":sobotConvertToString(self.tempModel.richModel.content)};
        }
    }
    
    if(self.lblSugguest.subviews.count > 0){
//    if(sobotConvertToString(self.lblSugguest.text).length > 0){
        _layoutPicTop.constant = ZCChatPaddingVSpace;
        _layoutPicBottom.constant = -ZCChatMarginVSpace;
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            _layoutPicLeft.constant = ZCChatPaddingHSpace;
        }
    }else{
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            _layoutPicLeft.constant = 0;
        }
        _layoutPicTop.constant = 0;
        _layoutPicBottom.constant = 0;
    }
    _ivPicture.userInteractionEnabled = YES;
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
        [self resizeImageFrame:localImage sendMsg:NO];
    }else{
        if (message.msgType == SobotMessageTypeVideo) {
            NSString *imgUrl = sobotConvertToString(message.richModel.snapshot);
//            if (imgUrl.length == 0) {
//                imgUrl = sobotConvertToString(message.richModel.videoImgUrl);
//            }
            if (imgUrl.length == 0) {
                // 网络占位图
                imgUrl = @"https://img.sobot.com/chat/common/res/83f5636f-51b7-48d6-9d63-40eba0963bda.png";
            }
            UIImage *cacheImage = [SobotXHCacheManager imageWithURL:[NSURL URLWithString:sobotUrlEncodedString(imgUrl)] storeMemoryCache:YES];
            if (cacheImage) {
                [_ivPicture setImage:cacheImage];
                [self resizeImageFrame:cacheImage sendMsg:NO];
            }else{
                self.layoutPicHeight.constant = 160;
                self.layoutPicWidth.constant = 160;
                [self setChatViewBgState:CGSizeMake(160-ZCChatPaddingHSpace*2, 160)];
                [self.contentView layoutIfNeeded];
                
                // 之前是不是加载失败了 如果是加载失败了 显示加载失败的图片和比
                if ([[ZCUICore getUICore] isHasUserWithUrl:sobotConvertToString(imgUrl)]) {
                    self.layoutPicHeight.constant = 160;
                    self.layoutPicWidth.constant = 160;
                    [self setChatViewBgState:CGSizeMake(160-ZCChatPaddingHSpace*2, 160)];
                    self.plImg.hidden = NO;
                    [self.plImg setImage:SobotKitGetImage(@"zcicon_default_placeholer_image")];
                    [self.contentView layoutIfNeeded];
                }else{
                    [_ivPicture loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(imgUrl)] placeholer:nil  showActivityIndicatorView:YES completionBlock:^(UIImage * _Nonnull image, NSURL * _Nonnull url, NSError * _Nonnull error) {
                        if(!error){
                            if (sobotIsNull(image)) {
                                [[ZCUICore getUICore] addUrlToTempImageArray:sobotConvertToString(imgUrl)];
                            }
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"SOBOTCHATPHOTCELLUPDATE" object:nil userInfo:@{@"indexPath":self.indexPath}];
                            });
                        }else{
                            // 加载失败
                            [self->_ivPicture setImage:SobotKitGetImage(@"zcicon_default_placeholer_image")];
                        }
                    }];
                }
            }
        }else{
            UIImage *cacheImage = [SobotXHCacheManager imageWithURL:[NSURL URLWithString:sobotUrlEncodedString(message.richModel.content)] storeMemoryCache:YES];
            if (cacheImage) {
                [_ivPicture setImage:cacheImage];
                [self resizeImageFrame:cacheImage sendMsg:NO];
            }else{
                self.layoutPicHeight.constant = 160;
                self.layoutPicWidth.constant = 160;
                [self setChatViewBgState:CGSizeMake(160-ZCChatPaddingHSpace*2, 160)];
                [self.contentView layoutIfNeeded];
                // 之前是不是加载失败了 如果是加载失败了 显示加载失败的图片和比
                if ([[ZCUICore getUICore] isHasUserWithUrl:sobotConvertToString(message.richModel.content)]) {
                    self.layoutPicHeight.constant = 160;
                    self.layoutPicWidth.constant = 160;
                    [self setChatViewBgState:CGSizeMake(160-ZCChatPaddingHSpace*2, 160)];
                    self.plImg.hidden = NO;
                    [self.plImg setImage:SobotKitGetImage(@"zcicon_default_placeholer_image")];
                    [self.contentView layoutIfNeeded];
                }else{
                    [_ivPicture loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(message.richModel.content)] placeholer:nil  showActivityIndicatorView:YES completionBlock:^(UIImage * _Nonnull image, NSURL * _Nonnull url, NSError * _Nonnull error) {
                        if(!error){
                            if (sobotIsNull(image)) {
                                [[ZCUICore getUICore] addUrlToTempImageArray:sobotConvertToString(message.richModel.content)];
                            }
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"SOBOTCHATPHOTCELLUPDATE" object:nil userInfo:@{@"indexPath":self.indexPath}];
                            });
                        }else{
                            // 加载失败
                            [self->_ivPicture setImage:SobotKitGetImage(@"zcicon_default_placeholer_image")];
                        }
                    }];
                }
            }
        }
    }
    
//    [self setChatViewBgState:CGSizeMake(160-ZCChatPaddingHSpace*2, ImageHeight)];
//    CALayer *layer              = self.ivLayerView.layer;
//    layer.frame                 = (CGRect){{0,0},self.ivLayerView.layer.frame.size};
//    _ivPicture.layer.mask = layer;
    // 如果有引导语，不能设置背景颜色为空
    if([message getModelDisplaySugestionText].length == 0){
        self.ivBgView.backgroundColor = UIColor.clearColor;
    }
}


// 是否发送通知 isSend
-(void)resizeImageFrame:(UIImage *)img sendMsg:(BOOL)isSend{
//    UIImage *img = self.ivPicture.image;
    if(img){
        CGSize s = img.size;
        CGFloat w = s.width;
        CGFloat h = s.height;
        if (w >h) {
           // 以宽为基准
           if(s.width < 40){
               w = 40;
               h = 40 * s.height / s.width;
           }
           
           if(s.width > 160){
               w = 160;
               h = 160 * s.height / s.width;
           }
       }else{
           // 以高为基准
           if(s.height < 40){
               h = 40;
               w = 40 * s.width / s.height;
           }
           
           if(s.height > 160){
               h = 160;
               w = 160 * s.width / s.height;
           }
       }
        self.layoutPicHeight.constant = h;
        self.layoutPicWidth.constant = w;
        [self setChatViewBgState:CGSizeMake(w-ZCChatPaddingHSpace*2, h)];
        [self.contentView layoutIfNeeded];
//        if (isSend) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"SOBOTCHATPHOTCELLUPDATE" object:nil userInfo:@{@"indexPath":self.indexPath}];
//        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
