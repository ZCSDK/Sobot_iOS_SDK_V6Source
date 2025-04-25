//
//  SobotFastMenuView.m
//  SobotKit
//
//  Created by zhangxy on 2024/8/6.
//

#import "SobotFastMenuView.h"
#import <SobotCommon/SobotCommon.h>
#import "ZCUIKitTools.h"
#import "ZCLibCusMenu.h"
#import "ZCUICore.h"
#import <SobotChatClient/SobotChatClient.h>

@interface SobotFastMenuView(){

}

@property(nonatomic,strong)UIScrollView * scrollView;
@property(nonatomic,strong)NSLayoutConstraint *layoutHeight;


@property(nonatomic,strong)NSDictionary *robotDict;
@property(nonatomic,strong)NSDictionary *manualDict;

@property(nonatomic,strong)NSMutableArray * listArray;
@property(nonatomic,assign)BOOL isloading;// 正在加载

// 0,进入会话（不会使用，默认合并到机器人和人工中），1机器人会话，2人工
@property(nonatomic,assign)int opportunity;
// 上一次展示的列表，如果不相同则说明切了
@property(nonatomic,assign)int lastOpportunity;

// 当前显示的方案planId
@property(nonatomic,strong)NSString *tempSchemeId;

@end

@implementation SobotFastMenuView

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
        self.opportunity = -1;
        self.lastOpportunity = -1;
        
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


-(void)addTriggerCount{
    // 两次不相同，则添加统计
    if(self.opportunity >= 0 && self.opportunity!=self.lastOpportunity && sobotConvertToString(self.tempSchemeId).length > 0){
        self.lastOpportunity = self.opportunity;
        
        [ZCLibServer addLabelShowTriggerCount:[self getZCIMConfig] menuPlanId:sobotConvertToString(self.tempSchemeId) start:^(NSString * _Nonnull url) {
            
        } success:^(NSDictionary * _Nonnull dict, ZCMessageSendCode sendCode) {
            
        } fail:^(NSString * _Nonnull errorMsg, ZCMessageSendCode errorCode) {
            
        }];
    }
}

-(void)refreshData{
    [self refreshData:NO];
}

