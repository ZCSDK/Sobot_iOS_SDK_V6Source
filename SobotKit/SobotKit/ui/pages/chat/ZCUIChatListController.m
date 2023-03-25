//
//  ZCUIChatListController.m
//  SobotKit
//
//  Created by zhangxy on 2022/9/29.
//

#import "ZCUIChatListController.h"

#import "ZCUIChatListCell.h"
#define cellIdentifier @"ZCUIChatListCell"

#import "ZCSobotApi.h"
#import "ZCUIKitTools.h"
#import "ZCUICore.h"

@interface ZCUIChatListController ()<UITableViewDelegate,UITableViewDataSource>{
    CGFloat y;
}

@property(nonatomic,strong)NSString      *partnerid;

@property(nonatomic,strong)UITableView      *listTable;
@property(nonatomic,strong)NSMutableArray   *listArray;
@property (nonatomic,assign) BOOL isHiddenNav;

@property(nonatomic,assign) BOOL isloading;
@property (nonatomic,strong)NSLayoutConstraint *listR;
@property (nonatomic,strong)NSLayoutConstraint *listB;
@property (nonatomic,strong)NSLayoutConstraint *listY;
@property (nonatomic,strong)NSLayoutConstraint *listL;
@end


@implementation ZCUIChatListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [ZCUICore getUICore].kitInfo = _kitInfo;
    
    self.automaticallyAdjustsScrollViewInsets = false;
    _isHiddenNav = self.navigationController.navigationBarHidden;
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }
    [self createVCTitleView];
    [self updateNavOrTopView];
    [self setTitle:SobotKitLocalString(@"消息中心")];
    
    [self createTableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadMoreData) name:@"ZCSobotChatlistLoadData" object:nil];
    
    [ZCNotificatCenter addObserver:self selector:@selector(onReceiveNewMessage:) name:SobotReceiveNewMessage object:nil];
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    [self loadMoreData];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

// button点击事件
-(IBAction)buttonClick:(UIButton *) sender{
    if(sender.tag == SobotButtonClickBack){
        if([ZCUICore getUICore].ZCViewControllerCloseBlock != nil){
            [ZCUICore getUICore].ZCViewControllerCloseBlock(self,ZC_CloseChatList);
        }
        [ZCIMChat getZCIMChat].delegate = nil;
        
        if(self.navigationController != nil && self.navigationController.viewControllers.count>1){
            self.byController.navigationController.navigationBarHidden = _isHiddenNav;
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
    }
}




-(void)createTableView{
    _listArray = [[NSMutableArray alloc] init];
    
    _listTable=[[UITableView alloc] init];
    [self.view addSubview:_listTable];
    
    if(self.navigationController && sobotIsNull(self.topView)){
        // 当translucent属性为YES的时候，vc的view的坐标从导航栏的左上角开始；
//        当translucent属性为NO的时候，vc的view的坐标从导航栏的左下角开始；
        if (self.navigationController.navigationBar.translucent) {
            self.listY = sobotLayoutPaddingTop(NavBarHeight, self.listTable, self.view);
        }else{
            self.listY = sobotLayoutPaddingTop(0, self.listTable, self.view);
        }
    }else{
        self.listY = sobotLayoutPaddingTop(NavBarHeight, self.listTable, self.view);
    }
    self.listB = sobotLayoutPaddingBottom(-XBottomBarHeight, self.listTable, self.view);
    self.listL = sobotLayoutPaddingLeft(0, self.listTable, self.view);
    self.listR = sobotLayoutPaddingRight(0, self.listTable, self.view);
    
    [self.view addConstraint:self.listY];
    [self.view addConstraint:self.listB];
    [self.view addConstraint:self.listL];
    [self.view addConstraint:self.listR];
    
    _listTable.delegate=self;
    _listTable.dataSource=self;
    [_listTable setSeparatorColor:[UIColor clearColor]];
    [_listTable setBackgroundColor:[UIColor clearColor]];
    _listTable.clipsToBounds=NO;
    [_listTable registerClass:[ZCUIChatListCell class] forCellReuseIdentifier:cellIdentifier];
    //可以省略不设置
    _listTable.rowHeight = UITableViewAutomaticDimension;
    _listTable.allowsSelection = YES;//该属性控制该表格是否允许被选中
    _listTable.allowsMultipleSelection = NO;//该属性控制该表格是否允许多选
    _listTable.allowsSelectionDuringEditing = NO;//该属性控制该表格处于编辑状态时是否允许被选中
    _listTable.allowsMultipleSelectionDuringEditing = NO; //该属性控制该表格处于编辑状态时是否允许多选。
    
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [_listTable setTableFooterView:view];
    [_listTable setTableHeaderView:view];
    
    if (iOS7) {
        _listTable.backgroundView = nil;
    }
    if (sobotGetSystemDoubleVersion()>= 15.0) {
        _listTable.sectionHeaderTopPadding = 0;
    }
    
    [_listTable setSeparatorColor:UIColorFromModeColor(SobotColorBgLine)];
    [_listTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self setTableSeparatorInset];
    
//    [ZCIMChat getZCIMChat].delegate = self;
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
        CGFloat y ;
        if ([ZCUICore getUICore].kitInfo.navcBarHidden || self.topView) {
            y = NavBarHeight;
            self.listY = sobotLayoutPaddingTop(y, _listTable, self.view);
        }else{
            self.listY = sobotLayoutPaddingTop(e.top, _listTable, self.view);
        }
        self.listL = sobotLayoutPaddingLeft(e.left, _listTable, self.view);
        self.listR = sobotLayoutPaddingRight(-e.right, _listTable, self.view);
        self.listB = sobotLayoutPaddingBottom(-e.bottom, _listTable, self.view);
        
    }else{
        CGFloat y ;
        if(self.navigationController && self.topView==nil){
            if (self.navigationController.navigationBar.translucent) {
                y = NavBarHeight;
            }else{
                y = 0;
            }
        }else{
            y = NavBarHeight;
        }
        self.listY = sobotLayoutPaddingTop(y, _listTable, self.view);
        self.listL = sobotLayoutPaddingLeft(0, _listTable, self.view);
        self.listR = sobotLayoutPaddingRight(0, _listTable, self.view);
        self.listB = sobotLayoutPaddingBottom(-e.bottom, _listTable, self.view);
    }
    [self.view addConstraint:self.listL];
    [self.view addConstraint:self.listR];
    [self.view addConstraint:self.listB];
    [self.view addConstraint:self.listY];
    
    // 横竖屏更新导航栏渐变色
//    [self updateTopViewBgColor];
    // 横竖屏更新导航栏渐变色
    [self updateCenterViewBgColor];
}

