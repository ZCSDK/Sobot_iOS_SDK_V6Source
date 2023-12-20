//
//  ZCChatCustomCardVerticalCell.m
//  SobotKit
//
//  Created by zhangxy on 2023/6/13.
//

#import "ZCChatCustomCardVerticalCell.h"

#import "ZCChatCustomCardVCollectionCell.h"
#import "ZCChatCustomCardVNoSendCollectionCell.h"

@interface ZCChatCustomCardVerticalCell()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,ZCChatCustomCardInfoBaseCellDelegate>{
    CGFloat contentWidth;
    CGFloat itemHeight;
}

@property(nonatomic,strong) NSLayoutConstraint *layoutBgWidth;
@property(nonatomic,strong) NSLayoutConstraint *customMT;
@property (strong, nonatomic) UIView *bgView; //
@property (strong, nonatomic) UILabel *labTitle; //标题
@property (strong, nonatomic) UILabel *labDesc; //标题
@property (nonatomic,strong) SobotImageView *logoView;
@property(nonatomic,strong) NSLayoutConstraint *layoutGuideHeight;
@property (nonatomic,strong) UIView *guideView;

@property (nonatomic,strong) UICollectionViewFlowLayout *layout;
@property (nonatomic,strong)  UICollectionView * collectionView;
@property(nonatomic,strong) NSLayoutConstraint *layoutCollectionViewHeight;

@property(nonatomic,strong) NSLayoutConstraint *layoutCusFieldHeight;
@property(nonatomic,strong) NSLayoutConstraint *labDescMT;
@property(nonatomic,strong) NSLayoutConstraint *logoViewEH;
@property(nonatomic,strong) NSLayoutConstraint *layoutCollectTop;
@property (nonatomic,strong) UIView *cusFieldView;// 自定义字段

@property (nonatomic,strong)  UIView *cusButtonView;// 自定义button
@property (nonatomic,strong) UIButton *btnLookMore;
@end

@implementation ZCChatCustomCardVerticalCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self createViews];
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self createViews];
        //设置点击事件
        UITapGestureRecognizer *tapGesturer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bgViewClick:)];
        self.logoView.userInteractionEnabled=YES;
        [self.logoView addGestureRecognizer:tapGesturer];
        
        self.bgView.layer.masksToBounds = YES;
        self.bgView.layer.borderWidth = 2.0f;
        self.bgView.layer.shadowColor = [ZCUIKitTools zcgetChatBottomLineColor].CGColor;
        self.bgView.layer.shadowOpacity = 0.9;
        self.bgView.layer.shadowRadius = 8;
        self.bgView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        [self.bgView setBackgroundColor:[ZCUIKitTools zcgetChatBackgroundColor]];
        self.bgView.layer.cornerRadius = 8.0f;
        self.bgView.layer.borderColor = [ZCUIKitTools zcgetLeftChatColor].CGColor;
        
        //设置点击事件
        _layoutBgWidth = sobotLayoutEqualWidth(ScreenWidth, self.bgView, NSLayoutRelationEqual);
        [self.contentView addConstraint:_layoutBgWidth];
        [self.contentView addConstraint:sobotLayoutPaddingTop(0, self.bgView, self.ivBgView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(0, self.bgView, self.ivBgView)];
//        [self.contentView addConstraint:sobotLayoutMarginBottom(-ZCChatCellItemSpace, self.bgView, self.lblSugguest)];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(0, self.bgView, self.ivBgView)];
        
        // 顶部控件 上左右都是12px
        [self.bgView addConstraint:sobotLayoutPaddingTop(14, self.guideView, self.bgView)];// UI图需要加两个PX
        [self.bgView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingVSpace, self.guideView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatPaddingVSpace, self.guideView, self.bgView)];
        
        [self.guideView addConstraint: sobotLayoutPaddingTop(0, self.labTitle, self.guideView)];
        [self.guideView addConstraint:sobotLayoutPaddingLeft(0, self.labTitle, self.guideView)];
        [self.guideView addConstraint:sobotLayoutPaddingRight(0, self.labTitle, self.guideView)];
        
        self.labDescMT = sobotLayoutMarginTop(ZCChatRichCellItemSpace+2, self.labDesc, self.labTitle);
        [self.guideView addConstraint:self.labDescMT];
        [self.guideView addConstraint:sobotLayoutPaddingLeft(0, self.labDesc, self.guideView)];
        [self.guideView addConstraint:sobotLayoutPaddingRight(0, self.labDesc, self.guideView)];
        
        self.logoViewEH = sobotLayoutEqualHeight(66, self.logoView, NSLayoutRelationEqual);
        [self.guideView addConstraint:self.logoViewEH];
        [self.guideView addConstraint:sobotLayoutMarginTop(ZCChatRichCellItemSpace, self.logoView, self.labDesc)];
        [self.guideView addConstraint:sobotLayoutPaddingBottom(0, self.logoView, self.guideView)];
        [self.guideView addConstraint:sobotLayoutPaddingLeft(0, self.logoView, self.guideView)];
        [self.guideView addConstraint:sobotLayoutPaddingRight(0, self.logoView, self.guideView)];
        
        
        self.layoutCollectTop = sobotLayoutMarginTop(16, self.collectionView, self.guideView);
        [self.bgView addConstraint:self.layoutCollectTop];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingVSpace, self.collectionView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatPaddingVSpace, self.collectionView, self.bgView)];
        _layoutCollectionViewHeight = sobotLayoutEqualHeight(10, self.collectionView, NSLayoutRelationEqual);
        [self.bgView addConstraint:_layoutCollectionViewHeight];
