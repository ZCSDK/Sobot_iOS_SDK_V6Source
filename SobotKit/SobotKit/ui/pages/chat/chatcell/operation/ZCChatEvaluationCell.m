//
//  ZCChatEvaluationCell.m
//  SobotKit
//
//  Created by zhangxy on 2022/9/23.
//

#import "ZCChatEvaluationCell.h"
#import "ZCItemView.h"
#import "ZCUIRatingView.h"

@interface ZCChatEvaluationCell()<RatingViewDelegate>{
    // 0五星   1是0星
    int defaultStar;
}

@property(nonatomic,strong) ZCLibSatisfaction *satisfaction;
@property(nonatomic,strong) NSLayoutConstraint *layoutBgWidth;
@property(nonatomic,assign) int rating;

@property(nonatomic,strong) NSLayoutConstraint *layoutResolveTop;
@property(nonatomic,strong) NSLayoutConstraint *layoutResolveHeight;
@property(nonatomic,strong) NSLayoutConstraint *layoutStarItemsTop;
@property(nonatomic,strong) NSLayoutConstraint *layoutStarItemsHeight;
@property(nonatomic,strong) NSLayoutConstraint *layoutSendHeight;
@property(nonatomic,strong) NSLayoutConstraint *layoutRatingHeight;
@property(nonatomic,strong) NSLayoutConstraint *layoutRatingW;

@property(nonatomic,strong) NSLayoutConstraint *layoutItemTipsT;


// 深色背景
@property (strong, nonatomic) UIView *bgGroupView; //
// 标题
@property (strong, nonatomic) UILabel *labTitle; //标题

// 内容背景
@property (strong, nonatomic) UIView *bgView; //

@property (strong, nonatomic) UILabel *labTips; //标题
// 已解决
@property (strong, nonatomic) SobotButton *btnResolved;
// 未解决
@property (strong, nonatomic) SobotButton *btnUnResolved;

@property (strong, nonatomic) UIView *lineView;

@property (strong, nonatomic) ZCUIRatingView *ratingView; //星标或分数
@property (strong, nonatomic) UILabel *labStarTips; //标题
@property (strong, nonatomic) UILabel *labItemTips; //标题
@property (strong, nonatomic) ZCItemView *itemStarViews; //星标或分数

@property (strong, nonatomic) SobotButton *btnSend;

@end

@implementation ZCChatEvaluationCell

