//
//  ZCUIEvaluateView.m
//  SobotKit
//
//  Created by lizh on 2022/9/19.
//

#import "ZCUIEvaluateView.h"
#import "ZCUIRatingView.h"
#import "ZCUIPlaceHolderTextView.h"
#import "ZCItemView.h"
//#import "ZCUIPlaceHolderTextView.h"
#import "ZCUIRatingView.h"
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClient.h>
#import "ZCUICore.h"
#import "ZCUIKitTools.h"
#define BorderWith     0.75f //(1.0 / [UIScreen mainScreen].scale) / 2
#define INPUT_MAXCOUNT 200
#define ZCkScreenWidth         [UIScreen mainScreen].bounds.size.width

@interface ZCUIEvaluateView()<RatingViewDelegate,UIGestureRecognizerDelegate,UITextViewDelegate>
{
    CGFloat ZCMaxHeight;
    CGFloat viewWidth;
    CGFloat viewHeight;
    ZCLibConfig *_config;
    BOOL isKeyBoardShow;
    BOOL touchRating;
    BOOL _isMustAdd; // 标签是否是必选
    BOOL _isInputMust;// 评价框是否必填
    NSMutableArray * _listArray;// 人工评价标签数据
    // 默认显示 0五星   1  0星
    int defaultStar;
    int scoreFlag;// 0:5星,1:10分
    int curResolve;//-1未选择，0未解决，1已解决
    CGFloat SCH;// 中间页面的高度 动态获取
    CGFloat minw ;
    CGFloat SSCH;// 临时变量 记录切换人工评价标签前的 item 和满意度标签的高度
    CGFloat botH;// 底部提交和暂不评价的最终高度
    CGFloat nickH;// 临时变量，昵称动态高度
    CGFloat topViewH;//记录顶部的动态高度
    BOOL isTwoHight;// 已解决 未解决是否是两行高度
    
    CGFloat MH;// 默认中间部分展示高度
}

@property(nonatomic,strong) ZCUICustomActionSheetModel *evaluateModel; // 评价参数model
@property(nonatomic,strong) ZCItemView *item;
@property(nonatomic,strong) ZCUIRatingView *ratingView;// 星评View
@property(nonatomic,strong) ZCUIPlaceHolderTextView *textView;
@property(nonatomic,strong) UIView *sheetView;// 背景View(白色View)
@property(nonatomic,strong) UIScrollView *backGroundView;// 内容视图view（中间滑动部分）
@property(nonatomic,strong) UIView *topView;// 顶部View
@property(nonatomic,strong) UIButton *closeBtn;// 关闭
@property(nonatomic,strong) UIButton *canReturnBtn;// 暂不评价
@property(nonatomic,strong) UILabel *titlelab;// 顶部标题
@property(nonatomic,strong) UILabel *topTiplab;// 显示提交后会话将结束
@property(nonatomic,strong) UILabel *nicklab;// 【昵称】是否解决了您的问题
@property(nonatomic,strong) UIButton *robotChangeBtn1; // 已解决
@property(nonatomic,strong) UIButton *robotChangeBtn2; // 未解决
@property(nonatomic,strong) UIView *nickLineView;// 如果显示已解决、未解决，添加一条线
@property(nonatomic,assign) BOOL isChangePostion;// 是否去刷新星评
@property(nonatomic,strong) UILabel *tiplab;//满意度
@property(nonatomic,strong) UILabel *stLable;//是否有以下情况
@property(nonatomic,strong) UIButton *commitBtn;// 提交评价
/// 约束相关
@property(nonatomic,strong) NSLayoutConstraint *titleLabPT;
@property(nonatomic,strong) NSLayoutConstraint *titleLabEH;
@property(nonatomic,strong) NSLayoutConstraint *nicklabEH;
@property(nonatomic,strong) NSLayoutConstraint *nicklabPL;
@property(nonatomic,strong) NSLayoutConstraint *nicklabPR;
@property(nonatomic,strong) NSLayoutConstraint *nicklabPT;
@property(nonatomic,strong) NSLayoutConstraint *tiplabEH;
@property(nonatomic,strong) NSLayoutConstraint *stLableMT;
@property(nonatomic,strong) NSLayoutConstraint *stLableEH;
@property(nonatomic,strong) NSLayoutConstraint *itemEH;
@property(nonatomic,strong) NSLayoutConstraint *itemMT;
@property(nonatomic,strong) NSLayoutConstraint *textViewMT;
@property(nonatomic,strong) NSLayoutConstraint *backGroundViewEH;
@property(nonatomic,strong) NSLayoutConstraint *sheetViewEH;
//@property(nonatomic,strong) NSLayoutConstraint *sheetViewPT;
@property(nonatomic,strong) NSLayoutConstraint *textViewEW;
@property(nonatomic,strong) NSLayoutConstraint *topViewEH;
@end

@implementation ZCUIEvaluateView

-(ZCUIEvaluateView*)initActionSheetWith:(ZCUICustomActionSheetModel *)model Cofig:(ZCLibConfig *)config cView:(UIView *)view{
    self = [super init];
    if (self) {
        MH = 108;
        botH = 80;
        viewWidth = ScreenWidth;// view.frame.size.width;
        viewHeight = ScreenHeight;
        minw = MIN(viewWidth, viewHeight);
        ZCMaxHeight =   ((ScreenHeight>800) ? (ScreenHeight-420 - 59):(ScreenHeight-340 - 59));
        if(ZCMaxHeight < 160){
            ZCMaxHeight = 160;
        }
        _config = config;
        self.evaluateModel = model;
        // 初始化的背景视图，添加手势  添加高斯模糊
        self.frame = CGRectMake(0, 0, viewWidth, viewHeight);
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleHeight;
        self.autoresizesSubviews = YES;
        self.backgroundColor = SobotRgbColorAlpha(0,0,0,0.4);
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(shareViewDismiss:)];
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
        if (self.evaluateModel.isEvalutionAdmin) {
            // 加载人工客服的标签。根据接口的数据进行UI布局
            [self loadDataWithUid:self.evaluateModel.uid];
        }else{
            self.evaluateModel.isOpenProblemSolving = YES;
            // 机器人的模式为固定格式
            [self setupType:self.evaluateModel.type];
        }
    }
    return self;
}

- (void)loadDataWithUid:(NSString *)uid{
    if (self.evaluateModel.type == SatisfactionTypeLeaveReply) {
        // 刷新UI
        [self setDisplay];
    }else{
        if([ZCUICore getUICore].satisfactionConfig!=nil && [ZCUICore getUICore].satisfactionConfig.isCreated == 1){
            [self refreshSatisfaction];
        }else{
            [[ZCUICore getUICore] loadSatisfactionDictlock:^(int code) {
                [self refreshSatisfaction];
            }];
        }
    }
}

#pragma mark - 刷新评价参数
-(void)refreshSatisfaction{
    ZCSatisfactionConfig *config = [ZCUICore getUICore].satisfactionConfig;
    if(config && config.isCreated == 1){
        _listArray = config.list;
        
        defaultStar = 0;
        scoreFlag = config.scoreFlag;
        
        // 默认选中
        self.evaluateModel.isResolve = config.defaultQuestionFlag;
        self.evaluateModel.isOpenDefaultStar = YES;
        if (config.isQuestionFlag == 1) {
            self.evaluateModel.isOpenProblemSolving = config.isQuestionFlag;
        }else{
            self.evaluateModel.isOpenProblemSolving = NO;
        }
        
        if(config.scoreFlag==0){
            if(config.defaultType == 0){
                defaultStar = 5;
            }else if(config.defaultType == 1){
                defaultStar = 0;
                self.evaluateModel.isOpenDefaultStar = NO;
            }
        }else{
            
            if(config.defaultType == 0){
                defaultStar = 10;
            }else if(config.defaultType == 1){
                defaultStar = 5;
            }else if(config.defaultType == 2){
                defaultStar = 0;
            }else if(config.defaultType == 3){
                defaultStar = 0;
                self.evaluateModel.isOpenDefaultStar = NO;
            }
        }
        
    }
    // 加载成功的布局
    [self setDisplay];
}

-(void)setDisplay{
    [self setupType:self.evaluateModel.type];
}