//        self.collectionView.backgroundColor = UIColor.blueColor;
        
        _layoutCusFieldHeight = sobotLayoutEqualHeight(0, self.cusFieldView, NSLayoutRelationEqual);
        _layoutCusFieldHeight.priority = UILayoutPriorityFittingSizeLevel;
        [self.bgView addConstraint:_layoutCusFieldHeight];
        NSLayoutConstraint *_layoutFieldTop = sobotLayoutMarginTop(ZCChatRichCellItemSpace, self.cusFieldView, self.collectionView);
        [self.bgView addConstraint:_layoutFieldTop];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingVSpace, self.cusFieldView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatPaddingVSpace, self.cusFieldView, self.bgView)];
//        self.cusFieldView.backgroundColor = UIColor.yellowColor;
        
        [self.bgView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingVSpace, self.btnLookMore, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatPaddingVSpace, self.btnLookMore, self.bgView)];
        [self.bgView addConstraint:sobotLayoutMarginBottom(-ZCChatRichCellItemSpace, self.btnLookMore, self.cusButtonView)];
        [self.bgView addConstraint:sobotLayoutEqualHeight(33, self.btnLookMore, NSLayoutRelationEqual)];
//        self.btnLookMore.backgroundColor = UIColor.redColor;
        
        self.customMT = sobotLayoutMarginTop(16, self.cusButtonView, self.cusFieldView);
        [self.bgView addConstraint:self.customMT];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingVSpace, self.cusButtonView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatPaddingVSpace, self.cusButtonView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingBottom(-ZCChatPaddingVSpace, self.cusButtonView, self.bgView)];
        
    }
    return self;
}


