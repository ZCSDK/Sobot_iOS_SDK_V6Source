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
    _bgView = ({
        UIView *iv = [[UIView alloc]init];
        [self.contentView addSubview:iv];
        [iv setBackgroundColor:[UIColor clearColor]];
        [self.contentView addConstraint:sobotLayoutPaddingTop(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(0, iv, self.contentView)];
        NSLayoutConstraint *bgPB = sobotLayoutPaddingBottom(0, iv, self.contentView);
        bgPB.priority = UILayoutPriorityFittingSizeLevel;
        [self.contentView addConstraint:bgPB];
        [self.contentView addConstraint:sobotLayoutEqualHeight(55, iv, NSLayoutRelationEqual)];
        iv;
    });
    
    self.labelName = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.contentView addSubview:iv];
        iv.font = SobotFont14;
        iv.textColor = UIColorFromKitModeColor(SobotColorTextMain);
        [self.contentView addConstraint:sobotLayoutPaddingLeft(20, iv, self.contentView)];
        self.labelNamePT = sobotLayoutPaddingTop(17, iv, self.contentView);
        [self.contentView addConstraint:self.labelNamePT];
        self.labelNameEH = sobotLayoutEqualHeight(20, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.labelNameEH];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-20, iv, self.contentView)];
        iv;
    });
    
    _imgArrow = ({
       UIImageView *iv = [[UIImageView alloc]init];
        iv.image = [SobotUITools getSysImageByName:@"zcicon_arrow_right_record"];
        [self.contentView addSubview:iv];
//        [self.contentView addConstraint:sobotLayoutPaddingTop(54/2-12/2, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutEqualCenterY(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-25, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutEqualHeight(12, iv, NSLayoutRelationEqual)];
        [self.contentView addConstraint:sobotLayoutEqualWidth(7, iv, NSLayoutRelationEqual)];
        iv;
    });
    
    _labelContent = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.contentView addSubview:iv];
        [iv setTextColor:UIColorFromKitModeColor(SobotColorTextSub1)];
        [iv setFont:SobotFontBold14];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(20, iv, self.contentView)];
        self.labelContentPT = sobotLayoutPaddingTop(17, iv, self.contentView);
        [self.contentView addConstraint:self.labelContentPT];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-20, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutEqualHeight(20, iv, NSLayoutRelationEqual)];
        iv;
    });
}


-(void)initDataToView:(NSDictionary *)dict{
    if (self.labelNamePT) {
        [self.contentView removeConstraint:self.labelNamePT];
    }
    [self checkLabelState:NO];
    self.labelName.attributedText = [self getOtherColorString:@"*" Color:[UIColor redColor] withString:dict[@"dictDesc"]];
       if(!sobotIsNull(dict[@"dictValue"])){
           [_labelContent setText:dict[@"dictValue"]];
           [_labelContent setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
       }else{
           [_labelContent setText:@""];
           [_labelContent setTextColor:UIColorFromKitModeColor(SobotColorTextSub1)];
       }
       if([dict[@"propertyType"] intValue] == 3){
           _imgArrow.hidden = YES;
       }else{
           _imgArrow.hidden = NO;
       }
}

-(BOOL)checkLabelState:(BOOL) showSmall{
    BOOL isSmall = [super checkLabelState:showSmall text:@""];
    if(!isSmall){
        self.labelContentPT.constant = 17;
    }else{
        self.labelContentPT.constant = 29;
    }
    return isSmall;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
