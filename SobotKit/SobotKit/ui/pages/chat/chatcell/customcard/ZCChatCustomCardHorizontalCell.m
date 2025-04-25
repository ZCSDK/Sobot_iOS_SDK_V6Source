//
//  ZCChatCustomCardHorizontalCell.m
//  SobotKit
//
//  Created by zhangxy on 2023/6/13.
//

#import "ZCChatCustomCardHorizontalCell.h"

#import "ZCChatCustomCardHCollectionCell.h"

@interface ZCChatCustomCardHorizontalCell()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,ZCChatCustomCardInfoBaseCellDelegate>{
    CGFloat contentWidth;
    CGFloat itemHeight;
}

@property(nonatomic,strong) NSLayoutConstraint *layoutBgWidth;
@property(nonatomic,strong) NSLayoutConstraint *layoutBgLeft;

@property(nonatomic,strong) NSLayoutConstraint *layoutBgViewHeight;
@property (strong, nonatomic) UIView *bgView;

@property (nonatomic,strong) UICollectionViewFlowLayout *layout;
@property (nonatomic,strong)  UICollectionView * collectionView;
@property(nonatomic,strong) NSLayoutConstraint *layoutCollectionViewHeight;

@end

@implementation ZCChatCustomCardHorizontalCell

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
//        UITapGestureRecognizer *tapGesturer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bgViewClick:)];
//        self.bgView.userInteractionEnabled=YES;
//        [self.bgView addGestureRecognizer:tapGesturer];
        
        //设置点击事件
        _layoutBgWidth = sobotLayoutEqualWidth(ScreenWidth, self.bgView, NSLayoutRelationEqual);
        [self.contentView addConstraint:_layoutBgWidth];
        [self.contentView addConstraint:sobotLayoutPaddingTop(ZCChatPaddingVSpace, self.bgView, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(-ZCChatPaddingVSpace, self.bgView, self.contentView)];
        
        // 当不是用户的数据，显示全屏；当是用户的数据，需要显示正常的数据
        /**
         用户：left = self.viewWidth - self.maxWidth - 16;
            width = self.maxWidth
         非用户：left = 16
            width = self.viewWidth - 16;
         */
//        [self.contentView addConstraint:sobotLayoutPaddingLeft(0, self.bgView, self.ivBgView)];
        
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            _layoutBgLeft = sobotLayoutPaddingRight(-ZCChatPaddingHSpace, self.bgView, self.contentView);
        }else{
            _layoutBgLeft = sobotLayoutPaddingLeft(ZCChatPaddingHSpace, self.bgView, self.contentView);
        }
        [self.contentView addConstraint:_layoutBgLeft];
        
        [self.bgView addConstraint:sobotLayoutPaddingTop(0, self.collectionView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(0, self.collectionView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.collectionView, self.bgView)];
        _layoutCollectionViewHeight = sobotLayoutEqualHeight(10, self.collectionView, NSLayoutRelationEqual);
        [self.bgView addConstraint:_layoutCollectionViewHeight];
        [self.bgView addConstraint:sobotLayoutPaddingBottom(0, self.collectionView, self.bgView)];
        
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
    
    _collectionView = ({
        _layout = [UICollectionViewFlowLayout new];
        _layout.itemSize = CGSizeMake(ScreenWidth, 120);
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _layout.minimumLineSpacing = ZCChatMarginHSpace;
        
        
        // 12的间隙为 item 到 消息
        UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:_layout];
//        collectionView.backgroundColor = UIColorFromKitModeColor(SobotColorWhite);
        collectionView.backgroundColor = [ZCUIKitTools zcgetChatBackgroundColor];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.scrollEnabled = YES;
        collectionView.scrollsToTop = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        // 超出View，是否切割
        collectionView.clipsToBounds = YES;
        collectionView.showsHorizontalScrollIndicator = NO;
        [collectionView registerClass:[ZCChatCustomCardHCollectionCell class] forCellWithReuseIdentifier:@"ZCChatCustomCardHCollectionCell"];
        if(sobotGetSystemDoubleVersion()>=11){
            if (@available(iOS 11.0, *)) {
                collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
        }
        [_bgView addSubview:collectionView];
    
//        collectionView.backgroundColor = UIColor.placeholderTextColor;
        collectionView;
    });
}


