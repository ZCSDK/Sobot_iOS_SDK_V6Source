//
//  ZCChatReferenceSoundCell.m
//  SobotKit
//


#import "ZCChatReferenceSoundCell.h"
#import "ZCChatBaseCell.h"
@interface  ZCChatReferenceSoundCell()

@property(nonatomic,strong) SobotButton *voiceButton;

@property(nonatomic,strong) SobotChatMessage *tempModel;

@property(nonatomic,strong) NSLayoutConstraint *voiceButtonEW;

@end

static const CGFloat SobotVoiceBaseWidth = 180.0f;


@implementation ZCChatReferenceSoundCell

-(void)layoutSubViewUI{
    [super layoutSubViewUI];
    
    // 移除viewcontent的所有子view
    [self.viewContent.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _voiceButton = ({
        SobotButton *iv = [SobotButton buttonWithType:UIButtonTypeCustom];
        iv.obj = @"1";
        [iv setBackgroundColor:[UIColor clearColor]];
        [iv.imageView setContentMode:UIViewContentModeScaleAspectFit];
        //        [_voiceButton.titleLabel setFont:[ZCUITools zcgetListKitDetailFont]];
        [iv.titleLabel setFont:SobotFont14];
        iv.layer.cornerRadius = 4.0f;
        iv.layer.masksToBounds = YES;
        [self.viewContent addSubview:iv];
        iv.imageView.animationDuration = 0.8f;
        iv.imageView.animationRepeatCount = 0;
        [iv addTarget:self action:@selector(playVoice:) forControlEvents:UIControlEventTouchUpInside];
        [iv setBackgroundImage:[SobotImageTools sobotImageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
        iv.userInteractionEnabled=YES;
//        [iv addTarget:self action:@selector(bgColorChangeAction:) forControlEvents:UIControlEventTouchDown];
        [iv setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [iv setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [self.viewContent addConstraint:sobotLayoutEqualHeight(25 + 24, iv, NSLayoutRelationEqual)];
        self.voiceButtonEW = sobotLayoutEqualWidth(180, iv, NSLayoutRelationEqual);
        [self.viewContent addConstraint:self.voiceButtonEW];
        [self.viewContent addConstraint:sobotLayoutPaddingLeft(0, iv, self.viewContent)];
        [self.viewContent addConstraint:sobotLayoutPaddingTop(0, iv, self.viewContent)];
        [self.viewContent addConstraint:sobotLayoutPaddingBottom(0, iv, self.viewContent)];
//        [self.viewContent addConstraint:sobotLayoutPaddingRight(0, iv, self.viewContent)];
        iv;
    });
    
}


-(void)dataToView:(SobotChatMessage *)message{
    [super dataToView:message];
    self.tempModel = message;
    CGSize size = CGSizeMake(180, 25 + 12*2);

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
    CGFloat btnWidth = (ScreenWidth -180)/60*time;
    NSLog(@"btnwidth ==== %f",btnWidth);
    if (time == 0) {
        [_voiceButton setTitle:@"" forState:UIControlStateNormal];
    }else{
        [_voiceButton setTitle:timeStr forState:UIControlStateNormal];
    }
   
    CGSize ssize = [timeStr boundingRectWithSize:CGSizeMake(180, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_voiceButton.titleLabel.font} context:nil].size;
    size = CGSizeMake(ssize.width + btnWidth +50, 25); // 50个固定宽
    self.voiceButtonEW.constant = size.width;
    NSLog(@"size.width ==== %f",size.width);
//    [_voiceButton setBackgroundColor:[ZCUIKitTools zcgetRobotBackGroundColorWithSize:CGSizeMake(size.width, size.height)]];
    [_voiceButton setBackgroundColor:UIColorFromModeColorAlpha(SobotColorWhite, 0.14)];
    // 0,自己，1机器人，2客服
    if(self.tempMessage.senderType==0){
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
    [self showContent:@"" view:_voiceButton btm:nil isMaxWidth:NO customViewWidth:self.voiceButtonEW.constant];
}


-(void)setAnimationImages:(UIButton *)sender{
    if(self.tempMessage.senderType == 0){
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
    // 不是自己发送的，显示的是未读状态
    if(self.tempModel && self.delegate && [self.delegate respondsToSelector:@selector(onReferenceCellEvent:type:state:obj:)]){
        [self setAnimationImages:sender];
        [self.delegate onReferenceCellEvent:self.tempModel type:ZCChatReferenceCellEventPlayVoice state:0 obj:sender.imageView];
    }
}


@end
