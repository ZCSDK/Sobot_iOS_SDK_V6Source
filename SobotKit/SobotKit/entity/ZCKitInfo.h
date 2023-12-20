//
//  ZCKitInitInfo.h
//  SobotKit
//
//  Created by zhangxy on 15/11/13.
//  Copyright © 2015年 zhichi. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class ZCProductInfo;
@class ZCOrderGoodsModel;

/**
 *  配置初始化自定义类（UI配置相关）
 *  自定义字体（可选） 自定义背景、边框线颜色（可选）
 */
@interface ZCKitInfo : NSObject
/**
 *   调整行间距 ，默认为 0
 */
@property (nonatomic,assign) NSInteger lineSpacing;

/**
 * 机器人引导语 行间距，默认为 0
 */
@property (nonatomic,assign) NSInteger guideLineSpacing;

/**
 *  是否设置为暗黑模式 默认为0,跟随系统设置, 1暗黑，2普通模式
 */
@property (nonatomic,assign) NSInteger themeStyle;

/**
 * 暗黑模式时自定义颜色是否失效，默认为YES不使用
 */
@property (nonatomic,assign) BOOL useDefaultDarkTheme;

/**
 *  链接地址正则表达式
 *  默认为：
    @"(https?|ftp|file)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]"
 */
@property (nonatomic,strong) NSString *urlRegular;

/**
*  电话号码正则表达式
 *  默认为@"0+\\d{2}-\\d{8}|0+\\d{2}-\\d{7}|0+\\d{3}-\\d{8}|0+\\d{3}-\\d{7}|1+[34578]+\\d{9}|\\+\\d{2}1+[34578]+\\d{9}|400\\d{7}|400-\\d{3}-\\d{4}|\\d{11}|\\d{10}|\\d{8}|\\d{7}"
 * 例如：82563452、01082563234、010-82543213、031182563234、0311-82563234
 、+8613691080322、4008881234、400-888-1234
 */
@property (nonatomic,strong) NSString *telRegular;

/**
 * 自定义换业务(切换机器人)文案
 */
@property (nonatomic,strong) NSString *changeBusinessStr;

/**
 *  是否有返回提示，默认为 NO
 */
@property (nonatomic,assign) BOOL isShowReturnTips;

/**
 *  push后隐藏 BottomBar
 *  vc.hidesBottomBarWhenPushed = 设定值，默认YES
 */
@property (nonatomic,assign) BOOL ishidesBottomBarWhenPushed;

/**
 *  留言完成后，是否 显示 回复按钮
 *  默认为 yes  , 可以回复
 */
@property (nonatomic,assign) BOOL leaveCompleteCanReply;

/**
 *  已完成留言详情界面：返回时是否弹出服务评价窗口(只会第一次返回弹，下次返回不会再弹)
 *  默认为 NO   , 不主动提醒
 */
@property (nonatomic,assign) BOOL showLeaveDetailBackEvaluate;

/**
 *  仅支持竖屏
 *  默认为 NO
 */
@property (nonatomic,assign) BOOL isShowPortrait;

/**
 *  仅支持横屏
 *  默认为 NO，如何强制横屏，默认为LandscapeRight
 */
@property (nonatomic,assign) BOOL isShowLandscape;

/**
 *  SDK 页面中使用自定义的导航栏不在使用系统的导航栏（隐藏）
 *  默认 为NO 跟随集成项目
 **/
@property (nonatomic,assign) BOOL navcBarHidden;

/**
 *   人工状态，是否可以发送位置
 【 注意：
 由于各家定位插件特别多，智齿没有实现选择位置功能，所以需要自行传递位置到SDK以及打开显示，步骤如下：
 1、实现messageLinkClick事件（ZCSobot startZCChatVC函数中）
 2、当收到link = sobot://sendlocation 调用智齿接口发送位置信息
 3、当收到link = sobot://openlocation?latitude=xx&longitude=xxx&address=xxx 可根据自己情况处理相关业务】
 **/
