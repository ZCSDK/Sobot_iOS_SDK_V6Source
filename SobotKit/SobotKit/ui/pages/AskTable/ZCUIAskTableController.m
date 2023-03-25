//
//  ZCUIAskTableController.m
//  SobotKit
//
//  Created by lizh on 2022/9/15.
//

#import "ZCUIAskTableController.h"
#import <SobotChatClient/SobotChatClient.h>
#import <SobotCommon/SobotCommon.h>
#import "ZCUIKitTools.h"
#import "ZCOrderContentCell.h"
#define cellOrderContentIdentifier @"ZCOrderContentCell"
#import "ZCOrderOnlyEditCell.h"
#define cellOrderSingleIdentifier @"ZCOrderOnlyEditCell"
#import "ZCOrderEditCell.h"
#define cellEditIdentifier @"ZCOrderEditCell"
#import "ZCOrderCheckCell.h"
#define cellCheckIdentifier @"ZCOrderCheckCell"
#import "ZCZHPickView.h"
#import "ZCCheckCusFieldView.h"
#import "ZCPageSheetView.h"
#import "ZCCheckMulCusFieldView.h"
#import "ZCUIWebController.h"
#import "SobotHtmlFilter.h"
#import "ZCCheckCityView.h"

@interface ZCUIAskTableController ()<UITextFieldDelegate,UITextViewDelegate,UIGestureRecognizerDelegate,UINavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate,SobotEmojiLabelDelegate,UIScrollViewDelegate,ZCZHPickViewDelegate,ZCOrderCreateCellDelegate>
{
    // 链接点击
    void (^LinkedClickBlock) (NSString *url);
    // 呼叫的电话号码
    NSString *callURL;
    ZCOrderCusFiledsModel *curEditModel;
    CGPoint contentoffset;// 记录list的偏移量
    CGFloat headerViewH ;// 区头的高度
}
@property (nonatomic, assign) BOOL isSend;// 是否正在发送
@property (nonatomic,strong) UITableView *listView;
@property (nonatomic,strong) NSMutableArray *listArray;
@property(nonatomic,strong)NSMutableArray *coustomArr;// 用户自定义字段数组
@property(nonatomic,strong)UITextView *tempTextView;
@property(nonatomic,strong)UITextField *tempTextField;
@property (nonatomic,strong) UIView *placeholderView;
@property (nonatomic,copy) NSString *detailStr;// 表单描述
@property (nonatomic,strong) ZCAddressModel *addressModel;
@property (nonatomic,strong)UIButton *commitBtn;// 提交按钮

@property (nonatomic,strong)NSLayoutConstraint *listR;
@property (nonatomic,strong)NSLayoutConstraint *listB;
@property (nonatomic,strong)NSLayoutConstraint *listY;
@property (nonatomic,strong)NSLayoutConstraint *listL;


@end

@implementation ZCUIAskTableController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }
    self.view.backgroundColor = [ZCUIKitTools zcgetLightGrayDarkBackgroundColor];
    [self createVCTitleView];
    [self updateNavOrTopView];
    // 创建列表
    [self createTableView];
    if(!self.navigationController.navigationBarHidden){
        self.title = SobotKitLocalString(@"请填写询前表单");
    }else{
        self.titleLabel.text = SobotKitLocalString(@"请填写询前表单");
    }
    
    // 加载数据
    [self loadDataForPage];
    // 布局子页面
    [self refreshViewData];
}

-(void)setDict:(NSMutableDictionary *)dict{
    _dict = dict;
    [self loadDataForPage];
    [self refreshViewData];
}

