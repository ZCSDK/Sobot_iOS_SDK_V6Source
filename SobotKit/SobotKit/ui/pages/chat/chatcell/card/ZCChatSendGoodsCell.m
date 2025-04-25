//
//  ZCChatSendGoodsCell.m
//  SobotKit
//
//  Created by zhangxy on 2022/9/22.
//

#import "ZCChatSendGoodsCell.h"
#import "ZCUICore.h"

@interface ZCChatSendGoodsCell()<UIGestureRecognizerDelegate>{
    NSString *morelink;
    
}

@property(nonatomic,strong) NSLayoutConstraint *layoutTitleHeight;
@property(nonatomic,strong) NSLayoutConstraint *layoutTitleDescHeight;

@property(nonatomic,strong) NSLayoutConstraint *layoutImageHeight;
@property(nonatomic,strong) NSLayoutConstraint *layoutImageWidth;
@property(nonatomic,strong) NSLayoutConstraint *layoutImageLeft;
@property(nonatomic,strong) NSLayoutConstraint *layoutImageBottom;

@property(nonatomic,strong) NSLayoutConstraint *layoutSendBottom;
@property(nonatomic,strong) NSLayoutConstraint *layoutSendW;

@property (strong, nonatomic) UIView *bgView; //
@property (nonatomic,strong) SobotImageView *logoView;
@property (strong, nonatomic) UILabel *labTitle; //标题
@property (strong, nonatomic) UILabel *labDesc; //标题
@property (strong, nonatomic) UILabel *labTag; //标题
@property (strong, nonatomic) SobotButton *btnSend;
@property (strong, nonatomic) UIButton *tapBtn;
@property (copy,nonatomic)NSString *linkUrl;

@end

@implementation ZCChatSendGoodsCell

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
        [self.contentView addConstraint:sobotLayoutPaddingTop(ZCChatMarginVSpace, self.bgView, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(ZCChatMarginHSpace, self.bgView, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-ZCChatMarginHSpace, self.bgView, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(-ZCChatMarginVSpace, self.bgView, self.contentView)];
        
        [self.bgView addConstraint:sobotLayoutPaddingLeft(0, self.tapBtn, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.tapBtn, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingBottom(0, self.tapBtn, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingTop(0, self.tapBtn, self.bgView)];
        
        _layoutImageBottom = sobotLayoutPaddingBottom(-ZCChatPaddingVSpace, self.logoView, self.bgView);
        _layoutImageBottom.priority = UILayoutPriorityDefaultHigh;
        _layoutImageHeight = sobotLayoutEqualHeight(76, self.logoView, NSLayoutRelationEqual);
        _layoutImageWidth = sobotLayoutEqualWidth(76, self.logoView, NSLayoutRelationEqual);
        _layoutImageLeft = sobotLayoutPaddingLeft(ZCChatPaddingVSpace, self.logoView, self.bgView);
        [self.bgView addConstraint:_layoutImageWidth];
        [self.bgView addConstraint:_layoutImageHeight];
        [self.bgView addConstraint:_layoutImageLeft];
        [self.bgView addConstraint:_layoutImageBottom];
        [self.bgView addConstraint:sobotLayoutPaddingTop(ZCChatPaddingVSpace, self.logoView, self.bgView)];
        
        
        _layoutTitleHeight =sobotLayoutEqualHeight(0, self.labTitle, NSLayoutRelationEqual);
        [self.bgView addConstraint:sobotLayoutPaddingTop(ZCChatPaddingVSpace, self.labTitle, self.bgView)];
        [self.bgView addConstraint:sobotLayoutMarginLeft(ZCChatMarginVSpace, self.labTitle, self.logoView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatMarginVSpace, self.labTitle, self.bgView)];
        
        
        [self.bgView addConstraint:sobotLayoutMarginTop(ZCChatCellItemSpace, self.labDesc, self.labTitle)];
        [self.bgView addConstraint:sobotLayoutMarginLeft(ZCChatMarginVSpace, self.labDesc, self.logoView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatMarginVSpace, self.labDesc, self.bgView)];
        
        
        _layoutSendBottom = sobotLayoutPaddingBottom(-ZCChatPaddingVSpace, self.btnSend, self.bgView);
        _layoutSendBottom.priority = UILayoutPriorityDefaultLow;
        [self.bgView addConstraint:_layoutSendBottom];
        
        _layoutSendW = sobotLayoutEqualWidth(60, self.btnSend, NSLayoutRelationEqual);
        [self.bgView addConstraint:sobotLayoutEqualHeight(28, self.btnSend, NSLayoutRelationEqual)];
        [self.bgView addConstraint:_layoutSendW];
        [self.bgView addConstraint:sobotLayoutMarginTop(ZCChatPaddingVSpace, self.btnSend, self.labDesc)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatMarginVSpace, self.btnSend, self.bgView)];
        
        [self.bgView addConstraint: sobotLayoutEqualCenterY(0, self.labTag, self.btnSend)];
//        [self.bgView addConstraint:sobotLayoutEqualHeight(30, self.labTag, NSLayoutRelationEqual)];
        [self.bgView addConstraint:sobotLayoutMarginLeft(ZCChatMarginVSpace, self.labTag, self.logoView)];
        [self.bgView addConstraint:sobotLayoutMarginRight(-ZCChatMarginVSpace, self.labTag, self.btnSend)];
        
    }
    return self;
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//    if ([touch.view isKindOfClass:[UIButton class]]  || [touch.view isKindOfClass:[UITableView class]]  ||[NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
//        //判断如果点击的是tableView的cell，就把手势给关闭了
//        return NO;//关闭手势
//    }
//    //否则手势存在
//    return YES;
//}


-(void)tapAction{
    if (sobotConvertToString(self.linkUrl).length > 0) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
            [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeOpenURL text:sobotConvertToString(self.linkUrl)  obj:sobotConvertToString(self.linkUrl)];
        }
    }
}


