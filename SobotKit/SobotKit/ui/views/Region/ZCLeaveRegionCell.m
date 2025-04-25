//
//  ZCLeaveRegionCell.m
//  SobotOrderSDK
//
//  Created by zhangxy on 2024/3/26.
//

#import "ZCLeaveRegionCell.h"
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClient.h>
#import "ZCUIKitTools.h"
@interface ZCLeaveRegionCell(){
    
}
@property(nonatomic,strong) NSLayoutConstraint *layoutImgWidth;
@property(nonatomic,strong) NSLayoutConstraint *layoutIconW;
@property(nonatomic,strong) NSLayoutConstraint *layoutIconH;
@end

@implementation ZCLeaveRegionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.contentView.backgroundColor = UIColorFromModeColor(SobotColorBgMain);
        _labName = ({
            UILabel *iv = [[UILabel alloc]init];
            iv.textAlignment = NSTextAlignmentLeft;
            iv.numberOfLines = 0;
            iv.textColor = UIColorFromModeColor(SobotColorTextMain);
            iv.font = SobotFont14;
            [self.contentView addSubview:iv];
            [self.contentView addConstraint:sobotLayoutPaddingLeft(16, iv, self.contentView)];
            [self.contentView addConstraint:sobotLayoutPaddingTop(15, iv, self.contentView)];
            [self.contentView addConstraint:sobotLayoutPaddingBottom(-15, iv, self.contentView)];
            iv;
        });
        
        _imgArrow = ({
            UIImageView *iv = [[UIImageView alloc]init];
            iv.contentMode = UIViewContentModeScaleAspectFit;
            iv.image = SobotGetImage(@"zcion_mor_sel");
            [self.contentView addSubview:iv];
            iv.backgroundColor = UIColor.clearColor;
            [self.contentView addConstraint:sobotLayoutPaddingRight(-16, iv, self.contentView)];
//            [self.contentView addConstraints:sobotLayoutSize(16, 12, iv, NSLayoutRelationEqual)];
            self.layoutIconW = sobotLayoutEqualWidth(16, iv, NSLayoutRelationEqual);
            self.layoutIconH = sobotLayoutEqualHeight(12, iv, NSLayoutRelationEqual);
            [self.contentView addConstraint:self.layoutIconH];
            [self.contentView addConstraint:self.layoutIconW];
            [self.contentView addConstraint:sobotLayoutEqualCenterY(0, iv, self.contentView)];
            iv.hidden = YES;
            iv;
        });
        
        _labCheck = ({
            UILabel *iv = [[UILabel alloc]init];
            iv.textAlignment = NSTextAlignmentRight;
            iv.textColor = [ZCUIKitTools zcgetServerConfigBtnBgColor];//UIColorFromModeColor(SobotColorTheme);
            iv.font = SobotFont12;
            [self.contentView addSubview:iv];
            [self.contentView addConstraint:sobotLayoutEqualCenterY(0, iv, self.contentView)];
            [self.contentView addConstraint:sobotLayoutMarginRight(-5, iv, self.imgArrow)];
            [self.contentView addConstraint:sobotLayoutMarginLeft(5, iv, self.labName)];
            iv.hidden = YES;
            iv;
        });
        
        _lineView = ({
            UIView *iv = [[UIView alloc]init];
            [self.contentView addSubview:iv];
//            iv.backgroundColor = UIColorFromModeColor(SobotColorBgLine);
            iv.backgroundColor = UIColor.clearColor;// 新版UI不显示
            [self.contentView addConstraint:sobotLayoutPaddingLeft(20, iv, self.contentView)];
            [self.contentView addConstraint:sobotLayoutPaddingRight(0, iv, self.contentView)];
            [self.contentView addConstraint:sobotLayoutPaddingBottom(-1, iv, self.contentView)];
            [self.contentView addConstraint:sobotLayoutEqualHeight(0.5, iv, NSLayoutRelationEqual)];
            iv.hidden = YES;
            iv;
        });
    }
    return self;
}