-(void)refreshViewData{
    [_listArray removeAllObjects];
    // 0，特殊行   1 单行文本 2 多行文本 3 日期 4 时间 5 数值 6 下拉列表 7 复选框 8 单选框 9 级联字段
    // propertyType == 1是自定义字段，0固定字段, 3不可点击
    NSMutableArray * arr1 = [NSMutableArray arrayWithCapacity:0];
    if (_coustomArr.count >0 && ![_coustomArr isKindOfClass:[NSNull class]]) {
        int index = 0;
        for (ZCOrderCusFiledsModel *cusModel in _coustomArr) {
            NSString *propertyType = @"1";
            NSString * titleStr = sobotConvertToString(cusModel.fieldName);
            if([sobotConvertToString(cusModel.fillFlag) intValue] == 1){
                titleStr = [NSString stringWithFormat:@"%@ *",titleStr];
            }
            // 城市
            if ([sobotConvertToString(cusModel.fieldId) isEqualToString:@"city"] ) {
                cusModel.fieldValue = [NSString stringWithFormat:@"%@%@%@", sobotConvertToString(self.addressModel.provinceName) ,sobotConvertToString(self.addressModel.cityName) ,sobotConvertToString(self.addressModel.areaName)];
                cusModel.fieldSaveValue = cusModel.fieldValue;
            }
            
            if ([sobotConvertToString(cusModel.fieldId) isEqualToString:@"qq"]) {
                cusModel.fieldType = @"5";
            }
            [arr1 addObject:@{@"code":[NSString stringWithFormat:@"%d",index],
                              @"dictName":sobotConvertToString(cusModel.fieldName),
                              @"dictDesc":sobotConvertToString(titleStr),
                              @"placeholder":sobotConvertToString(cusModel.fieldRemark),
                              @"dictValue":sobotConvertToString(cusModel.fieldValue),
                              @"dictType":sobotConvertToString(cusModel.fieldType),
                              @"propertyType":propertyType,
                              @"dictfiledId":sobotConvertToString(cusModel.fieldId),
                              @"model":cusModel
                              }];
            index = index + 1;
        }

        [_listArray addObjectsFromArray:arr1];
    }
    [self reloadHeaderView];
    [_listView reloadData];
}
-(void)reloadHeaderView{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    if (_coustomArr.count) {
        [view setBackgroundColor:UIColorFromKitModeColor(SobotColorBgSub2Dark1)];
        SobotEmojiLabel *label=[[SobotEmojiLabel alloc] initWithFrame:CGRectMake(15, 15, ScreenWidth-30, 0)];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [label setFont:SobotFont14];
        //    [label setText:_listArray[section][@"sectionName"]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextAlignment:NSTextAlignmentLeft];
        [label setTextColor:UIColorFromKitModeColor(SobotColorTextSub)];
        label.numberOfLines = 0;
        label.isNeedAtAndPoundSign = NO;
        label.disableEmoji = NO;
        label.lineSpacing = 3.0f;
        [label setLinkColor:[ZCUIKitTools zcgetChatLeftLinkColor]];
        label.delegate = self;
        
        NSString *text = self.detailStr;
        [SobotHtmlCore filterHtml:text result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
            if (text1 !=nil && text1.length > 0) {
                label.attributedText =   [SobotHtmlFilter setHtml:text1 attrs:arr view:label textColor:UIColorFromKitModeColor(SobotColorTextSub) textFont:SobotFont14 linkColor:[ZCUIKitTools zcgetChatLeftLinkColor]];
            }else{
                label.attributedText = [[NSAttributedString alloc] initWithString:@""];
            }
        }];
        CGSize  labSize  =  [label preferredSizeWithMaxWidth:ScreenWidth-30];
        label.frame = CGRectMake(15, 12, labSize.width, labSize.height);
        [view addSubview:label];
        
        CGRect VF = view.frame;
        VF.size.height = labSize.height + 24;
        view.frame = VF;
        
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, view.frame.size.height - 1, ScreenWidth, 0.5)];
        lineView.backgroundColor = UIColorFromKitModeColor(SobotColorBgLine);
        lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [view addSubview:lineView];
    }else{
        view.frame = CGRectMake(0, 0, ScreenWidth, 0.01);
    }
    headerViewH = CGRectGetHeight(view.frame);
    self.listView.tableHeaderView = view;
}

#pragma mark - 构建子视图
-(void)createTableView{
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
    _listView = (SobotTableView *)[SobotUITools createTableWithView:self.view delegate:self style:UITableViewStyleGrouped];
    [self.view addSubview:_listView];
    
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
    _listView.backgroundColor = [UIColor clearColor];
    _listArray = [[NSMutableArray alloc]init];
    
    _listView.clipsToBounds = YES;
    [_listView registerClass:[ZCOrderCheckCell class] forCellReuseIdentifier:cellCheckIdentifier];
    [_listView registerClass:[ZCOrderEditCell class] forCellReuseIdentifier:cellEditIdentifier];
    [_listView registerClass:[ZCOrderOnlyEditCell class] forCellReuseIdentifier:cellOrderSingleIdentifier];
    [_listView setSeparatorColor:UIColorFromKitModeColor(SobotColorBgLine)];
    [self setTableSeparatorInset];
    
    UIView * footView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 15 + 30 + 80)];
    footView.backgroundColor = [UIColor clearColor];
    footView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

