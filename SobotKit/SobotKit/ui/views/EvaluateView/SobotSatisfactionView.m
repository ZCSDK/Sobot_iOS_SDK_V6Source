//
//  SobotSatisfactionView.m
//  SobotKit
//
//  Created by zhangxy on 2023/8/11.
//

#import "SobotSatisfactionView.h"
#import "SobotRatingView.h"
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClient.h>
#import "ZCUICore.h"
#import "ZCUIKitTools.h"
#import "ZCUIPlaceHolderTextView.h"
#import "SobotSatisfactionItemView.h"

#define SobotSheetTitleHeight 60
#define INPUT_MAXCOUNT 200

// 垂直间隔
#define SobotSpaceVerticall 24

// 水平间隔
#define SobotSpaceHorizontall 20

@implementation SobotSatisfactionParams
@end;



@interface SobotSatisfactionView()<UIGestureRecognizerDelegate,UITextViewDelegate,SobotRatingViewDelegate>{
    // 键盘高度，如果>0说明键盘显示
    CGFloat keyboardHeight;
    
    // 简单过滤一下刷屏
    BOOL isLandScreen;
    
    BOOL isMustTag;
    BOOL isMustInput;
    
    // 是否解决按钮显示了多行
    BOOL isMulResolveBtn;
    
}


@property(nonatomic,strong) ZCSatisfactionConfig *satisfactionConfig;
@property(nonatomic,strong) SobotSatisfactionParams *inParams;
// 只关心触发时的状态
@property(nonatomic,strong) ZCLibConfig *libConfig;


// 顶部导航
@property(nonatomic,strong) UIView *topView;
@property(nonatomic,strong) UIButton *btnTopClose;
@property(nonatomic,strong) UILabel *labTopTitle;
@property(nonatomic,strong) UILabel *labTopSubTitle;

// 当没有副标题时，高度变化
@property(nonatomic,strong) NSLayoutConstraint *subTitleLabH;
// 副标题顶部高度
@property(nonatomic,strong) NSLayoutConstraint *subTitleLabT;

// 内容
@property(nonatomic,strong) UIScrollView *scrollView;

// 由于ScrollView约束需要子类控件撑开，否则有滑动问题
@property(nonatomic,strong) UIView *contentView;


@property(nonatomic,strong) UILabel *labResolveTitle;
@property(nonatomic,strong) NSLayoutConstraint *layoutResolveT;

@property(nonatomic,strong) UIButton *btnResolve;
@property(nonatomic,strong) UIButton *btnUnResolve;
@property(nonatomic,strong) NSLayoutConstraint *layoutBtnUnResolveT;
@property(nonatomic,strong) NSLayoutConstraint *layoutBtnUnResolveH;
@property(nonatomic,strong) NSLayoutConstraint *layoutBtnResolveT;
@property(nonatomic,strong) NSLayoutConstraint *layoutBtnResolveH;

// 分值上面的横线，如果不显示分值，隐藏
@property(nonatomic,strong) NSLayoutConstraint *layoutStartLineT;
@property(nonatomic,strong) NSLayoutConstraint *layoutStartLineH;

@property(nonatomic,strong) SobotRatingView *ratingView;
@property(nonatomic,strong) NSLayoutConstraint *layoutRatingT;

// 非常满意xxx
@property(nonatomic,strong) UILabel *labRating1;
@property(nonatomic,strong) NSLayoutConstraint *layoutLabRating1T;
@property(nonatomic,strong) NSLayoutConstraint *layoutLabRating1W;
// 评分描述xxxx
@property(nonatomic,strong) UILabel *labRating2;
@property(nonatomic,strong) NSLayoutConstraint *layoutLabRating2T;



@property(nonatomic,strong) SobotSatisfactionItemView *itemsView;
@property(nonatomic,strong) NSLayoutConstraint *layoutItemsT;
@property(nonatomic,strong) NSMutableArray *listArray;


// 输入框
@property(nonatomic,strong) ZCUIPlaceHolderTextView *textView;

@property(nonatomic,strong) NSLayoutConstraint *layoutBtmB;

@property(nonatomic,strong)UIButton *commitBtn;
@property(nonatomic,strong)UIButton *cancelBtn;
@property(nonatomic,strong) NSLayoutConstraint *layoutCancelH;
@property(nonatomic,strong) NSLayoutConstraint *layoutCancelT;


// 撑开ScrollView的内容大小，也是实际的内容框大小，显示时动态计算
@property(nonatomic,strong) NSLayoutConstraint *layoutContentH;
@property(nonatomic,strong) NSLayoutConstraint *layoutContentW;

// 输入框
@property(nonatomic,strong) NSLayoutConstraint *layoutTextViewT;
@property(nonatomic,strong) NSLayoutConstraint *layoutTextViewH;

@end

@implementation SobotSatisfactionView

-(SobotSatisfactionView *)initActionSheetWith:(SobotSatisfactionParams *)params config:(ZCLibConfig *)config cView:(UIView * _Nullable)view{
    self = [super init];
    if (self) {
        self.inParams = params;
        self.libConfig = config;
        self.autoresizesSubviews = YES;
        self.backgroundColor = UIColorFromKitModeColorAlpha(SobotColorBlack, 0.4);
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        
        if(sobotGetSystemDoubleVersion() < 13){
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleDeviceOrientationChange:)
                                                 name:UIDeviceOrientationDidChangeNotification object:nil];
        }
        
    }
    return self;
}

// 显示弹出层
- (void)showSatisfactionView:(UIView * _Nullable) superView{
    if(superView!=nil){
        [superView addSubview:self];
    }else{
        [[SobotUITools getCurWindow] addSubview:self];
    }
    // 添加父类约束
    [self.superview addConstraints:sobotLayoutPaddingWithAll(0, 0, 0, 0, self, self.superview)];
    
    // 创建子控件，必须在设置父类Constraints以后创建，否则会有警告
    [self createSubView];
    
    // 先初始化头尾
    [self setupDateToView];
        
    // 计算一次高度
    [self reSetLayout];
    
    if(self.inParams.fromSource == SobotSatisfactionFromSrouceLeave){
        // 加载留言的配置
        self.satisfactionConfig =  [ZCUICore getUICore].satisfactionLeaveConfig;
        // 根据传入数据inParams，设置页面的值
        [self setupDateToView];
        
        [self reSetLayout];
        
    }else{
        // 加载配置信息，如果是留言，此处无需加载
        [[ZCUICore getUICore] loadSatisfactionDictlock:^(int code) {
            self.satisfactionConfig = [ZCUICore getUICore].satisfactionConfig;
            
            // 根据传入数据inParams，设置页面的值
            [self setupDateToView];
            
            // 计算一次高度
            [self reSetLayout];
        }];
    }
}

