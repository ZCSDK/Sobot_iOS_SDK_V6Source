//
//  ZCUIAskTableView.m
//  SobotKit
//
//  Created by lizh on 2024/11/6.
//

#import "ZCUIAskTableView.h"
#define cellIdentifier @"ZCUITableViewCell"
#import "ZCPageSheetView.h"
#import "ZCUICore.h"
#import "ZCUIKitTools.h"
#import <SobotChatClient/SobotFormNodeRespVosModel.h>
#import <SobotChatClient/SobotFormNodeRelRespVos.h>
#import "ZCUIAskTableCell.h"
#import "ZCCheckCusFieldView.h"
#import "ZCAskCusFieldView.h"
#define ZCSheetTitleH 52
@interface ZCUIAskTableView ()<UITableViewDelegate,UITableViewDataSource,ZCUIAskTableCellDelegate,UIGestureRecognizerDelegate>{
    NSMutableDictionary *checkDict;
    // 屏幕宽高
    CGFloat                     viewWidth;
    CGFloat                     viewHeigth;
    CGPoint contentoffset;// 记录list的偏移量
    SobotFormNodeRespVosModel *curEditModel;
    BOOL isClose;
}

@property(nonatomic,strong) UITableView *listTable;
@property(nonatomic,strong) NSMutableArray *mulArr;
@property(nonatomic,strong)UIView *topView;
@property(nonatomic,strong)UIButton *backButton;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UITextField *searchField;
@property(nonatomic,strong)UIView *bottomView;
@property(nonatomic,strong)UILabel *tipLab;
@property(nonatomic,strong)UIButton *commitBtn;

@property(nonatomic,strong)UITextView *tempTextView;
@property(nonatomic,strong)UITextField *tempTextField;
@property(nonatomic,strong)NSIndexPath *indexPath;
// 关系树节点
@property(nonatomic,strong)NSMutableArray *formNodeRelRespVos;
// 全部字段节点+连接线节点
@property(nonatomic,strong)NSMutableArray *formNodeRespVos;
// 头节点
@property(nonatomic,strong)SobotFormNodeRespVosModel *headerModel;
//显示首屏数据
@property(nonatomic,strong)NSMutableArray *firstShowArr;
// 头部引导文案的高度
@property(nonatomic,assign)CGFloat hearderHeight;
// 键盘的高度
@property(nonatomic,assign)CGFloat keyboardH;

@property(nonatomic,assign)BOOL isSend;
// 提交成功
@property(nonatomic,assign)BOOL isCommitSuccess;
// 画布ID 提交接口使用
@property(nonatomic,copy) NSString *canvasId;

@property(nonatomic,strong)ZCAskCusFieldView *vc;
// 最终底部区域的高度
@property(nonatomic,assign)CGFloat lastBotmH;
// 顶部标题的高度动态计算
@property(nonatomic,assign)CGFloat topViewH;
@end

@implementation ZCUIAskTableView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
        self.autoresizesSubviews = YES;
        [self createTableView];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didRotate:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)didRotate:(NSNotification *)notification {
   
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
        viewWidth = ScreenWidth;
        viewHeigth = ScreenHeight;
        // 横屏
//        NSLog(@"横屏");
    } else if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown) {
        // 竖屏
//        NSLog(@"竖屏");
        viewWidth = ScreenWidth;
        viewHeigth = ScreenHeight;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        // 先移除后创建
        if (self.bottomView) {
            [self.bottomView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [self.bottomView removeFromSuperview];
        }
       
        if (self.topView) {
            [self.topView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [self.topView removeFromSuperview];
        }
        
        if (self.listTable) {
            [self.listTable removeFromSuperview];
        }
        [self createTableView];
        self.dict = self.dict;
        [self updataPage];
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self createTableView];
    }
    return self;
}

-(void)createTableView{
    self.topViewH = 52;
    self.lastBotmH = 72-16;// 去掉底部边距
    [self createTitleView];
    [self createBottomView];
    _listArray = [NSMutableArray array];
    _listTable = [[UITableView alloc]initWithFrame:CGRectMake(0, self.topViewH, ScreenWidth, 0) style:UITableViewStyleGrouped];
    _listTable.delegate = self;
    _listTable.dataSource = self;
    [_listTable registerClass:[ZCUIAskTableCell class] forCellReuseIdentifier:@"ZCUIAskTableCell"];
    [self addSubview:_listTable];
    [_listTable setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark1)];
//    [_listTable setBackgroundColor:UIColor.blueColor];
    UIView * bgview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    // 这里判断是否显示 声明
    _listTable.tableFooterView = bgview;
    _listTable.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_listTable setSeparatorColor:[ZCUIKitTools zcgetCommentButtonLineColor]];
    [_listTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    // 关闭安全区域，否则UITableViewCell横屏时会是全屏的宽
    NSString *version = [UIDevice currentDevice].systemVersion;
    if (version.doubleValue >= 11.0) {
        [_listTable setInsetsContentViewsToSafeArea:NO];
    }
    
//    [self setTableSeparatorInset];
    checkDict  = [NSMutableDictionary dictionaryWithCapacity:0];
    if(_listArray == nil){
        _listArray = [[NSMutableArray alloc] init];
    }
    _listTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    _listTable.separatorColor = [UIColor clearColor];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHideKeyboard)];
    gestureRecognizer.numberOfTapsRequired = 1;
    gestureRecognizer.cancelsTouchesInView = NO;
   gestureRecognizer.delegate = self;
    [_listTable addGestureRecognizer:gestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)createBottomView{
    _bottomView = ({
        UIView *iv = [[UIView alloc]init];
        [self addSubview:iv];
        iv.frame = CGRectMake(0, self.frame.size.height - 72-16 , ScreenWidth, self.lastBotmH);
        iv.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
//        iv.backgroundColor = UIColor.redColor;
        iv;
    });
        
    _commitBtn = ({
        UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bottomView addSubview:iv];
        iv.layer.masksToBounds = YES;
        iv.layer.cornerRadius = 4;
        iv.frame = CGRectMake(16, 16, ScreenWidth - 32, 40);
        [iv setTitle:SobotKitLocalString(@"提交") forState:0];
        [iv setTitleColor:UIColorFromKitModeColor(SobotColorWhite) forState:0];
        [iv setBackgroundColor:[ZCUIKitTools zcgetServerConfigBtnBgColor]];
        iv.titleLabel.font = SobotFont16;
        [iv addTarget:self action:@selector(commitAction:) forControlEvents:UIControlEventTouchUpInside];
        iv;
    });
    
    // 这里判断是否显示 声明
    if ([[ZCUICore getUICore] getLibConfig].formAuthFlag == 1 &&sobotConvertToString([[ZCUICore getUICore] getLibConfig].formExplain).length >0 ) {
        if ([[[ZCUICore getUICore] getLibConfig].formEffectiveScope containsString:@"2"]) {
            _tipLab = ({
                UILabel *iv = [[UILabel alloc]init];
                [_bottomView addSubview:iv];
                iv.textColor = UIColorFromKitModeColor(SobotColorTextSub1);
                iv.text = sobotConvertToString([[ZCUICore getUICore] getLibConfig].formExplain);
                iv.font = SobotFont12;
                iv.frame = CGRectMake(16, 0, ScreenWidth - 32, 22);
                iv.numberOfLines = 0;
                iv;
            });
            
        }
        
    }
    
    if (sobotIsNull(_tipLab)) {
        // 没有开启搜集说明
        _bottomView.frame = CGRectMake(0, self.frame.size.height - self.lastBotmH , ScreenWidth, self.lastBotmH);
        _commitBtn.frame = CGRectMake(16, 16, ScreenWidth - 32, 40);
    }else{
        // 计算文本高度
        CGRect ivf = [self getTextRectWith:ScreenWidth - 32 AddLabel:_tipLab];
        CGFloat lh = ivf.size.height;
        self.lastBotmH = self.lastBotmH + lh;
        _bottomView.frame = CGRectMake(0, self.frame.size.height - self.lastBotmH , ScreenWidth,self.lastBotmH);
        // 重新布局提交按钮的位置
        CGRect cmitF = _commitBtn.frame;
        cmitF.origin.y = _bottomView.frame.size.height - 40;
        _commitBtn.frame = cmitF;
        self.tipLab.frame = ivf;
    }    
}

