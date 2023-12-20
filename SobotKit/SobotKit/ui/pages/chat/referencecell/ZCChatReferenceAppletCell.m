//
//  ZCChatReferenceAppletCell.m
//  SobotKit
//
//  Created by lizh on 2023/11/24.
//

#import "ZCChatReferenceAppletCell.h"

@interface ZCChatReferenceAppletCell()

@property(nonatomic,strong) UIView *bgView;
@property(nonatomic,strong) SobotImageView *iconImg;
@property(nonatomic,strong) UILabel *nickLab;
@property(nonatomic,strong) SobotImageView *rightImg;

@property(nonatomic,strong) SobotChatMessage *tempModel;

@property(nonatomic,strong) NSLayoutConstraint *iconPL;
@property(nonatomic,strong) NSLayoutConstraint *iconEW;
@property(nonatomic,strong) NSLayoutConstraint *nickLabPL;

@property(nonatomic,copy) NSString *clickUrl;
@end

@implementation ZCChatReferenceAppletCell

-(void)layoutSubViewUI{
    [super layoutSubViewUI];
    // 移除viewcontent的所有子view
    [self.viewContent.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _bgView = ({
        UIView *iv = [[UIView alloc]init];
        [self.viewContent addSubview:iv];
        iv.backgroundColor = UIColorFromModeColorAlpha(SobotColorWhite, 0.14);
        [self.viewContent addConstraint:sobotLayoutPaddingTop(0, iv, self.viewContent)];
        [self.viewContent addConstraint:sobotLayoutPaddingLeft(0, iv, self.viewContent)];
        [self.viewContent addConstraint:sobotLayoutPaddingRight(0, iv, self.viewContent)];
        [self.viewContent addConstraint:sobotLayoutEqualHeight(40, iv, NSLayoutRelationEqual)];
        [self.viewContent addConstraint:sobotLayoutPaddingBottom(0, iv, self.viewContent)];
        iv;
    });
    
    _iconImg = ({
        SobotImageView *iv = [[SobotImageView alloc]init];
        [self.bgView addSubview:iv];
        self.iconPL = sobotLayoutPaddingLeft(9, iv, self.bgView);
        [self.bgView addConstraint:self.iconPL];
        [self.bgView addConstraint:sobotLayoutEqualCenterY(0, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutEqualHeight(13, iv, NSLayoutRelationEqual)];
        self.iconEW = sobotLayoutEqualWidth(11, iv, NSLayoutRelationEqual);
        [self.bgView addConstraint:self.iconEW];
        [_iconImg loadWithURL:[NSURL URLWithString:@""] placeholer:SobotKitGetImage(@"zciocn_location_nol") showActivityIndicatorView:NO];
        iv.hidden = YES;
        iv;
    });
    
    _rightImg = ({
        SobotImageView *iv = [[SobotImageView alloc]init];
        [self.bgView addSubview:iv];
        [self.bgView addConstraint:sobotLayoutEqualCenterY(0, iv, self.bgView)];
        [self.bgView addConstraints:sobotLayoutSize(20, 20, iv, NSLayoutRelationEqual)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-10, iv, self.bgView)];
        iv;
    });
    
    _nickLab = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.bgView addSubview:iv];
        iv.font = SobotFont13;
        iv.numberOfLines = 1;
        iv.lineBreakMode = 4;
        iv.textColor = UIColorFromKitModeColor(SobotColorWhite);
        [self.bgView addConstraint:sobotLayoutEqualCenterY(0, iv, self.bgView)];
        self.nickLabPL = sobotLayoutMarginLeft(3, iv, self.iconImg);
        [self.bgView addConstraint:self.nickLabPL];
        [self.bgView addConstraint:sobotLayoutMarginRight(-3, iv, self.rightImg)];
        iv;
    });
    
    UITapGestureRecognizer *tapGesturer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bgViewClick:)];
    self.bgView.userInteractionEnabled=YES;
    [self.bgView addGestureRecognizer:tapGesturer];
    
}