//    UIView *lineView_2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.5)];
//    lineView_2.backgroundColor = UIColorFromKitModeColor(SobotColorBgLine);
//    [footView addSubview:lineView_2];
    
    int th = 0;
    if(sobotConvertToString(_dict[@"formSafety"]).length > 0){
        // todo
        UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(15, 10, ScreenWidth-30, 0)];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [label setFont:SobotFont14];
        [label setText:sobotConvertToString(_dict[@"formSafety"])];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextAlignment:NSTextAlignmentLeft];
        [label setTextColor:UIColorFromKitModeColor(SobotColorTextSub)];
        label.numberOfLines = 0;
        [label sizeToFit];
        [footView addSubview:label];
        th = CGRectGetMaxY(label.frame);
    }
    
    // 区尾添加提交按钮 2.7.1改版
    _commitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_commitBtn setTitle:SobotKitLocalString(@"提交并咨询") forState:UIControlStateNormal];
    [_commitBtn setTitle:SobotKitLocalString(@"提交并咨询") forState:UIControlStateSelected];
    [_commitBtn setBackgroundColor:[ZCUIKitTools zcgetRobotBtnBgColor]];
    [_commitBtn setTitleColor:[ZCUIKitTools zcgetLeaveSubmitTextColor] forState:UIControlStateNormal];
    [_commitBtn setTitleColor:[ZCUIKitTools zcgetLeaveSubmitTextColor] forState:UIControlStateHighlighted];
    _commitBtn.tag = BUTTON_MORE;
    [_commitBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    _commitBtn.layer.masksToBounds = YES;
    _commitBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _commitBtn.layer.cornerRadius = SobotNumber(22);
    _commitBtn.titleLabel.font = SobotFontBold17;
    [footView addSubview:_commitBtn];
    [footView addConstraint:sobotLayoutPaddingTop(th + SobotNumber(15), _commitBtn, footView)];
    [footView addConstraint:sobotLayoutPaddingLeft(SobotNumber(15), _commitBtn, footView)];
    [footView addConstraint:sobotLayoutPaddingRight(SobotNumber(-15), _commitBtn, footView)];
    [footView addConstraint:sobotLayoutEqualHeight(SobotNumber(44), _commitBtn, NSLayoutRelationEqual)];
    _listView.tableFooterView = footView;
    _isSend = NO;
    
    self.listView.backgroundColor = [ZCUIKitTools zcgetLightGrayDarkBackgroundColor];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHideKeyboard)];
    gestureRecognizer.numberOfTapsRequired = 1;
    gestureRecognizer.cancelsTouchesInView = NO;
    [_listView addGestureRecognizer:gestureRecognizer];
    
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
    [self updateTopViewBgColor];
}

-(void)loadDataForPage{
    if (_coustomArr == nil) {
        _coustomArr = [NSMutableArray arrayWithCapacity:0];
    }else{
        [_coustomArr removeAllObjects];
    }
    if (_dict) {
        if(sobotConvertToString(_dict[@"formTitle"]).length >0){
            if(!self.navigationController.navigationBarHidden){
                self.title = SobotKitLocalString(sobotConvertToString(_dict[@"formTitle"]));
            }else{
                self.titleLabel.text = SobotKitLocalString(sobotConvertToString(_dict[@"formTitle"]));
            }
        }
        if (![_dict[@"fields"] isKindOfClass:[NSNull class]]) {
            for (NSDictionary * item  in _dict[@"fields"]) {
                ZCOrderCusFiledsModel * model = [[ZCOrderCusFiledsModel alloc]initWithMyDict:item];
                [_coustomArr addObject:model];
            }
        }
        self.detailStr = sobotConvertToString(_dict[@"formDoc"]);
    }
    if (_coustomArr.count<1) {
        [self createPlaceHolderView:self.view title:SobotKitLocalString(@"网络原因请求超时 重新加载") desc:nil image:[UIImage imageNamed:@"zcicon_networkfail"] block:nil];
    }else{
        [self removePlaceholderView];
    }
}

// 提交请求
- (void)UpLoadWith:(NSMutableDictionary*)dict{
    if(_isSend){
        return;
    }
    _isSend = YES;
     NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    // 添加自定义字段
    if (_coustomArr>0) {
        [dic setValue:sobotConvertToString([SobotCache dataTOjsonString:dict]) forKey:@"customerFields"];
    }
    // 调用接口
    [ZCLibServer postAskTabelWithUid:[self getZCLibConfig].uid Parms:dic start:^{
        
    } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
        [[SobotToast shareToast] showToast:SobotKitLocalString(@"提交成功") duration:1.0f view:self.view position:SobotToastPositionCenter Image:[SobotUITools getSysImageByName:@"zcicon_successful"]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self backAction];
            if (self->_trunServerBlock) {
                self->_trunServerBlock(NO);
            }
            self->_isSend = NO;
        });
    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
         self->_isSend = NO;
        [[SobotToast shareToast] showToast:errorMessage duration:1.0f view:self.view position:SobotToastPositionCenter];
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

