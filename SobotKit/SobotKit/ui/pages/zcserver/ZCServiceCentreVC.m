//
//  ZCServiceCentreVC.m
//  SobotKit
//
//  Created by lizh on 2022/9/26.
//

#import "ZCServiceCentreVC.h"
#import "ZCUICore.h"
#import "ZCUIKitTools.h"
#import "ZCServiceListVC.h"

typedef NS_ENUM(NSInteger,ZCLineType) {
    LineLayerBorder = 0,//边框线
    LineHorizontal  = 1,//竖线
    LineVertical    = 2,//横线
};
// 理想线宽
#define LINE_WIDTH                  1
// 实际应该显示的线宽
#define SINGLE_LINE_WIDTH           floor((LINE_WIDTH / [UIScreen mainScreen].scale)*100) / 100
//偏移的宽度
#define SINGLE_LINE_ADJUST_OFFSET   floor(((LINE_WIDTH / [UIScreen mainScreen].scale) / 2)*100) / 100

typedef BOOL(^LinkClickBlock)(NSString *linkUrl);
typedef void (^PageLoadBlock)(id object,ZCPageStateType type);

@interface ZCServiceCentreVC ()
{
    UIView *serviceBtnBgView;
}
@property (nonatomic,strong) NSMutableArray *listArray;
@property (nonatomic,assign) id<ZCChatControllerDelegate> delegate;

@property (nonatomic,strong) NSLayoutConstraint *telBtnEW;
@property (nonatomic,strong) UIButton *telButton;
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) NSLayoutConstraint *scrollViewPT;
@end

@implementation ZCServiceCentreVC

#pragma mark - 返回事件
-(void)buttonClick:(UIButton *)sender{
    if (sender.tag == SobotButtonClickBack) {
        if([ZCUICore getUICore].ZCViewControllerCloseBlock != nil){
            [ZCUICore getUICore].ZCViewControllerCloseBlock(self,ZC_CloseHelpCenter);
        }
        if (self.navigationController && self.isPush) {
            [self.navigationController popViewControllerAnimated:NO];
        }else{
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
        [self.titleLabel setText:SobotKitLocalString(@"客户服务中心")];
    }else if (![ZCUICore getUICore].kitInfo.navcBarHidden && self.navigationController){
        self.title = SobotKitLocalString(@"客户服务中心");
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorFromKitModeColor(SobotColorBgSub2Dark1);
    self.automaticallyAdjustsScrollViewInsets = YES;
    if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }
    [self createVCTitleView];
    [self createSubviews];
    [self loadData];
}

#pragma mark -- 添加子控件
-(void)createSubviews{
    // 构建 联系客服和联系热线按钮
    serviceBtnBgView = [[UIView alloc]init];
    serviceBtnBgView.backgroundColor = UIColorFromKitModeColor(SobotColorBgSub2Dark1);
    [self.view addSubview:serviceBtnBgView];
    [self createHelpCenterButtons:10 sView:serviceBtnBgView];
    [self.view addConstraint:sobotLayoutPaddingBottom(0, serviceBtnBgView, self.view)];
    [self.view addConstraint:sobotLayoutPaddingLeft(0, serviceBtnBgView, self.view)];
    [self.view addConstraint:sobotLayoutEqualHeight(80, serviceBtnBgView, NSLayoutRelationEqual)];
    [self.view addConstraint:sobotLayoutPaddingRight(0, serviceBtnBgView, self.view)];
    CGFloat navh = NavBarHeight;
    if (self.topView == nil || ![ZCUICore getUICore].kitInfo.navcBarHidden) {
        navh = 0;
    }
    _scrollView = ({
        UIScrollView *iv = [[UIScrollView alloc]init];
        [self.view addSubview:iv];
        iv.alwaysBounceVertical = YES;
        iv.alwaysBounceHorizontal = NO;
        iv.bounces = NO;
        iv.frame = CGRectMake(0, navh, ScreenWidth, self.view.frame.size.height - navh- 80);
        iv;
    });
    
}

#pragma mark - 联系客服 和 联系电话点击事件
-(void)openZCSDK:(UIButton *)sender{
    NSLog(@"点击了联系客服 %ld",(long)sender.tag);
    if(sender.tag == 1){
        if (self.OpenZCSDKTypeBlock) {
            self.OpenZCSDKTypeBlock(self);
        }else{
            [ZCSobotApi openZCChat:_kitInfo with:self pageBlock:^(id  _Nonnull object, ZCPageStateType type) {
                
            }];
        }
        return;
    }
    if (sender.tag == 2) {
        NSString *link = sobotConvertToString([ZCUICore getUICore].kitInfo.helpCenterTel);
        if(![link hasSuffix:@"tel:"]){
            link = [NSString stringWithFormat:@"tel:%@",link];
        }
        if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_9_x_Max) {
            [SobotUITools showAlert:nil message:[link stringByReplacingOccurrencesOfString:@"tel:" withString:@""] cancelTitle:SobotKitLocalString(@"取消") viewController:self confirm:^(NSInteger buttonTag) {
                if(buttonTag>=0){
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
                }
            } buttonTitles:SobotKitLocalString(@"呼叫"), nil];
        }else{
            if([ZCUICore getUICore].ZCViewControllerCloseBlock != nil){
                [ZCUICore getUICore].ZCViewControllerCloseBlock(self,ZC_PhoneCustomerService);
            }
            // 打电话
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
        }
    }
}


