//
//  ZCChatAppletCell.m
//  SobotKit
//
//  Created by zhangxy on 2022/9/22.
//

#import "ZCChatAppletCell.h"

#import <SobotCommon/SobotCommon.h>


@interface ZCChatAppletCell(){
    NSString *morelink;
    
}

@property(nonatomic,strong) NSLayoutConstraint *layoutBgWidth;
@property(nonatomic,strong) NSLayoutConstraint *layoutTitleDescHeight;

@property(nonatomic,strong) NSLayoutConstraint *layoutImageHeight;
@property(nonatomic,strong) NSLayoutConstraint *layoutLogoLeft;
@property(nonatomic,strong) NSLayoutConstraint *layoutLogoWidth;

@property(nonatomic,strong) NSLayoutConstraint *layoutSummaryHeight;
@property(nonatomic,strong) NSLayoutConstraint *layoutLookHeight;

@property (strong, nonatomic) UIView *bgView; //
@property (strong, nonatomic) UIView *bgLineView; //

@property (nonatomic,strong) SobotImageView *logoView;
@property (strong, nonatomic) UILabel *labTitleDesc; // 要素标题
@property (strong, nonatomic) UILabel *labTitle; //标题
@property (strong, nonatomic) SobotImageView *posterView;// 图片
@property (strong, nonatomic) UIView *lineView; //
@property (nonatomic,strong) SobotImageView *iconView;
@property (strong, nonatomic) UILabel *lookMore; //

@property (nonatomic,strong) SobotChatMessage *message;
@end

@implementation ZCChatAppletCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self createViews];
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self createViews];
        
//        [self.contentView addConstraints:sobotLayoutPaddingView(1, -1, 1, -1, self.bgView, self.ivBgView)];
        [self.contentView addConstraint:sobotLayoutPaddingTop(ZCChatMarginVSpace, self.bgView, self.ivBgView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(0, self.bgView, self.ivBgView)];
//        [self.contentView addConstraint:sobotLayoutPaddingRight(-1, self.bgView, self.ivBgView)];
        _layoutBgWidth = sobotLayoutEqualWidth(ScreenWidth, self.bgView, NSLayoutRelationEqual);
//        _layoutBgHeight = sobotLayoutEqualHeight(0, self.bgView, NSLayoutRelationEqual);
        [self.contentView addConstraint:_layoutBgWidth];
//        [self.contentView addConstraint:_layoutBgHeight];
        [self.contentView addConstraint:sobotLayoutMarginBottom(0, self.bgView, self.lblSugguest)];
        
        [self.contentView addConstraint:sobotLayoutPaddingTop(0, self.bgLineView, self.ivBgView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(0, self.bgLineView, self.bgView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(0, self.bgLineView, self.bgView)];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(0, self.bgLineView, self.ivBgView)];
        
        _layoutLogoLeft = sobotLayoutPaddingLeft(ZCChatMarginVSpace, self.logoView, self.bgView);
        _layoutLogoWidth = sobotLayoutEqualWidth(20, self.logoView, NSLayoutRelationEqual);
        [self.bgView addConstraint:sobotLayoutEqualHeight(20, self.logoView, NSLayoutRelationEqual)];
        [self.bgView addConstraint:_layoutLogoWidth];
        [self.bgView addConstraint:_layoutLogoLeft];
        [self.bgView addConstraint:sobotLayoutPaddingTop(0, self.logoView, self.bgView)];
        
        
        _layoutTitleDescHeight = sobotLayoutEqualHeight(20, self.labTitleDesc, NSLayoutRelationEqual);
        [self.bgView addConstraint:_layoutTitleDescHeight];
        [self.bgView addConstraint:sobotLayoutMarginLeft(ZCChatItemSpace8, self.labTitleDesc, self.logoView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.labTitleDesc, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingTop(0, self.labTitleDesc, self.bgView)];
        
        
        [self.bgView addConstraint: sobotLayoutMarginTop(ZCChatItemSpace8, self.labTitle, self.labTitleDesc)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(ZCChatMarginVSpace, self.labTitle, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatMarginVSpace, self.labTitle, self.bgView)];
        [self.bgView addConstraint:sobotLayoutEqualHeight(22, self.labTitle, NSLayoutRelationEqual)];
        
        
        _layoutImageHeight = sobotLayoutEqualHeight(164, self.posterView, NSLayoutRelationEqual);
        [self.bgView addConstraint:_layoutImageHeight];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(ZCChatMarginVSpace, self.posterView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatMarginVSpace, self.posterView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutMarginTop(ZCChatItemSpace8, self.posterView, self.labTitle)];
        
        
        [self.bgView addConstraint:sobotLayoutMarginTop(ZCChatMarginVSpace, self.lineView, self.posterView)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(ZCChatMarginVSpace, self.lineView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatMarginVSpace, self.lineView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutEqualHeight(1, self.lineView, NSLayoutRelationEqual)];
        
        [self.bgView addConstraints:sobotLayoutSize(12, 12, self.iconView, NSLayoutRelationEqual)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(ZCChatMarginVSpace, self.iconView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutMarginTop(6, self.iconView, self.lineView)];
        
        [self.bgView addConstraint:sobotLayoutEqualHeight(20, self.lookMore, NSLayoutRelationEqual)];
        [self.bgView addConstraint:sobotLayoutMarginLeft(4, self.lookMore, self.iconView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatMarginVSpace, self.lookMore, self.bgView)];
        [self.bgView addConstraint:sobotLayoutMarginTop(2, self.lookMore, self.lineView)];
        [self.bgView addConstraint:sobotLayoutPaddingBottom(-2, self.lookMore, self.bgView)];
        
//        [self.bgView addConstraints:sobotLayoutPaddingView(0, 2, -ZCChatPaddingHSpace, ZCChatPaddingHSpace, self.lineView, self.posterView)];
    }
    return self;
}


-(void)createViews{
    _bgLineView = ({
        UIView *iv = [[UIView alloc] init];
        [iv setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark3)]; //[ZCUIKitTools zcgetLightGrayBackgroundColor]
        iv.layer.borderColor = UIColorFromKitModeColor(SobotColorBgLine).CGColor;
        iv.layer.borderWidth = 0.75;
        iv.layer.cornerRadius = 4;
        iv.layer.masksToBounds = YES;
        [self.contentView insertSubview:iv atIndex:0];
        
        
        iv;
    });
    _bgView = ({
        UIView *iv = [[UIView alloc] init];
        [iv setBackgroundColor:UIColor.clearColor];
//        [iv setBackgroundColor:UIColorFromKitModeColor(SobotColorWhite)]; //[ZCUIKitTools zcgetLightGrayBackgroundColor]
//        iv.layer.borderColor = UIColorFromKitModeColor(SobotColorBgLine).CGColor;
//        iv.layer.borderWidth = 1;
        [self.contentView addSubview:iv];
        iv;
    });
    _logoView = ({
        SobotImageView *iv = [[SobotImageView alloc] init];
        iv.layer.masksToBounds = YES;
        iv.contentMode = UIViewContentModeScaleAspectFit;
        //设置点击事件
        iv.userInteractionEnabled=YES;
        [self.bgView addSubview:iv];
        iv;
    });
    _iconView = ({
        SobotImageView *iv = [[SobotImageView alloc] init];
        iv.layer.masksToBounds = YES;
        iv.contentMode = UIViewContentModeScaleAspectFit;
        //设置点击事件
        iv.userInteractionEnabled=YES;
        [self.bgView addSubview:iv];
        iv;
    });
    _posterView = ({
        SobotImageView *iv = [[SobotImageView alloc] init];
        iv.layer.cornerRadius = 4.0f;
        iv.layer.masksToBounds = YES;
        iv.contentMode = UIViewContentModeScaleAspectFill;
        //设置点击事件
        UITapGestureRecognizer *tapGesturer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgTouchUpInside:)];
        iv.userInteractionEnabled=YES;
        [iv addGestureRecognizer:tapGesturer];
        [self.bgView addSubview:iv];
        iv;
    });
    _labTitle = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        iv.numberOfLines = 0;
        [iv setFont:SobotFont12];
        [self.bgView addSubview:iv];
        iv;
    });
    
    
    _labTitleDesc = ({
        UILabel *iv = [[UILabel alloc] init];
        iv.numberOfLines = 0;
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        [iv setFont:SobotFont14];
        [self.bgView addSubview:iv];
        iv;
    });
    _lookMore = ({
        UILabel *iv = [[UILabel alloc] init];
        iv.numberOfLines = 0;
        [iv setTextAlignment:NSTextAlignmentLeft];
//        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        [iv setTextColor:UIColorFromKitModeColor(SobotColorTextSub)];
        [iv setFont:SobotFont12];
        [self.bgView addSubview:iv];
        iv;
    });
    
    
    _lineView = ({
        UIView *iv = [[UIView alloc] init];
        [iv setBackgroundColor:[ZCUIKitTools zcgetLineRichColor]];
//        [iv setBackgroundColor:[UIColor clearColor]];
        [self.bgView addSubview:iv];
        iv;
    });
    
}