// 重新布局页面
// 键盘变化，横竖屏切换
-(void)reSetLayout{
    _layoutContentW.constant = ScreenWidth;
    _layoutLabRating1W.constant = ScreenWidth - SobotSpaceHorizontall*2;
    // 获取内容的高度
    [_contentView layoutIfNeeded];
    
    CGFloat ch = CGRectGetHeight(_contentView.frame);
    
    ch = ch;
    _scrollView.contentSize = CGSizeMake(ScreenWidth, ch);
    CGFloat maxProgress = 0.75;
    isLandScreen = NO;
    if(ScreenWidth > ScreenHeight){
        isLandScreen = YES;
        // 横屏
        maxProgress = 0.5;
    }
    if(ch > (ScreenHeight * maxProgress)){
        ch = (ScreenHeight * maxProgress);
    }
    _layoutContentH.constant = ch;
    
    // 如果键盘显示，直接提高到键盘的高度
    if(keyboardHeight > 0){
        _layoutBtmB.constant = -keyboardHeight + XBottomBarHeight;
    }else{
        _layoutBtmB.constant = 0;
    }
}


// 0消失，1，点击关闭，2点击暂不评价,3评价完成
- (void)dismissView{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [UIView animateWithDuration:0.1f animations:^{
        self->_layoutContentH.constant = 0;
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}


#pragma mark 加载数据到view上
-(void)setupDateToView{
    // 显示标题
    if(self.inParams.showType == SobotSatisfactionTypeRobot){
        self.labTopTitle.text = SobotKitLocalString(@"机器人客服评价");
    }else{
        self.labTopTitle.text = SobotKitLocalString(@"服务评价");
    }
    if (self.inParams.showType == SobotSatisfactionTypeManual && self.inParams.fromSource == SobotSatisfactionFromSrouceClose) {
        _labTopSubTitle.hidden = NO;
        // 显示副标题
        self.subTitleLabT.constant = 6;
        self.subTitleLabH.constant = 12;
        self.labTopSubTitle.text = SobotKitLocalString(@"提交评价后会话将结束");
    }else{
        _labTopSubTitle.hidden = YES;
        self.labTopSubTitle.text = @"";
        // 不显示副标题
        self.subTitleLabT.constant = 0;
        self.subTitleLabH.constant = 2;
    }
    
    
    self.labRating1.text= @"";
    self.labRating2.text = @"";
    
    _layoutRatingT.constant = 0;
    _layoutLabRating1T.constant = 0;
    _layoutLabRating2T.constant = 0;
    _layoutItemsT.constant = 0;
    if(self.satisfactionConfig!=nil){
        if(_satisfactionConfig.isDefaultGuide == 0){
            if(sobotConvertToString(_satisfactionConfig.guideCopyWriting).length > 0){
                self.labTopTitle.text = sobotConvertToString(_satisfactionConfig.guideCopyWriting);
            }
        }
        
        _btnUnResolve.hidden = YES;
        _btnResolve.hidden = YES;
        // 设置默认都不选中
        _btnUnResolve.selected = NO;
        _btnResolve.selected = NO;
        
        // 是否解决问题
        if(self.satisfactionConfig.isQuestionFlag == 1 || self.inParams.showType == SobotSatisfactionTypeRobot){
            _labResolveTitle.hidden = NO;
            _layoutResolveT.constant = SobotSpaceVerticall;
            
            // 多行展示
            if(isMulResolveBtn){
                _layoutBtnResolveT.constant = 16;
            }
            _layoutBtnUnResolveT.constant = 16;
            _layoutBtnUnResolveH.constant = 36;
            _layoutBtnResolveH.constant = 36;
            
            _btnUnResolve.hidden = NO;
            _btnResolve.hidden = NO;
            
            // 设置默认都不选中
            _btnUnResolve.selected = NO;
            _btnResolve.selected = NO;
            
            _layoutStartLineT.constant = SobotSpaceVerticall;
            _layoutStartLineH.constant = 1.0;
            if(self.inParams.showType == SobotSatisfactionTypeRobot){
                _labResolveTitle.text = SobotKitLocalString(@"是否解决了您的问题？");
            }else{
                _labResolveTitle.text = [NSString stringWithFormat:@"%@ %@",sobotConvertToString(self.inParams.serviceName),SobotKitLocalString(@"是否解决了您的问题？")];
            }
            // 邀评，根据邀评带过来的数据
            if(self.inParams.fromSource == SobotSatisfactionFromSrouceInvite){
                // 未解决
                [self changeResoleState:self.inParams.invateQuestionFlag];
            }else if(self.inParams.showType != SobotSatisfactionTypeRobot){
                // 未解决
                [self changeResoleState:self.satisfactionConfig.defaultQuestionFlag];
            }
        }else{
            _btnUnResolve.hidden = YES;
            _btnResolve.hidden = YES;
            _layoutResolveT.constant = 0;
            
            // 多行展示
            if(isMulResolveBtn){
                _layoutBtnResolveT.constant = 0;
            }
            _layoutBtnUnResolveT.constant = 0;
            _layoutBtnUnResolveH.constant = 0;
            _layoutBtnResolveH.constant = 0;
            
            _layoutStartLineT.constant = 0;
            _layoutStartLineH.constant = 0;
            
        }
        
        // 解决未解决和星星下面的提示语，默认隐藏，根据选择的星星自动填充
        _layoutLabRating1T.constant = 0;
        _layoutLabRating2T.constant = 0;
        _labRating1.text = @"";
        _labRating2.text = @"";
        
        // 默认分数
        int defaultStar = 0;
        if(_inParams.showType == SobotSatisfactionTypeRobot){
            // 机器人不显示
            _layoutRatingT.constant = 0;
            [_ratingView clearViews];
        }else{
            _layoutRatingT.constant = SobotSpaceVerticall;
            [_ratingView setImagesDeselected:@"zcicon_star_unsatisfied" fullSelected:@"zcicon_star_satisfied" count:_satisfactionConfig.scoreFlag == 1?10:5 showLRTip:_satisfactionConfig.scoreFlag == 1 andDelegate:self];
            _ratingView.userInteractionEnabled = YES;
            self.ratingView.hidden = NO;
            
            // 如果邀评给了值，使用邀评带过来的数据
            if(self.inParams.rating > 0 && self.inParams.fromSource == SobotSatisfactionFromSrouceInvite){
                // 设置默认值
                [_ratingView displayRating:self.inParams.rating];
            }else{
                // 根据配置获取是否选中
                if(_satisfactionConfig.scoreFlag==0){
                    if(_satisfactionConfig.defaultType == 0){
                        defaultStar = 5;
                    }else if(_satisfactionConfig.defaultType == 1){
                        defaultStar = 0;
                    }
                }else{
                    
                    if(_satisfactionConfig.defaultType == 0){
                        defaultStar = 11;
                    }else if(_satisfactionConfig.defaultType == 1){
                        defaultStar = 6;
                    }else if(_satisfactionConfig.defaultType == 2){
                        defaultStar = 1;
                    }else if(_satisfactionConfig.defaultType == 3){
                        defaultStar = 0;
                    }
                }
                if(defaultStar > 0){
                    [_ratingView displayRating:defaultStar];
                }
            }
        }
        
        if(_satisfactionConfig.isDefaultButton==0 && sobotConvertToString(_satisfactionConfig.buttonDesc).length > 0){
            [_commitBtn setTitle:sobotConvertToString(_satisfactionConfig.buttonDesc) forState:UIControlStateNormal];
        }
        
        if(_satisfactionConfig.txtFlag == 0){
            _layoutTextViewH.constant = 0;
            _layoutTextViewT.constant = 0;
        }else{
            _layoutTextViewH.constant = 74;
            _layoutTextViewT.constant = SobotSpaceVerticall;
            if(sobotConvertToString(_satisfactionConfig.txtDesc).length > 0){
                
            }
        }
    }
    
    // 判断暂不评价
    if ((self.inParams.fromSource == SobotSatisfactionFromSrouceBack || self.inParams.fromSource == SobotSatisfactionFromSrouceClose) && [ZCUICore getUICore].kitInfo.canBackWithNotEvaluation) {
        self.cancelBtn.hidden = NO;
        _layoutCancelT.constant = 10;
        _layoutCancelH.constant = 20;
    }else{
        self.cancelBtn.hidden = YES;
        _layoutCancelT.constant = 0;
        _layoutCancelH.constant = 0;
    }
}

#pragma mark 提交评价
// 提交评价
-(void)sendComment{
    NSString *comment=_itemsView!=nil ? [_itemsView getSeletedTitle] : @"";
    if (self.inParams.showType != SobotSatisfactionTypeRobot) {
        // 只在人工是做评定
        if ([@"" isEqualToString:comment] && isMustTag) {
            // 提示
            [[SobotToast shareToast] showToast:SobotKitLocalString(@"标签为必选") duration:1.0f position:SobotToastPositionCenter];
            return;
        }
        // 如果是必传 去除两端的 空格+换行  是否为空
        if (_satisfactionConfig.txtFlag == 1 && isMustInput && sobotConvertToString(_textView.text).length == 0) {
            [[SobotToast shareToast] showToast:SobotKitLocalString(@"建议为必填") duration:1.0f view:self position:SobotToastPositionCenter];
            return;
        }
    }
    
    
    // 是否解决必填,可能不显示，但是必填
    if(_satisfactionConfig.isQuestionFlag == 1 && _satisfactionConfig.isQuestionMust && !_btnResolve.selected && !_btnUnResolve.selected){
        // 提示
        [[SobotToast shareToast] showToast:SobotKitLocalString(@"请选择是否解决了您的问题") duration:1.0f view:self position:SobotToastPositionCenter];
        return;
    }
    // 是否解决必填
    if(_ratingView!=nil && _ratingView.rating == 0 && self.inParams.showType != SobotSatisfactionTypeRobot){
        // 提示
        [[SobotToast shareToast] showToast:[NSString stringWithFormat:@"%@%@",SobotKitLocalString(@"评分"),SobotKitLocalString(@"不能为空")] duration:1.0f view:self  position:SobotToastPositionCenter];
        return;
    }
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
    [dict setObject:comment forKey:@"problem"];
    
    if(_libConfig){
        [dict setObject:sobotConvertToString(_libConfig.cid)  forKey:@"cid"];
        [dict setObject:sobotConvertToString(_libConfig.uid)  forKey:@"userId"];
    }
    if (self.inParams.showType == SobotSatisfactionTypeRobot) {
        [dict setObject:[NSString stringWithFormat:@"%d",0] forKey:@"type"];
    }else{
        [dict setObject:[NSString stringWithFormat:@"%d",1] forKey:@"type"];
        
        
        // 0:5星,1:10分
        if (self.satisfactionConfig.scoreFlag == 1) {
            [dict setObject:[NSString stringWithFormat:@"%.0f",_ratingView.rating - 1] forKey:@"source"];
        } else {
            [dict setObject:[NSString stringWithFormat:@"%.0f",_ratingView.rating] forKey:@"source"];
            [dict setObject:sobotConvertToString(_labRating2.text) forKey:@"scoreExplain"];
        }
        [dict setObject:[NSString stringWithFormat:@"%d",self.satisfactionConfig.scoreFlag] forKey:@"scoreFlag"];
    }

    NSString * textStr = @"";
    if (_textView.text!=nil ) {
        textStr = _textView.text;
    }
    // 去除两端的 空格+换行
    textStr = [sobotConvertToString(_textView.text) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [dict setObject:textStr forKey:@"suggest"];
    
    
    // 注意，isresolve此处的值是反的
    int curResolve = -1;
    if(_btnResolve.selected){
        curResolve = 0;
    }else if(_btnUnResolve.selected){
        curResolve = 1;
    }
    [dict setObject:[NSString stringWithFormat:@"%d",curResolve] forKey:@"isresolve"];
    // commentType  评价类型 主动评价 1 邀请评价0
    [dict setObject:[NSString stringWithFormat:@"%d",(self.inParams.fromSource==SobotSatisfactionFromSrouceInvite)] forKey:@"commentType"];
     
    // 静止重复点击
    _commitBtn.enabled = false;
    
    if(self.inParams.showType == SobotSatisfactionTypeLeave){
        [self sendLeaveSatisfaction];
    }
    else{
        [ZCLibServer doComment:dict result:^(ZCNetWorkCode code, int status, NSString * _Nonnull msg) {
            
        }];
        
        if(self.onSatisfactionClickBlock){
            self.onSatisfactionClickBlock(1, self.inParams, dict,nil);
        }
    }
   
    // 隐藏键盘
    if(_textView!=nil){
        [_textView resignFirstResponder];
    }
    
    [self dismissView];
}


#pragma mark --- 工单留言页面的触发的评价
-(void)sendLeaveSatisfaction{
    NSString * textStr = @"";
    if (_textView.text!=nil && _textView.text.length > 0) {
        textStr = [sobotConvertToString(_textView.text) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    self->_commitBtn.enabled = false;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"ticketId":sobotConvertToString(self.inParams.ticketld),@"companyId":sobotConvertToString(_libConfig.companyID),@"remark":textStr}];
    params[@"tag"] = [_itemsView getSeletedTitle];
    // 0:5星,1:10分
    if (self.satisfactionConfig.scoreFlag == 1) {
        [params setObject:[NSString stringWithFormat:@"%.0f",_ratingView.rating - 1] forKey:@"score"];
    } else {
        [params setObject:[NSString stringWithFormat:@"%.0f",_ratingView.rating] forKey:@"score"];
        [params setObject:sobotConvertToString(_labRating2.text) forKey:@"scoreExplain"];
    }
    // 注意，isresolve此处的值是反的
    int curResolve = -1;
    if(_btnResolve.selected){
        curResolve = 1;
    }else if(_btnUnResolve.selected){
        curResolve = 0;
    }
    params[@"defaultQuestionFlag"] = @(curResolve);
    
    [ZCLibServer postAddTicketSatisfactionWith:sobotConvertToString(_libConfig.uid) dict:params start:^{
        
    } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
        @try{
            SLog(@"提交留言评价结果：%@", dict);
            if (dict && [dict[@"data"][@"retCode"] isEqualToString:@"000000"]) {
                // 刷新工单详情页面数据
                if(self.onSatisfactionClickBlock){
                    self.onSatisfactionClickBlock(1, self.inParams, [NSMutableDictionary dictionaryWithDictionary:dict],dict);
                }
            }
            self->_commitBtn.enabled = false;
            // 隐藏弹出层
            [self dismissView];
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
        
    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
        // 提示
        [[SobotToast shareToast] showToast:SobotKitLocalString(errorMessage) duration:1.0f view:self  position:SobotToastPositionCenter];
        self->_commitBtn.enabled = YES;
    }];
}

// 暂不评价
-(void)cancelButtonClick{
    if(self.onSatisfactionClickBlock){
        self.onSatisfactionClickBlock(-1, self.inParams, nil,nil);
    }
    [self dismissView];
}
// 页面点击事件，点击收起键盘，空白区域关闭评价页面
-(void)tapClick:(UITapGestureRecognizer *) gestap{
    if(self.onSatisfactionClickBlock){
        self.onSatisfactionClickBlock(0, self.inParams, nil,nil);
    }
    
    if(_textView!=nil){
        [_textView resignFirstResponder];
    }
    CGPoint point = [gestap locationInView:self];
    CGRect f=self.topView.frame;
    if(point.x<f.origin.x || point.x>(f.origin.x+f.size.width) ||
       point.y<f.origin.y){
        [self dismissView];
    }
}

// 是否解决
-(void)resolveBtnClick:(UIButton *) sender{
    if(_btnResolve.tag == sender.tag && _btnResolve.selected){
        return;
    }
    if(_btnUnResolve.tag == sender.tag && _btnUnResolve.selected){
        return;
    }
    [self changeResoleState:sender.tag];
    
    // 机器人时，才会改变选项
    if(self.inParams.showType == SobotSatisfactionTypeRobot){
        [self showRatingItems];
    }
}

// 修改解决未解决按钮状态
-(void)changeResoleState:(NSInteger) tag{
    // tag == -1/2 选择，1解决，0未解决
    if(tag < 0 || tag == 2){
        return;
    }
    
    if(tag == 1){
        // 已解决
        [_btnUnResolve setSelected:NO];
        _btnUnResolve.layer.borderColor = UIColorFromModeColor(SobotColorBgLine).CGColor;
        
        [_btnResolve setSelected:YES];
        _btnResolve.layer.borderColor = UIColor.clearColor.CGColor;
    }else{
        // 已解决
        [_btnUnResolve setSelected:YES];
        _btnUnResolve.layer.borderColor = UIColor.clearColor.CGColor;
        
        [_btnResolve setSelected:NO];
        _btnResolve.layer.borderColor = UIColorFromModeColor(SobotColorBgLine).CGColor;
    }
}

// 星级变更代理
-(void)ratingChanged:(float)newRating{
    [self showRatingItems];
}



-(void)showRatingItems{
    self.itemsView.hidden = NO;
    // 人工评价时
    _listArray = _satisfactionConfig.list;
    
    NSString *inputLanguage = SobotKitLocalString(@"欢迎给我们的服务提建议~");
    // 数据源
    NSMutableArray *items= [[NSMutableArray alloc] init];
    if(self.inParams.showType == SobotSatisfactionTypeRobot){
        // 隐藏机器人评价标签
        if(![ZCUICore getUICore].kitInfo.hideRototEvaluationLabels && _btnUnResolve.selected){
            [items addObjectsFromArray:[_libConfig.robotCommentTitle componentsSeparatedByString:@","]];
        }
    }else{
        isMustInput = NO;
        isMustTag = NO;
        
        [items removeAllObjects];// 调用接口不成功的时候用
        // 2.8.9 根据配置隐藏人工评价标签
        if (_listArray.count >0 && _listArray !=nil && ![ZCUICore getUICore].kitInfo.hideManualEvaluationLabels){
            // 接口返回的数据
            if (_ratingView.rating>0 && _listArray.count >= _ratingView.rating) {
                ZCLibSatisfaction * model = _listArray[(int)_ratingView.rating -1];
                
                if (![@"" isEqual: sobotConvertToString(model.labelName)]) {
                    [items addObjectsFromArray:[model.labelName componentsSeparatedByString:@"," ]];
                }else if(model.tags!=nil && [model.tags isKindOfClass:[NSArray class]]){
                    for(NSDictionary *tag in model.tags){
                        [items addObject:sobotConvertToString(tag[@"labelName"])];
                    }
                }
                
                isMustInput = [sobotConvertToString(model.isInputMust) boolValue];
                isMustTag = [sobotConvertToString(model.isTagMust) boolValue];
                if(sobotConvertToString(model.inputLanguage).length > 0){
                    inputLanguage = sobotConvertToString(model.inputLanguage);
                }
                if(sobotConvertToString(model.scoreExplain).length > 0){
                    if(sobotConvertToString(model.scoreExplain).length > 0){
                        [_labRating1 setText:model.scoreExplain];
                        _layoutLabRating1T.constant = 12;
                    }else{
                        [_labRating1 setText:@""];
                        _layoutLabRating1T.constant = 0;
                        
                    }
                    if(sobotConvertToString(model.tagTips).length > 0){
                        [_labRating2 setText:model.tagTips];
                        _layoutLabRating2T.constant = SobotSpaceVerticall;
                    }else{
                        [_labRating2 setText:@""];
                        _layoutLabRating2T.constant = 0;
                    }
                }
            }
        }
    }
    if(items.count > 0){
        _layoutItemsT.constant = SobotSpaceVerticall;
        //邀请评价时，可能已经默认选择了标签，此处给默认值
        if(self.inParams.fromSource == SobotSatisfactionFromSrouceInvite){
            [self.itemsView refreshData:items withCheckLabels:sobotConvertToString([ZCUICore getUICore].inviteSatisfactionCheckLabels)];
            [self.itemsView layoutIfNeeded];
        }else{
            [self.itemsView refreshData:items];
        }
    }else{
        _layoutItemsT.constant = 0;
        [self.itemsView clearData];
    }
    
    if(isMustInput){
        self.textView.placeholder         = [NSString stringWithFormat:@"%@ (%@)",inputLanguage,SobotKitLocalString(@"必填")];
    }else{
        
        self.textView.placeholder         = [NSString stringWithFormat:@"%@ (%@)",inputLanguage,SobotKitLocalString(@"选填")];
    }
    [self reSetLayout];
}

// 点击关闭按钮
-(void)zcDismissView:(UIButton *)btn{
    if(self.onSatisfactionClickBlock){
        self.onSatisfactionClickBlock(0, self.inParams, nil,nil);
    }
    
    [self dismissView];
}



#pragma mark 横竖屏适配
//设备方向改变的处理
- (void)handleDeviceOrientationChange:(NSNotification *)notification{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    BOOL isChanged = NO;
    switch (deviceOrientation) {
        case UIDeviceOrientationFaceUp:
            NSLog(@"屏幕朝上平躺");
            if(isLandScreen){
                isChanged = YES;
            }
            break;
        case UIDeviceOrientationFaceDown:
            NSLog(@"屏幕朝下平躺");
            if(isLandScreen){
                isChanged = YES;
            }
            break;
        case UIDeviceOrientationUnknown:
            NSLog(@"未知方向");
            break;
        case UIDeviceOrientationLandscapeLeft:
            NSLog(@"屏幕向左横置");
            if(!isLandScreen){
                isChanged = YES;
            }
            break;
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"屏幕向右橫置");
            if(!isLandScreen){
                isChanged = YES;
            }
            break;
        case UIDeviceOrientationPortrait:
            NSLog(@"屏幕直立");
            if(isLandScreen){
                isChanged = YES;
            }
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"屏幕直立，上下顛倒");
            if(isLandScreen){
                isChanged = YES;
            }
            break;
        default:
            NSLog(@"无法辨识");
            break;
    }
    
    if(isChanged){
        [self reSetLayout];
        
        if(_ratingView){
            [_ratingView viewOrientationChange];
        }
        if(_itemsView){
            [_itemsView viewOrientationChange];
        }
        NSString *placeholder = self.textView.placeholder;
        self.textView.placeholder = sobotConvertToString(placeholder);
    }
}

// 适配iOS 13以上的横竖屏切换
-(void)safeAreaInsetsDidChange{
    
//    UIEdgeInsets e = self.safeAreaInsets;
//
//    if(e.left > 0 || e.right > 0){
//        // 横屏
//        SLog(@"执行了横屏:l:%f-r:%f", e.left,e.right);
//        if(!isLandScreen){
//            if(_ratingView){
//                [_ratingView viewOrientationChange];
//            }
//            if(_itemsView){
//                [_itemsView viewOrientationChange];
//            }
//
//            [self reSetLayout];
//        }
//    }else{
//        // 竖屏
//        SLog(@"执行了竖屏:t:%f-b:%f", e.top,e.bottom);
//        if(isLandScreen){
//            if(_ratingView){
//                [_ratingView viewOrientationChange];
//            }
//            if(_itemsView){
//                [_itemsView viewOrientationChange];
//            }
//            [self reSetLayout];
//        }
//    }
    
    
    if(self.contentView!=nil){
        [self reSetLayout];
        if(_ratingView){
            [_ratingView viewOrientationChange];
        }
        if(_itemsView){
            [_itemsView viewOrientationChange];
        }
        NSString *placeholder = self.textView.placeholder;
        self.textView.placeholder = sobotConvertToString(placeholder);
    }
    
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
    if ([touch.view isKindOfClass:[UIButton class]]  || [touch.view isKindOfClass:[SobotRatingView class]]  || [touch.view isMemberOfClass:[UIImageView class]]){
        return NO;
    }
    return YES;
}


#pragma mark - 键盘监听事件 输入框的高度变化 更新页面的高度
-(void)keyboardWillShow:(NSNotification *) notification{
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    keyboardHeight = [[[notification userInfo] objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue].size.height;
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationDelegate:self];
    {
        [self reSetLayout];
    }
    [UIView commitAnimations];
}

//键盘隐藏
- (void)keyboardWillHide:(NSNotification *)notification {
    keyboardHeight = 0;
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView beginAnimations:@"bottomBarDown" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView commitAnimations];
    [UIView animateWithDuration:0.25 animations:^{
        [self reSetLayout];
    }];
}


