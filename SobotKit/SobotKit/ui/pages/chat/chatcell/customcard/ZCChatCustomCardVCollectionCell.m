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
@property (strong, nonatomic) NSLayoutConstraint *layoutBtnPB;
@property (strong, nonatomic) NSLayoutConstraint *layoutTipPB;
@property (strong,nonatomic) SobotChatMessage *chatMsg;
@end

@implementation ZCChatCustomCardVCollectionCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addConstraints:sobotLayoutPaddingWithAll(0, 0, 0, 0, self.bgView, self.contentView)];
        self.posterView.contentMode = UIViewContentModeScaleAspectFill;
        self.posterView.layer.cornerRadius  = 4.0f;
        self.posterView.layer.masksToBounds = YES;
        
        [self.bgView addConstraints:sobotLayoutSize(76, 76, self.posterView, NSLayoutRelationEqual)];
        //            [self.bgView addConstraint:sobotLayoutEqualCenterY(0, self.posterView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingBottom(0, self.posterView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(0, self.posterView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingTop(0, self.posterView, self.bgView)];
        
        self.labTitle.font = SobotFontBold14;
        self.labTitle.numberOfLines = 1;
        self.labTitle.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.bgView addConstraint:sobotLayoutPaddingTop(2, self.labTitle, self.bgView)];
        [self.bgView addConstraint:sobotLayoutMarginLeft(ZCChatRichCellItemSpace, self.labTitle, self.posterView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-8, self.labTitle, self.bgView)]; // 到屏宽是20 -12的外部约束
        
        self.labDesc.font = SobotFont12;
        self.labDesc.numberOfLines = 2;
        [self.bgView addConstraint:sobotLayoutMarginTop(ZCChatCellItemSpace-1, self.labDesc, self.labTitle)];
        [self.bgView addConstraint:sobotLayoutMarginLeft(ZCChatRichCellItemSpace, self.labDesc, self.posterView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.labDesc, self.bgView)];
                
        self.priceTip.font = SobotFont12;
        [self.bgView addConstraint:sobotLayoutMarginLeft(ZCChatRichCellItemSpace, self.priceTip, self.posterView)];
        [self.bgView addConstraint:sobotLayoutPaddingBottom(-1, self.priceTip, self.labTips)];
//        [self.bgView addConstraint:sobotLayoutEqualCenterY(2, self.priceTip, self.btnSend)];
        self.priceTip.textAlignment = NSTextAlignmentRight;
        [self.bgView addConstraint:sobotLayoutEqualWidth(12, self.priceTip, NSLayoutRelationEqual)];
        [self.bgView addConstraint:sobotLayoutEqualHeight(12, self.priceTip, NSLayoutRelationEqual)];
        
        self.labTips.font = SobotFontBold16;
//        [self.labTips setTextColor:[ZCUIKitTools zcgetChatLeftLinkColor]];
        [self.bgView addConstraint:sobotLayoutMarginLeft(0, self.labTips, self.priceTip)];
        [self.bgView addConstraint:sobotLayoutMarginRight(-10, self.labTips, self.btnSend)];
        self.layoutTipPB = sobotLayoutPaddingBottom(-3.5, self.labTips, self.bgView);
        [self.bgView addConstraint:self.layoutTipPB];
        [self.bgView addConstraint:sobotLayoutEqualHeight(17, self.labTips, NSLayoutRelationEqual)];
//        [self.bgView addConstraint:sobotLayoutEqualCenterY(0, self.labTips, self.btnSend)];

        
        self.btnSend.layer.cornerRadius = 12.0f;
        _layoutBtnWidth = sobotLayoutEqualWidth(55, self.btnSend, NSLayoutRelationEqual);
        [self.bgView addConstraint:_layoutBtnWidth];
        [self.bgView addConstraint:sobotLayoutEqualHeight(24, self.btnSend, NSLayoutRelationEqual)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.btnSend, self.bgView)];
        self.layoutBtnPB = sobotLayoutPaddingBottom(0, self.btnSend, self.posterView);
        [self.bgView addConstraint:self.layoutBtnPB];
        
        
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
    
    if(sobotConvertToString(model.customCardDesc).length >0){
        CGFloat lh = [SobotUITools getHeightContain:sobotConvertToString(model.customCardDesc) font:SobotFont12 Width:self.bgView.frame.size.width - 86];
        if(lh > 14){
            self.layoutBtnPB.constant = 12;
        }else{
            self.layoutBtnPB.constant = 0;
        }
    }
    
    if(model.customMenus.count > 0 && message.senderType!=0){
        SobotChatCustomCardMenu *menu = [model.customMenus firstObject];
        self.btnSend.hidden = NO;
        _layoutBtnWidth.constant = 55;
        self.btnSend.obj = menu;
        [self.btnSend setTitle:sobotConvertToString(menu.menuName) forState:0];
        self.layoutTipPB.constant = -3.5;
    }else{
        self.btnSend.hidden = YES;
        _layoutBtnWidth.constant = 0;
        self.layoutTipPB.constant = 0;
    }
    
}

@end
