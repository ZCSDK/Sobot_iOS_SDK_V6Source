//
//  ZCChatWhell1Cell.m
//  SobotKit
//
//  Created by lizh on 2024/1/19.
//

#import "ZCChatWhell1Cell.h"
#import <SobotCommon/SobotCommon.h>

//static const float gap = 15;

@interface ZCChatWhell1Cell ()<UIScrollViewDelegate>{
    int currentPage; // 当前页码
    NSInteger numberOfPages ; // 页数
}
@property (nonatomic,strong) NSMutableArray * listArray;
@property (nonatomic,strong)  SobotEmojiLabel * titleLab;
@property (nonatomic,strong) UIButton * btnPre;
@property (nonatomic,strong) UIButton * btnNext;
@property (nonatomic,strong) NSLayoutConstraint * layoutTitleHeight;
@property (nonatomic,strong) NSLayoutConstraint * layoutTitleWidth;

@property (nonatomic,strong) NSLayoutConstraint * layoutCollectionHeight;
@property (nonatomic,strong) NSLayoutConstraint * layoutBtnPreHight;
@property (nonatomic,strong) NSLayoutConstraint * layoutBtnPreT;

@property (nonatomic,assign) NSInteger cellNumOnPageInt;
@property (nonatomic,assign) NSInteger clickFlag;
@property (nonatomic,strong) UIScrollView *scrollView;
//@property (nonatomic,strong) UIView *bgSView;// 滑动视图的背景视图

@property (nonatomic,assign) CGFloat scrollViewH;
@end

@implementation ZCChatWhell1Cell

-(SobotEmojiLabel *)titleLab{
    if(!_titleLab){
        _titleLab = [ZCChatBaseCell createRichLabel];
        _titleLab.textColor = [ZCUIKitTools zcgetLeftChatTextColor];
        _titleLab.numberOfLines = 0;
    }
    return _titleLab;
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

    _scrollView = ({
        UIScrollView *iv = [[UIScrollView alloc]init];
        [self.contentView addSubview:iv];
        iv.scrollEnabled = YES;
        iv.userInteractionEnabled = YES;
        iv.showsVerticalScrollIndicator = NO;
        iv.showsHorizontalScrollIndicator = NO;
        iv.pagingEnabled = YES;
        iv.delegate = self;
        iv.backgroundColor = [UIColor clearColor];
        iv;
    });
    
    [self.contentView addSubview:self.titleLab];
    [self.contentView addSubview:self.btnPre];
    [self.contentView addSubview:self.btnNext];
    
    // 距离ivBgView，上面和左边
    [self.contentView addConstraints:sobotLayoutPaddingView(ZCChatPaddingVSpace, 0, ZCChatPaddingHSpace, 0, self.titleLab,self.ivBgView)];
    _layoutTitleWidth = sobotLayoutEqualWidth(ZCChatPaddingHSpace*2, self.titleLab, NSLayoutRelationEqual);
    _layoutTitleHeight = sobotLayoutEqualHeight(22, self.titleLab, NSLayoutRelationEqual);
    [self.contentView addConstraint:_layoutTitleWidth];
    [self.contentView addConstraint:_layoutTitleHeight];
    
    // collectionview，与titleLab等宽，并顶部距离其一个间隔
    [self.contentView addConstraint:sobotLayoutMarginTop(ZCChatItemSpace10, self.scrollView, _titleLab)];
    [self.contentView addConstraint:sobotLayoutPaddingLeft(0, self.scrollView, self.titleLab)];
    [self.contentView addConstraint:sobotLayoutPaddingRight(0, self.scrollView, self.titleLab)];
    _layoutCollectionHeight = sobotLayoutEqualHeight(0, self.scrollView, NSLayoutRelationEqual);
    [self.contentView addConstraint:_layoutCollectionHeight];
    
    // btnPre，整个最终高的确定对象，上下左右均有定义
    _layoutBtnPreT = sobotLayoutMarginTop(ZCChatItemSpace10, self.btnPre, self.scrollView);
    [self.contentView addConstraint:_layoutBtnPreT];
    [self.contentView addConstraint:sobotLayoutPaddingLeft(0, self.btnPre, self.titleLab)];
    _layoutBtnPreHight = sobotLayoutEqualHeight(25, self.btnPre, NSLayoutRelationEqual);
    [self.contentView addConstraint:_layoutBtnPreHight];
    [self.contentView addConstraint:sobotLayoutEqualWidth(120, self.btnPre, NSLayoutRelationEqual)];
    [self.contentView addConstraint:sobotLayoutMarginBottom(-ZCChatCellItemSpace, self.btnPre, self.lblSugguest)];
    
    // 和titleLab有边界相同
    [self.contentView addConstraint:sobotLayoutMarginTop(ZCChatItemSpace10, self.btnNext, self.scrollView)];
    [self.contentView addConstraint:sobotLayoutPaddingRight(0, self.btnNext, self.titleLab)];
    [self.contentView addConstraint:sobotLayoutEqualHeight(25, self.btnNext, NSLayoutRelationEqual)];
    [self.contentView addConstraint:sobotLayoutEqualWidth(120, self.btnNext, NSLayoutRelationEqual)];
    
    _listArray = [[NSMutableArray alloc] init];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    [self creatView];
}