//@property (nonatomic,assign) BOOL canSendLocation;

/**
 *   聊天页面底部加号中功能：隐藏评价，默认NO(不隐藏)
 */
@property (nonatomic,assign) BOOL hideMenuSatisfaction;

/**
 * 聊天页面底部加号中功能：隐藏留言，默认NO(不隐藏)
 */
@property (nonatomic,assign) BOOL hideMenuLeave;

/**
 * 聊天页面底部加号中功能：仅隐藏人工状态下的留言，默认NO(不隐藏)
 */
@property (nonatomic,assign) BOOL hideMenuManualLeave;

/**
 * 聊天页面底部加号中功能：隐藏图片，默认NO(不隐藏)
 */
@property (nonatomic,assign) BOOL hideMenuPicture;

/**
 *  聊天页面底部加号中功能：隐藏拍摄，默认NO(不隐藏)
 */
@property (nonatomic,assign) BOOL hideMenuCamera;

/**
 *  聊天页面底部加号中功能：隐藏文件，默认NO(不隐藏)
 */
@property (nonatomic,assign) BOOL hideMenuFile;

/**
 *  导航栏右上角 是否显示 评价按钮  默认不显示
 */
@property (nonatomic,assign) BOOL isShowEvaluation;

/**
 * 导航栏右上角 是否显示 拨号按钮 默认不显示    注意：和isShowEvaluation 互斥 只能设置一个有效
 */
@property (nonatomic,assign) BOOL isShowTelIcon;

/**
 *  设置电话号码
 *  当导航栏右上角 显示 拨号按钮时  （和isShowTelIcon 一起设置有效）
 */
@property (nonatomic,copy) NSString *customTel;

/**
 *  帮助中心添加呼叫电话号码
 */
@property (nonatomic,copy) NSString *helpCenterTel;

/**
 *  帮助中心电话号码按钮字段
 */
@property (nonatomic,copy) NSString *helpCenterTelTitle;

/**
 * 导航栏右上角 是否显示 关闭按钮 默认不显示，关闭按钮，点击后无法监听后台消息
 */
@property (nonatomic,assign) BOOL isShowClose;

/**
 * 是否关闭询前表单（默认为NO，使用系统默认配置）
 */
@property (nonatomic,assign) BOOL isCloseInquiryForm;

// 关闭系统设置RTL功能
@property (nonatomic,assign) BOOL isCloseSystemRTL;
////////////////////////////////////////////////////////////////
#pragma Mark -- 和UI相关的配置参数自定义可选项
////////////////////////////////////////////////////////////////
/**
 *  是否使用Images
 *  默认为NO 未开启
 */
@property (nonatomic,assign) BOOL isUseImagesxcassets;

/**
 *针对关闭按钮，单独设置是否显示评价界面，默认不显示  (同isShowReturnTips 一起设置起效)
 */
@property (nonatomic,assign) BOOL isShowCloseSatisfaction;

/**
 *  评价完人工是否关闭会话（人工满意度评价后释放会话）
 *  默认为NO 未开启
 */
@property (nonatomic,assign) BOOL isCloseAfterEvaluation;

/**
 *  返回时是否开启满意度评价
 *  默认为NO 未开启
 */
@property (nonatomic,assign) BOOL isOpenEvaluation;

/**
 *  返回时开启满意度评价,显示暂不评价
 *  默认为NO 未开启
 */
@property (nonatomic,assign) BOOL canBackWithNotEvaluation;

/**
 * 机器人优先模式，是否直接显示转人工按钮(值为NO时，会在机器人无法回答时显示转人工按钮)，默认，YES
 */
@property (nonatomic,assign) BOOL isShowTansfer;

/**
// *  机器人优先模式，通过记录机器人未知说辞的次数设置是否直接显示转人工按钮
// *  默认 0次。
// */
@property (nonatomic,strong) NSString *unWordsCount;