-(void)btnExpand:(UIButton *)sender{
    self.tempModel.showAllMessage = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]) {
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemRefreshData text:@"" obj:self.tempModel];
    }
}

-(void)initDataToView:(SobotChatMessage *)message time:(NSString *)showTime{
    [super initDataToView:message time:showTime];
    
    self.tempModel = message;
    self.ivHeader.hidden = YES;
    self.lblNickName.hidden = YES;
    self.lblSugguest.hidden = YES;
    self.ivBgView.hidden = YES;
    
//    [_logoView loadWithURL:[NSURL URLWithString:sobotConvertToString(self.cardModel.cardImg)]];
//    [_labDesc setText:sobotConvertToString(self.cardModel.cardGuide)];
//    [_labTitle setText:sobotTrimString(self.cardModel.cardDesc)];
    
    [self.listArray removeAllObjects];
    itemHeight = 0;
    contentWidth = 300;
    if(self.tempModel.senderType!=0){
        contentWidth = contentWidth+ZCChatMarginHSpace;
    }
    if(self.cardModel.customCards.count > 0){
        for(SobotChatCustomCardInfo *info in self.cardModel.customCards){
            CGFloat logoHeight = 188;
            
            CGFloat descH = 24;
            if(info.customCardDesc){
                CGFloat tempH = [SobotUITools getHeightContain:sobotConvertToString(info.customCardDesc) font:SobotFont14 Width:contentWidth-ZCChatPaddingVSpace*2];
                if(tempH > 20){
                    descH = 44;
                }
            }
            CGFloat titleDescHeight = 34 + descH;
            CGFloat tipsHeight = 0;
            CGFloat btnHeight = 0;
            if(sobotConvertToString(info.customCardThumbnail).length == 0){
                logoHeight = 0;
            }
            // 可能隐藏此行  sobotConvertToString(info.customCardCount).length > 0 ||
//            if( sobotConvertToString(info.customCardAmount).length > 0 ){
//                // 金额和单位必现同时有
//                tipsHeight = 29;
//            }
            //////////////////////////////////
            if(message.richModel.customCard.cardType == 0){
                if(sobotConvertToString(info.customCardCount).length > 0 || sobotConvertToString(info.customCardAmount).length > 0){
                    tipsHeight = 17+12;
                }else{
                   
                }
            }
            if(message.richModel.customCard.cardType == 1){
                if (sobotConvertToString(info.customCardAmount).length == 0) {

                }else{
                    tipsHeight = 17+12;
                }
            }
            
            //////////////////////////////////
            
            
            // 计算要显示的button的个数
            CGFloat tempCount = 0;
            for (SobotChatCustomCardMenu *menu in info.customMenus) {
                if(menu.menuType == 0 && menu.menuLinkType == 1){
                    // 是跳转链接 并且是客服跳转类型，SDK不展示
                    continue;
                }
                if(self.tempModel.senderType!=0){
                    tempCount ++;
                }
            }
            // 按钮有上限 不能超过3个
            if (tempCount >3) {
                tempCount = 3;
            }
            
            // 如果有按钮，需要添加底部16的间隔
            if(tempCount > 0){
                // 由于 title未固定高度，导致下面计算有误差，理论上此处也需要添加12的底部间隔
                btnHeight = tempCount * (36) + (tempCount-1)*ZCChatRichCellItemSpace + ZCChatMarginHSpace +  ZCChatMarginVSpace;
            }else{
                // 没有按钮，仅需要添加12个间隔
                btnHeight = ZCChatMarginVSpace;
            }
            
            CGFloat totalHeight = logoHeight + tipsHeight + titleDescHeight + btnHeight;
            if(itemHeight<totalHeight){
                itemHeight = totalHeight;
            }
        }
        
        // invalidate之前的layout，这个很关键
        [self.collectionView.collectionViewLayout invalidateLayout];
        [self.listArray addObjectsFromArray:self.cardModel.customCards];
        // 一定要重新设置，否则尺寸不生效
        contentWidth = 300;
        if(self.tempModel.senderType!=0){
            contentWidth = contentWidth+ZCChatMarginHSpace;
//            _layoutBgWidth.constant = self.viewWidth -66;// 平铺的最大宽度
            _layoutBgWidth.constant = self.viewWidth - ZCChatPaddingHSpace;// 平铺的最大宽度
            if ([ZCUIKitTools getSobotIsRTLLayout]) {
                _layoutBgLeft.constant = -ZCChatPaddingHSpace;
            }else{
                _layoutBgLeft.constant = ZCChatPaddingHSpace;
            }
            _layoutCollectionViewHeight.constant = itemHeight + 4;

        }else{
            // 由于图片尺寸固定300*188,此处固定300宽度
//            contentWidth = self.maxWidth + ZCChatPaddingHSpace*2;
           
            if ([ZCUIKitTools getSobotIsRTLLayout]) {
                _layoutBgLeft.constant = -(self.viewWidth - contentWidth - ZCChatPaddingHSpace);
            }else{
                _layoutBgLeft.constant = self.viewWidth - contentWidth - ZCChatPaddingHSpace;
            }
            _layoutBgWidth.constant =  contentWidth;// 发送后的也是同样的宽度
            _layoutCollectionViewHeight.constant = itemHeight;// 用户发送的 这里不搞阴影，不用加间隔

        }
        
                
        self.layout.itemSize = CGSizeMake(contentWidth , itemHeight);
        // 这里我们使用重写systemLayoutSizeFittingSize的方式
        [self.collectionView reloadData];
        [self.collectionView layoutIfNeeded];
    }

    [self.bgView layoutIfNeeded];
}


