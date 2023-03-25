//
//  SobotChatClientDefines.h
//  SobotChatClient
//
//  Created by zhangxy on 2022/8/30.
//
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClientCache.h>

// 国际化
#define SobotKitLocalString(key) [SobotChatClientCache localKitString:key]

// 资源
#define SobotKitGetImage(imageName) [SobotUITools getSysImageByName:imageName bundleName:ChatClientBundelName]
// 颜色
#define UIColorFromKitModeColor(themeColorKey) [SobotUITools getSobotThemeModeColor:themeColorKey  bundleName:ChatClientBundelName]
#define UIColorFromKitModeColorAlpha(themeColorKey,a) [SobotUITools getSobotThemeModeColor:themeColorKey alpha:a bundleName:ChatClientBundelName]

// 底部弹出标题高度
#define ZCSheetTitleHeight   60

// 是否开启自动提醒
#define Sobot_isEnableAutoTips @"Sobot_isEnableAutoTips"

// 企业ID
#define Sobot_CompanyId @"Sobot_CompanyId"

// 是否收集日志
#define Sobot_collectFlag @"Sobot_collectFlag"

// 初始化返回的UID
#define Sobot_ChatClientCurUID @"Sobot_ChatClientCurUID"

// 初始化信息过时信息
#define Sobot_ConfigExperiseInfoHeader @"Sobot_ConfigExperiseInfo_"

// 查询的地址信息
#define Sobot_CacheURLHeader @"Sobot_CacheURL_"



/**
 *  @enum 网络请求
 */
typedef NS_ENUM(NSInteger, ZCNetWorkCode) {
    /**
     *  访问成功。
     */
     ZC_NETWORK_SUCCESS = 0,
    
    /**
     *  访问成功，但是空数据。
     */
     ZC_NETWORK_NULL_DATA = 1,
    
    /**
     发送时新增数据
     */
    ZC_NETWORK_New_Data = 2,
    
    /**
     *  连接失败。
     */
     ZC_NETWORK_FAIL = -1,
    
    /**
     *  参数错误。
     */
    ZC_NETWORK_PARAMETER_FAIL = -2,
    
    /**
     *  有编码错误。
     */
    ZC_KNOWNCODE_FAIL = -3,
};

/**
 *  @enum 智齿消息业务状态码
 */
typedef NS_ENUM(NSInteger, ZCMessageSendCode) {
    /**
     *  发送消息成功。
     */
     ZC_SENDMessage_Success = 0,
    /**
     *  新消息回复。
     */
     ZC_SENDMessage_New = 1,
    
    /**
     *  发送消息失败。
     */
     ZC_SENDMessage_FAIL = -1,
    
    /**
     *  发送消息失败
     */
    ZC__SENDMessage_FAIL_STATUS = 1002,
    /**
     *  发送消息为空
     */
     ZC_SENDMessage_NULL = -2,
    
    /**
     *  文件不存在。
     */
     ZC_File_NotFound = -1000,
    
};
