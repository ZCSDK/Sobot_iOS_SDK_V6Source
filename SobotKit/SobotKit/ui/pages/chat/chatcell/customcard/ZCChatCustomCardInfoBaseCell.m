//
//  ZCChatCustomCardInfoBaseCell.m
//  SobotKit
//
//  Created by zhangxy on 2023/6/13.
//

#import "ZCChatCustomCardInfoBaseCell.h"
#import "ZCChatBaseCell.h"

@interface ZCChatCustomCardInfoBaseCell()


@end

@implementation ZCChatCustomCardInfoBaseCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
//        [self.contentView setBackgroundColor:[ZCUIKitTools zcgetChatBackgroundColor]];
        [self.contentView setBackgroundColor:UIColor.clearColor];
        [self createViews];
    }
    return self;
}

-(void)prepareForReuse{
    [super prepareForReuse];
    _posterView.image = nil;
}

-(void)createViews{
    _bgView = ({
        UIView *iv = [[UIView alloc] init];
        [iv setBackgroundColor:UIColor.clearColor];
        [self.contentView addSubview:iv];
        iv;
    });
    
    _posterView = ({
        SobotImageView *iv = [[SobotImageView alloc] init];
        iv.contentMode = UIViewContentModeScaleAspectFit;
        iv.layer.masksToBounds = YES;
        iv.layer.cornerRadius = 4.0f;
        [iv setImage:SobotKitGetImage(@"zcicon_arrow_right_record")];
        [self.bgView addSubview:iv];
        iv;
    });
    _labTitle = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        iv.numberOfLines = 1;
        iv.lineBreakMode = NSLineBreakByTruncatingTail;
        [iv setFont:SobotFontBold14];
        [self.bgView addSubview:iv];
        iv;
    });
    _labDesc = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        [iv setFont:SobotFont14];
        iv.numberOfLines = 2;
        iv.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.bgView addSubview:iv];
        iv;
    });
    _labTips = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:[ZCUIKitTools zcgetPricetTagTextColor]];
        [iv setFont:SobotFontBold16];
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
    
    _btnSend = ({
        SobotButton *iv = (SobotButton*)[SobotUITools createZCButton];
        [iv.titleLabel setFont:SobotFont12];
        iv.layer.masksToBounds = YES;
        iv.layer.borderColor = [ZCUIKitTools zcgetGoodSendBtnColor].CGColor;
        iv.layer.cornerRadius = 12.0f;
        iv.layer.borderWidth = 1.0f;
        iv.titleEdgeInsets = UIEdgeInsetsMake(0, 9, 0, 9);
        iv.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [iv setTitleColor:[ZCUIKitTools zcgetGoodSendBtnColor] forState:0];
        [iv setTitle:SobotKitLocalString(@"发送") forState:0];
        [iv addTarget:self action:@selector(sendButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgView addSubview:iv];
        iv;
    });
}

-(void)configureCellWithData:(SobotChatCustomCardInfo *)model message:(SobotChatMessage *)message{
    NSString *photoUrl = sobotConvertToString(model.customCardThumbnail);
    [_posterView loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(photoUrl)] placeholer:SobotKitGetImage(@"zcicon_default_goods_1")  showActivityIndicatorView:YES];
    [_labTitle setText:sobotConvertToString(model.customCardName)];
    [_labDesc setText:sobotConvertToString(model.customCardDesc)];
//    NSString *tipStr = [NSString stringWithFormat:@"%@%@",sobotConvertToString(model.customCardAmountSymbol),sobotConvertToString(model.customCardAmount)];
//    [_labTips setText:tipStr];
    [_labTips setText:sobotConvertToString(model.customCardAmount)];
    [_priceTip setText:sobotConvertToString(model.customCardAmountSymbol)];
    [self.labTips setTextColor:[ZCUIKitTools zcgetPricetTagTextColor]];
    [self.priceTip setTextColor:[ZCUIKitTools zcgetPricetTagTextColor]];
    [self.labDesc setTextColor:UIColorFromKitModeColor(SobotColorTextSub1)];
    [self.labTitle setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
    
}


-(void)menuButtonClick:(SobotButton *) btn{
    if(self.delegate && [self.delegate respondsToSelector:@selector(onCollectionItemMenuClick:index:message:)]){
        [self.delegate onCollectionItemMenuClick:btn.obj index:self.indexPath message:self.message];
    }
}


-(void)sendButtonClick:(SobotButton *) btn{
    if(btn!=nil && self.cardModel!=nil){
        [self menuButtonClick:btn];
    }
}

@end
