//
//  ZCChatView.m
//  SobotKit
//
//  Created by zhangxy on 2022/8/30.
//

#import "ZCChatView.h"
#import <SobotChatClient/ZCIMChat.h>
#import <SobotChatClient/ZCPlatformTools.h>
#import <SobotChatClient/ZCLibServer.h>
#import <SobotCommon/SobotCommon.h>
#import "ZCUICore.h"
#import "ZCUIChatKeyboard.h"
#import "ZCFastMenuView.h"
#import "ZCLeaveMsgController.h"

#import "ZCChatBaseCell.h"
#import "ZCChatTextCell.h"
#import "ZCChatVoiceCell.h"
#import "ZCChatTipsCell.h"
#import "ZCChatPhotoVideoCell.h"
#import "ZCChatRichCell.h"
#import "ZCChatWheel123Cell.h"
#import "ZCChatWheel4Cell.h"
#import "ZCChatHotGuideCell.h"
#import "ZCChatOnlineTipsCell.h"
#import "ZCChatNoticeCell.h"
#import "ZCChatNoticeLeaveCell.h"
#import "ZCChatEvaluationCell.h"
#import "ZCChatLocationCell.h"
#import "ZCChatFileCell.h"
#import "ZCChatOrderCardCell.h"
#import "ZCChatGoodsCardCell.h"
#import "ZCChatSendGoodsCell.h"
#import "ZCChatArticleCell.h"
#import "ZCChatAppletCell.h"
#import "ZCQuickLeaveView.h"
#import "ZCUIAskTableController.h"
#import "ZCDocumentLookController.h"
#import "ZCTurnRobotView.h"
#import "ZCUILoading.h"

@interface ZCChatView()<UITableViewDelegate,UITableViewDataSource,ZCUICoreDelegate,ZCChatCellDelegate>{
    NSInteger lastMsgCount;
    SobotXHImageViewer *xhObj;
    
    // 当前正在播放的语音按钮
    SobotChatMessage *playModel;

    // 是否已经打开了表单
    BOOL isOpenNewPage;
}

/** 声音播放对象 */
@property(nonatomic,copy) UITableView *listTable;
@property(nonatomic,copy) ZCFastMenuView *fastMenuView;
@property (nonatomic,strong) UIRefreshControl * refreshControl;

@property(nonatomic,strong) ZCUIChatKeyboard *keyboardTools;
@property(nonatomic,strong) NSLayoutConstraint *tableBottomCons;
@property(nonatomic,strong) NSLayoutConstraint *tableLayoutTop;

// 通告
@property(nonatomic,copy) UIView *notifitionTopView;

@property(nonatomic,copy) UIButton *newWorkStatusButton;
@property(nonatomic,copy) UIButton *socketStatusButton;

// 多伦唤起留言
@property(nonatomic,strong)ZCQuickLeaveView *leaveEditView;


// 切换机器人控件
@property (nonatomic,strong) ZCTurnRobotView *changeRobotView;
/** 多机器人按钮*/
@property (nonatomic,strong) UIButton * changeRobotBtn;
@property (nonatomic,strong) UIButton *goUnReadButton;

@property (nonatomic,strong)UIButton *changeRobotBtn_btn1;
@property (nonatomic,strong)UIButton *changeRobotBtn_btn2;
@end

@implementation ZCChatView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)loadDataToView{
    [self createChatUI];
    
    [self doSDKConfig];
}
-(void)doSDKConfig{
    [[ZCUICore getUICore] doInitSDK:self block:^(ZCInitStatus status, NSString * _Nullable message, ZCLibConfig * _Nullable confg) {
        if(status == ZCInitStatusLoading){
            [[ZCUILoading shareZCUILoading] showAddToSuperView:self style:NO];
        }
        if(status == ZCInitStatusLoadSuc){
            [[ZCUILoading shareZCUILoading] dismiss];
            [self->_keyboardTools setInitConfig:confg];
//            [self->_fastMenuView refreshData]; // 这里去掉 和键盘设置刷新快捷菜单的时间太相近了，导致数据重复
            [self updateTopViewBgColor];
            
            [self notifitionTopViewWithisShowTopView];
            
            // 是否显示 多机器人按钮
            if ([self getZCIMConfig].robotSwitchFlag == 1) {
                if ([self getZCIMConfig].type != 2 && ![self getZCIMConfig].isArtificial) {
                    self->_changeRobotBtn.hidden = NO;
                    [self->_changeRobotBtn_btn2 setTitleColor:[ZCUIKitTools zcgetRobotBtnBgColor] forState:UIControlStateNormal];
                    UIImage *robotimg = SobotKitGetImage(@"zcicon_changerobot");
                    [self->_changeRobotBtn_btn1 setImage:[self imageChangeColor:[ZCUIKitTools zcgetRobotBtnBgColor] chageImg:robotimg] forState:UIControlStateNormal];
                }else{
                    self->_changeRobotBtn.hidden = YES;
                }
            }else{
                self->_changeRobotBtn.hidden = YES;
            }
        }
        
        if(status == ZCInitStatusFail){
            [[ZCUILoading shareZCUILoading] createPlaceholderView:SobotKitLocalString(@"网络错误，请检查网络后重试") image:nil withView:self action:^(UIButton *button) {
                [[ZCUILoading shareZCUILoading] dismiss];
                [self doSDKConfig];
            }];
        }
    }];
}
#pragma mark - 更新导航栏颜色
-(void)updateTopViewBgColor{
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateTopViewBgColor)]) {
        [self.delegate updateTopViewBgColor];
    }
}


-(void)createChatUI{
    _listTable = [SobotUITools createTableWithView:self delegate:self];
    _listTable.backgroundColor = [UIColor clearColor];
    [self addSubview:_listTable];
    [_listTable registerClass:[ZCChatTextCell class] forCellReuseIdentifier:@"ZCChatTextCell"];
    [_listTable registerClass:[ZCChatVoiceCell class] forCellReuseIdentifier:@"ZCChatVoiceCell"];
    [_listTable registerClass:[ZCChatTipsCell class] forCellReuseIdentifier:@"ZCChatTipsCell"];
    [_listTable registerClass:[ZCChatPhotoVideoCell class] forCellReuseIdentifier:@"ZCChatPhotoVideoCell"];
    [_listTable registerClass:[ZCChatRichCell class] forCellReuseIdentifier:@"ZCChatRichCell"];
    [_listTable registerClass:[ZCChatRichCell class] forCellReuseIdentifier:@"ZCChatRichCell"];
    [_listTable registerClass:[ZCChatWheel123Cell class] forCellReuseIdentifier:@"ZCChatWheel123Cell"];
    [_listTable registerClass:[ZCChatWheel4Cell class] forCellReuseIdentifier:@"ZCChatWheel4Cell"];
    
    [_listTable registerClass:[ZCChatNoticeCell class] forCellReuseIdentifier:@"ZCChatNoticeCell"];
    [_listTable registerClass:[ZCChatNoticeLeaveCell class] forCellReuseIdentifier:@"ZCChatNoticeLeaveCell"];
    [_listTable registerClass:[ZCChatEvaluationCell class] forCellReuseIdentifier:@"ZCChatEvaluationCell"];
    [_listTable registerClass:[ZCChatLocationCell class] forCellReuseIdentifier:@"ZCChatLocationCell"];
    [_listTable registerClass:[ZCChatFileCell class] forCellReuseIdentifier:@"ZCChatFileCell"];
    [_listTable registerClass:[ZCChatOrderCardCell class] forCellReuseIdentifier:@"ZCChatOrderCardCell"];
    [_listTable registerClass:[ZCChatGoodsCardCell class] forCellReuseIdentifier:@"ZCChatGoodsCardCell"];
    [_listTable registerClass:[ZCChatSendGoodsCell class] forCellReuseIdentifier:@"ZCChatSendGoodsCell"];
    [_listTable registerClass:[ZCChatArticleCell class] forCellReuseIdentifier:@"ZCChatArticleCell"];
    [_listTable registerClass:[ZCChatAppletCell class] forCellReuseIdentifier:@"ZCChatAppletCell"];
    [_listTable registerClass:[ZCChatOnlineTipsCell class] forCellReuseIdentifier:@"ZCChatOnlineTipsCell"];
    
    // 分割线的隐藏
//    _listTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
//    _listTable.separatorColor = UIColor.redColor;
    self.listTable.separatorStyle = UITableViewCellSeparatorStyleNone;
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

    self.refreshControl = [[UIRefreshControl alloc]init];
    self.refreshControl.attributedTitle = nil;
    [self.refreshControl addTarget:self action:@selector(getHistoryMessage) forControlEvents:UIControlEventValueChanged];
    [_listTable addSubview:_refreshControl];
    
    __weak ZCChatView *safeSelf = self;
    _fastMenuView = [[ZCFastMenuView alloc] initWithSuperView:self];
    [_fastMenuView setFastMenuBlock:^(ZCLibCusMenu * _Nonnull menu) {
        
        if(menu.menuType == ZCCusMenuTypeConnectUser){
//            [[ZCUICore getUICore] doConnectUserService:nil connectType:ZCTurnType_BtnClick];
            [self->_keyboardTools hideKeyboard];
            [[ZCUICore getUICore] checkUserServiceWithType:ZCTurnType_BtnClick model:nil];
        }else if(menu.menuType == ZCCusMenuTypeOpenUrl){
            [[ZCUICore getUICore] dealWithLinkClickWithLick:menu.labelLink viewController:[SobotUITools getCurrentVC]];
        }else if(menu.menuType == ZCCusMenuTypeLeave){
            // 留言
            [[ZCUICore getUICore] goLeavePage];
        }else if(menu.menuType == ZCCusMenuTypeEvaluetion){
            // 评价
            BOOL isEvalutionAdmin = [ZCUICore getUICore].getLibConfig.isArtificial;
            if(self.keyboardTools.curKeyboardStatus == ZCKeyboardStatusNewSession){
                isEvalutionAdmin = [ZCUICore getUICore].isAdminServerBeforeCloseSession;
            }
            
            [[ZCUICore getUICore] checkSatisfacetion:isEvalutionAdmin type:SatisfactionTypeKeyboard];
        }else if(menu.menuType == ZCCusMenuTypeCloseChat){
            // 结束会话
//            [ZCLibClient closeAndoutZCServer:NO];
//            [safeSelf.keyboardTools setKeyboardMenuByStatus:ZCKeyboardStatusNewSession];
            
            [safeSelf closeChatView:YES];
        }else if(menu.menuType == ZCCusMenuTypeSendMessage || menu.menuType == ZCCusMenuTypeSendRobotMessage){
            // 发送消息
            //question=menuId,fromEnum=5
            //知识库 ，question=标问.questions 菜单名字、,fromEnum=3、4
            // 内部知识库 fromEnum=4，机器人知识库=3，普通问答=5（机器人知识库结果有顶踩转人工，其他没有）
            NSString *fromEnum = @"5";
            if(menu.menuType == ZCCusMenuTypeSendRobotMessage){
                if([menu.robotType intValue] == 1){
                    fromEnum = @"3";
                }else{
                    fromEnum = @"4";
                }
            }
            
            [[ZCUICore getUICore] sendMessage:menu.menuName type:SobotMessageTypeText exParams:@{@"fromEnum":fromEnum,@"question":menu.menuid,@"requestText":menu.menuName,@"docId":menu.menuid,@"questionFlag":@"1"} duration:@""];
        }
    }];
    
    _tableLayoutTop = sobotLayoutPaddingTop(0, _listTable, self);
    [self addConstraint:_tableLayoutTop];
    [self addConstraint:sobotLayoutPaddingLeft(0, _listTable, self)];
    [self addConstraint:sobotLayoutPaddingRight(0, _listTable, self)];
    [self addConstraint:sobotLayoutMarginBottom(0, _listTable, _fastMenuView)];
    
    _keyboardTools = [[ZCUIChatKeyboard alloc] initConfigView:self table:_listTable];
    [_keyboardTools setKeyboardMenuByStatus:ZCKeyboardStatusRobot];
    
    _tableBottomCons = sobotLayoutMarginBottom(0, _fastMenuView, _keyboardTools.zc_bottomView);
    [self addConstraint:_tableBottomCons];
    
    [self changeRobotBtn];
    [self goUnReadButton];
   
    // 转屏通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didChangeRotate:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
}

