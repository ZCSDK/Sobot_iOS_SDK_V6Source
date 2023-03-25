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
@interface ZCMsgRecordCell()
{
    
}
@property (nonatomic,strong) UILabel * titleLab;// 留言消息
@property (nonatomic,strong) UIImageView * picLab; // 新工单图标
@property (nonatomic,strong) UILabel * statusLab;
@property (nonatomic,strong) UILabel * timeLab;
@property (nonatomic,strong) UIView * bgView;
// 2.8.0 增加两条线
@property (nonatomic,strong) UIView * topLineView;
@property (nonatomic,strong) UIView * bottomLineView;

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
        [self.contentView addConstraint:sobotLayoutPaddingTop(10, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutEqualHeight(110, iv, NSLayoutRelationEqual)];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(0, iv, self.contentView)];
        iv;
    });
    
    _topLineView = ({
        UIView *iv = [[UIView alloc]init];
        iv.backgroundColor = UIColorFromKitModeColor(SobotColorBgLine);
        [self.bgView addSubview:iv];
        [self.bgView addConstraint:sobotLayoutPaddingTop(0, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(0, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutEqualHeight(0.5, iv, NSLayoutRelationEqual)];
        iv;
    });
    
    _timeLab = ({
        UILabel *iv = [[UILabel alloc]init];
        iv.textAlignment = NSTextAlignmentLeft;
        iv.font = SobotFontBold16;
        iv.textColor = UIColorFromKitModeColor(SobotColorTextMain);
        [self.bgView addSubview:iv];
        [self.bgView addConstraint:sobotLayoutPaddingTop(16, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(20, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutEqualWidth(170, iv, NSLayoutRelationEqual)];
        [self.bgView addConstraint:sobotLayoutEqualHeight(20, iv, NSLayoutRelationEqual)];
        iv;
    });
    
    _picLab = ({
        UIImageView *iv = [[UIImageView alloc]init];
        [self.bgView addSubview:iv];
        [iv setImage:[SobotUITools getSysImageByName:@"zcicon_new_tag"]];
        [self.bgView addConstraint:sobotLayoutMarginLeft(5, iv, self.timeLab)];
        [self.bgView addConstraint:sobotLayoutPaddingTop(22, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutEqualHeight(14, iv, NSLayoutRelationEqual)];
        [self.bgView addConstraint:sobotLayoutEqualWidth(26, iv, NSLayoutRelationEqual)];
        iv.hidden = YES;
        iv;
    });
    
    _titleLab = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.bgView addSubview:iv];
        iv.textColor = UIColorFromKitModeColor(SobotColorTextSub);
        iv.font = SobotFont14;
        [self.bgView addConstraint:sobotLayoutPaddingLeft(20, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingTop(47, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutEqualHeight(20, iv, NSLayoutRelationEqual)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-122, iv, self.bgView)];
        iv;
    });
    
    _statusLab = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.bgView addSubview:iv];
        iv.textAlignment = NSTextAlignmentCenter;
        iv.textColor = UIColorFromKitModeColor(SobotColorTextWhite);
        iv.font = SobotFont14;
        iv.layer.masksToBounds = YES;
        iv.layer.cornerRadius = 15;
        [self.bgView addConstraint:sobotLayoutPaddingRight(-20, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingBottom(-24, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutEqualHeight(30, iv, NSLayoutRelationEqual)];
        [self.bgView addConstraint:sobotLayoutEqualWidth(72, iv, NSLayoutRelationEqual)];
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
    [self setString:sobotConvertToString(model.content) withlLabel:_titleLab withColor:UIColorFromKitModeColor(SobotColorTextSub)];
    _timeLab.text = sobotConvertToString(SobotDateTransformString(@"YYYY-MM-dd HH:mm:ss", sobotStringFormateDate(model.timeStr)));
    _picLab.hidden = YES;
    if (model.newFlag == 2) {
        _picLab.hidden = YES;
    }
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
