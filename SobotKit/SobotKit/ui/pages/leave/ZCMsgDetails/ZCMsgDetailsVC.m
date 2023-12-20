//
//  ZCMsgDetailsVC.m
//  SobotKit
//
//  Created by lizh on 2022/9/7.
//

#import "ZCMsgDetailsVC.h"
#import "ZCUIKitTools.h"
#import <SobotCommon/SobotCommon.h>
#import "SobotHtmlFilter.h"
#import "ZCReplyFileView.h"
#import "SobotRatingView.h"
#import "ZCVideoPlayer.h"
#import "ZCDocumentLookController.h"
#import "ZCLeaveDetailCell.h"
#define cellIdentifier @"ZCLeaveDetailCell"
#import "ZCUIWebController.h"
#import "ZCReplyLeaveView.h"
#import <AVFoundation/AVFoundation.h>
#import "SobotSatisfactionView.h"
#import <SobotChatClient/SobotChatClient.h>
@interface ZCMsgDetailsVC ()<SobotEmojiLabelDelegate,UITableViewDelegate,UITableViewDataSource,ZCReplyLeaveViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    BOOL isShowHeard;
    CGSize contSize;
}

@property(nonatomic,strong)UITableView *listView;
@property(nonatomic,strong)NSMutableArray *listArray;
@property (nonatomic, strong) UIView *buttonBgView;
@property (nonatomic, strong) UIButton *replyButton;
@property (nonatomic, strong) UIButton *evaluateButton;
//  2.8.2 已创建  model ，单独处理 ，
@property (nonatomic, strong) ZCRecordListModel *creatRecordListModel;
@property (nonatomic,strong) UIView *commitFootView;
@property (nonatomic,strong) UIView *headerView;
@property (nonatomic,strong) UIView *headerMoreFileView; // 区头文件View
@property (nonatomic,strong) SobotEmojiLabel *conlab;
@property (nonatomic,strong) SobotButtonUpDown *showBtn;
@property (nonatomic,strong) ZCReplyLeaveView *replyLeaveView;
@property (nonatomic, strong) UIImagePickerController *zc_imagepicker;
@property (nonatomic, strong) NSMutableArray *imageArr;
@property (nonatomic, strong) NSMutableArray * imagePathArr;
@property (nonatomic, strong) NSString *replyStr;

// 线条
@property (nonatomic,strong) UIView *headerlineView1;
// 线条
@property (nonatomic,strong) UILabel *headerTitleLab;
@property (nonatomic,strong) UILabel *headerStateLab;

@property (nonatomic,strong)NSLayoutConstraint *listR;
@property (nonatomic,strong)NSLayoutConstraint *listB;
@property (nonatomic,strong)NSLayoutConstraint *listY;
@property (nonatomic,strong)NSLayoutConstraint *listL;
@property (nonatomic, strong)NSDictionary *evaluateModelDic;
@property (nonatomic,strong) UIView *footView;

@property (nonatomic,strong) SobotSatisfactionView *sheet;

@end

@implementation ZCMsgDetailsVC


- (void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
//        self.navigationController.navigationBarHidden = YES;
//    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [ZCUIKitTools zcgetLightGrayDarkBackgroundColor];
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }
    [self createVCTitleView];
    [self updateNavOrTopView];
    
    if(!self.navigationController.navigationBarHidden){
        self.title = SobotKitLocalString(@"留言详情");
    }else{
        self.titleLabel.text = SobotKitLocalString(@"留言详情");
    }
   
    isShowHeard = NO;
    _listArray = [NSMutableArray arrayWithCapacity:0];
    [self.view setBackgroundColor:[ZCUIKitTools zcgetLightGrayDarkBackgroundColor]];
    [self createTableView];
    [self createBottomBtn];
    [self loadData];
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
    [_listView registerClass:[ZCLeaveDetailCell class] forCellReuseIdentifier:cellIdentifier];
    // 分割线的隐藏
    _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //可以省略不设置
    _listView.rowHeight = UITableViewAutomaticDimension;
    self.listB = sobotLayoutPaddingBottom(-XBottomBarHeight -60, self.listView, self.view);
    self.listL = sobotLayoutPaddingLeft(0, self.listView, self.view);
    self.listR = sobotLayoutPaddingRight(0, self.listView, self.view);
    self.listY = sobotLayoutPaddingTop(TY, self.listView, self.view);

    [self.view addConstraint:self.listY];
    [self.view addConstraint:self.listB];
    [self.view addConstraint:self.listL];
    [self.view addConstraint:self.listR];
    _listView.backgroundColor = [UIColor clearColor];
    _listArray = [[NSMutableArray alloc]init];
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
            self.listY = sobotLayoutPaddingTop(y, _listView, self.view);
        }else{
            self.listY = sobotLayoutPaddingTop(e.top, _listView, self.view);
        }
        self.listL = sobotLayoutPaddingLeft(e.left, _listView, self.view);
        self.listR = sobotLayoutPaddingRight(-e.right, _listView, self.view);
        self.listB = sobotLayoutPaddingBottom(-e.bottom -60, _listView, self.view);
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
        self.listB = sobotLayoutPaddingBottom(-e.bottom -60, _listView, self.view);
    }
    [self.view addConstraint:self.listL];
    [self.view addConstraint:self.listR];
    [self.view addConstraint:self.listB];
    [self.view addConstraint:self.listY];
    if (!sobotIsNull(self.listArray) && self.listArray.count > 0) {
        // 这里解决横竖屏切换的
        [self.listView reloadData];
    }
    if (!sobotIsNull(self.replyLeaveView)) {
        [self.replyLeaveView tappedCancel:YES];
        // 重新创建
        self.replyLeaveView = [[ZCReplyLeaveView alloc]initActionSheetWithView:self.view];
        self.replyLeaveView.delegate = self;
        self.replyLeaveView.ticketId = _ticketId;
        [self.replyLeaveView showInView:self.view];
        self.replyLeaveView.imageArr = self.imageArr;
        self.replyLeaveView.imagePathArr = self.imagePathArr;
        self.replyLeaveView.textDesc.text = self.replyStr;
        [self.replyLeaveView reloadScrollView];
    }
    // 横竖屏更新导航栏渐变色
    [self updateTopViewBgColor];
}

#pragma mark UITableView delegate Start
// 返回section数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

// 返回section高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        if(_listArray.count > 0){
            if(_headerView){
                [self changeHeaderStyle];
                return CGRectGetHeight(_headerView.frame);
            }else{
                [self getHeaderViewHeight];
                return CGRectGetHeight(_headerView.frame);
            }
        }
        return 0;
    }
    // 底部间隔？
    return 114;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(section == 0){
        
         ZCRecordListModel *first = self.listArray.firstObject;
                if((first.isOpen && first.isEvalution == 1) || self.evaluateModelDic)
                {
                    if(_footView){
                        return CGRectGetHeight(_footView.frame);
                    }else{
                        [self getHeaderStarViewHeight];
                        return CGRectGetHeight(_footView.frame);
                    }
                    
                    
                }
        
        return 20;
     }
     return 0;
}
// 返回section 的View
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section == 0){
        NSString * str = @"";
        if (self.listArray.count > 0) {
            ZCRecordListModel * model = [_listArray lastObject];
            str = sobotConvertToString(model.content);
        }
        if(_headerView){
            [self changeHeaderStyle];
            return _headerView;
        }
        return [self getHeaderViewHeight];
    }else{
        UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
        view.backgroundColor = [UIColor clearColor];
        return view;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        ZCRecordListModel *first = self.listArray.firstObject;
        if((first.isOpen && first.isEvalution == 1) || self.evaluateModelDic)
        {
            return [self getHeaderStarViewHeight];
        }else{
            UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
            bgView.backgroundColor =[ZCUIKitTools zcgetLightGrayDarkBackgroundColor];
            return bgView;
        }
    }else {
        return nil;
    }
}

