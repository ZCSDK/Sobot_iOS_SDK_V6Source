//
//  ZCOrderContentCell.m
//  SobotKit
//
//  Created by lizh on 2022/9/13.
//

#import "ZCOrderContentCell.h"
#import <SobotCommon/SobotCommon.h>
#import "ZCUIKitTools.h"
#import "ZCActionSheet.h"
#import <SobotChatClient/ZCHtmlCore.h>
@interface ZCOrderContentCell()<UITextViewDelegate,ZCActionSheetDelegate,UITextFieldDelegate>
{
    SobotImageView *imageView;
    UIButton *delButton;
}

@property(nonatomic,strong)NSLayoutConstraint *textViewEH;
@property(nonatomic,strong)NSLayoutConstraint *fileScrollViewPB;
@property(nonatomic,strong)NSLayoutConstraint *textDescPB;

@property(nonatomic,strong)NSLayoutConstraint *fileScrollViewPL;
@property(nonatomic,strong)NSLayoutConstraint *fileScrollViewPR;
@property(nonatomic,strong)NSLayoutConstraint *fileScrollViewEH;
@property(nonatomic,strong)NSLayoutConstraint *fileScrollViewMT;

@property(nonatomic,strong)NSLayoutConstraint *tiplabPT;
@property(nonatomic,strong)NSLayoutConstraint *tipLabH;
@property(nonatomic,strong)NSLayoutConstraint *textDescMT;

@property (nonatomic, strong) UIView *fileItemsView;
@property (nonatomic, strong) UILabel *bottomTipLab;

// 上传附件的按钮
@property (nonatomic,strong) UIButton *fileButton;
@property (nonatomic, strong) UIView *fileBtnBgView;
@property (nonatomic, strong) UILabel *filelab;
@property (nonatomic,strong) UIImageView *iconImg;

// 底部提示文案的约束
@property (nonatomic,strong)NSLayoutConstraint *bottomTipLabMT;
@property (nonatomic,strong)NSLayoutConstraint *fileItemsViewH;
@property (nonatomic,strong)NSLayoutConstraint *fileBgViewW;
@property (nonatomic,strong)NSLayoutConstraint *fileItemPB;
@property (nonatomic,strong)NSLayoutConstraint *tipLabEH;
@property (nonatomic,strong)NSLayoutConstraint *fileItemsViewMT;
@property (nonatomic,strong)NSLayoutConstraint *fileBtnBgViewMT;
@property (nonatomic,strong)NSLayoutConstraint *fileBtnBgViewEH;
// 每一个图片的宽高
@property (nonatomic, assign) CGFloat itemW;
@end

@implementation ZCOrderContentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self createItemsView];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.userInteractionEnabled=YES;
        [self createItemsView];
        self.backgroundColor = [ZCUIKitTools zcgetLightGrayDarkBackgroundColor];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadScrollView) name:@"ZCOrderContentCellReload" object:nil];
    }
    return self;
}

