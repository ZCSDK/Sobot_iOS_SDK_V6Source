//
//  ZCChatCustomCardVCollectionCell.m
//  SobotKit
//
//  Created by zhangxy on 2023/6/12.
//

#import "ZCChatCustomCardVCollectionCell.h"


#import "ZCChatBaseCell.h"

@interface ZCChatCustomCardVCollectionCell()

@property (strong, nonatomic) NSLayoutConstraint *layoutBtnWidth;
@property (strong, nonatomic) NSLayoutConstraint *layoutBtnTop;
@property (strong, nonatomic) NSLayoutConstraint *layoutTipTop;

@property (strong, nonatomic) NSLayoutConstraint *layoutLogoWidth;
@property (strong, nonatomic) NSLayoutConstraint *layoutLogoHeight;
@property (strong, nonatomic) NSLayoutConstraint *layoutLineHeight;

@property (strong, nonatomic) NSLayoutConstraint *layoutPriceHeight;

@property (strong, nonatomic) NSLayoutConstraint *layoutLeftTitle;
@property (strong, nonatomic) NSLayoutConstraint *layoutLeftDesc;
@property (strong, nonatomic) NSLayoutConstraint *layoutLeftTips;

@property (strong, nonatomic) UIView *lineView;// 下划线，当没有图片时显示

@property (strong,nonatomic) SobotChatMessage *chatMsg;
@end

@implementation ZCChatCustomCardVCollectionCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addConstraints:sobotLayoutPaddingWithAll(0, 0, 0, 0, self.bgView, self.contentView)];
        
        _lineView = [[UIView alloc] init];
//        self.lineView.backgroundColor = UIColorFromModeColor(SobotColorBgLine);
        self.lineView.backgroundColor = UIColor.clearColor;
        [self.bgView addSubview:_lineView];
        
        _layoutLineHeight = sobotLayoutEqualHeight(1, self.lineView, NSLayoutRelationEqual);
        [self.bgView addConstraint:_layoutLineHeight];
        [self.bgView addConstraint:sobotLayoutPaddingBottom(0, self.lineView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(0, self.lineView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.lineView, self.bgView)];
        
        
        self.posterView.contentMode = UIViewContentModeScaleAspectFill;
        self.posterView.layer.cornerRadius  = 4.0f;
        self.posterView.layer.masksToBounds = YES;
        
        
        _layoutLogoHeight = sobotLayoutEqualHeight(76, self.posterView, NSLayoutRelationEqual);
        _layoutLogoWidth = sobotLayoutEqualWidth(76, self.posterView, NSLayoutRelationEqual);
        [self.bgView addConstraint:_layoutLogoHeight];
        [self.bgView addConstraint:_layoutLogoWidth];
//        [self.bgView addConstraint:sobotLayoutPaddingBottom(0, self.posterView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(0, self.posterView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingTop(0, self.posterView, self.bgView)];
        
        self.labTitle.font = SobotFontBold14;
        self.labTitle.numberOfLines = 1;
        self.labTitle.lineBreakMode = NSLineBreakByTruncatingTail;
        // UI 要求文字和图片相齐
        [self.bgView addConstraint:sobotLayoutPaddingTop(-2, self.labTitle, self.bgView)];
        _layoutLeftTitle = sobotLayoutMarginLeft(ZCChatRichCellItemSpace, self.labTitle, self.posterView);
        [self.bgView addConstraint:_layoutLeftTitle];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-8, self.labTitle, self.bgView)]; // 到屏宽是20 -12的外部约束
        
        self.labDesc.font = SobotFont12;
        self.labDesc.numberOfLines = 2;
        [self.bgView addConstraint:sobotLayoutMarginTop(ZCChatCellItemSpace-1, self.labDesc, self.labTitle)];
        _layoutLeftDesc = sobotLayoutMarginLeft(ZCChatRichCellItemSpace, self.labDesc, self.posterView);
        [self.bgView addConstraint:_layoutLeftDesc];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.labDesc, self.bgView)];
                
        self.priceTip.font = SobotFont12;
        _layoutLeftTips = sobotLayoutMarginLeft(ZCChatRichCellItemSpace, self.priceTip, self.posterView);
        [self.bgView addConstraint:_layoutLeftTips];
        [self.bgView addConstraint:sobotLayoutPaddingBottom(-4, self.priceTip, self.labTips)];
//        [self.bgView addConstraint:sobotLayoutEqualCenterY(2, self.priceTip, self.btnSend)];
        self.priceTip.textAlignment = NSTextAlignmentRight;
        [self.bgView addConstraint:sobotLayoutEqualWidth(12, self.priceTip, NSLayoutRelationEqual)];
        [self.bgView addConstraint:sobotLayoutEqualHeight(12, self.priceTip, NSLayoutRelationEqual)];
        
        // 59999
        self.labTips.font = SobotFontBold20;
