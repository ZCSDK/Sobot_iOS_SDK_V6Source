//
//  ZCServiceListVC.m
//  SobotKit
//
//  Created by lizh on 2022/9/27.
//

#import "ZCServiceListVC.h"
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClient.h>
#import "ZCUIKitTools.h"
#import "ZCServiceListCell.h"
#define  serviceCelIdentifier @"ZCServiceListCell"
#import "ZCServiceDetailVC.h"
@interface ZCServiceListVC ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong) UITableView *listView;
@property(nonatomic,strong) NSMutableArray *listArray;

@property (nonatomic,strong)NSLayoutConstraint *listR;
@property (nonatomic,strong)NSLayoutConstraint *listB;
@property (nonatomic,strong)NSLayoutConstraint *listY;
@property (nonatomic,strong)NSLayoutConstraint *listL;
@end

@implementation ZCServiceListVC

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }
}

#pragma mark - 返回事件
-(void)buttonClick:(UIButton *)sender{
    if (sender.tag == SobotButtonClickBack) {
        if (self.navigationController) {
            [self.navigationController popViewControllerAnimated:NO];
        }else{
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }
    [self createVCTitleView];
    [self updateNavOrTopView];
    self.view.backgroundColor = UIColorFromKitModeColor(SobotColorBgSub2Dark1);;
    _listArray = [NSMutableArray arrayWithCapacity:0];
    [self createListView];
    [self loadData];
}

-(void)createListView{
    // 屏蔽橡皮筋功能
    self.automaticallyAdjustsScrollViewInsets = NO;
//    // 计算Y值
    CGFloat TY = 0;
    if(self.navigationController && sobotIsNull(self.topView)){
        if (self.navigationController.navigationBar.translucent) {
            TY = NavBarHeight;
        }else{
            TY = 0;
        }
    }else{
        TY = NavBarHeight;
    }
    _listView = (SobotTableView *)[SobotUITools createTableWithView:self.view delegate:self style:UITableViewStylePlain];
    [self.view addSubview:_listView];
    [_listView registerClass:[ZCServiceListCell class] forCellReuseIdentifier:serviceCelIdentifier];
    _listView.backgroundColor = [UIColor clearColor];
    // 分割线的隐藏
//    _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //可以省略不设置
    _listView.rowHeight = UITableViewAutomaticDimension;
    self.listB = sobotLayoutPaddingBottom(-XBottomBarHeight, self.listView, self.view);
    self.listL = sobotLayoutPaddingLeft(0, self.listView, self.view);
    self.listR = sobotLayoutPaddingRight(0, self.listView, self.view);
    self.listY = sobotLayoutPaddingTop(TY, self.listView, self.view);
    [self.view addConstraint:self.listY];
    [self.view addConstraint:self.listB];
    [self.view addConstraint:self.listL];
    [self.view addConstraint:self.listR];
    [self setTableSeparatorInset];
}

#pragma mark - 加载数据
-(void)loadData{
    __weak ZCServiceListVC * saveSelf = self;
    [ZCLibServer getHelpDocByCategoryIdWith:self.appId CategoryId:self.categoryId start:^{
        [[SobotToast shareToast] showProgress:@"" with:self.view];
    } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
        if (dict) {
            NSArray * dataArr = dict[@"data"];
            if ([dataArr isKindOfClass:[NSArray class]] && dataArr.count > 0) {
                for (NSDictionary * item in dataArr) {
                    ZCSCListModel * model = [[ZCSCListModel alloc]initWithMyDict:item];
                    [saveSelf.listArray addObject:model];
                }
                if (saveSelf.listArray.count > 0) {
                    [saveSelf removePlaceholderView];
                    [saveSelf.listView reloadData];
                }else{
                    [self createPlaceHolderView:self.view title:SobotKitLocalString(@"暂无相关内容") desc:@"" image:nil block:nil];
                }
            }else{
                [self createPlaceHolderView:self.view title:SobotKitLocalString(@"暂无相关内容") desc:@"" image:nil block:nil];
            }
        }
        [[SobotToast shareToast] dismisProgress];
    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
        [[SobotToast shareToast] dismisProgress];
        [self createPlaceHolderView:self.view title:SobotKitLocalString(@"暂无相关内容") desc:@"" image:nil block:nil];
    }];
}

/**
 *  设置UITableView分割线空隙
 */
