//
//  ZCChatHotGuideCell.m
//  SobotKit
//
//  Created by zhangxy on 2022/9/21.
//

#import "ZCChatHotGuideCell.h"
#import <SobotCommon/SobotCommon.h>
#import "ZCChatHotCollectionCell.h"

@interface ZCChatHotGuideCell()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>{
    SobotButton *checkGroupBtn;
    CGFloat contentWidth;
}

@property (nonatomic,strong) NSMutableArray * listArray;

@property (nonatomic,strong) UICollectionViewFlowLayout *layout;

@property (nonatomic,strong)  UIScrollView * businessView;
@property (nonatomic,strong)  UIView *logoViewBgView;
@property (nonatomic,strong)  SobotImageView * logoView;
@property (nonatomic,strong)  UIScrollView * groupView;
@property (nonatomic,strong)  UICollectionView * collectionView;
@property (nonatomic,strong)  SobotButton * btnLookMore;
@property (nonatomic,strong)  UIView *groupBgView;

@property (nonatomic,strong)  UIView * bgView;
@property (nonatomic,strong)  NSLayoutConstraint * layoutLogoWidth;
@property (nonatomic,strong)  NSLayoutConstraint * layoutLogoBgViewWidth;
@property (nonatomic,strong)  NSLayoutConstraint * layoutBusinessHeight;
@property (nonatomic,strong)  NSLayoutConstraint * layoutBgViewTop;
@property (nonatomic,strong)  NSLayoutConstraint * layoutGroupLeft;
@property (nonatomic,strong)  NSLayoutConstraint * layoutGroupHeight;
@property (nonatomic,strong)  NSLayoutConstraint * layoutLookMoreHeight;
@property (nonatomic,strong)  NSLayoutConstraint * layoutLookMoreTop;
@property (nonatomic,strong)  NSLayoutConstraint * layoutCollectionHeight;


@end

@implementation ZCChatHotGuideCell


