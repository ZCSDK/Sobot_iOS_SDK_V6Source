//
//  ZCChatReferenceGoodCell.m
//  SobotKit
//
//  Created by lizh on 2023/11/22.
//

#import "ZCChatReferenceGoodCell.h"

// 非自定义卡片的 商品卡片
@interface  ZCChatReferenceGoodCell()

@property (strong, nonatomic) UIView *bgView; //
@property (nonatomic,strong) SobotImageView *logoView;
@property (strong, nonatomic) UILabel *labTitle; //标题
@property (strong, nonatomic) UILabel *labDesc; //标题
@property (strong, nonatomic) UILabel *labTag; //标题
@property (nonatomic,copy) NSString *jumpUrl;

@property (strong, nonatomic) UILabel *priceTip;// 商品价格标签

@property(nonatomic,strong) NSLayoutConstraint *layoutBgWidth;
@property(nonatomic,strong) NSLayoutConstraint *layoutTitleHeight;
@property(nonatomic,strong) NSLayoutConstraint *layoutTitleDescHeight;
@property(nonatomic,strong) NSLayoutConstraint *layoutImageHeight;
@property(nonatomic,strong) NSLayoutConstraint *layoutImageWidth;
@property(nonatomic,strong) NSLayoutConstraint *layoutImageLeft;
@property(nonatomic,strong) NSLayoutConstraint *layoutImageBottom;
@property(nonatomic,strong) NSLayoutConstraint *layoutLabelBottom;

@property(nonatomic,strong) NSLayoutConstraint *priceTipEW;
@property(nonatomic,strong) NSLayoutConstraint *priceTipML;
@property(nonatomic,strong) NSLayoutConstraint *labTagML;

@end

@implementation ZCChatReferenceGoodCell