// 返回section下得行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return _listArray.count;
    }
    return 0;
}

// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZCLeaveDetailCell *cell = (ZCLeaveDetailCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[ZCLeaveDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    if ( indexPath.row > _listArray.count -1) {
        return cell;
    }

    [cell setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark1)];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    ZCRecordListModel * model = _listArray[indexPath.row];
    __weak ZCMsgDetailsVC * saveSelf = self;
    [cell initWithData:model IndexPath:indexPath.row count:(int)self.listArray.count];
    [cell setShowDetailClickCallback:^(ZCRecordListModel * _Nonnull model,NSString *urlStr) {
        if (urlStr) {
            ZCUIWebController *webVC = [[ZCUIWebController alloc] initWithURL:urlStr];
            [saveSelf.navigationController pushViewController:webVC animated:YES];
            return;
        }
        NSString *htmlString = model.replyContent;
        if (model.flag == 3) {
            htmlString = model.content;
        }
        ZCUIWebController *webVC = [[ZCUIWebController alloc] initWithURL:htmlString];
        [saveSelf.navigationController pushViewController:webVC animated:YES];
    }];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.selected = NO;
    return cell;
}

#pragma mark - 区头创建和获取高度
-(UIView*)getHeaderViewHeight{
    if (_headerView != nil) {
        [_headerView removeFromSuperview];
        _headerView = nil;
    }
    CGFloat tableWidth = self.listView.frame.size.width;
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableWidth, SobotNumber(140))];
    _headerView.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
    _headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _headerView.autoresizesSubviews = YES;
    
    _headerTitleLab = [[UILabel alloc] initWithFrame:CGRectMake(20,27, tableWidth - 20 -50 - 10, SobotNumber(22))];
    [_headerTitleLab setFont:SobotFontBold16];
    [_headerTitleLab setTextAlignment:NSTextAlignmentLeft];
    [_headerTitleLab setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
    _headerTitleLab.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _headerTitleLab.autoresizesSubviews =  YES;
    [_headerView addSubview:_headerTitleLab];
    
    _headerStateLab = [[UILabel alloc] initWithFrame:CGRectMake(tableWidth - 70, 30,50, 20)];
    [_headerStateLab setBackgroundColor:UIColorFromKitModeColor(SobotColorTheme)];
    [_headerStateLab setFont:SobotFont12];
    _headerStateLab.layer.cornerRadius = 10.0f;
    [_headerStateLab setTextColor:UIColorFromKitModeColor(SobotColorTextWhite)];
    [_headerStateLab setTextAlignment:NSTextAlignmentCenter];
    _headerStateLab.layer.masksToBounds = YES;
    _headerStateLab.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    _headerStateLab.autoresizesSubviews = YES;
    [_headerView addSubview:_headerStateLab];

    ZCRecordListModel * model = nil;
    if(_listArray.count > 0){
        model = [_listArray lastObject];
        _headerTitleLab.text = sobotConvertToString(sobotDateTransformString(@"YYYY-MM-dd HH:mm:ss", sobotStringFormateDate(model.timeStr)));
        ZCRecordListModel *firstFlag = [_listArray firstObject];
        switch (firstFlag.flag) {
            case 1:
                _headerStateLab.text =  SobotKitLocalString(@"已创建");
                _headerStateLab.backgroundColor = UIColorFromKitModeColor(SobotColorTextSub1);
                break;
            case 2:
                _headerStateLab.text =  SobotKitLocalString(@"受理中");
                _headerStateLab.backgroundColor = UIColorFromKitModeColor(SobotColorYellow);
                break;
            case 3:
                _headerStateLab.text =  SobotKitLocalString(@"已完成");
                _headerStateLab.backgroundColor = UIColorFromKitModeColor(SobotColorTheme);
                break;
            default:
                break;
        }
    }
    
    _conlab = [[SobotEmojiLabel alloc]initWithFrame:CGRectMake(SobotNumber(20), CGRectGetMaxY(_headerTitleLab.frame) + SobotNumber(8), tableWidth - SobotNumber(40), SobotNumber(50))];
    _conlab.numberOfLines = 0;
    [_conlab setTextColor:UIColorFromKitModeColor(SobotColorTextSub)];
    [_conlab setLinkColor:[ZCUIKitTools zcgetChatLeftLinkColor]];
    _conlab.font = SobotFont14;
    _conlab.lineSpacing = 4.0f;
    _conlab.delegate = self;
    if(model){
        // 优化卡顿问题，此处希望使用setText，暂未优化
        [_conlab setText:model.content];
        [_conlab setLinkColor:[ZCUIKitTools zcgetChatLeftLinkColor]];
        CGRect labelF = _conlab.frame;
        CGSize size = [self autoHeightOfLabel:_conlab with:CGRectGetWidth(_conlab.frame) IsSetFrame:YES];
        labelF.size.height = size.height;
        _conlab.frame = labelF;
        [_headerView addSubview:_conlab];
        contSize = [self autoHeightOfLabel:_conlab with:tableWidth - SobotNumber(30) IsSetFrame:NO];
    }

    float h = _conlab.frame.origin.y + contSize.height + 10;
    
//    2.8.2 增加客户回复：
    float pics_height = [self addContentFileList:h];
    _showBtn = [SobotButtonUpDown buttonWithType:UIButtonTypeCustom];
    _showBtn.frame = CGRectMake(self.view.frame.size.width/2- SobotNumber(120/2), pics_height + contSize.height + SobotNumber(8), 120, SobotNumber(0));
    [_showBtn addTarget:self action:@selector(showMoreAction:) forControlEvents:UIControlEventTouchUpInside];
    _showBtn.tag = 1001;
//    _showBtn.type = 2;
//    _showBtn.space = SobotNumber(0);
    [_showBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    _showBtn.titleLabel.font = SobotFont12;
    [_showBtn setTitle:[NSString stringWithFormat:@"%@    ",SobotKitLocalString(@"展开")] forState:UIControlStateNormal];
//    [_showBtn setImage:[SobotUITools getSysImageByName:@"zciocn_arrow_down"] forState:UIControlStateNormal];

    [_headerView addSubview: _showBtn];
    _showBtn.hidden = YES;
    [_showBtn setTitleColor:UIColorFromKitModeColor(SobotColorTheme) forState:UIControlStateNormal];
    if (contSize.height > 35 || self.creatRecordListModel.fileList.count > 0) {
        // 添加 展开全文btn
        _showBtn.hidden = NO;
    }
    // 线条
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0,0, tableWidth, 10)];
    lineView.backgroundColor = [ZCUIKitTools zcgetLightGrayDarkBackgroundColor];
    [_headerView addSubview:lineView];
    
    CGFloat y = CGRectGetMaxY(_showBtn.frame)+17;
    if(_showBtn.isHidden){
        y = CGRectGetMaxY(_conlab.frame)+17;
    }
    // 线条
    _headerlineView1 = [[UIView alloc]initWithFrame:CGRectMake(0,y, tableWidth, 10)];
    _headerlineView1.backgroundColor = [ZCUIKitTools zcgetLightGrayDarkBackgroundColor];
    UIView *lineView_1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableWidth, 0.5)];
    lineView_1.backgroundColor = [ZCUIKitTools zcgetChatBottomLineColor];
    lineView_1.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    lineView_1.autoresizesSubviews = YES;
    [_headerlineView1 addSubview:lineView_1];
    [_headerView addSubview:_headerlineView1];
    
    UIView *lineView_0 = [[UIView alloc]initWithFrame:CGRectMake(0, 10, tableWidth, 0.5)];
    lineView_0.backgroundColor =  [ZCUIKitTools zcgetChatBottomLineColor];
    [_headerView addSubview:lineView_0];
    lineView_0.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    lineView_0.autoresizesSubviews = YES;
    [self changeHeaderStyle];
    return _headerView;
}

