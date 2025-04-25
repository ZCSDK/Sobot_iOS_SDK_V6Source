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

@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) NSLayoutConstraint *scrollViewPT;
@property (nonatomic,strong) NSLayoutConstraint *scrollViewPL;
@property (nonatomic,strong) NSLayoutConstraint *scrollViewPR;
@end

@implementation ZCServiceCentreVC

#pragma mark - 返回事件
-(void)buttonClick:(UIButton *)sender{
    if (sender.tag == SobotButtonClickBack) {
        if([ZCUICore getUICore].ZCViewControllerCloseBlock != nil){
            [ZCUICore getUICore].ZCViewControllerCloseBlock(self,ZC_CloseHelpCenter);
        }
        
        [self goBack];
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
    
    [self setNavTitle:SobotKitLocalString(@"客户服务中心")];
    
    [self createSubviews];
    [self loadData];
    
    [self updateNavOrTopView];
}

#pragma mark -- 添加子控件
-(void)createSubviews{
    // 构建 联系客服和联系热线按钮
    serviceBtnBgView = [self createBtmView:YES];
    
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
        //            iv.frame = CGRectMake(0, navh, ScreenWidth, self.view.frame.size.height - navh- 80);
        iv;
    });
    _scrollViewPT = sobotLayoutPaddingTop(navh, self.scrollView, self.view);
    _scrollViewPL = sobotLayoutPaddingLeft(0, self.scrollView, self.view);
    _scrollViewPR = sobotLayoutPaddingRight(navh, self.scrollView, self.view);
    [self.view addConstraint:_scrollViewPL];
    [self.view addConstraint:_scrollViewPR];
    [self.view addConstraint:_scrollViewPT];
    [self.view addConstraint:sobotLayoutMarginBottom(0, self.scrollView, serviceBtnBgView)];
}

-(void)btmButtonClick:(UIButton *)sender{
    [super btmButtonClick:sender];
    
    if(sender.tag == 1){
        if (self.OpenZCSDKTypeBlock) {
            self.OpenZCSDKTypeBlock(self);
        }else{
            [ZCSobotApi openZCChat:_kitInfo with:self pageBlock:^(id  _Nonnull object, ZCPageStateType type) {
                
            }];
        }
        return;
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
    CGFloat hSpace = SobotSpace16;
    CGFloat vSpace = 8;
    CGFloat x= hSpace;
    CGFloat y= SobotSpace16;
    CGFloat itemW = (bw-vSpace - hSpace*2)/2.0f;
    
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
            x = SobotSpace16;
//            y = y + itemH + 6;

            if (itemView.frame.size.height >= lastView.frame.size.height) {
                CGRect lastF = lastView.frame;
                lastF.size.height = itemView.frame.size.height;
                lastView.frame = lastF;
                CGRect btnF = lastBtn.frame;
                btnF.size = lastF.size ;
                lastBtn.frame = btnF;
                y = y + vSpace + lastF.size.height;
            }else{
                CGRect itemF = itemView.frame;
                itemF.size.height = lastView.frame.size.height;
                itemView.frame = itemF;
                CGRect btnF = lastBtn.frame;
                btnF.size = itemF.size ;
                lastBtn.frame = btnF;
                y = y + vSpace + itemF.size.height;
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
            x = itemW + hSpace + vSpace;
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
    [_scrollView setContentSize:CGSizeMake(bw, CGRectGetMaxY(lastView.frame)+hSpace)];
//    [scrollView setContentInset:UIEdgeInsetsZero];

}

#pragma mark - 创建单个的itemView
-(UIView *)addItemView:(ZCSCListModel *) model withX:(CGFloat )x withY:(CGFloat) y withW:(CGFloat) w Tag:(int)i{
    
    UIView *itemView = [[UIView alloc] initWithFrame:CGRectMake(x, y, w,0)];
    [itemView setFrame:CGRectMake(x, y, w, 0)];
    itemView.layer.cornerRadius = 8.0f;
    itemView.layer.masksToBounds = YES;
    [itemView setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark3)];
    
    SobotImageView *img = [[SobotImageView alloc]initWithFrame:CGRectMake(12, 12, 32, 32)];
    [img loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(model.categoryUrl)] placeholer:nil showActivityIndicatorView:YES completionBlock:^(UIImage *image, NSURL *url, NSError *error) {
        if(image){
            dispatch_async(dispatch_get_main_queue(), ^{
                img.image = [self grayImage:image];
            });
        }
    }];
    img.layer.cornerRadius = 4.0f;
    img.layer.masksToBounds = YES;
    [img setBackgroundColor:UIColorFromKitModeColor(SobotColorBgF5)];
    [itemView addSubview:img];
    
    CGFloat maxW = w-20-32-12;
    CGFloat titleH = [ZCUIKitTools getHeightContain:sobotConvertToString(model.categoryName) font:SobotFontBold14 Width:maxW];
    
    if(titleH<32){
        titleH = 32;
    }
    
    UILabel *titlelab = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(img.frame) + 8, 12, maxW, titleH)];
    titlelab.numberOfLines = 0;
    [titlelab setTextAlignment:NSTextAlignmentLeft];
    [titlelab setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
    [titlelab setText:sobotConvertToString(model.categoryName)];
    [titlelab setFont:SobotFontBold14];
    [itemView addSubview:titlelab];
    
    
    CGFloat detailH = [ZCUIKitTools getHeightContain:sobotConvertToString(model.categoryDetail) font:SobotFont12 Width:w-24];
    UILabel *detailLab = [[UILabel alloc] initWithFrame:CGRectMake(12, CGRectGetMaxY(titlelab.frame) + 8, w-24, detailH)];
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


// 适配iOS 13以上的横竖屏切换
-(void)viewSafeAreaInsetsDidChange{
    [super viewSafeAreaInsetsDidChange];
    UIEdgeInsets e = self.view.safeAreaInsets;
    // 横竖屏更新导航栏渐变色
    [self updateTopViewBgColor];
    
    CGFloat navh = NavBarHeight;
    if (self.topView == nil || ![ZCUICore getUICore].kitInfo.navcBarHidden) {
        navh = 0;
    }
    // 中间部分
    if (self.scrollView) {
        _scrollViewPL.constant = e.left;
        _scrollViewPR.constant = -e.right;
        _scrollViewPT.constant = navh;
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        // 更新UIScrollView的子视图的约束
        
        // 强制更新布局
        [self.scrollView layoutIfNeeded];
        if (self->_listArray.count > 0) {
            [self removePlaceholderView];
            [self->_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [self layoutItemWith:self->_listArray];
        }
        
    } completion:nil];
}

-(void)dealloc{
    SLog(@"zcservicecentevc dealloc", nil);
}

@end
