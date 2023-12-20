//
//  ZCChatArticleCell.m
//  SobotKit
//
//  Created by zhangxy on 2022/9/22.
//

#import "ZCChatArticleCell.h"

#import <SobotCommon/SobotCommon.h>


@interface ZCChatArticleCell(){
    NSString *morelink;
    
}

@property(nonatomic,strong) NSLayoutConstraint *layoutBgWidth;
@property(nonatomic,strong) NSLayoutConstraint *layoutTitleDescHeight;

@property(nonatomic,strong) NSLayoutConstraint *layoutImageHeight;
@property(nonatomic,strong) NSLayoutConstraint *layoutLogoLeft;

@property(nonatomic,strong) NSLayoutConstraint *layoutSummaryHeight;
@property(nonatomic,strong) NSLayoutConstraint *layoutLookHeight;

@property (strong, nonatomic) UIView *bgView; //
@property (nonatomic,strong) SobotImageView *logoView;
@property (strong, nonatomic) UILabel *labTitle; //标题
@property (strong, nonatomic) UILabel *labTitleDesc; //标题
@property (strong, nonatomic) UIView *lineView; //
@property (strong, nonatomic) UILabel *lookMore; //
@property (nonatomic,strong) SobotImageView *iconView;


@end

@implementation ZCChatArticleCell

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
        UITapGestureRecognizer *tapGesturer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(articleClick:)];
        self.bgView.userInteractionEnabled=YES;
        [self.bgView addGestureRecognizer:tapGesturer];
        
        [self.contentView addConstraint:sobotLayoutPaddingTop(ZCChatPaddingVSpace, self.bgView, self.ivBgView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingHSpace, self.bgView, self.ivBgView)];
        _layoutBgWidth = sobotLayoutEqualWidth(ScreenWidth, self.bgView, NSLayoutRelationEqual);
//        _layoutBgHeight = sobotLayoutEqualHeight(0, self.bgView, NSLayoutRelationEqual);
        [self.contentView addConstraint:_layoutBgWidth];
//        [self.contentView addConstraint:_layoutBgHeight];
        [self.contentView addConstraint:sobotLayoutMarginBottom(-ZCChatCellItemSpace, self.bgView, self.lblSugguest)];
        
        _layoutImageHeight = sobotLayoutEqualHeight(175, self.logoView, NSLayoutRelationEqual);
        [self.bgView addConstraint:_layoutImageHeight];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(0, self.logoView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.logoView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingTop(0, self.logoView, self.bgView)];
        
        
        
        [self.bgView addConstraint: sobotLayoutMarginTop(ZCChatCellItemSpace, self.labTitle, self.logoView)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(0, self.labTitle, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.labTitle, self.bgView)];
        
        
        [self.bgView addConstraint: sobotLayoutMarginTop(ZCChatCellItemSpace, self.labTitleDesc, self.labTitle)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(0, self.labTitleDesc, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.labTitleDesc, self.bgView)];
        
        
        [self.bgView addConstraint: sobotLayoutMarginTop(ZCChatCellItemSpace, self.lineView, self.labTitleDesc)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(0, self.lineView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.lineView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutEqualHeight(1, self.lineView, NSLayoutRelationEqual)];
        
        [self.bgView addConstraint:sobotLayoutEqualHeight(20, self.lookMore, NSLayoutRelationEqual)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(0, self.lookMore, self.bgView)];
        [self.bgView addConstraint:sobotLayoutMarginRight(0, self.lookMore, self.iconView)];
        [self.bgView addConstraint:sobotLayoutMarginTop(ZCChatCellItemSpace, self.lookMore, self.lineView)];
        [self.bgView addConstraint:sobotLayoutPaddingBottom(-ZCChatCellItemSpace, self.lookMore, self.bgView)];
        
        [self.bgView addConstraint:sobotLayoutEqualHeight(20, self.iconView, NSLayoutRelationEqual)];
        [self.bgView addConstraint:sobotLayoutEqualWidth(20, self.iconView, NSLayoutRelationEqual)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.iconView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutMarginTop(ZCChatCellItemSpace, self.iconView, self.lineView)];
    }
    return self;
}


-(void)createViews{
    _bgView = ({
        UIView *iv = [[UIView alloc] init];
        [iv setBackgroundColor:[ZCUIKitTools zcgetLightGrayBackgroundColor]];
        [self.contentView addSubview:iv];
        iv;
    });
    _logoView = ({
        SobotImageView *iv = [[SobotImageView alloc] init];
        iv.layer.masksToBounds = YES;
        iv.contentMode = UIViewContentModeScaleAspectFill;
        //设置点击事件
        iv.userInteractionEnabled=YES;
        [self.bgView addSubview:iv];
        iv;
    });
    
    _labTitle = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        iv.numberOfLines = 0;
        [iv setFont:SobotFontBold14];
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
        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        [iv setFont:SobotFont14];
        [self.bgView addSubview:iv];
        iv;
    });
    
    
    _lineView = ({
        UIView *iv = [[UIView alloc] init];
        [iv setBackgroundColor:[ZCUIKitTools zcgetLineRichColor]];
        [self.bgView addSubview:iv];
//        [iv setBackgroundColor:[UIColor clearColor]];
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
}

-(void)initDataToView:(SobotChatMessage *)message time:(NSString *)showTime{
    [super initDataToView:message time:showTime];
    if (sobotConvertToString(message.richModel.richContent.snapshot).length > 0) {
        // 有APP图标
        _logoView.hidden = NO;
        _layoutImageHeight.constant = 175;
        [_logoView loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(message.richModel.richContent.snapshot)] placeholer:SobotKitGetImage(@"zcicon_default_goods_1")  showActivityIndicatorView:YES];
    }else{
        _layoutImageHeight.constant = 0;
        _logoView.hidden = YES;
    }
    
    _labTitle.text = sobotConvertToString(message.richModel.richContent.title);
    _labTitleDesc.text = sobotConvertToString(message.richModel.richContent.desc);
    
    _iconView.image = SobotKitGetImage(@"zcicon_arrow_reply");
    _lookMore.text = SobotKitLocalString(@"查看详情");
    morelink = sobotConvertToString(message.richModel.richContent.richMoreUrl);
    
    _layoutBgWidth.constant = self.maxWidth;
    [self.bgView layoutIfNeeded];
    [self setChatViewBgState:CGSizeMake(self.maxWidth,CGRectGetMaxX(_lookMore.frame))];
}

-(void)articleClick:(UITapGestureRecognizer *) tap{
    if (sobotConvertToString(morelink).length == 0) {
        return;
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeOpenURL text:sobotConvertToString(morelink)  obj:sobotConvertToString(morelink)];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
