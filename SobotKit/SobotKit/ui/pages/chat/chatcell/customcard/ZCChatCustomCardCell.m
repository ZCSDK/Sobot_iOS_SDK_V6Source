//
//  ZCChatCustomCardCell.m
//  SobotKit
//
//  Created by zhangxy on 2023/6/8.
//

#import "ZCChatCustomCardCell.h"
#import "ZCChatCustomCardVCollectionCell.h"
#import "ZCChatCustomCardHCollectionCell.h"

@interface ZCChatCustomCardCell()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>{
    CGFloat contentWidth;
    CGFloat itemHeight;
}
@property(nonatomic,strong)SobotChatCustomCard *cardModel;

@property(nonatomic,strong) NSLayoutConstraint *layoutBgWidth;

@property(nonatomic,strong) NSLayoutConstraint *layoutBgViewHeight;
@property (strong, nonatomic) UIView *bgView; //
@property (strong, nonatomic) UILabel *labTitle; //标题
@property (strong, nonatomic) UILabel *labDesc; //标题
@property (nonatomic,strong) SobotImageView *logoView;
@property (nonatomic,strong) UIView *guideView;

@property (nonatomic,strong) UICollectionViewFlowLayout *layout;
@property (nonatomic,strong)  UICollectionView * collectionView;
@property(nonatomic,strong) NSLayoutConstraint *layoutCollectionViewHeight;

@property (nonatomic,strong) UIView *cusFieldView;// 自定义字段

@property (nonatomic,strong)  UIView *cusButtonView;// 自定义button
@property (nonatomic,strong) NSMutableArray *listArray;

@property (nonatomic,strong) UIButton *btnLookMore;
@end

@implementation ZCChatCustomCardCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self createViews];
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self createViews];
        _listArray = [[NSMutableArray alloc] init];
        //设置点击事件
        UITapGestureRecognizer *tapGesturer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bgViewClick:)];
        self.bgView.userInteractionEnabled=YES;
        [self.bgView addGestureRecognizer:tapGesturer];
        
        //设置点击事件
        _layoutBgWidth = sobotLayoutEqualWidth(ScreenWidth, self.bgView, NSLayoutRelationEqual);
        [self.contentView addConstraint:_layoutBgWidth];
        [self.contentView addConstraint:sobotLayoutPaddingTop(ZCChatPaddingVSpace, self.bgView, self.ivBgView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingHSpace, self.bgView, self.ivBgView)];
        
        
        [self.contentView addConstraint:sobotLayoutMarginTop(0, self.cusButtonView, self.bgView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingHSpace, self.cusButtonView, self.ivBgView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(0, self.cusButtonView, self.bgView)];
        
        [self.contentView addConstraint:sobotLayoutMarginBottom(-ZCChatCellItemSpace, self.cusButtonView, self.lblSugguest)];
        
        _layoutBgViewHeight = sobotLayoutEqualHeight(0, self.bgView, NSLayoutRelationEqual);
        _layoutBgViewHeight.priority = UILayoutPriorityFittingSizeLevel;
        [self.contentView addConstraint:_layoutBgViewHeight];
        
        [self.bgView addConstraint:sobotLayoutPaddingTop(0, self.guideView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(0, self.guideView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.guideView, self.bgView)];
        
        [self.guideView addConstraint: sobotLayoutPaddingTop(ZCChatPaddingVSpace, self.labTitle, self.guideView)];
        [self.guideView addConstraint:sobotLayoutPaddingLeft(0, self.labTitle, self.guideView)];
        [self.guideView addConstraint:sobotLayoutPaddingRight(0, self.labTitle, self.guideView)];
        
        [self.guideView addConstraint:sobotLayoutMarginTop(ZCChatCellItemSpace, self.labDesc, self.labTitle)];
        [self.guideView addConstraint:sobotLayoutPaddingLeft(0, self.labDesc, self.guideView)];
        [self.guideView addConstraint:sobotLayoutPaddingRight(0, self.labDesc, self.guideView)];
        
        [self.guideView addConstraint:sobotLayoutEqualHeight(40, self.logoView, NSLayoutRelationEqual)];
        [self.guideView addConstraint:sobotLayoutMarginTop(0, self.logoView, self.labDesc)];
        [self.guideView addConstraint:sobotLayoutPaddingBottom(0, self.logoView, self.guideView)];
        [self.guideView addConstraint:sobotLayoutPaddingLeft(0, self.logoView, self.guideView)];
        [self.guideView addConstraint:sobotLayoutPaddingRight(0, self.logoView, self.guideView)];
        
        
        NSLayoutConstraint *_layoutCollectTop = sobotLayoutMarginTop(ZCChatCellItemSpace, self.collectionView, self.guideView);
        [self.bgView addConstraint:_layoutCollectTop];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(0, self.collectionView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.collectionView, self.bgView)];
        _layoutCollectionViewHeight = sobotLayoutEqualHeight(10, self.collectionView, NSLayoutRelationEqual);
        [self.bgView addConstraint:_layoutCollectionViewHeight];
        
        
        NSLayoutConstraint *_layoutFieldTop = sobotLayoutMarginTop(ZCChatCellItemSpace, self.cusFieldView, self.collectionView);
        [self.bgView addConstraint:_layoutFieldTop];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(0, self.cusFieldView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.cusFieldView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingBottom(-ZCChatPaddingHSpace, self.cusFieldView, self.bgView)];
        
        [self.bgView addConstraint:sobotLayoutPaddingLeft(0, self.btnLookMore, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.btnLookMore, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingBottom(0, self.btnLookMore, self.bgView)];
        
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
        [iv setBackgroundColor:UIColor.redColor];
        [_bgView addSubview:iv];
        iv;
    });
    
    
    _logoView = ({
        SobotImageView *iv = [[SobotImageView alloc] init];
        iv.layer.masksToBounds = YES;
        iv.contentMode = UIViewContentModeScaleAspectFill;
        //设置点击事件
        iv.userInteractionEnabled=YES;
        [self.guideView addSubview:iv];
        iv;
    });
    
    _labTitle = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        iv.numberOfLines = 1;
        [iv setFont:SobotFontBold14];
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
        _layout.minimumLineSpacing = 1;
        
        
        // 12的间隙为 item 到 消息
        UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:_layout];