#pragma mark -- 计算文本高度
-(CGRect)getTextRectWith:(CGFloat)width  AddLabel:(UILabel *)label{
    CGSize size = [self autoHeightOfLabel:label with:width];
    CGRect labelF = label.frame;
    labelF.size.height = size.height;
    label.frame = labelF;
    return labelF;
}

/**
 计算Label高度
 
 @param label 要计算的label，设置了值
 @param width label的最大宽度
 @param type 是否从新设置宽，1设置，0不设置
 */
- (CGSize )autoHeightOfLabel:(UILabel *)label with:(CGFloat )width{
    CGSize maximumLabelSize = CGSizeMake(width, FLT_MAX);
    CGSize expectedLabelSize = [label sizeThatFits:maximumLabelSize];// 返回最佳的视图大小
    //adjust the label the the new height.
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    label.frame = newFrame;
    [label updateConstraintsIfNeeded];
    return expectedLabelSize;
}


#pragma mark -- 刷新数据源
-(void)setDict:(NSDictionary *)dict{
    if (!sobotIsNull(dict) && [[dict allKeys] containsObject:@"item"]) {
        NSDictionary *item = [dict objectForKey:@"item"];
        self.canvasId = sobotConvertToString([item objectForKey:@"id"]);
        NSArray *formNodeRelRespVos = [item objectForKey:@"formNodeRelRespVos"];
        NSArray *formNodeRespVos = [item objectForKey:@"formNodeRespVos"];
        self.formNodeRelRespVos = [NSMutableArray array];
        self.formNodeRespVos = [NSMutableArray array];
        for (NSDictionary *relVos in formNodeRelRespVos) {
            SobotFormNodeRelRespVos *model = [[SobotFormNodeRelRespVos alloc] initWithMyDict:relVos];
            [self.formNodeRelRespVos addObject:model];
        }
        for (NSDictionary *vos in formNodeRespVos) {
            SobotFormNodeRespVosModel *model = [[SobotFormNodeRespVosModel alloc]initWithMyDict:vos];
            [self.formNodeRespVos addObject:model];
        }
        
        if (self.formNodeRespVos.count > 0 && self.formNodeRelRespVos.count > 0) {
            // 处理显示数据
            self.headerModel = self.formNodeRespVos[0];
            // 找到要显示的第一屏数据 直到单选节点停止
            self.firstShowArr = [NSMutableArray array];
            NSString *preNodeId = self.headerModel.rid;
            self.firstShowArr = [self getShowArr:preNodeId showTempArr:self.firstShowArr];
            [self refreshViewData:YES isChange:NO changeModel:nil];
        }
        
    }
    _dict = dict;
}

#pragma mark -- 单选之后的查询方案
-(NSMutableArray *)getShowDataArr:(NSString *)fieldDataId showTempArr:(NSMutableArray *)showTempArr{
    SobotFormNodeRelRespVos * nextRelVos = [self searchNextDataId:fieldDataId];
    SobotFormNodeRespVosModel * vosModel = [self searchNextVos:nextRelVos.nextNodeId];
    if (vosModel.nodeType == 2) {
        // 连线节点 不添加 继续查找
        return [self getShowArr:vosModel.rid showTempArr:showTempArr];
    }else if(vosModel.fieldType == 8){
        // 查看是否是被选中的，如果是选中的要添加下一级
        [showTempArr addObject:vosModel];
    }else if(vosModel.fieldType == 1){
        // 单行文本 查询是否有下一级
        [showTempArr addObject:vosModel];
        return [self getShowArr:vosModel.rid showTempArr:showTempArr];
    }else{
        if (!sobotIsNull(vosModel)) {
            // 同单行文本
            return [self getShowArr:vosModel.rid showTempArr:showTempArr];
        }
    }
    return showTempArr;
}
#pragma mark -- 查询下一个节点信息 通过选中的子节点节点找
-(SobotFormNodeRelRespVos *)searchNextDataId:(NSString *)preNodeId{
    for (SobotFormNodeRelRespVos *model in self.formNodeRelRespVos) {
        if ([model.fieldDataId isEqualToString:preNodeId]) {
            return model;
        }
    }
    return [SobotFormNodeRelRespVos new];
}

#pragma mark -- 循环查询并添加要显示的数据
// 上一个父关系节点
-(NSMutableArray *)getShowArr:(NSString *)preNodeId showTempArr:(NSMutableArray *)showTempArr {
//    NSMutableArray *showTempArr = [NSMutableArray array];
    SobotFormNodeRelRespVos * nextRelVos = [self searchNextRelVos:preNodeId];
    if (sobotConvertToString(nextRelVos.nextNodeId).length == 0) {
        return showTempArr;
    }
    //通过关系树节点查看
//    1.信息节点对象是否是连线节点
//    2.是否是单选节点
//    3.单选节点是否选中
//      4.fieldDataId 单选之后的节点是通过这个字段查询的
    SobotFormNodeRespVosModel * vosModel = [self searchNextVos:nextRelVos.nextNodeId];
    if (vosModel.nodeType == 2) {
        // 连线节点 不添加 继续查找
        return [self getShowArr:vosModel.rid showTempArr:showTempArr];
    }else if(vosModel.fieldType == 8){
        // 查看是否是被选中的，如果是选中的要添加下一级
        [showTempArr addObject:vosModel];
    }else if(vosModel.fieldType == 1){
        // 单行文本 查询是否有下一级
        [showTempArr addObject:vosModel];
        return [self getShowArr:vosModel.rid showTempArr:showTempArr];
    }else{
        if (!sobotIsNull(vosModel)) {
            // 同单行文本
            return [self getShowArr:vosModel.rid showTempArr:showTempArr];
        }
    }
    return showTempArr;
}


