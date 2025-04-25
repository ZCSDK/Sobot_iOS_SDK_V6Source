//
//  ZCChatHotGuideCell.m
//  SobotKit
//
//  Created by zhangxy on 2022/9/21.
//

#import "ZCChatHotGuideCell.h"
#import <SobotCommon/SobotCommon.h>
#import "ZCChatHotCollectionCell.h"
#import "ZCShadowRadiusView.h"

@interface ZCChatHotGuideCell()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate>{
    SobotButton *checkGroupBtn;
    CGFloat contentWidth;
}

@property (nonatomic,strong) NSMutableArray * listArray;

@property (nonatomic,strong) UICollectionViewFlowLayout *layout;

@property (nonatomic,strong)  UIScrollView * businessView;
// 渐变色
@property (nonatomic,strong) UIImageView *busColorView;
@property (nonatomic,strong) UIImageView *leftBusColorView;
// 渐变的view
@property (nonatomic,strong)  UIImageView *groupColorView;
@property (nonatomic,strong)  UIImageView *leftGroupColorView;
@property (nonatomic,strong)  UIView *logoViewBgView;
@property (nonatomic,strong)  SobotImageView * logoView;
@property (nonatomic,strong)  UIScrollView * groupView;
@property (nonatomic,strong)  UICollectionView * collectionView;
@property (nonatomic,strong)  SobotButton * btnLookMore;
@property (nonatomic,strong)  UIView *groupBgView;

@property (nonatomic,strong)  UIView * bgView;

@property (nonatomic,strong) UIView *groupLineView;
@property (nonatomic,strong)  NSLayoutConstraint * layoutLogoBgViewWidth;
@property (nonatomic,strong)  NSLayoutConstraint * layoutBusinessHeight;
@property (nonatomic,strong)  NSLayoutConstraint * layoutViewH;
@property (nonatomic,strong)  NSLayoutConstraint * layoutBgViewTop;
@property (nonatomic,strong)  NSLayoutConstraint * layoutGroupLeft;
@property (nonatomic,strong)  NSLayoutConstraint * layoutGroupHeight;
@property (nonatomic,strong)  NSLayoutConstraint * layoutLookMoreHeight;
@property (nonatomic,strong)  NSLayoutConstraint * layoutLookMoreTop;
@property (nonatomic,strong)  NSLayoutConstraint * layoutCollectionHeight;
@property (nonatomic,strong) NSLayoutConstraint *groupLineViewH;
//@property (nonatomic,strong) NSLayoutConstraint *logoViewBgViewH;// 高度固定
@property (nonatomic,assign) CGFloat itemSizeHeight;

@property (nonatomic,strong) NSLayoutConstraint *busColorViewH;
@property (nonatomic,strong) NSLayoutConstraint *busColorViewW;
@property (nonatomic,strong) NSLayoutConstraint *lbusColorViewH;
@property (nonatomic,strong) NSLayoutConstraint *lbusColorViewW;

@property (nonatomic,strong) NSLayoutConstraint *groupColorViewW;
@property (nonatomic,strong) NSLayoutConstraint *leftGroupColorViewW;


#pragma mark -- 换一批的按钮 搞成组合的 方便调间距
@property (nonatomic,strong) UIView *moreBgView;
@property (nonatomic,strong) UIImageView *moreIcon;
@property (nonatomic,strong) UILabel *moreLab;
@property (nonatomic,strong) UIButton *moreBtn;

@property (nonatomic,strong)  NSLayoutConstraint * moreBgH;
@property (nonatomic,strong)  NSLayoutConstraint * moreBgW;
@property (nonatomic,strong)  NSLayoutConstraint * moreIconH;
@property (nonatomic,strong)  NSLayoutConstraint * moreIconW;
@property (nonatomic,strong)  NSLayoutConstraint * moreLabH;
@end

@implementation ZCChatHotGuideCell


