//
//  ZCChatNoticeCell.m
//  SobotKit
//
//  Created by zhangxy on 2022/9/23.
//

#import "ZCChatNoticeCell.h"

@interface ZCChatNoticeCell()


@property(nonatomic,strong) UIView *bgView;
@property(nonatomic,strong) SobotEmojiLabel *lblTextMsg;
@property(nonatomic,strong) SobotButton *lookBtn;
@property(nonatomic,strong) UIImageView *imgIcon;
//@property(nonatomic,strong) NSLayoutConstraint *layoutMessageHeight;
@property(nonatomic,strong) NSLayoutConstraint *lookBtnTop;
@property(nonatomic,strong) NSLayoutConstraint *lookBtnEH;

@property(nonatomic,strong) UIView *cAGradientView;
@property(nonatomic,strong) UIView *lineView;
//#FA8314

@property(nonatomic,strong) UILabel *openLabel;
@property(nonatomic,strong) UIImageView *openIcon;
@property(nonatomic,strong) UIView *openBgView;
@property(nonatomic,strong) UIButton *openClickBtn;
@property(nonatomic,strong) NSLayoutConstraint *openBgViewH;

@end

@implementation ZCChatNoticeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self createItemViews];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self createItemViews];
    }
    return self;
}

-(void)initDataToView:(SobotChatMessage *)message time:(NSString *)showTime{
    [super initDataToView:message time:showTime];
    self.tempModel = message;
    self.ivHeader.hidden = YES;
    self.lblNickName.hidden = YES;
    self.lblSugguest.hidden = YES;
    self.ivBgView.hidden = YES;
    _lblTextMsg.text = @"";
    #pragma mark 标题+内容
    NSString * text = sobotConvertToString(message.richModel.content);
    [ZCChatBaseCell configHtmlText:text label:_lblTextMsg right:self.isRight];
    _lblTextMsg.textColor = UIColorFromModeColor(SobotColorTextMain);
    [_lblTextMsg setLinkColor:UIColorFromModeColor(SobotColorYellow)];
    CGFloat maxw = self.viewWidth - ZCChatMarginHSpace*4 - ZCChatItemSpace8 - 14;
    
    // 要在前面设置一次，不然第二次计算会不正确
    _lblTextMsg.numberOfLines = 0;
    CGSize size = [_lblTextMsg preferredSizeWithMaxWidth:maxw];
    
//    _layoutMessageHeight.constant = size.height;
    // 如果显示，文本最多显示4行
    if (size.height > 95 && !self.tempModel.isOpenNotice) {
        _lblTextMsg.numberOfLines = 4;
    }else{
        _lblTextMsg.numberOfLines = 0;
    }
   // 大于40 并且没有开启展开 或者 当前是展开的场景
    if ((size.height > 95 && !self.tempModel.isOpenNotice) || self.tempModel.isOpenNotice) {
        _lookBtn.hidden = NO;
        _lineView.hidden = NO;
        self.lookBtnEH.constant = 40;
        self.lookBtnTop.constant = 0;
        // 显示
        self.openBgViewH.constant = 17;
    }else{
        _lineView.hidden = YES;
        _lookBtn.hidden = YES;
        self.lookBtnEH.constant = 0;
        self.lookBtnTop.constant = 0;
        self.openBgViewH.constant = 0;
        [self.openIcon setImage:nil];
        self.openLabel.text = @"";
    }
    
    [self.bgView setNeedsLayout];
}