-(id)initWithInitInfo:(ZCKitInfo *)info{
    self=[super init];
    if(self){
        [ZCUICore getUICore].kitInfo = info;
    }
    return self;
}

#pragma mark -- 加载数据
-(void)loadData{
    [self createPlaceHolderView:self.view title:SobotKitLocalString(@"暂无帮助内容") desc:SobotKitLocalString(@"可点击下方按钮咨询人工客服") image:nil block:nil];
    _listArray = [NSMutableArray arrayWithCapacity:0];
    __weak ZCServiceCentreVC *weakself = self;
    [SobotProgressHUD show];
    [ZCLibServer getCategoryWith:[ZCLibClient getZCLibClient].libInitInfo.app_key start:^{

    } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
        if (dict) {
            NSArray * dataArr = dict[@"data"];
            if ([dataArr isKindOfClass:[NSArray class]] && dataArr.count > 0) {
                
                for (NSDictionary *item in dataArr) {
                    ZCSCListModel * listModel = [[ZCSCListModel alloc]initWithMyDict:item];                    
                    [weakself.listArray addObject:listModel];
                }
                if (weakself.listArray.count > 0) {
                    [weakself removePlaceholderView];
                    [weakself layoutItemWith:weakself.listArray];
                }
            }
        }
        [SobotProgressHUD dismiss];
    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
        [SobotProgressHUD dismiss];
    }];
}


-(void)layoutItemWith:(NSMutableArray *)array{
    CGFloat bw= _scrollView.frame.size.width;
    CGFloat x= 12;
    CGFloat y= 11;
    CGFloat itemW = (bw-0.25 - 30)/2.0f;
    
    int index = _listArray.count%2==0?round(_listArray.count/2):round(_listArray.count/2)+1;
    UIView *lastView;
    UIButton *lastBtn;
    for (int i =0; i<_listArray.count; i++) {
        UIView * itemView = [self addItemView:_listArray[i] withX:x withY:y withW:itemW Tag:i];
        itemView.layer.borderColor = UIColorFromKitModeColor(SobotColorBgLine).CGColor;
        itemView.layer.borderWidth = 1.0f;
        itemView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleWidth;
        itemView.autoresizesSubviews = YES;
        [itemView setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark2)];
        itemView.userInteractionEnabled = YES;
        itemView.tag = i;
        if(i%2==1){
            // 右边的按钮,与上一个左边按钮对比，那个高度高，就使用那个高度
            x = 12;
//            y = y + itemH + 6;

            if (itemView.frame.size.height >= lastView.frame.size.height) {
                CGRect lastF = lastView.frame;
                lastF.size.height = itemView.frame.size.height;
                lastView.frame = lastF;
                CGRect btnF = lastBtn.frame;
                btnF.size = lastF.size ;
                lastBtn.frame = btnF;
                y = y + 6 + lastF.size.height;
            }else{
                CGRect itemF = itemView.frame;
                itemF.size.height = lastView.frame.size.height;
                itemView.frame = itemF;
                CGRect btnF = lastBtn.frame;
                btnF.size = itemF.size ;
                lastBtn.frame = btnF;
                y = y + 6 + itemF.size.height;
            }
            lastView = itemView;
            UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = i;
            btn.frame = CGRectMake(0, 0, CGRectGetWidth(itemView.frame),CGRectGetHeight(itemView.frame));
            btn.backgroundColor = [UIColor clearColor];
            [btn addTarget:self action:@selector(tapItemAction:) forControlEvents:UIControlEventTouchUpInside];
            [itemView addSubview:btn];
            lastBtn = btn;
            
        }else if(i%2==0){
            x = itemW + 12 + 6;
            lastView = itemView;
            UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = i;
            btn.frame = CGRectMake(0, 0, CGRectGetWidth(itemView.frame),CGRectGetHeight(itemView.frame));
            btn.backgroundColor = [UIColor clearColor];
            [btn addTarget:self action:@selector(tapItemAction:) forControlEvents:UIControlEventTouchUpInside];
            [itemView addSubview:btn];
            lastBtn = btn;
        }
        [_scrollView addSubview:itemView];
    }
    [_scrollView setContentSize:CGSizeMake(bw, CGRectGetMaxY(lastView.frame)+10)];