#pragma mark -- 返回和提交
-(void)buttonClick:(UIButton*)sender{
    if (sender.tag != BUTTON_MORE) {
        // 点击技能组的Item 之后会记录当前点选的技能组，返回是置空 重新显示技能组弹框
        if (_isclearskillId) {
            [ZCUICore getUICore].checkGroupId = @"";
            [ZCUICore getUICore].checkGroupName = @"";
        }
        
        [ZCUICore getUICore].isShowForm = NO;
        [self backAction];
        if (_trunServerBlock) {
            _trunServerBlock(YES);
        }
    }else{
        NSMutableDictionary *cusFields = [NSMutableDictionary dictionaryWithCapacity:0];
        // 自定义字段
        for (ZCOrderCusFiledsModel *cusModel in _coustomArr) {
            if([cusModel.fillFlag intValue] == 1 && sobotIsNull(cusModel.fieldValue)){
                [[SobotToast shareToast] showToast:[NSString stringWithFormat:@"%@%@",cusModel.fieldName,SobotKitLocalString(@"不能为空")] duration:1.0f view:self.view position:SobotToastPositionCenter];
                return;
            }
            if(![self checkContentValid:cusModel.fieldSaveValue model:cusModel]){
                [[SobotToast shareToast] showToast:[NSString stringWithFormat:@"%@%@",cusModel.fieldName,SobotKitLocalString(@"格式不正确")] duration:1.0f view:self.view position:SobotToastPositionCenter];
                return;
            }
            if( [@"tel" isEqual:sobotConvertToString(cusModel.fieldId)] && sobotConvertToString(cusModel.fieldValue).length>0 && !sobotValidateMobile(sobotConvertToString(cusModel.fieldValue))){
                [[SobotToast shareToast] showToast:[NSString stringWithFormat:@"%@%@",cusModel.fieldName,SobotKitLocalString(@"格式不正确")] duration:1.0f view:self.view position:SobotToastPositionCenter];
                return;
            }
            if( [@"email" isEqual:sobotConvertToString(cusModel.fieldId)] && sobotConvertToString(cusModel.fieldValue).length>0 && !sobotValidateEmail(sobotConvertToString(cusModel.fieldValue))){
                [[SobotToast shareToast] showToast:SobotKitLocalString(@"请输入正确的邮箱") duration:1.0f view:self.view position:SobotToastPositionCenter];
                return;
            }
            if(!sobotIsNull(cusModel.fieldSaveValue)){
                if (![@"city" isEqualToString:sobotConvertToString(cusModel.fieldId)]) {
                    if([cusModel.fieldType intValue] == 9){
                        [cusFields setObject:@{@"id":sobotConvertToString(cusModel.fieldId),
                                               @"text":sobotConvertToString(cusModel.fieldValue),
                                               @"value":sobotConvertToString(cusModel.fieldSaveValue)
                                               } forKey:sobotConvertToString(cusModel.fieldId)];
                    
                    }else{
                        [cusFields setObject:sobotConvertToString(cusModel.fieldSaveValue) forKey:sobotConvertToString(cusModel.fieldId)];
                        
                    }
                }else if([@"city" isEqualToString:sobotConvertToString(cusModel.fieldId)]){
                    [cusFields setObject:sobotConvertToString(_addressModel.provinceId) forKey:@"proviceId"];
                    [cusFields setObject:sobotConvertToString(_addressModel.provinceName) forKey:@"proviceName"];
                    [cusFields setObject:sobotConvertToString(_addressModel.cityId) forKey:@"cityId"];
                    [cusFields setObject:sobotConvertToString(_addressModel.cityName) forKey:@"cityName"];
                    [cusFields setObject:sobotConvertToString(_addressModel.areaId) forKey:@"areaId"];
                    [cusFields setObject:sobotConvertToString(_addressModel.areaName) forKey:@"areaName"];
                }
            }
        
        }
        [self UpLoadWith:cusFields];
        [self allHideKeyBoard];
    }
}

