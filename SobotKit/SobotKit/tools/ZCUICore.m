//
//  ZCUICore.m
//  SobotKit
//
//  Created by zhangxy on 2022/8/30.
//

#import "ZCUICore.h"
#import <SobotChatClient/SobotChatClient.h>
#import "ZCUIKitTools.h"
#import "ZCUIWebController.h"
#import "ZCVideoPlayer.h"
#import "ZCUIChatKeyboard.h"
#import "ZCUISkillSetView.h"
//#import "ZCUIEvaluateView.h"
#import "ZCLeaveMsgController.h"
#import "ZCLeaveMsgVC.h"
#import "ZCSelLeaveView.h"
#import "ZCChatShowDetailView.h"

@interface ZCUICore(){
    BOOL _isInitLoading;
        
    // 正在提交评价
    BOOL _isCommentEvaluate;
    
    // 是否执行过一次转人工
    BOOL isDoConnectedUser;
    // 正在执行转人工
    BOOL _isTurnLoading;
    
    
    BOOL isShowAdminHello;
    
    SobotChatMessage *_keyworkRobotReplyModel;
    
    // 计时器
    int lowMinTime;
    
    UITextView *inputTextView;
    // 间隔指定时间，发送正在输入内容，并且是人工客服时
    int inputCount;
    BOOL isInputSending;
    NSString *lastMessage;
    BOOL isShowNotice;
    
    NSString *tempUid;// 此UID 用于 和人工会话设置了评价人工之后结束会话的场景下，config置为nil的情况下，临时存储使用
}

@property(nonatomic,strong) NSString * receivedName;
@property(nonatomic,strong) NSString * curCid;
@property(nonatomic,strong) ZCUISkillSetView *skillSetView;
@property(nonatomic,strong) NSTimer *tipTimer;
@property(nonatomic,assign) BOOL isHadCidLoaded;
@property(nonatomic,strong) ZCChatShowDetailView *showDetailView;

@end

@implementation ZCUICore

static ZCUICore *_instance = nil;
static dispatch_once_t onceToken;
+(ZCUICore *)getUICore{
    dispatch_once(&onceToken, ^{
        if(_instance == nil){
            _instance = [[ZCUICore alloc] initPrivate];
        }
    });
    return _instance;
}

-(id)initPrivate{
    self=[super init];
    if(self){
        _chatMessages = [[NSMutableArray alloc] init];
        _cids = [[NSMutableArray alloc] init];
        [ZCNotificatCenter addObserver:self selector:@selector(onReceiveNewMessage:) name:SobotReceiveNewMessage object:nil];
        [ZCNotificatCenter addObserver:self selector:@selector(onConnectStatusChanged:) name:SobotTcpConnectedChanged object:nil];
        
        _unReadMessageCache = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(id)init{
    return [[self class] getUICore];
}


-(void)setKitInfo:(ZCKitInfo *)kitInfo{
    _kitInfo = kitInfo;
    
    if(kitInfo.isCloseSystemRTL){
        // 关闭
        [SobotCache addObject:@(YES) forKey:@"SobotisCloseSystemRTL"];
    }else{
        [SobotCache addObject:@(NO) forKey:@"SobotisCloseSystemRTL"];
    }
}

-(void)detailViewClikBlock:(void(^)(SobotChatMessage *model,int type,id obj))detailViewBlock{
    self.detailViewBlock = detailViewBlock;
}

-(void)doInitSDK:(id<ZCUICoreDelegate>)delegate block:(void (^)(ZCInitStatus, NSString * _Nullable, ZCLibConfig * _Nullable))resultBlock{
    _delegate = delegate;
#pragma mark - 是否要重新初始化
    if([ZCPlatformTools checkInitParameterChanged]){
        
        // 还原评价配置缓存
        _satisfactionConfig = nil;
        
        _isShowRobotHello = NO;
        isShowAdminHello = NO;
        _isSendToRobot = NO;
        _isSendToUser = NO;
        _isAdminServerBeforeCloseSession = NO;
        _isEvaluationService = NO; // 是否评价过人工
        _isEvaluationRobot = NO; // 是否评价过机器人
        _checkGroupId = @"";
        _checkGroupName = @"";
        _afterModel = nil;
        
        _isHadCidLoaded = NO;
        if(resultBlock){
            resultBlock(ZCInitStatusLoading,@"",nil);
        }
        if(_isInitLoading){
            return;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(showSoketConentStatus:)]) {
            [self.delegate showSoketConentStatus:ZCConnectStatusCode_START];
        }
        _isInitLoading = YES;
        [ZCLibClient getZCLibClient].libInitInfo.isFirstEntry = 1;
        [ZCLibServer initSobotChat:^(ZCLibConfig * _Nonnull config) {
            if(resultBlock){
                resultBlock(ZCInitStatusLoadSuc,@"",config);
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(showSoketConentStatus:)]) {
                [self.delegate showSoketConentStatus:ZCConnectStatusCode_SUCCESS];
            }
            self->_chatMessages = [[NSMutableArray alloc] init];
            self->_cids = [[NSMutableArray alloc] init];
            self->_isInitLoading = NO;
            [self configInitResult:YES];
            self->_isOfflineBeBlack = NO;
            if(config.isblack){
                self->_isOfflineBeBlack = YES;
            }
            self->_curCid = config.cid;
            [self getChatMessages];
            [self getRemoteCids];
        } error:^(ZCNetWorkCode status, NSString * _Nonnull errorMessage) {
            self->_isInitLoading = NO;
            if(resultBlock){
                resultBlock(ZCInitStatusFail,errorMessage,nil);
            }
        } appIdIncorrect:^(NSString * _Nonnull appId) {
            self->_isInitLoading = NO;
            if(resultBlock){
                resultBlock(ZCInitStatusFail,appId,nil);
            }
        }];
    }else{
        if(resultBlock){
            resultBlock(ZCInitStatusLoadSuc,nil,[self getLibConfig]);
        }
//        _curCid = [self getLibConfig].cid;
        _cids = [self getPlatfromInfo].cidsArray;
        _chatMessages = [self getPlatfromInfo].messageArr;
        // * 注意 *  会话保持的状态下 _curCid有值，不要直接去获取 cids数组中最后一条 、cid,因为历史记录的获取逻辑哪里 在返回页面前已经将 lastcid 赋值给_curCid ，这里如果直接获取，会少一次会话记录。
        if(_cids.count !=0 && (_curCid ==nil || sobotConvertToString(_curCid).length == 0)){
            _curCid = [_cids lastObject]; // 这里需要处理会话保持的状态下，加载消息的数据重复的问题
        }
        _isHadCidLoaded = YES;
        
        [self configInitResult:NO];
        
        // 加载历史消息完成
        if(_chatMessages != nil && _chatMessages.count> 0){
            
        }else{
            // 加载历史消息完成
            if(self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
                [self.delegate onPageStatusChanged:ZCShowStatusCompleteNoMore message:@"" obj:nil];
            }
        }
        if([self getLibConfig].isArtificial){
            [self sendMessageWithConnectStatus:ZCServerConnectArtificial];
            // 会话保持进入页面刷新快捷菜单
            
        }else{
            [self sendMessageWithConnectStatus:ZCServerConnectRobot];
        }
    }
}

-(void)configInitResult:(BOOL) isRemote{
    if(isRemote){
        // 重新初始化重新设置转人工未知次数和转人工按钮是否显示的值
        [ZCLibClient getZCLibClient].isShowTurnBtn = NO;
        [ZCUICore getUICore].unknownWordsCount = 0;
        
        _recordModel = nil;
        isShowNotice = NO;
        _isShowRobotGuide = NO;
        _isSendToUser = NO;
        _isSendToUser = NO;
        _isShowForm = NO;
        _isEvaluationRobot = NO;
        _isAfterConnectUser = NO;
        _isAdminServerBeforeCloseSession = NO;
    }else{
        /**
         *  todo 判断未读消息数
         */
        // 此处需要在 ZCUIKitManager类中处理标记，解决ZCUIConfigManager中为空的问题  先清理掉原来的商品信息，在添加未读消息数
        int unReadNum = [[ZCIMChat getZCIMChat] getUnReadNum];
        if (unReadNum >=1 && _chatMessages.count >= unReadNum) {
            _lineModel = [ZCPlatformTools createLocalMessage:NO messageType:SobotMessageTypeTipsText richType:0 action:SobotMessageActionTypeNewMessage message:@{@"content":@""} robot:NO config:[self getLibConfig]];
            
            [_chatMessages insertObject:_lineModel atIndex:_chatMessages.count - unReadNum];
        }
        
        if(unReadNum >= 10){
            if(self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
                [self.delegate onPageStatusChanged:ZCShowStatusUnRead message:[NSString stringWithFormat:@" %d%@",unReadNum,SobotKitLocalString(@"条新消息")] obj:nil];
            }
        }
        if(self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
            [self.delegate onPageStatusChanged:ZCShowStatusRefreshFastMenuView message:nil obj:nil];
        }
    }
    
    ZCLibConfig * config = [self getPlatfromInfo].config;
    // 设置客服发送离线消息转人工参数
    if(config.offlineMsgConnectFlag && sobotConvertToString(config.offlineMsgAdminId).length > 0 && !config.isblack){
        [ZCPlatformTools sharedInstance].isOfflineMsgConnect = config.offlineMsgConnectFlag;
        [ZCPlatformTools sharedInstance].offlineMsgAdminId   = sobotConvertToString(config.offlineMsgAdminId);
    }
    
    if ([self getPlatfromInfo].config.isArtificial) {
        // 设置昵称
        if (self.delegate && [self.delegate respondsToSelector:@selector(setTitleName:)]) {
            [self.delegate setTitleName:_receivedName];
        }
    }else{
        if(config.type ==1 || config.type == 3 || (config.type == 4 && ![self getPlatfromInfo].config.isArtificial)){
            _receivedName = config.robotName;
            
        }
        // 设置昵称
        if (self.delegate && [self.delegate respondsToSelector:@selector(setTitleName:)]) {
            [self.delegate setTitleName:_receivedName];
        }
    }
#pragma mark 3.0.4开始超时提醒由服务端下发 215的消息体
    // 启动计时器
    [self startTipTimer];
    
    // 设置输入框，在_keyboardTools setInitConfig中会处理仅人工转人工情况
    
    if(config.type==4 || config.type==2 || config.ustatus == 1 || ([ZCLibClient getZCLibClient].libInitInfo.service_mode!=1 && config.ustatus == -2)){
        // * ustatus -2.排队中 -1.机器人 0.离线  1.在线
        if(config.isblack){
            // 手动添加，无需修改业务逻辑。
            [self addMessageToList:SobotMessageActionTypeIsBlock content:@"" type:SobotMessageTypeTipsText dict:nil];
            // 设置昵称
            if (_delegate && [self.delegate respondsToSelector:@selector(setTitleName:)]) {
                [self.delegate setTitleName:SobotKitLocalString(@"暂无客服在线")];
            }
        }else{
            // 人工优先，直接执行转人工,  ##2 仅人工   ,ustatus，说明断线后用户还在线  //仅机器人模式排队不在去执行转人工操作
            // 如果显示在线或者排队中，自动转接到人工
            if (isRemote) {
                if(config.ustatus == 1|| config.ustatus == -2){
                    [ZCUICore getUICore].isShowForm = YES;
                    [[ZCUICore getUICore] checkUserServiceWithType:ZCTurnType_InitBeConnected model:nil];
                }else{
                    [[ZCUICore getUICore] checkUserServiceWithType:ZCTurnType_InitOnUserType model:nil];
                }
            }
        }
    }else if(config.type == 1){
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]) {
            [self.delegate onPageStatusChanged:ZCSetKeyBoardStatus message:@"" obj:@(ZCKeyboardStatusRobot)];
        }
    }else if(config.type == 3){
        //3.智能客服-机器人优先
        if (config.type == 3) {
            // 3.智能客服-机器人优先    // && self.isShowConnectedButton == 0  isShowTurnBtn记录在会话保持的状态下是否之前显示转人工按钮（一次有效会话之内）
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]) {
                [self.delegate onPageStatusChanged:ZCSetKeyBoardStatus message:@"" obj:@(ZCKeyboardStatusRobot)];
            }
            // 2.9.2版本开始，如果客服发送过离线消息，直接转接到对应的客服
            // 不是仅机器人，不是黑名单用户
            if([ZCPlatformTools sharedInstance].isOfflineMsgConnect && sobotConvertToString([ZCPlatformTools sharedInstance].offlineMsgAdminId).length > 0 && !config.isblack){
                if (isRemote) {
                    [[ZCUICore getUICore] doConnectUserService:nil connectType:ZCTurnType_OffMessageAdmin];
                }
            }
        }
    }
    
    if(_chatMessages.count > 0){
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]) {
            [self.delegate onPageStatusChanged:ZCShowStatusMessageChanged message:@"" obj:config];
        }
    }
}

-(void)getRemoteCids{
    if(_isHadCidLoaded){
        return;
    }
    if([self getLibConfig]==nil || sobotConvertToString([self getLibConfig].uid).length == 0){
        return;
    }
    if(sobotIsNull(_cids)){
        _cids  = [[NSMutableArray alloc] init];
    }else{
        [_cids removeAllObjects];
    }
    __weak ZCUICore *  weakSelf = self;
    [ZCLibServer getChatUserCids:[ZCLibClient getZCLibClient].libInitInfo.scope_time uid:[self getLibConfig].uid start:^(NSString * _Nonnull url, NSDictionary * _Nonnull paramters) {
        weakSelf.isHadCidLoaded = NO;
    } success:^(NSDictionary * _Nonnull dict, ZCNetWorkCode code) {
        weakSelf.isHadCidLoaded = YES;
        NSArray *arr = dict[@"data"][@"cids"];
        if(!sobotIsNull(arr)  && arr.count > 0){
            //            [_cids removeAllObjects];
            for (NSString *itemCid in arr) {
                if((!sobotIsNull(weakSelf.curCid) && [itemCid isEqual:weakSelf.curCid]) || ([itemCid isEqualToString:[weakSelf getPlatfromInfo].config.cid])){
                    continue;
                }
                [weakSelf.cids addObject:itemCid];
            }
            SLog(@"3333333333333  %@  %ld", weakSelf.cids,weakSelf.cids.count);
            if(sobotIsNull(weakSelf.curCid)){
                weakSelf.curCid = [weakSelf.cids lastObject];
                [weakSelf getChatMessages];
            }
        }else if (!sobotIsNull(arr) && arr.count == 0){
            if(!self->_isShowRobotHello){
                // 判断是否显示机器人欢迎语
                // 不是人工、不是人工优先，不是仅人工、不是在线状态、不是排队状态、没显示过欢迎语  (ustatus = -1 时不要显示欢迎语) && [weakSelf getLibConfig].ustatus != -1
                if(![weakSelf getLibConfig].isArtificial
                   && [weakSelf getLibConfig].type!=4
                   && [weakSelf getLibConfig].type !=2
                   && [weakSelf getLibConfig].ustatus!=1
                   && [weakSelf getLibConfig].ustatus!=-2
                   ){

                    // 添加机器人欢迎语
                    [weakSelf sendMessageWithConnectStatus:ZCServerConnectRobot];
                }
            }
            
            //  cid 接口加载完成之后，cid 数据为空 新用户首次加载是发生 刷新页面 取消加载动画
            // 加载历史消息完成
            if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
                [weakSelf.delegate onPageStatusChanged:ZCShowStatusCompleteNoMore message:@"" obj:nil];
            }
        }
    } failed:^(NSString * _Nonnull errormsg, ZCNetWorkCode code) {
        weakSelf.isHadCidLoaded = YES;
    }];
}


-(void)getChatMessages{
    if(sobotIsNull(_curCid) && !_isHadCidLoaded){
        [self getRemoteCids];
        return;
    }
    if([self getLibConfig]==nil || sobotConvertToString([self getLibConfig].uid).length == 0){
        return;
    }
    if(sobotIsNull(_curCid) && _isHadCidLoaded){// 当前cid空  加载过cid数据
        if(_cids!=nil && _cids.count>0){
            _curCid = [_cids lastObject];
        }else{
            
            // 加载历史消息完成
            if(self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
                [self.delegate onPageStatusChanged:ZCShowStatusCompleteNoMore message:@"" obj:nil];
            }
            return;
        }
    }
    
    
    __weak ZCUICore *  weakSelf = self;
    [ZCLibServer getHistoryMessages:_curCid withUid:[self getLibConfig].uid start:^(NSString * _Nonnull url, NSDictionary * _Nonnull parameters) {
        // 开始加载历史记录
        if(self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
            
            [self.delegate onPageStatusChanged:ZCShowStatusStartMessages message:@"" obj:nil];
        }
    } success:^(NSMutableArray * _Nonnull messages, ZCNetWorkCode code) {
        
        if(messages && messages.count>0){
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:
                                    NSMakeRange(0,[messages count])];
//            for(SobotChatMessage *msg in messages){
//                [ZCUIKitTools zcModelStringToAttributeString:msg];
//            }
            [weakSelf.chatMessages insertObjects:messages atIndexes:indexSet];
            
        }
        if (weakSelf.cids.count == 0) {
            weakSelf.curCid = nil;
        }
        
        if(weakSelf.isHadCidLoaded && weakSelf.cids!=nil && weakSelf.cids.count>0){
            NSString *lastCid = [weakSelf.cids lastObject];
            if([weakSelf.curCid isEqual:lastCid]){
                [weakSelf.cids removeLastObject];
            }
            weakSelf.curCid = [weakSelf.cids lastObject];
            [weakSelf.cids removeLastObject];
        }else{
            weakSelf.curCid = nil;
        }
        
        if(!self->_isShowRobotHello){
            // 判断是否显示机器人欢迎语
            // 不是人工、不是人工优先，不是仅人工、不是在线状态、不是排队状态、没显示过欢迎语  (ustatus = -1 时不要显示欢迎语) && [weakSelf getLibConfig].ustatus != -1
            if(![weakSelf getLibConfig].isArtificial
               && [weakSelf getLibConfig].type!=4
               && [weakSelf getLibConfig].type !=2
               && [weakSelf getLibConfig].ustatus!=1
               && [weakSelf getLibConfig].ustatus!=-2
               ){

                // 添加机器人欢迎语
                [weakSelf sendMessageWithConnectStatus:ZCServerConnectRobot];
            }
        }
        
        if(weakSelf.isHadCidLoaded && weakSelf.cids.count == 0 && weakSelf.curCid == nil) {
            if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
                //加载历史消息完成
                [weakSelf.delegate onPageStatusChanged:ZCShowStatusCompleteNoMore message:@"" obj:nil];
            }
        }else{
            if (messages && messages.count>0) {
                if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
                    //加载历史消息完成
                    [weakSelf.delegate onPageStatusChanged:ZCShowStatusMessageChanged message:@"" obj:nil];
                }
            }else{
                if (weakSelf.isHadCidLoaded && weakSelf.cids.count >0) {
                    [weakSelf getChatMessages];// 数据为空的场景下 需要再次主动拉取上一次的会话记录
                }else if(weakSelf.isHadCidLoaded && weakSelf.cids.count== 0  && messages== nil){
                    [weakSelf getChatMessages];//NSLog(@"处理首次加载为空的处理");
                }
            }
        }
    } failed:^(NSString * _Nonnull errormsg, ZCNetWorkCode code) {
        // 加载历史消息完成
        if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
            [weakSelf.delegate onPageStatusChanged:ZCShowStatusMessageChanged message:@"" obj:nil];
        }
    }];
}


