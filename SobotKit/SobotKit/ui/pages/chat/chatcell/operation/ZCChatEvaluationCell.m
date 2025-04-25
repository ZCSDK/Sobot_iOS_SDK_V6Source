//
//  ZCChatEvaluationCell.m
//  SobotKit
//
//  Created by zhangxy on 2022/9/23.
//

#import "ZCChatEvaluationCell.h"
#import "SobotSatisfactionItemView.h"
//#import "ZCUIRatingView.h"
#import "SobotRatingView.h"
#import "ZCShadowBorderView.h"

#define ZCChatTopSpace24 24
#define ZCChatTopSpace8 8

@interface ZCChatEvaluationCell()<SobotRatingViewDelegate>{
    // 0五星   1是0星
    int defaultStar;
    
    // 是否解决按钮显示了多行
    BOOL isMulResolveBtn;
}

@property(nonatomic,strong) ZCLibSatisfaction *satisfaction;
@property(nonatomic,assign) int rating;


// 标题
@property (strong, nonatomic) UILabel *labTitle; //标题

// 内容背景
@property (strong, nonatomic) UIView *bgView; //
@property (strong, nonatomic) NSLayoutConstraint *layoutMaxW;

@property(nonatomic,strong) NSLayoutConstraint *layoutResolveTipTop;
@property (strong, nonatomic) UILabel *labTips;

// 已解决
@property(nonatomic,strong) NSLayoutConstraint *layoutResolveTop;
@property (strong, nonatomic) SobotButton *btnResolved;
// 未解决
@property (strong, nonatomic) SobotButton *btnUnResolved;
@property(nonatomic,strong) NSLayoutConstraint *layoutResolveHeight;
@property(nonatomic,strong) NSLayoutConstraint *layoutUnResolvedEH;
@property(nonatomic,strong) NSLayoutConstraint *layoutUnResolvedTop;

@property(nonatomic,strong) NSLayoutConstraint *layoutLineTop;
@property (strong, nonatomic) UIView *lineView;

@property (strong, nonatomic) SobotRatingView *ratingView; //星标或分数
@property(nonatomic,strong) NSLayoutConstraint *layoutStartTipsTop;
@property (strong, nonatomic) UILabel *labStarTips; //标题

@property(nonatomic,strong) NSLayoutConstraint *layoutItemTipsT;
@property (strong, nonatomic) UILabel *labItemTips; //标题

@property(nonatomic,strong) NSLayoutConstraint *layoutStarItemsTop;
@property (strong, nonatomic) SobotSatisfactionItemView *itemStarViews; //星标或分数

@property (strong, nonatomic) SobotButton *btnSend;
@property(nonatomic,strong) NSLayoutConstraint *layoutSendHeight;
@property(nonatomic,strong) NSLayoutConstraint *layoutSendTop;

@end

@implementation ZCChatEvaluationCell

-(void)createViews{
    _bgView = ({
        ZCShadowBorderView *iv = [[ZCShadowBorderView alloc] init];
//        [iv setBackgroundColor:[ZCUIKitTools zcgetLightGrayDarkBackgroundColor]];
        iv.backgroundColor = UIColorFromModeColor(SobotColorBgMainDark2);
        [self.contentView addSubview:iv];
        
        // 最大500居中处理
        _layoutMaxW = sobotLayoutEqualWidth(ScreenWidth - ZCChatMarginHSpace*2, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:_layoutMaxW];
        [self.contentView addConstraint:sobotLayoutEqualCenterX(0, iv, self.contentView)];
        
        [self.contentView addConstraint:sobotLayoutPaddingTop(ZCChatMarginVSpace, iv, self.contentView)];
//        [self.contentView addConstraint:sobotLayoutPaddingLeft(ZCChatMarginHSpace, iv, self.contentView)];
//        [self.contentView addConstraint:sobotLayoutPaddingRight(-ZCChatMarginHSpace, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(-ZCChatMarginVSpace, iv, self.contentView)];
        iv;
    });
    
    
    _labTitle = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentCenter];
        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        iv.numberOfLines = 0;
        [iv setFont:SobotFontBold16];
        [self.bgView addSubview:iv];
        
        
        [self.bgView addConstraint: sobotLayoutPaddingTop(20+3, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(ZCChatMarginHSpace, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutEqualHeight(22, iv, NSLayoutRelationGreaterThanOrEqual)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatMarginHSpace, iv, self.bgView)];
        iv;
    });
    
    _labTips = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentCenter];
        [iv setTextColor:UIColorFromModeColor(SobotColorTextSub1)];
        iv.numberOfLines = 0;
        [iv setFont:SobotFont14];
        [self.bgView addSubview:iv];
        
        _layoutResolveTipTop = sobotLayoutMarginTop(ZCChatMarginHSpace, iv, self.labTitle);
        [self.bgView addConstraint:_layoutResolveTipTop];
