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
@property(nonatomic,strong) NSLayoutConstraint *layoutItemEH;

@property (strong, nonatomic) UIView *bgView; //
@property (strong, nonatomic) UIView *guideView; //
@property (nonatomic,strong) SobotImageView *logoView;
@property (strong, nonatomic) UILabel *labTitle; //标题
@property (strong, nonatomic) UILabel *labDesc; //标题

@property (strong, nonatomic) UILabel *labStatus; //标题
@property (strong,nonatomic) UILabel *labStatusValue;// 状态的值
@property (strong, nonatomic) UILabel *labCode; //标题
@property (strong, nonatomic) UILabel *labTime; //标题

@property (strong,nonatomic) UIView *customView;// 自定义字段

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
        _layoutBgWidth = sobotLayoutEqualWidth(ScreenWidth, self.bgView, NSLayoutRelationEqual);
        [self.contentView addConstraint:_layoutBgWidth];
        [self.contentView addConstraint:sobotLayoutPaddingTop(0, self.bgView, self.ivBgView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(0, self.bgView, self.ivBgView)];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(0, self.bgView, self.ivBgView)];
//        [self.contentView addConstraint:sobotLayoutPaddingRight(0, self.bgView, self.ivBgView)];
        
        // 顶部控件 上左右都是12px
        // UI图需要加两个PX,设置最小高度
        [self.bgView addConstraint:sobotLayoutPaddingTop(ZCChatPaddingVSpace, self.guideView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingVSpace, self.guideView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatPaddingVSpace, self.guideView, self.bgView)];
        
        _layoutImageWidth = sobotLayoutEqualWidth(52, self.logoView, NSLayoutRelationEqual);
        [self.guideView addConstraint:_layoutImageWidth];
        [self.guideView addConstraint:sobotLayoutEqualHeight(52, self.logoView, NSLayoutRelationEqual)];
        [self.guideView addConstraint:sobotLayoutPaddingTop(ZCChatItemSpace8, self.logoView, self.guideView)];
        [self.guideView addConstraint:sobotLayoutPaddingLeft(ZCChatItemSpace8, self.logoView, self.guideView)];
        
        [self.guideView addConstraint: sobotLayoutPaddingTop(ZCChatItemSpace8, self.labTitle, self.guideView)];
        [self.guideView addConstraint:sobotLayoutMarginLeft(ZCChatPaddingVSpace, self.labTitle, self.logoView)];
        [self.guideView addConstraint:sobotLayoutPaddingRight(-ZCChatItemSpace8, self.labTitle, self.guideView)];
        [self.guideView addConstraint:sobotLayoutEqualHeight(22, self.labTitle,NSLayoutRelationEqual)];
        
        [self.guideView addConstraint:sobotLayoutMarginTop(10, self.labDesc, self.labTitle)];
        [self.guideView addConstraint:sobotLayoutMarginLeft(ZCChatPaddingVSpace, self.labDesc, self.logoView)];
        [self.guideView addConstraint:sobotLayoutPaddingRight(-ZCChatItemSpace8, self.labDesc, self.guideView)];
        [self.guideView addConstraint:sobotLayoutEqualHeight(20, self.labDesc,NSLayoutRelationGreaterThanOrEqual)];
        [self.guideView addConstraint:sobotLayoutPaddingBottom(-ZCChatItemSpace8, self.labDesc, self.guideView)];
        
        
        _layoutLineTop = sobotLayoutMarginTop(ZCChatPaddingVSpace, self.labStatus, self.guideView);
        [self.bgView addConstraint:_layoutLineTop];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(ZCChatMarginVSpace, self.labStatus, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.labStatus, self.bgView)];
        
        [self.bgView addConstraint: sobotLayoutMarginTop(ZCChatCellItemSpace, self.labCode, self.labStatus)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(ZCChatMarginVSpace, self.labCode, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.labCode, self.bgView)];
        
        [self.bgView addConstraint: sobotLayoutMarginTop(ZCChatCellItemSpace, self.labTime, self.labCode)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(ZCChatMarginVSpace, self.labTime, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.labTime, self.bgView)];
//        [self.bgView addConstraint:sobotLayoutPaddingBottom(-ZCChatPaddingVSpace, self.labTime, self.bgView)];
        
        [self.bgView addConstraint:sobotLayoutMarginTop(ZCChatMarginVSpace, self.customView, self.labTime)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(0, self.customView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.customView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingBottom(0, self.customView, self.bgView)];
    }
    return self;
}