#pragma mark - 根据调用页面的action 类型布局子视图
-(void)setupType:(SatisfactionType)type{
    _sheetView = ({
        UIView *iv = [[UIView alloc]init];
        [self addSubview:iv];
        iv.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
//        iv.backgroundColor = [UIColor yellowColor];
        [self addConstraint:sobotLayoutPaddingLeft(0, iv, self)];
        [self addConstraint:sobotLayoutPaddingRight(0, iv, self)];
        [self addConstraint:sobotLayoutPaddingBottom(0, iv, self)];
        self.sheetViewEH = sobotLayoutEqualHeight(ZCMaxHeight, iv, NSLayoutRelationEqual);
        [self addConstraint:self.sheetViewEH];
        iv;
    });
    
    _topView = ({
        UIView *iv = [[UIView alloc]init];
        [self.sheetView addSubview:iv];
        iv.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
//        iv.backgroundColor = [UIColor purpleColor];
        [self.sheetView addConstraint:sobotLayoutPaddingTop(0, iv, self.sheetView)];
        [self.sheetView addConstraint:sobotLayoutPaddingLeft(0, iv, self.sheetView)];
        [self.sheetView addConstraint:sobotLayoutPaddingRight(0, iv, self.sheetView)];
        self.topViewEH = sobotLayoutEqualHeight(60, iv, NSLayoutRelationEqual);
        [self.sheetView addConstraint:self.topViewEH];
        topViewH = 60;
        iv;
    });
    
    // 顶部标题栏部分  关闭按钮  标题  暂不评价 评价后结束会话
    // 左上角关闭按钮
    _closeBtn = ({
        UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.topView addSubview:iv];
        [iv setImage:[SobotUITools getSysImageByName:@"zcicon_sf_close"] forState:UIControlStateNormal];
        [iv setImage:[SobotUITools getSysImageByName:@"zcicon_sf_close"] forState:UIControlStateSelected];
        [iv setImage:[SobotUITools getSysImageByName:@"zcicon_sf_close"] forState:UIControlStateHighlighted];
        [iv addTarget:self action:@selector(zcDismissView:) forControlEvents:UIControlEventTouchUpInside];
//        iv.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.topView addConstraint:sobotLayoutPaddingTop(8, iv, self.topView)];
        [self.topView addConstraint:sobotLayoutEqualWidth(44, iv, NSLayoutRelationEqual)];
        [self.topView addConstraint:sobotLayoutPaddingRight(-10, iv, self.topView)];
        [self.topView addConstraint:sobotLayoutEqualHeight(44, iv, NSLayoutRelationEqual)];
        iv;
    });
    
    
    // 评价标题
    _titlelab = ({
        UILabel *iv = [[UILabel alloc]init];
        iv.textColor = UIColorFromKitModeColor(SobotColorTextMain);
        iv.textAlignment = NSTextAlignmentCenter;
        iv.numberOfLines = 0;
        iv.font = SobotFontBold17;
        iv.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.topView addSubview:iv];
        self.titleLabPT = sobotLayoutPaddingTop(10, iv, self.topView);
        [self.topView addConstraint:self.titleLabPT];
        self.titleLabEH = sobotLayoutEqualHeight(20, iv, NSLayoutRelationEqual);
        [self.topView addConstraint:self.titleLabEH];
        [self.topView addConstraint:sobotLayoutPaddingLeft(50, iv, self.topView)];
        [self.topView addConstraint:sobotLayoutPaddingRight(-50, iv, self.topView)];
        iv;
    });
    // 评价标题下面提示语
    _topTiplab = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.topView addSubview:iv];
        iv.font = SobotFont12;
        iv.textAlignment = NSTextAlignmentCenter;
        iv.numberOfLines = 0;
        iv.textColor = [ZCUIKitTools zcgetSatisfactionColor];
        iv.text = SobotKitLocalString(@"提交评价后会话将结束");
        [self.topView addConstraint:sobotLayoutMarginTop(6, iv, self.titlelab)];
        [self.topView addConstraint:sobotLayoutPaddingLeft(50, iv, self.topView)];
        [self.topView addConstraint:sobotLayoutPaddingRight(-50, iv, self.topView)];
//        [self.topView addConstraint:sobotLayoutEqualHeight(12, iv, NSLayoutRelationEqual)];
        iv.hidden = YES;
        iv;
    });
    
    [self.topView removeConstraint:self.titleLabPT];
    [self.topView removeConstraint:self.titleLabEH];
    if (self.evaluateModel.isCloseAfterEvaluation && self.evaluateModel.isEvalutionAdmin) {
        self.titlelab.text = SobotKitLocalString(@"服务评价");
        if (type == 1) {
            self.titlelab.text = SobotKitLocalString(@"机器人客服评价");
        }
        self.titleLabEH = sobotLayoutEqualHeight(18, self.titlelab, NSLayoutRelationEqual);
        [self.topView addConstraint:self.titleLabEH];
        self.titleLabPT = sobotLayoutPaddingTop(10, self.titlelab, self.topView);
        [self.topView addConstraint:self.titleLabPT];
        self.topTiplab.hidden = NO;
        // 显示提示 计算高度
        CGFloat th = [SobotUITools getHeightContain:SobotKitLocalString(@"提交评价后会话将结束") font:SobotFont12 Width:viewWidth-100];
        if (th > 12) {
            self.topViewEH.constant = 60 + th -12 +5;
            topViewH = 60 + th -12 +5;
        }
    }else{
        self.titleLabEH = sobotLayoutEqualHeight(20, self.titlelab, NSLayoutRelationEqual);
        [self.topView addConstraint:self.titleLabEH];
        self.titleLabPT = sobotLayoutPaddingTop(20, self.titlelab, self.topView);
        [self.topView addConstraint:self.titleLabPT];
        // 标题只有一行
        if(type == 2){
            self.titlelab.text = SobotKitLocalString(@"机器人客服评价");
        }else{
            self.titlelab.text = SobotKitLocalString(@"服务评价");
        }
    }

    UIView *iv = [[UIView alloc]init];
    [self.topView addSubview:iv];
    iv.backgroundColor = [ZCUIKitTools zcgetCommentButtonLineColor];
    [self.topView addConstraint:sobotLayoutPaddingLeft(0, iv, self.topView)];
    [self.topView addConstraint:sobotLayoutPaddingRight(0, iv, self.topView)];
    [self.topView addConstraint:sobotLayoutPaddingBottom(-0.5, iv, self.topView)];
    [self.topView addConstraint:sobotLayoutEqualHeight(0.5, iv, NSLayoutRelationEqual)];

#pragma mark - 顶部view end
    if (type != !self.evaluateModel.isEvalutionAdmin) {
        self.evaluateModel.isOpenProblemSolving = YES;
    }
    
    if (type == SatisfactionTypeLeaveReply) {
        self.evaluateModel.isOpenProblemSolving = NO;
    }
    
#pragma mark - 中间动态部分
    _backGroundView = ({
        UIScrollView *iv = [[UIScrollView alloc]init];
        iv.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
//        iv.backgroundColor = [UIColor greenColor];
        [self.sheetView addSubview:iv];
        self.backGroundViewEH = sobotLayoutEqualHeight(ZCMaxHeight, iv, NSLayoutRelationEqual);
        [self.sheetView addConstraint:self.backGroundViewEH];
        [self.sheetView addConstraint:sobotLayoutMarginTop(0, iv, self.topView)];
        [self.sheetView addConstraint:sobotLayoutPaddingLeft(0, iv, self.sheetView)];
        [self.sheetView addConstraint:sobotLayoutPaddingRight(0, iv, self.sheetView)];
        iv;
    });
    

    
#pragma mark -- 提交按钮是最下面的位置固定
    _commitBtn = ({
        UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.backGroundView addSubview:iv];
        [iv setTitle:SobotKitLocalString(@"提交") forState:UIControlStateNormal];
        iv.titleLabel.font = SobotFontBold17;
        [iv setTitleColor:[ZCUIKitTools zcgetSubmitEvaluationButtonColor] forState:UIControlStateNormal];
        [iv setBackgroundColor:[ZCUIKitTools zcgetServerConfigBtnBgColor]];
        [iv addTarget:self action:@selector(sendComment:) forControlEvents:UIControlEventTouchUpInside];
        iv.layer.cornerRadius = 22.0f;
        iv.layer.masksToBounds = YES;
        [self.sheetView addSubview:iv];
        [self.sheetView addConstraint:sobotLayoutEqualCenterX(0, iv, self.sheetView)];
//        [self.sheetView addConstraint:sobotLayoutEqualWidth(minw - 40, iv, NSLayoutRelationEqual)];
        [self.sheetView addConstraint:sobotLayoutPaddingLeft(20, iv, self.sheetView)];
        [self.sheetView addConstraint:sobotLayoutPaddingRight(-20, iv, self.sheetView)];
        [self.sheetView addConstraint:sobotLayoutEqualHeight(44, iv, NSLayoutRelationEqual)];
        [self.sheetView addConstraint:sobotLayoutMarginTop(30, iv, self.backGroundView)];
        iv;
    });
    