//        collectionView.backgroundColor = [ZCUIKitTools zcgetChatBottomLineColor];
//        collectionView.backgroundColor = UIColor.orangeColor;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.scrollEnabled = NO;
        collectionView.scrollsToTop = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        // 超出View，是否切割
        collectionView.clipsToBounds = YES;
        collectionView.showsHorizontalScrollIndicator = NO;
        [collectionView registerClass:[ZCChatCustomCardHCollectionCell class] forCellWithReuseIdentifier:@"ZCChatCustomCardHCollectionCell"];
        [collectionView registerClass:[ZCChatCustomCardVCollectionCell class] forCellWithReuseIdentifier:@"ZCChatCustomCardVCollectionCell"];
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
    
    // 注意此处添加的view在UITableViewCell上，方便控制最大高度时，展开控制
    _cusButtonView = ({
        UIView *iv = [[UIView alloc]init];
        [self.contentView addSubview:iv];
        iv.backgroundColor =UIColor.clearColor;
        [iv.layer setMasksToBounds:YES];
        iv;
    });
    
    _btnLookMore = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:SobotKitLocalString(@"展开更多") forState:0];
        [btn setTitleColor:[ZCUIKitTools zcgetTimeTextColor] forState:0];
        btn.backgroundColor = [ZCUIKitTools zcgetChatBgBottomColor];
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
    
    
    _cardModel = message.richModel.customCard;
    CGFloat tempHeight = 0;
    
    [_logoView loadWithURL:[NSURL URLWithString:sobotConvertToString(_cardModel.cardImg)]];
    [_labDesc setText:sobotConvertToString(_cardModel.cardGuide)];
    [_labTitle setText:sobotTrimString(_cardModel.cardDesc)];
    
    
   
    [_listArray removeAllObjects];
    itemHeight = 0;
    if(_cardModel.customCards.count){
        // invalidate之前的layout，这个很关键
        [self.collectionView.collectionViewLayout invalidateLayout];
        
        [_listArray addObjectsFromArray:_cardModel.customCards];
        if(_cardModel.cardStyle == 0){
            // 一定要重新设置，否则尺寸不生效
            contentWidth = 160;
            itemHeight = 180 + ZCChatCellItemSpace;
            _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            
            self.collectionView.scrollEnabled = YES;
            self.collectionView.showsHorizontalScrollIndicator = YES;
        }else{
            // 一定要重新设置，否则尺寸不生效
            contentWidth = self.maxWidth;
            itemHeight = 120*_listArray.count + ZCChatCellItemSpace;
            _layout.scrollDirection = UICollectionViewScrollDirectionVertical;
            
            self.collectionView.scrollEnabled = NO;
            self.collectionView.showsHorizontalScrollIndicator = NO;
            
        }
        _layoutCollectionViewHeight.constant = itemHeight;
        
        self.layout.itemSize = CGSizeMake(contentWidth , itemHeight);
        // 这里我们使用重写systemLayoutSizeFittingSize的方式
        [self.collectionView layoutIfNeeded];
    }
    
    // 自定义字段
    if(_cardModel.customField && _cardModel.customField.count > 0){
        [self createItemFieldLabel];
    }
    
    // 自定义按钮
    if(_cardModel.cardMenus && _cardModel.cardMenus.count > 0){
        [self createItemCusButton];
    }
    
    _layoutBgWidth.constant = self.maxWidth + ZCChatPaddingHSpace * 2;
    if(!self.tempModel.showAllMessage){
        [self.bgView layoutIfNeeded];
        tempHeight = CGRectGetHeight(_bgView.frame);
    }
    
    if(tempHeight > 400){
        _btnLookMore.hidden = NO;
        _layoutBgViewHeight.constant = 400;
        _layoutBgViewHeight.priority = UILayoutPriorityDefaultHigh;
    }else{
        _btnLookMore.hidden = YES;
        _layoutBgViewHeight.constant = 0;
        _layoutBgViewHeight.priority = UILayoutPriorityFittingSizeLevel;
    }
    
    // 说明需要再次执行一次
    if(tempHeight == 0 || tempHeight > 400){
        [self.bgView layoutIfNeeded];
    }
    [self setChatViewBgState:CGSizeMake(self.maxWidth + ZCChatPaddingHSpace * 2,CGRectGetMaxY(_cusButtonView.frame))];
}