-(void)setupView{
    _listArray = [[NSMutableArray alloc] init];
    // 顶部业务布局
    _businessView = ({
        UIScrollView *iv = [[UIScrollView alloc] init];
        iv.showsHorizontalScrollIndicator = NO;
        iv.bounces = NO;
        iv.scrollEnabled = YES;
        iv.backgroundColor = [ZCUIKitTools zcgetChatBackgroundColor];
        [self.contentView addSubview:iv];
        iv.backgroundColor = UIColor.clearColor;
        iv.tag = 20001;
        iv.delegate = self;
        iv;
    });
  
    _bgView = ({
        ZCShadowRadiusView *iv = [[ZCShadowRadiusView alloc] init];
//        [iv setBackgroundColor:[ZCUIKitTools zcgetLeftChatColor]];
//        [iv setBackgroundColor:[UIColor clearColor]];
//        iv.layer.cornerRadius = 10.0f;
//        iv.layer.masksToBounds = YES;
//        iv.layer.borderColor = [UIColor clearColor].CGColor;
//        iv.layer.borderWidth = 1.0f;
        iv.maxRadius = YES;
        [self.contentView addSubview:iv];
        iv;
    });
    
    _logoViewBgView = ({
        UIView *iv = [[UIView alloc]init];
        [self.bgView addSubview:iv];
        iv.backgroundColor =UIColor.clearColor;
        [iv.layer setMasksToBounds:YES];
        iv.layer.shadowColor =  [ZCUIKitTools zcgetChatBottomLineColor].CGColor;
        iv;
    });
    
    _logoView = ({
        SobotImageView *iv = [[SobotImageView alloc] init];
        [iv setContentMode:UIViewContentModeScaleAspectFill];
        [iv.layer setMasksToBounds:YES];
        [iv setBackgroundColor:[UIColor clearColor]];
        iv.layer.masksToBounds = YES;
        [_logoViewBgView addSubview:iv];
        iv;
    });
    
    _groupBgView = ({
        UIView *iv = [[UIView alloc]init];
        iv.backgroundColor = [ZCUIKitTools zcgetChatBackgroundColor];
        [_bgView addSubview:iv];
        iv;
    });
    
    _groupView = ({
        UIScrollView *iv = [[UIScrollView alloc] init];
        iv.showsHorizontalScrollIndicator = NO;
        iv.bounces = NO;
        iv.scrollEnabled = YES;
        iv.tag = 20002;
        iv.delegate = self;
        iv.backgroundColor = [ZCUIKitTools zcgetChatBackgroundColor];
//        iv.backgroundColor = [UIColor clearColor];
        [_groupBgView addSubview:iv];
//        iv.backgroundColor = UIColor.greenColor;
        iv;
    });
    
    _groupLineView = ({
        UIView *iv = [[UIView alloc]init];
        [_groupBgView addSubview:iv];
        [_groupBgView addConstraint:sobotLayoutPaddingLeft(16, iv, _groupBgView)];
        [_groupBgView addConstraint:sobotLayoutPaddingRight(-16, iv, _groupBgView)];
        [_groupBgView addConstraint:sobotLayoutMarginTop(0, iv, _groupView)];
        self.groupLineViewH = sobotLayoutEqualHeight(0.5, iv, NSLayoutRelationEqual);
        [_groupBgView addConstraint:self.groupLineViewH];
        iv.backgroundColor = UIColorFromKitModeColor(SobotColorBgTopLine);
        iv;
    });
    
    _collectionView = ({
        _layout = [UICollectionViewFlowLayout new];
        _layout.itemSize = CGSizeMake(80, 20);
        _layout.scrollDirection = UICollectionViewScrollDirectionVertical;
//        _layout.minimumLineSpacing = 1;
        _layout.minimumLineSpacing = 0;
        // 顶部添加8个间距
        _layout.headerReferenceSize = CGSizeMake(1, 8);
        
        
        // 12的间隙为 item 到 消息
        UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:_layout];
//        collectionView.backgroundColor = [ZCUIKitTools zcgetChatBottomLineColor];
        collectionView.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark3);// [ZCUIKitTools zcgetChatBackgroundColor];// UIColor.clearColor;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.scrollEnabled = NO;
        collectionView.scrollsToTop = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.clipsToBounds = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        // 镜像
        collectionView.semanticContentAttribute =  UISemanticContentAttributeForceLeftToRight;
        [collectionView registerClass:[ZCChatHotCollectionCell class] forCellWithReuseIdentifier:@"ZCChatHotCollectionCell"];
        if(sobotGetSystemDoubleVersion()>=11){
            if (@available(iOS 11.0, *)) {
                collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            } else {
                // Fallback on earlier versions
            }
        }
        [_bgView addSubview:collectionView];
    
//        collectionView.backgroundColor = UIColor.placeholderTextColor;
        collectionView;
    });
    
    _btnLookMore = ({
        SobotButton *iv = [SobotButton buttonWithType:UIButtonTypeCustom];
        iv.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
//        [iv setImage:SobotKitGetImage(@"zcicon_refresh") forState:0];
        [iv setBackgroundColor:[ZCUIKitTools zcgetChatBackgroundColor]];
//        [iv setTitle:SobotKitLocalString(@"换一批") forState:UIControlStateNormal];
        [iv setTitleColor:UIColorFromKitModeColor(SobotColorTextSub1) forState:0];
        [iv addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventTouchUpInside];
        [iv.titleLabel setFont:SobotFont14];
//        iv.layer.cornerRadius = 5;
        iv.layer.masksToBounds = YES;
        [self.bgView addSubview:iv];
        // 设置图片和文字的间距
//        [SobotUITools sobotButon:iv hSpace:4 top:12 rtl:SobotKitIsRTLLayout];
        iv;
    });
   
#pragma mark -- 同步更新
    _moreBgView = ({
        UIView *iv = [[UIView alloc]init];
        [self.btnLookMore addSubview:iv];
        iv;
    });
    
    _moreIcon = ({
        UIImageView *iv = [[UIImageView alloc]init];
        [_moreBgView addSubview:iv];
        [iv setImage:SobotKitGetImage(@"zcicon_refresh")];
        iv.contentMode = UIViewContentModeScaleAspectFit;
        iv;
    });
    
    _moreLab = ({
        UILabel *iv = [[UILabel alloc]init];
        [_moreBgView addSubview:iv];
        iv.font = SobotFont14;
        iv.text = SobotKitLocalString(@"换一批");
        iv.textColor = UIColorFromKitModeColor(SobotColorTextSub1);
        iv;
    });
    _moreBtn = ({
        UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
        [_moreBgView addSubview:iv];
        [_moreBgView addConstraint:sobotLayoutPaddingLeft(0, iv, _moreBgView)];
        [_moreBgView addConstraint:sobotLayoutPaddingRight(0, iv, _moreBgView)];
        [_moreBgView addConstraint:sobotLayoutPaddingTop(0, iv, _moreBgView)];
        [_moreBgView addConstraint:sobotLayoutPaddingBottom(0, iv, _moreBgView)];
        [iv addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventTouchUpInside];
        iv;
    });
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self createView];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self createView];
    }
    return self;
}
-(void)createView{
    [self setupView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCollectionViewItem) name:@"updatecollectionitem" object:nil];
    // 业务
    [self.contentView addConstraint:sobotLayoutPaddingTop(ZCChatMarginVSpace, self.businessView, self.contentView)];
    [self.contentView addConstraint:sobotLayoutPaddingLeft(ZCChatMarginHSpace, self.businessView, self.contentView)];
    [self.contentView addConstraint:sobotLayoutPaddingRight(-ZCChatMarginHSpace, self.businessView, self.contentView)];
    _layoutBusinessHeight = sobotLayoutEqualHeight(90, self.businessView, NSLayoutRelationEqual);
    _layoutGroupHeight.priority = UILayoutPriorityDefaultHigh;
    [self.contentView addConstraint:_layoutBusinessHeight];

    _bgView.layer.masksToBounds = NO;
