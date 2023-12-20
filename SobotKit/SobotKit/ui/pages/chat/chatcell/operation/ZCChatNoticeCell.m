//
//  ZCChatNoticeCell.m
//  SobotKit
//
//  Created by zhangxy on 2022/9/23.
//

#import "ZCChatNoticeCell.h"

// 气泡外部间隔
#define ZCChatMarginHSpace 16
#define ZCChatMarginVSpace 10
@interface ZCChatNoticeCell()


@property(nonatomic,strong) UIView *bgView;
@property(nonatomic,strong) SobotEmojiLabel *lblTextMsg;
@property(nonatomic,strong) SobotButton *lookBtn;
@property(nonatomic,strong) UIImageView *imgIcon;
//@property(nonatomic,strong) NSLayoutConstraint *layoutMessageHeight;
@property(nonatomic,strong) NSLayoutConstraint *lookBtnEH;
@property(nonatomic,strong) NSLayoutConstraint *lblTextMB;
@property(nonatomic,strong) NSLayoutConstraint *lblTextPB;
@property(nonatomic,strong) NSLayoutConstraint *lookBtnPB;

@property(nonatomic,strong) UIView *cAGradientView;
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
    _lblTextMsg.textColor = UIColorFromModeColor(SobotColorYellowDark);
    [_lblTextMsg setLinkColor:UIColorFromModeColor(SobotColorYellow)];
    CGFloat maxw = ScreenWidth - ZCChatMarginHSpace*2 - ZCChatCellItemSpace - ZCChatPaddingVSpace*2 - ZCChatPaddingHSpace -13;
    CGSize size = [_lblTextMsg preferredSizeWithMaxWidth:maxw];
    
//    _layoutMessageHeight.constant = size.height;
    // 如果显示，文本最多显示3行
    if (size.height > 40 && !self.tempModel.isOpenNotice) {
        _lblTextMsg.numberOfLines = 2;
//        _layoutMessageHeight.constant = 120;
//        _cAGradientView.frame = CGRectMake(0,ZCChatMarginVSpace + 45 ,ScreenWidth - ZCChatMarginVSpace*2,  20 );
//        CAGradientLayer *layer = [CAGradientLayer new];
//        //存放渐变的颜色的数组
//        layer.colors = @[(__bridge id)UIColor.clearColor.CGColor, (__bridge id)UIColorFromModeColor(SobotColorYellowLight).CGColor];
//        //起点和终点表示的坐标系位置，(0,0)表示左上角，(1,1)表示右下角
//        layer.startPoint = CGPointMake(0.0, 0.0);
//        layer.endPoint = CGPointMake(0.0, 1);
//        layer.frame = _cAGradientView.frame;
//        [self.cAGradientView.layer addSublayer:layer];
    }else{
        _lblTextMsg.numberOfLines = 0;
//        _cAGradientView.hidden = YES;
    }
   
    if (size.height >40) {
        _lookBtn.hidden = NO;
    }else{
        _lookBtn.hidden = YES;
        [self.bgView removeConstraint:self.lookBtnPB];
        [self.bgView removeConstraint:self.lblTextMB];
        [self.bgView addConstraint:self.lblTextPB];
    }
    
    [self.bgView setNeedsLayout];
}


-(void)createItemViews{
    [self bgView];
    [self imgIcon];
    [self lblTextMsg];
    [self lookBtn];
    
    //设置点击事件
    [self.contentView addConstraint:sobotLayoutPaddingTop(ZCChatMarginVSpace, self.bgView, self.contentView)];
    [self.contentView addConstraint:sobotLayoutPaddingLeft(ZCChatMarginHSpace, self.bgView, self.contentView)];
    [self.contentView addConstraint:sobotLayoutPaddingRight(-ZCChatMarginHSpace, self.bgView, self.contentView)];
    [self.contentView addConstraint:sobotLayoutPaddingBottom(-ZCChatMarginVSpace, self.bgView, self.contentView)];
    
    [self.bgView addConstraints:sobotLayoutPaddingView(ZCChatPaddingVSpace+3, 0, ZCChatPaddingHSpace, 0, self.imgIcon, self.bgView)];
    [self.bgView addConstraints:sobotLayoutSize(15, 15, self.imgIcon, NSLayoutRelationEqual)];
    
    
    [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatPaddingVSpace, self.lblTextMsg, self.bgView)];
    [self.bgView addConstraint:sobotLayoutPaddingTop(ZCChatPaddingVSpace, self.lblTextMsg, self.bgView)];
    [self.bgView addConstraint:sobotLayoutMarginLeft(ZCChatCellItemSpace, self.lblTextMsg, self.imgIcon)];
//    _layoutMessageHeight = sobotLayoutEqualHeight(0,self.lblTextMsg, NSLayoutRelationEqual);
//    [self.bgView addConstraint:_layoutMessageHeight];
    self.lblTextPB = sobotLayoutPaddingBottom(-ZCChatPaddingVSpace, self.lblTextMsg, self.bgView);
    self.lblTextMB = sobotLayoutMarginBottom(-ZCChatPaddingVSpace, self.lblTextMsg, self.lookBtn);
    [self.bgView addConstraint:self.lblTextMB];
    [self.bgView addConstraint:sobotLayoutEqualWidth(80, self.lookBtn, NSLayoutRelationEqual)];
    self.lookBtnEH = sobotLayoutEqualHeight(20, self.lookBtn, NSLayoutRelationEqual);
    [self.bgView addConstraint:self.lookBtnEH];
    [self.bgView addConstraint:sobotLayoutEqualCenterX(0,self.lookBtn, self.bgView)];
    self.lookBtnPB = sobotLayoutPaddingBottom(-ZCChatPaddingVSpace, self.lookBtn, self.bgView);
    [self.bgView addConstraint:self.lookBtnPB];
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
        [_lookBtn setTitle:[NSString stringWithFormat:@"%@ ",SobotKitLocalString(@"展开")] forState:UIControlStateNormal];
        [_lookBtn setImage:SobotKitGetImage(@"zcicon_arrow_down") forState:UIControlStateNormal];
        [_lookBtn addTarget:self action:@selector(openBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        _lookBtn.titleLabel.font = SobotFont14;
        [_lookBtn setTitleColor:UIColorFromKitModeColor(SobotColorTextSub1) forState:UIControlStateNormal];
        [self.bgView addSubview:_lookBtn];
//        [_lookBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -40)];
//        [_lookBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 40, 0, 0)];
        [_lookBtn setSemanticContentAttribute:UISemanticContentAttributeForceRightToLeft];
        _lookBtn.hidden = YES;
    }
    return _lookBtn;
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
        _bgView.backgroundColor = UIColorFromModeColor(SobotColorYellowLight);
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
        [_lookBtn setTitle:[NSString stringWithFormat:@"%@ ",SobotKitLocalString(@"收起")] forState:UIControlStateNormal];
        [_lookBtn setImage:SobotKitGetImage(@"zcicon_arrow_up") forState:UIControlStateNormal];
    }else{
        [_lookBtn setTitle:[NSString stringWithFormat:@"%@ ",SobotKitLocalString(@"展开")] forState:UIControlStateNormal];
        [_lookBtn setImage:SobotKitGetImage(@"zcicon_arrow_down") forState:UIControlStateNormal];
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
