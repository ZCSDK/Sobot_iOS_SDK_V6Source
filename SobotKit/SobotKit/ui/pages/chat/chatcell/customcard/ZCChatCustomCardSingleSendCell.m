//
//  ZCChatCustomCardSingleSendCell.m
//  SobotKit
//
//  Created by zhangxy on 2023/6/14.
//

#import "ZCChatCustomCardSingleSendCell.h"
#import "ZCUICore.h"

@interface ZCChatCustomCardSingleSendCell(){
    
}

@property(nonatomic,strong) NSLayoutConstraint *layoutBgWidth;
@property(nonatomic,strong) NSLayoutConstraint *layoutImageLeft;
@property(nonatomic,strong) NSLayoutConstraint *layoutImageWidth;
@property(nonatomic,strong) NSLayoutConstraint *layoutImageHeight;

@property (strong, nonatomic) UIView *bgView; //
@property (nonatomic,strong) SobotImageView *logoView;

@property (strong, nonatomic) UILabel *labTitle; //标题
@property (strong, nonatomic) UILabel *labDesc; //标题
@property (strong, nonatomic) UILabel *labTag; //标题
@property (strong, nonatomic) UILabel *priceTip;// 价格单位标签
@property (copy,nonatomic)NSString *linkUrl;
@end

@implementation ZCChatCustomCardSingleSendCell

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
        UITapGestureRecognizer *tapGesturer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bgViewClick:)];
        self.logoView.userInteractionEnabled=YES;
        [self.logoView addGestureRecognizer:tapGesturer];
        
        //设置点击事件
        _layoutBgWidth = sobotLayoutEqualWidth(ScreenWidth, self.bgView, NSLayoutRelationEqual);
        [self.contentView addConstraint:_layoutBgWidth];
        [self.contentView addConstraint:sobotLayoutPaddingTop(ZCChatPaddingVSpace, self.bgView, self.ivBgView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingVSpace, self.bgView, self.ivBgView)];
        [self.contentView addConstraint:sobotLayoutMarginBottom(-ZCChatCellItemSpace, self.bgView, self.lblSugguest)];
        
        _layoutImageWidth = sobotLayoutEqualWidth(76, self.logoView, NSLayoutRelationEqual);
        _layoutImageHeight = sobotLayoutEqualHeight(76, self.logoView, NSLayoutRelationEqual);
        _layoutImageLeft = sobotLayoutPaddingLeft(0, self.logoView, self.bgView);
        [self.bgView addConstraint:_layoutImageWidth];
        [self.bgView addConstraint:_layoutImageHeight];
        [self.bgView addConstraint:_layoutImageLeft];
        [self.bgView addConstraint:sobotLayoutPaddingTop(0, self.logoView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingBottom(0, self.logoView, self.bgView)];
        
        [self.bgView addConstraint: sobotLayoutPaddingTop(0, self.labTitle, self.bgView)];
        [self.bgView addConstraint:sobotLayoutMarginLeft(ZCChatMarginVSpace, self.labTitle, self.logoView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-12, self.labTitle, self.bgView)];
        
        [self.bgView addConstraint: sobotLayoutMarginTop(ZCChatCellItemSpace-1, self.labDesc, self.labTitle)];
        [self.bgView addConstraint:sobotLayoutMarginLeft(ZCChatMarginVSpace, self.labDesc, self.logoView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-12, self.labDesc, self.bgView)];
        
        [self.bgView addConstraint:sobotLayoutMarginLeft(ZCChatMarginVSpace, self.priceTip, self.logoView)];
//        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatPaddingHSpace, self.priceTip, self.s)];
        [self.bgView addConstraint:sobotLayoutPaddingBottom(0, self.priceTip, self.logoView)];
        
        [self.bgView addConstraint:sobotLayoutMarginLeft(0, self.labTag, self.self.priceTip)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-12, self.labTag, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingBottom(-2, self.labTag, self.logoView)];
    }
    return self;
}