-(void)createItemsView{
    // 整体按约束布局，提供横竖屏的最大高度
    self.itemW = (ScreenWidth-32-3*8)/4;
    self.itemW = 0; // 默认0 单个64
    _tipLab = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.contentView addSubview:iv];
        iv.textColor = UIColorFromKitModeColor(SobotColorTextSub);
        iv.font = SobotFont14;
        iv.numberOfLines = 0;
        iv.text = SobotKitLocalString(@"问题描述");
        self.tiplabPT = sobotLayoutPaddingTop(EditCellPT, iv, self.contentView);
        [self.contentView addConstraint:self.tiplabPT];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(EditCellHSpec, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-EditCellHSpec, iv, self.contentView)];
        self.tipLabH = sobotLayoutEqualHeight(20, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.tipLabH];
        iv.hidden = YES;
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            iv.textAlignment = NSTextAlignmentRight;
        }else{
            iv.textAlignment = NSTextAlignmentLeft;
        }
        iv;
    });
    
    _textDesc = ({
        ZCUITextView *iv = [[ZCUITextView alloc]init];
        iv.placeholder = @"";
        [iv setPlaceholderColor:UIColorFromKitModeColor(SobotColorTextSub1)];
        [iv setFont:SobotFont14];
        [iv setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
        iv.delegate = self;
        iv.placeholederFont = SobotFont14;
        iv.layer.cornerRadius = 4.0f;
        iv.layer.masksToBounds = YES;
        [iv setBackgroundColor:UIColor.clearColor];
        [self.contentView addSubview:iv];
        self.textDescMT = sobotLayoutMarginTop(0, iv, self.tipLab);
        [self.contentView addConstraint:self.textDescMT];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(EditCellHSpec-8, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-EditCellHSpec+8, iv, self.contentView)];
        self.textViewEH = sobotLayoutEqualHeight(74, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.textViewEH];
        
//        iv.textContainerInset = UIEdgeInsetsMake(8, 2, 8, 2); // 上, 左, 下, 右
        [iv setContentInset:UIEdgeInsetsMake(8, 2, 8, 2)];
//        [iv setContentOffset:CGPointZero animated:NO];
        iv;
    });
    
    // 这里需要计算宽度
    NSString *tip = SobotKitLocalString(@"上传附件");
    CGFloat w1 = [SobotUITools getWidthContain:tip font:SobotFont12 Height:20];
    // 左右间距
    w1 = w1 + 42;
    if (w1 <90) {
        w1 = 90;
    }
    
    _fileBtnBgView = ({
        UIView *iv = [[UIView alloc]init];
        [self.contentView addSubview:iv];
        iv.layer.masksToBounds = YES;
        iv.layer.cornerRadius = 4;
        iv.layer.borderWidth = 1;
        iv.layer.borderColor = UIColorFromKitModeColor(SobotColorBgTopLine).CGColor;
        self.fileBtnBgViewMT = sobotLayoutMarginTop(17, iv, self.textDesc);
        [self.contentView addConstraint:self.fileBtnBgViewMT];
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            [self.contentView addConstraint:sobotLayoutPaddingRight(-16, iv, self.contentView)];
        }else{
            [self.contentView addConstraint:sobotLayoutPaddingLeft(16, iv, self.contentView)];
        }
        self.fileBgViewW = sobotLayoutEqualWidth(w1, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.fileBgViewW];
        self.fileBtnBgViewEH = sobotLayoutEqualHeight(28, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.fileBtnBgViewEH];
        iv.hidden = YES;
        iv;
    });
    
    _iconImg = ({
        UIImageView *iv = [[UIImageView alloc]init];
        [self.fileBtnBgView addSubview:iv];
        iv.contentMode = UIViewContentModeScaleAspectFit;
        [self.fileBtnBgView addConstraint:sobotLayoutEqualWidth(14, iv, NSLayoutRelationEqual)];
        [self.fileBtnBgView addConstraint:sobotLayoutEqualHeight(14, iv, NSLayoutRelationEqual)];
        [self.fileBtnBgView addConstraint:sobotLayoutPaddingLeft(12, iv, self.fileBtnBgView)];
        [self.fileBtnBgView addConstraint:sobotLayoutPaddingTop(7, iv, self.fileBtnBgView)];
        [iv setImage:[SobotUITools getSysImageByName:@"zcicon_upfile"]];
        iv;
    });
    
    _filelab = ({
        UILabel *iv = [[UILabel alloc]init];
        iv.text = SobotKitLocalString(@"上传附件");
        iv.textColor = UIColorFromKitModeColor(SobotColorTextMain);
        iv.font = SobotFont12;
        [self.fileBtnBgView addSubview:iv];
        [self.fileBtnBgView addConstraint:sobotLayoutPaddingRight(-12, iv, self.fileBtnBgView)];
        [self.fileBtnBgView addConstraint:sobotLayoutMarginLeft(4, iv, self.iconImg)];
        [self.fileBtnBgView addConstraint:sobotLayoutEqualHeight(20, iv, NSLayoutRelationEqual)];
        [self.fileBtnBgView addConstraint:sobotLayoutPaddingTop(4, iv, self.fileBtnBgView)];
        iv;
    });
    
    _fileButton = ({
        UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.fileBtnBgView addSubview:iv];
        [iv addTarget:self action:@selector(photoSelecte) forControlEvents:UIControlEventTouchUpInside];
        [self.fileBtnBgView addConstraint:sobotLayoutPaddingLeft(0, iv, self.fileBtnBgView)];
        [self.fileBtnBgView addConstraint:sobotLayoutPaddingRight(0, iv, self.fileBtnBgView)];
        [self.fileBtnBgView addConstraint:sobotLayoutPaddingTop(0, iv, self.fileBtnBgView)];
        [self.fileBtnBgView addConstraint:sobotLayoutPaddingBottom(0, iv, self.fileBtnBgView)];
        iv;
    });
    
    NSString *text = [NSString stringWithFormat:@"%@%@%@%@%@",SobotKitLocalString(@"最多上传"),@"15",SobotKitLocalString(@"个，"),SobotKitLocalString(@"大小不超过"),@"50M"];
    CGFloat th = [SobotUITools getHeightContain:text font:SobotFont12 Width:ScreenWidth-32];
    if (th <20) {
        th = 20;
    }
    
    _bottomTipLab = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.contentView addSubview:iv];
