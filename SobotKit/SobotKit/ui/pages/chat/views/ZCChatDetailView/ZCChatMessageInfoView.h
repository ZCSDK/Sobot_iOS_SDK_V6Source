//
//  ZCChatMessageInfoView.h
//  SobotKit
//
//  Created by zhangxy on 2023/11/23.
//

#import <UIKit/UIKit.h>
#import <SobotCommon/SobotCommon.h>
#import "ZCChatBaseCell.h"

typedef NS_ENUM(NSUInteger, ZCChatMessageInfoViewEvent) {
    ZCChatMessageInfoViewEventOpenUrl,
    ZCChatMessageInfoViewEventOpenVideo,// 打开视频
    ZCChatMessageInfoViewEventOpenFile,// 打开文件
};

@protocol ZCChatMessageInfoViewDelegate <NSObject>

@optional
-(void)onViewEvent:(ZCChatMessageInfoViewEvent)type dict:(NSDictionary *_Nullable)dict obj:(id _Nullable)obj;

//-(void)updateContentHeight:(CGFloat)height;

@end




NS_ASSUME_NONNULL_BEGIN

@interface ZCChatMessageInfoView : UIView

@property(nonatomic,weak) id<ZCChatMessageInfoViewDelegate>delegate;
@property(nonatomic,strong) UILabel *labTopText;
@property(nonatomic,strong) UIView *viewContent;
@property(nonatomic,strong) UILabel *labTopText2;
@property(nonatomic,strong) UILabel *labTopText3;

-(CGFloat )dataToView:(SobotChatMessage *)model;

+(ZCChatMessageInfoView *)createViewUseFactory:(SobotChatMessage *)message;

@end

NS_ASSUME_NONNULL_END