-(void)createViews{
    _bgView = ({
        UIView *iv = [[UIView alloc] init];
        [iv setBackgroundColor:UIColor.clearColor];
//        iv.layer.masksToBounds = YES;
//        iv.layer.borderWidth = 2.0f;
//        iv.layer.shadowColor = [ZCUIKitTools zcgetChatBottomLineColor].CGColor;
//        iv.layer.shadowOpacity = 0.9;
//        iv.layer.shadowRadius = 8;
//        iv.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        [self.contentView addSubview:iv];
        iv;
    });
    _logoView = ({
        SobotImageView *iv = [[SobotImageView alloc] init];
        iv.layer.masksToBounds = YES;
        iv.contentMode = UIViewContentModeScaleAspectFill;
        iv.layer.cornerRadius = 4;
        iv.layer.masksToBounds = YES;
        //设置点击事件
        iv.userInteractionEnabled=YES;
        [self.bgView addSubview:iv];
        iv;
    });
    
    _labTitle = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        iv.numberOfLines = 1;
        [iv setFont:SobotFontBold14];
        [self.bgView addSubview:iv];
        iv;
    });
    
    
    _labDesc = ({
        UILabel *iv = [[UILabel alloc] init];
        iv.numberOfLines = 2;
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:UIColorFromKitModeColor(SobotColorTextSub1)];
        [iv setFont:SobotFont12];
        [self.bgView addSubview:iv];
        iv;
    });
    
    _labTag = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:[ZCUIKitTools zcgetPricetTagTextColor]];
        iv.numberOfLines = 1;
        [iv setFont:SobotFontBold20];
        [self.bgView addSubview:iv];
        iv;
    });
    
    _priceTip = ({
        UILabel *iv = [[UILabel alloc]init];
        [iv setTextAlignment:NSTextAlignmentRight];
        [iv setTextColor:[ZCUIKitTools zcgetPricetTagTextColor]];
        iv.numberOfLines = 1;
        [iv setFont:SobotFont12];
        [self.bgView addSubview:iv];
        iv;
    });
}



-(void)initDataToView:(SobotChatMessage *)message time:(NSString *)showTime{
    [super initDataToView:message time:showTime];
    
    SobotChatCustomCardInfo *info = [self.cardModel.customCards firstObject];
    _linkUrl = info.customCardLink;
    
    [_labTitle setText:sobotConvertToString(info.customCardName)];
    [_labDesc setText:sobotConvertToString(info.customCardDesc)];
//    NSString *tipStr = [NSString stringWithFormat:@"%@%@",sobotConvertToString(info.customCardAmountSymbol),sobotConvertToString(info.customCardAmount)];
//    [_labTag setText:sobotConvertToString(tipStr)];
    [_priceTip setText:sobotConvertToString(info.customCardAmountSymbol)];
    [_labTag setText:sobotConvertToString(info.customCardAmount)];
    if(sobotConvertToString(info.customCardThumbnail).length > 0){
        _layoutImageLeft.constant = 0;
        _layoutImageWidth.constant = 76;
        _layoutImageHeight.constant = 76;
        
        [_logoView loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(info.customCardThumbnail)] placeholer:SobotKitGetImage(@"zcicon_default_goods_1")  showActivityIndicatorView:NO];
    }else{
        _logoView.hidden = YES;
        _layoutImageLeft.constant = -ZCChatMarginVSpace;
        _layoutImageWidth.constant = 0;
        _layoutImageHeight.constant = 0;
    }
    
    // 如果没有标签
    CGFloat textHeight = 0;
    if(sobotConvertToString(info.customCardAmount).length == 0 && sobotConvertToString(info.customCardAmountSymbol).length == 0){
        CGFloat contentWidth = 0;
        if(self.tempModel.senderType == 0){
            contentWidth = self.maxWidth+2*ZCChatPaddingVSpace -40;
        }else{
            contentWidth = self.maxWidth+2*ZCChatPaddingVSpace;
        }
        CGFloat lh = [SobotUITools getHeightContain:sobotConvertToString(info.customCardDesc) font:SobotFont12 Width:contentWidth - _layoutImageWidth.constant - 2*ZCChatPaddingVSpace];
        
        if(lh > 14){
            lh = 34;
        }else{
            lh = 17;
        }
        lh = lh;
        textHeight = 18+lh;
    }else{
        textHeight = 76;
    }
    if(_layoutImageHeight.constant == 0){
        _layoutImageHeight.constant = textHeight;
    }
   
//    [self setChatViewBgState:CGSizeMake(self.maxWidth,CGRectGetMaxY(_bgView.frame)) isSetBgColor:NO];
    
    if(self.tempModel.senderType == 0){
        _layoutBgWidth.constant = self.maxWidth+2*ZCChatPaddingVSpace;
        [self.bgView layoutIfNeeded];
        [self setChatViewBgState:CGSizeMake(self.maxWidth,CGRectGetMaxY(_bgView.frame)) isSetBgColor:NO];
    }else{
        _layoutBgWidth.constant = self.maxWidth+2*ZCChatPaddingVSpace;
        [self.bgView layoutIfNeeded];
        [self setChatViewBgState:CGSizeMake(self.maxWidth,CGRectGetMaxY(_bgView.frame)) isSetBgColor:NO];
    }
    
    [self.bgView layoutIfNeeded];
}


-(void)bgViewClick:(UITapGestureRecognizer *) tap{
    //    NSLog(@"取消发送文件\\");
    if (sobotConvertToString(self.linkUrl).length > 0) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
            [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeOpenURL text:sobotConvertToString(self.linkUrl)  obj:sobotConvertToString(self.linkUrl)];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end