-(void)setupView{
    _listArray = [[NSMutableArray alloc] init];
    _businessView = ({
        UIScrollView *iv = [[UIScrollView alloc] init];
        iv.showsHorizontalScrollIndicator = NO;
        iv.bounces = NO;
        iv.scrollEnabled = YES;
        //    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        iv.backgroundColor = [ZCUIKitTools zcgetChatBackgroundColor];
        [self.contentView addSubview:iv];
        
        iv;
    });
    _bgView = ({
        UIView *iv = [[UIView alloc] init];
//        [iv setBackgroundColor:[ZCUIKitTools zcgetLeftChatColor]];
        [iv setBackgroundColor:[UIColor clearColor]];
        iv.layer.cornerRadius = 10.0f;
        iv.layer.masksToBounds = YES;
//        iv.layer.borderColor = [ZCUIKitTools zcgetLeftChatColor].CGColor;
        iv.layer.borderColor = [UIColor clearColor].CGColor;
        iv.layer.borderWidth = 1.0f;
        [self.contentView addSubview:iv];
        iv;
    });
    
    _logoViewBgView = ({
        UIView *iv = [[UIView alloc]init];
        [self.bgView addSubview:iv];
//        iv.backgroundColor =[ZCUIKitTools zcgetLeftChatColor];
        iv.backgroundColor =UIColor.clearColor;
        [iv.layer setMasksToBounds:YES];
//        iv.layer.cornerRadius = 5.0f;
        iv;
    });
    
    _logoView = ({
        SobotImageView *iv = [[SobotImageView alloc] init];
        [iv setContentMode:UIViewContentModeScaleToFill];
        [iv.layer setMasksToBounds:YES];
        [iv setBackgroundColor:[UIColor clearColor]];
//        [iv setBackgroundColor:UIColorFromKitModeColor(SobotColorWhite)];
//        iv.layer.cornerRadius = 2.0f;
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
        iv.backgroundColor = [ZCUIKitTools zcgetChatBackgroundColor];
//        iv.backgroundColor = [UIColor clearColor];
        [_groupBgView addSubview:iv];
        iv;
    });
        
    _collectionView = ({
        _layout = [UICollectionViewFlowLayout new];
        _layout.itemSize = CGSizeMake(80, 20);
        _layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _layout.minimumLineSpacing = 1;
        
        
        // 12的间隙为 item 到 消息
        UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:_layout];
//        collectionView.backgroundColor = [ZCUIKitTools zcgetChatBottomLineColor];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.scrollEnabled = NO;
        collectionView.scrollsToTop = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.clipsToBounds = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        [collectionView registerClass:[ZCChatHotCollectionCell class] forCellWithReuseIdentifier:@"ZCChatHotCollectionCell"];
        if(sobotGetSystemVersion()>=11){
            collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [_bgView addSubview:collectionView];
        
        collectionView;
    });
    
    _btnLookMore = ({
        SobotButton *iv = [SobotButton buttonWithType:UIButtonTypeCustom];
        [iv setImage:SobotKitGetImage(@"zcicon_refresh") forState:0];
        [iv setBackgroundColor:[ZCUIKitTools zcgetChatBackgroundColor]];
        [iv setTitle:[NSString stringWithFormat:@" %@",SobotKitLocalString(@"换一批")] forState:UIControlStateNormal];
        [iv setTitleColor:UIColorFromKitModeColor(SobotColorTextSub) forState:0];
        [iv addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventTouchUpInside];
        [iv.titleLabel setFont:SobotFont12];
//        iv.layer.cornerRadius = 5;
        iv.layer.masksToBounds = YES;
        [self.bgView addSubview:iv];
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
    
    // 业务
    [self.contentView addConstraint:sobotLayoutPaddingTop(ZCChatMarginVSpace, self.businessView, self.contentView)];
    [self.contentView addConstraint:sobotLayoutPaddingLeft(ZCChatMarginHSpace, self.businessView, self.contentView)];
    [self.contentView addConstraint:sobotLayoutPaddingRight(-ZCChatMarginHSpace, self.businessView, self.contentView)];
    _layoutBusinessHeight = sobotLayoutEqualHeight(0, self.businessView, NSLayoutRelationEqual);
    [self.contentView addConstraint:_layoutBusinessHeight];
    
    
    _bgView.layer.masksToBounds = NO;
    _bgView.layer.borderWidth = 1.0f;
    _bgView.layer.shadowColor = [ZCUIKitTools zcgetChatBottomLineColor].CGColor;
    _bgView.layer.shadowOpacity = 0.9;
    _bgView.layer.shadowRadius = 5;
    _bgView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
    // 分组+内容
    _layoutBgViewTop = sobotLayoutMarginTop(ZCChatMarginVSpace, self.bgView, self.businessView);
    [self.contentView addConstraint:_layoutBgViewTop];
    [self.contentView addConstraint:sobotLayoutPaddingLeft(ZCChatMarginHSpace, self.bgView, self.contentView)];
    [self.contentView addConstraint:sobotLayoutPaddingRight(-ZCChatMarginHSpace, self.bgView, self.contentView)];
    [self.contentView addConstraint:sobotLayoutMarginBottom(-ZCChatCellItemSpace, self.bgView, self.lblSugguest)];
    
    // logoViewBGview
    [self.bgView addConstraint:sobotLayoutPaddingTop(0, self.logoViewBgView, self.bgView)];
    [self.bgView addConstraint:sobotLayoutPaddingLeft(0, self.logoViewBgView, self.bgView)];
    [self.bgView addConstraint:sobotLayoutPaddingBottom(0, self.logoViewBgView, self.btnLookMore)];
//    [self.bgView addConstraint:sobotLayoutEqualHeight(100, self.logoView, NSLayoutRelationEqual)];
    _layoutLogoBgViewWidth = sobotLayoutEqualWidth(0, self.logoViewBgView, NSLayoutRelationEqual);
    [self.bgView addConstraint:_layoutLogoBgViewWidth];
    
    // logoView
    [self.bgView addConstraint:sobotLayoutPaddingTop(0, self.logoView, self.logoViewBgView)];
    [self.bgView addConstraint:sobotLayoutPaddingLeft(0, self.logoView, self.logoViewBgView)];
    [self.bgView addConstraint:sobotLayoutPaddingBottom(0, self.logoView, self.logoViewBgView)];
//    [self.bgView addConstraint:sobotLayoutEqualHeight(100, self.logoView, NSLayoutRelationEqual)];
    _layoutLogoWidth = sobotLayoutEqualWidth(0, self.logoView, NSLayoutRelationEqual);
    [self.bgView addConstraint:_layoutLogoWidth];
    
    // 分组
//    [self.bgView addConstraint:sobotLayoutPaddingTop(0, self.groupView, self.bgView)];
//    _layoutGroupLeft = sobotLayoutPaddingLeft(0, self.groupView, self.bgView);
//    [self.bgView addConstraint:_layoutGroupLeft];
//    [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.groupView, self.bgView)];
//    _layoutGroupHeight = sobotLayoutEqualHeight(0, self.groupView, NSLayoutRelationEqual);
//    [self.bgView addConstraint:_layoutGroupHeight];
    
    [self.bgView addConstraint:sobotLayoutPaddingTop(0, self.groupBgView, self.bgView)];
    _layoutGroupLeft = sobotLayoutPaddingLeft(0, self.groupBgView, self.bgView);
    [self.bgView addConstraint:_layoutGroupLeft];
    [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.groupBgView, self.bgView)];
    _layoutGroupHeight = sobotLayoutEqualHeight(0, self.groupBgView, NSLayoutRelationEqual);
    [self.bgView addConstraint:_layoutGroupHeight];
    
    [self.groupBgView addConstraint:sobotLayoutPaddingLeft(8, self.groupView, self.groupBgView)];
    [self.groupBgView addConstraint:sobotLayoutPaddingRight(-8, self.groupView, self.groupBgView)];
    [self.groupBgView addConstraint:sobotLayoutPaddingTop(0, self.groupView, self.groupBgView)];
    [self.groupBgView addConstraint:sobotLayoutPaddingBottom(0, self.groupView, self.groupBgView)];
    
    // collectionView
    [self.bgView addConstraint:sobotLayoutMarginTop(1, self.collectionView, self.groupBgView)];
    [self.bgView addConstraint:sobotLayoutPaddingLeft(0, self.collectionView, self.groupBgView)];
    [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.collectionView, self.bgView)];
    _layoutCollectionHeight = sobotLayoutEqualHeight(0, self.collectionView, NSLayoutRelationEqual);
    [self.bgView addConstraint:_layoutCollectionHeight];
    
    
    // lookMore
    _layoutLookMoreTop = sobotLayoutMarginTop(1, self.btnLookMore, self.collectionView);
    [self.bgView addConstraint:_layoutLookMoreTop];
    [self.bgView addConstraint:sobotLayoutPaddingLeft(0, self.btnLookMore, self.groupBgView)];
    [self.bgView addConstraint:sobotLayoutPaddingRight(-1, self.btnLookMore, self.bgView)];
    _layoutLookMoreHeight = sobotLayoutEqualHeight(0, self.btnLookMore, NSLayoutRelationEqual);
    [self.bgView addConstraint:_layoutLookMoreHeight];
    [self.bgView addConstraint:sobotLayoutPaddingBottom(-1, self.btnLookMore, self.bgView)];
    
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
    
    
    // 展示类型:1-问题列表,2-分组加问题列表,3-业务加分组加问题列表
    int showType = message.robotAnswer.showType;
    _layoutLookMoreHeight.constant = 44; // 默认展示
    _btnLookMore.enabled = NO;
    [_btnLookMore setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [_btnLookMore setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    _layoutBgViewTop.constant = 0;
    if(showType == 1){
        _layoutGroupHeight.constant = 0;
        _layoutBusinessHeight.constant = 0;
        message.robotAnswer.showFaqDocRespVos = message.robotAnswer.faqDocRespVos;
    }
    else if(showType == 2){
        _layoutBusinessHeight.constant = 0;
        _layoutGroupHeight.constant = 44;
        
        [self createGroupItems];
        NSArray *groups = message.robotAnswer.groupRespVos;
        if([groups isKindOfClass:[NSArray class]] && groups.count > 0){
            NSDictionary *item = groups[message.robotAnswer.curGroupPage];
            message.robotAnswer.showFaqDocRespVos = item[@"faqDocRespVos"];
        }
    }else if(showType == 3){
        _layoutGroupHeight.constant = 44;
        _layoutBusinessHeight.constant = 88;
        _layoutBgViewTop.constant = ZCChatMarginVSpace;
        
        
        NSArray *business = message.robotAnswer.businessLineRespVos;
        if([business isKindOfClass:[NSArray class]] && business.count > 0){
            NSDictionary *item = business[message.robotAnswer.curBusinessPage];
            if(!sobotIsNull(item)){
                message.robotAnswer.imgUrl = item[@"imgUrl"];
                // 把当前显示的business下的group赋值给robotAnswer
                message.robotAnswer.groupRespVos = item[@"groupRespVos"];
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
    
    // logo图片
    if(sobotConvertToString(message.robotAnswer.imgUrl).length == 0){
        _layoutLogoWidth.constant = 0;
        _layoutLogoBgViewWidth.constant = 0;
        _layoutGroupLeft.constant = 0;
    }else{
        _layoutLogoWidth.constant = 80;
        _layoutLogoBgViewWidth.constant = 80;
        _layoutGroupLeft.constant = 0.5+80;
        [_logoView setUrl:[NSURL URLWithString:sobotConvertToString(message.robotAnswer.imgUrl)] autoLoading:YES];
    }
    
    [_listArray removeAllObjects];
    int allCount = (int)message.robotAnswer.showFaqDocRespVos.count;
//    _btnLookMore.hidden = YES;
    _layoutLookMoreTop.constant = 0;
    int pageSize = message.robotAnswer.guidePageCount;
    if(allCount > pageSize){
//        _btnLookMore.hidden = NO;
        [_btnLookMore setImage:SobotKitGetImage(@"zcicon_refresh") forState:0];
        [_btnLookMore setBackgroundColor:[ZCUIKitTools zcgetChatBackgroundColor]];
        [_btnLookMore setTitle:SobotKitLocalString(@"换一批") forState:UIControlStateNormal];
        [_btnLookMore setTitleColor:UIColorFromKitModeColor(SobotColorTextSub) forState:0];
        _layoutLookMoreHeight.constant = 44;
        _layoutLookMoreTop.constant = 1;
        _btnLookMore.enabled = YES;
        int startNum = message.robotAnswer.curFaqPage*pageSize;
        int endNum = (startNum + pageSize)>allCount ? allCount:(startNum+pageSize);
        for (int i=startNum; i<endNum;i++) {
            [_listArray addObject:message.robotAnswer.showFaqDocRespVos[i]];
        }
    }else{
        [_listArray addObjectsFromArray:message.robotAnswer.showFaqDocRespVos];
    }
    CGFloat itemHeight = 44;
    if(_listArray.count == 0){
        itemHeight = 0;
        _layoutCollectionHeight.constant = 0;
        
    }else{
//        _layoutCollectionHeight.constant = itemHeight * _listArray.count + (_listArray.count-1)*1;
        if(_layoutLogoWidth.constant == 0){
            if(allCount > pageSize){
                _layoutCollectionHeight.constant = itemHeight * pageSize + (pageSize-1)*1;
            }else{
                
                _layoutCollectionHeight.constant = itemHeight * _listArray.count + (_listArray.count-1)*1;
            }
        }else{
            _layoutCollectionHeight.constant = itemHeight * 5 ; // 默认5个高度 + 换一组按钮的高度 如果后期要改成动态的高度 将上面的代码打开
        }
    }
    
    // invalidate之前的layout，这个很关键
    [self.collectionView.collectionViewLayout invalidateLayout];
    // 一定要重新设置，否则尺寸不生效
    contentWidth = self.viewWidth - ZCChatMarginHSpace*2 -_layoutGroupLeft.constant;
    self.layout.itemSize = CGSizeMake(contentWidth , itemHeight);
    
    // 这里我们使用重写systemLayoutSizeFittingSize的方式
    [self.collectionView layoutIfNeeded];
    
    [self.bgView layoutIfNeeded];
    CGSize s = CGSizeMake(self.maxWidth,_layoutCollectionHeight.constant + _layoutGroupHeight.constant + _layoutBusinessHeight.constant + _layoutLookMoreHeight.constant);
    
    [self setChatViewBgState:s];
    
    [self.collectionView reloadData];
    self.ivBgView.backgroundColor = UIColor.clearColor;
    
    UIBezierPath *maskPath1 = [UIBezierPath bezierPathWithRoundedRect:self.logoViewBgView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(5,5)];
    //创建 layer
    CAShapeLayer *maskLayer1 = [[CAShapeLayer alloc] init];
    maskLayer1.frame = self.logoViewBgView.bounds;
    //赋值
    maskLayer1.path = maskPath1.CGPath;
    self.logoViewBgView.layer.mask = maskLayer1;
}



#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _listArray.count;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(collectionView.frame.size.width, 44);
}
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
    NSDictionary * model = self.tempModel.robotAnswer.showFaqDocRespVos[indexPath.row];
    
    if (self.tempModel.isHistory) {
        return;
    }
    NSString * question = sobotConvertToString(model[@"questionName"]);
    // 发送点击消息
    
    NSDictionary * dict = @{@"question":question,@"docId":sobotConvertToString(model[@"faqDocRelId"]),@"requestText":question,@"title":question,@"ishotguide":@"1"};

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


-(void)createBusinessItems{
    [_businessView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIView *preButton = nil;
    int i = 0;
    for (NSDictionary *item in self.tempModel.robotAnswer.businessLineRespVos) {
        UIView *buttons = [self createItemMenuButton:item tag:i];
        [_businessView addSubview:buttons];
        [_businessView addConstraints:sobotLayoutSize(65, 85, buttons, NSLayoutRelationEqual)];
        [_businessView addConstraint:sobotLayoutPaddingTop(0, buttons, _businessView)];
        [_businessView addConstraint:sobotLayoutPaddingBottom(0, buttons, _businessView)];
        if(sobotIsNull(preButton)){
            [_businessView addConstraint:sobotLayoutPaddingLeft(0, buttons, _businessView)];
        }else{
            [_businessView addConstraint:sobotLayoutMarginLeft(10, buttons, preButton)];
        }
        preButton = buttons;
        i = i+1;
    }
    if(preButton){
        [_businessView addConstraint:sobotLayoutPaddingRight(-ZCChatCellItemSpace, preButton, _businessView)];
    }
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
        [buttons setTitleColor:[ZCUIKitTools zcgetLeftChatTextColor] forState:UIControlStateNormal];
        [buttons setTitleColor:[ZCUIKitTools zcgetRobotBtnBgColor] forState:UIControlStateHighlighted];
        [buttons setTitleColor:[ZCUIKitTools zcgetRobotBtnBgColor] forState:UIControlStateSelected];
        [buttons.titleLabel setFont:SobotFont14];
        [_groupView addSubview:buttons];
        [_groupView addConstraint:sobotLayoutEqualHeight(44, buttons, NSLayoutRelationEqual)];
        [_groupView addConstraint:sobotLayoutPaddingBottom(0, buttons, _groupView)];
        [_groupView addConstraint:sobotLayoutPaddingTop(0, buttons, _groupView)];
        if(sobotIsNull(preButton)){
            [_groupView addConstraint:sobotLayoutPaddingLeft(ZCChatCellItemSpace, buttons, _groupView)];
        }else{
            [_groupView addConstraint:sobotLayoutMarginLeft(ZCChatMarginHSpace, buttons, preButton)];
        }
        
        UIView *lineView = [[UIView alloc] init];
        lineView.tag = 1;
        [lineView setBackgroundColor:[ZCUIKitTools zcgetRobotBtnBgColor]];
        [buttons addSubview:lineView];
        [buttons addConstraint:sobotLayoutEqualHeight(2, lineView, NSLayoutRelationEqual)];
        [buttons addConstraint:sobotLayoutPaddingLeft(0, lineView, buttons)];
        [buttons addConstraint:sobotLayoutPaddingRight(0, lineView, buttons)];
        [buttons addConstraint:sobotLayoutPaddingBottom(0, lineView, buttons)];
        lineView.hidden = YES;
        
        
        if(i== self.tempModel.robotAnswer.curGroupPage){
            buttons.selected = YES;
            lineView.hidden = NO;
            
            checkGroupBtn = buttons;
            
//            [_groupView layoutIfNeeded];
            
            
        }
        preButton = buttons;
        i = i+1;
    }
    
    
    if(preButton){
        [_groupView addConstraint:sobotLayoutPaddingRight(-ZCChatCellItemSpace, preButton, _groupView)];
    }
}

-(void)buttonGroupClick:(SobotButton *) btn{
    int tag = (int)btn.tag;
    
    UIView *lineView = [btn viewWithTag:1];
    if(self.tempModel.robotAnswer.curGroupPage == tag){
        btn.selected = YES;
        lineView.hidden = NO;
        checkGroupBtn = btn;
        return;
    }
    else{
        self.tempModel.robotAnswer.curGroupPage = tag;
        if(checkGroupBtn){
            checkGroupBtn.selected = NO;
            UIView *lineView1 = [btn viewWithTag:1];
            lineView1.hidden = YES;
        }
        
        lineView.hidden = NO;
        btn.selected = YES;
        
        self.tempModel.robotAnswer.showFaqDocRespVos = @[];
        
        [ZCUIKitTools addBottomBorderWithColor:[ZCUIKitTools zcgetButtonThemeBgColor] andWidth:2 withView:btn];
        checkGroupBtn = btn;
        
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
        // 刷新页面
        if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
            [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeNewDataGroup text:@"" obj:nil];
        }
    }
}

// 上下
-(UIView *)createItemMenuButton:(NSDictionary *) menu tag:(int)tag{
    UIView *buttons = [[UIView alloc] init];
    buttons.userInteractionEnabled = YES;
    buttons.layer.masksToBounds = NO;
    buttons.layer.borderWidth = 1.0f;
    buttons.layer.shadowColor = [ZCUIKitTools zcgetChatBottomLineColor].CGColor;
    buttons.layer.shadowOpacity = 0.9;
    buttons.layer.shadowRadius = 4;
    buttons.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    [buttons setBackgroundColor:[ZCUIKitTools zcgetChatBackgroundColor]];
    buttons.layer.cornerRadius = 5.0f;
    buttons.layer.borderColor = [ZCUIKitTools zcgetLeftChatColor].CGColor;
    
    SobotImageView *iv = [[SobotImageView alloc] init];
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [iv loadWithURL:[NSURL URLWithString:sobotConvertToString(sobotConvertToString(menu[@"titleImgUrl"]))]];
    [buttons addSubview:iv];
    
    UILabel *label = [[UILabel alloc] init];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setText:sobotConvertToString(menu[@"businessLineName"])];
    [label setFont:SobotFont12];
    [label setTextColor:[ZCUIKitTools zcgetTextNolColor]];
    [buttons addSubview:label];
    
    
    SobotButton * btnClick = (SobotButton*)[SobotUITools createZCButton];
    //        [buttons setFrame:CGRectMake((i-1)*60+(i-1)*30, MoreViewHeight/2-itemH/2, 60, itemH)];
//    [buttons setFrame:f];
    btnClick.obj = menu;
    btnClick.tag = tag;
    [btnClick addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [buttons addSubview:btnClick];
    
    
    [buttons addConstraint:sobotLayoutEqualHeight(36, iv, NSLayoutRelationEqual)];
    [buttons addConstraint:sobotLayoutPaddingLeft(14.5, iv, buttons)];
    [buttons addConstraint:sobotLayoutPaddingRight(-14.5, iv, buttons)];
    [buttons addConstraint:sobotLayoutPaddingTop(15, iv, buttons)];
    
    [buttons addConstraint:sobotLayoutMarginTop(10, label, iv)];
    [buttons addConstraint:sobotLayoutPaddingLeft(0, label, buttons)];
    [buttons addConstraint:sobotLayoutPaddingRight(0, label, buttons)];
    [buttons addConstraint:sobotLayoutEqualHeight(20, label, NSLayoutRelationEqual)];
    [buttons addConstraint:sobotLayoutPaddingBottom(-6, label, buttons)];
    
    
    [buttons addConstraints:sobotLayoutPaddingWithAll(0, 0, 0, 0,btnClick, buttons)];
    
    
    return buttons;
}

@end