/**
 *  V6 请在PC工作台配置该功能
// * 是否开启智能转人工,(如输入“转人工”，直接转接人工)
// * 需要隐藏转人工按钮，请参见isShowTansfer和unWordsCount属性
// */
//@property (nonatomic,assign) BOOL isOpenActiveUser;

/**
 V6 请在PC工作台配置该功能
 智能转人工关键字，关键字作为key{@"转人工",@"1",@"R":@"1"}
 */
//@property (nonatomic,strong) NSDictionary *activeKeywords;

/**
 *  自定义快捷入口
 *  填充内容为： NSDictionary
 *  url: 快捷入口链接(点击后会调用初始化linkBock)
 *  title: 按钮标题
 *  lableId: 自定义快捷入口的ID
 **/
@property (nonatomic,strong) NSMutableArray *cusMenuArray;

/**
 * 自定义输入框下方更多(+号图标)按钮下面内容(不会替换原有内容，会在原有基础上追加)
 * 修改人工模式的按钮
 * 填充内容为：ZCLibCusMenu.h
 *  title:按钮名称
 *  url：点击链接(点击后会调用初始化linkBock)
 *  imgName:本地图片名称，如xxx@2x.png,icon=xxx
 */
@property (nonatomic,strong) NSMutableArray *cusMoreArray;

/**
 * 自定义输入框下方更多(+号图标)按钮下面内容(不会替换原有内容，会在原有基础上追加)
 * 修改机器人模式的按钮
 * 填充内容为：ZCLibCusMenu.h
 *  title:按钮名称
 *  url：点击链接(点击后会调用初始化linkBock)
 *  imgName:本地图片名称，如xxx@2x.png,icon=xxx
 */
@property (nonatomic,strong) NSMutableArray *cusRobotMoreArray;

/**
 *  是否开启语音功能
 *  默认开启
 */
@property (nonatomic,assign) BOOL isOpenRecord;

/**
 是否开启机器人语音，（付费，否则语音无法识别）
 默认NO
 */
@property (nonatomic,assign) BOOL isOpenRobotVoice;

////////////////////////////////////////////////////////////////
// 自定义咨询内容，在转接人工成功时，方便用户发送自己咨询的信息，（可选）
// 标题（必填）、页面地址url（必填）、摘要、标签、缩略图url
////////////////////////////////////////////////////////////////

/**
 *   商品卡片信息是否自动发送（转人工成功时，自动发送商品卡片信息）
 *   默认关闭  开启后默认一次有效会话内只发送一次
 */
@property (nonatomic,assign) BOOL isSendInfoCard;

/**
   是否每次都自动发送商品信息 （转人工成功时，自动发送商品卡片信息）
   需要先开启 isSendInfoCard = YES
  （3.0.3版本新增）
 */
@property (nonatomic,assign) BOOL isEveryTimeSendCard;

/**
 *  产品信息
 */
@property(nonatomic,strong) ZCProductInfo *productInfo;
//
///**
// * 需要发送的订单信息
// */
@property(nonatomic,strong) ZCOrderGoodsModel *orderGoodsInfo;

/**
 * 人工后，是否主动发送一条信息
 */
@property(nonatomic,assign) BOOL autoSendOrderMessage;

/**
 * 是否每次都发送订单信息，需要先设置参数 autoSendOrderMessage = YES
 */
@property(nonatomic,assign) BOOL isEveryTimeAutoSend;

/**
 *  是否关闭wkwebview 页面暗夜模式   默认NO 支持暗夜模式，YES 关闭默认适配
 */
@property(nonatomic,assign)BOOL isCloseWKDarkMode;

#pragma mark -- 自定义字体，（可选）
//===========================================================  自定义字体 font ========================================
/**
 *  顶部标题颜色、评价标题
 */