-(UIButton *)changeRobotBtn{
    if (!_changeRobotBtn) {
        _changeRobotBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_changeRobotBtn];
        _changeRobotBtn.hidden = YES;
        [self addConstraints:sobotLayoutSize(70, 80, _changeRobotBtn, NSLayoutRelationEqual)];
        [self addConstraint:sobotLayoutPaddingBottom(-106, _changeRobotBtn, self.listTable)];
        [self addConstraint:sobotLayoutPaddingRight(-2, _changeRobotBtn, self.listTable)];
        
        _changeRobotBtn_btn1 = [[UIButton alloc]init];
        UIImage *robotimg = SobotKitGetImage(@"zcicon_changerobot");
        [_changeRobotBtn_btn1 setImage:robotimg forState:UIControlStateNormal];
        [_changeRobotBtn_btn1 addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        _changeRobotBtn_btn1.tag = BUTTON_TURNROBOT;
        [_changeRobotBtn addSubview:_changeRobotBtn_btn1];
        
        _changeRobotBtn_btn2 = [[UIButton alloc]init];
        _changeRobotBtn_btn2.backgroundColor = UIColorFromModeColor(SobotColorBgMainDark2);
        _changeRobotBtn_btn2.layer.cornerRadius = 8.0f;
        _changeRobotBtn_btn2.layer.shadowOpacity= 1;
        _changeRobotBtn_btn2.layer.shadowColor = UIColorFromModeColorAlpha(SobotColorTextMain, 0.15).CGColor;
        _changeRobotBtn_btn2.layer.shadowOffset = CGSizeZero;//投影偏移
        _changeRobotBtn_btn2.layer.shadowRadius = 4;
        
        [_changeRobotBtn_btn2 addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        _changeRobotBtn_btn2.tag = BUTTON_TURNROBOT;
        
        NSString *titleStr = [ZCUICore getUICore].kitInfo.changeBusinessStr.length > 0?[ZCUICore getUICore].kitInfo.changeBusinessStr:SobotKitLocalString(@"换业务");
        
        [_changeRobotBtn_btn2 setTitle:titleStr forState:UIControlStateNormal];
        [_changeRobotBtn_btn2.titleLabel setFont:SobotFontBold10];
        
        [_changeRobotBtn_btn2 setTitleColor:[ZCUIKitTools zcgetRobotBtnBgColor] forState:UIControlStateNormal];
        [_changeRobotBtn addSubview:_changeRobotBtn_btn2];
        
        CGSize s = [titleStr sizeWithAttributes:@{NSFontAttributeName:SobotFontBold10}];
        if(s.width > 72){
            s.width = 72-5;
        }
        [self.changeRobotBtn addConstraints:sobotLayoutSize(60, 60, _changeRobotBtn_btn1, NSLayoutRelationEqual)];
        [self.changeRobotBtn addConstraint:sobotLayoutPaddingTop(0, _changeRobotBtn_btn1, self.changeRobotBtn)];
        [self.changeRobotBtn addConstraint:sobotLayoutEqualCenterX(0, _changeRobotBtn_btn1, self.changeRobotBtn)];
        [self.changeRobotBtn addConstraints:sobotLayoutSize(s.width, 16, _changeRobotBtn_btn2, NSLayoutRelationEqual)];
        [self.changeRobotBtn addConstraint:sobotLayoutPaddingBottom(0, _changeRobotBtn_btn2, self.changeRobotBtn)];
        [self.changeRobotBtn addConstraint:sobotLayoutEqualCenterX(0, _changeRobotBtn_btn2, self.changeRobotBtn)];
        _changeRobotBtn.tag = BUTTON_TURNROBOT;
        [_changeRobotBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return  _changeRobotBtn;
}

-(UIButton *)goUnReadButton{
    if(!_goUnReadButton){
        _goUnReadButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [_goUnReadButton setImage:SobotKitGetImage(@"zcicon_newmessages") forState:UIControlStateNormal];
        [_goUnReadButton setImage:SobotKitGetImage(@"zcicon_newmessages") forState:UIControlStateHighlighted];
        
        [_goUnReadButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_goUnReadButton setTitleColor:UIColorFromModeColor(SobotColorTheme) forState:UIControlStateNormal];
        [_goUnReadButton.titleLabel setFont:[ZCUIKitTools zcgetListKitDetailFont]];
        [_goUnReadButton setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        [_goUnReadButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        _goUnReadButton.layer.cornerRadius = 20;
        _goUnReadButton.layer.borderWidth = 0.75f;
        _goUnReadButton.layer.borderColor = UIColorFromModeColor(SobotColorTheme).CGColor;
        _goUnReadButton.layer.masksToBounds = YES;
        [_goUnReadButton setBackgroundColor:[ZCUIKitTools zcgetBgBannerColor]];
        _goUnReadButton.tag = BUTTON_UNREAD;
        [_goUnReadButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_goUnReadButton];
        _goUnReadButton.hidden=YES;
        
        
        [self addConstraints:sobotLayoutSize(120, 40, _goUnReadButton, NSLayoutRelationEqual)];
        [self addConstraint:sobotLayoutPaddingTop(40, _goUnReadButton, self.listTable)];
        [self addConstraint:sobotLayoutPaddingRight(-20, _goUnReadButton, self.listTable)];
    }
    return _goUnReadButton;
}

#pragma mark 新消息和切换机器人按钮事件
-(void)buttonClick:(UIButton *)sender{
    // 未读消息数
    if(sender.tag == BUTTON_UNREAD){
        self.goUnReadButton.hidden = YES;
        int unNum = [[ZCIMChat getZCIMChat] getUnReadNum];
        if(unNum<=[ZCUICore getUICore].chatMessages.count){
            CGRect  popoverRect = [_listTable rectForRowAtIndexPath:[NSIndexPath indexPathForRow:([ZCUICore getUICore].chatMessages.count - unNum) inSection:0]];
            [_listTable setContentOffset:CGPointMake(0,popoverRect.origin.y-40) animated:NO];
        }
        
    }
    
    // 切换机器人
    if (sender.tag == BUTTON_TURNROBOT) {
        sender.enabled = NO;
        
        [_keyboardTools hideKeyboard];
        if (_changeRobotView) {
            sender.enabled = YES;
            return;
        }
         __weak  ZCChatView * safeView = self;
        [ZCLibServer getrobotlist:[self getPlatformInfo].config start:^{
            
        } success:^(NSDictionary *dict, ZCMessageSendCode sendCode) {
            sender.enabled = YES;
             @try{
                 NSMutableArray * listaArr = [NSMutableArray arrayWithCapacity:0];
                 NSArray * arr = dict[@"data"][@"list"];
                 if (arr.count == 0) {
                     return ;
                 }
                for (NSDictionary * Dic in arr) {
                    ZCLibRobotSet * model = [[ZCLibRobotSet alloc]initWithMyDict:Dic];
                    [listaArr addObject:model];
                }
                 
                 // 已经存在，不重复创建
                 if(safeView.changeRobotView!=nil){
                     return;
                 }
                 
                safeView.changeRobotView = [[ZCTurnRobotView alloc]initActionSheet:listaArr WithView:self RobotId:[safeView getPlatformInfo].config.robotFlag];
         
                [safeView.changeRobotView showInView:self];
               
                safeView.changeRobotView.robotSetClickBlock = ^(ZCLibRobotSet *itemModel) {
                    safeView.changeRobotView = nil;
                    if (itemModel == nil) {
                        return ;
                    }
                    if ([itemModel.robotFlag intValue] == [safeView getZCIMConfig].robotFlag) {
                        return ;
                    }else{
                        
                        [safeView getPlatformInfo].config.robotFlag = [itemModel.robotFlag intValue];
                        [safeView getZCIMConfig].robotName = itemModel.robotName;
                        [safeView getZCIMConfig].robotLogo = itemModel.robotLog;
                        [safeView getZCIMConfig].robotFlag = [itemModel.robotFlag intValue];
                        
                        [self getPlatformInfo].config.robotName = itemModel.robotName;
                        // 自定义喜欢有有，不设置
                        if(sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.robot_hello_word).length == 0){
                            // 切换机器人，切换每个机器人的欢迎语
                            [self getPlatformInfo].config.robotHelloWord = itemModel.robotHelloWord;
                        }
                        if(itemModel.guideFlag){
                            [self getPlatformInfo].config.guideFlag = 1;
                        }else{
                            [self getPlatformInfo].config.guideFlag = 0;
                        }
                        [ZCUICore getUICore].getLibConfig.sessionPhaseAndFaqIdRespVos = itemModel.sessionPhaseAndFaqIdRespVos;
                        [ZCUICore getUICore].isShowRobotHello = NO;
                        [ZCUICore getUICore].isSendToRobot = NO;
                        [ZCUICore getUICore].isShowRobotGuide = NO;
                        [[ZCUICore getUICore] sendMessageWithConnectStatus:ZCServerConnectRobot];
                        [self.fastMenuView refreshData];
                    }
                    
                };
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
        } fail:^(NSString *errorMsg, ZCMessageSendCode errorCode) {
            NSLog(@"%@",errorMsg);
            sender.enabled = YES;
        }];
        
        
    }
}

#pragma  mark -- 状态提醒UI
-(UIButton *)newWorkStatusButton{
    if(!_newWorkStatusButton){
        _newWorkStatusButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_newWorkStatusButton];
        
        [self addConstraint:sobotLayoutPaddingTop(0, self.newWorkStatusButton, self.listTable)];
        [self addConstraint:sobotLayoutPaddingLeft(0, self.newWorkStatusButton, self)];
        [self addConstraint:sobotLayoutPaddingRight(0, self.newWorkStatusButton, self)];
        [self addConstraint:sobotLayoutEqualHeight(40, self.newWorkStatusButton, NSLayoutRelationEqual)];
        
        [_newWorkStatusButton setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
        [_newWorkStatusButton setImage:SobotKitGetImage(@"zcicon_tag_nonet") forState:UIControlStateNormal];
        [_newWorkStatusButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_newWorkStatusButton setBackgroundColor:SobotColorFromRGBAlpha(BgNetworkFailColor, 0.8)];
        [_newWorkStatusButton setTitle:[NSString stringWithFormat:@" %@",SobotKitLocalString(@"当前网络不可用，请检查您的网络设置")] forState:UIControlStateNormal];
        [_newWorkStatusButton setTitleColor:SobotColorFromRGB(TextNetworkTipColor) forState:UIControlStateNormal];
        [_newWorkStatusButton.titleLabel setFont:SobotFont15];
        [_newWorkStatusButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        
        
        _newWorkStatusButton.hidden=YES;
    }
    return _newWorkStatusButton;
}

-(UIButton *)socketStatusButton{
    if(!_socketStatusButton){
        _socketStatusButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_socketStatusButton];
        
        
        [self addConstraint:sobotLayoutPaddingTop(0, self.socketStatusButton, self.listTable)];
        [self addConstraint:sobotLayoutPaddingLeft(0, self.socketStatusButton, self)];
        [self addConstraint:sobotLayoutPaddingRight(0, self.socketStatusButton, self)];
        [self addConstraint:sobotLayoutEqualHeight(40, self.socketStatusButton, NSLayoutRelationEqual)];
        
//        [_socketStatusButton setFrame:CGRectMake(60, SSY, CGRectGetWidth(self.frame)-120, 44)];
        [_socketStatusButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_socketStatusButton setBackgroundColor:[ZCUIKitTools zcgetBgBannerColor]];
        if ([ZCUICore getUICore].kitInfo.topViewBgColor != nil) {
            [_socketStatusButton setBackgroundColor:[ZCUICore getUICore].kitInfo.topViewBgColor];
        }
        [_socketStatusButton setTitle:[NSString stringWithFormat:@"  %@",SobotKitLocalString(@"收取中...")] forState:UIControlStateNormal];
        [_socketStatusButton setTitleColor:[ZCUIKitTools zcgetTextNolColor] forState:UIControlStateNormal];
        [_socketStatusButton.titleLabel setFont:[ZCUIKitTools zcgetTitleFont]];
        [_socketStatusButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        
        _socketStatusButton.hidden=YES;
        
        UIActivityIndicatorView *_activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityView.hidden=YES;
        _activityView.tag = 1;
        _activityView.center = CGPointMake(_socketStatusButton.frame.size.width/2 - 50, 20);
        [_socketStatusButton addSubview:_activityView];
        [self addConstraint:sobotLayoutEqualCenterY(0,_activityView, self.socketStatusButton)];
        [self addConstraint:sobotLayoutEqualCenterX(-50,_activityView, self.socketStatusButton)];
    }
    return _socketStatusButton;
    
    
}

#pragma mark -- 通告栏 eg: “国庆大酬宾。

- (void)openNoticeWebView:(UITapGestureRecognizer*)tap{
      [_keyboardTools hideKeyboard];
    if (sobotConvertToString([self getZCIMConfig].announceClickUrl).length >0 && [self getZCIMConfig].announceClickFlag == 1) {
        [self cellItemClick:nil type:ZCChatCellClickTypeOpenURL text:@"" obj:[self getZCIMConfig].announceClickUrl];
    }
}
- (UIView *)notifitionTopViewWithisShowTopView{
    if ([[ZCUICore getUICore] getLibConfig].announceMsgFlag == 1 && [[ZCUICore getUICore] getLibConfig].announceTopFlag == 1) {
        NSString *title = [self getPlatformInfo].config.announceMsg;
        NSString *icoUrl = [ZCLibClient getZCLibClient].libInitInfo.notifition_icon_url;
        if (!_notifitionTopView && ![@"" isEqual:sobotConvertToString(title)]) {
            _notifitionTopView = [[UIView alloc]init];
            _notifitionTopView.backgroundColor = [ZCUIKitTools getNotifitionTopViewBgColor];
            _notifitionTopView.alpha = 0.8;
      
            UITapGestureRecognizer * tapAction = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openNoticeWebView:)];
            [_notifitionTopView addGestureRecognizer:tapAction];
            [self addSubview:_notifitionTopView];
            _notifitionTopView.hidden = NO;
            
            [self addConstraint:sobotLayoutPaddingTop(0, self.notifitionTopView, self)];
            [self addConstraint:sobotLayoutPaddingLeft(0, self.notifitionTopView, self)];
            [self addConstraint:sobotLayoutPaddingRight(0, self.notifitionTopView, self)];
            [self addConstraint:sobotLayoutEqualHeight(36, self.notifitionTopView, NSLayoutRelationEqual)];
            
            
            // icon
            SobotImageView * icon = [[SobotImageView alloc]init];
            if (![@"" isEqual:sobotConvertToString(icoUrl)]) {
                [icon loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(icoUrl)] placeholer:SobotKitGetImage(@"zcicon_annunciate") showActivityIndicatorView:NO];
            }else{
                [icon setImage:SobotKitGetImage(@"zcicon_annunciate")];
            }
            
            icon.contentMode = UIViewContentModeScaleAspectFill;
            [icon setBackgroundColor:[UIColor clearColor]];
            [icon addGestureRecognizer:tapAction];
            [_notifitionTopView addSubview:icon];
            [_notifitionTopView addConstraint:sobotLayoutEqualCenterY(0, icon, self.notifitionTopView)];
            [_notifitionTopView addConstraint:sobotLayoutPaddingLeft(10, icon, self.notifitionTopView)];
            [_notifitionTopView addConstraints:sobotLayoutSize(14, 14, icon, NSLayoutRelationEqual)];
            
            UIView *bgView = [[UIView alloc]init];
            bgView.layer.masksToBounds = YES;
            [_notifitionTopView addSubview:bgView];
            [_notifitionTopView addConstraint:sobotLayoutPaddingTop(8, bgView, self.notifitionTopView)];
            [_notifitionTopView addConstraint:sobotLayoutMarginLeft(10, bgView, icon)];
            [_notifitionTopView addConstraint:sobotLayoutPaddingRight(-10, bgView, self.notifitionTopView)];
            [_notifitionTopView addConstraint:sobotLayoutEqualHeight(20, bgView, NSLayoutRelationEqual)];

            
            CGFloat animateWidth = ScreenWidth - 30 - 10;
            // 跑马灯label
            UILabel *titleLab = [[UILabel alloc]init];
            titleLab.font = SobotFont14;
            titleLab.textColor = [ZCUIKitTools getNotifitionTopViewLabelColor];
            [titleLab addGestureRecognizer:tapAction];
            [bgView addSubview:titleLab];
            
            [bgView addConstraint:sobotLayoutPaddingTop(0, titleLab, bgView)];
            [bgView addConstraint:sobotLayoutPaddingLeft(10, titleLab, bgView)];
            [bgView addConstraint:sobotLayoutEqualHeight(20, titleLab, NSLayoutRelationEqual)];

            
            
            // 过滤 html标签
            NSString * text = [SobotHtmlCore filterHTMLTag:title];
            titleLab.text = text;
            [titleLab sizeToFit];
//            [titleLab layoutIfNeeded];
            // 关闭跑马灯效果,2.8.0最大20字
            if (titleLab.frame.size.width > animateWidth) {
                [self aniantionsNotice:titleLab];
            }else{
                [titleLab setTextAlignment:NSTextAlignmentLeft];
            }
        
            if (sobotConvertToString([self getZCIMConfig].announceClickUrl).length >0 && [self getZCIMConfig].announceClickFlag == 1) {
                titleLab.textColor = UIColorFromModeColor(SobotColorYellow);

            }else{
                titleLab.textColor = [ZCUIKitTools getNotifitionTopViewLabelColor];
            }

            // table置顶添加40的高度
            _tableLayoutTop.constant = 36;
            
            [self layoutIfNeeded];
            
        }
    }
    return _notifitionTopView;
}

-(void)aniantionsNotice:(UILabel *) titleLab{
    if (!_notifitionTopView.hidden) {
        CGFloat baseWidth = ScreenWidth - 40;
        [UIView beginAnimations:@"Marquee" context:NULL];
//        [UIView setAnimationDuration:CGRectGetWidth(titleLab.frame) / 30.f * (1 / 1.0f)];
        CGFloat duration = (titleLab.frame.size.width - baseWidth) / 30.f * (1 / 1.0f);
        if(duration < 2){
            duration = 2.0;
        }
        [UIView setAnimationDuration:duration];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationRepeatAutoreverses:NO];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationRepeatCount:MAXFLOAT];

        CGRect frame = titleLab.frame;
        frame.origin.x = -(frame.size.width - baseWidth + 30);
//        frame.origin.x = -frame.size.width;
        titleLab.frame = frame;
        [UIView commitAnimations];
    }
}
#pragma mark - 清空历史记录之后刷新页面
-(void)roadData{
    [self.listTable reloadData];
}

- (void)didChangeRotate:(NSNotification*)notice {
    // 旋转时，隐藏技能组
    if([[ZCUICore getUICore] getGroupView]!=nil){
        [[ZCUICore getUICore] dismissGroupView];
    }
    [_keyboardTools hideKeyboard];
}

#pragma mark ZCUICore Delegate

#pragma mark - 获取默认的头像
-(NSString*)getDefultTitleImg{
    NSString *imageUrl = @"";
    if([self getZCIMConfig].isArtificial){
        imageUrl = [self getZCIMConfig].senderFace;
    }else{
        if([self getZCIMConfig].type != 2){
            imageUrl = [self getZCIMConfig].robotLogo;
        }
    }
    return sobotConvertToString(imageUrl);
}

#pragma mark - 获取默认接待客服昵称
-(NSString*)getDefultNickTitle{
    NSString *nick = @"";
    if([self getZCIMConfig].isArtificial){
        nick = [self getZCIMConfig].senderName;
    }else{
        if([self getZCIMConfig].type != 2){
            nick = [self getZCIMConfig].robotName;
        }
    }
    return nick;
}

#pragma mark - 设置昵称
-(void)setTitleName:(NSString *)titleName{
    NSString *imageUrl = @"";
    NSString *placeholderName = titleName;
    NSString *nickTitle = @"";
    NSString *companyTitle = @"";
    NSString *title = @"";
    int imgSizeType = [[ZCUICore getUICore] getLibConfig].topBarType;
 #pragma mark - 用户头像
    // 用户自定义显示头像
    if ([ZCUICore getUICore].kitInfo.isShowTitleViewImg) {
        imageUrl = sobotConvertToString([ZCUICore getUICore].kitInfo.custom_title_url);
    }else{
        // 先查看 导航条样式  1展示接待客服+企业名称    2.展示企业信息 +接待状态
        if ([[ZCUICore getUICore] getLibConfig].topBarType == 1) {
            if ([[ZCUICore getUICore] getLibConfig].topBarStaffPhotoFlag) {
                // 开启了客服头像开关  显示当前接待的客服头像
              imageUrl = [self getDefultTitleImg];
                // 处理特殊情况
                if ([placeholderName isEqualToString:SobotKitLocalString(@"排队中...")]) {
                    // 显示企业logo
                    if ([[ZCUICore getUICore] getLibConfig].topBarCompanyLogoFlag) {
                        imageUrl = sobotConvertToString([[ZCUICore getUICore] getLibConfig].topBarCompanyLogoUrl);
                    }
                }
            }
        }else if([[ZCUICore getUICore] getLibConfig].topBarType == 2){
            if ([[ZCUICore getUICore] getLibConfig].topBarCompanyLogoFlag) {
                imageUrl = sobotConvertToString([[ZCUICore getUICore] getLibConfig].topBarCompanyLogoUrl);
//                imgSizeType = 2;
            }
        }else{
            // 设置SDK默认 0 PC端没有设置
            imageUrl = [self getDefultTitleImg];
        }
    }
 #pragma mark - 接待客服名称
    // 用户自定义 接待客服昵称
    if ([ZCUICore getUICore].kitInfo.isShowTitleViewNick) {
        nickTitle = sobotConvertToString([ZCUICore getUICore].kitInfo.custom_nick_title);
    }else{
        // 先查看 导航条样式  1展示接待客服+企业名称
        if ([[ZCUICore getUICore] getLibConfig].topBarType == 1){
            if ([[ZCUICore getUICore] getLibConfig].topBarStaffNickFlag) {
                // 显示客服昵称
                nickTitle = [self getDefultNickTitle];
            }
        //  2.展示企业信息 +接待状态
        }else if ([[ZCUICore getUICore] getLibConfig].topBarType == 2){
            nickTitle = @"";
        }else{
            //显示 SDK默认值
            nickTitle = [self getDefultNickTitle];
        }
    }
 #pragma mark - 企业名称
    // 用户自定义 接待企业名称
    if ([ZCUICore getUICore].kitInfo.isShowTitleViewCompanyName) {
        companyTitle = sobotConvertToString([ZCUICore getUICore].kitInfo.custom_company_title);
    }else{
        if ([[ZCUICore getUICore] getLibConfig].topBarType == 1){
            if ([[ZCUICore getUICore] getLibConfig].topBarCompanyNameFlag) {
                companyTitle = sobotConvertToString([[ZCUICore getUICore] getLibConfig].topBarCompanyName);
            }
        }else if ([[ZCUICore getUICore] getLibConfig].topBarType == 2){
            if ([[ZCUICore getUICore] getLibConfig].topBarCompanyNameFlag) {
                companyTitle = sobotConvertToString([[ZCUICore getUICore] getLibConfig].topBarCompanyName);
//                companyTitle = @"";// 状态2 不显示企业昵称
            }
        }else{
            companyTitle = [self getZCIMConfig].companyName;
        }
    }
    
    // 当延迟转人工没有头像时，设置默认头像
    if([self getZCIMConfig].invalidSessionFlag && sobotConvertToString(imageUrl).length == 0 && sobotConvertToString(titleName).length == 0 && [self getZCIMConfig].type == 2){
        imageUrl = @"zcicon_useravatart_girl";
    }
    if ([[ZCUICore getUICore] getLibConfig].topBarType == 2) {
        if (sobotConvertToString(imageUrl).length > 0) {
            companyTitle = @""; // 有头像就不在显示昵称，如果只有企业昵称是要显示的
        }
    }
    
    if ([placeholderName isEqualToString:SobotKitLocalString(@"排队中...")]) {
        title = SobotKitLocalString(@"排队中...");
        nickTitle = @"";
        companyTitle = @"";
    }else if ([placeholderName isEqualToString:SobotKitLocalString(@"暂无客服在线")]){
        title = SobotKitLocalString(@"暂无客服在线");
        nickTitle = @"";
        companyTitle = @"";
    }
    
    // 当前页面没有导航栏，都在VC中
    if (self.delegate && [self.delegate respondsToSelector:@selector(onTitleChanged:imageUrl:nick:company:topBarType:)]) {
        [self.delegate onTitleChanged:title imageUrl:imageUrl nick:nickTitle company:companyTitle topBarType:imgSizeType];
    }
    
}

#pragma mark - 连接状态变化
-(void)showSoketConentStatus:(ZCConnectStatusCode)statusCode{
    // 连接中
    if(statusCode == ZCConnectStatusCode_START){
        UIButton *btn = [self socketStatusButton];
        [btn setTitle:[NSString stringWithFormat:@"  %@",SobotKitLocalString(@"连接中...")] forState:UIControlStateNormal];
        UIActivityIndicatorView *activityView  = [btn viewWithTag:1];
        btn.hidden = NO;
        activityView.hidden = NO;
        [activityView startAnimating];
        
        
        // 机器人时，不显示
        if(![self getZCIMConfig].isArtificial){
            btn.hidden = YES;
        }
        
    }else{
        UIButton *btn = [self socketStatusButton];
        UIActivityIndicatorView *activityView  = [btn viewWithTag:1];
        [activityView stopAnimating];
        activityView.hidden = YES;
        
        if(statusCode == ZCConnectStatusCode_SUCCESS){
            btn.hidden = YES;
        }else{
            if([self getZCIMConfig].isArtificial){
                btn.hidden = NO;
                [self bringSubviewToFront:btn];
                [btn setTitle:[NSString stringWithFormat:@"%@",SobotKitLocalString(@"未连接")] forState:UIControlStateNormal];
            }else{
                btn.hidden = YES;
            }
        }
    }
}

-(void)onPageStatusChanged:(ZCShowStatus)status message:(NSString *)message obj:(id)object other:(NSDictionary *)otherObj{
    if(status == ZCShowStatusOpenAskTable){
        if(isOpenNewPage){
            return;
        }
        
        //@{@"type":@(type),@"model":msgModel,@"dict":dict}
        NSDictionary *p = otherObj;
        isOpenNewPage = YES;
        ZCUIAskTableController * askVC = [[ZCUIAskTableController alloc]init];
        askVC.dict = p[@"dict"];
        if (sobotConvertToString(message).length > 0) {
            askVC.isclearskillId = YES;
        }
        [askVC setTrunServerBlock:^(BOOL isback) {
            self->isOpenNewPage = NO;
            if (isback && [[ZCUICore getUICore] getLibConfig].type == 2) {
                // 返回当前页面 结束会话回到启动页面
                [self backChatView];
                if(self.delegate && [self.delegate respondsToSelector:@selector(onBackFinish:closeClick:)]){
                    [self.delegate onBackFinish:YES closeClick:YES];
                 }
            }else{
                if (isback) {
                    return ;
                }else{
                    // 去执行转人工的操作
                    [[ZCUICore getUICore] doConnectUserService:object connectType:[p[@"type"] intValue]];
                }
            }
        }];
        
        [self openNewPage:askVC];
    }
}

-(void)onPageStatusChanged:(ZCShowStatus)status message:(NSString *)message obj:(id)object{
    if(status == ZCShowStatusConnectingUser){
//        _keyboardTools.btnConnectUser.enabled = NO;
    }else if(status == ZCShowLeaveEditViewWithTempleteId){
        [self showQuickLeaveView:object tempId:message];
    }else if(status == ZCShowStatusReConnectClick){
        // 清楚记录，重新初始化
        ZCPlatformInfo *info = [[ZCPlatformTools sharedInstance] getPlatformInfo];
        info.checkInitKey = @"";
        [[ZCPlatformTools sharedInstance] savePlatformInfo:info];
        //  要去初始化啊
        [self doSDKConfig];
    }else if(status == ZCShowStatusLeaveMsgPage){
        [[ZCUICore getUICore] openLeaveOrRecoredVC:NO dict:nil];
    }else if(status == ZCShowStatusLeaveOpenWithClose){
        [[ZCUICore getUICore] openLeaveOrRecoredVC:NO dict:@{@"msg": sobotConvertToString(message)}];
        
    }// 超过一定数量显示未读消息点击效果
    else if(status == ZCShowStatusUnRead){
        [self.goUnReadButton setTitle:message forState:UIControlStateNormal];
        self.goUnReadButton.hidden = NO;
    }else if(status == ZCShowStatusConnectFinished){
//        _keyboardTools.btnConnectUser.enabled = YES;
        
        [[ZCUICore getUICore] dismissGroupView];
        
        
    }else if(status == ZCShowStatusSatisfaction){
        [_keyboardTools hideKeyboard];
        
    }else if(status == ZCShowStatusGoBack){
        if(self.delegate && [self.delegate respondsToSelector:@selector(onBackFinish:closeClick:)]){
            NSDictionary *params = object;
            [self.delegate onBackFinish:[params[@"isFinish"] intValue] closeClick:[params[@"isClose"] intValue]];
         }
    }
    else if (status == ZCShowStatusReConnected) {
        // 新会话
        // 新的会话要将上一次的数据清空全部初始化在重新拉取
        [_listTable reloadData];
//        _isHadLoadHistory = NO;
        // 将仅人工模式 如果是延迟转人工开启 参数回执
        [_keyboardTools setKeyboardMenuByStatus:ZCKeyboardStatusNewSession];
        
        // 键盘状态发生变化了，需要重新设置table的高度，因为新会话的键盘高度变化了
        [self tableScrollToBottom];
        // 重新加载数据
        return;
    }else if(status == ZCShowTextHeightChanged){
        [self tableScrollToBottom];
    }else if(status == ZCSetKeyBoardStatus){
        ZCKeyboardViewStatus state = [object intValue];
        [_keyboardTools setKeyboardMenuByStatus:state];
        
        if(state == ZCKeyboardStatusUser){
            [_fastMenuView refreshData];
            
            self.changeRobotBtn.hidden  = YES;
        }else if(state == ZCKeyboardStatusRobot){
            [_fastMenuView refreshData];
            // 是否显示 多机器人按钮
            if ([self getZCIMConfig].robotSwitchFlag == 1) {
                if ([self getZCIMConfig].type != 2 && ![self getZCIMConfig].isArtificial) {
                    self->_changeRobotBtn.hidden = NO;
                    [self->_changeRobotBtn_btn2 setTitleColor:[ZCUIKitTools zcgetRobotBtnBgColor] forState:UIControlStateNormal];
                    UIImage *robotimg = SobotKitGetImage(@"zcicon_changerobot");
                    [self->_changeRobotBtn_btn1 setImage:[self imageChangeColor:[ZCUIKitTools zcgetRobotBtnBgColor] chageImg:robotimg] forState:UIControlStateNormal];
                }else{
                    self->_changeRobotBtn.hidden = YES;
                }
            }else{
                self->_changeRobotBtn.hidden = YES;
            }
        }
    }else if(status == ZCShowStatusCloseSkillSet){
        [[ZCUICore getUICore] dismissGroupView];
    }else if(status == ZCShowStatusAddMessage || status ==  ZCShowStatusMessageChanged || status == ZCShowStatusCompleteNoMore){
        // 有新消息、消息列表改变
        
        if(status == ZCShowStatusCompleteNoMore){
            [self.refreshControl removeFromSuperview];
        }

        [_listTable reloadData];
        
        if(self.refreshControl.refreshing){
            [self.refreshControl endRefreshing];
        }else{
            if([ZCUICore getUICore].chatMessages.count != lastMsgCount){
                lastMsgCount = [ZCUICore getUICore].chatMessages.count;

                [self tableScrollToBottom];
            }
        }
        
        return;
    }
    
}

-(void)showQuickLeaveView:(SobotChatMessage *) object tempId:(NSString *) message{
    if(_leaveEditView){
        [_leaveEditView tappedCancel:YES];
        _leaveEditView = nil;
    }
    __block ZCChatView *safeSelf = self;
    if (sobotConvertToString(message).length <= 0) {
        return;
    }
    _leaveEditView = [[ZCQuickLeaveView alloc] initActionSheet:self withController:[SobotUITools getCurrentVC]];
    _leaveEditView.templateldIdDic = @{@"templateId":sobotConvertToString(message)};
    [_leaveEditView setResultBlock:^(int code, id  _Nonnull obj) {
        [safeSelf.leaveEditView tappedCancel:YES];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [safeSelf.keyboardTools hideKeyboard];
        });
        
        // 添加成功
        if(code == 1){
            NSString *uploadMessage = obj;
            uploadMessage = [uploadMessage stringByReplacingOccurrencesOfString:@"$\n$" withString:@"<br/>"];
            uploadMessage = [uploadMessage stringByReplacingOccurrencesOfString:@"$:$" withString:@"<br/>"];
//                //如果开启了
            [ZCLibServer insertSysMsg:[safeSelf getZCIMConfig] title:@"多轮对话工单提交确认提示" msg:uploadMessage start:^(NSString *url){
                
            } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
                if (![safeSelf getZCIMConfig].isArtificial) {
                    [[ZCUICore getUICore] addMessageToList:SobotMessageActionTypeLeaveSuccess content:obj type:SobotMessageTypeTipsText dict:nil];
                }
            } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
                
            }];
        }
    }];
    [[SobotToast shareToast] showProgress:@"" with:self];
    
   static BOOL isJump = NO;
    // 线程处理
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    NSString *tempUid = [self getZCIMConfig].uid;
    if (sobotConvertToString([self getZCIMConfig].uid).length > 0) {
        tempUid = sobotConvertToString([self getZCIMConfig].uid);
    }
    // 加载基础模板接口
    [ZCLibServer postMsgTemplateConfigWithUid:tempUid Templateld:message start:^{
        
    } success:^(NSDictionary *dict,NSMutableArray * typeArr, ZCNetWorkCode sendCode) {
        safeSelf.leaveEditView.tickeTypeFlag = [ sobotConvertToString( dict[@"data"][@"item"][@"ticketTypeFlag"] )intValue];
        safeSelf.leaveEditView.ticketTypeId = sobotConvertToString( dict[@"data"][@"item"][@"ticketTypeId"]);
        safeSelf.leaveEditView.telFlag = [sobotConvertToString( dict[@"data"][@"item"][@"telFlag"]) boolValue];
        safeSelf.leaveEditView.telShowFlag = [sobotConvertToString(dict[@"data"][@"item"][@"telShowFlag"]) boolValue];
        safeSelf.leaveEditView.emailFlag = [sobotConvertToString(dict[@"data"][@"item"][@"emailFlag"]) boolValue];
        safeSelf.leaveEditView.emailShowFlag = [sobotConvertToString(dict[@"data"][@"item"][@"emailShowFlag"]) boolValue];
        safeSelf.leaveEditView.enclosureFlag = [sobotConvertToString(dict[@"data"][@"item"][@"enclosureFlag"]) boolValue];
        safeSelf.leaveEditView.enclosureShowFlag = [sobotConvertToString(dict[@"data"][@"item"][@"enclosureShowFlag"]) boolValue];
//            safeSelf.leaveEditView.ticketShowFlag = [sobotConvertToString(dict[@"data"][@"item"][@"ticketShowFlag"]) intValue];
        safeSelf.leaveEditView.ticketTitleShowFlag = [sobotConvertToString(dict[@"data"][@"item"][@"ticketTitleShowFlag"]) boolValue];
        
        safeSelf.leaveEditView.msgTmp = sobotConvertToString(dict[@"data"][@"item"][@"msgTmp"]);
        safeSelf.leaveEditView.msgTxt = sobotConvertToString(dict[@"data"][@"item"][@"msgTxt"]);
        if (typeArr.count) {
            if (safeSelf.leaveEditView.typeArr == nil) {
                safeSelf.leaveEditView.typeArr = [NSMutableArray arrayWithCapacity:0];
                safeSelf.leaveEditView.typeArr = typeArr;
            }
        }
        if ([dict[@"data"][@"retCode"] isEqualToString:@"000000"]) {
            isJump = YES;
        }else{
            isJump = NO;
        }
        dispatch_group_leave(group);
    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[SobotToast shareToast] showToast:SobotKitLocalString(@"网络错误，请检查网络后重试") duration:1.0f position:SobotToastPositionCenter];

        });
        dispatch_group_leave(group);
    }];


    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        [[SobotToast shareToast] dismisProgress];
        if (isJump) {
            [safeSelf.leaveEditView showEditView];
        }
    });
}