-(void)setTableSeparatorInset{
    UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, 0, 0);
    if ([_listView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_listView setSeparatorInset:inset];
    }
    if ([_listView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_listView setLayoutMargins:inset];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _listArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZCServiceListCell * cell = [tableView dequeueReusableCellWithIdentifier:serviceCelIdentifier];
    if (cell == nil) {
        cell = [[ZCServiceListCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:serviceCelIdentifier];
    }
    if(_listArray==nil || _listArray.count<indexPath.row){
        return cell;
    }
    ZCSCListModel * model = _listArray[indexPath.row];
    [cell initWithModel:model width:_listView.frame.size.width];
    [cell setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark1)];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZCSCListModel * model  = _listArray[indexPath.row];
    ZCServiceDetailVC *VC = [[ZCServiceDetailVC alloc]init];
    VC.appId = sobotConvertToString(self.appId);
    VC.docId = sobotConvertToString(model.docId);
    VC.questionTitle = sobotConvertToString(model.questionTitle);
    [VC setOpenZCSDKTypeBlock:self.OpenZCSDKTypeBlock];
    if (self.navigationController) {
        [self.navigationController pushViewController:VC animated:NO];
    }else{
        [self presentViewController:VC animated:NO completion:nil];
    }
}

#pragma mark - 更新导航栏
-(void)updateNavOrTopView{
    // 统计 系统导航栏上面的按钮
    NSMutableDictionary *navItemSource = [NSMutableDictionary dictionary];
    [navItemSource setObject:@{@"img":@"zcicon_titlebar_back_normal",@"imgsel":sobotConvertToString([ZCUICore getUICore].kitInfo.topBackNolImg)} forKey:@(SobotButtonClickBack)];
    // 更新系统导航栏的按钮
    self.navItemsSource = navItemSource;
    [self setLeftTags:@[@(SobotButtonClickBack)] rightTags:@[] titleView:nil];
    if (!self.navigationController.navigationBarHidden) {
        if([ZCUIKitTools getZCThemeStyle] == SobotThemeMode_Light){
            if(sobotGetSystemDoubleVersion() >= 13){
                self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
                self.navigationController.toolbar.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
            }
        }
        self.title = sobotConvertToString(self.titleName);
    }else{
        self.titleLabel.hidden = NO;
        self.backButton.hidden = NO;
        self.bottomLine.hidden = YES;
        self.titleLabel.text = sobotConvertToString(self.titleName);
    }
}

// 适配iOS 13以上的横竖屏切换
-(void)viewSafeAreaInsetsDidChange{
    [super viewSafeAreaInsetsDidChange];
    UIEdgeInsets e = self.view.safeAreaInsets;
    [self.view removeConstraint:self.listB];
    [self.view removeConstraint:self.listL];
    [self.view removeConstraint:self.listR];
    [self.view removeConstraint:self.listY];
    if(e.left > 0){
        // 横屏
        if (self.navigationController.navigationBarHidden || self.topView) {
            self.listY = sobotLayoutPaddingTop(NavBarHeight, _listView, self.view);
        }else{
            self.listY = sobotLayoutPaddingTop(e.top, _listView, self.view);
        }
        self.listL = sobotLayoutPaddingLeft(e.left, _listView, self.view);
        self.listR = sobotLayoutPaddingRight(-e.right, _listView, self.view);
        self.listB = sobotLayoutPaddingBottom(-e.bottom, _listView, self.view);
    }else{
        CGFloat TY = 0;
        if(self.navigationController && sobotIsNull(self.topView)){
            if (self.navigationController.navigationBar.translucent) {
                TY = NavBarHeight;
            }else{
                TY = 0;
            }
        }else{
            TY = NavBarHeight;
        }
        self.listY = sobotLayoutPaddingTop(TY, _listView, self.view);
        self.listL = sobotLayoutPaddingLeft(0, _listView, self.view);
        self.listR = sobotLayoutPaddingRight(0, _listView, self.view);
        self.listB = sobotLayoutPaddingBottom(-e.bottom, _listView, self.view);
    }
    [self.view addConstraint:self.listL];
    [self.view addConstraint:self.listR];
    [self.view addConstraint:self.listB];
    [self.view addConstraint:self.listY];
    if (!sobotIsNull(self.listArray) && self.listArray.count > 0) {
        // 这里解决横竖屏切换的
        [self.listView reloadData];
    }
    // 横竖屏更新导航栏渐变色
    [self updateCenterViewBgColor];
}

@end