//        [self.bgView addConstraint:sobotLayoutEqualHeight(22, iv, NSLayoutRelationGreaterThanOrEqual)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(ZCChatMarginHSpace, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatMarginHSpace, iv, self.bgView)];
        iv;
    });
    
    CGFloat resolveW1 = [SobotUITools getWidthContain:SobotKitLocalString(@"已解决") font:SobotFont14 Height:24] + 30;
    if(resolveW1 < 97){
        resolveW1 = 97;
    }
    CGFloat resolveW2 = [SobotUITools getWidthContain:SobotKitLocalString(@"未解决") font:SobotFont14 Height:24] + 30;
    if(resolveW2 < 97){
        resolveW2 = 97;
    }
    if(resolveW1 < resolveW2){
        resolveW1 = resolveW2;
    }
    if(resolveW1 > (ScreenWidth - 90)/2){
        isMulResolveBtn = YES;
    }else{
        isMulResolveBtn = NO;
    }
    
    
    
    _btnResolved = ({
        SobotButton *iv = [SobotButton buttonWithType:UIButtonTypeCustom];
        [iv.titleLabel setFont:SobotFont14];
        [iv setTitle:SobotKitLocalString(@"已解决") forState:UIControlStateNormal];
        [iv setImage:SobotKitGetImage(@"zcicon_useful_nol_new") forState:UIControlStateNormal];
        [iv setImage:SobotKitGetImage(@"zcicon_useful_sel") forState:UIControlStateSelected];
        [iv setImage:SobotKitGetImage(@"zcicon_useful_sel") forState:UIControlStateHighlighted];
        iv.tag = 1;
        
        iv.layer.cornerRadius = 4.0f;
        iv.layer.borderColor = UIColorFromKitModeColor(SobotColorBorderLine).CGColor;
        iv.layer.borderWidth = 1.0f;
        [iv setTitleColor:[ZCUIKitTools zcgetNoSatisfactionTextColor] forState:UIControlStateNormal];
        [iv setTitleColor:[ZCUIKitTools zcgetSatisfactionTextSelectedColor] forState:UIControlStateHighlighted];
        [iv setTitleColor:[ZCUIKitTools zcgetSatisfactionTextSelectedColor]  forState:UIControlStateSelected];
        [iv setBackgroundColor:[ZCUIKitTools zcgetSatisfactionBgSelectedColor]];
//        if([SobotUITools getSobotThemeMode] != SobotThemeMode_Dark){
//            iv.layer.shadowOpacity= 1;
//            iv.layer.shadowColor = UIColorFromModeColorAlpha(SobotColorTextMain, 0.15).CGColor;
//            iv.layer.shadowOffset = CGSizeZero;//投影偏移
//            iv.layer.shadowRadius = 2;
//        }
        [iv setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 8)];
        [iv addTarget:self action:@selector(robotServerButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgView addSubview:iv];
        
        _layoutResolveTop = sobotLayoutMarginTop(ZCChatMarginHSpace, iv, self.labTips);
        
        [self.bgView addConstraint:sobotLayoutEqualWidth(resolveW1, iv, NSLayoutRelationGreaterThanOrEqual)];
       _layoutResolveHeight = sobotLayoutEqualHeight(36, iv, NSLayoutRelationEqual);
        [self.bgView addConstraint:_layoutResolveHeight];
        [self.bgView addConstraint:_layoutResolveTop];
        if(isMulResolveBtn){
//            [self.bgView addConstraint:sobotLayoutPaddingLeft(ZCChatMarginHSpace, iv, self.bgView)];
            [self.bgView addConstraint:sobotLayoutEqualCenterX(0, iv, self.bgView)];
        }else{
            [self.bgView addConstraint:sobotLayoutPaddingLeft((ScreenWidth - 40 - resolveW1 - resolveW1 - 20)/2, iv, self.bgView)];
        }
        
        iv.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
        iv;
    });
    _btnUnResolved = ({
        SobotButton *iv = [SobotButton buttonWithType:UIButtonTypeCustom];
        [iv.titleLabel setFont:SobotFont14];
        [iv setTitle:SobotKitLocalString(@"未解决") forState:UIControlStateNormal];
        [iv setImage:SobotKitGetImage(@"zcicon_useless_nol_new") forState:UIControlStateNormal];
        [iv setImage:SobotKitGetImage(@"zcicon_useless_sel") forState:UIControlStateSelected];
        [iv setImage:SobotKitGetImage(@"zcicon_useless_sel") forState:UIControlStateHighlighted];
        iv.tag = 2;
        
        iv.layer.cornerRadius = 4.0f;
        iv.layer.borderColor = UIColorFromKitModeColor(SobotColorBorderLine).CGColor;
        iv.layer.borderWidth = 1.0f;
        [iv setTitleColor:[ZCUIKitTools zcgetNoSatisfactionTextColor] forState:UIControlStateNormal];
        [iv setTitleColor:[ZCUIKitTools zcgetSatisfactionTextSelectedColor] forState:UIControlStateHighlighted];
        [iv setTitleColor:[ZCUIKitTools zcgetSatisfactionTextSelectedColor]  forState:UIControlStateSelected];
        [iv setBackgroundColor:[ZCUIKitTools zcgetSatisfactionBgSelectedColor]];
//        if([SobotUITools getSobotThemeMode] != SobotThemeMode_Dark){
//            iv.layer.shadowOpacity= 1;
//            iv.layer.shadowColor = UIColorFromModeColorAlpha(SobotColorTextMain, 0.15).CGColor;
//            iv.layer.shadowOffset = CGSizeZero;//投影偏移
//            iv.layer.shadowRadius = 2;
//        }
        [iv setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
        [iv addTarget:self action:@selector(robotServerButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgView addSubview:iv];
        
        [self.bgView addConstraint:sobotLayoutEqualWidth(resolveW1, iv, NSLayoutRelationGreaterThanOrEqual)];
        self.layoutUnResolvedEH = sobotLayoutEqualHeight(36, iv, NSLayoutRelationEqual);
        [self.bgView addConstraint:self.layoutUnResolvedEH];
        if(isMulResolveBtn){
            _layoutUnResolvedTop = sobotLayoutMarginTop(ZCChatMarginHSpace, iv, self.btnResolved);
            [self.bgView addConstraint:_layoutUnResolvedTop];
//            [self.bgView addConstraint:sobotLayoutMarginLeft(ZCChatMarginHSpace, iv, self.bgView)];
            [self.bgView addConstraint:sobotLayoutEqualCenterX(0, iv, self.bgView)];
        }else{
            _layoutUnResolvedTop = sobotLayoutPaddingTop(0, iv, self.btnResolved);
            [self.bgView addConstraint:_layoutUnResolvedTop];
            [self.bgView addConstraint:sobotLayoutMarginLeft(ZCChatMarginHSpace, iv, self.btnResolved)];
        }
        iv.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
        iv;
    });
    
    _lineView = ({
        UIView *iv = [[UIView alloc] init];
        [iv setBackgroundColor:[ZCUIKitTools zcgetLineRichColor]];
        [self.bgView addSubview:iv];
        _layoutLineTop = sobotLayoutMarginTop(ZCChatTopSpace24, iv, self.btnUnResolved);
        [self.bgView addConstraint:_layoutLineTop];
        [self.bgView addConstraint:sobotLayoutEqualHeight(1, iv, NSLayoutRelationEqual)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(ZCChatMarginHSpace, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatMarginHSpace, iv, self.bgView)];
        iv;
    });
    
    _ratingView = ({
        SobotRatingView *iv = [[SobotRatingView alloc] init];
//        iv.backgroundColor = UIColor.redColor;
        [self.bgView addSubview:iv];
        [self.bgView addConstraint:sobotLayoutMarginTop(24, iv, self.lineView)];
//        [self.contentView addConstraint:sobotLayoutEqualCenterX(0, iv, self.contentView)];
//        [self.contentView addConstraint:sobotLayoutEqualWidth(292, iv, NSLayoutRelationEqual)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(26, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-26, iv, self.bgView)];
        iv;
    });
    _labStarTips = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentCenter];
        [iv setTextColor:[ZCUIKitTools zcgetTextPlaceHolderColor]];
        iv.numberOfLines = 0;
        [iv setFont:SobotFont14];
        [self.bgView addSubview:iv];
        _layoutStartTipsTop = sobotLayoutMarginTop(ZCChatMarginHSpace, iv, self.ratingView);
        [self.bgView addConstraint:_layoutStartTipsTop];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(ZCChatMarginHSpace, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatMarginHSpace, iv, self.bgView)];
        iv;
    });
    _labItemTips = ({
        UILabel *iv = [[UILabel alloc] init];
//        [iv setTextColor:UIColorFromModeColor(SobotColorTextSub1)];
        [iv setTextColor:UIColorFromModeColor(SobotColorTextMain)];
        iv.numberOfLines = 0;
        [iv setFont:SobotFont14];
        [self.bgView addSubview:iv];
        
        _layoutItemTipsT = sobotLayoutMarginTop(ZCChatTopSpace24, iv, self.labStarTips);
        [self.bgView addConstraint:_layoutItemTipsT];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(ZCChatMarginHSpace, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatMarginHSpace, iv, self.bgView)];
        
        iv;
    });
    // 这里是item 标签的数据展示view
    _itemStarViews = ({
        SobotSatisfactionItemView *iv = [[SobotSatisfactionItemView alloc] init];
        [self.bgView addSubview:iv];
        _layoutStarItemsTop = sobotLayoutMarginTop(ZCChatTopSpace8, iv, self.labItemTips);
        [self.bgView addConstraint:_layoutStarItemsTop];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(ZCChatMarginHSpace, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatMarginHSpace, iv, self.bgView)];
        iv;
        
    });
    
    _btnSend = ({
        SobotButton *iv = [SobotButton buttonWithType:UIButtonTypeCustom];
//        [iv setBackgroundColor:[ZCUIKitTools zcgetRightChatColor]];
//        [iv setTitleColor:UIColorFromModeColor(SobotColorTextWhite) forState:0];
        iv.backgroundColor = UIColor.clearColor;
        [iv setTitleColor:[ZCUIKitTools zcgetServerConfigBtnBgColor] forState:0];
        [iv.titleLabel setFont:SobotFont14];
//        iv.layer.cornerRadius = 18;
//        iv.layer.masksToBounds = YES;
//        iv.contentEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 16);
        iv.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [iv setTitle:SobotKitLocalString(@"提交") forState:0];
        [iv addTarget:self action:@selector(sendButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgView addSubview:iv];
        
        _layoutSendHeight = sobotLayoutEqualHeight(46, iv, NSLayoutRelationEqual);
        [self.bgView addConstraint:_layoutSendHeight];
        _layoutSendTop = sobotLayoutMarginTop(ZCChatTopSpace24+1, iv, self.itemStarViews);
        [self.bgView addConstraint:_layoutSendTop];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(0, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingBottom(0, iv, self.bgView)];
        
        UIView *sendLine = [[UIView alloc] init];
        [sendLine setBackgroundColor:[ZCUIKitTools zcgetLineRichColor]];
        [iv addSubview:sendLine];
        
        [iv addConstraint:sobotLayoutPaddingTop(0, sendLine, iv)];
        [iv addConstraint:sobotLayoutEqualHeight(1, sendLine, NSLayoutRelationEqual)];
        [iv addConstraint:sobotLayoutPaddingLeft(0, sendLine, iv)];
        [iv addConstraint:sobotLayoutPaddingRight(0, sendLine, iv)];
        
        iv;
    });
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self createViews];
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self createViews];
    }
    return self;
}