#pragma mark - cell data
-(void)initDataToView:(SobotChatMessage *)message time:(NSString *)showTime{
    _layoutCollectionHeight.constant = 0;
    [super initDataToView:message time:showTime];
    numberOfPages = 0;
    currentPage = 0;
    self.clickFlag = 0;
    CGFloat maxContentWidth = self.maxWidth;
    // 处理标题
    NSString * text = sobotConvertToString(message.richModel.richContent.msg);
    text = [text stringByReplacingOccurrencesOfString:@"&#x27;" withString:@"’"];
    [ZCChatBaseCell configHtmlText:text label:self.titleLab right:self.isRight];
    CGSize size = [self.titleLab preferredSizeWithMaxWidth:maxContentWidth];
    if(size.height < 22){
        size.height = 22;
    }
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
    _btnNext.hidden = YES;
    _btnPre.hidden = YES;
    int templateId = message.richModel.richContent.templateId;
    CGFloat collectionHeight = 0;
    CGFloat itemHeight = 0;
    _layoutBtnPreHight.constant = 0;
    _layoutBtnPreT.constant = 0;
     if(templateId == 1){
         _cellNumOnPageInt = 0; // 每页多少条
         numberOfPages = 0; // 几页
         if (_listArray.count <= 3) {
             _cellNumOnPageInt = _listArray.count;
             numberOfPages = 1;
         }else{
             _cellNumOnPageInt = 3;
             if(templateId == 1){
                 _cellNumOnPageInt = 10;
                 if(_listArray.count < _cellNumOnPageInt){
                     _cellNumOnPageInt = _listArray.count;
                 }
             }
             if (_listArray.count%_cellNumOnPageInt > 0) {
                 numberOfPages = _listArray.count/_cellNumOnPageInt + 1;
             }else {
                 numberOfPages = _listArray.count/_cellNumOnPageInt;
             }
         }
         if (numberOfPages >1) {
             _btnPre.hidden = NO;
             _btnPre.enabled = false;
             _btnNext.hidden = NO;
             _btnNext.enabled = true;
             _layoutBtnPreHight.constant = 25;
             _layoutBtnPreT.constant = ZCChatItemSpace10;
         }else{
             _btnPre.hidden = YES;
             _btnPre.enabled = YES;
             _btnNext.hidden = YES;
             _btnNext.enabled = false;
             _layoutBtnPreHight.constant = 0;
             _layoutBtnPreT.constant = 0;
         }
         
        
         SobotChatRichContent *pm = self.tempModel.richModel.richContent;
         itemHeight = 36 ;
         if(message.richModel.richContent.showLinkStyle){
             itemHeight = 25 ;
         }
      collectionHeight = [self createScrollViewSubItem:message.richModel.richContent.showLinkStyle molH:itemHeight list:pm.interfaceRetList];
         
    }
    _layoutCollectionHeight.constant = collectionHeight;
    
    [self setChatViewBgState:CGSizeMake(maxContentWidth,collectionHeight + size.height)];
}

