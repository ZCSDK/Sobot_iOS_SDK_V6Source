//
//  ZCChatBaseCell.h
//  SobotKit
//
//  Created by zhangxy on 2022/9/1.
//

#import <UIKit/UIKit.h>
#import <SobotCommon/SobotCommon.h>
#import "ZCUIKitTools.h"
#import "ZCUICore.h"
#import <SobotChatClient/SobotChatClient.h>

/**聊天消息cell的点击类型*/
typedef NS_ENUM(NSInteger,ZCChatCellClickType) {
    /** 点击图片 */
    ZCChatCellClickTypeTouchImageNO      = 1,
    /** 点击头像 （未使用）*/
    ZCChatCellClickTypeHeader            = 2,
    /** 重新发送 */
    ZCChatCellClickTypeReSend            = 3,
    /** 播放声音 */
    ZCChatCellClickTypePlayVoice         = 4,
    /** 听筒播放 （未使用）*/
    ZCChatCellClickTypeReceiverPlayVoice = 5,
    /** 打开Web */
    ZCChatCellClickTypeOpenURL           = 6,
    /** 引导答案 */
    ZCChatCellClickTypeItemChecked       = 7,
    /** 点击图片 */
    ZCChatCellClickTypeTouchImageYES     = 8,
    /** 转人工 机器人回复cell下面转人工按钮*/
    ZCChatCellClickTypeConnectUser       = 9,
    /** 满意度评价 */
    ZCChatCellClickTypeSatisfaction      = 10,
    /** 留言 */
    ZCChatCellClickTypeLeaveMessage      = 11,
    /** 发送商品信息 */
    ZCChatCellClickTypeSendGoosText      = 12,
    /** 展示复制成功 */
    ZCChatCellClickTypeShowToast         = 13,
    /** 踩 */
    ZCChatCellClickTypeStepOn            = 14,
    /** 顶 */
    ZCChatCellClickTypeTheTop            = 15,
    /** collectionCell 的点击发送内容 */
    ZCChatCellClickTypeCollectionSendMsg = 16,
    /** 展开和收起 */
    ZCChatCellClickTypeCollectionBtnSend = 17,
    /** 点击技能组item */
    ZCChatCellClickTypeGroupItemChecked  = 18,
    /** 多轮会话1511 点击发送 */
    ZCChatCellClickTypeItemGuide         = 19,
    /*u取消发送文件*/
    ZCChatCellClickTypeItemCancelFile    = 21,
    /*打开地图*/
    ZCChatCellClickTypeItemOpenLocation  = 22,
    /** 点击提示cell 前往留言记录页面 */
    ZCChatCellClickTypeLeaveRecordPage   = 23,
    
    /**** 点击通告 展开和收起****/
    ZCChatCellClickTypeNotice            = 24,
    
    /**** 热点引导，点击换一组****/
    ZCChatCellClickTypeNewDataGroup      = 25,
    /**** 热点引导，新会话 ****/
    ZCChatCellClickTypeNewSession        = 26,
    /**** 机器人点踩，发送提示转人工消息 ****/
    ZCChatCellClickTypeInsterTurn        = 27,
    // 显示所有敏感信息
    ZCChatCellClickTypeShowSensitive     = 28,
    // 拒绝发送敏感信息
    ZCChatCellClickTypeRefuseSend        = 29,
    // 同意发送敏感信息
    ZCChatCellClickTypeAgreeSend         = 30,
    //点击了小程序事件
    ZCChatCellClickTypeAppletAction      = 31,
    // 打开富文本消息中的文件
    ZCChatCellClickTypeOpenFile          = 32,
    // 打开富文本中的音频
    ZCChatCellClickTypeOpenAudio         = 33,
    // 继续排队
    ZCChatCellClickTypeItemContinueWaiting = 34,
};

/**
 *  ZCChatCellDelegate
 */
@protocol ZCChatCellDelegate <NSObject>

/**
 *  聊天消息cell点击的代理方法
 *
 *  @param model  消息体
 *  @param type   聊天消息cell的点击类型
 *  @param object 代理
 */
