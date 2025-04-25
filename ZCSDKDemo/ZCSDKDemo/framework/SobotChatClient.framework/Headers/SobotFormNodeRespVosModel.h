//
//  SobotFormNodeRespVosModel.h
//  SobotChatClient
//
//  Created by lizh on 2024/11/7.
//

#import <SobotCommon/SobotCommon.h>
#import "ZCOrderCusFieldsDetailModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface SobotFormNodeRespVosModel : SobotBaseEntity

// 节点ID
@property(nonatomic,copy)NSString *rid;

@property(nonatomic,copy)NSString *companyId;
// string or null 节点名称
@property(nonatomic,copy)NSString *name;
// integer or null 可选 头节点标识 0-是，1-不是
@property(nonatomic,assign)int nodeHeadType;
// integer or null 可选节点类型：1-收集节点、2-连线节点
@property(nonatomic,assign)int nodeType;
// 坐标
@property(nonatomic,copy)NSString *coordinate;
// 引导语
@property(nonatomic,copy)NSString *tips;
// 错误引导语
@property(nonatomic,copy)NSString *errorTips;
//字段ID
@property(nonatomic,copy)NSString *fieldId;
//字段名称
@property(nonatomic,copy)NSString *fieldName;
//字段来源
@property(nonatomic,assign)int fieldFrom;
//
@property(nonatomic,copy)NSString *fieldVariable;
//字段类型 0-单行文本，8-单选框
@property(nonatomic,assign)int fieldType;
//分支类型 1-条件分支 2-默认分支（单选 回复任意）
@property(nonatomic,assign)int branchType;
// 单行文本 字段选项
@property(nonatomic,copy)NSString *limitOptions;
// 单行文本 字符限制
@property(nonatomic,copy)NSString *limitChar;
// 字段IDs（所以选项ID）
@property(nonatomic,copy)NSString *fieldDataIds;
//状态 0-启用 1-失效 -1-删除
@property(nonatomic,assign)int status;
// 字段值（所有选项）, 数组
@property(nonatomic,copy)NSString *fieldValues;
// 字段值（所以选项值）
@property(nonatomic,copy)NSString *fieldDataValues;

// 存放单选的子集 单选数据
@property(nonatomic,strong)NSMutableArray *customFieldArr;

@property (nonatomic,copy) NSString * fieldValue;// 自定义字段值
@property (nonatomic,strong) NSString * fieldSaveValue;// 存储当前自定义字段填写的值
// 是否选中
@property(nonatomic,assign)BOOL isCheck;
// 单选当前选中的子集
@property(nonatomic,strong)ZCOrderCusFieldsDetailModel *selSubModel;
//{
//                "id": "1853755314158088192",
//                "companyId": "66a522ea3ef944a98af45bac09220861",
//                "name": "收集询单选-1",
//                "nodeHeadType": 1,
//                "nodeType": 1,
//                "coordinate": "1728,208",
//                "tips": "请选择询单选-1",
//                "errorTips": "请输入选项序号",
//                "fieldId": "f04fde5d5291456d9d0ee9dc90657ee6",
//                "fieldName": "询单选-1",
//                "fieldFrom": 3,
//                "fieldVariable": "customField27",
//                "fieldType": 8,
//                "branchType": null,
//                "limitOptions": "[]",
//                "limitChar": null,
//                "fieldDataIds": "[\"a17f3dc2302748ce97368a1499b5face\",\"2086deba3bf740b389dffc3202b736d9\",\"a937f5064031484aab41fea7f60b6703\"]",
//                "fieldDataValues": "[\"单选-1\",\"单选-2\",\"单选-3\"]",
//                "fieldValues": "[\"730804453148431\",\"730804453149368\",\"730804453150829\"]",
//                "status": 0
//            }
@end

NS_ASSUME_NONNULL_END