#pragma mark -- 查询下一个节点信息 通过父节点找
-(SobotFormNodeRelRespVos *)searchNextRelVos:(NSString *)preNodeId{
    for (SobotFormNodeRelRespVos *model in self.formNodeRelRespVos) {
        if ([model.preNodeId isEqualToString:preNodeId]) {
            return model;
        }
    }
    return [SobotFormNodeRelRespVos new];
}

#pragma mark -- 通过关系节点找到 信息节点
-(SobotFormNodeRespVosModel *)searchNextVos:(NSString *)nextNodeId{
    if (!sobotIsNull(self.formNodeRespVos) && self.formNodeRespVos.count >0) {
        for (SobotFormNodeRespVosModel *model in self.formNodeRespVos) {
            if ([model.rid isEqualToString:sobotConvertToString(nextNodeId)]) {
                return model;
            }
        }
    }
    return [SobotFormNodeRespVosModel new];
}

-(void)updataPage{
    CGFloat tipH = 0;
    if (!sobotIsNull(_tipLab)) {
        tipH = 24;
    }
    
    self.titleLabel.text = SobotKitLocalString(@"请填写询前表单");
    
    CGFloat th = [SobotUITools getHeightContain:SobotKitLocalString(@"请填写询前表单") font:SobotFont16 Width:viewWidth-32];
    if (th <= 22) {
        th = 22 + 30;
    }else{
        th = th +30;
    }
    self.topViewH = th;
   
    CGRect topViewF = self.topView.frame;
    topViewF.size.height = th;
    self.topView.frame = topViewF;
    CGRect titleLabelF = self.titleLabel.frame;
    titleLabelF.size.height = th;
    
    
    [_listTable reloadData];
    CGRect f = self.listTable.frame;
    f.origin.y = th;
    f.size.height = _listArray.count * 72 + self.hearderHeight; // 间距40
    // 这里需要获取最终的高度
    CGRect bf = _bottomView.frame;
    float footHeight = bf.size.height;// 底部提交按钮的高度
    
    // 如果支持模糊搜索或最大高度限制
    CGFloat fh = ScreenHeight * 0.8;
    if (ScreenWidth >ScreenHeight) {
        fh = ScreenHeight * 0.9;
    }
    if(f.size.height > fh - 52 - footHeight -self.topViewH){
        f.size.height = fh - 52 - footHeight -self.topViewH;
    }
    _listTable.frame = f;
    [self setFrame:CGRectMake(0, 0, self.frame.size.width, f.size.height + self.topViewH + footHeight + tipH)];
    self.superview.frame = CGRectMake(0, ScreenHeight - CGRectGetMaxY(self.frame), self.frame.size.width, CGRectGetMaxY(self.frame));
    [self setFrame:CGRectMake(0, 0, ScreenWidth, f.size.height + self.topViewH + footHeight)];
    // 顶部切圆角
    [self addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadii:CGSizeMake(8, 8) withView:self.topView];
    [self addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadii:CGSizeMake(8, 8) withView:self];
    CGRect btf = _bottomView.frame;
    btf.origin.y = self.frame.size.height - btf.size.height;
    _bottomView.frame = btf;
}


-(void)layoutSubviews{
    [super layoutSubviews];
    if (isClose) {
        return;
    }
    CGFloat tipH = 0;
    if (!sobotIsNull(_tipLab)) {
        tipH = 24;
    }
    
    self.titleLabel.text = SobotKitLocalString(@"请填写询前表单");
    
    CGFloat th = [SobotUITools getHeightContain:SobotKitLocalString(@"请填写询前表单") font:SobotFont16 Width:viewWidth-32];
    if (th <= 22) {
        th = 22 + 30;
    }else{
        th = th +30;
    }
    self.topViewH = th;
   
    CGRect topViewF = self.topView.frame;
    topViewF.size.height = th;
    self.topView.frame = topViewF;
    CGRect titleLabelF = self.titleLabel.frame;
    titleLabelF.size.height = th;
    
    if (self.keyboardH >0) {
        
    }else{
        CGRect f = self.listTable.frame;
        // 16的间距是为了提交按钮在底部对齐
        f.size.height = _listArray.count * 72 + self.hearderHeight;
        float footHeight = 0;
        footHeight = _bottomView.frame.size.height;
        // 如果支持模糊搜索或最大高度限制
        if(f.size.height > ScreenHeight * 0.8 -52 - footHeight - self.topViewH){
            f.size.height = ScreenHeight * 0.8-52 - footHeight - self.topViewH;
        }
       f.origin.y = th;
        int direction = [SobotUITools getCurScreenDirection];
           CGFloat spaceX = 0;
           CGFloat LW = self.frame.size.width;
           // iphoneX 横屏需要单独处理
           if(direction > 0){
               LW = self.frame.size.width - XBottomBarHeight;
           }
           if(direction == 2){
               spaceX = XBottomBarHeight;
           }
        f.origin.x = spaceX;
        f.size.width = LW;
       _listTable.frame = f;
        [_listTable reloadData];
        [self setFrame:CGRectMake(0, 0, self.frame.size.width, f.size.height + self.topViewH + footHeight+tipH)];
        self.superview.frame = CGRectMake(0, ScreenHeight - CGRectGetMaxY(self.frame) -XBottomBarHeight, self.frame.size.width, CGRectGetMaxY(self.frame));
        [self addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadii:CGSizeMake(8, 8) withView:self.topView];
        [self addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadii:CGSizeMake(8, 8) withView:self];
        CGRect btf = _bottomView.frame;
        btf.origin.y = self.frame.size.height - btf.size.height;
        _bottomView.frame = btf;
    }
}


-(void)buttonClick:(UIButton *) btn{
    if(btn.tag == BUTTON_BACK){
        if (_isclearskillId) {
            [ZCUICore getUICore].checkGroupId = @"";
            [ZCUICore getUICore].checkGroupName = @"";
        }
        [ZCUICore getUICore].isShowForm = NO;
        if (_trunServerBlock) {
            _trunServerBlock(YES);
        }
        isClose = YES;
        [(ZCPageSheetView *)self.superview.superview  dissmisPageSheet];
    }
}