-(void)createViews{
    _bgGroupView = ({
        UIView *iv = [[UIView alloc] init];
        [iv setBackgroundColor:[ZCUIKitTools zcgetLightGrayDarkBackgroundColor]];
        [self.contentView addSubview:iv];
        iv;
    });
    
    _labTitle = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        iv.numberOfLines = 0;
        [iv setFont:SobotFontBold14];
        [self.bgGroupView addSubview:iv];
        iv;
    });
    _bgView = ({
        UIView *iv = [[UIView alloc] init];
        [iv setBackgroundColor:UIColorFromModeColor(SobotColorBgMainDark2)];
        iv.layer.cornerRadius = 4.0f;
        iv.layer.borderColor = [ZCUIKitTools zcgetChatBottomLineColor].CGColor;
        iv.layer.borderWidth = 1.0f;
        [self.bgGroupView addSubview:iv];
        iv;
    });
    
    _labTips = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentCenter];
        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        iv.numberOfLines = 0;
        [iv setFont:SobotFontBold14];
        [self.bgView addSubview:iv];
        iv;
    });
    
    _btnResolved = ({
        SobotButton *iv = [SobotButton buttonWithType:UIButtonTypeCustom];
        [iv.titleLabel setFont:SobotFont14];
        [iv setTitle:SobotKitLocalString(@"已解决") forState:UIControlStateNormal];
        [iv setImage:SobotKitGetImage(@"zcicon_useful_nol") forState:UIControlStateNormal];
        [iv setImage:SobotKitGetImage(@"zcicon_useful_sel") forState:UIControlStateSelected];
        [iv setImage:SobotKitGetImage(@"zcicon_useful_sel") forState:UIControlStateHighlighted];
        iv.tag = 1;
        
        iv.layer.cornerRadius = 18;
        [iv setTitleColor:[ZCUIKitTools zcgetNoSatisfactionTextColor] forState:UIControlStateNormal];
        [iv setTitleColor:[ZCUIKitTools zcgetSatisfactionTextSelectedColor] forState:UIControlStateHighlighted];
        [iv setTitleColor:[ZCUIKitTools zcgetSatisfactionTextSelectedColor]  forState:UIControlStateSelected];
        [iv setBackgroundColor:[ZCUIKitTools zcgetSatisfactionBgSelectedColor]];
        if([SobotUITools getSobotThemeMode] != SobotThemeMode_Dark){
            iv.layer.shadowOpacity= 1;
            iv.layer.shadowColor = UIColorFromModeColorAlpha(SobotColorTextMain, 0.15).CGColor;
            iv.layer.shadowOffset = CGSizeZero;//投影偏移
            iv.layer.shadowRadius = 2;
        }
        [iv setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
        [iv addTarget:self action:@selector(robotServerButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgView addSubview:iv];
        iv;
        
    });
    _btnUnResolved = ({
        SobotButton *iv = [SobotButton buttonWithType:UIButtonTypeCustom];
        [iv.titleLabel setFont:SobotFont14];
        [iv setTitle:SobotKitLocalString(@"未解决") forState:UIControlStateNormal];
        [iv setImage:SobotKitGetImage(@"zcicon_useless_nol") forState:UIControlStateNormal];
        [iv setImage:SobotKitGetImage(@"zcicon_useless_sel") forState:UIControlStateSelected];
        [iv setImage:SobotKitGetImage(@"zcicon_useless_sel") forState:UIControlStateHighlighted];
        iv.tag = 2;
        iv.layer.cornerRadius = 18;
        [iv setTitleColor:[ZCUIKitTools zcgetNoSatisfactionTextColor] forState:UIControlStateNormal];
        [iv setTitleColor:[ZCUIKitTools zcgetSatisfactionTextSelectedColor] forState:UIControlStateHighlighted];
        [iv setTitleColor:[ZCUIKitTools zcgetSatisfactionTextSelectedColor]  forState:UIControlStateSelected];
        [iv setBackgroundColor:[ZCUIKitTools zcgetSatisfactionBgSelectedColor]];
        if([SobotUITools getSobotThemeMode] != SobotThemeMode_Dark){
            iv.layer.shadowOpacity= 1;
            iv.layer.shadowColor = UIColorFromModeColorAlpha(SobotColorTextMain, 0.15).CGColor;
            iv.layer.shadowOffset = CGSizeZero;//投影偏移
            iv.layer.shadowRadius = 2;
        }
        [iv setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
        [iv addTarget:self action:@selector(robotServerButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgView addSubview:iv];
        iv;
        
    });
    
    _lineView = ({
        UIView *iv = [[UIView alloc] init];
        [iv setBackgroundColor:[ZCUIKitTools zcgetLineRichColor]];
        [self.bgView addSubview:iv];
        iv;
        
    });
    
    _ratingView = ({
        ZCUIRatingView *iv = [[ZCUIRatingView alloc] init];
        [self.bgView addSubview:iv];
        iv;
    });
    _labStarTips = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentCenter];
        [iv setTextColor:[ZCUIKitTools zcgetTextPlaceHolderColor]];
        iv.numberOfLines = 0;
        [iv setFont:SobotFontBold14];
        [self.bgView addSubview:iv];
        iv;
    });
    _labItemTips = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextColor:[ZCUIKitTools zcgetTextPlaceHolderColor]];
        [iv setFont:SobotFontBold14];
        iv.textAlignment = NSTextAlignmentLeft;
        iv.numberOfLines = 0;
        iv.textColor = [ZCUIKitTools zcgetSatisfactionColor];
        [self.bgView addSubview:iv];
        iv;
    });
    
    _itemStarViews = ({
        ZCItemView *iv = [[ZCItemView alloc] init];
        [self.bgView addSubview:iv];
        iv;
        
    });
    _btnSend = ({
        SobotButton *iv = [SobotButton buttonWithType:UIButtonTypeCustom];
        [iv setBackgroundColor:[ZCUIKitTools zcgetRightChatColor]];
        [iv setTitleColor:UIColorFromModeColor(SobotColorTextWhite) forState:0];
        [iv.titleLabel setFont:SobotFont14];
        iv.layer.cornerRadius = 18;
        iv.layer.masksToBounds = YES;
        [iv setTitle:SobotKitLocalString(@"提交") forState:0];
        [iv addTarget:self action:@selector(sendButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgView addSubview:iv];
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
        
        //设置点击事件
        [self.contentView addConstraint:sobotLayoutPaddingTop(ZCChatMarginVSpace, self.bgGroupView, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(ZCChatMarginHSpace, self.bgGroupView, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-ZCChatMarginHSpace, self.bgGroupView, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(-ZCChatMarginVSpace, self.bgGroupView, self.contentView)];
        
        [self.bgGroupView addConstraint: sobotLayoutPaddingTop(ZCChatPaddingVSpace, self.labTitle, self.bgGroupView)];
        [self.bgGroupView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingHSpace, self.labTitle, self.bgGroupView)];
        [self.bgGroupView addConstraint:sobotLayoutPaddingRight(-ZCChatPaddingHSpace, self.labTitle, self.bgGroupView)];
        
        [self.bgGroupView addConstraint:sobotLayoutMarginTop(ZCChatMarginVSpace, self.bgView, self.labTitle)];
        [self.bgGroupView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingHSpace, self.bgView, self.bgGroupView)];
        [self.bgGroupView addConstraint:sobotLayoutPaddingRight(-ZCChatPaddingHSpace, self.bgView, self.bgGroupView)];
        [self.bgGroupView addConstraint:sobotLayoutPaddingBottom(-ZCChatPaddingVSpace, self.bgView, self.bgGroupView)];
        
        
        [self.bgView addConstraint: sobotLayoutPaddingTop(ZCChatMarginHSpace, self.labTips, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(0, self.labTips, self.bgView)];
        [self.bgGroupView addConstraint:sobotLayoutPaddingRight(0, self.labTips, self.bgView)];
        
        [self.bgView addConstraint:sobotLayoutEqualWidth(97, self.btnResolved, NSLayoutRelationEqual)];
       _layoutResolveHeight = sobotLayoutEqualHeight(36, self.btnResolved, NSLayoutRelationEqual);
        [self.bgView addConstraint:_layoutResolveHeight];
        [self.bgView addConstraint: sobotLayoutMarginTop(ZCChatMarginVSpace, self.btnResolved, self.labTips)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingHSpace, self.btnResolved, self.bgView)];
        
        [self.bgView addConstraint:sobotLayoutEqualWidth(97, self.btnUnResolved, NSLayoutRelationEqual)];
         [self.bgView addConstraint:sobotLayoutEqualHeight(36, self.btnUnResolved, NSLayoutRelationEqual)];
         [self.bgView addConstraint: sobotLayoutMarginTop(ZCChatMarginVSpace, self.btnUnResolved, self.labTips)];
         [self.bgGroupView addConstraint:sobotLayoutPaddingRight(-ZCChatPaddingHSpace, self.btnUnResolved, self.bgView)];
        
        
        [self.bgView addConstraint:sobotLayoutEqualHeight(1, self.lineView, NSLayoutRelationEqual)];
        [self.bgView addConstraint: sobotLayoutMarginTop(ZCChatPaddingVSpace, self.lineView, self.btnResolved)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(0, self.lineView, self.bgView)];
        [self.bgGroupView addConstraint:sobotLayoutPaddingRight(-0, self.lineView, self.bgView)];
        
        
        _layoutRatingHeight = sobotLayoutEqualHeight(60, self.ratingView, NSLayoutRelationEqual);
        _layoutRatingW = sobotLayoutEqualWidth(280, self.ratingView, NSLayoutRelationEqual);
        [self.bgView addConstraint:_layoutRatingHeight];
        [self.bgView addConstraint:_layoutRatingW];
        [self.bgView addConstraint:sobotLayoutMarginTop(ZCChatPaddingHSpace, self.ratingView, self.lineView)];
        [self.bgView addConstraint:sobotLayoutEqualCenterX(0,self.ratingView, self.bgView)];
        self.ratingView.backgroundColor = UIColor.clearColor;
        
        [self.bgView addConstraint:sobotLayoutMarginTop(ZCChatMarginVSpace, self.labStarTips, self.ratingView)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(10, self.labStarTips, self.bgView)];
        [self.bgGroupView addConstraint:sobotLayoutPaddingRight(-10, self.labStarTips, self.bgView)];
        
        _layoutItemTipsT = sobotLayoutMarginTop(ZCChatMarginVSpace, self.labItemTips, self.labStarTips);
        [self.bgView addConstraint:_layoutItemTipsT];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(10, self.labItemTips, self.bgView)];
        [self.bgGroupView addConstraint:sobotLayoutPaddingRight(-10, self.labItemTips, self.bgView)];
        
        
        
        _layoutStarItemsHeight = sobotLayoutEqualHeight(0, self.itemStarViews, NSLayoutRelationEqual);
        _layoutStarItemsTop = sobotLayoutMarginTop(ZCChatMarginVSpace, self.itemStarViews, self.labItemTips);
        [self.bgView addConstraint:_layoutStarItemsHeight];
        [self.bgView addConstraint:sobotLayoutEqualWidth(280, self.itemStarViews, NSLayoutRelationEqual)];
        [self.bgView addConstraint:_layoutStarItemsTop];
        [self.bgView addConstraint:sobotLayoutEqualCenterX(0,self.itemStarViews, self.bgView)];
        
        
        self.btnSend.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        self.btnSend.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _layoutSendHeight = sobotLayoutEqualHeight(36, self.btnSend, NSLayoutRelationEqual);
        [self.bgView addConstraint:sobotLayoutEqualWidth(200, self.btnSend, NSLayoutRelationEqual)];
        [self.bgView addConstraint:_layoutSendHeight];
        [self.bgView addConstraint:sobotLayoutPaddingBottom(-ZCChatPaddingVSpace, self.self.btnSend, self.bgView)];
        [self.bgView addConstraint:sobotLayoutEqualCenterX(0, self.btnSend, self.bgView)];
        [self.bgView addConstraint: sobotLayoutMarginTop(ZCChatPaddingVSpace, self.btnSend, self.itemStarViews)];
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
    
    // 不选中
    int isResolved = 2;
    
    ZCSatisfactionConfig *config = [ZCUICore getUICore].satisfactionConfig;
    _satisfaction = nil;
    
    int starCount = 5;
    if(config!=nil && config.isCreated == 1){
        // 0 5星，1、10星
        // scoreFlag==0星级: 0代表5星,1代表不选中
        // scoreFlag==1分值: 0代表10分，1代表5分，2代表0分，3代表不选中
        if(config.scoreFlag==0){
            starCount = 5;
            if(config.defaultType == 0 && config.list.count >= defaultStar){
                defaultStar = 5;
                _satisfaction = config.list[defaultStar-1];
            }else if(config.defaultType == 1){
                _satisfaction = nil;
                
            }
        }else{
            
            starCount = 10;            
            if(config.defaultType == 0){
                defaultStar = 10;
            }else if(config.defaultType == 1){
                defaultStar = 5;
            }else if(config.defaultType == 2){
                defaultStar = 1;
            }else if(config.defaultType == 3){
                defaultStar = 0;
                _satisfaction = nil;
            }
            if(config.defaultType != 3 && config.list.count >= defaultStar){
                _satisfaction = config.list[defaultStar];
            }
        }
        
        
        if(config.isDefaultButton==0 && sobotConvertToString(config.buttonDesc).length > 0){
            [_btnSend setTitle:sobotConvertToString(config.buttonDesc) forState:UIControlStateNormal];
        }
        
        
    }
    
    
    
    CGFloat starWith = (starCount/5==1)?180:300;
    if(starCount == 0){
        starWith = 180;
    }
    _layoutRatingW.constant = starWith;
    
    if(config.scoreFlag == 0){
        _layoutRatingHeight.constant = 60;
    }else{
        _layoutRatingHeight.constant = 60 + 29;
    }
    
    // 开启已解决未解决  1开启 0关闭，并且没有评价过
    if (config.isQuestionFlag > 0 ) {
        _layoutResolveHeight.constant = 36;
        _layoutResolveTop.constant = ZCChatCellItemSpace;
        
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
    }else{
        _layoutItemTipsT.constant = 0;
        _labItemTips.text = @"";
        _labTips.text=@"";
        _layoutResolveHeight.constant = 0;
        _layoutResolveTop.constant = 0;
        _btnResolved.hidden = YES;
        _btnUnResolved.hidden = YES;
    }
            
    _labTitle.text = [NSString stringWithFormat:@"%@%@",message.senderName,SobotKitLocalString(@"邀请您对本次服务进行评价")];
    [_ratingView layoutIfNeeded];
    [_ratingView setImagesDeselected:@"zcicon_star_unsatisfied" partlySelected:@"zcicon_star_satisfied" fullSelected:@"zcicon_star_satisfied" count:starCount andDelegate:self];
    
    _labStarTips.text = SobotKitLocalString(@"非常满意");
    
    _layoutItemTipsT.constant = 0;
    _labItemTips.text = @"";
    [_itemStarViews InitDataWithArray:@[]];
    [_bgView layoutIfNeeded];
    // 没有评价，0 没有评价 1已解决  2未解决，3，评价但没有选择是否评价
    if(message.satisfactionCommtType == 0){
        [_labStarTips setTextColor:UIColorFromModeColor(SobotColorYellow)];
        if(_satisfaction!=nil){
            if(sobotConvertToString(_satisfaction.scoreExplain).length > 0){
                [_labStarTips setText:sobotConvertToString(_satisfaction.scoreExplain)];
            }
            _itemStarViews.hidden = NO;
            if(sobotConvertToString(_satisfaction.labelName).length > 0){
                NSArray *items =  items = [sobotConvertToString(_satisfaction.labelName) componentsSeparatedByString:@"," ];
                [_bgView layoutIfNeeded];
                [_itemStarViews InitDataWithArray:items];
                _layoutStarItemsHeight.constant =[_itemStarViews getHeightWithArray:items];
            }
            
            [_ratingView displayRating:defaultStar];
            
            
            _btnSend.hidden = NO;
            _layoutSendHeight.constant = 36;
            
            if(sobotConvertToString(_satisfaction.tagTips).length > 0){
                
                _layoutItemTipsT.constant = ZCChatMarginVSpace;
                _labItemTips.text = sobotConvertToString(_satisfaction.tagTips);
                
            }
        }else{
            // 说明已经评价过了
            _layoutSendHeight.constant = 0;
            _layoutStarItemsHeight.constant = 0;
            _itemStarViews.hidden = YES;
            _labStarTips.text = @"";
            [_ratingView displayRating:0];
            [_itemStarViews InitDataWithArray:@[]];
            _btnSend.hidden = YES;
        }
    }else{
        // 说明已经评价过了
        _layoutSendHeight.constant = 0;
        _layoutStarItemsHeight.constant = 0;
        _itemStarViews.hidden = YES;
        _labStarTips.text = SobotKitLocalString(@"您的评价会让我们做得更好");
        [_labStarTips setTextColor:UIColorFromModeColor(SobotColorTextSub2)];
        [_ratingView displayRating:0];
        _btnSend.hidden = YES;
    }
    [self.bgView setNeedsLayout];
//    [self.contentView layoutIfNeeded];
}

-(void)sendButtonClick:(SobotButton *) btn{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:isResolved:rating:problem:scoreFlag:)]) {
        [ZCUICore getUICore].inviteSatisfactionCheckLabels = [_itemStarViews getSeletedTitle];
        // 0:5星,1:10分
        int isResolved = -1;
        if(_btnResolved.selected){
            isResolved = 1;
        }
        if(_btnUnResolved.selected){
            isResolved = 0;
        }
        ZCSatisfactionConfig *config = [ZCUICore getUICore].satisfactionConfig;
        // 是否解决必填
        if(config.isQuestionMust && isResolved == -1){
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
        [self.delegate cellItemClick:2 isResolved:isResolved rating:_ratingView.rating problem:[_itemStarViews getSeletedTitle] scoreFlag:_satisfaction.scoreFlag];
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
    [self  commitAction:1];
    
    
    // 设置默认值
    self.rating = defaultStar;
    [self.ratingView displayRating:defaultStar];
}

// 提交评价   type 1代表5星以下  2 代表5星提交
- (void)commitAction:(int)type{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:isResolved:rating:problem:scoreFlag:)]) {
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
        [self.delegate cellItemClick:type isResolved:isResolved rating:self.rating problem:[_itemStarViews getSeletedTitle] scoreFlag:_satisfaction.scoreFlag];
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
