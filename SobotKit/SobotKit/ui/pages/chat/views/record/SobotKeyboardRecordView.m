//
//  SobotKeyboardRecordView.m
//  SobotKit
//
//  Created by zhangxy on 2025/1/16.
//

#import "SobotKeyboardRecordView.h"

#import "ZCUICore.h"
#import <SobotChatClient/SobotChatClient.h>
#import "ZCUIKitTools.h"

#import "SobotMultiBarView.h"

#define RecordViewWidth  180
#define RecordViewHeight 180

@interface SobotKeyboardRecordView()
@property (nonatomic,strong)NSLayoutConstraint *lastTimeLabMT;
@property (nonatomic,strong)NSLayoutConstraint *anniminViewLeftMT;
@property (nonatomic,strong)NSLayoutConstraint *anniminViewRightMt;

@property (nonatomic,strong) SobotMultiBarView *waveView;

@property (nonatomic,strong)  NSTimer *levelTimer;
// 背景渐变色
@property(nonatomic,strong) UIImageView *bgImg;
@end

@implementation SobotKeyboardRecordView{
    UIView      *centerView;
    UIImageView *anniminViewLeft;
    UIImageView *anniminViewRight;
    UILabel     *timeLablel;
    UILabel     *tipLabel;
    
    NSTimer     *voiceTimer;
    
    //开始录音
    NSURL           *tmpFile;
    AVAudioRecorder *recorder;
    BOOL            recording;
    AVAudioPlayer   *audioPlayer;
    // 倒计时
    UILabel *lastTimeLab;
    // 临时变量记录当前的状态
    SobotKeyboardRecordState recordState;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (SobotKeyboardRecordView *)initRecordView:(id<SobotKeyboardRecordDelegate>)delegate{
    self=[super init];
    if(self){
        //初始化背景视图，添加手势
//        self.backgroundColor = UIColorFromModeColorAlpha(SobotColorBgMainDark1, 0.8);
        self.userInteractionEnabled = YES;
        self.hidden = YES;
        [self createView];
        _delegate=delegate;
    }
    return self;
}

-(void)createView{
//    _bgImg = ({
//        UIImageView *iv = [[UIImageView alloc]init];
//        [self addSubview:iv];
//        [self addConstraint:sobotLayoutPaddingTop(0, iv, self)];
//        [self addConstraint:sobotLayoutPaddingLeft(0, iv, self)];
//        [self addConstraint:sobotLayoutPaddingRight(0, iv, self)];
//        [self addConstraint:sobotLayoutPaddingBottom(0, iv, self)];
//        [iv setImage:SobotKitGetImage(@"zcicon_recordview_bg")];
////        iv.backgroundColor = UIColor.redColor;
//        iv;
//    });
    
    
    centerView=[[UIView alloc] init];
    [centerView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:centerView];
    
    [self addConstraint:sobotLayoutPaddingLeft(16, centerView, self)];
    [self addConstraint:sobotLayoutPaddingRight(-16, centerView, self)];
    [self addConstraint:sobotLayoutEqualCenterY(0, centerView, self)];
    
    lastTimeLab = [[UILabel alloc]init];
    [lastTimeLab setBackgroundColor:UIColor.clearColor];
    [lastTimeLab setTextColor:UIColorFromModeColor(SobotColorTextSub)];
    [lastTimeLab setFont:SobotFont14];
    [lastTimeLab setTextAlignment:NSTextAlignmentCenter];
    [centerView addSubview:lastTimeLab];
    [centerView addConstraint:sobotLayoutEqualCenterX(0, lastTimeLab, centerView)];
    [centerView addConstraint:sobotLayoutPaddingTop(0, lastTimeLab, centerView)];
    lastTimeLab.hidden = YES;
    
    
    timeLablel=[[UILabel alloc] init];
    [timeLablel setBackgroundColor:[UIColor clearColor]];
    [timeLablel setTextColor:UIColorFromModeColor(SobotColorTextSub)];
    [timeLablel setFont:SobotFont14];
    [timeLablel setTextAlignment:NSTextAlignmentCenter];
    [centerView addSubview:timeLablel];
    [centerView addConstraint:sobotLayoutPaddingTop(17+22, timeLablel, centerView)];
    [centerView addConstraint:sobotLayoutEqualCenterX(0, timeLablel, centerView)];
    [centerView addConstraint:sobotLayoutEqualHeight(22, timeLablel, NSLayoutRelationEqual)];
  
    
    anniminViewLeft=[[UIImageView alloc] init];
    [anniminViewLeft setContentMode:UIViewContentModeScaleAspectFit];
    anniminViewLeft.animationDuration = .8f;
//    anniminViewLeft.backgroundColor = UIColor.greenColor;
    anniminViewLeft.animationRepeatCount = 0;
    [centerView addSubview:anniminViewLeft];
    [centerView addConstraint:sobotLayoutPaddingTop(5+17+22, anniminViewLeft, centerView)];
//    [centerView addConstraint:sobotLayoutMarginRight(-8, anniminViewLeft, timeLablel)];
//    [centerView addConstraint:sobotLayoutEqualHeight(12, anniminViewLeft, NSLayoutRelationEqual)];
//    [centerView addConstraint:sobotLayoutEqualWidth(44, anniminViewLeft, NSLayoutRelationEqual)];
    
    [centerView addConstraints:sobotLayoutSize(44*2 +41, 12, anniminViewLeft, NSLayoutRelationEqual)];
    [centerView addConstraint:sobotLayoutEqualCenterX(0, anniminViewLeft, timeLablel)];
    
    anniminViewRight = [[UIImageView alloc] init];
    [anniminViewRight setContentMode:UIViewContentModeScaleAspectFit];
    anniminViewRight.animationDuration = .8f;
    anniminViewRight.animationRepeatCount = 0;
//    anniminViewRight.backgroundColor = UIColor.yellowColor;
    [centerView addSubview:anniminViewRight];
    [centerView addConstraint:sobotLayoutPaddingTop(5+17+22, anniminViewRight, centerView)];
//    [centerView addConstraint:sobotLayoutMarginLeft(8, anniminViewRight, timeLablel)];
//    [centerView addConstraint:sobotLayoutEqualHeight(12, anniminViewRight, NSLayoutRelationEqual)];
//    [centerView addConstraint:sobotLayoutEqualWidth(44, anniminViewRight, NSLayoutRelationEqual)];
    [centerView addConstraints:sobotLayoutSize(44*2 +41, 12, anniminViewRight, NSLayoutRelationEqual)];
    [centerView addConstraint:sobotLayoutEqualCenterX(0, anniminViewRight, timeLablel)];
    anniminViewRight.hidden = YES;
    
    [self getAnniminImages:NO];
    
    
    
    tipLabel=[[UILabel alloc] init];
    [tipLabel setBackgroundColor:[UIColor clearColor]];
    [tipLabel setFont:SobotFont14];
    tipLabel.numberOfLines = 0;
    [tipLabel setTextAlignment:NSTextAlignmentCenter];
    [tipLabel setTextColor:UIColorFromModeColor(SobotColorTextSub)];
    [centerView addSubview:tipLabel];
    
    [centerView addConstraint:sobotLayoutMarginTop(12, tipLabel, timeLablel)];
    [centerView addConstraint:sobotLayoutPaddingLeft(0, tipLabel, centerView)];
    [centerView addConstraint:sobotLayoutPaddingRight(0, tipLabel, centerView)];
    [centerView addConstraint:sobotLayoutPaddingBottom(0, tipLabel, centerView)];
    
//    self.waveView = [[SobotMultiBarView alloc] init];
//    self.waveView.backgroundColor = UIColor.redColor;
//    [centerView addSubview:self.waveView];
//    
//    [centerView addConstraint:sobotLayoutMarginTop(12, self.waveView, tipLabel)];
//    [centerView addConstraint:sobotLayoutEqualCenterX(0, self.waveView, centerView)];
//    [centerView addConstraints:sobotLayoutSize(100, 50, self.waveView, NSLayoutRelationEqual)];
}

-(void)getAnniminImages:(BOOL )isCannel{
    if(isCannel){
        anniminViewLeft.hidden = YES;
        anniminViewRight.hidden = NO;
        anniminViewRight.animationImages =
        [NSArray arrayWithObjects:
         SobotKitGetImage(@"zcicon_pop_voice_send_anime_0"),
         SobotKitGetImage(@"zcicon_pop_voice_send_anime_1"),
         SobotKitGetImage(@"zcicon_pop_voice_send_anime_2"),
         SobotKitGetImage(@"zcicon_pop_voice_send_anime_3"),
         SobotKitGetImage(@"zcicon_pop_voice_send_anime_4"),
         SobotKitGetImage(@"zcicon_pop_voice_send_anime_5"),
         SobotKitGetImage(@"zcicon_pop_voice_send_anime_6"),
         SobotKitGetImage(@"zcicon_pop_voice_send_anime_7"),nil];
        [anniminViewRight startAnimating];
        
        
//        anniminViewRight.animationImages =
//        [NSArray arrayWithObjects:
//         SobotKitGetImage(@"zcicon_pop_voice_send_anime_1"),
//         SobotKitGetImage(@"zcicon_pop_voice_send_anime_2"),
//         SobotKitGetImage(@"zcicon_pop_voice_send_anime_3"), nil];
//        [anniminViewRight startAnimating];
        
    }else{
        anniminViewLeft.hidden = NO;
        anniminViewRight.hidden = YES;
        anniminViewLeft.animationImages =
        [NSArray arrayWithObjects:
         SobotKitGetImage(@"zcicon_recording_volum0"),
         SobotKitGetImage(@"zcicon_recording_volum1"),
         SobotKitGetImage(@"zcicon_recording_volum2"),
         SobotKitGetImage(@"zcicon_recording_volum3"),
         SobotKitGetImage(@"zcicon_recording_volum4"),
         SobotKitGetImage(@"zcicon_recording_volum5"),
         SobotKitGetImage(@"zcicon_recording_volum6"),
         SobotKitGetImage(@"zcicon_recording_volum7"),nil];
        [anniminViewLeft startAnimating];
        
//        anniminViewRight.animationImages =
//        [NSArray arrayWithObjects:
//         SobotKitGetImage(@"zcicon_recording_volum0"),
//         SobotKitGetImage(@"zcicon_recording_volum1"),
//         SobotKitGetImage(@"zcicon_recording_volum2"),
//         SobotKitGetImage(@"zcicon_recording_volum3"),
//         SobotKitGetImage(@"zcicon_recording_volum4"),
//         SobotKitGetImage(@"zcicon_recording_volum5"), nil];
//        [anniminViewRight startAnimating];
        
    }
}

-(void)changeViewState:(SobotKeyboardRecordState) state{
    recordState = state;
    if(state == RecordPause || state == RecordCancel){
        [tipLabel setTextColor:UIColorFromModeColor(SobotColorTextRed)];
        [self getAnniminImages:YES];
    }else{
        [tipLabel setTextColor:UIColorFromModeColor(SobotColorTextSub)];
        [self getAnniminImages:NO];
    }
}


/**
 *  显示弹出层
 */
- (void)showInView{
    self.hidden = NO;
    self.alpha = 1;
    
}


-(void)closeRecorder{
    [self->timeLablel setText:[NSString stringWithFormat:@"%d″",0]];
    if(voiceTimer){
        [voiceTimer invalidate];
        voiceTimer = nil;
    }
    recording = NO;
    if(recorder){
        [recorder stop];
    }
    [anniminViewLeft stopAnimating];
    [anniminViewRight stopAnimating];
    
    if(self.levelTimer){
        [self.levelTimer invalidate];
    }
    
    // 后台应用可以继续播放音乐（例如酷狗音乐）,此设置页面会卡顿，影响布局销毁
//    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

-(void)cancelRecordClearFile{
    if(recording){
        [voiceTimer invalidate];
        recording = NO;
        [recorder stop];
        [anniminViewLeft stopAnimating];
        [anniminViewRight stopAnimating];
        if(self.levelTimer){
            [self.levelTimer invalidate];
        }
        
//                [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    }
    // 取消发送，删除文件
    sobotDeleteFileOrPath([tmpFile path]);
    if(_delegate && [_delegate respondsToSelector:@selector(recordCompleteType:videoDuration:)]){
        [self->_delegate recordCompleteType:RecordCancel videoDuration:[self currentTime]];
    }
     [[NSNotificationCenter defaultCenter] postNotificationName:@"ZCRecordPlayer_stop" object:nil];
}

/**
 *  关闭弹出层
 */
- (void)dismissRecordView{
    __block SobotKeyboardRecordView *weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [weakSelf closeRecorder];
        if (finished) {
            self.alpha = 1;
            self.hidden = YES;
        }
    }];
}

-(void)didChangeState:(SobotKeyboardRecordState) state{
    switch (state) {
        case RecordStart:
        {
            if(voiceTimer==nil){
                [timeLablel setText:[NSString stringWithFormat:@"0″"]];
                // 先执行一次
                [self timerDiscount];
                voiceTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerDiscount) userInfo:nil repeats:YES];
                
//                self.levelTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateMeter) userInfo:nil repeats:YES];

            }else{
                [voiceTimer setFireDate:[NSDate date]];
                
//                if(self.levelTimer){
//                    [self.levelTimer setFireDate:[NSDate date]];
//                }
            }
            
            NSMutableParagraphStyle *style =  [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            style.alignment = NSTextAlignmentCenter;
//            style.firstLineHeadIndent = 10.0f;
            style.lineSpacing = [ZCUIKitTools zcgetChatLineSpacing];
            NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:SobotKitLocalString(@"松开发送，上滑取消") attributes:@{ NSParagraphStyleAttributeName : style}];
            tipLabel.attributedText = attrText;
            
            [self changeViewState:state];
            
            if (!recording) {
                recording = YES;
//                NSString *fileName=[NSString stringWithFormat:@"%ldtempAudio.wav",(long)[[NSDate date] timeIntervalSince1970]];
//                tmpFile = [NSURL fileURLWithPath:sobotGetTempFilePath(fileName)];
                NSString * fname = [NSString stringWithFormat:@"/sobot/audio300%ld.wav",(long)[NSDate date].timeIntervalSince1970];
                sobotCheckPathAndCreate(sobotGetDocumentsFilePath(@"/sobot/"));
                NSString *filePath=sobotGetDocumentsFilePath(fname);
                tmpFile = [NSURL fileURLWithPath:filePath];
                [self startForFilePath:tmpFile];
                [recorder prepareToRecord];
                
            }
            if(!recorder.isRecording){
                [recorder record];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ZCRecordPlayer_start" object:nil];
            if(_delegate && [_delegate respondsToSelector:@selector(recordCompleteType:videoDuration:)]){
                [_delegate recordCompleteType:RecordStart videoDuration:0];
            }
        }
           
            break;

        case RecordPause:
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ZCRecordPlayer_stop" object:nil];
           
            NSMutableParagraphStyle *style =  [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            style.alignment = NSTextAlignmentCenter;
            style.lineSpacing = [ZCUIKitTools zcgetChatLineSpacing];
            NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:SobotKitLocalString(@"松开 取消") attributes:@{ NSParagraphStyleAttributeName : style}];
            tipLabel.attributedText = attrText;
            
            
            [self changeViewState:state];
        }
            
            break;
        case RecordCancel:
            if(recording){
                [voiceTimer invalidate];
                recording = NO;
                [recorder stop];
                [anniminViewLeft stopAnimating];
                [anniminViewRight stopAnimating];
                
//                [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
            }
            // 取消发送，删除文件
            sobotDeleteFileOrPath([tmpFile path]);
            
            if(_delegate && [_delegate respondsToSelector:@selector(recordCompleteType:videoDuration:)]){
                [self->_delegate recordCompleteType:RecordCancel videoDuration:[self currentTime]];
            }
             [[NSNotificationCenter defaultCenter] postNotificationName:@"ZCRecordPlayer_stop" object:nil];
            break;
        case RecordComplete:
            if(recording){
                [voiceTimer invalidate];
                recording = NO;
                [recorder stop];
                [anniminViewLeft stopAnimating];
                [anniminViewRight stopAnimating];
                
                // 后台应用可以继续播放音乐（例如酷狗音乐）
//                [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
                
                
                
                NSError *error;
                audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:tmpFile
                                                                  error:&error];
                CGFloat duration=audioPlayer.duration;
                // 至少是1秒
                if(duration>=1){
                    if(_delegate && [_delegate respondsToSelector:@selector(recordComplete:videoDuration:)]){
                        [_delegate recordComplete:[tmpFile path] videoDuration:duration];
                    }
                }else{
//                    [tipLabel setText:SobotKitLocalString(@"录制时间过短")];
//                    [tipLabel setBackgroundColor:UIColorFromModeColor(SobotColorRed)];
                    [SobotProgressHUD showImage:SobotKitGetImage(@"zciocn_warning_circle") status:SobotKitLocalString(@"录制时间过短")];
                    [timeLablel setText:[NSString stringWithFormat:@"00:00"]];
                    
                    // 删除发送的空语音
                    [self->_delegate recordCompleteType:RecordCancel videoDuration:0];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ZCRecordPlayer_stop" object:nil];
            }
            break;
        default:
            break;
    }
}