#pragma mark - 区头展开和收起
-(void)showMoreAction:(UIButton *)sender{
    if (sender.tag == 1001) {
        isShowHeard = YES;
    }else{
        isShowHeard = NO;
    }
    [self.listView reloadData];
}

#pragma mark - changeHeaderStyle
-(void)changeHeaderStyle{
    CGFloat tableWidth = self.listView.frame.size.width;
    ZCRecordListModel * model = nil;
    if(_listArray.count > 0){
        model = [_listArray lastObject];
        _headerTitleLab.text = sobotConvertToString(sobotDateTransformString(SOBOT_FORMATE_DATETIME, sobotStringFormateDate(model.timeStr)));
        [_headerTitleLab sizeToFit];
        ZCRecordListModel *firstFlag = [_listArray firstObject];
        switch (firstFlag.flag) {
            case 1:
                _headerStateLab.text =  SobotKitLocalString(@"已创建");
                _headerStateLab.backgroundColor = UIColorFromKitModeColor(SobotColorTextSub1);
                break;
            case 2:
                _headerStateLab.text =  SobotKitLocalString(@"受理中");
                _headerStateLab.backgroundColor = UIColorFromKitModeColor(SobotColorYellow);
                break;
            case 3:
                _headerStateLab.text =  SobotKitLocalString(@"已完成");
                _headerStateLab.backgroundColor = UIColorFromKitModeColor(SobotColorTheme);
                break;
            default:
                break;
        }
    }
   
    CGSize s = [_headerStateLab.text sizeWithAttributes:@{NSFontAttributeName:_headerStateLab.font}];
    if(s.width > 50){
        _headerStateLab.frame = CGRectMake(tableWidth - 20 - s.width-10, 27, s.width+10, SobotNumber(20));
        // 这里不能大于最大距离 左边时间间距 16
        if ((tableWidth - 20 - s.width-10) < CGRectGetMaxX(_headerTitleLab.frame)+16) {
            _headerStateLab.frame = CGRectMake(CGRectGetMaxX(_headerTitleLab.frame)+16, 27, tableWidth - CGRectGetMaxX(_headerTitleLab.frame) -32, 20);
        }
    }
    
    if (!_showBtn.hidden) {
        if (isShowHeard) {
            CGFloat pics_height = 0;
            if(_headerMoreFileView!=nil){
                pics_height =  CGRectGetHeight(_headerMoreFileView.frame);
                _headerMoreFileView.hidden = NO;
            }
            NSString *clickText = [NSString stringWithFormat:@"%@    ",SobotKitLocalString(@"收起")];
            CGSize s = [clickText sizeWithFont:SobotFont12];
            CGFloat textwidth = s.width + 25;
            // 显示全部
            _showBtn.frame = CGRectMake(tableWidth/2-textwidth/2, CGRectGetMaxY(_conlab.frame) + SobotNumber(8) + pics_height,textwidth, SobotNumber(20));
            //展开之后
            _conlab.frame = CGRectMake(SobotNumber(15), CGRectGetMaxY(_headerTitleLab.frame) + SobotNumber(10) , contSize.width, contSize.height);
            _showBtn.tag = 1002;
//            _showBtn.space = SobotNumber(1);
            [_showBtn setTitle:clickText forState:UIControlStateNormal];
//            [_showBtn setImage:[SobotUITools getSysImageByName:@"zciocn_arrow_up"] forState:UIControlStateNormal];
            CGRect sf = _showBtn.frame;
            sf.origin.y = CGRectGetMaxY(_conlab.frame) + SobotNumber(20) + pics_height;
            _showBtn.frame = sf;
            for (UIView *view in [_headerView subviews]) {
                 if ([view isKindOfClass:[ZCReplyFileView class]]) {
                     view.hidden = NO;
                 }
             }
        }else{
            if(_headerMoreFileView!=nil){
                _headerMoreFileView.hidden = YES;
            }
            // 收起之后
            _conlab.frame = CGRectMake(SobotNumber(20), CGRectGetMaxY(_headerTitleLab.frame) + SobotNumber(8), tableWidth - SobotNumber(40), SobotNumber(40));
            NSString *clickText = [NSString stringWithFormat:@"%@    ",SobotKitLocalString(@"展开")];
            CGSize s = [clickText sizeWithFont:SobotFont12];
            CGFloat textwidth = s.width + 25;
            _showBtn.frame = CGRectMake(tableWidth/2 - textwidth/2, CGRectGetMaxY(_conlab.frame) + SobotNumber(8), textwidth, SobotNumber(20));
            _showBtn.tag = 1001;
//            _showBtn.space = SobotNumber(1);
            [_showBtn setTitle:[NSString stringWithFormat:@"%@    ",SobotKitLocalString(@"展开")] forState:UIControlStateNormal];
//            [_showBtn setImage:[SobotUITools getSysImageByName:@"zciocn_arrow_down"] forState:UIControlStateNormal];
            for (UIView *view in [_headerView subviews]) {
                 if ([view isKindOfClass:[ZCReplyFileView class]]) {
                     view.hidden = YES;
                 }
             }
        }
    }
    CGFloat y = CGRectGetMaxY(_showBtn.frame)+17;
    if(_showBtn.isHidden){
        y = CGRectGetMaxY(_conlab.frame)+17;
    }
    // 线条
    _headerlineView1.frame = CGRectMake(0,y, tableWidth, 10);
    
    CGRect hf = _headerView.frame;
    hf.size.height = y + 10;
    _headerView.frame = hf;
}

