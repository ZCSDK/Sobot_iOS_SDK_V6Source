//
//  ZCCheckMulCusFieldCell.m
//  SobotKit
//
//  Created by lizh on 2025/1/10.
//

#import "ZCCheckMulCusFieldCell.h"

@interface ZCCheckMulCusFieldCell()
@property (nonatomic,strong)NSLayoutConstraint *iconEH;
@property (nonatomic,strong)NSLayoutConstraint *iconEW;

@end
@implementation ZCCheckMulCusFieldCell

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
    }
    return self;
}

#pragma mark - 布局子控件
-(void)createItemsView{
    // 423 新版UI改版 左右16间距
    // 新版UI 标题全部显示 换行展示全部 高度要自适应增加 行高大于等于22
    _labelName = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.contentView addSubview:iv];
        iv.font = SobotFont14;
        iv.numberOfLines = 0;
        iv.textColor = UIColorFromKitModeColor(SobotColorTextMain);
        [self.contentView addConstraint:sobotLayoutPaddingTop(8, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutEqualHeight(EditCellTitleH, iv, NSLayoutRelationGreaterThanOrEqual)];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(-8, iv, self.contentView)];
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            iv.textAlignment = NSTextAlignmentRight;
            [self.contentView addConstraint:sobotLayoutPaddingRight(-EditCellHSpec, iv, self.contentView)];
            [self.contentView addConstraint:sobotLayoutPaddingLeft(44, iv, self.contentView)];
        }else{
            iv.textAlignment = NSTextAlignmentLeft;
            [self.contentView addConstraint:sobotLayoutPaddingLeft(EditCellHSpec, iv, self.contentView)];
            [self.contentView addConstraint:sobotLayoutPaddingRight(-44, iv, self.contentView)];
        }
        iv;
    });
    _iconImg = ({
        UIImageView *iv = [[UIImageView alloc]init];
        [self.contentView addSubview:iv];
        [iv setImage:[SobotUITools getSysImageByName:@"zcicon_arrow_right_record"]];
        [self.contentView addConstraint:sobotLayoutEqualCenterY(0, iv, self.contentView)];
        self.iconEH = sobotLayoutEqualHeight(20, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.iconEH];
        self.iconEW = sobotLayoutEqualWidth(20, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.iconEW];
        iv.hidden = NO;
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            [self.contentView addConstraint:sobotLayoutPaddingLeft(16, iv, self.contentView)];
        }else{
            [self.contentView addConstraint:sobotLayoutPaddingRight(-16, iv, self.contentView)];
        }
        iv;
    });
}

-(void)initDataToView:(ZCOrderCusFieldsDetailModel *)model isSel:(BOOL)isSel isNext:(BOOL)isNext{
//    ZCOrderCusFieldsDetailModel *model = [_searchArray objectAtIndex:indexPath.row];
    _labelName.text = model.dataName;
    if (isNext) {
        [_iconImg setImage:[SobotUITools getSysImageByName:@"zcicon_arrow_right_record_new"]];
        self.iconEW.constant = 10;
        self.iconEH.constant = 20;
    }else{
        [_iconImg setImage:[SobotUITools getSysImageByName:@""]];
    }
    if (isSel) {
        UIImage *img = [[SobotImageTools sobotScaleToSize:CGSizeMake(12, 12) with:SobotKitGetImage(@"zcion_mor_sel")] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_iconImg setImage:img];
        _iconImg.tintColor = [ZCUIKitTools zcgetServerConfigBtnBgColor];
        self.iconEW.constant = 20;
        self.iconEH.constant = 20;
    }
    if ([ZCUIKitTools getSobotIsRTLLayout]) {
        _iconImg.transform = CGAffineTransformMakeRotation(M_PI);  // M_PI_4 是 45 度
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
