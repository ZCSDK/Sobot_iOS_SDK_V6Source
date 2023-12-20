//
//  ZCChatCustomCardVNoSendCollectionCell.m
//  SobotKit
//
//  Created by zhangxy on 2023/6/25.
//

#import "ZCChatCustomCardVNoSendCollectionCell.h"

#import "ZCChatBaseCell.h"

@interface ZCChatCustomCardVNoSendCollectionCell()


@property (strong, nonatomic) NSLayoutConstraint *layoutImgBottom;
@property (strong, nonatomic) NSLayoutConstraint *layoutTipBottom;

@end

@implementation ZCChatCustomCardVNoSendCollectionCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self.bgView setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark1)];
        
        [self.contentView addConstraints:sobotLayoutPaddingWithAll(0, 0, 0, 0, self.bgView, self.contentView)];
        self.posterView.contentMode = UIViewContentModeScaleAspectFill;
        self.posterView.layer.cornerRadius  = 4.0f;
        self.posterView.layer.masksToBounds = YES;
        
        [self.bgView addConstraints:sobotLayoutSize(52, 52, self.posterView, NSLayoutRelationEqual)];
        //            [self.bgView addConstraint:sobotLayoutEqualCenterY(0, self.posterView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(6, self.posterView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingTop(6, self.posterView, self.bgView)];
        _layoutImgBottom = sobotLayoutPaddingBottom(-6, self.posterView, self.bgView);
        _layoutImgBottom.priority = UILayoutPriorityDefaultLow;
        [self.bgView addConstraint:_layoutImgBottom];
        
        self.labTitle.font = SobotFontBold14;
        self.labTitle.numberOfLines = 1;
        [self.bgView addConstraint:sobotLayoutPaddingTop(10, self.labTitle, self.bgView)];
        [self.bgView addConstraint:sobotLayoutMarginLeft(ZCChatRichCellItemSpace, self.labTitle, self.posterView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-6, self.labTitle, self.bgView)];
        
        self.labDesc.font = SobotFont12;
        self.labDesc.numberOfLines = 2;
        [self.bgView addConstraint:sobotLayoutMarginTop(ZCChatCellItemSpace, self.labDesc, self.labTitle)];
        [self.bgView addConstraint:sobotLayoutMarginLeft(ZCChatRichCellItemSpace, self.labDesc, self.posterView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-6, self.labDesc, self.bgView)];
        
        self.labTips.font = SobotFontBold12;
//        [self.labTips setTextColor:[ZCUIKitTools zcgetChatLeftLinkColor]];
        [self.bgView addConstraint:sobotLayoutMarginTop(ZCChatRichCellItemSpace, self.labTips, self.labDesc)];
        [self.bgView addConstraint:sobotLayoutMarginLeft(ZCChatRichCellItemSpace, self.labTips, self.posterView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-6, self.labTips, self.bgView)];
//        _layoutTipBottom = sobotLayoutPaddingBottom(-6, self.labTips, self.bgView);
//        _layoutTipBottom.priority = UILayoutPriorityDefaultHigh;
//        [self.bgView addConstraint:_layoutTipBottom];
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
    
    [self.bgView layoutIfNeeded];
    
    CGFloat ch = CGRectGetMaxY(self.labTips.frame);
    if(ch > 52){
        _layoutTipBottom.priority = UILayoutPriorityDefaultHigh;
        _layoutImgBottom.priority = UILayoutPriorityDefaultLow;
    }else{
        _layoutTipBottom.priority = UILayoutPriorityDefaultLow;
        _layoutImgBottom.priority = UILayoutPriorityDefaultHigh;
    }
    
}

@end
