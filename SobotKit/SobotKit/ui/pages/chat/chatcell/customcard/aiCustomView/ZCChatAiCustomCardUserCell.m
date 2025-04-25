//
//  ZCChatAiCustomCardUserCell.m
//  SobotKit
//
//  Created by lizh on 2025/3/21.
//

#import "ZCChatAiCustomCardUserCell.h"
#import "ZCUICore.h"
//#import "ZCChatAiCustomCardView.h"
#import "ZCChatAiCardView.h"
@interface ZCChatAiCustomCardUserCell()<ZCChatAiCardViewDelegate>{
    
}

@property(nonatomic,strong) NSLayoutConstraint *layoutBgWidth;
@property (strong, nonatomic) UIView *bgView;

@end


@implementation ZCChatAiCustomCardUserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self createViews];
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self createViews];
    }
    return self;
}


-(void)createViews{
    _bgView = ({
        UIView *iv = [[UIView alloc] init];
//        [iv setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark1)];
        [self.contentView addSubview:iv];
        iv.backgroundColor = UIColor.redColor;
        iv.layer.masksToBounds = YES;
        iv.layer.cornerRadius = 4;
        iv.layer.borderColor = UIColorFromKitModeColor(SobotColorBgTopLine).CGColor;
        iv.layer.borderWidth = 0.75f;
        iv;
    });
    //设置点击事件
    _layoutBgWidth = sobotLayoutEqualWidth(self.maxWidth+32, self.bgView, NSLayoutRelationEqual);
    [self.contentView addConstraint:_layoutBgWidth];
    [self.contentView addConstraint:sobotLayoutPaddingTop(0, self.bgView, self.ivBgView)];
    [self.contentView addConstraint:sobotLayoutPaddingLeft(0, self.bgView, self.ivBgView)];
    [self.contentView addConstraint:sobotLayoutPaddingBottom(0, self.bgView, self.ivBgView)];
    [self.contentView addConstraint:sobotLayoutMarginBottom(0, self.bgView, self.lblSugguest)];
}



-(void)initDataToView:(SobotChatMessage *)message time:(NSString *)showTime{
    [super initDataToView:message time:showTime];
    [self.bgView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _layoutBgWidth.constant = self.maxWidth +32;
    ZCChatAiCardView *view = [[ZCChatAiCardView alloc]initWithDict:[message.richModel.customCard.customCards firstObject] maxW:self.maxWidth supView:self.bgView lastView:nil isHistory:message.isHistory isUnBtn:YES];
    [self.bgView addSubview:view];
    [self.bgView addConstraint:sobotLayoutPaddingTop(0, view, self.bgView)];
    [self.bgView addConstraint:sobotLayoutPaddingLeft(0, view, self.bgView)];
    [self.bgView addConstraint:sobotLayoutPaddingRight(0, view, self.bgView)];
    [self.bgView addConstraint:sobotLayoutPaddingBottom(0, view, self.bgView)];
    [view layoutIfNeeded];
    [self.bgView layoutIfNeeded];
    [self setChatViewBgState:CGSizeMake(self.maxWidth,view.frame.size.height)];
    [self.ivBgView setBackgroundColor:UIColor.clearColor];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