-(CGFloat)createScrollViewSubItem:(BOOL)showLinkStyle molH:(CGFloat)molH list:(NSMutableArray*)list {
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.scrollViewH = 0;
    float titleMaxWidth = self.maxWidth - ZCChatPaddingHSpace*2;
    CGFloat itemH = molH;
    // 先获取最大的高度
    CGFloat currPageH = 0;
    for (int i = 0; i<list.count; i++) {
        if (i % _cellNumOnPageInt == 0 && i !=0 ) {
            currPageH = 0;
        }
        NSDictionary *detail = list[i];
        NSString *title = sobotConvertToString([detail objectForKey:@"title"]);
        if (showLinkStyle) {
            title = [NSString stringWithFormat:@"%d.%@",i+1,sobotConvertToString([detail objectForKey:@"title"])];
        }
        CGSize size = [title sizeWithFont:SobotFont14 constrainedToSize:CGSizeMake(titleMaxWidth-24, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
        if (showLinkStyle) {
            if (size.height > itemH) {
                itemH = size.height+8;
            }
        }else{
            if (size.height > itemH) {
                itemH = size.height + 16;
            }
        }
        // 得到单个高度 + 间隙10
        if (showLinkStyle) {
            currPageH = currPageH + itemH +5;  // 超链的格式不加间距
        }else{
            currPageH = currPageH + itemH + 12;
        }
        if (currPageH >self.scrollViewH) {
            self.scrollViewH = currPageH;
        }
        itemH = molH; // 计算完回执
    }

    CGFloat btnH = molH;
    // 布局子视图和分页
    if (!sobotIsNull(list) && list.count >0) {
        for (int i = 0; i<numberOfPages; i++) {
            // 一共有几页
            UIView *iv = [[UIView alloc]init];
            iv.frame = CGRectMake(self.maxWidth*i, 0, self.maxWidth, self.scrollViewH);
            [self.scrollView addSubview:iv];
            iv.backgroundColor = UIColor.clearColor;
            CGFloat itemY = 0;
            for (int j = 0; j <_cellNumOnPageInt; j++) {
                int index = i*_cellNumOnPageInt +j;
                if (index < list.count) {
                    SobotButton *objBtn = [SobotButton buttonWithType:UIButtonTypeCustom];
                    NSDictionary *detail = list[index];
                    objBtn.obj = detail;
                    NSString *title = sobotConvertToString([detail objectForKey:@"title"]);
                    if (showLinkStyle) {
                        title = [NSString stringWithFormat:@"%d.%@",index+1,sobotConvertToString([detail objectForKey:@"title"])];
                    }
                    CGSize size = [title sizeWithFont:SobotFont14 constrainedToSize:CGSizeMake(titleMaxWidth-24, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
                    if (showLinkStyle) {
                        if (size.height > btnH) {
                            btnH = size.height + 8;
                        }
                    }else{
                        if (size.height + 16 > btnH) {
                            btnH = size.height + 16;
                        }
                    }
                    objBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 12);
                    objBtn.titleLabel.numberOfLines = 0;
                    objBtn.titleLabel.font = SobotFont14;
                    [objBtn setTitle:title forState:0];
                    [objBtn addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
                    objBtn.frame = CGRectMake(0, itemY, self.maxWidth, btnH);
                    if (showLinkStyle) {
                        itemY = itemY + btnH +5;// 不加间隔
                        objBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                    }else{
                        itemY = itemY + btnH + 12;
                    }
                    [iv addSubview:objBtn];
                    
                    [objBtn setTitleColor:[ZCUIKitTools zcgetLeftChatTextColor] forState:0];
                    if (!self.tempModel.isHistory) {
//                        [objBtn setTitleColor:[ZCUIKitTools zcgetChatLeftLinkColor] forState:0];
                        [objBtn setTitleColor:[ZCUIKitTools zcgetServerConfigBtnBgColor] forState:0];
                    }
                    if (!showLinkStyle) {
                        [objBtn setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark3)];
                        objBtn.layer.cornerRadius = 4;
                        //添加阴影
//                        objBtn.layer.shadowOpacity= 0.8;
//                        objBtn.layer.shadowColor = UIColorFromKitModeColorAlpha(SobotColorTextMain, 0.07).CGColor;
//                        objBtn.layer.shadowOffset = CGSizeZero;//投影偏移
//                        objBtn.layer.shadowRadius = 2;
                        objBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
                    }
                    // 回执默认值
                    btnH = molH;
                }
            }
        }
    }
    [_scrollView setContentSize:CGSizeMake(self.maxWidth * numberOfPages, 0)];
    
    if (showLinkStyle) {
        self.scrollViewH = self.scrollViewH - 5;  // 超链的格式不加间距
    }else{
        self.scrollViewH = self.scrollViewH - 12;
    }
    return  self.scrollViewH;
}

#pragma mark -- 上一页 + 下一页
-(void)onPageClick:(UIButton *) btn{
    if(btn == _btnNext){
        currentPage = currentPage + 1;
        CGRect f = self.scrollView.frame;
        CGFloat x = currentPage * f.size.width ;// 15是间隔间距
        if((currentPage+1) >= numberOfPages){
            self.btnNext.enabled = false;
            currentPage = (int)numberOfPages-1;
        }
        if(currentPage > 0){
            self.btnPre.enabled = true;
        }
        [self.scrollView setContentOffset:CGPointMake(x, 0) animated:YES];
    }else{
        currentPage = currentPage - 1;
        if(currentPage <= 0){
            currentPage = 0;
            self.btnPre.enabled = false;
        }
        
        if(currentPage < numberOfPages){
            self.btnNext.enabled = true;
        }
        CGRect f = self.scrollView.frame;
        CGFloat x = currentPage * f.size.width;
        [self.scrollView setContentOffset:CGPointMake(x, 0) animated:YES];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    // 判断当前是第几页
    NSInteger index = scrollView.contentOffset.x/scrollView.bounds.size.width;
//    NSLog(@"index === %ld",index);
    currentPage = (int)index;
    if(currentPage > 0){
        self.btnPre.enabled = true;
    }
    
    if(currentPage <= 0){
        currentPage = 0;
        self.btnPre.enabled = false;
    }
    
    if((currentPage+1) >= numberOfPages){
        self.btnNext.enabled = false;
    }else{
        if(numberOfPages > 0){
            self.btnNext.enabled = true;
        }
    }
}

#pragma mark -- 点击 发送消息
-(void)itemClick:(SobotButton*)sender{
    SobotChatRichContent *pm = self.tempModel.richModel.richContent;
    if(pm.interfaceRetList.count == 0){
        return;
    }
    NSDictionary *detail = (NSDictionary*)sender.obj;
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

-(ZCLibConfig *)getCurConfig{
    return [[ZCPlatformTools sharedInstance] getPlatformInfo].config;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
