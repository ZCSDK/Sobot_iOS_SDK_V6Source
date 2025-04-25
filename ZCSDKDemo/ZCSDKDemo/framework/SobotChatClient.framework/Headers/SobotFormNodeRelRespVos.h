//
//  SobotFormNodeRelRespVos.h
//  SobotChatClient
//
//  Created by lizh on 2024/11/7.
//

#import <SobotCommon/SobotCommon.h>

NS_ASSUME_NONNULL_BEGIN

@interface SobotFormNodeRelRespVos : SobotBaseEntity
// 关系ID
@property(nonatomic,copy)NSString *respid;
// 后节点ID
@property(nonatomic,copy)NSString *nextNodeId;
// 前节点ID
@property(nonatomic,copy)NSString *preNodeId;
// 字段值ID（选项ID）
@property(nonatomic,copy)NSString *fieldDataId;
// integer or null 分支排序
@property(nonatomic,assign)int branchSort;

//            {
//                "id": "1853755949003747328",
//                "nextNodeId": "1853755263474118656",
//                "preNodeId": "1853755013300662272",
//                "fieldDataId": null,
//                "branchSort": 1
//            },
@end

NS_ASSUME_NONNULL_END