#pragma mark -- 有暂不评价 显示到最下方
    _canReturnBtn = ({
        UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.sheetView addSubview:iv];
        [iv setTitle:SobotKitLocalString(@"暂不评价") forState:0];
        [iv.titleLabel setFont:SobotFont14];
        [iv setTitleColor:[ZCUIKitTools zcgetSatisfactionTextSelectedColor] forState:0];
        [iv addTarget:self action:@selector(itemMenuClick:) forControlEvents:UIControlEventTouchUpInside];
        iv.tag = RobotChangeTag3;
        [self.sheetView addConstraint:sobotLayoutMarginTop(10, iv, self.commitBtn)];
        [self.sheetView addConstraint:sobotLayoutPaddingRight(-20, iv, self.sheetView)];
        [self.sheetView addConstraint:sobotLayoutPaddingLeft(20, iv, self.sheetView)];
        [self.sheetView addConstraint:sobotLayoutEqualHeight(20, iv, NSLayoutRelationEqual)];
        iv.hidden = YES;
        iv;
    });
    
    if ((type == SatisfactionTypeBack || type == SatisfactionTypeClose) && [ZCUICore getUICore].kitInfo.canBackWithNotEvaluation) {
        self.canReturnBtn.hidden = NO;
        botH = botH + 30;
    }
    
    
    _nicklab = ({
        UILabel *iv = [[UILabel alloc]init];
        iv.font = SobotFont15;
        iv.numberOfLines = 0;
        iv.textColor = UIColorFromKitModeColor(SobotColorTextMain);
        iv.backgroundColor = [UIColor whiteColor];
        iv.text = [NSString stringWithFormat:@"%@ %@",sobotConvertToString(self.evaluateModel.name),SobotKitLocalString(@"是否解决了您的问题？")];
        iv.textAlignment = NSTextAlignmentCenter;
        [self.backGroundView addSubview:iv];
        self.nicklabEH = sobotLayoutEqualHeight(21, iv, NSLayoutRelationEqual);
        [self.backGroundView addConstraint:sobotLayoutEqualCenterX(0, iv, self.backGroundView)];
        [self.backGroundView addConstraint:sobotLayoutEqualWidth(viewWidth-30, iv, NSLayoutRelationEqual)];
        self.nicklabPT = sobotLayoutPaddingTop(30, iv, self.backGroundView);
        // 计算最终高度
        CGFloat nicklabH = [SobotUITools getHeightContain:SobotKitLocalString(@"是否解决了您的问题？") font:SobotFont15 Width:viewWidth-30];
        if (nicklabH <21) {
            nicklabH = 21;
        }else{
            self.nicklabEH.constant = nicklabH;
        }
        nickH = nicklabH -21;
        [self.backGroundView addConstraint:self.nicklabEH];
        [self.backGroundView addConstraint:self.nicklabPT];
        iv.hidden = YES;
        iv;
    });

    
    // 是否显示 已解决 和 未解决 按钮
    if (self.evaluateModel.isOpenProblemSolving) {
        self.nicklab.hidden = NO;
        // 先看已解决和未解决按钮的文案的长度，长度较长 上下排列，默认左右对称排列
        CGFloat w1 = [SobotUITools getWidthContain:SobotKitLocalString(@"已解决") font:SobotFont14 Height:36];
        CGFloat w2 = [SobotUITools getWidthContain:SobotKitLocalString(@"未解决") font:SobotFont14 Height:36];

        CGFloat w = w1>w2?w1:w2;
        
        if(w > 70){
            isTwoHight = YES;
            MH = MH + 62;
            if(w + 27 > ScreenWidth - 40){
                w = ScreenWidth - 40 ;
            }
        }
        
        // 已解决 未解决
        for (int i=0; i<2; i++) {
            if(i==0){
                _robotChangeBtn1 = ({
                    UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
                    [self.backGroundView addSubview:iv];
                    iv.tag=RobotChangeTag1;
                    iv.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 7);
                    [iv setImage:SobotKitGetImage(@"zcicon_useful_nol") forState:UIControlStateNormal];
                    [iv setImage:SobotKitGetImage(@"zcicon_useful_sel") forState:UIControlStateSelected];
                    [iv setImage:SobotKitGetImage(@"zcicon_useful_sel") forState:UIControlStateHighlighted];
                    iv.selected=NO;
                    iv.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
                    [iv setTitle:SobotKitLocalString(@"已解决") forState:UIControlStateNormal];
                    
                    [iv.titleLabel setFont:[ZCUIKitTools zcgetListKitTitleFont]];
                    [iv setTitleColor:[ZCUIKitTools zcgetNoSatisfactionTextColor] forState:UIControlStateNormal];
                    [iv setTitleColor:[ZCUIKitTools zcgetSatisfactionTextSelectedColor] forState:UIControlStateHighlighted];
                    [iv setTitleColor:[ZCUIKitTools zcgetSatisfactionTextSelectedColor]  forState:UIControlStateSelected];
                    [iv addTarget:self action:@selector(robotServerButton:) forControlEvents:UIControlEventTouchUpInside];
                    [iv setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
                    [iv setBackgroundColor:[ZCUIKitTools zcgetSatisfactionBgSelectedColor]];
                    iv.layer.cornerRadius = 18.0f;
                    if([SobotUITools getSobotThemeMode] != SobotThemeMode_Dark){
                        iv.layer.shadowOpacity= 1;
                        iv.layer.shadowColor = UIColorFromModeColorAlpha(SobotColorTextMain, 0.15).CGColor;
                        iv.layer.shadowOffset = CGSizeZero;//投影偏移
                        iv.layer.shadowRadius = 2;
                    }
                    iv.titleLabel.font = SobotFont14;
                    if(sobotIsRTLLayout()){
                        [iv setImageEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 3)];
                    }
                    
                    if(isTwoHight){
                        NSString *title = [NSString stringWithFormat:@"%@                                    ",SobotKitLocalString(@"已解决")];
                        [iv setTitle:title forState:UIControlStateNormal];
                        iv.imageEdgeInsets = UIEdgeInsetsMake(0, 7, 0, 7);
                        iv.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 7);
                        iv.titleLabel.textAlignment = NSTextAlignmentLeft;
                        [self.backGroundView addConstraint:sobotLayoutMarginTop(20, iv, self.nicklab)];
                        [self.backGroundView addConstraint:sobotLayoutEqualHeight(36, iv, NSLayoutRelationEqual)];
                        [self.backGroundView addConstraint:sobotLayoutPaddingLeft(ScreenWidth/2 -w/2, iv, self.backGroundView)];
//                        [self.backGroundView addConstraint:sobotLayoutPaddingRight(-36, iv, self.backGroundView)];
                        [self.backGroundView addConstraint:sobotLayoutEqualWidth(w, iv, NSLayoutRelationEqual)];
                    }else{
                        [self.backGroundView addConstraint:sobotLayoutMarginTop(20, iv, self.nicklab)];
                        [self.backGroundView addConstraint:sobotLayoutEqualHeight(36, iv, NSLayoutRelationEqual)];
                        [self.backGroundView addConstraint:sobotLayoutEqualWidth(97, iv, NSLayoutRelationEqual)];
                        [self.backGroundView addConstraint:sobotLayoutEqualCenterX(- 15 -97/2 , iv, self.backGroundView)];
                    }
                    
                    iv;
                });
            }else{
                _robotChangeBtn2 = ({
                    UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
                    [self.backGroundView addSubview:iv];
                    iv.tag=RobotChangeTag2;
                    iv.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 7);
                    [iv setImage:[SobotUITools getSysImageByName:SobotKitLocalString(@"zcicon_useless_nol")] forState:UIControlStateNormal];
                    [iv setImage:[SobotUITools getSysImageByName:SobotKitLocalString(@"zcicon_useless_sel")] forState:UIControlStateSelected];
                    [iv setImage:[SobotUITools getSysImageByName:SobotKitLocalString(@"zcicon_useless_sel")] forState:UIControlStateHighlighted];
                    iv.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
                    [iv setTitle:SobotKitLocalString(@"未解决") forState:UIControlStateNormal];
                    iv.selected=NO;
                    if(sobotIsRTLLayout()){
                        [iv setImageEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 3)];
                    }
                    [iv.titleLabel setFont:[ZCUIKitTools zcgetListKitTitleFont]];
                    [iv setTitleColor:[ZCUIKitTools zcgetNoSatisfactionTextColor] forState:UIControlStateNormal];
                    [iv setTitleColor:[ZCUIKitTools zcgetSatisfactionTextSelectedColor] forState:UIControlStateHighlighted];
                    [iv setTitleColor:[ZCUIKitTools zcgetSatisfactionTextSelectedColor]  forState:UIControlStateSelected];
                    [iv addTarget:self action:@selector(robotServerButton:) forControlEvents:UIControlEventTouchUpInside];
                    [iv setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
                    [iv setBackgroundColor:[ZCUIKitTools zcgetSatisfactionBgSelectedColor]];
                    iv.layer.cornerRadius = 18.0f;
                    if([SobotUITools getSobotThemeMode] != SobotThemeMode_Dark){
                        iv.layer.shadowOpacity= 1;
                        iv.layer.shadowColor = UIColorFromModeColorAlpha(SobotColorTextMain, 0.15).CGColor;
                        iv.layer.shadowOffset = CGSizeZero;//投影偏移
                        iv.layer.shadowRadius = 2;
                    }
                    iv.titleLabel.font = SobotFont14;
                    
                    if(isTwoHight){
                        iv.imageEdgeInsets = UIEdgeInsetsMake(0, 7, 0, 7);
                        iv.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 7);
                        NSString *title = [NSString stringWithFormat:@"%@                                    ",SobotKitLocalString(@"未解决")];
                        [iv setTitle:title forState:UIControlStateNormal];
                        iv.titleLabel.textAlignment = NSTextAlignmentLeft;
                        [self.backGroundView addConstraint:sobotLayoutMarginTop(7, iv, _robotChangeBtn1)];
                        [self.backGroundView addConstraint:sobotLayoutEqualHeight(36, iv, NSLayoutRelationEqual)];
                        [self.backGroundView addConstraint:sobotLayoutPaddingLeft(ScreenWidth/2-w/2, iv, self.backGroundView)];
//                        [self.backGroundView addConstraint:sobotLayoutPaddingRight(-36, iv, self.backGroundView)];
                        [self.backGroundView addConstraint:sobotLayoutEqualWidth(w, iv, NSLayoutRelationEqual)];
                    }else{
                        [self.backGroundView addConstraint:sobotLayoutMarginTop(20, iv, self.nicklab)];
                        [self.backGroundView addConstraint:sobotLayoutEqualHeight(36, iv, NSLayoutRelationEqual)];
                        [self.backGroundView addConstraint:sobotLayoutEqualWidth(97, iv, NSLayoutRelationEqual)];
                        [self.backGroundView addConstraint:sobotLayoutEqualCenterX( 15 +97/2 , iv, self.backGroundView)];
                    }
                    
                    iv;
                });
            }
            if (self.evaluateModel.isResolve == 0) {
                self.robotChangeBtn2.selected = YES;
                curResolve = 1;
            }else if (self.evaluateModel.isResolve == 1) {
                self.robotChangeBtn1.selected = YES;
                curResolve = 0;
            }else{
                curResolve = -1;
                self.robotChangeBtn2.selected = NO;
                self.robotChangeBtn1.selected = NO;
                
            }
        }
        SCH = 108 + (isTwoHight? 62 :0);// 添加完机器人是否已解决按钮之后的高度
        
    }
        