-(void)createViews{
    _bgView = ({
        UIView *iv = [[UIView alloc] init];
        [iv setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark1)];
        [self.contentView addSubview:iv];
        iv.layer.masksToBounds = YES;
        iv.layer.cornerRadius = 5;
//        iv.layer.borderColor = [ZCUIKitTools zcgetServerConfigBtnBgColor].CGColor;
        iv.layer.borderWidth = 1;
        iv;
    });
    
    _guideView = ({
        UIView *iv = [[UIView alloc] init];
        [iv setBackgroundColor:UIColorFromKitModeColor(SobotColorBgSub2Dark3)];
        [self.bgView addSubview:iv];
        iv.layer.masksToBounds = YES;
        iv.layer.cornerRadius = 5;
//        iv.layer.borderColor = [ZCUIKitTools zcgetServerConfigBtnBgColor].CGColor;
//        iv.layer.borderWidth = 1;
        iv;
    });
    
    
    _logoView = ({
        SobotImageView *iv = [[SobotImageView alloc] init];
        iv.layer.masksToBounds = YES;
        iv.layer.cornerRadius = 5;
        iv.contentMode = UIViewContentModeScaleAspectFill;
        //设置点击事件
        iv.userInteractionEnabled=YES;
        [self.guideView addSubview:iv];
        iv;
    });
    
    _labTitle = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
//        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        [iv setTextColor:UIColorFromKitModeColor(SobotColorTextGoods)];
//        iv.numberOfLines = 0;
        [iv setFont:SobotFontBold14];
//        [iv setFont:[ZCUIKitTools  zcgetTitleGoodsFont]];
        [self.guideView addSubview:iv];
        iv;
    });
    
    
    _labDesc = ({
        UILabel *iv = [[UILabel alloc] init];
//        iv.numberOfLines = 0;
        [iv setTextAlignment:NSTextAlignmentLeft];
//        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        [iv setTextColor:UIColorFromKitModeColor(SobotColorTextSub)];
        [iv setFont:[ZCUIKitTools zcgetGoodsDetFont]];
        [self.guideView addSubview:iv];
        iv;
    });
    
    _labStatus = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:UIColorFromModeColor(SobotColorTextGoods)];
//        iv.numberOfLines = 0;
        [iv setFont:SobotFont14];
        [self.bgView addSubview:iv];
        iv;
    });
    
    _labCode = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
//        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        [iv setTextColor:UIColorFromModeColor(SobotColorTextGoods)];
        [iv setFont:SobotFont14];
        [self.bgView addSubview:iv];
        iv;
    });
    
    _labTime = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