/**
 *  设置UITableView分割线空隙
 */
-(void)setTableSeparatorInset{
    UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, 0, ScreenWidth);
    if ([_listTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [_listTable setSeparatorInset:inset];
    }
    if ([_listTable respondsToSelector:@selector(setLayoutMargins:)]) {
        [_listTable setLayoutMargins:inset];
    }
    
}

//设置分割线间距
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    // 不要线条
//    if((indexPath.row+1) < _listArray.count){
//        [self setTableSeparatorInset];
//    }
}

-(void)viewDidLayoutSubviews{
//    [self setTableSeparatorInset];
}

#pragma mark -- tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _listArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    // 获取实际高度 ，这里高度是固定的，本期只有 单选和单行
    return 72;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *iv = [[UIView alloc]init];
    iv.backgroundColor = UIColorFromKitModeColor(SobotColorBgF5);
    UILabel *tiplab = [[UILabel alloc]init];
    tiplab.text = @"";
    if (!sobotIsNull(self.headerModel)) {
        tiplab.text = sobotConvertToString(self.headerModel.tips);
    }
    if ([ZCUIKitTools getSobotIsRTLLayout]) {
        tiplab.textAlignment = NSTextAlignmentRight;
    }else{
        tiplab.textAlignment = NSTextAlignmentLeft;
    }
    tiplab.textColor = UIColorFromKitModeColor(SobotColorTextSub1);
    tiplab.numberOfLines = 0;
    tiplab.font = SobotFont14;
    tiplab.frame = CGRectMake(16, 12, ScreenWidth-32, 44);
    [iv addSubview:tiplab];
    [tiplab sizeToFit];
    CGRect ivf = iv.frame;
    ivf.size.height = tiplab.frame.size.height + 24;
    iv.frame = ivf;
    return iv;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    UILabel *tiplab = [[UILabel alloc]init];
    tiplab.text = @"";
    if (!sobotIsNull(self.headerModel)) {
        tiplab.text = sobotConvertToString(self.headerModel.tips);
    }
    tiplab.textColor = UIColorFromKitModeColor(SobotColorTextSub1);
    tiplab.numberOfLines = 0;
    tiplab.font = SobotFont14;
    tiplab.frame = CGRectMake(16, 12, ScreenWidth-32, 44);
    [tiplab sizeToFit];
    // 获取最终的头部高度 计算整体高度 切圆角使用
    self.hearderHeight = tiplab.frame.size.height + 24;
    return tiplab.frame.size.height + 24;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZCUIAskTableCell *cell = (ZCUIAskTableCell*)[tableView dequeueReusableCellWithIdentifier:@"ZCUIAskTableCell"];
    if (cell == nil) {
        cell = [[ZCUIAskTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCUIAskTableCell"];
    }
    [cell setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark1)];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    NSDictionary *dict = [_listArray objectAtIndex:indexPath.row];
    cell.delegate = self;
    cell.indexPath = indexPath;
    [cell initDataToView:dict];
    return cell;
}


// table 行的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    NSDictionary *itemDict = _listArray[indexPath.row];
//    if([itemDict[@"propertyType"] intValue]==3){
//        return;
//    }
//    NSString *dictName = itemDict[@"dictName"];
//    // 0，特殊行   1 单行文本 2 多行文本 3 日期 4 时间 5 数值 6 下拉列表 7 复选框 8 单选框 9 级联字段
//    int propertyType = [itemDict[@"propertyType"] intValue];
//    if(propertyType == 1){
//        NSDictionary *dict = _listArray[indexPath.row];
//        curEditModel = (SobotFormNodeRespVosModel*)[dict objectForKey:@"model"];
//        int fieldType = curEditModel.fieldType ;
//        if(fieldType == 6 || fieldType == 7 || fieldType == 8){
//            ZCAskCusFieldView *vc = [[ZCAskCusFieldView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0)];
//            vc.cusModel = curEditModel;
//            vc.orderCusFiledCheckBlock = ^(ZCOrderCusFieldsDetailModel *model, NSMutableArray *arr) {
//                self->curEditModel.fieldValue = model.dataName;
//                self->curEditModel.fieldSaveValue = model.dataId;
//                self->curEditModel.isCheck = YES;
//                self->curEditModel.selSubModel = model;
//                [self refreshViewData:NO isChange:YES changeModel:self->curEditModel];
//                // 选择完结束
//                self->_vc = nil;
//            };
//            vc.backBlock = ^(NSString * _Nonnull msg) {
//                // 点击关闭
//                self->_vc = nil;
//            };
//            ZCPageSheetView *sheetView = [[ZCPageSheetView alloc] initWithTitle:sobotConvertToString(dictName) superView:self showView:vc type:ZCPageSheetTypeLong];
//            [sheetView showSheet:vc.frame.size.height animation:YES block:^{
//                
//            }];
//            sheetView.dissmisBlock = ^(NSString * _Nonnull msg, int type) {
//                // 点击手势取消
//                self->_vc = nil;
//            };
//            
//            self.vc = vc;
//            return;
//        }
//    }
}

