//
//  SobotDataTimePickView.h
//  SobotCommon
//
//  Created by zhangxy on 2024/6/25.
// 日期+时间 + 时区

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SobotDataTimePickView : UIView

// 查询时区的服务域名
@property (nonatomic,copy) NSString *server_host;

// 默认为1显示，0不显示时区，1显示时区
@property (nonatomic,assign) int region;
@property (nonatomic,strong) NSString *language;

// 是不是必填，如果必填，当没有选择时区的时候，不允许消失
@property (nonatomic,assign) BOOL isMustFlag;

// 默认拼接yyyy-MM-dd HH:mm:ss,设置YES后，返回yyyy-MM-dd HH:mm
@property (nonatomic,assign) BOOL existMinute;

// 如果已经有选中的时区，可以配置
@property (nonatomic,strong)NSDictionary *checkedTimeZone;


// 提交按钮颜色
@property (nonatomic,copy) NSString *pageTitle;
@property (nonatomic,copy) UIColor *btnTitleColor;
@property (nonatomic,copy) UIColor *btnBgColor;

// 是否镜像
@property (nonatomic,assign) BOOL isRTL;
// action:0，取消；1；确定
@property (nonatomic,strong) void(^onCommitBlock)(int action,NSString *resultText,NSString *_Nullable timezoneId,id _Nullable timeZone);

- (void)pickViewShow;
- (void)pickViewDismiss;

@end

NS_ASSUME_NONNULL_END
