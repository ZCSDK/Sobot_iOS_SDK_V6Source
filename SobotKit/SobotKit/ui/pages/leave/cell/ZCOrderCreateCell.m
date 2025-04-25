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
    // 423 新版UI改版 左右16间距
    // 新版UI 标题全部显示 换行展示全部 高度要自适应增加 行高大于等于22
    _labelName = ({
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
        iv;
    });
    
    _lineView = ({
        UIView *iv = [[UIView alloc]init];
        [self.contentView addSubview:iv];
        iv.backgroundColor = UIColorFromKitModeColor(SobotColorBgTopLine);
        self.lineViewPL = sobotLayoutPaddingLeft(16, iv, self.contentView);
        [self.contentView addConstraint:self.lineViewPL];
        [self.contentView addConstraint:sobotLayoutPaddingRight(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutEqualHeight(0.5, iv, NSLayoutRelationEqual)];
        iv;
    });
}

-(void)initDataToView:(NSDictionary *)dict{
    _tempDict = dict;
}

-(BOOL)checkLabelState:(BOOL) showSmall text:(NSString *)text{
    if(_labelName){
//        [self.contentView removeConstraint:self.labelNameEH];
//        [self.contentView removeConstraint:self.labelNamePT];
        // 如果当前是手机号码，并且区号不为空是，也显示编辑态
        if(sobotConvertToString(self.tempDict[@"dictValue"]).length > 0 || sobotConvertToString(text).length >0 || showSmall || ([self.tempDict[@"dictName"] isEqualToString:@"ticketTel"] && sobotConvertToString(self.tempModel.regionCode).length > 0)){
//            self.labelNameEH = sobotLayoutEqualHeight(EditCellTitleH, self.labelName, NSLayoutRelationEqual);
//            self.labelNamePT = sobotLayoutPaddingTop(EditCellPT, self.labelName, self.contentView);
//            [_labelName setFont:SobotFont12];
//            [_labelName setTextColor:UIColorFromKitModeColor(SobotColorTextSub1)];
//            [self.contentView addConstraint:self.labelNameEH];
//            [self.contentView addConstraint:self.labelNamePT];
            return YES;
        }else{
//            self.labelNamePT = sobotLayoutPaddingTop(EditCellPT, self.labelName, self.contentView);
//            self.labelNameEH = sobotLayoutEqualHeight(EditCellTitleH, self.labelName, NSLayoutRelationEqual);
//            [_labelName setFont:SobotFont14];
//            [_labelName setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
//            [self.contentView addConstraint:self.labelNameEH];
//            [self.contentView addConstraint:self.labelNamePT];
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
