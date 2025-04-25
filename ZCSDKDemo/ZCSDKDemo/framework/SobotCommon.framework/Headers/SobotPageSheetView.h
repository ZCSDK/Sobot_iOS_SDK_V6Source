//
//  SobotPageSheetView.h
//  SobotCommon
//
//  Created by zhangxy on 2024/12/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/***
 SheetPage 底部弹起视图
 本视图为父类视图，仅包含主题框架
 ** view
 1：头部 topView (固定，不可删除)
 2：内容 centerView (自定义实现)
    headerView
        搜索
        多级分类
    内容(tableview或collectionview)
 3：底部内容 btmView
 
 ** 函数：
 显示
 关闭
 刷新数据(重新定义显示高度)
 
 使用示例：
 
 SobotPageSheetView *view = [[SobotPageSheetView alloc] init];
 view.titleLab.text = @"我是测试标题1我是测试标题2我是测试标题3我是测试标题4我是测试标题5我是测试标题xx";
 [view createHeaderView:YES addSearch:YES];
 [view createTable];
 view.listTable.backgroundColor = UIColor.greenColor;
 [view createBtmBtns:@[@"提交ssss提交ee提交eeee提交xxx提交3333提交xxx提交3333提交xtxxx提交3333提交cc",@"暂不取消"]];
 [view showSheet:400 animation:YES block:^{
     
 }];
 */
@interface SobotPageSheetView : UIView

@property (nonatomic,strong) UILabel *titleLab;

// 显示区域背景
@property (nonatomic,strong) UIView *bgView;

@property (nonatomic,strong) UIView *topView;
@property (nonatomic,strong) UIView *centerView;
@property (nonatomic,strong) UIView *btmView;


@property (nonatomic,strong) UIScrollView *typeView;

@property(nonatomic,strong) UITableView *listTable;
@property(nonatomic,assign) BOOL isMulCell;


// 如果执行了createCollection，则会自动创建
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *layout;


// 以下为显示数组，如果创建搜索或table会自动创建
// table始终显示的值
@property(nonatomic,strong)NSMutableArray   *listArray;

// @{title,check,model}
@property (nonatomic,strong) NSDictionary *checkItem;// 用于UI显示比对


// 关闭监听
@property (strong, nonatomic) void(^CloseClickBlock)(NSString *clickMsg,BOOL onlyDismiss);
@property (strong, nonatomic) void(^BtmClickBlock)(int tag);


// 多选确定
@property (nonatomic, strong)  void(^ChooseResultBlock) (id _Nullable item,NSString *names,NSString *ids);


/// 显示view
/// - Parameters:
///   - contentHeight: 内容的高度
///   - animation: 是否需要动画显示
///   - ShowBloc: 显示完成通知
- (void)showSheet:(CGFloat)contentHeight animation:(BOOL)animation block:(nonnull void (^)(void))ShowBloc;

/**
 关闭view
 */
- (void)closeSheetView;


/**
 如果有列表数据，刷新数据
 */
-(void)refreshData:(BOOL) showPlacehoder;


/** 根据需求创建view ****/
/***
 * 动态创建底部按钮，调用此方法会自动添加到底部btmView中
 * 如果需要特殊处理，使用btm.subviews[0...]获取button处理
 * - Parameter titles: 按钮title
 */
-(void)createBtmBtns:(NSArray *) titles;


/// 创建内容头部信息
/// - Parameters:
///   - isAddType: 是否添加多级分类显示信息
///   - isAddSearch: 是否添加搜索信息
-(void)createHeaderView:(BOOL) isAddType addSearch:(BOOL) isAddSearch;




/// 如果内容需要table，可直接调用此函数创建
-(void)createTable;


/// 创建collection
/// - Parameter column: 当前列
///
/// 需要重写：
//当前cell - (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
// 定义每个Cell的大小 - (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//
-(void)createCollectionView:(int) column;


@end

NS_ASSUME_NONNULL_END