-(void)createViews{
    _bgView = ({
        UIView *iv = [[UIView alloc] init];
        [iv setBackgroundColor:[ZCUIKitTools zcgetLightGrayDarkBackgroundColor]];
        iv.layer.cornerRadius = 5.0f;
        iv.layer.masksToBounds = YES;
        [self.contentView addSubview:iv];
        iv;
    });
    _logoView = ({
        SobotImageView *iv = [[SobotImageView alloc] init];
        iv.layer.masksToBounds = YES;
        iv.contentMode = UIViewContentModeScaleAspectFill;
        //设置点击事件
        iv.userInteractionEnabled=YES;
        
        iv.layer.cornerRadius  = 4.0f;
        iv.layer.masksToBounds = YES;
        [self.bgView addSubview:iv];
        iv;
    });
    
    _labTitle = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        iv.numberOfLines = 0;
//        [iv setFont:SobotFontBold14];
        [iv setFont:[ZCUIKitTools  zcgetTitleGoodsFont]];
        [self.bgView addSubview:iv];
        iv;
    });
    
    
    _labDesc = ({
        UILabel *iv = [[UILabel alloc] init];
//        iv.numberOfLines = 0;
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        [iv setFont:SobotFont14];
        [self.bgView addSubview:iv];
        iv;
    });
    
    _tapBtn = ({
        UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
        [iv setBackgroundColor:UIColor.clearColor];
        [iv setTitle:@"" forState:UIControlStateNormal];
        [self.bgView addSubview:iv];
        [iv addTarget:self action:@selector(tapAction) forControlEvents:UIControlEventTouchUpInside];
        iv;
    });
    
    _btnSend = ({
        SobotButton *iv = [SobotButton buttonWithType:UIButtonTypeCustom];
//        [iv setBackgroundColor:[ZCUIKitTools zcgetBgBannerColor]];
        [iv setBackgroundColor:[ZCUIKitTools zcgetServerConfigBtnBgColor]];
        [iv setTitleColor:[ZCUIKitTools zcgetGoodsSendColor] forState:0];
        [iv.titleLabel setFont:SobotFont14];
        iv.layer.cornerRadius = 14;
        iv.layer.masksToBounds = YES;
        [iv setTitle:SobotKitLocalString(@"发送") forState:0];
        iv.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        iv.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
        [iv addTarget:self action:@selector(sendButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgView addSubview:iv];
        iv;
    });
    
    _labTag = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
//        [iv setTextColor:[ZCUIKitTools zcgetPricetTagTextColor]];
        [iv setTextColor:UIColorFromKitModeColor(SobotColorHeaderText)];
//        iv.numberOfLines = 0;
        [iv setFont:SobotFontBold14];
        [self.bgView addSubview:iv];
        iv;
    });

}

- (ZCProductInfo *)getZCproductInfo{
    ZCProductInfo * productInfo = [ZCUICore getUICore].kitInfo.productInfo;
    //    productInfo.desc = @"";
    return productInfo;
}
-(void)initDataToView:(SobotChatMessage *)message time:(NSString *)showTime{
    [super initDataToView:message time:showTime];
    
    ZCProductInfo *info = [self getZCproductInfo];
    
    _labTitle.text = sobotConvertToString(info.title);
    _labDesc.text = sobotConvertToString(info.desc);
    _labTag.text = sobotConvertToString(info.label);
    _linkUrl = sobotConvertToString(info.link);
    
    CGFloat sendW = [SobotUITools getWidthContain:self.btnSend.titleLabel.text font:self.btnSend.titleLabel.font Height:20] + 24;
    if(sendW > 68){
        sendW = 68;
    }
    _layoutSendW.constant = sendW;
    
    if(sobotConvertToString(info.thumbUrl).length > 0){
        _layoutImageLeft.constant = ZCChatPaddingVSpace;
        _layoutImageWidth.constant = 76;
        [_logoView loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(info.thumbUrl)] placeholer:SobotKitGetImage(@"zcicon_default_goods_1")  showActivityIndicatorView:NO];
        _layoutImageBottom.priority = UILayoutPriorityDefaultHigh;
        _layoutSendBottom.priority = UILayoutPriorityDefaultLow;
    }else{
        _logoView.hidden = YES;
        _layoutImageLeft.constant = 0;
        _layoutImageWidth.constant = 0;
        _layoutImageBottom.priority = UILayoutPriorityDefaultLow;
        _layoutSendBottom.priority = UILayoutPriorityDefaultHigh;
    }
    
    
    self.bgView.layer.masksToBounds = NO;
   self.bgView.layer.backgroundColor = [ZCUIKitTools zcgetChatBackgroundColor].CGColor;
   self.bgView.layer.cornerRadius = 4;
   self.bgView.layer.shadowColor = [ZCUIKitTools zcgetChatBottomLineColor].CGColor;
   self.bgView.layer.shadowOffset = CGSizeMake(0,1);
   self.bgView.layer.shadowOpacity = 1;
   self.bgView.layer.shadowRadius = 4;
    

    [self.bgView layoutIfNeeded];
    [self setChatViewBgState:CGSizeMake(self.maxWidth,CGRectGetMaxY(_btnSend.frame))];
    
    self.ivBgView.backgroundColor = UIColor.clearColor;
}

-(void)sendButtonClick:(SobotButton *) btn{
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeSendGoosText text:sobotConvertToString(@"")  obj:sobotConvertToString(@"")];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