//    _bgView.layer.borderWidth = 1.0f;
//    _bgView.layer.shadowColor = [ZCUIKitTools zcgetChatBottomLineColor].CGColor;
//    _bgView.layer.shadowOpacity = 0.9;
//    _bgView.layer.shadowRadius = 5;
//    _bgView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
//    _bgView.layer.borderColor = UIColor.redColor.CGColor;
    
    // 分组+内容
    _layoutBgViewTop = sobotLayoutMarginTop(ZCChatMarginVSpace, self.bgView, self.businessView);
    [self.contentView addConstraint:_layoutBgViewTop];
    [self.contentView addConstraint:sobotLayoutPaddingLeft(ZCChatMarginHSpace, self.bgView, self.contentView)];
    [self.contentView addConstraint:sobotLayoutPaddingRight(-ZCChatMarginHSpace, self.bgView, self.contentView)];
    NSLayoutConstraint *layoutBtm = sobotLayoutPaddingBottom(-ZCChatMarginVSpace, self.bgView, self.contentView);
    layoutBtm.priority = UILayoutPriorityDefaultHigh;
    [self.contentView addConstraint:layoutBtm];
    
    // logoViewBGview
    [self.bgView addConstraint:sobotLayoutPaddingTop(0, self.logoViewBgView, self.bgView)];
    [self.bgView addConstraint:sobotLayoutPaddingLeft(0, self.logoViewBgView, self.bgView)];
    [self.bgView addConstraint:sobotLayoutPaddingBottom(0, self.logoViewBgView, self.bgView)];
//    self.logoViewBgViewH = sobotLayoutEqualHeight(100, self.logoView, NSLayoutRelationEqual);
//    [self.bgView addConstraint:self.logoViewBgViewH];
    _layoutLogoBgViewWidth = sobotLayoutEqualWidth(0, self.logoViewBgView, NSLayoutRelationEqual);
    [self.bgView addConstraint:_layoutLogoBgViewWidth];
    
    // logoView
    [self.bgView addConstraint:sobotLayoutPaddingTop(0, self.logoView, self.logoViewBgView)];
    [self.bgView addConstraint:sobotLayoutPaddingLeft(0, self.logoView, self.logoViewBgView)];
    [self.bgView addConstraint:sobotLayoutPaddingBottom(0, self.logoView, self.logoViewBgView)];
    [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.logoView, self.logoViewBgView)];

    
    [self.bgView addConstraint:sobotLayoutPaddingTop(0, self.groupBgView, self.bgView)];
    _layoutGroupLeft = sobotLayoutPaddingLeft(0, self.groupBgView, self.bgView);
    [self.bgView addConstraint:_layoutGroupLeft];
    [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.groupBgView, self.bgView)];
    _layoutGroupHeight = sobotLayoutEqualHeight(0, self.groupBgView, NSLayoutRelationEqual);
    [self.bgView addConstraint:_layoutGroupHeight];
    
    [self.groupBgView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingHSpace, self.groupView, self.groupBgView)];
    [self.groupBgView addConstraint:sobotLayoutPaddingRight(-ZCChatPaddingHSpace+1, self.groupView, self.groupBgView)];
    [self.groupBgView addConstraint:sobotLayoutPaddingTop(0, self.groupView, self.groupBgView)];
    [self.groupBgView addConstraint:sobotLayoutPaddingBottom(0, self.groupView, self.groupBgView)];
    
    // collectionView 和分组一样
    [self.bgView addConstraint:sobotLayoutMarginTop(1, self.collectionView, self.groupBgView)];
    [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.collectionView, self.groupBgView)];
    [self.bgView addConstraint:sobotLayoutPaddingLeft(0, self.collectionView, self.groupBgView)];
    
    _layoutCollectionHeight = sobotLayoutEqualHeight(0, self.collectionView, NSLayoutRelationEqual);
    [self.bgView addConstraint:_layoutCollectionHeight];
    
    
    // lookMore  这里需要显示线条的时候 间距 ——+1
    _layoutLookMoreTop = sobotLayoutMarginTop(0, self.btnLookMore, self.collectionView);
    [self.bgView addConstraint:_layoutLookMoreTop];
    [self.bgView addConstraint:sobotLayoutPaddingLeft(0, self.btnLookMore, self.groupBgView)];
    [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.btnLookMore, self.groupBgView)];
    _layoutLookMoreHeight = sobotLayoutEqualHeight(0, self.btnLookMore, NSLayoutRelationEqual);
    [self.bgView addConstraint:_layoutLookMoreHeight];
    [self.bgView addConstraint:sobotLayoutPaddingBottom(-8, self.btnLookMore, self.bgView)];
    
    
    // 这里需要计算宽度
    NSString *tip = SobotKitLocalString(@"换一批");
    CGFloat w1 = [SobotUITools getWidthContain:tip font:SobotFont14 Height:22];
    // 左右间距
    w1 = w1 + 14 + 4;
    if ([tip isEqualToString:@"换一批"]) {
        
    }
    [self.btnLookMore addConstraint:sobotLayoutEqualCenterX(0, _moreBgView, self.btnLookMore)];
    [self.btnLookMore addConstraint:sobotLayoutEqualCenterY(0, _moreBgView, self.btnLookMore)];
    self.moreBgW = sobotLayoutEqualWidth(w1, _moreBgView, NSLayoutRelationEqual);
    [self.btnLookMore addConstraint:self.moreBgW];
    self.moreBgH = sobotLayoutEqualHeight(22, _moreBgView, NSLayoutRelationEqual);
    [self.btnLookMore addConstraint:self.moreBgH];
    
    self.moreIconH = sobotLayoutEqualHeight(12, _moreIcon, NSLayoutRelationEqual);
    self.moreIconW = sobotLayoutEqualWidth(14, _moreIcon, NSLayoutRelationEqual);
    [_moreBgView addConstraint:self.moreIconW];
    [_moreBgView addConstraint:self.moreIconH];
    
    [_moreBgView addConstraint:sobotLayoutPaddingLeft(0, _moreIcon, _moreBgView)];
    [_moreBgView addConstraint:sobotLayoutEqualCenterY(0, _moreIcon, _moreBgView)];
    
    [_moreBgView addConstraint:sobotLayoutMarginLeft(4, _moreLab, _moreIcon)];
    [_moreBgView addConstraint:sobotLayoutEqualCenterY(0, _moreLab, _moreBgView)];
    [_moreBgView addConstraint:sobotLayoutPaddingRight(0, _moreLab, _moreBgView)];
    self.moreLabH = sobotLayoutEqualHeight(22, _moreLab, NSLayoutRelationEqual);
    [_moreBgView addConstraint:self.moreLabH];

}