#pragma mark - 格式校验
-(BOOL)checkContentValid:(NSString *) text model:(ZCOrderCusFiledsModel *) model{
    if(model != nil && sobotConvertToString(text).length >0){
        NSArray *limitOptions = nil;
        if([model.limitOptions isKindOfClass:[NSString class]]){
            NSString *limitOption =  sobotConvertToString(model.limitOptions);
            limitOption = [limitOption stringByReplacingOccurrencesOfString:@"[" withString:@""];
            limitOption = [limitOption stringByReplacingOccurrencesOfString:@"]" withString:@""];
            limitOptions = [limitOption componentsSeparatedByString:@","];
        }else if([model.limitOptions isKindOfClass:[NSArray class]]){
            limitOptions = model.limitOptions;
        }
        if(limitOptions==nil || limitOptions.count == 0){
            return YES;
        }
        //限制方式  1禁止输入空格   2 禁止输入小数点  3 小数点后只允许2位  4 禁止输入特殊字符  5只允许输入数字 6最多允许输入字符  7判断邮箱格式  8判断手机格式
        if([limitOptions containsObject:[NSNumber numberWithInt:1]] || [limitOptions containsObject:@"1"]){
            NSRange _range = [text rangeOfString:@" "];
            if(_range.location!=NSNotFound) {
                return NO;
            }
        }
        if([limitOptions containsObject:[NSNumber numberWithInt:2]] || [limitOptions containsObject:@"2"]){
             NSRange _range = [text rangeOfString:@"."];
            if(_range.location!=NSNotFound) {
                return NO;
            }
        }
        if([limitOptions containsObject:[NSNumber numberWithInt:3]] || [limitOptions containsObject:@"3"]){
             return sobotValidateFloatWithNum(text,2);
        }
        if([limitOptions containsObject:[NSNumber numberWithInt:4]] || [limitOptions containsObject:@"4"]){
             return sobotValidateRuleNotBlank(text);
        }
        
        if([limitOptions containsObject:[NSNumber numberWithInt:5]] || [limitOptions containsObject:@"5"]){
             return sobotValidateNumber(text);
        }
        
        if([limitOptions containsObject:[NSNumber numberWithInt:6]] || [limitOptions containsObject:@"6"]){
            if(sobotConvertToString(text).length > [model.limitChar intValue]){
                return NO;
            }
        }
        
        if([limitOptions containsObject:[NSNumber numberWithInt:7]] || [limitOptions containsObject:@"7"]){
            return sobotValidateEmail(text);
        }
        
        if([limitOptions containsObject:[NSNumber numberWithInt:8]] || [limitOptions containsObject:@"8"]){
            return sobotValidateMobileWithRegex(text, [ZCUIKitTools zcgetTelRegular]);
        }
        
    }
    return YES;
}

