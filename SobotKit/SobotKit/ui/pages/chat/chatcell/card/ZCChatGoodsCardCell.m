//
//  ZCChatGoodsCardCell.m
//  SobotKit
//
//  Created by zhangxy on 2022/9/22.
//

#import "ZCChatGoodsCardCell.h"
#import "ZCUICore.h"

@interface ZCChatGoodsCardCell(){
    
}

@property(nonatomic,strong) NSLayoutConstraint *layoutBgWidth;

@property(nonatomic,strong) NSLayoutConstraint *layoutTitleHeight;
@property(nonatomic,strong) NSLayoutConstraint *layoutTitleDescHeight;

@property(nonatomic,strong) NSLayoutConstraint *layoutImageHeight;
@property(nonatomic,strong) NSLayoutConstraint *layoutImageWidth;
@property(nonatomic,strong) NSLayoutConstraint *layoutImageLeft;

@property(nonatomic,strong) NSLayoutConstraint *layoutImageBottom;
@property(nonatomic,strong) NSLayoutConstraint *layoutLabelBottom;

@property (strong, nonatomic) UIView *bgView; //
@property (nonatomic,strong) SobotImageView *logoView;
@property (strong, nonatomic) UILabel *labTitle; //标题
@property (strong, nonatomic) UILabel *labDesc; //标题
@property (strong, nonatomic) UILabel *labTag; //标题

@property (nonatomic,copy) NSString *jumpUrl;
@end

@implementation ZCChatGoodsCardCell

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
        [self.contentView addConstraint:sobotLayoutPaddingTop(0, self.bgView, self.ivBgView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(0, self.bgView, self.ivBgView)];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(0, self.bgView, self.ivBgView)];
        
        
        
        _layoutImageHeight = sobotLayoutEqualHeight(76, self.logoView, NSLayoutRelationEqual);
        _layoutImageWidth = sobotLayoutEqualWidth(76, self.logoView, NSLayoutRelationEqual);
        _layoutImageLeft = sobotLayoutPaddingLeft(ZCChatMarginVSpace, self.logoView, self.bgView);
        [self.bgView addConstraint:_layoutImageWidth];
        [self.bgView addConstraint:_layoutImageHeight];
        [self.bgView addConstraint:_layoutImageLeft];
        _layoutImageBottom = sobotLayoutPaddingBottom(-ZCChatMarginVSpace, self.logoView, self.bgView);
        _layoutImageBottom.priority = UILayoutPriorityDefaultHigh;
        [self.bgView addConstraint:_layoutImageBottom];
        [self.bgView addConstraint: sobotLayoutPaddingTop(ZCChatMarginVSpace, self.logoView, self.bgView)];
        
        _layoutTitleHeight =sobotLayoutEqualHeight(0, self.labTitle, NSLayoutRelationEqual);
        [self.bgView addConstraint: sobotLayoutPaddingTop(ZCChatMarginVSpace, self.labTitle, self.bgView)];
        [self.bgView addConstraint:sobotLayoutMarginLeft(ZCChatMarginVSpace, self.labTitle, self.logoView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatMarginVSpace, self.labTitle, self.bgView)];
        
        [self.bgView addConstraint: sobotLayoutMarginTop(ZCChatCellItemSpace, self.labDesc, self.labTitle)];
        [self.bgView addConstraint:sobotLayoutMarginLeft(ZCChatMarginVSpace, self.labDesc, self.logoView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatMarginVSpace, self.labDesc, self.bgView)];
        
        [self.bgView addConstraint: sobotLayoutMarginTop(ZCChatPaddingVSpace, self.labTag, self.labDesc)];
        [self.bgView addConstraint:sobotLayoutEqualHeight(30, self.labTag, NSLayoutRelationEqual)];
        [self.bgView addConstraint:sobotLayoutMarginLeft(ZCChatMarginVSpace, self.labTag, self.logoView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatMarginVSpace, self.labTag, self.bgView)];
        _layoutLabelBottom = sobotLayoutPaddingBottom(-ZCChatMarginVSpace, self.labTag, self.bgView);
        _layoutLabelBottom.priority = UILayoutPriorityDefaultLow;
        [self.bgView addConstraint:_layoutLabelBottom];
    }
    return self;
}


-(void)createViews{
    _bgView = ({
        UIView *iv = [[UIView alloc] init];
        [iv setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark1)];
        iv.layer.cornerRadius = 5;
        iv.layer.borderWidth = 1;
        iv.layer.borderColor = [ZCUIKitTools zcgetServerConfigBtnBgColor].CGColor;
        [self.contentView addSubview:iv];
        iv.userInteractionEnabled=YES;
        iv;
    });
    _logoView = ({
        SobotImageView *iv = [[SobotImageView alloc] init];
        iv.layer.masksToBounds = YES;
        iv.contentMode = UIViewContentModeScaleAspectFill;
        iv.layer.cornerRadius = 4.0f;
        //设置点击事件
        iv.userInteractionEnabled=YES;
        [self.bgView addSubview:iv];
        iv;
    });
    
    _labTitle = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