-(void)refreshData:(SobotButton *) btn{
    int allCount = (int)self.tempModel.robotAnswer.showFaqDocRespVos.count;
    
    self.tempModel.robotAnswer.curFaqPage = self.tempModel.robotAnswer.curFaqPage + 1;
    
    if(self.tempModel.robotAnswer.curFaqPage*self.tempModel.robotAnswer.guidePageCount >= allCount){
        self.tempModel.robotAnswer.curFaqPage = 0;
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeNewDataGroup text:@"" obj:nil];
    }
}


#pragma mark -- 父类的方法
-(void)initDataToView:(SobotChatMessage *)message time:(NSString *)showTime{
    [super initDataToView:message time:showTime];
    
    self.tempModel = message;
    self.ivHeader.hidden = YES;
    self.lblNickName.hidden = YES;
    self.lblSugguest.hidden = YES;
    self.ivBgView.hidden = YES;
    
    
    // 展示类型:1-问题列表,2-分组加问题列表,3-业务加分组加问题列表
    int showType = message.robotAnswer.showType;
    _layoutLookMoreHeight.constant = 38; // 默认展示
    _moreIconH.constant = 12;
    _moreIconW.constant = 14;
    _moreBgH.constant = 22;
    _moreLabH.constant = 22;
    
    _btnLookMore.enabled = NO;
    [_btnLookMore setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [_btnLookMore setImage:[SobotUITools getSysImageByName:@""] forState:UIControlStateNormal];
//    _btnLookMore.hidden = YES;
    _layoutBgViewTop.constant = 0;
    if(showType == 1){
        _layoutGroupHeight.constant = 0;
        _layoutBusinessHeight.constant = 0;
        _groupLineViewH.constant = 0;
//        _layoutViewH.constant = 0;
        message.robotAnswer.showFaqDocRespVos = message.robotAnswer.faqDocRespVos;
        if(message.robotAnswer.faqDocRespVos.count <=5){
            _layoutLookMoreHeight.constant = 0; // 默认展示
            _moreIconH.constant = 0;
            _moreIconW.constant = 0;
            _moreBgH.constant = 0;
            _moreLabH.constant = 0;
        }
    }
    else if(showType == 2){
        _layoutBusinessHeight.constant = 0;
        _groupLineViewH.constant = 0.5;
//        _layoutViewH.constant = 0;
        _layoutGroupHeight.constant = 44;
        
        [self createGroupItems];
        NSArray *groups = message.robotAnswer.groupRespVos;
        if([groups isKindOfClass:[NSArray class]] && groups.count > 0){
            NSDictionary *item = groups[message.robotAnswer.curGroupPage];
            message.robotAnswer.showFaqDocRespVos = item[@"faqDocRespVos"];
        }
    }else if(showType == 3){
        _groupLineViewH.constant = 0.5;
        _layoutGroupHeight.constant = 44;
        _layoutBusinessHeight.constant = 90;
//        _layoutViewH.constant = 90;
        _layoutBgViewTop.constant = ZCChatMarginVSpace;
        
        
        NSArray *business = message.robotAnswer.businessLineRespVos;
        if([business isKindOfClass:[NSArray class]] && business.count > 0){
            NSDictionary *item = business[message.robotAnswer.curBusinessPage];
            if(!sobotIsNull(item)){
                message.robotAnswer.imgUrl = item[@"imgUrl"];
                // 把当前显示的business下的group赋值给robotAnswer
                // 这里每个item 的 guidePageCount 都不同
                message.robotAnswer.groupRespVos = item[@"groupRespVos"];
                if (sobotConvertToString(message.robotAnswer.imgUrl).length <=0) {
                    // 没有图片才有效，有图片会拉伸图片
                    message.robotAnswer.guidePageCount = [sobotConvertToString([item objectForKey:@"guidePageCount"]) intValue];
                }
                NSArray *groups = message.robotAnswer.groupRespVos;
                if([groups isKindOfClass:[NSArray class]] && groups.count > 0){
                    NSDictionary *item = groups[message.robotAnswer.curGroupPage];
                    // 把当前显示的group下的faq赋值给robotAnswer
                    message.robotAnswer.showFaqDocRespVos = item[@"faqDocRespVos"];
                }else{
                    message.robotAnswer.showFaqDocRespVos = item[@"faqDocRespVos"];
                    
                }
            }
        }
        
        
        [self createBusinessItems];
        if(!sobotIsNull(message.robotAnswer.groupRespVos)&&[message.robotAnswer.groupRespVos isKindOfClass:[NSArray class]]){
            [self createGroupItems];
        }else{
            _layoutGroupHeight.constant = 0;
            
        }
    }
    
    
    [_listArray removeAllObjects];
    [_collectionView reloadData];
    int allCount = (int)message.robotAnswer.showFaqDocRespVos.count;
//    _btnLookMore.hidden = YES;
    _layoutLookMoreTop.constant = 0;
    int pageSize = message.robotAnswer.guidePageCount;
    if(allCount > pageSize){
//        _btnLookMore.hidden = NO;
//        [_btnLookMore setImage:SobotKitGetImage(@"zcicon_refresh") forState:0];
//        [_btnLookMore setBackgroundColor:[ZCUIKitTools zcgetChatBackgroundColor]];
//        [_btnLookMore setTitle:[NSString stringWithFormat:@"%@",SobotKitLocalString(@"换一批")] forState:UIControlStateNormal];
        [_btnLookMore setTitleColor:UIColorFromKitModeColor(SobotColorTextSub1) forState:0];
        _layoutLookMoreHeight.constant = 38;
        
        _moreIconH.constant = 12;
        _moreIconW.constant = 14;
        _moreBgH.constant = 22;
        _moreLabH.constant = 22;
        
        _layoutLookMoreTop.constant = 0;
        _btnLookMore.enabled = YES;
//        _btnLookMore.hidden = NO;
        int startNum = message.robotAnswer.curFaqPage*pageSize;
        int endNum = (startNum + pageSize)>allCount ? allCount:(startNum+pageSize);
        for (int i=startNum; i<endNum;i++) {
            [_listArray addObject:message.robotAnswer.showFaqDocRespVos[i]];
        }
    }else{
        // 不需要显示换一组
        _layoutLookMoreTop.constant = 0;
        _layoutLookMoreHeight.constant = 0;
        _moreIconH.constant = 0;
        _moreLabH.constant = 0;
        _moreIconW.constant = 0;
        _moreBgH.constant = 0;
        if([message.robotAnswer.showFaqDocRespVos isKindOfClass:[NSArray class]]){
            // 处理异常
//            *** -[NSMutableArray addObjectsFromArray:]: array argument is not an NSArray
            [_listArray addObjectsFromArray:message.robotAnswer.showFaqDocRespVos];
        }
    }
    
    // logo图片
    if(sobotConvertToString(message.robotAnswer.imgUrl).length == 0){
        _layoutLogoBgViewWidth.constant = 0;
        _layoutGroupLeft.constant = 0;
        
    }else{
        _layoutLogoBgViewWidth.constant = 80;
        _layoutGroupLeft.constant = 0.5+80;
        [_logoView setUrl:[NSURL URLWithString:sobotConvertToString(message.robotAnswer.imgUrl)] autoLoading:YES];
    }
    
    
    
    CGFloat itemHeight = 38;
    if(_listArray.count == 0){
        itemHeight = 0;
        _layoutCollectionHeight.constant = 0;
        // 图片是固定高度  有图片 右边也跟着铺满  有分组272 无分组233
        if (sobotConvertToString(message.robotAnswer.imgUrl).length > 0) {
//            _layoutCollectionHeight.constant = 44*5 + 5;
            _layoutCollectionHeight.constant = 38*5 + 8;
        }
    }else{
        if(_layoutLogoBgViewWidth.constant == 0){
            if(allCount > pageSize){
//                _layoutCollectionHeight.constant = itemHeight * pageSize + (pageSize-1)*1;
                _layoutCollectionHeight.constant = itemHeight * pageSize  + 8;
            }else{
//                _layoutCollectionHeight.constant = itemHeight * _listArray.count + (_listArray.count-1)*1;
                _layoutCollectionHeight.constant = itemHeight * _listArray.count  + 8;
            }
        }else{
//            _layoutCollectionHeight.constant = 44*5 + 5;
            _layoutCollectionHeight.constant = 38*5  + 8;
            if (sobotConvertToString(message.robotAnswer.imgUrl).length > 0 && _layoutLookMoreHeight.constant == 0) {
                // 有图片多加一个换一组的高度
                _layoutCollectionHeight.constant = 38*6 + 8;
            }
        }
    }
    
    
    
    
    // invalidate之前的layout，这个很关键
    [self.collectionView.collectionViewLayout invalidateLayout];
    // 一定要重新设置，否则尺寸不生效     sobotConvertToString(message.robotAnswer.imgUrl).length == 0
    // _layoutGroupLeft.constant 替换掉之前的计算方式，直接获取要减去的宽度，防止约束还没有及时刷新导致 宽度计算不及时
    contentWidth = self.viewWidth - ZCChatMarginHSpace*2 - (sobotConvertToString(message.robotAnswer.imgUrl).length == 0 ? 0 :80.5);
    self.layout.itemSize = CGSizeMake(contentWidth , itemHeight);
    self.itemSizeHeight = itemHeight;
    // 这里我们使用重写systemLayoutSizeFittingSize的方式
    [self.collectionView layoutIfNeeded];
    
    [self.bgView layoutIfNeeded];
    
    [self.collectionView reloadData];
    
    if(_layoutLogoBgViewWidth.constant > 0){
        UIBezierPath *maskPath1 = [UIBezierPath bezierPathWithRoundedRect:self.logoViewBgView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(5,5)];
        //创建 layer
        CAShapeLayer *maskLayer1 = [[CAShapeLayer alloc] init];
        maskLayer1.frame = self.logoViewBgView.bounds;
        //赋值
        maskLayer1.path = maskPath1.CGPath;
        self.logoViewBgView.layer.mask = maskLayer1;
    }
}


-(void)updateCollectionViewItem{
    // invalidate之前的layout，这个很关键
    [self.collectionView.collectionViewLayout invalidateLayout];
    // 一定要重新设置，否则尺寸不生效
//    contentWidth = ScreenWidth - ZCChatMarginHSpace*2 -_layoutGroupLeft.constant;
    contentWidth = ScreenWidth - ZCChatMarginHSpace*2 - (sobotConvertToString(self.tempModel.robotAnswer.imgUrl).length == 0 ? 0 :80.5);
    self.layout.itemSize = CGSizeMake(contentWidth , self.itemSizeHeight);
    // 这里我们使用重写systemLayoutSizeFittingSize的方式
    [self.collectionView layoutIfNeeded];
    [self.bgView layoutIfNeeded];
}

#pragma mark -- 添加渐变色和颜色
- (void)addGradientToView:(UIView *)view colors:(NSArray *)colors{
    // 创建渐变层
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = view.bounds;
    // 设置渐变色数组（从左到右）
    if (colors) {
        gradientLayer.colors = colors;
    }else{
        gradientLayer.colors = @[
            (__bridge id)UIColorFromKitModeColorAlpha(SobotColorBgMainDark1, 0.1).CGColor,   // 左侧颜色
            (__bridge id)UIColorFromKitModeColorAlpha(SobotColorBgMainDark1, 0.5).CGColor,
            (__bridge id)UIColorFromKitModeColor(SobotColorBgMainDark1).CGColor   // 右侧颜色
        ];
    }
    // 设置颜色渐变方向（从左到右）
    gradientLayer.startPoint = CGPointMake(0, 0.5); // 左侧
    gradientLayer.endPoint = CGPointMake(1, 0.5);   // 右侧
    // 添加渐变层到 View
    [view.layer insertSublayer:gradientLayer atIndex:0];
}
    
- (void)addGradientToView:(UIView *)view {
    [self addGradientToView:view colors:nil];
}



#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _listArray.count;
}
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//    return CGSizeMake(collectionView.frame.size.width, 44);
//}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);//分别为上、左、下、右
}

- ( UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [collectionView dequeueReusableCellWithReuseIdentifier:@"ZCChatHotCollectionCell" forIndexPath:indexPath];
}

// 点击发送消息
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //    NSLog(@" 点击水平 item的 事件 %@",indexPath);
//    NSDictionary * model = self.tempModel.robotAnswer.showFaqDocRespVos[indexPath.row];
    NSDictionary *model = _listArray[indexPath.row];
    if (self.tempModel.isHistory) {
        return;
    }
    NSString * question = sobotConvertToString(model[@"questionName"]);
    NSString *fromEnum = @"";
    // 发送点击消息
//    内部知识库 fromEnum=4，机器人知识库=3，普通问答=5（机器人知识库结果有顶踩转人工，其他没有）
//    4.1.7修改
    /**
     1-常见问题机器人知识库类型
     2-常见问题内部知识库类型
     3-快捷菜单机器人知识库
     4-快捷菜单内部知识库
     5-快捷菜单发消息
     */
    if([sobotConvertToString([model objectForKey:@"from"]) intValue]== 1){
        fromEnum = @"1";
    }else if([sobotConvertToString([model objectForKey:@"from"]) intValue]== 2){
        fromEnum = @"2";
    }
    
    NSDictionary * dict = @{@"question":question,@"docId":sobotConvertToString(model[@"faqDocRelId"]),@"requestText":question,@"title":question,@"ishotguide":@"1",@"fromEnum":fromEnum};

    if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]) {
        [self.delegate cellItemClick:nil type:ZCChatCellClickTypeCollectionSendMsg text:@"" obj:dict];
    }
    
    
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary  *model = _listArray[indexPath.row];
    
    ZCChatHotCollectionCell * vcell = (ZCChatHotCollectionCell *)cell;
    
    
    NSString * title = sobotConvertToString(model[@"questionName"]);
    
    NSDictionary * dict = @{
                            @"summary":@"",
                            @"tag":@"",
                            @"label":@"",
                            @"title":title,
                            @"thumbnail":@""
                            };
 
    
    [vcell configureCellWithPostURL:dict message:self.tempModel];
    
    
}



