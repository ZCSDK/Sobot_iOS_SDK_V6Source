//
//  SobotFontDefines.h
//  SobotUI
//
//  Created by zhangxy on 2021/7/16.
//

////////////////////////////////////////////////////////////
///
///

////////////////////////////////////////////////////////////
/**
 *  字体
 */
#define  SobotFont20       [UIFont fontWithName:@"Helvetica" size:20]
#define  SobotFontBold20   [UIFont fontWithName:@"Helvetica-Bold" size:20]

#define  SobotFont18       [UIFont fontWithName:@"Helvetica" size:18]
#define  SobotFontBold18   [UIFont fontWithName:@"Helvetica-Bold" size:18]

#define  SobotFont17       [UIFont fontWithName:@"Helvetica" size:17]
#define  SobotFontBold17   [UIFont fontWithName:@"Helvetica-Bold" size:17]
// 字体
#define SobotFontSTHeitiSC17(f) [UIFont fontWithName:@"STHeitiSC-Light" size:f]

#define  SobotFont16       [UIFont fontWithName:@"Helvetica" size:16]
#define  SobotFontBold16   [UIFont fontWithName:@"Helvetica-Bold" size:16]


#define  SobotFont15       [UIFont fontWithName:@"Helvetica" size:15]
#define  SobotFontBold15   [UIFont fontWithName:@"Helvetica-Bold" size:15]

#define  SobotFont14       [UIFont fontWithName:@"Helvetica" size:14]
#define  SobotFontBold14   [UIFont fontWithName:@"Helvetica-Bold" size:14]

#define  SobotFont13       [UIFont fontWithName:@"Helvetica" size:13]
#define  SobotFontBold13   [UIFont fontWithName:@"Helvetica-Bold" size:13]

#define  SobotFont12       [UIFont fontWithName:@"Helvetica" size:12]
#define  SobotFontBold12   [UIFont fontWithName:@"Helvetica-Bold" size:12]

#define  SobotFont11       [UIFont fontWithName:@"Helvetica" size:11]
#define  SobotFontBold11   [UIFont fontWithName:@"Helvetica-Bold" size:11]

#define  SobotFont10       [UIFont fontWithName:@"Helvetica" size:10]
#define  SobotFontBold10   [UIFont fontWithName:@"Helvetica-Bold" size:10]


#define  SobotFont8       [UIFont fontWithName:@"Helvetica" size:8]
#define  SobotFontBold8   [UIFont fontWithName:@"Helvetica-Bold" size:8]

// 常用高度
#define SobotHSheetTitle 60
#define SobotHButton36 36
#define SobotHButton44 44

// 圆角Radius
#define SobotRadius18 18
#define SobotRadius8 8
#define SobotRadius6 6
#define SobotRadius4 4
#define SobotRadiosMax 18
#define SobotRadiosMiddle 8
#define SobotRadiosMin 4

// 间距SPACE
#define SobotSpace20 20
#define SobotSpace18 18
#define SobotSpace16 16
#define SobotSpace12 12
#define SobotSpace10 10
#define SobotSpace8 8
#define SobotSpace2 2
// 常用边距
#define SobotSpaceOut 20
#define SobotSpaceIn 16
#define SobotSpaceInLine 8
#define SobotSpaceInLineMin 4

// Color keys
typedef NSString *SobotTypeColor NS_STRING_ENUM;
 