-(void)cellItemClick:(SobotChatMessage * _Nullable)model type:(ZCChatCellClickType) type text:(NSString * _Nullable)text obj:(id _Nullable )object;
@optional
// 评价cell使用
- (void)cellItemClick:(int)satifactionType isResolved:(int)isResolved rating:(int)rating problem:(NSString * _Nullable) problem scoreFlag:(int)scoreFlag;

@end

// 气泡外部间隔
#define ZCChatMarginHSpace 16
#define ZCChatMarginVSpace 10

// 气泡内容四周的边距
#define ZCChatPaddingVSpace 12
#define ZCChatPaddingHSpace 18

// 拼接内容相邻空间间距
#define ZCChatCellItemSpace 5
#define ZCChatRichCellItemSpace 10
NS_ASSUME_NONNULL_BEGIN

@interface ZCChatBaseCell : UITableViewCell<SobotEmojiLabelDelegate,SobotXHImageViewerDelegate>



/**
 *  显示时间
 */
@property (nonatomic,strong) UILabel                  *lblTime;


/**
 *  头像
 */
@property (nonatomic,strong) SobotImageView            *ivHeader; // 2.8.0 去掉


/**
 *
 *   留言转离线消息图标  2.8.0 改成文字
 *
 **/
@property (nonatomic,strong) UILabel * leaveIcon;

/**
 *  名称
 */
@property (nonatomic,strong) UILabel                  *lblNickName; // 2.8.0 去掉


@property(nonatomic,strong) SobotEmojiLabel *lblSugguest;

/**
 *  发送动画
 */
@property (nonatomic,strong) UIActivityIndicatorView  *activityView;

/**
 *  重新发送
 */
@property (nonatomic,strong) UIButton                 *btnReSend;

/**
 *  转人工
 */
@property (nonatomic,strong) UIButton                 *btnTurnUser;

/**
 *
 *  转人工 顶踩 按钮的背景View
 *
 **/
@property (nonatomic,strong) UIView                  *bottomBgView;

/**
 *  顶
 */
@property (nonatomic,strong) UIButton                 *btnTheTop;

/**
 *  踩
 */
@property (nonatomic,strong) UIButton                 *btnStepOn;


/**
 *  气泡
 */
@property (nonatomic,strong) UIImageView              *ivBgView;

/**
 *  映射view,做背景使用
 */
@property (nonatomic,strong) UIImageView    *ivLayerView;


/**
 *  当前展示的消息体
 */
@property (nonatomic,strong) SobotChatMessage         *tempModel;

/**
 *  是否是右边
 */
@property (nonatomic,assign) BOOL                     isRight;

/**
 *  最大宽度
 */
@property (nonatomic,assign) CGFloat                  maxWidth;

/**
 *  页面的宽度
 */
@property (nonatomic,assign) CGFloat                  viewWidth;


/**
 *  内边距宽度
 */
@property (nonatomic,assign) UIEdgeInsets contentPadding;

/**
 *  ZCChatCellDelegate的代理
 */
@property (nonatomic,weak) id<ZCChatCellDelegate>   delegate;

/**
 *  其它点击问题
 */
@property (nonatomic,strong) NSString     *callURL;



+(SobotEmojiLabel *) createRichLabel;

+(BOOL) isRightChat:(SobotChatMessage *) model;
+(void)configHtmlText:(NSString *) text label:(SobotEmojiLabel *)label right:(BOOL) isRight;

// 查询链接信息
-(void)getLinkValues:(NSString *) link result:(void(^)(NSString *title,NSString *desc,NSString *icon)) block;

+(void)configHtmlText:(NSString *) text label:(SobotEmojiLabel *)label right:(BOOL) isRight isTip:(BOOL)isTip;

-(void)initDataToView:(SobotChatMessage *) message time:(NSString *) showTime;

-(void)setChatViewBgState:(CGSize) size;


-(void)doClickURL:(NSString *)url text:(NSString * )htmlText;


-(void)playVideo:(SobotButton *)btn;
-(void) imgTouchUpInside:(UITapGestureRecognizer *)recognizer;

- (void)doLongPress:(UIGestureRecognizer *)recognizer;
@end

NS_ASSUME_NONNULL_END