- (void)updateMeter {
    [recorder updateMeters];
    
    // 获取平均功率（以分贝为单位）
    float averagePower = [recorder averagePowerForChannel:0];
    
    // 转换为线性比例
    float linearPower = pow(10, (0.05 * averagePower));
    
//    float peakPower = [recorder peakPowerForChannel:0]; // 获取峰值分贝值
    
    self.waveView.amplitude = 50.0*linearPower; // 设置波动幅度
    self.waveView.frequency = 2.0;  // 设置波动频率
    [self.waveView setNeedsDisplay];
}

-(NSTimeInterval)currentTime{
    if(recorder){
        return recorder.currentTime;
    }
    return 0;
}

//动态显示时间
-(void)timerDiscount{
    int duration=(int)recorder.currentTime;
    // 这里四舍五入一下，0到1秒的时候 和计时器的时间相差0.5秒内 页面显示录音时长 反应慢1秒
    CGFloat flotDuration = round(recorder.currentTime);
    duration = (int)flotDuration;
    // 当时间大于1s的时候
    if (duration == 1) {
     //   NSLog(@"当前时间为1s");
        if(_delegate && [_delegate respondsToSelector:@selector(recordComplete:videoDuration:)]){
            
            [_delegate recordCompleteType:RecordStart videoDuration:1.0f];
        }
    }
    
    // 录音振动波形
//    [self updateWaveform];
    
    if(duration>50){
        int limit=60-duration;
        NSString *text=[NSString stringWithFormat:@"%@″",[NSString stringWithFormat:@"%@ %d",SobotKitLocalString(@"倒计时"),limit]];
        
//        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:text];
//        [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(text.length-2,2)];
//        timeLablel.attributedText=str;
        [lastTimeLab setText:text];
        lastTimeLab.hidden = NO;
        [timeLablel setText:[NSString stringWithFormat:@"%d″",duration]];
    }else{
        [timeLablel setText:[NSString stringWithFormat:@"%d″",duration]];
        [lastTimeLab setText:@""];
        lastTimeLab.hidden = YES;
    }
    
    //大于60秒，停止录音
    if(duration>=60){
        if (recordState == RecordPause || recordState == RecordCancel) {
            [self cancelRecordClearFile];
            [self dismissRecordView];
            return;
        }
        [self didChangeState:RecordComplete];
        //[tipLabel setText:VoiceMaxTips];
//        [tipLabel setText:SobotKitLocalString(@"录音时间过长")];
//        [tipLabel setBackgroundColor:UIColorFromModeColor(SobotColorRed)];
        // 新版UI不在显示了
//        [SobotProgressHUD showInfoWithStatus:SobotKitLocalString(@"录音时间过长")];
        [timeLablel setText:[NSString stringWithFormat:@"00:59"]];
        [self dismissRecordView];
    }
}