// 键盘状态改变
-(void)keyboardOnClick:(ZCShowStatus ) status{
    if(status == ZCShowStatusReConnectClick){
        if(self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
            [self.delegate onPageStatusChanged:ZCShowStatusReConnectClick message:nil obj:nil];
        }
    }else{
        if(self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
            [self.delegate onPageStatusChanged:ZCShowTextHeightChanged message:nil obj:nil];
        }
    }
}

#pragma mark 监听消息
-(void)onReceiveNewMessage:(NSNotification *) info{
    NSDictionary *userInfo = info.userInfo;
    SobotChatMessage *message = userInfo[@"message"];
    NSDictionary *obj = userInfo[@"obj"];
    ZCReceivedMessageType type = [userInfo[@"receivetype"] integerValue];
    
    
    if(![[self getPlatfromInfo].app_key isEqual:sobotConvertToString(obj[@"appId"])]){
        return;
    }
    
    if (type == ZCReceivedMessageLockType_1) {
        [self pauseCount];
        return;
    }
    
    if (type == ZCReceivedMessageLockType_2) {
        [self pauseToStartCount];
        return;
    }
   
    if(type==ZCReceivedMessageUnKonw){
        return;
    }
    
    // 消息撤回
    // 处理消息撤回的问题 ，下面的代码判断了是否在聊天页面 无论是否在聊天页面都做处理
    if(type == ZCReceivedMessageRevertMsg){
        if([ZCIMChat getZCIMChat].isChatPageActive){
            if (_chatMessages !=nil && _chatMessages.count>0 ) {
                int index = -1;
                for (int i = (int)_chatMessages.count-1; i>=0 ; i--) {
                    SobotChatMessage *libMassage = _chatMessages[i];
                    if ([libMassage.msgId isEqual:message.revokeMsgId]) {
                        index = i;
                        break;
                    }
                }
                if(index >= 0){
                    [_chatMessages replaceObjectAtIndex:index withObject:message];
                }
            }
        }
        
    }
    
    
    
    // 设置消息为已读
    if(type == ZCReceivedMessageChatReadMsg){
        NSArray *arr = obj[@"msgIdList"];
        // 设置消息已读
        if(arr!=nil && [arr isKindOfClass:[NSArray class]]){
            for(NSString *msgId in arr){
                // 移除本地未读对象，理论上里面没有数据，因为存储的都是对方未读消息
                [_unReadMessageCache removeObjectForKey:sobotConvertToString(msgId)];
                
                // 设置发送的消息为已读
                for(SobotChatMessage *chatMsg in _chatMessages){
                    if([chatMsg.msgId isEqual:sobotConvertToString(msgId)]){
                        chatMsg.readStatus = 2;
                    }
                }
            }
            if(self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
                [self.delegate onPageStatusChanged:ZCShowStatusMessageChanged message:@"" obj:message];
            }
        }
    }
    
    _receivedName = message.senderName;
    
    if ([self getPlatfromInfo].config.type == 2 && ![self getPlatfromInfo].config.isArtificial) {
        // 设置昵称
        if(self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
            // 仅人工，结束会话，标题显示空白3.1.3修改
            [self.delegate onPageStatusChanged:ZCShowStatusChangedTitle message:nil obj:nil];
        }
    }
    
    if(type == ZCReceivedMessageTansfer){
        // 设置昵称
        NSString *nameStr;
        if ([obj isKindOfClass:[NSDictionary class]]) {
            if(![[obj objectForKey:@"name"] isEqual:[NSNull null]]){
                // logic
                nameStr = [obj objectForKey:@"name"];
            }
        }
        
        // 转接后，移除评价标签数据，因为评价标签会跟客户动态变化
        if(_satisfactionConfig){
            _satisfactionConfig = nil;
        }
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
            [self.delegate onPageStatusChanged:ZCShowStatusChangedTitle message:nameStr obj:nil];
        }
        return;
    }
    
    // 当前已经是人工，在接收到排队消息不做处理
    if([self getPlatfromInfo].config.isArtificial && type == ZCReceivedMessageWaiting){
        return;
    }
    if (type == ZCReceivedMessageWaiting && [self getLibConfig].queueFlag ==0) {
        return;// 没开启排队说辞，不显示。
    }
    
    if(type==ZCReceivedMessageOnline){
        [self removeListModelWithType:SobotMessageTypeTipsText tips:SobotMessageActionTypeChat_WaitingContinueTips];
        
        // 转人工成功
        if(self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
            [self.delegate onPageStatusChanged:ZCSetKeyBoardStatus message:@"" obj:@(ZCKeyboardStatusUser)];
        }
        // 仅人工模式
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]) {
            [self.delegate onPageStatusChanged:ZCShowStatusChangedTitle message:_receivedName obj:nil];
        }
    }
    
    if(message.msgType == SobotMessageTypeTipsText){
        // 移除相同的提示语
        [self removeListModelWithType:SobotMessageTypeTipsText tips:message.action];
    }
    
    if(type==ZCReceivedMessageOfflineBeBlack ||
       type==ZCReceivedMessageOfflineByAdmin ||
       type==ZCReceivedMessageOfflineByClose ||
       type== ZCReceivedMessageOfflineToLong ||
       type == ZCReceivedMessageToNewWindow||
       type == ZCReceivedMessageOfflineToWaiting ||
       type == ZCReceivedMessageOfflineUnknown){
        
        if (sobotConvertToString(obj[@"aname"]).length) {
            _receivedName = sobotConvertToString(obj[@"aname"]);
        }
        [self removeListModelWithType:SobotMessageTypeTipsText tips:SobotMessageActionTypeChat_WaitingContinueTips];
        
        // 设置重新接入时键盘样式
        if(self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
            [self.delegate onPageStatusChanged:ZCShowStatusReConnected message:@"" obj:nil];
        }
        
 
        
        if ( obj !=nil && ![obj[@"isServer"] boolValue]) {
            // 记录新会话之前是否是人工的状态  和人工超下线
            _isOffline = NO;
        }else{
            _isOffline = YES;
        }
        
        if (type == ZCReceivedMessageOfflineByAdmin || type == ZCReceivedMessageOfflineByClose) {
            _isOffline = YES;
            
            // 判定设置下线文案 客服离线 客服下线用户 这两中情况
            if ([self getPlatfromInfo].config.serviceEndPushFlag == 1 && ![[self getPlatfromInfo].config.serviceEndPushMsg isEqualToString:@""]) {
                
                NSString *customerStr = SobotKitLocalString(@"客服");
                NSString *allCustomerStr = [NSString stringWithFormat:@"#%@#",customerStr];
                
                NSString * pushMsg = [[self getPlatfromInfo].config.serviceEndPushMsg stringByReplacingOccurrencesOfString:allCustomerStr withString:_receivedName];
                message.tipsMessage = pushMsg;
            }
        }
        // 拉黑
        if (type == ZCReceivedMessageOfflineBeBlack) {
            [self getPlatfromInfo].config.isblack = YES;
            [[ZCPlatformTools sharedInstance] savePlatformInfo:[self getPlatfromInfo]];
        }
        
        for(SobotChatMessage *item in [self getPlatfromInfo].messageArr){
            if(item.msgType == SobotMessageTypeTipsText){
                item.tipsMessage=[item.tipsMessage stringByReplacingOccurrencesOfString:SobotKitLocalString(@"重新接入") withString:@""];
            }
        }
        // serviceEndPushFlag 只对 客服离线 和客服主动移除用户起效 拉黑和超时下线逻辑不变
        if ([self getPlatfromInfo].config.serviceEndPushFlag == 0 && type == ZCReceivedMessageOfflineByClose) {
            return;// 没开，不给提示
        }
        
    }
    
    
    if (type == ZCReceivedMessageNews && ![self getPlatfromInfo].config.isArtificial) {
        return;
    }
    if ([sobotConvertToString(message.richModel.content) isEqualToString:[self getPlatfromInfo].config.adminHelloWord]) {
        [self sendMessageWithConnectStatus:ZCServerConnectArtificial];
    }else{
        if(!sobotIsNull(message)){
            _isSendToUser = YES;
            [self addMessage:message reload:YES];
        }
    }
    
    // 处理仅人工超时
    if (type == ZCReceivedMessageOfflineToLong
        && [ZCUICore getUICore].getLibConfig.type == 2
        && [ZCUICore getUICore].getLibConfig.invalidSessionFlag == 1
        && ![ZCIMChat getZCIMChat].isChatPageActive) {
        if ([[ZCUICore getUICore] getPlatfromInfo].messageArr != nil) {
            [[[ZCUICore getUICore] getPlatfromInfo].messageArr removeAllObjects];
            [[ZCUICore getUICore] getPlatfromInfo].messageArr = nil;
        }
    }
}

-(void)removeListModelWithType:(SobotMessageType ) type tips:(SobotMessageActionType) action{
    if(type == SobotMessageTypeTipsText){
        for (SobotChatMessage *msg in _chatMessages) {
            if(msg.action == action){
                [_chatMessages removeObject:msg];
                break;
            }
        }
    }else{
        for (SobotChatMessage *msg in _chatMessages) {
            if(msg.msgType == type){
                [_chatMessages removeObject:msg];
                break;
            }
        }
    }
}

-(void)onConnectStatusChanged:(NSNotification *) info{
    NSDictionary *userInfo = info.userInfo;
    ZCConnectStatusCode code = [userInfo[@"code"] intValue];
//    NSDictionary *dict = userInfo[@"obj"];
//    ZCReceivedMessageType type = [userInfo[@"receivetype"] integerValue];
    if (self.delegate && [self.delegate respondsToSelector:@selector(showSoketConentStatus:)]) {
        [self.delegate showSoketConentStatus:code];
    }
}

-(ZCPlatformInfo *) getPlatfromInfo{
    return [[ZCPlatformTools sharedInstance] getPlatformInfo];
}

-(ZCLibConfig *)getLibConfig{
    return [self getPlatfromInfo].config;
}

-(BOOL)getRecordModel{
    if(sobotIsNull(_recordModel)){
        return NO;
    }
    return YES;
}

#pragma mark - 识别链接 和链接事件
- (void)dealWithLinkClickWithLick:(NSString *)link viewController:(UIViewController *)viewController{
    if(sobotConvertToString(link).length == 0){
        return;
    }
    
    if([[sobotConvertToString(link) lowercaseString] hasSuffix:@".mp4"]){
        UIWindow *window = [SobotUITools getCurWindow];
        ZCVideoPlayer *player = [[ZCVideoPlayer alloc] initWithFrame:window.bounds withShowInView:window url:[NSURL URLWithString:link] Image:nil];
        [player showControlsView];
        return;
    }
    if([[ZCUICore getUICore] LinkClickBlock] == nil || ![ZCUICore getUICore].LinkClickBlock(ZCLinkClickTypeURL,link,viewController)){
        if([link hasPrefix:@"tel:"] || sobotValidateMobileWithRegex(link, [ZCUIKitTools zcgetTelRegular])){
            if(![link hasSuffix:@"tel:"]){
                link = [NSString stringWithFormat:@"tel:%@",link];
            }
            if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_9_x_Max) {
                [SobotUITools showAlert:nil message:[link stringByReplacingOccurrencesOfString:@"tel:" withString:@""] cancelTitle:SobotLocalString(@"取消") viewController:viewController confirm:^(NSInteger buttonTag) {
                    if(buttonTag>=0){
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
                    }
                } buttonTitles:SobotLocalString(@"呼叫"), nil];
            }else{
                // 打电话
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
            }
        }else if([link hasPrefix:@"mailto:"] || sobotValidateEmail(link)){
            if(![link hasSuffix:@"mailto:"]){
                link = [NSString stringWithFormat:@"mailto:%@",link];
            }
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
        }else{
            NSString *urlStr;
            
            if (sobotIsUrl(link,[ZCUIKitTools zcgetUrlRegular])) {
                if (![link hasPrefix:@"https"] && ![link hasPrefix:@"http"]) {
                    link = [@"https://" stringByAppendingString:link];
                }
                urlStr = sobotUrlEncodedString(link);
            }else{
                urlStr = link;
            }
            ZCUIWebController *webPage=[[ZCUIWebController alloc] initWithURL:urlStr];
            if(viewController.navigationController != nil ){
                [viewController.navigationController pushViewController:webPage animated:YES];
            }else{
                UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:webPage];
                nav.navigationBarHidden=YES;
                nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
                [viewController presentViewController:nav animated:YES completion:^{
                }];
            }
        }
    }
}


#pragma mark 发送消息
/// 发送自定义卡片
/// - Parameters:
///   - card: 自定义卡片对象
///   - sendType: 0:添加消息到会话，1:发送卡片消息给客服/机器人
-(void)sendCusCardMessage:(SobotChatCustomCard *) card type:(int) sendType{
    if(!sobotIsNull(card)){
        NSDictionary *dict = [SobotCache getObjectData:card];
        
       
        // 有数据，并且没有发送过
        if(dict){ // 一个会话仅发送一次
            NSString *key = @"";
            if(sendType == 0){
                key = [NSString stringWithFormat:@"SobotCacheCardID_%@:%@",sobotConvertToString([self getLibConfig].cid),sobotConvertToString(dict[@"cardId"])];
                NSString *value = [SobotCache getLocalParamter:key];
                // 有值，说明已经发送过了
                if([@"SEND" isEqual:value]){
                    return;
                }
            }
            ZCLibSendMessageParams *params = [[ZCLibSendMessageParams alloc] init];
            params.content = [SobotCache dataTOjsonString:dict];
            params.exParams = dict;
            params.sendType = sendType;
            params.richType = SobotMessageRichJsonTypeCustomCard;
            [self sendMessage:params type:SobotMessageTypeRichJson];
            
            if(sendType == 0){
                [SobotCache addObject:@"SEND" forKey:key];
            }
        }
    }
}


/// 执行按钮点击计数
/// - Parameter menu: 点击的按钮
-(void)addCusCardMenuClick:(SobotChatCustomCardMenu *) menu{
    [ZCLibServer addCusCardMenuClick:menu config:[self getLibConfig] success:^(ZCNetWorkCode code) {
        if(menu.menuType == 1 && sobotConvertToString(menu.menuTip).length > 0){
            // 本地显示 menuTip 提示消息            
            [[ZCUICore getUICore] addMessageToList:SobotMessageActionTypeCardMenuTip content:sobotConvertToString(menu.menuTip) type:SobotMessageTypeTipsText dict:nil];
            
        }
    } fail:^(NSString * _Nonnull errorMsg, ZCNetWorkCode code) {
        
    }];
}

// 发送订单卡片
-(void)sendOrderGoodsInfo:(ZCOrderGoodsModel *)orderGoodsInfo resultBlock:(nonnull void (^)(NSString * _Nonnull, int code))ResultBlock{
    
    if(orderGoodsInfo){
        NSDictionary *contentDic = [SobotCache getObjectData:orderGoodsInfo];
        // 仅人工时才可以发送
        if([[ZCUICore getUICore] getLibConfig].isArtificial){
            [self sendMessage:[SobotCache dataTOjsonString:contentDic] type:SobotMessageTypeRichJson exParams:contentDic duration:@"" richType:SobotMessageRichJsonTypeOrder];
            if(ResultBlock){
                ResultBlock([NSString stringWithFormat:@"执行了接口调用:%@",contentDic],0);
            }
        }else{
            if(ResultBlock){
                   ResultBlock(@"当前是不是人工客服状态，不能给人工发送消息",1);
            }
        }
        
        
    }
    
}

// 发送商品卡片
-(NSDictionary *) getProductInfoDict:(ZCProductInfo *) productInfo{
    NSDictionary *contentDic = @{
        @"title":sobotConvertToString(productInfo.title),
        @"label":sobotConvertToString(productInfo.label),
        @"url":sobotConvertToString(productInfo.link),
        @"description":sobotConvertToString(productInfo.desc),
        @"thumbnail":sobotConvertToString(productInfo.thumbUrl),
    };
    return contentDic;
}
-(void)sendProductInfo:(ZCProductInfo *)productInfo resultBlock:(nonnull void (^)(NSString * _Nonnull, int code))ResultBlock{
    [self sendProductInfo:productInfo isOnlyArtificial:YES resultBlock:ResultBlock];
}
-(void)sendProductInfo:(ZCProductInfo *)productInfo isOnlyArtificial:(BOOL) onArtificial resultBlock:(nonnull void (^)(NSString * _Nonnull, int code))ResultBlock{
    
    if(productInfo){
        NSDictionary *contentDic = [self getProductInfoDict:productInfo];
        // 转json
        NSString *contextStr = [SobotCache dataTOjsonString:contentDic];
        if(onArtificial){
            // 仅人工时才可以发送
            if([[ZCUICore getUICore] getLibConfig].isArtificial){
                [self sendMessage:contextStr type:SobotMessageTypeRichJson exParams:contentDic duration:@"" richType:SobotMessageRichJsonTypeGoods];
                if(ResultBlock){
                    ResultBlock(@"执行了接口调用",0);
                }
            }else{
                if(ResultBlock){
                       ResultBlock(@"当前是不是人工客服状态，不能给人工发送消息",1);
                }
            }
        }else{
            [self sendMessage:contextStr type:SobotMessageTypeRichJson exParams:contentDic duration:@"" richType:SobotMessageRichJsonTypeGoods];
            if(ResultBlock){
                ResultBlock(@"执行了接口调用",0);
            }
        }
    }
    
}
-(void)sendMessage:(NSString *_Nonnull) content type:(SobotMessageType) msgType exParams:(NSDictionary * _Nullable) dict duration:(NSString *_Nullable) duration richType:(SobotMessageRichJsonType )richType{
    [self sendMessage:content type:msgType exParams:dict duration:duration richType:richType obj:nil];
}

