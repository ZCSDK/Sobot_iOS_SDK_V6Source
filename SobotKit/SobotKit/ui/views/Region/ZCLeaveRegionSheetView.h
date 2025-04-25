//
//  ZCLeaveRegionSheetView.h
//  SobotOrderSDK
//
//  Created by zhangxy on 2024/3/26.
//

#import "ZCLeaveRegionSheetView.h"
#import "ZCLeaveRegionEntity.h"

#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClient.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZCLeaveRegionSheetView : UIView


@property (strong, nonatomic) ZCOrderCusFiledsModel *fieldModel;


// 0 单选，1，多选
@property(nonatomic,assign) int showType;

@property(nonatomic,strong) NSString *pageTitle;

@property (nonatomic,strong) UITextField *textField;
@property(nonatomic,strong) UITableView *listTable;
//     线条
@property(nonatomic,strong)  UIView *topBottomLine;

// 如果有分类，使用此代码显示分类
@property (nonatomic,strong) UIScrollView *typeView;
@property (nonatomic,strong) UIView *typeBgView;
// topView的约束
@property (nonatomic,strong)NSLayoutConstraint *listVeiwH;
@property (nonatomic,strong)NSLayoutConstraint *typeVeiwH;
// 分类下的选项线条
@property (nonatomic,strong) UIView *topLineView;


@property (nonatomic,strong)NSLayoutConstraint *layoutBtmH;
@property (nonatomic,strong)NSLayoutConstraint *layoutBtmContentH;
// 底部按钮
@property (nonatomic,strong)UIButton *btnCommit;

// 1 总结分类
@property (nonatomic, strong)  void(^ChooseResultBlock) (id _Nullable item,NSString *names,NSString *ids);

// table始终显示的值
@property(nonatomic,strong)NSMutableArray   *listArray;

// 搜索出的数据
@property(nonatomic,strong)NSMutableArray   *searchArray;
@property (nonatomic,strong) NSMutableArray *defArray;

// @{title,checked,model}
@property (nonatomic,strong) NSDictionary *checkItem;// 用于UI显示比对

-(ZCLeaveRegionSheetView *)initAlterView:(NSString *) title;

- (void)showInView:(UIView * _Nullable)view;

- (void)closeSheetView;

-(void)reSetViewHeight;


-(void)textChangAction:(UITextField *)textField;
-(void)buttonCommit;

/***
 以下是业务开始
 */
-(void)createSubView;

// 可以重写
-(void)createButtomView;

-(void)hideAllWithOutTable;
-(void)hideTypeView;
-(void)hideSearchView;
-(void)hideBottomView;
-(void)showBottomView;
-(void)showSaveBtn;// 显示保存按钮


-(void)loadData;

// 需要设置curController

-(void)createPlaceHolder:(NSString *_Nullable) title message:(NSString *_Nullable) message image:(UIImage *_Nullable) placeImage;
-(void)removeHolderView;

-(void)buttonClick:(UIButton *)sender;

-(void)setBtnCommitTitleColor:(UIColor*)titleColor;
-(void)setBtnCommitBgColor:(UIColor*)bgColor;

@end

NS_ASSUME_NONNULL_END