//        iv.text = SobotKitLocalString(@"最多上传 15 个，大小不超过 50M");
        iv.text = text;
        iv.textColor = UIColorFromKitModeColor(SobotColorTextSub1);
        iv.font = SobotFont12;
        iv.numberOfLines = 0;
        [self.contentView addConstraint:sobotLayoutPaddingLeft(16, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-16, iv, self.contentView)];
        self.bottomTipLabMT = sobotLayoutMarginTop(6, iv, self.fileBtnBgView);
        [self.contentView addConstraint:self.bottomTipLabMT];
        self.tipLabEH = sobotLayoutEqualHeight(th, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.tipLabEH];
        iv.hidden = YES;
        iv;
    });
    
    // 中间添加部分
    _fileItemsView = ({
        UIView *iv = [[UIView alloc]init];
        [self.contentView addSubview:iv];
        self.fileItemsViewMT = sobotLayoutMarginTop(16, iv, self.bottomTipLab);
        [self.contentView addConstraint:self.fileItemsViewMT];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(16, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-16, iv, self.contentView)];
        self.fileItemsViewH = sobotLayoutEqualHeight(_itemW, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.fileItemsViewH];
        self.fileItemPB = sobotLayoutPaddingBottom(-16, iv, self.contentView);
        [self.contentView addConstraint:self.fileItemPB];
        iv.hidden = YES;
        iv;
    });
    
    [self reloadScrollView];
    
    self.lineView = ({
        UIView *iv = [[UIView alloc]init];
        [self.contentView addSubview:iv];
        iv.backgroundColor = UIColorFromKitModeColor(SobotColorBgTopLine);
        self.lineViewPL = sobotLayoutPaddingLeft(16, iv, self.contentView);
        [self.contentView addConstraint:self.lineViewPL];
        [self.contentView addConstraint:sobotLayoutPaddingRight(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutEqualHeight(0.5, iv, NSLayoutRelationEqual)];
        iv;
    });
}

- (NSMutableArray *)imageArr{
    if (!_imageArr) {
        _imageArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _imageArr;
}

-(ZCLibConfig *)getCurConfig{
    return [[ZCPlatformTools sharedInstance] getPlatformInfo].config;
}

-(void)initDataToView:(NSDictionary *)dict{
    _textDesc.text   = @"";
    UILabel * detailLab = [[UILabel alloc]initWithFrame:CGRectMake(20, 12 + 10, self.tableWidth-80, 102)];
    detailLab.numberOfLines = 0;
//    __block CGFloat DH = CGRectGetHeight(detailLab.frame);
    [SobotHtmlCore filterHtml:dict[@"placeholder"] result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
        // 过滤特殊转义符 前端编辑框转义的导致
        if (sobotConvertToString(text1).length >0) {
            text1 = [ZCHtmlCore filterHTMLTag:text1];
        }
        self->_textDesc.placeholder = text1;
        self->_textDesc.placeholderLinkColor = UIColorFromKitModeColor(SobotColorTextSub1);
    }];
    
    [_textDesc setText:sobotConvertToString(self.tempModel.ticketDesc)];
    if (self.ticketContentShowFlag) {
        self.tipLab.hidden = NO;
        if (self.ticketContentFillFlag) {
            self.tipLab.attributedText = [self getOtherColorString:@"*" Color:[UIColor redColor] withString:[NSString stringWithFormat:@"* %@",SobotKitLocalString(@"问题描述")]];
        }
    }else{
        // 不显示输入框和文案
        self.tipLabH.constant = 0;
        self.tiplabPT.constant = 0;
        self.textDescMT.constant = 0;
        self.textViewEH.constant = 0;
    }
    // 附件是否必填
    if (_enclosureShowFlag) {
        self.bottomTipLab.hidden = NO;
        self.fileItemsView.hidden = NO;
        self.fileBtnBgView.hidden = NO;
        NSString *text = [NSString stringWithFormat:@"%@%@%@%@%@",SobotKitLocalString(@"最多上传"),@"15",SobotKitLocalString(@"个，"),SobotKitLocalString(@"大小不超过"),@"50M"];
        CGFloat th = [SobotUITools getHeightContain:text font:SobotFont12 Width:ScreenWidth-32];
        if (th <20) {
            th = 20;
        }
        self.bottomTipLabMT.constant = 6;
        if (!sobotIsNull(self.imageArr) && self.imageArr.count >0) {
            self.fileItemPB.constant = -16;
        }else{
            self.fileItemPB.constant = 0;
        }
        self.tipLabEH.constant = th;
        self.fileItemsViewMT.constant = 16;
//        self.fileItemsViewH.constant = self.itemW;
        [self reloadFileItemViews:YES];
        self.fileBtnBgViewEH.constant = 28;
        self.fileBtnBgViewMT.constant = 17;
    }else{
        self.fileBtnBgViewMT.constant = 0;
        self.bottomTipLabMT.constant = 0;
        self.fileScrollViewEH.constant = 0;
        self.fileItemPB.constant = 0;
        self.tipLabEH.constant = 0;
        self.fileItemsViewMT.constant = 0;
        self.fileItemsViewH.constant = 0;
        self.fileBtnBgViewEH.constant = 0;
        self.bottomTipLab.hidden = YES;
        self.fileItemsView.hidden = YES;
        self.fileBtnBgView.hidden = YES;
    }
    if(SobotKitIsRTLLayout){
        [_textDesc setTextAlignment:NSTextAlignmentRight];
    }
}

