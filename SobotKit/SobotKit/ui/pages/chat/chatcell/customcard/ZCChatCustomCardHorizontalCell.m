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
        [self.contentView addConstraint:sobotLayoutPaddingTop(0, self.bgView, self.ivBgView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(0, self.bgView, self.ivBgView)];
//        [self.contentView addConstraint:sobotLayoutMarginBottom(-ZCChatCellItemSpace, self.bgView, self.lblSugguest)];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(0, self.bgView, self.ivBgView)];
        
        
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
    
    
    
//    [_logoView loadWithURL:[NSURL URLWithString:sobotConvertToString(self.cardModel.cardImg)]];
//    [_labDesc setText:sobotConvertToString(self.cardModel.cardGuide)];
//    [_labTitle setText:sobotTrimString(self.cardModel.cardDesc)];
    
    [self.listArray removeAllObjects];
    itemHeight = 0;
    if(self.cardModel.customCards.count > 0){
        NSInteger maxMenuCount = 0;
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
        
        // invalidate之前的layout，这个很关键
        [self.collectionView.collectionViewLayout invalidateLayout];
        [self.listArray addObjectsFromArray:self.cardModel.customCards];
        // 一定要重新设置，否则尺寸不生效
        contentWidth = 280;
        if(self.tempModel.senderType!=0){
            itemHeight = 240 + ZCChatMarginHSpace + maxMenuCount*(32+ZCChatPaddingVSpace);
            _layoutBgWidth.constant = self.viewWidth -66;// 平铺的最大宽度
            _layoutCollectionViewHeight.constant = itemHeight+8;

        }else{
            itemHeight = 240 + 12;
//            contentWidth = self.maxWidth + ZCChatPaddingHSpace*2;
//            _layoutBgWidth.constant = self.maxWidth + ZCChatPaddingHSpace*2;
            contentWidth = self.maxWidth;
            _layoutBgWidth.constant =  self.maxWidth;// 发送后的也是同样的宽度
            _layoutCollectionViewHeight.constant = itemHeight;// 用户发送的 这里不搞阴影，不用加间隔

        }
        
                
        self.layout.itemSize = CGSizeMake(contentWidth , itemHeight);
        // 这里我们使用重写systemLayoutSizeFittingSize的方式
        [self.collectionView reloadData];
        [self.collectionView layoutIfNeeded];
    }

    [self.bgView layoutIfNeeded];
    if(self.tempModel.senderType == 0){
        [self setChatViewBgState:CGSizeMake(self.maxWidth-40,CGRectGetMaxY(_bgView.frame))];
    }else{
        [self setChatViewBgState:CGSizeMake(self.maxWidth,CGRectGetMaxY(_bgView.frame))];
    }
    

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
        return UIEdgeInsetsMake(0, 4, 0, 4);//分别为上、左、下、右
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
