//
//  ZCChatOnlineTipsCell.m
//  SobotKit
//
//  Created by zhangxy on 2022/9/22.
//

#import "ZCChatOnlineTipsCell.h"
#import "ZCUICore.h"

#define ZCOnlineHaderWidth 40
@interface ZCChatOnlineTipsCell(){
    NSString *morelink;
    
}

@property(nonatomic,strong) NSLayoutConstraint *layoutBgWidth;


@property (strong, nonatomic) UIView *bgView; //
@property (nonatomic,strong) SobotImageView *logoView;
@property (strong, nonatomic) UILabel *labTitle; //标题
@property (strong, nonatomic) UILabel *labDesc; //标题


@end

@implementation ZCChatOnlineTipsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self createViews];
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self createViews];
        
        
        [self.contentView addConstraints:sobotLayoutSize(ZCOnlineHaderWidth, ZCOnlineHaderWidth, self.logoView, NSLayoutRelationEqual)];
        [self.contentView addConstraint:sobotLayoutEqualCenterX(0, self.logoView, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingTop(ZCChatMarginVSpace, self.logoView, self.contentView)];
        
        //设置点击事件
        [self.contentView addConstraint:sobotLayoutPaddingTop(ZCChatMarginVSpace + ZCOnlineHaderWidth/2, self.bgView, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(ZCChatMarginHSpace, self.bgView, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-ZCChatMarginHSpace, self.bgView, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(-ZCChatMarginVSpace, self.bgView, self.contentView)];
        
        [self.bgView addConstraint: sobotLayoutPaddingTop(ZCChatPaddingVSpace + 18, self.labTitle, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingHSpace, self.labTitle, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatPaddingHSpace, self.labTitle, self.bgView)];
        
        [self.bgView addConstraint: sobotLayoutMarginTop(ZCChatMarginVSpace, self.labDesc, self.labTitle)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingHSpace, self.labDesc, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatPaddingHSpace, self.labDesc, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingBottom(-ZCChatPaddingVSpace, self.labDesc, self.bgView)];
    }
    return self;
}


-(void)createViews{
    _bgView = ({
        UIView *iv = [[UIView alloc] init];
        [iv setBackgroundColor:[ZCUIKitTools zcgetChatBackgroundColor]];
        iv.layer.cornerRadius = 5.0f;
        iv.layer.masksToBounds = YES;
        iv.layer.borderColor = [ZCUIKitTools zcgetLeftChatColor].CGColor;
        iv.layer.borderWidth = 1.0f;
        [self.contentView addSubview:iv];
        
        
        iv.layer.masksToBounds = NO;
        iv.layer.borderWidth = 2.0f;
        iv.layer.shadowColor = [ZCUIKitTools zcgetChatBottomLineColor].CGColor;
        iv.layer.shadowOpacity = 0.8;
        iv.layer.shadowRadius = 5;
        iv.layer.shadowOffset = CGSizeMake(5.0f, 5.0f);
        iv;
    });
    
    _logoView = ({
        SobotImageView *iv = [[SobotImageView alloc] init];
        iv.layer.masksToBounds = YES;
        iv.contentMode = UIViewContentModeScaleAspectFill;
        iv.layer.cornerRadius = ZCOnlineHaderWidth/2;
        //设置点击事件
        iv.userInteractionEnabled=YES;
        [self.contentView addSubview:iv];
        iv;
    });
    
    _labTitle = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentCenter];
        [iv setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
        iv.numberOfLines = 0;
        [iv setFont:SobotFont15];
        [self.bgView addSubview:iv];
        iv;
    });
    
    
    _labDesc = ({
        UILabel *iv = [[UILabel alloc] init];
//        iv.numberOfLines = 0;
        [iv setTextAlignment:NSTextAlignmentCenter];
        [iv setTextColor:UIColorFromKitModeColor(SobotColorTextSub1)];
        [iv setFont:SobotFont14];
        [self.bgView addSubview:iv];
        iv;
    });
}

-(void)initDataToView:(SobotChatMessage *)message time:(NSString *)showTime{
    [super initDataToView:message time:showTime];
    
    self.ivHeader.hidden = YES;
    self.lblNickName.hidden = YES;
    self.lblSugguest.hidden = YES;
    self.ivBgView.hidden = YES;
    [_logoView loadWithURL:[NSURL URLWithString:sobotConvertToString(message.senderFace)] placeholer:SobotKitGetImage(@"zcicon_useravatart_girl")];
    
    
    [_labTitle setText:sobotConvertToString(message.senderName)];
    [_labDesc setText:sobotConvertToString(message.tipsMessage)];
    
    [self.bgView layoutIfNeeded];
    [self setChatViewBgState:CGSizeMake(self.maxWidth,CGRectGetMaxY(_bgView.frame))];
    
    self.ivBgView.backgroundColor = UIColor.clearColor;
}

-(void)sendButtonClick:(SobotButton *) btn{
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeSendGoosText text:sobotConvertToString(@"")  obj:sobotConvertToString(@"")];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