-(void)refreshData:(BOOL) reLoadData{
    // 如果已经查询过接口，则不在重新查询
    if(self.opportunity >= 0 && !reLoadData){
        // 接口已经加载过了，直接重新获取数据
        [self changeShowList];
        
        [self showViews];
        return;
    }
    
    if(self.isloading){
        return;
    }
    __weak SobotFastMenuView *safeView = self;
    self.isloading = YES;
    [ZCLibServer getLabelInfoListNew:[self getZCIMConfig] start:^(NSString * _Nonnull url) {
    } success:^(NSDictionary *dict, ZCMessageSendCode sendCode) {
        safeView.isloading = NO;
        @try{
            // 还原重新赋值
            self.opportunity = -1;
            self.lastOpportunity = -1;
            self.robotDict = nil;
            self.manualDict = nil;
            if (dict) {
                if(!sobotIsNull(dict[@"data"]) && [dict[@"data"] isKindOfClass:[NSArray class]]){
                    for(NSDictionary *item in dict[@"data"]){
                        if(!sobotIsNull(item) && [item isKindOfClass:[NSDictionary class]]){
                            if([sobotConvertToString(item[@"opportunity"]) intValue] == 1){
                                self.robotDict = item;
                            }else if([sobotConvertToString(item[@"opportunity"]) intValue] == 2){
                                self.manualDict = item;
                            }
                        }
                        
                    }
                }
            }
            [self changeShowList];
            [self showViews];
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    } fail:^(NSString *errorMsg, ZCMessageSendCode errorCode) {
        [self changeShowList];
        [self showViews];
        safeView.isloading = NO;
    }];
}



// 新会话键盘显示的时候清理掉数据
-(void)clearDataUpdateUIForNewSession{
    // 新会话键盘弹出时，回执默认参数
    self.opportunity = -1;
    self.lastOpportunity = -1;
    [_listArray removeAllObjects];
    _layoutHeight.constant = 0;
    [self layoutIfNeeded];
}

// 切换当前显示列表数据
-(void)changeShowList{
    [_listArray removeAllObjects];
    // 添加一个转人工  仅人工模式也不显示转人工按钮
    if(![self getZCIMConfig].isArtificial && [self getZCIMConfig].type != 1 && [self getZCIMConfig].type != 2 && [self getZCIMConfig].type != 4 ){
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
    
    
    NSDictionary *tempList = nil;
    if([self getZCIMConfig].isArtificial){
        if(self.manualDict!=nil){
            tempList = self.manualDict;
            self.opportunity = 2;
            self.tempSchemeId = sobotConvertToString(self.manualDict[@"id"]);
        }
    }else{
        if(self.robotDict!=nil){
            tempList = self.robotDict;
            self.opportunity = 1;
            self.tempSchemeId = sobotConvertToString(self.robotDict[@"id"]);
        }
    }
    
    if(tempList != nil){
        NSArray *listArr =  tempList[@"menuConfigRespVos"];
        for (NSDictionary *Dic in listArr) {
            ZCLibCusMenu * model = [[ZCLibCusMenu alloc]initWithMyDict:Dic];
            [self->_listArray addObject:model];
        }
    }else{
        if ([ZCUICore getUICore].kitInfo.cusMenuArray.count > 0 ) {
            for (id dic in [ZCUICore getUICore].kitInfo.cusMenuArray) {
                ZCLibCusMenu * model = nil;
                if([dic isKindOfClass:[ZCLibCusMenu class]]){
                    model = dic;
                }else if([dic isKindOfClass:[NSDictionary class]]){
                    model = [[ZCLibCusMenu alloc]initWithMyDict:dic];
                    model.menuName = model.title;
                    model.labelLink = model.url;
                    model.menuType = ZCCusMenuTypeOpenUrl;
                }
                if(model!=nil){
                    [self->_listArray addObject:model];
                }
            }
        }
    }
}
-(void)showViews{
    // 显示时，判断是否切换过
    [self addTriggerCount];
    
    if(_listArray.count == 0){
        _layoutHeight.constant = 0;
        [self layoutIfNeeded];
        return;
    }else{
        _layoutHeight.constant = 50;
        [self layoutIfNeeded];
        [_scrollView.subviews  makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    
    UIView *preButton;
    for (int i = 0; i< _listArray.count; i++) {
        UIView * itemBtn = [self addItemIconView:_listArray[i]];
        [_scrollView addSubview:itemBtn];
        [_scrollView addConstraint:sobotLayoutEqualHeight(30, itemBtn, NSLayoutRelationEqual)];
        [_scrollView addConstraint:sobotLayoutEqualCenterY(0, itemBtn, _scrollView)];
        if(i==0){
//            if ([ZCUIKitTools getSobotIsRTLLayout]) {
//                [_scrollView addConstraint:sobotLayoutPaddingRight(-10, itemBtn, _scrollView)];
//            }else{
                [_scrollView addConstraint:sobotLayoutPaddingLeft(10, itemBtn, _scrollView)];
//            }
        }else{
//            if ([ZCUIKitTools getSobotIsRTLLayout]) {
//                [_scrollView addConstraint:sobotLayoutMarginRight(-10, itemBtn, preButton)];
//            }else{
                [_scrollView addConstraint:sobotLayoutMarginLeft(10, itemBtn, preButton)];
//            }
        }
        [itemBtn layoutIfNeeded];
        preButton = itemBtn;
        
        itemBtn.userInteractionEnabled = YES;
        itemBtn.tag = i;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemTapClick:)];
        tap.numberOfTapsRequired = 1;
        [itemBtn addGestureRecognizer:tap];
        
//        [itemBtn addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
        itemBtn.layer.borderWidth = 1;
//        itemBtn.layer.borderColor = UIColorFromRGB(TextUnPlaceHolderColor).CGColor;
        
    }
    if(preButton){
        [preButton layoutIfNeeded];
//        if ([ZCUIKitTools getSobotIsRTLLayout]) {
//            [_scrollView addConstraint:sobotLayoutPaddingLeft(10, preButton, _scrollView)];
//        }else{
            [_scrollView addConstraint:sobotLayoutPaddingRight(-10, preButton, _scrollView)];
//        }
    }
    [ZCUIKitTools setViewRTLtransForm:_scrollView];
    
    // 刷新高度，列表的内容偏移量也需要刷新
    if (_fastMenuRefreshDataBlock) {
        _fastMenuRefreshDataBlock(_layoutHeight.constant);
    }
}

-(void)itemTapClick:(UITapGestureRecognizer *) tap{
    UIView *sender = tap.view;
    
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

-(NSString *)getMenuUrl:(NSString *) menuUrl paramFlag:(NSString *)paramFlag{
    menuUrl = sobotConvertToString(menuUrl);
    // 未开启，直接返回url
    if([sobotConvertToString(paramFlag) intValue] == 0){
        return menuUrl;
    }
    // 用户自定义字段
    NSString *params = @"";
    ZCLibInitInfo *initInfo = [ZCLibClient getZCLibClient].libInitInfo;
    /** 解析外部传入的自定义 */
    if (initInfo.params != nil&& [initInfo.params isKindOfClass:[NSDictionary class]]) {
        @try {
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:initInfo.params];
            
            // 用户昵称，电话，邮箱 头像  来源页  来源页标题
            if (dict[@"email"] !=nil) {
                initInfo.user_emails = dict[@"email"];
                [dict removeObjectForKey:@"email"];
            }
            
            if (dict[@"uname"] !=nil) {
                initInfo.user_nick = dict[@"uname"];
                [dict removeObjectForKey:@"uname"];
            }
            
            if (dict[@"tel"] !=nil) {
                initInfo.user_tels = dict[@"tel"];
                [dict removeObjectForKey:@"tel"];
            }
            
            if (dict[@"face"] != nil) {
                initInfo.face = dict[@"face"];
                [dict removeObjectForKey:@"face"];
            }
            
            if (dict[@"visitUrl"] != nil) {
                initInfo.visit_url = dict[@"visitUrl"];
                [dict removeObjectForKey:@"visitUrl"];
            }
            
            if (dict[@"visitTitle"] != nil) {
                initInfo.visit_title = dict[@"visitTitle"];
                [dict removeObjectForKey:@"visitTitle"];
            }
            
            if (dict[@"realname"] !=nil) {
                initInfo.user_name = dict[@"realname"];
                [dict removeObjectForKey:@"realname"];
            }
            
            if(dict != nil){
                params = [SobotCache dataTOjsonString:dict];
            }
            
            
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    }
    
    NSString *multi_params = @""; // 2.7.5新增
    @try{
        if (initInfo.multi_params != nil && [initInfo.multi_params isKindOfClass:[NSDictionary class]]) {
            multi_params = [SobotCache dataTOjsonString:initInfo.multi_params];
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
    if([menuUrl rangeOfString:@"?"].length>0){
        menuUrl=[NSString stringWithFormat:@"%@&partnerid=%@&multiparams=%@&params=%@",menuUrl,sobotConvertToString(initInfo.partnerid),sobotUrlEncodedString(multi_params),sobotUrlEncodedString(params)];
    }else{
        menuUrl=[NSString stringWithFormat:@"%@?partnerid=%@&multiparams=%@&params=%@",menuUrl,sobotConvertToString(initInfo.partnerid),sobotUrlEncodedString(multi_params),sobotUrlEncodedString(params)];
    }
    return menuUrl;
}


-(UIView*)addItemIconView:(ZCLibCusMenu *)model{
    UIView *itemView = [[UIView alloc] init];
    [itemView setBackgroundColor:UIColor.clearColor];
    itemView.layer.masksToBounds = YES;
    itemView.layer.cornerRadius = 15.0f;
    itemView.layer.borderWidth = 1;
    itemView.layer.borderColor = [ZCUIKitTools zcgetCommentButtonLineColor].CGColor;
    [_scrollView addSubview:itemView];
    
    SobotImageView *img = [[SobotImageView alloc]init];
//    img.layer.cornerRadius = 4.0f;
//    img.layer.masksToBounds = YES;
    [img setContentMode:UIViewContentModeScaleAspectFit];
    [img setBackgroundColor:UIColor.clearColor];
    [itemView addSubview:img];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.numberOfLines = 1;
    titleLabel.font = SobotFont12;
    titleLabel.textColor = UIColorFromModeColor(SobotColorTextMain);
    titleLabel.lineBreakMode = NSLineBreakByClipping;
    titleLabel.text = sobotConvertToString(model.menuName);
    [itemView addSubview:titleLabel];
    
    [itemView addConstraint:sobotLayoutPaddingLeft(12, img, itemView)];
    [itemView addConstraint:sobotLayoutPaddingTop(8, img, itemView)];
    [itemView addConstraint:sobotLayoutPaddingBottom(-8, img, itemView)];
    
    [itemView addConstraint:sobotLayoutPaddingRight(-12, titleLabel, itemView)];
    [itemView addConstraint:sobotLayoutEqualCenterY(0, titleLabel, itemView)];
    
    NSString *imageName = @"";
    if(model.exhibit == 1){
        if(sobotConvertToString(model.menuPicUrl).length > 0){
            imageName = sobotConvertToString(model.menuPicUrl);
        }else if(sobotConvertToString(model.iconMaterial).length > 0){
            imageName = sobotConvertToString(model.iconMaterial);
        }
    }
    
    if(sobotConvertToString(imageName).length > 0){
        [itemView addConstraint:sobotLayoutEqualWidth(14, img, NSLayoutRelationEqual)];
        [itemView addConstraint:sobotLayoutMarginLeft(3, titleLabel, img)];
        
        // 如果自定义menuPicUrl图片么有，使用默认图片
        NSString *picUrl = sobotConvertToString(model.menuPicUrl);
        if(picUrl.length == 0){
            picUrl = sobotConvertToString(model.iconMaterial);
        }
        [img loadWithURL:[NSURL URLWithString:picUrl] placeholer:SobotKitGetImage(model.imgName) showActivityIndicatorView:NO completionBlock:^(UIImage *image, NSURL *url, NSError *error) {
            if(image){
                dispatch_async(dispatch_get_main_queue(), ^{
                    img.image = [self grayImage:image];
                });
            }
        }];
    }else{
        if ([sobotConvertToString(model.imgName) isEqualToString:@"icon_fast_transfer"]) {
            [itemView addConstraint:sobotLayoutEqualWidth(14, img, NSLayoutRelationEqual)];
            [itemView addConstraint:sobotLayoutMarginLeft(3, titleLabel, img)];
            [img setImage:SobotKitGetImage(@"icon_fast_transfer")];
        }else{
            [itemView addConstraint:sobotLayoutEqualWidth(0, img, NSLayoutRelationEqual)];
            [itemView addConstraint:sobotLayoutMarginLeft(0, titleLabel, img)];
        }
    }
    return itemView;
}

-(UIImage *)grayImage:(UIImage *) image{
    if([SobotUITools getSobotThemeMode] != SobotThemeMode_Dark){
        return image;
    }
    if(image.size.width == 0 || image.size.height == 0){
        return image;
    }
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)
                   blendMode:kCGBlendModeDarken
                       alpha:1.0];
    UIImage *highlighted = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return highlighted;
}
@end