//    [scrollView setContentInset:UIEdgeInsetsZero];

}

#pragma mark - 创建单个的itemView
-(UIView *)addItemView:(ZCSCListModel *) model withX:(CGFloat )x withY:(CGFloat) y withW:(CGFloat) w Tag:(int)i{
    
    UIView *itemView = [[UIView alloc] initWithFrame:CGRectMake(x, y, w,0)];
    [itemView setFrame:CGRectMake(x, y, w, 0)];
    [itemView setBackgroundColor:UIColorFromKitModeColor(SobotColorWhite)];
    
    SobotImageView *img = [[SobotImageView alloc]initWithFrame:CGRectMake(14, 18, 40, 40)];
    [img loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(model.categoryUrl)] placeholer:nil showActivityIndicatorView:NO completionBlock:^(UIImage *image, NSURL *url, NSError *error) {
        if(image){
            dispatch_async(dispatch_get_main_queue(), ^{
                img.image = [self grayImage:image];
            });
        }
    }];
    img.layer.cornerRadius = 4.0f;
    img.layer.masksToBounds = YES;
    [img setBackgroundColor:UIColorFromKitModeColor(SobotColorBgSub)];
    [itemView addSubview:img];
    
    CGFloat maxW = w-70;
    CGFloat titleH = [ZCUIKitTools getHeightContain:sobotConvertToString(model.categoryName) font:SobotFontBold14 Width:maxW];
    CGFloat detailH = [ZCUIKitTools getHeightContain:sobotConvertToString(model.categoryDetail) font:SobotFont12 Width:maxW];
    
    
    UILabel *titlelab = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(img.frame) + 10, 20, maxW, titleH)];
    titlelab.numberOfLines = 0;
    [titlelab setTextAlignment:NSTextAlignmentLeft];
    [titlelab setTextColor:UIColorFromKitModeColor(SobotColorTextSub)];
    [titlelab setText:sobotConvertToString(model.categoryName)];
    [titlelab setFont:SobotFontBold14];
    [itemView addSubview:titlelab];
    
    
    UILabel *detailLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(img.frame) +10, CGRectGetMaxY(titlelab.frame) +2, maxW, detailH)];
    [detailLab setTextAlignment:NSTextAlignmentLeft];
    detailLab.numberOfLines = 0;
    [detailLab setTextColor:UIColorFromKitModeColor(SobotColorTextSub)];
    [detailLab setText:sobotConvertToString(model.categoryDetail)];
    [detailLab setFont:SobotFont12];
    [itemView addSubview:detailLab];
    
    CGRect vf = itemView.frame;
    vf.size.height = CGRectGetMaxY(detailLab.frame) + 15;
    itemView.frame = vf;

    return itemView;
}


#pragma mark - 跳转到条目列表页面
-(void)tapItemAction:(UIButton *)sender{
    ZCServiceListVC * listVC = [[ZCServiceListVC alloc]init];
    int tag = (int)sender.tag;
    ZCSCListModel * model= _listArray[tag];
    listVC.titleName = sobotConvertToString(model.categoryName);
    listVC.appId = sobotConvertToString(model.appId);
    listVC.categoryId = model.categoryId;
    [listVC setOpenZCSDKTypeBlock:self.OpenZCSDKTypeBlock];
    if (self.navigationController) {
        [self.navigationController pushViewController:listVC animated:NO];
    }else{
        [self presentViewController:listVC animated:NO completion:nil];
    }
}