-(void)sendMessage:(NSString *_Nonnull) content type:(SobotMessageType) msgType exParams:(NSDictionary * _Nullable) dict duration:(NSString *_Nullable) duration richType:(SobotMessageRichJsonType )richType obj:(id _Nullable) obj{
    ZCLibSendMessageParams *params = [[ZCLibSendMessageParams alloc] init];
    params.content = content;
    params.exParams = dict;
    params.richType = richType;
    params.duration = duration;
    //  纯文本发生时添加引用消息
    if(obj && [obj isKindOfClass:[SobotChatMessage class]] && msgType == SobotMessageTypeText){
        params.referenceMessage = obj;
    }
    if(dict){
        params.docId = sobotConvertToString(dict[@"docId"]);
        params.question = sobotConvertToString(dict[@"question"]);
        params.msgContent = sobotConvertToString(dict[@"msgContent"]);
        params.requestText = sobotConvertToString(dict[@"requestText"]);
        params.fromEnum = sobotConvertToString(dict[@"fromEnum"]);
        
        params.questionFlag = sobotConvertToString(dict[@"questionFlag"]);
    }else{
        params.questionFlag = @"0";
    }
    params.robotflag = [self getLibConfig].robotFlag;
    [self sendMessage:params type:msgType];
}

-(void)sendMessage:(ZCLibSendMessageParams *_Nonnull) sendParams type:(SobotMessageType) msgType{
    // 发送空的录音样式
    if (msgType == SobotMessageTypeStartSound) {
        if(_recordModel == nil){
            _recordModel =  [ZCPlatformTools createLocalMessage:YES messageType:SobotMessageTypeSound richType:0 action:SobotMessageActionTypeText message:@{@"content":sendParams.content} robot:NO config:[self getLibConfig]];
            _recordModel.progress     = 0;
            _recordModel.sendStatus   = 1;
            _recordModel.senderType   = 0;
            _recordModel.richModel.duration = @"0";
            _recordModel.richModel.content = sendParams.content;
            _recordModel.richModel.state = -1;
            [self addMessage:_recordModel reload:YES];
        }
        return;
    }
    
    if (msgType == SobotMessageTypeCancelSound) {
        if(_recordModel!=nil){
            [_chatMessages removeObject:_recordModel];
            _recordModel = nil;
        }
        if(self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
            [self.delegate onPageStatusChanged:ZCShowStatusMessageChanged message:@"" obj:nil];
        }
        return;
    }
    
    if(msgType == SobotMessageTypeSound){
        if(_recordModel!=nil){
            [_chatMessages removeObject:_recordModel];
            _recordModel = nil;
        }
    }
    if(_isAfterConnectUser && ![self getLibConfig].isArtificial && _afterModel==nil){
        
        if(msgType==SobotMessageTypePhoto){
            _afterModel = [ZCPlatformTools createLocalMessage:YES messageType:msgType richType:0 action:SobotMessageActionTypeDefault message:@{@"content":sendParams.content} robot:NO config:[self getLibConfig]];
        }else if(msgType == SobotMessageTypeSound){
            _afterModel = [ZCPlatformTools createLocalMessage:YES messageType:msgType richType:0 action:SobotMessageActionTypeDefault message:@{@"content":sendParams.content} robot:NO config:[self getLibConfig]];
            _afterModel.progress = 0;
            _afterModel.richModel.richmoreurl = sendParams.content;
            _afterModel.richModel.duration = sendParams.duration;
            NSString * mid = [NSString stringWithFormat:@"%d",arc4random_uniform(10000) + 100];// 生成随机数
            mid = sobotMd5(mid);
            _afterModel.msgId = mid;
        }else{
            NSString * contentText = sendParams.content;
            if ([sendParams.questionFlag intValue] == 2) {
                contentText = sendParams.msgContent;
            }
            _afterModel = [ZCPlatformTools createLocalMessage:YES messageType:msgType richType:0 action:SobotMessageActionTypeDefault message:@{@"content":contentText} robot:NO config:[self getLibConfig]];
        }
        _isAfterConnectUser = NO;
        // 转完人工再发送，检查转人工
        [self checkUserServiceWithType:ZCTurnType_BtnClick model:nil];
        return;
    }
    
    // 发送完成再计数
    [self cleanUserCount];
    
    if([self getLibConfig].isArtificial){
        _isSendToUser = YES;
    }else{
        _isSendToRobot = YES;
    }
    
    
    [ZCLibServer sendMessage:sendParams msgType:msgType config:[self getLibConfig] start:^(SobotChatMessage * _Nonnull message) {
        if(sendParams.referenceMessage!=nil){
            message.appointMessage = sendParams.referenceMessage;
        }
        [self addMessage:message reload:YES];
        
    } success:^(SobotChatMessage * _Nonnull message, ZCNetWorkCode code) {
        if(code == ZC_NETWORK_SUCCESS){
//            [self addMessage:nil reload:YES];
            [self addSoundMessage:message reload:YES];
        }
        if(code == ZC_NETWORK_New_Data){
            int fromEnum = [sendParams.fromEnum intValue];
            // 说明是快捷菜单的回复，说明是发送消息，此时不需要顶/踩/转人工
            // 4内部知识库，5普通问答，3机器人知识库(不关闭顶/踩/转人工)
            if(fromEnum == 5 || fromEnum == 4){
                // 关闭顶/踩/转人工
                message.commentType = 0;
                message.showTurnUser = NO;
                // 设置发送身份，根据当前状态来判断
                if(fromEnum == 5){
                    if([self getLibConfig].isArtificial){
                        message.sender       = [self getLibConfig].companyID;
                        message.senderName = [self getLibConfig].senderName;
                        message.senderFace = [self getLibConfig].senderFace;
                    }else{
                        message.sender       = sobotConvertIntToString([self getLibConfig].robotFlag);
                        message.senderName = [self getLibConfig].robotName;
                        message.senderFace = [self getLibConfig].robotLogo;
                    }
                }
            }
            
            [self parseRobotMessage:message];
            
        }
    } progress:^(SobotChatMessage * _Nonnull message) {
        [self addMessage:nil reload:YES];
    } fail:^(SobotChatMessage * _Nonnull message, NSString * _Nonnull errorMsg, ZCNetWorkCode code) {
        [self addMessage:nil reload:YES];
        
        if([@"SendUserOffline" isEqual:sobotConvertToString(errorMsg)]){
            // 会话已结束，不能再发送消息
            [[ZCUICore getUICore] addMessageToList:SobotMessageActionTypeOverWord content:@"" type:SobotMessageTypeTipsText dict:nil];
            // 设置新会话样式
            if (self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]) {
                [self.delegate onPageStatusChanged:ZCSetKeyBoardStatus message:@"" obj:@(ZCKeyboardStatusNewSession)];
            }

        }
    }];
}

-(void)parseRobotMessage:(SobotChatMessage *) message{
#pragma mark -- 人工客服发送的消息 直接显示
    if(message.senderType == 2){
        // 人工消息，直接添加
        [self addMessage:message reload:YES];
        return;
    }
    
//    // 如果当前是 语音转文字消息，需要重新刷新页面高度
//    if(message.senderType == 0 && message.msgType == SobotMessageTypeSound){
//        if(self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
//            [self.delegate onPageStatusChanged:ZCShowStatusMessageChanged message:@"" obj:nil];
//        }
//    }
#pragma mark -- 处理机器人接待时 是否显示转人工按钮（快捷菜单中的转人工按钮，V6的键盘转人工按钮现在放到了快捷菜单中）
    if(message.richModel
       &&(message.robotAnswer.answerType == 3 || message.robotAnswer.answerType == 4)
       && ![ZCUICore getUICore].kitInfo.isShowTansfer
       && ![ZCLibClient getZCLibClient].isShowTurnBtn){
        [ZCUICore getUICore].unknownWordsCount ++;
        // 没有配置，默认给1
        if([[ZCUICore getUICore].kitInfo.unWordsCount intValue] == 0 ){
            [ZCUICore getUICore].kitInfo.unWordsCount = @"1";
        }
        if([ZCUICore getUICore].unknownWordsCount >= [[ZCUICore getUICore].kitInfo.unWordsCount intValue]){
            // 仅机器人的模式不做处理
            if([self getLibConfig].type !=1){
                // 保存在本次有效的会话中显示转人工按钮
                [ZCLibClient getZCLibClient].isShowTurnBtn = YES;
                // 设置键盘的样式 （机器人，转人工按钮显示）
                if(self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
                    [self.delegate onPageStatusChanged:ZCShowStatusRefreshFastMenuView message:nil obj:nil];
                }
            }
        }
    }
    
    // 4.1.0新增
    if(message.richModel
       &&(message.robotAnswer.answerType == 3 || message.robotAnswer.answerType == 4)
       && [self getLibConfig].showTurnManualBtn
       && [self getLibConfig].isManualBtnFlag){
        [ZCUICore getUICore].unknownWordsCount ++;
        
        if([ZCUICore getUICore].unknownWordsCount >= [self getLibConfig].manualBtnCount){
            // 仅机器人的模式不做处理
            if([self getLibConfig].type !=1){
                // 保存在本次有效的会话中显示转人工按钮
                [ZCLibClient getZCLibClient].isShowTurnBtn = YES;
                // 设置键盘的样式 （机器人，转人工按钮显示）
                if(self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
                    [self.delegate onPageStatusChanged:ZCShowStatusRefreshFastMenuView message:nil obj:nil];
                }
            }
        }
    }
 
#pragma mark -- 工单节点的需求逻辑
    if ( [sobotConvertToString([NSString stringWithFormat:@"%d",message.robotAnswer.answerType]) hasPrefix:@"15"] && !sobotIsNull(message.richModel.richContent) && message.richModel.richContent.endFlag) {
        // 如果返回的数据是最后一轮，当前的多轮会话的cell不可点击
        //    || message.richModel.richContent.endFlag
        // 记录下标
        // 3.1.1新增需求  工单节点
        if((!sobotIsNull(message.richModel.richContent) && message.richModel.richContent.leaveTemplateId.length > 0) || message.robotAnswer.answerType == 1525){
            // 3.1.2 去掉延迟3秒，直接弹出
            if (self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]) {
               [self.delegate onPageStatusChanged:ZCShowLeaveEditViewWithTempleteId message:message.richModel.richContent.leaveTemplateId obj:message];
           }
        }
        [self addMessage:message reload:YES];
        return;
    }

#pragma mark -- 处理机器人回复时，是否触发关键字转人工
    /**
     // 仅当onlineFlag == 3时，显示机器人回复
     transferFlag=1或3：
     queueFlag=1:展示提示语，不展示机器人回复，触发转人工逻辑
     queueFlag=0:
     onlineFlag:1 表示有客服在线可接入（展示提示语，不展示机器人回复，触发转人工逻辑）
     onlineFlag:2 表示需要弹出分组接待（不展示提示语，不展示机器人回复，触发转人工逻辑）
     onlineFlag:3 表示无客服在线 （不执行转人工，展示机器人回复）
     transferFlag=2:
     不展示机器人回复，展示选择技能组文案
     */
#pragma mark -- 未触发关键字转人工，直接显示机器人回复
    if(message.robotAnswer.transferType == 0 || sobotConvertToString(message.robotAnswer.keywordId).length == 0){
        // 普通机器人回复
        [self addMessage:message reload:YES];
    }else{
#pragma mark -- 机器人指定技能组转人工或者直接转人工 并且不展示排队标记并且无客服在线
        if((message.robotAnswer.transferFlag == 1 || message.robotAnswer.transferFlag == 3) && message.robotAnswer.queueFlag == 0 && message.robotAnswer.onlineFlag == 3){
            // 普通机器人回复 没有转成功的消息
            // 这里清理掉关键字的相关属性
            message.robotAnswer.groupList = [NSMutableArray array];
            message.robotAnswer.keyword = @"";
            message.robotAnswer.keywordId = @"";
            message.robotAnswer.tipsMessage = @"";
            [self addMessage:message reload:YES];
        }else{
#pragma mark -- 仅机器人模式 并且是关键字转人工  显示 机器人回复内容 同 普通消息
            if([self getLibConfig].type == 1 &&sobotConvertToString(message.robotAnswer.keywordId).length > 0){
                message.robotAnswer.groupList = [NSMutableArray array];
                message.robotAnswer.keyword = @"";
                message.robotAnswer.keywordId = @"";
                message.robotAnswer.tipsMessage = @"";
                [self addMessage:message reload:YES];
            }
        }
    }
     
#pragma mark -- 关键字转人工的逻辑
    if([self getLibConfig].type != 1 && ![self getLibConfig].isArtificial && message.robotAnswer.keywordId.length > 0 && !message.userOffline){
        int tempType = [self getPlatfromInfo].config.type;
        if([ZCLibClient getZCLibClient].libInitInfo.service_mode > 0){
            tempType = [ZCLibClient getZCLibClient].libInitInfo.service_mode;
        }
        if(tempType == 1){
            // 只有机器人模式 不转人工
            return;
        }
#pragma mark -- 关键字转人工 显示机器人回复的技能组列表，用户点选技能转人工
        if (message.robotAnswer.transferFlag ==2 && message.robotAnswer.groupList.count > 0) {
            [self addMessage:message reload:YES];
            if(self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
                [self.delegate onPageStatusChanged:ZCShowStatusMessageChanged message:@"" obj:nil];
            }
            return;
        }
        
        if(message.robotAnswer.transferFlag == 1 || message.robotAnswer.transferFlag == 3){
            // 1-指定技能组接入，2-选择技能组列表，3-直接转入;
            if(message.robotAnswer.queueFlag == 1 || (message.robotAnswer.queueFlag == 0 && message.robotAnswer.onlineFlag == 1)){
                
                if(message.robotAnswer.transferFlag ==1){
                    // queueFlag=1:展示提示语，不展示机器人回复，触发转人工逻辑
                    if(message.robotAnswer.queueFlag == 1){
                        if(message.robotAnswer.onlineFlag == 1){
                            _checkGroupId = sobotConvertToString(message.robotAnswer.groupId);
                            _checkGroupName = @"";
                        }
                        [self doConnectUserService:message connectType:ZCTurnType_KeyWordNoGroup];
                    }else{
                        if(message.robotAnswer.onlineFlag == 1 || message.robotAnswer.onlineFlag == 2){
                            //关键字转人工 直接转人工
                            // 这里当onlineFlag==2时，groupId应该是空的，所以没有单独做onlineFlag==1判断
                            _checkGroupId = sobotConvertToString(message.robotAnswer.groupId);
                            _checkGroupName = @"";
                            if(message.robotAnswer.onlineFlag == 2){
                                // 弹技能组选择框
                                [self checkUserServiceWithType:ZCTurnType_KeyWordSelGroup model:message];
                            }else{
                                [self doConnectUserService:message connectType:ZCTurnType_KeyWord];
                            }
                        }
                    }
                }
                else {
                    // queueFlag=1:展示提示语，不展示机器人回复，触发转人工逻辑
                    if(message.robotAnswer.queueFlag == 1){
                        [self addMessageToList:SobotMessageActionTypeTransferTips content:message.robotAnswer.transferTips type:SobotMessageTypeTipsText dict:nil];
                        // 没有指定技能组
//                        [self doConnectUserService:message connectType:ZCTurnType_KeyWordNoGroup];
                        // 弹技能组
                        [self checkUserServiceWithType:ZCTurnType_KeyWordSelGroup model:message];
                    }else{
                        if(message.robotAnswer.onlineFlag == 1 || message.robotAnswer.onlineFlag == 2){
                            [self addMessage:message reload:YES];
                            if(self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
                                [self.delegate onPageStatusChanged:ZCShowStatusMessageChanged message:@"" obj:nil];
                            }
                            // 没有指定技能组
//                            if(message.robotAnswer.onlineFlag == 2){
                                // 弹技能组
                                [self checkUserServiceWithType:ZCTurnType_KeyWordSelGroup model:message];
//                            }else{
//                                // 不弹技能组 直接转
//                                [self doConnectUserService:message connectType:ZCTurnType_KeyWordNoGroup];
//                            }
                        }
                    }
                }
            }else if(message.robotAnswer.queueFlag == 0 && message.robotAnswer.onlineFlag == 2){
                // 表示需要弹出分组接待 并且不展示提示语
                _checkGroupId = @"";
                _checkGroupName = @"";
                // 重新检查，可以弹技能组  这里是要弹技能组列表的，
                [self checkUserServiceWithType:ZCTurnType_KeyWordSelGroup model:message];
            }
        }
        return;
    }
    
    // 处理 重复提问转人工 和情绪负向转人工的规则,2.8.0版本新增了transferType=4(显示转人工按钮，不主动转)，所以单独判断=1，2、3、5的情况
    // 2.8.3版本添加transferType=5的情况，需求6240按回答类型设置转人工策略
    if ([self getLibConfig].type != 1 && ![self getLibConfig].isArtificial  && (message.robotAnswer.transferType ==1 || message.robotAnswer.transferType == 2 || message.robotAnswer.transferType == 3 || message.robotAnswer.transferType == 5) && !message.userOffline) {
        // 先把键盘清理掉，以免后续页面展示被遮挡
        if ([ZCUICore getUICore].delegate  && [[ZCUICore getUICore].delegate respondsToSelector:@selector(onPageStatusChanged: message: obj:)]) {
            [[ZCUICore getUICore].delegate onPageStatusChanged:ZCShowStatusSatisfaction message:@"" obj:nil];
        }
        
        // 先添加一条提示消息 （显示成该消息由机器人发送）“对不起未能解决您的问题，正在为您转接人工客服”
//        [self addMessageToList:SobotMessageActionTypeRobotTurnMsg content:@"" type:SobotMessageTypeTipsText dict:nil];
        [self addMessageToList:SobotMessageActionTypeTransferTips content:message.robotAnswer.transferTips type:SobotMessageTypeTipsText dict:nil];
        [[ZCUICore getUICore] checkUserServiceWithType:ZCTurnType_RepeatOrMood model:message];
        return;
    }
    
    
    /**
     // 仅当onlineFlag == 3时，显示机器人回复
     transferFlag=1或3：
                 queueFlag=1:展示提示语，不展示机器人回复，触发转人工逻辑
                 queueFlag=0:
                     onlineFlag:1 表示有客服在线可接入（展示提示语，不展示机器人回复，触发转人工逻辑）
                     onlineFlag:2 表示需要弹出分组接待（不展示提示语，不展示机器人回复，触发转人工逻辑）
                     onlineFlag:3 表示无客服在线 （不执行转人工，展示机器人回复）
             transferFlag=2:
                 不展示机器人回复，展示选择技能组文案
     */