#pragma mark -- 九宫格的布局代码
- (void)reloadScrollView{
    [self reloadFileItemViews:YES];
    // 先移除，后添加
//    [[self.fileScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
//    // 加一是为了有个添加button
//    NSUInteger assetCount = self.imageArr.count +1 ;
//    CGFloat width = (self.fileScrollView.frame.size.width - 5*3)/4;
//
//    CGFloat heigth = 60;
//    CGFloat x = 0;
//    NSUInteger countX = 0;
//    if(SobotKitIsRTLLayout){
//        countX = (assetCount < 4) ? 4 : assetCount;
//    }
//    
//    for (NSInteger i = 0; i < assetCount; i++) {
//        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
//        x = (width + 5)*i;
//        if(SobotKitIsRTLLayout){
//            x = (width + 5)* (countX - i - 1);
//        }
//        btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
//        btn.frame = CGRectMake(x,0, width, heigth);
//        imageView.frame = btn.frame;
//        // UIButton
//        if (i == self.imageArr.count){
//            // 最后一个Button
//            [btn setImage: [SobotUITools getSysImageByName:@"zcicon_add_photo"]  forState:UIControlStateNormal];
//            // 添加图片的点击事件
//            [btn addTarget:self action:@selector(photoSelecte) forControlEvents:UIControlEventTouchUpInside];
//            if (assetCount == 11) {
//                assetCount = 10;
//                btn.frame = CGRectZero;
//            }
//            [btn.imageView setContentMode:UIViewContentModeScaleAspectFit];
//        }else{
//            [btn.imageView setContentMode:UIViewContentModeScaleAspectFill];
//            // 就从本地取
//            if(sobotCheckFileIsExsis([_imagePathArr objectAtIndex:i])){
//                UIImage *localImage=[UIImage imageWithContentsOfFile:[_imagePathArr objectAtIndex:i]];
//                [btn setImage:localImage forState:UIControlStateNormal];
//            }
//            NSDictionary *imgDic = [_imageArr objectAtIndex:i];
//            NSString *imgFileStr =  sobotConvertToString(imgDic[@"cover"]);
//            if (imgFileStr.length>0) {
//                UIImage *localImage=[UIImage imageWithContentsOfFile:imgFileStr];
//                [btn setImage:localImage forState:UIControlStateNormal];
//            }
//            btn.tag = i;
//            // 点击放大图片，进入图片
//            [btn addTarget:self action:@selector(tapBrowser:) forControlEvents:UIControlEventTouchUpInside];
//                btn.layer.borderColor = UIColorFromKitModeColor(SobotColorBgLine).CGColor;
//        }
//        btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
//        [self.fileScrollView addSubview:btn];
//        if (i != self.imageArr.count){
//            UIButton *btnDel = [UIButton buttonWithType:UIButtonTypeCustom];
//            btnDel.imageView.contentMode = UIViewContentModeScaleAspectFit;
//            x = (width + 5)*i + width - 24;
//            if(SobotKitIsRTLLayout){
//                x = (width + 5)* (countX - i - 1) + width - 24;
//            }
//            btnDel.frame = CGRectMake(x,4, 20, 20);
//            [btnDel setImage:[SobotUITools getSysImageByName:@"zcicon_close_down"] forState:0];
//            btnDel.tag = 100 + i;
//            // 点击放大图片，进入图片
//            [btnDel addTarget:self action:@selector(tapDelFiles:) forControlEvents:UIControlEventTouchUpInside];
//            [self.fileScrollView addSubview:btnDel];
//        }
//    }
//    
//    if(assetCount >= 4){
//        self.fileScrollView.scrollEnabled = YES;
//    }else{
//        self.fileScrollView.scrollEnabled = NO;
//    }
//    // 设置contentSize
//    self.fileScrollView.contentSize = CGSizeMake((width+5)*assetCount,self.fileScrollView.frame.size.height);
//    if(assetCount > 4){
//        if(SobotKitIsRTLLayout){
//            [self.fileScrollView setContentOffset:CGPointMake(0, 0)];
//            
//        }else{
//            [self.fileScrollView setContentOffset:CGPointMake(self.fileScrollView.contentSize.width - self.fileScrollView.frame.size.width, 0)];
//        }
//    }
}

