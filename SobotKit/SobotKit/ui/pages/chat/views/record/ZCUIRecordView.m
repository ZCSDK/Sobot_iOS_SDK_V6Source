//
//  RecordView.m
//  SobotSDK
//
//  Created by 张新耀 on 15/8/12.
//  Copyright (c) 2015年 sobot. All rights reserved.
//

#import "ZCUIRecordView.h"
#import "ZCUICore.h"
#import <SobotChatClient/SobotChatClient.h>
#import "ZCUIKitTools.h"

#define RecordViewWidth  180
#define RecordViewHeight 180

@implementation ZCUIRecordView{
    UIView      *topView;
    UIImageView *anniminView;
    UIImageView *pauseView;
    UILabel     *timeLablel;
    UILabel     *tipLabel;
    
    NSTimer     *voiceTimer;
    
    //开始录音
    NSURL           *tmpFile;
    AVAudioRecorder *recorder;
    BOOL            recording;
    AVAudioPlayer   *audioPlayer;
    UIView *clearView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (ZCUIRecordView *)initRecordView:(id<ZCUIRecordDelegate>)delegate cView:(UIView *)view{
    self=[super init];
    if(self){
        //初始化背景视图，添加手势
        self.frame = CGRectMake((view.frame.size.width-RecordViewWidth)/2, (view.frame.size.height-RecordViewHeight)/2, RecordViewWidth, RecordViewHeight);
//        self.backgroundColor = UIColorFromRGB(0xE6566573);
        self.backgroundColor = UIColorFromModeColorAlpha(SobotColorBlack, 0.9);

        self.layer.cornerRadius  = 5.0f;
        self.layer.masksToBounds = YES;
        
        [self createView];
        
        _delegate=delegate;
    }
    return self;
}

-(void)createView{
    topView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, RecordViewWidth, 100)];
    [topView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:topView];
    
    
    UIImageView *voiceTagView=[[UIImageView alloc] initWithFrame:CGRectMake((RecordViewWidth)/2 - 40 - 5, 40, 40, 60)];
//    [voiceTagView setContentMode:UIViewContentModeScaleAspectFit];
    [voiceTagView setImage:SobotKitGetImage(@"zcicon_recording_mike")];
//    voiceTagView.backgroundColor = [UIColor redColor];
    [topView addSubview:voiceTagView];
    
    anniminView=[[UIImageView alloc] initWithFrame:CGRectMake((RecordViewWidth)/2 + 10, 10, 30, 120)];
//    anniminView.backgroundColor = [UIColor blueColor];
    [anniminView setContentMode:UIViewContentModeScaleAspectFit];
    anniminView.animationImages = [NSArray arrayWithObjects:
                                   SobotKitGetImage(@"zcicon_recording_volum0"),
    SobotKitGetImage(@"zcicon_recording_volum1"),
    SobotKitGetImage(@"zcicon_recording_volum2"),
    SobotKitGetImage(@"zcicon_recording_volum3"),
    SobotKitGetImage(@"zcicon_recording_volum4"),
    SobotKitGetImage(@"zcicon_recording_volum5"), nil];
    anniminView.animationDuration = .8f;
    anniminView.animationRepeatCount = 0;
    [topView addSubview:anniminView];
    [anniminView startAnimating];
    
    pauseView=[[UIImageView alloc] initWithImage:SobotKitGetImage(@"zcicon_recording_cancel")];
    [pauseView setContentMode:UIViewContentModeScaleAspectFit];
    [pauseView setFrame:CGRectMake((RecordViewWidth-166)/2, 30, 166, 70)];
    [self addSubview:pauseView];
    pauseView.hidden=YES;
    
    timeLablel=[[UILabel alloc] initWithFrame:CGRectMake(0, 105, RecordViewWidth, 25)];
    [timeLablel setBackgroundColor:[UIColor clearColor]];
    [timeLablel setTextColor:[UIColor whiteColor]];
    [timeLablel setFont:SobotFont12];
    timeLablel.layer.cornerRadius  = 3.0f;
    timeLablel.layer.masksToBounds = YES;
    [timeLablel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:timeLablel];
    
    
    tipLabel=[[UILabel alloc] initWithFrame:CGRectMake(25, 135, RecordViewWidth-50, 25)];
    [tipLabel setBackgroundColor:[UIColor lightGrayColor]];
    [tipLabel setFont:SobotFont12];
    tipLabel.layer.cornerRadius  = 3.0f;
    tipLabel.layer.masksToBounds = YES;
    tipLabel.numberOfLines = 0;
    [tipLabel setTextAlignment:NSTextAlignmentCenter];
    [tipLabel setTextColor:[UIColor whiteColor]];
    tipLabel.layer.borderColor = [UIColor clearColor].CGColor;
    tipLabel.layer.borderWidth = 2;
    [self addSubview:tipLabel];
}