-(ZCLibConfig *)getCurConfig{
    return [[ZCPlatformTools sharedInstance] getPlatformInfo].config;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)createGroupItems{
    [_groupView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIButton *preButton = nil;
    int i = 0;
    for (NSDictionary *item in self.tempModel.robotAnswer.groupRespVos) {
        SobotButton * buttons = (SobotButton*)[SobotUITools createZCButton];
        buttons.obj = item;
        buttons.tag = i;
        buttons.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [buttons.titleLabel setBackgroundColor:[UIColor clearColor]];
        [buttons addTarget:self action:@selector(buttonGroupClick:) forControlEvents:UIControlEventTouchUpInside];
        [buttons setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 2, 0)];
        [buttons setTitle:SobotKitLocalString(sobotConvertToString(item[@"groupName"])) forState:UIControlStateNormal];
//        [buttons setTitleColor:[ZCUIKitTools zcgetLeftChatTextColor] forState:UIControlStateNormal];
//        [buttons setTitleColor:[ZCUIKitTools zcgetServerConfigBtnBgColor] forState:UIControlStateHighlighted];
//        [buttons setTitleColor:[ZCUIKitTools zcgetServerConfigBtnBgColor] forState:UIControlStateSelected];
        
        [buttons setTitleColor:UIColorFromKitModeColor(SobotColorTextSub) forState:UIControlStateNormal];
        [buttons setTitleColor:[ZCUIKitTools zcgetLeftChatTextColor] forState:UIControlStateHighlighted];
        [buttons setTitleColor:[ZCUIKitTools zcgetLeftChatTextColor] forState:UIControlStateSelected];
        buttons.titleLabel.font = SobotFont14;
        [_groupView addSubview:buttons];
        [_groupView addConstraint:sobotLayoutEqualHeight(44, buttons, NSLayoutRelationEqual)];
        [_groupView addConstraint:sobotLayoutPaddingBottom(0, buttons, _groupView)];
        [_groupView addConstraint:sobotLayoutPaddingTop(0, buttons, _groupView)];
        if(sobotIsNull(preButton)){
            [_groupView addConstraint:sobotLayoutPaddingLeft(0, buttons, _groupView)];
        }else{
            [_groupView addConstraint:sobotLayoutMarginLeft(SobotSpace20, buttons, preButton)];
        }
        
        UIView *lineView = [[UIView alloc] init];
        lineView.tag = 1;
        [lineView setBackgroundColor:[ZCUIKitTools zcgetServerConfigBtnBgColor]];
        [buttons addSubview:lineView];
        [buttons addConstraint:sobotLayoutEqualHeight(2, lineView, NSLayoutRelationEqual)];
        [buttons addConstraint:sobotLayoutPaddingLeft(0, lineView, buttons)];
        [buttons addConstraint:sobotLayoutPaddingRight(0, lineView, buttons)];
        [buttons addConstraint:sobotLayoutPaddingBottom(0, lineView, buttons)];
        lineView.hidden = YES;
        
        
        if(i== self.tempModel.robotAnswer.curGroupPage){
            buttons.selected = YES;
            lineView.hidden = NO;
            
            buttons.titleLabel.font = SobotFontBold14;
            checkGroupBtn = buttons;
            
//            [_groupView layoutIfNeeded];
            
            
        }
        preButton = buttons;
        i = i+1;
    }
    
    
    if(preButton){
        [_groupView addConstraint:sobotLayoutPaddingRight(0, preButton, _groupView)];
    }
    
    _groupColorView = ({
        UIImageView *iv = [[UIImageView alloc]init];
        [_groupBgView addSubview:iv];
        [_groupBgView addConstraint:sobotLayoutEqualHeight(44, iv, NSLayoutRelationEqual)];
        [_groupBgView addConstraint:sobotLayoutPaddingTop(0, iv, _groupBgView)];
        self.groupColorViewW = sobotLayoutEqualWidth(24, iv, NSLayoutRelationEqual);
        [_groupBgView addConstraint:self.groupColorViewW];
        [_groupBgView addConstraint:sobotLayoutPaddingRight(0, iv, _groupBgView)];
        [iv setImage:SobotKitGetImage(@"zcicon_fzbg_color")];
        iv.layer.masksToBounds = YES;
        iv.layer.cornerRadius = 4;
        iv;
    });
    
    _leftGroupColorView = ({
        UIImageView *iv = [[UIImageView alloc]init];
        [_groupBgView addSubview:iv];
        [_groupBgView addConstraint:sobotLayoutEqualHeight(44, iv, NSLayoutRelationEqual)];
        [_groupBgView addConstraint:sobotLayoutPaddingTop(0, iv, _groupBgView)];
        self.leftGroupColorViewW = sobotLayoutEqualWidth(24, iv, NSLayoutRelationEqual);
        [_groupBgView addConstraint:self.leftGroupColorViewW];
        [_groupBgView addConstraint:sobotLayoutPaddingLeft(0, iv, _groupBgView)];
        [iv setImage:SobotKitGetImage(@"zcicon_fzbg_color")];
        iv.hidden = YES;
        iv;
    });
    _leftGroupColorView.transform = CGAffineTransformMakeRotation(M_PI);  // M_PI_4 是 45 度
    
    [ZCUIKitTools setViewRTLtransForm:_businessView];
}