//    if(message.robotAnswer.transferFlag == 1 || message.robotAnswer.transferFlag == 3){
//        if(message.robotAnswer.queueFlag == 0 && message.robotAnswer.onlineFlag == 3){
//            [self addMessage:message reload:YES];
//            if(self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
//                [self.delegate onPageStatusChanged:ZCShowStatusMessageChanged message:@"" obj:nil];
//            }
//        }else if(message.robotAnswer.queueFlag == 0 && message.robotAnswer.onlineFlag == 2){
//            _checkGroupId = @"";
//            _checkGroupName = @"";
//            // 关键字转人工，出现此情况，keyworkId会有值
//            [self doConnectUserService:message connectType:ZCTurnType_KeyWord];
//        }else{
//            [self addMessageToList:SobotMessageActionTypeTransferTips content:message.robotAnswer.transferTips type:SobotMessageTypeTipsText dict:nil];
//            // 展示提示语，不显示机器人回复
//            _checkGroupId = sobotConvertToString(message.robotAnswer.groupId);
//            // 没有指定技能组
//            [self checkUserServiceWithType:ZCTurnType_KeyWordNoGroup model:message];
//        }
//    }else if(message.robotAnswer.transferFlag == 2){
//        // 选择groupList中的技能组
//        [self addMessage:message reload:YES];
//        if(self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
//            [self.delegate onPageStatusChanged:ZCShowStatusMessageChanged message:@"" obj:nil];
//        }
//    }
    
    
}

#pragma mark 自动应答语，欢迎语/引导语/自动发送
// 添加机器人自动问答
// 添加人工欢迎语
-(void)sendMessageWithConnectStatus:(ZCServerConnectStatus) status{
    if(status == ZCServerConnectRobot){
        if ([self getPlatfromInfo].config.robotHelloWordFlag == 1 && [self getPlatfromInfo].config.type !=2) {
            // 添加机器人欢迎语
            if(!_isShowRobotHello){
                _isShowRobotHello = YES;
                SobotChatMessage *message = [ZCPlatformTools createLocalMessage:NO messageType:SobotMessageTypeText richType:0 action:SobotMessageActionTypeRobotHelloWord message:@{@"content":[self getLibConfig].robotHelloWord} robot:NO config:[self getLibConfig]];
                [message getModelDisplayText:YES];// 处理欢迎语中带有富文本标签
                [self addMessage:message reload:YES];
            }
        }
        
//        if ([self getPlatfromInfo].config.guideFlag == 1) {
            // 添加机器人引导语
            [self getRobotGuide:2];
//        }
        
        // 发送自定义消息
        [self sendCusMsg];
    }
    if(status == ZCServerConnectArtificial){
        // 人工欢迎语
        if(!isShowAdminHello && [self showChatAdminHello]){
            isShowAdminHello = YES;
            SobotChatMessage *message = [ZCPlatformTools createLocalMessage:NO messageType:SobotMessageTypeText richType:0 action:SobotMessageActionTypeAdminHelloWord message:@{@"content":[self getLibConfig].adminHelloWord} robot:NO config:[self getLibConfig]];
            [message getModelDisplayText:YES];// 处理欢迎语中带有富文本标签
            [self addMessage:message reload:YES];
        }
//        if ([self getPlatfromInfo].config.guideFlag == 1) {
        if([ZCUICore getUICore].getLibConfig.type != 2 && [ZCUICore getUICore].getLibConfig.type != 4){
            // 添加机器人引导语
            [self getRobotGuide:3];
        }
            
//        }
        // 显示发送商品信息布局
        if(_kitInfo.productInfo!=nil && [self getPlatfromInfo].config.isArtificial  && ![@"" isEqualToString:_kitInfo.productInfo.title] && ![@"" isEqualToString:_kitInfo.productInfo.link]){
            SobotChatMessage *message = [ZCPlatformTools createLocalMessage:NO messageType:SobotMessageTypeTipsText richType:0 action:SobotMessageActionTypeSendGoods message:[self getProductInfoDict:_kitInfo.productInfo] robot:NO config:[self getLibConfig]];
            // 这里要处理掉 之前的发送卡片的消息
            if(_chatMessages.count > 0){
                int index = -1;
                for (int i = 0; i<_chatMessages.count; i++) {
                    SobotChatMessage *item = _chatMessages[i];
                    if(item.action == SobotMessageActionTypeSendGoods){
                        index = i;
                    }
                }
                if(index >-1){
                    if(_chatMessages.count > 0 && _chatMessages.count-1>=index){
                        [_chatMessages removeObjectAtIndex:index];
                    }
                }
            }
            [self addMessage:message reload:YES];
        }
        
        // 发送商品卡片
        // 自动发送商品信息
        if (_kitInfo.productInfo!=nil && [self getPlatfromInfo].config.isArtificial  && ![@"" isEqualToString:_kitInfo.productInfo.title] && ![@"" isEqualToString:_kitInfo.productInfo.link] && _kitInfo.isSendInfoCard) {
            
            if (_kitInfo.isEveryTimeSendCard) {
                [self sendProductInfo:_kitInfo.productInfo resultBlock:^(NSString * _Nonnull msg, int code) {
                    
                }];
            }else{
                // 查看之前有没有发送过，同一次会话中 查找
                NSUserDefaults *userDefatluts = [NSUserDefaults standardUserDefaults];
                NSString *isSave = sobotConvertToString([userDefatluts objectForKey:[NSString stringWithFormat:@"sobot_cid_sendCardCount%@",[self getLibConfig].cid]]);
                if (isSave.length > 0) {
                    // 只发送一次 同一次会话之前已经发送过 不在发送
                }else{
                    NSDictionary *dictionary = [userDefatluts dictionaryRepresentation];
                    for(NSString* key in [dictionary allKeys]){
                        if([key hasPrefix:@"sobot_cid_sendCardCount"]){
                            [userDefatluts removeObjectForKey:key];
                            [userDefatluts synchronize];
                        }
                    }
                    [self sendProductInfo:_kitInfo.productInfo resultBlock:^(NSString * _Nonnull msg, int code) {
                        
                    }];
                    [userDefatluts setObject:@"1" forKey:[NSString stringWithFormat:@"sobot_cid_sendCardCount%@",[self getLibConfig].cid]];
                }
            }
        }
        
        // 发送订单卡片
        if (_kitInfo.orderGoodsInfo!=nil && [self getPlatfromInfo].config.isArtificial && _kitInfo.autoSendOrderMessage) {
            if(_kitInfo.isEveryTimeAutoSend){
                [self sendOrderGoodsInfo:_kitInfo.orderGoodsInfo resultBlock:^(NSString * _Nonnull msg, int code) {
                    
                }];
            }else{
                // 查看之前有没有发送过，同一次会话中 查找
                NSUserDefaults *userDefatluts = [NSUserDefaults standardUserDefaults];
                NSString *isSave = sobotConvertToString([userDefatluts objectForKey:[NSString stringWithFormat:@"sobot_cid_sendOrderCount%@",[self getLibConfig].cid]]);
                if(isSave.length > 0){
                    // 只发送一次 同一次会话之前已经发送过 不在发送
                }else{
                    NSDictionary *dictionary = [userDefatluts dictionaryRepresentation];
                    for(NSString* key in [dictionary allKeys]){
                        if([key hasPrefix:@"sobot_cid_sendOrderCount"]){
                            [userDefatluts removeObjectForKey:key];
                            [userDefatluts synchronize];
                        }
                    }
                    // 发送订单卡片
                    [self sendOrderGoodsInfo:_kitInfo.orderGoodsInfo resultBlock:^(NSString * _Nonnull msg, int code) {
                        
                    }];
                    [userDefatluts setObject:@"1" forKey:[NSString stringWithFormat:@"sobot_cid_sendOrderCount%@",[self getLibConfig].cid]];
                }
            }
        }
        
        // 发送自定义消息
        [self sendCusMsg];
        
        
        // 转完人工再发送，发送过滤无效会话消息
        [self sendAfterConnectUserMessage];
        
    }
    
    
    // 添加通告
    if (!isShowNotice && ([self getLibConfig].announceMsgFlag == 1 && [self getLibConfig].announceTopFlag == 0 && [self getLibConfig].announceMsg.length > 0)) {
        isShowNotice = YES;
        [self addMessageToList:SobotMessageActionTypeNotice content:[self getLibConfig].announceMsg type:SobotMessageTypeTipsText dict:nil];
    }
    
    
}


-(BOOL)showChatAdminHello{
    if( isShowAdminHello ){
        return NO;
    }
    // 是否显示欢迎语
    if([self getLibConfig].adminHelloWordFlag == 1){
        // 同一个会话是否仅显示一次
        if([self getLibConfig].adminHelloWordCountRule == 2){
            if([self getLibConfig].isNew==1){
                return YES;
            }
            return NO;
        }else if([self getLibConfig].adminHelloWordCountRule == 1){
            
            NSUserDefaults *userDefatluts = [NSUserDefaults standardUserDefaults];
            NSString *isSave =  sobotConvertToString([userDefatluts objectForKey:[NSString stringWithFormat:@"sobot_cid_adminhello%@",[self getLibConfig].cid]]);
            if(isSave.length > 0){
                // 已经显示过了，不显示了
                return NO;
            }else{
                NSDictionary *dictionary = [userDefatluts dictionaryRepresentation];
                for(NSString* key in [dictionary allKeys]){
                    if([key hasPrefix:@"sobot_cid_adminhello"]){
                        [userDefatluts removeObjectForKey:key];
                        [userDefatluts synchronize];
                    }
                }
                [userDefatluts setObject:@"1" forKey:[NSString stringWithFormat:@"sobot_cid_adminhello%@",[self getLibConfig].cid]];
                
                return YES;
            }
        }
        
        return YES;
    }
    
    return NO;
}


-(void)sendCusMsg{
    // 添加自动发送自定义消息，客户单独要求需要每次都发送
    if ([ZCLibClient getZCLibClient].libInitInfo.good_msg_type >0 && sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.content).length > 0) {
        // 机器人和人工都发送
        if([ZCLibClient getZCLibClient].libInitInfo.good_msg_type > 1 && [self getPlatfromInfo].config.isArtificial){
            // 默认ZCMessageTypeText
            SobotMessageType type = [ZCLibClient getZCLibClient].libInitInfo.auto_send_msgtype;
            [self sendMessage:sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.content) type:type exParams:nil duration:nil richType:[ZCLibClient getZCLibClient].libInitInfo.auto_send_richtype];
        }
        // 自动给机器人发送文本信息
        if (([ZCLibClient getZCLibClient].libInitInfo.good_msg_type == 1 || [ZCLibClient getZCLibClient].libInitInfo.good_msg_type == 3) && ![self getPlatfromInfo].config.isArtificial) {
            SobotMessageType type = [ZCLibClient getZCLibClient].libInitInfo.auto_send_msgtype;
            // 默认ZCMessageTypeText
            [self sendMessage:sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.content) type:type exParams:nil duration:nil richType:[ZCLibClient getZCLibClient].libInitInfo.auto_send_richtype];
        }
    }
    

    // 首次加载页面时 检查是否开启工单更新提醒
    if(![self getLibConfig].isArtificial){
        [self checkUserTicketinfo];
    }
    
    // 4.0.5 添加卡片信息到会话中
    if([ZCLibClient getZCLibClient].libInitInfo.customCard){
        if(![self getLibConfig].isArtificial && ![ZCLibClient getZCLibClient].libInitInfo.showCustomCardAllMode){
            // 机器人是，没有开启所有模式都发布，不显示
        }else{
            [self sendCusCardMessage:[ZCLibClient getZCLibClient].libInitInfo.customCard type:0];
        }
    }
}




-(void)checkUserTicketinfo{
    if ([self getLibConfig].customerId.length > 0 && [self getLibConfig].msgFlag == 0) {
        __weak ZCUICore * save = self;
        [ZCLibServer checkUserTicketInfoWith:[self getLibConfig] start:^(NSString * _Nonnull url) {
            
        } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
            if (dict) {
                int existFlag = [sobotConvertToString(dict[@"data"][@"item"][@"existFlag"]) intValue];
                if (existFlag == 1) {
                    [save addMessageToList:SobotMessageActionTypeUpdateLeave content:nil type:SobotMessageTypeTipsText dict:nil];
                }
            }
        } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {

        }];
    }
}