-(void)initDataToView:(SobotChatMessage *)message time:(NSString *)showTime{
    [super initDataToView:message time:showTime];
    if (sobotConvertToString(message.richModel.richContent.logo).length > 0) {
        // 有APP图标
        _logoView.hidden = NO;
        _layoutLogoLeft.constant = ZCChatMarginVSpace;
        _layoutLogoWidth.constant = 20;
        [_logoView loadWithURL:[NSURL URLWithString:sobotConvertToString(message.richModel.richContent.logo)] placeholer:[SobotUITools getSysImageByName:@""] showActivityIndicatorView:NO];
    }else{
        _layoutLogoLeft.constant = ZCChatMarginVSpace - ZCChatItemSpace8;
        _layoutLogoWidth.constant = 0;
        _logoView.hidden = YES;
    }
    if (sobotConvertToString(message.richModel.richContent.describe).length > 0) {
        _labTitleDesc.text = sobotConvertToString(message.richModel.richContent.describe);
        _layoutTitleDescHeight.constant = 22;
    }else{
        _layoutTitleDescHeight.constant = 0;
    }
    
    _labTitle.text = sobotConvertToString(message.richModel.richContent.title);
    [_posterView loadWithURL:[NSURL URLWithString:sobotConvertToString(message.richModel.richContent.thumbUrl)] placeholer:[SobotUITools getSysImageByName:@""] showActivityIndicatorView:NO];
    
    [_iconView loadWithURL:[NSURL URLWithString:@""] placeholer:SobotKitGetImage(@"zcicon_applet") showActivityIndicatorView:NO];
    _lookMore.text = SobotKitLocalString(@"小程序");
    CGFloat w = self.maxWidth;
    if(self.maxWidth > 260){
        w = 260;
    }
    _layoutBgWidth.constant = w;
    [self.bgView layoutIfNeeded];
    [self setChatViewBgState:CGSizeMake(w-ZCChatPaddingHSpace*2,CGRectGetMaxX(_lookMore.frame))];
    self.ivBgView.backgroundColor = [UIColor clearColor];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)imgTouchUpInside:(UITapGestureRecognizer*)tap{
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeAppletAction text:@"" obj:_message];
    }
}


@end

