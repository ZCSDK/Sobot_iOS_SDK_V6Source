//
//  ZCChatReferenceCustomCardCell.m
//  SobotKit
//
//  Created by lizh on 2023/11/22.
//

#import "ZCChatReferenceCustomCardCell.h"

@interface  ZCChatReferenceCustomCardCell()

@property (strong, nonatomic) UIView *bgView; //
@property (nonatomic,strong) SobotImageView *logoView;
@property (strong, nonatomic) UILabel *labTitle; //标题
@property (strong, nonatomic) UILabel *labDesc; //标题
@property (strong, nonatomic) UILabel *labTag; //标题
@property (nonatomic,copy) NSString *jumpUrl;
@property (strong, nonatomic) UILabel *priceTip;// 商品价格标签
@end

@implementation ZCChatReferenceCustomCardCell

-(void)layoutSubViewUI{
    [super layoutSubViewUI];
    // 移除viewcontent的所有子view
    [self.viewContent.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _bgView = ({
        UIView *iv = [[UIView alloc] init];
        [iv setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark1)];
        iv.layer.cornerRadius = 5;
//        iv.layer.borderWidth = 1;
        iv.layer.borderColor = [ZCUIKitTools zcgetServerConfigBtnBgColor].CGColor;
        [self.viewContent addSubview:iv];
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
        iv;
    });
    
    _labTitle = ({
        UILabel *iv = [[UILabel alloc] init];
        iv.numberOfLines = 1;
        iv.lineBreakMode = 4;
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:UIColorFromModeColor(SobotColorTextGoods)];
        iv.numberOfLines = 1;
        iv.font = SobotFontBold10;
        [self.bgView addSubview:iv];
        iv;
    });
    
    _labDesc = ({
        UILabel *iv = [[UILabel alloc] init];
        iv.numberOfLines = 1;
        iv.lineBreakMode = 4;
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        iv.backgroundColor = UIColor.clearColor;
        iv.font = SobotFont8;
        [self.bgView addSubview:iv];
        iv;
    });
    
    _priceTip = ({
        UILabel *iv = [[UILabel alloc]init];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setFont:SobotFont12];
        [iv setTextColor:[ZCUIKitTools zcgetPricetTagTextColor]];
        [self.bgView addSubview:iv];
        iv;
    });
    
    _labTag = ({
        UILabel *iv = [[UILabel alloc] init];
        iv.numberOfLines = 1;
        iv.lineBreakMode = 4;
        [iv setTextAlignment:NSTextAlignmentLeft];
        iv.backgroundColor = UIColor.clearColor;
        [iv setTextColor:[ZCUIKitTools zcgetPricetTagTextColor]];
        [iv setFont:SobotFontBold14];
        [self.bgView addSubview:iv];
        iv;
    });
    
    [self.viewContent addConstraint:sobotLayoutEqualWidth(133, self.bgView, NSLayoutRelationEqual)];
    [self.viewContent addConstraint:sobotLayoutPaddingTop(0, self.bgView, self.viewContent)];
    [self.viewContent addConstraint:sobotLayoutPaddingLeft(0, self.bgView, self.viewContent)];
    [self.viewContent addConstraint:sobotLayoutPaddingBottom(0, self.bgView, self.viewContent)];
    [self.viewContent addConstraint:sobotLayoutEqualHeight(128, self.bgView, NSLayoutRelationEqual)];
    
    [self.bgView addConstraint:sobotLayoutPaddingTop(0, self.logoView, self.bgView)];
    [self.bgView addConstraint:sobotLayoutPaddingLeft(0, self.logoView, self.bgView)];
    [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.logoView, self.bgView)];
    [self.bgView addConstraint:sobotLayoutEqualHeight(66, self.logoView, NSLayoutRelationEqual)];
    
    [self.bgView addConstraint:sobotLayoutMarginTop(5, self.labTitle, self.logoView)];
    [self.bgView addConstraint:sobotLayoutPaddingLeft(10, self.labTitle, self.bgView)];
    [self.bgView addConstraint:sobotLayoutPaddingRight(-10, self.labTitle, self.bgView)];
    
    [self.bgView addConstraint:sobotLayoutMarginTop(3, self.labDesc, self.labTitle)];
    [self.bgView addConstraint:sobotLayoutPaddingLeft(10, self.labDesc, self.bgView)];
    [self.bgView addConstraint:sobotLayoutPaddingRight(-10, self.labDesc, self.bgView)];
    
    [self.bgView addConstraint:sobotLayoutEqualHeight(12, self.priceTip, NSLayoutRelationEqual)];
    [self.bgView addConstraint:sobotLayoutEqualWidth(12, self.priceTip, NSLayoutRelationEqual)];
    [self.bgView addConstraint:sobotLayoutPaddingBottom(-1, self.priceTip, self.labTag)];
    [self.bgView addConstraint:sobotLayoutPaddingLeft(10,self.priceTip,self.bgView)];
    
    [self.bgView addConstraint:sobotLayoutPaddingBottom(-9, self.labTag, self.bgView)];
    [self.bgView addConstraint:sobotLayoutMarginLeft(0, self.labTag, self.priceTip)];
    [self.bgView addConstraint:sobotLayoutPaddingRight(-10, self.labTag, self.bgView)];
    
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
    [self showContent:@"" view:_bgView btm:nil isMaxWidth:NO customViewWidth:133];
}

-(void)bgViewClick:(UITapGestureRecognizer *) tap{
    if(self.delegate && [self.delegate respondsToSelector:@selector(onReferenceCellEvent:type:state:obj:)]){
        [self.delegate onReferenceCellEvent:self.tempMessage type:ZCChatReferenceCellEventOpenURL state:0 obj:sobotConvertToString(_jumpUrl)];
    }
}

@end
