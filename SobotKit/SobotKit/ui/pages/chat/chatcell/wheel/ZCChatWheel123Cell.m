//
//  ZCChatWheel134Cell.m
//  SobotKit
//
//  Created by zhangxy on 2022/9/20.
//

#import "ZCChatWheel123Cell.h"
#import "ZCChatWheelFlowLayout.h"
#import <SobotCommon/SobotCommon.h>
#import "ZCChatWheelCollectionCell.h"
#import "ZCChatWheelCollection2Cell.h"


@interface ZCChatWheel123Cell()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,ZCChatWheelFlowLayoutDelegate>{
    int currentPage;
    NSInteger numberOfPages ;
    
}

@property (nonatomic,strong) NSMutableArray * listArray;

@property (nonatomic,strong)  SobotEmojiLabel * titleLab;
@property (nonatomic,strong) ZCChatWheelFlowLayout *layout;
@property (nonatomic,strong) UICollectionView * collectionView;
@property (nonatomic,strong) UIPageControl *pageControl;
@property (nonatomic,strong) UIButton * btnPre;
@property (nonatomic,strong) UIButton * btnNext;


@property (nonatomic,strong) NSLayoutConstraint * layoutTitleHeight;
@property (nonatomic,strong) NSLayoutConstraint * layoutTitleWidth;

@property (nonatomic,strong) NSLayoutConstraint * layoutCollectionHeight;
@property (nonatomic,strong) NSLayoutConstraint * layoutBtnPreHight;

@property (nonatomic,assign) NSInteger cellNumOnPageInt;
@property (nonatomic,assign) NSInteger clickFlag;

@end

@implementation ZCChatWheel123Cell


#pragma mark - cell
-(SobotEmojiLabel *)titleLab{
    if(!_titleLab){
        _titleLab = [ZCChatBaseCell createRichLabel];
        _titleLab.textColor = [ZCUIKitTools zcgetLeftChatTextColor];
        _titleLab.numberOfLines = 0;
    }
    return _titleLab;
}
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        
        self.layout = [ZCChatWheelFlowLayout new];
        self.layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.layout.minimumLineSpacing = 0;
        self.layout.delegate = self;
        
        
        _layout.itemSize = CGSizeMake(ScreenWidth, 20);
        _layout.minimumLineSpacing = [ZCUIKitTools zcgetChatLineSpacing];
        _layout.minimumInteritemSpacing = 0;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[ZCChatWheelCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([ZCChatWheelCollectionCell class])];
        [_collectionView registerClass:[ZCChatWheelCollection2Cell class] forCellWithReuseIdentifier:NSStringFromClass([ZCChatWheelCollection2Cell class])];
        
        _collectionView.showsHorizontalScrollIndicator=NO;
        _collectionView.showsVerticalScrollIndicator=NO;
        _collectionView.backgroundColor=[UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
//        _collectionView.scrollEnabled = NO;
        
        
        self.collectionView.pagingEnabled = YES;
    }
    return _collectionView;
}

-(UIPageControl *)pageControl
{
    if(!_pageControl){
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.currentPage = 0;
        _pageControl.currentPageIndicatorTintColor = [ZCUIKitTools zcgetRightChatColor];
        if([SobotUITools getSobotThemeMode] == SobotThemeMode_Dark){
            _pageControl.pageIndicatorTintColor = [ZCUIKitTools zcgetTextPlaceHolderColor];
        }else{
            _pageControl.pageIndicatorTintColor = UIColorFromModeColor(SobotColorBgMainDark1);
        }
        _pageControl.hidesForSinglePage = YES;
        _pageControl.userInteractionEnabled = NO;
    }
    return _pageControl;
}