-(void)robotServerButton:(SobotButton *) sender{
//    sender.layer.borderColor = [UIColor clearColor].CGColor;
    if (sender.tag == 1) {
        //        UIButton *btn=(UIButton *)[self.backgroundView viewWithTag:102];
        //        [btn setSelected:NO];
//        _btnResolved.layer.borderColor = UIColorFromModeColor(SobotColorBgLine).CGColor;
        _btnResolved.selected = YES;
        _btnUnResolved.selected = NO;
    }else{
        _btnResolved.selected = NO;
        _btnUnResolved.selected = YES;
    }
}

-(void)initDataToView:(SobotChatMessage *)message time:(NSString *)showTime{
    [super initDataToView:message time:showTime];
    
    self.tempModel = message;
    self.ivHeader.hidden = YES;
    self.lblNickName.hidden = YES;
    self.lblSugguest.hidden = YES;
    self.ivBgView.hidden = YES;
    
    CGFloat cw = self.viewWidth - ZCChatMarginHSpace * 2;
    if(cw > 500){
        cw = 500;
    }
    _layoutMaxW.constant = cw;
    // 不选中
    int isResolved = 2;
    
    ZCSatisfactionConfig *config = [ZCUICore getUICore].satisfactionConfig;
    _satisfaction = nil;
    int starCount = 5;
    
//    _labTitle.text = [NSString stringWithFormat:@"%@%@",message.senderName,SobotKitLocalString(@"邀请您对本次服务进行评价")];
    _labTitle.text = SobotKitLocalString(@"服务评价");
    if(config!=nil && config.isCreated == 1){
        if(config.isDefaultGuide == 0){
            if(sobotConvertToString(config.guideCopyWriting).length > 0){
                self.labTitle.text = sobotConvertToString(config.guideCopyWriting);
            }
        }
        if(config.isDefaultButton==0 && sobotConvertToString(config.buttonDesc).length > 0){
            [self.btnSend setTitle:sobotConvertToString(config.buttonDesc) forState:UIControlStateNormal];
        }
        // 0 5星，1、10星
        // scoreFlag==0星级: 0代表5星,1代表不选中
        // scoreFlag==1分值: 0代表10分，1代表5分，2代表0分，3代表不选中
        // scoreFlag==2分值: 0代表满意，1不满意，2不选中
        // defaultType 默认显示星级  0-5星,1-0星 / 0-10分，1-5分，2-0分，3-不选中 / 0-满意，1-不满意，2-不选中
        if(config.scoreFlag==0){
            starCount = 5;
            if(config.defaultType == 0 && config.list > 0){
                defaultStar = 5;
                // '*** -[__NSArrayM objectAtIndexedSubscript:]: index 4 beyond bounds [0 .. 2]'
                _satisfaction = [[ZCUICore getUICore] getSatisFactionWithScore:defaultStar];
            }else if(config.defaultType == 1){
                _satisfaction = nil;
                
            }
        }else if(config.scoreFlag==2){
            starCount = 2;
            if(config.defaultType < 2 && config.list.count > 0){
                if(config.defaultType == 0){
                    defaultStar = 1;
                    _satisfaction = [[ZCUICore getUICore] getSatisFactionWithScore:5];
                }else{
                    defaultStar = 2;
                    _satisfaction = [[ZCUICore getUICore] getSatisFactionWithScore:1];
                }
                
            }else if(config.defaultType == 2){
                _satisfaction = nil;
                
            }
        }else{
            starCount = 10;            
            if(config.defaultType == 0){
                defaultStar = 11;
            }else if(config.defaultType == 1){
                defaultStar = 6;
            }else if(config.defaultType == 2){
                defaultStar = 1;
            }else if(config.defaultType == 3){
                defaultStar = 0;
                _satisfaction = nil;
            }
            
            if(config.defaultType != 3 && config.list.count > 0){
                if(defaultStar == 6){
                    _satisfaction = [[ZCUICore getUICore] getSatisFactionWithScore:5];
                }else if(defaultStar == 11){
                    _satisfaction = [[ZCUICore getUICore] getSatisFactionWithScore:10];
                }else{
                    _satisfaction = [[ZCUICore getUICore] getSatisFactionWithScore:defaultStar];
                }
            }
        }
        
        
        if(config.isDefaultButton==0 && sobotConvertToString(config.buttonDesc).length > 0){
            [_btnSend setTitle:sobotConvertToString(config.buttonDesc) forState:UIControlStateNormal];
        }
        
        
    }
    
    // 开启已解决未解决  1开启 0关闭，并且没有评价过
    if (config.isQuestionFlag == 0 ) {
        _labTips.text=@"";
        _layoutResolveTipTop.constant = 0;
        _layoutResolveHeight.constant = 0;
        self.layoutUnResolvedEH.constant = 0;
        self.layoutResolveTop.constant = 0;
        _layoutLineTop.constant = -1;
        self.lineView.hidden = YES;
        _btnResolved.hidden = YES;
        _btnUnResolved.hidden = YES;
        
        _layoutUnResolvedTop.constant = 0;
    }else{
        _layoutResolveTipTop.constant = ZCChatMarginHSpace;
        _layoutResolveHeight.constant = 36;
        self.layoutUnResolvedEH.constant = 36;
        self.layoutResolveTop.constant = ZCChatMarginHSpace;
        self.lineView.hidden = NO;
        _layoutLineTop.constant = ZCChatTopSpace24;
        if(isMulResolveBtn){
            _layoutUnResolvedTop.constant = ZCChatMarginHSpace;
        }else{
            _layoutUnResolvedTop.constant = 0;
        }
        
        _btnResolved.hidden = NO;
        _btnUnResolved.hidden = NO;
        _labTips.text = [NSString stringWithFormat:@"%@ %@",message.senderName,SobotKitLocalString(@"是否解决了您的问题？")];
        isResolved = config.defaultQuestionFlag;
        if(config.defaultQuestionFlag == 0){
            // 未解决
            [self robotServerButton:_btnUnResolved];
        }else if(config.defaultQuestionFlag == 1){
            // 已解决
            [self robotServerButton:_btnResolved];
        }
    }
    
    // 提前执行一下，否则内部拿到的坐标不准确
//    [_ratingView setImagesDeselected:@"zcicon_star_unsatisfied" partlySelected:@"zcicon_star_satisfied" fullSelected:@"zcicon_star_satisfied" count:starCount andDelegate:self];
    [_ratingView setImagesDeselected:@"zcicon_star_satisfied_new" fullSelected:@"zcicon_star_satisfied_new" count:starCount showLRTip:config.scoreFlag == 1 andDelegate:self];
    
    _labStarTips.text = @"";
    _layoutStartTipsTop.constant = 0;
    
    
    _layoutItemTipsT.constant = 0;
    _labItemTips.text = @"";
    [_itemStarViews refreshData:@[]];
    // 没有评价，0 没有评价 1已解决  2未解决，3，评价但没有选择是否评价
    if(message.satisfactionCommtType == 0){
//        [_labStarTips setTextColor:UIColorFromModeColor(SobotColorYellow)];
        [_labStarTips setTextColor:UIColorFromKitModeColor(SobotColorHeaderText)];
        if(_satisfaction!=nil){
            
            // 二级评价没有提示语
            if(starCount == 2){
                [_labStarTips setText:@""];
                _layoutStartTipsTop.constant = 0;
            }else if(sobotConvertToString(_satisfaction.scoreExplain).length > 0){
                _layoutStartTipsTop.constant = ZCChatMarginHSpace;
            
                [_labStarTips setText:sobotConvertToString(_satisfaction.scoreExplain)];
            }
            
            if(sobotConvertToString(_satisfaction.tagTips).length > 0){
                _layoutItemTipsT.constant = ZCChatTopSpace24;
                _labItemTips.text = sobotConvertToString(_satisfaction.tagTips);
            }
            
            _itemStarViews.hidden = NO;
            if(sobotConvertToString(_satisfaction.labelName).length > 0){
                NSArray *items =  items = [sobotConvertToString(_satisfaction.labelName) componentsSeparatedByString:@"," ];
                [_bgView layoutIfNeeded];
                [_itemStarViews refreshData:items];
                
                _layoutStarItemsTop.constant = ZCChatTopSpace8;
                if(_layoutItemTipsT.constant == 0){
                    _layoutItemTipsT.constant = ZCChatTopSpace24 - ZCChatTopSpace8;
                }
            }else{
                _layoutStarItemsTop.constant = 0;
            }
            
            if(defaultStar > 0){
                [_bgView layoutIfNeeded];
                [_ratingView displayRating:defaultStar];
            }
            
            
            _btnSend.hidden = NO;
            _layoutSendHeight.constant = 36;
            _layoutSendTop.constant = 24;
            
        }else{
            // 没有获取到配置信息，不显示信息
            _layoutSendTop.constant = 0;
            _layoutSendHeight.constant = 0;
            _itemStarViews.hidden = YES;
            _labStarTips.text = @"";
            _layoutStartTipsTop.constant = 0;
            [_ratingView displayRating:0];
            [_itemStarViews refreshData:@[]];
            _btnSend.hidden = YES;
        }
    }else{
        // 说明已经评价过了
        _layoutSendTop.constant = 0;
        _layoutSendHeight.constant = 0;
        _itemStarViews.hidden = YES;
        _labStarTips.text = SobotKitLocalString(@"您的评价会让我们做得更好");
        _layoutStartTipsTop.constant = ZCChatMarginHSpace;
        [_labStarTips setTextColor:UIColorFromModeColor(SobotColorTextSub2)];
        [_ratingView displayRating:0];
        [_itemStarViews refreshData:@[]];
        _btnSend.hidden = YES;
    }
    [self.bgView setNeedsLayout];
}

