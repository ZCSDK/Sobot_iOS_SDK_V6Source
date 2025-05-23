//
//  ZCLeaveMsgController.h
//  SobotKit
//
//  Created by lizh on 2022/9/5.
//

#import <SobotKit/SobotKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,ExitType) {
    ISCOLSE         = 1,// 直接退出SDK
    ISNOCOLSE       = 2,// 不直接退出SDK
    ISBACKANDUPDATE = 3,// 仅人工模式 点击技能组上的留言按钮后,（返回上一页面 提交退出SDK）
    ISROBOT         = 4,// 机器人优先，点击技能组的留言按钮后，（返回技能组 提交和机器人会话）
    ISUSER          = 5,// 人工优先，点击技能组的留言按钮后，（返回技能组 提交机器人会话）
};

typedef void(^BackRefreshPageBlock)(id _Nonnull object);

@interface ZCLeaveMsgController : SobotClientBaseController

@property (nonatomic,assign) BOOL isExitSDK;
@property (nonatomic,assign) BOOL isNavOpen;
/**  是否显示排队人数已满*/
@property (nonatomic,assign) BOOL isShowToat;
@property (nonatomic,strong) NSString * _Nullable tipMsg;
@property (nonatomic,assign) int selectedType; // 默认 创建工单 2 留言记录
@property (nonatomic,strong) NSDictionary * _Nullable templateldIdDic;// {"templateId":1}，模板id从配置列表接口获取
@property(nonatomic,strong)NSMutableArray   * _Nullable coustomArr;// 用户自定义字段数组
// 2.7.1版本 和留言模板关联 数据从模板接口获取 原初始化接口的数据不在使用
@property (nonatomic , assign) BOOL telShowFlag;
// 2.8.0 是否显示标题
@property (nonatomic , assign) BOOL ticketTitleShowFlag;
@property (nonatomic , assign) BOOL telFlag;
@property (nonatomic , assign) BOOL enclosureShowFlag;
@property (nonatomic , assign) BOOL enclosureFlag;
@property (nonatomic , assign) BOOL emailFlag;
@property (nonatomic , assign) BOOL emailShowFlag;
// 未使用
//@property (nonatomic , assign) int  ticketStartWay;
@property (nonatomic,copy) NSString * _Nullable msgTmp;// "'您好，为了更好地解决您的问题,请告诉我们以下内容：<br>1. 您的姓名 2. 问题描述'"
@property (nonatomic,copy) NSString * _Nullable msgTxt;// "<p>您好，很抱歉我们暂时无法为您提供服务，如需帮助，请留言，我们将尽快联系并解决您的问题</p>"
@property (nonatomic,assign) int  ticketShowFlag;//  1 显示留言记录
@property (nonnull,strong) NSMutableArray * typeArr;// 分类的数据
@property (nonatomic,assign) int tickeTypeFlag ; //1-自行选择分类，要显示  2-指定分类 其他，不显示
@property (nonatomic,copy) NSString * _Nullable ticketTypeId;// 当-指定分类 传这个值
@property (nonatomic,copy) BackRefreshPageBlock  _Nullable backRefreshPageblock;
@property (nonatomic,assign) BOOL ticketContentShowFlag;
@property (nonatomic,assign) BOOL ticketContentFillFlag;

//ticketContentShowFlag 问题描述是否显示 0-不显示 1-显示 默认显示
//        ticketContentFillFlag 问题描述是否必填 0-非必填 1-必填 默认必填
//        enclosureShowFlag 是否显示附件 0 不显示 1显示
//        enclosureFlag 附件是否为必填字段 0 选填 1 必填
@end

NS_ASSUME_NONNULL_END
