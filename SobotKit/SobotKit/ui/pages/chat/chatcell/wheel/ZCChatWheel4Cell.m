//
//  ZCChatWheel4Cell.m
//  SobotKit
//
//  Created by zhangxy on 2022/9/20.
//

#import "ZCChatWheel4Cell.h"
#import <SobotCommon/SobotCommon.h>


@interface ZCChatWheel4Cell(){
    NSString *morelink;
    
}

@property(nonatomic,strong) NSLayoutConstraint *layoutBgWidth;
//@property(nonatomic,strong) NSLayoutConstraint *layoutBgHeight;
@property(nonatomic,strong) NSLayoutConstraint *layoutTitleHeight;

@property(nonatomic,strong) NSLayoutConstraint *layoutImageHeight;
@property(nonatomic,strong) NSLayoutConstraint *layoutImageLeft;

@property(nonatomic,strong) NSLayoutConstraint *layoutSummaryHeight;
@property(nonatomic,strong) NSLayoutConstraint *layoutLookHeight;

@property (strong, nonatomic) UIView *bgView; //背景
@property (strong, nonatomic) UILabel *labTitle; //标题
@property (strong, nonatomic) SobotImageView *posterView;// 图片
@property (strong, nonatomic) UILabel *labTitleDesc; // 要素标题
@property (strong, nonatomic) SobotEmojiLabel *labSummary; // 要素内容
@property (strong, nonatomic) UIView *lineView; //
@property (strong, nonatomic) SobotEmojiLabel *lookMore; //


@end

@implementation ZCChatWheel4Cell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self createViews];
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self createViews];
        
        [self.contentView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingHSpace, self.bgView, self.ivBgView)];
        [self.contentView addConstraint:sobotLayoutPaddingTop(ZCChatPaddingVSpace, self.bgView, self.ivBgView)];
        _layoutBgWidth = sobotLayoutEqualWidth(ScreenWidth, self.bgView, NSLayoutRelationEqual);
        [self.contentView addConstraint:_layoutBgWidth];
        [self.contentView addConstraint:sobotLayoutMarginBottom(-ZCChatCellItemSpace, self.bgView, self.lblSugguest)];
        
        
        [self.bgView addConstraint: sobotLayoutPaddingTop(0, self.labTitle, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(0, self.labTitle, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-0, self.labTitle, self.bgView)];
//        _layoutTitleHeight = sobotLayoutEqualHeight(34, self.labTitle, NSLayoutRelationEqual);
//        [self.bgView addConstraint:_layoutTitleHeight];
        
        _layoutImageHeight = sobotLayoutEqualHeight(175, self.posterView, NSLayoutRelationEqual);
        [self.bgView addConstraint:_layoutImageHeight];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(0, self.posterView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-0, self.posterView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutMarginTop(ZCChatCellItemSpace, self.posterView, self.labTitle)];
        
        [self.bgView addConstraint:sobotLayoutMarginTop(ZCChatCellItemSpace, self.labTitleDesc, self.posterView)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(0, self.labTitleDesc, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.labTitleDesc, self.bgView)];
        
        
//        _layoutSummaryHeight = sobotLayoutEqualHeight(50, self.labSummary, NSLayoutRelationEqual);
//        [self.bgView addConstraint:_layoutSummaryHeight];
        [self.bgView addConstraint:sobotLayoutMarginTop(ZCChatCellItemSpace, self.labSummary, self.labTitleDesc)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(0, self.labSummary, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.labSummary, self.bgView)];
      
        
        [self.bgView addConstraint:sobotLayoutMarginTop(ZCChatCellItemSpace, self.lineView, self.labSummary)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(0, self.lineView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.lineView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutEqualHeight(1, self.lineView, NSLayoutRelationEqual)];
        
        _layoutLookHeight = sobotLayoutEqualHeight(0, self.lookMore, NSLayoutRelationEqual);
        [self.bgView addConstraint:_layoutLookHeight];
        [self.bgView addConstraint:sobotLayoutMarginTop(ZCChatCellItemSpace, self.lookMore, self.lineView)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(0, self.lookMore, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, self.lookMore, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingBottom(-ZCChatCellItemSpace, self.lookMore, self.bgView)];
        
    }
    return self;
}


-(void)createViews{
    _bgView = ({
        UIView *iv = [[UIView alloc] init];
        [iv setBackgroundColor:UIColor.clearColor];
        [self.contentView addSubview:iv];
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
        [iv setFont:SobotFont14];
        [self.bgView addSubview:iv];
        iv;
    });
    
    _labSummary = ({
        SobotEmojiLabel *iv = [ZCChatBaseCell createRichLabel];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        [iv setFont:SobotFont14];
        iv.numberOfLines = 0;
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
        SobotEmojiLabel *iv = [ZCChatBaseCell createRichLabel];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        [iv setFont:SobotFont14];
        iv.delegate = self;
        [self.bgView addSubview:iv];
        iv;
    });
    
    
    _lineView = ({
        UIView *iv = [[UIView alloc] init];
        [iv setBackgroundColor:[ZCUIKitTools zcgetLineRichColor]];
        [self.bgView addSubview:iv];
        iv;
    });
    
}

-(void)initDataToView:(SobotChatMessage *)message time:(NSString *)showTime{
    [super initDataToView:message time:showTime];
    
    NSString *showMsg = sobotConvertToString(message.richModel.richContent.msg);
    showMsg = [showMsg stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
    showMsg = [showMsg stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
    [_labTitle setText:sobotConvertToString(showMsg)];
    
    NSMutableDictionary * detailDict = message.richModel.richContent.interfaceRetList.firstObject; // 多个
    if(sobotConvertToString(detailDict[@"thumbnail"]).length > 0){
        [_posterView loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(detailDict[@"thumbnail"])] placeholer:SobotKitGetImage(@"zcicon_default_goods") showActivityIndicatorView:NO];
      
    }
    [_labTitleDesc setText:sobotConvertToString(detailDict[@"title"])];
    [_labSummary setText:sobotConvertToString(detailDict[@"summary"])];
    if(sobotConvertToString(detailDict[@"anchor"]).length > 0){
        if(self.isRight){
            [self.lookMore setTextColor:[ZCUIKitTools zcgetRightChatTextColor]];
            [self.lookMore setLinkColor:[ZCUIKitTools zcgetRightChatTextColor]];
        }else{
            [self.lookMore setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
            [self.lookMore setLinkColor:[ZCUIKitTools zcgetChatLeftLinkColor]];
            
        }
        _layoutLookHeight.constant = 25;
        self.lookMore.hidden = NO;
        self.lookMore.text = SobotKitLocalString(@"查看详情");
        self.lookMore.textAlignment = NSTextAlignmentCenter;
        // 一定要在设置text文本之后设置
        [[self lookMore] addLinkToURL:[NSURL URLWithString:sobotConvertToString(detailDict[@"anchor"])] withRange:NSMakeRange(0, SobotKitLocalString(@"查看详情").length)];
        morelink = sobotConvertToString(detailDict[@"anchor"]);
        _lineView.hidden = NO;
    }else{
        morelink = @"";
        self.lookMore.hidden = YES;
        _lineView.hidden = YES;
        _layoutLookHeight.constant = 0;
    }
    _layoutBgWidth.constant = self.maxWidth;
    [self.bgView layoutIfNeeded];
    [self.ivBgView updateConstraints];
    
    [self setChatViewBgState:CGSizeMake(self.maxWidth,CGRectGetMaxX(self.bgView.frame))];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
