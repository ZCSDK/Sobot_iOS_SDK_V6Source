//
//  ZCChatOrderCardCell.m
//  SobotKit
//
//  Created by zhangxy on 2022/9/22.
//

#import "ZCChatOrderCardCell.h"

#import "ZCUICore.h"

@interface ZCChatOrderCardCell(){
    
}

@property(nonatomic,strong) NSLayoutConstraint *layoutBgWidth;

@property(nonatomic,strong) NSLayoutConstraint *layoutTitleHeight;
@property(nonatomic,strong) NSLayoutConstraint *layoutTitleDescHeight;

@property(nonatomic,strong) NSLayoutConstraint *layoutImageHeight;
@property(nonatomic,strong) NSLayoutConstraint *layoutImageWidth;
@property(nonatomic,strong) NSLayoutConstraint *layoutImageLeft;

@property(nonatomic,strong) NSLayoutConstraint *layoutLineTop;

@property (strong, nonatomic) UIView *bgView; //
@property (nonatomic,strong) SobotImageView *logoView;
@property (strong, nonatomic) UILabel *labTitle; //标题
@property (strong, nonatomic) UILabel *labDesc; //标题

@property (strong, nonatomic) UIView *lineView; //标题

@property (strong, nonatomic) UILabel *labStatus; //标题
@property (strong, nonatomic) UILabel *labCode; //标题
@property (strong, nonatomic) UILabel *labTime; //标题

@end

@implementation ZCChatOrderCardCell

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
//        _layoutBgWidth = sobotLayoutEqualWidth(ScreenWidth, self.bgView, NSLayoutRelationEqual);
//        [self.contentView addConstraint:_layoutBgWidth];
        [self.contentView addConstraint:sobotLayoutPaddingTop(0, self.bgView, self.ivBgView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(0, self.bgView, self.ivBgView)];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(0, self.bgView, self.ivBgView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(0, self.bgView, self.ivBgView)];
        
        _layoutImageHeight = sobotLayoutEqualHeight(48, self.logoView, NSLayoutRelationEqual);
        _layoutImageWidth = sobotLayoutEqualWidth(48, self.logoView, NSLayoutRelationEqual);
        _layoutImageLeft = sobotLayoutPaddingLeft(0, self.logoView, self.bgView);
        self.logoView.backgroundColor = UIColor.redColor;
        [self.bgView addConstraint:_layoutImageWidth];
        [self.bgView addConstraint:_layoutImageHeight];
        [self.bgView addConstraint:_layoutImageLeft];
        [self.bgView addConstraint:sobotLayoutPaddingTop(10, self.logoView, self.bgView)];
        
        _layoutTitleHeight =sobotLayoutEqualHeight(0, self.labTitle, NSLayoutRelationEqual);
        [self.bgView addConstraint: sobotLayoutPaddingTop(10, self.labTitle, self.bgView)];
        [self.bgView addConstraint:sobotLayoutMarginLeft(ZCChatCellItemSpace, self.labTitle, self.logoView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.labTitle, self.bgView)];
        
        [self.bgView addConstraint: sobotLayoutMarginTop(ZCChatCellItemSpace, self.labDesc, self.labTitle)];
        [self.bgView addConstraint:sobotLayoutMarginLeft(ZCChatCellItemSpace, self.labDesc, self.logoView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.labDesc, self.bgView)];
        
        _layoutLineTop = sobotLayoutMarginTop(ZCChatCellItemSpace*2, self.lineView, self.logoView);
        [self.bgView addConstraint:_layoutLineTop];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(10, self.lineView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-10, self.lineView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutEqualHeight(1, self.lineView, NSLayoutRelationEqual)];
        
        [self.bgView addConstraint: sobotLayoutMarginTop(ZCChatPaddingVSpace, self.labStatus, self.lineView)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(10, self.labStatus, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.labStatus, self.bgView)];
        
        [self.bgView addConstraint: sobotLayoutMarginTop(ZCChatPaddingVSpace, self.labCode, self.labStatus)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(10, self.labCode, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.labCode, self.bgView)];
        
        [self.bgView addConstraint: sobotLayoutMarginTop(ZCChatCellItemSpace, self.labTime, self.labCode)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(10, self.labTime, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.labTime, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingBottom(-ZCChatPaddingVSpace, self.labTime, self.bgView)];
    }
    return self;
}


