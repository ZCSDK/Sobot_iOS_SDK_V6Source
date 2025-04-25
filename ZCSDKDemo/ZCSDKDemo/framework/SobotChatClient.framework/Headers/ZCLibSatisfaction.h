//
//  ZCLibSatisfaction.h
//  SobotChatClient
//
//  Created by lizh on 2022/9/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZCLibSatisfaction : NSObject
/** id */
@property (nonatomic,strong) NSString  * sId;

// 模板id
@property (nonatomic,strong) NSString  * templateId;

/** 企业id */
@property (nonatomic,strong) NSString  * companyId;

/** 满意度配置id */
@property (nonatomic,strong) NSString  * configId;

/** 创建时间 */
@property (nonatomic,strong) NSString  * createTime;

/** 技能组id */
@property (nonatomic,strong) NSString  * groupId;

/** 技能组名称 */
@property (nonatomic,strong) NSString  * groupName;

/** 评价框引导语 */
@property (nonatomic,strong) NSString  * inputLanguage;

/** 评价框是否必填 1是 0否 */
@property (nonatomic,strong) NSString  * isInputMust;

/** 人工客服是否解决问题  1开启 0关闭 */
@property (nonatomic,strong) NSString  * isQuestionFlag;

/** '标签是否必填 1是 0否 */
@property (nonatomic,strong) NSString  * isTagMust;

/** 标签id，多个id之间逗号分隔 */
@property (nonatomic,strong) NSString  * labelId;

/** 标签名称，多个名称之间逗号分隔 */
@property (nonatomic,strong) NSString  * labelName;

/** 操作类型 0开关设置 1满意度策略 */
@property (nonatomic,strong) NSString  * operateType;

/** 星级 1,2,3,4,5星 */
@property (nonatomic,assign) int  score;

// 4.2.4新增
@property (nonatomic,strong) NSString *scoreExplainLan;//提交大模型评价，传值给scoreExplain


/** 星级说明 */
@property (nonatomic,strong) NSString  * scoreExplain;

/** 设置方式：1整体设置 2区分客服技能组设置 */
@property (nonatomic,strong) NSString  * settingMethod;

/** 更新时间 */
@property (nonatomic,strong) NSString  * updateTime;

//scoreFlag=1:0-默认10分,1-默认5分,2-默认0分
//scoreFlag=0:0-默认5星,1-默认0星
@property (nonatomic,assign) int   defaultTypeBack;
@property (nonatomic,assign) int   defaultStar;

// 1:10分，0是5星
@property (nonatomic,assign) int   scoreFlag;

// 是否存在以下问题评价
@property (nonatomic,strong) NSString  *tagTips;

// 4.2.4版本开始，把tags换成scoreTags，使用对象解析
@property (nonatomic,strong) NSMutableArray *scoreTags;

-(id)initWithMyDict:(NSDictionary *)dict;
@end


@interface ZCScoreTag : NSObject

@property (nonatomic,strong) NSString *tid;// id
@property (nonatomic,strong) NSString *scoreId;
@property (nonatomic,strong) NSString *labelId;// id
@property (nonatomic,strong) NSString *labelName;
@property (nonatomic,strong) NSString *labelNameLan;
@property (nonatomic,assign) int sortNo;//

-(id)initWithMyDict:(NSDictionary *)dict;
@end
NS_ASSUME_NONNULL_END