#pragma mark -- 创建所有子View
-(void)createSubView{
    _topView = ({
        UIView *iv = [[UIView alloc] init];
        iv.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
        [self addSubview:iv];
        
        [self addConstraint:sobotLayoutPaddingLeft(0, iv, self)];
        [self addConstraint:sobotLayoutPaddingRight(0, iv, self)];
        [self addConstraint:sobotLayoutEqualHeight(SobotSheetTitleHeight, iv, NSLayoutRelationEqual)];
        iv;
    });
    
    
    // 顶部标题栏部分  关闭按钮  标题  暂不评价 评价后结束会话
    // 左上角关闭按钮
    _btnTopClose = ({
        UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.topView addSubview:iv];
        [iv setImage:[SobotUITools getSysImageByName:@"zcicon_sf_close"] forState:UIControlStateNormal];
        [iv setImage:[SobotUITools getSysImageByName:@"zcicon_sf_close"] forState:UIControlStateSelected];
        [iv setImage:[SobotUITools getSysImageByName:@"zcicon_sf_close"] forState:UIControlStateHighlighted];
        [iv addTarget:self action:@selector(zcDismissView:) forControlEvents:UIControlEventTouchUpInside];
//        iv.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.topView addConstraint:sobotLayoutEqualWidth(44, iv, NSLayoutRelationEqual)];
        [self.topView addConstraint:sobotLayoutEqualHeight(44, iv, NSLayoutRelationEqual)];
        [self.topView addConstraint:sobotLayoutPaddingRight(-10, iv, self.topView)];
        [self.topView addConstraint:sobotLayoutEqualCenterY(0, iv, self.topView)];
        iv;
    });
    
    // 评价标题
    _labTopTitle = ({
        UILabel *iv = [[UILabel alloc]init];
        iv.textColor = UIColorFromKitModeColor(SobotColorTextMain);
        iv.textAlignment = NSTextAlignmentLeft;
        iv.numberOfLines = 0;
        iv.font = SobotFontBold17;
        iv.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.topView addSubview:iv];
        [self.topView addConstraint:sobotLayoutEqualHeight(20, iv, NSLayoutRelationEqual)];
        [self.topView addConstraint:sobotLayoutPaddingLeft(SobotSpaceHorizontall, iv, self.topView)];
        [self.topView addConstraint:sobotLayoutPaddingRight(-60, iv, self.topView)];
        iv;
    });
    
    // 评价标题下面提示语
    _labTopSubTitle = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.topView addSubview:iv];
        iv.font = SobotFont12;
        iv.textAlignment = NSTextAlignmentLeft;
        iv.numberOfLines = 0;
        iv.textColor = [ZCUIKitTools zcgetSatisfactionColor];
        iv.text = SobotKitLocalString(@"提交评价后会话将结束");
        _subTitleLabT = sobotLayoutMarginTop(6, iv, self.labTopTitle);
        _subTitleLabH = sobotLayoutEqualHeight(12, iv, NSLayoutRelationEqual);
        [self.topView addConstraint:_subTitleLabT];
        [self.topView addConstraint:sobotLayoutPaddingLeft(SobotSpaceHorizontall, iv, self.topView)];
        [self.topView addConstraint:sobotLayoutPaddingRight(-SobotSpaceHorizontall, iv, self.topView)];
        [self.topView addConstraint:_subTitleLabH];
        [self.topView addConstraint:sobotLayoutPaddingBottom(-18, iv, self.topView)];
        iv.hidden = YES;
        iv;
    });
    // 导航线条
    UIView *iv = [[UIView alloc]init];
    [self.topView addSubview:iv];
    iv.backgroundColor = [ZCUIKitTools zcgetCommentButtonLineColor];
    [self.topView addConstraint:sobotLayoutPaddingLeft(0, iv, self.topView)];
    [self.topView addConstraint:sobotLayoutPaddingRight(0, iv, self.topView)];
    [self.topView addConstraint:sobotLayoutPaddingBottom(-0.5, iv, self.topView)];
    [self.topView addConstraint:sobotLayoutEqualHeight(0.5, iv, NSLayoutRelationEqual)];
    
    
    
    _scrollView = ({
        UIScrollView *iv = [[UIScrollView alloc]init];
        iv.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
        [self addSubview:iv];
        _layoutContentH = sobotLayoutEqualHeight(0, iv, NSLayoutRelationEqual);
        [self addConstraint:_layoutContentH];
        [self addConstraint:sobotLayoutMarginTop(0, iv, self.topView)];
        [self addConstraint:sobotLayoutPaddingLeft(0, iv, self)];
        [self addConstraint:sobotLayoutPaddingRight(0, iv, self)];
        iv;
    });
    
    _contentView = ({
        UIView *iv = [[UIView alloc] init];
        iv.backgroundColor = UIColor.clearColor;
        [self.scrollView addSubview:iv];

        [self.scrollView addConstraint:sobotLayoutPaddingTop(0, iv, self.scrollView)];
        [self.scrollView addConstraint:sobotLayoutPaddingLeft(0, iv, self.scrollView)];
        [self.scrollView addConstraint:sobotLayoutPaddingBottom(0, iv, self.scrollView)];

        _layoutContentW = sobotLayoutEqualWidth(ScreenWidth, iv, NSLayoutRelationEqual);
        _layoutContentW.priority = UILayoutPriorityDefaultHigh;
        [self.scrollView addConstraint:_layoutContentW];
        iv;
    });
    _contentView.hidden = NO;


    // 是否解决了您的问题
    _labResolveTitle = ({
        UILabel *iv = [[UILabel alloc]init];
        iv.font = SobotFont15;
        iv.numberOfLines = 0;
        iv.textColor = UIColorFromKitModeColor(SobotColorTextMain);
        iv.backgroundColor = [UIColor whiteColor];
        iv.text = [NSString stringWithFormat:@"%@ %@",sobotConvertToString(self.inParams.serviceName),SobotKitLocalString(@"是否解决了您的问题？")];
        iv.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:iv];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(SobotSpaceHorizontall, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-SobotSpaceHorizontall, iv, self.contentView)];
        self.layoutResolveT = sobotLayoutPaddingTop(24, iv, self.contentView);
        [self.contentView addConstraint:self.layoutResolveT];

        iv.hidden = YES;
        iv;
    });
    
    
    // 此处要判断上下的情况
    _btnUnResolve = [self createResolveButton:0];
    _btnResolve = [self createResolveButton:1];

    isMulResolveBtn = NO;
    
    [_btnUnResolve sizeToFit];
    [_btnResolve sizeToFit];
    CGFloat maxItemW = (ScreenWidth - 40 - 20)/2;
    if(CGRectGetWidth(_btnResolve.frame) > maxItemW || CGRectGetWidth(_btnUnResolve.frame) > maxItemW){
        isMulResolveBtn = YES;
        
        _layoutBtnResolveT = sobotLayoutMarginTop(16, _btnResolve, self.labResolveTitle);
        _layoutBtnResolveH = sobotLayoutEqualHeight(36, _btnResolve, NSLayoutRelationEqual);
        _layoutBtnResolveH.priority = UILayoutPriorityDefaultHigh;
        [self.contentView addConstraint:_layoutBtnResolveT];
        [self.contentView addConstraint:_layoutBtnResolveH];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(SobotSpaceHorizontall, _btnResolve, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-SobotSpaceHorizontall, _btnResolve, self.contentView)];
        
        _layoutBtnUnResolveT = sobotLayoutMarginTop(16, _btnUnResolve, self.btnResolve);
        _layoutBtnUnResolveH = sobotLayoutEqualHeight(36, _btnUnResolve, NSLayoutRelationEqual);
        _layoutBtnUnResolveH.priority = UILayoutPriorityDefaultHigh;
        [self.contentView addConstraint:_layoutBtnUnResolveT];
        [self.contentView addConstraint:_layoutBtnUnResolveH];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(SobotSpaceHorizontall, _btnUnResolve, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-SobotSpaceHorizontall, _btnUnResolve, self.contentView)];
        
    }else{
        // 居中一个20的间隔
        UIView *spaceView = [[UIView alloc] init];
        spaceView.backgroundColor = UIColor.clearColor;
        [self.contentView addSubview:spaceView];
        [self.contentView addConstraint:sobotLayoutEqualWidth(20, spaceView, NSLayoutRelationEqual)];
        [self.contentView addConstraint:sobotLayoutMarginTop(SobotSpaceVerticall, spaceView, self.contentView)];
        [self.contentView addConstraint:sobotLayoutEqualCenterX(0, spaceView, self.contentView)];
        
        // 按钮的宽
        [self.contentView addConstraint:sobotLayoutEqualWidth(97, _btnResolve, NSLayoutRelationEqual)];
        [self.contentView addConstraint:sobotLayoutEqualWidth(97, _btnUnResolve, NSLayoutRelationEqual)];
        
        // 右侧按钮
        [self.contentView addConstraint:sobotLayoutPaddingTop(0, _btnResolve, _btnUnResolve)];
        [self.contentView addConstraint:sobotLayoutMarginRight(0, _btnResolve, spaceView)];
        _layoutBtnResolveH = sobotLayoutEqualHeight(36, _btnResolve, NSLayoutRelationEqual);
        _layoutBtnResolveH.priority = UILayoutPriorityDefaultHigh;
        [self.contentView addConstraint:_layoutBtnResolveH];
        
        _layoutBtnUnResolveT = sobotLayoutMarginTop(16, _btnUnResolve, self.labResolveTitle);
        _layoutBtnUnResolveH = sobotLayoutEqualHeight(36, _btnUnResolve, NSLayoutRelationEqual);
        _layoutBtnUnResolveH.priority = UILayoutPriorityDefaultHigh;
        [self.contentView addConstraint:_layoutBtnUnResolveH];
        [self.contentView addConstraint:_layoutBtnUnResolveT];
        [self.contentView addConstraint:sobotLayoutMarginLeft(0, _btnUnResolve, spaceView)];
        
    }



    // 星星上面的横线
    UIView *lineView1 = [[UIView alloc] init];
    [self.contentView addSubview:lineView1];
    lineView1.backgroundColor = [ZCUIKitTools zcgetCommentButtonLineColor];
    
    _layoutStartLineT = sobotLayoutMarginTop(SobotSpaceVerticall, lineView1, self.btnUnResolve);
    _layoutStartLineH = sobotLayoutEqualHeight(1.0f, lineView1, NSLayoutRelationEqual);
    _layoutStartLineH.priority = UILayoutPriorityDefaultHigh;
    [self.contentView addConstraint:_layoutStartLineT];
    [self.contentView addConstraint:sobotLayoutPaddingRight(-SobotSpaceHorizontall, lineView1, self.contentView)];
    [self.contentView addConstraint:sobotLayoutPaddingLeft(SobotSpaceHorizontall, lineView1, self.contentView)];
    [self.contentView addConstraint:_layoutStartLineH];


    // 星星或评分
    _ratingView = [[SobotRatingView alloc] init];
    [self.contentView addSubview:_ratingView];
    _layoutRatingT = sobotLayoutMarginTop(0, _ratingView, lineView1);
    [self.contentView addConstraint:_layoutRatingT];
    [self.contentView addConstraint:sobotLayoutPaddingRight(-SobotSpaceHorizontall*2, _ratingView, self.contentView)];
    [self.contentView addConstraint:sobotLayoutPaddingLeft(SobotSpaceHorizontall*2, _ratingView, self.contentView)];

    _labRating1 = ({
        UILabel *iv = [[UILabel alloc]init];
        iv.numberOfLines = 0;
        [self.contentView addSubview:iv];
        iv.textAlignment = NSTextAlignmentCenter;
        iv.font = SobotFont12;
        iv.textColor = [ZCUIKitTools zcgetScoreExplainTextColor];
        _layoutLabRating1T = sobotLayoutMarginTop(0, iv, self.ratingView);
        [self.contentView addConstraint:_layoutLabRating1T];
        _layoutLabRating1W = sobotLayoutEqualWidth(ScreenWidth - SobotSpaceHorizontall*2,iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:_layoutLabRating1W];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(SobotSpaceHorizontall, iv, self.contentView)];
        iv;
    });

    _labRating2 = ({
        UILabel *iv = [[UILabel alloc]init];
        iv.numberOfLines = 0;
        [self.contentView addSubview:iv];
        iv.textColor = UIColorFromKitModeColor(SobotColorTextSub);
        iv.font = SobotFont15;
        iv.textAlignment = NSTextAlignmentLeft;
        _layoutLabRating2T = sobotLayoutMarginTop(0, iv, self.labRating1);
        [self.contentView addConstraint:_layoutLabRating2T];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-SobotSpaceHorizontall, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(SobotSpaceHorizontall, iv, self.contentView)];
        iv;
    });


    // 添加选项
    _itemsView = [[SobotSatisfactionItemView alloc] init];
    [self.contentView addSubview:_itemsView];
    _layoutItemsT = sobotLayoutMarginTop(0, _itemsView, self.labRating2);
    [self.contentView addConstraint:_layoutItemsT];
    [self.contentView addConstraint:sobotLayoutPaddingRight(-SobotSpaceHorizontall, _itemsView, self.contentView)];
    [self.contentView addConstraint:sobotLayoutPaddingLeft(SobotSpaceHorizontall, _itemsView, self.contentView)];