-(UILabel *)createLabel:(CGFloat )y text:(NSString *) text isTag:(BOOL) tag{
    if(tag){
        y = y + 14;
    }else{
        y = y + 5;
    }
    UILabel * labScore = [[UILabel alloc]initWithFrame:CGRectMake(20, y, ScreenWidth - 40, 18)];
    labScore.numberOfLines = 0;
    labScore.font = SobotFont14;
    if(tag){
        labScore.textColor = UIColorFromKitModeColor(SobotColorTextSub);
        labScore.text = [NSString stringWithFormat:@"%@:",text];
    }else{
        labScore.textColor = UIColorFromKitModeColor(SobotColorTextMain);
        labScore.text = text;
    }
    [_footView addSubview:labScore];
    
    
    labScore.textAlignment = NSTextAlignmentLeft;
    if(sobotIsRTLLayout()){
        labScore.textAlignment = NSTextAlignmentRight;
    }
    [labScore sizeToFit];
    
    return labScore;
}
-(UIView*)getHeaderStarViewHeight{
    if (_footView != nil) {
        [_footView removeFromSuperview];
        _footView = nil;
    }
    if(_listArray.count == 0){
        return nil;
    }
    [self createStarView];
    NSString *remarkStr = @"--";
    NSString *scoreStr = @"";
    NSString *tags = @"--";
    NSString *resolve = @"--";
   
    
    ZCRecordListModel * model = _listArray[0];
    ZCSatisfactionConfig *config = [[ZCSatisfactionConfig alloc] initWithMyDict:model.cusNewSatisfactionVO];

    
    if(sobotConvertToString(model.tag).length > 0){
        tags = model.tag;
    }
    if(sobotConvertToString(model.remark).length > 0){
        remarkStr = model.remark;
    }
    int defaultQuestionFlag = model.defaultQuestionFlag;
    if(defaultQuestionFlag == 1){
        resolve = SobotKitLocalString(@"已解决");
    }
    else if(defaultQuestionFlag == 0){
        resolve = SobotKitLocalString(@"未解决");
    }
    
    if(self.evaluateModelDic){
        NSDictionary *dic = self.evaluateModelDic[@"data"];
        if (dic) {
            NSDictionary *itemDic = dic[@"item"];
            if (itemDic) {
                
                
                if(sobotConvertToString(itemDic[@"tag"]).length > 0){
                    tags = sobotConvertToString(itemDic[@"tag"]);
                }
                
                if(sobotConvertToString(itemDic[@"remark"]).length > 0){
                    remarkStr = sobotConvertToString(itemDic[@"remark"]);
                }
                scoreStr = sobotConvertToString(itemDic[@"score"]);
                int isresolve = [sobotConvertToString(itemDic[@"defaultQuestionFlag"]) intValue];
                if(isresolve == 1){
                    resolve = SobotKitLocalString(@"已解决");
                }
                else if(isresolve == 0){
                    resolve = SobotKitLocalString(@"未解决");
                }
            }
        }
    }
    tags = [tags stringByReplacingOccurrencesOfString:@"," withString:@";"];
    tags = [tags stringByReplacingOccurrencesOfString:@";" withString:@"；"];
    
    _footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.listView.frame.size.width,0)];
//    _footView.backgroundColor = [ZCUIKitTools zcgetLightGrayBackgroundColor];
    _footView.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
    
    UIView *bgView_1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 10)];
    bgView_1.backgroundColor = UIColorFromKitModeColor(SobotColorBgLine);
    [_footView addSubview:bgView_1];
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 10, self.listView.frame.size.width, 0.5)];
    lineView.backgroundColor = [ZCUIKitTools zcgetCommentButtonLineColor];
    [_footView addSubview:lineView];
    
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(20, SobotNumber(26), ScreenWidth - SobotNumber(40), SobotNumber(24))];
    [titleLab setFont:SobotFontBold14];
    titleLab.text =SobotKitLocalString(@"我的服务评价");
    [titleLab setTextAlignment:NSTextAlignmentLeft];
    [titleLab setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
    [_footView addSubview:titleLab];
    if(sobotIsRTLLayout()){
        [titleLab setTextAlignment:NSTextAlignmentRight];
    }
    
    
    UIView *topLabel = titleLab;
    if(config.isQuestionFlag == 1){
        UILabel *lab0 = [self createLabel:CGRectGetMaxY(topLabel.frame) text:SobotKitLocalString(@"是否解决") isTag:YES];
        UILabel *lab01 = [self createLabel:CGRectGetMaxY(lab0.frame) text:resolve isTag:NO];
        topLabel = lab01;
    }
    
    
    CGFloat sx = 20;
    UILabel *lab1 = [self createLabel:CGRectGetMaxY(topLabel.frame) text:SobotKitLocalString(@"评分") isTag:YES];
    SobotRatingView *startView = [[SobotRatingView alloc] initWithFrame:CGRectMake(sx, CGRectGetMaxY(lab1.frame)+5, ScreenWidth - sx*2, 26)];
    [_footView addSubview:startView];
    [startView setImagesDeselected:@"zcicon_star_unsatisfied" fullSelected:@"zcicon_star_satisfied" count:[ZCUICore getUICore].satisfactionLeaveConfig.scoreFlag==1?10:5 showLRTip:NO andDelegate:nil];
    
    if (scoreStr.length > 0) {
        [startView displayRating:[scoreStr floatValue]];
    }else{
        [startView displayRating:[model.score floatValue]];
    }
    
    startView.backgroundColor = [UIColor clearColor];
    startView.userInteractionEnabled = NO;
    
    topLabel = startView;
    
    BOOL showScore = [@"--" isEqual:tags]?NO:YES;
    if(startView.rating > 0 && [@"--" isEqual:tags] && config!=nil && config.list!=nil && config.list.count >= startView.rating){
        ZCLibSatisfaction * model = config.list[(int)startView.rating-1];
        if(config.scoreFlag == 1){
            if(config.list.count > startView.rating){
                model = config.list[(int)startView.rating];
            }
        }
        if(model!=nil && model.tags!=nil && model.tags.count > 0){
            showScore = YES;
        }
        
    }
    if(showScore){
        UILabel *lab2 = [self createLabel:CGRectGetMaxY(topLabel.frame) text:SobotKitLocalString(@"标签") isTag:YES];
        UILabel *lab3 = [self createLabel:CGRectGetMaxY(lab2.frame) text:tags isTag:NO];
        
        topLabel = lab3;
    }
    
    if(config.txtFlag == 1){
        UILabel *lab4 = [self createLabel:CGRectGetMaxY(topLabel.frame) text:SobotKitLocalString(@"评语") isTag:YES];
        UILabel *lab5 = [self createLabel:CGRectGetMaxY(lab4.frame) text:remarkStr isTag:NO];
        topLabel = lab5;
    }
    
    _footView.frame = CGRectMake(0, 0, ScreenWidth, CGRectGetMaxY(topLabel.frame) + 20);
    
    // 线条
    UIView *lineView_1 = [[UIView alloc]initWithFrame:CGRectMake(0, _footView.frame.size.height - 1, self.listView.frame.size.width, 0.5)];
    lineView_1.backgroundColor = [ZCUIKitTools zcgetCommentButtonLineColor];
    [_footView addSubview:lineView_1];
    
//    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(lineView_1.frame), ScreenWidth, 40)];
//    bgView.backgroundColor = UIColorFromKitModeColor(SobotColorBgLine);
//    [_footView addSubview:bgView];
    return _footView;
}