// 此处原本为机器人热点问题，4.0版本开始，替换为常见问题
// 有选项标签和分页
// sessionPhase:1-会话开始，2-机器人会话开始，3-人工会话开始
-(void)getRobotGuide:(int )sessionPhase{
    if(_isShowRobotGuide){
        return;
    }
    _isShowRobotGuide = YES;
    
    __weak ZCUICore * safeVC = self;
    //* 会话阶段：1-会话开始，2-机器人会话开始，3-人工会话开始
    [ZCLibServer getRobotGuide:[self getPlatfromInfo].config sessionPhase:sessionPhase start:^(NSString *url) {

    } success:^(SobotChatMessage *message, ZCMessageSendCode sendCode) {
        if(sendCode == ZC_SENDMessage_New){
            // 移除已有的引导语
            [safeVC removeListModelWithType:SobotMessageTypeHotGuide tips:SobotMessageActionTypeDefault];
            
            [message getModelDisplayText:YES];
            [message getModelDisplaySugestionText:YES];
            [safeVC.chatMessages addObject:message];
            
            
            // 雷霆游戏2.8.6，移动排队消息到最下面
            if(safeVC.chatMessages!=nil && safeVC.chatMessages.count>0){
                int index = -1;
                SobotChatMessage *waitModel = nil;
                for (int i = 0; i< safeVC.chatMessages.count; i++) {
                    waitModel = safeVC.chatMessages[i];
                    // 删除上一次商品信息
                    if(waitModel.action == SobotMessageActionTypeWaiting){
                        index = i;
                        break;
                    }
                }
                
                if(index >= 0){
                    [safeVC.chatMessages removeObjectAtIndex:index];
                    [ZCUIKitTools zcModelStringToAttributeString:waitModel];
                    [safeVC.chatMessages addObject:waitModel];
                }
            }
            
        }
        
        if(safeVC.delegate && [safeVC.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
            [safeVC.delegate onPageStatusChanged:ZCShowStatusMessageChanged message:@"" obj:safeVC.chatMessages];
        }

        // 添加机器人热点引导语
        [safeVC getHotGuideWord];

        [self sendCusMsg];
    } fail:^(SobotChatMessage *message, ZCMessageSendCode errorCode) {
        // 添加机器人热点引导语
        [safeVC getHotGuideWord];

        [self sendCusMsg];
    }];
}

-(void)getHotGuideWord{
    
    if (![ZCLibClient getZCLibClient].libInitInfo.is_enable_hot_guide) {
        return;
    }
    NSMutableDictionary * param = [NSMutableDictionary dictionaryWithCapacity:0];
    NSString * margs = @"";
    // 用户自定义字段 2.2.1版本新增
    @try {
        if ([ZCLibClient getZCLibClient].libInitInfo.margs != nil && [[ZCLibClient getZCLibClient].libInitInfo.margs isKindOfClass:[NSDictionary class]]) {
            margs = [SobotCache dataTOjsonString:[ZCLibClient getZCLibClient].libInitInfo.margs];
            
            [param setObject:sobotConvertToString(margs) forKey:@"margs"];
        }else{
            [param setObject:@"" forKey:@"margs"];
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    __weak ZCUICore *safeVC = self;
    [ZCLibServer getHotGuide:[self getLibConfig] Parms:param start:^(NSString * _Nonnull url) {
        
    } success:^(SobotChatMessage * _Nonnull message, ZCMessageSendCode sendCode) {
        if(sendCode == ZC_SENDMessage_New){
            [message getModelDisplayText:YES];
            [message getModelDisplaySugestionText:YES];
            [safeVC addMessage:message reload:YES];
        }
    } fail:^(SobotChatMessage * _Nonnull message, ZCMessageSendCode errorCode) {
        
    }];
    
}


#pragma mark -- 添加提示消息
-(SobotChatMessage *_Nullable)addMessageToList:(SobotMessageActionType) action content:(NSString * _Nullable) content type:(SobotMessageType )msgType dict:(NSDictionary * _Nullable) message{
    SobotChatMessage *newMessage = nil;
    if(action == SobotMessageActionTypeUserTipWord || action == SobotMessageActionTypeAdminTipWord){
        if ([self getPlatfromInfo].config.isArtificial) {
            // 当前人工客服的昵称(在会话保持的模式下，返回再进入SDK ，昵称变成机器人昵称的问题)
            _receivedName = [self getPlatfromInfo].config.senderName;
        }
        newMessage=  [ZCPlatformTools createLocalMessage:NO messageType:msgType richType:0 action:action message:@{@"content":content} robot:NO config:[self getLibConfig]];
        newMessage.tipsMessage = [ZCPlatformTools getTipMsg:action content:@""];
        [_chatMessages addObject:newMessage];
    }else{
        if(sobotIsNull(message)){
            newMessage = [ZCPlatformTools createLocalMessage:NO messageType:msgType richType:0 action:action message:@{@"content":content} robot:NO config:[self getLibConfig]];
        }else{
            newMessage = [ZCPlatformTools createLocalMessage:NO messageType:msgType richType:0 action:action message:message robot:NO config:[self getLibConfig]];
        }
        newMessage.tipsMessage = [ZCPlatformTools getTipMsg:action content:content];
        if(action == SobotMessageActionTypeLeaveSuccess){
            newMessage.senderType = 0;
        }
        // 转人工成功之后清理掉所有的留言入口
        if (!sobotIsNull(_chatMessages) && _chatMessages.count>=1) {
            
            [self checkMessage:newMessage];
        }
        [_chatMessages addObject:newMessage];
    }
    
    // 设置昵称
    if(_delegate && [_delegate respondsToSelector:@selector(setTitleName:)]){
        [_delegate setTitleName:_receivedName];
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
        [self.delegate onPageStatusChanged:ZCShowStatusMessageChanged message:@"" obj:nil];
    }
    return newMessage;
}


/// 如果message 为空，说明仅想刷新页面
/// @param message 可以为空
/// @param isReload 是否通知页面刷新
-(void)addMessage:(SobotChatMessage *  _Nullable) message reload:(BOOL) isReload{
    if(!sobotIsNull(message)){
        if(message.action == SobotMessageActionTypeEvaluation){
            [self checkMessage:message];
            return;
        }
        
        // 添加机器人标记
        if(message.senderType == 1 && [self getLibConfig].adminReadFlag==1 && message.action!=SobotMessageActionTypeRobotHelloWord){
//            message.readStatus = 2;
            // 机器人，记录已读
            [[ZCUICore getUICore].unReadMessageCache setObject:message forKey:message.msgId];
        }
        
        [_chatMessages addObject:message];
    }
    
    if(isReload){
        if(self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
            [self.delegate onPageStatusChanged:ZCShowStatusMessageChanged message:@"" obj:message];
        }
    }
}

-(void)addSoundMessage:(SobotChatMessage *) message reload:(BOOL) isReload{
    if(isReload){
        if(self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
            [self.delegate onPageStatusChanged:ZCShowStatusMessageChanged message:@"" obj:message];
        }
    }
}


-(void)checkMessage:(SobotChatMessage *) message{
    ZCLibConfig *conf = [self getPlatfromInfo].config;
    NSString *indexs = @"";
    SobotMessageActionType action = message.action;
    
    for (int i = (int)_chatMessages.count-1; i>=0; i--) {
        SobotChatMessage *model = _chatMessages[i];
        // 删除上一条留言信息
        if ([model.tipsMessage hasPrefix:sobotConvertToString([self getPlatfromInfo].config.adminNonelineTitle)] && (action == SobotMessageActionTypeUserNoAdmin)) {
            indexs = [indexs stringByAppendingFormat:@",%d",i];
        }else if([model.tipsMessage hasPrefix:SobotKitLocalString(@"您已完成评价")] && (action == SobotMessageActionTypeEvaluationCompleted)){
            // 删除上一次商品信息
            indexs = [indexs stringByAppendingFormat:@",%d",i];
        }else if ([model.tipsMessage hasPrefix:SobotKitLocalString(@"咨询后才能评价服务质量")] && (action == SobotMessageActionTypeAfterConsultingEvaluation)){
            indexs = [indexs stringByAppendingFormat:@",%d",i];
        }else if ([model.tipsMessage hasPrefix:SobotKitLocalString(@"暂时无法转接人工客服")] && (action == SobotMessageActionTypeIsBlock)){
            indexs = [indexs stringByAppendingFormat:@",%d",i];
        }else if ([model.richModel.content isEqual:[self getPlatfromInfo].config.robotHelloWord] && [self getPlatfromInfo].config.type !=2){
            
            //                        [ZCStoreConfiguration setZCParamter:KEY_ZCISROBOTHELLO value:@"1"];
            
        }else if ([model.tipsMessage hasPrefix:SobotKitLocalString(@"您好,本次会话已结束")] && (action == SobotMessageActionTypeOverWord)){
            indexs = [indexs stringByAppendingFormat:@",%d",i];
        }else if (action == SobotMessageActionTypeUpdateLeave){
            indexs = [indexs stringByAppendingFormat:@",%d",i];
        }
    }
    if(indexs.length>0){
        indexs = [indexs substringFromIndex:1];
        for (NSString *index in [indexs componentsSeparatedByString:@","]) {
            [_chatMessages removeObjectAtIndex:[index intValue]];
        }
    }
    
    // 排队 和  接入人工成功
    if (message.action == SobotMessageActionTypeWaiting) {
        
        if([self getPlatfromInfo].config.isArtificial){
            _receivedName = [self getPlatfromInfo].config.robotName;
            
            // 设置重新接入时键盘样式
            if(self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
                [self.delegate onPageStatusChanged:ZCShowStatusRobotStyle message:_receivedName obj:nil];
            }
            conf.isArtificial = NO;

        }
        
        if (conf.type == 2 && !conf.isArtificial) {
            // 设置昵称
            _receivedName = SobotKitLocalString(@"排队中...");
            // 设置重新接入时键盘样式
            if(self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
                [self.delegate onPageStatusChanged:ZCShowStatusChangedTitle message:_receivedName obj:nil];
            }
        }
        
        // 先清掉人工不在时的留言Tipcell
        if (_chatMessages !=nil && _chatMessages.count>0 && !conf.isArtificial) {
            NSMutableArray *indexs = [[NSMutableArray alloc] init];
            for (int i = (int)_chatMessages.count-1; i>=0 ; i--) {
                SobotChatMessage *libMassage = _chatMessages[i];
                if ( [sobotConvertToString(libMassage.tipsMessage) hasSuffix:SobotKitLocalString(@"留言")] ) {// 2.6.4 去掉|| [libMassage.sysTips hasPrefix:ZCSTLocalString(@"排队中，您在队伍中")]
                    [indexs addObject:[NSString stringWithFormat:@"%d",i]];
                }
                
            }
            if(indexs.count>0){
                for (NSString *index in indexs) {
                    [_chatMessages removeObjectAtIndex:[index intValue]];
                }
            }
            [indexs removeAllObjects];
        }
        
        
        if (_chatMessages!=nil && _chatMessages.count>0) {
            int index = -1;
            for (int i = ((int)_chatMessages.count-1); i >= 0 ; i--) {
                //注意 libMassage 和 message 之间的区别
                SobotChatMessage *libMassage = _chatMessages[i];
                if (libMassage.action == SobotMessageActionTypeWaiting) {
                    
                    index = i;
                    break;
                }
            }
            if (index>=0) {
                [_chatMessages removeObjectAtIndex:index];
            }
            
        }
    }
    
    
    // 转人工成功之后清理掉所有的留言入口
    if (message.action == SobotMessageActionTypeOnline) {
        
        if (_chatMessages !=nil) {
            NSString *indexs = @"";
            for (int i = (int)_chatMessages.count-1; i>=0; i--) {
                SobotChatMessage *libMassage = _chatMessages[i];
                
                // 删除上一条留言信息
                if ([sobotConvertToString(libMassage.tipsMessage) hasSuffix:SobotKitLocalString(@"留言")] || [libMassage.tipsMessage isEqualToString:conf.adminNonelineTitle]) {
                    indexs = [indexs stringByAppendingFormat:@",%d",i];
                }else if(libMassage.msgType == SobotMessageActionTypeSendGoods){
                    // 删除上一次商品信息
                    indexs = [indexs stringByAppendingFormat:@",%d",i];
                }else if([sobotConvertToString(libMassage.tipsMessage) hasPrefix:SobotKitLocalString(@"未解决问题？点击")]){
                    libMassage.isHistory = YES;
                    indexs = [indexs stringByAppendingFormat:@",%d",i];
                }else if([sobotConvertToString(libMassage.tipsMessage) hasSuffix:SobotKitLocalString(@"接受了您的请求")]){
                    indexs = [indexs stringByAppendingFormat:@",%d",i];
                }
            }
            if(indexs.length>0){
                indexs = [indexs substringFromIndex:1];
                for (NSString *index in [indexs componentsSeparatedByString:@","]) {
                    [_chatMessages removeObjectAtIndex:[index intValue]];
                }
            }
        }
        
    }
    
    
    // 过滤多余的满意度cell
    if (message.action == SobotMessageActionTypeEvaluation) {
        if (_chatMessages !=nil && _chatMessages.count>0 ) {
            NSMutableArray *indexs = [[NSMutableArray alloc] init];
            for (int i = (int)_chatMessages.count-1; i>=0 ; i--) {
                SobotChatMessage *libMassage = _chatMessages[i];
                if ( libMassage.action == SobotMessageActionTypeEvaluation) {
                    [indexs addObject:[NSString stringWithFormat:@"%d",i]];
                }
            }
            if(indexs.count>0){
                for (NSString *index in indexs) {
                    [_chatMessages removeObjectAtIndex:[index intValue]];
                }
            }
            [indexs removeAllObjects];
        }
        if(_satisfactionConfig!=nil && _satisfactionConfig.isCreated == 0){
            // code = 0获取成功，code = 1,获取失败
            if(![@"SUCCESS" isEqual:message.tipsMessage]){
                [_chatMessages addObject:message];
                
                
                if(self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
                    [self.delegate onPageStatusChanged:ZCShowStatusMessageChanged message:@"" obj:nil];
                }
            }
        }else{
            [self loadSatisfactionDictlock:^(int code) {
                // code = 0获取成功，code = 1,获取失败
                if(![@"SUCCESS" isEqual:message.tipsMessage]){
                    
                    [self->_chatMessages addObject:message];

                    
                    if(self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
                        [self.delegate onPageStatusChanged:ZCShowStatusMessageChanged message:@"" obj:nil];
                    }
                }
            }];
        }
    }else if(message.action == SobotMessageActionTypeRevertMsg){
        if (_chatMessages !=nil && _chatMessages.count>0 ) {
            int index = -1;
            for (int i = (int)_chatMessages.count-1; i>=0 ; i--) {
                SobotChatMessage *libMassage = _chatMessages[i];
                if ([libMassage.msgId isEqual:message.revokeMsgId]) {
                    index = i;
                    break;
                }
            }
            if(index >= 0){
                [_chatMessages replaceObjectAtIndex:index withObject:message];
            }
        }
    }else{
        // 清理掉已有的欢迎语
        if([[self getLibConfig].adminHelloWord isEqual:message.richModel.content]){
            if (_chatMessages !=nil && _chatMessages.count>0) {
                NSMutableArray *indexs = [[NSMutableArray alloc] init];
                for (int i = (int)_chatMessages.count-1; i>=0 ; i--) {
                    SobotChatMessage *libMassage = _chatMessages[i];
                    if([[self getLibConfig].adminHelloWord isEqual:libMassage.richModel.content]){
                        [indexs addObject:[NSString stringWithFormat:@"%d",i]];
                    }
                    
                }
                if(indexs.count>0){
                    for (NSString *index in indexs) {
                        [_chatMessages removeObjectAtIndex:[index intValue]];
                    }
                }
                [indexs removeAllObjects];
            }
        }
    }
    
    
    // 安全性提示
    if (([self getLibConfig].accountStatus == 0 || [self getLibConfig].accountStatus == 1) && !message.isHistory) {
        if ([self getLibConfig].isArtificial) {
            if (!sobotIsNull(message.richModel.content) && [message.richModel.content rangeOfString:SobotKitLocalString(@"验证码")].location != NSNotFound) {
                // 添加提示消息
                [self addMessageToList:SobotMessageActionTypeSafety content:@"" type:SobotMessageTypeTipsText dict:nil];
            }
        }
    }
}

#pragma mark - 获取人工评价标签
- (void)loadSatisfactionDictlock:(void (^)(int)) loadResult{
    if(_satisfactionConfig!=nil && _satisfactionConfig.isCreated == 1){
        if(loadResult){
            loadResult(0);
        }
        return;
    }
    [ZCLibServer satisfactionMessage:[self getLibConfig].uid start:^{
            
        } success:^(NSDictionary *dict, ZCNetWorkCode code) {
            self->_satisfactionConfig = [[ZCSatisfactionConfig alloc] initWithMyDict:dict];
            
            if(loadResult){
                loadResult(0);
            }
        } fail:^(NSString *msg, ZCNetWorkCode errorCode) {
            if(loadResult){
                loadResult(1);
            }
        }];
}

#pragma mark 转人工开始
-(void)doConnectUserService:(SobotChatMessage *)msgModel connectType:(ZCTurnType) type{
    // 2.4.2新增询前表单
    // 2.8.0添加单独配置，关闭询前表单
    // 在转人工的事件进行操作
    if (!_isShowForm  && !_kitInfo.isCloseInquiryForm) {
        // 关闭加载动画
        [[SobotToast shareToast] dismisProgress];
        [ZCLibServer getAskTabelWithUid:[self getPlatfromInfo].config.uid start:^{

        } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
            self.isShowForm = YES;

            @try{
                if ([sobotConvertToString(dict[@"code"]) intValue] == 1 && [sobotConvertToString(dict[@"data"][@"openFlag"]) intValue] == 1) {
                    if(self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:other:)]){
                        [self.delegate onPageStatusChanged:ZCShowStatusOpenAskTable message:sobotConvertToString(self->_checkGroupId) obj:msgModel other:@{@"type":@(type),@"dict":dict[@"data"]}];
                    }
                }else{
                    // 去执行转人工的操作
                    [self doConnectUserService:msgModel connectType:type];
                }

            } @catch (NSException *exception) {

            } @finally {

            }

        } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {

        }];
        // 先填写询前表单，填写完成再执行转人工
        return;
        
    }
    
    // 定义传输参数
    ZCLibOnlineCustomerParams * paramter = [[ZCLibOnlineCustomerParams  alloc] init];
    
    // 指定客服
    NSString *chooseAdminId = sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.choose_adminid);
    // 上次联系过的客户
    if(type == ZCTurnType_OffMessageAdmin){
        chooseAdminId = sobotConvertToString([ZCPlatformTools sharedInstance].offlineMsgAdminId);
    }
    // 如果指定客服，客服不在线是否还要继续往下转，tranFlag=0往下转，默认为0
    int tranFlag = [ZCLibClient getZCLibClient].libInitInfo.tran_flag;
    BOOL tempisDoConnectedUser = isDoConnectedUser;
    if (isDoConnectedUser) {
        chooseAdminId = @"";
        tranFlag = 0;
        isDoConnectedUser = NO;
    }
    paramter.tranFlag = tranFlag;
    paramter.chooseAdminId = chooseAdminId;
    
    // 是否正在排队
    bool current = NO;
    if([self getPlatfromInfo].waitingMessage!=nil &&  [[self getLibConfig].cid isEqual:[self getPlatfromInfo].waitingMessage.cid]){
        current = YES;
    }
    paramter.current = current;
    
    // 技能组，指定了技能组
    if(sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.groupid).length > 0){
        paramter.groupId = sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.groupid);
        paramter.groupName = sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.group_name);
    }
    
    // 选择了技能组
    if(sobotConvertToString(_checkGroupId).length > 0){
        paramter.groupId = sobotConvertToString(_checkGroupId);
        paramter.groupName = sobotConvertToString(_checkGroupName);
        
        // 把选择的技能组还原
        if(type == ZCTurnType_KeyWord || type == ZCTurnType_CellGroupClick || type == ZCTurnType_KeyWordNoGroup){
            _checkGroupId = @"";
            _checkGroupName   = @"";
        }
    }
    
    if(msgModel!=nil && [msgModel isKindOfClass:[SobotChatMessage class]]){
        /// 3.1.5 新增 answerMsgId ruleId 字段
        paramter.answerMsgId = sobotConvertToString(msgModel.msgId);
        paramter.ruleId = sobotConvertToString(msgModel.robotAnswer.ruleId);
        
        // 关键字转人工的场景 添加关键字的参数
        if(type == ZCTurnType_KeyWord || type == ZCTurnType_KeyWordNoGroup || type == ZCTurnType_KeyWordSelGroup){
            paramter.queueFlag = msgModel.robotAnswer.queueFlag;
            paramter.keyword = sobotConvertToString(msgModel.robotAnswer.keyword);
            paramter.keywordId = sobotConvertToString(msgModel.robotAnswer.keywordId);
        }
        
        paramter.transferType = msgModel.robotAnswer.transferType;
        
        // 当transferType=5时,需要拆分transferType的值为6、7、8、9
        // 3.0.6版本发现bug，当transferType=0时，点击转人工作，需要根据机器人回答，重新赋值类型
        if((paramter.transferType == 0 && type == ZCTurnType_BtnClick) || paramter.transferType == 5){
            int temptransferType = 0;
            // 1 直接回答，2 理解回答，3 不能回答, 4引导回答
            // 1、9、11、12、14都是直接回答
            if(msgModel.robotAnswer.answerType == 1 || msgModel.robotAnswer.answerType == 9 ||
               msgModel.robotAnswer.answerType == 11 ||
               msgModel.robotAnswer.answerType == 12 ||
               msgModel.robotAnswer.answerType == 14){
                temptransferType = 6;
            }else if(msgModel.robotAnswer.answerType == 2){
                temptransferType = 7;
            }else if(msgModel.robotAnswer.answerType == 3){
                temptransferType = 9;
            }else if(msgModel.robotAnswer.answerType == 4){
                temptransferType = 8;
            }
            if(temptransferType > 0){
                paramter.transferType = temptransferType;
            }
        }
        if(paramter.transferType >= 4 && paramter.transferType <= 9){
            if(paramter.transferType==4){
                paramter.docId = msgModel.robotAnswer.docId;
            }else{
                paramter.docId = msgModel.robotAnswer.docId;
            }
        }
        if(sobotConvertToString(paramter.docId).length == 0){
            paramter.docId = msgModel.robotAnswer.docId;
        }
        paramter.unknownQuestion = sobotConvertToString(msgModel.robotAnswer.originQuestion);
    }
    
    // 机器人出现转人工按钮
    if(paramter.transferType >= 1 && paramter.transferType < 4){
        paramter.activeTransfer = 0;
        
    }else if(type == ZCTurnType_BtnClickUpOrDown){
        // 客户踩或赞显示转人工按钮
        paramter.activeTransfer = 1;
        paramter.transferType = 10;
    }else if(type == ZCTurnType_BtnClick || type == ZCTurnType_InitBeConnected  || type == ZCTurnType_InitOnUserType){
        // 客服主动转,（4.1.0版本新增如果是人工优或仅人工自动转人工，且为第一次转，设置activeTransfer为0）
        if(type == ZCTurnType_InitOnUserType && !tempisDoConnectedUser){
            paramter.activeTransfer = 0;
        }else{
            paramter.activeTransfer = 1;
        }
    }else{
        paramter.activeTransfer = 0;
    }
    paramter.transferAction  = [ZCLibClient getZCLibClient].libInitInfo.transferaction;
    paramter.queueFirst  = [ZCLibClient getZCLibClient].libInitInfo.queue_first;
    
    // 存储当前的技能组
    [self getPlatfromInfo].groupId = paramter.groupId;
    [self getPlatfromInfo].groupName = paramter.groupName;
    [[ZCPlatformTools sharedInstance] savePlatformInfo:[self getPlatfromInfo]];
    
    __weak ZCUICore *safeVC = self;
    if(_isTurnLoading){
        return;
    }
    
