//
//  ZCOrderCheckCell.m
//  SobotKit
//
//  Created by lizh on 2022/9/14.
//

#import "ZCOrderCheckCell.h"
#import <SobotChatClient/SobotChatClient.h>
#import <SobotCommon/SobotCommon.h>
#import "ZCUIKitTools.h"

@interface ZCOrderCheckCell()

@property (nonatomic,strong) UIView *bgView;
@property(nonatomic,strong) NSLayoutConstraint *labelContentPT;
@property(nonatomic,strong) NSLayoutConstraint *iconEH;
@property(nonatomic,strong) NSLayoutConstraint *iconEW;
@end

@implementation ZCOrderCheckCell

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
    self.labelName = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.contentView addSubview:iv];
        iv.font = SobotFont14;
        iv.numberOfLines = 0;
        iv.textColor = UIColorFromKitModeColor(SobotColorTextSub);
        [self.contentView addConstraint:sobotLayoutPaddingLeft(EditCellHSpec, iv, self.contentView)];
        self.labelNamePT = sobotLayoutPaddingTop(EditCellPT, iv, self.contentView);
        [self.contentView addConstraint:self.labelNamePT];
        self.labelNameEH = sobotLayoutEqualHeight(EditCellTitleH, iv, NSLayoutRelationGreaterThanOrEqual);
        [self.contentView addConstraint:self.labelNameEH];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-EditCellHSpec, iv, self.contentView)];
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            iv.textAlignment = NSTextAlignmentRight;
        }else{
            iv.textAlignment = NSTextAlignmentLeft;
        }
        iv;
    });
    
    _imgArrow = ({
       UIImageView *iv = [[UIImageView alloc]init];
        [self.contentView addSubview:iv];
        [self.contentView addConstraint:sobotLayoutEqualCenterY(0, iv, self.contentView)];
        self.iconEH = sobotLayoutEqualHeight(12, iv, NSLayoutRelationEqual);
        self.iconEW = sobotLayoutEqualWidth(7, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.iconEH];
        [self.contentView addConstraint:self.iconEW];
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            [self.contentView addConstraint:sobotLayoutPaddingLeft(EditCellHSpec, iv, self.contentView)];
        }else{
            [self.contentView addConstraint:sobotLayoutPaddingRight(-EditCellHSpec, iv, self.contentView)];
        }
        iv;
    });
    
    _labelContent = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.contentView addSubview:iv];
        [iv setTextColor:UIColorFromKitModeColor(SobotColorTextSub1)];
        [iv setFont:SobotFont14];
        iv.numberOfLines = 1;
        self.labelContentPT = sobotLayoutMarginTop(EditCellMT, iv, self.labelName);
        [self.contentView addConstraint:self.labelContentPT];
        [self.contentView addConstraint:sobotLayoutEqualHeight(EditCellTitleH, iv, NSLayoutRelationEqual)];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(-EditCellPT, iv, self.contentView)];
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            [self.contentView addConstraint:sobotLayoutPaddingLeft(EditCellHSpec, iv, self.contentView)];
            [self.contentView addConstraint:sobotLayoutPaddingRight(-EditCellHSpec, iv, self.contentView)];
            iv.textAlignment = NSTextAlignmentRight;
        }else{
            [self.contentView addConstraint:sobotLayoutPaddingLeft(EditCellHSpec, iv, self.contentView)];
            [self.contentView addConstraint:sobotLayoutPaddingRight(-EditCellHSpec, iv, self.contentView)];
            iv.textAlignment = NSTextAlignmentLeft;
        }
        iv;
    });
    
    self.lineView = ({
        UIView *iv = [[UIView alloc]init];
        [self.contentView addSubview:iv];
        iv.backgroundColor = UIColorFromKitModeColor(SobotColorBgTopLine);
        self.lineViewPL = sobotLayoutPaddingLeft(16, iv, self.contentView);
        [self.contentView addConstraint:self.lineViewPL];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutEqualHeight(0.5, iv, NSLayoutRelationEqual)];
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            self.lineViewPL.constant = 0;
            [self.contentView addConstraint:sobotLayoutPaddingRight(-16, iv, self.contentView)];
        }else{
            [self.contentView addConstraint:sobotLayoutPaddingRight(0, iv, self.contentView)];
        }
        iv;
    });
}


-(void)initDataToView:(NSDictionary *)dict{
    [self checkLabelState:NO];
    self.labelName.attributedText = [self getOtherColorString:@"*" Color:[UIColor redColor] withString:dict[@"dictDesc"]];
       if(!sobotIsNull(dict[@"dictValue"])){
           [_labelContent setText:dict[@"dictValue"]];
//           [_labelContent setTextColor:UIColorFromKitModeColor(SobotColorTextSub)];
           [_labelContent setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
           [_labelContent setFont:SobotFont14];
       }else{
           [_labelContent setText:@""];
           NSString *plStr = SobotKitLocalString(@"请选择");
           [_labelContent setText:plStr];
           [_labelContent setFont:SobotFont14];
           [_labelContent setTextColor:UIColorFromKitModeColor(SobotColorTextSub1)];
       }
       if([dict[@"propertyType"] intValue] == 3){
           _imgArrow.hidden = YES;
       }else{
           _imgArrow.hidden = NO;
       }
    
    // 查看数据类型 区分 监听还是时间icon
    int dictType = [[dict objectForKey:@"dictType"] intValue];
    // 0，特殊行   1 单行文本 2 多行文本 3 日期 4 时间 5 数值 6 下拉列表 7 复选框 8 单选框 9 级联字段  11 地区 12 日期+时间
    if ((dictType == 3 || dictType == 12) && ![@"ticketType" isEqual:sobotConvertToString([dict objectForKey:@"dictName"])]) {
        [_imgArrow setImage:[SobotUITools getSysImageByName:@"zcion_time"]];
        self.iconEH.constant = 14;
        self.iconEW.constant = 14;
    }else if ( dictType == 4){
        [_imgArrow setImage:[SobotUITools getSysImageByName:@"zcion_time_only"]];
        self.iconEH.constant = 14;
        self.iconEW.constant = 14;
    }else{
        [_imgArrow setImage:[SobotUITools getSysImageByName:@"zcicon_arrow_right_record"]];
        self.iconEH.constant = 12;
        self.iconEW.constant = 7;
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            _imgArrow.transform = CGAffineTransformMakeRotation(M_PI);  // M_PI_4 是 45 度
        }
    }
    
}

-(BOOL)checkLabelState:(BOOL) showSmall{
    BOOL isSmall = [super checkLabelState:showSmall text:@""];
    return isSmall;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