#pragma mark -- 输入框编辑事件
-(void)itemCreateCusCellOnClick:(ZCOrderCreateItemType)type dictValue:(NSString *)value dict:(NSDictionary *)dict indexPath:(NSIndexPath *)indexPath{
    // 单行或多行文本，是自定义字段，需要单独处理_coustomArr对象的内容
    if(type == ZCOrderCreateItemTypeOnlyEdit || type == ZCOrderCreateItemTypeMulEdit){
        int propertyType = [dict[@"propertyType"] intValue];
        if(propertyType == 1){
//            int index = [dict[@"code"] intValue];
            NSDictionary *showDict = _listArray[indexPath.row];
            SobotFormNodeRespVosModel *temModel = showDict[@"model"];
            temModel.fieldValue = value;
            temModel.fieldSaveValue = value;
            _listArray[indexPath.row] = @{@"code":[NSString stringWithFormat:@"%ld",(long)indexPath.row],
                                    @"dictName":sobotConvertToString(temModel.fieldName),
                                    @"dictDesc":sobotConvertToString(temModel.fieldName),
                                          @"placeholder":sobotConvertToString(temModel.tips),
                                    @"dictValue":sobotConvertToString(temModel.fieldValue),
                                          @"dictType":[NSString stringWithFormat:@"%d",temModel.fieldType],
                                    @"propertyType":@"1",
                                          @"model":temModel
                                    };
        }
    }else if(type == ZCOrderCreateItemTypeSelAsk){
        [self hideKeyboard];
        // 单选
        NSDictionary *itemDict = _listArray[indexPath.row];
        if([itemDict[@"propertyType"] intValue]==3){
            return;
        }
        NSString *dictName = itemDict[@"dictName"];
        // 0，特殊行   1 单行文本 2 多行文本 3 日期 4 时间 5 数值 6 下拉列表 7 复选框 8 单选框 9 级联字段
        int propertyType = [itemDict[@"propertyType"] intValue];
        if(propertyType == 1){
            NSDictionary *dict = _listArray[indexPath.row];
            curEditModel = (SobotFormNodeRespVosModel*)[dict objectForKey:@"model"];
            int fieldType = curEditModel.fieldType ;
            if(fieldType == 6 || fieldType == 7 || fieldType == 8){
                ZCAskCusFieldView *vc = [[ZCAskCusFieldView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0)];
                vc.cusModel = curEditModel;
                vc.orderCusFiledCheckBlock = ^(ZCOrderCusFieldsDetailModel *model, NSMutableArray *arr) {
                    self->curEditModel.fieldValue = model.dataName;
                    self->curEditModel.fieldSaveValue = model.dataId;
                    self->curEditModel.isCheck = YES;
                    self->curEditModel.selSubModel = model;
                    [self refreshViewData:NO isChange:YES changeModel:self->curEditModel];
                    // 选择完结束
                    self->_vc = nil;
                };
                vc.backBlock = ^(NSString * _Nonnull msg) {
                    // 点击关闭
                    self->_vc = nil;
                };
                ZCPageSheetView *sheetView = [[ZCPageSheetView alloc] initWithTitle:sobotConvertToString(dictName) superView:self showView:vc type:ZCPageSheetTypeLong];
                [sheetView showSheet:vc.frame.size.height animation:YES block:^{
                    
                }];
                sheetView.dissmisBlock = ^(NSString * _Nonnull msg, int type) {
                    // 点击手势取消
                    self->_vc = nil;
                };
                
                self.vc = vc;
                return;
            }
        }
    }
}




-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self hideKeyboard];
}

#pragma mark -- 头部UI
-(void)createTitleView{
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, self.topViewH)];
    [self.topView setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark1)];
    self.topView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_topView setAutoresizesSubviews:YES];
    [self addSubview:self.topView];
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16,0, _topView.frame.size.width- 32, self.topViewH)];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.titleLabel setFont:SobotFontBold16];
    [self.titleLabel setTextColor:[ZCUIKitTools zcgetscTopTextColor]];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.titleLabel setAutoresizesSubviews:YES];
    
//    self.backButton=[UIButton buttonWithType:UIButtonTypeCustom];
//    [self.backButton setFrame:CGRectMake(_topView.frame.size.width-64, 0, 64, ZCSheetTitleH)];
//    [self.backButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
//    [self.backButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
//    [self.backButton setContentEdgeInsets:UIEdgeInsetsZero];
//    [self.backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
//    [self.backButton setAutoresizesSubviews:YES];
//    [self.backButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
//    [self.backButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
//    [self.backButton setImage:[SobotUITools getSysImageByName:@"zcicon_sf_close"] forState:UIControlStateNormal];
//    [self.backButton setImage:[SobotUITools getSysImageByName:@"zcicon_sf_close"] forState:UIControlStateHighlighted];
//    [self.topView addSubview:self.backButton];
//    self.backButton.tag = BUTTON_BACK;
//    [self.backButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self.topView addSubview:self.backButton];
    [self.topView addSubview:self.titleLabel];
    UIView *bottomLine = [[UIView alloc]init];
    bottomLine.backgroundColor = [ZCUIKitTools zcgetCommentButtonLineColor];
    [bottomLine setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.topView addSubview:bottomLine];
    [self.topView addConstraint:sobotLayoutPaddingBottom(0, bottomLine, self.topView)];
    [self.topView addConstraint:sobotLayoutPaddingLeft(0, bottomLine, self.topView)];
    [self.topView addConstraint:sobotLayoutPaddingLeft(0, bottomLine, self.topView)];
    [self.topView addConstraint:sobotLayoutEqualHeight(0.5, bottomLine, NSLayoutRelationEqual)];
}


/**
 *  设置部分圆角(绝对布局)
 *
 *  @param corners 需要设置为圆角的角 UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerAllCorners
 *  @param radii   需要设置的圆角大小 例如 CGSizeMake(20.0f, 20.0f)
 */
- (void)addRoundedCorners:(UIRectCorner)corners
                withRadii:(CGSize)radii withView:(UIView *) view {
    view.layer.masksToBounds = YES;
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:corners cornerRadii:radii];
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    
    view.layer.mask = shape;
}
/**
 *  设置部分圆角(相对布局)
 *
 *  @param corners 需要设置为圆角的角 UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerAllCorners
 *  @param radii   需要设置的圆角大小 例如 CGSizeMake(20.0f, 20.0f)
 *  @param rect    需要设置的圆角view的rect
 */
- (void)addRoundedCorners:(UIRectCorner)corners
                withRadii:(CGSize)radii
                 viewRect:(CGRect)rect withView:(UIView *) view {
    
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:radii];
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    
    view.layer.mask = shape;
}


#pragma mark - 刷新数据
-(void)refreshViewData:(BOOL)isFisrt isChange:(BOOL)isChange changeModel:(SobotFormNodeRespVosModel *)changModel{
    if (isFisrt) {
        _coustomArr = [NSMutableArray arrayWithArray:self.firstShowArr];
    }else{
        // 选择完之后刷新数据源 单选之后 重新切换数据列
        if (isChange && !sobotIsNull(changModel)) {
            // 1.先找到当前节点的位置
            // 2.添加从1到当前节点的数据
            // 3.移除当前节点之后的数据
            // 4.查询当前节点后的子节点，并添加到数据列表中展示
            NSMutableArray *tempArr = [NSMutableArray array];
            for (int i = 0; i<self.listArray.count; i++) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.listArray[i]];
                SobotFormNodeRespVosModel *cusModel = (SobotFormNodeRespVosModel *)dict[@"model"];
                if ([cusModel.fieldId isEqualToString:changModel.fieldId]) {
                    [dict setObject:sobotConvertToString(changModel.fieldValue) forKey:@"dictValue"];
                    [tempArr addObject:dict];
                    NSMutableArray *nextArr = [NSMutableArray array];
                    NSString *preNodeId = changModel.selSubModel.fieldId;
                    nextArr = [self getShowDataArr:preNodeId showTempArr:nextArr];
                    if (!sobotIsNull(nextArr) && nextArr.count >0) {
                        int index = (int)nextArr.count -1 ;
                        for (int i= 0; i<nextArr.count; i++) {
                            SobotFormNodeRespVosModel *subModel = nextArr[i];
                            NSString * titleStr = sobotConvertToString(subModel.fieldName);
                            NSMutableDictionary *showDict = [NSMutableDictionary dictionary];
                            [showDict setObject:[NSString stringWithFormat:@"%d",index] forKey:@"code"];
                            [showDict setObject:sobotConvertToString(subModel.fieldName) forKey:@"dictName"];
                            [showDict setObject:sobotConvertToString(titleStr) forKey:@"dictDesc"];
                            [showDict setObject:sobotConvertToString(subModel.tips) forKey:@"placeholder"];
                            [showDict setObject:sobotConvertToString(subModel.fieldValue) forKey:@"dictValue"];
                            [showDict setObject:[NSString stringWithFormat:@"%d",subModel.fieldType] forKey:@"dictType"];
                            [showDict setObject:@"1" forKey:@"propertyType"];
                            [showDict setObject:subModel forKey:@"model"];
                            index ++;
                            [tempArr addObject:showDict];
                        }
                    }
                    [_listArray removeAllObjects];
                    [_listArray addObjectsFromArray:tempArr];
                    [self updataPage];
                    return;
                }else{
                    [tempArr addObject:dict];
                }
            }
        }
    }
    [self upRefreshViewData];
}