// 背景色
static SobotTypeColor const SobotColorBanner  = @"SobotColorBanner";// 导航"#1B1B1C";
static SobotTypeColor const SobotColorTheme   = @"SobotColorTheme";// 主题色，固定"#0DAEAF";
static SobotTypeColor const SobotColorBgMain  = @"SobotColorBgMain";// 新增默认背景"#000000";
static SobotTypeColor const SobotColorBgSubToMain  = @"SobotColorBgSub2Main";// 搜索等次级背景"#353538";
static SobotTypeColor const SobotColorBgSub   = @"SobotColorBgSub";// 普通页面浅色背景"#262628";
static SobotTypeColor const SobotColorBgSub2  = @"SobotColorBgSub2";// 搜索等次级背景" 搜索栏背景颜色 附件背景色
static SobotTypeColor const SobotColorBgSub3  = @"SobotColorBgSub3";// 搜索等次级背景"#FFFFFF";
static SobotTypeColor const SobotColorBgSub5  = @"SobotColorBgSub5";
static SobotTypeColor const SobotColorBgSub6  = @"SobotColorBgSub6";// 外呼软键盘按钮默认的背景色
static SobotTypeColor const SobotColorBgSub7  = @"SobotColorBgSub7";// 外呼软键盘按钮选中的背景色
static SobotTypeColor const SobotColorBlack = @"SobotColorBlack";//纯黑色"#000000";
static SobotTypeColor const SobotColorWhite = @"SobotColorWhite";//纯白色"#FFFFFF";
static SobotTypeColor const SobotColorYellow = @"SobotColorYellow";//黄色"#F8C46E";
static SobotTypeColor const SobotColorRed  = @"SobotColorRed";// 红色标记颜色 #FF6D63
static SobotTypeColor const SobotColorBgTransferList = @"SobotColorBgTransferList";
static SobotTypeColor const SobotColorBgWhite = @"SobotColorBgWhite";
static SobotTypeColor const SobotColorBgTitle = @"SobotColorBgTitle"; // 接单按钮背景颜色和工单详情页选选项卡选中状态文字颜色
static SobotTypeColor const SobotColorBgActionSheetView = @"SobotColorBgActionSheetView"; // 排序弹窗背景色
static SobotTypeColor const SobotColorBgGreen = @"SobotColorBgGreen";// 果绿色 #21CFA6
static SobotTypeColor const SobotColorBgGray = @"SobotColorBgGray";// 果绿色 #21CFA6

static SobotTypeColor const SobotColorHeaderBg = @"SobotColorHeaderBg";// 留言头部文字背景色
static SobotTypeColor const SobotColorHeaderText = @"SobotColorHeaderText";// 留言头部文字色

// 文字颜色
static SobotTypeColor const SobotColorTextMain = @"SobotColorTextMain";//主文本颜色
static SobotTypeColor const SobotColorTextSub  = @"SobotColorTextSub";//次级文本颜色"#888890";
static SobotTypeColor const SobotColorTextSub1 = @"SobotColorTextSub1";//次级1文本颜色"#74747c";
static SobotTypeColor const SobotColorTextSub2 = @"SobotColorTextSub2";//次级2文本颜色"#7B7B7B";
static SobotTypeColor const SobotColorTextSub3 = @"SobotColorTextSub3";//次级3文本颜色#BDC3D1
static SobotTypeColor const SobotColorTextSub4 = @"SobotColorTextSub4"; //次级4文字颜色  8B98AD
static SobotTypeColor const SobotColorTextSub5 = @"SobotColorTextSub5";
static SobotTypeColor const SobotColorTextSection = @"SobotColorTextSection"; // 首页homecell中title文字颜色 #3D4966
static SobotTypeColor const SobotColorTextMenuSelected = @"SobotColorTextMenuSelected";// 上一个 下一个 按钮不可点击的文字颜色
static SobotTypeColor const SobotColorTextActionSheet = @"SobotColorTextActionSheet";// 排序弹窗文字颜色
static SobotTypeColor const SobotColorTextCancel = @"SobotColorTextCancel"; // 搜索取消按钮的文字颜色
static SobotTypeColor const SobotColorTextNav = @"SobotColorTextNav";// 导航栏文字颜色
static SobotTypeColor const SobotColorTextWhite = @"SobotColorTextWhite";// 白色文字颜色
static SobotTypeColor const SobotColorTextGoods = @"SobotColorTextGoods";// 商品卡片和订单卡片的文字颜色
static SobotTypeColor const SobotColorTextPricetTag = @"SobotColorTextPricetTag";// 商品卡片价格标签的文字颜色
static SobotTypeColor const SobotColorBgF5 = @"SobotColorBgF5";// 新增背景颜色

// 线条颜色
static SobotTypeColor const SobotColorBorderLine  = @"SobotColorBorderLine";// #D9D9D9
static SobotTypeColor const SobotColorBgLine  = @"SobotColorBgLine";// 线条颜色"#2C2C2C";分割线
static SobotTypeColor const SobotColorSeparatorLine = @"SobotColorSeparatorLine";// 分割线颜色
static SobotTypeColor const SobotColorBgTopLine  = @"SobotColorBgTopLine";// 顶部线条颜色线条颜色"#EBEBEB";


// 链接颜色
static SobotTypeColor const SobotColorTextLink = @"SobotColorTextLink";//链接文本颜色"#0DAEAF";