//     评价输入框
    _textView = ({
        ZCUIPlaceHolderTextView *iv = [[ZCUIPlaceHolderTextView alloc]init];
        [self.contentView addSubview:iv];
        [iv setContentInset:UIEdgeInsetsMake( 7, 12, 15, 15)];
        iv.textColor  = [ZCUIKitTools zcgetLeftChatTextColor];
        iv.backgroundColor =  [ZCUIKitTools zcgetLeftChatColor];
        iv.placeholder         = SobotKitLocalString(@"欢迎给我们的服务提建议~");
        iv.placeholderColor    = UIColorFromKitModeColor(SobotColorTextSub1);
        iv.placeholderLinkColor = UIColorFromKitModeColor(SobotColorTextSub1);
        iv.placeholederFont    = SobotFont14;
        iv.font                = SobotFont14;
        iv.delegate            = self;
        [iv setContentInset:UIEdgeInsetsMake(0,5, 0, 5)];

        self.layoutTextViewT = sobotLayoutMarginTop(SobotSpaceVerticall, iv, self.itemsView);

        self.layoutTextViewH = sobotLayoutEqualHeight(74, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.layoutTextViewT];
        [self.contentView addConstraint:self.layoutTextViewH];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(25, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-25, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(-10, iv, self.contentView)];
        iv;
    });
    


