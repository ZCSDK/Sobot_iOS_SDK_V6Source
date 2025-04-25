//
//  ZCLibCusMenu.h
//  SobotKit
//
//  Created by lizhihui on 2018/5/25.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SobotCommon/SobotCommon.h>
//菜单类型:0.发消息、1.转人工、2.触发知识库、3.结束会话、4.满意度评价、5.留言、6.跳转链接
typedef NS_ENUM(NSInteger,ZCCusMenuType) {
    ZCCusMenuTypeSendMessage = 0,
    ZCCusMenuTypeConnectUser = 1,
    ZCCusMenuTypeSendRobotMessage = 2,
    ZCCusMenuTypeCloseChat = 3,
    ZCCusMenuTypeEvaluetion = 4,
    ZCCusMenuTypeLeave = 5,
    ZCCusMenuTypeOpenUrl = 6,
};

/**
 * 自定义菜单
 *
 **/
@interface ZCLibCusMenu : SobotBaseEntity

//自定义按钮类型 （1.留言 2 服务评价 3文件 4表情  5截图  6自定义跳转链接 7 图片 8 视频 9 拍摄，10弹窗）
// 4.1.0版本新增10，当超链接处理
@property (nonatomic,assign) int extModelType;
// 按钮的图片链接   https://img.sobot.com/console/common/res/sobot_leavemsg_normal.png
@property (nonatomic,copy) NSString *extModelPhoto;
// 菜单标题
@property (nonatomic,strong) NSString * title;

// 点击事件
@property (nonatomic,strong) NSString * url;

// 备用字段（不用填写）
@property (nonatomic,assign) NSInteger  lableId;

// 菜单图标(更多时使用,选填)
@property (nonatomic,strong) NSString * imgName;

// 菜单图标(网络图片，如果此参数有值，优先使用网络图片，menuPicUrl为空则使用默认iconMaterial)
@property (nonatomic,strong) NSString * iconMaterial;
@property (nonatomic,strong) NSString * menuPicUrl;

// 按下效果，选填
@property (nonatomic,strong) NSString * imgNamePress;


// enableStatus 值为1时，以下参数起效
@property (nonatomic,strong) NSString *menuid;//": "0dd2c1ea760242b08e06e41ad17185cc", //菜单主键ID
@property (nonatomic,strong) NSString *companyId;//": "9413d75901d546c289e7b29c012c7243", //公司Id
@property (nonatomic,strong) NSString *createId;//": "8d7a2c922236427e8794b60b9209bd11", //创建人ID
@property (nonatomic,strong) NSString *createTime;//": 1662640617990, //创建时间
@property (nonatomic,strong) NSString *updateId;//": "8d7a2c922236427e8794b60b9209bd11", //修改人ID
@property (nonatomic,strong) NSString *updateTime;//": 1662640617990,  //修改时间
@property (nonatomic,strong) NSString *menuName;//": "快捷菜单1", //菜单名称
@property (nonatomic,strong) NSString *menuId;//": "1662640617989", //菜单code
@property (nonatomic,strong) NSString *citations;//": 2, //引用次数
@property (nonatomic,strong) NSString *hitCount;//": null, //被点击次数
@property (nonatomic,strong) NSString *labelLink;//": "https://www.google.com", //链接
@property (nonatomic,strong) NSString *paramFlag;//": 0, //是否开启参数拼接 0:关闭 1:开启
@property (nonatomic,strong) NSString *robotFlag;//": "", //知识库Id
@property (nonatomic,strong) NSString *questions;//": "", //标问
@property (nonatomic,strong) NSString *entryId;//": "", //词条Id
@property (nonatomic,strong) NSString *robotType;//": null, //知识库类型 0:内部知识库 1:机器人知识库
@property (nonatomic,assign) ZCCusMenuType menuType;//": 6, //菜单类型:0.发消息、1.转人工、2.触发知识库、3.结束会话、4.满意度评价、5.留言、6.跳转链接
@property (nonatomic,assign) int menuStatus;//": 0, //状态:0-正常,1-删除
@property (nonatomic,assign) int sortNo;//": 0, //排序值
@property (nonatomic,strong) NSString *updateName;//": null, //修改人名称
@property (nonatomic,assign) int channelType;//": 0, //渠道类型:0-桌面移动 1:移动网络 2:APP
@property (nonatomic,assign) int exhibit;//": 0 //是否展示图标:0-不展示,1-展示

@property (nonatomic,assign) BOOL isSave;//临时存储
-(id)initWithMyDict:(NSDictionary *)dict;

@end
