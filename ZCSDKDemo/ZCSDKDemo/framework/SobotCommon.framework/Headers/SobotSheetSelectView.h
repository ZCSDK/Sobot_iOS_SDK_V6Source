//
//  SobotSheetSelectView.h
//  SobotCommon
//  带标题、关闭，搜索和选项
//  Created by zhangxy on 2024/6/25.
//

#import <UIKit/UIKit.h>

#define SobotSheetSelectCellIdentifier @"SobotCallUITableViewCell"

NS_ASSUME_NONNULL_BEGIN

@interface SobotSheetSelectView : UIView

// 0 单选，1，多选
@property(nonatomic,assign) int showType;

@property(nonatomic,strong) NSString *pageTitle;

@property(nonatomic, strong) UIView *searchView;
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

// 底部按钮
@property (nonatomic,strong)UIButton *btnCommit;
// 主题色
@property (nonatomic,strong)UIColor *servecBgColor;
// 是否镜像
@property (nonatomic,assign) BOOL isRTL;


// 1 总结分类
@property (nonatomic, strong)  void(^ChooseResultBlock) (id _Nullable item,NSString *names,NSString *ids);

// table始终显示的值
@property(nonatomic,strong)NSMutableArray   *listArray;

// 搜索出的数据
@property(nonatomic,strong)NSMutableArray   *searchArray;

// @{title,check,model}
@property (nonatomic,strong) NSDictionary *checkItem;// 用于UI显示比对

-(SobotSheetSelectView *)initAlterView:(NSString *) title;

- (void)showInView:(UIView * _Nullable)view;

- (void)closeSheetView;

-(void)reSetViewHeight;


-(void)textChangAction:(UITextField *)textField;
-(void)buttonCommit;

/***
 以下是业务开始
 */
-(void)createSubView;

-(void)hideAllWithOutTable;
-(void)hideTypeView;
-(void)hideSearchView;
-(void)hideBottomView;
-(void)showBottomView;
-(void)showSaveBtn;// 显示保存按钮


-(void)loadData;
-(void)reloadTableData:(BOOL) showPlacehoder;
-(void)uncheckAllValue;

-(void)createPlaceHolder:(NSString *_Nullable) title message:(NSString *_Nullable) message image:(UIImage *_Nullable) placeImage;
-(void)removeHolderView;

-(void)buttonClick:(UIButton *)sender;





/// 高亮文字
/// - Parameters:
///   - string: 完整字符串
///   - Color: 颜色
///   - originalString: 匹配的内容
-(NSMutableAttributedString *)getOtherColorString:(NSString *)string Color:(UIColor *)Color withString:(NSString *)originalString;

@end

NS_ASSUME_NONNULL_END