-(void)createViews{
    _bgView = ({
        UIView *iv = [[UIView alloc] init];
        [iv setBackgroundColor:UIColor.clearColor];
        [self.contentView addSubview:iv];
        iv;
    });
    _guideView = ({
        UIView *iv = [[UIView alloc] init];
        [iv setBackgroundColor:UIColor.clearColor];
        [_bgView addSubview:iv];
        iv;
    });
    
    
    _logoView = ({
        SobotImageView *iv = [[SobotImageView alloc] init];
        iv.layer.masksToBounds = YES;
        iv.contentMode = UIViewContentModeScaleAspectFill;
        iv.layer.cornerRadius = 4.0f;
        //设置点击事件
        iv.userInteractionEnabled=YES;
        [self.guideView addSubview:iv];
        iv;
    });
    
    _labTitle = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        iv.numberOfLines = 0;
        [iv setFont:SobotFontBold16];
        [self.guideView addSubview:iv];
        iv;
    });
    
    
    _labDesc = ({
        UILabel *iv = [[UILabel alloc] init];
        iv.numberOfLines = 0;
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        [iv setFont:SobotFont14];
        [self.guideView addSubview:iv];
        iv;
    });
    
    
    _collectionView = ({
        _layout = [UICollectionViewFlowLayout new];
        _layout.itemSize = CGSizeMake(ScreenWidth, 120);
        _layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _layout.minimumLineSpacing = ZCChatMarginHSpace;
//        _layout.minimumLineSpacing = 1;
        
        
        // 12的间隙为 item 到 消息
        UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:_layout];
//        collectionView.backgroundColor = [ZCUIKitTools zcgetChatBottomLineColor];
        collectionView.backgroundColor = UIColor.clearColor;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.scrollEnabled = NO;
        collectionView.scrollsToTop = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        // 超出View，是否切割
        collectionView.clipsToBounds = YES;
        collectionView.showsHorizontalScrollIndicator = NO;
        [collectionView registerClass:[ZCChatCustomCardVCollectionCell class] forCellWithReuseIdentifier:@"ZCChatCustomCardVCollectionCell"];
        [collectionView registerClass:[ZCChatCustomCardVNoSendCollectionCell class] forCellWithReuseIdentifier:@"ZCChatCustomCardVNoSendCollectionCell"];
        
        if(sobotGetSystemDoubleVersion()>=11){
            if (@available(iOS 11.0, *)) {
                collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
        }
        [_bgView addSubview:collectionView];
    
//        collectionView.backgroundColor = UIColor.placeholderTextColor;
        collectionView;
    });
    
    _cusFieldView = ({
        UIView *iv = [[UIView alloc]init];
        [self.bgView addSubview:iv];
        iv.backgroundColor =UIColor.clearColor;
        [iv.layer setMasksToBounds:YES];
        iv;
    });
    

    _cusButtonView = ({
        UIView *iv = [[UIView alloc]init];
        [self.bgView addSubview:iv];
        iv.backgroundColor =UIColor.clearColor;
        [iv.layer setMasksToBounds:YES];
        iv;
    });
    
    _btnLookMore = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:SobotKitLocalString(@"展开更多") forState:0];
        btn.titleLabel.font = SobotFont12;
        [btn setImage:SobotKitGetImage(@"zcicon_arrow_down") forState:UIControlStateNormal];
        [btn setTitleColor:[ZCUIKitTools zcgetTimeTextColor] forState:0];
        [btn setBackgroundColor:[ZCUIKitTools zcgetChatBackgroundColor]];
        [btn setSemanticContentAttribute:UISemanticContentAttributeForceRightToLeft];
        [btn addTarget:self action:@selector(btnExpand:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgView addSubview:btn];
        
        btn.hidden = YES;
        btn;
    });
}


-(void)btnExpand:(UIButton *)sender{
    self.tempModel.showAllMessage = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]) {
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemRefreshData text:@"" obj:self.tempModel];
    }
}