-(void)reloadFileItemViews:(BOOL)isShowClear{
    // 先移除，后添加
    [[self.fileItemsView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // 加一是为了有个添加button 最多15个 + 1个添加按钮
    NSUInteger assetCount = self.imageArr.count;
    UIView *lastView;
    for (int i = 0; i<assetCount; i++) {
        UIView *itemView = [[UIView alloc]init];
        [self.fileItemsView addSubview:itemView];
        itemView.backgroundColor = UIColorFromKitModeColor(SobotColorBgSub);
        itemView.layer.cornerRadius = 4;
        itemView.layer.masksToBounds = YES;
        if (sobotIsNull(lastView)) {
            [self.fileItemsView addConstraint:sobotLayoutPaddingTop(0, itemView, self.fileItemsView)];
        }else{
            [self.fileItemsView addConstraint:sobotLayoutMarginTop(8, itemView, lastView)];
        }
        [self.fileItemsView addConstraint:sobotLayoutPaddingLeft(0, itemView, self.fileItemsView)];
        [self.fileItemsView addConstraint:sobotLayoutPaddingRight(0, itemView, self.fileItemsView)];
        [self.fileItemsView addConstraint:sobotLayoutEqualHeight(64, itemView, NSLayoutRelationEqual)];
        lastView = itemView;
        if (i == assetCount -1) {
            [self.fileItemsView addConstraint:sobotLayoutPaddingBottom(0, itemView, self.fileItemsView)];
            if (i == 0) {
                self.fileItemsViewH.constant = 64;
                self.itemW = 64;
            }else{
                self.fileItemsViewH.constant = 64*(i+1) + (8*i);
                self.itemW = 64*(i+1) + (8*i);
            }
            
            SLog(@"00000000------%f", self.fileItemsViewH.constant);
        }
        // 子控件
        UIButton *icon = [[UIButton alloc]init];
        [itemView addSubview:icon];
        icon.layer.cornerRadius = 4;
        icon.layer.masksToBounds = YES;
        icon.backgroundColor = UIColor.clearColor;
        [itemView addConstraint:sobotLayoutEqualWidth(40, icon, NSLayoutRelationEqual)];
        [itemView addConstraint:sobotLayoutEqualHeight(40, icon, NSLayoutRelationEqual)];
        [itemView addConstraint:sobotLayoutPaddingLeft(12, icon, itemView)];
        [itemView addConstraint:sobotLayoutEqualCenterY(0, icon, itemView)];
        icon.tag = 100+ i;
        
//        CGFloat size = 0;
        // 就从本地取
        if(sobotCheckFileIsExsis([_imagePathArr objectAtIndex:i])){
            UIImage *localImage=[UIImage imageWithContentsOfFile:[_imagePathArr objectAtIndex:i]];
            [icon setImage:localImage forState:0];
        }
        
        NSDictionary *imgDic = [_imageArr objectAtIndex:i];
        NSString *imgFileStr =  sobotConvertToString(imgDic[@"cover"]);
        if (imgFileStr.length>0) {
            UIImage *localImage=[UIImage imageWithContentsOfFile:imgFileStr];
            [icon setImage:localImage forState:0];
        }
        icon.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        UILabel *subTip = [[UILabel alloc]init];
        [itemView addSubview:subTip];
        subTip.textColor = UIColorFromKitModeColor(SobotColorTextMain);
        subTip.font = SobotFont14;
        subTip.numberOfLines = 1;
        [itemView addConstraint:sobotLayoutPaddingRight(-12, subTip, itemView)];
        [itemView addConstraint:sobotLayoutMarginLeft(8, subTip, icon)];
        [itemView addConstraint:sobotLayoutPaddingTop(12, subTip, itemView)];
        [itemView addConstraint:sobotLayoutEqualHeight(22, subTip, NSLayoutRelationEqual)];
        subTip.text = sobotConvertToString([_imagePathArr objectAtIndex:i]);
        subTip.lineBreakMode = NSLineBreakByTruncatingMiddle;
        subTip.text = sobotConvertToString([imgDic objectForKey:@"fileUrl"]);
        // UI要显示最后一级的
        NSString *tip = sobotConvertToString([_imagePathArr objectAtIndex:i]);
        if (tip.length >0) {
            NSArray *tipArr = [tip componentsSeparatedByString:@"/"];
            if (!sobotIsNull(tipArr) && tipArr.count >0) {
                subTip.text = sobotConvertToString([tipArr lastObject]);
            }
        }
        subTip.tag = 100 + i;
        
        UILabel *sizeLab = [[UILabel alloc]init];
        [itemView addSubview:sizeLab];
        sizeLab.font = SobotFont12;
        sizeLab.textColor = UIColorFromKitModeColor(SobotColorTextSub1);
        [itemView addConstraint:sobotLayoutMarginTop(0, sizeLab, subTip)];
        [itemView addConstraint:sobotLayoutEqualHeight(20, sizeLab, NSLayoutRelationEqual)];
        [itemView addConstraint:sobotLayoutMarginLeft(8, sizeLab, icon)];
        [itemView addConstraint:sobotLayoutPaddingRight(-12, sizeLab, itemView)];
        sizeLab.tag = 100 +i;
        
//        size = [self getImageFileSizeWithURL:[NSURL URLWithString:sobotConvertToString([imgDic objectForKey:@"fileUrl"])]]/1024;
//        
//        NSString *sizeReult = [self removeSuffix:[NSString stringWithFormat:@"%.2f",size]];
////        // 网络的方式
//        NSString *sizeStr = [NSString stringWithFormat:@"%@KB",sizeReult];
//        sizeLab.text = @"";
        
        
        
        // 整个点击事件
        SobotButton *clickBtn = [SobotButton buttonWithType:UIButtonTypeCustom];
        [itemView addSubview:clickBtn];
        clickBtn.backgroundColor = UIColor.clearColor;
        clickBtn.tag = 100 +i;
        clickBtn.obj = icon;
        [itemView addSubview:clickBtn];
        [itemView addConstraint:sobotLayoutPaddingTop(0, clickBtn, itemView)];
        [itemView addConstraint:sobotLayoutPaddingLeft(0, clickBtn, itemView)];
        [itemView addConstraint:sobotLayoutPaddingRight(-40, clickBtn, itemView)];
        [itemView addConstraint:sobotLayoutPaddingBottom(0, clickBtn, itemView)];
        // 点击放大图片，进入图片
        [clickBtn addTarget:self action:@selector(tapBrowser:) forControlEvents:UIControlEventTouchUpInside];
                
        
        if (isShowClear) {
            // 显示删除按钮
            
            UIImageView *btnDel = [[UIImageView alloc] init];
            [itemView addSubview:btnDel];
            [btnDel setImage:[SobotUITools getSysImageByName:@"zcicon_close_del"]];
            btnDel.contentMode = UIViewContentModeScaleAspectFill;
            btnDel.tag = 100 + i;
            // 点击放大图片，进入图片
            [itemView addConstraint:sobotLayoutPaddingTop(0, btnDel, itemView)];
            [itemView addConstraint:sobotLayoutPaddingRight(0, btnDel, itemView)];
            [itemView addConstraint:sobotLayoutEqualWidth(20, btnDel, NSLayoutRelationEqual)];
            [itemView addConstraint:sobotLayoutEqualHeight(20, btnDel, NSLayoutRelationEqual)];
            
            
            
            // 增大响应面积
            UIButton *btnDelbig = [UIButton buttonWithType:UIButtonTypeCustom];
            btnDelbig.tag = 100 + i;
            [btnDelbig addTarget:self action:@selector(tapDelFiles:) forControlEvents:UIControlEventTouchUpInside];
            [itemView addSubview:btnDelbig];
            [itemView addConstraint:sobotLayoutPaddingTop(0, btnDelbig, itemView)];
            [itemView addConstraint:sobotLayoutPaddingRight(0, btnDelbig, itemView)];
            [itemView addConstraint:sobotLayoutEqualWidth(40, btnDelbig, NSLayoutRelationEqual)];
            [itemView addConstraint:sobotLayoutEqualHeight(40, btnDelbig, NSLayoutRelationEqual)];
        }
        
    }
    if (assetCount == 0) {
        self.fileItemsViewH.constant = 0;
    }
    if (assetCount >0) {
        self.fileItemPB.constant = -16;
        self.fileItemPB.priority = UILayoutPriorityDefaultHigh;
    }else{
        self.fileItemPB.constant = 0;
        self.fileItemPB.priority = UILayoutPriorityDefaultLow;
    }
    if (assetCount == 15) {
        _fileBtnBgView.backgroundColor = UIColorFromKitModeColor(SobotColorBgGray);
    }else{
        _fileBtnBgView.backgroundColor = UIColor.clearColor;
    }
}

//@param numberStr .2f格式化后的字符串
// @return 去除末尾0之后的
// */
- (NSString *)removeSuffix:(NSString *)numberStr{
    if (numberStr.length > 1) {
        if ([numberStr componentsSeparatedByString:@"."].count == 2) {
            NSString *last = [numberStr componentsSeparatedByString:@"."].lastObject;
            if ([last isEqualToString:@"00"]) {
                numberStr = [numberStr substringToIndex:numberStr.length - (last.length + 1)];
                return numberStr;
            }else{
                if ([[last substringFromIndex:last.length -1] isEqualToString:@"0"]) {
                    numberStr = [numberStr substringToIndex:numberStr.length - 1];
                    return numberStr;
                }
            }
        }
        return numberStr;
    }else{
        return nil;
    }
}

- (CGFloat)getImageFileSizeWithURL:(NSURL *)url
{
    NSURL *mUrl = nil;
    if ([url isKindOfClass:[NSURL class]]) {
        mUrl = url;
    }
    if (!mUrl) {
        return 0.0f;
    }
    CGFloat fileSize = 0;
    CGImageSourceRef imageSourceRef = CGImageSourceCreateWithURL((CFURLRef)mUrl, NULL);
    if (imageSourceRef) {
        CFDictionaryRef imageProperties = CGImageSourceCopyProperties(imageSourceRef, NULL);
        if (imageProperties != NULL) {
            CFNumberRef fileSizeNumberRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyFileSize);
            if (fileSizeNumberRef != NULL) {
                CFNumberGetValue(fileSizeNumberRef, kCFNumberFloat64Type, &fileSize);
            }
            CFRelease(imageProperties);
        }
        CFRelease(imageSourceRef);
    }
    return fileSize;
}

#pragma mark -- 新版 图片附件  UI再次改版，如果使用九宫格使用这个
//-(void)reloadFileItemView{
//    // 先移除，后添加
//    [[self.fileItemsView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
//    // 加一是为了有个添加button 最多15个 + 1个添加按钮
//    NSUInteger assetCount = self.imageArr.count +1 ;
//    CGFloat itemW = self.itemW;
//    CGFloat itemH = self.itemW;
//    CGFloat itemX = 0;
//    CGFloat itemY = 0;
//    CGFloat itemSpec = 8;
//    // 列
//    int kColCount = 4;
//    for (int i = 0; i<assetCount; i++) {
//        // 所在的行
//        int row = i/kColCount;
//        // 所在的列
//        int col = i%kColCount;
//        // 0 1 2 3
//        itemX = col *(itemW + itemSpec);
//        // 第 0行 1 2 3 的Y值
//        itemY = row *(itemH +itemSpec);
//        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
//        btn.frame = CGRectMake(itemX,itemY, itemW, itemH);
//        btn.layer.cornerRadius = 2;
//        btn.layer.masksToBounds = YES;
//        [self.fileItemsView addSubview:btn];
//        btn.backgroundColor = UIColorFromKitModeColor(SobotColorBgF5);
//        
//        // UIButton
//        if (i == self.imageArr.count){
//            // 最后一个Button
//            [btn setImage: [SobotUITools getSysImageByName:@"zcicon_add_photo_new"]  forState:UIControlStateNormal];
//            // 添加图片的点击事件
//            [btn addTarget:self action:@selector(photoSelecte) forControlEvents:UIControlEventTouchUpInside];
//            if (assetCount == 16) {
//                btn.frame = CGRectZero;
//                assetCount = 15;
//            }
//            [btn.imageView setContentMode:UIViewContentModeScaleAspectFit];
//        }else{
//            [btn.imageView setContentMode:UIViewContentModeScaleAspectFill];
//            // 就从本地取
//            if(sobotCheckFileIsExsis([_imagePathArr objectAtIndex:i])){
//                UIImage *localImage=[UIImage imageWithContentsOfFile:[_imagePathArr objectAtIndex:i]];
//                [btn setImage:localImage forState:UIControlStateNormal];
//            }
//            
//            NSDictionary *imgDic = [_imageArr objectAtIndex:i];
//            NSString *imgFileStr =  sobotConvertToString(imgDic[@"cover"]);
//            if (imgFileStr.length>0) {
//                UIImage *localImage=[UIImage imageWithContentsOfFile:imgFileStr];
//                [btn setImage:localImage forState:UIControlStateNormal];
//            }
//            btn.tag = 100+i;
//            // 点击放大图片，进入图片
//            [btn addTarget:self action:@selector(tapBrowser:) forControlEvents:UIControlEventTouchUpInside];
//                btn.layer.borderColor = UIColorFromKitModeColor(SobotColorBgLine).CGColor;
//        }
//        
//        // 删除按钮
//        if (i != self.imageArr.count){
//            UIButton *btnDel = [UIButton buttonWithType:UIButtonTypeCustom];
//            btnDel.imageView.contentMode = UIViewContentModeScaleAspectFit;
//            btnDel.frame = CGRectMake(itemW-10,0, 10, 10);
//            [btnDel setImage:[SobotUITools getSysImageByName:@"zcicon_close_del"] forState:0];
//            btnDel.tag = 100 + i;
//            // 点击放大图片，进入图片
//            [btnDel addTarget:self action:@selector(tapDelFiles:) forControlEvents:UIControlEventTouchUpInside];
//            [btn addSubview:btnDel];
//            
//            // 增大响应面积
//            UIButton *btnDelbig = [UIButton buttonWithType:UIButtonTypeCustom];
//            btnDelbig.frame = CGRectMake(itemW-25,0, 25, 25);
//            btnDelbig.tag = 100 + i;
//            [btnDelbig addTarget:self action:@selector(tapDelFiles:) forControlEvents:UIControlEventTouchUpInside];
//            [btn addSubview:btnDelbig];
//        }
//        
//        if (i == assetCount-1) {
//            // 最后一个获取最大高度
//            self.fileItemsViewH.constant = itemY + itemH;
//            SLog(@"00000000------%f", self.fileItemsViewH.constant);
//            // 换一行的时候才改变 或者最后yi列
////            [self setScrollViewFrameChange:NO];
////            CGPoint bottomOffset = CGPointMake(0, self->_contScrollView.contentSize.height - self->_scontH.constant);
////            [self->_contScrollView setContentOffset:bottomOffset animated:NO];
//        }
//    }
//}



#pragma mark - 选择图片
// 添加图片
- (void)photoSelecte{
    if (_imageArr.count >=15) {
        [SobotProgressHUD showInfoWithStatus:SobotKitLocalString(@"已达上限 15 个")];
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(itemCreateCellOnClick:dictKey:model:withButton:)]) {
        if(self.isReply){
            [self.delegate  itemCreateCellOnClick:ZCOrderCreateItemTypeAddReplyPhoto dictKey:@"dictContentImages" model:self.tempModel withButton:nil];
        }else{
        [self.delegate  itemCreateCellOnClick:ZCOrderCreateItemTypeAddPhoto dictKey:@"dictContentImages" model:self.tempModel withButton:nil];
        }
    }
    [_textDesc resignFirstResponder];
}