-(void)layoutSubViewUI{
    [super layoutSubViewUI];
    // 移除viewcontent的所有子view
    [self.viewContent.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _bgView = ({
        UIView *iv = [[UIView alloc] init];
        [iv setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark1)];
        iv.layer.cornerRadius = 5;
//        iv.layer.borderWidth = 1;
//        iv.layer.borderColor = [ZCUIKitTools zcgetServerConfigBtnBgColor].CGColor;
        [self.viewContent addSubview:iv];
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
        [iv setTextColor:UIColorFromModeColor(SobotColorTextGoods)];
        iv.numberOfLines = 1;
        iv.lineBreakMode = 4;
        [iv setFont:[UIFont systemFontOfSize:9]];
        [self.bgView addSubview:iv];
        iv;
    });
    
    _labDesc = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        iv.backgroundColor = UIColor.clearColor;
        iv.numberOfLines = 1;
        iv.lineBreakMode = 4;
        [iv setFont:[UIFont systemFontOfSize:8]];
        [self.bgView addSubview:iv];
        iv;
    });
    
    _priceTip = ({
        UILabel *iv = [[UILabel alloc]init];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setFont:[UIFont systemFontOfSize:6]];
        [iv setTextColor:[ZCUIKitTools zcgetPricetTagTextColor]];
        [self.bgView addSubview:iv];
        iv.hidden = YES;
        iv;
    });
    
    _labTag = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
        iv.backgroundColor = UIColor.clearColor;
        [iv setTextColor:[ZCUIKitTools zcgetPricetTagTextColor]];
        [iv setFont:[UIFont systemFontOfSize:10]];
        iv.numberOfLines = 1;
        iv.lineBreakMode = 4;
        [self.bgView addSubview:iv];
        iv;
    });
    
    _layoutBgWidth = sobotLayoutEqualWidth(1, self.bgView, NSLayoutRelationEqual);
    [self.viewContent addConstraint:_layoutBgWidth];
    [self.viewContent addConstraint:sobotLayoutPaddingTop(0, self.bgView, self.viewContent)];
    [self.viewContent addConstraint:sobotLayoutPaddingLeft(0, self.bgView, self.viewContent)];
    [self.viewContent addConstraint:sobotLayoutPaddingBottom(0, self.bgView, self.viewContent)];
    
    _layoutTitleHeight =sobotLayoutEqualHeight(0, self.labTitle, NSLayoutRelationEqual);
    [self.bgView addConstraint: sobotLayoutPaddingTop(10, self.labTitle, self.bgView)];
    [self.bgView addConstraint:sobotLayoutPaddingLeft(11, self.labTitle, self.bgView)];
    [self.bgView addConstraint:sobotLayoutPaddingRight(-10, self.labTitle, self.bgView)];
    
    
    _layoutImageHeight = sobotLayoutEqualHeight(49, self.logoView, NSLayoutRelationEqual);
    _layoutImageWidth = sobotLayoutEqualWidth(49, self.logoView, NSLayoutRelationEqual);
    _layoutImageLeft = sobotLayoutPaddingLeft(8, self.logoView, self.bgView);
    [self.bgView addConstraint:_layoutImageWidth];
    [self.bgView addConstraint:_layoutImageHeight];
    [self.bgView addConstraint:_layoutImageLeft];
    [self.bgView addConstraint:sobotLayoutMarginTop(11, self.logoView, self.labTitle)];
    _layoutImageBottom = sobotLayoutPaddingBottom(-8, self.logoView, self.bgView);
    _layoutImageBottom.priority = UILayoutPriorityDefaultHigh;
    [self.bgView addConstraint:_layoutImageBottom];
        
    [self.bgView addConstraint: sobotLayoutMarginTop(8, self.labDesc, self.labTitle)];
    [self.bgView addConstraint:sobotLayoutMarginLeft(11, self.labDesc, self.logoView)];
    [self.bgView addConstraint:sobotLayoutPaddingRight(-10, self.labDesc, self.bgView)];
    
    self.priceTipEW = sobotLayoutEqualWidth(12, self.priceTip, NSLayoutRelationEqual);
    [self.bgView addConstraint:sobotLayoutEqualHeight(12, self.priceTip, NSLayoutRelationEqual)];
    [self.bgView addConstraint:self.priceTipEW];
    [self.bgView addConstraint:sobotLayoutPaddingBottom(-1, self.priceTip, self.labTag)];
    self.priceTipML = sobotLayoutMarginLeft(8,self.priceTip,self.logoView);
    [self.bgView addConstraint:self.priceTipML];
    
    [self.bgView addConstraint: sobotLayoutMarginTop(10, self.labTag, self.labDesc)];
    [self.bgView addConstraint:sobotLayoutEqualHeight(30, self.labTag, NSLayoutRelationEqual)];
    self.labTagML = sobotLayoutMarginLeft(8, self.labTag, self.priceTip);
    [self.bgView addConstraint:self.labTagML];
    [self.bgView addConstraint:sobotLayoutPaddingRight(-10, self.labTag, self.bgView)];
    _layoutLabelBottom = sobotLayoutPaddingBottom(-12, self.labTag, self.bgView);
    _layoutLabelBottom.priority = UILayoutPriorityDefaultLow;
    [self.bgView addConstraint:_layoutLabelBottom];
    
    //设置点击事件
    UITapGestureRecognizer *tapGesturer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bgViewClick:)];
    self.bgView.userInteractionEnabled=YES;
    [self.bgView addGestureRecognizer:tapGesturer];
    
}
-(void)dataToView:(SobotChatMessage *)message{
    [super dataToView:message];

    self.priceTipEW.constant = 0;
    self.priceTipML.constant = 0;
    self.priceTip.hidden = YES;
    self.labTagML.constant = 11;
    // 普通的商品卡片
    //    if(message.sendType == 0){
    //        self.bgView.layer.borderColor = [ZCUIKitTools zcgetRightChatColor].CGColor;
    //    }else{
    //        self.bgView.layer.borderColor = [ZCUIKitTools zcgetLeftChatColor].CGColor;
    //    }
    
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
    
    if(message.sendType == 0){
        [_labTitle setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        [_labTag setTextColor:[ZCUIKitTools zcgetServerConfigBtnBgColor]];
        [_labDesc setTextColor:UIColorFromModeColor(SobotColorTextSub)];
    }else{
        [_labTitle setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        [_labTag setTextColor:[ZCUIKitTools zcgetServerConfigBtnBgColor]];
        [_labDesc setTextColor:UIColorFromModeColor(SobotColorTextSub)];
    }
    
    _labTitle.text = sobotConvertToString(titleStr);
    _labDesc.text = sobotConvertToString(descStr);
    _labTag.text = sobotConvertToString(labelStr);
    
    if(sobotConvertToString(urlStr).length > 0){
        _layoutImageLeft.constant = 8;
        _layoutImageWidth.constant = 49;
        _layoutImageWidth.constant = 49;
        [_logoView loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(urlStr)] placeholer:SobotKitGetImage(@"zcicon_default_goods_1")  showActivityIndicatorView:NO];
        _layoutImageBottom.priority = UILayoutPriorityDefaultHigh;
        _layoutLabelBottom.priority = UILayoutPriorityDefaultLow;
    }else{
        _logoView.hidden = YES;
        _layoutImageLeft.constant = 0;
        _layoutImageWidth.constant = 0;
        _layoutImageWidth.constant = 0;
        _layoutImageBottom.priority = UILayoutPriorityDefaultLow;
        _layoutLabelBottom.priority = UILayoutPriorityDefaultHigh;
    }
    
    _jumpUrl = link;
        
    _layoutBgWidth.constant = 182;
    
    [self showContent:@"" view:_bgView btm:nil isMaxWidth:NO customViewWidth:_layoutBgWidth.constant];
}

-(void)bgViewClick:(UITapGestureRecognizer *) tap{
    [self viewEvent:ZCChatReferenceCellEventOpenURL state:0 obj:sobotConvertToString(_jumpUrl)];
}

@end
