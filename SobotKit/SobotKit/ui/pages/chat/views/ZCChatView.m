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
#import <SobotCommon/SobotAutoDragView.h>
#import "ZCUICore.h"
#import "ZCUIChatKeyboard.h"
#import "SobotFastMenuView.h"
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
#import "ZCChatEnumCell.h"

#import "ZCChatCustomCardSingleCell.h"
#import "ZCChatCustomCardHorizontalCell.h"
#import "ZCChatCustomCardVerticalCell.h"
#import "ZCChatCustomCardSingleSendCell.h"
#import "ZCChatStepOnBaseCell.h"
#import "ZCChatSensitiveCell.h"
#import "ZCChatAiCustomCardCell.h"
#import "ZCChatAiCustomCardUserCell.h"
#import "ZCChatAiLoadingCell.h"

#import "ZCQuickLeaveView.h"
#import "ZCUIAskTableController.h"
#import "ZCDocumentLookController.h"
#import "ZCTurnRobotView.h"
#import "ZCUILoading.h"
#import "ZCChatWhell1Cell.h"
#import "ZCChatLanguageCell.h"
#import "ZCLanguageView.h"
#import "ZCPageSheetView.h"
#import "ZCUIAskTableView.h"
#import "ZCChatAiCustomCardPage.h"

@interface ZCChatView()<UITableViewDelegate,UITableViewDataSource,ZCUICoreDelegate,ZCChatCellDelegate>{
    NSInteger lastMsgCount;
    SobotXHImageViewer *xhObj;
    
    // 当前正在播放的语音按钮
    SobotChatMessage *playModel;

    // 播放时动画展示View
     UIImageView   *animateView;
    
    // 是否已经打开了表单
    BOOL isOpenNewPage;
    
    // 正在发送已读标记，防止重复发送
    BOOL isSendReadState;
    
    
    CGFloat notifyHeight;
    CGFloat tableH;
}

/** 声音播放对象 */
@property(nonatomic,copy) UITableView *listTable;
@property(nonatomic,copy) SobotFastMenuView *fastMenuView;
@property (nonatomic,strong) UIRefreshControl * refreshControl;

@property(nonatomic,strong) ZCUIChatKeyboard *keyboardTools;
@property(nonatomic,strong) NSLayoutConstraint *tableBottomCons;
@property(nonatomic,strong) NSLayoutConstraint *tableLayoutTop;
@property(nonatomic,strong) NSLayoutConstraint *tableLayoutHeight;

@property(nonatomic,strong) NSLayoutConstraint *nextImgPR;
@property(nonatomic,strong) NSLayoutConstraint *nextImgW;
@property(nonatomic,strong) NSLayoutConstraint *bgViewPR;

// 通告
@property(nonatomic,copy) UIView *notifitionTopView;

@property(nonatomic,copy) UIButton *newWorkStatusButton;
@property(nonatomic,copy) UIButton *socketStatusButton;

// 多伦唤起留言
@property(nonatomic,strong)ZCQuickLeaveView *leaveEditView;


// 切换机器人控件
@property (nonatomic,strong) ZCTurnRobotView *changeRobotView;
/** 多机器人按钮*/
@property (nonatomic,strong) UIButton * changeClickBtn;
@property (nonatomic,strong) SobotAutoDragView * changeRobotDragView;
@property(nonatomic,strong) NSLayoutConstraint *changeRobotR;

// 未读消息提示按钮
@property (nonatomic,strong) UIButton *goUnReadButton;


// 人机问答 一问多答 和 人工回复消息 要显示 查看按钮
@property(nonatomic,strong) UIButton *lookMoreBtn;
@property(nonatomic,assign) BOOL isLockMsg;// 是否锁定滑动

@property(nonatomic,strong) UIView *plView;
@property(nonatomic,strong)NSLayoutConstraint *plH;
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
    notifyHeight = 0;
    [self createChatUI];
    [ZCLibClient getZCLibClient].libInitInfo.isFirstEntry = 1;// 要开验证加密相关的参数
    
    self.refreshControl.enabled = NO;
    [self doSDKConfig];
    
    [ZCUICore getUICore].detailViewBlock = ^(SobotChatMessage * _Nonnull model, int type, id obj) {
        if(type == ZCChatCellClickTypeOpenFile){
            [self cellItemClick:model type:ZCChatCellClickTypeOpenFile text:@"" obj:nil];
        }
        if(type == ZCChatCellClickTypeOpenURL){
            NSString *url = sobotConvertToString(obj);
            [self cellItemClick:nil type:ZCChatCellClickTypeOpenURL text:url obj:url];
        }
    };
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zcInitStatusLoadSuc) name:@"ZCInitStatusLoadSuc" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadTabelView:) name:@"SOBOTCHATPHOTCELLUPDATE"  object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnderBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jumpEvaluation) name:@"SOBOTJUMPEVALUAION" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(aiMessageListUpdate) name:@"SOBOTCHATMESSAGEUPDATTOPORON" object:nil];
}

-(void)aiMessageListUpdate{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ( self && [ZCUICore getUICore].getLibConfig.aiAgent && [ZCUICore getUICore].getLibConfig.realuateFlag && [ZCUICore getUICore].chatMessages.count >0) {
            if (!sobotIsNull([SobotCache shareSobotCache].aiMsgIdArray) && [SobotCache shareSobotCache].aiMsgIdArray.count >0) {
                NSString *msgId = sobotConvertToString([[SobotCache shareSobotCache].aiMsgIdArray lastObject]);
                if (sobotConvertToString(msgId).length >0) {
                    [[ZCUICore getUICore].chatMessages enumerateObjectsUsingBlock:^(SobotChatMessage *item, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([sobotConvertToString(item.msgId) isEqualToString:sobotConvertToString(msgId)]) {
                            item.commentType = 1;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                // 在主线程中更新 UI
                                [self->_listTable reloadData];
                                [self.listTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                            });
                            [SobotCache shareSobotCache].aiMsgIdArray = [NSMutableArray array];
                            *stop = YES;
                        }
                    }];
                }
            }
        }
    });
    
}

-(void)jumpEvaluation{
    [self hiddenKeyboard];
}

#pragma mark - 录音是先关闭正在播放的语音
-(void)stopPlayVideo{
    if(animateView){
        [animateView stopAnimating];
    }
    [[SobotVoiceTools shareSobotVoiceTools] sotpPlayVoide];
    if (playModel) {
        playModel.isPlaying=NO;
        playModel=nil;
    }
}

- (void)applicationDidEnderBackground:(NSNotification *)notification
{
    [SobotLog logDebug:@"按理说是重新进来后响应！"];
    // 切换前台移除正在播放的
    playModel.isPlaying=NO;
    playModel=nil;
    [self stopPlayVideo];
    [SobotVoiceTools shareSobotVoiceTools].fileUrl = @"";
}

#pragma mark -- 图片动态计算完宽高之后 重新刷新cell
-(void)uploadTabelView:(NSNotification*)notification{
//    NSDictionary *userInfo = notification.userInfo;
//    NSIndexPath *indexPath = userInfo[@"indexPath"];
    if (self && !sobotIsNull(self.listTable)) {
        [self.listTable reloadData];
//        [self.listTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
-(void)zcInitStatusLoadSuc{
       self.refreshControl.enabled = YES;
        self->_plH.constant = 0;
    if (_plView) {
        [_plView removeFromSuperview];
        _plView = nil;
    }

}
-(void)doSDKConfig{
    __weak ZCChatView *weakSelf = self;
    
    [[ZCUICore getUICore] doInitSDK:self block:^(ZCInitStatus status, NSString * _Nullable message, ZCLibConfig * _Nullable confg) {
        if(status == ZCInitStatusLoading){
            [[ZCUILoading shareZCUILoading] showAddToSuperView:self style:NO];
            self.plH.constant = 140;
        }
        if(status == ZCInitStatusLoadSuc){
            // 成功之后再添加下拉刷新
            [self->_listTable addSubview:self->_refreshControl];
            // 创建切换机器人按钮主题色
            [self createChangeRobotBtn];
            self.changeRobotDragView.hidden = YES;
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"ZCInitStatusLoadSuc" object:nil];
            
            // 显示键盘,此代码重复执行了，因为页面监听了ZCInitStatusLoadSuc通知
            [self zcInitStatusLoadSuc];
            
            [[ZCIMChat getZCIMChat] setChatPageState:YES];
            [[ZCUILoading shareZCUILoading] dismiss];
            [self->_keyboardTools setInitConfig:confg];
//            [self->_fastMenuView refreshData]; // 这里去掉 和键盘设置刷新快捷菜单的时间太相近了，导致数据重复
            [self updateTopViewBgColor];//
            [self notifitionTopViewWithisShowTopView];
            
            // 是否显示 多机器人按钮
            if ([self getZCIMConfig].robotSwitchFlag == 1) {
                if ([self getZCIMConfig].type != 2 && ![self getZCIMConfig].isArtificial) {
                    self->_changeRobotDragView.hidden = NO;
                    if(self.changeRobotDragView){
                        CGFloat sw = self.changeRobotR.constant;
                        self.changeRobotR.constant = 0;
                        [self.changeRobotDragView layoutIfNeeded];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [UIView animateWithDuration:0.25 animations:^{
                                self.changeRobotR.constant = sw;
                                [self.changeRobotDragView layoutIfNeeded];
                            }];
                        });
                    }
                }else{
                    self->_changeRobotDragView.hidden = YES;
                }
            }else{
                self->_changeRobotDragView.hidden = YES;
            }
            // 初始化成功，添加回调事件
            if([[ZCUICore getUICore] PageLoadBlock]){
                [ZCUICore getUICore].isCanShowAutoView = YES;
                // 通知外部可以更新UI
                [ZCUICore getUICore].PageLoadBlock(weakSelf,ZCPageStateTypeChatLoadFinish);
            }
        }
        
        if(status == ZCInitStatusFail){
            [[ZCUILoading shareZCUILoading] createPlaceholderView:SobotKitLocalString(@"网络错误，请检查网络后重试") image:nil withView:self action:^(UIButton *button) {
                [[ZCUILoading shareZCUILoading] dismiss];
                [self doSDKConfig];
            }];
        }
        
        if (status == ZCInitStatusLanguage) {
            // 影藏键盘
            [[ZCUILoading shareZCUILoading] dismiss];
            // 这里不显示清理数据的按钮 ，如果清理了数据，会话保持的逻辑再次进入页面无法下一步了
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ZCInitStatusLanguage" object:nil];
            // 这里判断一下，当前是否是重建会话过来的，要再次显示 空白占位图
            if (sobotIsNull(self.plView)) {
                [self createPlView];
            }
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
    if (sobotGetSystemDoubleVersion() >=15.0) {
        [[UITableView appearance] setPrefetchingEnabled:NO];
    }
    
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
    [_listTable registerClass:[ZCChatCustomCardSingleCell class] forCellReuseIdentifier:@"ZCChatCustomCardSingleCell"];
    [_listTable registerClass:[ZCChatCustomCardHorizontalCell class] forCellReuseIdentifier:@"ZCChatCustomCardHorizontalCell"];
    [_listTable registerClass:[ZCChatCustomCardVerticalCell class] forCellReuseIdentifier:@"ZCChatCustomCardVerticalCell"];
    [_listTable registerClass:[ZCChatCustomCardSingleSendCell class] forCellReuseIdentifier:@"ZCChatCustomCardSingleSendCell"];
    [_listTable registerClass:[ZCChatWhell1Cell class] forCellReuseIdentifier:@"ZCChatWhell1Cell"];
    [_listTable registerClass:[ZCChatStepOnBaseCell class] forCellReuseIdentifier:@"ZCChatStepOnBaseCell"];
    [_listTable registerClass:[ZCChatLanguageCell class] forCellReuseIdentifier:@"ZCChatLanguageCell"];
    [_listTable registerClass:[ZCChatEnumCell class] forCellReuseIdentifier:@"ZCChatEnumCell"];
    [_listTable registerClass:[ZCChatSensitiveCell class] forCellReuseIdentifier:@"ZCChatSensitiveCell"];
    [_listTable registerClass:[ZCChatAiCustomCardCell class] forCellReuseIdentifier:@"ZCChatAiCustomCardCell"];
    [_listTable registerClass:[ZCChatAiCustomCardUserCell class] forCellReuseIdentifier:@"ZCChatAiCustomCardUserCell"];
    [_listTable registerClass:[ZCChatAiLoadingCell class] forCellReuseIdentifier:@"ZCChatAiLoadingCell"];
    
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
    // 多语言切换完成之后再添加该功能，或者下拉不起效
    
    __weak ZCChatView *safeSelf = self;
    _fastMenuView = [[SobotFastMenuView alloc] initWithSuperView:self];
    [_fastMenuView setFastMenuBlock:^(ZCLibCusMenu * _Nonnull menu) {
        
        if(menu.menuType == ZCCusMenuTypeConnectUser){
//            [[ZCUICore getUICore] doConnectUserService:nil connectType:ZCTurnType_BtnClick];
            [safeSelf hiddenKeyboard];
            [[ZCUICore getUICore] checkUserServiceWithType:ZCTurnType_BtnClick model:nil];
        }else if(menu.menuType == ZCCusMenuTypeOpenUrl){
            [[ZCUICore getUICore] dealWithLinkClickWithLick:[safeSelf.fastMenuView getMenuUrl:menu.labelLink paramFlag:menu.paramFlag] viewController:[SobotUITools getCurrentVC]];
//            [[ZCUICore getUICore] dealWithLinkClickWithLick:menu.labelLink viewController:[SobotUITools getCurrentVC]];
        }else if(menu.menuType == ZCCusMenuTypeLeave){
            // 留言
            [[ZCUICore getUICore] goLeavePage];
        }else if(menu.menuType == ZCCusMenuTypeEvaluetion){
            // 评价
            BOOL isEvalutionAdmin = [ZCUICore getUICore].getLibConfig.isArtificial;
            if(self.keyboardTools.curKeyboardStatus == ZCKeyboardStatusNewSession){
                isEvalutionAdmin = [ZCUICore getUICore].isAdminServerBeforeCloseSession;
            }
            [safeSelf hiddenKeyboard];
            [[ZCUICore getUICore] checkSatisfacetion:isEvalutionAdmin type:SobotSatisfactionFromSrouceAdd];
        }else if(menu.menuType == ZCCusMenuTypeCloseChat){
            // 结束会话
//            [ZCLibClient closeAndoutZCServer:NO];
//            [safeSelf.keyboardTools setKeyboardMenuByStatus:ZCKeyboardStatusNewSession];
            
            [safeSelf closeChatView:YES];
        }else if(menu.menuType == ZCCusMenuTypeSendMessage || menu.menuType == ZCCusMenuTypeSendRobotMessage){
//            if ([ZCUICore getUICore].aiAgentAsking && ![[ZCUICore getUICore] getLibConfig].isArtificial) {
//                return;
//            }
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
            
            [[ZCUICore getUICore] sendMessage:menu.menuName type:SobotMessageTypeText exParams:@{@"fromEnum":fromEnum,@"question":menu.menuid,@"requestText":menu.menuName,@"docId":menu.menuid,@"questionFlag":@"1"} duration:@"" richType:SobotMessageRichJsonTypeText];
        }
    }];
    [_fastMenuView setFastMenuRefreshDataBlock:^(CGFloat height) {
        // 如果当前是一问多答 显示了 先不要刷新这里 导致第一条不起效啊 TODO
        // 高度发生变化的时候 重新刷新列表内容的偏移量
//        [safeSelf tableScrollToBottom];
    }];
    _tableLayoutTop = sobotLayoutPaddingTop(0, _listTable, self);
    _tableLayoutTop.priority = UILayoutPriorityDefaultLow;
//    [self addConstraint:_tableLayoutTop];
    [self addConstraint:sobotLayoutPaddingLeft(0, _listTable, self)];
    [self addConstraint:sobotLayoutPaddingRight(0, _listTable, self)];
    [self addConstraint:sobotLayoutMarginBottom(0, _listTable, _fastMenuView)];
    
    _tableLayoutHeight = sobotLayoutEqualHeight(60, _listTable, NSLayoutRelationEqual);
    [self addConstraint:_tableLayoutHeight];
    
    _keyboardTools = [[ZCUIChatKeyboard alloc] initConfigView:self table:_listTable fastView:self.fastMenuView];
    [_keyboardTools setKeyboardMenuByStatus:ZCKeyboardStatusRobot];
    _tableBottomCons = sobotLayoutMarginBottom(0, _fastMenuView, _keyboardTools.zc_bottomView);
    [self addConstraint:_tableBottomCons];
    
//    [self createChangeRobotBtn];
    [self goUnReadButton];
    
    [self lookMoreBtn];
    [self createPlView];
   
    // 转屏通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didChangeRotate:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    
    [SobotNetworkObserve shareSobotNetworkObserve];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netWorkChanged:) name:SobotNetworkChanged object:nil];
    
    // 进入时主动调用一次，防止会话保持时断网进入，此时没有网络变化无法监听到
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self netWorkChanged:nil];
    });
}