#pragma mark -- 星星
    if (type == SatisfactionTypeLeaveReply || self.evaluateModel.isEvalutionAdmin) {
        if (!self.evaluateModel.isOpenProblemSolving) {
            [self.backGroundView removeConstraint:self.nicklabEH];
            [self.backGroundView removeConstraint:self.nicklabPL];
            [self.backGroundView removeConstraint:self.nicklabPR];
            [self.backGroundView removeConstraint:self.nicklabPT];
            // 人工时 不显示是否已解决按钮  这里只是为了间隙不在创建新的控件来间隔
            self.nicklabEH = sobotLayoutEqualHeight(21, self.nicklab, NSLayoutRelationEqual);
            self.nicklabPL = sobotLayoutPaddingLeft(0, self.nicklab, self.backGroundView);
            self.nicklabPR = sobotLayoutPaddingRight(0, self.nicklab, self.backGroundView);
            self.nicklabPT = sobotLayoutPaddingTop(0, self.nicklab, self.backGroundView);
            self.nicklab.text = @"";
            [self.backGroundView addConstraint:self.nicklabEH];
            [self.backGroundView addConstraint:self.nicklabPT];
            [self.backGroundView addConstraint:self.nicklabPR];
            [self.backGroundView addConstraint:self.nicklabPL];
            // 不显示已解决 未解决
            self.nickLineView.hidden = YES;
            SCH = 21;
        }else if (self.evaluateModel.isOpenProblemSolving){
            // 如果显示已解决、未解决，添加一条线
            self.nickLineView.hidden = NO;
            SCH = 108;// 显示已解决和未解决的之后的高度
        }
        
        if (type == SatisfactionTypeLeaveReply) {
            // 留言不显示已解决未解决
//            self.nicklabEH = sobotLayoutEqualHeight(0, self.nicklab, NSLayoutRelationEqual);
//            self.nicklabPL = sobotLayoutPaddingLeft(0, self.nicklab, self.backGroundView);
//            self.nicklabPR = sobotLayoutPaddingRight(0, self.nicklab, self.backGroundView);
//            self.nicklabPT = sobotLayoutPaddingTop(0, self.nicklab, self.backGroundView);
//            [self.backGroundView addConstraint:self.nicklabEH];
//            [self.backGroundView addConstraint:self.nicklabPT];
//            [self.backGroundView addConstraint:self.nicklabPR];
//            [self.backGroundView addConstraint:self.nicklabPL];
            // 没有21 的高度间隙
            SCH = SCH - 21;
        }
        
        // 星星或者1-10
        float ratingView_margin_top = 0;
        if (Sobot_IsPortrait) {
            ratingView_margin_top = 20;
        }else{
            ratingView_margin_top = 10;
        }
        CGFloat ratingWidth = (scoreFlag==0)?250:280;
        CGFloat ratingHegith = (scoreFlag==0)?40:59+29;
        _ratingView = ({
            ZCUIRatingView *iv = [[ZCUIRatingView alloc]init];
            [self.backGroundView addSubview:iv];
            iv.frame = CGRectMake(0, 0, ratingWidth, ratingHegith);// 先现在默认值 内部子视图使用
            [self.backGroundView addConstraint:sobotLayoutEqualHeight(ratingHegith, iv, NSLayoutRelationEqual)];
            [self.backGroundView addConstraint:sobotLayoutEqualWidth(ratingWidth, iv, NSLayoutRelationEqual)];
//            if ((type == SatisfactionTypeInvite || type == self.evaluateModel.isEvalutionAdmin) && ) {
//                [self.backGroundView addConstraint:sobotLayoutMarginTop(ratingView_margin_top, iv, self.robotChangeBtn2)];
//            }else{
//                [self.backGroundView addConstraint:sobotLayoutMarginTop(ratingView_margin_top, iv, self.nicklab)];
//            }
            if(self.evaluateModel.isOpenProblemSolving){
                [self.backGroundView addConstraint:sobotLayoutMarginTop(ratingView_margin_top, iv, self.robotChangeBtn2)];
            }else{
                [self.backGroundView addConstraint:sobotLayoutMarginTop(ratingView_margin_top, iv, self.nicklab)];
            }
            [self.backGroundView addConstraint:sobotLayoutEqualCenterX(0, iv, self.backGroundView)];
            [iv setImagesDeselected:@"zcicon_star_unsatisfied" partlySelected:@"zcicon_star_satisfied" fullSelected:@"zcicon_star_satisfied" count:(scoreFlag==0)?5:10 andDelegate:self];
            iv.userInteractionEnabled = YES;
//            [iv setBackgroundColor:[UIColor redColor]];
            
            iv;
        });
        self.userInteractionEnabled = YES;
        self.isChangePostion =NO;
        // 设置星评的默认值
        if (self.evaluateModel.type == SatisfactionTypeInvite) {
            if(self.evaluateModel.rating > 0){
                [_ratingView displayRating:self.evaluateModel.rating];
            }else{
                
                // 默认0星应该选择1
                if(self.evaluateModel.isOpenDefaultStar){
                    [_ratingView displayRating:(float)(defaultStar)];
                }else{
                    self.evaluateModel.rating = 0;
                }
            }
        }else{
            [_ratingView displayRating:defaultStar];
        }
        if(!self.evaluateModel.isOpenDefaultStar){
            self.isChangePostion = YES;
        }
        
        SCH = SCH + ratingView_margin_top + ratingHegith;// 添加完星星 或者 1-10之后的高度
        
        _tiplab = ({
            UILabel *iv = [[UILabel alloc]init];
            [self.backGroundView addSubview:iv];
            iv.textAlignment = NSTextAlignmentCenter;
            iv.font = SobotFont12;
            iv.textColor = [ZCUIKitTools zcgetScoreExplainTextColor];
            [self.backGroundView addConstraint:sobotLayoutMarginTop(24, iv, self.ratingView)];
            [self.backGroundView addConstraint:sobotLayoutEqualCenterX(0, iv, self.backGroundView)];
            [self.backGroundView addConstraint:sobotLayoutEqualWidth(minw, iv, NSLayoutRelationEqual)];
            self.titleLabEH = sobotLayoutEqualHeight(20, iv, NSLayoutRelationEqual);
            [self.backGroundView addConstraint:self.titleLabEH];
            iv;
        });
    
        SCH = SCH + 44;// 添加完满意标签之后的高度
        SSCH = SCH;
        // 满意度标签赋值
        if (type == SatisfactionTypeLeaveReply) {
            // 先处理排序
            if (self.evaluateModel.ticketScoreInfooList.count && self.evaluateModel.ticketScoreInfooList != nil && ![ZCUICore getUICore].kitInfo.hideManualEvaluationLabels) {
                NSComparator cmptr = ^(ZCLibSatisfaction *obj1, ZCLibSatisfaction *obj2){
                    if (obj1.score  > obj2.score) {
                        return (NSComparisonResult)NSOrderedDescending;
                    }
                    if (obj1.score  < obj2.score ) {
                        return (NSComparisonResult)NSOrderedAscending;
                    }
                    return (NSComparisonResult)NSOrderedSame;
                };
                NSArray *sorArray = [self.evaluateModel.ticketScoreInfooList sortedArrayUsingComparator:cmptr];
                int index = (int)_ratingView.rating -1;
                if(index < 0){
                    index = 0;
                }
                ZCLibSatisfaction *item = sorArray[index];
                _tiplab.text =  item.scoreExplain;
            }
            if([ZCUICore getUICore].kitInfo.hideManualEvaluationLabels){
                [self.backGroundView removeConstraint:self.tiplabEH];
                self.tiplabEH = sobotLayoutEqualHeight(0, self.tiplab, NSLayoutRelationEqual);
                [self.backGroundView addConstraint:self.tiplabEH];
                SCH = SCH -32;// 不显人工满意度标签
            }
        }else{
            if (_listArray.count && _listArray != nil && _ratingView.rating > 0) {
                ZCLibSatisfaction *item = _listArray[(int)_ratingView.rating -1];
                _tiplab.text = item.scoreExplain;
            }
        }
        // 解决显示延迟问题
        [self createItemViewsWithType:1];
    }
    