@property (nonatomic,strong) UIFont *titleFont;

/**
 *  副标题字体
 */
@property (nonatomic,strong) UIFont *subTitleFont;

/**
 *  列表标题字体
 */
@property (nonatomic,strong) UIFont *listTitleFont;

/**
 *  各种按钮，网络提醒
 */
@property (nonatomic,strong) UIFont *listDetailFont;

/**
 *  消息提醒(转人工、客服接待等)
 */
@property (nonatomic,strong) UIFont *listTimeFont;

/**
 *  聊天气泡中文字
 */
@property (nonatomic,strong) UIFont *chatFont;

/**
 *  录音按钮的文字
 */
@property (nonatomic,strong) UIFont *voiceButtonFont;

/**
 *  商品详情cell 中title的文字
 */
@property (nonatomic,strong) UIFont *goodsTitleFont;

/**
 *  商品详情cell中 摘要的文字
 *
 */
@property (nonatomic,strong) UIFont *goodsDetFont;

/**
 * 帮助中心 标题font
 */
@property (nonatomic,strong) UIFont *scTopTextFont;


//=======================================================  font end ================================================


#pragma mark -- 自定义背景、边框线颜色，（可选）
//=======================================================  自定义背景、边框线颜色 ========================================

/**
 *    商品卡片中 发送按钮的背景颜色  默认使用主题色
 */
@property (nonatomic,strong) UIColor *goodSendBtnColor;

/**
 *  对话页面chat背景
 */
@property (nonatomic,strong) UIColor *chatBgColor;

/**
 *  左边聊天气泡颜色
 */
@property (nonatomic,strong) UIColor *leftChatColor;

/**
 *  右边聊天气泡颜色
 */
@property (nonatomic,strong) UIColor *rightChatColor;

/**
 *  左边聊天气泡复制选中的背景颜色
 */
@property (nonatomic,strong) UIColor *leftChatSelectedColor;

/**
 *  右边聊天气泡复制选中的背景颜色
 */
@property (nonatomic,strong) UIColor *rightChatSelectedColor;

/**
 * 语音cell选中的背景色
 */
@property (nonatomic,strong) UIColor *videoCellBgSelColor;

/**
 * 语音文字颜色背景色
 */
@property (nonatomic,strong) UIColor *videoConversionBgColor;
/**
 * 语音文字颜色
 */
@property (nonatomic,strong) UIColor *videoConversionTextColor;


/**
 *  底部bottom的背景颜色
 */
@property (nonatomic,strong) UIColor *chatBgBottomColor;

/**
 *  底部bottom框边框线颜色(输入框、录音按钮、分割线)
 */
@property (nonatomic,strong) UIColor *chatBgBottomLineColor;

/**
 *  评价(提交)按钮背景颜色(默认跟随主题色)
 */
@property (nonatomic,strong) UIColor *commentCommitButtonColor;

/**
 *  评价选项按钮选中颜色(默认跟随主题色)
 */
@property (nonatomic,strong) UIColor *commentItemButtonBgColor;

@property (nonatomic,strong) UIColor *commentItemButtonSelBgColor;

/**
 * 富文本中的线条颜色
 */
@property (nonatomic,strong) UIColor *LineRichColor;

/**
 * 留言页面中 提交按钮的背景颜色
 * 2.7.4  新增
 */
@property (nonatomic,strong) UIColor *leaveSubmitBtnImgColor;

/**
 *  返回按钮的默认背景色
 */
@property (nonatomic,strong) UIColor *topBackNolColor;

/**
 *  返回按钮的高亮背景色
 */
@property (nonatomic,strong) UIColor *topBackSelColor;

/**
 * 导航栏背景色  （系统导航栏 和自定义导航栏View背景色  默认白色）
 */
@property (nonatomic,strong) UIColor *topViewBgColor;

/**
 * 留言页面 顶部 ”请您留言“ 标题文字颜色
 */
