//
//  ZCFastMenuView.m
//  SobotKit
//
//  Created by zhangxy on 2022/9/20.
//

#import "ZCFastMenuView.h"
#import <SobotCommon/SobotCommon.h>
#import "ZCUIKitTools.h"
#import "ZCLibCusMenu.h"
#import "ZCUICore.h"
#import <SobotChatClient/SobotChatClient.h>

@interface ZCFastMenuView(){

}

@property(nonatomic,strong)UIScrollView * scrollView;
@property(nonatomic,strong)NSLayoutConstraint *layoutHeight;

@property(nonatomic,strong)NSMutableArray * listArray;
@property(nonatomic,assign)BOOL isloading;// 正在加载
@property(nonatomic,copy)NSString *tempOpportunity;// 临时记录上一次请求的数据
@end

@implementation ZCFastMenuView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithSuperView:(UIView *) view{
    self = [super init];
    if (self) {
        [view addSubview:self];
        _listArray = [[NSMutableArray alloc] init];
        
        self.backgroundColor = UIColor.clearColor;
        [view addConstraint:sobotLayoutPaddingLeft(0, self, view)];
        [view addConstraint:sobotLayoutPaddingRight(0, self, view)];
        [self createSubviews];
    }
    return self;
}

-(void)createSubviews{
    
    _scrollView = [[UIScrollView alloc]init];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.bounces = NO;
    _scrollView.scrollEnabled = YES;
//    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _scrollView.backgroundColor = [ZCUIKitTools zcgetChatBackgroundColor];
    [self addSubview:_scrollView];
    
    _layoutHeight = sobotLayoutEqualHeight(0, _scrollView, NSLayoutRelationEqual);
    [self addConstraint:_layoutHeight];
    [self addConstraint:sobotLayoutPaddingLeft(10, _scrollView, self)];
    [self addConstraint:sobotLayoutPaddingRight(-10, _scrollView, self)];
    [self addConstraint:sobotLayoutPaddingTop(0, _scrollView, self)];
    [self addConstraint:sobotLayoutPaddingBottom(0, _scrollView, self)];
    
    
}
-(ZCLibConfig *) getZCIMConfig{
    return [[ZCPlatformTools sharedInstance] getPlatformInfo].config;
}

-(void)refreshData{
    [_listArray removeAllObjects];
    // 添加一个转人工  仅人工模式也不显示转人工按钮
    if(![self getZCIMConfig].isArtificial && [self getZCIMConfig].type != 1 && [self getZCIMConfig].type != 2 ){
        BOOL isShowManualBtn = NO;
        // 自己配置不显示转人工
        if(![ZCUICore getUICore].kitInfo.isShowTansfer && ![ZCLibClient getZCLibClient].isShowTurnBtn){
            // 不显示转人工按钮
        }else if([ZCLibClient getZCLibClient].isShowTurnBtn){
            // 自己配置或后端接口配置触发了显示转人工按钮
            isShowManualBtn = YES;
        }else if([self getZCIMConfig].showTurnManualBtn && ![self getZCIMConfig].isManualBtnFlag){
            // 自己配置长显,并且未开启
            isShowManualBtn = YES;
        }
        
        if(isShowManualBtn){
            ZCLibCusMenu * model = [[ZCLibCusMenu alloc]initWithMyDict:@{@"menuType":@"1",@"imgName":@"icon_fast_transfer",@"menuName":SobotKitLocalString(@"转人工")}];
            [_listArray addObject:model];
            [self showViews]; // 先将转人工的按钮显示
        }
    }
   
    // 加载快捷入口标签
//    if ([self getZCIMConfig].quickEntryFlag == 1) {
        NSString *opportunity = @"";
        if(!sobotIsNull([self getZCIMConfig].menuSessionPhase) && [self getZCIMConfig].menuSessionPhase.count > 0){
            if([self getZCIMConfig].isArtificial && [[self getZCIMConfig].menuSessionPhase containsObject:@2]){
                opportunity = @"2";
            }else if(![self getZCIMConfig].isArtificial && [[self getZCIMConfig].menuSessionPhase containsObject:@1]){
                opportunity = @"1";
            }else{
                opportunity = @"0";
            }
        }
        
        if(opportunity.length >0){
            // 防止相同的数据多次联系请求
            if(self.isloading && [self.tempOpportunity isEqualToString:opportunity]){
                return;
            }
            __weak ZCFastMenuView *safeView = self;
            self.isloading = YES;
            self.tempOpportunity = opportunity;
            [ZCLibServer getLableInfoList:[self getZCIMConfig] opportunity:opportunity start:^(NSString * _Nonnull url) {
            } success:^(NSDictionary *dict, ZCMessageSendCode sendCode) {
                safeView.isloading = NO;
                @try{
                    if (dict) {
                        NSArray * listArr ;
                        if([dict[@"data"] isKindOfClass:[NSDictionary class]] && !sobotIsNull(dict[@"data"])){
                            if([[dict[@"data"] allKeys] containsObject:@"menuConfigRespVos"]){
                                listArr =  dict[@"data"][@"menuConfigRespVos"];
                            }
                        }
                        if (!sobotIsNull(listArr) && [listArr isKindOfClass:[NSArray class]] && listArr.count > 0) {
                            for (NSDictionary *Dic in listArr) {
                                ZCLibCusMenu * model = [[ZCLibCusMenu alloc]initWithMyDict:Dic];
                                [self->_listArray addObject:model];
                            }
                        }else{
                            if ([ZCUICore getUICore].kitInfo.cusMenuArray.count > 0 ) {
                                for (NSDictionary * Dic in [ZCUICore getUICore].kitInfo.cusMenuArray) {
                                    ZCLibCusMenu * model = [[ZCLibCusMenu alloc]initWithMyDict:Dic];
                                    [self->_listArray addObject:model];
                                }
                            }else{
                                [self getZCIMConfig].quickEntryFlag = 0;
                                [self showViews];
                                return ;
                            }
                        }
                    }
                    [self showViews];
                } @catch (NSException *exception) {
                    
                } @finally {
                    
                }
            } fail:^(NSString *errorMsg, ZCMessageSendCode errorCode) {
                [self showViews];
                safeView.isloading = NO;
            }];
        }else{
            [self showViews];
        }
//    }else{
//        [self showViews];
//    }
}