-(void)initDataToView:(ZCLeaveRegionEntity *) entity{
    self.imgArrow.hidden = YES;
    self.labCheck.hidden = YES;
    self.labCheck.text = @"";
    self.layoutIconH.constant = 12;
    self.layoutIconW.constant = 16;
    if(sobotConvertToString(self.searchText).length > 0){
        NSString *text =  [self getCheckModelTitle:entity];
        self.labName.attributedText = [self getOtherColorString:sobotTrimString(self.searchText) Color:UIColorFromModeColor(SobotColorYellow) withString:sobotConvertToString(text)];
        NSString *checkCode = [self getCheckModelCode:_checkModel];
        NSString *ecode = [self getCheckModelCode:entity];
        if(_checkModel!=nil && [checkCode isEqual:ecode]){
            self.imgArrow.hidden = NO;
            self.imgArrow.image = [SobotGetImage(@"zcion_mor_sel") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            if (!sobotIsNull(_imgColor)) {
                self.imgArrow.tintColor = _imgColor;
            }
            self.layoutIconH.constant = 20;
            self.layoutIconW.constant = 20;
        }
    }else{
        NSString *text = entity.name;
        [_labName setText:text];
        if(self.fieldModel.regionalLevel > entity.level){
            self.imgArrow.hidden = NO;
            self.imgArrow.image = SobotGetImage(@"zcicon_arrow_right_record");
        }
        if(self.checkModel){
            NSString *checkCode = [NSString stringWithFormat:@"%@/%@/%@/%@",self.checkModel.provinceCode,self.checkModel.cityCode,self.checkModel.areaCode,self.checkModel.streetCode];
            if([checkCode rangeOfString:entity.curId].location != NSNotFound){
                if(entity.level == self.fieldModel.regionalLevel){
                    self.imgArrow.hidden = NO;
                    self.imgArrow.image = [SobotGetImage(@"zcion_mor_sel") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    if (!sobotIsNull(_imgColor)) {
                        self.imgArrow.tintColor = _imgColor;
                    }
                    self.layoutIconH.constant = 20;
                    self.layoutIconW.constant = 20;
                }else if(entity.level < self.fieldModel.regionalLevel){
                    self.labCheck.hidden = NO;
                    self.labCheck.text = SobotLocalString(@"已选");
                }
            }
        }
    }
}


-(NSString *)getCheckModelCode:(ZCLeaveRegionEntity *) model{
    NSString *title = @"";
    for(int i=1;i<= model.level;i++){
        if(i>self.fieldModel.regionalLevel){
            break;
        }
        if(i == 1){
            title = sobotConvertToString(model.provinceCode);
        }else if(i == 2){
            title = [title stringByAppendingFormat:@"/%@",model.cityCode];
        }else if(i == 3){
            title = [title stringByAppendingFormat:@"/%@",model.areaCode];
        }else if(i == 4){
            title = [title stringByAppendingFormat:@"/%@",model.streetCode];
        }
    }
    return title;
}

-(NSString *)getCheckModelTitle:(ZCLeaveRegionEntity *) model{
    NSString *title = @"";
    for(int i=1;i<=model.level;i++){
        if(i>self.fieldModel.regionalLevel){
            break;
        }
        if(i == 1){
            title = sobotConvertToString(model.province);
        }else if(i == 2){
            title = [title stringByAppendingFormat:@"/%@",model.city];
        }else if(i == 3){
            title = [title stringByAppendingFormat:@"/%@",model.area];
        }else if(i == 4){
            title = [title stringByAppendingFormat:@"/%@",model.street];
        }
    }
    return title;
}

-(NSMutableAttributedString *)getOtherColorString:(NSString *)string Color:(UIColor *)Color withString:(NSString *)originalString
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]init];
    NSMutableString *temp = [NSMutableString stringWithString:originalString];
    str = [[NSMutableAttributedString alloc] initWithString:temp];
    if (string.length) {
        NSRange range = [temp rangeOfString:string options:NSBackwardsSearch];
        [str addAttribute:NSForegroundColorAttributeName value:Color range:range];
        return str;
    }
    return str;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
