//
//  ZCChatLocationCell.m
//  SobotKit
//
//  Created by zhangxy on 2022/9/22.
//

#import "ZCChatLocationCell.h"


#import "ZCUICore.h"
#import "ZCCircleProgressView.h"

@interface ZCChatLocationCell(){
    
}

@property(nonatomic,strong) NSLayoutConstraint *layoutBgWidth;
@property(nonatomic,strong) NSLayoutConstraint *layoutImageHeight;

@property (strong, nonatomic) UIView *bgView; //
@property (strong, nonatomic) UILabel *labTitle; //标题
@property (strong, nonatomic) UILabel *labDesc; //标题
@property (nonatomic,strong) SobotImageView *logoView;

@end

@implementation ZCChatLocationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self createViews];
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self createViews];
        
        //设置点击事件
        UITapGestureRecognizer *tapGesturer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bgViewClick:)];
        self.bgView.userInteractionEnabled=YES;
        [self.bgView addGestureRecognizer:tapGesturer];
        
        //设置点击事件
        _layoutBgWidth = sobotLayoutEqualWidth(ScreenWidth, self.bgView, NSLayoutRelationEqual);
        [self.contentView addConstraint:_layoutBgWidth];
        [self.contentView addConstraint:sobotLayoutPaddingTop(ZCChatPaddingVSpace, self.bgView, self.ivBgView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(0, self.bgView, self.ivBgView)];
        // 这里往上提一点，这里如果有引导语会有问题
        [self.contentView addConstraint:sobotLayoutMarginBottom(ZCChatPaddingVSpace-ZCChatCellItemSpace, self.bgView, self.lblSugguest)];
        
        [self.bgView addConstraint: sobotLayoutPaddingTop(0, self.labTitle, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingVSpace, self.labTitle, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatPaddingVSpace, self.labTitle, self.bgView)];
        [self.bgView addConstraint:sobotLayoutEqualHeight(22, self.labTitle, NSLayoutRelationEqual)];
        
        [self.bgView addConstraint: sobotLayoutMarginTop(2, self.labDesc, self.labTitle)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingVSpace, self.labDesc, self.bgView)];
        [self.bgView addConstraint:sobotLayoutEqualHeight(20, self.labDesc, NSLayoutRelationGreaterThanOrEqual)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatPaddingVSpace, self.labDesc, self.bgView)];
        
        _layoutImageHeight = sobotLayoutEqualHeight(120, self.logoView, NSLayoutRelationEqual);
        [self.bgView addConstraint:_layoutImageHeight];
        [self.bgView addConstraint: sobotLayoutMarginTop(ZCChatItemSpace8, self.logoView, self.labDesc)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(0, self.logoView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.logoView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingBottom(0, self.logoView, self.bgView)];
        
    }
    return self;
}


-(void)createViews{
    _bgView = ({
        UIView *iv = [[UIView alloc] init];
        [iv setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark3)];
        [self.contentView addSubview:iv];
        iv.layer.cornerRadius = 4;
        iv.layer.masksToBounds = YES;
        iv.layer.borderColor = UIColorFromKitModeColor(SobotColorBgTopLine).CGColor;
        iv.layer.borderWidth = 0.75f;
        iv;
    });
    _logoView = ({
        SobotImageView *iv = [[SobotImageView alloc] init];
        iv.layer.masksToBounds = YES;
        iv.contentMode = UIViewContentModeScaleAspectFill;
        //设置点击事件
//        iv.layer.cornerRadius = 4.0f;
//        iv.layer.borderColor = UIColorFromModeColor(SobotColorBgLine).CGColor;
//        iv.layer.borderWidth = 0.5f;
        iv.userInteractionEnabled=YES;
        [self.bgView addSubview:iv];
        
        iv;
    });
    
    _labTitle = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        iv.numberOfLines = 0;
        [iv setFont:SobotFont14];
        [self.bgView addSubview:iv];
        iv;
    });
    
    
    _labDesc = ({
        UILabel *iv = [[UILabel alloc] init];
        iv.numberOfLines = 0;
        [iv setTextAlignment:NSTextAlignmentLeft];
//        [iv setTextColor: UIColorFromKitModeColor(SobotColorTextSub)];
        [iv setTextColor: UIColorFromKitModeColor(SobotColorTextSub)];
        [iv setFont:SobotFont12];
        [self.bgView addSubview:iv];
        iv;
    });
    
}


-(void)initDataToView:(SobotChatMessage *)message time:(NSString *)showTime{
    [super initDataToView:message time:showTime];
    if(self.isRight){
        [self.labTitle setTextColor:[ZCUIKitTools zcgetRightChatTextColor]];
    }else{
        [self.labTitle setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
    }
    [_logoView loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(message.richModel.richContent.picUrl)] placeholer:SobotKitGetImage(@"zcicon_default_goods_1") showActivityIndicatorView:NO];
    [_labTitle setText:sobotTrimString(message.richModel.richContent.title)];
    [_labDesc setText:message.richModel.richContent.desc];
    
    
    if(!_logoView.isHidden){
        dispatch_async(dispatch_get_main_queue(), ^{
               UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.logoView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(4,4)];
               //创建 layer
               CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
               maskLayer.frame = self.logoView.bounds;
               //赋值
               maskLayer.path = maskPath.CGPath;
               self.logoView.layer.mask = maskLayer;
           });
    }
    CGFloat w = self.maxWidth;
    if(self.maxWidth > 260){
        w = 260;
    }
    _layoutBgWidth.constant = w;
    [self.bgView layoutIfNeeded];
    [self setChatViewBgState:CGSizeMake(w-ZCChatPaddingHSpace*2,CGRectGetMaxX(_bgView.frame))];
    self.ivBgView.backgroundColor =UIColorFromKitModeColor(SobotColorBgMainDark3);
}


-(void)bgViewClick:(UITapGestureRecognizer *) tap{
    NSString * link = self.tempModel.richModel.richContent.url;
    
    if(sobotConvertToString(link).length  == 0){
        link = [NSString stringWithFormat:@"%@?longitude=%@&latitude=%@&name=%@&address=%@",@"sobot://openlocation",self.tempModel.richModel.richContent.lng,self.tempModel.richModel.richContent.lat,self.tempModel.richModel.richContent.title,self.tempModel.richModel.richContent.label];
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemOpenLocation text:sobotConvertToString(link)  obj:sobotConvertToString(link)];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end