#pragma mark -- 提交按钮是最下面的位置固定
    UIView *btmView = [[UIView alloc] init];
    btmView.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
    [self addSubview:btmView];
    [self addConstraint:sobotLayoutMarginTop(0, btmView, self.scrollView)];
    [self addConstraint:sobotLayoutPaddingRight(0, btmView, self)];
    [self addConstraint:sobotLayoutPaddingLeft(0, btmView, self)];
    _layoutBtmB = sobotLayoutPaddingBottom(0, btmView, self);
    [self addConstraint:_layoutBtmB];

    _commitBtn = ({
        UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
        [btmView addSubview:iv];
        
        [iv setTitle:SobotKitLocalString(@"提交") forState:UIControlStateNormal];
        iv.titleLabel.font = SobotFontBold17;
        [iv setTitleColor:[ZCUIKitTools zcgetSubmitEvaluationButtonColor] forState:UIControlStateNormal];
        [iv setBackgroundColor:[ZCUIKitTools zcgetServerConfigBtnBgColor]];
        [iv addTarget:self action:@selector(sendComment) forControlEvents:UIControlEventTouchUpInside];
        iv.layer.cornerRadius = 22.0f;
        iv.layer.masksToBounds = YES;
        iv.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        iv.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [btmView addSubview:iv];
        [btmView addConstraint:sobotLayoutPaddingLeft(20, iv, btmView)];
        [btmView addConstraint:sobotLayoutPaddingRight(-20, iv, btmView)];
        [btmView addConstraint:sobotLayoutEqualHeight(44, iv, NSLayoutRelationEqual)];
        [btmView addConstraint:sobotLayoutPaddingTop(20, iv, btmView)];
        iv;
    });