-(void)layoutSubviews{
//    [super layoutSubviews];
    
    CGFloat h = self.frame.size.height;
    CGFloat bh = self.keyboardTools.zc_bottomView.frame.size.height;
    CGFloat fh = self.fastMenuView.frame.size.height;
    
    tableH = h - bh - notifyHeight - fh;
    
    if(self.keyboardTools.zc_keyBoardHeight > 0){
        if(self.listTable.contentSize.height < tableH){
            // 防止重复修改高度抖动，模糊的键盘高度即可
            if(tableH - self.listTable.contentSize.height > self.keyboardTools.zc_keyBoardHeight){
                tableH = tableH - self.keyboardTools.zc_keyBoardHeight;
            }else{
                CGFloat lastKeyH = tableH - _tableLayoutHeight.constant;
                // 如果不是首次抬起，并且上一次的键盘高度与现有的不一致
                if(lastKeyH != 0 && lastKeyH!=self.keyboardTools.zc_keyBoardHeight){
                    CGFloat emojiViewHeight = 210;
                    if (SobotViewHeight(self) < SobotViewWidth(self)) {
                        emojiViewHeight = 120;
                    }
                    tableH = tableH - emojiViewHeight;
                }else{
                    tableH = tableH - self.keyboardTools.zc_keyBoardHeight;
                }
            }
            
            // 如果要准确值，使用此代码
//            tableH = tableH - self.keyboardTools.zc_keyBoardHeight;
        }
        
    }
    _tableLayoutHeight.constant = tableH;
}

-(void)createPlView{
    _plView = ({
        UIView *iv = [[UIView alloc]init];
        iv.backgroundColor = [ZCUIKitTools zcgetChatBackgroundColor];
        [self addSubview:iv];
        [self addConstraint:sobotLayoutPaddingBottom(0, iv, self)];
        [self addConstraint:sobotLayoutPaddingLeft(0, iv, self)];
        [self addConstraint:sobotLayoutPaddingRight(0, iv, self)];
        self.plH = sobotLayoutEqualHeight(140, iv, NSLayoutRelationEqual);
        [self addConstraint:self.plH];
        iv;
    });
}

-(void)beginAniantions{
    if (_notifitionTopView != nil) {
        [_notifitionTopView removeFromSuperview];
        _notifitionTopView = nil;
        [self notifitionTopViewWithisShowTopView];
    }
}

-(void )createChangeRobotBtn{
    
    _changeRobotDragView = ({
        NSString *titleStr = [ZCUICore getUICore].kitInfo.changeBusinessStr.length > 0?[ZCUICore getUICore].kitInfo.changeBusinessStr:SobotKitLocalString(@"换业务");
        CGSize s = [titleStr sizeWithAttributes:@{NSFontAttributeName:SobotFont14}];
        
        SobotAutoDragView *iv = [[SobotAutoDragView alloc] init];
        iv.tag = 20000;
        iv.draggingType = SobotDraggingTypePullOverRight;
        // 由于添加到chatview上，实际底部输入框和快捷菜单的高度
        iv.bottomSpace = XBottomBarHeight + 100;
        iv.rightSpace = s.width+12;
        iv.isShakeAnimation = NO;
        [self addSubview:iv];
        
        
        [self addConstraints:sobotLayoutSize(s.width + 44, 36, iv, NSLayoutRelationEqual)];
//        [self addConstraint:sobotLayoutPaddingBottom(-10, iv, self.listTable)];
        // 放到上面
        [self addConstraint:sobotLayoutPaddingTop(30, iv, self.listTable)];
        _changeRobotR = sobotLayoutPaddingRight(s.width+12, iv, self.listTable);
        [self addConstraint:_changeRobotR];
        
        
        CGRect cs = CGRectMake(0, 0, s.width + 44, 36);
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:cs byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerTopLeft cornerRadii:CGSizeMake(18,18)];
        
        //创建 layer
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        // 使用addSublayer 无需设置frame
//        maskLayer.frame = cs;
        //赋值
        maskLayer.path = maskPath.CGPath;
        // 边框颜色和大小
//        maskLayer.lineWidth = 1.0f;
//        maskLayer.strokeColor = UIColorFromModeColorAlpha(SobotColorBgLine, 1).CGColor;
        maskLayer.fillColor = [ZCUIKitTools zcgetChatBackgroundColor].CGColor;
        maskLayer.backgroundColor = [ZCUIKitTools zcgetChatBackgroundColor].CGColor;
//        maskLayer.shadowColor = UIColorFromModeColorAlpha(SobotColorBgLine, 0.3).CGColor;//
        maskLayer.shadowColor = [UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:0.3000].CGColor;
        maskLayer.shadowOffset = CGSizeMake(0,0);
        maskLayer.shadowOpacity = 1;
        maskLayer.shadowRadius = 5;
        // 这里不能使用mask，需要重新添加子layer
//        iv.layer.mask = maskLayer;
        [iv.layer addSublayer:maskLayer];
        iv.hidden = YES;
        
        UIImage *colorImg = [SobotImageTools changeImageColor:SobotKitGetImage(@"zcicon_changerobot") color:[ZCUIKitTools zcgetServerConfigBtnBgColor]];
//        UIImage *img = [SobotImageTools sobotScaleToSize:CGSizeMake(12, 12) with:colorImg];
        
        // 配合ivBtn.imageView.tintColor使用
//        UIImage *img = [[SobotImageTools sobotScaleToSize:CGSizeMake(12, 12) with:SobotKitGetImage(@"zcicon_changerobot")] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        UIButton *ivBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        ivBtn.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
        [ivBtn setTitle:titleStr forState:UIControlStateNormal];
        [ivBtn.titleLabel setFont:SobotFont14];
        [ivBtn setTitleColor:[ZCUIKitTools zcgetServerConfigBtnBgColor] forState:UIControlStateNormal];
        [ivBtn setImage:colorImg forState:UIControlStateNormal];
//        [ivBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 16, 0, 8)];
//        ivBtn.imageView.tintColor = [ZCUIKitTools zcgetServerConfigBtnBgColor];
        // 设置图片和文字的间距
        CGFloat spacing = 5; // 间距值
        [ivBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, spacing, 0, -spacing)];
        [ivBtn setImageEdgeInsets:UIEdgeInsetsMake(12, -spacing, 12, spacing)];
        [iv addSubview:ivBtn];
        ivBtn.tag = BUTTON_TURNROBOT;
        [ivBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [iv addConstraints:sobotLayoutPaddingWithAll(0, 0, 0, 0, ivBtn, iv)];
        // 处理镜像  这里有切边，父类不做镜像处理
//        if ([ZCUIKitTools getSobotIsRTLLayout]) {
//            for (UIView *subview in iv.subviews) {
//                subview.transform = CGAffineTransformMakeScale(-1, 1);
//            }
//        }
        iv;
    });
    
    
//    _changeClickBtn = ({
//        NSString *titleStr = [ZCUICore getUICore].kitInfo.changeBusinessStr.length > 0?[ZCUICore getUICore].kitInfo.changeBusinessStr:SobotKitLocalString(@"换业务");
//        
//        iv;
//    });
}