//预览图片
- (void)tapBrowser:(SobotButton *)btn{
    // 点击图片浏览器 放大图片
//    NSLog(@"点击图片浏览器 放大图片");
    if (self.delegate && [self.delegate respondsToSelector:@selector(itemCreateCellOnClick:dictKey:model:withButton:)]) {
        if(self.isReply){
            [self.delegate  itemCreateCellOnClick:ZCOrderCreateItemTypeLookAtReplyPhoto dictKey: [NSString stringWithFormat:@"%d",(int)btn.tag -100] model:self.tempModel withButton:(UIButton*)(btn.obj)];
        }else{
            [self.delegate  itemCreateCellOnClick:ZCOrderCreateItemTypeLookAtPhoto dictKey:[NSString stringWithFormat:@"%d",(int)btn.tag -100]  model:self.tempModel withButton:(UIButton*)(btn.obj)];
        }
    }
    [_textDesc resignFirstResponder];
}

- (void)tapDelFiles:(UIButton *)btn{
    // 点击图片浏览器 放大图片
    //    NSLog(@"点击图片浏览器 放大图片");
    delButton = btn;
    NSString *tip = SobotKitLocalString(@"要删除这张图片吗？");
   NSInteger currentInt = btn.tag - 100;
   if(currentInt < _imagePathArr.count){
       NSString *file  = _imagePathArr[currentInt];
       if([file hasSuffix:@".mp4"]){
           tip = SobotKitLocalString(@"要删除这个视频吗?");
       }
   }
    ZCActionSheet *mysheet = [[ZCActionSheet alloc] initWithDelegate:self selectedColor:UIColorFromKitModeColor(SobotColorRed) showTitle:tip CancelTitle:SobotKitLocalString(@"取消") OtherTitles:SobotKitLocalString(@"删除"), nil];
    mysheet.tag = 3;
    mysheet.selectIndex = 2;
    [mysheet show];
    [_textDesc resignFirstResponder];
}

