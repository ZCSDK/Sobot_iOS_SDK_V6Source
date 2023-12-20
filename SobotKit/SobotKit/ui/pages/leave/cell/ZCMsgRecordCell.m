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
@property (nonatomic,strong) UILabel *descLab;// 描述
@property (nonatomic,strong) UILabel * timeLab;
@property (nonatomic,strong) UIView * bgView;
// 2.8.0 增加两条线
@property (nonatomic,strong) UIView * topLineView;
@property (nonatomic,strong) UIView * bottomLineView;

@property (nonatomic,strong)NSLayoutConstraint *bgviewH;
@property (nonatomic,strong)NSLayoutConstraint *descLabMT;
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
        self.backgroundColor = [ZCUIKitTools zcgetLightGrayDarkBackgroundColor];
    }
    return self;
}

-(void)createItemsView{

    _bgView = ({
        UIView *iv = [[UIView alloc]init];
        iv.backgroundColor = [ZCUIKitTools zcgetMsgRecordCellBgColor];
        [self.contentView addSubview:iv];
        [self.contentView addConstraint:sobotLayoutPaddingTop(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(0, iv, self.contentView)];
        self.bgviewH = sobotLayoutEqualHeight(142, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.bgviewH];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(0, iv, self.contentView)];
        iv;
    });
    
//    _topLineView = ({
//        UIView *iv = [[UIView alloc]init];
//        iv.backgroundColor = UIColorFromKitModeColor(SobotColorBgLine);
//        [self.bgView addSubview:iv];
//        [self.bgView addConstraint:sobotLayoutPaddingTop(0, iv, self.bgView)];
//        [self.bgView addConstraint:sobotLayoutPaddingLeft(0, iv, self.bgView)];
//        [self.bgView addConstraint:sobotLayoutPaddingRight(0, iv, self.bgView)];
//        [self.bgView addConstraint:sobotLayoutEqualHeight(0.5, iv, NSLayoutRelationEqual)];
//        iv;
//    });
    
    _titleLab = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.bgView addSubview:iv];
        iv.textColor = UIColorFromKitModeColor(SobotColorTextMain);
        iv.font = SobotFontBold15;
        iv.numberOfLines = 1;
        iv.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.bgView addConstraint:sobotLayoutPaddingLeft(20, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingTop(20, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-20, iv, self.bgView)];
        iv;
    });
    
    _statusLab = ({
        ZCStatusLab *iv = [[ZCStatusLab alloc]init];
        [self.bgView addSubview:iv];
        iv.textAlignment = NSTextAlignmentCenter;
        iv.textColor = UIColorFromKitModeColor(SobotColorTextWhite);
        iv.font = SobotFont14;
        iv.layer.masksToBounds = YES;
        iv.layer.cornerRadius = 16;
//        iv.numberOfLines = 1;
        [self.bgView addConstraint:sobotLayoutPaddingRight(-18, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutEqualWidth(83, iv, NSLayoutRelationEqual)];
        [self.bgView addConstraint:sobotLayoutEqualHeight(32, iv, NSLayoutRelationEqual)];
        [self.bgView addConstraint:sobotLayoutEqualCenterY(0, iv, self.bgView)];
        iv.textInsets = UIEdgeInsetsMake(0.f, 10.f, 0.f, 10.f);
        iv;
    });
    
    _descLab = ({
        UILabel *iv = [[UILabel alloc]init];
        iv.textColor = UIColorFromKitModeColor(SobotColorTextSub);
        iv.font = SobotFont13;
        [self.bgView addSubview:iv];
        iv.numberOfLines = 2;
        self.descLabMT = sobotLayoutMarginTop(8, iv, self.titleLab);
        [self.bgView addConstraint:self.descLabMT];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(20, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutMarginRight(-16, iv, self.statusLab)];
//        [self.bgView addConstraint:sobotLayoutEqualHeight(44, iv, NSLayoutRelationEqual)];
        iv;
    });
    
    _timeLab = ({
        UILabel *iv = [[UILabel alloc]init];
        iv.textAlignment = NSTextAlignmentLeft;
        iv.font = SobotFont12;
        iv.textColor = UIColorFromKitModeColor(SobotColorTextSub);
        [self.bgView addSubview:iv];
//        [self.bgView addConstraint:sobotLayoutMarginTop(8, iv, self.descLab)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(20, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-20, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutEqualHeight(20, iv, NSLayoutRelationEqual)];
        [self.bgView addConstraint:sobotLayoutPaddingBottom(-20, iv, self.bgView)];
        iv;
    });
    
    _bottomLineView = ({
        UIView *iv = [[UIView alloc]init];
        [self.bgView addSubview:iv];
        iv.backgroundColor = UIColorFromKitModeColor(SobotColorBgLine);
        [self.bgView addConstraint:sobotLayoutPaddingBottom(-0.5, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(0, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutEqualHeight(0.5, iv, NSLayoutRelationEqual)];
        iv;
    });
}

-(void)initWithDict:(ZCRecordListModel*)model with:(CGFloat) width{

    if(sobotConvertToString(model.ticketTitle).length > 0){
        self.titleLab.text = sobotConvertToString(model.ticketTitle);
        self.bgviewH.constant = 142;
        self.descLabMT.constant = 8;
    }else{
        self.titleLab.text = @"";
        self.descLabMT.constant = 0;
        self.bgviewH.constant = 92;
    }
    
    
    [self setString:sobotConvertToString(model.content) withlLabel:_descLab withColor:UIColorFromKitModeColor(SobotColorTextSub)];
    _descLab.lineBreakMode = NSLineBreakByTruncatingTail;
    _timeLab.text = sobotConvertToString(sobotDateTransformString(@"YYYY-MM-dd HH:mm:ss", sobotStringFormateDate(model.timeStr)));
    _statusLab.text = SobotKitLocalString(@"已创建");
        switch (model.flag) {
        case 1:
            _statusLab.text =  SobotKitLocalString(@"已创建");
            _statusLab.backgroundColor = UIColorFromModeColor(SobotColorTextSub1);
            break;
        case 2:
            _statusLab.text =  SobotKitLocalString(@"受理中");
            _statusLab.backgroundColor = UIColorFromKitModeColor(SobotColorYellow);
            break;
        case 3:
            _statusLab.text =  SobotKitLocalString(@"已完成");
            _statusLab.backgroundColor = UIColorFromKitModeColor(SobotColorTheme);
            break;
        default:
            break;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

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