-(CGFloat)addContentFileList:(CGFloat) topY{
    CGFloat  pics_height = 0;
    if(self.creatRecordListModel.fileList.count > 0) {
         float fileBgView_margin_left = 20;
         float fileBgView_margin_top = 10;
         float fileBgView_margin_right = 20;
         float fileBgView_margin = 10;
 //      算一下每行多少个 ，
        float nums = 3;
         NSInteger numInt = floor(nums);
        CGSize fileViewRect = CGSizeMake((self.view.frame.size.width - fileBgView_margin_left - fileBgView_margin_right - fileBgView_margin*2)/3, 85);
 //      行数：
         NSInteger rows = ceil(self.creatRecordListModel.fileList.count/(float)numInt);
        _headerMoreFileView = [[UIView alloc] initWithFrame:CGRectMake(fileBgView_margin_left, topY+fileBgView_margin_top, self.view.frame.size.width - fileBgView_margin_left - fileBgView_margin_right, 0)];
         for (int i = 0 ; i < self.creatRecordListModel.fileList.count;i++) {
             NSDictionary *modelDic = self.creatRecordListModel.fileList[i];
             //           当前列数
             NSInteger currentColumn = i%numInt;
 //           当前行数
             NSInteger currentRow = i/numInt;

             float x = (fileViewRect.width + fileBgView_margin)*currentColumn;
             float y = (fileViewRect.height + fileBgView_margin)*currentRow;
             float w = fileViewRect.width;
             float h = fileViewRect.height;

             ZCReplyFileView *fileBgView = [[ZCReplyFileView alloc]initWithDic:modelDic withFrame:CGRectMake(x, y, w, h)];
             fileBgView.layer.cornerRadius = 4;
             fileBgView.layer.masksToBounds = YES;

             [fileBgView setClickBlock:^(NSDictionary * _Nonnull modelDic, UIImageView * _Nonnull imgView) {
                NSString *fileType = modelDic[@"fileType"];
                NSString *fileUrlStr = modelDic[@"fileUrl"];
 //                NSArray *imgArray = [[NSArray alloc]initWithObjects:fileUrlStr, nil];
                 if ([fileType isEqualToString:@"jpg"] ||
                     [fileType isEqualToString:@"jpeg"] ||
                     [fileType isEqualToString:@"png"] ||
                     [fileType isEqualToString:@"gif"] ) {
                     //     图片预览
                     UIImageView *picView = imgView;
                     CALayer *calayer = picView.layer.mask;
                     [picView.layer.mask removeFromSuperlayer];
                     SobotXHImageViewer *xh=   [[SobotXHImageViewer alloc]initWithImageViewersobotHxWillDismissWithSelectedViewBlock:^(SobotXHImageViewer *imageViewer, UIImageView *selectedView) {
                                              
                                          } sobotHxDidDismissWithSelectedViewBlock:^(SobotXHImageViewer *imageViewer, UIImageView *selectedView) {
                                              selectedView.layer.mask = calayer;
                                              [selectedView setNeedsDisplay];
                                          } sobotHxDidChangeToImageViewBlock:^(SobotXHImageViewer *imageViewer, UIImageView *selectedView) {
                                              
                                          }];

                     NSMutableArray *photos = [[NSMutableArray alloc] init];
                     [photos addObject:picView];
                     xh.disableTouchDismiss = NO;
                     [xh showWithImageViews:photos selectedView:picView];

                 }
                 else if ([fileType isEqualToString:@"mp4"]){
                     NSURL *imgUrl = [NSURL URLWithString:fileUrlStr];
                      UIWindow *window = [SobotUITools getCurWindow];
                      ZCVideoPlayer *player = [[ZCVideoPlayer alloc] initWithFrame:window.bounds withShowInView:window url:imgUrl Image:nil];
                      [player showControlsView];
                 }

                 else{
                     SobotChatMessage *message = [[SobotChatMessage alloc]init];
                     SobotChatContent *rich = [[SobotChatContent alloc]init];
                     rich.url = fileUrlStr;

                     /**
                     * 13 doc文件格式
                     * 14 ppt文件格式
                     * 15 xls文件格式
                     * 16 pdf文件格式
                     * 17 mp3文件格式
                     * 18 mp4文件格式
                     * 19 压缩文件格式
                     * 20 txt文件格式
                     * 21 其他文件格式
                     */
                     if ([fileType isEqualToString:@"doc"] || [fileType isEqualToString:@"docx"]) {
                         rich.fileType = 13;
                     }
                     else if ([fileType isEqualToString:@"ppt"] || [fileType isEqualToString:@"pptx"]){
                         rich.fileType = 14;
                     }
                     else if ([fileType isEqualToString:@"xls"] || [fileType isEqualToString:@"xlsx"]){
                         rich.fileType = 15;
                     }
                     else if ([fileType isEqualToString:@"pdf"]){
                         rich.fileType = 16;
                     }
                     else if ([fileType isEqualToString:@"mp3"]){
                         rich.fileType = 17;
                     }
 //                    else if ([fileType isEqualToString:@"mp4"]){
 //                        rich.fileType = 18;
 //                    }
                     else if ([fileType isEqualToString:@"zip"]){
                         rich.fileType = 19;
                     }
                     else if ([fileType isEqualToString:@"txt"]){
                         rich.fileType = 20;
                     }
                     else{
                         rich.fileType = 21;
                     }
                     message.richModel = rich;
                     ZCDocumentLookController *docVc = [[ZCDocumentLookController alloc]init];
                     docVc.message = message;
                     [self.navigationController pushViewController:docVc animated:YES];
                 }
             }];
             [_headerMoreFileView addSubview:fileBgView];
         }

         pics_height =  (fileViewRect.height + fileBgView_margin_top)*rows;
        CGRect hff = _headerMoreFileView.frame;
        hff.size.height = pics_height;
        _headerMoreFileView.frame = hff;
        [_headerView addSubview:_headerMoreFileView];
     }
    return pics_height;
}

#pragma mark - 2.8.0新增回复按钮
-(void)createBottomBtn{
    self.buttonBgView = [[UIView alloc]init];
    self.buttonBgView.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
    self.buttonBgView.layer.shadowOpacity= 1;
    self.buttonBgView.layer.shadowColor = SobotColorFromRGBAlpha(0x515a7c, 0.15).CGColor;
    self.buttonBgView.layer.shadowOffset = CGSizeZero;//投影偏移
    self.buttonBgView.layer.shadowRadius = 2;
    self.buttonBgView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.buttonBgView];
    [self.view addConstraint:sobotLayoutPaddingBottom(0, self.buttonBgView, self.view)];
    [self.view addConstraint:sobotLayoutPaddingLeft(0, self.buttonBgView, self.view)];
    [self.view addConstraint:sobotLayoutPaddingRight(0, self.buttonBgView, self.view)];
    [self.view addConstraint:sobotLayoutEqualHeight(50+XBottomBarHeight, self.buttonBgView, NSLayoutRelationEqual)];
    // 回复
    self.replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.replyButton setFrame:CGRectMake(0,7, ScreenWidth, 36)];
    self.replyButton.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    self.replyButton.backgroundColor = [UIColor clearColor];
    self.replyButton.titleLabel.font = SobotFontBold14;
    [self.replyButton setTitleColor:UIColorFromModeColor(SobotColorTheme) forState:UIControlStateNormal];