-(void)buttonGroupClick:(SobotButton *) btn{
    int tag = (int)btn.tag;
    
    UIView *lineView = [btn viewWithTag:1];
    if(self.tempModel.robotAnswer.curGroupPage == tag){
        if(checkGroupBtn){
            checkGroupBtn.titleLabel.font = SobotFont14;
        }
        btn.selected = YES;
        lineView.hidden = NO;
        checkGroupBtn = btn;
        
        btn.titleLabel.font = SobotFontBold14;
        return;
    }
    else{
        self.tempModel.robotAnswer.curGroupPage = tag;
        if(checkGroupBtn){
            checkGroupBtn.selected = NO;
            UIView *lineView1 = [btn viewWithTag:1];
            lineView1.hidden = YES;
            
            checkGroupBtn.titleLabel.font = SobotFont14;
        }
        
        lineView.hidden = NO;
        btn.selected = YES;
        
        self.tempModel.robotAnswer.curFaqPage = 0;
        self.tempModel.robotAnswer.showFaqDocRespVos = @[];
        
        [ZCUIKitTools addBottomBorderWithColor:[ZCUIKitTools zcgetButtonThemeBgColor] andWidth:2 withView:btn];
        checkGroupBtn = btn;
        
        checkGroupBtn.titleLabel.font = SobotFontBold14;
//        _layoutLineLeft.constant = CGRectGetMaxX(btn.frame);
//        _layoutLineWidth.constant = CGRectGetWidth(btn.frame);
        // 刷新页面
        if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
            [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeNewDataGroup text:@"" obj:nil];
        }
    }
}

-(void)buttonClick:(SobotButton *) btn{
    int tag = (int)btn.tag;
    NSDictionary *item = btn.obj;
    if([item[@"hasGroup"] intValue] == 2){
        // 说明是链接
        // 刷新页面
        if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
            [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeOpenURL text:item[@"businessLineUrl"] obj:sobotConvertToString(item[@"businessLineUrl"])];
        }
        return;
    }
    
    if(self.tempModel.robotAnswer.curBusinessPage == tag){
        return;
    }
    else{
        self.tempModel.robotAnswer.showFaqDocRespVos = @[];
        self.tempModel.robotAnswer.curBusinessPage = tag;
        self.tempModel.robotAnswer.curGroupPage = 0;
        self.tempModel.robotAnswer.curFaqPage = 0;
        // 刷新页面
        if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
            [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeNewDataGroup text:@"" obj:nil];
        }
    }
}


