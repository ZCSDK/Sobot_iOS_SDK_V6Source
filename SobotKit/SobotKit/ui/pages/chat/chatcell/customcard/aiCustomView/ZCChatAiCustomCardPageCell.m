//
//  ZCChatAiCustomCardPageCell.m
//  SobotKit
//
//  Created by lizh on 2025/3/20.
//

#import "ZCChatAiCustomCardPageCell.h"
#import "ZCChatAiCustomCardView.h"
#import <SobotCommon/SobotCommon.h>
#import "ZCUICore.h"
#import "ZCChatAiCardView.h"
#import "ZCUIKitTools.h"
@interface  ZCChatAiCustomCardPageCell()<ZCChatAiCardViewDelegate>
@property (nonatomic,strong)ZCChatAiCustomCardView *cradView;
@property (nonatomic,strong)SobotButton *clickBtn;
@property (nonatomic,strong)UIView *bgView;
@end

@implementation ZCChatAiCustomCardPageCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.userInteractionEnabled=YES;
//        [self createItemsView];
//        self.backgroundColor = [ZCUIKitTools zcgetLightGrayDarkBackgroundColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

-(void)createItemsViewWithModel:(SobotChatCustomCardInfo *)model{
    
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _bgView = ({
        UIView *iv = [[UIView alloc]init];
        [self.contentView addSubview:iv];
        [self.contentView addConstraint:sobotLayoutPaddingTop(12,iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(16, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-16, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(0, iv, self.contentView)];
        iv.layer.cornerRadius = 8;
        iv.layer.borderColor = UIColorFromKitModeColor(SobotColorBgTopLine).CGColor;
        iv.layer.borderWidth = 0.75f;
        iv;
    });
    
    ZCChatAiCardView *card = [[ZCChatAiCardView alloc]initWithDict:model maxW:ScreenWidth-32 supView:self.bgView lastView:nil isHistory:self.isHistory isUnBtn:NO];
    card.delegate = self;
    [self.bgView addSubview:card];
    [_bgView addConstraint:sobotLayoutPaddingTop(0, card, _bgView)];
    [_bgView addConstraint:sobotLayoutPaddingLeft(0, card, _bgView)];
    [_bgView addConstraint:sobotLayoutPaddingRight(0, card, _bgView)];
    [_bgView addConstraint:sobotLayoutPaddingBottom(0, card, _bgView)];
    [card layoutIfNeeded];
    [_bgView layoutIfNeeded];
}

- (void)buttonStateChanged:(UIButton *)sender{
        if (sender.isHighlighted) {
            _bgView.layer.borderColor = [ZCUIKitTools zcgetServerConfigBtnBgColor].CGColor;
        } else {
            _bgView.layer.borderColor = UIColorFromKitModeColor(SobotColorBgTopLine).CGColor;
        }
}

-(void)clickType:(int)type obj:(NSObject *)obj Menu:(nonnull SobotChatCustomCardMenu *)menu{
    if (self.isHistory) {
        return;
    }
    if (type == 1 || type == 3) {
        SobotChatCustomCardInfo *cardModel = (SobotChatCustomCardInfo *)obj;
        if (_aiCardPageCellBlock) {
            self.aiCardPageCellBlock(cardModel,menu,type);
        }
    }else if(type == 2){
        // 打开链接
        [[ZCUICore getUICore] dealWithLinkClickWithLick:sobotConvertToString(menu.menuLink) viewController:[SobotUITools getCurrentVC]];
        SobotChatCustomCardInfo *cardModel = (SobotChatCustomCardInfo *)obj;
        if (_aiCardPageCellBlock) {
            self.aiCardPageCellBlock(cardModel,menu,type);
        }
    }
}


-(void)initDataToView:(SobotChatCustomCardInfo *) model{
    [self createItemsViewWithModel:model];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
//    if (selected) {
//        self.contentView.backgroundColor =  UIColorFromKitModeColor(SobotColorBgF5);
//    }else{
//        self.contentView.backgroundColor = UIColor.clearColor;
//    }
}

// 配置cell高亮状态
//- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
//    [super setHighlighted:highlighted animated:animated];
//    if (highlighted) {
//        self.cradView.backgroundColor = UIColorFromKitModeColor(SobotColorBgF5);
//    } else {
//        // 增加延迟消失动画效果，提升用户体验
//        [UIView animateWithDuration:0.1 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//            self.cradView.backgroundColor = UIColor.clearColor;
//        } completion:nil];
//    }
//}
@end