-(UIButton *)goUnReadButton{
    if(!_goUnReadButton){
        _goUnReadButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [_goUnReadButton setImage:SobotKitGetImage(@"zcicon_newmessages") forState:UIControlStateNormal];
        [_goUnReadButton setImage:SobotKitGetImage(@"zcicon_newmessages") forState:UIControlStateHighlighted];
        
        [_goUnReadButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
//        [_goUnReadButton setTitleColor:UIColorFromModeColor(SobotColorTheme) forState:UIControlStateNormal];
        [_goUnReadButton setTitleColor:UIColorFromModeColor(SobotColorWhite) forState:UIControlStateNormal];
        [_goUnReadButton.titleLabel setFont:[ZCUIKitTools zcgetListKitDetailFont]];
        [_goUnReadButton setContentEdgeInsets:UIEdgeInsetsMake(0, 16, 0, 16+18)];
        [_goUnReadButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        _goUnReadButton.layer.cornerRadius = 18;
//        _goUnReadButton.layer.borderWidth = 0.75f;
//        _goUnReadButton.layer.borderColor = UIColorFromModeColor(SobotColorTheme).CGColor;
        _goUnReadButton.layer.masksToBounds = YES;
//        [_goUnReadButton setBackgroundColor:[ZCUIKitTools zcgetBgBannerColor]];
        [_goUnReadButton setBackgroundColor:UIColorFromModeColor(@"SobotColorBgUnRead")];
        _goUnReadButton.tag = BUTTON_UNREAD;
        [_goUnReadButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_goUnReadButton];
        _goUnReadButton.hidden=YES;
        
        
//        [self addConstraint:sobotLayoutEqualWidth(120, _goUnReadButton, NSLayoutRelationGreaterThanOrEqual)];
        [self addConstraint:sobotLayoutEqualHeight(36, _goUnReadButton, NSLayoutRelationEqual)];
        [self addConstraint:sobotLayoutPaddingTop(40, _goUnReadButton, self.listTable)];
//        [self addConstraint:sobotLayoutPaddingRight(-20, _goUnReadButton, self.listTable)];
        // 这里往右缩进18个像素，满足UI右侧不圆角
        [self addConstraint:sobotLayoutPaddingRight(18, _goUnReadButton, self.listTable)];
    }
    return _goUnReadButton;
}

-(UIButton *)lookMoreBtn{
    if(!_lookMoreBtn){
        
        _lookMoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        UIImage *img = [[SobotImageTools sobotScaleToSize:CGSizeMake(12, 12) with:SobotKitGetImage(@"zcicon_newmessages_down")] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage *img = [SobotImageTools changeImageColor:SobotKitGetImage(@"zcicon_newmessages_down") color:[ZCUIKitTools zcgetServerConfigBtnBgColor]];
        [_lookMoreBtn setImage:img forState:UIControlStateNormal];
//        _lookMoreBtn.imageView.tintColor =/* [ZCUIKitTools zcgetServerConfigBtnBgColor];*/
        
        [_lookMoreBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_lookMoreBtn setTitleColor:[ZCUIKitTools zcgetServerConfigBtnBgColor] forState:UIControlStateNormal];
        [_lookMoreBtn.titleLabel setFont:[ZCUIKitTools zcgetListKitDetailFont]];
        [_lookMoreBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 16, 0, 16+18)];
        // 设置图片和文字的间距
        CGFloat spacing = 4.0; // 间距值
        self.lookMoreBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -spacing, 0, spacing);
        self.lookMoreBtn.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, -spacing);
        
        [_lookMoreBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        _lookMoreBtn.layer.masksToBounds = NO;
//        [_lookMoreBtn setBackgroundColor:UIColorFromModeColor(@"SobotColorBgUnRead")];
        
        _lookMoreBtn.layer.backgroundColor = UIColorFromModeColor(SobotColorBgMain).CGColor;
        _lookMoreBtn.layer.cornerRadius = 18;
        _lookMoreBtn.layer.shadowColor = [UIColor colorWithRed:63/255.0 green:65/255.0 blue:68/255.0 alpha:0.1000].CGColor;
        _lookMoreBtn.layer.shadowOffset = CGSizeMake(0,1);
        _lookMoreBtn.layer.shadowOpacity = 1;
        _lookMoreBtn.layer.shadowRadius = 10;
        
        _lookMoreBtn.tag = BUTTON_NewMsgCount;
        [_lookMoreBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_lookMoreBtn];
        _lookMoreBtn.hidden=YES;
        [self addConstraint:sobotLayoutEqualHeight(36, _lookMoreBtn, NSLayoutRelationEqual)];
        [self addConstraint:sobotLayoutPaddingBottom(-40, _lookMoreBtn, self.listTable)];
        // 这里往右缩进18个像素，满足UI右侧不圆角
        [self addConstraint:sobotLayoutPaddingRight(18, _lookMoreBtn, self.listTable)];
//        _lookMoreBtn.imageView.transform = CGAffineTransformMakeRotation(M_PI);
    }
    return _lookMoreBtn;
}

#pragma mark 新消息和切换机器人按钮事件
-(void)buttonClick:(UIButton *)sender{
    // 未读消息数
    if(sender.tag == BUTTON_UNREAD){
        self.goUnReadButton.hidden = YES;
        int unNum = [[ZCIMChat getZCIMChat] getUnReadNum];
        if(unNum<=[ZCUICore getUICore].chatMessages.count){
            // 找到那个提示消息的下标 跳转到提示消息的位置
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if([ZCUICore getUICore].chatMessages != nil && [ZCUICore getUICore].chatMessages.count > 0){
                if ([self.listTable numberOfRowsInSection:0] > 0) {
                    int index = -1;
                    for (int i = 0; i<[ZCUICore getUICore].chatMessages.count; i++) {
                        SobotChatMessage *chatMsg = [ZCUICore getUICore].chatMessages[i];
                        if (chatMsg.msgType == SobotMessageTypeTipsText && [chatMsg.tipsMessage isEqualToString:SobotKitLocalString(@"以下为未读消息")]) {
                            index = i;
                            break;
                        }
                    }
                    if (index >-1) {
                        NSIndexPath *lastMessage = [NSIndexPath indexPathForRow:index inSection:0];
                        // 滚动到底部
                        [self.listTable scrollToRowAtIndexPath:lastMessage atScrollPosition:UITableViewScrollPositionTop animated:YES];
                    }
                }
            }
            });
        }
    }
    if (sender.tag == BUTTON_NewMsgCount) {
        [self setDismissLockMsgBtn];
    }
    
    // 切换机器人
    if (sender.tag == BUTTON_TURNROBOT) {
        // 当前是新会话键盘样式，点击不起效
        if (_keyboardTools.curKeyboardStatus == ZCKeyboardStatusNewSession) {
            return;
        }
        
        sender.enabled = NO;
        
        [self hiddenKeyboard];
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
                        [safeView getPlatformInfo].config.robotName = itemModel.robotName;
                        
                        [safeView getZCIMConfig].robotName = itemModel.robotName;
                        [safeView getZCIMConfig].robotLogo = itemModel.robotLog;
                        [safeView getZCIMConfig].robotFlag = [itemModel.robotFlag intValue];
                        [safeView getZCIMConfig].aiStatus = itemModel.aiStatus;
                        [safeView getZCIMConfig].templateId = itemModel.templateId;
                        [safeView getZCIMConfig].commentFlag = itemModel.commentFlag;
                        
                        // 切换机器人，加载大模型配置
                        [[ZCUICore getUICore] loadAiAgentSatisfactionDictlock:^(int code) {
                            
                        }];
                        
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
                        // 切换机器人之后顶部的标题也要切换
                        [self setTitleName:itemModel.robotName];
                        // 切换机器人之后从新获取  重新获取是否开启的点踩的配置开关
                        if ([ZCUICore getUICore].getLibConfig.aiAgent) {
                            [[ZCUICore getUICore] getAiRobotTip];
                        }else{
                            [[ZCUICore getUICore] getRobotTip];
                        }
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

#pragma mark -- 清理掉新消息按钮以及回执初始化值
-(void)setDismissLockMsgBtn{
    [ZCUICore getUICore].isLockMsg = NO;
    [ZCUICore getUICore].lockMsgCount = 0;
    self.lookMoreBtn.hidden = YES;
    [self.lookMoreBtn setTitle:@"" forState:0];
    [self tableScrollToBottom];
}

-(void)netWorkChanged:(NSNotification *) noticeInfoTemp{
 
    [SobotLog logHeader:SobotLogHeader info:@"网络发送变化： %d", [SobotNetworkObserve shareSobotNetworkObserve].isSobotReachable]; 
    // 上传日志
    if([SobotNetworkObserve shareSobotNetworkObserve].isSobotReachable){
        self.newWorkStatusButton.hidden = YES;
    }else{
        self.newWorkStatusButton.hidden = NO;
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
        [self addConstraint:sobotLayoutEqualHeight(46, self.newWorkStatusButton, NSLayoutRelationEqual)];
        
        [_newWorkStatusButton setContentEdgeInsets:UIEdgeInsetsMake(0, 16, 0, 16)];
        [_newWorkStatusButton setImage:SobotKitGetImage(@"zcicon_tag_nonet") forState:UIControlStateNormal];
        [_newWorkStatusButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_newWorkStatusButton setBackgroundColor:SobotColorFromRGB(0xFFF1F0)];
        [_newWorkStatusButton setTitle:[NSString stringWithFormat:@" %@",SobotKitLocalString(@"当前网络不可用，请检查您的网络设置")] forState:UIControlStateNormal];
        [_newWorkStatusButton setTitleColor:UIColorFromKitModeColor(SobotColorTextMain) forState:UIControlStateNormal];
        [_newWorkStatusButton.titleLabel setFont:SobotFont14];
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

//- (void)openNoticeWebView:(UITapGestureRecognizer*)tap{
//     [self hiddenKeyboard];
//    if (sobotConvertToString([self getZCIMConfig].announceClickUrl).length >0 && [self getZCIMConfig].announceClickFlag == 1) {
//        [self cellItemClick:nil type:ZCChatCellClickTypeOpenURL text:@"" obj:[self getZCIMConfig].announceClickUrl];
//    }
//}

- (void)openNoticeWebView:(UIButton *)sender{
    [self hiddenKeyboard];
  if (sobotConvertToString([self getZCIMConfig].announceClickUrl).length >0) {
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
//            _notifitionTopView.alpha = 0.8;
      
//            UITapGestureRecognizer * tapAction = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openNoticeWebView:)];
//            [_notifitionTopView addGestureRecognizer:tapAction];
            [self addSubview:_notifitionTopView];
            _notifitionTopView.hidden = NO;
            
            [self addConstraint:sobotLayoutPaddingTop(0, self.notifitionTopView, self)];
            [self addConstraint:sobotLayoutPaddingLeft(0, self.notifitionTopView, self)];
            [self addConstraint:sobotLayoutPaddingRight(0, self.notifitionTopView, self)];
            [self addConstraint:sobotLayoutEqualHeight(46, self.notifitionTopView, NSLayoutRelationEqual)];
            
            
            // icon
            SobotImageView * icon = [[SobotImageView alloc]init];
            if (![@"" isEqual:sobotConvertToString(icoUrl)]) {
                [icon loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(icoUrl)] placeholer:SobotKitGetImage(@"zcicon_annunciate") showActivityIndicatorView:NO];
            }else{
                [icon setImage:SobotKitGetImage(@"zcicon_annunciate")];
            }
            
            icon.contentMode = UIViewContentModeScaleAspectFill;
            [icon setBackgroundColor:[UIColor clearColor]];
//            [icon addGestureRecognizer:tapAction];
            [_notifitionTopView addSubview:icon];
            [_notifitionTopView addConstraint:sobotLayoutEqualCenterY(0, icon, self.notifitionTopView)];
            [_notifitionTopView addConstraint:sobotLayoutPaddingLeft(16, icon, self.notifitionTopView)];
            [_notifitionTopView addConstraints:sobotLayoutSize(14, 14, icon, NSLayoutRelationEqual)];
            
            UIImageView *nextImg = [[UIImageView alloc]init];
            [nextImg setImage:SobotKitGetImage(@"zcicon_arrow_right_top")];
            [_notifitionTopView addSubview:nextImg];
            self.nextImgPR = sobotLayoutPaddingRight(-16, nextImg, _notifitionTopView);
            [_notifitionTopView addConstraint:self.nextImgPR];
            [_notifitionTopView addConstraint:sobotLayoutEqualCenterY(0, nextImg, _notifitionTopView)];
            self.nextImgW = sobotLayoutEqualWidth(10, nextImg, NSLayoutRelationEqual);
            [_notifitionTopView addConstraint:self.nextImgW];
            [_notifitionTopView addConstraint:sobotLayoutEqualHeight(20, nextImg, NSLayoutRelationEqual)];
            
            
            UIView *bgView = [[UIView alloc]init];
            bgView.layer.masksToBounds = YES;
            [_notifitionTopView addSubview:bgView];
            [_notifitionTopView addConstraint:sobotLayoutPaddingTop(14, bgView, self.notifitionTopView)];
            [_notifitionTopView addConstraint:sobotLayoutMarginLeft(8, bgView, icon)];
            self.bgViewPR = sobotLayoutMarginRight(-16, bgView, nextImg);
            [_notifitionTopView addConstraint:self.bgViewPR];
            [_notifitionTopView addConstraint:sobotLayoutEqualHeight(22, bgView, NSLayoutRelationEqual)];

            CGFloat sw = 0;
            if (sobotConvertToString([self getZCIMConfig].announceClickUrl).length >0) {
                sw = 16 + 10;
                self.nextImgPR.constant = -16;
                self.nextImgW.constant = 10;
            }else{
                self.nextImgPR.constant = 0;
                self.nextImgW.constant = 0;
            }
            CGFloat animateWidth = ScreenWidth - 32 - 8 - 14 -sw;
            // 跑马灯label
            UILabel *titleLab = [[UILabel alloc]init];
            titleLab.font = SobotFont14;
            titleLab.textColor = UIColorFromKitModeColor(SobotColorTextMain); //[ZCUIKitTools getNotifitionTopViewLabelColor];
            titleLab.backgroundColor = UIColor.clearColor;
//            [titleLab addGestureRecognizer:tapAction];
            [bgView addSubview:titleLab];
            titleLab.frame = CGRectMake(0, 0, animateWidth, 22);
//            [bgView addConstraint:sobotLayoutPaddingTop(0, titleLab, bgView)];
//            [bgView addConstraint:sobotLayoutPaddingLeft(10, titleLab, bgView)];
//            [bgView addConstraint:sobotLayoutEqualHeight(20, titleLab, NSLayoutRelationEqual)];
            // 过滤 html标签
            NSString * text =  [[SobotHtmlCore stringByReplacingHTMLEntities:title] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];

            titleLab.text = text;
            [titleLab sizeToFit];
//            [titleLab layoutIfNeeded];
            // 关闭跑马灯效果,2.8.0最大20字
            if (titleLab.frame.size.width > animateWidth) {
                [self aniantionsNotice:titleLab];
            }else{
                [titleLab setTextAlignment:NSTextAlignmentLeft];
            }
        
            // 416修改，通告顶部文字颜色 统一修改入口
            titleLab.textColor = [ZCUIKitTools getNotifitionTopViewLabelColor];
            

            // table置顶添加40的高度
            notifyHeight = 46;
            _tableLayoutTop.constant = notifyHeight;
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setBackgroundColor:UIColor.clearColor];
            [btn addTarget:self action:@selector(openNoticeWebView:) forControlEvents:UIControlEventTouchUpInside];
            [_notifitionTopView addSubview:btn];
            [_notifitionTopView addConstraints:sobotLayoutPaddingWithAll(0, 0, 0, 0, btn, _notifitionTopView)];
            
            // 新增 左右渐变色效果
            UIImageView *leftColorView = [[UIImageView alloc]init];
            [_notifitionTopView addSubview:leftColorView];
            
            [_notifitionTopView addConstraint:sobotLayoutPaddingTop(0, leftColorView, _notifitionTopView)];
            [_notifitionTopView addConstraint:sobotLayoutEqualWidth(30, leftColorView, NSLayoutRelationEqual)];
            [_notifitionTopView addConstraint:sobotLayoutMarginLeft(0, leftColorView, icon)];
            [_notifitionTopView addConstraint:sobotLayoutPaddingBottom(0, leftColorView, _notifitionTopView)];
            [leftColorView setImage:SobotKitGetImage(@"zcicon_notifition_jbbg_color")];
//            [leftColorView setBackgroundColor:UIColor.redColor];

            UIImageView *rightColorView = [[UIImageView alloc]init];
            [_notifitionTopView addSubview:rightColorView];
            [_notifitionTopView addConstraint:sobotLayoutMarginRight(0, rightColorView, nextImg)];
            [_notifitionTopView addConstraint:sobotLayoutPaddingTop(0, rightColorView, _notifitionTopView)];
            [_notifitionTopView addConstraint:sobotLayoutEqualWidth(30, rightColorView, NSLayoutRelationEqual)];
            [_notifitionTopView addConstraint:sobotLayoutPaddingBottom(0, rightColorView, _notifitionTopView)];
            [rightColorView setImage:SobotKitGetImage(@"zcicon_notifition_jbbg_color")];
            rightColorView.transform = CGAffineTransformMakeRotation(M_PI);  // M_PI_4 是 45 度
            
//            if ([ZCUIKitTools getSobotIsRTLLayout]) {
//                leftColorView.transform = CGAffineTransformMakeRotation(M_PI);  // M_PI_4 是 45 度
//                rightColorView.transform = CGAffineTransformMakeRotation(M_PI);  // M_PI_4 是 45 度
//            }
            [self layoutIfNeeded];
            
        }
    }
    return _notifitionTopView;
}
-(void)aniantionsNotice:(UILabel *) titleLab{
    if (!_notifitionTopView.hidden) {
        CGFloat baseWidth = ScreenWidth - 32 - 8 - 14;
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
//    if([[ZCUICore getUICore] getGroupView]!=nil){
//        [[ZCUICore getUICore] dismissGroupView];
//    }
    [self hiddenKeyboard];
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
        if([[ZCUICore getUICore] getLibConfig].topBarStaffPhotoFlag == 0){
            // 不显示头像
            imageUrl = @"";
        }
    }
    
    // 4.1.8 新增 当仅人工，并且不是人工状态时
    if([self getZCIMConfig].type == 2 && ![self getZCIMConfig].isArtificial){
        title = @"";
        // 显示企业logo
        if([self getZCIMConfig].topBarCompanyLogoFlag == 1 && sobotConvertToString(imageUrl).length == 0){
            imageUrl = sobotConvertToString([[ZCUICore getUICore] getLibConfig].topBarCompanyLogoUrl);
        }
        if(sobotConvertToString(companyTitle).length == 0 && [[ZCUICore getUICore] getLibConfig].topBarCompanyNameFlag == 1){
            companyTitle = sobotConvertToString([[ZCUICore getUICore] getLibConfig].topBarCompanyName);
        }
    }else{
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
        isOpenNewPage = YES;
        //@{@"type":@(type),@"model":msgModel,@"dict":dict}
        NSDictionary *p = otherObj;
        if ([[p allKeys] containsObject:@"isNewAsk"] && [[p objectForKey:@"isNewAsk"] isEqualToString:@"1"]) {
            // 新版的
            ZCUIAskTableView *vc = [[ZCUIAskTableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0)];
            if (sobotConvertToString(message).length > 0) {
                vc.isclearskillId = YES;
            }
            
            // 询前表单页面点击关闭和提交完成之后
            [vc setTrunServerBlock:^(BOOL isback) {
                self->isOpenNewPage = NO;
                if (isback && [[ZCUICore getUICore] getLibConfig].type == 2) {
                    // 这里不移除缓存   钱龙和朝国 新版逻辑 结束会话弹新会话键盘
                [ZCLibServer logOut:[[ZCPlatformTools sharedInstance] getPlatformInfo].config];
                if([ZCUICore getUICore].delegate && [[ZCUICore getUICore].delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
                    [[ZCUICore getUICore].delegate onPageStatusChanged:ZCShowStatusReConnected message:nil obj:nil];
                }

                }else{
                    if (isback) {
                        [ZCUICore getUICore].isShowForm = NO;
                        return ;
                    }else{
                        // 去执行转人工的操作
                        [[ZCUICore getUICore] doConnectUserService:object connectType:[p[@"type"] intValue]];
                    }
                }
            }];
            
            ZCPageSheetView *sheetView = [[ZCPageSheetView alloc] initWithTitle:SobotKitLocalString(@"选择") superView:self showView:vc type:ZCPageSheetTypeLong];
            [sheetView showSheet:vc.frame.size.height animation:YES block:^{

            }];
            sheetView.isFromAsk = 1;
            if (XBottomBarHeight >0) {
                UIView *tempView =  [[UIView alloc]init];
                    [sheetView addSubview:tempView];
                [sheetView addConstraint:sobotLayoutPaddingBottom(0, tempView, sheetView)];
                [sheetView addConstraint:sobotLayoutPaddingLeft(0, tempView, sheetView)];
                [sheetView addConstraint:sobotLayoutPaddingRight(0, tempView, sheetView)];
                [sheetView addConstraint:sobotLayoutEqualHeight(XBottomBarHeight, tempView, NSLayoutRelationEqual)];
//                tempView.frame = CGRectMake(0, sheetView.frame.size.height -XBottomBarHeight, ScreenWidth, XBottomBarHeight);
                tempView.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
            }
            
            sheetView.dissmisBlock = ^(NSString * _Nonnull msg, int type) {
                self->isOpenNewPage = NO;
                if (type == 1 && [[ZCUICore getUICore] getLibConfig].type == 2) {
                    // 这里不移除缓存   钱龙和朝国 新版逻辑 结束会话弹新会话键盘
                [ZCLibServer logOut:[[ZCPlatformTools sharedInstance] getPlatformInfo].config];
                if([ZCUICore getUICore].delegate && [[ZCUICore getUICore].delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
                    [[ZCUICore getUICore].delegate onPageStatusChanged:ZCShowStatusReConnected message:nil obj:nil];
                }

                }else{
                    if (type == 1) {
                        // 点了空白区域关闭
                        [ZCUICore getUICore].isShowForm = NO;
                        return ;
                    }else{
                        // 去执行转人工的操作
                        [[ZCUICore getUICore] doConnectUserService:object connectType:[p[@"type"] intValue]];
                    }
                }
            };
            
            vc.dict = [p objectForKey:@"dict"];
            [vc updataPage];
            return;
        }else{
            // 旧版的
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
}

-(void)onPageStatusChanged:(ZCShowStatus)status message:(NSString *)message obj:(id)object{
    if (status == ZCShowStatusClearLockMsgBtn) {
        [self setDismissLockMsgBtn];
        return;
    }
    if(status == ZCShowStatusRefreshFastMenuView){
        // 会话保持刷新快捷菜单
        [self.fastMenuView refreshData];
        return;
    }
    if(status == ZCShowStatusShowReferenceMessage){
        SobotChatMessage *msg = object;
        [self.keyboardTools showReferenceMessage:msg];
        return;
    }
    if(status == ZCShowStatusConnectingUser){
//        _keyboardTools.btnConnectUser.enabled = NO;
    }else if(status == ZCShowLeaveEditViewWithTempleteId){
        [self showQuickLeaveView:object tempId:message];
    }else if(status == ZCShowStatusReConnectClick){
        // 清理掉未读消息
        [self setDismissLockMsgBtn];
        // 添加空白占位view ,有多语言切换 在显示切换语言列表时再判断一遍
        ZCPlatformInfo *info = [[ZCPlatformTools sharedInstance] getPlatformInfo];
        info.checkInitKey = @"";
        [[ZCPlatformTools sharedInstance] savePlatformInfo:info];
        [ZCLibClient getZCLibClient].libInitInfo.isFirstEntry = 0;
        //  要去初始化啊
        [self doSDKConfig];
    }else if(status == ZCShowStatusLeaveMsgPage){
        [self hiddenKeyboard];
        [[ZCUICore getUICore] openLeaveOrRecoredVC:NO dict:nil];
    }else if(status == ZCShowStatusLeaveOpenWithClose){
        [self hiddenKeyboard];
        [[ZCUICore getUICore] openLeaveOrRecoredVC:NO dict:@{@"msg": sobotConvertToString(message)}];
        
    }// 超过一定数量显示未读消息点击效果
    else if(status == ZCShowStatusUnRead){
        [self.listTable reloadData];
        
        // 此处要延迟1秒，否则visibleRows返回的数据不准确
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if([ZCUICore getUICore].chatMessages != nil && [ZCUICore getUICore].chatMessages.count > 0){
                if([ZCUICore getUICore].lineModel!=nil){
                    NSInteger index = [[ZCUICore getUICore].chatMessages indexOfObject:[ZCUICore getUICore].lineModel];
                    NSArray *visibleRows = [self.listTable indexPathsForVisibleRows];
                    BOOL isVisible = NO;
                    for(NSIndexPath *rows in visibleRows){
                        if(index == rows.row){
                            isVisible = YES;
                            break;
                        }
                    }
                    // 如果当前已经显示了，则不现在提醒按钮
                    if(!isVisible){
                        [self.goUnReadButton setTitle:message forState:UIControlStateNormal];
                        self.goUnReadButton.hidden = NO;
                    }
                }
            }
        });
    }else if(status == ZCShowStatusConnectFinished){
//        _keyboardTools.btnConnectUser.enabled = YES;
        
        [[ZCUICore getUICore] dismissGroupView];
        
        
    }else if(status == ZCShowStatusSatisfaction){
        [self hiddenKeyboard];
        
    }else if(status == ZCShowStatusGoBack){
        if(self.delegate && [self.delegate respondsToSelector:@selector(onBackFinish:closeClick:)]){
            NSDictionary *params = object;
            [self.delegate onBackFinish:[params[@"isFinish"] intValue] closeClick:[params[@"isClose"] intValue]];
         }
    }
    else if (status == ZCShowStatusReConnected) {
        // 当新会话键盘显示的时候要将快捷菜单移除掉
        if(_fastMenuView != nil){
            [_fastMenuView clearDataUpdateUIForNewSession];
        }
        // 新会话
        // 新的会话要将上一次的数据清空全部初始化在重新拉取
        [_listTable reloadData];
//        _isHadLoadHistory = NO;
        // 将仅人工模式 如果是延迟转人工开启 参数回执
        [_keyboardTools setKeyboardMenuByStatus:ZCKeyboardStatusNewSession];
        
        // 键盘状态发生变化了，需要重新设置table的高度，因为新会话的键盘高度变化了
        [self tableScrollToBottom];
        // 重新加载数据
        
        // 这里新会话键盘样式显示时，关闭切换机器人的入口
        // 新会话键盘弹起的时候也是要回收掉的
        self.changeRobotDragView.hidden  = YES;
        if (self.changeRobotDragView) {
            [self.changeRobotDragView removeFromSuperview];
            self.changeRobotDragView = nil;
        }
        return;
    }else if(status == ZCShowTextHeightChanged){
        // 清理掉数据
        [self setDismissLockMsgBtn];
        [self tableScrollToBottom];
    }else if(status == ZCSetKeyBoardStatus){
        ZCKeyboardViewStatus state = [object intValue];
        [_keyboardTools setKeyboardMenuByStatus:state];
        if(state == ZCKeyboardStatusUser){
            [_fastMenuView refreshData];
            self.changeRobotDragView.hidden  = YES;
            if (self.changeRobotDragView) {
                [self.changeRobotDragView removeFromSuperview];
                self.changeRobotDragView = nil;
            }
            if(self.delegate && [self.delegate respondsToSelector:@selector(onPageConnectStatusChange:)]){
                [self.delegate onPageConnectStatusChange:[self getZCIMConfig].isArtificial];
            }
        }else if(state == ZCKeyboardStatusRobot){
            [_fastMenuView refreshData];
            // 是否显示 多机器人按钮
            if ([self getZCIMConfig].robotSwitchFlag == 1) {
                if ([self getZCIMConfig].type != 2 && ![self getZCIMConfig].isArtificial) {
                    self.changeRobotDragView.hidden = NO;
                }else{
                    self.changeRobotDragView.hidden = YES;
                }
            }else{
                self.changeRobotDragView.hidden = YES;
            }
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(onPageConnectStatusChange:)]){
                [self.delegate onPageConnectStatusChange:NO];
            }
        }else if(state == ZCKeyboardStatusNewSession){
            // 新会话键盘弹起的时候也是要回收掉的
            self.changeRobotDragView.hidden  = YES;
            if (self.changeRobotDragView) {
                [self.changeRobotDragView removeFromSuperview];
                self.changeRobotDragView = nil;
            }
            [[ZCUICore getUICore] clearAiLoadingCell];
            [_listTable reloadData];
        }
    }else if(status == ZCShowStatusCloseSkillSet){
        [[ZCUICore getUICore] dismissGroupView];
        // 返回当前页面 结束会话回到启动页面
        if(self.delegate && [self.delegate respondsToSelector:@selector(onBackFinish:closeClick:)]){
            [self.delegate onBackFinish:YES closeClick:YES];
         }
        [self backChatView];
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
//                [self tableScrollToBottom];
                
                // 新功能 先不使用
                SobotChatMessage *chatMsg ;
                if (!sobotIsNull(object) && [object isKindOfClass:[SobotChatMessage class]]) {
                    chatMsg = (SobotChatMessage*)object;
                }
                if (!chatMsg.isLastAnswersMsg && chatMsg.isAnswersMsg ) {
                    // 不滚动 等待最后一条消息再刷新
                    return;
                }
                if (status == ZCShowStatusMessageChanged && !sobotIsNull(chatMsg) &&  (chatMsg.isLockMsg || (chatMsg.isLastAnswersMsg && chatMsg.isAnswersMsg)) ) {
                    if ([ZCUICore getUICore].isLockMsg && [ZCUICore getUICore].lockMsgCount >0) {
                        [ZCUICore getUICore].lockMsgCount ++;
                        self.lookMoreBtn.hidden = NO;
                        [self.lookMoreBtn setTitle:[NSString stringWithFormat:@"%d%@",[ZCUICore getUICore].lockMsgCount,SobotKitLocalString(@"条新消息")]  forState:0];
                        SLog(@"触发条件2--------------", nil);
                        return;
                    }
                    
                    // 是否是一问多答的场景
                    if (chatMsg.isLastAnswersMsg && chatMsg.isAnswersMsg) {
                        
                        NSIndexPath *indexpath2 ;
                        indexpath2 = [NSIndexPath indexPathForRow:[[ZCUICore getUICore].chatMessages count]-1 inSection:0];
                        BOOL isVisible = [self isCellFullyVisibleAtIndexPath:indexpath2];
                        if (!isVisible && chatMsg.answersCount >2) {
                            // 找到这次一问多答的消息
                            self.lookMoreBtn.hidden = NO;
                            [self.lookMoreBtn setTitle:[NSString stringWithFormat:@"%d%@",[ZCUICore getUICore].lockMsgCount + chatMsg.answersCount,SobotKitLocalString(@"条新消息")]  forState:0];
                            SLog(@"触发条件6 ========", nil);
                            // 拿到第一条 加上第一条的高度去设置偏移量
                            NSIndexPath *lastMessage = [NSIndexPath indexPathForRow:[ZCUICore getUICore].chatMessages.count-chatMsg.answersCount-1 inSection:0];
                            CGRect cellR = [self.listTable rectForRowAtIndexPath:lastMessage];
                            CGFloat py =  self.listTable.contentOffset.y + cellR.size.height;
//                            self.listTable.contentOffset = CGPointMake(0, py);
//                            [self.listTable setContentOffset:CGPointMake(self.listTable.contentOffset.x, py)];
                            
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                if([ZCUICore getUICore].chatMessages != nil && [ZCUICore getUICore].chatMessages.count > 0){
                                    if ([self.listTable numberOfRowsInSection:0] > 0) {
                                        NSIndexPath *lastMessage = [NSIndexPath indexPathForRow:[ZCUICore getUICore].chatMessages.count-chatMsg.answersCount-1 inSection:0];
                                        // 滚动到底部
                                        [self.listTable scrollToRowAtIndexPath:lastMessage atScrollPosition:UITableViewScrollPositionTop animated:YES];
                                    }
                                }
                            });
                            
                        }else{
                            [self tableScrollToBottom];
                        }
                        return;
                    }
                    
            
                    NSIndexPath *indexpath ;
                    indexpath = [NSIndexPath indexPathForRow:[[ZCUICore getUICore].chatMessages count]-1 inSection:0];
                    // 查看是滚动到了哪里了
                    CGRect cellR = [self.listTable rectForRowAtIndexPath:indexpath];
                    
                    // 这里有个81 需要处理 约束没有那么快  有误差
                    if (cellR.size.height == 81) {
                        cellR.size.height = 62;
                    }
                    SLog(@"cellR =========  %@", NSStringFromCGRect(cellR));
                    if (self.listTable.contentSize.height - cellR.origin.y < cellR.size.height && cellR.size.height >400) {
                        
                        [ZCUICore getUICore].isLockMsg = YES;
                        // 首条也是要加载的，只不过没有全部滚动完成
                        self.lookMoreBtn.hidden = NO;
                        [ZCUICore getUICore].lockMsgCount ++;
                        [self.lookMoreBtn setTitle:[NSString stringWithFormat:@"%d%@",[ZCUICore getUICore].lockMsgCount,SobotKitLocalString(@"条新消息")]  forState:0];
                        SLog(@"触发条件1--------------", nil);
//                        if (chatMsg.isLastAnswersMsg && chatMsg.isAnswersMsg) {
//                            // 找到这次一问多答的消息
//                            self.lookMoreBtn.hidden = NO;
//                            [self.lookMoreBtn setTitle:[NSString stringWithFormat:@"%d%@",[ZCUICore getUICore].lockMsgCount,SobotKitLocalString(@"条新消息")]  forState:0];
////                            找到下标
//                            int index = -1;
//                            for (int i = 0; i<[ZCUICore getUICore].chatMessages.count ; i++) {
//                                SobotChatMessage *item = [ZCUICore getUICore].chatMessages[i];
//                                if ([item.msgId isEqualToString:sobotConvertToString(chatMsg.msgId)] && item.isFisrtAnswersMsg) {
//                                    index = i;
//                                    break;
//                                }
//                            }
//                            if (index >-1) {
//                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                                    if([ZCUICore getUICore].chatMessages != nil && [ZCUICore getUICore].chatMessages.count > 0){
//                                        if ([self.listTable numberOfRowsInSection:0] > 0) {
//                                            NSIndexPath *lastMessage = [NSIndexPath indexPathForRow:index inSection:0];
//                                            // 滚动到底部
//                                            [self.listTable scrollToRowAtIndexPath:lastMessage atScrollPosition:UITableViewScrollPositionTop animated:YES];
//                                        }
//                                    }
//                                });
//                               
//                            }
//                        }
//                        else{
                            [self tableScrollToBottom];
//                        }
                    }else{
                    
                        if ([[ZCUICore getUICore].chatMessages count] >2) {
                                                        
                            NSIndexPath *indexpath2 ;
                            indexpath2 = [NSIndexPath indexPathForRow:[[ZCUICore getUICore].chatMessages count]-3 inSection:0];
                            BOOL isVisible = [self isCellFullyVisibleAtIndexPath:indexpath2];
                            if (!isVisible) {
                                if (self.listTable.contentSize.height - cellR.size.height - self.listTable.contentOffset.y >self.listTable.frame.size.height) {
                                    [ZCUICore getUICore].lockMsgCount ++;
                                    self.lookMoreBtn.hidden = NO;
                                    [self.lookMoreBtn setTitle:[NSString stringWithFormat:@"%d%@",[ZCUICore getUICore].lockMsgCount,SobotKitLocalString(@"条新消息")]  forState:0];
                                    SLog(@"触发条件5--------------", nil);
                                    return;
                                }
                            }
                        }
                                                
                        if (cellR.origin.y -(self.listTable.contentOffset.y + _listTable.frame.size.height) >_listTable.frame.size.height) {
                            // 滚动到中间了，不滚动，要显示
                            [ZCUICore getUICore].lockMsgCount ++;
                            self.lookMoreBtn.hidden = NO;
                            [self.lookMoreBtn setTitle:[NSString stringWithFormat:@"%d%@",[ZCUICore getUICore].lockMsgCount,SobotKitLocalString(@"条新消息")]  forState:0];
                            SLog(@"触发条件3--------------", nil);
                            // 没有达到条件 是滚动到底部显示
//                            [self tableScrollToBottom];
                            if (chatMsg.isLastAnswersMsg && chatMsg.isAnswersMsg) {
                                // 找到这次一问多答的消息
    //                            找到下标
                                int index = -1;
                                for (int i = 0; i<[ZCUICore getUICore].chatMessages.count ; i++) {
                                    SobotChatMessage *item = [ZCUICore getUICore].chatMessages[i];
                                    if ([item.qustionMsgId isEqualToString:sobotConvertToString(chatMsg.qustionMsgId)] && item.isFisrtAnswersMsg) {
                                        index = i;
                                        break;
                                    }
                                }
                                if (index >-1) {
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                        if([ZCUICore getUICore].chatMessages != nil && [ZCUICore getUICore].chatMessages.count > 0){
                                            if ([self.listTable numberOfRowsInSection:0] > 0) {
                                                NSIndexPath *lastMessage = [NSIndexPath indexPathForRow:index inSection:0];
                                                // 滚动到底部
                                                [self.listTable scrollToRowAtIndexPath:lastMessage atScrollPosition:UITableViewScrollPositionTop animated:YES];
                                            }
                                        }
                                    });
                                    self.lookMoreBtn.hidden = NO;
                                    [self.lookMoreBtn setTitle:[NSString stringWithFormat:@"%d%@",[ZCUICore getUICore].lockMsgCount,SobotKitLocalString(@"条新消息")]  forState:0];
                                }
                            }
                        }else{
                            // 没有达到条件 是滚动到底部显示
                            [self tableScrollToBottom];
                            [self setDismissLockMsgBtn];
                        }
                    }
                }else{
                    [self tableScrollToBottom];
                    [self setDismissLockMsgBtn];
                }
            }
        }
        
        if(!sobotIsNull(object)){
            SobotChatMessage *message = (SobotChatMessage*)object;
            if([message isKindOfClass:[SobotChatMessage class]]){
                if(message.msgType == SobotMessageTypeSound){
                    [self tableScrollToBottom]; // 最后一条消息是语音消息涉及到转文字的高度变化
                }
                
                if(sobotConvertToString(message.aiAgentCid).length > 0){
                    if(message.isReceiving){
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            if([ZCUICore getUICore].chatMessages != nil && [ZCUICore getUICore].chatMessages.count > 0){
                                if ([self.listTable numberOfRowsInSection:0] > 0) {
                                    NSIndexPath *lastMessage = [NSIndexPath indexPathForRow:[[ZCUICore getUICore].chatMessages count]-1 inSection:0];
//                                    // 滚动到底部
//                                    [self.listTable scrollToRowAtIndexPath:lastMessage atScrollPosition:UITableViewScrollPositionTop animated:YES];
                                    // 选中底部
                                    [self.listTable selectRowAtIndexPath:lastMessage animated:YES scrollPosition:UITableViewScrollPositionBottom];
                                }
                            }
                        });
                    }else{
                        [self tableScrollToBottom];
                    }
                }
            }
        }
        
        SobotChatMessage *newMsg = object;
        if(!sobotIsNull(object) && [object isKindOfClass:[SobotChatMessage class]] && sobotConvertToString(newMsg.msgId).length > 0){
            // 添加新消息,必须标记为readStatus=1的才发送已读消息
            if(newMsg.senderType != 0 && newMsg.senderType!=1 && [self getZCIMConfig].isArtificial && [self getZCIMConfig].readFlag==1 && newMsg.readStatus == 1){
                newMsg.readStatus = 2;
                // 机器人，记录已读
                [[ZCUICore getUICore].unReadMessageCache setObject:newMsg forKey:newMsg.msgId];
            }
        }
        // 发布已读消息标记
        [self updateMsgReadStatus];
        return;
    }else if (status == ZCShowStatusChangedTitle){
        // 更新标题
        [self setTitleName:sobotConvertToString(message)];
    }
    
}