/**
 加载更多
 */
-(void)loadMoreData{
    if (self.isloading ) {
        return;
    }
    self.isloading = YES;
    if (_listArray) {
        [_listArray removeAllObjects];
    }
    _partnerid = [ZCLibClient getZCLibClient].libInitInfo.partnerid;
    _listArray = [[ZCPlatformTools sharedInstance] getPlatformList:[[ZCPlatformTools sharedInstance] getPlatformUserId]];
//    if(_listArray.count == 0){
    
    __weak ZCUIChatListController * listVC = self;
    __block NSMutableArray *difObject = [NSMutableArray arrayWithCapacity:0];
        [ZCLibServer getPlatformMemberNews:_partnerid start:^(NSString *url){
            
        } success:^(NSMutableArray *news, NSDictionary *dictionary, ZCNetWorkCode sendCode) {
            listVC.isloading = NO;
            // 对比appkey是否相同 相同用本地的替换 接口的
            //找到news中有,_listArray中没有的数据
            [news enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                ZCPlatformInfo *info1 = (ZCPlatformInfo*)obj;
                __block BOOL isHave = NO;
                [_listArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    ZCPlatformInfo *info2 = (ZCPlatformInfo*)obj;
                    if ([info1.app_key isEqual:info2.app_key]) {
                        if (info1.avatar.length >0) {
                            info2.avatar = info1.avatar;
                        
                        }
                        if (info1.platformName.length >0) {
                            info2.platformName  = info1.platformName;
                        }
                        
                        if (info1.lastDate.length >0) {
                            info2.lastDate = info1.lastDate;
                        }
                        isHave = YES;
                        *stop = YES;
                    }
                }];
                if (!isHave) {
                    [difObject addObject:info1];
                }
            }];
            
            if (difObject.count >0) {
                [_listArray addObjectsFromArray:difObject];
            }
            [difObject removeAllObjects];
//            _listArray = news;
            [listVC sortedListArray];
        } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
            [listVC sortedListArray];
            listVC.isloading = NO;
        }];
//    }else{
//        [_listTable reloadData];
//    }
}

-(void)sortedListArray{
    if (_listArray.count >1) {
        [_listArray sortUsingComparator:^NSComparisonResult(ZCPlatformInfo * obj1, ZCPlatformInfo * obj2) {
            NSString * time1 = obj1.lastDate;
            NSString * time2 = obj2.lastDate;
             return [time2 compare:time1];
        }];
    }
    
     [_listTable reloadData];
}

#pragma mark UITableView delegate Start
// 返回section数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

// 返回section高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
     if(_listArray==nil || _listArray.count==0){
        return 80;
    }else{
        return 0;
    }
}

// 返回section 的View
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(_listArray==nil || _listArray.count==0){
        UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 80)];
        [view setBackgroundColor:[UIColor clearColor]];
        
        UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(12, 40, ScreenWidth-24, 40)];
        [label setFont:SobotFont12];
        [label setText:[NSString stringWithFormat:@"%@!",SobotKitLocalString(@"暂无相关内容")]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setTextColor:[ZCUIKitTools zcgetTimeTextColor]];
        [label setBackgroundColor:[UIColor clearColor]];
        [view addSubview:label];
        return view;
    }
    return nil;
}