-(void)upRefreshViewData{
    // 头和尾部单独处理
    [_listArray removeAllObjects];
    _listArray = [NSMutableArray array];
    //    NSDictionary *dict = [ZCJSONDataTools getObjectData:_model];
    // 0，特殊行   1 单行文本 2 多行文本 3 日期 4 时间 5 数值 6 下拉列表 7 复选框 8 单选框 9 级联字段
    // propertyType == 1是自定义字段，0固定字段, 3不可点击
    NSMutableArray *arr2 = [[NSMutableArray alloc] init];
    if (_coustomArr.count >0) {
        int index = 0;
        for (SobotFormNodeRespVosModel *cusModel in _coustomArr) {
            NSString *propertyType = @"1";
//            if (cusModel.status == 0) {
//                propertyType = @"3";
//                cusModel.fieldType = @"3";
//            }
            NSString * titleStr = sobotConvertToString(cusModel.fieldName);
//            if([sobotConvertToString(cusModel.fillFlag) intValue] == 1){
//                titleStr = [NSString stringWithFormat:@"%@*",titleStr];
//            }
            [arr2 addObject:@{@"code":[NSString stringWithFormat:@"%d",index],
                              @"dictName":sobotConvertToString(cusModel.fieldName),
                              @"dictDesc":sobotConvertToString(titleStr),
                              @"placeholder":sobotConvertToString(cusModel.tips),
                              @"dictValue":sobotConvertToString(cusModel.fieldValue),
                              @"dictType":[NSString stringWithFormat:@"%d",cusModel.fieldType],
                              @"propertyType":propertyType,
                              @"model":cusModel
                              }];
            index = index + 1;
        }
        [_listArray addObjectsFromArray:arr2];
    }
    
    [_listTable reloadData];
}

#pragma mark -- 键盘滑动的高度
-(void)didKeyboardWillShow:(NSIndexPath *)indexPath view1:(UITextView *)textview view2:(UITextField *)textField{
    _tempTextView = textview;
    _tempTextField = textField;
    _indexPath = indexPath;
    //获取当前cell在tableview中的位置
//    CGRect rectintableview = [_listTable rectForRowAtIndexPath:indexPath];
//    //获取当前cell在屏幕中的位置
//    CGRect rectinsuperview = [_listTable convertRect:rectintableview fromView:[_listTable superview]];
//    contentoffset = _listTable.contentOffset;
//    if ((rectinsuperview.origin.y+50 - _listTable.contentOffset.y)>200) {
//        if(!isLandspace){
//            [_listTable setContentOffset:CGPointMake(_listTable.contentOffset.x,((rectintableview.origin.y-_listTable.contentOffset.y)-150)+  _listTable.contentOffset.y) animated:YES];
//            contentoffset = CGPointMake(_listTable.contentOffset.x,((rectintableview.origin.y-_listTable.contentOffset.y)-150)+  _listTable.contentOffset.y);
//        }
//    }
}

#pragma mark - 手势冲突的代理
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIButton class]]){
        return NO;
    }
    return YES;
}

#pragma mark - 回收键盘
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
//    if (_listTable.contentSize.height <( ScreenHeight - NavBarHeight)) {
//        [_listTable setContentOffset:CGPointMake(0, 0)];
//    }
    if(contentoffset.x != 0 || contentoffset.y != 0){
//        // 隐藏键盘，还原偏移量
//        [_listTable setContentOffset:contentoffset];
        contentoffset.y = 0;
    }
    [self layoutSubviews];
}

- (void)hideKeyboard {
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
//        // 隐藏键盘，还原偏移量
//        [_listTable setContentOffset:contentoffset];
        contentoffset.y = 0;
    }
    [self layoutSubviews];
}

