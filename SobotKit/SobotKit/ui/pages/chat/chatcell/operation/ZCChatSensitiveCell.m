//
//  ZCChatSensitiveCell.m
//  SobotKit
//
//  Created by zhangxy on 2025/1/9.
//

#import "ZCChatSensitiveCell.h"
#import "ZCShadowBorderView.h"

@interface ZCChatSensitiveCell(){
    
}


// 内容背景
@property (strong, nonatomic) UIView *bgView;


@property (strong, nonatomic) UIView *contentBgView;
// 标题
@property (strong, nonatomic) UILabel *labTitle; //标题

@property (strong, nonatomic) UILabel *labTip; //标题

@property (strong, nonatomic) UIView *btmView;
// 单行中间线条
@property (strong, nonatomic) UIView *lineView1;

// 多行中间线条
@property (strong, nonatomic) UIView *lineView2;


@property (strong, nonatomic) SobotButton *btnRefuse;
@property (strong, nonatomic) SobotButton *btnAgree;
@property (strong, nonatomic) SobotButton *lookBtn;


@property (strong, nonatomic) NSLayoutConstraint *layoutMaxW;

@property (strong, nonatomic) NSLayoutConstraint *layoutAgreeLeft;
@property (strong, nonatomic) NSLayoutConstraint *layoutRefuseRight;
@property (strong, nonatomic) NSLayoutConstraint *layoutRefuseTop;

@property (strong, nonatomic) NSLayoutConstraint *layoutMsgBgH;


@property (strong, nonatomic) NSLayoutConstraint *layoutLookT;
@property (strong, nonatomic) NSLayoutConstraint *layoutLookH;

@property (strong, nonatomic) NSLayoutConstraint *layoutMsgH;

@end

@implementation ZCChatSensitiveCell