//        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        [iv setTextColor:UIColorFromModeColor(SobotColorTextGoods)];
        iv.numberOfLines = 1;
//        [iv setFont:SobotFontBold14];
        [iv setFont:[ZCUIKitTools  zcgetTitleGoodsFont]];
        [self.bgView addSubview:iv];
        iv.userInteractionEnabled=YES;
        iv;
    });
    
    
    _labDesc = ({
        UILabel *iv = [[UILabel alloc] init];
//        iv.numberOfLines = 0;
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        iv.backgroundColor = UIColor.clearColor;
//        [iv setFont:SobotFont14];
        [iv setFont:[ZCUIKitTools zcgetGoodsDetFont]];
        [self.bgView addSubview:iv];
        iv.userInteractionEnabled=YES;
        iv;
    });
    
    _labTag = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
        iv.backgroundColor = UIColor.clearColor;
//        [iv setTextColor:[ZCUIKitTools zcgetPricetTagTextColor]];
        [iv setTextColor:UIColorFromKitModeColor(SobotColorHeaderText)];
//        iv.numberOfLines = 0;
        [iv setFont:SobotFontBold14];
        [self.bgView addSubview:iv];
        iv.userInteractionEnabled=YES;
        iv;
    });
    
}


-(void)initDataToView:(SobotChatMessage *)message time:(NSString *)showTime{
    [super initDataToView:message time:showTime];
    
    if(self.isRight){
        self.bgView.layer.borderColor = [ZCUIKitTools zcgetRightChatColor].CGColor;
    }else{
        self.bgView.layer.borderColor = [ZCUIKitTools zcgetLeftChatColor].CGColor;
    }
    
    NSString *titleStr = @"";
    NSString *descStr = @"";
    NSString *labelStr = @"";
    NSString *urlStr = @"";
    NSString *link = @"";
 
    if(message.richModel.richContent){
        titleStr = sobotConvertToString(message.richModel.richContent.cardTitle);
        descStr = sobotConvertToString(message.richModel.richContent.descriptionStr);
        labelStr = sobotConvertToString(message.richModel.richContent.label);
        urlStr = sobotConvertToString(message.richModel.richContent.thumbnail);
        link = sobotConvertToString(message.richModel.richContent.url);
    }
    
    if(self.isRight){
        [_labTitle setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        // 不要主题色 橙色
//        [_labTag setTextColor:[ZCUIKitTools zcgetServerConfigBtnBgColor]];//
        [_labDesc setTextColor:UIColorFromModeColor(SobotColorTextSub)];
    }else{
        [_labTitle setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
//        [_labTag setTextColor:[ZCUIKitTools zcgetServerConfigBtnBgColor]];
        [_labDesc setTextColor:UIColorFromModeColor(SobotColorTextSub)];
    }
    
    _labTitle.text = sobotConvertToString(titleStr);
    _labDesc.text = sobotConvertToString(descStr);
    _labTag.text = sobotConvertToString(labelStr);
    if(sobotConvertToString(urlStr).length > 0){
        _layoutImageLeft.constant = ZCChatMarginVSpace;
        _layoutImageWidth.constant = 76;
        [_logoView loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(urlStr)] placeholer:SobotKitGetImage(@"zcicon_default_goods_1")  showActivityIndicatorView:NO];
        _layoutImageBottom.priority = UILayoutPriorityDefaultHigh;
        _layoutLabelBottom.priority = UILayoutPriorityDefaultLow;
    }else{
        _logoView.hidden = YES;
        _layoutImageLeft.constant = 0;
        _layoutImageWidth.constant = 0;
        _layoutImageBottom.priority = UILayoutPriorityDefaultLow;
        _layoutLabelBottom.priority = UILayoutPriorityDefaultHigh;
    }
    
    _jumpUrl = link;
    _layoutBgWidth.constant = self.maxWidth + ZCChatPaddingHSpace*2;
    
    self.bgView.layer.cornerRadius = 4;
    self.bgView.layer.borderColor = [ZCUIKitTools zcgetChatBottomLineColor].CGColor;
    self.bgView.layer.borderWidth = 1.0f;
    self.bgView.layer.masksToBounds = YES;
    
    [self.bgView layoutIfNeeded];
    [self setChatViewBgState:CGSizeMake(self.maxWidth,CGRectGetMaxX(_bgView.frame))];
}

-(void)bgViewClick:(UITapGestureRecognizer *) tap{
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeOpenURL text:sobotConvertToString(_jumpUrl)  obj:sobotConvertToString(_jumpUrl)];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