@property (nonatomic,strong) UIColor *leaveTitleTextColor;

/**
 * 文件查看，ImgProgress 图片背景颜色  2.8.0新增
 */
@property (nonatomic,strong) UIColor * documentLookImgProgressColor;

/**
 * 文件查看，按钮 背景颜色  2.8.0新增
 */
@property (nonatomic,strong) UIColor * documentBtnDownColor;

/**
 * 通告栏的背景色
 */
@property (nonatomic,strong) UIColor *notificationTopViewBgColor;

/**
 *  评价页面中 已解决 未解决 按钮的选中的背景色
 */
@property (nonatomic, strong) UIColor *satisfactionSelectedBgColor;

/**
 *  留言页面背景色
 */
@property(nonatomic,strong) UIColor *leaveVCBgColor;

/**
 *  留言页面中 提交按钮的背景颜色和留言页面顶部选项卡底部线条颜色
 */
@property(nonatomic,strong) UIColor *LeaveSubmitImgColor;


///// 帮助中心 导航栏背景色 默认主题色
//@property(nonatomic,strong) UIColor *helpCenterTopViewBgColor;

/// 导航栏默认 渐变开始颜色  默认#4ADABE   需要和 sobot_color_title_bar_right_bg一起使用
@property(nonatomic,copy) NSString *sobotColor_title_bar_left_bg;

/// 导航栏默认 渐变色结束颜色 默认#0DAEAF  需要和 sobotColor_title_bar_left_bg 一起使用
@property(nonatomic,copy) NSString *sobot_color_title_bar_right_bg;

//========================================================= 自定义背景颜色 end ========================================


#pragma Mark -- 自定义文字颜色，（可选）
//=======================================================  自定义文字颜色 ========================================

/**
 *  顶部文字颜色
 */
@property (nonatomic,strong) UIColor *topViewTextColor;

/**
 *  左边气泡文字颜色
 */
@property (nonatomic,strong) UIColor *leftChatTextColor;

/**
 *  右边气泡文字颜色
 */
@property (nonatomic,strong) UIColor *rightChatTextColor;

/**
 *  表情发送按钮背景颜色,2.8.5新增
 */
@property (nonatomic,strong) UIColor *emojiSendBgColor;

/**
 *  表情发送按钮文字颜色,2.8.5新增
 */
@property (nonatomic,strong) UIColor *emojiSendTextColor; // 暂未使用

/**
 *  输入框字体颜色
 */
@property (nonatomic,strong) UIColor *chatTextViewColor;

/**
 *  时间文字的颜色
 */
@property (nonatomic,strong) UIColor *timeTextColor;

/**
 *  提示气泡文字颜色
 */
@property (nonatomic,strong) UIColor *tipLayerTextColor;

/**
 *  播放失败提醒，消息中心文字颜色
 */
@property (nonatomic,strong) UIColor *serviceNameTextColor;

/**
 *  左边气泡中的链接颜色
 */
@property (nonatomic,strong) UIColor *chatLeftLinkColor;

/**
 *  右边气泡中的链接颜色
 */
@property(nonatomic,strong) UIColor *chatRightLinkColor;

/**
 *  商品详情cell中title的文字颜色
 */
@property (nonatomic, strong) UIColor *goodsTitleTextColor;

/**
 *  商品详情cell中标签的文字颜色
 */
@property (nonatomic ,strong) UIColor *goodsTipTextColor;

/**
 *  商品详情cell中摘要的文字颜色
 */
@property (nonatomic, strong) UIColor *goodsDetTextColor;

/**
 *  商品详情cell中发送的文字颜色
 */
@property (nonatomic, strong) UIColor *goodsSendTextColor;

/**
 *  提交评价后将结束会话的文字颜色
 */
@property (nonatomic, strong) UIColor *satisfactionTextColor;

/**
 *  暂不评价文字颜色
 */