#pragma mark - 调用转人工接口
    [ZCLibServer connectOnlineCustomer:paramter config:[self getLibConfig] start:^(NSString * _Nonnull url) {
        self->_isTurnLoading = YES;
        //开始转人工
        if (safeVC.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]) {
            [safeVC.delegate onPageStatusChanged:ZCShowStatusConnectingUser message:@"" obj:nil];
        }
    } result:^(NSDictionary * _Nonnull result, ZCConnectUserStatusCode status) {
        // 转人工完成,隐藏技能组页面，转人工按钮可点击
        if (safeVC.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]) {
            [safeVC.delegate onPageStatusChanged:ZCShowStatusConnectFinished message:@"" obj:nil];
        }
        
        self->_isTurnLoading = NO;
        
        [[SobotToast shareToast] dismisProgress];
        // 先设置机器人名称
        self.receivedName = [self getPlatfromInfo].config.robotName;
        
        
        if (status == ZCConnectUserNextTry) {
            if (type == ZCTurnType_KeyWord || type == ZCTurnType_CellGroupClick ) {
                // 这里需要区分是否是关键字转人工 返回6不做处理
                //            [self doConnectUserService];
                // 2.9.2关键字转人工，如果是指定客服且不显示提醒时，显示机器人回答
                if(self->_keyworkRobotReplyModel){
                    [safeVC addMessage:self->_keyworkRobotReplyModel reload:YES];
                }
            }
            
            self->isDoConnectedUser = YES;
            
            // 回复原始值，在次转人工时，重新走转人工逻辑，不在直接转其他客服
            [ZCLibClient getZCLibClient].libInitInfo.choose_adminid = @"";
            
            // 重新检查，可以弹技能组
            [self checkUserServiceWithType:type model:msgModel];
        }else{
            if(status != ZCConnectUserServerFailed){
                [safeVC configConnectedResult:result code:status turnType:type];
                
            }
        }
    }];
}
-(void)configConnectedResult:(NSDictionary *) dict code:(ZCConnectUserStatusCode) status turnType:(ZCTurnType ) turnType{
    if(status==ZCConnectUserRobotTimeout){
        // 用户长时间没有说话，已经超时 （做机器人超时下线的操作显示新会话的键盘样式）
        [ZCUICore getUICore].isShowForm = NO;
        return;
    }
    
    if(status!=ZCConnectUserOfWaiting && status!=ZCConnectUserBeConnected && status!=ZCConnectUserSuccess){
        if(_afterModel!=nil){
            [self sendLeaveMessageWithConnectFail];
        }
    }

    // status = 6 说明当前对接的客服转人工没有成功
   
    // 2.7.1 需求5185 关键字转人工 触发排队给提示 原逻辑不提示
    if (status == ZCConnectUserWaitingThreshold ) {
        if ( turnType == ZCTurnType_KeyWord && [sobotConvertToString(dict[@"data"][@"queueFlag"]) intValue] == 0) {
            return;
        }
        
        [ZCLibClient getZCLibClient].libInitInfo.groupid = @"";
        // 排队达到阀值
        // 1.留言开关是否开启
        // 2.各种接待模式
        // 3.键盘的切换
        // 4.添加提示语
        // 5.设置键盘样式
        [ZCUICore getUICore].isShowForm = NO;
                
        if ([self getPlatfromInfo].config.type ==2){
            if (self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]) {
                [self.delegate onPageStatusChanged:ZCSetKeyBoardStatus message:@"" obj:@(ZCKeyboardStatusNewSession)];
            }
            
            // 设置昵称
            self.receivedName =SobotKitLocalString(@"排队已满");

        }
        // 设置昵称
        if (self.delegate && [self.delegate respondsToSelector:@selector(setTitleName:)]) {
            [self.delegate setTitleName:_receivedName];
        }
        // 添加提示语
        if ([self getPlatfromInfo].config.msgFlag == 0) {
            //  跳转到留言不直接退出SDK
            if(self.delegate  && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
                [self.delegate onPageStatusChanged:ZCShowStatusLeaveOpenWithClose message:sobotConvertToString(dict[@"data"][@"msg"]) obj:@(ZCTurnType_BtnClick)];
            }
        }
        return;
    }
    
    // 转人工成功或者已经是人工状态
    if(status == ZCConnectUserBeBlock){// 说明当前用户是黑名单用户
        if ( turnType == ZCTurnType_KeyWord && [sobotConvertToString(dict[@"data"][@"queueFlag"]) intValue] == 0) {
            return;
        }
        [self addMessageToList:SobotMessageActionTypeIsBlock content:@"" type:SobotMessageTypeTipsText dict:nil];
    }else if(status==ZCConnectUserSuccess || status == ZCConnectUserBeConnected){
        self.receivedName = sobotConvertToString(dict[@"data"][@"aname"]);
        ZCLibConfig *libConfig = [self getPlatfromInfo].config;
        libConfig.isArtificial = YES;
        libConfig.senderFace = sobotConvertToString(dict[@"data"][@"aface"]);
        libConfig.senderName = self.receivedName;
        [[self getPlatfromInfo] setConfig:libConfig];

        
        SobotChatMessage *message = [ZCPlatformTools createLocalMessage:NO messageType:SobotMessageTypeTipsText richType:0 action:SobotMessageActionTypeOnline message:@{@"content":sobotConvertToString(self.receivedName)} robot:NO config:[self getLibConfig]];
        message.senderFace = sobotConvertToString(dict[@"data"][@"aface"]);
        [self addMessage:message reload:YES];
        
        // 是否设置语音开关
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]) {
            [self.delegate onPageStatusChanged:ZCSetKeyBoardStatus message:@"" obj:@(ZCKeyboardStatusUser)];
        }
        
        // 处理关键字转人工的cell 不可在点击
        for (SobotChatMessage *message in _chatMessages) {
            if (message.robotAnswer && message.robotAnswer.groupList.count >0 && !message.isHistory ) {
                message.isHistory = YES;// 变成不可点击，成为历史
            }
        }
        
        [self sendMessageWithConnectStatus:ZCServerConnectArtificial];
    }else if(status==ZCConnectUserOfWaiting ){
        [self sendAfterModeWhithConnectWait];
        
        // queueFlag 关键字转人工未成功，是否排队 1-排队，0-不排队（决定页面端是否展示排队文案）
        if ( turnType == ZCTurnType_KeyWord && [sobotConvertToString(dict[@"data"][@"queueFlag"]) intValue] == 0) {
            return;
        }
        
        if ([self getPlatfromInfo].config.type == 2) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 if (self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]) {
                    [self.delegate onPageStatusChanged:ZCSetKeyBoardStatus message:@"" obj:@(ZCKeyboardStatusWaiting)];
                }
                
            });
        }else{
            if (sobotConvertToString(dict[@"data"][@"aname"]).length) {
                self.receivedName = sobotConvertToString(dict[@"data"][@"aname"]);
            }
          
            if (self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]) {
                [self.delegate onPageStatusChanged:ZCSetKeyBoardStatus message:@"ZCKeyboardStatusRobot" obj:nil];
            }
        }
        // 2.6.4  content:sobotConvertToString(dict[@"data"][@"count"])  替换 由服务端处理排队个数数据
        if ([self getLibConfig].queueFlag == 1) {
            SobotChatMessage *message = [ZCPlatformTools createLocalMessage:NO messageType:SobotMessageTypeTipsText richType:0 action:SobotMessageActionTypeWaiting message:@{@"content":sobotConvertToString(dict[@"data"][@"queueDoc"])} robot:NO config:[self getLibConfig]];
            message.senderFace = sobotConvertToString(dict[@"data"][@"aface"]);
            [self addMessage:message reload:YES];
            [self getPlatfromInfo].waitingMessage = message;
        }
        // 如果没有机器人欢迎语，添加机器人欢迎语 (只在转人工不成功的情况下添加) 仅人工模式不添加
        if ([self getPlatfromInfo].config.type != 2 ) {
            // 添加机器人欢迎语
            [self sendMessageWithConnectStatus:ZCServerConnectRobot];
        }
    } else if(status==ZCConnectUserNoAdmin){
        if ( turnType == ZCTurnType_KeyWord && [sobotConvertToString(dict[@"data"][@"queueFlag"]) intValue] == 0) {
            return;
        }
        [ZCUICore getUICore].isShowForm = NO;
        
        // 无客服在线
        [self addNoAdminOnlineTips];
        
        // 如果当前列表清空了，再次添加欢迎语
        if(self.chatMessages.count == 0)
        {
            _isShowRobotHello = NO;
        }
        // 如果没有机器人欢迎语，添加机器人欢迎语 (只在转人工不成功的情况下添加) 仅人工模式不添加
        if ([self getPlatfromInfo].config.type != 2 ) {
            // 添加机器人欢迎语
            [self sendMessageWithConnectStatus:ZCServerConnectRobot];
            
            // 设置机器人的键盘样式
            if (self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]) {
                [self.delegate onPageStatusChanged:ZCSetKeyBoardStatus message:@"" obj:@(ZCKeyboardStatusRobot)];
            }
            
        }else{
            if([self getPlatfromInfo].config.msgFlag == 1){

                if (self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]) {
                    [self.delegate onPageStatusChanged:ZCSetKeyBoardStatus message:@"" obj:@(ZCKeyboardStatusNewSession)];
                }
            }else if([self getPlatfromInfo].config.msgFlag == 0){
                if (self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]) {
                    [self.delegate onPageStatusChanged:ZCSetKeyBoardStatus message:@"" obj:@(ZCKeyboardStatusNewSession)];
                }
                
            }
            // 设置昵称
            self.receivedName = SobotKitLocalString(@"暂无客服在线");
        }
    }else if(status == ZCConnectUserServerFailed ){
        if ( turnType == ZCTurnType_KeyWord && [sobotConvertToString(dict[@"data"][@"queueFlag"]) intValue] == 0) {
            return;
        }
        [ZCUICore getUICore].isShowForm = NO;
        
        // status == -1 重连
        if ([self getPlatfromInfo].config.type ==2){
            if([self getPlatfromInfo].config.msgFlag == 1){
                // 无客服在线
                [self addNoAdminOnlineTips];
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]) {
                [self.delegate onPageStatusChanged:ZCSetKeyBoardStatus message:@"" obj:@(ZCKeyboardStatusNewSession)];
            }
            // 设置昵称
            self.receivedName = SobotKitLocalString(@"暂无客服在线");
        }
        
    }
    
    // 设置昵称
    if (self.delegate && [self.delegate respondsToSelector:@selector(setTitleName:)]) {
        [self.delegate setTitleName:_receivedName];
    }
    
}


// 转人工排队，调用新的延迟转人工发送消息接口
-(void)sendAfterModeWhithConnectWait{
    if(_afterModel!=nil){
        [ZCLibServer sendAfterModeWithConnectWait:sobotConvertToString(_afterModel.richModel.content) uid:[self getLibConfig] error:^(ZCNetWorkCode status, NSString * _Nonnull errorMessage) {
            
        } success:^(NSString * _Nonnull msgLeaveTxt, NSString * _Nonnull msgLeaveContentTxt, NSString * _Nonnull leaveExplain) {
            
        }];
        _afterModel = nil;
    }
}

// 转人工失败，调用留言接口
-(void)sendLeaveMessageWithConnectFail{
    if(_afterModel==nil){
        return;
    }
    [ZCLibServer getLeaveMsgWith:[self getLibConfig].uid Content:sobotConvertToString(_afterModel.richModel.content) groupId:[[ZCUICore getUICore] getTempGroupId] start:^{
        
    } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
        
        
    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
        NSLog(@"%@",errorMessage);
    }];
    _afterModel = nil;
}

-(void)sendAfterConnectUserMessage{
    if(_isAfterConnectUser){
        _isAfterConnectUser = NO;
    }
    if(_afterModel == nil){
        return;
    }
    if([self getLibConfig].isArtificial){
        // 如果已经是人工了，发送普通消息
        [self sendMessage:sobotConvertToString(_afterModel.richModel.content) type:_afterModel.msgType exParams:nil duration:sobotConvertToString(_afterModel.richModel.duration) richType:_afterModel.richModel.type];
        
        _afterModel = nil;
        return;
    }
}

-(void)addNoAdminOnlineTips{
    if ([self getLibConfig].adminNoneLineFlag == 1) {
        [self removeListModelWithType:SobotMessageTypeTipsText tips:SobotMessageActionTypeUserNoAdmin];
        
        SobotChatMessage *message = [ZCPlatformTools createLocalMessage:NO messageType:SobotMessageTypeTipsText richType:0 action:SobotMessageActionTypeUserNoAdmin message:@{@"content":sobotConvertToString([self getLibConfig].adminNonelineTitle)} robot:NO config:[self getLibConfig]];
        [self addMessage:message reload:YES];
    }
}

/// 检查转人工
/// @param type  转人工类型
/// @param message 当前影响的对象
-(void)checkUserServiceWithType:(ZCTurnType) type model:(SobotChatMessage *) message{
    
    ZCPlatformInfo *info = [[ZCPlatformTools sharedInstance] getPlatformInfo];
    // 没有初始化
    if(sobotIsNull(info.config) || sobotConvertToString(info.config.uid).length == 0){
        return;
    }
    
    // 正在执行转人工
    if(_isTurnLoading){
        return;
    }
    
    // 不直接转人工，等待发送消息
    if([self checkAfterConnectUser:type]){
        return;
    }
    
    if(info.config.isblack){
        // 如果是被拉黑的用户在仅人工的模式直接跳到留言
        if (info.config.type == 2 && info.config.msgFlag == 0) {
            // 留言完直接结束
            if(self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
                [self.delegate onPageStatusChanged:ZCShowStatusLeaveMsgPage message:@"1" obj:nil];
            }
            return;
        }
    }
    
    // 用户拦截转人工，不做其他关键字判断
    if ([ZCLibClient getZCLibClient].turnServiceBlock) {
        [ZCLibClient getZCLibClient].turnServiceBlock(message, ZCTurnType_CellGroupClick);
        return;
    }
    
    // 如果有指定的客服ID 先传客服ID
    if (_kitInfo!= nil && sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.choose_adminid).length>0) {
        
        [self doConnectUserService:message connectType:type];
        return;
    }
    
    
    
    if(_kitInfo!=nil && sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.groupid).length>0){
        // 设置外部技能组
        [self doConnectUserService:message connectType:type];
        return;
    }
    
    // 3.0.5 设置溢出技能组，直接转人工
    if([ZCLibClient getZCLibClient].libInitInfo.transferaction!=nil && [ZCLibClient getZCLibClient].libInitInfo.transferaction.count > 0){
        // 设置溢出技能组
        [self doConnectUserService:message connectType:type];
        return;
    }
    
    // 已经选择了技能组了
    if(_kitInfo!=nil && sobotConvertToString(_checkGroupId).length>0){
        // 设置外部技能组
        [self doConnectUserService:message connectType:type];
        return;
    }
    
    if (self.isShowForm && !isDoConnectedUser) {
        [self doConnectUserService:message connectType:type];
        return;
    }
    
    // 是否开启智能路由 并且不是再次转人工（已经执行过一次智能路由转人工了）
    if ([self getPlatfromInfo].config.smartRouteInfoFlag == 1 && !isDoConnectedUser) {
        [self doConnectUserService:message connectType:type];
        return;
    }
    
    
    //****************** 如果开启了智能路由，不在显示技能组弹框，直接去转人工 ******************
    //判断是否需要显示技能组
    //1、根据初始化信息直接判断，不显示技能组
    if(![self getLibConfig].groupflag){
        [self doConnectUserService:message connectType:type];
        return;
    }
    
    // 加载动画K
    [[SobotToast shareToast] showProgress:@"" with:(UIView *)_delegate];
    
    [ZCLibServer getGroupList:[self getLibConfig] start:^(NSString * _Nonnull url) {
        
    } success:^(NSMutableArray * _Nonnull messages, ZCNetWorkCode code) {
        // 加载动画
        [[SobotToast shareToast] dismisProgress];

        if(code == ZC_NETWORK_SUCCESS){
            // 根据结果判定显示转人工操作
            [self showSkillSetView:messages result:^(int code) {
                if(code == 0){
                    [self doConnectUserService:message connectType:type];
                }
            }];
        }
    } failed:^(NSString * _Nonnull msg, ZCNetWorkCode code) {
        // 加载动画
        [[SobotToast shareToast] dismisProgress];
    }];
}

-(BOOL)checkAfterConnectUser:(ZCTurnType ) type{
    if([self getLibConfig].invalidSessionFlag == 1 && ([self getLibConfig].type == 2||[self getLibConfig].type == 4) && _afterModel==nil){
        _isAfterConnectUser = YES;
        //切换键盘样式
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]) {
            [self.delegate onPageStatusChanged:ZCSetKeyBoardStatus message:@"" obj:@(ZCKeyboardStatusUser)];
        }
        
        // 添加欢迎语
        if([self getLibConfig].type == 4){
            // 添加机器人欢迎语
            [self sendMessageWithConnectStatus:ZCServerConnectRobot];
            
            // 添加自动发送自定义消息，客户单独要求需要每次都发送
            if ([ZCLibClient getZCLibClient].libInitInfo.good_msg_type >0 && sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.content).length > 0) {
                [self checkUserServiceWithType:type model:nil];
            }
        }else{
            if ([[ZCUICore getUICore] getLibConfig].isArtificial) {
                [self sendCusMsg];
            }
        }
        return YES;
    }
    return NO;
}