#pragma mark - 返回事件
-(void)backAction{
    if (self.navigationController != nil) {
        [self.navigationController popViewControllerAnimated:NO];
    }else{
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

-(ZCLibConfig *)getZCLibConfig{
    return [self getPlatformInfo].config;
}
-(ZCPlatformInfo *) getPlatformInfo{
    return [[ZCPlatformTools sharedInstance] getPlatformInfo];
}
#pragma mark -- uitabelView delegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self allHideKeyBoard];
}

// 返回section数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
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
    ZCOrderCreateCell *cell = nil;
    // 0，特殊行   1 单行文本 2 多行文本 3 日期 4 时间 5 数值 6 下拉列表 7 复选框 8 单选框 9 级联字段
    NSDictionary *itemDict = _listArray[indexPath.row];
    int type = [itemDict[@"dictType"] intValue];
    if(type == 1 || type ==5){
        cell = (ZCOrderOnlyEditCell*)[tableView dequeueReusableCellWithIdentifier:cellOrderSingleIdentifier];
        if (cell == nil) {
            cell = [[ZCOrderOnlyEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellOrderSingleIdentifier];
        }
    }else if(type == 2){
        cell = (ZCOrderEditCell*)[tableView dequeueReusableCellWithIdentifier:cellEditIdentifier];
        if (cell == nil) {
            cell = [[ZCOrderEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellEditIdentifier];
        }
    }else{
        cell = (ZCOrderCheckCell*)[tableView dequeueReusableCellWithIdentifier:cellCheckIdentifier];
        if (cell == nil) {
            cell = [[ZCOrderCheckCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellCheckIdentifier];
        }
    }
    [cell setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark1)];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.tableWidth = self.listView.frame.size.width;
    cell.delegate = self;
    cell.tempDict = itemDict;
    cell.indexPath = indexPath;
    [cell initDataToView:itemDict];
    return cell;
}

// 是否显示删除功能
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

// 删除清理数据
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    editingStyle = UITableViewCellEditingStyleDelete;
}

// table 行的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *itemDict = _listArray[indexPath.row];
    if([itemDict[@"propertyType"] intValue]==3){
        return;
    }
    // 0，特殊行   1 单行文本 2 多行文本 3 日期 4 时间 5 数值 6 下拉列表 7 复选框 8 单选框 9 级联字段
    int propertyType = [itemDict[@"propertyType"] intValue];
    if(propertyType == 1){
        int index = [itemDict[@"code"] intValue];
        curEditModel = _coustomArr[index];
        int fieldType = [curEditModel.fieldType intValue];
        if(fieldType == 4){
            ZCZHPickView *pickView = [[ZCZHPickView alloc] initWithFrame:self.view.frame DatePickWithDate:[NSDate new]  datePickerMode:UIDatePickerModeTime isHaveNavControler:NO];
            pickView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
            pickView.delegate = self;
            [pickView show];
        }
        if(fieldType == 3){
            ZCZHPickView *pickView = [[ZCZHPickView alloc] initWithFrame:self.view.frame DatePickWithDate:[NSDate new]  datePickerMode:UIDatePickerModeDate isHaveNavControler:NO];
            pickView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
            pickView.delegate = self;
            [pickView show];
        }
        if(fieldType == 9){
            __weak  ZCUIAskTableController *weakSelf = self;
            // 城市 级联字段
            if ([itemDict[@"dictfiledId"] isEqualToString:@"city"]) {
                ZCCheckCityView *cityVC = [[ZCCheckCityView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
                ZCPageSheetView *sheetView = [[ZCPageSheetView alloc] initWithTitle:SobotKitLocalString(@"选择") superView:self.view showView:cityVC type:ZCPageSheetTypeLong];
                cityVC.pageTitle = itemDict[@"dictDesc"];
                cityVC.parentView = nil;
                cityVC.levle = 1;
                cityVC.orderTypeCheckBlock = ^(ZCAddressModel *model) {
                    weakSelf.addressModel = model;
                    // 刷新 城市
                    [self refreshViewData];
                    [sheetView dissmisPageSheet];
                };
                [sheetView showSheet:cityVC.frame.size.height animation:YES block:^{
                    
                }];
                return;
            }else{
                __block ZCUIAskTableController *myself = self;
                ZCCheckMulCusFieldView *typeVC = [[ZCCheckMulCusFieldView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
                ZCPageSheetView *sheetView = [[ZCPageSheetView alloc] initWithTitle:SobotKitLocalString(@"选择") superView:self.view showView:typeVC type:ZCPageSheetTypeLong];
                typeVC.parentDataId = @"";
                typeVC.parentView = nil;
                typeVC.allArray = curEditModel.detailArray;
                typeVC.orderCusFiledCheckBlock = ^(ZCOrderCusFieldsDetailModel *model, NSString *dataIds,NSString *dataNames) {
                    self->curEditModel.fieldValue = dataNames;
                    self->curEditModel.fieldSaveValue = dataIds;
                    [myself refreshViewData];
                    [sheetView dissmisPageSheet];
                };
                [sheetView showSheet:typeVC.frame.size.height animation:YES block:^{
                    
                }];
            }
            return;
        }
        
        if(fieldType == 6 || fieldType == 7 || fieldType == 8){
            ZCCheckCusFieldView *vc = [[ZCCheckCusFieldView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
            vc.preModel = curEditModel;
            vc.orderCusFiledCheckBlock = ^(ZCOrderCusFieldsDetailModel *model, NSMutableArray *arr) {
                self->curEditModel.fieldValue = model.dataName;
                self->curEditModel.fieldSaveValue = model.dataValue;
                if(fieldType == 7){
                    NSString *dataName = @"";
                    NSString *dataIds = @"";
                    for (ZCOrderCusFieldsDetailModel *item in arr) {
                        dataName = [dataName stringByAppendingFormat:@",%@",item.dataName];
                        dataIds = [dataIds stringByAppendingFormat:@",%@",item.dataValue];
                    }
                    if(dataName.length>0){
                        dataName = [dataName substringWithRange:NSMakeRange(1, dataName.length-1)];
                        dataIds = [dataIds substringWithRange:NSMakeRange(1, dataIds.length-1)];
                    }
                    self->curEditModel.fieldValue = dataName;
                    self->curEditModel.fieldSaveValue = dataIds;
                }
                [self refreshViewData];
            };
            ZCPageSheetView *sheetView = [[ZCPageSheetView alloc] initWithTitle:SobotKitLocalString(@"选择") superView:self.view showView:vc type:ZCPageSheetTypeLong];
            [sheetView showSheet:vc.frame.size.height animation:YES block:^{
                
            }];
            return;
        }
        
        __weak  ZCUIAskTableController *weakSelf = self;
        // 城市 级联字段
        if ([itemDict[@"dictfiledId"] isEqualToString:@"city"]) {
            ZCCheckCityView *cityVC = [[ZCCheckCityView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
            
            ZCPageSheetView *sheetView = [[ZCPageSheetView alloc] initWithTitle:SobotKitLocalString(@"选择") superView:self.view showView:cityVC type:ZCPageSheetTypeLong];
            
//            ZCUIAskCityController * cityVC = [[ZCUIAskCityController alloc]init];
            cityVC.pageTitle = itemDict[@"dictDesc"];
            cityVC.parentView = nil;
            cityVC.levle = 1;
            cityVC.orderTypeCheckBlock = ^(ZCAddressModel *model) {
                weakSelf.addressModel = model;
                // 刷新 城市
                [self refreshViewData];
                
                [sheetView dissmisPageSheet];
            };
            
            
            [sheetView showSheet:cityVC.frame.size.height animation:YES block:^{
                
            }];
            return;
        }
    }
}

//设置分割线间距
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if((indexPath.row+1) < _listArray.count){
        UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, 0, 0);
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:inset];
        }
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:inset];
        }
    }
}

#pragma mark --  监听左滑返回的事件
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // 解决ios7调用系统的相册时出现的导航栏透明的情况
    if ([navigationController isKindOfClass:[UIImagePickerController class]]) {
        viewController.navigationController.navigationBar.translucent = NO;
        viewController.edgesForExtendedLayout = UIRectEdgeNone;
        return;
    }
    id<UIViewControllerTransitionCoordinator> tc = navigationController.topViewController.transitionCoordinator;
    __weak ZCUIAskTableController *weakSelf = self;
    [tc notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        if(![context isCancelled]){
            // 设置页面不能使用边缘手势关闭
//            if(iOS7 && navigationController!=nil){
//                navigationController.interactivePopGestureRecognizer.enabled = NO;
//            }
            [weakSelf backAction];
        }
    }];
}