-(void)sendButtonClick:(SobotButton *) btn{
    
    // 查看是否必填
    if (!sobotIsNull(_satisfaction) && [_satisfaction.isInputMust intValue] == 1) {
        // 输入框必填
        [self commitAction:1];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:isResolved:rating:problem:scoreFlag:scoreExplain:checkScore:)]) {
        [ZCUICore getUICore].inviteSatisfactionCheckLabels = [_itemStarViews getSeletedTitle];
        // 0:5星,1:10分
        int isResolved = -1;
        if(_btnResolved.selected){
            isResolved = 0;
        }
        if(_btnUnResolved.selected){
            isResolved = 1;
        }
        ZCSatisfactionConfig *config = [ZCUICore getUICore].satisfactionConfig;
        // 是否解决必填
        if(config.isQuestionMust  && config.isQuestionFlag && isResolved == -1){
            // 提示
            [[SobotToast shareToast] showToast:SobotKitLocalString(@"是否解决了您的问题？") duration:1.0f position:SobotToastPositionCenter];
            return;
        }
        
        BOOL _isMustAdd = NO;
        if(_satisfaction!=nil){
            if ([@"" isEqual: sobotConvertToString(_satisfaction.labelName)]) {
                _isMustAdd = NO;
            }else{
                if ([_satisfaction.isTagMust intValue] == 1 ) {
                    _isMustAdd = YES;
                }else{
                    _isMustAdd = NO;
                }
            }
        }
        
        // 必填项为空
        if(_isMustAdd && sobotConvertToString([_itemStarViews getSeletedTitle]).length == 0){
            // 提示
            [[SobotToast shareToast] showToast:SobotKitLocalString(@"标签必选") duration:1.0f position:SobotToastPositionCenter];
            
            return;
        }
        // 提交评价
        [self.delegate cellItemClick:2 isResolved:isResolved rating:_ratingView.rating problem:[_itemStarViews getSeletedTitle] scoreFlag:_satisfaction.scoreFlag scoreExplain:_satisfaction.scoreExplain checkScore:_satisfaction];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma delegate
// 赋值的时候，不执行
-(void)ratingChanged:(float)newRating{
    // 优先于ratingChangedWithTap 方法
//    NSLog(@"change:%f",newRating);
}

-(void)ratingChangedWithTap:(float)newRating{
    // 始终一样，去掉此逻辑
//    if (newRating == self.rating) {
//        return;
//    }
    
    self.rating = newRating;
    [self commitAction:1];
    
    
    // 设置默认值
    self.rating = defaultStar;
    [self.ratingView displayRating:defaultStar];
}

// 提交评价   type 1代表5星以下  2 代表提交
- (void)commitAction:(int)type{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:isResolved:rating:problem:scoreFlag:scoreExplain:checkScore:)]) {
        if(type == 2){
            if(_satisfaction!=nil){
                // 内容必填 ，切换为1弹评价页面
                if([_satisfaction.isInputMust intValue] == 1){
                    type = 1;
                }
            }
        }
        [ZCUICore getUICore].inviteSatisfactionCheckLabels = [_itemStarViews getSeletedTitle];
        // 0:5星,1:10分
        int isResolved = -1;
        if(_btnResolved.selected){
            isResolved = 1;
        }
        if(_btnUnResolved.selected){
            isResolved = 0;
        }
        
        [self.delegate cellItemClick:type isResolved:isResolved rating:self.rating problem:[_itemStarViews getSeletedTitle] scoreFlag:_satisfaction.scoreFlag scoreExplain:_satisfaction.scoreExplain checkScore:_satisfaction];
    }
}


// 只有可能是5星的时候调用此函数
-(void)buttonClick:(UIButton *) btn{
    BOOL _isMustAdd = NO;
    if(_satisfaction!=nil){
        if ([@"" isEqual: sobotConvertToString(_satisfaction.labelName)]) {
            _isMustAdd = NO;
        }else{
            if ([_satisfaction.isTagMust intValue] == 1 ) {
                _isMustAdd = YES;
            }else{
                _isMustAdd = NO;
            }
        }
        // 标签必填直接谈评价
        if([_satisfaction.isInputMust intValue] == 1){
            [self commitAction:1];
            return;
        }
    }
    
    // 必填项为空
    if(_isMustAdd && sobotConvertToString([_itemStarViews getSeletedTitle]).length == 0){
        // 提示
        [[SobotToast shareToast] showToast:SobotKitLocalString(@"标签必选") duration:1.0f position:SobotToastPositionCenter];
        
        return;
    }
    
    [self commitAction:2];
}

@end