- (void)allHideKeyBoard
{
    [self endEditing:true];
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

#pragma mark -- 键盘显示
-(void)keyBoardWillShow:(NSNotification *) notification{
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat keyboardHeight = [[[notification userInfo] objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue].size.height;
    self.keyboardH = keyboardHeight;
    SLog(@"键盘的高度 %f",self.keyboardH);
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationDelegate:self];
    {
        //获取当前cell在tableview中的位置
//        CGRect rectintableview = [self->_listTable rectForRowAtIndexPath:self.indexPath];
//        //获取当前cell在屏幕中的位置
//        CGRect rectinsuperview = [self->_listTable convertRect:rectintableview fromView:[SobotUITools getCurWindow].rootViewController.view];
        
        
        // 假设 cell 是你当前的 UITableViewCell 或 UICollectionViewCell
        CGRect cellRect = [_listTable rectForRowAtIndexPath:self.indexPath]; // 获取 cell 在 tableView 中的 rect
        CGRect cellRectInSuperview = [_listTable convertRect:cellRect toView:[UIApplication sharedApplication].keyWindow]; // 转换到窗口的坐标系统
        NSLog(@"Cell 在屏幕中的位置: %@", NSStringFromCGRect(cellRectInSuperview));
        self->contentoffset = self->_listTable.contentOffset;
        // 获取键盘的高度  两者直接的差值
        if (cellRectInSuperview.origin.y + 72 > (ScreenHeight - self->_keyboardH)) {
            if(!isLandspace){
                // 这里的72 是行高  y+H
//                [self->_listTable setContentOffset:CGPointMake(self->_listTable.contentOffset.x,cellRectInSuperview.origin.y - (ScreenHeight - self->_keyboardH)+72) animated:YES];
//                self->contentoffset = CGPointMake(self->_listTable.contentOffset.x,cellRectInSuperview.origin.y - (ScreenHeight - self->_keyboardH)+72);
                if (sobotIsNull(self->_vc)) {
                    // 这里通过偏移量 有问题，当只有一个元素 应该设置整体的高度
                    self.superview.frame = CGRectMake(0, ScreenHeight - CGRectGetMaxY(self.frame), self.frame.size.width, CGRectGetMaxY(self.frame));
                    CGRect sf = self.superview.frame;
                    sf.origin.y = sf.origin.y -(cellRectInSuperview.origin.y - (ScreenHeight - self->_keyboardH)+72)-XBottomBarHeight;
                    self->contentoffset.y = (cellRectInSuperview.origin.y - (ScreenHeight - self->_keyboardH)+72);
                    self.superview.frame = sf;
    
                    [self addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadii:CGSizeMake(8, 8) withView:self.topView];
                    [self addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadii:CGSizeMake(8, 8) withView:self];
                }
            }
        }
    }
    
    // commit animations
    [UIView commitAnimations];
}

//键盘隐藏
- (void)keyBoardWillHide:(NSNotification *)notification {
//    isKeyBoardShow = NO;
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView beginAnimations:@"bottomBarDown" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView commitAnimations];
    [UIView animateWithDuration:0.25 animations:^{
        self->_keyboardH = 0;
        if (sobotIsNull(self->_vc)) {
            CGRect sf = self.superview.frame;
            sf.origin.y = sf.origin.y + self->contentoffset.y ;
//            sf.size.height = sf.size.height - self->contentoffset.y;
            self.superview.frame = sf;
            [self addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadii:CGSizeMake(8, 8) withView:self.topView];
            [self addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadii:CGSizeMake(8, 8) withView:self];
        }
    }];
}

#pragma mark -- 提交事件
-(void)commitAction:(UIButton*)sender{
    
    // 检验各字段格式 是否必填
    NSMutableArray *cusFields = [NSMutableArray arrayWithCapacity:0];
    // 自定义字段
    for (NSDictionary *dict in _listArray) {
        SobotFormNodeRespVosModel *cusModel = [dict objectForKey:@"model"];
        if(sobotConvertToString([dict objectForKey:@"dictValue"]).length == 0 || sobotIsEmpty(sobotConvertToString([dict objectForKey:@"dictValue"]))){
            [[SobotToast shareToast] showToast:[NSString stringWithFormat:@"%@%@",cusModel.fieldName,SobotKitLocalString(@"不能为空")] duration:1.0f view:self position:SobotToastPositionCenter];
            return;
        }
        
        if(![self checkContentValid:cusModel.fieldSaveValue model:cusModel]){
//            [[SobotToast shareToast] showToast:[NSString stringWithFormat:@"%@%@",cusModel.fieldName,SobotKitLocalString(@"格式不正确")] duration:1.0f view:self position:SobotToastPositionCenter];
            [[SobotToast shareToast] showToast:[NSString stringWithFormat:@"%@%@",cusModel.fieldName,sobotConvertToString(cusModel.errorTips)] duration:1.0f view:self position:SobotToastPositionCenter];
            return;
        }
        if(!sobotIsNull(cusModel.fieldSaveValue) || sobotConvertToString(cusModel.fieldValue).length > 0){
//            /**
//                 * 字段id
//                 */
//                private String fieldId;
//                /**
//                 * 字段名称
//                 */
//                private String fieldName;
//                /**
//                 * 单选框 - 对应dataValue字段id
//                 * 单行文本 - 对应访客输入的内容
//                 */
//                private String fieldValue;
//                /**
//                 * 单选框 - 对应访客选择的字段值 dataName
//                 * 单行文本 - 没有用到
//                 */
//                private String fieldValueName;
//                /**
//                 * 字段类型
//                 */
//                private FieldTypeEnum fieldTypeEnum;
//
//                /**
//                 * 字段来源
//                 * @see com.sobot.chat.model.form.FieldSourceEnum
//                 */
//                private Integer fieldFrom;
//                /**
//                 * 字段类型 0-单行文本，8-单选框
//                 * @see com.sobot.chat.model.form.FieldTypeEnum
//                 */
//                private Integer fieldType;
            
            NSString *fieldValue = sobotConvertToString(cusModel.fieldValue);
            NSString *fieldValueName = @"";
            if (cusModel.fieldType == 8) {
                fieldValue = sobotConvertToString(cusModel.selSubModel.dataId);
                fieldValueName = sobotConvertToString(cusModel.selSubModel.dataName);
            }
            [cusFields addObject:@{@"fieldId":sobotConvertToString(cusModel.fieldId),
                                   @"fieldName":sobotConvertToString(cusModel.fieldName),
                                   @"fieldValue":sobotConvertToString(fieldValue),
                                   @"fieldValueName":sobotConvertToString(fieldValueName),
                                   @"fieldFrom":[NSString stringWithFormat:@"%d",cusModel.fieldFrom],
                                   @"fieldType":[NSString stringWithFormat:@"%d",cusModel.fieldType],
                                   }];
        }
    }
    [self UpLoadWith:cusFields];
}

// 提交接口
- (void)UpLoadWith:(NSMutableArray*)arr{
    if(_isSend){
        return;
    }

    // 添加自定义字段
//    if (arr.count > 0) {
//        formData = sobotConvertToString([SobotCache dataTOjsonString:arr]);
//    }
    _isSend = YES;
    __weak ZCUIAskTableView *safeSelf = self;
    [ZCLibServer postNewAskTabelWithUid:[[ZCUICore getUICore] getLibConfig].uid cid:[[ZCUICore getUICore] getLibConfig].cid schemeId:[[ZCUICore getUICore] getLibConfig].inquiryPlanId formData:arr canvasId:self.canvasId start:^{
        
    } success:^(NSDictionary * _Nonnull dict, ZCNetWorkCode sendCode) {
        safeSelf.isSend = NO;
        if (sendCode == ZC_NETWORK_SUCCESS) {
            // 退出当前页面
            // 标记已经提交过询前表单
            // 继续执行转人工的操作
            safeSelf.isCommitSuccess = YES;
            [[SobotToast shareToast] showToast:SobotKitLocalString(@"提交成功") duration:1.0f view:[SobotUITools getCurWindow] position:SobotToastPositionCenter Image:[SobotUITools getSysImageByName:@"zcicon_successful"]];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self->_trunServerBlock) {
                    self->_trunServerBlock(NO);
                }
                self->_isSend = NO;
                self->isClose = YES;
                [(ZCPageSheetView *)self.superview.superview  dissmisPageSheet];
            });
        }
    } failed:^(NSString * _Nonnull errorMessage, ZCNetWorkCode errorCode) {
        if (sobotConvertToString(errorMessage).length >0) {
            [[SobotToast shareToast] showToast:sobotConvertToString(errorMessage) duration:1.0f view:safeSelf position:SobotToastPositionCenter];
        }
        safeSelf.isSend = NO;
    }];
}


