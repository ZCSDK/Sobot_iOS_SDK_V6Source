//
//  ZCChatVoiceCell.m
//  SobotKit
//
//  Created by zhangxy on 2022/9/18.
//

#import "ZCChatVoiceCell.h"
@interface ZCChatVoiceCell(){
    
}

@property(nonatomic,strong) SobotButton *voiceButton;
@property(nonatomic,strong) UIView *translationView;
@property(nonatomic,strong) UILabel *translationLabel;
@property(nonatomic,strong) UIButton *translationStateButton;

@property(nonatomic,strong) NSLayoutConstraint *layoutWidth;
@property(nonatomic,strong) NSLayoutConstraint *layoutTransTop;
@property(nonatomic,strong) NSLayoutConstraint *layoutTransTextWidth;
@property(nonatomic,strong) NSLayoutConstraint *layoutTransTextTop;
@property(nonatomic,strong) NSLayoutConstraint *layoutTransStateTop;
@property(nonatomic,strong) NSLayoutConstraint *layoutTransStateBottom;
@property(nonatomic,strong) NSLayoutConstraint *layoutTransStateHeight;


@end

static const CGFloat SobotVoiceBaseWidth = 180.0f;

@implementation ZCChatVoiceCell

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
    
    _voiceButton = ({
        SobotButton *iv = [SobotButton buttonWithType:UIButtonTypeCustom];
        iv.obj = @"1";
        [iv setBackgroundColor:[UIColor clearColor]];
        [iv.imageView setContentMode:UIViewContentModeScaleAspectFit];
        //        [_voiceButton.titleLabel setFont:[ZCUITools zcgetListKitDetailFont]];
        [iv.titleLabel setFont:SobotFont14];
        iv.layer.cornerRadius = 4.0f;
        iv.layer.masksToBounds = YES;
        [self.contentView addSubview:iv];
        iv.imageView.animationDuration = 0.8f;
        iv.imageView.animationRepeatCount = 0;
        [iv addTarget:self action:@selector(playVoice:) forControlEvents:UIControlEventTouchUpInside];
        [iv setBackgroundImage:[SobotImageTools sobotImageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
        iv.userInteractionEnabled=YES;
        [iv addTarget:self action:@selector(bgColorChangeAction:) forControlEvents:UIControlEventTouchDown];
        [iv setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [iv setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        _layoutWidth = sobotLayoutEqualWidth(SobotVoiceBaseWidth, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:sobotLayoutEqualHeight(25 + ZCChatPaddingVSpace*2, iv, NSLayoutRelationEqual)];
        [self.contentView addConstraint:_layoutWidth];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(0, iv, self.ivBgView)];
        [self.contentView addConstraint:sobotLayoutPaddingTop(0, iv, self.ivBgView)];
        
        iv;
    });
    _translationView = ({
        UIView *iv = [[UIView alloc] initWithFrame:CGRectZero];
        iv.backgroundColor = [ZCUIKitTools zcgetRightChatVoiceTextBgColor];
        iv.layer.cornerRadius = 4.0f;
        iv.layer.masksToBounds = YES;
        [self.contentView addSubview:iv];
        
        // 只会在左边
        _layoutTransTop = sobotLayoutMarginTop(ZCChatMarginVSpace, iv, self.self.voiceButton);
        [self.contentView addConstraint:_layoutTransTop];
        [self.contentView addConstraint:sobotLayoutPaddingRight(0, iv, self.voiceButton)];
        NSLayoutConstraint *layotBottom = sobotLayoutMarginBottom(-ZCChatCellItemSpace, iv, self.lblSugguest);
        [self.contentView addConstraint:layotBottom];
        iv;
        
    });
    
    _translationLabel = ({
        UILabel *iv = [[UILabel alloc] init];
        iv.font = [ZCUIKitTools zcgetKitChatFont];
        iv.textColor = [ZCUIKitTools zcgetRightChatVoiceTextColor];
        iv.numberOfLines = 0;
        [self.translationView addSubview:iv];
        
        _layoutTransTextTop = sobotLayoutPaddingTop(ZCChatPaddingVSpace, iv, self.translationView);
        [self.translationView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingHSpace, iv, self.translationView)];
        [self.translationView addConstraint:sobotLayoutPaddingRight(-ZCChatPaddingHSpace, iv, self.translationView)];
        [self.translationView addConstraint:_layoutTransTextTop];
        _layoutTransTextWidth = sobotLayoutEqualWidth(0, iv, NSLayoutRelationEqual);
        [self.translationView addConstraint:_layoutTransTextWidth];
        iv;
    });
    
    
    _translationStateButton = ({
        UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
        [iv setTitleColor:UIColorFromKitModeColor(SobotColorTextSub1) forState:0];
        [iv.titleLabel setFont:[ZCUIKitTools zcgetKitChatFont]];
        [iv setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [iv setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        [iv.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [iv setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self.translationView addSubview:iv];
        
        _layoutTransStateTop = sobotLayoutMarginTop(ZCChatPaddingVSpace, iv, self.translationLabel);
        _layoutTransStateBottom = sobotLayoutPaddingBottom(-ZCChatPaddingVSpace, iv, self.translationView);
        _layoutTransStateHeight= sobotLayoutEqualHeight(0, iv, NSLayoutRelationEqual);
        [self.translationView addConstraint:_layoutTransStateTop];
        [self.translationView addConstraint:_layoutTransStateHeight];
        [self.translationView addConstraint:_layoutTransStateBottom];
        [self.translationView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingHSpace, iv, self.translationView)];
        [self.translationView addConstraint:sobotLayoutPaddingRight(-ZCChatPaddingHSpace, iv, self.translationView)];
        iv;
    });
}

-(void)initDataToView:(SobotChatMessage *) message time:(NSString *) showTime{
    [super initDataToView:message time:showTime];
   
    _layoutTransStateHeight.constant = 0;
    
    CGSize size = CGSizeMake(SobotVoiceBaseWidth, 25 + ZCChatPaddingVSpace*2);
    if(message.richModel.duration.length < 5 || message.richModel.duration.length>6){
        message.richModel.duration=@"00:00";
    }
    NSString *timeStr = [NSString stringWithFormat:@"%@",message.richModel.duration];
    
//    NSLog(@"当前记录的语音时间时长为%@",timeStr);
    if ([timeStr isEqualToString:@"01:00"]) {
        timeStr = @"00:59";
    }
    if([timeStr isEqualToString:@"01:01"] || [timeStr isEqualToString:@"01:00"]){
        timeStr = @"00:59";
    }

    timeStr = [timeStr substringFromIndex:3];
    if (timeStr.length ==2 && [timeStr hasPrefix:@"0"]) {
       timeStr = [timeStr substringFromIndex:1];

    }
    timeStr = [timeStr stringByAppendingString:@"″"]; // 不显示引号
    
    // 获取最终大小
    int time = [sobotConvertToString(timeStr) intValue];
    CGFloat btnWidth = (self.viewWidth -160)/60*time;
    NSLog(@"btnwidth ==== %f",btnWidth);
    if (time == 0) {
        [_voiceButton setTitle:@"" forState:UIControlStateNormal];
    }else{
        [_voiceButton setTitle:timeStr forState:UIControlStateNormal];
    }
   
    CGSize ssize = [timeStr boundingRectWithSize:CGSizeMake(self.maxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_voiceButton.titleLabel.font} context:nil].size;
    size = CGSizeMake(ssize.width + btnWidth +50, 25); // 50个固定宽
    _layoutWidth.constant = size.width;
    NSLog(@"size.width ==== %f",size.width);
    [_voiceButton setBackgroundColor:[ZCUIKitTools zcgetRobotBackGroundColorWithSize:CGSizeMake(size.width, size.height)]];
    // 0,自己，1机器人，2客服
    if(self.isRight){
        [_voiceButton setImage:SobotKitGetImage(@"zcicon_pop_voice_send_normal") forState:UIControlStateNormal];
        [_voiceButton setImage:SobotKitGetImage(@"zcicon_pop_voice_send_normal") forState:UIControlStateHighlighted];
        [_voiceButton setTitleColor:[ZCUIKitTools zcgetRightChatTextColor] forState:UIControlStateNormal];
        [_voiceButton setImageEdgeInsets:UIEdgeInsetsMake(0, size.width - 30, 0, 0)];
        [_voiceButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, size.width - ssize.width - 30 + 10)];
        
    }else{
        [_voiceButton setImage:SobotKitGetImage(@"zcicon_pop_voice_receive_normal") forState:UIControlStateNormal];
        [_voiceButton setImage:SobotKitGetImage(@"zcicon_pop_voice_receive_normal") forState:UIControlStateHighlighted];
        [_voiceButton setTitleColor:[ZCUIKitTools zcgetLeftChatTextColor] forState:UIControlStateNormal];
        [_voiceButton setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0,size.width - ssize.width -10)];
        [_voiceButton setTitleEdgeInsets:UIEdgeInsetsMake(0, size.width - ssize.width - 30, 0,0)];
    }
    
    // 历史消息，转换失败，什么都不显示
    if(message.isHistory && message.richModel.state == 0){
        message.richModel.state = -1;
    }
    if(message.richModel.state == 3){
        message.richModel.state = -1;
    }
    
    if(message.richModel.state == -1){
        _translationLabel.text = @"";
        _translationLabel.hidden = YES;
        _layoutTransTop.constant = 0;
        _layoutTransTextTop.constant = 0;
        _layoutTransStateTop.constant = 0;
        _layoutTransStateBottom.constant = 0;
    }else{
        
        _layoutTransTop.constant = ZCChatCellItemSpace;
        _layoutTransTextTop.constant = ZCChatPaddingVSpace;
        _layoutTransStateTop.constant = ZCChatPaddingVSpace;
        _layoutTransStateBottom.constant = -ZCChatPaddingVSpace;
        if(self.isRight){
            _translationLabel.textAlignment = NSTextAlignmentLeft;
            [_translationLabel setTextColor:[ZCUIKitTools zcgetRightChatVoiceTextColor]];
        }else{
            _translationLabel.textAlignment = NSTextAlignmentLeft;
            [_translationLabel setTextColor:[ZCUIKitTools zcgetRightChatVoiceTextColor]];
        }
        
        _translationLabel.text = sobotConvertToString(message.richModel.voiceText);
        _translationLabel.hidden = NO;
        
        // 1 成功，0失败
        if(message.richModel.state == 1){
            [_translationStateButton setTitle:SobotKitLocalString(@"转换完成") forState:0];
            [_translationStateButton setImage:SobotKitGetImage(@"zcicon_transvoice_success") forState:0];
        }else if(message.richModel.state == 0){
            [_translationStateButton setTitle:SobotKitLocalString(@"转换失败") forState:0];
            [_translationStateButton setImage:SobotKitGetImage(@"zcicon_transvoice_fail") forState:0];
        }else{
            
            // 默认不显示 置空
            [_translationStateButton setTitle:SobotKitLocalString(@"") forState:0];
            [_translationStateButton setImage:SobotKitGetImage(@"") forState:0];
        }
        
        CGSize textSize = [_translationLabel.text boundingRectWithSize:CGSizeMake(self.maxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_translationLabel.font} context:nil].size;
        if(textSize.width == 0 || textSize.height == 0){
            _layoutTransTextTop.constant = 0;
        }
        
        CGSize btnSize = [_translationStateButton.titleLabel.text boundingRectWithSize:CGSizeMake(self.maxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_translationStateButton.titleLabel.font} context:nil].size;
        _layoutTransStateHeight.constant = btnSize.height;
        btnSize.width = btnSize.width + 25;
    
        if(btnSize.width < textSize.width){
            _layoutTransTextWidth.constant = textSize.width;
        }else{
            _layoutTransTextWidth.constant = btnSize.width;
        }
    }
    [_translationView layoutIfNeeded];
    CGFloat h = CGRectGetMaxY(_translationView.frame);
    
    [self setChatViewBgState:CGSizeMake(size.width-ZCChatPaddingHSpace*2,h)];
    // 如果有引导语，不能设置背景颜色为空
    if([message getModelDisplaySugestionText].length == 0){
        self.ivBgView.backgroundColor = UIColor.clearColor;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setAnimationImages:(UIButton *)sender{
    if(self.isRight){
        [sender.imageView setAnimationImages:[NSArray arrayWithObjects:
                                              SobotKitGetImage(@"zcicon_pop_voice_send_anime_1"),
                                              SobotKitGetImage(@"zcicon_pop_voice_send_anime_2"),
                                              SobotKitGetImage(@"zcicon_pop_voice_send_anime_3"),
//                                              [ZCUITools zcuiGetBundleImage:@"zcicon_pop_voice_send_anime_4"],
//                                              [ZCUITools zcuiGetBundleImage:@"zcicon_pop_voice_send_anime_5"],
                                              nil]];
        
    }else{
        [sender.imageView setAnimationImages:[NSArray arrayWithObjects:
                                              SobotKitGetImage(@"zcicon_pop_voice_receive_anime_1"),
                                              SobotKitGetImage(@"zcicon_pop_voice_receive_anime_2"),
                                              SobotKitGetImage(@"zcicon_pop_voice_receive_anime_3"),
//                                              [ZCUITools zcuiGetBundleImage:@"zcicon_pop_voice_receive_anime_4"],
//                                              [ZCUITools zcuiGetBundleImage:@"zcicon_pop_voice_receive_anime_5"],
                                              nil]];
    }
}

// 点击播放声音
-(void)playVoice:(UIButton *) sender{
//    [self.ivBgView setBackgroundColor:[ZCUIKitTools zcgetRightChatColor]];
//    [self.ivBgView setNeedsDisplay];
    // 不是自己发送的，显示的是未读状态
    if(!self.btnReSend.hidden && !self.isRight){
        self.btnReSend.hidden=YES;
        if(self.tempModel){
            self.tempModel.isRead=YES;
        }
    }
    if(self.tempModel && self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
        [self setAnimationImages:sender];
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypePlayVoice text:nil obj:sender.imageView];
    }
}


- (void)bgColorChangeAction:(UIButton*)sender{

//    [self.ivBgView setBackgroundColor:[ZCUIKitTools zcgetChatRightVideoSelBgColor]];
//    [self.ivBgView setNeedsDisplay];
    
}


// 长按选择听筒模式,未使用
-(void)playAction:(id)sender{
    // 不是自己发送的，显示的是未读状态
    if(!self.btnReSend.hidden && !self.isRight){
        self.btnReSend.hidden=YES;
        if(self.tempModel){
            self.tempModel.isRead=YES;
        }
    }
    
    if(self.tempModel && self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
        [self setAnimationImages:sender];
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeReceiverPlayVoice text:@"" obj:_voiceButton.imageView];
    }
}



#pragma mark -- cell的呼吸动画
- (CABasicAnimation*)AlphaLight:(float)time{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:0.9f];
    animation.toValue = [NSNumber numberWithFloat:0.3f];
    animation.autoreverses = YES;
    animation.duration = time;
    animation.repeatCount = 59;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    return animation;
}
@end