-(void)bgViewClick:(UITapGestureRecognizer *) tap{
    NSString * link = self.tempModel.richModel.url;
    
    if(sobotConvertToString(link).length  == 0){
        return;
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeOpenFile text:sobotConvertToString(link)  obj:sobotConvertToString(link)];
    }
}


-(void)createItemFieldLabel{
    [_cusFieldView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if(_cardModel.cardMenus.count > 0){
        UILabel *preLab = nil;
        for(int i=0;i<_cardModel.customField.allKeys.count ; i ++ ){
            NSString *key = sobotConvertToString(_cardModel.customField.allKeys[i]);
            NSString *value = sobotConvertToString(_cardModel.customField[key]);
            UILabel *lab = [SobotUITools createZCLabel];
            lab.numberOfLines = 0;
            [lab setText:[NSString stringWithFormat:@"%@:%@",key,value]];
            [_cusFieldView addSubview:lab];
            
            if(i==0){
                [_cusFieldView addConstraint:sobotLayoutPaddingTop(0,  lab, _cusFieldView)];
                [_cusFieldView addConstraint:sobotLayoutPaddingLeft(0, lab, _cusFieldView)];
                [_cusFieldView addConstraint:sobotLayoutPaddingRight(0, lab, _cusFieldView)];
            }
            else{
                [_cusFieldView addConstraint:sobotLayoutMarginTop(5, lab, preLab)];
                [_cusFieldView addConstraint:sobotLayoutPaddingLeft(0, lab, _cusFieldView)];
                [_cusFieldView addConstraint:sobotLayoutPaddingRight(0, lab, _cusFieldView)];
            }
            preLab = lab;
        }
        
        [_cusFieldView addConstraint:sobotLayoutPaddingBottom(0, preLab, _cusFieldView)];
    }
}

-(void)createItemCusButton{
    [_cusButtonView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if(_cardModel.cardMenus.count > 0){
        SobotButton *preButton = nil;
        for(int i=0;i<_cardModel.cardMenus.count ; i ++ ){
            SobotChatCustomCardMenu *menu = _cardModel.cardMenus[i];
            
            SobotButton *btn = (SobotButton *)[SobotUITools createZCButton];
            [btn setTitle:sobotConvertToString(menu.menuTip) forState:0];
            btn.layer.borderColor = [ZCUIKitTools zcgetCommentCommitButtonColor].CGColor;
            btn.layer.cornerRadius = 10.0f;
            btn.layer.borderWidth = 1.0f;
            btn.obj = menu;
            [_cusButtonView addSubview:btn];
            
            if(i==0){
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
        [_cusButtonView addConstraint:sobotLayoutPaddingBottom(0, preButton, _cusButtonView)];
    }
}



#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _listArray.count;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(contentWidth-2, itemHeight);
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
    if(self.cardModel.cardStyle == 0){
        
        return [collectionView dequeueReusableCellWithReuseIdentifier:@"ZCChatCustomCardVCollectionCell" forIndexPath:indexPath];
    }else{
        
        return [collectionView dequeueReusableCellWithReuseIdentifier:@"ZCChatCustomCardCollectionCell" forIndexPath:indexPath];
    }
}

// 点击发送消息
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if(_listArray.count > 0){
        
        //    NSLog(@" 点击水平 item的 事件 %@",indexPath);
        SobotChatCustomCardInfo * model = _listArray[indexPath.row];
     
        // 发送点击消息
        
        NSDictionary * dict = [SobotCache getObjectData:model];

        if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]) {
            [self.delegate cellItemClick:nil type:ZCChatCellClickTypeCollectionSendMsg text:@"" obj:dict];
        }
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if(_listArray.count > 0){
        //    NSLog(@" 点击水平 item的 事件 %@",indexPath);
        SobotChatCustomCardInfo * model = _cardModel.customCards[indexPath.row];
        ZCChatCustomCardInfoBaseCell * vcell = (ZCChatCustomCardInfoBaseCell *)cell;
        vcell.indexPath = indexPath;
        [vcell configureCellWithData:model message:self.tempModel];
//        if(_cardModel.cardStyle == 1 && _cardModel.cardType == 0){
//            // 订单并且是列表
//            vcell.bgView.backgroundColor = UIColorFromKitModeColor(SobotColorBgSub);
//        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