//    [self.replyButton setTitleColor:[ZCUIKitTools zcgetLeaveSubmitImgColor] forState:UIControlStateNormal];
    [self.replyButton setTitle:SobotKitLocalString(@"回复") forState:UIControlStateNormal];
    [self.replyButton setImage:[SobotUITools getSysImageByName:@"zcicon_reply_button_icon"] forState:UIControlStateNormal];
    [self.replyButton setImage:[SobotUITools getSysImageByName:@"zcicon_reply_button_icon"] forState:UIControlStateHighlighted];
    if(sobotIsRTLLayout()){
        [self.replyButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -6, 0, 6)];
    }else{
        [self.replyButton setImageEdgeInsets:UIEdgeInsetsMake(0, -6, 0, 6)];
    }
    [self.replyButton addTarget:self action:@selector(replyButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonBgView addSubview:self.replyButton];
    // 评价
    self.evaluateButton = [[UIButton alloc]initWithFrame:CGRectMake(0,5, ScreenWidth, 36 )];
    self.evaluateButton.backgroundColor = [ZCUIKitTools zcgetLeaveSubmitImgColor];
    self.evaluateButton.layer.cornerRadius = 18;
    self.evaluateButton.layer.masksToBounds = YES;
    self.evaluateButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.evaluateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.evaluateButton setTitle:SobotKitLocalString(@"服务评价") forState:UIControlStateNormal];
    self.evaluateButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.evaluateButton addTarget:self action:@selector(commitScore) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonBgView addSubview:self.evaluateButton];
    self.evaluateButton.hidden = YES;
}

#pragma mark - 留言回复事件
- (void)replyButtonClick {
//    如果是横屏 跳转页面
//    if (isLandspace) {
//        ZCReplyLeaveController *vc = [[ZCReplyLeaveController alloc]init];
//        vc.ticketId = _ticketId;
//        [self.navigationController pushViewController:vc animated:YES];
//    }else{
//        //    弹出留言
            self.replyLeaveView = [[ZCReplyLeaveView alloc]initActionSheetWithView:self.view];
            self.replyLeaveView.delegate = self;
            self.replyLeaveView.ticketId = _ticketId;
            [self.replyLeaveView showInView:self.view];
            self.replyLeaveView.imageArr = self.imageArr;
            self.replyLeaveView.imagePathArr = self.imagePathArr;
            self.replyLeaveView.textDesc.text = self.replyStr;
            [self.replyLeaveView reloadScrollView];
//    }
}

#pragma mark - 去评价
-(void)commitScore{
    if(_sheet){
        [_sheet dismissView];
    }
    SobotSatisfactionParams *inP = [[SobotSatisfactionParams alloc] init];
    inP.showType = SobotSatisfactionTypeLeave;
    inP.fromSource = SobotSatisfactionFromSrouceLeave;
    inP.uid = [[ZCUICore getUICore] getLibConfig].uid;
    inP.ticketld = sobotConvertToString(self.ticketId);
    
    _sheet = [[SobotSatisfactionView alloc] initActionSheetWith:inP config:[[ZCUICore getUICore] getLibConfig] cView:nil];
    [_sheet showSatisfactionView:nil];
    
    SobotWeakSelf(self);
    [_sheet setOnSatisfactionClickBlock:^(int type, SobotSatisfactionParams * _Nonnull inParams, NSMutableDictionary * _Nullable outParams,NSDictionary * _Nullable result) {
        SobotStrogSelf(self);
        
        if(type == -1){
            // 暂不评价，直接退出
        }
        else if(type == 0){
            
        }else if(type == 1){
            [[SobotToast shareToast] showToast:SobotKitLocalString(@"感谢您的评价!") duration:1.5f view:self.view position:SobotToastPositionCenter Image:[SobotUITools getSysImageByName:@"zcicon_successful"]];
            
            self.evaluateModelDic = result;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                ZCRecordListModel *first = self.listArray.firstObject;
                first.isEvalution = 1;
                
                [self loadData];
                
                NSString *key = [NSString stringWithFormat:@"TicketKEY_%@",sobotConvertToString(self.ticketId)];
                [SobotCache removeObjectByKey:key];
            });
            
        }
        
        _sheet = nil;
    }];
}

#pragma mark - 刷新回复按钮
- (void)reloadReplyButton {
    CGFloat viewWidth = ScreenWidth;
    float replyButton_height = 36;
    float evaluateButton_margin = 10;
    float replyButton_y = 10;
    if(self.listArray==nil || self.listArray.count == 0){
        return;
    }
    ZCRecordListModel *first = self.listArray.firstObject;
    if( (first.isOpen && first.isEvalution == 0) && !self.evaluateModelDic)
    {
        [ZCUICore getUICore].satisfactionLeaveConfig = [[ZCSatisfactionConfig alloc] initWithMyDict:first.cusNewSatisfactionVO];

        if (first.flag == 3 && ![ZCUICore getUICore].kitInfo.leaveCompleteCanReply) {
            //        已完成 状态，并且 配置 不能回复，
            self.replyButton.hidden = YES;
            self.evaluateButton.hidden = NO;
            self.evaluateButton.frame = CGRectMake(0, replyButton_y, viewWidth, replyButton_height );
        }else{
            //        有评价按钮
            self.replyButton.hidden = NO;
            self.evaluateButton.hidden = NO;
            self.replyButton.frame = CGRectMake(0, replyButton_y, viewWidth/3, replyButton_height );
            self.evaluateButton.frame = CGRectMake(viewWidth/3 + evaluateButton_margin, replyButton_y, viewWidth/3*2 - evaluateButton_margin*2, replyButton_height );
        }
    }else{
        if (first.flag == 3 && ![ZCUICore getUICore].kitInfo.leaveCompleteCanReply) {
            //        已完成 状态，并且 配置 不能回复，
            self.replyButton.hidden = YES;
            self.evaluateButton.hidden = YES;
        }else{
            self.replyButton.hidden = NO;
            self.evaluateButton.hidden = YES;
            self.replyButton.frame = CGRectMake(0, replyButton_y, ScreenWidth, replyButton_height );
        }
    }
}

-(ZCLibConfig *)getCurConfig{
    return [[ZCUICore getUICore] getLibConfig];
}

#pragma mark - 加载数据
-(void)loadData{
    [[SobotToast shareToast] showProgress:@"" with:self.view];
    __weak ZCMsgDetailsVC * weakSelf = self;
    NSDictionary *dict = @{
        @"partnerid":sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.partnerid),
        @"uid":sobotConvertToString([self getCurConfig].uid),
        @"companyId":sobotConvertToString(_companyId)};
    [ZCLibServer postUserDealTicketinfoListWith:dict ticketld:_ticketId start:^{
        
    } success:^(NSDictionary *dict, NSMutableArray *itemArray, ZCNetWorkCode sendCode) {
        [[SobotToast shareToast] dismisProgress];
        if (itemArray.count > 0) {
            [weakSelf.listArray removeAllObjects];
            // flag ==2 时是 还需要处理
            for (ZCRecordListModel * model in itemArray) {
                if (model.flag == 2 && model.replayList.count > 0) {
                    for (ZCRecordListModel * item in model.replayList) {
                        item.flag = 2;
                        item.content = model.content;
                        item.timeStr = model.timeStr;
                        item.time = model.time;
                        [self.listArray addObject:item];
                    }
                }else{
                    if(model.flag == 1){
                        self.creatRecordListModel = model;
//                       创建 状态，去掉 附件
//                        model.fileList = nil;
                    }
                    [self.listArray addObject:model];
                }
                [self reloadReplyButton];
            }
            ZCRecordListModel * model = [weakSelf.listArray lastObject];
            [SobotHtmlCore filterHtml:[weakSelf filterHtmlImage:model.content] result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
                if (text1.length > 0 && text1 != nil) {
                    model.contentAttr =   [SobotHtmlFilter setHtml:text1 attrs:arr view:nil textColor:UIColorFromKitModeColor(SobotColorTextSub) textFont:SobotFont14 linkColor:[ZCUIKitTools zcgetChatLeftLinkColor]];
                }else{
                    model.contentAttr =  [[NSAttributedString alloc] initWithString:sobotConvertToString(model.content)];
                }
            }];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self createStarView];
            //这里进行UI更新
            [weakSelf.listView reloadData];
            [weakSelf.listView layoutIfNeeded];
//            NSLog(@"刷新了");
        });
        [self updateReadStatus];
    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
        [[SobotToast shareToast] dismisProgress];
        [self updateReadStatus];
    } ];
}