/**
 *  显示弹出层
 *
 *  @param view 显示在那个view上
 */
- (void)showInView:(UIView *)view{
    clearView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height- XBottomBarHeight-49)];
    [clearView setBackgroundColor:[UIColor clearColor]];
    [view addSubview:clearView];
    [view addSubview:self];
}



/**
 *  关闭弹出层
 */
- (void)dismissRecordView{
    if (!sobotIsNull(clearView)) {
        [clearView removeFromSuperview];
        clearView = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    __block ZCUIRecordView *weakSelf = self;
    [UIView animateWithDuration:1.0f animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [weakSelf removeFromSuperview];
        }
    }];
}

-(void)didChangeState:(SobotKeyboardRecordState) state{
    CGRect SF = self.frame;
    
    switch (state) {
        case RecordStart:
        {
            if(voiceTimer==nil){
                [timeLablel setText:[NSString stringWithFormat:@"0″"]];
                voiceTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerDiscount) userInfo:nil repeats:YES];
            }else{
                [voiceTimer setFireDate:[NSDate date]];
            }
           
            topView.hidden   = NO;
            pauseView.hidden = YES;
//            [tipLabel setText:ZCSTLocalString(@"手指上滑，取消发送")];
            
            NSMutableParagraphStyle *style =  [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            style.alignment = NSTextAlignmentCenter;
//            style.firstLineHeadIndent = 10.0f;
            style.headIndent = 10.0f;
            style.tailIndent = -10.0f;
            NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:SobotKitLocalString(@"手指上滑，取消发送") attributes:@{ NSParagraphStyleAttributeName : style}];
            tipLabel.attributedText = attrText;
            tipLabel.layer.borderColor = UIColor.clearColor.CGColor;
            
            CGFloat SH = [SobotUITools getHeightContain:tipLabel.text font:SobotFont12 Width:RecordViewWidth-30];
            SH = SH +16;
            CGRect TF = tipLabel.frame;
            TF.size.height = SH;
            tipLabel.frame = TF;
            
            if (SH > 30) {
                if (SF.size.height != RecordViewHeight + SH -30) {
                    SF.size.height = RecordViewHeight + SH -30;
                    SF.origin.y = SF.origin.y - (SH -30)/2;
                    self.frame = SF;
                }
            }
            
            [tipLabel setBackgroundColor:[UIColor clearColor]];
            [anniminView startAnimating];
            
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
            topView.hidden   = YES;
            pauseView.hidden = NO;
//            [tipLabel setText:ZCSTLocalString(@"松开手指，取消发送")];
            NSMutableParagraphStyle *style =  [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            style.alignment = NSTextAlignmentCenter;
//            style.firstLineHeadIndent = 10.0f;
            style.headIndent = 10.0f;
            style.tailIndent = -10.0f;
            NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:SobotKitLocalString(@"松开手指，取消发送") attributes:@{ NSParagraphStyleAttributeName : style}];
            tipLabel.attributedText = attrText;
//            tipLabel.layer.borderColor = UIColorFromRGB(BgVoiceRedColor).CGColor;
            [tipLabel setBackgroundColor:UIColorFromModeColor(SobotColorRed)];
//            [tipLabel setBackgroundColor:UIColorFromRGB(BgVoiceRedColor)];
            
            CGFloat SH2 = [SobotUITools getHeightContain:tipLabel.text font:SobotFont12 Width:RecordViewWidth-55];
            SH2 = SH2 +16; // 上下间距
            CGRect TF2 = tipLabel.frame;
            TF2.size.height = SH2;
            tipLabel.frame = TF2;
            if (SH2 > 30) {
                if (SF.size.height != RecordViewHeight + SH2 -30) {
                    SF.size.height = RecordViewHeight + SH2 -30;
                    SF.origin.y = SF.origin.y - (SH2 -30)/2;
                    self.frame = SF;
                }
            }
        }
            
            break;
        case RecordCancel:
            if(recording){
                [voiceTimer invalidate];
                recording = NO;
                [recorder stop];
                [anniminView stopAnimating];
                [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
            }
            // 取消发送，删除文件
            sobotDeleteFileOrPath([tmpFile path]);
            
            if(_delegate && [_delegate respondsToSelector:@selector(recordCompleteType:videoDuration:)]){
#pragma mark - 这里加延时的原因  当用户秒点 “按住 说话” 之后秒释放 创建的闪烁语音cell还没有在主线程上UI刷新完成，这时候销毁的事件已经触发，导致语音闪烁cell并没有真正的移除掉
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self->_delegate recordCompleteType:RecordCancel videoDuration:[self currentTime]];
                });
            }
             [[NSNotificationCenter defaultCenter] postNotificationName:@"ZCRecordPlayer_stop" object:nil];
            break;
        case RecordComplete:
            if(recording){
                [voiceTimer invalidate];
                recording = NO;
                [recorder stop];
                [anniminView stopAnimating];
                
//                AVAudioSession * audioSession = [AVAudioSession sharedInstance];
//                [audioSession setActive:NO error:nil];
//                [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
                
                // 后台应用可以继续播放音乐（例如酷狗音乐）
                [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
                
//                NSData *data=[NSData dataWithContentsOfURL:tmpFile];
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
                    //[self.window.rootViewController.view makeToast:VoiceMinTips duration:1 position:@"center"];
                    topView.hidden   = YES;
                    pauseView.hidden = NO;
                    pauseView.image = SobotKitGetImage(@"zcicon_recording_timeshort");
                   // [tipLabel setText:VoiceMinTips];
                    [tipLabel setText:SobotKitLocalString(@"录制时间过短")];
//                    [tipLabel setBackgroundColor:UIColorFromRGB(BgVoiceRedColor)];
//                    tipLabel.layer.borderColor = UIColorFromRGB(BgVoiceRedColor).CGColor;
                    [tipLabel setBackgroundColor:UIColorFromModeColor(SobotColorRed)];
                    [timeLablel setText:[NSString stringWithFormat:@"00:00"]];
                    
                    CGFloat SH3 = [SobotUITools getHeightContain:tipLabel.text font:SobotFont12 Width:RecordViewWidth-55];
                    CGRect TF3 = tipLabel.frame;
                    TF3.size.height = SH3;
                    tipLabel.frame = TF3;
                    
                    if (SH3 > 30) {
                        if (SF.size.height != RecordViewHeight + SH3 -30) {
                            SF.size.height = RecordViewHeight + SH3 -30;
                            SF.origin.y = SF.origin.y - (SH3 -30)/2;
                            self.frame = SF;
                        }
                    }
                    
                    // 删除发送的空语音
#pragma mark - 这里加延时的原因  当用户秒点 “按住 说话” 之后秒释放 创建的闪烁语音cell还没有在主线程上UI刷新完成，这时候销毁的事件已经触发，导致语音闪烁cell并没有真正的移除掉
                    if (_delegate && [_delegate respondsToSelector:@selector(recordCompleteType:videoDuration:)]) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            SLog(@"触发了取消的代理事件", nil);
                            [self->_delegate recordCompleteType:RecordCancel videoDuration:0];
                        });
                    }
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ZCRecordPlayer_stop" object:nil];
            }
            break;
        default:
            break;
    }
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
    // 当时间大于1s的时候
    if (duration == 1) {
     //   NSLog(@"当前时间为1s");
        if(_delegate && [_delegate respondsToSelector:@selector(recordComplete:videoDuration:)]){
            
            [_delegate recordCompleteType:RecordStart videoDuration:1.0f];
        }
    }
    
    if(duration>50){
        int limit=60-duration;
        NSString *text=[NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@ %d",SobotKitLocalString(@"倒计时"),limit]];
        
//        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:text];
//        [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(text.length-2,2)];
//        timeLablel.attributedText=str;
        [timeLablel setText:text];
    }else{
        [timeLablel setText:[NSString stringWithFormat:@"%d″",duration]];
    }
    
    //大于60秒，停止录音
    if(duration>=60){
        [self didChangeState:RecordComplete];
        
//        [self.window.rootViewController.view makeToast:VoiceMaxTips duration:1 position:@"center"];
        topView.hidden   = YES;
        pauseView.hidden = NO;
        pauseView.image = SobotKitGetImage(@"zcicon_recording_timeshort");
        //[tipLabel setText:VoiceMaxTips];
        [tipLabel setText:SobotKitLocalString(@"录音时间过长")];
        [tipLabel setBackgroundColor:UIColorFromModeColor(SobotColorRed)];
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


@end
