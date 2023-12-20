//
//  ZCChatReferenceCustomVerticalCell.m
//  SobotKit
//
//  Created by lizh on 2023/11/24.
//

#import "ZCChatReferenceCustomVerticalCell.h"


@interface  ZCChatReferenceCustomVerticalCell()

@property (strong, nonatomic) UIView *bgView; //
@property (nonatomic,strong) SobotImageView *logoView;
@property (strong, nonatomic) UILabel *labTitle; //标题
@property (strong, nonatomic) UILabel *labDesc; //标题
@property (strong, nonatomic) UILabel *labTag; //标题
@property (nonatomic,copy) NSString *jumpUrl;
@property (strong, nonatomic) UILabel *priceTip;// 商品价格标签

@end


@implementation ZCChatReferenceCustomVerticalCell

-(void)layoutSubViewUI{
    [super layoutSubViewUI];
    // 移除viewcontent的所有子view
    [self.viewContent.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _bgView = ({
        UIView *iv = [[UIView alloc] init];
        [iv setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark1)];
        iv.layer.cornerRadius = 5;
//        iv.layer.borderWidth = 1;
        [self.viewContent addSubview:iv];
        [self.viewContent addConstraints:sobotLayoutSize(182, 65, iv, NSLayoutRelationEqual)];
        [self.viewContent addConstraint:sobotLayoutPaddingTop(0, iv, self.viewContent)];
        [self.viewContent addConstraint:sobotLayoutPaddingBottom(0, iv, self.viewContent)];
        iv;
    });
    _logoView = ({
        SobotImageView *iv = [[SobotImageView alloc] init];
        iv.layer.masksToBounds = YES;
        iv.contentMode = UIViewContentModeScaleAspectFill;
        iv.layer.cornerRadius = 4.0f;
        //设置点击事件
        iv.userInteractionEnabled=YES;
        [self.bgView addSubview:iv];
        [self.bgView addConstraints:sobotLayoutSize(49, 49, iv, NSLayoutRelationEqual)];
        [self.bgView addConstraint:sobotLayoutEqualCenterY(0, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(8, iv, self.bgView)];
        iv;
    });
    
    _labTitle = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:UIColorFromModeColor(SobotColorTextGoods)];
        iv.numberOfLines = 1;
        iv.lineBreakMode = 4;
        [iv setFont:SobotFontBold8];
        [self.bgView addSubview:iv];
        [self.bgView addConstraint:sobotLayoutPaddingTop(10, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutMarginLeft(11, iv, self.logoView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-11, iv, self.bgView)];
        iv;
    });
    
    _labDesc = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        iv.backgroundColor = UIColor.clearColor;
        iv.numberOfLines = 1;
        iv.lineBreakMode = 4;
        [iv setFont:[UIFont systemFontOfSize:7]];
        [self.bgView addSubview:iv];
        [self.bgView addConstraint:sobotLayoutMarginTop(5, iv, self.labTitle)];
        [self.bgView addConstraint:sobotLayoutMarginLeft(11, iv, self.logoView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-11, iv, self.bgView)];
        iv;
    });
    
    _priceTip = ({
        UILabel *iv = [[UILabel alloc]init];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setFont:[UIFont systemFontOfSize:10]];
        [iv setTextColor:[ZCUIKitTools zcgetPricetTagTextColor]];
        [self.bgView addSubview:iv];
        [self.bgView addConstraint:sobotLayoutMarginLeft(11, iv, self.logoView)];
        [self.bgView addConstraint:sobotLayoutPaddingBottom(-9, iv, self.bgView)];
        [self.bgView addConstraints:sobotLayoutSize(12, 12, iv, NSLayoutRelationEqual)];
        iv;
    });
    
    _labTag = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
        iv.backgroundColor = UIColor.clearColor;
        [iv setTextColor:[ZCUIKitTools zcgetPricetTagTextColor]];
        [iv setFont:SobotFontBold12];
        iv.numberOfLines = 1;
        iv.lineBreakMode = 4;
        [self.bgView addSubview:iv];
        [self.bgView addConstraint:sobotLayoutMarginLeft(0, iv, self.priceTip)];
        [self.bgView addConstraint:sobotLayoutPaddingBottom(-8, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-11, iv, self.bgView)];
        iv;
    });
    
    //设置点击事件
    UITapGestureRecognizer *tapGesturer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bgViewClick:)];
    self.bgView.userInteractionEnabled=YES;
    [self.bgView addGestureRecognizer:tapGesturer];
    
}
-(void)dataToView:(SobotChatMessage *)message{
    [super dataToView:message];
    NSString *link = @"";
//    SobotChatCustomCard *cardModel = message.richModel.customCard;
    SobotChatCustomCardInfo *model = [message.richModel.customCard.customCards firstObject];
    NSString *photoUrl = sobotConvertToString(model.customCardThumbnail);
    [_logoView loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(photoUrl)] placeholer:SobotKitGetImage(@"zcicon_default_goods_1")  showActivityIndicatorView:YES];
    [_labTitle setText:sobotConvertToString(model.customCardName)];
    [_labDesc setText:sobotConvertToString(model.customCardDesc)];

    [_labTag setText:sobotConvertToString(model.customCardAmount)];
    [_priceTip setText:sobotConvertToString(model.customCardAmountSymbol)];
    [self.labTag setTextColor:[ZCUIKitTools zcgetPricetTagTextColor]];
//    [self.priceTip setTextColor:[ZCUIKitTools zcgetPricetTagTextColor]];
    [self.labDesc setTextColor:UIColorFromKitModeColor(SobotColorTextSub1)];
    [self.labTitle setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
    link = sobotConvertToString(model.customCardLink);
  
    _jumpUrl = link;
    [self showContent:@"" view:_bgView btm:nil isMaxWidth:NO customViewWidth:182];
}

-(void)bgViewClick:(UITapGestureRecognizer *) tap{
    if(self.delegate && [self.delegate respondsToSelector:@selector(onReferenceCellEvent:type:state:obj:)]){
        [self.delegate onReferenceCellEvent:self.tempMessage type:ZCChatReferenceCellEventOpenURL state:0 obj:sobotConvertToString(_jumpUrl)];
    }
}

@end