#pragma mark -- 2.7.4版本新增 留言详情页评价 先计算是否添加 评价输入框，不在时时点击添加
    if (self.evaluateModel.type == SatisfactionTypeLeaveReply && self.evaluateModel.textFlag) {
        [self.backGroundView removeConstraint:self.textViewMT];
        self.textViewMT = sobotLayoutMarginTop(20, self.textView, self.tiplab);
        [self.backGroundView addConstraint:self.textViewMT];
        _textView.placeholder = [NSString stringWithFormat:@"%@ (%@)",SobotKitLocalString(@"欢迎给我们的服务提建议~"),SobotKitLocalString(@"选填")];
    }

    if (!self.evaluateModel.isEvalutionAdmin) {
        // 更新中间部分的约束
        [self.sheetView removeConstraint:self.backGroundViewEH];
        self.backGroundViewEH = sobotLayoutEqualHeight(SCH, self.backGroundView, NSLayoutRelationEqual);
        [self.sheetView addConstraint:self.backGroundViewEH];
        [self.backGroundView setContentSize:CGSizeMake(minw, SCH)];
        // 更新最后的高度
        [self removeConstraint:self.sheetViewEH];
        self.sheetViewEH = sobotLayoutEqualHeight(topViewH + botH + XBottomBarHeight + SCH + nickH, self.sheetView, NSLayoutRelationEqual);
        [self addConstraint:self.sheetViewEH];
    }else{
        // 人工
        CGFloat pointH = SCH ;
        if (SCH > SSCH + 92 + 30 + 20 +74) {
            pointH = SSCH + 92 + 30 + 20 +74 ;
        }
        if (ScreenWidth > ScreenHeight) {
            if (SCH > 45 + SSCH + 30 ) {
                pointH = 45 + SSCH + 30 ;
            }
            
        }
        // 更新约束
        [self.sheetView removeConstraint:self.backGroundViewEH];
        // 中间最大的高度
        if (pointH  +(topViewH  + botH + XBottomBarHeight)>= ScreenHeight) {
            pointH = ScreenHeight - (topViewH + botH + XBottomBarHeight);
        }
        self.backGroundViewEH = sobotLayoutEqualHeight(pointH, self.backGroundView, NSLayoutRelationEqual);
        [self.sheetView addConstraint:self.backGroundViewEH];
        
        [self removeConstraint:self.sheetViewEH];
        CGFloat shvH = pointH + topViewH  + botH + XBottomBarHeight;
        if (shvH >ScreenHeight) {
            shvH = ScreenHeight;//最大高度
        }
        self.sheetViewEH = sobotLayoutEqualHeight(shvH, self.sheetView, NSLayoutRelationEqual);
        [self addConstraint:_sheetViewEH];
        [self.backGroundView setContentSize:CGSizeMake(viewWidth, SCH+nickH)];
    }
}

#pragma mark - 创建中间部分子视图 1 人工评价模式下首次构建  2 点了是否已解决按钮事件
-(void)createItemViewsWithType:(SatisfactionType)type{
    // 显示标签
    if(self.item){
        [self.item removeFromSuperview];
        [self.textView removeFromSuperview];
        [self.stLable removeFromSuperview];
    }
    if (type == 2) {
        SCH = 0;
    }
    // 2.8.0隐藏掉
    // 是否有以下情况label 以及Btn
    _stLable = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.backGroundView addSubview:iv];
        iv.textColor = UIColorFromKitModeColor(SobotColorTextSub);
        iv.font = SobotFont15;
        iv.textAlignment = NSTextAlignmentCenter;