@property (nonatomic, strong) UIColor *noSatisfactionTextColor;

/**
 *  评价页面中 已解决 未解决  文字的高亮状态颜色
 */
@property (nonatomic, strong) UIColor   *satisfactionTextSelectedColor;

/**
 *  满意度星级说明的文字颜色
 */
@property (nonatomic,strong) UIColor *scoreExplainTextColor;

/**
 *  评价(条件选择 按钮）文字颜色(默认跟随主题色)
 */
@property (nonatomic,strong) UIColor *commentButtonTextColor;

/**
 *  提价评价按钮的文字颜色
 */
@property (nonatomic,strong) UIColor *submitEvaluationColor;

/**
 *通告栏的文字颜色
 */
@property (nonatomic,strong) UIColor *notificationTopViewLabelColor;

/**
 *  多轮会话模板四的超链颜色
 */
@property (nonatomic,strong) UIColor *chatLeftMultColor;

/**
 *  多轮会话中 展开和收起的文字颜色
 */
@property (nonatomic,strong) UIColor *openMoreBtnTextColor;

/**
 * 聊天对话框中 顶踩、转人工 文字 默认颜色
 */
@property (nonatomic,strong) UIColor *topBtnNolColor;

/**
 *  聊天对话框中顶踩 、转人工文字 选中颜色
 */
@property (nonatomic,strong) UIColor *topBtnSelColor;

/**
 *  顶踩 文字 置灰颜色
 */
@property (nonatomic,strong) UIColor *topBtnGreyColor;

/**
 *  留言页面中 提交按钮的文字颜色
 *  2.7.4  新增
 */
@property (nonatomic,strong) UIColor *leaveSubmitBtnTextColor;

/**
 * 帮助中心 详情页面、 导航栏标题的文字颜色
 */
@property (nonatomic,strong) UIColor *scTopTextColor;

/**
 * 帮助中心 顶部返回的文字颜色
 */
//@property (nonatomic,strong) UIColor *scTopBackTextColor; 


/**
 *   超链卡片的标题文字颜色
 */
@property (nonatomic,strong) UIColor *linkTitleTextColor;

/**
 *  提交留言成功后提示页面的背景颜色
 *  4.0.0  新增
 */
@property (nonatomic,strong) UIColor *leaveSuccessViewBgColor;

/// 机器人按钮的文字颜色
@property (nonatomic,strong) UIColor *robotBtnTitleColor;

///  输入框 点击更多 中 评价 留言 图片等按钮的文字默认颜色
@property (nonatomic,strong) UIColor *textNolColor;

/// 自定义卡片 商品价格文件颜色
@property(nonatomic,strong)UIColor *pricetTagTextColor;
//=======================================================自定义文字颜色 end ==============================================

#pragma Mark -- 图片相关
//======================================================= 图片相关 ==============================================

/**
 *更多按钮默认图片
 */
@property (nonatomic,copy) NSString *moreBtnNolImg;

/**
 *更多按钮选中图片
 */
@property (nonatomic,copy) NSString *moreBtnSelImg;

/**
 * 转人工按钮默认图片
 */
@property (nonatomic,copy) NSString *turnBtnNolImg;

/**
 *转人工按选中图片
 */
@property (nonatomic,copy) NSString *turnBtnSelImg;

/**
 *返回按钮默认图片
 */
@property (nonatomic,copy) NSString *topBackNolImg;

/**
 *返回按钮选中图片
 */
@property (nonatomic,copy) NSString *topBackSelImg;

/**
 *  是否设置相册背景图片
 */
@property (nonatomic ,assign) BOOL isSetPhotoLibraryBgImage;

//======================================================= 图片相关 end==============================================

/**
 *  聊天页面 左上角 返回按钮的文字 （默认 返回）
 */
@property (nonatomic,copy) NSString *topBackTitle;