-(void)bgViewClick:(UITapGestureRecognizer *) tap{
    if(sobotConvertToString(self.clickUrl).length  == 0){
        return;
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(onReferenceCellEvent:type:state:obj:)]){
        if(self.tempModel.richModel.type == SobotMessageRichJsonTypeLocation){
            [self.delegate onReferenceCellEvent:self.tempModel type:ZCChatReferenceCellEventOpenLocation state:1 obj:sobotConvertToString(self.clickUrl)];
        }else if (self.tempModel.richModel.type == SobotMessageRichJsonTypeApplet){
            [self.delegate onReferenceCellEvent:self.tempModel type:ZCChatReferenceCellEventAppletAction state:1 obj:self.tempModel];
        }else{
            [self.delegate onReferenceCellEvent:self.tempModel type:ZCChatReferenceCellEventOpenURL state:1 obj:sobotConvertToString(self.clickUrl)];
        }
        
    }
}



-(void)dataToView:(SobotChatMessage *)message{
    [super dataToView:message];
    self.tempModel = message;
    
    self.iconPL.constant =0;
    self.iconEW.constant = 0;
    self.iconImg.hidden = YES;
    self.nickLabPL.constant = 9;
    if(message.richModel.type == SobotMessageRichJsonTypeApplet){
        if (sobotConvertToString(message.richModel.richContent.logo).length > 0) {
            // 有APP图标
            [_rightImg loadWithURL:[NSURL URLWithString:sobotConvertToString(message.richModel.richContent.logo)] placeholer:SobotKitGetImage(@"zcicon_applet_sml") showActivityIndicatorView:NO];
        }else{
            [_rightImg loadWithURL:[NSURL URLWithString:@""] placeholer:SobotKitGetImage(@"zcicon_applet_sml") showActivityIndicatorView:NO];
        }
        _nickLab.text = sobotConvertToString(message.richModel.richContent.title);
//        self.iconPL.constant =9;
//        self.iconEW.constant = 11;
//        self.iconImg.hidden = yes;
//        self.nickLabPL.constant = 3;
//        [_iconImg loadWithURL:[NSURL URLWithString:@""] placeholer:SobotKitGetImage(@"zciocn_location_nol") showActivityIndicatorView:NO];
    }else if (message.richModel.type == SobotMessageRichJsonTypeArticle){
            // 有APP图标
            [_rightImg loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(message.richModel.richContent.snapshot)] placeholer:SobotKitGetImage(@"zcicon_default_goods_1")  showActivityIndicatorView:NO];
        _nickLab.text = sobotConvertToString(message.richModel.richContent.title);
        self.clickUrl = sobotConvertToString(message.richModel.richContent.richMoreUrl);
    }else if (message.richModel.type == SobotMessageRichJsonTypeLocation){
        self.iconPL.constant =9;
        self.iconEW.constant = 11;
        self.iconImg.hidden = NO;
        self.nickLabPL.constant = 3;
        [_iconImg loadWithURL:[NSURL URLWithString:@""] placeholer:SobotKitGetImage(@"zciocn_location_nol") showActivityIndicatorView:NO];
        [_rightImg loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(message.richModel.richContent.picUrl)] placeholer:SobotKitGetImage(@"zcicon_default_goods_1") showActivityIndicatorView:NO];
        [_nickLab setText:sobotTrimString(message.richModel.richContent.title)];
        
        NSString * link = self.tempModel.richModel.richContent.url;
        
        if(sobotConvertToString(link).length  == 0){
            link = [NSString stringWithFormat:@"%@?longitude=%@&latitude=%@&name=%@&address=%@",@"sobot://openlocation",self.tempModel.richModel.richContent.lng,self.tempModel.richModel.richContent.lat,self.tempModel.richModel.richContent.title,self.tempModel.richModel.richContent.label];
        }
        self.clickUrl = link;
    }
    
    [self showContent:@"" view:_bgView btm:nil isMaxWidth:YES customViewWidth:ScreenWidth];
}

@end