//        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        [iv setTextColor:UIColorFromModeColor(SobotColorTextGoods)];
        [iv setFont:SobotFont14];
        [self.bgView addSubview:iv];
        iv;
    });
    
    _customView = ({
        UIView *iv = [[UIView alloc] init];
        iv.backgroundColor = [UIColor clearColor];
        [self.bgView addSubview:iv];
//        _customView.backgroundColor = [UIColor redColor];
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
    
    NSArray *goods = message.richModel.richContent.goods;
    NSString *goodsDesc = @"";
    _logoView.hidden = YES;
    _layoutImageLeft.constant = 0;
    _layoutImageWidth.constant = 0;
    [self.bgView removeConstraint:_layoutLineTop];
    [self.bgView addConstraint:_layoutLineTop];
    if(goods && [goods isKindOfClass:[NSArray class]] && goods.count>0){
        NSDictionary *good = goods[0];
        goodsDesc = good[@"name"];
        if(sobotUrlEncodedString(good[@"pictureUrl"]).length > 0){
            _logoView.hidden = NO;
            _layoutImageLeft.constant = ZCChatPaddingVSpace;
            _layoutImageWidth.constant = 52;
            
            [_logoView loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(good[@"pictureUrl"])] placeholer:SobotKitGetImage(@"zcicon_default_goods")  showActivityIndicatorView:NO];
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
        _labStatus.attributedText = [self getOtherColorString:orderStatus Color:UIColorFromModeColor(SobotColorHeaderText) withString:[NSString stringWithFormat:@"%@%@：%@",orderStr,statusStr,orderStatus]];
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
   
    #pragma mark - 403 新增自定义字段和查看详情
    [_customView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_bgView removeConstraint:self.layoutItemEH]; // 先移除掉高度的约束，高度是动态添加的
    
    UIView *lastView;
    UIView *btnlineView = [[UIView alloc]init];
    // && ([self.tempModel.richModel.richContent.extendFields isKindOfClass:[NSArray class]]  && self.tempModel.richModel.richContent.extendFields.count > 0)
    if (sobotConvertToString(self.tempModel.richModel.richContent.orderUrl).length > 0 ) {
        if (sobotConvertToString(self.tempModel.richModel.richContent.orderUrl).length > 0) {
            UIButton *lookBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [lookBtn setTitle:SobotKitLocalString(@"查看详情") forState:UIControlStateNormal];
            [lookBtn setTitleColor:[ZCUIKitTools zcgetServerConfigBtnBgColor] forState:UIControlStateNormal];
            lookBtn.titleLabel.font = SobotFont14;
            [lookBtn addTarget:self action:@selector(lookAction:) forControlEvents:UIControlEventTouchUpInside];
            [_customView addSubview:lookBtn];
            [_customView addConstraint:sobotLayoutPaddingBottom(0, lookBtn, _customView)];
            [_customView addConstraint:sobotLayoutPaddingRight(0, lookBtn, _customView)];
            [_customView addConstraint:sobotLayoutPaddingLeft(0, lookBtn, _customView)];
            [_customView addConstraint:sobotLayoutEqualHeight(40, lookBtn, NSLayoutRelationEqual)];
            
            btnlineView.backgroundColor = UIColorFromKitModeColor(SobotColorBgLine);
            [_customView addSubview:btnlineView];
            [_customView addConstraint:sobotLayoutMarginBottom(0, btnlineView, lookBtn)];
            [_customView addConstraint:sobotLayoutPaddingLeft(ZCChatMarginVSpace, btnlineView, _customView)];
            [_customView addConstraint:sobotLayoutPaddingRight(-ZCChatMarginVSpace, btnlineView, _customView)];
            [_customView addConstraint:sobotLayoutEqualHeight(1, btnlineView, NSLayoutRelationEqual)];
            
            lastView = btnlineView;
        }
    }
        
    if ([self.tempModel.richModel.richContent.extendFields isKindOfClass:[NSArray class]]  && self.tempModel.richModel.richContent.extendFields.count > 0) {
        UILabel *lastLab;
        for (int i = 0; i<self.tempModel.richModel.richContent.extendFields.count ; i++) {
            NSDictionary *item = self.tempModel.richModel.richContent.extendFields[i];
            if ([item isKindOfClass:[NSDictionary class]] && !sobotIsNull(item)) {
                NSString *tipStr = sobotConvertToString([item objectForKey:@"fieldName"]);
                NSString *tipValue = sobotConvertToString([item objectForKey:@"fieldValue"]);
                UILabel *tipLab = [[UILabel alloc]init];
                tipLab.text = [[NSString alloc]initWithFormat:@"%@: %@",tipStr,tipValue];
                tipLab.textColor = [ZCUIKitTools zcgetLeftChatTextColor];
                tipLab.numberOfLines = 0;
                [tipLab setFont:SobotFontBold14];
                [_customView addSubview:tipLab];
                if (!sobotIsNull(lastLab)) {
                    [_customView addConstraint:sobotLayoutMarginTop(ZCChatItemSpace8, tipLab, lastLab)];
                }else{
                    [_customView addConstraint:sobotLayoutPaddingTop(0, tipLab, _customView)];
                }
                [_customView addConstraint:sobotLayoutEqualHeight(20, tipLab, NSLayoutRelationGreaterThanOrEqual)];
                [_customView addConstraint:sobotLayoutPaddingLeft(ZCChatMarginVSpace, tipLab, _customView)];
                [_customView addConstraint:sobotLayoutPaddingRight(-ZCChatMarginVSpace, tipLab, _customView)];
                lastLab = tipLab;
                if (i == self.tempModel.richModel.richContent.extendFields.count -1) {
                    // 最后一个  计算最底部的约束
                    if (!sobotIsNull(lastView)) {
                        // 有查看详情，并且有自定义字段
//                        [_customView addConstraint:sobotLayoutMarginTop(ZCChatPaddingVSpace,btnlineView,lastLab)];
                        [_customView addConstraint:sobotLayoutPaddingBottom(-ZCChatPaddingVSpace,tipLab,btnlineView)];
                    }else{
                        // 没有查看详情
                        [_customView addConstraint:sobotLayoutPaddingBottom(-ZCChatPaddingVSpace, tipLab, _customView)];
                    }
                }
            }
        }
    }else{
        // 没有自定义字段
        if (!sobotIsNull(lastView)) {
            // 有查看详情 没有自定义字段
//            [_bgView addConstraint:sobotLayoutEqualHeight(41, _customView, NSLayoutRelationEqual)];
            self.layoutItemEH = sobotLayoutEqualHeight(41, _customView, NSLayoutRelationEqual);
            [_bgView addConstraint:self.layoutItemEH];

        }else{
            // 没有查看详情 没有自定义字段
//            [_bgView addConstraint:sobotLayoutEqualHeight(0, _customView, NSLayoutRelationEqual)];
            self.layoutItemEH = sobotLayoutEqualHeight(0, _customView, NSLayoutRelationEqual);
            [_bgView addConstraint:self.layoutItemEH];

        }
    }
    [_customView setNeedsUpdateConstraints];
    _layoutBgWidth.constant = self.maxWidth + ZCChatPaddingHSpace*2;
    
    
    self.bgView.layer.cornerRadius = 4;
    self.bgView.layer.borderColor = [ZCUIKitTools zcgetChatBottomLineColor].CGColor;
    self.bgView.layer.borderWidth = 1.0f;
    self.bgView.layer.masksToBounds = YES;
    
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

-(void)lookAction:(UIButton*)sender{
    NSString *link = sobotConvertToString(self.tempModel.richModel.richContent.orderUrl);
    if(sobotConvertToString(link).length  == 0){
        return;
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeOpenURL text:sobotConvertToString(link)  obj:sobotConvertToString(link)];
    }
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