- (void)actionSheet:(ZCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(actionSheet.tag == 3){
        if(buttonIndex == 2){
            if (self.delegate && [self.delegate respondsToSelector:@selector(itemCreateCellOnClick:dictKey:model:withButton:)]) {
                   if(self.isReply){
                       [self.delegate  itemCreateCellOnClick:ZCOrderCreateItemTypeDeletePhoto dictKey: [NSString stringWithFormat:@"%d",(int)delButton.tag - 100]  model:self.tempModel withButton:nil];
                   }else{
                       [self.delegate  itemCreateCellOnClick:ZCOrderCreateItemTypeDeletePhoto dictKey:[NSString stringWithFormat:@"%d",(int)delButton.tag - 100]   model:self.tempModel withButton:nil];
                   }
            }
        }
    }
}
-(void)textViewDidChange:(ZCUITextView *)textView{
    self.tempModel.ticketDesc = sobotConvertToString(textView.text);
    if (self.delegate && [self.delegate respondsToSelector:@selector(itemCreateCellOnClick:dictKey:model:withButton:)]) {
        [self.delegate  itemCreateCellOnClick:ZCOrderCreateItemTypeTitle dictKey:@"dictDesc" model:self.tempModel withButton:nil];
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    if(self.delegate && [self.delegate respondsToSelector:@selector(didKeyboardWillShow:view1:view2:)]){
        [self.delegate didKeyboardWillShow:self.indexPath view1:textView view2:nil];
    }
}

-(void)textFieldDidChangeBegin:(UITextField *) textField{
    if(self.delegate && [self.delegate respondsToSelector:@selector(didKeyboardWillShow:view1:view2:)]){
        [self.delegate didKeyboardWillShow:self.indexPath view1:nil view2:textField];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - 获取label 最终计算高度
-(CGRect)getTextRectWith:(NSString *)str WithMaxWidth:(CGFloat)width  WithlineSpacing:(CGFloat)LineSpacing AddLabel:(UILabel *)label{
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc]initWithString:str];
    NSMutableParagraphStyle * parageraphStyle = [[NSMutableParagraphStyle alloc]init];
    [parageraphStyle setLineSpacing:LineSpacing];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:parageraphStyle range:NSMakeRange(0, [str length])];
    [attributedString addAttribute:NSFontAttributeName value:label.font range:NSMakeRange(0, str.length)];
    label.attributedText = attributedString;
    // 这里的高度的计算，不能在按 attributedString的属性去计算了，需要拿到label中的
    CGSize size = [self autoHeightOfLabel:label with:width];
    CGRect labelF = label.frame;
    labelF.size.height = size.height;
    label.frame = labelF;
    return labelF;
}


- (CGSize )autoHeightOfLabel:(UILabel *)label with:(CGFloat )width{
    //Calculate the expected size based on the font and linebreak mode of your label
    // FLT_MAX here simply means no constraint in height
    CGSize maximumLabelSize = CGSizeMake(width, FLT_MAX);
    CGSize expectedLabelSize = [label sizeThatFits:maximumLabelSize];
    //adjust the label the the new height.
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    label.frame = newFrame;
    [label updateConstraintsIfNeeded];
    return expectedLabelSize;
}

- (NSMutableAttributedString *)getOtherColorString:(NSString *)originalString colorArray:(NSArray<UIColor *> *)colorArray withStringArray:(NSArray<NSString *> *)stringArray {
    if (stringArray.count != colorArray.count) {
        return [[NSMutableAttributedString alloc] initWithString:sobotConvertToString(originalString)];
    }
    NSMutableString *temp = [NSMutableString stringWithString:sobotConvertToString(originalString)];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:temp];
    for (int i = 0;i < stringArray.count; i++) {
        if (stringArray[i].length) {
            NSRange range = [temp rangeOfString:stringArray[i]];
            [str addAttribute:NSForegroundColorAttributeName value:colorArray[i] range:range];
        }
    }
    return str;
}
@end