-(void)cancelSendMsg:(UIButton *)sender{
    //    NSLog(@"取消发送文件\\");
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]) {
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemCancelFile text:@"" obj:self.tempModel];
    }
}
-(void)initDataToView:(SobotChatMessage *)message time:(NSString *)showTime{
    [super initDataToView:message time:showTime];
    
    CGFloat tempHeight = 0;
    
    if(sobotConvertToString(self.cardModel.cardImg).length>0){
        [_logoView loadWithURL:[NSURL URLWithString:sobotConvertToString(self.cardModel.cardImg)]];
        self.logoViewEH.constant = 66;
    }else{
        self.logoViewEH.constant = 0;
    }
    if(sobotConvertToString(self.cardModel.cardGuide).length >0){
        [_labTitle setText:sobotConvertToString(self.cardModel.cardGuide)];
        self.labDescMT.constant = ZCChatRichCellItemSpace+2;
    }else{
        self.labDescMT.constant = 0;
    }
    if(sobotConvertToString(self.cardModel.cardDesc).length >0){
        [_labDesc setText:sobotTrimString(self.cardModel.cardDesc)];
    }
    if(sobotConvertToString(self.cardModel.cardImg).length==0 && sobotConvertToString(self.cardModel.cardGuide).length==0 && sobotConvertToString(self.cardModel.cardDesc).length==0){
        self.layoutCollectTop.constant = 0;
    }else{
        self.layoutCollectTop.constant = 16;
    }
       
    [self.listArray removeAllObjects];
    // 先删除原来的 解决重用的刷新问题
    [self.collectionView reloadData];
    itemHeight = 0;
    if(self.cardModel.customCards.count){
        // invalidate之前的layout，这个很关键
        [self.collectionView.collectionViewLayout invalidateLayout];
        
        if(self.cardModel.cardType == 0){
            [self.listArray addObjectsFromArray:[NSArray arrayWithObject:[self.cardModel.customCards firstObject]]];
        }else{
            [self.listArray addObjectsFromArray:self.cardModel.customCards];
        }

        // 一定要重新设置，否则尺寸不生效
        contentWidth = self.maxWidth + ZCChatPaddingHSpace*2 - ZCChatPaddingVSpace*2;
        if(self.tempModel.senderType == 0){
            contentWidth = self.maxWidth + ZCChatPaddingHSpace*2 - ZCChatPaddingVSpace*2 -40;// 用户发送的宽度刷新去掉头像的间隔
        }
        
        // 这里应该获取的是动态的高度，描述是有一行或者2行的场景
        CGFloat curruntH = 0;
        for (SobotChatCustomCardInfo * model in self.listArray) {
            NSString *text = sobotConvertToString(model.customCardDesc);
            CGFloat lh = [SobotUITools getHeightContain:text font:SobotFont12 Width:contentWidth - 86];
            if(self.tempModel.senderType == 0){
                curruntH = curruntH +76;
            }else if(lh > 14){
                curruntH = curruntH + 76 + 12;
            }else{
                curruntH = curruntH +76;
            }
        }
        
//        if(self.cardModel.cardType == 0){
//            itemHeight = 76*self.listArray.count + ZCChatMarginHSpace*(self.listArray.count-1) + ZCChatCellItemSpace;
//        }else{
//            itemHeight = curruntH + ZCChatMarginHSpace*(self.listArray.count-1) + ZCChatCellItemSpace;
//        }
        
        // 只取第一个
        if(self.cardModel.cardType == 0){
            itemHeight = [self getItemOrderHeight];
        }else{
            itemHeight = curruntH + ZCChatMarginHSpace*(self.listArray.count-1) + ZCChatCellItemSpace;
        }
        _layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        self.collectionView.scrollEnabled = NO;
        self.collectionView.showsHorizontalScrollIndicator = NO;
            
        _layoutCollectionViewHeight.constant = itemHeight;
        
        self.layout.itemSize = CGSizeMake(contentWidth , itemHeight);
        // 这里我们使用重写systemLayoutSizeFittingSize的方式
        [self.collectionView layoutIfNeeded];
    }
    
    NSMutableArray *tempCusArr = [NSMutableArray array];
    if(self.cardModel.cardType == 0 && self.cardModel.customField && !sobotIsNull(self.cardModel.customCards) && self.cardModel.customCards.count >0){
        SobotChatCustomCardInfo *cardInfo = [self.cardModel.customCards firstObject];
        if(sobotConvertToString(cardInfo.customCardId).length>0){
            [tempCusArr addObject:@{SobotKitLocalString(@"订单号"):sobotConvertToString(cardInfo.customCardId)}];
        }
        if(sobotConvertToString(cardInfo.customCardStatus).length >0){
            [tempCusArr addObject:@{SobotKitLocalString(@"交易状态"):sobotConvertToString(cardInfo.customCardStatus)}];
        }
        if(sobotConvertToString(cardInfo.customCardTime).length >0){
            [tempCusArr addObject:@{SobotKitLocalString(@"创建时间"):sobotConvertToString(cardInfo.customCardTime)}];
        }
    }
    if(!sobotIsNull(self.cardModel.customField) && self.cardModel.customField.count> 0){
        for (int i =0 ; i<self.cardModel.customField.count; i++) {
            NSString *key = sobotConvertToString(self.cardModel.customField.allKeys[i]);
            NSString *value = sobotConvertToString(self.cardModel.customField[key]);
            [tempCusArr addObject:@{sobotConvertToString(key):sobotConvertToString(value)}];
        }
    }
    
    // 自定义字段
    if(tempCusArr && tempCusArr.count > 0){
        [self createItemFieldLabel:tempCusArr];
    }
    
    BOOL isCreate = NO;
    // 自定义按钮
    if(self.cardModel.cardMenus && self.cardModel.cardMenus.count > 0){
        isCreate = [self createItemCusButton];
    }
    
    
    if(!isCreate){
        // 没有自定义按钮 调整间距
        self.customMT.constant = 0;
    }else{
        self.customMT.constant = 16;
    }
    
    _layoutBgWidth.constant = self.maxWidth+ ZCChatPaddingHSpace*2;
    
    if(self.tempModel.senderType == 0){
        // 右边用户发送的 和 发送前的宽度一样
        _layoutBgWidth.constant = self.maxWidth+ ZCChatPaddingHSpace*2 -40;
    }
    if(!self.tempModel.showAllMessage && self.tempModel.senderType != 0){
        [self.bgView layoutIfNeeded];
        tempHeight = CGRectGetHeight(_bgView.frame);
    }
    
    if(tempHeight > 400){
        CGFloat guideheight = CGRectGetHeight(_guideView.frame);
        _layoutCollectionViewHeight.constant = 400 - guideheight - 120;
        if(itemHeight > (400 - guideheight - 40)){
            _layoutCollectionViewHeight.constant = (400 - guideheight - 40);
            _layoutCusFieldHeight.constant = 0;
        }else{
            _layoutCollectionViewHeight.constant = itemHeight;
            _layoutCusFieldHeight.constant = (400 - guideheight - 80 - itemHeight);
        }
        _btnLookMore.hidden = NO;
        _layoutCusFieldHeight.priority = UILayoutPriorityDefaultHigh;
        // 展开更多按钮显示，自定义字段不显示的问题，需要再次刷新 正序
        if(tempCusArr && tempCusArr.count > 0){
            [self createItemFieldLabelIsDesc:NO customField:tempCusArr];
        }
    }else{
        // 去掉展开更多 自定义字段要显示全部 重新设置排序 倒序
        if(tempCusArr && tempCusArr.count > 0){
            [self createItemFieldLabel:tempCusArr];
        }
        _btnLookMore.hidden = YES;
        _layoutCusFieldHeight.constant = 0;
        _layoutCusFieldHeight.priority = UILayoutPriorityFittingSizeLevel;
    }
    
    // 说明需要再次执行一次
    if(tempHeight == 0 || tempHeight > 400){
        [self.bgView layoutIfNeeded];
    }
    
    if(self.tempModel.senderType == 0){
        [self setChatViewBgState:CGSizeMake(self.maxWidth-40,CGRectGetMaxY(_cusButtonView.frame))];
    }else{
        [self setChatViewBgState:CGSizeMake(self.maxWidth,CGRectGetMaxY(_cusButtonView.frame))];
    }

    // 这里不需要背景色
    self.ivBgView.backgroundColor = [UIColor clearColor];
    self.ivBgView.image = nil;
    
    if(message.senderType!=0){
            NSArray<CALayer *> *subLayers = self.bgView.layer.sublayers;
            NSArray<CALayer *> *removedLayers = [subLayers filteredArrayUsingPredicate:
             
            [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                return [evaluatedObject isKindOfClass:[CAShapeLayer class]];
            }]];
            [removedLayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj removeFromSuperlayer];
             }];
            self.bgView.layer.masksToBounds = NO;
            self.bgView.layer.backgroundColor = [ZCUIKitTools zcgetChatBackgroundColor].CGColor;
            self.bgView.layer.cornerRadius = 8;
            self.bgView.layer.shadowColor = [ZCUIKitTools zcgetChatBottomLineColor].CGColor;
            self.bgView.layer.shadowOffset = CGSizeMake(0,1);
            self.bgView.layer.shadowOpacity = 1;
            self.bgView.layer.shadowRadius = 4;
        
        }else{
            NSArray<CALayer *> *subLayers = self.bgView.layer.sublayers;
            NSArray<CALayer *> *removedLayers = [subLayers filteredArrayUsingPredicate:
             
            [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                return [evaluatedObject isKindOfClass:[CAShapeLayer class]];
            }]];
            [removedLayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj removeFromSuperlayer];
             }];

            self.bgView.layer.cornerRadius = 8;
            self.bgView.layer.borderColor = [ZCUIKitTools zcgetChatBottomLineColor].CGColor;
            self.bgView.layer.borderWidth = 1.0f;
            self.bgView.layer.masksToBounds = YES;
        }
    
    
    
    // 重新设置完约束 刷新数据
    [self.collectionView reloadData];
}