//        [iv setBackgroundColor:[UIColor yellowColor]];
        [self.backGroundView addConstraint:sobotLayoutPaddingLeft(0, iv, self.backGroundView)];
        [self.backGroundView addConstraint:sobotLayoutEqualCenterX(0, iv, self.backGroundView)];
        self.stLableEH = sobotLayoutEqualHeight(0, iv, NSLayoutRelationEqual);
        [self.backGroundView addConstraint:self.stLableEH];
        if (!sobotIsNull(self.tiplab)) {
            self.stLableMT = sobotLayoutMarginTop(0, iv, self.tiplab);
        }else{
            self.stLableMT = sobotLayoutMarginTop(0, iv, self.robotChangeBtn2);
            SCH = SCH + MH;// 添加完未解决按钮之后的高度
        }
        [self.backGroundView addConstraint:self.stLableMT];
        iv.hidden = YES;
        iv;
    });
    
    // 这里区分是否是人工评价 人工评价是从满意度提示语下面开始布局 、机器人是从 是否已解决的按钮的下方开始布局
    [self.backGroundView removeConstraint:self.stLableMT];
    
    // 如果当前是0分，说明未选中任何评分
    self.titleLabEH.constant = 20;
    if (self.evaluateModel.isEvalutionAdmin) {
        if ([ZCUICore getUICore].kitInfo.hideManualEvaluationLabels || _ratingView.rating == 0) {
            // 隐藏星星提示语
            self.tiplab.text = @"";
            //  去掉人工评价5星标签提醒
            self.stLableMT = sobotLayoutMarginTop(-20, self.stLable, self.tiplab);
            SCH = SCH -20;
            self.titleLabEH.constant = 0;
        }else{
            self.stLableMT = sobotLayoutMarginTop(0, self.stLable, self.tiplab);
        }
    }else{
        self.stLableMT = sobotLayoutMarginTop(0, self.stLable, self.robotChangeBtn2);
        SCH =  MH;// 机器人评价 添加完未解决按钮之后的高度
    }
    [self.backGroundView addConstraint:self.stLableMT];
    _item = ({
        ZCItemView *iv = [[ZCItemView alloc]init];
        iv.exclusiveTouch = YES;
        iv.multipleTouchEnabled = YES;
        self.backGroundView.multipleTouchEnabled = YES;
        self.backGroundView.exclusiveTouch = YES;
//        CGFloat minW = MIN(viewWidth, viewHeight);
        iv.frame = CGRectMake(0, 20, viewWidth, 0); // 先设置默认大小 子视图创建需要
//        iv.backgroundColor = [UIColor purpleColor];
        [self.backGroundView addSubview:iv];
        self.itemEH = sobotLayoutEqualHeight(0, iv, NSLayoutRelationEqual);
        [self.backGroundView addConstraint:self.itemEH];
        [self.backGroundView addConstraint:sobotLayoutEqualCenterX(0, iv, self.backGroundView)];
        [self.backGroundView addConstraint:sobotLayoutEqualWidth(viewWidth, iv, NSLayoutRelationEqual)];
//        [self.backGroundView addConstraint:sobotLayoutPaddingLeft(20, iv, self.backGroundView)];
//        [self.backGroundView addConstraint:sobotLayoutPaddingRight(-20, iv, self.backGroundView)];
        self.itemMT = sobotLayoutMarginTop(30, iv, self.stLable);
        [self.backGroundView addConstraint:self.itemMT];
        iv;
    });
    
    if (!self.evaluateModel.isEvalutionAdmin) {
        [self.backGroundView removeConstraint:self.itemMT];
        self.itemMT = sobotLayoutMarginTop(30, self.item, self.stLable);
        [self.backGroundView addConstraint:self.itemMT];
        SCH = SCH + 30;// 间距
    }else{
        // 人工评价时
        if (scoreFlag) {
            if (self.evaluateModel.type >2 &&(_listArray.count > 0 && _listArray != nil) && (_ratingView.rating>0 && _ratingView.rating<= 11) && _listArray.count >= _ratingView.rating) {
                ZCLibSatisfaction * model = _listArray[(int)_ratingView.rating - 1];
                // 设置是否必填标记
                _isMustAdd = [model.isTagMust boolValue];
                _isInputMust = [model.isInputMust boolValue];
                if (![@"" isEqual: sobotConvertToString(model.labelName)]) {
                    [self.backGroundView removeConstraint:self.itemMT];
                    self.itemMT = sobotLayoutMarginTop(15, self.item, self.stLable);
                    [self.backGroundView addConstraint:self.itemMT];
                    SCH = SCH + 15;
                }
            }
        } else {
            if (self.evaluateModel.type >2 &&(_listArray.count > 0 && _listArray != nil) && (_ratingView.rating>0 && _ratingView.rating<= 5) && _listArray.count >= _ratingView.rating) {
                ZCLibSatisfaction * model = _listArray[(int)_ratingView.rating - 1];
                // 设置是否必填标记
                _isMustAdd = [model.isTagMust boolValue];
                _isInputMust = [model.isInputMust boolValue];
                if (![@"" isEqual: sobotConvertToString(model.labelName)]) {
                    [self.backGroundView removeConstraint:self.itemMT];
                    self.itemMT = sobotLayoutMarginTop(15, self.item, self.stLable);
                    [self.backGroundView addConstraint:self.itemMT];
                    SCH = SCH + 15;
                }
            }
        }
    }
    
    // 数据源
    NSArray *items= @[];
    if(!self.evaluateModel.isEvalutionAdmin && self.evaluateModel.type != SatisfactionTypeLeaveReply){
        // 隐藏机器人评价标签
        if(![ZCUICore getUICore].kitInfo.hideRototEvaluationLabels){
//            _config.robotCommentTitle = @"答非所问,理解能力差,问题不能回答,不礼貌,答非所问,理解能力差,问题不能回答,不礼貌";
            items = [_config.robotCommentTitle componentsSeparatedByString:@","];
        }
    }
    
    // 人工评价时便利
    if(self.evaluateModel.isEvalutionAdmin){
        items = @[];// 调用接口不成功的时候用
        // 2.8.9 根据配置隐藏人工评价标签
        if (_listArray.count >0 && _listArray !=nil && ![ZCUICore getUICore].kitInfo.hideManualEvaluationLabels){
            // 接口返回的数据
            if (_ratingView.rating>0 && _listArray.count >= _ratingView.rating) {
                ZCLibSatisfaction * model = _listArray[(int)_ratingView.rating -1];
                if (![@"" isEqual: sobotConvertToString(model.labelName)]) {
                    items = [model.labelName componentsSeparatedByString:@"," ];
                    if(sobotConvertToString(model.tagTips).length > 0){
                        [_stLable setText:model.tagTips];
                        [self.backGroundView removeConstraint:self.stLableEH];
                        self.stLableEH = sobotLayoutEqualHeight(30, self.stLable, NSLayoutRelationEqual);
                        [self.backGroundView addConstraint:self.stLableEH];
                        SCH = SCH + 30;
                        _stLable.hidden = NO;
                        [self.backGroundView removeConstraint:self.itemEH];
                        self.itemEH = sobotLayoutEqualHeight(0, self.item, NSLayoutRelationEqual);
                        [self.backGroundView addConstraint:self.itemEH];
                    }
                }
            }
        }
    }
    
    //邀请评价时，可能已经默认选择了标签，此处给默认值
    if(self.evaluateModel.type == SatisfactionTypeInvite && sobotConvertToString([ZCUICore getUICore].inviteSatisfactionCheckLabels).length > 0){
        [self.item InitDataWithArray:items withCheckLabels:sobotConvertToString([ZCUICore getUICore].inviteSatisfactionCheckLabels)];
    }else{
        [self.item InitDataWithArray:items];
    }
    CGFloat itemHeight = [self.item getHeightWithArray:items];
    if (itemHeight == 0) {
        // 没有item
        [self.backGroundView removeConstraint:self.itemMT];
        self.itemMT = sobotLayoutMarginTop(0, self.item, self.stLable);
        [self.backGroundView addConstraint:self.itemMT];
    }
    
    [self.backGroundView removeConstraint:self.itemEH];
    self.itemEH = sobotLayoutEqualHeight(itemHeight, self.item, NSLayoutRelationEqual);
    [self.backGroundView addConstraint:self.itemEH];
    
    SCH = SCH + itemHeight ;
        
    if (self.textView) {
        [self.textView removeFromSuperview];
    }
    // 评价输入框
    _textView = ({
        ZCUIPlaceHolderTextView *iv = [[ZCUIPlaceHolderTextView alloc]init];
        [self.backGroundView addSubview:iv];
        [iv setContentInset:UIEdgeInsetsMake( 7, 12, 15, 15)];
        iv.backgroundColor = [UIColor clearColor];
        iv.backgroundColor = [UIColor redColor];
        iv.placeholder         = SobotKitLocalString(@"欢迎给我们的服务提建议~");
        iv.placeholderColor    = UIColorFromKitModeColor(SobotColorTextSub1);
        iv.placeholderLinkColor = UIColorFromKitModeColor(SobotColorTextSub1);
        iv.placeholederFont    = SobotFont14;
        iv.font                = SobotFont14;
        iv.delegate            = self;
        iv.textColor  = [ZCUIKitTools zcgetLeftChatTextColor];
        iv.backgroundColor =  [ZCUIKitTools zcgetLeftChatColor];
        [iv setContentInset:UIEdgeInsetsMake(0,5, 0, 5)];
        [self.backGroundView addConstraint:sobotLayoutEqualHeight(74, iv, NSLayoutRelationEqual)];
        [self.backGroundView addConstraint:sobotLayoutEqualCenterX(0, iv, self.backGroundView)];
//        CGFloat minw = MIN(viewWidth, viewHeight);
        self.textViewEW = sobotLayoutEqualWidth(viewWidth -50, iv, NSLayoutRelationEqual);
        [self.backGroundView addConstraint:self.textViewEW];
//        [self.backGroundView addConstraint:sobotLayoutPaddingLeft(20, iv, self.backGroundView)];
//        [self.backGroundView addConstraint:sobotLayoutPaddingRight(-20, iv, self.backGroundView)];
        self.textViewMT = sobotLayoutMarginTop(20, iv, self.item);
        [self.backGroundView addConstraint:self.textViewMT];
        iv;
    });
    
    SCH = SCH + 20 + 74;
    
    if (_listArray != nil && _listArray.count >0) {
        if (_ratingView.rating >0) {
            ZCLibSatisfaction * model = _listArray[(int)_ratingView.rating -1];
            if (![@"" isEqual:sobotConvertToString(model.inputLanguage)]) {
                if (_isInputMust) {
                    NSString *needStr = SobotKitLocalString(@"必填");
                    _textView.placeholder = [NSString stringWithFormat:@"(%@)%@",needStr,model.inputLanguage];
                }else{
                    _textView.placeholder = model.inputLanguage;
                }
            }
        }
    }
    if(_ratingView!=nil && _ratingView.rating == 0){
        _commitBtn.enabled = NO;
        _commitBtn.alpha = 0.8;
        _commitBtn.opaque = YES;
    }
    // 获取中间部分的最终高度
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark -- 提交评价
-(void)sendComment:(UIButton *) btn{
#pragma mark --- 工单留言页面的触发的评价
    if (self.evaluateModel.type == SatisfactionTypeLeaveReply) {
        NSString * textStr = @"";
        if (_textView.text!=nil && _textView.text.length > 0) {
            textStr = [sobotConvertToString(_textView.text) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        self->_commitBtn.enabled = false;
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"ticketId":sobotConvertToString(self.evaluateModel.ticketld),@"companyId":sobotConvertToString(_config.companyID),@"remark":textStr}];
        params[@"tag"] = [_item getSeletedTitle];
        // 0:5星,1:10分
        if (scoreFlag == 1) {
            [params setObject:[NSString stringWithFormat:@"%.0f",_ratingView.rating - 1] forKey:@"score"];
        } else {
            [params setObject:[NSString stringWithFormat:@"%.0f",_ratingView.rating] forKey:@"score"];
        }
        // 注意，isresolve此处的值是反的
        int curResolve = -1;
        if(_robotChangeBtn1.selected){
            curResolve = 0;
        }else if(_robotChangeBtn1.selected){
            curResolve = 1;
        }
        params[@"defaultQuestionFlag"] = [NSString stringWithFormat:@"%d",curResolve];
        __weak ZCUIEvaluateView * saveSelf = self;
        btn.enabled = false;
        [ZCLibServer postAddTicketSatisfactionWith:sobotConvertToString(self.evaluateModel.uid) dict:params start:^{
            
        } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
            @try{
                if (dict && [dict[@"data"][@"retCode"] isEqualToString:@"000000"]) {
                    // 刷新工单详情页面数据
                    if (saveSelf.delegate && [saveSelf.delegate respondsToSelector:@selector(actionSheetClickWithDic:)]) {
                        [saveSelf.delegate actionSheetClickWithDic:dict];
                    }
                }
                btn.enabled = false;
                // 隐藏弹出层
                [saveSelf dismissView:3];
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
            
        } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
            NSLog(@"%@",errorMessage);
            btn.enabled = false;
        }];
        
        return;
    }
    
    NSString *comment=_item!=nil ? [_item getSeletedTitle] : @"";
    if (self.evaluateModel.isEvalutionAdmin) {
        // 只在人工是做评定
        if ([@"" isEqualToString:comment] && _isMustAdd) {
            // 提示
            [[SobotToast shareToast] showToast:SobotKitLocalString(@"标签为必选") duration:1.0f view:self position:SobotToastPositionCenter];
            return;
        }
        // 如果是必传 去除两端的 空格+换行  是否为空
        if (_isInputMust && [@"" isEqualToString:[sobotConvertToString(_textView.text) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]) {
            [[SobotToast shareToast] showToast:SobotKitLocalString(@"建议为必填") duration:1.0f view:self position:SobotToastPositionCenter];
            return;
        }
    }
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
    [dict setObject:comment forKey:@"problem"];
    
    if(_config){
        [dict setObject:sobotConvertToString(_config.cid)  forKey:@"cid"];
        [dict setObject:sobotConvertToString(_config.uid)  forKey:@"userId"];
    }
    if (self.evaluateModel.type >2) {
        [dict setObject:[NSString stringWithFormat:@"%d",1] forKey:@"type"];
    }else{
        [dict setObject:[NSString stringWithFormat:@"%d",0] forKey:@"type"];
    }
    // 0:5星,1:10分
    if (scoreFlag) {
        [dict setObject:[NSString stringWithFormat:@"%.0f",_ratingView.rating - 1] forKey:@"source"];
    } else {
        [dict setObject:[NSString stringWithFormat:@"%.0f",_ratingView.rating] forKey:@"source"];
        [dict setObject:sobotConvertToString(_tiplab.text) forKey:@"scoreExplain"];
    }
    [dict setObject:[NSString stringWithFormat:@"%d",scoreFlag] forKey:@"scoreFlag"];

    NSString * textStr = @"";
    if (_textView.text!=nil ) {
        textStr = _textView.text;
    }
    // 去除两端的 空格+换行
    textStr = [sobotConvertToString(_textView.text) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [dict setObject:textStr forKey:@"suggest"];
    
    
    ZCSatisfactionConfig *config = [ZCUICore getUICore].satisfactionConfig;
    // 是否解决必填
    if(config.isQuestionMust && curResolve == -1){
        // 提示
        [[SobotToast shareToast] showToast:SobotKitLocalString(@"请选择是否解决了您的问题") duration:1.0f position:SobotToastPositionCenter];
        return;
    }
    // 是否解决必填
    if(_ratingView!=nil && _ratingView.rating == 0){
        // 提示
        [[SobotToast shareToast] showToast:[NSString stringWithFormat:@"%@%@",SobotKitLocalString(@"评分"),SobotKitLocalString(@"不能为空")] duration:1.0f position:SobotToastPositionCenter];
        return;
    }
    
    [dict setObject:[NSString stringWithFormat:@"%d",curResolve] forKey:@"isresolve"];
    // commentType  评价类型 主动评价 1 邀请评价0
    [dict setObject:[NSString stringWithFormat:@"%d",(self.evaluateModel.type == SatisfactionTypeInvite)] forKey:@"commentType"];
        
    btn.enabled = false;
    
    [ZCLibServer doComment:dict result:^(ZCNetWorkCode code, int status, NSString *msg) {
        
    }];
    
    
#pragma mark --- 普通评价提交的逻辑
    //  此处要做是否评价过人工或者是机器人的区分
    if ([ZCUICore getUICore].isOffline || [[ZCPlatformTools sharedInstance] getPlatformInfo].config.isArtificial) {
        // 评价过客服了，下次不能再评价人工了
        [ZCUICore getUICore].isEvaluationService = YES;
    }else{
        // 评价过机器人了，下次不能再评价了
        [ZCUICore getUICore].isEvaluationRobot = YES;
    }
    
    if(isKeyBoardShow){
        isKeyBoardShow=NO;
        [_textView resignFirstResponder];
    }
    
    btn.enabled = true;
    // 隐藏弹出层
    [self dismissView:3];
    // 客服主动邀请评价相关

//    int resolve = 0;
//    if (curResolve == 0) {
//        resolve = 2;
//    }else if(curResolve == 1){
//        resolve = 1;
//    }else{
//        resolve = 3;
//    }
    
    
    self.evaluateModel.isResolve = curResolve;
    self.evaluateModel.rating = _ratingView.rating;
    if (_delegate && [_delegate respondsToSelector:@selector(thankFeedBack:)]) {
        [self.delegate thankFeedBack:self.evaluateModel];
        return;
    }
    [ZCUICore getUICore].unknownWordsCount = 0;
}

#pragma 显示存在问题
-(void)showMenuItem:(BOOL) isShow{
    if (isShow) {
        [self createItemViewsWithType:2];
        // 设置偏移量
        CGFloat pointH = SCH;
        if (!self.evaluateModel.isEvalutionAdmin) {
            // 机器人 item + 已解决 + 输入框
            if (SCH > 92 + MH + 30 + 20 +74) {
                pointH = 92 + MH + 30 + 20 +74;
            }
            
            if (ScreenWidth > ScreenHeight) {
                if (SCH > 45 + MH + 30 ) {
                    pointH = 45 + MH + 30 ;
                }
            }
        }else{
            // 人工
            SCH = SCH + SSCH;
            pointH = SCH;
            if (SCH > SSCH + 92 + 30 + 20 +74) {
                pointH = SSCH + 92 + 30 + 20 +74;
            }
            if (ScreenWidth > ScreenHeight) {
                if (SCH > 45 + SSCH + 30 ) {
                    pointH = 45 + SSCH + 30 ;
                }
                if (pointH +(topViewH + botH + XBottomBarHeight) >= ScreenHeight) {
                    pointH = ScreenHeight - (topViewH + botH + XBottomBarHeight);
                }
            }
        }
        // 更新约束
        [self.sheetView removeConstraint:self.backGroundViewEH];
        self.backGroundViewEH = sobotLayoutEqualHeight(pointH, self.backGroundView, NSLayoutRelationEqual);
        [self.sheetView addConstraint:self.backGroundViewEH];
        [self removeConstraint:self.sheetViewEH];
        CGFloat shvH = pointH + topViewH + botH + XBottomBarHeight;
        self.sheetViewEH = sobotLayoutEqualHeight(shvH, self.sheetView, NSLayoutRelationEqual);
        [self addConstraint:_sheetViewEH];
        CGFloat minW = MIN(viewWidth, viewHeight);
        [self.backGroundView setContentSize:CGSizeMake(minW, SCH)];
        
    }else{
        // 不显示  标签  这里只有机器人模式下会
        [self.item removeFromSuperview];
        [self.textView removeFromSuperview];
        [self.stLable removeFromSuperview];
        SCH = MH; // 添加完 机器人未解决按钮之后的高度
        // 更新约束
        [self.sheetView removeConstraint:self.backGroundViewEH];
        self.backGroundViewEH = sobotLayoutEqualHeight(SCH, self.backGroundView, NSLayoutRelationEqual);
        [self.sheetView addConstraint:self.backGroundViewEH];
        [self removeConstraint:self.sheetViewEH];
        CGFloat shvH = SCH + topViewH + botH + XBottomBarHeight;
        self.sheetViewEH = sobotLayoutEqualHeight(shvH, self.sheetView, NSLayoutRelationEqual);
        [self addConstraint:_sheetViewEH];
        CGFloat minW = MIN(viewWidth, viewHeight);
        [self.backGroundView setContentSize:CGSizeMake(minW, SCH)];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }
    
}

#pragma mark -- 点击 已解决 未解决 事件
-(IBAction)robotServerButton:(UIButton *)sender{
    [sender setSelected:YES];
    if (sender.tag == RobotChangeTag1) {
        curResolve=0;
        UIButton *btn=(UIButton *)[self.backGroundView viewWithTag:RobotChangeTag2];
        [btn setSelected:NO];
        btn.layer.borderColor = UIColorFromModeColor(SobotColorBgLine).CGColor;
        // 不是人工
        if (self.evaluateModel.type <3 && !self.evaluateModel.isEvalutionAdmin) {
            // 机器人模式触发
            [self showMenuItem:NO];// 收起
        }
    }else if(sender.tag == RobotChangeTag2){
        curResolve=1;
        UIButton *btn=(UIButton *)[self.backGroundView viewWithTag:RobotChangeTag1];
        [btn setSelected:NO];
        btn.layer.borderColor = UIColorFromModeColor(SobotColorBgLine).CGColor;
        if (!self.evaluateModel.isEvalutionAdmin) {
            [self showMenuItem:YES];// 展开
        }
    }
}


#pragma mark --  关闭页面 不做评价  左上角关闭
- (void)zcDismissView:(UIButton*)sender{
    [self dismissView:1];
}

#pragma mark 暂不评价 跳过、取消
-(IBAction)itemMenuClick:(UIButton *)sender{
    [self dismissView:2];
}

/**
 *  反馈成功，做页面提醒
 *  @param isComment
 *  0  清理数据 并返回   1 评价完成后 结束会话 弹新会话键盘样式  2 弹感谢反馈  3 评价完成后 结束会话 弹新会话键盘样式  4 直接返回
 */
//-(void)closePage:(int) isComment{
//    // 跳过，直接退出
//    if(self.delegate && [self.delegate respondsToSelector:@selector(actionSheetClick:)]){
//        [self.delegate actionSheetClick:isComment];
//    }
//    self.delegate = nil;
//}

// 隐藏弹出层
- (void)shareViewDismiss:(UITapGestureRecognizer *) gestap{
    // 触摸的评分
    if(touchRating){
        touchRating=NO;
        return;
    }
    if(isKeyBoardShow){
        isKeyBoardShow=NO;
        [_textView resignFirstResponder];
        return;
    }
    CGPoint point = [gestap locationInView:self];
    CGRect f=self.sheetView.frame;
    if(point.x<f.origin.x || point.x>(f.origin.x+f.size.width) ||
       point.y<f.origin.y || point.y>(f.origin.y+f.size.height)){
        [self dismissView];
    }
}

// 页面消失
- (void)dismissView{
    [self dismissView:0];
}
// 0消失，1，点击关闭，2点击暂不评价,3评价完成
- (void)dismissView:(int ) type{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [UIView animateWithDuration:0.1f animations:^{
        [self.backGroundView setFrame:CGRectMake(self->_backGroundView.frame.origin.x,self->viewHeight ,self.backGroundView.frame.size.width,self.backGroundView.frame.size.height)];
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
    // 记录页面消失
    if (_delegate && [_delegate respondsToSelector:@selector(dimissViews:type:)]) {
        [_delegate dimissViews:self.evaluateModel type:type];
    }
    
}

#pragma mark - 键盘监听事件 输入框的高度变化 更新页面的高度
-(void)keyBoardWillShow:(NSNotification *) notification{
    isKeyBoardShow = YES;
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat keyboardHeight = [[[notification userInfo] objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue].size.height;
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationDelegate:self];
    {
        CGRect  sheetViewFrame = self.sheetView.frame;
        sheetViewFrame.origin.y = self->viewHeight - keyboardHeight - self->_sheetView.frame.size.height + XBottomBarHeight+20;
        [self sheetViewSetFrameWithNewF:sheetViewFrame];
//        UIWindow * window=[[[UIApplication sharedApplication] delegate] window];
//        CGRect rect = [self.textView convertRect:self.textView.bounds toView:window];
//        if((rect.origin.y + rect.size.height)  > self->viewHeight - keyboardHeight){
//            [self.backGroundView setContentOffset:CGPointMake(0, (rect.origin.y + rect.size.height)  - (self->viewHeight - keyboardHeight))];
//        }

    }
    [UIView commitAnimations];
}

//键盘隐藏
- (void)keyBoardWillHide:(NSNotification *)notification {
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView beginAnimations:@"bottomBarDown" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView commitAnimations];
    [UIView animateWithDuration:0.25 animations:^{
        CGRect sheetFrame = self.sheetView.frame;
        sheetFrame.origin.y = self->viewHeight - self->_sheetView.frame.size.height;
        [self sheetViewSetFrameWithNewF:sheetFrame];
//        [self.backGroundView setContentOffset:CGPointMake(0, 0)];
    }];
}
- (void)sheetViewSetFrameWithNewF:(CGRect)newFrame{
    self.sheetView.frame = newFrame;
}

#pragma mark 打分改变代理
-(void)ratingChangedWithTap:(float)newRating{
    
}

#pragma mark - 1-10分 点击事件
-(void)ratingChanged:(float)newRating{
    SLog(@"---rating当前点击：%f", newRating);
    _commitBtn.enabled = YES;
    _commitBtn.alpha = 1;
    _commitBtn.opaque = NO;
    
    touchRating=YES;
    // 留言评价单独处理
    if (self.evaluateModel.type == SatisfactionTypeLeaveReply) {
        // 修改星评描述
        if (scoreFlag) {
            if (_ratingView.rating > 0 && _ratingView.rating<=11) {
                //            _tiplab.text = [NSString stringWithFormat:@"%d星",_ratingView.rating];
                if (!sobotIsNull(self.evaluateModel.ticketScoreInfooList) && self.evaluateModel.ticketScoreInfooList.count) {
                    NSComparator cmptr = ^(ZCLibSatisfaction *obj1, ZCLibSatisfaction *obj2){
                        if (obj1.score  > obj2.score ) {
                            return (NSComparisonResult)NSOrderedDescending;
                        }
                        if (obj1.score < obj2.score) {
                            return (NSComparisonResult)NSOrderedAscending;
                        }
                        return (NSComparisonResult)NSOrderedSame;
                    };
                    NSArray *sorArray = [self.evaluateModel.ticketScoreInfooList sortedArrayUsingComparator:cmptr];
                    ZCLibSatisfaction *item = sorArray[(int)_ratingView.rating -1];
                    _tiplab.text = item.scoreExplain;
                }
            }
            return;
        } else {
            if (_ratingView.rating > 0 && _ratingView.rating<=5) {
                if (self.evaluateModel.ticketScoreInfooList.count && self.evaluateModel.ticketScoreInfooList != nil) {
                    NSComparator cmptr = ^(ZCLibSatisfaction *obj1, ZCLibSatisfaction *obj2){
                        if (obj1.score  > obj2.score ) {
                            return (NSComparisonResult)NSOrderedDescending;
                        }
                        if (obj1.score < obj2.score) {
                            return (NSComparisonResult)NSOrderedAscending;
                        }
                        return (NSComparisonResult)NSOrderedSame;
                    };
                    NSArray *sorArray = [self.evaluateModel.ticketScoreInfooList sortedArrayUsingComparator:cmptr];
                    ZCLibSatisfaction *item = sorArray[(int)_ratingView.rating -1];
                    _tiplab.text = item.scoreExplain;
                }
            }
            return;
        }
    }
    if (self.isChangePostion) {
        // 星评提示语
        if (_listArray != nil && _listArray.count > 0) {
            if (_ratingView.rating>0 && _ratingView.rating <= _listArray.count) {
                // 小心数组越界了。。
                ZCLibSatisfaction *item = _listArray[(int)_ratingView.rating -1];
                _tiplab.text = item.scoreExplain;
            }
        }
        // 人工客服评价点击了星评去刷新对应分值下的 item
        [self showMenuItem:YES];
    }
    self.isChangePostion = YES;
}

// 显示弹出层
- (void)showInView:(UIView *)view{
    [[SobotUITools getCurWindow] addSubview:self];
    self.sheetView.hidden = NO;
}

#pragma mark -- 代理事件限制200个字符的长度
- (void)textViewDidChange:(UITextView *)textView{
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    //如果在变化中是高亮部分在变，就不要计算字符了
    if (selectedRange && pos) {
        return;
    }
    if (textView.text.length>INPUT_MAXCOUNT) {
        textView.text = [textView.text substringToIndex:INPUT_MAXCOUNT];
    }
    
}


#pragma mark -- 手势冲突的代理
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIButton class]]  || [touch.view isKindOfClass:[ZCUIRatingView class]]  || [touch.view isMemberOfClass:[UIImageView class]] || [touch.view isMemberOfClass:[UILabel class]]){
        return NO;
    }
    return YES;
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (!view && [self.backGroundView pointInside:point withEvent:event]) {
        view = _backGroundView;
        CGPoint currentPoint = point;
        for (UIView *subview in view.subviews) {
            BOOL res = [subview isKindOfClass:[UIControl class]] || [subview isKindOfClass:[UIButton class]] || [subview isKindOfClass:[UIImageView class]];
            if (res) {
                currentPoint = [self convertPoint:point toView:view];
                res = [subview pointInside:currentPoint withEvent:event];
            }
            if (res) {
                return subview;
            }
        }
    }
    return view;
}

