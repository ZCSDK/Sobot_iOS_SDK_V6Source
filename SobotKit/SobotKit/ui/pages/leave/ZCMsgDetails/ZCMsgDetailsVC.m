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
#import "ZCLeaveDetailHeaderCell.h"
#define headercellIdentifier @"ZCLeaveDetailHeaderCell"
#import "ZCMsgDetailsNoDataCell.h"
#define noDatallIdentifier @"ZCMsgDetailsNoDataCell"
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
// 顶部背景的渐变色
@property (nonatomic,strong) UIView *hBgView;
@property (nonatomic,strong) UIView *headerContView;
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

// 4.2.3开始接口改造，整个页面都在同一个model下
@property (nonatomic,strong) ZCRecordListModel *showModel;
// 回复按钮的右边
@property (nonatomic,strong) NSLayoutConstraint *replyButtonPR;
@property (nonatomic,strong) NSLayoutConstraint *evaluateButtonW;
@property (nonatomic,strong) NSLayoutConstraint *buttonBgViewH;
@property (nonatomic,strong) NSLayoutConstraint *evaluateButtonH;
@property (nonatomic,strong) NSLayoutConstraint *replyButtonH;
// 有时在上 有时在回复按钮的下方 12个像素
@property (nonatomic,strong) NSLayoutConstraint *evaluateButtonT;
@end

@implementation ZCMsgDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
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
    [self createTableView];
    [self createBottomBtn];
    [self getOrerStatusList];
    [self loadData];
}

-(void)getOrerStatusList{
    [ZCLibServer getOrderStatusList:[self getCurConfig] start:^(NSString * _Nonnull urlString) {
        
    } success:^(NSDictionary * _Nonnull dict, ZCNetWorkCode sendCode) {
        
    } failed:^(NSString * _Nonnull errorMessage, ZCNetWorkCode errorCode) {
        
    } finish:^(NSString * _Nonnull jsonString) {
        
    }];
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
    [_listView registerClass:[ZCLeaveDetailHeaderCell class] forCellReuseIdentifier:headercellIdentifier];
    [_listView registerClass:[ZCMsgDetailsNoDataCell class] forCellReuseIdentifier:noDatallIdentifier];
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
    _listView.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
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

// 返回section高度 已抽cell
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(section == 0){
        ZCRecordListModel *first = self.showModel;
        if((first.isOpen && first.isEvaluation == 1) || !sobotIsNull(self.evaluateModelDic))
                {
                    if(_footView){
                        return CGRectGetHeight(_footView.frame);
                    }else{
                        [self getHeaderStarViewHeight];
                        return CGRectGetHeight(_footView.frame);
                    }
                }
        return 0;
     }
     return 0;
}
// 返回section 的View
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        ZCRecordListModel *first = self.showModel;
        if((first.isOpen && first.isEvaluation == 1) || self.evaluateModelDic)
        {
            return [self getHeaderStarViewHeight];
        }else{
            UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
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
//        && !sobotIsNull(self.showModel.replyList) && self.showModel.replyList.count >0 &&self.listArray.count >0
        if (!sobotIsNull(self.showModel)) {
            return self.listArray.count;
        }
    }
    return 0;
}

// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        ZCLeaveDetailHeaderCell *cell = (ZCLeaveDetailHeaderCell*)[tableView dequeueReusableCellWithIdentifier:headercellIdentifier];
        if (cell == nil) {
            cell = [[ZCLeaveDetailHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        [cell initWithData:self.listArray[0] IndexPath:indexPath.row isOpen:self.showModel.isLookOpen];
        cell.headerBlock = ^(ZCRecordListModel * _Nonnull model, BOOL isOpen) {
            self->_showModel.isLookOpen = isOpen;
            [self->_listView reloadData];
        };
        // 去掉选中时的背景色
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if ((sobotIsNull(self.showModel.replyList) || self.showModel.replyList.count ==0) && indexPath.row == 1 ){
        ZCRecordListModel *listModel = self.listArray[indexPath.row];
        if (listModel.isShowNoData) {
            // 占位页面
            ZCMsgDetailsNoDataCell *cell = (ZCMsgDetailsNoDataCell*)[tableView dequeueReusableCellWithIdentifier:noDatallIdentifier];
            if (cell == nil) {
                cell = [[ZCMsgDetailsNoDataCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:noDatallIdentifier];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        return nil;
    }else{
        ZCLeaveDetailCell *cell = (ZCLeaveDetailCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[ZCLeaveDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        if ( indexPath.row > self.listArray.count -1) {
            return cell;
        }
        
        [cell setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark1)];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        ZCRecordListDetailModel * model = self.listArray[indexPath.row];
        __weak ZCMsgDetailsVC * saveSelf = self;
        [cell initWithData:model IndexPath:indexPath.row count:(int)self.listArray.count];
        [cell setShowDetailClickCallback:^(ZCRecordListDetailModel * _Nonnull model,NSString *urlStr) {
            if (urlStr) {
                ZCUIWebController *webVC = [[ZCUIWebController alloc] initWithURL:urlStr];
                [saveSelf.navigationController pushViewController:webVC animated:YES];
                return;
            }
            // 新版数据结构 头部使用content 列表数据都使用replyContent
            NSString *htmlString = model.replyContent;
            ZCUIWebController *webVC = [[ZCUIWebController alloc] initWithURL:htmlString];
            [saveSelf.navigationController pushViewController:webVC animated:YES];
        }];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.selected = NO;
        // 去掉选中时的背景色
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
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
    [labScore sizeToFit];
    return labScore;
}

#pragma mark --// 是否有星评的数据 显示星评的数据 已解决 未解决 几星 几分 备注 等显示 放的区尾
-(UIView*)getHeaderStarViewHeight{
    if (_footView != nil) {
        [_footView removeFromSuperview];
        _footView = nil;
    }
    if(sobotIsNull(self.showModel)){
        return nil;
    }
    [self createStarView];
    NSString *remarkStr = @"--";
    NSString *scoreStr = @"";
    NSString *tags = @"--";
    NSString *resolve = @"--";
    
    ZCRecordListModel * model = self.showModel;
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
    _footView.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
    UIView *bgView_1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 10)];
    // 不要颜色
//    bgView_1.backgroundColor = UIColorFromKitModeColor(SobotColorBgTopLine);
    [_footView addSubview:bgView_1];
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 10, self.listView.frame.size.width, 0.5)];
    lineView.backgroundColor = UIColorFromKitModeColor(SobotColorBgTopLine);
    [_footView addSubview:lineView];
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 26, ScreenWidth - 40, SobotNumber(24))];
    [titleLab setFont:SobotFontBold14];
    titleLab.text =SobotKitLocalString(@"我的服务评价");
    [titleLab setTextAlignment:NSTextAlignmentLeft];
    if ([ZCUIKitTools getSobotIsRTLLayout]) {
        [titleLab setTextAlignment:NSTextAlignmentRight];
    }
    [titleLab setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
    [_footView addSubview:titleLab];
    UIView *topLabel = titleLab;
    if(config.isQuestionFlag == 1){
        UILabel *lab0 = [self createLabel:CGRectGetMaxY(topLabel.frame) text:SobotKitLocalString(@"是否解决") isTag:YES];
        UILabel *lab01 = [self createLabel:CGRectGetMaxY(lab0.frame) text:resolve isTag:NO];
        topLabel = lab01;
    }
    CGFloat sx = 20;
    UILabel *lab1 = [self createLabel:CGRectGetMaxY(topLabel.frame) text:SobotKitLocalString(@"评分") isTag:YES];
    SobotRatingView *startView = [[SobotRatingView alloc] initWithFrame:CGRectMake(sx, CGRectGetMaxY(lab1.frame)+5, ScreenWidth - sx*2, 26)];
    startView.alignLeft = YES;
    [_footView addSubview:startView];
    [startView setImagesDeselected:@"zcicon_star_unsatisfied_new" fullSelected:@"zcicon_star_satisfied_new" count:[ZCUICore getUICore].satisfactionLeaveConfig.scoreFlag==1?10:5 showLRTip:NO andDelegate:nil];
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
        if(model!=nil && model.scoreTags!=nil && model.scoreTags.count > 0){
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
//    lineView_1.backgroundColor = [ZCUIKitTools zcgetCommentButtonLineColor];
    [_footView addSubview:lineView_1];
    
    [ZCUIKitTools setViewRTLtransForm:_footView];
    return _footView;
}

#pragma mark -- 区头的文件
-(CGFloat)addContentFileList:(CGFloat) topY{
    CGFloat  pics_height = 0;
    if(self.creatRecordListModel.fileList.count > 0) {
         float fileBgView_margin_left = 20;
         float fileBgView_margin_top = 12;
         float fileBgView_margin_right = 20;
         float fileBgView_margin = 8;// 间距item之间
 //      算一下每行多少个 ，
        float nums = 4;
         NSInteger numInt = floor(nums);
        CGSize fileViewRect = CGSizeMake((self.view.frame.size.width - fileBgView_margin_left - fileBgView_margin_right - fileBgView_margin*3)/4, 75);
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

#pragma mark - 2.8.0新增回复按钮  423 使用新版的UI
-(void)createBottomBtn{
    self.buttonBgView = [[UIView alloc]init];
    self.buttonBgView.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
    [self.view addSubview:self.buttonBgView];
    [self.view addConstraint:sobotLayoutPaddingBottom(0, self.buttonBgView, self.view)];
    [self.view addConstraint:sobotLayoutPaddingLeft(0, self.buttonBgView, self.view)];
    [self.view addConstraint:sobotLayoutPaddingRight(0, self.buttonBgView, self.view)];
    self.buttonBgViewH = sobotLayoutEqualHeight(50+XBottomBarHeight, self.buttonBgView, NSLayoutRelationEqual);
    [self.view addConstraint:self.buttonBgViewH];
    // 回复
    self.replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.replyButton.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    self.replyButton.backgroundColor = [UIColor clearColor];
    self.replyButton.titleLabel.font = SobotFont16;
    [self.replyButton setTitleColor:UIColorFromModeColor(SobotColorTheme) forState:UIControlStateNormal];
    [self.replyButton setTitle:SobotKitLocalString(@"回复") forState:UIControlStateNormal];
    [self.replyButton addTarget:self action:@selector(replyButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.replyButton setTitleColor:[ZCUIKitTools zcgetRobotBtnTitleColor] forState:0];
    [self.replyButton setBackgroundColor:[ZCUIKitTools zcgetServerConfigBtnBgColor]];
    self.replyButton.layer.cornerRadius = 4;
    self.replyButton.layer.masksToBounds = YES;
    [self.buttonBgView addSubview:self.replyButton];
    [self.buttonBgView addConstraint:sobotLayoutPaddingLeft(16, self.replyButton, self.buttonBgView)];
    self.replyButtonPR = sobotLayoutPaddingRight(-16, self.replyButton, self.buttonBgView);
    [self.buttonBgView addConstraint:self.replyButtonPR];
    self.replyButtonH = sobotLayoutEqualHeight(40, self.replyButton, NSLayoutRelationEqual);
    [self.buttonBgView addConstraint:self.replyButtonH];
    [self.buttonBgView addConstraint:sobotLayoutPaddingTop(10, self.replyButton, self.buttonBgView)];

    // 评价
    self.evaluateButton = [[UIButton alloc]init];
    self.evaluateButton.backgroundColor = [ZCUIKitTools zcgetServerConfigBtnBgColor];
    self.evaluateButton.layer.cornerRadius = 4;
    self.evaluateButton.layer.masksToBounds = YES;
    self.evaluateButton.titleLabel.font = SobotFont16;
    [self.evaluateButton setTitleColor:[ZCUIKitTools zcgetRobotBtnTitleColor] forState:UIControlStateNormal];
    [self.evaluateButton setTitle:SobotKitLocalString(@"服务评价") forState:UIControlStateNormal];
    self.evaluateButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.evaluateButton addTarget:self action:@selector(commitScore) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonBgView addSubview:self.evaluateButton];
    self.evaluateButton.hidden = YES;
    [self.buttonBgView addConstraint:sobotLayoutPaddingRight(-16, self.evaluateButton, self.buttonBgView)];
    self.evaluateButtonT = sobotLayoutMarginTop(-40, self.evaluateButton, self.replyButton);
//    [self.buttonBgView addConstraint:sobotLayoutPaddingTop(10, self.evaluateButton, self.buttonBgView)];
    [self.buttonBgView addConstraint:self.evaluateButtonT];
    self.evaluateButtonH = sobotLayoutEqualHeight(40, self.evaluateButton, NSLayoutRelationEqual);
    [self.buttonBgView addConstraint:self.evaluateButtonH];
    self.evaluateButtonW = sobotLayoutEqualWidth((ScreenWidth-32-8)/2, self.evaluateButton, NSLayoutRelationEqual);
    [self.buttonBgView addConstraint:self.evaluateButtonW];
}

#pragma mark - 留言回复事件
- (void)replyButtonClick {
//    如果是横屏 跳转页面
//    if (isLandspace) {
//        ZCReplyLeaveController *vc = [[ZCReplyLeaveController alloc]init];
//        vc.ticketId = _ticketId;
//        [self.navigationController pushViewController:vc animated:YES];
//    }else{
    // 先看缓存是否有
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@_%@_%@",[self getCurConfig].cid,[self getCurConfig].uid,self.ticketId];
    NSDictionary *dict = [userdefaults objectForKey:key];
    if (!sobotIsNull(dict) && [dict isKindOfClass:[NSDictionary class]]) {
        NSMutableArray *imageArr = [NSMutableArray arrayWithArray:[dict objectForKey:@"images"]];
        NSMutableArray *imagePathArr = [NSMutableArray arrayWithArray:[dict objectForKey:@"imagepath"]];
        NSString *text = sobotConvertToString([dict objectForKey:@"text"]);
        
        if (!sobotIsNull(imageArr) && [imageArr isKindOfClass:[NSMutableArray class]]) {
            self.imageArr = imageArr;
        }
        if (!sobotIsNull(imagePathArr) && [imagePathArr isKindOfClass:[NSMutableArray class]]) {
            self.imagePathArr = imagePathArr;
        }
        self.replyStr = text;
    }
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
                ZCRecordListModel *first = self->_showModel;
                first.isEvaluation = 1;
                
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
    float replyButton_height = 40;
    float evaluateButton_margin = 10;
    float replyButton_y = 10;
    if (sobotIsNull(self.showModel)) {
        return;
    }
    
    self.replyButton.layer.borderColor = UIColor.clearColor.CGColor;
    self.replyButton.layer.borderWidth = 0;
    [self.replyButton setTitleColor:UIColorFromKitModeColor(SobotColorWhite) forState:0];
    [self.replyButton setBackgroundColor:[ZCUIKitTools zcgetServerConfigBtnBgColor]];
    self.replyButtonH.constant = 40;
    self.evaluateButtonH.constant = 40;
    ZCRecordListModel *first = self.showModel;
    self.evaluateButtonT.constant = -40;
    self.buttonBgViewH.constant = 50 +XBottomBarHeight;
    self.listB.constant = -XBottomBarHeight -60;
    if( (first.isOpen && first.isEvaluation == 0) && !self.evaluateModelDic)
    {
        [ZCUICore getUICore].satisfactionLeaveConfig = [[ZCSatisfactionConfig alloc] initWithMyDict:first.cusNewSatisfactionVO];
        // 缺已完成的状态
        if (![ZCUICore getUICore].kitInfo.leaveCompleteCanReply) {
            //        已完成 状态，并且 配置 不能回复，
            self.replyButton.hidden = YES;
            self.evaluateButton.hidden = NO;
//            self.evaluateButton.frame = CGRectMake(0, replyButton_y, viewWidth, replyButton_height );
            self.evaluateButtonW.constant = ScreenWidth-32;
            [self.evaluateButton setBackgroundColor:[ZCUIKitTools zcgetServerConfigBtnBgColor]];
            
        }else{
            //        有评价按钮
            self.replyButton.hidden = NO;
            self.evaluateButton.hidden = NO;
            self.replyButtonPR.constant = -(ScreenWidth/2) -4;
            self.evaluateButtonW.constant = (ScreenWidth-32-8)/2;
            [self.evaluateButton setBackgroundColor:[ZCUIKitTools zcgetServerConfigBtnBgColor]];
            [self.replyButton setBackgroundColor:UIColor.clearColor];
            self.replyButton.layer.borderColor = UIColorFromKitModeColor(SobotColorBgTopLine).CGColor;
            self.replyButton.layer.borderWidth = 1;
            [self.replyButton setTitleColor:UIColorFromKitModeColor(SobotColorTextMain) forState:0];
            
            // 这里需要考虑一行放不下的问题 两个按钮同时显示的场景下出现
            CGFloat maxW =  (ScreenWidth - SobotSpace16 * 2 - 8)/2;
            CGFloat w1 = [SobotUITools getWidthContain:SobotKitLocalString(@"回复") font:_replyButton.titleLabel.font Height:22];
            CGFloat w2 = [SobotUITools getWidthContain:SobotKitLocalString(@"服务评价") font:_evaluateButton.titleLabel.font Height:22];
            if (w1 >maxW || w2 >maxW) {
                // 按钮需要换行显示，并且需要重新计算实际高度
                // 同时显示 上下排列
                // 获取最大高度  内部左右间距20
                CGFloat th = [SobotUITools getHeightContain:SobotKitLocalString(@"服务评价") font:SobotFont16 Width:ScreenWidth-32-40];
                th = th +16;// 上下8个像素
                if (th <40) {
                    th = 40;
                }
                self.evaluateButtonH.constant = th;
                CGFloat th1 = [SobotUITools getHeightContain:SobotKitLocalString(@"回复") font:SobotFont16 Width:ScreenWidth-32-40];
                th1 = th1 +16;// 上下8个像素
                if (th1 <40) {
                    th1 = 40;
                }
                self.replyButtonH.constant = th1;
                self.evaluateButtonT.constant = 12;
                self.buttonBgViewH.constant = 10 + th + 12 + th1 + XBottomBarHeight;
                self.listB.constant = - self.buttonBgViewH.constant;
            }
        }
    }else{
        if (![ZCUICore getUICore].kitInfo.leaveCompleteCanReply) {
            //        已完成 状态，并且 配置 不能回复，
            self.replyButton.hidden = YES;
            self.evaluateButton.hidden = YES;
        }else{
            self.replyButton.hidden = NO;
            self.evaluateButton.hidden = YES;
            self.replyButtonPR.constant = -16;
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
            // 新版接口改造 数据结构改变 只有一个数据
            self->_showModel = [[ZCRecordListModel alloc]init];
            self->_showModel = [itemArray firstObject];
            // 同步处理底部按钮回显
            [self reloadReplyButton];
            if (weakSelf.showModel && !sobotIsNull(weakSelf.showModel.replyList) && weakSelf.showModel.replyList.count >0) {
                [weakSelf.listArray addObjectsFromArray:weakSelf.showModel.replyList];
            }
            if (weakSelf.showModel) {
                if (weakSelf.showModel.replyList.count == 0) {
                    ZCRecordListModel *noModel = [[ZCRecordListModel alloc]init];
                    noModel = [itemArray firstObject];
                    noModel.isShowNoData = YES;
                    [weakSelf.listArray addObject:noModel];
                }
                // 这里插入原区头数据
                [weakSelf.listArray insertObject:self.showModel atIndex:0];
            }
            // 处理HTML数据 用于显示
            [SobotHtmlCore filterHtml:[weakSelf filterHtmlImage:weakSelf.showModel.content] result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
                if (text1.length > 0 && text1 != nil) {
                    weakSelf.showModel.contentAttr =   [SobotHtmlFilter setHtml:text1 attrs:arr view:nil textColor:UIColorFromKitModeColor(SobotColorTextSub) textFont:SobotFont14 linkColor:[ZCUIKitTools zcgetChatLeftLinkColor]];
                }else{
                    weakSelf.showModel.contentAttr =  [[NSAttributedString alloc] initWithString:sobotConvertToString(weakSelf.showModel.content)];
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

#pragma mark - _commitFootView view commitFootView
-(void)createStarView{
    ZCRecordListModel *first = self.showModel;
    if(first.isOpen && first.isEvaluation == 0 && !self.evaluateModelDic)
    {
        UIView * bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 64 + XBottomBarHeight)];
        bgView.backgroundColor = UIColor.clearColor;
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

- (void)buttonClick:(UIButton *)sender{
//    [super buttonClick:sender];
    if (sender.tag == SobotButtonClickBack) {
        if (![self autoAlertEvaluate]) {
            [super buttonClick:sender];
        }
    }
}

-(BOOL)autoAlertEvaluate{
    if(!sobotIsNull(self.showModel)){
        ZCRecordListModel *first = self.showModel;
        // evaluateModelDic当前评价信息，已经评价过
        if(first.isOpen && first.isEvaluation == 0 && !self.evaluateModelDic)
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
        first.isEvaluation = 1;
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
//    NSString *imgFileStr =  sobotConvertToString(imgDic[@"fileUrl"]);
    if (imgFileStr.length>0) {
        imgFileStr = sobotConvertToString(imgDic[@"fileUrl"]);
//        视频预览
        NSURL *imgUrl = [NSURL fileURLWithPath:imgFileStr];
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
    [[SobotImagePickerTools shareImagePickerTools] getPhotoByType:buttonIndex onlyPhoto:NO byUIImagePickerController:_myselft block:^(NSString * _Nullable filePath, SobotImagePickerFileType type, NSDictionary * _Nullable duration) {
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
    // 这里需要清理掉缓存数据
    NSUserDefaults *defaultDict = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@_%@_%@",[self getCurConfig].cid,[self getCurConfig].uid,self.ticketId];
    [defaultDict removeObjectForKey:key];
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
    if ([ZCUIKitTools getSobotIsRTLLayout]) {
        [self setLeftTags:@[] rightTags:rightItem titleView:nil];
    }else{
        [self setLeftTags:rightItem rightTags:@[] titleView:nil];
    }
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