-(void)createViews{
    _bgView = ({
        ZCShadowBorderView *iv = [[ZCShadowBorderView alloc] init];
//        [iv setBackgroundColor:[ZCUIKitTools zcgetLightGrayDarkBackgroundColor]];
        iv.backgroundColor = UIColorFromModeColor(SobotColorBgMainDark2);
        [self.contentView addSubview:iv];
        
        // 最大500居中处理
        _layoutMaxW = sobotLayoutEqualWidth(ScreenWidth - ZCChatMarginHSpace*2, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:_layoutMaxW];
        [self.contentView addConstraint:sobotLayoutEqualCenterX(0, iv, self.contentView)];
        
        [self.contentView addConstraint:sobotLayoutPaddingTop(ZCChatMarginVSpace, iv, self.contentView)];
//        [self.contentView addConstraint:sobotLayoutPaddingLeft(ZCChatMarginHSpace, iv, self.contentView)];
//        [self.contentView addConstraint:sobotLayoutPaddingRight(-ZCChatMarginHSpace, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(-ZCChatMarginVSpace, iv, self.contentView)];
        iv;
    });
    
    _contentBgView = ({
        UIView *iv = [[UIView alloc] init];
        [iv setBackgroundColor:[ZCUIKitTools zcgetLightGrayDarkBackgroundColor]];
        iv.layer.cornerRadius = 4.0f;
        iv.layer.masksToBounds = YES;
//        iv.scrollEnabled = YES;
//        iv.alwaysBounceVertical = YES;
//        iv.alwaysBounceHorizontal = NO;
//        iv.bounces = NO;
        [self.bgView addSubview:iv];
        
        [self.bgView addConstraint:sobotLayoutPaddingTop(SobotSpace20+3, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(SobotSpace20, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-SobotSpace20, iv, self.bgView)];
        
        
//        _layoutMsgBgH = sobotLayoutEqualHeight(20, iv, NSLayoutRelationEqual);
//        
//        [self.contentBgView addConstraint:_layoutMsgBgH];
        iv;
    });
    
    
    _labTitle = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:UIColorFromModeColor(SobotColorTextSub)];
        iv.numberOfLines = 0;
        iv.lineBreakMode = NSLineBreakByTruncatingTail;
        [iv setFont:SobotFont14];
        [self.contentBgView addSubview:iv];
        
        
        [self.contentBgView addConstraint: sobotLayoutPaddingTop(ZCChatItemSpace8, iv, self.contentBgView)];
//        [self.contentBgView addConstraint: sobotLayoutPaddingBottom(-ZCChatItemSpace8, iv, self.contentBgView)];
        [self.contentBgView addConstraint:sobotLayoutPaddingLeft(ZCChatItemSpace10, iv, self.contentBgView)];
        
        _layoutMsgH = sobotLayoutEqualWidth(20, iv, NSLayoutRelationEqual);
        [self.contentBgView addConstraint:_layoutMsgH];
        // 添加到ScrollView里面，必须设置宽度
        [self.contentBgView addConstraint:sobotLayoutPaddingRight(-ZCChatItemSpace10, iv, self.contentBgView)];
        iv;
    });
    
    _lookBtn = ({
        SobotButton *iv = [self lookBtn];
        [self.contentBgView addSubview:iv];
        
        _layoutLookH = sobotLayoutEqualHeight(0, iv, NSLayoutRelationEqual);
        _layoutLookT = sobotLayoutMarginTop(0, iv, self.labTitle);
        [self.contentBgView addConstraint:_layoutLookH];
        [self.contentBgView addConstraint:_layoutLookT];
        
        [self.contentBgView addConstraint: sobotLayoutPaddingBottom(-ZCChatItemSpace8, iv, self.contentBgView)];
        [self.contentBgView addConstraint:sobotLayoutPaddingLeft(ZCChatItemSpace10, iv, self.contentBgView)];
        [self.contentBgView addConstraint:sobotLayoutPaddingRight(-ZCChatItemSpace10, iv, self.contentBgView)];
        
        iv;
    });
    
    
    _labTip = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:UIColorFromModeColor(SobotColorTextMain)];
        iv.numberOfLines = 0;
        [iv setFont:SobotFont14];
        [self.bgView addSubview:iv];
        
        
        [self.bgView addConstraint:sobotLayoutMarginTop(ZCChatMarginVSpace, iv, self.contentBgView)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(SobotSpace20, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-SobotSpace20, iv, self.bgView)];
        iv;
    });
    
    _btmView = ({
        UIView *iv = [[UIView alloc] init];
        iv.backgroundColor = UIColor.clearColor;
        [self.bgView addSubview:iv];
        
        [self.bgView addConstraint:sobotLayoutMarginTop(SobotSpace20, iv, self.labTip)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(0, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingBottom(0, iv, self.bgView)];
        iv;
    });
    
    [self createLineView:_btmView style:0];
    self.lineView1 = [self createLineView:_btmView style:2];
    self.btnRefuse = [self createButton:NO];
    self.btnAgree = [self createButton:YES];
    
    self.lineView2 =[self createLineView:_btmView style:1];
    self.lineView2.hidden  = YES;
    
}