-(UIButton *)btnPre{
    if(!_btnPre){
        _btnPre = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnPre setTitle:SobotKitLocalString(@"上一页") forState:0];
        [_btnPre setImage:SobotKitGetImage(@"zcicon_pre_page") forState:UIControlStateNormal];
        [_btnPre setImage:SobotKitGetImage(@"zcicon_no_pre_page") forState:UIControlStateDisabled];
        [_btnPre setTitleColor:[ZCUIKitTools zcgetServiceNameTextColor] forState:0];
        [_btnPre setTitleColor:[ZCUIKitTools zcgetTextPlaceHolderColor] forState:UIControlStateDisabled];
        [_btnPre.titleLabel setFont:[ZCUIKitTools zcgetKitChatFont]];
        [_btnPre addTarget:self action:@selector(onPageClick:) forControlEvents:UIControlEventTouchUpInside];
        _btnPre.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        
    }
    return _btnPre;
}
-(UIButton *)btnNext{
    if(!_btnNext){
        _btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnNext.titleLabel setFont:[ZCUIKitTools zcgetKitChatFont]];
        [_btnNext setTitle:SobotKitLocalString(@"下一页") forState:0];
        [_btnNext setImage:SobotKitGetImage(@"zcicon_last_page") forState:UIControlStateNormal];
        [_btnNext setImage:SobotKitGetImage(@"zcicon_no_last_page") forState:UIControlStateDisabled];
        [_btnNext setTitleColor:[ZCUIKitTools zcgetServiceNameTextColor] forState:0];
        [_btnNext setTitleColor:[ZCUIKitTools zcgetTextPlaceHolderColor] forState:UIControlStateDisabled];
        [_btnNext addTarget:self action:@selector(onPageClick:) forControlEvents:UIControlEventTouchUpInside];
        if(sobotGetSystemDoubleVersion()>=9.0){
            _btnNext.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
        }else{
            [_btnNext setTitleEdgeInsets:UIEdgeInsetsMake(0, - _btnNext.imageView.image.size.width, 0, _btnNext.imageView.image.size.width)];
            [_btnNext setImageEdgeInsets:UIEdgeInsetsMake(0, _btnNext.titleLabel.bounds.size.width, 0, -_btnNext.titleLabel.bounds.size.width)];
        }
        _btnNext.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    }
    return _btnNext;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self creatView];
    }
    return self;
}

- (void)creatView
{
    if(self.pageControl){
        [self.pageControl removeFromSuperview];
        self.pageControl = nil;
        NSLog(@"ssssssss");
    }
    
    [self.contentView addSubview:self.titleLab];
    [self.contentView addSubview:self.collectionView];
    [self.contentView addSubview:self.btnPre];
    [self.contentView addSubview:self.btnNext];
    [self.contentView addSubview:self.pageControl];
    
    // 距离ivBgView，上面和左边
    [self.contentView addConstraints:sobotLayoutPaddingView(ZCChatPaddingVSpace, 0, ZCChatPaddingHSpace, 0, self.titleLab,self.ivBgView)];
    _layoutTitleWidth = sobotLayoutEqualWidth(30, self.titleLab, NSLayoutRelationEqual);
    _layoutTitleHeight = sobotLayoutEqualHeight(0, self.titleLab, NSLayoutRelationEqual);
    [self.contentView addConstraint:_layoutTitleWidth];
    [self.contentView addConstraint:_layoutTitleHeight];
    
    // collectionview，与titleLab等宽，并顶部距离其一个间隔
    [self.contentView addConstraint:sobotLayoutMarginTop(ZCChatCellItemSpace, self.collectionView, _titleLab)];
    [self.contentView addConstraint:sobotLayoutPaddingLeft(0, self.collectionView, self.titleLab)];
    [self.contentView addConstraint:sobotLayoutPaddingRight(0, self.collectionView, self.titleLab)];
    _layoutCollectionHeight = sobotLayoutEqualHeight(0, self.collectionView, NSLayoutRelationEqual);
    [self.contentView addConstraint:_layoutCollectionHeight];
    
    // btnPre，整个最终高的确定对象，上下左右均有定义
    [self.contentView addConstraint:sobotLayoutMarginTop(ZCChatCellItemSpace, self.btnPre, self.collectionView)];
    [self.contentView addConstraint:sobotLayoutPaddingLeft(0, self.btnPre, self.titleLab)];
    _layoutBtnPreHight = sobotLayoutEqualHeight(25, self.btnPre, NSLayoutRelationEqual);
    [self.contentView addConstraint:_layoutBtnPreHight];
    [self.contentView addConstraint:sobotLayoutEqualWidth(90, self.btnPre, NSLayoutRelationEqual)];
    [self.contentView addConstraint:sobotLayoutMarginBottom(-ZCChatCellItemSpace, self.btnPre, self.lblSugguest)];
    
    // 和titleLab有边界相同
    [self.contentView addConstraint:sobotLayoutMarginTop(ZCChatCellItemSpace, self.btnNext, self.collectionView)];
    [self.contentView addConstraint:sobotLayoutPaddingRight(0, self.btnNext, self.titleLab)];
    [self.contentView addConstraint:sobotLayoutEqualHeight(25, self.btnNext, NSLayoutRelationEqual)];
    [self.contentView addConstraint:sobotLayoutEqualWidth(90, self.btnNext, NSLayoutRelationEqual)];
    
    
    // pageControl,和btnPre底部相同，和titleLab宽度相同
    [self.contentView addConstraint:sobotLayoutPaddingBottom(0, self.pageControl, self.btnPre)];
    [self.contentView addConstraints:sobotLayoutPaddingView(0,0, 10, -10, self.pageControl, self.titleLab)];
    
    _listArray = [[NSMutableArray alloc] init];
}