// 2.8.0
/**
 自定义留言内容预置文案，如果需要国际化，可自行在bundle文件中，以文案为key，翻译即可
 例如："请输入内容"="Please enter content";
 */
@property (nonatomic,strong) NSString *leaveContentPlaceholder;

/**
 自定义留言引导语，如果需要国际化，可自行在bundle文件中，以文案为key，翻译即可
 例如："无法解答你的问题，你可以留言"="Please leave";
 */
@property (nonatomic,strong) NSString *leaveMsgGuideContent;

/**
 *  直接进入留言自定义字段
 *  数组，可以以传递多个
 *  id: 自定义字段的id
 *  value: 想传递的数据
 *  @{@"id":@"",@"value":@"我是数据"}
 */
@property (nonatomic,strong) NSMutableArray *leaveCusFieldArray;

/**
 *  直接进入留言对接字段
 *  数组，可以以传递多个
 *  id: 对接字段系统自动生成的id
 *  value: 想传递的数据
 *  params: 显示的字段ID，例如city、address，与id对应
 *  @{@"id":@"textfield12",@"value":@"我是数据",@"params":@"city"}
 **/
@property (nonatomic,strong) NSMutableArray *leaveParamsExtends;

/**
 留言技能组 id
 获取：设置 —>工单技能组设置
*/
@property (nonatomic,strong) NSString *leaveMsgGroupId;

/**
 留言模板 id
 获取：设置 —>工单
*/
@property (nonatomic,strong) NSString *leaveTemplateId;

/**
  选择图片时，不直接发送，预览发送
 【注意：预览方框仅为放大镜效果，不是裁切图片，发送的还是原图】
*/
@property (nonatomic,assign) BOOL showPhotoPreview;

/**
  是否隐藏会话时间，默认NO不隐藏；如果不是中国区，与客户端的真实时间是有差异可以选择隐藏会话中的时间
*/
@property (nonatomic,assign) BOOL hideChatTime;

/**
  是否隐藏机器人评价标签，默认不隐藏
*/
@property (nonatomic,assign) BOOL hideRototEvaluationLabels;

/**
  是否隐藏人工评价标签，默认不隐藏
*/
@property (nonatomic,assign) BOOL hideManualEvaluationLabels;

/**
  是否底部新会话时的评价按钮留言按钮，默认不隐藏
*/
@property (nonatomic,assign) BOOL hideBottomLeave;

/**
  是否隐藏底部新会话时的评价按钮，默认不隐藏
*/
@property (nonatomic,assign) BOOL hideBottomEvaluation;

/**
  是否隐藏导航右上角“...”更多按钮，默认不隐藏
*/
@property (nonatomic,assign) BOOL hideNavBtnMore;

/**
 * 是否关闭识别二维码的功能  设置YES关闭 ，NO保留
 */
@property (nonatomic,assign) BOOL hideQRCode;


/**
 * 3.1.3 新增 富文本中图片的宽度和高度属性设置 
 * 高度设置： 如果设置的高度 <= 0 取默认高度 110
 * 宽度设置 ：如果传入的宽度 <= 0 取 默认宽度  ，如果传入的宽度 大于最大宽度 取最大宽度
 */

/**
 * 自定义 富文本消息中图片的高度 （如果设置的高度 <= 0 取默认高度 110  ）
 * 默认 取110
 */
//@property (nonatomic,assign) CGFloat richImgHeight;

/**
 * 自定义 富文本消息中图片的宽度 （如果传入的宽度 <= 0 取 默认宽度  ，如果传入的宽度 大于最大宽度 取最大宽度）
 * 默认  取聊天消息的的最大宽度
 */
//@property (nonatomic,assign) CGFloat richImgWidth;