-(SobotButton *)lookBtn{
    SobotButton *lookBtn = [SobotButton buttonWithType:UIButtonTypeCustom];
    [lookBtn setTitle:[NSString stringWithFormat:@"%@ ",SobotKitLocalString(@"展开消息")] forState:UIControlStateNormal];
    [lookBtn setImage:SobotKitGetImage(@"zcicon_arrow_down") forState:UIControlStateNormal];
    [lookBtn addTarget:self action:@selector(openBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    lookBtn.titleLabel.font = SobotFont14;
    [lookBtn setTitleColor:UIColorFromKitModeColor(SobotColorTextSub1) forState:UIControlStateNormal];
    
    [lookBtn setSemanticContentAttribute:UISemanticContentAttributeForceRightToLeft];
    lookBtn.hidden = YES;
    
    return lookBtn;
}

-(void)openBtnAction:(UIButton *)sender{
    if (!self.tempModel.showAllMessage) {
        [_lookBtn setTitle:[NSString stringWithFormat:@"%@ ",SobotKitLocalString(@"收起")] forState:UIControlStateNormal];
        [_lookBtn setImage:SobotKitGetImage(@"zcicon_arrow_up") forState:UIControlStateNormal];
    }else{
        [_lookBtn setTitle:[NSString stringWithFormat:@"%@ ",SobotKitLocalString(@"展开消息")] forState:UIControlStateNormal];
        [_lookBtn setImage:SobotKitGetImage(@"zcicon_arrow_down") forState:UIControlStateNormal];
    }
    
    if (self.delegate &&[self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]) {
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemShowallsensitive text:@"" obj:[NSString stringWithFormat:@"%zd",sender.tag]];
    }
}


/// 添加线条
/// - Parameters:
///   - sView: 父类
///   - location: 位置：0 顶部，1（同意）底部，2中间
-(UIView *)createLineView:(UIView *) sView style:(int) location{
    UIView *iv = ({
        UIView *iv = [[UIView alloc] init];
        iv.backgroundColor = UIColorFromModeColor(SobotColorBgF5);
        iv;
    });
    
    [sView addSubview:iv];
    if(location == 0){
        [sView addConstraint:sobotLayoutEqualHeight(1, iv, NSLayoutRelationEqual)];
        [sView addConstraint:sobotLayoutPaddingTop(0, iv, sView)];
        [sView addConstraint:sobotLayoutPaddingLeft(0, iv, sView)];
        [sView addConstraint:sobotLayoutPaddingRight(0, iv, sView)];
        
    }
    if(location == 1){
        // 注意此情况要先添加按钮，否则可能会被覆盖，看不见
        [sView addConstraint:sobotLayoutEqualHeight(1, iv, NSLayoutRelationEqual)];
        [sView addConstraint:sobotLayoutPaddingTop(46, iv, sView)];
        [sView addConstraint:sobotLayoutPaddingLeft(0, iv, sView)];
        [sView addConstraint:sobotLayoutPaddingRight(0, iv, sView)];
        
    }
    if(location == 2){
        [sView addConstraint:sobotLayoutEqualWidth(1, iv, NSLayoutRelationEqual)];
        [sView addConstraint:sobotLayoutPaddingTop(0, iv, sView)];
        [sView addConstraint:sobotLayoutPaddingBottom(0, iv, sView)];
        
        [sView addConstraint:sobotLayoutEqualCenterX(0, iv, sView)];
        
    }

    return iv;
}
-(void)authSensitive:(UIButton *) button{
    if(button.tag == 1){
        // 拒绝
        if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
            [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeRefuseSend text:nil obj:nil];
        }
    }else{
        // 继续发送
        if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
            [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeAgreeSend text:nil obj:nil];
        }
    }
}


-(SobotButton *)createButton:(BOOL) isAgree{
    
    SobotButton *btn = ({
        SobotButton *iv = [SobotButton buttonWithType:UIButtonTypeCustom];
        [iv setBackgroundColor:UIColor.clearColor];
        [iv.titleLabel setFont:SobotFont14];
        iv.layer.cornerRadius = 18;
        iv.layer.masksToBounds = YES;
        if(isAgree){
            iv.tag = 0;
            [iv setTitle:SobotKitLocalString(@"继续发送") forState:0];
            [iv setTitleColor:[ZCUIKitTools zcgetThemeToWhiteColor] forState:0];
        }else{
            iv.tag = 1;
            [iv setTitle:SobotKitLocalString(@"拒绝") forState:0];
            [iv setTitleColor:UIColorFromModeColor(SobotColorTextMain) forState:0];
        }
        [iv addTarget:self action:@selector(authSensitive:) forControlEvents:UIControlEventTouchUpInside];
        [self.btmView addSubview:iv];


        iv.contentEdgeInsets = UIEdgeInsetsMake(12, 20, 12, 20);
        iv.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.btmView addConstraint:sobotLayoutEqualHeight(46, iv, NSLayoutRelationEqual)];
        
        // 默认按一行处理
        if(!isAgree){
            // 拒绝能确定底部和左侧
            [self.btmView addConstraint:sobotLayoutPaddingBottom(0, iv, self.btmView)];
            [self.btmView addConstraint:sobotLayoutPaddingLeft(0, iv, self.btmView)];
            
            _layoutRefuseTop = sobotLayoutPaddingTop(0, iv, self.btmView);
            _layoutRefuseRight = sobotLayoutMarginRight(0, iv, self.lineView1);
            [self.btmView addConstraint:_layoutRefuseTop];
            [self.btmView addConstraint:_layoutRefuseRight];
        }else{
            // 同意能确定顶部和右侧
            [self.btmView addConstraint:sobotLayoutPaddingRight(0, iv, self.btmView)];
            [self.btmView addConstraint:sobotLayoutPaddingTop(0, iv, self.btmView)];
            
            _layoutAgreeLeft = sobotLayoutMarginLeft(0, iv, self.lineView1);
            [self.btmView addConstraint:_layoutAgreeLeft];
        }
        iv;
    });
    
    return btn;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self createViews];
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self createViews];
    }
    return self;
}

