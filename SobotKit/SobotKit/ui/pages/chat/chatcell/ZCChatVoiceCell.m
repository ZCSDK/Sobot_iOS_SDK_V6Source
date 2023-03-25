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
@property(nonatomic,strong) UILabel *translationLabel;

@property(nonatomic,strong) NSLayoutConstraint *layoutWidth;
@property(nonatomic,strong) NSLayoutConstraint *layoutHeight;
@property(nonatomic,strong) NSLayoutConstraint *layoutTransTop;
@property(nonatomic,strong) NSLayoutConstraint *layoutTransWidth;
@property(nonatomic,strong) NSLayoutConstraint *layoutTransHeight;

@end

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
        [self.contentView addSubview:iv];
        iv.imageView.animationDuration = 0.8f;
        iv.imageView.animationRepeatCount = 0;
        [iv addTarget:self action:@selector(playVoice:) forControlEvents:UIControlEventTouchUpInside];
        [iv setBackgroundImage:[SobotImageTools sobotImageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
        iv.userInteractionEnabled=YES;
        [iv addTarget:self action:@selector(bgColorChangeAction:) forControlEvents:UIControlEventTouchDown];
        [iv setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [iv setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        _layoutWidth = sobotLayoutEqualWidth(60, iv, NSLayoutRelationEqual);
        _layoutHeight = sobotLayoutEqualHeight(25, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:_layoutHeight];
        [self.contentView addConstraint:_layoutWidth];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingHSpace, iv, self.ivBgView)];
        [self.contentView addConstraint:sobotLayoutPaddingTop(ZCChatPaddingVSpace, iv, self.ivBgView)];
        
        iv;
    });
    //        _voiceButton.backgroundColor = [UIColor redColor];
    
    _translationLabel = ({
        UILabel *iv = [[UILabel alloc] init];
        iv.font = [ZCUIKitTools zcgetKitChatFont];
        iv.textColor = [ZCUIKitTools zcgetRightChatColor];
        iv.numberOfLines = 0;
        [self.contentView addSubview:iv];
        iv.hidden = YES;
        _layoutTransWidth = sobotLayoutEqualWidth(0, iv, NSLayoutRelationEqual);
        _layoutTransWidth.priority = UILayoutPriorityDefaultLow;
        _layoutTransTop = sobotLayoutMarginTop(0, iv, _voiceButton);
        [self.contentView addConstraint:_layoutHeight];
        [self.contentView addConstraint:_layoutHeight];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingHSpace, iv, self.ivBgView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-ZCChatPaddingHSpace, iv, self.ivBgView)];
        [self.contentView addConstraint:_layoutTransTop];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(-ZCChatPaddingVSpace, iv, self.ivBgView)];
        iv;
    });
}

-(void)initDataToView:(SobotChatMessage *) message time:(NSString *) showTime{
    [super initDataToView:message time:showTime];
    
    
    #pragma mark 标题+内容
    // 0,自己，1机器人，2客服
    if(self.isRight){
        [_voiceButton setImage:SobotKitGetImage(@"zcicon_pop_voice_send_normal") forState:UIControlStateNormal];
        [_voiceButton setImage:SobotKitGetImage(@"zcicon_pop_voice_send_normal") forState:UIControlStateHighlighted];
        [_voiceButton setTitleColor:[ZCUIKitTools zcgetRightChatTextColor] forState:UIControlStateNormal];
        
    }else{
        [_voiceButton setImage:SobotKitGetImage(@"zcicon_pop_voice_receive_normal") forState:UIControlStateNormal];
        [_voiceButton setImage:SobotKitGetImage(@"zcicon_pop_voice_receive_normal") forState:UIControlStateHighlighted];
        [_voiceButton setTitleColor:[ZCUIKitTools zcgetLeftChatTextColor] forState:UIControlStateNormal];
    }
    CGSize size = CGSizeMake(90, 25);
    // 设置数据
    if(sobotConvertToString(message.richModel.msgtranslation).length == 0 ){
        if(message.richModel.duration.length < 5 || message.richModel.duration.length>6){
            message.richModel.duration=@"00:00″";
        }
        NSString *timeStr = [NSString stringWithFormat:@"%@",message.richModel.duration];
        
    //    NSLog(@"当前记录的语音时间时长为%@",timeStr);
        if ([timeStr isEqualToString:@"01:00"]) {
            timeStr = @"00:59";
        }

        timeStr = [timeStr substringFromIndex:3];
        if (timeStr.length ==2 && [timeStr hasPrefix:@"0"]) {
           timeStr = [timeStr substringFromIndex:1];
            
        }
        timeStr = [timeStr stringByAppendingString:@"″"];
        [_voiceButton setTitle:timeStr forState:UIControlStateNormal];
        CGSize ssize = [_voiceButton.titleLabel.text boundingRectWithSize:CGSizeMake(self.maxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_voiceButton.titleLabel.font} context:nil].size;
        size = CGSizeMake(ssize.width + 35, 25);
        _translationLabel.text = @"";
        _translationLabel.hidden = YES;
        
        _layoutWidth.priority = UILayoutPriorityDefaultHigh;
        _layoutHeight.constant = 25;
    }else{
        if(self.isRight){
            _translationLabel.textAlignment = NSTextAlignmentRight;
            [_translationLabel setTextColor:[ZCUIKitTools zcgetRightChatTextColor]];
        }else{
            _translationLabel.textAlignment = NSTextAlignmentLeft;
            [_translationLabel setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        }
        _layoutWidth.priority = UILayoutPriorityDefaultLow;
        _layoutHeight.constant = 0;
        _layoutTransWidth.priority = UILayoutPriorityDefaultHigh;
        
        _translationLabel.text = sobotConvertToString(message.richModel.msgtranslation);
        _translationLabel.hidden = NO;
        
        size = [_translationLabel.text boundingRectWithSize:CGSizeMake(self.maxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_translationLabel.font} context:nil].size;
    }
    
    
    
    
    [self setChatViewBgState:CGSizeMake(size.width, size.height)];
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