#pragma mark - cell data
-(void)initDataToView:(SobotChatMessage *)message time:(NSString *)showTime{
    [super initDataToView:message time:showTime];
    numberOfPages = 0;
    currentPage = 0;
    self.clickFlag = 0;
    CGFloat maxContentWidth = self.maxWidth;
    // 处理标题
    NSString * text = sobotConvertToString(message.richModel.richContent.msg);
    [ZCChatBaseCell configHtmlText:text label:self.titleLab right:self.isRight];
    CGSize size = [self.titleLab preferredSizeWithMaxWidth:maxContentWidth];
    _layoutTitleWidth.constant = maxContentWidth;
    _layoutTitleHeight.constant = size.height;
    [_listArray removeAllObjects];
//    [_collectionView reloadData];
    
    if(message.richModel.richContent && message.richModel.richContent.interfaceRetList && [message.richModel.richContent.interfaceRetList isKindOfClass:[NSArray class]]){
        for(NSDictionary *item in message.richModel.richContent.interfaceRetList){
            [_listArray addObject:item];
        }
    }
    // 计算collectionView的高度
    _pageControl.hidden = YES;
    _pageControl.currentPage = 0;
    _btnNext.hidden = YES;
    _btnPre.hidden = YES;
    int templateId = message.richModel.richContent.templateId;
    CGFloat collectionHeight = 0;
    CGFloat itemHeight = 0;
    _layoutBtnPreHight.constant = 0;
    if(templateId == 0 || templateId == 2){
        // 114 card 标题+图片+文字,//2, 94 address 没有标题
        _cellNumOnPageInt = 3;
        if(_listArray.count <= 3){
            _cellNumOnPageInt = _listArray.count;
        }else{
            _pageControl.hidden = NO;
            _layoutBtnPreHight.constant = 25;
            
            if (self.listArray.count%_cellNumOnPageInt > 0) {
                numberOfPages = self.listArray.count/_cellNumOnPageInt + 1;
            }else {
                numberOfPages = self.listArray.count/_cellNumOnPageInt;
            }
            _pageControl.numberOfPages = numberOfPages;
            _pageControl.currentPage = 0;
        }
        itemHeight = (templateId==2?90:114);
        collectionHeight = _cellNumOnPageInt * itemHeight + (_cellNumOnPageInt-1)*ZCChatPaddingVSpace;
        
    }else if(templateId == 1){
        _pageControl.hidden = YES;
        _cellNumOnPageInt = 10;
        if(_listArray.count <= 10){
            _cellNumOnPageInt = _listArray.count;
        }else{
            if (self.listArray.count%13 > 0) {
                numberOfPages = self.listArray.count/13 + 1;
            }else {
                numberOfPages = self.listArray.count/13;
            }
            _btnPre.hidden = NO;
            _btnPre.enabled = false;
            _btnNext.hidden = NO;
            _layoutBtnPreHight.constant = 25;
        }
        
        // 34  text
        itemHeight = 30 + ZCChatCellItemSpace;
        if(message.richModel.richContent.showLinkStyle){
            itemHeight = 34 + ZCChatCellItemSpace;
        }
        collectionHeight = _cellNumOnPageInt * itemHeight + (_cellNumOnPageInt-1)*ZCChatPaddingVSpace;
    }
    self.pageControl.numberOfPages = numberOfPages;
    
    _layoutCollectionHeight.constant = collectionHeight;
    
    // invalidate之前的layout，这个很关键
    [self.collectionView.collectionViewLayout invalidateLayout];
    // 一定要重新设置，否则尺寸不生效,需要减去[ZCUIKitTools zcgetChatLineSpacing]间隔
    self.layout.itemSize = CGSizeMake(maxContentWidth - [ZCUIKitTools zcgetChatLineSpacing] , itemHeight);
    [self.collectionView reloadData];
    
    // 这里我们使用重写systemLayoutSizeFittingSize的方式
    [self.collectionView layoutIfNeeded];
    
    [self setChatViewBgState:CGSizeMake(maxContentWidth,collectionHeight + size.height)];
}

#pragma mark - 计算高度
//- (CGSize)systemLayoutSizeFittingSize:(CGSize)targetSize withHorizontalFittingPriority:(UILayoutPriority)horizontalFittingPriority verticalFittingPriority:(UILayoutPriority)verticalFittingPriority
//{
//    // 先对bgview进行布局
////    self.bgView.frame = CGRectMake(0, 0, targetSize.width, 44);
////    [self.bgView layoutIfNeeded];
//
//    // 在对collectionView进行布局
////    self.collectionView.frame = CGRectMake(0, 0, targetSize.width-Margin*2, 44);
//    [self.collectionView layoutIfNeeded];
//
//    // 由于这里collection的高度是动态的，这里cell的高度我们根据collection来计算
//    CGSize collectionSize = self.collectionView.collectionViewLayout.collectionViewContentSize;
//    CGFloat cotentViewH = collectionSize.height + ZCChatMarginHSpace*2;
//
//    // 返回当前cell的高度
//    return CGSizeMake([UIScreen mainScreen].bounds.size.width, cotentViewH);
//}

