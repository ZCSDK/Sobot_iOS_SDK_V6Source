//
//  SobotKeyboardRecordView.h
//  SobotKit
//
//  Created by zhangxy on 2025/1/16.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

NS_ASSUME_NONNULL_BEGIN


/**
 *  录音状态
 */
typedef NS_ENUM(NSInteger, SobotKeyboardRecordState) {
    /** 开始录音或接着录音 */
    RecordStart=1,
    /** 暂停录音 */
    RecordPause=2,
    /** 录音完成 */
    RecordComplete=3,
    /** 取消录音 */
    RecordCancel=4,
};

/**
 *  ZCUIRecordDelegate
 */
@protocol SobotKeyboardRecordDelegate <NSObject>

/**
 *  录音结束
 *
 *  @param filePath 录音文件路径
 *  @param duration 音频时长
 */
-(void)recordComplete:(NSString *)filePath videoDuration:(CGFloat )duration;

/**
 *  开始录音 取消录音 页面cell的闪烁动画，以及取消发送之后删除 cell的事件
 *  @param  duration  录音时长
 *  @param  type  开始录音/取消录音
 *
 */
- (void)recordCompleteType:(SobotKeyboardRecordState) type videoDuration:(CGFloat)duration;

@end

/**
 *  录音view
 *  处理录音事件
 */
@interface SobotKeyboardRecordView : UIView<AVAudioRecorderDelegate>

// 录音成功代理，录音没有取消时调用
@property (nonatomic , retain) id<SobotKeyboardRecordDelegate> delegate;

/**
 *  初始化view
 *
 *  @param delegate 录音完成，返回录音文件
 *  @return 初始化对象
 */
- (SobotKeyboardRecordView *)initRecordView:(id<SobotKeyboardRecordDelegate>) delegate;


/**
 *  显示弹出
 */
- (void)showInView;

/**
 *  取消View
 */
- (void)dismissRecordView;

/**
 *  改变录音状态
 *
 *  @param state 当前显示的状态
 */
-(void)didChangeState:(SobotKeyboardRecordState) state;

/**
 *   当前时间
 */
-(NSTimeInterval) currentTime;

@end
NS_ASSUME_NONNULL_END