// 返回section下得行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_listArray==nil){
        return 0;
    }
    return _listArray.count;
}

// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZCUIChatListCell *cell = (ZCUIChatListCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell =  (ZCUIChatListCell*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        
        
    }
    if(indexPath.row==_listArray.count-1){
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
        
        if([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
            [cell setPreservesSuperviewLayoutMargins:NO];
        }
    }
    
    if(_listArray.count < indexPath.row){
        return cell;
    }
    
    ZCPlatformInfo *model=[_listArray objectAtIndex:indexPath.row];
    [cell dataToView:model];
    
    
    return cell;
}



// 是否显示删除功能
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

// 删除清理数据
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        ZCPlatformInfo *model = [_listArray objectAtIndex:indexPath.row];
        
        [[ZCPlatformTools sharedInstance] deletePlatformByAppKey:sobotConvertToString(model.app_key) user:sobotConvertToString(model.partnerid)];
        
        [ZCLibServer delPlatformMemberByUser:model.listId start:^(NSString *url){
        } success:^(NSDictionary *dictionary, ZCNetWorkCode sendCode) {
            if (dictionary && [dictionary[@"code"] intValue] ==1) {
                [_listArray removeObject:model];
                [_listTable reloadData];
            }
        } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
            
        }];
    }
    
}


// table 行的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(_listArray==nil || _listArray.count<indexPath.row){
        return;
    }
    ZCPlatformInfo *info = [_listArray objectAtIndex:indexPath.row];
    if([ZCLibClient getZCLibClient].libInitInfo==nil || ![info.app_key isEqual:[ZCLibClient getZCLibClient].libInitInfo.app_key]){
        if(sobotConvertToString(info.configJson).length > 0){
            [ZCLibClient getZCLibClient].libInitInfo = [[ZCLibInitInfo alloc] initByJsonDict:[SobotCache dictionaryWithJsonString:sobotConvertToString(info.configJson)]];
        }else{
            ZCLibInitInfo *initinfo = [ZCLibInitInfo new];
            initinfo.app_key = info.app_key;
            initinfo.partnerid = _partnerid;
            [ZCLibClient getZCLibClient].libInitInfo = initinfo;
        }
    }
    [ZCIMChat getZCIMChat].delegate = nil;
    
    
//  BOOL  isaa =  [ZCSobot getPlatformIsArtificialWithAppkey:info.appkey Uid:info.uid];
//    NSLog(@"%d",isaa);
    
    if(_OnItemClickBlock){
        _OnItemClickBlock(self,info);
    }else{
        [ZCSobotApi openZCChat:_kitInfo with:self pageBlock:nil];
    }
    
}



//设置分割线间距
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if((indexPath.row+1) < _listArray.count){
        [self setTableSeparatorInset];
    }
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self setTableSeparatorInset];
}

#pragma mark UITableView delegate end

/**
 *  设置UITableView分割线空隙
 */
-(void)setTableSeparatorInset{
    UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, 0, 0);
    if ([_listTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [_listTable setSeparatorInset:inset];
    }
    
    if ([_listTable respondsToSelector:@selector(setLayoutMargins:)]) {
        [_listTable setLayoutMargins:inset];
    }
}


#pragma mark 监听消息
-(void)onReceiveNewMessage:(NSNotification *) info{
    NSDictionary *userInfo = info.userInfo;
    SobotChatMessage *message = userInfo[@"message"];
//    NSDictionary *dict = userInfo[@"obj"];
//    ZCReceivedMessageType type = [userInfo[@"receivetype"] integerValue];
    
    if(!sobotIsNull(message)){
        [self loadMoreData];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ZCSobotChatlistLoadData" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SobotReceiveNewMessage object:nil];
}

-(void)updateNavOrTopView{
    // 统计 系统导航栏上面的按钮
    NSMutableArray *rightItem = [NSMutableArray array];
    NSMutableDictionary *navItemSource = [NSMutableDictionary dictionary];
    [rightItem addObject:@(SobotButtonClickBack)];
    [navItemSource setObject:@{@"img":@"zcicon_titlebar_back_normal",@"imgsel":sobotConvertToString([ZCUICore getUICore].kitInfo.topBackNolImg)} forKey:@(SobotButtonClickBack)];
    // 更新系统导航栏的按钮
    self.navItemsSource = navItemSource;
    [self setLeftTags:rightItem rightTags:@[] titleView:nil];
    if (!self.navigationController.navigationBarHidden) {
        if([ZCUIKitTools getZCThemeStyle] == SobotThemeMode_Light){
            if(sobotGetSystemDoubleVersion() >= 13){
                self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
                self.navigationController.toolbar.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
            }
        }
    }else{
        self.titleLabel.hidden = NO;
        self.backButton.hidden = NO;
//        self.bottomLine.hidden = YES;
    }
}


@end