#pragma mark - _commitFootView view
-(void)createStarView{
    ZCRecordListModel *first = self.listArray.firstObject;
    if(first.isOpen && first.isEvalution == 0 && !self.evaluateModelDic)
    {
        UIView * bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 64 + XBottomBarHeight)];
        bgView.backgroundColor = [ZCUIKitTools zcgetLightGrayBackgroundColor];
        _listView.tableFooterView = bgView;
        _commitFootView = [[UIView alloc]initWithFrame:CGRectMake(0, ScreenHeight - 84 - XBottomBarHeight - NavBarHeight, ScreenWidth, 84 + XBottomBarHeight)];
        _commitFootView.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
        _commitFootView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
        _commitFootView.autoresizesSubviews = YES;
        // 区尾添加提交按钮 2.7.1改版
        UIButton * commitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [commitBtn setTitle:SobotKitLocalString(@"服务评价") forState:UIControlStateNormal];
        [commitBtn setTitleColor:UIColorFromKitModeColor(SobotColorTextWhite) forState:UIControlStateNormal];
        [commitBtn setTitleColor:UIColorFromKitModeColor(SobotColorTextWhite) forState:UIControlStateHighlighted];
        UIImage * img = [SobotUIImageLoader sobotImageWithColor:[ZCUIKitTools zcgetLeaveSubmitImgColor]];
        [commitBtn setBackgroundImage:img forState:UIControlStateNormal];
        [commitBtn setBackgroundImage:img forState:UIControlStateSelected];
        commitBtn.frame = CGRectMake(SobotNumber(20), 20, ScreenWidth- SobotNumber(40), SobotNumber(44));
        commitBtn.tag = BUTTON_MORE;
        [commitBtn addTarget:self action:@selector(commitScore) forControlEvents:UIControlEventTouchUpInside];
        commitBtn.layer.masksToBounds = YES;
        commitBtn.layer.cornerRadius = 22.f;
        commitBtn.titleLabel.font = SobotFont17;
        commitBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
        commitBtn.autoresizesSubviews = YES;
        [_commitFootView addSubview:commitBtn];
    }else{
        UIView * bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        _listView.tableFooterView = bgView;
        if(self.commitFootView){
            [self.commitFootView removeFromSuperview];
        }
    }
}

#pragma mark - 设置留言已读
-(void)updateReadStatus{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:@{
    @"partnerId":sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.partnerid),
    @"ticketId":sobotConvertToString(_ticketId),
    @"companyId":sobotConvertToString(_companyId)}];
    [ZCLibServer updateUserTicketReplyInfo:dict start:^{
       
    } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
       
    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
        
    }];
}

#pragma mark - 替换Img标签
-(NSString *)filterHtmlImage:(NSString *)tmp{
    NSString *picStr = [NSString stringWithFormat:@"[%@]",SobotKitLocalString(@"图片")];
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:@"<img.*?/>" options:0 error:nil];
    tmp  = [regularExpression stringByReplacingMatchesInString:tmp options:0 range:NSMakeRange(0, tmp.length) withTemplate:picStr];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"<BR/>" withString:@"\n"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"<BR />" withString:@"\n"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"<p>" withString:@"\n"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"</p>" withString:@" "];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    while ([tmp hasPrefix:@"\n"]) {
        tmp=[tmp substringWithRange:NSMakeRange(1, tmp.length-1)];
    }
    return tmp;
}

-(void)didMoveToParentViewController:(UIViewController *)parent{
    [super didMoveToParentViewController:parent];
    NSLog(@"页面侧滑返回：%@",parent);
    if(!parent){
        if([self autoAlertEvaluate]){
            return;
        }
    }
}

-(BOOL)autoAlertEvaluate{
    if(self.listArray!=nil && self.listArray.count > 0){
        ZCRecordListModel *first = self.listArray.firstObject;
        // evaluateModelDic当前评价信息，已经评价过
        if(first.isOpen && first.isEvalution == 0 && !self.evaluateModelDic)
        {
            NSString *key = [NSString stringWithFormat:@"TicketKEY_%@",sobotConvertToString(_ticketId)];
            if([ZCUICore getUICore].kitInfo.showLeaveDetailBackEvaluate && sobotConvertToString([SobotCache getLocalParamter:key]).length == 0){
                [SobotCache addObject:key forKey:key];
                [self commitScore];
                return YES;
            }
        }
    }
    return NO;
}


#pragma mark - 评论返回结果
- (void)actionSheetClickWithDic:(NSDictionary *)modelDic{
    self.evaluateModelDic = modelDic;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ZCRecordListModel *first = self.listArray.firstObject;
        first.isEvalution = 1;
        [self loadData];
        NSString *key = [NSString stringWithFormat:@"TicketKEY_%@",sobotConvertToString(self->_ticketId)];
        [SobotCache removeObjectByKey:key];
    });
}

#pragma delegate
// 赋值的时候，不执行
-(void)ratingChanged:(float)newRating{

}

-(void)ratingChangedWithTap:(float)newRating{
}
/**
 计算Label高度
 
 @param label 要计算的label，设置了值
 @param width label的最大宽度
 @param type 是否从新设置宽，1设置，0不设置
 */
- (CGSize )autoHeightOfLabel:(UILabel *)label with:(CGFloat )width IsSetFrame:(BOOL)isSet{
    //Calculate the expected size based on the font and linebreak mode of your label
    // FLT_MAX here simply means no constraint in height
    CGSize maximumLabelSize = CGSizeMake(width, FLT_MAX);
    CGSize expectedLabelSize = [label sizeThatFits:maximumLabelSize];// 返回最佳的视图大小
    //adjust the label the the new height.
    if (isSet) {
        CGRect newFrame = label.frame;
        newFrame.size.height = expectedLabelSize.height;
        label.frame = newFrame;
        [label updateConstraintsIfNeeded];
    }
    return expectedLabelSize;
}