// 不会使用
-(CGFloat)getItemOrderHeight{
    SobotChatCustomCardInfo *model = [self.cardModel.customCards firstObject];
    CGFloat imgHeight = 0;
    // 有头像
    if(sobotConvertToString(model.customCardThumbnail).length > 0){
        imgHeight = 12 + 52;
    }
    
    CGFloat cHeight = 8;
    // 标题
    if(sobotConvertToString(model.customCardName).length > 0){
        cHeight = cHeight + 20 + 4;
    }
    if(sobotConvertToString(model.customCardDesc).length > 0){
        CGFloat descH = [SobotUITools getHeightContain:sobotConvertToString(model.customCardDesc) font:SobotFont12 Width:contentWidth -78];//self.maxWidth -contentWidth - 12 - 52
        if(descH > 34){
            descH = 34;
        }
        cHeight = cHeight + descH;
    }
    NSString *allStr = SobotKitLocalString(@"共");
    NSString *unitStr = SobotKitLocalString(@"件");
    NSString *goodsStr = SobotKitLocalString(@"商品");
    NSString *totalStr = SobotKitLocalString(@"合计");
    NSString *text = [NSString stringWithFormat:@"%@%@%@%@  %@ %@%@",allStr,model.customCardCount,unitStr,goodsStr,totalStr,model.customCardAmountSymbol,model.customCardAmount];
    
    CGFloat lw = [SobotUITools getWidthContain:text font:SobotFontBold12 Height:14];
    if(lw > (contentWidth - 78)){
        text = [NSString stringWithFormat:@"%@%@%@\n%@ %@%@",model.customCardCount,unitStr,goodsStr,totalStr,model.customCardAmountSymbol,model.customCardAmount];
    }
    
    cHeight = cHeight + [SobotUITools getHeightContain:text font:SobotFontBold12 Width:contentWidth - 78];
    if(contentWidth >229 && lw > contentWidth - 78){
        cHeight = cHeight +10; // 屏宽换行，计算高度有误差 ，之间差10个行间距
    }
    
    return cHeight > imgHeight ? (cHeight + 6):imgHeight;
}

