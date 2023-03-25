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
    // 添加一个转人工
    if(![self getZCIMConfig].isArtificial && [self getZCIMConfig].type != 1){
        ZCLibCusMenu * model = [[ZCLibCusMenu alloc]initWithMyDict:@{@"menuType":@"1",@"imgName":@"icon_fast_transfer",@"menuName":SobotKitLocalString(@"转人工")}];
        [_listArray addObject:model];
        [self showViews]; // 先将转人工的按钮显示
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
            [ZCLibServer getLableInfoList:[self getZCIMConfig] opportunity:opportunity start:^(NSString * _Nonnull url) {
            } success:^(NSDictionary *dict, ZCMessageSendCode sendCode) {
                @try{
                    if (dict) {
                        NSArray * listArr = dict[@"data"][@"menuConfigRespVos"];
                        if (listArr.count > 0) {
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
            }];
        }else{
            [self showViews];
        }
//    }else{
//        [self showViews];
//    }
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
}

-(void)itemClick:(UIButton *)sender{
//    UIButton * btn = (UIButton*)sender;
//    NSLog(@"%@",btn.titleLabel.text);
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
