//
//  ZCChatSendGoodsCell.m
//  SobotKit
//
//  Created by zhangxy on 2022/9/22.
//

#import "ZCChatSendGoodsCell.h"
#import "ZCUICore.h"

@interface ZCChatSendGoodsCell(){
    NSString *morelink;
    
}

@property(nonatomic,strong) NSLayoutConstraint *layoutTitleHeight;
@property(nonatomic,strong) NSLayoutConstraint *layoutTitleDescHeight;

@property(nonatomic,strong) NSLayoutConstraint *layoutImageHeight;
@property(nonatomic,strong) NSLayoutConstraint *layoutImageWidth;
@property(nonatomic,strong) NSLayoutConstraint *layoutImageLeft;
@property(nonatomic,strong) NSLayoutConstraint *layoutImageBottom;

@property(nonatomic,strong) NSLayoutConstraint *layoutSendBottom;

@property (strong, nonatomic) UIView *bgView; //
@property (nonatomic,strong) SobotImageView *logoView;
@property (strong, nonatomic) UILabel *labTitle; //标题
@property (strong, nonatomic) UILabel *labDesc; //标题
@property (strong, nonatomic) UILabel *labTag; //标题
@property (strong, nonatomic) SobotButton *btnSend;


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
        
        _layoutTitleHeight =sobotLayoutEqualHeight(0, self.labTitle, NSLayoutRelationEqual);
        [self.bgView addConstraint: sobotLayoutPaddingTop(ZCChatPaddingVSpace, self.labTitle, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingHSpace, self.labTitle, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatPaddingHSpace, self.labTitle, self.bgView)];
        
        
        _layoutImageBottom = sobotLayoutPaddingBottom(-ZCChatPaddingVSpace, self.logoView, self.bgView);
        _layoutImageBottom.priority = UILayoutPriorityDefaultHigh;
        _layoutImageHeight = sobotLayoutEqualHeight(72, self.logoView, NSLayoutRelationEqual);
        _layoutImageWidth = sobotLayoutEqualWidth(72, self.logoView, NSLayoutRelationEqual);
        _layoutImageLeft = sobotLayoutPaddingLeft(ZCChatPaddingHSpace, self.logoView, self.bgView);
        [self.bgView addConstraint:_layoutImageWidth];
        [self.bgView addConstraint:_layoutImageHeight];
        [self.bgView addConstraint:_layoutImageLeft];
        [self.bgView addConstraint:_layoutImageBottom];
        [self.bgView addConstraint:sobotLayoutMarginTop(ZCChatCellItemSpace, self.logoView, self.labTitle)];
        
        
        [self.bgView addConstraint: sobotLayoutMarginTop(ZCChatCellItemSpace, self.labDesc, self.labTitle)];
        [self.bgView addConstraint:sobotLayoutMarginLeft(ZCChatCellItemSpace*2, self.labDesc, self.logoView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatPaddingHSpace, self.labDesc, self.bgView)];
        
        
        _layoutSendBottom = sobotLayoutPaddingBottom(-ZCChatPaddingVSpace, self.btnSend, self.bgView);
        _layoutSendBottom.priority = UILayoutPriorityDefaultLow;
        [self.bgView addConstraints:sobotLayoutSize(90, 30, self.btnSend, NSLayoutRelationEqual)];
        [self.bgView addConstraint:_layoutSendBottom];
        [self.bgView addConstraint:sobotLayoutMarginTop(ZCChatPaddingVSpace, self.btnSend, self.labDesc)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatPaddingHSpace, self.btnSend, self.bgView)];
        
        [self.bgView addConstraint: sobotLayoutMarginTop(ZCChatCellItemSpace, self.labTag, self.labDesc)];
        [self.bgView addConstraint:sobotLayoutEqualHeight(30, self.labTag, NSLayoutRelationEqual)];
        [self.bgView addConstraint:sobotLayoutMarginLeft(ZCChatCellItemSpace*2, self.labTag, self.logoView)];
        [self.bgView addConstraint:sobotLayoutMarginRight(-ZCChatCellItemSpace, self.labTag, self.btnSend)];
        
    }
    return self;
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
    _btnSend = ({
        SobotButton *iv = [SobotButton buttonWithType:UIButtonTypeCustom];
//        [iv setBackgroundColor:[ZCUIKitTools zcgetBgBannerColor]];
        [iv setBackgroundColor:[ZCUIKitTools zcgetGoodSendBtnColor]];
        [iv setTitleColor:[ZCUIKitTools zcgetGoodsSendColor] forState:0];
        [iv.titleLabel setFont:SobotFont14];
        iv.layer.cornerRadius = 15;
        iv.layer.masksToBounds = YES;
        [iv setTitle:SobotKitLocalString(@"发送") forState:0];
        [iv addTarget:self action:@selector(sendButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgView addSubview:iv];
        iv;
    });
    
    _labTag = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:[ZCUIKitTools zcgetChatLeftLinkColor]];
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
    if(sobotConvertToString(info.thumbUrl).length > 0){
        _layoutImageLeft.constant = ZCChatPaddingVSpace;
        _layoutImageWidth.constant = 72;
        _layoutImageWidth.constant = 72;
        [_logoView loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(info.thumbUrl)] placeholer:SobotKitGetImage(@"zcicon_default_goods_1")  showActivityIndicatorView:YES];
        _layoutImageBottom.priority = UILayoutPriorityDefaultHigh;
        _layoutSendBottom.priority = UILayoutPriorityDefaultLow;
    }else{
        _logoView.hidden = YES;
        _layoutImageLeft.constant = ZCChatPaddingVSpace - ZCChatCellItemSpace;
        _layoutImageWidth.constant = 0;
        _layoutImageWidth.constant = 0;
        _layoutImageBottom.priority = UILayoutPriorityDefaultLow;
        _layoutSendBottom.priority = UILayoutPriorityDefaultHigh;
    }
    

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