-(void)openNewPage:(UIViewController *) vc{
   if ([SobotUITools getCurrentVC].navigationController) {
//            vc.isNavOpen = YES;
        [[SobotUITools getCurrentVC].navigationController pushViewController:vc animated:YES];
    }else{
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
//            vc.isNavOpen = NO;
        nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [[SobotUITools getCurrentVC]  presentViewController:nav animated:YES completion:^{
            
        }];
        
    }
}


-(void)tableScrollToBottom{
    if([ZCUICore getUICore].chatMessages.count <= 0){
        return;
    }
    // 等待reloadData执行完成，或者使用[self.listTable layoutIfNeeded];
//    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *lastMessage = [NSIndexPath indexPathForRow:[[ZCUICore getUICore].chatMessages count]-1 inSection:0];
        // 滚动到底部
        [self.listTable scrollToRowAtIndexPath:lastMessage atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        // 选中底部
//        [self.listTable selectRowAtIndexPath:lastMessage animated:YES scrollPosition:UITableViewScrollPositionBottom];
//    });
}

#pragma mark ZCUICore Delegate end
-(void)getHistoryMessage{
    [[ZCUICore getUICore] getChatMessages];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [_keyboardTools hideKeyboard];
    // 隐藏复制小气泡
    [[NSNotificationCenter defaultCenter] postNotificationName:UIMenuControllerDidHideMenuNotification object:nil];
}

#pragma mark - tableView 代理事件
// 返回section数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


// 返回section 的View
//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
//    
//    return headerView;
//}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [ZCUICore getUICore].chatMessages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    SobotCallTaskEntity *item = [_listArray objectAtIndex:indexPath.row];
    ZCChatBaseCell *cell=nil;
    //  解决数组越界问题
    if ( indexPath.row >= [ZCUICore getUICore].chatMessages.count) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ZCChatRichCell"];
        if (cell == nil) {
            cell = [[ZCChatRichCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatRichCell"];
        }
        return cell;
    }
    SobotChatMessage *model=[[ZCUICore getUICore].chatMessages objectAtIndex:indexPath.row];

    cell = [tableView dequeueReusableCellWithIdentifier:@"ZCChatTextCell"];
    if (cell == nil) {
        cell = [[ZCChatTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatTextCell"];
    }
    if(model.msgType == SobotMessageTypeSound || model.msgType == SobotMessageTypeStartSound){
        cell = [tableView dequeueReusableCellWithIdentifier:@"ZCChatVoiceCell"];
        if (cell == nil) {
            cell = [[ZCChatVoiceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatVoiceCell"];
        }
    }else if(model.msgType == SobotMessageTypeTipsText){
        if(model.action == SobotMessageActionTypeNotice){
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"ZCChatNoticeCell"];
            if (cell == nil) {
                cell = [[ZCChatNoticeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatNoticeCell"];
            }
        }else if(model.action == SobotMessageActionTypeLeaveSuccess){
            cell = (ZCChatNoticeLeaveCell *)[tableView dequeueReusableCellWithIdentifier:@"ZCChatNoticeLeaveCell"];
            if (cell == nil) {
                cell = [[ZCChatNoticeLeaveCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatNoticeLeaveCell"];
            }
        }else if(model.action == SobotMessageActionTypeOnline){
//            cell = (ZCChatOnlineTipsCell *)[tableView dequeueReusableCellWithIdentifier:@"ZCChatOnlineTipsCell"];
//            if (cell == nil) {
//                cell = [[ZCChatOnlineTipsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatOnlineTipsCell"];
//            }
            // 暂时保留，后期有可能使用
            cell = [tableView dequeueReusableCellWithIdentifier:@"ZCChatTipsCell"];
            if (cell == nil) {
                cell = [[ZCChatTipsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatTipsCell"];
            }
            
        }else if(model.action == SobotMessageActionTypeSendGoods){
            cell = (ZCChatSendGoodsCell *)[tableView dequeueReusableCellWithIdentifier:@"ZCChatSendGoodsCell"];
            if (cell == nil) {
                cell = [[ZCChatSendGoodsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatSendGoodsCell"];
            }
        }else if(model.action == SobotMessageActionTypeEvaluation){
            cell = (ZCChatEvaluationCell *)[tableView dequeueReusableCellWithIdentifier:@"ZCChatEvaluationCell"];
            if (cell == nil) {
                cell = [[ZCChatEvaluationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatEvaluationCell"];
            }
        }else{
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"ZCChatTipsCell"];
            if (cell == nil) {
                cell = [[ZCChatTipsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatTipsCell"];
            }
        }
    }else if(model.msgType == SobotMessageTypeVideo || model.msgType == SobotMessageTypePhoto){
        cell = [tableView dequeueReusableCellWithIdentifier:@"ZCChatPhotoVideoCell"];
        if (cell == nil) {
            cell = [[ZCChatPhotoVideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatPhotoVideoCell"];
        }
    }else if(model.msgType == SobotMessageTypeHotGuide){
        cell = [tableView dequeueReusableCellWithIdentifier:@"ZCChatHotGuideCell"];
        if (cell == nil) {
            cell = [[ZCChatHotGuideCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatHotGuideCell"];
        }
    }else if (model.msgType == SobotMessageTypeCard){
        cell = (ZCChatGoodsCardCell*)[tableView dequeueReusableCellWithIdentifier:@"ZCChatGoodsCardCell"];
        if (cell == nil) {
            cell = [[ZCChatGoodsCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatGoodsCardCell"];
        }
    }else if (model.msgType == SobotMessageTypeOrder){
        cell = (ZCChatOrderCardCell*)[tableView dequeueReusableCellWithIdentifier:@"ZCChatOrderCardCell"];
        if (cell == nil) {
            cell = [[ZCChatOrderCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatOrderCardCell"];
        }
    }else if (model.msgType == SobotMessageTypeLocation){
        cell = (ZCChatLocationCell*)[tableView dequeueReusableCellWithIdentifier:@"ZCChatLocationCell"];
        if (cell == nil) {
            cell = [[ZCChatLocationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatLocationCell"];
        }
    }else if (model.msgType == SobotMessageTypeFile){
        cell = (ZCChatFileCell*)[tableView dequeueReusableCellWithIdentifier:@"ZCChatFileCell"];
        if (cell == nil) {
            cell = [[ZCChatFileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatFileCell"];
        }
    }else if(model.msgType == SobotMessageTypeRichJson){
        if(model.richModel.type == SobotMessageRichJsonTypeLoop){
            if(model.richModel.richContent.templateId <= 2){
                cell = [tableView dequeueReusableCellWithIdentifier:@"ZCChatWheel123Cell"];
                if (cell == nil) {
                    cell = [[ZCChatWheel123Cell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatWheel123Cell"];
                }
            }
            if(model.richModel.richContent.templateId == 3){
                cell = [tableView dequeueReusableCellWithIdentifier:@"ZCChatWheel4Cell"];
                if (cell == nil) {
                    cell = [[ZCChatWheel4Cell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatWheel4Cell"];
                }
            }
        }else if (model.richModel.type == SobotMessageRichJsonTypeApplet) {
            cell = (ZCChatAppletCell*)[tableView dequeueReusableCellWithIdentifier:@"ZCChatAppletCell"];
            if (cell == nil) {
                cell =  [[ZCChatAppletCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatAppletCell"];
            }
        }else if (model.richModel.type == SobotMessageRichJsonTypeArticle){
            cell = (ZCChatArticleCell*)[tableView dequeueReusableCellWithIdentifier:@"ZCChatArticleCell"];
            if (cell == nil) {
                cell = [[ZCChatArticleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatArticleCell"];
            }
        }else if (model.richModel.type == SobotMessageRichJsonTypeLocation){
            cell = (ZCChatLocationCell*)[tableView dequeueReusableCellWithIdentifier:@"ZCChatLocationCell"];
            if (cell == nil) {
                cell = [[ZCChatLocationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatLocationCell"];
            }
        }else if (model.richModel.type == SobotMessageRichJsonTypeGoods){
            cell = (ZCChatGoodsCardCell*)[tableView dequeueReusableCellWithIdentifier:@"ZCChatGoodsCardCell"];
            if (cell == nil) {
                cell = [[ZCChatGoodsCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatGoodsCardCell"];
            }
        }else if (model.richModel.type == SobotMessageRichJsonTypeOrder){
            cell = (ZCChatOrderCardCell*)[tableView dequeueReusableCellWithIdentifier:@"ZCChatOrderCardCell"];
            if (cell == nil) {
                cell = [[ZCChatOrderCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatOrderCardCell"];
            }
        }else if(model.richModel.type == SobotMessageRichJsonTypeText){
            cell = [tableView dequeueReusableCellWithIdentifier:@"ZCChatRichCell"];
            if (cell == nil) {
                cell = [[ZCChatRichCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatRichCell"];
            }
        }
        
        
    }
    if(cell == nil){
        cell = [tableView dequeueReusableCellWithIdentifier:@"ZCChatRichCell"];
        if (cell == nil) {
            cell = [[ZCChatRichCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatRichCell"];
        }
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    cell.viewWidth = _listTable.frame.size.width;
    cell.delegate=self;
    NSString *time=@"";
    NSString *format=@"MM-dd HH:mm";
    
    if([model.cid isEqual:[ZCUICore getUICore].getLibConfig.cid]){// [self getZCIMConfig].cid
        format=@"HH:mm";
    }
    
    
    if(indexPath.row>0){
        SobotChatMessage *lm=[[ZCUICore getUICore].chatMessages objectAtIndex:(indexPath.row-1)];
        if(![model.cid isEqual:lm.cid]){
            //            time=intervalSinceNow(model.ts);
            time = sobotDateTransformString(format, sobotStringFormateDate(model.ts));
        }
    }else{
        time = sobotDateTransformString(format, sobotStringFormateDate(model.ts));
    }
    
    if([ZCUICore getUICore].getLibConfig.isArtificial){// [self getZCIMConfig].isArtificial
        model.isHistory = YES;
    }
    
    if(model.msgType == SobotMessageTypeTipsText){
        time = @"";
    }
    
    // 不是中文时，不显示时间
//    if([ZCUICore getUICore].kitInfo.hideChatTime && (![zcGetLanguagePrefix() hasPrefix:@"zh-"] || ![[ZCLibClient getZCLibClient].libInitInfo.absolute_language hasPrefix:@"zh-"])){
    if([ZCUICore getUICore].kitInfo.hideChatTime){
        time = @"";
    }
    // 是否显示发送的头像和名称，不是同一个发送者或者2条消息大于1分钟
    model.isShowSenderFlag = [self checkShowSenerMessage:model index:(int)indexPath.row];
    
    [cell initDataToView:model time:time];
    
    return cell;
}
-(int)checkShowSenerMessage:(SobotChatMessage *) lastMessage index:(int) index{
    if(lastMessage.isShowSenderFlag || index == 0){
        return YES;
    }
    if (lastMessage.action == SobotMessageActionTypeAdminHelloWord) {
        // 人工欢迎语
        return YES;
    }
    if (lastMessage.action == SobotMessageActionTypeRobotHelloWord) {
        return YES;
    }
    
    if(index -1 >= 0){
        SobotChatMessage *chat = [ZCUICore getUICore].chatMessages[index - 1];
        // 仅与上一个相比就可以了
        if(![chat.senderName isEqual:lastMessage.senderName]){
            return YES;
        }
        
        if(![chat.cid isEqual:lastMessage.cid]){
            return YES;
        }
    }
    for (int i=(index-1);i>=0;i--) {
        SobotChatMessage *chat = [ZCUICore getUICore].chatMessages[i];
        
        if(chat.isShowSenderFlag && chat.action != SobotMessageActionTypeOnline && !chat.isHistory){
            return NO;
        }
        int ss = sobotIntervalDateSinceSimpleNow(lastMessage.ts) - sobotIntervalDateSinceSimpleNow(chat.ts);
        if(ss/3600 > 1){
            return YES;
        }
    }
    return NO;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    SobotCallTaskEntity *item = [_listArray objectAtIndex:indexPath.row];
//    SobotCallTaskDetailController *detailVC = [[SobotCallTaskDetailController alloc]init];
//    detailVC.model = item;
//    detailVC.titleStr = sobotConvertToString(item.campaignName);
//    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - tableView end

#pragma mark tableviewcell delegate start
-(void)cellItemClick:(SobotChatMessage *)model type:(ZCChatCellClickType)type text:(NSString *)text obj:(id)object{
    if(type == ZCChatCellClickTypeSendGoosText){
        [[ZCUICore getUICore] sendProductInfo:[ZCUICore getUICore].kitInfo.productInfo resultBlock:^(NSString * _Nonnull msg, int code) {
            
        }];
    }else if (type == ZCChatCellClickTypeAppletAction){
        // 小程序
        if ( [[ZCUICore getUICore] AppletClickBlock] != nil) {
            // 用户做了拦截事件
            [ZCUICore getUICore].AppletClickBlock(object);
        }else{
            [[SobotToast shareToast] showToast:SobotKitLocalString(@"小程序只能通过微信打开") duration:2 view:[UIApplication sharedApplication].keyWindow position:SobotToastPositionCenter];
        }
        return;
    }else if(type == ZCChatCellClickTypeOpenFile){
        ZCDocumentLookController *leaveMessageVC = [[ZCDocumentLookController alloc]init];
        leaveMessageVC.message = model;
        [self openNewPage:leaveMessageVC];
        return;
    }else if (type == ZCChatCellClickTypeLeaveMessage) {
        [_keyboardTools hideKeyboard];
        // 不直接退出SDK
        [[ZCUICore getUICore] openLeaveOrRecoredVC:NO dict:nil];
    }else if (type == ZCChatCellClickTypeLeaveRecordPage) {
        [_keyboardTools hideKeyboard];
        // 跳转到留言记录
        [[ZCUICore getUICore] openLeaveOrRecoredVC:YES dict:@{@"selectedType":@"2",@"templateId":@"1"}];
    }else if (type == ZCChatCellClickTypeItemCancelFile) {
        // 取消发送文件
        [[ZCUICore getUICore] cancelSendFileMsg:model];
    }else if(type == ZCChatCellClickTypeItemOpenLocation){
        [self cellItemClick:nil type:ZCChatCellClickTypeOpenURL text:@"" obj:text];
    }else if (type == ZCChatCellClickTypeItemContinueWaiting) {
        // 继续排队
        [[ZCUICore getUICore] continueWaiting:model];
        return;
    }else if (type == ZCChatCellClickTypeInsterTurn) {
        // 机器人 点踩 转人工
        if ([self getZCIMConfig].isArtificial) {
            return;
        }
        [[ZCUICore getUICore] checkUserServiceWithType:ZCTurnType_BtnClickUpOrDown model:model];
    }else if(type == ZCChatCellClickTypeNewSession){
        // 清楚记录，重新初始化
        ZCPlatformInfo *info = [[ZCPlatformTools sharedInstance] getPlatformInfo];
        info.checkInitKey = @"";
        [[ZCPlatformTools sharedInstance] savePlatformInfo:info];
        //  要去初始化啊
        [self doSDKConfig];
        return;
    }else if (type == ZCChatCellClickTypeGroupItemChecked) {
        // 点击机器人回复的技能组选项
        NSDictionary *dict = model.robotAnswer.groupList[[object intValue]];
        if(dict==nil || dict[@"groupId"]==nil){
            return;
        }
        int temptype = [self getZCIMConfig].type;
        if ([ZCLibClient getZCLibClient].libInitInfo.service_mode >0) {
            temptype = [ZCLibClient getZCLibClient].libInitInfo.service_mode;
        }
        if (temptype == 1) {
            return;
        }
        [ZCUICore getUICore].checkGroupId = sobotConvertToString(dict[@"groupId"]);
        [ZCUICore getUICore].checkGroupName = sobotConvertToString(dict[@"groupName"]);
        [[ZCUICore getUICore] checkUserServiceWithType:ZCTurnType_CellGroupClick model:model];
    }else if(type == ZCChatCellClickTypeNewDataGroup){
        [self.listTable reloadData];
        return;
    }else if (type == ZCChatCellClickTypeNotice) {
        // 展开和收起
        model.isOpenNotice = !model.isOpenNotice;
        [self.listTable reloadData];
        return;
    }else if(type==ZCChatCellClickTypeTouchImageYES){
        if(object!=nil && [object isKindOfClass:[SobotXHImageViewer class]]){
            xhObj = object;
        }
        [_keyboardTools hideKeyboard];
    }else if(type == ZCChatCellClickTypeOpenURL){
        [[ZCUICore getUICore] dealWithLinkClickWithLick:object viewController:[SobotUITools getCurrentVC]];
    }else if(type==ZCChatCellClickTypeTouchImageNO){
        // 隐藏大图查看
        xhObj = nil;
    }else if(type==ZCChatCellClickTypePlayVoice  || type == ZCChatCellClickTypeReceiverPlayVoice){
        
        // 新增逻辑 如果当前是正在录音的时候 不能播放语音消息，会影响录音结果
        if ([self.keyboardTools isKeyboardRecord]) {
            return;
        }
        
        // 已经有播放的，关闭当前播放的
        if(playModel && [model isEqual:playModel]){
            playModel.isPlaying=NO;
            playModel=nil;
            [[SobotVoiceTools shareSobotVoiceTools] sotpPlayVoide];
        }
        playModel=model;
        playModel.isPlaying=YES;
        [[SobotVoiceTools shareSobotVoiceTools] startWithModel:sobotConvertToString(model.richModel.richmoreurl) view:object category:SobotAudioSessionCategoryPlayback];
    }else if(type == ZCShowStatusGoBack){
        if(self.delegate && [self.delegate respondsToSelector:@selector(onBackFinish:closeClick:)]){
            NSDictionary *params = object;
            [self.delegate onBackFinish:[params[@"isFinish"] intValue] closeClick:[params[@"isClose"] intValue]];
         }
    }
    else if(type == ZCChatCellClickTypeItemChecked || type == ZCChatCellClickTypeCollectionSendMsg){
        if(_keyboardTools.curKeyboardStatus == ZCKeyboardStatusNewSession){
            [ZCUICore getUICore].isAdminServerBeforeCloseSession = [self getZCIMConfig].isArtificial;
            // 会话已结束，不能再发送消息
            [[ZCUICore getUICore] addMessageToList:SobotMessageActionTypeOverWord content:@"" type:SobotMessageTypeTipsText dict:nil];
            return;
        }
        // 向导内容
        NSDictionary *dict =  object;
        
        if(dict==nil || dict[@"question"]==nil){
            return;
        }
        NSString *title = dict[@"question"];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:dict];
        if(type == ZCChatCellClickTypeCollectionSendMsg){
            params[@"questionFlag"] = @"2";
            title = dict[@"title"];
            params[@"msgContent"] = title;
            if([dict[@"ishotguide"] intValue] == 1){
                params[@"questionFlag"] = @"1";
                params[@"requestText"] = dict[@"question"];
            }
        }else{
            params[@"requestText"] = dict[@"question"];
            params[@"questionFlag"] = @"1";
            
        }
        [[ZCUICore getUICore] sendMessage:title type:SobotMessageTypeText exParams:params duration:@""];
    }else if(type == ZCChatCellClickTypeConnectUser){
        [[ZCUICore getUICore] checkUserServiceWithType:ZCTurnType_BtnClick model:model];
    }else if(type == ZCChatCellClickTypeStepOn || type == ZCChatCellClickTypeTheTop){
        // 踩/顶   -1踩   1顶
        if (_keyboardTools.curKeyboardStatus == ZCKeyboardStatusNewSession) {
            // 置灰不可点
            [[SobotToast shareToast] showToast:SobotKitLocalString(@"会话结束，无法反馈") duration:1.5f position:SobotToastPositionCenter];
            model.commentType = 4;
            [_listTable  reloadData];
            return;
        }
        
        
        int status = (type == ZCChatCellClickTypeStepOn)?-1:1;
#pragma mark - 机器人点踩调用接口
        [ZCLibServer rbAnswerComment:[self getZCIMConfig] message:model status:status start:^(NSString *url){
            
        } success:^(ZCNetWorkCode code) {
            if(status== -1){
                if(model.commentType == 2){
                    model.commentType = 0;
                }else{
                    model.commentType = 3;
                }
                [[SobotToast shareToast] showToast:SobotKitLocalString(@"我会努力学习，希望下次帮到您") duration:1.5f position:SobotToastPositionCenter];
            }else{
                if(model.commentType == 3){
                    model.commentType = 0;
                }else{
                    model.commentType = 2;
                }
                [[SobotToast shareToast] showToast:SobotKitLocalString(@"感谢您的支持") duration:1.5f position:SobotToastPositionCenter];
            }
            [self->_listTable  reloadData];
            
        } fail:^(ZCNetWorkCode errorCode) {
            
        }];
        if ([self getZCIMConfig].realuateTransferFlag && type == ZCChatCellClickTypeStepOn && [self getZCIMConfig].type != 1) {// 仅机器人模式不可以触发
            //如果开启了
            [ZCLibServer insertSysMsg:[self getZCIMConfig] title:@"点踩转人工提示" msg:[NSString stringWithFormat:@"%@ %@",SobotKitLocalString(@"未解决问题？点击"),SobotKitLocalString(@"转人工服务")]  start:^(NSString *url){
                
            } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
                if (![self getZCIMConfig].isArtificial) {
                    [[ZCUICore getUICore] removeListModelWithType:SobotMessageTypeTipsText tips:SobotMessageActionTypeUnresolvedProblemTurn];
                    [[ZCUICore getUICore] addMessageToList:SobotMessageActionTypeUnresolvedProblemTurn content:@"" type:SobotMessageTypeTipsText dict:nil];
                }
            } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
                
            }];
        }
    }else if(type == ZCChatCellClickTypeAgreeSend || type == ZCChatCellClickTypeRefuseSend){
        int isAgree = 1;
        if(type == ZCChatCellClickTypeRefuseSend){
            isAgree = 0;
            model.includeSensitive = 2;
        }
        [ZCLibServer authSendMessageSensitive:[self getZCIMConfig] type:isAgree start:^(NSString *url){
            
        } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
            if(type == ZCChatCellClickTypeRefuseSend){
                model.includeSensitive = 2;
                [self.listTable reloadData];
            }else{
                [self cellItemClick:model type:ZCChatCellClickTypeReSend text:@"" obj:nil];
//                status 1 成功
//                status 2 会话已结束
//                status 3 已授权
//                status 0 失败
                if([dict[@"data"][@"status"] intValue] == 1){
                    // 添加同意提示语
                    [[ZCUICore getUICore] addMessageToList:SobotMessageActionTypeChat_AUTH_AGREE content:@"" type:SobotMessageTypeTipsText dict:nil];
                }
            }
        } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
            
        }];
    }
}
-(void)cellItemClick:(int)satifactionType isResolved:(int)isResolved rating:(int)rating problem:(NSString *)problem scoreFlag:(int)scoreFlag{
    if (satifactionType == 1) {
        
            BOOL isEvalutionAdmin = [ZCUICore getUICore].getLibConfig.isArtificial;
            if(_keyboardTools.curKeyboardStatus == ZCKeyboardStatusNewSession){
                isEvalutionAdmin = [ZCUICore getUICore].isAdminServerBeforeCloseSession;
            }
            
            [[ZCUICore getUICore] checkSatisfacetion:isEvalutionAdmin type:SatisfactionTypeInvite rating:rating resolve:isResolved];

    }else{
        // 提交评价,10分实际是11
        if(scoreFlag == 1){
            rating = rating - 1;
            if(rating < 0){
                rating = 0;
            }
        }
        [[ZCUICore getUICore] commitSatisfactionWithIsResolved:isResolved Rating:rating problem:problem scoreFlag:scoreFlag];
    }
}

#pragma mark tableviewcell delegate end


// 销毁界面
-(void)dismissZCChatView{
//    if([_keyboardTools getKeyBoardViewStatus] == ZCKeyboardStatusNewSession){
//        // 加上这一句，下次进入会立即初始化
//        [[ZCPlatformTools sharedInstance] getPlatformInfo].config = nil;
//    }
    
    [self backChatView];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}


/// 是否为点击关闭按钮
/// @param isClose YES，点击关闭
-(void)closeChatView:(BOOL) isClose{
    BOOL showEvaluation = NO;
    // 返回提醒开关
    if ([ZCUICore getUICore].kitInfo.isOpenEvaluation) {
        showEvaluation = YES;
    }
    // 判断评价与否
    if (isClose && [ZCUICore getUICore].kitInfo.isShowCloseSatisfaction) {
        showEvaluation = YES;
    }
    if(!showEvaluation){
        if(self.delegate && [self.delegate respondsToSelector:@selector(onBackFinish:closeClick:)]){
            [self.delegate onBackFinish:YES closeClick:isClose];
        }
        return;
    }
    BOOL isEvalutionAdmin = [ZCUICore getUICore].getLibConfig.isArtificial;
    if(_keyboardTools.curKeyboardStatus == ZCKeyboardStatusNewSession){
        isEvalutionAdmin = [ZCUICore getUICore].isAdminServerBeforeCloseSession;
    }
    
    BOOL isShow = [[ZCUICore getUICore] checkSatisfacetion:isEvalutionAdmin type:isClose?SatisfactionTypeClose:SatisfactionTypeBack];
    if(!isShow){
        if(self.delegate && [self.delegate respondsToSelector:@selector(onBackFinish:closeClick:)]){
            [self.delegate onBackFinish:YES closeClick:isClose];
        }
    }
}



-(void)backChatView{
    [ZCUICore getUICore].unknownWordsCount = 0;
    if ([ZCUICore getUICore].lineModel) {
        [[ZCUICore getUICore].chatMessages removeObject:[ZCUICore getUICore].lineModel];
    }
    // 判断是否保存会话id，以判断是否重新初始化
    // 没有说过话，下次进入时判断是否需要重新初始化，如果当前时间-time,大于out_time就重新初始化
    if(![ZCUICore getUICore].isSendToUser && ![ZCUICore getUICore].isSendToRobot){
        NSDictionary *lastChat = @{@"cid":sobotConvertToString([self getZCIMConfig].cid),
                                   @"time":sobotDateTransformString(SOBOT_FORMATE_DATETIME,[NSDate new]),
                                   @"out_time":[NSString stringWithFormat:@"%d",[self getZCIMConfig].userOutTime]
        };
        [SobotCache addObject:lastChat forKey:@"KEYP_ZCLastChat"];
    }


    if ([ZCUICore getUICore].recordModel) {
        [[ZCUICore getUICore].chatMessages removeObject:[ZCUICore getUICore].recordModel];
    }

    @try{
        if([ZCUICore getUICore].chatMessages && [ZCUICore getUICore].chatMessages.count>0){
            SobotChatMessage *lastMsg = [[ZCUICore getUICore].chatMessages lastObject];
            if(lastMsg.action != SobotMessageActionTypeText){
                [[ZCPlatformTools sharedInstance] getPlatformInfo].lastMsg = lastMsg.tipsMessage;
                [[ZCPlatformTools sharedInstance] getPlatformInfo].lastDate = lastMsg.ts;
            } else {
                [[ZCPlatformTools sharedInstance] getPlatformInfo].lastMsg = [ZCPlatformTools getLastMessage:lastMsg];
                [[ZCPlatformTools sharedInstance] getPlatformInfo].lastDate = lastMsg.ts;
            }
        }
        [[ZCUICore getUICore] destoryViewsData];
        // 如果设置NO，每次返回都会从新添加
//        [ZCUICore getUICore].isAddNotice = NO;

        NSInteger keyboardtype = [_keyboardTools curKeyboardStatus];
        // 如果通道没有建立成功，当前正在链接中  则清空数据，下次重新初始化  2. 当前会话键盘是新会话键盘，返回时清空数据 重新初始化
        if((![ZCIMChat getZCIMChat].isConnected && [self getZCIMConfig].isArtificial) || keyboardtype == ZCKeyboardStatusNewSession){
            [self getPlatformInfo].cidsArray = nil;
            [self getPlatformInfo].messageArr = nil;
        }else{
            [self getPlatformInfo].cidsArray = [[ZCUICore getUICore].cids mutableCopy];
            [self getPlatformInfo].messageArr = [[ZCUICore getUICore].chatMessages mutableCopy];
        }

        [[ZCPlatformTools sharedInstance] savePlatformInfo:[self getPlatformInfo]];

        [ZCUICore getUICore].cids = nil;
        [ZCUICore getUICore].chatMessages = nil;

        [[ZCIMChat getZCIMChat] setChatPageState:NO];

        if([ZCUICore getUICore].ZCViewControllerCloseBlock){
            [ZCUICore getUICore].ZCViewControllerCloseBlock(self,ZC_CloseChat);
        }

//        // 离线用户，关闭通道
//        if ([ZCUICore getUICore].kitInfo.isShowCloseSatisfaction) {
//            //  如果打开 关闭弹出评价开关，需要判断是否已经评价，如果没有评价，则不关闭会话
//            if (isClickCloseBtn) {
//                [ZCLibClient closeAndoutZCServer:YES];
//            }else{
//                // 这里设置有问题 用户主动点击评价 之后 点击返回 触发弹窗提示， 如果是会话保持的逻辑（点的是暂时离开）是不能离线用户的
////                if (isCompleteSatisfaction) {
////                    [ZCLibClient closeAndoutZCServer:YES];
////                }
//            }
//        }else{
//            if(isClickCloseBtn){
//            [ZCLibClient closeAndoutZCServer:YES];
//            }
//        }

    } @catch (NSException *exception) {

    } @finally {

    }
    
    
    if (_keyboardTools) {
        [_keyboardTools removeKeyboardObserver];
        _keyboardTools = nil;
    }
    // 已经有播放的，关闭当前播放的
    if(playModel){
        playModel.isPlaying=NO;
        playModel=nil;
        [[SobotVoiceTools shareSobotVoiceTools] sotpPlayVoide];
    }
    if (_delegate) {
        _delegate = nil;
    }
}

-(ZCLibConfig *)getZCIMConfig{
    return [self getPlatformInfo].config;
    //从platforminfo 中获取config会卡顿
}

-(ZCPlatformInfo *) getPlatformInfo{
    return [[ZCPlatformTools sharedInstance] getPlatformInfo];
}

-(UITextView *) getChatTextView{
    if(_keyboardTools && _keyboardTools.zc_chatTextView){
        return _keyboardTools.zc_chatTextView;
    }
    return nil;
}

#pragma mark - 转换图片颜色
-(UIImage*)imageChangeColor:(UIColor*)color chageImg:(UIImage*)chageImg;
{
    //获取画布
    UIGraphicsBeginImageContextWithOptions(chageImg.size, NO, 0.0f);
    //画笔沾取颜色
    [color setFill];
    
    CGRect bounds = CGRectMake(0, 0, chageImg.size.width, chageImg.size.height);
    UIRectFill(bounds);
    //绘制一次
    [chageImg drawInRect:bounds blendMode:kCGBlendModeLuminosity alpha:1.0f];
    //再绘制一次
    [chageImg drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    //获取图片
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
@end