- (void)startForFilePath:(NSURL *)filePath {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        // [SobotLog logDebug:@"audioSession: %@ %d %@", [err domain], (int)[err code], [[[err userInfo] description]];
        return;
    }
    [audioSession setActive:YES error:&err];

    err = nil;
    if(err){
//        [SobotLog logDebug:@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]];
        return;
    }
    
    err = nil;
    
    NSData *audioData = [NSData dataWithContentsOfFile:[tmpFile path] options: 0 error:&err];
    if(audioData)
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:[tmpFile path] error:&err];
    }
    
    err = nil;
    recorder = [[AVAudioRecorder alloc] initWithURL:tmpFile settings:[SobotUITools getAudioRecorderSettingDict] error:&err];
    if(!recorder){

        
        return;
    }
    
    [recorder setDelegate:self];
    [recorder prepareToRecord];
    
    [recorder record];
    recorder.meteringEnabled = YES;
    
    //时间
    [recorder recordForDuration:(NSTimeInterval) 60];
}

//-(void)layoutSubviews{
//    [super layoutSubviews];
//    CGRect sf = self.frame;
//    if (sf.size.height >0) {
//        // 处理渐变
//        NSMutableArray *colorsArr = [NSMutableArray array];
//        [colorsArr addObject:@"#00000000"];
//        [colorsArr addObject:@"#ffffff"];
//        [colorsArr addObject:@"#ffffff"];
//        self.backgroundColor = [self gradientColorWithSize:self.frame.size colorArr:colorsArr];
//    }
//}


@end