//        [self.labTips setTextColor:[ZCUIKitTools zcgetChatLeftLinkColor]];
        [self.bgView addConstraint:sobotLayoutMarginLeft(0, self.labTips, self.priceTip)];
        [self.bgView addConstraint:sobotLayoutMarginRight(-10, self.labTips, self.btnSend)];
        self.layoutTipTop = sobotLayoutMarginTop(4, self.labTips, self.labDesc);
        [self.bgView addConstraint:self.layoutTipTop];
        _layoutPriceHeight = sobotLayoutEqualHeight(28, self.labTips, NSLayoutRelationEqual);
        [self.bgView addConstraint:_layoutPriceHeight];

        
        self.btnSend.layer.cornerRadius = 14.0f;
        _layoutBtnWidth = sobotLayoutEqualWidth(55, self.btnSend, NSLayoutRelationEqual);
        [self.bgView addConstraint:_layoutBtnWidth];
        [self.bgView addConstraint:sobotLayoutEqualHeight(28, self.btnSend, NSLayoutRelationEqual)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.btnSend, self.bgView)];
        self.layoutBtnTop = sobotLayoutMarginTop(4, self.btnSend, self.labDesc);
        [self.bgView addConstraint:self.layoutBtnTop];
        
        
    }
    return self;
}

-(void)prepareForReuse{
    [super prepareForReuse];
    self.posterView.image = nil;
}


-(void)configureCellWithData:(SobotChatCustomCardInfo *)model message:(SobotChatMessage *)message{
    [super configureCellWithData:model message:message];
//    if(self.labDesc.text.length>0 ){
//        NSMutableAttributedString *attriString =
//            [[NSMutableAttributedString alloc] initWithString:self.labDesc.text];
//            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//           [paragraphStyle setLineSpacing:2];//设置距离
//           [attriString addAttribute:NSParagraphStyleAttributeName
//                                    value:paragraphStyle
//                                    range:NSMakeRange(0, [self.labDesc.text length])];
//        self.labDesc.attributedText = attriString;
//    }
    
    if(sobotConvertToString(model.customCardThumbnail).length == 0){
        _layoutLogoWidth.constant = 0;
        _layoutLogoHeight.constant = 0;
        _layoutLeftDesc.constant = 0;
        _layoutLeftTitle.constant = 0;
        _layoutLeftTips.constant = 0;
        _layoutLineHeight.constant = 1.0;
    }else{
        _layoutLogoWidth.constant = 76;
        _layoutLogoHeight.constant = 76;
        _layoutLeftDesc.constant = ZCChatRichCellItemSpace;
        _layoutLeftTitle.constant = ZCChatRichCellItemSpace;
        _layoutLeftTips.constant = ZCChatRichCellItemSpace;
        _layoutLineHeight.constant = 0;
    }
    
    
//    if(sobotConvertToString(model.customCardDesc).length >0){
//        CGFloat lh = [SobotUITools getHeightContain:sobotConvertToString(model.customCardDesc) font:SobotFont12 Width:self.bgView.frame.size.width - 86];
//        if(lh > 14){
//            self.layoutBtnTop.constant = 12;
//        }else{
//            self.layoutBtnTop.constant = 0;
//        }
//    }
    
    if(sobotConvertToString(model.customCardAmount).length == 0 && sobotConvertToString(model.customCardAmountSymbol).length == 0){
        self.layoutTipTop.constant = 0;
        self.labTips.text = @"";
        self.priceTip.text = @"";
        _layoutPriceHeight.constant = 0;
    }else{
        self.layoutPriceHeight.constant = 28;
        self.layoutTipTop.constant = 4;
    }
    
    if(model.customMenus.count > 0 && message.senderType!=0){
        
        self.labDesc.numberOfLines = 1;
        self.labDesc.lineBreakMode = NSLineBreakByTruncatingTail;
        
        SobotChatCustomCardMenu *menu = [model.customMenus firstObject];
        self.btnSend.hidden = NO;
        
        self.btnSend.obj = menu;
        [self.btnSend setTitle:sobotConvertToString(menu.menuName) forState:0];
        CGFloat sendW = [SobotUITools getWidthContain:self.btnSend.titleLabel.text font:self.btnSend.titleLabel.font Height:20] + 24;
        if(sendW > 68){
            sendW = 68;
        }
        
        _layoutBtnWidth.constant = sendW;
        
        
        // 价格要和按钮对齐
        if(self.layoutTipTop.constant > 0){
            self.layoutTipTop.constant = 18;
        }
    }else{
        self.btnSend.hidden = YES;
        _layoutBtnWidth.constant = 0;
    }
    
}

@end