// 新会话键盘显示的时候清理掉数据
-(void)clearDataUpdateUIForNewSession{
    [_listArray removeAllObjects];
    _layoutHeight.constant = 0;
    [self layoutIfNeeded];
}

-(void)showViews{
    if ([ZCUICore getUICore].kitInfo.cusMenuArray.count > 0 ) {
        for (NSDictionary * Dic in [ZCUICore getUICore].kitInfo.cusMenuArray) {
            ZCLibCusMenu * model = [[ZCLibCusMenu alloc]initWithMyDict:Dic];
            model.menuName = model.title;
            model.labelLink = model.url;
            model.menuType = ZCCusMenuTypeOpenUrl;
            [self->_listArray addObject:model];
            [self->_listArray addObject:model];
        }
    }
    
    if(_listArray.count == 0){
        _layoutHeight.constant = 0;
        [self layoutIfNeeded];
        return;
    }else{
        _layoutHeight.constant = 50;
        [self layoutIfNeeded];
        [_scrollView.subviews  makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    
    UIButton *preButton;
    for (int i = 0; i< _listArray.count; i++) {
        UIButton * itemBtn = [self addItemView:_listArray[i]];
        [_scrollView addSubview:itemBtn];
        [_scrollView addConstraint:sobotLayoutEqualHeight(30, itemBtn, NSLayoutRelationEqual)];
        [_scrollView addConstraint:sobotLayoutEqualCenterY(0, itemBtn, _scrollView)];
        if(i==0){
            [_scrollView addConstraint:sobotLayoutPaddingLeft(10, itemBtn, _scrollView)];
        }else{
            [_scrollView addConstraint:sobotLayoutMarginLeft(10, itemBtn, preButton)];
        }
        [itemBtn layoutIfNeeded];
        preButton = itemBtn;
        
        itemBtn.userInteractionEnabled = YES;
        itemBtn.tag = i;
        [itemBtn addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
        itemBtn.layer.borderWidth = 1;
//        itemBtn.layer.borderColor = UIColorFromRGB(TextUnPlaceHolderColor).CGColor;
        
    }
    if(preButton){
        [preButton layoutIfNeeded];
        [_scrollView addConstraint:sobotLayoutPaddingRight(-10, preButton, _scrollView)];
    }
    // 刷新高度，列表的内容偏移量也需要刷新
    if (_fastMenuRefreshDataBlock) {
        _fastMenuRefreshDataBlock(_layoutHeight.constant);
    }
}

-(void)itemClick:(UIButton *)sender{
//    UIButton * btn = (UIButton*)sender;
//    NSLog(@"%@",btn.titleLabel.text);
    if(_listArray.count == 0 || _listArray == nil){
        // 解决多次点击转人工按钮异常问题处理
        return;
    }
    ZCLibCusMenu *menu = _listArray[sender.tag];
    if(sobotConvertToString(menu.menuid).length > 0){
        [ZCLibServer uploadLableInfoClick:[self getZCIMConfig] menuId:sobotConvertToString(menu.menuid) start:^(NSString * _Nonnull url) {
            
        } success:^(NSDictionary * _Nonnull dict, ZCMessageSendCode sendCode) {
            
        } fail:^(NSString * _Nonnull errorMsg, ZCMessageSendCode errorCode) {
            
        }];
    }
    if (_fastMenuBlock) {
        _fastMenuBlock(menu);
    }
}

-(UIButton*)addItemView:(ZCLibCusMenu *)model{
    UIButton *itemView = [[UIButton alloc] init];
    [_scrollView addSubview:itemView];
    itemView.titleLabel.numberOfLines = 1;
    itemView.titleLabel.font = SobotFont12;
//    NSLog(@"%@",model.title);
    [itemView setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];;
    [itemView setContentEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
    [itemView setImage:SobotKitGetImage(model.imgName) forState:0];
    if(sobotConvertToString(model.imgName).length > 0){
        
        [itemView setTitle:[NSString stringWithFormat:@"  %@", SobotKitLocalString(sobotConvertToString(model.menuName))] forState:UIControlStateNormal];
    }else{
        
        [itemView setTitle:SobotKitLocalString(sobotConvertToString(model.menuName)) forState:UIControlStateNormal];
    }
//    [itemView setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
//    [itemView setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    itemView.titleLabel.textAlignment = NSTextAlignmentCenter;
    [itemView setBackgroundColor:UIColor.clearColor];
    [itemView setTitleColor:UIColorFromModeColor(SobotColorTextMain) forState:UIControlStateNormal];
    [itemView setTitleColor:UIColorFromModeColor(SobotColorTextMain) forState:UIControlStateHighlighted];
    itemView.titleLabel.lineBreakMode = NSLineBreakByClipping;



    itemView.layer.masksToBounds = YES;
    itemView.layer.cornerRadius = 15.0f;
    itemView.layer.borderWidth = 1;
    itemView.layer.borderColor = [ZCUIKitTools zcgetCommentButtonLineColor].CGColor;
    [itemView sizeToFit];
    return itemView;
}

@end