#pragma mark -- 有暂不评价 显示到最下方
    _cancelBtn = ({
        UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
        [btmView addSubview:iv];
        [iv setTitle:SobotKitLocalString(@"暂不评价") forState:0];
        [iv.titleLabel setFont:SobotFont14];
        iv.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        iv.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [iv setTitleColor:[ZCUIKitTools zcgetSatisfactionTextSelectedColor] forState:0];
        [iv addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];

        [btmView addConstraint:sobotLayoutPaddingRight(-SobotSpaceHorizontall, iv, btmView)];
        [btmView addConstraint:sobotLayoutPaddingLeft(SobotSpaceHorizontall, iv, btmView)];
        _layoutCancelH = sobotLayoutEqualHeight(20, iv, NSLayoutRelationEqual);
        _layoutCancelH.priority = UILayoutPriorityDefaultHigh;
        _layoutCancelT = sobotLayoutMarginTop(10, iv, self.commitBtn);
        [btmView addConstraint:_layoutCancelT];
        [btmView addConstraint:_layoutCancelH];
        [btmView addConstraint:sobotLayoutPaddingBottom(-XBottomBarHeight - 10, iv, btmView)];
        iv;
    });
}


// 创建解决、未解决按钮
-(UIButton *)createResolveButton:(int ) tag{
    UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:iv];
    iv.tag=tag;
    iv.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 7);
    if(tag == 0){
        [iv setImage:[SobotUITools getSysImageByName:SobotKitLocalString(@"zcicon_useless_nol")] forState:UIControlStateNormal];
        [iv setImage:[SobotUITools getSysImageByName:SobotKitLocalString(@"zcicon_useless_sel")] forState:UIControlStateSelected];
        [iv setImage:[SobotUITools getSysImageByName:SobotKitLocalString(@"zcicon_useless_sel")] forState:UIControlStateHighlighted];
        [iv setTitle:SobotKitLocalString(@"未解决") forState:UIControlStateNormal];
    }else{
        [iv setImage:SobotKitGetImage(@"zcicon_useful_nol") forState:UIControlStateNormal];
        [iv setImage:SobotKitGetImage(@"zcicon_useful_sel") forState:UIControlStateSelected];
        [iv setImage:SobotKitGetImage(@"zcicon_useful_sel") forState:UIControlStateHighlighted];
        [iv setTitle:SobotKitLocalString(@"已解决") forState:UIControlStateNormal];
    }
    
    if(sobotIsRTLLayout()){
        [iv setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [iv setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
        [iv setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
    }else{
        [iv setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        [iv setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    }
    
    iv.selected=NO;
    iv.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [iv.titleLabel setFont:[ZCUIKitTools zcgetListKitTitleFont]];
    [iv setTitleColor:[ZCUIKitTools zcgetNoSatisfactionTextColor] forState:UIControlStateNormal];
    [iv setTitleColor:[ZCUIKitTools zcgetSatisfactionTextSelectedColor] forState:UIControlStateHighlighted];
    [iv setTitleColor:[ZCUIKitTools zcgetSatisfactionTextSelectedColor]  forState:UIControlStateSelected];
    
    [iv addTarget:self action:@selector(resolveBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [iv setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [iv setBackgroundColor:[ZCUIKitTools zcgetSatisfactionBgSelectedColor]];
    iv.layer.cornerRadius = 18.0f;
    if([SobotUITools getSobotThemeMode] != SobotThemeMode_Dark){
        iv.layer.shadowOpacity= 1;
        iv.layer.shadowColor = UIColorFromModeColorAlpha(SobotColorTextMain, 0.15).CGColor;
        iv.layer.shadowOffset = CGSizeZero;//投影偏移
        iv.layer.shadowRadius = 2;
    }
    if(sobotIsRTLLayout()){
        [iv setImageEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 3)];
    }
//    [self.contentView addConstraints:sobotLayoutSize(97, 36, iv, NSLayoutRelationEqual)];
    return iv;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