#pragma mark - 横竖屏切换
-(void)layoutSubviews{
    [super layoutSubviews];
    
    
    if (viewWidth != ScreenWidth) {
//        [self dismissView];
//        return;
        viewWidth = ScreenWidth;
        viewHeight = ScreenHeight;
        minw = MIN(viewWidth, viewHeight);
        ZCMaxHeight =   ((ScreenHeight>800) ? (ScreenHeight-420 - 59):(ScreenHeight-340 - 59));
        if(ZCMaxHeight < 160){
            ZCMaxHeight = 160;
        }
        
        if (SCH > 0) {
            // 机器人模式 横竖屏切换的时候 调整约束
            if (self.evaluateModel.type <3) {
                // 设置偏移量
                CGFloat pointH = SCH;
                if (SCH > 92 + MH + 30 + 20 +74) {
                    pointH = 92 + MH + 30 + 20 +74;
                }
                if (viewWidth > viewHeight) {
                    if (SCH > 45 + MH + 30 ) {
                        pointH = 45 + MH + 30 ;
                    }
                }
                // 更新约束
                [self.sheetView removeConstraint:self.backGroundViewEH];
                self.backGroundViewEH = sobotLayoutEqualHeight(pointH, self.backGroundView, NSLayoutRelationEqual);
                [self.sheetView addConstraint:self.backGroundViewEH];
                [self removeConstraint:self.sheetViewEH];
                CGFloat shvH = pointH + 60 + 80 + XBottomBarHeight;
                self.sheetViewEH = sobotLayoutEqualHeight(shvH, self.sheetView, NSLayoutRelationEqual);
                [self addConstraint:_sheetViewEH];
                CGFloat minW = MIN(viewWidth, viewHeight);
                [self.backGroundView setContentSize:CGSizeMake(minW, SCH)];
            }else{
                // 设置偏移量
                CGFloat pointH = SCH;
                if (SCH > 92 + MH + 30 + 20 +74) {
                    pointH = 92 + MH + 30 + 20 +74;
                }
                if (viewWidth > viewHeight) {
                    if (SCH > 45 + MH + 30 ) {
                        pointH = 45 + MH + 30 ;
                    }
                }
                // 人工
                pointH = SCH;
                if (SCH > SSCH + 92 + 30 + 20 +74) {
                    pointH = SSCH + 92 + 30 + 20 +74;
                }
                if (viewWidth > viewHeight) {
                    if (SCH > 45 + SSCH + 30 ) {
                        pointH = 45 + SSCH + 30 ;
                    }
                }
                // 更新约束
                [self.sheetView removeConstraint:self.backGroundViewEH];
                CGFloat scrollviewH = pointH;
                if (scrollviewH > viewHeight - (60 + 80 + XBottomBarHeight)) {
                    scrollviewH = viewHeight - (60 + 80 + XBottomBarHeight);
                }
                self.backGroundViewEH = sobotLayoutEqualHeight(scrollviewH, self.backGroundView, NSLayoutRelationEqual);
                [self.sheetView addConstraint:self.backGroundViewEH];
                [self removeConstraint:self.sheetViewEH];
                CGFloat shvH = pointH + 60 + 80 + XBottomBarHeight;
                if (shvH >viewHeight) {
                    shvH = viewHeight;
                }
                self.sheetViewEH = sobotLayoutEqualHeight(shvH, self.sheetView, NSLayoutRelationEqual);
                [self addConstraint:_sheetViewEH];
                CGFloat minW = MIN(viewWidth, viewHeight);
                [self.backGroundView setContentSize:CGSizeMake(minW, SCH)];
            }
        }
    }
}


@end
