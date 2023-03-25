//
//  ZCOrderCreateCell.m
//  SobotKit
//
//  Created by lizh on 2022/9/13.
//

#import "ZCOrderCreateCell.h"
#import "ZCUIKitTools.h"
#import <SobotCommon/SobotCommon.h>
@interface ZCOrderCreateCell (){
    
}

@end

@implementation ZCOrderCreateCell

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

#pragma mark - 布局子控件
-(void)createItemsView{
    _labelName = ({
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
}

-(void)initDataToView:(NSDictionary *)dict{
    _tempDict = dict;
}

-(BOOL)checkLabelState:(BOOL) showSmall text:(NSString *)text{
    if(_labelName){
        [self.contentView removeConstraint:self.labelNameEH];
        [self.contentView removeConstraint:self.labelNamePT];
        if(sobotConvertToString(self.tempDict[@"dictValue"]).length > 0 || sobotConvertToString(text).length >0 || showSmall){
            self.labelNameEH = sobotLayoutEqualHeight(17, self.labelName, NSLayoutRelationEqual);
            self.labelNamePT = sobotLayoutPaddingTop(6, self.labelName, self.contentView);
            [_labelName setFont:SobotFont12];
            [_labelName setTextColor:UIColorFromKitModeColor(SobotColorTextSub1)];
            [self.contentView addConstraint:self.labelNameEH];
            [self.contentView addConstraint:self.labelNamePT];
            return YES;
        }else{
            self.labelNamePT = sobotLayoutPaddingTop(17, self.labelName, self.contentView);
            self.labelNameEH = sobotLayoutEqualHeight(20, self.labelName, NSLayoutRelationEqual);
            [_labelName setFont:SobotFont14];
            [_labelName setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
            [self.contentView addConstraint:self.labelNameEH];
            [self.contentView addConstraint:self.labelNamePT];
            return NO;
        }
    }
    return NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (NSMutableAttributedString *)getOtherColorString:(NSString *)originalString colorArray:(NSArray<UIColor *> *)colorArray withStringArray:(NSArray<NSString *> *)stringArray {
    if (stringArray.count != colorArray.count) {
        return [[NSMutableAttributedString alloc] initWithString:sobotConvertToString(originalString)];
    }
    NSMutableString *temp = [NSMutableString stringWithString:sobotConvertToString(originalString)];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:temp];
    for (int i = 0;i < stringArray.count; i++) {
        if (stringArray[i].length) {
            NSRange range = [temp rangeOfString:stringArray[i]];
            [str addAttribute:NSForegroundColorAttributeName value:colorArray[i] range:range];
        }
    }
    return str;
}



-(NSMutableAttributedString *)getOtherColorString:(NSString *)string Color:(UIColor *)Color withString:(NSString *)originalString
{
    NSMutableString *temp = [NSMutableString stringWithString:sobotConvertToString(originalString)];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:temp];
    if (string.length) {
        NSRange range = [temp rangeOfString:string];
        [str addAttribute:NSForegroundColorAttributeName value:Color range:range];
        return str;
    }
    return str;
}


@end