/**
 判断显示技能组

 @param groupArr 技能组列表
 */
-(void)showSkillSetView:(NSMutableArray *) groupArr  result:(void (^)(int code))doConnectServiceBlock{
    /**
     *  技能组没有数据
     */
    if(groupArr == nil || groupArr.count==0){
        if(doConnectServiceBlock){
            doConnectServiceBlock(0);
        }
        return;
    }
    
    // 计数
    // 2.8.0开始只有0的时候，不弹出技能组，其他情况都弹技能组
    NSInteger flagCount = 0;

    for(ZCLibSkillSet *set in groupArr) {
        if (set.isOnline) {
            flagCount ++;
        }
    }
    // 所有客服都不在线
    if(flagCount==0 ){
        // 仅人工模式，直接留言
        if ([self getLibConfig].msgFlag == 1 && [self getLibConfig].type == 2) {
            // 留言完直接结束
            if(self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
                //  跳转到留言不直接退出SDK
                [self.delegate onPageStatusChanged:ZCShowStatusLeaveMsgPage message:@"1" obj:nil];
            }
        }else{
            // 添加暂无客服在线提醒
            [self keyboardOnClickAddLeavemeg];
        }
        
        [self sendLeaveMessageWithConnectFail];
        return;
    }else{
        // 回收键盘
        if(self.delegate && [_delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
            [self.delegate onPageStatusChanged:ZCShowStatusSatisfaction message:@"" obj:nil];
        }
        
        __weak ZCUICore * safeSelf = self;
        
       _skillSetView  = [[ZCUISkillSetView alloc] initActionSheet:groupArr  withView:(UIView *)_delegate];
        
        [_skillSetView setItemClickBlock:^(ZCLibSkillSet *itemModel) {
            [SobotLog logDebug:@"选择一个技能组"];

            // 点击之后就影藏
            [safeSelf.skillSetView tappedCancel:NO];
            safeSelf.skillSetView = nil;
            
            // 客服不在线且开启了留言开关
            if(!itemModel.isOnline ){
                // 添加暂无客服在线提醒
                [safeSelf keyboardOnClickAddLeavemeg];
                
                
                // 点击技能组弹框上的留言跳转
                if ([safeSelf getLibConfig].msgFlag == 0) {
                    if ([safeSelf getLibConfig].type == 2) {
                        
                        if ([ZCUICore getUICore].delegate  && [[ZCUICore getUICore].delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]) {
                            
                            [[ZCUICore getUICore].delegate onPageStatusChanged:ZCShowStatusLeaveOpenWithClose message:@"1" obj:nil];
                        }

                        return ;
                    }
                    if ([safeSelf getLibConfig].type == 3) {
                        if ([ZCUICore getUICore].delegate  && [[ZCUICore getUICore].delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]) {
                            [[ZCUICore getUICore].delegate onPageStatusChanged:ZCShowStatusLeaveMsgPage message:@"0" obj:nil];
                        }
                        
                        return;
                    }
                    if ([safeSelf getLibConfig].type == 4) {

                        if ([ZCUICore getUICore].delegate  && [[ZCUICore getUICore].delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]) {
                            [[ZCUICore getUICore].delegate onPageStatusChanged:ZCShowStatusLeaveMsgPage message:@"0" obj:nil];
                        }

                        return ;
                    }
                    if ([ZCUICore getUICore].delegate  && [[ZCUICore getUICore].delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]) {
                        
                        [[ZCUICore getUICore].delegate onPageStatusChanged:ZCShowStatusLeaveOpenWithClose message:@"1" obj:nil];
                    }
                }

            }else{
                // 使用 _checkGroupId 替换一下选项,调用接口时会清空
                self->_checkGroupId = itemModel.groupId;
                self->_checkGroupName = itemModel.groupName;
                // 加载动画
                [[SobotToast shareToast] showProgress:@"" with:(UIView *)safeSelf.delegate];

                // 执行转人工
                if(doConnectServiceBlock){
                    doConnectServiceBlock(0);
                }
            }
        }];
        
        __weak  ZCUICore * safeCore = self;
        // 直接关闭技能组
        [_skillSetView setCloseBlock:^{
            // 关闭技能组（取消按钮）选项，如果是仅人工模式和人工优先 退出   // 2.4.2 只有仅人工模式起效
            if([self getPlatfromInfo].config.type == 2){
                // 直接关闭技能组
                if(safeCore.delegate && [safeCore.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
                    [safeCore.delegate onPageStatusChanged:ZCShowStatusCloseSkillSet message:@"" obj:nil];
                }
            }else if([self getPlatfromInfo].config.type == 4){
                // 添加机器人欢迎语
                [safeCore sendMessageWithConnectStatus:ZCServerConnectRobot];
                // 设置机器人的键盘样式
                if (safeCore.delegate && [safeCore.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]) {
                    [safeCore.delegate onPageStatusChanged:ZCSetKeyBoardStatus message:@"" obj:@(ZCKeyboardStatusRobot)];
                }
            }
            
            safeCore.skillSetView = nil;
            
        }];
        
        // 关闭技能组页面 和机器人会话并提示留言
        [_skillSetView closeSkillToRobotBlock:^{
            // 添加暂无客服在线提醒
            [self keyboardOnClickAddLeavemeg];
            safeCore.skillSetView = nil;
        }];
        
        [_skillSetView showInView:(UIView *)_delegate];
    }
}



/**
 隐藏技能组
 */
//-(void)dismissSkillSetView{
//    if(_skillSetView){
//        // 点击之后就影藏
//        [_skillSetView tappedCancel:NO];
//        _skillSetView = nil;
//    }
//}
-(UIView * _Nullable)getGroupView{
    return _skillSetView;
}
-(void)dismissGroupView{
    if(_skillSetView){
        [_skillSetView tappedCancel:YES];
        _skillSetView = nil;
    }
}


/**
 *
 *  转人工不成功，添加提示留言消息
 *
 **/
-(void)keyboardOnClickAddLeavemeg{
    // 设置昵称
    _receivedName = [self getPlatfromInfo].config.robotName;
    
    // 无客服在线
    [self addNoAdminOnlineTips];
    
    // 仅人工，客服不在线直接提示
    if ([self getPlatfromInfo].config.type == 2){
        // 设置昵称
        _receivedName = SobotKitLocalString(@"暂无客服在线");
        if (self.delegate && [self.delegate respondsToSelector:@selector(setTitleName:)]) {
            [self.delegate setTitleName:_receivedName];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]) {
            [self.delegate onPageStatusChanged:ZCSetKeyBoardStatus message:@"" obj:@(ZCKeyboardStatusNewSession)];
        }
        
        return;
    }
    
    // 如果没有机器人欢迎语，添加机器人欢迎语
    if ([self getPlatfromInfo].config.type !=2) {
        [self sendMessageWithConnectStatus:ZCServerConnectRobot];
    }
    
    if ([self getPlatfromInfo].config.type == 4 && ![self getPlatfromInfo].config.isArtificial ) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]) {
            [self.delegate onPageStatusChanged:ZCSetKeyBoardStatus message:@"" obj:@(ZCKeyboardStatusRobot)];
        }
    }
    
    // 设置昵称
    if (self.delegate && [self.delegate respondsToSelector:@selector(setTitleName:)]) {
        [self.delegate setTitleName:_receivedName];
    }
}

-(void)goLeavePage{
    // 留言完直接结束
    if(self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
        [self.delegate onPageStatusChanged:ZCShowStatusLeaveMsgPage message:@"1" obj:nil];
    }
}

// 取消发送文件
-(void)cancelSendFileMsg:(SobotChatMessage *)fileMsg{
    if ([ZCUICore getUICore].chatMessages.count > 0) {

        [[ZCUICore getUICore].chatMessages removeObject:fileMsg];
        [[ZCLibHttpManager getZCHttpManager] cancelConnectMsgId:fileMsg.msgId];
            if (self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]) {
                [self.delegate onPageStatusChanged:ZCShowStatusMessageChanged message:@"" obj:[ZCUICore getUICore].chatMessages];
            }
    }
}

#pragma mark 排队

-(void)continueWaiting:(SobotChatMessage *)tipsModel{
    [ZCLibServer continueWaiting:[self getLibConfig] start:^(NSString *url){
        
    } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
        if(!sobotIsNull(tipsModel)){
            tipsModel.isHistory = YES;
        }
        [[ZCUICore getUICore] removeListModelWithType:SobotMessageTypeTipsText tips:SobotMessageActionTypeChat_WaitingContinueTips];
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]) {
            [self.delegate onPageStatusChanged:ZCShowStatusMessageChanged message:@"" obj:[ZCUICore getUICore].chatMessages];
        }
    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
        
    }];
}


#pragma mark 定时器相关
-(void)startTipTimer{
    if(_tipTimer){
        [_tipTimer invalidate];
        _tipTimer = nil;
    }
    _tipTimer       = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerCount) userInfo:nil repeats:YES];
    
    // 定时器相关
    lowMinTime = 0;
//    userTipTime = 0;
//    adminTipTime = 0;
}
-(void)cleanAdminCount{
//    isUserTipTime  = NO;
//    isAdminTipTime = YES;
//    adminTipTime   = 0;
//    userTipTime    = 0;
}

-(void)cleanUserCount{
//    isUserTipTime  = YES;
//    isAdminTipTime = NO;
//    userTipTime    = 0;
//    adminTipTime   = 0;
}

-(void)pauseCount{
    if(_tipTimer){
        if (_tipTimer && ![_tipTimer isValid]) {
            return ;
        }
        [_tipTimer setFireDate:[NSDate distantFuture]];
    }
}

-(void)pauseToStartCount{
    if(_tipTimer){
        if (_tipTimer && ![_tipTimer isValid]) {
            return ;
        }
        [_tipTimer setFireDate:[NSDate date]];
    }
}

-(void)setInputListener:(UITextView *)textView{
    inputTextView = textView;
}


/**
 *  计数，计算提示信息
 */
-(void)timerCount{
    ZCLibConfig *libConfig = [self getLibConfig];
    
    lowMinTime=lowMinTime+1;
    
    // 间隔指定时间，发送正在输入内容，并且是人工客服时
    if(inputTextView && libConfig.isArtificial){
        inputCount = inputCount + 1;
        
        if(inputCount > 3){
            inputCount = 0;
            // 发送正输入
            NSString *text = inputTextView.text;
            if(![text isEqual:lastMessage]){
                lastMessage = text;
//                [SobotLog logDebug:@"发送正在输入内容...%@",lastMessage];
                if(isInputSending){
                    return;
                }
                isInputSending = YES;
                // 正在输入
                [ZCLibServer sendInputMessage:lastMessage config:libConfig success:^(ZCNetWorkCode code) {
                    self->isInputSending = NO;
                } fail:^(NSString * _Nonnull errorMsg, ZCNetWorkCode code) {
                    self->isInputSending = NO;
                }];
            }
        }
    }
}



/**
 *
 *   处理评价的事件
 *   是否是点击返回触发的评价
 **/
-(BOOL)checkSatisfacetion:(BOOL) isEvalutionAdmin type:(SobotSatisfactionFromSrouce ) type{
    return [self checkSatisfacetion:isEvalutionAdmin type:type rating:0 resolve:-1];
}

#pragma mark - 评价，是否可评价，是否已经评价
-(BOOL)checkSatisfacetion:(BOOL) isEvalutionAdmin type:(SobotSatisfactionFromSrouce ) type rating:(int) rating resolve:(int) resolve{
    //1.只和机器人聊过天 评价机器人
    //2.只和人工聊过天 评价人工
    //3.机器人的评价和人工的评价做区分，互不相干。
    // 是否转接过人工  或者当前是否是人工 （人工的评价逻辑）
    if (self.isOffline || [self getPlatfromInfo].config.isArtificial || type == SobotSatisfactionFromSrouceInvite) {
        //        if(type != SatisfactionTypeInvite){
        // 拉黑不能评价客服添加提示语(只有在评价人工的情景下，并且被拉黑，评价机器人不触发此条件)
        if ([[self getPlatfromInfo].config isblack]) {
            [self addMessageToList:SobotMessageActionTypeTemporarilyUnableToEvaluate content:@"" type:SobotMessageTypeTipsText dict:nil];
            return NO;
        }
        
        // 之前评价过人工，提示已评价过。
        if (self.isEvaluationService && type != SobotSatisfactionFromSrouceInvite) {
            [self addMessageToList:SobotMessageActionTypeEvaluationCompleted content:@"" type:SobotMessageTypeTipsText dict:nil];
            return NO;
        }
        
        if (!_isSendToUser && type != SobotSatisfactionFromSrouceInvite) {
            self.isEvaluationService = NO;
            [self addMessageToList:SobotMessageActionTypeAfterConsultingEvaluation content:@"" type:SobotMessageTypeTipsText dict:nil];
            return NO;
        }
    }else{
        // 之前评价过机器人，提示已评价。（机器人的评价逻辑）
        if (self.isEvaluationRobot) {
            [self addMessageToList:SobotMessageActionTypeEvaluationCompleted content:@"" type:SobotMessageTypeTipsText dict:nil];
            return NO;
        }
        
        if (!_isSendToRobot) {
            self.isEvaluationRobot = NO;
            [self addMessageToList:SobotMessageActionTypeAfterConsultingEvaluation content:@"" type:SobotMessageTypeTipsText dict:nil];
            return NO;
        }
    }
    
    
    SobotSatisfactionParams *inP = [[SobotSatisfactionParams alloc] init];
    inP.rating = rating;
    inP.invateQuestionFlag = resolve;
    inP.fromSource = type;
    inP.showType = isEvalutionAdmin?SobotSatisfactionTypeManual:SobotSatisfactionTypeRobot;
    if(type == SobotSatisfactionFromSrouceInvite){
        inP.rating = rating;
        inP.invateQuestionFlag = resolve;
        inP.uid = [[ZCUICore getUICore] getLibConfig].uid;
    }
    
    if(isEvalutionAdmin){
        inP.serviceName = [self getLibConfig].senderName;
    }else{
        inP.serviceName = [self getLibConfig].robotName;
    }
    SobotSatisfactionView *satisfactionView = [[SobotSatisfactionView alloc] initActionSheetWith:inP config:[[ZCUICore getUICore] getLibConfig] cView:[SobotUITools getCurrentVC].view];
    [satisfactionView showSatisfactionView:nil];
    
    [satisfactionView setOnSatisfactionClickBlock:^(int type, SobotSatisfactionParams * _Nonnull inParams, NSMutableDictionary * _Nullable outParams,id _Nullable result) {
        // 提交成功
        if(type == 1){
            // 评价结束会话
            [self thankFeedBack:inParams];
        }
        
        // 暂不评价
        if(type == -1){
            [self checkSatistionBack:inParams];
        }
        
        // 点击关闭
        if(type == 0){
            // 不做处理，仅隐藏
        }
    }];
    return YES;
}


// 提交评价
- (void)commitSatisfactionWithIsResolved:(int)isResolved Rating:(int)rating problem:(NSString *) problem scoreFlag:(float)scoreFlag {
    if(_isCommentEvaluate){
        return;
    }
    if (isResolved == 2) {
        // 没有选择 按已解决处理
        isResolved = 0;
    }
    //  此处要做是否评价过人工或者是机器人的区分
    if (self.isOffline || [self getLibConfig].isArtificial) {
        // 评价过客服了，下次不能再评价人工了
        self.isEvaluationService = YES;
    }else{
        // 评价过机器人了，下次不能再评价了
        self.isEvaluationRobot = YES;
    }
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
    [dict setObject:sobotConvertToString(problem) forKey:@"problem"];
    [dict setObject:[self getLibConfig].cid forKey:@"cid"];
    [dict setObject:[self getLibConfig].uid forKey:@"userId"];
    
    [dict setValue:[NSString stringWithFormat:@"%d",(int)scoreFlag] forKey:@"scoreFlag"];
    [dict setObject:@"1" forKey:@"type"];
    [dict setObject:[NSString stringWithFormat:@"%d",rating] forKey:@"source"];
    [dict setObject:@"" forKey:@"suggest"];
    [dict setObject:[NSString stringWithFormat:@"%d",isResolved] forKey:@"isresolve"];
    // commentType  评价类型 主动评价 1 邀请评价0
    [dict setObject:@"0" forKey:@"commentType"];
    _isCommentEvaluate = YES;
    [ZCLibServer doComment:dict result:^(ZCNetWorkCode code, int status, NSString *msg) {
        self->_isCommentEvaluate = NO;
        if(code == ZC_NETWORK_SUCCESS){
            
        }
    }];
    
    
    SobotSatisfactionParams *inParam = [[SobotSatisfactionParams alloc] init];
    inParam.fromSource = SobotSatisfactionFromSrouceInvite;
    inParam.showType = SobotSatisfactionTypeManual;
    [self thankFeedBack:inParam];
}


#pragma mark 评价
-(void)thankFeedBack:(SobotSatisfactionParams *)inParams{
    // 评价完回收键盘
    if (self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]) {
        [self.delegate onPageStatusChanged:ZCShowStatusSatisfaction message:@"" obj:nil];
    }
    BOOL isClose = NO;
    if([ZCUICore getUICore].kitInfo.isCloseAfterEvaluation || inParams.fromSource == SobotSatisfactionFromSrouceClose){
        isClose = YES;
    }
    
    if(isClose){
        // 会话已结束，不能再发送消息
        [[ZCUICore getUICore] addMessageToList:SobotMessageActionTypeOverWord content:@"" type:SobotMessageTypeTipsText dict:nil];
        
        // 设置新会话样式
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]) {
            [self.delegate onPageStatusChanged:ZCSetKeyBoardStatus message:@"" obj:@(ZCKeyboardStatusNewSession)];
        }
        
        //这2种情况，直接返回页面
        if(inParams.fromSource != SobotSatisfactionFromSrouceClose && inParams.fromSource != SobotSatisfactionFromSrouceBack){
            [ZCLibClient closeAndoutZCServer:NO];
        }
    }
    
    if(inParams.fromSource != SobotSatisfactionFromSrouceLeave){
        [[SobotToast shareToast] showToast:SobotKitLocalString(@"感谢您的评价!") position:SobotToastPositionCenter Image:SobotKitGetImage(@"zcicon_successful")];
        
        
        // 移除掉评价cell
        [self removeListModelWithType:SobotMessageTypeTipsText tips:SobotMessageActionTypeEvaluation];
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]) {
            [self.delegate onPageStatusChanged:ZCShowStatusMessageChanged message:@"" obj:nil];
        }
    }
   
    [self checkSatistionBack:inParams];
    
    //  此处要做是否评价过人工或者是机器人的区分
    if (inParams.showType == SobotSatisfactionTypeManual) {
        // 评价过客服了，下次不能再评价人工了
        [ZCUICore getUICore].isEvaluationService = YES;
    }else{
        // 评价过机器人了，下次不能再评价了
        [ZCUICore getUICore].isEvaluationRobot = YES;
    }
    [ZCUICore getUICore].unknownWordsCount = 0;
}

