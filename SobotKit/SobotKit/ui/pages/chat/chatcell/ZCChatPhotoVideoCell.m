//
//  ZCChatPhotoVideoCell.m
//  SobotKit
//
//  Created by zhangxy on 2022/9/20.
//

#import "ZCChatPhotoVideoCell.h"
#import "ZCPieChartView.h"

#define ImageHeight 175

@interface ZCChatPhotoVideoCell()
@property(nonatomic,strong) SobotImageView *ivPicture;
@property(nonatomic,strong) SobotButton *btnPlay;
@property (nonatomic,strong) ZCPieChartView *pieChartView;

@property (nonatomic,strong) NSLayoutConstraint *layoutPicHeight;
@property (nonatomic,strong) NSLayoutConstraint *layoutPicWidth;
@property (nonatomic,strong) NSLayoutConstraint *layoutPicBottom;
@property (nonatomic,strong) NSLayoutConstraint *layoutPicTop;
@property (nonatomic,strong) NSLayoutConstraint *layoutPicLeft;

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
        [iv setBackgroundColor:[ZCUIKitTools zcgetLeftChatColor]];
        iv.layer.cornerRadius = 4.0f;
        iv.layer.masksToBounds = YES;
        [self.contentView addSubview:iv];
        
        //设置点击事件
        UITapGestureRecognizer *tapGesturer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgTouchUpInside:)];
        iv.userInteractionEnabled=YES;
        [iv addGestureRecognizer:tapGesturer];
        
        _layoutPicHeight = sobotLayoutEqualHeight(ImageHeight, iv, NSLayoutRelationEqual);
        _layoutPicWidth = sobotLayoutEqualWidth(175, iv, NSLayoutRelationEqual);

        [self.contentView addConstraint:_layoutPicHeight];
        [self.contentView addConstraint:_layoutPicWidth];
        
        _layoutPicBottom = sobotLayoutMarginBottom(0, iv, self.lblSugguest);
        _layoutPicTop = sobotLayoutPaddingTop(0, iv, self.ivBgView);
        _layoutPicLeft = sobotLayoutPaddingLeft(0, iv, self.ivBgView);
        [self.contentView addConstraint:_layoutPicBottom];
        [self.contentView addConstraint:_layoutPicTop];
        [self.contentView addConstraint:_layoutPicLeft];
        iv;
    });
    
        
    _btnPlay = ({
        SobotButton *iv = [SobotButton buttonWithType:UIButtonTypeCustom];
        [iv setImage:SobotKitGetImage(@"zcicon_video_play") forState:0];
        [iv setBackgroundColor:UIColor.clearColor];
        [iv addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:iv];
        iv.hidden = YES;
        [self.contentView addConstraints:sobotLayoutSize(ImageHeight, ImageHeight, iv, NSLayoutRelationEqual)];
        [self.contentView addConstraint:sobotLayoutEqualCenterX(0, iv, _ivPicture)];
        [self.contentView addConstraint:sobotLayoutEqualCenterY(0, iv, _ivPicture)];
        iv.imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        iv;
    });
  
    _pieChartView = ({
        ZCPieChartView *iv = [[ZCPieChartView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
        [iv setBackgroundColor:UIColorFromModeColorAlpha(SobotColorBlack, 0.6)];
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
    
    
    #pragma mark 标题+内容
    // 0,自己，1机器人，2客服
    if(self.isRight){
//        [_ivPicture setBackgroundColor:[ZCUIKitTools zcgetRightChatColor]];
//        if (self.isRight) {
            // 处理右侧聊天气泡的 渐变色
        [_ivPicture setBackgroundColor:[ZCUIKitTools zcgetRobotBackGroundColorWithSize:CGSizeMake(ImageHeight*2, ImageHeight)]];
//        }
    }else{
        [_ivPicture setBackgroundColor:[ZCUIKitTools zcgetLeftChatColor]];
    }
    
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
    
    if(sobotConvertToString(self.lblSugguest.text).length > 0){
        _layoutPicTop.constant = ZCChatPaddingVSpace;
        _layoutPicLeft.constant = ZCChatPaddingHSpace;
        _layoutPicBottom.constant = -ZCChatCellItemSpace;
    }else{
        _layoutPicTop.constant = 0;
        _layoutPicLeft.constant = 0;
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
    }else{
        if (message.msgType == SobotMessageTypeVideo) {
            [_ivPicture loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(message.richModel.snapshot)] placeholer:SobotKitGetImage(@"zcicon_default_goods_1")  showActivityIndicatorView:YES];
        }else{
            [_ivPicture loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(message.richModel.content)] placeholer:SobotKitGetImage(@"zcicon_default_goods_1")  showActivityIndicatorView:YES];
        }
    }
    
    
    [self setChatViewBgState:CGSizeMake(175-ZCChatPaddingHSpace*2, ImageHeight)];
    
//    CALayer *layer              = self.ivLayerView.layer;
//    layer.frame                 = (CGRect){{0,0},self.ivLayerView.layer.frame.size};
//    _ivPicture.layer.mask = layer;
    // 如果有引导语，不能设置背景颜色为空
    if([message getModelDisplaySugestionText].length == 0){
        self.ivBgView.backgroundColor = UIColor.clearColor;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