-(BOOL)checkContentValid:(NSString *) text model:(SobotFormNodeRespVosModel *) model{
    if(model != nil && sobotConvertToString(text).length >0){
        NSArray *limitOptions = nil;
        if([model.limitOptions isKindOfClass:[NSString class]]){
            NSString *limitOption =  sobotConvertToString(model.limitOptions);
            limitOption = [limitOption stringByReplacingOccurrencesOfString:@"[" withString:@""];
            limitOption = [limitOption stringByReplacingOccurrencesOfString:@"]" withString:@""];
            limitOptions = [limitOption componentsSeparatedByString:@","];
            NSMutableArray *tempArr = [NSMutableArray array];
            for (NSString *text in limitOptions) {
                [text stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                if (sobotConvertToString(text).length >0) {
                    [tempArr addObject:(NSString*)text];
                }
            }
            limitOptions = [NSArray arrayWithArray:tempArr];
            
        }else if([model.limitOptions isKindOfClass:[NSArray class]]){
            limitOptions = (NSArray*)model.limitOptions;
        }
        
        if(limitOptions==nil || limitOptions.count == 0){
            
            if (model.fieldFrom == 12) {
                if ([sobotConvertToString(model.fieldVariable) isEqualToString:@"uname"]) {
                    NSString *match = @"^.+$";
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
                    return [predicate evaluateWithObject:text];
                }
                if ([sobotConvertToString(model.fieldVariable) isEqualToString:@"source"]) {
                    NSString *match = @"^.+$";
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
                    return [predicate evaluateWithObject:text];
                }
                if ([sobotConvertToString(model.fieldVariable) isEqualToString:@"tel"]) {
                    NSString *match =  @"^[A-Za-z0-9+]{3,16}$";
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
                    return [predicate evaluateWithObject:text];
                }
                if ([sobotConvertToString(model.fieldVariable) isEqualToString:@"email"]) {
                    NSString *match = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
                    return [predicate evaluateWithObject:text];
                }
                if ([sobotConvertToString(model.fieldVariable) isEqualToString:@"qq"]) {
                    NSString *match = @"^[1-9][0-9]{4,14}$";
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
                    return [predicate evaluateWithObject:text];
                }
                if ([sobotConvertToString(model.fieldVariable) isEqualToString:@"wx"]) {
                    NSString *match = @"^[a-zA-Z][a-zA-Z0-9_-]{5,19}$";
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
                    return [predicate evaluateWithObject:text];
                }
            }else if (model.fieldFrom == 22){
                if ([sobotConvertToString(model.fieldVariable) isEqualToString:@"enterpriseName"]) {
                    NSString *match = @"^.+$";
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
                    return [predicate evaluateWithObject:text];
                }
                if ([sobotConvertToString(model.fieldVariable) isEqualToString:@"enterpriseDomain"]) {
                    NSString *match = @"^.+$";
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
                    return [predicate evaluateWithObject:text];
                }
            }
            
            if(model.fieldType == 5){
                return sobotValidateFloat(text);
            }
            return YES;
        }
        
        // 特殊情况 同时包含 2中  例如【4 、6】
        // 先判断6
        if([limitOptions containsObject:[NSNumber numberWithInt:6]] || [limitOptions containsObject:@"6"]|| [limitOptions containsObject:@"\"6\""]){
            if(sobotConvertToString(text).length > [model.limitChar intValue]){
                return NO;
            }
        }
        
        //限制方式  1禁止输入空格   2 禁止输入小数点  3 小数点后只允许2位  4 禁止输入特殊字符  5只允许输入数字 6最多允许输入字符  7判断邮箱格式  8判断手机格式  9 请输入 3～16 位数字、英文符号, +
        if([limitOptions containsObject:[NSNumber numberWithInt:1]] || [limitOptions containsObject:@"1"]||[limitOptions containsObject:@"\"1\""]){
            NSRange _range = [text rangeOfString:@" "];
            if(_range.location!=NSNotFound) {
                return NO;
            }
        }
        if([limitOptions containsObject:[NSNumber numberWithInt:2]] || [limitOptions containsObject:@"2"]||[limitOptions containsObject:@"\"2\""]){
             NSRange _range = [text rangeOfString:@"."];
            if(_range.location!=NSNotFound) {
                return NO;
            }
        }
        if([limitOptions containsObject:[NSNumber numberWithInt:3]] || [limitOptions containsObject:@"3"]||[limitOptions containsObject:@"\"3\""]){
             return sobotValidateFloatWithNum(text,2);
        }
        if([limitOptions containsObject:[NSNumber numberWithInt:4]] || [limitOptions containsObject:@"4"]||[limitOptions containsObject:@"\"4\""]){
//            return sobotValidateRuleNotBlank(text);
            return sobotValidateMobileWithRegex(text, @"^[a-zA-Z0-9\u4E00-\u9FA5]+$");
        }
        
        if([limitOptions containsObject:[NSNumber numberWithInt:5]] || [limitOptions containsObject:@"5"]||[limitOptions containsObject:@"\"5\""]){
             return sobotValidateNumber(text);
        }
        
//        if([limitOptions containsObject:[NSNumber numberWithInt:6]] || [limitOptions containsObject:@"6"] ||[limitOptions containsObject:@"\"6\""]){
//            if(sobotConvertToString(text).length > [model.limitChar intValue]){
//                return NO;
//            }
//        }
        
        if([limitOptions containsObject:[NSNumber numberWithInt:7]] || [limitOptions containsObject:@"7"] ||[limitOptions containsObject:@"\"7\""]){
            return sobotValidateEmail(text);
        }
        
        if([limitOptions containsObject:[NSNumber numberWithInt:8]] || [limitOptions containsObject:@"8"] ||[limitOptions containsObject:@"\"8\""]){
            return sobotValidateMobileWithRegex(text, [ZCUIKitTools zcgetTelRegular]);
        }
        
        if([limitOptions containsObject:[NSNumber numberWithInt:9]] || [limitOptions containsObject:@"9"] ||[limitOptions containsObject:@"\"9\""]){
            return sobotValidateMobileWithRegex(text, @"^[A-Za-z0-9+]{3,16}$");
        }
        
    }
    return YES;
}



-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    // 键盘显示了才做处理
    if (self.keyboardH >0) {
        [self hideKeyboard];
    }
}
@end