-(void)initDataToView:(SobotChatMessage *)message time:(NSString *)showTime{
    [super initDataToView:message time:showTime];
    
    CGFloat cw = self.viewWidth - ZCChatMarginHSpace * 2;
    if(cw > 500){
        cw = 500;
    }
    _layoutMaxW.constant = cw;
    
    self.tempModel = message;
    self.ivHeader.hidden = YES;
    self.lblNickName.hidden = YES;
    self.lblSugguest.hidden = YES;
    self.ivBgView.hidden = YES;
    
    // 0不启动，1启动，2拒绝
    if(message.includeSensitive == 1){
        [self.btnRefuse setTitle:SobotKitLocalString(@"拒绝") forState:0];
        [self.btnRefuse setTitleColor:UIColorFromModeColor(SobotColorTextMain) forState:0];
    }else if(message.includeSensitive == 2){
        [self.btnRefuse setTitle:SobotKitLocalString(@"您已拒绝发送此消息") forState:0];
        [self.btnRefuse setTitleColor:UIColorFromModeColor(SobotColorTextSub) forState:0];
    }
    
    NSString *text = sobotConvertToString([message getModelDisplayText]);
    if(self.isRight){
        text = sobotConvertToString([message getModelDisplayTextUnHtml]);
    }
    [self changeBtmConstraint];
    
    NSString *warningTips = sobotConvertToString(message.sentisiveExplain);
    [self.labTip setText:warningTips];
    
    
    CGFloat w = self.viewWidth-SobotSpace20*2 - ZCChatPaddingHSpace*2 - 20;

    [self.labTitle setText:text];
    
    CGFloat h = [SobotUITools getHeightContain:text font:self.labTitle.font Width:w];
    
    if(h < 60 || message.showAllMessage){
        _layoutMsgH.constant = h;
    }else{
        _layoutMsgH.constant = 60;
    }
    
    self.lookBtn.hidden = YES;
    if(h > 60){
        self.lookBtn.hidden = NO;
        _layoutLookH.constant = 8;
        _layoutLookT.constant = 25;
        if (self.tempModel.showAllMessage) {
            [_lookBtn setTitle:[NSString stringWithFormat:@"%@ ",SobotKitLocalString(@"收起")] forState:UIControlStateNormal];
            [_lookBtn setImage:SobotKitGetImage(@"zcicon_arrow_up") forState:UIControlStateNormal];
        }else{
            [_lookBtn setTitle:[NSString stringWithFormat:@"%@ ",SobotKitLocalString(@"展开消息")] forState:UIControlStateNormal];
            [_lookBtn setImage:SobotKitGetImage(@"zcicon_arrow_down") forState:UIControlStateNormal];
        }
    }else{
        _layoutLookH.constant = 0;
        _layoutLookT.constant = 0;
    }
    
    [self.bgView layoutIfNeeded];
}


-(void)changeBtmConstraint{
    CGFloat w1 = [SobotUITools getWidthContain:_btnAgree.titleLabel.text font:_btnAgree.titleLabel.font Height:22]+40;
    CGFloat w2 = [SobotUITools getWidthContain:_btnRefuse.titleLabel.text font:_btnRefuse.titleLabel.font Height:22]+40;
    CGFloat itemW  = (self.viewWidth - ZCChatMarginHSpace * 2)/2;
    if(w1 > itemW || w2 > itemW){
        // 2 行
        [self.btmView removeConstraint:_layoutAgreeLeft];
        [self.btmView removeConstraint:_layoutRefuseRight];
        [self.btmView removeConstraint:_layoutRefuseTop];
        
        self.lineView1.hidden = YES;
        self.lineView2.hidden = NO;
        _layoutAgreeLeft = sobotLayoutPaddingLeft(0, self.btnAgree, self.btmView);
        _layoutRefuseRight = sobotLayoutPaddingRight(0, self.btnRefuse, self.btmView);
        _layoutRefuseTop = sobotLayoutMarginTop(0, self.btnRefuse, self.lineView2);
        
        [self.btmView addConstraint:_layoutAgreeLeft];
        [self.btmView addConstraint:_layoutRefuseRight];
        [self.btmView addConstraint:_layoutRefuseTop];
    }else{
        // 不变
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
