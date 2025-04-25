//
//  ZCServiceListCell.m
//  SobotKit
//
//  Created by lizh on 2022/9/27.
//

#import "ZCServiceListCell.h"

@interface  ZCServiceListCell()
{
    
}

@property (nonatomic,strong) UILabel *titleLab;
@property (nonatomic,strong) SobotImageView *img;

@end

@implementation ZCServiceListCell

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
    _img = ({
        SobotImageView *iv = [[SobotImageView alloc]init];
        [self.contentView addSubview:iv];
        [iv setContentMode:UIViewContentModeScaleAspectFit];
        iv.image = SobotKitGetImage(@"zcicon_list_right_arrow");
        [self.contentView addConstraint:sobotLayoutEqualWidth(12, iv, NSLayoutRelationEqual)];
        [self.contentView addConstraint:sobotLayoutEqualHeight(14, iv, NSLayoutRelationEqual)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-16, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutEqualCenterY(0, iv, self.contentView)];
        iv;
    });
    
    _titleLab = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.contentView addSubview:iv];
        iv.textColor = UIColorFromKitModeColor(SobotColorTextMain);
        iv.textAlignment = NSTextAlignmentLeft;
        iv.numberOfLines = 2;
        iv.font = SobotFont14;
        [self.contentView addConstraint:sobotLayoutPaddingLeft(16, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-40, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingTop(14, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(-14, iv, self.contentView)];
        iv;
    });
}

-(void)initWithModel:(ZCSCListModel *)model width:(CGFloat) tableWidth{
    NSLog(@"model.questionTitle ==== %@",model.questionTitle);
    _titleLab.text = sobotConvertToString(model.questionTitle);
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
