//
//  ZCChatCustomCardVNoSendCollectionCell.m
//  SobotKit
//
//  Created by zhangxy on 2023/6/25.
//

#import "ZCChatCustomCardVNoSendCollectionCell.h"

#import "ZCChatBaseCell.h"

@interface ZCChatCustomCardVNoSendCollectionCell()


@property (strong, nonatomic) NSLayoutConstraint *layoutImgLeft;

@property (strong, nonatomic) NSLayoutConstraint *layoutTipTop;

@property (strong, nonatomic) NSLayoutConstraint *layoutLogoWidth;
@property (strong, nonatomic) NSLayoutConstraint *layoutLogoHeight;

@end

@implementation ZCChatCustomCardVNoSendCollectionCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self.bgView setBackgroundColor:UIColorFromKitModeColor(SobotColorBgSub2Dark3)];
        
        [self.contentView addConstraints:sobotLayoutPaddingWithAll(0, 0, 0, 0, self.bgView, self.contentView)];
        self.posterView.contentMode = UIViewContentModeScaleAspectFill;
        self.posterView.layer.cornerRadius  = 4.0f;
        self.posterView.layer.masksToBounds = YES;
        
        _layoutLogoHeight = sobotLayoutEqualHeight(52, self.posterView, NSLayoutRelationEqual);
        _layoutLogoWidth = sobotLayoutEqualWidth(52, self.posterView, NSLayoutRelationEqual);
        [self.bgView addConstraint:_layoutLogoHeight];
        [self.bgView addConstraint:_layoutLogoWidth];
        _layoutImgLeft =sobotLayoutPaddingLeft(ZCChatItemSpace8, self.posterView, self.bgView);
        [self.bgView addConstraint:_layoutImgLeft];
        [self.bgView addConstraint:sobotLayoutPaddingTop(ZCChatItemSpace8, self.posterView, self.bgView)];
//        _layoutImgBottom = sobotLayoutPaddingBottom(-6, self.posterView, self.bgView);
//        _layoutImgBottom.priority = UILayoutPriorityDefaultLow;
//        [self.bgView addConstraint:_layoutImgBottom];
        
        self.labTitle.font = SobotFontBold14;
        self.labTitle.numberOfLines = 1;
        [self.bgView addConstraint:sobotLayoutPaddingTop(ZCChatItemSpace8, self.labTitle, self.bgView)];
        [self.bgView addConstraint:sobotLayoutMarginLeft(ZCChatMarginVSpace, self.labTitle, self.posterView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatMarginVSpace, self.labTitle, self.bgView)];
        [self.bgView addConstraint:sobotLayoutEqualHeight(22, self.labTitle, NSLayoutRelationEqual)];
        
        self.labDesc.font = SobotFont12;
        self.labDesc.numberOfLines = 2;
        [self.bgView addConstraint:sobotLayoutMarginTop(4, self.labDesc, self.labTitle)];
        [self.bgView addConstraint:sobotLayoutMarginLeft(ZCChatMarginVSpace, self.labDesc, self.posterView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatMarginVSpace, self.labDesc, self.bgView)];
        [self.bgView addConstraint:sobotLayoutEqualHeight(20, self.labDesc, NSLayoutRelationGreaterThanOrEqual)];
        
        self.labTips.font = SobotFontBold12;
//        [self.labTips setTextColor:[ZCUIKitTools zcgetChatLeftLinkColor]];
        _layoutTipTop = sobotLayoutMarginTop(ZCChatItemSpace8, self.labTips, self.labDesc);
        [self.bgView addConstraint:_layoutTipTop];
        [self.bgView addConstraint:sobotLayoutMarginLeft(ZCChatMarginVSpace, self.labTips, self.posterView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatMarginVSpace, self.labTips, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingBottom(-ZCChatItemSpace8, self.labTips, self.labDesc)];
    }
    return self;
}

-(void)prepareForReuse{
    [super prepareForReuse];
    self.posterView.image = nil;
}


-(void)configureCellWithData:(SobotChatCustomCardInfo *)model message:(SobotChatMessage *)message{
    [super configureCellWithData:model message:message];
    
    NSString *unitStr = SobotKitLocalString(@"件");
    NSString *goodsStr = SobotKitLocalString(@"商品");
    NSString *totalStr = SobotKitLocalString(@"合计");
    NSString *total = [NSString stringWithFormat:@"%@%@%@  %@ %@%@",model.customCardCount,unitStr,goodsStr,totalStr,model.customCardAmountSymbol,model.customCardAmount];
    
    
    CGFloat tw = self.contentView.frame.size.width - 74;
    
   CGFloat sw = [SobotUITools getWidthContain:total font:SobotFontBold12 Height:14];
    if(sw > tw){
        self.labTips.numberOfLines = 2;
        total = [NSString stringWithFormat:@"%@%@%@\n%@ %@%@",model.customCardCount,unitStr,goodsStr,totalStr,model.customCardAmountSymbol,model.customCardAmount];
    }
    [self.labTips setText:total];
    // 设置行间距
    if(self.labTips.text.length>0 ){
        NSMutableAttributedString *attriString =
        [[NSMutableAttributedString alloc] initWithString:self.labTips.text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:6];//设置距离
        [attriString addAttribute:NSParagraphStyleAttributeName
                            value:paragraphStyle
                            range:NSMakeRange(0, [self.labTips.text length])];
        self.labTips.attributedText = attriString;
    }
    if(sw > tw){
        self.labTips.numberOfLines = 2;
        self.labTips.lineBreakMode = 4;
    }
    
    [self.labDesc setText:model.customCardDesc];
    [self.labTips setTextColor:UIColorFromKitModeColor(SobotColorTextSub1)];
    [self.labDesc setTextColor:UIColorFromKitModeColor(SobotColorTextSub1)];
    
    
    if(sobotConvertToString(model.customCardThumbnail).length == 0){
        _layoutLogoWidth.constant = 0;
        _layoutLogoHeight.constant = 0;
        _layoutImgLeft.constant = 0;
        
    }else{
        _layoutLogoWidth.constant = 52;
        _layoutLogoHeight.constant = 52;
        _layoutImgLeft.constant = ZCChatMarginVSpace;
    }
    
    if(sobotConvertToString(model.customCardAmount).length == 0 && sobotConvertToString(model.customCardAmountSymbol).length == 0){
        self.layoutTipTop.constant = 0;
        self.labTips.text = @"";
    }else{
        self.layoutTipTop.constant = ZCChatItemSpace8;
    }
    [self.bgView layoutIfNeeded];
}

@end