#pragma mark EmojiLabel链接点击事件
// 链接点击
- (void)attributedLabel:(SobotAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    [self doClickURL:url.absoluteString text:@""];
}

// 链接点击
- (void)SobotEmojiLabel:(SobotEmojiLabel*)emojiLabel didSelectLink:(NSString*)link withType:(SobotEmojiLabelLinkType)type{
    [self doClickURL:link text:@""];
}

// 链接点击
-(void)doClickURL:(NSString *)url text:(NSString * )htmlText{
    if(url){
        url=[url stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        if(LinkedClickBlock){
            LinkedClickBlock(url);
        }else{
            if([url hasPrefix:@"tel:"] || sobotValidateMobile(url)){
                callURL=url;
                [SobotUITools showAlert:nil message:[url stringByReplacingOccurrencesOfString:@"tel:" withString:@""] cancelTitle:SobotKitLocalString(@"取消") viewController:self confirm:^(NSInteger buttonTag) {
                    if(buttonTag>=0){
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self->callURL]];
                    }
                } buttonTitles:SobotKitLocalString(@"呼叫"), nil];
                
            }else if([url hasPrefix:@"mailto:"] || sobotValidateEmail(url)){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            }else{
                if (![url hasPrefix:@"https"] && ![url hasPrefix:@"http"]) {
                    url = [@"http://" stringByAppendingString:url];
                }
                ZCUIWebController *webPage=[[ZCUIWebController alloc] initWithURL:sobotUrlEncodedString(url)];
                if(self.navigationController != nil ){
                    [self.navigationController pushViewController:webPage animated:YES];
                }else{
                    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:webPage];
                    nav.navigationBarHidden=YES;
                    nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
                    [self presentViewController:nav animated:YES completion:^{
                        
                    }];
                }
            }
        }
    }
}
#pragma mark --- EmojiLabel链接点击事件 end