-(void)checkSatistionBack:(SobotSatisfactionParams *)inParams{
    BOOL isClose = NO;
    if([ZCUICore getUICore].kitInfo.isCloseAfterEvaluation || inParams.fromSource == SobotSatisfactionFromSrouceClose){
        isClose = YES;
    }
    
    // 点击返回或关闭
    if(inParams.fromSource == SobotSatisfactionFromSrouceClose || inParams.fromSource == SobotSatisfactionFromSrouceBack){
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]) {
            [self.delegate onPageStatusChanged:ZCShowStatusGoBack message:@"" obj:@{@"isFinish":@(YES),@"isClose":@(isClose)}];
        }
    }
}
#pragma mark 评价代理结束end

#define VoiceLocalPath sobotGetDocumentsFilePath(@"/sobot/")
// 清理数据
-(void)destoryViewsData{
    _isOffline = NO;
//    _isShowForm = NO;
//    _isShowRobotHello = NO;
//    isShowAdminHello = NO;
    _satisfactionConfig = nil;
    _isOfflineBeBlack = NO;
    if(_tipTimer){
        [_tipTimer invalidate];
    }
    
    // 清理本地存储文件
    dispatch_async(dispatch_queue_create("com.sobot.cache", DISPATCH_QUEUE_SERIAL), ^{
        NSFileManager *_fileManager = [NSFileManager new];
        NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtPath:VoiceLocalPath];
        
        
        for (NSString *fileName in fileEnumerator) {
            NSString *filePath = [VoiceLocalPath stringByAppendingPathComponent:fileName];
            // 未过期，添加到排序列表
            if(![ZCUIKitTools videoIsValid:filePath]){
                // 过期，直接删除
                [_fileManager removeItemAtPath:filePath error:nil];
            }
        }
    });
}

-(void)openLeaveOrRecoredVC:(int) isRecord dict:(NSDictionary *) Dict{
    // 拦截留言点击事件
    if ( [[ZCUICore getUICore] CustomLeavePageBlock] != nil) {
        [ZCUICore getUICore].CustomLeavePageBlock(@{@"msgLeaveTxt":sobotConvertToString([self getLibConfig].msgLeaveTxt)});
        return;
    }
    
    if ([ZCUICore getUICore].PageLoadBlock) {
//        [ZCUICore getUICore].PageLoadBlock(nil, ZCPageStateTypeLeave);
        [ZCUICore getUICore].PageLoadBlock(@"", ZCPageStateTypeLeave);
    }

    //先判定 留言的方式 转离线留言
    if ([self getLibConfig].msgToTicketFlag == 2) {
        // 4.0.4版本解除以下限制，并且留言完结束会话
        // 2.8.9版本添加人工状态不支持留言转离线消息
//        if([self getLibConfig].isArtificial){
//            return;
//        }
        
        NSString *groupId = [self getPlatfromInfo].groupId;
        NSString *uid = [[ZCUICore getUICore] getLibConfig].uid;
        
        [ZCLibServer initLeaveMsgConfig:groupId uid:uid error:^(ZCNetWorkCode status, NSString *errorMessage) {
            [[SobotToast shareToast] showToast:errorMessage duration:2.0f position:SobotToastPositionCenter];
        } success:^(NSString *msgLeaveTxt, NSString *msgLeaveContentTxt,NSString *leaveExplain) {
            ZCLeaveMsgVC *vc = [[ZCLeaveMsgVC alloc]init];
            vc.msgTxt = msgLeaveTxt;
            vc.msgTmp = msgLeaveContentTxt;
            vc.groupId = [self getPlatfromInfo].groupId;
            vc.leaveExplain = leaveExplain;
            vc.passMsgBlock = ^(NSString *msg) {
                // 发送离线消息 （只是本地数据的展示，不可发给机器人或者人工客服）
                  SobotChatMessage *message = [ZCPlatformTools createLocalMessage:YES messageType:SobotMessageTypeText richType:0 action:SobotMessageActionTypeOrderLeave message:@{@"content":sobotConvertToString(msg)} robot:NO config:[self getLibConfig]];
                  message.leaveMsgFlag = 1;
                  [self addMessage:message reload:YES];
                  SobotChatMessage *tipMsg2 = [ZCPlatformTools createLocalMessage:NO messageType:SobotMessageTypeTipsText richType:0 action:SobotMessageActionTypeChatCloseByLeaveMsg message:@{@"content":SobotKitLocalString(@"您的留言已经提交成功，此会话已结束，如需继续咨询可点击下方 重建会话 按钮。")} robot:NO config:[self getLibConfig]];
                  [self addMessage:tipMsg2 reload:YES];
                
                // 4.0.4 新增如果是人工，留言完结束会话
                if([self getLibConfig].isArtificial){
                    [ZCLibClient closeAndoutZCServer:NO];
                }
                if(self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
                    [self.delegate onPageStatusChanged:ZCShowStatusReConnected message:nil obj:nil];
                }
            };
        
            // 仅人工模式，直接留言
            if ([self getLibConfig].msgFlag == 1 && [self getLibConfig].type == 2 && Dict) {
                NSString *msg = sobotConvertToString(Dict[@"msg"]);
                [[SobotToast shareToast] showToast:msg duration:3.0f position:SobotToastPositionCenter];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                        [[SobotUITools getCurrentVC].navigationController pushViewController:vc animated:YES];
                });
            }else{
                [[SobotUITools getCurrentVC].navigationController pushViewController:vc animated:YES];

            }
        }];
        return;
    }
    
    // 弹提示
    BOOL isShowLoading = YES;
    if ([self getLibConfig].msgFlag == 0  && Dict) {
        NSString *msg = sobotConvertToString(Dict[@"msg"]);
        if(msg.length >0){
            [[SobotToast shareToast] showToast:msg duration:3.0f position:SobotToastPositionCenter];
            isShowLoading = NO;
        }
    }
    
    if (isRecord) {
        // 直接跳转到留言记录的页面 默认选中 模版1
        [[ZCUICore getUICore] jumpNewPageVC:0 isShowToat:NO tipMsg:@"" Dict:Dict isRecord:isRecord];
        return;
    }
    if(isShowLoading){
        [[SobotToast shareToast] showProgress:@"" with:(UIView*)_delegate];
    }
    // 留言转工单 先查看工单列表模板
    [ZCLibServer getWsTemplateList:[self getLibConfig] uid:[[ZCUICore getUICore] getTempUid] groupId:[[ZCUICore getUICore] getTempGroupId] start:^{
    } success:^(NSDictionary * _Nonnull dict, NSMutableArray * _Nonnull typeArr, ZCNetWorkCode sendCode) {
        if(isShowLoading){
            [[SobotToast shareToast] dismisProgress];
        }
        [SobotLog logHeader:SobotLogHeader info:@"留言模板%@", dict];
        if (dict != nil && [sobotConvertToString(dict[@"code"]) intValue] == 1) {
            NSArray * arr = dict[@"data"];
            if (arr.count > 0) {
                NSMutableArray * array = [NSMutableArray arrayWithCapacity:0];
                for (NSDictionary * item in arr) {
                    ZCWsTemplateModel * model = [[ZCWsTemplateModel alloc]initWithMyDict:item];
                    [array addObject:model];
                }
                if (arr.count == 1) {
                    ZCWsTemplateModel * model = [array lastObject];
                    NSDictionary * Dic = @{@"templateId":sobotConvertToString(model.templateId),
                                           @"msg":sobotConvertToString([Dict objectForKey:@"msg"]),
                                           @"selectedType":sobotConvertToString([Dict objectForKey:@"selectedType"])
                    };
                    // 1个直接跳转
                    [[ZCUICore getUICore] jumpNewPageVC:0 isShowToat:NO tipMsg:@"" Dict:Dic isRecord:isRecord];
                }else{
                    // 2.掉接口 布局UI
                    ZCSelLeaveView * selMsgView = [[ZCSelLeaveView alloc]initActionSheet:array  WithView:[UIView new] MsgID:[self getLibConfig].robotFlag IsExist:0];
//                    if (isShow) {
//                        [[SobotToast shareToast] showToast:msg duration:2.0f view:self position:SobotToastPositionCenter];
//                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                            [selMsgView showInView:self];
//                        });
//                    }else{
                        [selMsgView showInView:[UIView new]];
//                    }
                    selMsgView.msgSetClickBlock = ^(ZCWsTemplateModel * _Nonnull itemModel) {
                        NSDictionary * Dic = @{@"templateId":sobotConvertToString(itemModel.templateId),
                                               @"msg":sobotConvertToString([Dict objectForKey:@"msg"]),
                                               @"selectedType":sobotConvertToString([Dict objectForKey:@"selectedType"])};
                        [[ZCUICore getUICore] jumpNewPageVC:0 isShowToat:NO tipMsg:@"" Dict:Dic isRecord:isRecord];
                    };
                }
            }else{
                [[ZCUICore getUICore] jumpNewPageVC:0 isShowToat:NO tipMsg:@"" Dict:Dict isRecord:isRecord];
            }
         }
    } fail:^(NSString * _Nonnull errorMsg, ZCNetWorkCode errorCode) {
        if(isShowLoading){
            [[SobotToast shareToast] dismisProgress];
        }
        [[SobotToast shareToast] showToast:SobotLocalString(@"网络错误，请检查网络后重试") duration:1.0f position:SobotToastPositionCenter];
    }];

}

#pragma mark - 跳转到留言的时候先处理 留言模版
-(void)jumpNewPageVC:(int)isExist isShowToat:(BOOL)isShow tipMsg:(NSString *)msg Dict:(NSDictionary *)dict isRecord:(BOOL)isRecord{
    // 测试留言页面 TODO
    __block ZCLeaveMsgController *leaveVC = [[ZCLeaveMsgController alloc]init];
    if(isRecord){
        NSString * code = @"1";
        NSString * templateId = @"1";
        if (dict != nil) {
            leaveVC.templateldIdDic = dict;
            if ([[dict allKeys] containsObject:@"selectedType"]) {
                code = [dict valueForKey:@"selectedType"];
            }
            if ([code intValue] ==2) {
                    // 删除掉这条消息
                    int index = -1;
                    if([ZCUICore getUICore].chatMessages!=nil && [ZCUICore getUICore].chatMessages.count>0){
                        for (int i = 0; i< [ZCUICore getUICore].chatMessages.count; i++) {
                            SobotChatMessage *libMassage = [ZCUICore getUICore].chatMessages[i];
                            // 删除上一次商品信息
                            if(libMassage.msgType == SobotMessageTypeTipsText && [libMassage.tipsMessage isEqualToString:[NSString stringWithFormat:@"%@ %@",SobotKitLocalString(@"您的留言状态有"),SobotKitLocalString(@"更新")]]){
                                index = i;
                                break;
                            }
                        }
                        if(index >= 0){
                            [[ZCUICore getUICore].chatMessages removeObjectAtIndex:index];
                            [self.delegate onPageStatusChanged:ZCShowStatusMessageChanged message:@"" obj:nil];
                        }
                    }
                // 直接跳转到 留言记录、
                leaveVC.selectedType = 2;
                leaveVC.ticketShowFlag  = 0;
                [[SobotUITools getCurrentVC].navigationController pushViewController:leaveVC animated:YES];
                return;
            }
            if ([[dict allKeys] containsObject:@"templateId"]) {
                templateId = [dict valueForKey:@"templateId"];
            }
            leaveVC.selectedType = [code intValue];
        }
        [[SobotToast shareToast] showProgress:@"" with:[SobotUITools getCurrentVC].view];
    }
    leaveVC.ticketShowFlag = 1;
//    leaveVC.isExitSDK = (isExist==1 || isExist==3)?YES:NO;
    if(dict && dict[@"msg"]){
        leaveVC.isShowToat = YES;
        leaveVC.tipMsg = sobotConvertToString(dict[@"msg"]);
    }
    static BOOL isJump = NO;
     // 线程处理
     dispatch_group_t group = dispatch_group_create();
     dispatch_group_enter(group);
     // 加载基础模板接口
    NSString *templateId = @"1";
    if (sobotConvertToString([dict objectForKey:@"templateId"]).length > 0) {
        templateId = sobotConvertToString([dict objectForKey:@"templateId"]);
    }
    if (dict != nil) {
        leaveVC.templateldIdDic = dict;
    }
    
     [ZCLibServer postMsgTemplateConfigWithUid:[[ZCUICore getUICore] getLibConfig].uid Templateld:templateId start:^{
         
     } success:^(NSDictionary *dict,NSMutableArray * typeArr, ZCNetWorkCode sendCode) {
         leaveVC.tickeTypeFlag = [ sobotConvertToString(dict[@"data"][@"item"][@"ticketTypeFlag"] )intValue];
         leaveVC.ticketTypeId = sobotConvertToString( dict[@"data"][@"item"][@"ticketTypeId"]);
         leaveVC.telFlag = [sobotConvertToString( dict[@"data"][@"item"][@"telFlag"]) boolValue];
         leaveVC.telShowFlag = [sobotConvertToString(dict[@"data"][@"item"][@"telShowFlag"]) boolValue];
         leaveVC.emailFlag = [sobotConvertToString(dict[@"data"][@"item"][@"emailFlag"]) boolValue];
         leaveVC.emailShowFlag = [sobotConvertToString(dict[@"data"][@"item"][@"emailShowFlag"]) boolValue];
         leaveVC.enclosureFlag = [sobotConvertToString(dict[@"data"][@"item"][@"enclosureFlag"]) boolValue];
         leaveVC.enclosureShowFlag = [sobotConvertToString(dict[@"data"][@"item"][@"enclosureShowFlag"]) boolValue];
         leaveVC.ticketTitleShowFlag = [sobotConvertToString(dict[@"data"][@"item"][@"ticketTitleShowFlag"]) boolValue];
         leaveVC.msgTmp = sobotConvertToString(dict[@"data"][@"item"][@"msgTmp"]);
         leaveVC.msgTxt = sobotConvertToString(dict[@"data"][@"item"][@"msgTxt"]);
        
         if (typeArr.count) {
             if (leaveVC.typeArr == nil) {
                 leaveVC.typeArr = [NSMutableArray arrayWithCapacity:0];
                 leaveVC.typeArr = typeArr;
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
             [[SobotToast shareToast] showToast:SobotLocalString(@"网络错误，请检查网络后重试") duration:1.0f position:SobotToastPositionCenter];
         });
         dispatch_group_leave(group);
     }];
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [[SobotToast shareToast] dismisProgress];
        if (isJump) {
            [[SobotUITools getCurrentVC].navigationController pushViewController:leaveVC animated:YES];
        }
    });
}

-(NSString *)getTempUid{
    return tempUid;
}

#pragma mark -- 临时保存技能组ID
-(void)saveGroupIdWith:(NSString*)groupId{
    NSUserDefaults *userDefatluts = [NSUserDefaults standardUserDefaults];
    NSDictionary *dictionary = [userDefatluts dictionaryRepresentation];
    for(NSString* key in [dictionary allKeys]){
        if([key hasPrefix:@"sobot_temp_groupid"]){
            [userDefatluts removeObjectForKey:key];
            [userDefatluts synchronize];
        }
    }
    [userDefatluts setObject:sobotConvertToString(groupId) forKey:@"sobot_temp_groupid"];
}

#pragma mark -- 获取临时保存的技能组ID
-(NSString*)getTempGroupId{
    NSUserDefaults *userDefatluts = [NSUserDefaults standardUserDefaults];
    return sobotConvertToString([userDefatluts objectForKey:[NSString stringWithFormat:@"sobot_temp_groupid"]]);
}

#pragma mark - 导航栏上面的评价按钮触发评价事件
-(void)keyboardOnClickSatisfacetion:(BOOL)isBcak{
    BOOL isUser = NO;
    if (self.isSendToUser) {
        isUser = YES;
    }
    BOOL isRobot = NO;
    if (self.isSendToRobot) {
        isRobot = YES;
    }
    [SobotLog logDebug:@"当前发送状态：%d,%d",isUser,isRobot];
    if(isUser){
        [[ZCUICore getUICore] checkSatisfacetion:YES type:SobotSatisfactionFromSrouceAdd rating:0 resolve:-1];
    }else {
        [[ZCUICore getUICore] checkSatisfacetion:NO type:SobotSatisfactionFromSrouceAdd rating:0 resolve:-1];
    }
}

-(void)showDetailViewWiht:(SobotChatMessage *)model{
//    if(self.detailView){
//        [self.detailView closeSheetView];
//    }
//    self.detailView = [[ZCChatDetailView alloc]initChatDetailViewWithModel:model withView:nil];
//    [_detailView showInView:nil];
    
    if(self.showDetailView){
        [self.showDetailView dismissView];
    }
    self.showDetailView = [[ZCChatShowDetailView alloc] initChatDetailViewWithModel:model obj:nil];
//    [self.showDetailView showInView:nil];
    
}


-(void)doReferenceMessage:(SobotChatMessage *)model{
    if(self.delegate && [self.delegate respondsToSelector:@selector(onPageStatusChanged:message:obj:)]){
        [self.delegate onPageStatusChanged:ZCShowStatusShowReferenceMessage message:nil obj:model];
    }
}

//-(void)updateChatDetailView:(CGFloat)y{
//    if(self.detailView){
//        [self.detailView updateChangeFrame:y];
//    }
//}
@end