-(void)createItemViews{
    [self bgView];
    [self imgIcon];
    [self lblTextMsg];
    [self lookBtn];
    [self createOpenSubViewIsOpen:NO];
    
    _lineView = ({
        UIView *iv = [[UIView alloc]init];
        [self.bgView addSubview:iv];
        iv.backgroundColor = UIColorFromKitModeColorAlpha(@"#FA8314", 0.3) ;
        [self.bgView addConstraint:sobotLayoutMarginTop(16, iv, self.lblTextMsg)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(0, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutEqualHeight(0.5, iv, NSLayoutRelationEqual)];
        iv.hidden = YES;
        iv;
    });
    //设置点击事件
    [self.contentView addConstraint:sobotLayoutPaddingTop(ZCChatMarginVSpace, self.bgView, self.contentView)];
    [self.contentView addConstraint:sobotLayoutPaddingLeft(ZCChatMarginHSpace, self.bgView, self.contentView)];
    [self.contentView addConstraint:sobotLayoutPaddingRight(-ZCChatMarginHSpace, self.bgView, self.contentView)];
    [self.contentView addConstraint:sobotLayoutPaddingBottom(-ZCChatMarginVSpace, self.bgView, self.contentView)];
    
//    [self.bgView addConstraints:sobotLayoutPaddingView(ZCChatMarginHSpace, 0, ZCChatPaddingHSpace, 0, self.imgIcon, self.bgView)];
    [self.bgView addConstraint:sobotLayoutPaddingTop(ZCChatMarginHSpace+1, self.imgIcon, self.bgView)];
    [self.bgView addConstraint:sobotLayoutPaddingLeft(ZCChatMarginHSpace, self.imgIcon, self.bgView)];
    [self.bgView addConstraints:sobotLayoutSize(14, 14, self.imgIcon, NSLayoutRelationEqual)];
    
    
    [self.bgView addConstraint:sobotLayoutPaddingTop(ZCChatMarginHSpace-3, self.lblTextMsg, self.bgView)];
    [self.bgView addConstraint:sobotLayoutMarginLeft(ZCChatItemSpace4, self.lblTextMsg, self.imgIcon)];
    [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatMarginHSpace, self.lblTextMsg, self.bgView)];
    
    _lookBtnTop = sobotLayoutMarginTop(0, self.lookBtn, self.lineView);
    [self.bgView addConstraint:self.lookBtnTop];
    [self.bgView addConstraint:sobotLayoutEqualWidth(ScreenWidth-80, self.lookBtn, NSLayoutRelationEqual)];
    self.lookBtnEH = sobotLayoutEqualHeight(20, self.lookBtn, NSLayoutRelationEqual);
    [self.bgView addConstraint:self.lookBtnEH];
    [self.bgView addConstraint:sobotLayoutEqualCenterX(0,self.lookBtn, self.bgView)];
    [self.bgView addConstraint:sobotLayoutPaddingBottom(0, self.lookBtn, self.bgView)];
}

-(SobotEmojiLabel *)lblTextMsg{ // 消息内容
    if (!_lblTextMsg) {
        _lblTextMsg = [[SobotEmojiLabel alloc] initWithFrame:CGRectZero];
        _lblTextMsg.numberOfLines = 0;
        _lblTextMsg.font = SobotFont14;
        _lblTextMsg.delegate = self;
        _lblTextMsg.lineBreakMode = NSLineBreakByTruncatingTail;
        _lblTextMsg.backgroundColor = [UIColor clearColor];
        _lblTextMsg.isNeedAtAndPoundSign = NO;
        _lblTextMsg.disableEmoji = NO;
        _lblTextMsg.lineSpacing = 3.0f;
        _lblTextMsg.verticalAlignment = SobotAttributedLabelVerticalAlignmentCenter;
        [self.bgView addSubview:_lblTextMsg];
    }
    return _lblTextMsg;
}

