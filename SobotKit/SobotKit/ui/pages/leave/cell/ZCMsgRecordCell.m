//
//  ZCMsgRecordCell.m
//  SobotKit
//
//  Created by lizh on 2022/9/7.
//

#import "ZCMsgRecordCell.h"
#import "ZCUIKitTools.h"
#import <SobotCommon/SobotCommon.h>
#import "SobotHtmlFilter.h"
#import "ZCStatusLab.h"
@interface ZCMsgRecordCell()
{
    
}
@property (nonatomic,strong) UILabel * titleLab;// 留言消息
@property (nonatomic,strong) UIImageView * picLab; // 新工单图标
@property (nonatomic,strong) ZCStatusLab * statusLab;
@property (nonatomic,strong) UILabel * timeLab;
@property (nonatomic,strong) UIView * bgView;

@property(nonatomic,strong) NSLayoutConstraint *bgViewPT;
@property(nonatomic,strong) NSLayoutConstraint *statusLabW;
@property(nonatomic,strong) NSLayoutConstraint *SPT;
@end

@implementation ZCMsgRecordCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self createItemsView];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.userInteractionEnabled=YES;
        [self createItemsView];
//        self.backgroundColor = [ZCUIKitTools zcgetLightGrayDarkBackgroundColor];
        self.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
    }
    return self;
}

-(void)createItemsView{
  // 底部边框
    _bgView = ({
        UIView *iv = [[UIView alloc]init];
        iv.backgroundColor = UIColor.clearColor;
        iv.layer.borderWidth = 1;
        iv.layer.borderColor = UIColorFromKitModeColor(SobotColorBgTopLine).CGColor;
        iv.layer.masksToBounds = YES;
        iv.layer.cornerRadius = 8.0f;
        [self.contentView addSubview:iv];
        self.bgViewPT = sobotLayoutPaddingTop(16, iv, self.contentView);
        [self.contentView addConstraint:self.bgViewPT];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(16, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-16, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(0, iv, self.contentView)];
        iv;
    });
    
    _timeLab = ({
        UILabel *iv = [[UILabel alloc]init];
        iv.textAlignment = NSTextAlignmentLeft;
        iv.font = SobotFont14;
        iv.textColor = UIColorFromKitModeColor(SobotColorTextSub1);
        [self.bgView addSubview:iv];
        [self.bgView addConstraint:sobotLayoutPaddingTop(12, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutEqualHeight(22, iv, NSLayoutRelationEqual)];
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            [self.bgView addConstraint:sobotLayoutPaddingRight(-16, iv, self.bgView)];
        }else{
            [self.bgView addConstraint:sobotLayoutPaddingLeft(16, iv, self.bgView)];
        }
        iv;
    });
    
    // 小红标
    _picLab = ({
        UIImageView *iv = [[UIImageView alloc]init];
        [iv setImage:SobotKitGetImage(@"zcicon_new_tag")];
        [self.bgView addSubview:iv];
        [self.bgView addConstraints:sobotLayoutSize(25, 12, iv, NSLayoutRelationEqual)];
        [self.bgView addConstraint:sobotLayoutEqualCenterY(0, iv, self.timeLab)];
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            [self.bgView addConstraint:sobotLayoutMarginRight(-4, iv, self.timeLab)];
        }else{
            [self.bgView addConstraint:sobotLayoutMarginLeft(4, iv, self.timeLab)];
        }
        iv.hidden = YES;
        iv;
    });
    
    // 切左下和右上圆角 8
    _statusLab = ({
        ZCStatusLab *iv = [[ZCStatusLab alloc]init];
        [self.contentView addSubview:iv];
        iv.textAlignment = NSTextAlignmentCenter;
        iv.textColor = UIColorFromKitModeColor(SobotColorTextWhite);
        iv.font = SobotFont12;
        self.statusLabW = sobotLayoutEqualWidth(52, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.statusLabW];
        [self.contentView addConstraint:sobotLayoutEqualHeight(24, iv, NSLayoutRelationEqual)];
        self.SPT = sobotLayoutPaddingTop(16, iv, self.contentView);
        [self.contentView addConstraint:self.SPT];
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            [self.contentView addConstraint:sobotLayoutPaddingLeft(16, iv, self.contentView)];
        }else{
            [self.contentView addConstraint:sobotLayoutPaddingRight(-16, iv, self.contentView)];
        }
        iv;
    });
    
    _titleLab = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.bgView addSubview:iv];
        iv.textColor = UIColorFromKitModeColor(SobotColorTextMain);
        iv.font = SobotFont14;
        iv.numberOfLines = 2;
        iv.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.bgView addConstraint:sobotLayoutPaddingLeft(16, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-16, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutMarginTop(4, iv, self.timeLab)];
        [self.bgView addConstraint:sobotLayoutPaddingBottom(-12, iv , self.bgView)];
        iv;
    });
}