#pragma mark -- 留言回复页面代理事件
- (void)replyLeaveViewPreviewImg:(UIButton *)button{
    NSInteger currentInt = button.tag - 100;
    NSString *imgPathStr;
    if(sobotCheckFileIsExsis([_imagePathArr objectAtIndex:currentInt])){
        imgPathStr = [_imagePathArr objectAtIndex:currentInt];
    }
    NSDictionary *imgDic = [_imageArr objectAtIndex:currentInt];
    NSString *imgFileStr =  sobotConvertToString(imgDic[@"cover"]);
    if (imgFileStr.length>0) {
//        视频预览
        NSURL *imgUrl = [NSURL fileURLWithPath:imgPathStr];
        UIWindow *window = [SobotUITools getCurWindow];
        ZCVideoPlayer *player = [[ZCVideoPlayer alloc] initWithFrame:window.bounds withShowInView:window url:imgUrl Image:button.imageView.image];
        [player showControlsView];
    }else{
//     图片预览
        UIImageView *picView=(UIImageView*)button.imageView ;
        CALayer *calayer = picView.layer.mask;
        [picView.layer.mask removeFromSuperlayer];

        SobotXHImageViewer *xh= [[SobotXHImageViewer alloc]initWithImageViewersobotHxWillDismissWithSelectedViewBlock:^(SobotXHImageViewer *imageViewer, UIImageView *selectedView) {
            
                } sobotHxDidDismissWithSelectedViewBlock:^(SobotXHImageViewer *imageViewer, UIImageView *selectedView) {
                    selectedView.layer.mask = calayer;
                    [selectedView setNeedsDisplay];
                } sobotHxDidChangeToImageViewBlock:^(SobotXHImageViewer *imageViewer, UIImageView *selectedView) {
                    
                }];
        
        NSMutableArray *photos = [[NSMutableArray alloc] init];
        [photos addObject:picView];
        xh.disableTouchDismiss = NO;
        [xh showWithImageViews:photos selectedView:picView];
    }
    
}

- (void)replyLeaveViewDeleteImg:(NSInteger )buttonIndex{
    NSInteger currentInt = buttonIndex - 100;
    if(_imageArr && _imageArr.count > currentInt){
        [_imageArr removeObjectAtIndex:currentInt];
    }
    if(_imagePathArr && _imagePathArr.count > currentInt){
        [_imagePathArr removeObjectAtIndex:currentInt];
    }
    self.replyLeaveView.imagePathArr = self.imagePathArr;
    self.replyLeaveView.imageArr = self.imageArr;
    [self.replyLeaveView reloadScrollView];
}

- (void)replyLeaveViewPickImg:(NSInteger )buttonIndex {
    __weak  ZCMsgDetailsVC *_myselft  = self;
    [[SobotImagePickerTools shareImagePickerTools] getPhotoByType:buttonIndex onlyPhoto:YES byUIImagePickerController:_myselft block:^(NSString * _Nullable filePath, SobotImagePickerFileType type, NSDictionary * _Nullable duration) {
        if(type == SobotImagePickerFileTypeImage){
            [_myselft updateloadFile:filePath type:SobotMessageTypePhoto dict:duration];
        }else{
            [_myselft converToMp4:duration withInfoDic:duration];
        }
    }];
}

- (void)replySuccess{
    [_imageArr removeAllObjects];
    [_imagePathArr removeAllObjects];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[SobotToast shareToast] showToast:SobotKitLocalString(@"提交成功") duration:1.0f view:self.view position:SobotToastPositionCenter Image:[SobotUITools getSysImageByName:@"zcicon_successful"]];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
       [self loadData];
    });
}

- (void)closeWithReplyStr:(NSString *)replyStr{
    self.replyStr = replyStr;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)updateloadFile:(NSString *)filePath type:(SobotMessageType) type dict:(NSDictionary *) cover{
    __block  ZCMsgDetailsVC *safeSelf  = self;
    [ZCLibServer fileUploadForLeave:filePath config:[self getCurConfig] start:^{
        [[SobotToast shareToast] showProgress:[NSString stringWithFormat:@"%@...",SobotKitLocalString(@"上传中")]  with:safeSelf.view];
    } success:^(NSString * _Nonnull fileURL, ZCNetWorkCode code) {
        [[SobotToast shareToast] dismisProgress];
        if (sobotIsNull(self->_imageArr)) {
            safeSelf.imageArr = [NSMutableArray arrayWithCapacity:0];
        }
        if (sobotIsNull(self->_imagePathArr)) {
            safeSelf.imagePathArr = [NSMutableArray arrayWithCapacity:0];
        }
        [safeSelf.imagePathArr addObject:filePath];
        
        NSDictionary * dic = @{@"fileUrl":fileURL};
        if(type == SobotMessageTypeVideo){
            dic = @{@"cover":cover[@"cover"],@"fileUrl":fileURL};
            [safeSelf.imageArr addObject:dic];
            //
        }else{
            [safeSelf.imageArr addObject:dic];
        }
        safeSelf.replyLeaveView.imagePathArr = safeSelf.imagePathArr;
        safeSelf.replyLeaveView.imageArr = safeSelf.imageArr;
        [safeSelf.replyLeaveView reloadScrollView];
    } fail:^(ZCNetWorkCode errorCode) {
        [[SobotToast shareToast] showToast:SobotKitLocalString(@"网络错误，请检查网络后重试") duration:1.0f view:safeSelf.view position:SobotToastPositionCenter];
    }];
}

- (NSString *)URLDecodedString:(NSString *) url
{
    NSString *result = [(NSString *)url stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    return [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

-(void) converToMp4:(NSDictionary *)dict withInfoDic:(NSDictionary *)infoDic{
    NSURL *videoUrl = dict[@"video"];
    NSString *coverImg = dict[@"image"];
    NSMutableDictionary *infoMutDic = [infoDic mutableCopy];
    [infoMutDic setValue:coverImg forKey:@"cover"];
//    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:videoUrl options:nil];
    [[SobotToast shareToast] showToast:SobotKitLocalString(@"视频处理中，请稍候!") duration:1.0 view:self.view  position:SobotToastPositionCenter];
    __weak  ZCMsgDetailsVC *keyboardSelf  = self;
    if (!sobotIsNull(videoUrl)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [keyboardSelf updateloadFile:[keyboardSelf URLDecodedString:[videoUrl absoluteString]] type:SobotMessageTypeVideo dict:infoMutDic];
        });
    }
//    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
//    NSString * fname = [NSString stringWithFormat:@"/sobot/output-%ld.mp4",(long)[NSDate date].timeIntervalSince1970];
//    sobotCheckPathAndCreate(sobotGetDocumentsFilePath(@"/sobot/"));
//    NSString *resultPath=sobotGetDocumentsFilePath(fname);
//    exportSession.outputURL = [NSURL fileURLWithPath:resultPath];
//    exportSession.outputFileType = AVFileTypeMPEG4;
//    exportSession.shouldOptimizeForNetworkUse = YES;
//    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
//     {
//         switch (exportSession.status) {
//             case AVAssetExportSessionStatusCompleted:{
//                 // 主队列回调
//                 dispatch_async(dispatch_get_main_queue(), ^{
//                     [keyboardSelf updateloadFile:[self URLDecodedString:resultPath] type:SobotMessageTypeVideo dict:infoMutDic];
//                 });
//             }
//                 break;
//             case AVAssetExportSessionStatusUnknown:
//                 //                 NSLog(@"AVAssetExportSessionStatusUnknown");
//                 break;
//
//             case AVAssetExportSessionStatusWaiting:
//                 //                 NSLog(@"AVAssetExportSessionStatusWaiting");
//                 break;
//
//             case AVAssetExportSessionStatusExporting:
//                 //                 NSLog(@"AVAssetExportSessionStatusExporting");
//                 break;
//             case AVAssetExportSessionStatusFailed:
//                 //                 NSLog(@"AVAssetExportSessionStatusFailed");
//                 break;
//             case AVAssetExportSessionStatusCancelled:
//                 break;
//         }
//     }];
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
    [self setLeftTags:rightItem rightTags:@[] titleView:nil];
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


@end