#pragma mark -- 查看当前cell 是否在屏幕上
- (BOOL)isCellVisibleAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *visibleIndexPaths = [self.listTable indexPathsForVisibleRows];
    return [visibleIndexPaths containsObject:indexPath];
}

- (BOOL)isCellFullyVisibleAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.listTable cellForRowAtIndexPath:indexPath];
    if (!cell) {
        return [self isCellVisibleAtIndexPath:indexPath];
    }
    CGRect cellRect = [self.listTable rectForRowAtIndexPath:indexPath];
    CGRect visibleRect = CGRectMake(self.listTable.contentOffset.x, self.listTable.contentOffset.y, self.listTable.bounds.size.width, self.listTable.bounds.size.height);
    return CGRectContainsRect(visibleRect, cellRect);
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
    
    // 4.0.5新增，如果当前点击关闭按钮，没有提交留言添加一条提示语
    [_leaveEditView setCloseBlock:^(int code, int type) {
        // code = 0无提交操作，1有提交操作, type = 0 仅关闭，type=1，空白区域关闭，type=2提交关闭
        if(code == 0){
            SobotChatMessage *tempModel = object;
            // 说明已经添加过了，不需要再添加了
            if(tempModel && [tempModel isKindOfClass:[SobotChatMessage class]] && tempModel.action == SobotMessageActionTypeChat_UnWriteLeaveMsg){
                return;
            }
            NSString *content = [NSString stringWithFormat:@"%@ %@",SobotKitLocalString(@"您未提交信息，请"),SobotKitLocalString(@"重新填写信息")];
            SobotChatMessage *tipMsg2 = [[ZCUICore getUICore] addMessageToList:SobotMessageActionTypeChat_UnWriteLeaveMsg content:content type:SobotMessageTypeTipsText dict:@{@"templateId":sobotConvertToString(message)}];
            tipMsg2.contentTemp = content;

            [ZCLibServer sendLoopTipActionMsg:[safeSelf getZCIMConfig] title:@"多轮对话工单提交取消" msg:content updateStatus:0 msgId:tempModel.msgId deployId:tipMsg2.deployId start:^{

            } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {

            } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {

            }];
        }
    }];
    
    [_leaveEditView setResultBlock:^(int code, id  _Nonnull obj) {
        [safeSelf.leaveEditView tappedCancel:YES];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [safeSelf hiddenKeyboard];
        });
        
        // 添加成功
        if(code == 1){
            NSString *uploadMessage = obj;
            uploadMessage = [uploadMessage stringByReplacingOccurrencesOfString:@"$\n$" withString:@"<br/>"];
            uploadMessage = [uploadMessage stringByReplacingOccurrencesOfString:@"$:$" withString:@"<br/>"];
            //如果开启了
            [ZCLibServer insertSysMsg:[safeSelf getZCIMConfig] title:@"多轮对话工单提交确认提示" msg:uploadMessage start:^(NSString *url){
                
            } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
                if ([sobotConvertToString(dict[@"code"]) intValue] == 1 && ![safeSelf getZCIMConfig].isArtificial) {
                    // 说明已经添加过了，需要修改状态为未读
                    SobotChatMessage *tempModel = object;
                    if(tempModel && [tempModel isKindOfClass:[SobotChatMessage class]] && (tempModel.action == SobotMessageActionTypeChat_UnWriteLeaveMsg || tempModel.action == SobotMessageActionTypeChat_UnWriteLeaveMsgUnDo)){
                        [ZCLibServer sendLoopTipActionMsg:[safeSelf getZCIMConfig] title:@"多轮对话工单提交成功" msg:tempModel.contentTemp updateStatus:1 msgId:tempModel.msgId deployId:tempModel.deployId start:^{
                            
                        } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
                            
                        } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
                            
                        }];
                        
                        tempModel.action = SobotMessageActionTypeChat_UnWriteLeaveMsgUnDo;
                        tempModel.isHistory = YES;
                        tempModel.displayMsgAttr = nil;
                        tempModel.tipsMessage = sobotConvertToString(tempModel.contentTemp);
                    }
                    
                    // 添加成功提示
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
        safeSelf.leaveEditView.ticketContentShowFlag = [sobotConvertToString(dict[@"data"][@"item"][@"ticketContentShowFlag"]) boolValue];
        safeSelf.leaveEditView.ticketContentFillFlag = [sobotConvertToString(dict[@"data"][@"item"][@"ticketContentFillFlag"]) boolValue];
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

#pragma mark -- 是否要滚动到底部
-(void)tableScrollToBottomIsScroll:(BOOL)isScroll{
    // 查看是否开启锁定
    if ([ZCUICore getUICore].isLockMsg) {
        return;
    }
    
    if (isScroll) {
        [self tableScrollToBottom];
    }
}

-(void)tableScrollToBottom{
    if([ZCUICore getUICore].chatMessages.count <= 0){
        return;
    }
    if(self.keyboardTools.zc_keyBoardHeight > 0){
        // 处理键盘弹起移动问题
        if(self.listTable.contentSize.height < tableH){
//            _tableLayoutHeight.constant = tableH - self.keyboardTools.zc_keyBoardHeight;
            _tableLayoutTop.priority = UILayoutPriorityDefaultHigh;
        }else{
            _tableLayoutHeight.constant = tableH;
        }
    }else{
        _tableLayoutHeight.constant = tableH;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    NSInteger section = [self->_listTable numberOfSections] - 1; // 获取最后一个 section
        NSInteger row = [self->_listTable numberOfRowsInSection:section] - 1; // 获取最后一行
        
        if (section >= 0 && row >= 0) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            
            // 滚动到指定的 indexPath
            [self->_listTable scrollToRowAtIndexPath:indexPath
                                  atScrollPosition:UITableViewScrollPositionBottom
                                          animated:YES];
        }
    });
}