-(SobotButton *)lookBtn{
    if (!_lookBtn) {
        _lookBtn = [SobotButton buttonWithType:UIButtonTypeCustom];
//        [_lookBtn setTitle:[NSString stringWithFormat:@"%@ ",SobotKitLocalString(@"展开")] forState:UIControlStateNormal];
//        [_lookBtn setImage:SobotKitGetImage(@"zcicon_arrow_down") forState:UIControlStateNormal];
        [_lookBtn addTarget:self action:@selector(openBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        _lookBtn.titleLabel.font = SobotFont14;
        [_lookBtn setTitleColor:UIColorFromKitModeColor(SobotColorTextSub) forState:UIControlStateNormal];
        [self.bgView addSubview:_lookBtn];
//        [_lookBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -40)];
//        [_lookBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 40, 0, 0)];
        [_lookBtn setSemanticContentAttribute:UISemanticContentAttributeForceLeftToRight];
        _lookBtn.hidden = YES;
    }
    return _lookBtn;
}

#pragma mark -- 更新
-(void)createOpenSubViewIsOpen:(BOOL)isOpen{
    // 这里需要计算宽度
    NSString *tip = SobotKitLocalString(@"展开");
    if (isOpen) {
        tip = SobotKitLocalString(@"收起");
    }
    CGFloat w1 = [SobotUITools getWidthContain:tip font:SobotFont12 Height:17];
    // 左右间距
    w1 = w1 + 4 + 7;
    if (!sobotIsNull(_bgView)) {
        [_openBgView removeFromSuperview];
        _openBgView = nil;
    }
    _openBgView = ({
        UIView *iv = [[UIView alloc]init];
        [_lookBtn addSubview:iv];
        [_lookBtn addConstraint:sobotLayoutEqualCenterX(0, iv, _lookBtn)];
        [_lookBtn addConstraint:sobotLayoutEqualCenterY(0, iv, _lookBtn)];
        self.openBgViewH = sobotLayoutEqualHeight(17, iv, NSLayoutRelationEqual);
        [_lookBtn addConstraint:self.openBgViewH];
        [_lookBtn addConstraint:sobotLayoutEqualWidth(w1, iv, NSLayoutRelationEqual)];
        iv;
    });
    
    if (!sobotIsNull(_openIcon)) {
        [_openIcon removeFromSuperview];
        _openIcon = nil;
    }
    _openIcon = ({
        UIImageView *iv = [[UIImageView alloc] init];
        if (isOpen) {
            [iv setImage:SobotKitGetImage(@"zcicon_arrow_up")];
        }else{
            [iv setImage:SobotKitGetImage(@"zcicon_arrow_down")];
        }
        [_openBgView addSubview:iv];
        [_openBgView addConstraints:sobotLayoutSize(7.04, 4, iv,NSLayoutRelationEqual)];
        [_openBgView addConstraint:sobotLayoutPaddingRight(0, iv, _openBgView)];
        [_openBgView addConstraint:sobotLayoutEqualCenterY(0, iv, _openBgView)];
        iv;
    });
    
    if (!sobotIsNull(_openLabel)) {
        [_openLabel removeFromSuperview];
        _openLabel = nil;
    }
    
    _openLabel = ({
        UILabel *iv = [[UILabel alloc]init];
        iv.font = SobotFont12;
        iv.textColor = UIColorFromKitModeColor(SobotColorTextSub);
        iv.text = tip;
        [_openBgView addSubview:iv];
        [_openBgView addConstraint:sobotLayoutEqualCenterY(0, iv, _openBgView)];
        [_openBgView addConstraint:sobotLayoutPaddingRight(-4, iv, _openBgView)];
        [_openBgView addConstraint:sobotLayoutPaddingLeft(0, iv, _openBgView)];
        iv;
    });
    
    if (!sobotIsNull(_openClickBtn)) {
        [_openClickBtn removeFromSuperview];
        _openClickBtn = nil;
    }
    
    _openClickBtn = ({
        UIButton *iv = [[UIButton alloc]init];
        [_openBgView addSubview:iv];
        [iv addTarget:self action:@selector(openBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_openBgView addConstraint:sobotLayoutPaddingTop(0, iv, _openBgView)];
        [_openBgView addConstraint:sobotLayoutPaddingRight(0, iv, _openBgView)];
        [_openBgView addConstraint:sobotLayoutPaddingLeft(0, iv, _openBgView)];
        [_openBgView addConstraint:sobotLayoutPaddingRight(0, iv, _openBgView)];
        iv;
    });
}

-(UIImageView*)imgIcon{
    if (!_imgIcon) {
        _imgIcon = [[UIImageView alloc]init];
        _imgIcon.contentMode = UIViewContentModeScaleAspectFill;
        _imgIcon.image =SobotKitGetImage(@"zcicon_annunciate");
        [self.bgView addSubview:_imgIcon];
    }
    return _imgIcon;
}
-(UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc]init];
        _bgView.backgroundColor = UIColorFromModeColor(SobotColorHeaderBg);
        //UIColorFromRGB(noticBgColor);
        _bgView.layer.cornerRadius = 5;
        _bgView.layer.masksToBounds = YES;
        [self.contentView addSubview:_bgView];
    }
    return _bgView;
}

//-(UIView *) cAGradientView{
//    if (!_cAGradientView) {
//        _cAGradientView = [[UIView alloc]init];
//        _cAGradientView.backgroundColor = [UIColor clearColor];
//        [_bgView addSubview:_cAGradientView];
//    }
//    return _cAGradientView;
//}

-(void)openBtnAction:(UIButton *)sender{
    if (!self.tempModel.isOpenNotice) {
//        [_lookBtn setTitle:[NSString stringWithFormat:@"%@ ",SobotKitLocalString(@"收起")] forState:UIControlStateNormal];
//        [_lookBtn setImage:SobotKitGetImage(@"zcicon_arrow_up") forState:UIControlStateNormal];
        [self createOpenSubViewIsOpen:YES];
    }else{
//        [_lookBtn setTitle:[NSString stringWithFormat:@"%@ ",SobotKitLocalString(@"展开")] forState:UIControlStateNormal];
//        [_lookBtn setImage:SobotKitGetImage(@"zcicon_arrow_down") forState:UIControlStateNormal];
        [self createOpenSubViewIsOpen:NO];
    }
    if (self.delegate &&[self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]) {
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeNotice text:@"" obj:[NSString stringWithFormat:@"%zd",sender.tag]];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