-(void)createViews{
    _bgView = ({
        UIView *iv = [[UIView alloc] init];
        [iv setBackgroundColor:UIColorFromKitModeColor(SobotColorWhite)];
        [self.contentView addSubview:iv];
        iv.layer.masksToBounds = YES;
        iv.layer.cornerRadius = 5;
        iv.layer.borderColor = [ZCUIKitTools zcgetRobotBtnBgColor].CGColor;
        iv.layer.borderWidth = 1;
        iv;
    });
    _logoView = ({
        SobotImageView *iv = [[SobotImageView alloc] init];
        iv.layer.masksToBounds = YES;
        iv.layer.cornerRadius = 5;
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
//        iv.numberOfLines = 0;
//        [iv setFont:SobotFontBold14];
        [iv setFont:[ZCUIKitTools  zcgetTitleGoodsFont]];
        [self.bgView addSubview:iv];
        iv;
    });
    
    
    _labDesc = ({
        UILabel *iv = [[UILabel alloc] init];
//        iv.numberOfLines = 0;
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
//        [iv setFont:SobotFont14];
        [iv setFont:[ZCUIKitTools zcgetGoodsDetFont]];
        [self.bgView addSubview:iv];
        iv;
    });
    
    _lineView = ({
        UIView *iv = [[UIView alloc] init];
        [iv setBackgroundColor:UIColorFromKitModeColor(SobotColorBgLine)];
        [self.bgView addSubview:iv];
        iv;
    });
    
    _labStatus = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:UIColorFromModeColor(SobotColorYellow)];
//        iv.numberOfLines = 0;
        [iv setFont:SobotFontBold14];
        [self.bgView addSubview:iv];
        iv;
    });
    
    _labCode = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
//        iv.numberOfLines = 0;
        [iv setFont:SobotFontBold14];
        [self.bgView addSubview:iv];
        iv;
    });
    
    _labTime = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
//        iv.numberOfLines = 0;
        [iv setFont:SobotFontBold14];
        [self.bgView addSubview:iv];
        iv;
    });
    
}



-(void)initDataToView:(SobotChatMessage *)message time:(NSString *)showTime{
    [super initDataToView:message time:showTime];
    NSArray *goods = message.richModel.richContent.goods;
    NSString *goodsDesc = @"";
    _logoView.hidden = YES;
    _layoutImageLeft.constant = ZCChatPaddingVSpace - ZCChatCellItemSpace;
    _layoutImageWidth.constant = 0;
    [self.bgView removeConstraint:_layoutLineTop];
    _layoutLineTop = sobotLayoutMarginTop(ZCChatCellItemSpace, self.lineView, self.labDesc);
    [self.bgView addConstraint:_layoutLineTop];
    if(goods && [goods isKindOfClass:[NSArray class]] && goods.count>0){
        NSDictionary *good = goods[0];
        goodsDesc = good[@"name"];
        if(sobotUrlEncodedString(good[@"pictureUrl"]).length > 0){
            _logoView.hidden = NO;
            _layoutImageLeft.constant = ZCChatPaddingVSpace;
            _layoutImageWidth.constant = 48;
            _layoutImageWidth.constant = 48;
            [self.bgView removeConstraint:_layoutLineTop];
            _layoutLineTop = sobotLayoutMarginTop(ZCChatCellItemSpace, self.lineView, self.logoView);
            [self.bgView addConstraint:_layoutLineTop];
            
            [_logoView loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(good[@"pictureUrl"])] placeholer:SobotKitGetImage(@"zcicon_default_goods")  showActivityIndicatorView:YES];
        }
    }
    
    NSString *orderStatus = [ZCOrderGoodsModel getOrderStatusMsg:[sobotConvertToString(message.richModel.richContent.orderStatus) intValue]];
    if(sobotConvertToString(orderStatus).length == 0 && sobotConvertToString(message.richModel.richContent.statusCustom).length > 0){
        orderStatus = sobotConvertToString(message.richModel.richContent.statusCustom);
    }
    NSString *orderCode = sobotConvertToString(message.richModel.richContent.orderCode);
    NSString *createTime = sobotConvertToString(message.richModel.richContent.createTimeFormat);