#pragma mark ZCUICore Delegate end
-(void)getHistoryMessage{
    [[ZCUICore getUICore] getChatMessages];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self scrollingFinish];
    }
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    [self scrollingFinish];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollingFinish];
}

// 停止滚动，标记当前消息是否已读
- (void)scrollingFinish {
    //enter code here
//    SLog(@"scrollingFinish");
    
//    if([self getZCIMConfig].readFlag == 1){
        NSArray *arr = self.listTable.visibleCells;
        for(ZCChatBaseCell *index in arr){
            SobotChatMessage *msg = index.tempModel;
            //        SLog(@"uid:%@\ncid:%@\nmsgId:%@",sobotConvertToString(msg.sender),sobotConvertToString(msg.cid),sobotConvertToString(msg.msgId));
            // 自己发送的(机器人通过接口判断，人工通过IM通道判断)
            if(msg.senderType==2){
                // 未标记，未读
                if(msg.readStatus == 1){
                    [[ZCUICore getUICore].unReadMessageCache setObject:msg forKey:sobotConvertToString(msg.msgId)];
                }
            }
            
        }
    [self updateMsgReadStatus];
//    }
    
    // 停止滚动时判断当前未读消息提醒是否已经显示，如果显示了就自动隐藏
    if(!self.goUnReadButton.hidden && [ZCUICore getUICore].lineModel!=nil){
        NSInteger index = [[ZCUICore getUICore].chatMessages indexOfObject:[ZCUICore getUICore].lineModel];
        NSArray *visibleRows = [self.listTable indexPathsForVisibleRows];
        BOOL isVisible = NO;
        for(NSIndexPath *rows in visibleRows){
            if(index == rows.row){
                isVisible = YES;
                break;
            }
        }
        // 如果当前已经显示了，则不现在提醒按钮
        if(isVisible){
            self.goUnReadButton.hidden = YES;
        }
    }
    
    // 停止滚动后 当前的最后一条消息 是否展示完了，如果展示完了就清理掉状态
    if ([ZCUICore getUICore].isLockMsg && [ZCUICore getUICore].lockMsgCount >0) {
        NSIndexPath *indexpath ;
        indexpath = [NSIndexPath indexPathForRow:[[ZCUICore getUICore].chatMessages count]-1 inSection:0];
        // 查看是滚动到了哪里了
        CGRect cellR = [self.listTable rectForRowAtIndexPath:indexpath];
        if (self.listTable.contentOffset.y - cellR.origin.y <= cellR.size.height) {
            [self setDismissLockMsgBtn];
        }
    }
//    SLog(@"self.listTable.contentOffset.y=== %f", self.listTable.contentOffset.y);
//    SLog(@"self.listTable.frame.heght == %f", self.listTable.frame.size.height);
//    SLog(@"========== %f", self.listTable.contentSize.height);
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self hiddenKeyboard];
    //全局回收键盘
    [self allHideKeyBoard];
    // 隐藏复制小气泡
    [[NSNotificationCenter defaultCenter] postNotificationName:UIMenuControllerDidHideMenuNotification object:nil];
}

#pragma mark -- 全局回收键盘
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