/**
 *   V4.0.0 开始 自定义聊天页面顶部标题 头像、客服昵称、企业名称
 *   默认 取PC工作台 设置  方式1展示接待客服 + 企业名称 ，方式2展示企业信息+接待状态
 *   如果您想在SDK端设置自定义控制 需同时设置 1.是否显示头像开关 、2.是否显示企业名称开关 、3是否显示接待客服昵称开关，如果这三个开关其中一个没有设置默认取PC工作台设置项
 *
 *
 *    原  title_type 不在使用
 *
 */


/// 聊天页面顶部自定义图片 是否展示  默认NO 取PC端开关设置
@property(nonatomic,assign) BOOL isShowTitleViewImg;

/**
 *  聊天页顶部标题自定义图片，,需配合isShowTitleViewImg使用
*/
@property(nonatomic,strong) NSString *custom_title_url;

/// 聊天页面顶部自定义接待客服昵称 是否展示  默认NO 取PC端开关设置
@property(nonatomic,assign) BOOL isShowTitleViewNick;

/**
 *  聊天页顶部标题自定义接待客服昵称，,需配合isShowTitleViewNick使用
*/
@property(nonatomic,strong) NSString *custom_nick_title;

/// 聊天页面顶部标题自定义企业名称 是否展示 默认NO 取PC端开关设置
@property(nonatomic,assign) BOOL isShowTitleViewCompanyName;

/**
 *  聊天页顶部标题自定义企业名称，,需配合isShowTitleViewCompanyName使用
 *   如果 isShowTitleViewCompanyName ，custom_company_title传空取PC端设置值
*/
@property(nonatomic,strong) NSString *custom_company_title;

// 是否显示聊天的头像和昵称(仅发送方)：0不显示，1头像+昵称，2仅头像 3仅昵称
@property (nonatomic,assign) int showChatLeftNameHeader;


// 把字典中的属性赋值给对象
-(id)jsonValueToDict:(NSDictionary *)dict;

@end



/**
 内容字段：标题（必填）、页面地址url（必填）、摘要、标签、缩略图url
 */
@interface ZCProductInfo : NSObject

// 标题
// not null
@property (nonatomic,strong) NSString *title;

// 页面链接
// not null
@property (nonatomic,strong) NSString *link;

// 摘要
@property (nonatomic,strong) NSString *desc;

// 标签
@property (nonatomic,strong) NSString *label;

// 缩略图地址
@property (nonatomic,strong) NSString *thumbUrl;

@end

/**
发送订单消息字段：
 订单状态: orderStatus
 订单编号: orderCode
 订单创建时间: createTime
 商品图片链接: goodsPicturesUrls
 订单链接: orderUrl  ，
 商品描述: goodsDesc
 商品件数: goodsCount
 总金额: totalFee，单位为分，显示时会默认格式化为元，例如，传入100，显示效果为1.00元
*/
@interface ZCOrderGoodsModel : NSObject

/*
待付款: 1,
待发货: 2,
运输中: 3,
派送中: 4,
已完成: 5,
待评价: 6,
已取消: 7,
其它: 不在编码中的
 */
@property (nonatomic,assign) int orderStatus;

// 自定义订单状态，仅当orderStatus=0时生效
@property (nonatomic,strong) NSString *statusCustom;

@property (nonatomic,strong) NSString *orderCode;

// Java 中的long类型，例如[NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]*1000*1000]
// 例如：1569491413000，不是这样的值，会发送不成功
@property (nonatomic,strong) NSString *createTime;

// 商品信息
// [{@"name":@"商品名称",@"pictureUrl":@"图片地址"}]
@property (nonatomic,strong) NSArray *goods;

//此链接可监听链接点击事件，拦截后自行处理
@property (nonatomic,strong) NSString *orderUrl;
@property (nonatomic,strong) NSString *goodsCount;


/// 单位为分，只能是int类型的数字（显示时会默认格式化为元，例如，传入100，显示效果为1.00元）
@property (nonatomic,strong) NSString *totalFee;

// 获取状态字符串内容
+(NSString *)getOrderStatusMsg:(int) status;

@end