//        NSString *orderUrl = sobotConvertToString(dict[@"orderUrl"]);
    NSString *goodsCount = sobotConvertToString(message.richModel.richContent.goodsCount);
    NSString *moneySum = sobotConvertToString(message.richModel.richContent.totalFee);
    if(sobotValidateNumber(moneySum)){
        moneySum = [NSString stringWithFormat:@"%0.2f%@",[sobotConvertToString(message.richModel.richContent.totalFee) floatValue]/100,SobotKitLocalString(@"元")];
    }
    _labTitle.text = goodsDesc;
    if(moneySum.length > 0 || goodsCount.length > 0){
        
        NSString *unitStr = SobotKitLocalString(@"件");
        NSString *goodsStr = SobotKitLocalString(@"商品");
        NSString *totalStr = SobotKitLocalString(@"合计");
        
        if (moneySum.length > 0 && goodsCount.length > 0) {

            [_labDesc setText:[NSString stringWithFormat:@"%@%@%@,%@ %@",goodsCount,unitStr,goodsStr,totalStr,moneySum]];
        }else if (moneySum.length > 0 && goodsCount.length == 0){
            [_labDesc setText:[NSString stringWithFormat:@"%@ %@",totalStr,moneySum]];
        }else if (moneySum.length == 0 && goodsCount.length > 0) {
            [_labDesc setText:[NSString stringWithFormat:@"%@%@%@",goodsCount,unitStr,goodsStr]];
        }
     }else{
         [_labDesc setText:@""];
         
    }

    NSString *orderStr = SobotKitLocalString(@"订单");
    NSString *statusStr = SobotKitLocalString(@"状态");
    NSString *numStr = SobotKitLocalString(@"编号");
    NSString *giveOrderStr = SobotKitLocalString(@"下单");
    NSString *timeStr = SobotKitLocalString(@"时间");
    [_labStatus setText:@""];
    if(sobotConvertToString(orderStatus).length > 0){
        _labStatus.attributedText = [self getOtherColorString:orderStatus Color:UIColorFromModeColor(SobotColorYellow) withString:[NSString stringWithFormat:@"%@%@：%@",orderStr,statusStr,orderStatus]];
    }
    
    [_labCode setText:@""];
    if(orderCode.length > 0 ){
       [_labCode setText:[NSString stringWithFormat:@"%@%@：%@",orderStr,numStr,orderCode]];
    }
    
    [_labTime setText:@""];
    if(createTime.length > 0 ){
       _labTime.hidden = NO;
       [_labTime setText:[NSString stringWithFormat:@"%@%@：%@",giveOrderStr,timeStr,createTime]];
    }

//    _layoutBgWidth.constant = self.maxWidth;
    [self.bgView layoutIfNeeded];
    [self setChatViewBgState:CGSizeMake(self.maxWidth,CGRectGetMaxX(_bgView.frame))];
}

-(NSMutableAttributedString *)getOtherColorString:(NSString *)string Color:(UIColor *)Color withString:(NSString *)originalString
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]init];
    
    NSMutableString *temp = [NSMutableString stringWithString:sobotConvertToString(originalString)];
    str = [[NSMutableAttributedString alloc] initWithString:temp];
    if (string.length) {
        NSRange range = [temp rangeOfString:string];
        [str addAttribute:NSForegroundColorAttributeName value:Color range:range];
        return str;
        
    }
    return str;
    
}
-(void)bgViewClick:(UITapGestureRecognizer *) tap{
    NSString *link = sobotConvertToString(self.tempModel.richModel.richContent.orderUrl);
    if(sobotConvertToString(link).length  == 0){
        return;
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeOpenURL text:sobotConvertToString(link)  obj:sobotConvertToString(link)];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end