// 设置消息为已读
-(void)updateMsgReadStatus{
//    if([self getZCIMConfig].readFlag == 0){
//        return;
//    }
    if(!sobotIsNull([ZCUICore getUICore].unReadMessageCache) && [ZCUICore getUICore].unReadMessageCache.allKeys.count > 0){
        NSString *adminId = @"";
        if([self getZCIMConfig].isArtificial){
            adminId = [self getZCIMConfig].offlineMsgAdminId;
        }
        
        NSMutableArray *msgIds = [[NSMutableArray alloc] init];
        for(SobotChatMessage *chatMsg in [ZCUICore getUICore].unReadMessageCache.allValues){
            [msgIds addObject:@{@"cid":sobotConvertToString(chatMsg.cid),@"msgId":sobotConvertToString(chatMsg.msgId)}];
        }
        
        if(isSendReadState){
            return;
        }
        isSendReadState = YES;
        
        // 设置消息为已读
        [ZCLibServer realMarkReadToAdmin:[self getZCIMConfig] msgId:msgIds start:^(NSString * _Nonnull url) {
           
        } success:^(NSDictionary * _Nonnull dict, ZCNetWorkCode sendCode) {
            self->isSendReadState = NO;
            // 修改本地标记
            for(NSDictionary *readMsg in msgIds){
                NSString *readMsgId = sobotConvertToString(readMsg[@"msgId"]);
                [[ZCUICore getUICore].unReadMessageCache removeObjectForKey:sobotConvertToString(readMsgId)];
                
                // 循环设置当前消息已读
                for(SobotChatMessage *chatMsg in [ZCUICore getUICore].chatMessages){
                    if([chatMsg.msgId isEqual:readMsgId]){
                        chatMsg.readStatus = 2;
                    }
                }
            }
            
            // 本地不显示标记，无需调用
            [self.listTable reloadData];
            if([ZCUICore getUICore].unReadMessageCache.allKeys.count > 0){
                [self updateMsgReadStatus];
            }
        } failed:^(NSString * _Nonnull errorMessage, ZCNetWorkCode errorCode) {
            self->isSendReadState = NO;
            
        }];
    }
    
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
    
    if(model.msgType == SobotMessageTypeSound || model.msgType == SobotMessageTypeStartSound){
        cell = [tableView dequeueReusableCellWithIdentifier:@"ZCChatVoiceCell"];
        if (cell == nil) {
            cell = [[ZCChatVoiceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatVoiceCell"];
        }
    }else if(model.msgType == SobotMessageTypeShowAiLoading){
        cell = [tableView dequeueReusableCellWithIdentifier:@"ZCChatAiLoadingCell"];
        if (cell == nil) {
            cell = [[ZCChatAiLoadingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatAiLoadingCell"];
        }
    }else if (model.msgType == SobotMessageTypeAiagentEnum){
        cell = [tableView dequeueReusableCellWithIdentifier:@"ZCChatEnumCell"];
        if (cell == nil) {
            cell = [[ZCChatEnumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatEnumCell"];
        }
    }else if (model.msgType == SobotMessageTypeRobotRealuate){
        cell = [tableView dequeueReusableCellWithIdentifier:@"ZCChatStepOnBaseCell"];
        if (cell == nil) {
            cell = [[ZCChatStepOnBaseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatStepOnBaseCell"];
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
        }else if (model.action == SobotMessageActionTypeLanguage){
            cell = (ZCChatLanguageCell *)[tableView dequeueReusableCellWithIdentifier:@"ZCChatLanguageCell"];
            if (cell == nil) {
                cell = [[ZCChatLanguageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatLanguageCell"];
            }
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"ZCChatTipsCell"];
            if (cell == nil) {
                cell = [[ZCChatTipsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatTipsCell"];
            }
        }
    }else if(model.senderType ==  0 && model.includeSensitive > 0){
        // 已拒绝单独样式
        cell = [tableView dequeueReusableCellWithIdentifier:@"ZCChatSensitiveCell"];
        if (cell == nil) {
            cell = [[ZCChatSensitiveCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatSensitiveCell"];
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
    }else if (model.msgType == SobotMessageTypeFile){
        cell = (ZCChatFileCell*)[tableView dequeueReusableCellWithIdentifier:@"ZCChatFileCell"];
        if (cell == nil) {
            cell = [[ZCChatFileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatFileCell"];
        }
    }else if(model.msgType == SobotMessageTypeRichJson){
        if(model.richModel.type == SobotMessageRichJsonTypeCustomCard){
            SobotChatCustomCard *cardModel = model.richModel.customCard;
            // 判断是否显示单个商品
            BOOL isSingle = NO;
            if(cardModel.cardType == 1 && cardModel.cardStyle != 0){
                if(sobotConvertToString(cardModel.cardGuide).length == 0
                   && sobotConvertToString(cardModel.cardImg).length == 0
                   && sobotConvertToString(cardModel.cardDesc).length == 0
                   && cardModel.customCards.count == 1){
                    isSingle = YES;
                    // 不是发送方，显示发送、编辑等自定义按钮
                    if(model.senderType!=0){
                        cell = (ZCChatCustomCardSingleCell*)[tableView dequeueReusableCellWithIdentifier:@"ZCChatCustomCardSingleCell"];
                        if (cell == nil) {
                            cell =  [[ZCChatCustomCardSingleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatCustomCardSingleCell"];
                        }
                    }else{
                        cell = (ZCChatCustomCardSingleSendCell*)[tableView dequeueReusableCellWithIdentifier:@"ZCChatCustomCardSingleSendCell"];
                        if (cell == nil) {
                            cell =  [[ZCChatCustomCardSingleSendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatCustomCardSingleSendCell"];
                        }
                    }
                }
            }
            if(!isSingle){
                // 平铺
                if(cardModel.cardStyle == 0){
                    cell = (ZCChatCustomCardHorizontalCell*)[tableView dequeueReusableCellWithIdentifier:@"ZCChatCustomCardHorizontalCell"];
                    if (cell == nil) {
                        cell =  [[ZCChatCustomCardHorizontalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatCustomCardHorizontalCell"];
                    }
                }else{
                    cell = (ZCChatCustomCardVerticalCell*)[tableView dequeueReusableCellWithIdentifier:@"ZCChatCustomCardVerticalCell"];
                    if (cell == nil) {
                        cell =  [[ZCChatCustomCardVerticalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatCustomCardVerticalCell"];
                    }
                }
                
            }
        }else if (model.richModel.type == SobotMessageRichJsonTypeAiCustomCard){
            // 大模型机器人 显示自定义卡片
            if (model.senderType == 0) {
                // 是用户发送的大模型消息卡片
                cell = (ZCChatAiCustomCardUserCell*)[tableView dequeueReusableCellWithIdentifier:@"ZCChatAiCustomCardUserCell"];
                if (cell == nil) {
                    cell = [[ZCChatAiCustomCardUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatAiCustomCardUserCell"];
                }
            }else{
                cell = (ZCChatAiCustomCardCell*)[tableView dequeueReusableCellWithIdentifier:@"ZCChatAiCustomCardCell"];
                if (cell == nil) {
                    cell = [[ZCChatAiCustomCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatAiCustomCardCell"];
                }
            }
        }else if(model.richModel.type == SobotMessageRichJsonTypeLoop){
            if(model.richModel.richContent.templateId <= 2 && model.richModel.richContent.templateId != 1){
                cell = [tableView dequeueReusableCellWithIdentifier:@"ZCChatWheel123Cell"];
                if (cell == nil) {
                    cell = [[ZCChatWheel123Cell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatWheel123Cell"];
                }
            }
            if (model.richModel.richContent.templateId == 1) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"ZCChatWhell1Cell"];
                if (cell == nil) {
                    cell = [[ZCChatWhell1Cell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatWhell1Cell"];
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
    }else if(model.msgType == SobotMessageTypeText){
        // 可能不需要,4.1.0版本修改，以前会自动使用ZCChatRichCell
        if(sobotIsNull(model.richModel.richList) || model.richModel.richList.count == 0){
            cell = [tableView dequeueReusableCellWithIdentifier:@"ZCChatTextCell"];
            if (cell == nil) {
                cell = [[ZCChatTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatTextCell"];
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
    
    // 开启人工已读未读，机器人在发送时处理
    if([self getZCIMConfig].readFlag && model.senderType==2){
        // 未标记，未读
        if(model.readStatus == 1){
            [[ZCUICore getUICore].unReadMessageCache setObject:model forKey:sobotConvertToString(model.msgId)];
        }
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
    // TODO 这里有问题
    if([ZCUICore getUICore].getLibConfig.isArtificial && model.senderType!=2){// [self getZCIMConfig].isArtificial
        // 排除重新填写信息
        if(model.action != SobotMessageActionTypeChat_UnWriteLeaveMsg){
            // 人工时，所有的机器人消息都不可以点击,把它变成历史消息
            model.isHistory = YES;
        }
    }
    
    if(model.msgType == SobotMessageTypeTipsText ){
        time = @"";
    }
    if (model.action == SobotMessageActionTypeLanguage || model.action == SobotMessageActionTypeSelLanguage) {
        // 显示时间获取当前时间
//        time = sobotDateTransformString(format, sobotStringFormateDate(model.ts));
        time = sobotDateTransformString(format,[NSDate date]);
    }
    
    // 不是中文时，不显示时间
    //    if([ZCUICore getUICore].kitInfo.hideChatTime && (![zcGetLanguagePrefix() hasPrefix:@"zh-"] || ![[ZCLibClient getZCLibClient].libInitInfo.absolute_language hasPrefix:@"zh-"])){
    if([ZCUICore getUICore].kitInfo.hideChatTime){
        time = @"";
    }
    // 是否显示发送的头像和名称，不是同一个发送者或者2条消息大于1分钟
    model.isShowSenderFlag = [self checkShowSenerMessage:model index:(int)indexPath.row];
    cell.indexPath = indexPath;
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
    
    if (lastMessage.action == SobotMessageActionTypeAdminTipWord || lastMessage.action == SobotMessageActionTypeUserTipWord) {
        // 超时提示语
        return YES;
    }
    
    if(index -1 >= 0 && [ZCUICore getUICore].chatMessages.count > 0){
        SobotChatMessage *chat = [ZCUICore getUICore].chatMessages[index - 1];
        // 仅与上一个相比就可以了,并且上一个不是提示语
        if(![chat.senderName isEqual:lastMessage.senderName] || chat.msgType == SobotMessageTypeTipsText || chat.msgType == SobotMessageTypeHotGuide){
            return YES;
        }
        
        if(![chat.cid isEqual:lastMessage.cid]){
            return YES;
        }
    }
    for (int i=(index-1);i>=0;i--) {
        if((i > [ZCUICore getUICore].chatMessages.count -1) || [ZCUICore getUICore].chatMessages.count == 0 || sobotIsNull([ZCUICore getUICore].chatMessages)){
            return NO; // 防止数组越界
        }
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

#pragma mark -- 切换初始化配置语言
-(void)changeLanguage:(ZCLanguageModel*)model{
    // *注意* 该接口如果超时或者异常 都放行，不拦截初始化流程
    [ZCLibServer sendToAdminChooseLan:sobotConvertToString(model.code) uid:[[ZCUICore getUICore] getLibConfig].uid start:^(NSString * _Nonnull urlString) {
        
    } success:^(NSDictionary * _Nonnull dict, ZCNetWorkCode sendCode) {
        if (dict && [[dict allKeys] containsObject:@"code"] && [sobotConvertToString([dict objectForKey:@"code"]) intValue]) {
            NSDictionary *data = [dict objectForKey:@"data"];
            if (sobotConvertToString([data objectForKey:@"adminNonelineTitle"]).length >0) {
                [[ZCUICore getUICore] getLibConfig].adminNonelineTitle = sobotConvertToString([data objectForKey:@"adminNonelineTitle"]);
            }
            if (sobotConvertToString([data objectForKey:@"manualCommentTitle"]).length >0) {
                [[ZCUICore getUICore] getLibConfig].manualCommentTitle = sobotConvertToString([data objectForKey:@"manualCommentTitle"]);
            }
            // 初始化接口没有这个字段临时添加
            if (sobotConvertToString([data objectForKey:@"queueToMsgDoc"]).length >0) {
                [[ZCUICore getUICore] getLibConfig].queueToMsgDoc = sobotConvertToString([data objectForKey:@"queueToMsgDoc"]);
            }
            if (sobotConvertToString([data objectForKey:@"robotCommentTitle"]).length >0) {
                [[ZCUICore getUICore] getLibConfig].robotCommentTitle = sobotConvertToString([data objectForKey:@"robotCommentTitle"]);
            }
            if (sobotConvertToString([data objectForKey:@"serviceEndPushMsg"]).length >0) {
                [[ZCUICore getUICore] getLibConfig].serviceEndPushMsg = sobotConvertToString([data objectForKey:@"serviceEndPushMsg"]);
            }
            
            if ([ZCUICore getUICore].changeLanguageBlock) {
                [ZCUICore getUICore].changeLanguageBlock(model,data);
            }
            
        }else{
            if ([ZCUICore getUICore].changeLanguageBlock) {
                [ZCUICore getUICore].changeLanguageBlock([ZCLanguageModel new],@{});
            }
        }
    } failed:^(NSString * _Nonnull errorMessage, ZCNetWorkCode errorCode) {
        if ([ZCUICore getUICore].changeLanguageBlock) {
            [ZCUICore getUICore].changeLanguageBlock([ZCLanguageModel new],@{});
        }
    } finish:^(NSString * _Nonnull jsonString) {
        
    }];
}

#pragma mark -- 大模型机器人点击卡片发送
-(void)aiRobotCellItemClick:(SobotChatMessage *)model type:(ZCChatCellClickType)type text:(NSString *)text obj:(id)object Menu:(SobotChatCustomCardMenu *)menu{
    if (type == ZCChatCellClickTypeAiRobotBtnClickSendMsg) {
        NSString *btnName = @"";
        // 发送 自定义卡片 大模型 机器人
        if ([text isEqualToString:@"1"]) {
            // 点击卡片发送
        }else{
            // 点击按钮发送
            btnName = sobotConvertToString(menu.menuName);
        }
        SobotChatCustomCard *card = model.richModel.customCard;
        
        NSMutableDictionary *interfaceInfo = [NSMutableDictionary dictionaryWithDictionary:card.sourceDict];
        [interfaceInfo setValue:@"0" forKey:@"cardStyle"];
        // 点击的单个卡片
        SobotChatCustomCardInfo *infocard = (SobotChatCustomCardInfo *)object;
        NSDictionary *infocardDict = infocard.sourceDict;
        NSDictionary *showQuestion = @{@"cardStyle":@"0",
                                       @"cardType":sobotConvertToString([interfaceInfo objectForKey:@"cardType"]),
                                       @"cardForm":@"1",
                                       @"cardGuide":sobotConvertToString([interfaceInfo objectForKey:@"cardGuide"]),
                                       @"customCards":@[infocardDict],
        };
        
        
        NSMutableArray *senParmArr = [NSMutableArray array];

        for (NSDictionary *item in infocard.paramInfos) {
            NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
            if (sobotIsNull([item objectForKey:@"variableId"])) {
                [newDict setObject:[NSNull null] forKey:@"variableId"];
            }else{
                [newDict setObject:sobotConvertToString([item objectForKey:@"variableId"]) forKey:@"variableId"];
            }
            [newDict setObject:sobotConvertToString([item objectForKey:@"paramValue"]) forKey:@"variableValue"];
           
            [newDict setObject:sobotConvertToString(btnName) forKey:@"customCardButtonName"];
            [newDict setObject:sobotConvertToString(model.nodeId) forKey:@"nodeId"];
            [newDict setObject:sobotConvertToString(model.processId) forKey:@"processId"];
            [senParmArr addObject:newDict];
        }
        //showQuestion 和 senParmArr 接口要转换成json
        NSError *error;
        NSData *jsonDataDict = [NSJSONSerialization dataWithJSONObject:showQuestion options:NSJSONWritingFragmentsAllowed error:&error];
//        NSData *jsonDataDict = [NSJSONSerialization dataWithJSONObject:showQuestion options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonStringDict = [[NSString alloc] initWithData:jsonDataDict encoding:NSUTF8StringEncoding];

        NSData *jsonDataArray = [NSJSONSerialization dataWithJSONObject:senParmArr options:NSJSONWritingFragmentsAllowed error:&error];
//        NSData *jsonDataArray = [NSJSONSerialization dataWithJSONObject:senParmArr options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonStringArray = [[NSString alloc] initWithData:jsonDataArray encoding:NSUTF8StringEncoding];

        NSDictionary *params = @{@"interfaceInfo":interfaceInfo,
                                 @"showQuestion":sobotConvertToString(jsonStringDict),
                                 @"question":sobotConvertToString(jsonStringArray),
                                 @"questionFlag":@"4",
                                 @"showCard":showQuestion
        };
        [[ZCUICore getUICore] sendMessage:@"" type:SobotMessageTypeRichJson exParams:params duration:@"" richType:SobotMessageRichJsonTypeAiCustomCard];
        return;
    }
}

#pragma mark tableviewcell delegate start 行事件处理
-(void)cellItemClick:(SobotChatMessage *)model type:(ZCChatCellClickType)type text:(NSString *)text obj:(id)object{
   
    if (type == ZCChatCellClickLookMoreCard) {
        [self hiddenKeyboard];
        //查看更多大模型机器人卡片
        ZCChatAiCustomCardPage *vc = [[ZCChatAiCustomCardPage alloc] initActionSheet:model.richModel.customCard WithView:self    cardModel:model.richModel.customCard];
        vc.orderSetClickBlock = ^(SobotChatMessage *megModel,SobotChatCustomCard *itemModel, SobotChatCustomCardInfo *model, SobotChatCustomCardMenu *menu, int type) {
            [self aiRobotCellItemClick:megModel type:ZCChatCellClickTypeAiRobotBtnClickSendMsg text:[NSString stringWithFormat:@"%d",type] obj:model Menu:menu];
        };
        vc.megModel = model;
        vc.isHistory = model.isHistory;
        [vc updataPage];
        ZCPageSheetView *sheetView = [[ZCPageSheetView alloc] initWithTitle:SobotKitLocalString(@"选择您要查询的订单") superView:self showView:vc type:ZCPageSheetTypeLong];
        [sheetView showSheet:vc.frame.size.height animation:YES block:^{

        }];
        return;
    }
    
    // 展示更多语言
    if (type == ZCChatCellClickTypeOpenMoreLanguage) {
        ZCLanguageView *vc = [[ZCLanguageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0)];
        vc.listArray = [NSMutableArray arrayWithArray:[[ZCUICore getUICore] getLibConfig].languageArr];
        vc.searchArray = [NSMutableArray arrayWithArray:[[ZCUICore getUICore] getLibConfig].languageArr];
        vc.orderCusFiledCheckBlock = ^(ZCLanguageModel *model, NSMutableArray *arr) {
            if (!sobotIsNull(model)) {
                // 选完语言之后切换初始化配置
                [self changeLanguage:model];
            }
        };
        [vc updataPage];
        ZCPageSheetView *sheetView = [[ZCPageSheetView alloc] initWithTitle:SobotKitLocalString(@"选择") superView:self showView:vc type:ZCPageSheetTypeLong];
        [sheetView showSheet:vc.frame.size.height animation:YES block:^{

        }];
        return;
    }
    // 切换语言
    if (type == ZCChatCellClickTypeSelLanguage) {
        ZCLanguageModel *model = (ZCLanguageModel *)object;
        [self changeLanguage:model];
        return;
    }
    
    if(type == ZCChatCellClickTypeSendGoosText){
        [[ZCUICore getUICore] sendProductInfo:[ZCUICore getUICore].kitInfo.productInfo resultBlock:^(NSString * _Nonnull msg, int code) {
            
        }];
    }else if(type == ZCChatCellClickTypeItemCloseKeyboard){
        [self hiddenKeyboard];
    }else if(type == ZCChatCellClickTypeItemClickCusCardButoon || type == ZCChatCellClickTypeItemClickCusCardInfoButoon){
        SobotChatCustomCardMenu *menu = object;
        if(menu.menuType == 2){
            if(type == ZCChatCellClickTypeItemClickCusCardInfoButoon){
                // 发送单个商品
                if(model && model.richModel && model.richModel.customCard && model.richModel.customCard.customCards.count > [sobotConvertToString(text) intValue]){
                    SobotChatCustomCardInfo *info = model.richModel.customCard.customCards[[sobotConvertToString(text) intValue]];
                    
                    SobotChatCustomCard *card = [[SobotChatCustomCard alloc] init];
                    card.cardType = model.richModel.customCard.cardType;
                    card.cardStyle = model.richModel.customCard.cardStyle;
                    card.ticketPartnerField = model.richModel.customCard.ticketPartnerField;
                    card.customField = model.richModel.customCard.customField;
//                    SobotChatCustomCard *card = [[SobotChatCustomCard alloc] initWithMyDict:[SobotCache getObjectData:model.richModel.customCard]];
                    card.customCards = [[NSMutableArray alloc] initWithObjects:info, nil];
                    NSLog(@"调用了 -----4");
                    [[ZCUICore getUICore] sendCusCardMessage:card type:1 isRobot:![ZCUICore getUICore].getLibConfig.isArtificial isFirst:NO];
                }
            }else{
                NSLog(@"调用了 -----5");
                // 发送整个卡片
                [[ZCUICore getUICore] sendCusCardMessage:model.richModel.customCard type:1 isRobot:![ZCUICore getUICore].getLibConfig.isArtificial isFirst:NO];
            }
        }
        else{
            if (menu.menuType == 0) {
                // 调整链接
                [[ZCUICore getUICore] dealWithLinkClickWithLick:sobotConvertToString(menu.menuLink) viewController:[SobotUITools getCurrentVC]];
            }
        }
        [[ZCUICore getUICore] addCusCardMenuClick:menu];
        return;
    }else if(type == ZCChatCellClickTypeItemRefreshData){
        model.showAllMessage = YES;
        // 展示所有消息
        [self.listTable reloadData];
        return;
    } else if(type == ZCChatCellClickTypeItemResendLeaveMsg){
        // 多伦留言提醒，重新发送留言消息
        [self onPageStatusChanged:ZCShowLeaveEditViewWithTempleteId message:model.deployId obj:model];
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
//        [self openNewPage:leaveMessageVC];
        if (self.delegate && [self.delegate respondsToSelector:@selector(jumpDocumentVC:)]) {
            [self.delegate jumpDocumentVC:leaveMessageVC];
        }
        return;
    }else if (type == ZCChatCellClickTypeLeaveMessage) {
        [self hiddenKeyboard];
        // 不直接退出SDK
        [[ZCUICore getUICore] openLeaveOrRecoredVC:NO dict:nil];
    }else if (type == ZCChatCellClickTypeLeaveRecordPage) {
       [self hiddenKeyboard];
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
    }else if (type == ZCChatCellClickTypeItemShowallsensitive) {
        model.showAllMessage = !model.showAllMessage;
        // 展示所有敏感词
        [self.listTable reloadData];
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
        [ZCLibClient getZCLibClient].libInitInfo.isFirstEntry = 0;
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
       [self hiddenKeyboard];
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
        
//        // 已经有播放的，关闭当前播放的
//        if(playModel && [model isEqual:playModel]){
//            playModel.isPlaying=NO;
//            playModel=nil;
//            [[SobotVoiceTools shareSobotVoiceTools] sotpPlayVoide];
//        }
//        playModel=model;
//        playModel.isPlaying=YES;
//        // 这里要区分 是否是本地的还是网络的加载地址，本地有本地优先，解决播放动画和加载进度不一致的问题
//        NSString *urlStr = sobotConvertToString(model.richModel.url);
//        if (sobotConvertToString(model.richModel.richmoreurl).length > 0) {
//            urlStr = sobotConvertToString(model.richModel.richmoreurl);
//        }
//        [[SobotVoiceTools shareSobotVoiceTools] startWithModel:urlStr view:object category:SobotAudioSessionCategoryPlayback];
        
        // 上面是4.2.2版本的逻辑
        // 1.查看当前对象是否同一个 如果是同一个正在播放 暂停播放 如果不是同一个 暂停上一个，播放下一个
        
        // 这里要区分 是否是本地的还是网络的加载地址，本地有本地优先，解决播放动画和加载进度不一致的问题
        NSString *urlStr = sobotConvertToString(model.richModel.url);
        if (sobotConvertToString(model.richModel.richmoreurl).length > 0) {
            urlStr = sobotConvertToString(model.richModel.richmoreurl);
        }
        
        if (sobotConvertToString([SobotVoiceTools shareSobotVoiceTools].fileUrl).length == 0) {
            // 已经有播放的，关闭当前播放的
            if(playModel && [model isEqual:playModel]){
                playModel.isPlaying=NO;
                playModel=nil;
                [[SobotVoiceTools shareSobotVoiceTools] sotpPlayVoide];
            }
            playModel=model;
            playModel.isPlaying=YES;
            animateView = object;
            [[SobotVoiceTools shareSobotVoiceTools] startWithModel:urlStr view:object category:SobotAudioSessionCategoryPlayback];
        }else{
            if ([sobotConvertToString([SobotVoiceTools shareSobotVoiceTools].fileUrl) isEqualToString:sobotConvertToString(urlStr)]) {
                // 是同一个 查看当前是否正在播放，如果是播放-》暂停 如果是暂停-》播放
                // 播放暂停
                if (![[SobotVoiceTools shareSobotVoiceTools] getIsPlay]) {
                    [[SobotVoiceTools shareSobotVoiceTools] startPlayVoide];
                }else{
                   // 正在播放 要暂停
                    [[SobotVoiceTools shareSobotVoiceTools] pausePlayVoide];
                }
            }else{
                // 已经有播放的，关闭当前播放的
                if(playModel && [model isEqual:playModel]){
                    playModel.isPlaying=NO;
                    playModel=nil;
//                    [[SobotVoiceTools shareSobotVoiceTools] sotpPlayVoide];
                }
                [[SobotVoiceTools shareSobotVoiceTools] sotpPlayVoide];
                playModel=model;
                playModel.isPlaying=YES;
                animateView = object;
                [[SobotVoiceTools shareSobotVoiceTools] startWithModel:urlStr view:object category:SobotAudioSessionCategoryPlayback];
            }
        }
        
        
    }else if(type == ZCShowStatusGoBack){
        if(self.delegate && [self.delegate respondsToSelector:@selector(onBackFinish:closeClick:)]){
            NSDictionary *params = object;
            [self.delegate onBackFinish:[params[@"isFinish"] intValue] closeClick:[params[@"isClose"] intValue]];
         }
    }else if (type == ZCChatCellClickTypeAiRobotBtnClickSendMsg){
        // 大模型机器人 点击 按钮卡片发送消息 给大模型机器人
        if(_keyboardTools.curKeyboardStatus == ZCKeyboardStatusNewSession){
            [ZCUICore getUICore].isAdminServerBeforeCloseSession = [self getZCIMConfig].isArtificial;
            // 会话已结束，不能再发送消息
            [[ZCUICore getUICore] addMessageToList:SobotMessageActionTypeOverWord content:@"" type:SobotMessageTypeTipsText dict:nil];
            return;
        }
        // 向导内容
        NSDictionary *dict =  object;
        NSString *title = dict[@"processInfo"][@"variableValue"];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:dict];
        [[ZCUICore getUICore] sendMessage:title type:SobotMessageTypeText exParams:params duration:@"" richType:SobotMessageRichJsonTypeText];
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
            if (sobotConvertToString([dict objectForKey:@"fromEnum"]).length >0) {
                params[@"fromEnum"] = sobotConvertToString([dict objectForKey:@"fromEnum"]);
            }
        }else{
            params[@"requestText"] = dict[@"question"];
            params[@"questionFlag"] = @"1";
        }
//        if ([ZCUICore getUICore].aiAgentAsking && ![[ZCUICore getUICore] getLibConfig].isArtificial) {
//            return;
//        }
        [[ZCUICore getUICore] sendMessage:title type:SobotMessageTypeText exParams:params duration:@"" richType:SobotMessageRichJsonTypeText];
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
        
        if (_keyboardTools.curKeyboardStatus == ZCKeyboardStatusUser) {
            // 转人工之后也清理掉
            [[ZCUICore getUICore] removeRobotSubmitMsg];
//            model.commentType = 4;
            [_listTable  reloadData];
            return;
        }
        
        int status = (type == ZCChatCellClickTypeStepOn)?-1:1;
#pragma mark - 机器人点踩调用接口
        
       // 这里要区分大模型机器人和普通机器人
        if ([ZCUICore getUICore].getLibConfig.aiAgent) {
            if ( model.realuateConfigInfo.realuateInfoFlag && status == -1) {
                SobotChatMessage *robotModel = [[ZCUICore getUICore] addMessageToList:SobotMessageActionTypeRobotTip content:sobotConvertToString(model.realuateConfigInfo.realuateSubmitWordLan) type:SobotMessageTypeRobotRealuate dict:nil];
                robotModel.realuateConfigInfo = model.realuateConfigInfo;
                robotModel.robotTipMsg = sobotConvertToString(model.realuateConfigInfo.realuateAfterWord);
                robotModel.submitStatus = @"1";
                robotModel.aiAgentCid = model.aiAgentCid;
                robotModel.content = model.content;
                robotModel.msgId = model.msgId;
                // 变成已踩，因为大模型机器人不会插入消息
                model.commentType = 3;
                // 展示本地消息 25的
                [[ZCUICore getUICore] addRobotRealuateMsg:model newMsg:robotModel];
                
                // 大模型点踩也要同时调用提交接口
//                "tagName": "This is not the question I want to ask",
//                    "tagId": "e6f7be9e9c424429bb59d1cb80c38422",
//                   "realuateInfoFlag": 1,
//                这三个字段都不要传
                
                NSMutableDictionary *param = [NSMutableDictionary dictionary];
                [param setObject:sobotConvertToString([ZCUICore getUICore].getLibConfig.uid) forKey:@"uid"];
                [param setObject:sobotConvertToString([ZCUICore getUICore].getLibConfig.cid) forKey:@"cid"];
                [param setObject:sobotConvertToString(model.msgId) forKey:@"msgId"];
                [param setObject:sobotConvertToString(model.aiAgentCid) forKey:@"aiAgentCid"];
                [param setObject:[NSString stringWithFormat:@"%d",model.robotflag] forKey:@"robotFlag"];
                [param setObject:sobotConvertToString([ZCUICore getUICore].getLibConfig.companyID) forKey:@"companyId"];
                [param setObject:@"APP" forKey:@"sourceEnum"];
                [param setObject:@"0" forKey:@"status"];
                [param setObject:[NSString stringWithFormat:@"%d",[ZCUICore getUICore].getLibConfig.realuateFlag] forKey:@"realuateFlag"];
                [param setObject:[NSString stringWithFormat:@"%d",[ZCUICore getUICore].getLibConfig.realuateButtonStyle] forKey:@"realuateButtonStyle"];
                [param setObject:[NSString stringWithFormat:@"%d",[ZCUICore getUICore].getLibConfig.realuateStyle] forKey:@"realuateStyle"];
                [param setObject:sobotConvertToString(model.content) forKey:@"answer"];
                [param setObject:sobotConvertToString(model.realuateConfigInfo.realuateSubmitWord) forKey:@"realuateSubmitWord"];
                [ZCLibServer postAiAgentRobotAnswerComment:param start:^(NSString * _Nonnull url) {
                    
                } success:^(NSDictionary * _Nonnull dict, ZCNetWorkCode sendCode) {
//                    if(status== -1){
//                        if(model.commentType == 2){
//                            model.commentType = 0;
//                        }else{
//                            model.commentType = 3;
//                        }
//                        if (model.realuateConfigInfo.realuateInfoFlag && status == -1){
//        //                    不弹提示
//                        }else{
//                            [[SobotToast shareToast] showToast:SobotKitLocalString(@"我会努力学习，希望下次帮到您") duration:1.5f position:SobotToastPositionCenter];
//                        }
//                        
//                    }else{
//                        if(model.commentType == 3){
//                            model.commentType = 0;
//                        }else{
//                            model.commentType = 2;
//                        }
//                        if (model.realuateConfigInfo.realuateInfoFlag && status == -1){
//                            // 不弹提示
//                        }else{
//                            [[SobotToast shareToast] showToast:SobotKitLocalString(@"感谢您的支持") duration:1.5f position:SobotToastPositionCenter];
//                        }
//                    }
                    model.commentType = 3;
                    [self->_listTable  reloadData];
                } failed:^(NSString * _Nonnull errorMessage, ZCNetWorkCode errorCode) {
                    if (sobotConvertToString(errorMessage).length >0) {
                        [[SobotToast shareToast] showToast:sobotConvertToString(errorMessage) duration:2 position:SobotToastPositionCenter];
                    }
                }];

                
            }else{
                NSMutableDictionary *param = [NSMutableDictionary dictionary];
                [param setObject:sobotConvertToString([ZCUICore getUICore].getLibConfig.uid) forKey:@"uid"];
                [param setObject:sobotConvertToString([ZCUICore getUICore].getLibConfig.cid) forKey:@"cid"];
                [param setObject:sobotConvertToString(model.msgId) forKey:@"msgId"];
                [param setObject:sobotConvertToString(model.aiAgentCid) forKey:@"aiAgentCid"];
                [param setObject:[NSString stringWithFormat:@"%d",model.robotflag] forKey:@"robotFlag"];
                [param setObject:sobotConvertToString([ZCUICore getUICore].getLibConfig.companyID) forKey:@"companyId"];
                [param setObject:@"APP" forKey:@"sourceEnum"];
                if (status == -1) {
                    [param setObject:@"0" forKey:@"status"];
                }else{
                    [param setObject:@"1" forKey:@"status"];
                }
                
                [param setObject:[NSString stringWithFormat:@"%d",[ZCUICore getUICore].getLibConfig.realuateFlag] forKey:@"realuateFlag"];
                [param setObject:[NSString stringWithFormat:@"%d",[ZCUICore getUICore].getLibConfig.realuateButtonStyle] forKey:@"realuateButtonStyle"];
                [param setObject:[NSString stringWithFormat:@"%d",[ZCUICore getUICore].getLibConfig.realuateStyle] forKey:@"realuateStyle"];
                [param setObject:sobotConvertToString(model.content) forKey:@"answer"];
                [param setObject:sobotConvertToString(model.realuateConfigInfo.realuateSubmitWord) forKey:@"realuateSubmitWord"];
                [ZCLibServer postAiAgentRobotAnswerComment:param start:^(NSString * _Nonnull url) {
                    
                } success:^(NSDictionary * _Nonnull dict, ZCNetWorkCode sendCode) {
                    if(status== -1){
                        if(model.commentType == 2){
                            model.commentType = 0;
                        }else{
                            model.commentType = 3;
                        }
                        if (model.realuateConfigInfo.realuateInfoFlag && status == -1){
        //                    不弹提示
                        }else{
                            [[SobotToast shareToast] showToast:SobotKitLocalString(@"我会努力学习，希望下次帮到您") duration:1.5f position:SobotToastPositionCenter];
                        }
                        
                    }else{
                        if(model.commentType == 3){
                            model.commentType = 0;
                        }else{
                            model.commentType = 2;
                        }
                        if (model.realuateConfigInfo.realuateInfoFlag && status == -1){
                            // 不弹提示
                        }else{
                            [[SobotToast shareToast] showToast:SobotKitLocalString(@"感谢您的支持") duration:1.5f position:SobotToastPositionCenter];
                        }
                    }
                    [self->_listTable  reloadData];
                } failed:^(NSString * _Nonnull errorMessage, ZCNetWorkCode errorCode) {
                    if (sobotConvertToString(errorMessage).length >0) {
                        [[SobotToast shareToast] showToast:sobotConvertToString(errorMessage) duration:2 position:SobotToastPositionCenter];
                    }
                }];
            }
            // 转人工提示语
            if ([ZCUICore getUICore].getLibConfig.realuateTransferFlag && type == ZCChatCellClickTypeStepOn && [self getZCIMConfig].type != 1) {// 仅机器人模式不可以触发
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
        }else{
            // 普通机器人
            [ZCLibServer rbAnswerComment:[self getZCIMConfig] message:model status:status start:^(NSString *url){
                
            } success:^(ZCNetWorkCode code) {
                if(status== -1){
                    if(model.commentType == 2){
                        model.commentType = 0;
                    }else{
                        model.commentType = 3;
                    }
                    if (model.realuateConfigInfo.realuateInfoFlag && status == -1){
    //                    不弹提示
                    }else{
                        [[SobotToast shareToast] showToast:SobotKitLocalString(@"我会努力学习，希望下次帮到您") duration:1.5f position:SobotToastPositionCenter];
                    }
                    
                }else{
                    if(model.commentType == 3){
                        model.commentType = 0;
                    }else{
                        model.commentType = 2;
                    }
                    if (model.realuateConfigInfo.realuateInfoFlag && status == -1){
                        // 不弹提示
                    }else{
                        [[SobotToast shareToast] showToast:SobotKitLocalString(@"感谢您的支持") duration:1.5f position:SobotToastPositionCenter];
                    }
                }
                [self->_listTable  reloadData];
                
            } fail:^(ZCNetWorkCode errorCode) {
                
            }];
        }
        
        // 当前消息开了踩标签收集  这里区分大模型机器人
        if (model.realuateConfigInfo.realuateInfoFlag && status == -1 && ![ZCUICore getUICore].getLibConfig.aiAgent) {
            // 先创建消息体 需要msgid
            SobotChatMessage *robotModel = [[ZCUICore getUICore] addMessageToList:SobotMessageActionTypeRobotTip content:sobotConvertToString(model.realuateConfigInfo.realuateSubmitWord) type:SobotMessageTypeRobotRealuate dict:nil];
            robotModel.realuateConfigInfo = model.realuateConfigInfo;
            robotModel.robotTipMsg = sobotConvertToString(model.realuateConfigInfo.realuateAfterWord);
            robotModel.submitStatus = @"1";
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            [param setObject:sobotConvertToString([ZCUICore getUICore].getLibConfig.uid) forKey:@"uid"];
            [param setObject:sobotConvertToString([ZCUICore getUICore].getLibConfig.cid) forKey:@"cid"];
            [param setObject:@"insert" forKey:@"type"];
            [param setObject:sobotConvertToString(model.realuateConfigInfo.realuateAfterWord) forKey:@"msg"];
            [param setObject:sobotConvertToString(robotModel.msgId) forKey:@"msgId"];
            [param setObject:@"1" forKey:@"submitStatus"];
            [param setObject:sobotConvertToString(model.realuateConfigInfoJsonStr) forKey:@"chatRealuateConfigInfo"];
            [param setObject:@"" forKey:@"realuateTagId"];
            [param setObject:@"" forKey:@"realuateTagName"];
            [param setObject:@"" forKey:@"realuateDetail"];
            [param setObject:sobotConvertToString(model.realuateConfigInfo.realuateSubmitWord) forKey:@"realuateSubmitWord"];
            [param setObject:sobotConvertToString(model.robotAnswer.msgId) forKey:@"docMsgId"];
            SLog(@"----入参 %@", param);
            [ZCLibServer postRobotOperation:param start:^(NSString * _Nonnull url) {
                
            } success:^(NSDictionary * _Nonnull dict, ZCNetWorkCode sendCode) {
                if (!sobotIsNull(dict) && [dict isKindOfClass:[NSDictionary class]]) {
                    // 展示本地消息 25的
                    [[ZCUICore getUICore] addRobotRealuateMsg:model newMsg:robotModel];
                }
            } failed:^(NSString * _Nonnull errorMessage, ZCNetWorkCode errorCode) {
                
            }];
        }
        
        
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
    }else if (type == ZCChatCellClickTypeReSend){
        // 重新发送
        // 当前的键盘样式是新会话的样式，重新发送的消息不在发送  （用户超时下线提示和会话结束提示）
        if (_keyboardTools.curKeyboardStatus  == ZCKeyboardStatusNewSession) {
            [_listTable reloadData];
            [self tableScrollToBottom];
            return;
        }
//        if ([ZCUICore getUICore].aiAgentAsking && ![[ZCUICore getUICore] getLibConfig].isArtificial) {
//            return;
//        }
        NSDictionary *dict = nil;
        NSString *text = model.richModel.content;
//        if(model.richModel.msgType == ZCMessageTypeLocation){
//            dict = @{@"lng":model.richModel.longitude,@"lat":model.richModel.latitude,@"localName":model.richModel.localName,@"localLabel":model.richModel.localLabel,@"file":model.richModel.richmoreurl};
//            //            model.richModel.msg = model.richModel.richmoreurl;
//            text = model.richModel.richmoreurl;
//        }
        if(model.msgType == SobotMessageTypeVideo){
            dict = @{@"cover":model.richModel.content};
            text = model.richModel.richmoreurl;
        }
        if (model.msgType == SobotMessageTypeFile) {
            text = model.richModel.richmoreurl;
        }
        
        ZCLibSendMessageParams *sendParms = [[ZCLibSendMessageParams alloc]init];
        sendParms.content = model.content;
        sendParms.msgContent = model.msgContent;
        sendParms.question = model.question;
        sendParms.requestText = model.requestText;
        sendParms.questionFlag = model.questionFlag;
        sendParms.docId = model.docId;
        sendParms.duration = model.duration;
        sendParms.robotflag = model.robotflag;
        sendParms.fromEnum = model.fromEnum;
        sendParms.exParams = model.exParams;
        sendParms.sendType = model.sendType;
        // 重新发送 当前是人工 要发给人工 去掉fromEnum
        if ([self getZCIMConfig].isArtificial) {
            sendParms.fromEnum = 0;
        }
        [ZCLibServer sendMessage:sendParms msgType:model.msgType config:[self getZCIMConfig] start:^(SobotChatMessage * _Nonnull message) {
            model.sendStatus = 1;
            
            
            [self->_listTable reloadData];
        } success:^(SobotChatMessage * _Nonnull message, ZCNetWorkCode code) {
            model.sendStatus = message.sendStatus;
            model.includeSensitive = 0;
            
//            if(model.msgType == SobotMessageTypeFile){
//                model.richModel.fileType = message.richModel.fileType;
//                model.richModel.fileName = message.richModel.fileName;
//                model.richModel.fileSize = message.richModel.fileSize;
//                model.richModel.url = message.richModel.richmoreurl;
//                
//            }
            
            if(![self getZCIMConfig].isArtificial && code == ZC_NETWORK_New_Data){
                
                [[ZCUICore getUICore] parseRobotMessage:message];
                // 3.1.0新增，发送完语音消息，消息被遮挡
                [self tableScrollToBottom];
            }else if(code == ZC_NETWORK_SUCCESS){
                model.sendStatus = 0;
                model.richModel.msgtranslation = message.richModel.msgtranslation;
                if(model.msgType == SobotMessageTypeText){
                    model.richModel.content = message.richModel.content;
                    model.displayMsgAttr = message.displayMsgAttr;
                }
                
                if(model.msgType == SobotMessageTypeFile){
                    model.richModel.fileType = message.richModel.fileType;
                    model.richModel.fileName = message.richModel.fileName;
                    model.richModel.fileSize = message.richModel.fileSize;
                    model.richModel.url = message.richModel.richmoreurl;
                }
                
                [self->_listTable reloadData];
            }else{
                model.sendStatus = 2;
                [self->_listTable reloadData];
            }
            
        } progress:^(SobotChatMessage * _Nonnull message) {
            model.progress = message.progress;
            [self->_listTable reloadData];
        } fail:^(SobotChatMessage * _Nonnull message, NSString * _Nonnull errorMsg, ZCNetWorkCode code) {
            model.sendStatus = 2;
            model.includeSensitive = 0;
            [self->_listTable reloadData];
        }];
    }
}
-(void)cellItemClick:(int)satifactionType isResolved:(int)isResolved rating:(int)rating problem:(NSString *)problem scoreFlag:(int)scoreFlag scoreExplain:(NSString * _Nullable)scoreExplain checkScore:(ZCLibSatisfaction *) model{
    if (satifactionType == 1) {
        
            BOOL isEvalutionAdmin = [ZCUICore getUICore].getLibConfig.isArtificial;
//            if(_keyboardTools.curKeyboardStatus == ZCKeyboardStatusNewSession){
//                isEvalutionAdmin = [ZCUICore getUICore].isAdminServerBeforeCloseSession;
//            }
        [self.keyboardTools hideKeyboard];
        
        isEvalutionAdmin = YES;
            [[ZCUICore getUICore] checkSatisfacetion:isEvalutionAdmin type:SobotSatisfactionFromSrouceInvite rating:rating resolve:isResolved];

    }else{
        // 提交评价,10分实际是11
        if(scoreFlag == 1){
            rating = rating - 1;
            if(rating < 0){
                rating = 0;
            }
        }
        [[ZCUICore getUICore] commitSatisfactionWithIsResolved:isResolved Rating:rating problem:problem scoreFlag:scoreFlag scoreExplain:scoreExplain checkScore:model];
    }
}
#pragma mark 点踩标签提交
-(void)cellCommitRealuateTagInfo:(NSString *)tagId tipStr:(NSString *)tipStr text:(NSString *)text msg:(SobotChatMessage *)msg answer:(NSString *)answer realuateTagLan:(NSString*)realuateTagLan realuateSubmitWordLan:(NSString *)realuateSubmitWordLan{
    // 点击提交了，先把键盘回收了
    [self hiddenKeyboard];
    // 这里提交需要区分大模型机器人
    if ([ZCUICore getUICore].getLibConfig.aiAgent) {
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        [param setObject:sobotConvertToString([ZCUICore getUICore].getLibConfig.uid) forKey:@"uid"];
        [param setObject:sobotConvertToString([ZCUICore getUICore].getLibConfig.cid) forKey:@"cid"];
        [param setObject:sobotConvertToString(msg.msgId) forKey:@"msgId"];
        [param setObject:sobotConvertToString(msg.aiAgentCid) forKey:@"aiAgentCid"];
        [param setObject:[NSString stringWithFormat:@"%d",[ZCUICore getUICore].getLibConfig.robotFlag] forKey:@"robotFlag"];
        [param setObject:sobotConvertToString([ZCUICore getUICore].getLibConfig.companyID) forKey:@"companyId"];
        [param setObject:@"APP" forKey:@"sourceEnum"];
        [param setObject:@"0" forKey:@"status"];
        [param setObject:[NSString stringWithFormat:@"%d",[ZCUICore getUICore].getLibConfig.realuateFlag] forKey:@"realuateFlag"];
        [param setObject:[NSString stringWithFormat:@"%d",[ZCUICore getUICore].getLibConfig.realuateButtonStyle] forKey:@"realuateButtonStyle"];
        [param setObject:[NSString stringWithFormat:@"%d",[ZCUICore getUICore].getLibConfig.realuateStyle] forKey:@"realuateStyle"];
        [param setObject:sobotConvertToString(tagId) forKey:@"tagId"];
        [param setObject:sobotConvertToString(tipStr) forKey:@"tagName"];
        [param setObject:sobotConvertToString([ZCUICore getUICore].getLibConfig.RealuateConfigInfo.realuateEvaluateWord) forKey:@"realuateEvaluateWord"];
        [param setObject:sobotConvertToString([ZCUICore getUICore].getLibConfig.RealuateConfigInfo.realuateSubmitWord) forKey:@"realuateSubmitWord"];
        [param setObject:sobotConvertToString(answer) forKey:@"answer"];
        [param setObject:sobotConvertToString(text) forKey:@"realuateDetail"];
//        [param setObject:sobotConvertToString(realuateTagLan) forKey:@"realuateTagLan"];
//        [param setObject:sobotConvertToString(realuateSubmitWordLan) forKey:@"realuateSubmitWordLan"];
        [ZCLibServer postAiAgentRobotAnswerComment:param start:^(NSString * _Nonnull url) {
            
        } success:^(NSDictionary * _Nonnull dict, ZCNetWorkCode sendCode) {
            if (!sobotIsNull(dict) && [dict isKindOfClass:[NSDictionary class]]) {
                // 刷新页面
                [[ZCUICore getUICore] updateRealuateMsgStatus:msg tagId:tagId tipStr:realuateTagLan text:text];
            }
        } failed:^(NSString * _Nonnull errorMessage, ZCNetWorkCode errorCode) {
            if (sobotConvertToString(errorMessage).length >0) {
                [[SobotToast shareToast] showToast:sobotConvertToString(errorMessage) duration:2 position:SobotToastPositionCenter];
            }
        }];
        
    }else{
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        [param setObject:sobotConvertToString([ZCUICore getUICore].getLibConfig.uid) forKey:@"uid"];
        [param setObject:sobotConvertToString([ZCUICore getUICore].getLibConfig.cid) forKey:@"cid"];
        [param setObject:@"submit" forKey:@"type"];
        [param setObject:sobotConvertToString(msg.realuateConfigInfo.realuateAfterWord) forKey:@"msg"];
        [param setObject:sobotConvertToString(msg.msgId) forKey:@"msgId"];
        [param setObject:@"2" forKey:@"submitStatus"];
        [param setObject:sobotConvertToString(tagId) forKey:@"realuateTagId"];
        [param setObject:sobotConvertToString(tipStr) forKey:@"realuateTagName"];
        [param setObject:sobotConvertToString(text) forKey:@"realuateDetail"];
        [param setObject:sobotConvertToString(msg.realuateConfigInfo.realuateSubmitWord) forKey:@"realuateSubmitWord"];
        [ZCLibServer postRobotOperation:param start:^(NSString * _Nonnull url) {
            
        } success:^(NSDictionary * _Nonnull dict, ZCNetWorkCode sendCode) {
            if (!sobotIsNull(dict) && [dict isKindOfClass:[NSDictionary class]]) {
                // 刷新页面
                [[ZCUICore getUICore] updateRealuateMsgStatus:msg tagId:tagId tipStr:tipStr text:text];
            }
        } failed:^(NSString * _Nonnull errorMessage, ZCNetWorkCode errorCode) {
            if (sobotConvertToString(errorMessage).length >0) {
                [[SobotToast shareToast] showToast:sobotConvertToString(errorMessage) duration:2 position:SobotToastPositionCenter];
            }
        }];
    }
}

-(void)updateListViewHeight:(CGFloat)height{
   CGPoint p = self.listTable.contentOffset;
    SLog(@"ssssss %@",NSStringFromCGPoint(p));
    [self.listTable setContentOffset:CGPointMake(0, p.y + height)];
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
    // 421 产品 钱龙同步 开启 commentFlag =1 机器人模式也起效 （去掉仅人工的 && [self getZCIMConfig].isArtificial）
    if(isClose && [self getZCIMConfig].commentFlag==1 ){
        showEvaluation = YES;// 点了结束会话 并且是人工，并且开启了会话结束是否推送评价开关
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
    [self hiddenKeyboard];
    // 是否评价
    BOOL isShow = [[ZCUICore getUICore] checkSatisfacetion:isEvalutionAdmin type:isClose?SobotSatisfactionFromSrouceClose:SobotSatisfactionFromSrouceBack];
    if(!isShow){
        if(self.delegate && [self.delegate respondsToSelector:@selector(onBackFinish:closeClick:)]){
            [self.delegate onBackFinish:YES closeClick:isClose];
        }
    }
}

-(void)hiddenKeyboard{
   [_keyboardTools hideKeyboard];
    _tableLayoutTop.constant = notifyHeight;
}


-(void)backChatView{
    // 退出页面先回执默认值
//    [ZCUICore getUICore].aiAgentAsking = NO;
//    [ZCLibClient getZCLibClient].isShowTurnBtn = NO;
//    [ZCUICore getUICore].unknownWordsCount = 0;
    if ([ZCUICore getUICore].lineModel) {
        if([ZCUICore getUICore].chatMessages &&[ZCUICore getUICore].chatMessages.count > 0){
            [[ZCUICore getUICore].chatMessages removeObject:[ZCUICore getUICore].lineModel];
        }
    }
    // 判断是否保存会话id，以判断是否重新初始化
    // 没有说过话，下次进入时判断是否需要重新初始化，如果当前时间-time,大于out_time就重新初始化
    if(![ZCUICore getUICore].isSendToUser && ![ZCUICore getUICore].isSendToRobot){
        NSDictionary *lastChat = @{@"cid":sobotConvertToString([self getZCIMConfig].cid),
                                   @"time":sobotDateTransformString(SOBOT_FORMATE_DATETIMESSS,[NSDate new]),
                                   @"out_time":[NSString stringWithFormat:@"%d",[self getZCIMConfig].userOutTime]
        };
        [SobotCache addObject:lastChat forKey:@"KEYP_ZCLastChat"];
    }


    if ([ZCUICore getUICore].recordModel) {
        if([ZCUICore getUICore].chatMessages &&[ZCUICore getUICore].chatMessages.count > 0){
            [[ZCUICore getUICore].chatMessages removeObject:[ZCUICore getUICore].recordModel];
        }
    }

    @try{
        if([ZCUICore getUICore].chatMessages && [ZCUICore getUICore].chatMessages.count>0){
            SobotChatMessage *lastMsg = [[ZCUICore getUICore].chatMessages lastObject];
            if(lastMsg.action != SobotMessageActionTypeText){
                [[ZCPlatformTools sharedInstance] getPlatformInfo].lastMsg = lastMsg.tipsMessage;
                [[ZCPlatformTools sharedInstance] getPlatformInfo].lastDate = lastMsg.ts;
            } else {
                [[ZCPlatformTools sharedInstance] getPlatformInfo].lastMsg = [ZCPlatformTools getLastMessage:lastMsg urlRegular:[ZCUIKitTools zcgetUrlRegular]];
                [[ZCPlatformTools sharedInstance] getPlatformInfo].lastDate = lastMsg.ts;
            }
        }
        [[ZCUICore getUICore] destoryViewsData];
        // 如果设置NO，每次返回都会从新添加
//        [ZCUICore getUICore].isAddNotice = NO;

        NSInteger keyboardtype = [_keyboardTools curKeyboardStatus];
        
        // 这里需要处理一个特殊情况 展示可以发送的商品信息卡片消息要处理掉
        int index = -1;
        if( [ZCUICore getUICore].chatMessages &&  [ZCUICore getUICore].chatMessages.count> 0){
            for (int i = 0; i<[ZCUICore getUICore].chatMessages.count; i++) {
                SobotChatMessage *msg = [ZCUICore getUICore].chatMessages[i];
                if(msg.action == SobotMessageActionTypeSendGoods && msg.msgType == SobotMessageTypeTipsText){
                    index = i;
                }
            }
            if (index >-1) {
                if ([ZCUICore getUICore].chatMessages.count >index) {
                    [[ZCUICore getUICore].chatMessages removeObjectAtIndex:index];
                }
            }
        }
        
        // 如果通道没有建立成功，当前正在链接中  则清空数据，下次重新初始化  2. 当前会话键盘是新会话键盘，返回时清空数据 重新初始化
        if((![ZCIMChat getZCIMChat].isConnected && [self getZCIMConfig].isArtificial) || keyboardtype == ZCKeyboardStatusNewSession){
            [self getPlatformInfo].cidsArray = nil;
            [self getPlatformInfo].messageArr = nil;
        }else{
            [self getPlatformInfo].cidsArray = [[ZCUICore getUICore].cids mutableCopy];
            [self getPlatformInfo].messageArr = [[ZCUICore getUICore].chatMessages mutableCopy];
        }

            ZCPlatformInfo *info = [self getPlatformInfo];
            SLog(@"未读消息数据== %d", info.unRead);
        [[ZCPlatformTools sharedInstance] savePlatformInfo:[self getPlatformInfo]];

        [ZCUICore getUICore].cids = nil;
        [ZCUICore getUICore].chatMessages = nil;

        if([ZCUICore getUICore].ZCViewControllerCloseBlock){
            [ZCUICore getUICore].ZCViewControllerCloseBlock(self,ZC_CloseChat);
        }
        
        if([ZCUICore getUICore].PageLoadBlock){
            [ZCUICore getUICore].isCanShowAutoView = NO;
            [ZCUICore getUICore].PageLoadBlock(self,ZCPageStateTypeChatBack);
            if (sobotGetSystemDoubleVersion()>=15.0) {
                // 退出SDK页面的时候 恢复默认
                [[UITableView appearance] setPrefetchingEnabled:YES];
            }
        }
        
        [[ZCIMChat getZCIMChat] setChatPageState:NO];

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
        if ([[SobotVoiceTools shareSobotVoiceTools] getIsPlay]) {
            [[SobotVoiceTools shareSobotVoiceTools] pausePlayVoide];
        }
        [SobotVoiceTools shareSobotVoiceTools].fileUrl = @"";
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

-(void)dealloc{
    [[ZCIMChat getZCIMChat] setChatPageState:NO];
}

#pragma mark - 转换图片颜色
-(UIImage*)imageChangeColor:(UIColor*)color chageImg:(UIImage*)chageImg;
{
    if(chageImg.size.width == 0 || chageImg.size.height == 0){
        return chageImg;
    }
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