// 工单等级颜色
static SobotTypeColor const SobotTextOrderLevel1 = @"SobotTextOrderLevel1"; // 工单等级1文字颜色
static SobotTypeColor const SobotTextOrderLevel2 = @"SobotTextOrderLevel2"; // 工单等级2文字颜色
static SobotTypeColor const SobotTextOrderLevel3 = @"SobotTextOrderLevel3"; // 工单等级3文字颜色
static SobotTypeColor const SobotTextOrderLevel4 = @"SobotTextOrderLevel4"; // 工单等级4文字颜色

// 工单状态颜色
static SobotTypeColor const SobotTextOrderStatus1 = @"SobotTextOrderStatus1"; // 工单状态文字颜色
static SobotTypeColor const SobotTextOrderStatus2 = @"SobotTextOrderStatus2"; // 工单状态文字颜色
static SobotTypeColor const SobotTextOrderStatus3 = @"SobotTextOrderStatus3"; // 工单状态文字颜色
static SobotTypeColor const SobotTextOrderStatus4 = @"SobotTextOrderStatus4"; // 工单状态文字颜色
static SobotTypeColor const SobotTextOrderStatus5 = @"SobotTextOrderStatus5"; // 工单状态文字颜色
static SobotTypeColor const SobotTextOrderStatus6 = @"SobotTextOrderStatus6"; // 工单状态文字颜色
static SobotTypeColor const SobotTextOrderStatus7 = @"SobotTextOrderStatus7"; // 工单状态文字颜色

// 状态类别 1-新建，2-受理中 3-等待客户回复 4-暂停 5-已解决 6 已关闭#161616 7 已删除#A3A5A8

static SobotTypeColor const SobotTextOrderStatus1Bg = @"SobotTextOrderStatus1Bg"; // 工单状态文字颜色
static SobotTypeColor const SobotTextOrderStatus2Bg = @"SobotTextOrderStatus2Bg"; // 工单状态文字颜色
static SobotTypeColor const SobotTextOrderStatus3Bg = @"SobotTextOrderStatus3Bg"; // 工单状态文字颜色
static SobotTypeColor const SobotTextOrderStatus4Bg = @"SobotTextOrderStatus4Bg"; // 工单状态文字颜色
static SobotTypeColor const SobotTextOrderStatus5Bg = @"SobotTextOrderStatus5Bg"; // 工单状态文字颜色
static SobotTypeColor const SobotTextOrderStatus6Bg = @"SobotTextOrderStatus6Bg"; // 工单状态文字颜色
static SobotTypeColor const SobotTextOrderStatus7Bg = @"SobotTextOrderStatus7Bg"; // 工单状态文字颜色

// 呼叫任务状态背景色
static SobotTypeColor const SobotTextCallStatus1 = @"SobotTextCallStatus1"; // 呼叫状态文字颜色
static SobotTypeColor const SobotTextCallStatus3 = @"SobotTextCallStatus3"; // 呼叫状态文字颜色
static SobotTypeColor const SobotTextCallStatus4 = @"SobotTextCallStatus4"; // 呼叫状态文字颜色
static SobotTypeColor const SobotTextCallStatus5 = @"SobotTextCallStatus5"; // 拨号页面不可点颜色

static SobotTypeColor const SobotColorTest = @"SobotColorTest"; // 测试颜色

// 颜色
#define UIColorFromModeColor(themeColorKey) [SobotUITools getSobotThemeModeColor:themeColorKey  bundleName:@""]
#define UIColorFromModeColorAlpha(themeColorKey,a) [SobotUITools getSobotThemeModeColor:themeColorKey alpha:a  bundleName:@""]

#define UIColorFromModeColorBundleName(themeColorKey,_bundleName) [SobotUITools getSobotThemeModeColor:themeColorKey  bundleName:_bundleName]
#define UIColorFromModeColorAlphaBundleName(themeColorKey,a,bundleName) [SobotUITools getSobotThemeModeColor:themeColorKey alpha:a bundleName:bundleName]

// 颜色取值方法
#define SobotRgbColor(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define SobotRgbColorAlpha(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define SobotColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define SobotColorFromRGBAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

#define SobotColorWithWhiteAlpha(w,a) [UIColor colorWithWhite:w alpha:a]

////////////////////////////////////////////////////////////