#pragma mark - collection
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if(self.tempModel.richModel.richContent.templateId==2){
        ZCChatWheelCollection2Cell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZCChatWheelCollection2Cell class]) forIndexPath:indexPath];
        cell.indexPath = indexPath;
        [cell configureCellWithPostURL:self.listArray[indexPath.row] message:self.tempModel];
        return cell;
    }else{
        ZCChatWheelCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZCChatWheelCollectionCell class]) forIndexPath:indexPath];
        cell.indexPath = indexPath;
        [cell configureCellWithPostURL:self.listArray[indexPath.row] message:self.tempModel];
        return cell;
    }
    
}

#pragma mark - 滑动代理事件
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint point = scrollView.contentOffset;
    NSLog(@"%f,%f",point.x,point.y);
    CGRect f = self.collectionView.frame;
    CGFloat x = point.x/f.size.width ;
    if(x == 0){
        self.btnPre.enabled = false;
    }else{
        self.btnPre.enabled = true;
    }
    if(x >= numberOfPages -1.2){
        self.btnNext.enabled = false;
    }else{
        self.btnNext.enabled = true;
    }
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout cellCenteredAtIndexPath:(NSIndexPath *)indexPath page:(int)page{
    self.pageControl.currentPage = page; // 分页控制器当前显示的页数
    NSLog(@"sssssssssssssss %d",page);
    
//    if(page > 0){
//        self.btnPre.enabled = true;
//    }
//
////
//    if(currentPage <= 0){
//        currentPage = 0;
//        self.btnPre.enabled = false;
//    }
//    if(currentPage > numberOfPages-1){
//        currentPage = (int)numberOfPages-1;
//        self.btnNext.enabled = false;
//    }
}


-(void)onPageClick:(UIButton *) btn{
    if(btn == _btnNext){
        currentPage = currentPage + 1;
        CGRect f = self.collectionView.frame;
        f.origin.x = currentPage * f.size.width;
        if((currentPage+1) > numberOfPages-1){
            self.btnNext.enabled = false;
            currentPage = (int)numberOfPages-1;
        }
        if(currentPage > 0){
            self.btnPre.enabled = true;
        }
        [self.collectionView scrollRectToVisible:f animated:YES];
    }else{
        currentPage = currentPage - 1;
        if(currentPage <= 0){
            currentPage = 0;
            self.btnPre.enabled = false;
        }
        if(currentPage < numberOfPages){
            self.btnNext.enabled = true;
        }
        CGRect f = self.collectionView.frame;
        f.origin.x = currentPage * f.size.width;
        [self.collectionView scrollRectToVisible:f animated:YES];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _listArray.count;
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);//分别为上、左、下、右
}



// 点击发送消息
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //    NSLog(@" 点击水平 item的 事件 %@",indexPath);
    //    NSDictionary * model = _listArray[indexPath.row];
    
    SobotChatRichContent *pm = self.tempModel.richModel.richContent;
    if(pm.interfaceRetList.count == 0){
        return;
    }
    NSDictionary *detail = [pm.interfaceRetList objectAtIndex:indexPath.row];
    
    if (pm.endFlag) {
        // 最后一轮会话，有外链，点击跳转外链
        if (![@"" isEqualToString: sobotConvertToString(detail[@"anchor"])]) {
            // 点击超链跳转
            if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]) {
                [self.delegate cellItemClick:nil type:ZCChatCellClickTypeOpenURL text:@"" obj:sobotConvertToString(detail[@"anchor"])];
            }
        }
        return;
    }
    
    NSInteger clickFlagInt = self.tempModel.richModel.richContent.clickFlag;
    
    // 历史记录，不允许多次点击，或者允许多次点击，但是当前cid不一样
    if (self.tempModel.isHistory && (clickFlagInt == 0 || (clickFlagInt>0&&[self getCurConfig].cid != self.tempModel.cid))) {
        return;
    }
    
    
    if (self.clickFlag > 0 && clickFlagInt == 0) {
//        clickFlagInt == 0 只能点击一次 模版一
        return;
    }
    self.clickFlag ++;
    
    
    // 发送点击消息
    NSString * title = sobotConvertToString(detail[@"title"]);
    NSDictionary * dict = @{@"requestText":[pm getRequestText:detail],
                            @"question":[pm getQuestion:detail],
                            @"questionFlag":@"2",
                            @"title":title,@"ishotguide":@"0"
                            };
    if ([self getCurConfig].isArtificial) {
        dict = @{@"title":title,@"ishotguide":@"0"};
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]) {
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeCollectionSendMsg text:@"" obj:dict];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(ZCLibConfig *)getCurConfig{
    return [[ZCPlatformTools sharedInstance] getPlatformInfo].config;
}

@end
