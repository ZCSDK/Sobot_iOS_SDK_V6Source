//
//  ZCCheckTypeViewCell.m
//  SobotKit
//
//  Created by lizh on 2025/1/14.
//

#import "ZCCheckTypeViewCell.h"
// **编辑cell的间距**
// 左右间距 16
#define  EditCellHSpec 16
// 标题行高 22
#define  EditCellTitleH 22
// 单行高度 72
#define  EditCellBGH 72
// 多行高度 112
#define  EditCellMBGH 112
// 标题上间距 12 和下间距 12
#define  EditCellPT 12
// 组件之间的上下间距 4
#define  EditCellMT 4

@interface ZCCheckTypeViewCell()
{
    
}
@property (nonatomic,strong)NSLayoutConstraint *iconEH;
@property (nonatomic,strong)NSLayoutConstraint *iconEW;
@end

@implementation ZCCheckTypeViewCell


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
            [self.contentView addConstraint:sobotLayoutPaddingLeft(44, iv, self.contentView)];
            [self.contentView addConstraint:sobotLayoutPaddingRight(-EditCellHSpec, iv, self.contentView)];
            iv.textAlignment = NSTextAlignmentRight;
        }else{
            [self.contentView addConstraint:sobotLayoutPaddingLeft(EditCellHSpec, iv, self.contentView)];
            [self.contentView addConstraint:sobotLayoutPaddingRight(-44, iv, self.contentView)];
            iv.textAlignment = NSTextAlignmentLeft;
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
        
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            [self.contentView addConstraint:sobotLayoutPaddingLeft(16, iv, self.contentView)];
        }else{
            [self.contentView addConstraint:sobotLayoutPaddingRight(-16, iv, self.contentView)];
        }
        
        iv.hidden = NO;
        iv;
    });
    
}

-(void)initDataToView:(ZCLibTicketTypeModel *)model isSel:(BOOL)isSel isNext:(BOOL)isNext{
//    ZCOrderCusFieldsDetailModel *model = [_searchArray objectAtIndex:indexPath.row];
    _labelName.text = model.typeName;
        _iconImg.transform = CGAffineTransformMakeRotation(0);
    if (isNext) {
        [_iconImg setImage:[SobotUITools getSysImageByName:@"zcicon_arrow_right_record_new"]];
        self.iconEW.constant = 10;
        self.iconEH.constant = 20;
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            _iconImg.transform = CGAffineTransformMakeRotation(M_PI);
        }
    }else{
        [_iconImg setImage:[SobotUITools getSysImageByName:@""]];
    }
    if (isSel) {
        UIImage *img = [[SobotUITools getSysImageByName:@"zcion_mor_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_iconImg setImage:img];
        _iconImg.tintColor = [ZCUIKitTools zcgetServerConfigBtnBgColor];
        self.iconEW.constant = 20;
        self.iconEH.constant = 20;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