-(void)createBusinessItems{
    [_businessView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIView *preButton = nil;
    NSMutableArray *btns = [[NSMutableArray alloc] init];
    int i = 0;
    for (NSDictionary *item in self.tempModel.robotAnswer.businessLineRespVos) {
        UIView *buttons = [self createItemMenuButton:item tag:i];
        if(sobotIsNull(preButton)){
            [_businessView addConstraint:sobotLayoutPaddingLeft(2, buttons, _businessView)];
        }else{
            [_businessView addConstraint:sobotLayoutMarginLeft(10, buttons, preButton)];
        }
        [btns addObject:buttons];
        preButton = buttons;
        i = i+1;
    }
    if(preButton){
        [_businessView addConstraint:sobotLayoutPaddingRight(-ZCChatCellItemSpace, preButton, _businessView)];
    }
    for(UIView *buttons in btns){
        // 这里高度要减去4个，不然阴影不显示
        [buttons addConstraint:sobotLayoutEqualHeight(self.layoutBusinessHeight.constant-4, buttons, NSLayoutRelationEqual)];
    }
    _busColorView = ({
        UIImageView *iv = [[UIImageView alloc]init];
        [self.contentView addSubview:iv];
        [self.contentView addConstraint:sobotLayoutPaddingRight(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingTop(ZCChatMarginVSpace +2, iv, self.contentView)];
        self.busColorViewW = sobotLayoutEqualWidth(24+16, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.busColorViewW];
        self.busColorViewH = sobotLayoutEqualHeight(self.layoutBusinessHeight.constant-4, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.busColorViewH];
        [iv setImage:SobotKitGetImage(@"zcicon_flbg_color")];
//        iv.backgroundColor = UIColor.redColor;
        iv;
    });
    
    _leftBusColorView = ({
        UIImageView *iv = [[UIImageView alloc]init];
        [self.contentView addSubview:iv];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingTop(ZCChatMarginVSpace +2, iv, self.contentView)];
        self.lbusColorViewW = sobotLayoutEqualWidth(24+16, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.lbusColorViewW];
        self.lbusColorViewH = sobotLayoutEqualHeight(self.layoutBusinessHeight.constant-4, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.lbusColorViewH];
        [iv setImage:SobotKitGetImage(@"zcicon_flbg_color")];
        iv.hidden = YES;
        iv;
    });
    _leftBusColorView.transform = CGAffineTransformMakeRotation(M_PI);
    
    
}
// 上下
-(UIView *)createItemMenuButton:(NSDictionary *) menu tag:(int)tag{
    ZCShadowRadiusView *buttons = [[ZCShadowRadiusView alloc] init];
    buttons.userInteractionEnabled = YES;
//    buttons.backgroundColor = UIColorFromModeColor(SobotColorBgMain);
    [_businessView addSubview:buttons];
    [_businessView addConstraint:sobotLayoutEqualWidth(82, buttons, NSLayoutRelationEqual)];
    [_businessView addConstraint:sobotLayoutPaddingTop(2, buttons, _businessView)];
//    NSLayoutConstraint *btm = sobotLayoutPaddingBottom(0, buttons, _businessView);
//    btm.priority = UILayoutPriorityDefaultHigh;
//    [_businessView addConstraint:btm];
    
    SobotImageView *iv = [[SobotImageView alloc] init];
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [iv loadWithURL:[NSURL URLWithString:sobotConvertToString(sobotConvertToString(menu[@"titleImgUrl"]))]placeholer:nil showActivityIndicatorView:NO];
    [buttons addSubview:iv];

    UILabel *label = [[UILabel alloc] init];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:SobotFont14];
    [label setTextColor:UIColorFromModeColor(SobotColorTextMain)];
    label.numberOfLines = 0;
    
    CGFloat h = [SobotUITools setLabel:label withText:sobotConvertToString(menu[@"businessLineName"]) lineHeight:[ZCUIKitTools zcgetChatLineSpacing] width:82-12];
    [buttons addSubview:label];
    
    CGFloat itemH = 72 + h;
    if(itemH < 90){
        itemH = 90;
    }
    if(self.layoutBusinessHeight.constant < itemH){
        self.layoutBusinessHeight.constant = itemH;
    }


    SobotButton * btnClick = (SobotButton*)[SobotUITools createZCButton];
    btnClick.obj = menu;
    btnClick.tag = tag;
    btnClick.backgroundColor = UIColor.clearColor;
    [btnClick addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [buttons addSubview:btnClick];

    [buttons addConstraint:sobotLayoutEqualHeight(40, iv, NSLayoutRelationEqual)];
    [buttons addConstraint:sobotLayoutEqualWidth(40, iv, NSLayoutRelationEqual)];
    [buttons addConstraint:sobotLayoutPaddingTop(12, iv, buttons)];
    [buttons addConstraint:sobotLayoutEqualCenterX(0, iv, buttons)];

    [buttons addConstraint:sobotLayoutMarginTop(8, label, iv)];
    [buttons addConstraint:sobotLayoutPaddingLeft(6, label, buttons)];
    [buttons addConstraint:sobotLayoutPaddingRight(-6, label, buttons)];
//    [buttons addConstraint:sobotLayoutEqualHeight(20, label, NSLayoutRelationGreaterThanOrEqual)];
//    [buttons addConstraint:sobotLayoutPaddingBottom(-12, label, buttons)];
    [buttons addConstraints:sobotLayoutPaddingWithAll(0, 0, 0, 0,btnClick, buttons)];
    
    buttons.layer.masksToBounds = NO;
    return buttons;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.tag == 20002) {
        if (!sobotIsNull(self.leftGroupColorView)) {
            self.leftGroupColorView.hidden = NO;
        }
    }
    if (scrollView.tag == 20001) {
        if (!sobotIsNull(self.leftBusColorView)) {
            self.leftBusColorView.hidden = NO;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    NSLog(@"滑动结束（惯性滚动停止）: contentOffset = %@", NSStringFromCGPoint(scrollView.contentOffset));
    if (scrollView.tag == 20002) {
        if (!sobotIsNull(self.leftGroupColorView)) {
            self.leftGroupColorView.hidden = YES;
        }
    }
    if (scrollView.tag == 20001) {
        if (!sobotIsNull(self.leftBusColorView)) {
            self.leftBusColorView.hidden = YES;
        }
    }
}


@end