#pragma mark - 隐藏键盘
-(void)tapHideKeyboard{
    if(!sobotIsNull(_tempTextView)){
        [_tempTextView resignFirstResponder];
        _tempTextView = nil;
    }else if(!sobotIsNull(_tempTextField)){
        [_tempTextField resignFirstResponder];
        _tempTextField  = nil;
    }else{
        [self allHideKeyBoard];
    }
    if(contentoffset.x != 0 || contentoffset.y != 0){
        // 隐藏键盘，还原偏移量
        [_listView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

- (void) hideKeyboard {
    if(!sobotIsNull(_tempTextView)){
        [_tempTextView resignFirstResponder];
        _tempTextView = nil;
    }else if(!sobotIsNull(_tempTextField)){
        [_tempTextField resignFirstResponder];
        _tempTextField  = nil;
    }else{
        [self allHideKeyBoard];
    }
    if(contentoffset.x != 0 || contentoffset.y != 0){
        // 隐藏键盘，还原偏移量
        [_listView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

- (void)allHideKeyBoard
{
    for (UIWindow* window in [UIApplication sharedApplication].windows)
    {
        for (UIView* view in window.subviews)
        {
            [self dismissAllKeyBoardInView:view];
        }
    }
}

-(BOOL) dismissAllKeyBoardInView:(UIView *)view
{
    if([view isFirstResponder])
    {
        [view resignFirstResponder];
        return YES;
    }
    for(UIView *subView in view.subviews)
    {
        if([self dismissAllKeyBoardInView:subView])
        {
            return YES;
        }
    }
    return NO;
}

#pragma mark - 更新导航栏
-(void)updateNavOrTopView{
    // 统计 系统导航栏上面的按钮
    NSMutableArray *rightItem = [NSMutableArray array];
    NSMutableDictionary *navItemSource = [NSMutableDictionary dictionary];
    [rightItem addObject:@(SobotButtonClickBack)];
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
    }else{
        self.moreButton.hidden = YES;
        self.titleLabel.hidden = NO;
        self.backButton.hidden = NO;
        self.bottomLine.hidden = YES;
    }
}


#pragma mark UITableViewCell 行点击事件处理
-(void)itemCreateCusCellOnClick:(ZCOrderCreateItemType)type dictValue:(NSString *)value dict:(NSDictionary *)dict indexPath:(NSIndexPath *)indexPath{
    // 单行或多行文本，是自定义字段，需要单独处理_coustomArr对象的内容
    if(type == ZCOrderCreateItemTypeOnlyEdit || type == ZCOrderCreateItemTypeMulEdit){
        int propertyType = [dict[@"propertyType"] intValue];
        if(propertyType == 1){
            int index = [dict[@"code"] intValue];
            ZCOrderCusFiledsModel *temModel = _coustomArr[index];
            temModel.fieldValue = value;
            temModel.fieldSaveValue = value;
            
            _listArray[indexPath.row] = @{@"code":[NSString stringWithFormat:@"%d",index],
                                    @"dictName":sobotConvertToString(temModel.fieldName),
                                    @"dictDesc":sobotConvertToString(temModel.fieldName),
                                    @"placeholder":sobotConvertToString(temModel.fieldRemark),
                                    @"dictValue":sobotConvertToString(temModel.fieldValue),
                                    @"dictType":sobotConvertToString(temModel.fieldType),
                                    @"propertyType":@"1"
                                    };
        }
    }
}

#pragma mark 日期控件
-(void)toobarDonBtnHaveClick:(ZCZHPickView *)pickView resultString:(NSString *)resultString{
    //    NSLog(@"%@",resultString);
    if(curEditModel && ([curEditModel.fieldType intValue]== 4 || [curEditModel.fieldType intValue] == 3)){
        curEditModel.fieldValue = resultString;
        curEditModel.fieldSaveValue = resultString;
        [self refreshViewData];
    }
}
#pragma mark -- 系统键盘的监听事件
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 影藏NavigationBar
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
//    if (iOS7) {
//        if (self.navigationController !=nil) {
//            self.navigationController.interactivePopGestureRecognizer.delegate = nil;
//            self.navigationController.delegate = nil;
//        }
//    }
    // 移除键盘的监听
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



-(void)keyboardHide:(NSNotification*)notification{
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView beginAnimations:@"bottomBarDown" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView commitAnimations];
}



#pragma mark -- 键盘滑动的高度
-(void)didKeyboardWillShow:(NSIndexPath *)indexPath view1:(UITextView *)textview view2:(UITextField *)textField{
    _tempTextView = textview;
    _tempTextField = textField;
    
    //获取当前cell在tableview中的位置
    CGRect rectintableview = [_listView rectForRowAtIndexPath:indexPath];
    
    //获取当前cell在屏幕中的位置
    CGRect rectinsuperview = [_listView convertRect:rectintableview fromView:[_listView superview]];
    
    contentoffset = _listView.contentOffset;
    
    if ((rectinsuperview.origin.y+50 - _listView.contentOffset.y)>200) {
        
        [_listView setContentOffset:CGPointMake(_listView.contentOffset.x,((rectintableview.origin.y-_listView.contentOffset.y)-150)+  _listView.contentOffset.y) animated:YES];
        
    }
}
@end