-(void)initWithDict:(ZCRecordListModel*)model with:(CGFloat) width index:(NSInteger)index{
    _statusLab.text = @"";
    [_statusLab.layer.mask removeFromSuperlayer];
    self.statusLabW.constant = 52;
    self.bgViewPT.constant = 12;
    self.SPT.constant = 12;
    if (index == 0) {
        self.bgViewPT.constant = 16;
        self.SPT.constant = 16;
    }
    self.titleLab.text = @"";
    _picLab.hidden = YES;
    if (model.newFlag == 2) {
        _picLab.hidden = NO;
    }
    // 这里要过滤html 标签
    _timeLab.text = sobotConvertToString(sobotDateTransformString(@"YYYY-MM-dd HH:mm:ss", sobotStringFormateDate(model.timeStr)));
    _statusLab.text = [[ZCPlatformTools sharedInstance] getOrderStatus:model.ticketStatus];
    _statusLab.backgroundColor = [[ZCPlatformTools sharedInstance] getOrderStatusTypeBgColor:model.ticketStatus bg:YES];
    _statusLab.textColor = [[ZCPlatformTools sharedInstance] getOrderStatusTypeBgColor:model.ticketStatus bg:NO];
    // 重新设置frame 重绘layer
    CGFloat sw = [self getLabelTextWidthWith:sobotConvertToString(_statusLab.text) font:SobotFont12 hight:24];
    sw = sw + 16;// 左右间距
    self.statusLabW.constant = sw;
    [self.statusLab layoutIfNeeded];
    [ZCUIKitTools addRoundedCorners:UIRectCornerTopRight|UIRectCornerBottomLeft withRadii:CGSizeMake(8, 8) withView:self.statusLab];
    
    //    _titleLab.text = sobotConvertToString(model.content);
        [self setString:sobotConvertToString(model.content) withlLabel:_titleLab withColor:UIColorFromKitModeColor(SobotColorTextMain)];
}

#pragma mark --计算文本宽度 注意字号
-(CGFloat)getLabelTextWidthWith:(NSString *)tip font:(UIFont*)font hight:(CGFloat)hight{;
    CGSize maxSize = CGSizeMake(CGFLOAT_MAX, hight);  // 限制高度为一行
    CGRect textRect = [tip boundingRectWithSize:maxSize
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName: font}
                                         context:nil];
    return textRect.size.width;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

// cell重用方法 重用时会调用这个方法
//-(void)prepareForReuse{
//    [super prepareForReuse];
//}

-(void)setString:(NSString *)string withlLabel:(UILabel *)label withColor:(UIColor *)textColor {
    [SobotHtmlCore filterHtml: [SobotHtmlCore filterHTMLTag:string] result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
        if (text1.length > 0 && text1 != nil) {
            label.attributedText =   [SobotHtmlFilter setHtml:text1 attrs:arr view:label textColor:textColor textFont:label.font linkColor:[ZCUIKitTools zcgetChatLeftLinkColor]];
        }else{
            label.attributedText =   [[NSAttributedString alloc] initWithString:@""];
        }
    }];
}

@end