-(UIImage *)grayImage:(UIImage *) image{
    if([SobotUITools getSobotThemeMode] == SobotThemeMode_Dark){
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

#pragma mark - 联系客服
-(UIButton *)createHelpCenterButtons:(CGFloat ) y sView:(UIView *) superView{
    CGFloat itemW =  (ScreenWidth - SobotNumber(24) - 20)/2;
    _telButton = [self createHelpCenterOpenButton];
    _telButton.tag = 2;
    [_telButton setTitle:sobotConvertToString([ZCUICore getUICore].kitInfo.helpCenterTelTitle) forState:UIControlStateNormal];
    [_telButton setTitle:sobotConvertToString([ZCUICore getUICore].kitInfo.helpCenterTelTitle) forState:UIControlStateHighlighted];
    [superView addSubview:_telButton];
    [superView addConstraint:sobotLayoutPaddingTop(y, _telButton, superView)];
    [superView addConstraint:sobotLayoutPaddingRight(SobotNumber(-12), _telButton, superView)];
    [superView addConstraint:sobotLayoutEqualHeight(44, _telButton, NSLayoutRelationEqual)];
    _telButton.hidden = YES;
    if(sobotConvertToString([ZCUICore getUICore].kitInfo.helpCenterTel).length > 0 && sobotConvertToString([ZCUICore getUICore].kitInfo.helpCenterTelTitle).length > 0){
        _telButton.hidden = NO;
        self.telBtnEW = sobotLayoutEqualWidth(itemW, _telButton, NSLayoutRelationEqual);
    }else{
        self.telBtnEW = sobotLayoutEqualWidth(0, _telButton, NSLayoutRelationEqual);
    }
    [superView addConstraint:self.telBtnEW];
    UIButton *serviceButton = [self createHelpCenterOpenButton];
    serviceButton.tag = 1;
    [superView addSubview:serviceButton];
    [superView addConstraint:sobotLayoutPaddingLeft(SobotNumber(12), serviceButton, superView)];
    [superView addConstraint:sobotLayoutPaddingTop(y, serviceButton, superView)];
    [superView addConstraint:sobotLayoutEqualHeight(44, serviceButton, NSLayoutRelationEqual)];
    if (!_telButton.hidden) {
        [superView addConstraint:sobotLayoutMarginRight(-20, serviceButton, _telButton)];
    }else{
        [superView addConstraint:sobotLayoutMarginRight(0, serviceButton, _telButton)];
    }
    return serviceButton;
}

#pragma mark - 在线客服按钮 和拨号按钮
-(UIButton *)createHelpCenterOpenButton{
    // 在线客服btn
    UIButton *serviceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    serviceBtn.type = 5;
    [serviceBtn setTitle:SobotKitLocalString(@"在线客服") forState:UIControlStateNormal];
    [serviceBtn setTitle:SobotKitLocalString(@"在线客服") forState:UIControlStateHighlighted];
    [serviceBtn setTitleColor:UIColorFromKitModeColor(SobotColorTextMain) forState:UIControlStateNormal];
    [serviceBtn setTitleColor:UIColorFromKitModeColor(SobotColorTextMain) forState:UIControlStateHighlighted];
    serviceBtn.titleLabel.font = SobotFontBold14;
    [serviceBtn addTarget:self action:@selector(openZCSDK:) forControlEvents:UIControlEventTouchUpInside];
    serviceBtn.layer.borderColor = UIColorFromKitModeColor(SobotColorBgLine).CGColor;
    serviceBtn.layer.borderWidth = 0.5f;
    serviceBtn.layer.cornerRadius = 22.0f;
    serviceBtn.layer.masksToBounds = YES;
    serviceBtn.titleLabel.lineBreakMode = 4;
    [serviceBtn setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark2)];
    [serviceBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 3)];
    [serviceBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 0)];
    [serviceBtn setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];
    [serviceBtn setAutoresizesSubviews:YES];
    return serviceBtn;
}

// 适配iOS 13以上的横竖屏切换
-(void)viewSafeAreaInsetsDidChange{
    [super viewSafeAreaInsetsDidChange];
    UIEdgeInsets e = self.view.safeAreaInsets;
    // 横竖屏更新导航栏渐变色
    [self updateCenterViewBgColor];
    [self updateNavOrTopView];
    CGFloat navh = NavBarHeight;
    if (self.topView == nil || ![ZCUICore getUICore].kitInfo.navcBarHidden) {
        navh = 0;
    }
    // 中间部分
    if (self.scrollView) {
        self.scrollView.frame = CGRectMake(e.left, navh, ScreenWidth-e.left*2, self.view.frame.size.height - navh- 80);
        if (_listArray.count > 0) {
            [self removePlaceholderView];
            [_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [self layoutItemWith:_listArray];
        }
    }
    // 底部 联系客服按钮的切换
    if (!self.telButton.hidden) {
        [serviceBtnBgView removeConstraint:self.telBtnEW];
        CGFloat itemW = (ScreenWidth - SobotNumber(24) -20)/2;
        self.telBtnEW = sobotLayoutEqualWidth(itemW, self.telButton, NSLayoutRelationEqual);
        [serviceBtnBgView addConstraint:self.telBtnEW];
    }
}

-(void)dealloc{
    SLog(@"zcservicecentevc dealloc", nil);
}

@end