-(void)bgViewClick:(UITapGestureRecognizer *) tap{
    NSString * link = self.cardModel.cardLink;
    
    if(sobotConvertToString(link).length  == 0){
        return;
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeOpenFile text:sobotConvertToString(link)  obj:sobotConvertToString(link)];
    }
}

// 是否倒序 是否展示全部
-(void)createItemFieldLabelIsDesc:(BOOL)isDesc customField:(NSMutableArray*)customField{
    [_cusFieldView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if(customField.count > 0){
        if(isDesc){
            UILabel *preLab = nil;
            for(int i=(int)(customField.count)-1;i>=0; i -- ){
                NSDictionary *item = customField[i];
                NSString *key = sobotConvertToString([item.allKeys firstObject]);
                NSString *value = sobotConvertToString(item[key]);
                UILabel *lab = [SobotUITools createZCLabel];
                lab.numberOfLines = 0;
                lab.font = SobotFont12;
                [lab setTextColor: UIColorFromModeColor(SobotColorTextMain)];
                [lab setText:[NSString stringWithFormat:@"%@：%@",key,value]];
                [_cusFieldView addSubview:lab];
                if(i==0){
                    [_cusFieldView addConstraint:sobotLayoutPaddingTop(0,  lab, _cusFieldView)];
                }
                [_cusFieldView addConstraint:sobotLayoutPaddingLeft(0, lab, _cusFieldView)];
                [_cusFieldView addConstraint:sobotLayoutPaddingRight(0, lab, _cusFieldView)];
                if(preLab!=nil){
                    [_cusFieldView addConstraint:sobotLayoutMarginBottom(-8, lab, preLab)];
                }
                if(preLab==nil){
                    [_cusFieldView addConstraint:sobotLayoutPaddingBottom(0, lab, _cusFieldView)];
                }
                preLab = lab;
            }
        }else{
            UILabel *preLab = nil;
            for(int i=0;i<customField.count-1; i++ ){
                NSDictionary *item = customField[i];
                NSString *key = sobotConvertToString([item.allKeys firstObject]);
                NSString *value = sobotConvertToString(item[key]);
                UILabel *lab = [SobotUITools createZCLabel];
                lab.numberOfLines = 0;
                lab.font = SobotFont12;
                [lab setTextColor: UIColorFromModeColor(SobotColorTextMain)];
                [lab setText:[NSString stringWithFormat:@"%@：%@",key,value]];
                [_cusFieldView addSubview:lab];
                if(i==0){
                    [_cusFieldView addConstraint:sobotLayoutPaddingTop(0,  lab, _cusFieldView)];
                }
                [_cusFieldView addConstraint:sobotLayoutPaddingLeft(0, lab, _cusFieldView)];
                [_cusFieldView addConstraint:sobotLayoutPaddingRight(0, lab, _cusFieldView)];
                if(preLab!=nil){
                    [_cusFieldView addConstraint:sobotLayoutMarginTop(8, lab, preLab)];
                }
                if(i == customField.count-1){
                    [_cusFieldView addConstraint:sobotLayoutPaddingBottom(0, lab, _cusFieldView)];
                }
                preLab = lab;
            }
        }
       
    }
}

-(void)createItemFieldLabel:(NSMutableArray*)customField{
    [_cusFieldView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if(customField.count > 0){
        UILabel *preLab = nil;
        for(int i=(int)(customField.count)-1;i>=0; i -- ){
            NSDictionary *item = customField[i];
            NSString *key = sobotConvertToString([item.allKeys firstObject]);
            NSString *value = sobotConvertToString(item[key]);
            UILabel *lab = [SobotUITools createZCLabel];
            lab.numberOfLines = 0;
            lab.font = SobotFont12;
            [lab setTextColor: UIColorFromModeColor(SobotColorTextMain)];
            [lab setText:[NSString stringWithFormat:@"%@：%@",key,value]];
            [_cusFieldView addSubview:lab];
            if(i==0){
                [_cusFieldView addConstraint:sobotLayoutPaddingTop(0,  lab, _cusFieldView)];
            }
            [_cusFieldView addConstraint:sobotLayoutPaddingLeft(0, lab, _cusFieldView)];
            [_cusFieldView addConstraint:sobotLayoutPaddingRight(0, lab, _cusFieldView)];
            if(preLab!=nil){
                [_cusFieldView addConstraint:sobotLayoutMarginBottom(-8, lab, preLab)];
            }
            if(preLab==nil){
                [_cusFieldView addConstraint:sobotLayoutPaddingBottom(0, lab, _cusFieldView)];
            }
            preLab = lab;
        }
    }
}

-(BOOL )createItemCusButton{
    [_cusButtonView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    BOOL isCreate = NO;
    // 不是自己发送时，才添加按钮
    if(self.cardModel.cardMenus.count > 0 && self.tempModel.senderType != 0){
        SobotButton *preButton = nil;
        int currentCount = 0;
        for(int i=0;i<self.cardModel.cardMenus.count ; i ++ ){
            SobotChatCustomCardMenu *menu = self.cardModel.cardMenus[i];
            if(menu.menuType == 0 && menu.menuLinkType ==1){
                continue;
            }
            isCreate =  YES;
            currentCount ++;
            SobotButton *btn = (SobotButton *)[SobotUITools createZCButton];
            [btn setTitle:sobotConvertToString(menu.menuName) forState:0];
            btn.obj = menu;
            btn.tag = i;
            btn.enabled = YES;
            btn.titleEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 16);
            btn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            [btn setBackgroundColor:UIColor.clearColor];
            [btn addTarget:self action:@selector(menuButton:) forControlEvents:UIControlEventTouchUpInside];
            // 发送
            if(currentCount == 1){
                btn.layer.borderWidth = 0;
                btn.backgroundColor = [ZCUIKitTools zcgetGoodSendBtnColor];
                [btn setTitleColor:[ZCUIKitTools zcgetGoodsSendColor] forState:0];
            }else{
                btn.layer.borderColor = [ZCUIKitTools zcgetCommentButtonLineColor].CGColor;
                [btn setTitleColor:[ZCUIKitTools zcgetChatTextViewColor] forState:0];
                btn.layer.borderWidth = .75f;
            }
            btn.layer.cornerRadius = 16.0f;
            [btn.titleLabel setFont:SobotFont14];
            [btn addTarget:self action:@selector(menuButton:) forControlEvents:UIControlEventTouchUpInside];
            [_cusButtonView addSubview:btn];
            if(menu.menuType == 1 && (menu.isUnEnabled || self.tempModel.isHistory)){
                // 确认按钮 历史记录和点击一次变成置灰不可点
                btn.enabled = NO;
                [btn setTitleColor:[ZCUIKitTools zcgetTextPlaceHolderColor] forState:UIControlStateNormal];
            }
            if(menu.menuType == 2 && self.tempModel.isHistory){
                btn.enabled = NO;
                [btn setTitleColor:[ZCUIKitTools zcgetTextPlaceHolderColor] forState:UIControlStateNormal];
            }
            if(currentCount == 1 && menu.menuType != 0 && self.tempModel.isHistory){
                btn.enabled = NO;
                [btn setTitleColor:[ZCUIKitTools zcgetGoodsSendColor] forState:0];
                [btn setBackgroundColor:UIColorFromModeColorAlpha(SobotColorTheme, 0.3)];
            }
            
            [_cusButtonView addConstraint:sobotLayoutEqualHeight(32, btn, NSLayoutRelationEqual)];
            if(sobotIsNull(preButton)){
                [_cusButtonView addConstraint:sobotLayoutPaddingTop(0, btn, _cusButtonView)];
                [_cusButtonView addConstraint:sobotLayoutPaddingLeft(0, btn, _cusButtonView)];
                [_cusButtonView addConstraint:sobotLayoutPaddingRight(0, btn, _cusButtonView)];
            }
            else{
                [_cusButtonView addConstraint:sobotLayoutMarginTop(10, btn, preButton)];
                [_cusButtonView addConstraint:sobotLayoutPaddingLeft(0, btn, _cusButtonView)];
                [_cusButtonView addConstraint:sobotLayoutPaddingRight(0, btn, _cusButtonView)];
            }
            preButton = btn;
        }
        if(!sobotIsNull(preButton)){
            [_cusButtonView addConstraint:sobotLayoutPaddingBottom(0, preButton, _cusButtonView)];
        }
    }
    return isCreate;
}



#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.listArray.count;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    // 只取第一个
    if(self.cardModel.cardType == 0){
        return CGSizeMake(contentWidth, itemHeight);
    }else{
        CGFloat curruntH = 0;
        if(self.listArray &&[self.listArray isKindOfClass:[NSMutableArray class]]&& self.listArray.count > 0){
            SobotChatCustomCardInfo * model = self.listArray[indexPath.row];
            NSString *text = sobotConvertToString(model.customCardDesc);
            CGFloat lh = [SobotUITools getHeightContain:text font:SobotFont12 Width:contentWidth - 86];
            if(lh > 14 && self.tempModel.senderType != 0){
                curruntH = 76 + 12;
            }else{
                curruntH = curruntH +76;
            }
        }
        return CGSizeMake(contentWidth, curruntH);
    }
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);//分别为上、左、下、右
}

- ( UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
//    if(_listArray && _listArray.count > 0){
//
//        SobotChatCustomCardInfo * model = _listArray[indexPath.row];
//        if(_cardModel.cardStyle==0){
//            ZCChatCustomCardCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZCChatCustomCardCollectionCell class]) forIndexPath:indexPath];
//            cell.indexPath = indexPath;
//            [cell configureCellWithData:model message:self.tempModel];
//            return cell;
//        }
//    }
    //0=订单卡片时，只显示一个商品
    if(self.cardModel.cardType == 0){
        return [collectionView dequeueReusableCellWithReuseIdentifier:@"ZCChatCustomCardVNoSendCollectionCell" forIndexPath:indexPath];
        
    }else{
        return [collectionView dequeueReusableCellWithReuseIdentifier:@"ZCChatCustomCardVCollectionCell" forIndexPath:indexPath];
    }
}

// 点击发送消息
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if(self.listArray.count > 0){
        
        //    NSLog(@" 点击水平 item的 事件 %@",indexPath);
        SobotChatCustomCardInfo * model = self.listArray[indexPath.row];
     
        // 发送点击消息
//        NSDictionary * dict = [SobotCache getObjectData:model];
        if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]) {
            [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeOpenURL text:sobotConvertToString(model.customCardLink) obj:sobotConvertToString(model.customCardLink)];
        }
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if(self.listArray.count > 0){
        //    NSLog(@" 点击水平 item的 事件 %@",indexPath);
        SobotChatCustomCardInfo * model = self.cardModel.customCards[indexPath.row];
        ZCChatCustomCardInfoBaseCell * vcell = (ZCChatCustomCardInfoBaseCell *)cell;
        vcell.indexPath = indexPath;
        vcell.delegate = self;
        vcell.message = self.tempModel;
        vcell.cardModel = model;
        [vcell configureCellWithData:model message:self.tempModel];
        // 设置订单和商品的列表的背景颜色
        if(self.cardModel.cardType == 0){
            vcell.bgView.backgroundColor = UIColorFromKitModeColor(SobotColorBgSub);
            vcell.bgView.layer.cornerRadius = 8;
            vcell.bgView.layer.masksToBounds = YES;
        }else{
            vcell.bgView.backgroundColor = UIColor.clearColor;
            vcell.bgView.layer.cornerRadius = 0;
        }
    }
}

-(void)menuButton:(SobotButton *)btn{
    SobotChatCustomCardMenu *menu = (SobotChatCustomCardMenu*)btn.obj;
    if(menu.menuType == 1){
        btn.enabled = NO;
        menu.isUnEnabled = YES;
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemClickCusCardButoon text:sobotConvertIntToString((int)btn.tag)  obj:btn.obj];
    }
}


-(void)onCollectionItemMenuClick:(SobotChatCustomCardMenu *)menu index:(NSIndexPath *)index message:(SobotChatMessage *)model{
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemClickCusCardInfoButoon text:sobotConvertIntToString((int)index.row)  obj:menu];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