//-(void)bgViewClick:(UITapGestureRecognizer *) tap{
//    NSString * link = self.tempModel.richModel.url;
//
//    if(sobotConvertToString(link).length  == 0){
//        return;
//    }
//    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
//        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeOpenFile text:sobotConvertToString(link)  obj:sobotConvertToString(link)];
//    }
//}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.listArray.count;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(self.tempModel.senderType!=0){
        return CGSizeMake(contentWidth-ZCChatMarginHSpace, itemHeight);
    }else{
        return CGSizeMake(contentWidth, itemHeight);
    }
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if(self.tempModel.senderType!=0){
//        return UIEdgeInsetsMake(0, 8, 0, 8);//分别为上、左、下、右
        // 这里不偏移一下，阴影边框会看不见
        return UIEdgeInsetsMake(0, 2, 0, 14);//分别为上、左、下、右
    }else{
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
}

- ( UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ZCChatCustomCardHCollectionCell *vcell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZCChatCustomCardHCollectionCell" forIndexPath:indexPath];
    SobotChatCustomCardInfo * model = self.cardModel.customCards[indexPath.row];
//    ZCChatCustomCardInfoBaseCell * vcell = (ZCChatCustomCardInfoBaseCell *)cell;
    vcell.indexPath = indexPath;
    vcell.message = self.tempModel;
    vcell.cardModel = model;
    vcell.delegate = self;
    NSInteger maxMenuCount = 0;
    if(self.cardModel.customCards.count > 0){
        for(SobotChatCustomCardInfo *info in self.cardModel.customCards){
            NSInteger tempCount = 0;
            for (SobotChatCustomCardMenu *menu in info.customMenus) {
                if(menu.menuType == 0 && menu.menuLinkType == 1){
                    
                }else{
                    tempCount ++;
                }
            }
            if(maxMenuCount < tempCount){
                maxMenuCount = tempCount;
            }
            tempCount = 0;
        }
    }
    if (maxMenuCount >3) {
        maxMenuCount = 3;
    }
    if(self.tempModel.senderType!=0){
        
        vcell.maxCustomMenus = (int)maxMenuCount;
    }else{
        vcell.maxCustomMenus = 0;
    }
    [vcell configureCellWithData:model message:self.tempModel];
    return vcell;
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
//    if(self.listArray.count > 0){
//        //    NSLog(@" 点击水平 item的 事件 %@",indexPath);
//        SobotChatCustomCardInfo * model = self.cardModel.customCards[indexPath.row];
//        ZCChatCustomCardInfoBaseCell * vcell = (ZCChatCustomCardInfoBaseCell *)cell;
//        vcell.indexPath = indexPath;
//        vcell.message = self.tempModel;
//        vcell.cardModel = model;
//        vcell.delegate = self;
//        [vcell configureCellWithData:model message:self.tempModel];
//    }
}

-(void)onCollectionItemMenuClick:(SobotChatCustomCardMenu *)menu index:(NSIndexPath *)index message:(SobotChatMessage *)model{
    [self menuItemClickButton:menu tag:(int)index.row];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
