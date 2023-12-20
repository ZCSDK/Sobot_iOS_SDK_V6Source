//
//  ZCOrderOnlyEditCell.m
//  SobotKit
//
//  Created by lizh on 2022/9/13.
//

#import "ZCOrderOnlyEditCell.h"
#import <SobotChatClient/SobotChatClient.h>
#import <SobotCommon/SobotCommon.h>
#import "ZCUIKitTools.h"
// 限制方式  1禁止输入空格   2 禁止输入小数点  3 小数点后只允许2位  4 禁止输入特殊字符  5只允许输入数字 6最多允许输入字符  7判断邮箱格式  8判断手机格式
typedef enum _ZCEditLimitType {
    ZCEditLimitType_noPoint  = 0,
    ZCEditLimitType_onlyTwo,
    ZCEditLimitType_other,
    ZCEditLimitType_special
} ZCEditLimitType;

@interface  ZCOrderOnlyEditCell()<UITextFieldDelegate>
{
    
}
@property(nonatomic,strong) NSString *labelNameStr;
@property(nonatomic,strong) ZCOrderCusFiledsModel *cusModel;
@property(nonatomic,assign) BOOL isHaveDian;

@property(nonatomic,strong) NSLayoutConstraint *fieldContentPL;
@property(nonatomic,strong) NSLayoutConstraint *fieldContentPT;
@property(nonatomic,strong) NSLayoutConstraint *fieldContentPR;

@property(nonatomic,strong) UIView *bgView;
@end

@implementation ZCOrderOnlyEditCell

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
        iv.textColor = UIColorFromKitModeColor(SobotColorTextMain);
        [self.contentView addConstraint:sobotLayoutPaddingLeft(20, iv, self.contentView)];
        self.labelNamePT = sobotLayoutPaddingTop(17, iv, self.contentView);
        [self.contentView addConstraint:self.labelNamePT];
        self.labelNameEH = sobotLayoutEqualHeight(20, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.labelNameEH];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-20, iv, self.contentView)];
        iv;
    });

    _bgView = ({
        UIView *iv = [[UIView alloc]init];
        [self.contentView addSubview:iv];
        iv.backgroundColor = [UIColor clearColor];
        [self.contentView addConstraint:sobotLayoutPaddingTop(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutEqualHeight(55, iv, NSLayoutRelationEqual)];
        NSLayoutConstraint *bgPB = sobotLayoutPaddingBottom(0, iv, self.contentView);
        bgPB.priority = UILayoutPriorityFittingSizeLevel;
        [self.contentView addConstraint:bgPB];
        iv;
    });
    
    _fieldContent = ({
        UITextField *iv = [[UITextField alloc]init];
        [iv setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
        [iv setFont:SobotFont14];
        [iv setBorderStyle:UITextBorderStyleNone];
        [iv setBackgroundColor:UIColor.clearColor];
        [iv addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        iv.delegate = self;
        [iv addTarget:self action:@selector(textFieldDidChangeBegin:) forControlEvents:UIControlEventEditingDidBegin];
        [self.contentView addSubview:iv];
        self.fieldContentPL = sobotLayoutPaddingLeft(20, iv, self.contentView);
        [self.contentView addConstraint:self.fieldContentPL];
        self.fieldContentPR = sobotLayoutPaddingRight(-20, iv, self.contentView);
        self.fieldContentPT = sobotLayoutPaddingTop(29, iv, self.contentView);
        [self.contentView addConstraint:self.fieldContentPT];
        [self.contentView addConstraint:self.fieldContentPR];
        [self.contentView addConstraint:sobotLayoutEqualHeight(20, iv, NSLayoutRelationEqual)];
        iv;
    });
}

-(void)initDataToView:(NSDictionary *)dict{
    self.tempDict = dict;
    // 限制方式  1禁止输入空格   2 禁止输入小数点  3 小数点后只允许2位  4 禁止输入特殊字符  5只允许输入数字 6最多允许输入字符  7判断邮箱格式  8判断手机格式
    if([dict[@"dictType"] intValue] == 5 || [dict[@"dictName"] isEqualToString:@"ticketTel"]){
        _fieldContent.keyboardType = UIKeyboardTypeDecimalPad;
    }else{
        _fieldContent.keyboardType = UIKeyboardTypeDefault;
    }
    if(dict[@"model"]!=nil){
        _cusModel = dict[@"model"];
    }
    _fieldContent.placeholder = @"";
    _fieldContent.text = @"";
    [_fieldContent setPlaceholder:dict[@"placeholder"]];
    [_fieldContent setPlaceholder:@""];
    if(!sobotIsNull(dict[@"dictValue"])){
        [_fieldContent setText:dict[@"dictValue"]];
    }
    
    self.labelNamePT.constant = 17;
    self.labelNameEH.constant = 20;
    self.labelNameStr = dict[@"dictDesc"];
    NSString *string = [NSString stringWithFormat:@"%@  %@",self.labelNameStr,SobotKitLocalString(@"请输入")];
    self.labelName.attributedText = [self getOtherColorString:string colorArray:@[[UIColor redColor],UIColorFromKitModeColor(SobotColorTextSub1)] withStringArray:@[@"*",SobotKitLocalString(@"请输入")]];
    [self checkLabelState:NO];
}

-(BOOL)checkLabelState:(BOOL)showSmall{
    BOOL isSmall = [super checkLabelState:showSmall text:_fieldContent.text];
   
    if(!isSmall){
        self.fieldContentPL.constant = 70;
        self.fieldContentPT.constant = 17;
        NSString *string = self.labelNameStr;
        if (string) {
            NSString *string = [NSString stringWithFormat:@"%@  %@",self.labelNameStr,SobotKitLocalString(@"请输入")];
            self.labelName.attributedText = [self getOtherColorString:string colorArray:@[[UIColor redColor],UIColorFromKitModeColor(SobotColorTextSub1)] withStringArray:@[@"*",SobotKitLocalString(@"请输入")]];
        }
    }else{
        self.fieldContentPL.constant = 20;
        self.fieldContentPT.constant = 29;
        NSString *string = self.labelNameStr;
        if (string) {
            self.labelName.attributedText = [self getOtherColorString:@"*" Color:[UIColor redColor] withString:string];
        }
    }
    return isSmall;
}

#pragma mark - 验证数据格式
-(BOOL)checkContentValid:(NSString *) text model:(ZCOrderCusFiledsModel *) model{
    if(model != nil && sobotConvertToString(text).length >0){
        NSArray *limitOptions = nil;
        if(limitOptions==nil || limitOptions.count == 0){
            return YES;
        }
        if([model.limitOptions isKindOfClass:[NSString class]]){
            NSString *limitOption =  sobotConvertToString(model.limitOptions);
            limitOption = [limitOption stringByReplacingOccurrencesOfString:@"[" withString:@""];
            limitOption = [limitOption stringByReplacingOccurrencesOfString:@"]" withString:@""];
            limitOptions = [limitOption componentsSeparatedByString:@","];
        }else if([model.limitOptions isKindOfClass:[NSArray class]]){
            limitOptions = model.limitOptions;
        }
        //限制方式  1禁止输入空格   2 禁止输入小数点  3 小数点后只允许2位  4 禁止输入特殊字符  5只允许输入数字 6最多允许输入字符  7判断邮箱格式  8判断手机格式
        if([limitOptions containsObject:[NSNumber numberWithInt:1]] || [limitOptions containsObject:@"1"]){
            NSRange _range = [text rangeOfString:@" "];
            if(_range.location!=NSNotFound) {
                return NO;
            }
        }
        if([limitOptions containsObject:[NSNumber numberWithInt:2]] || [limitOptions containsObject:@"2"]){
             NSRange _range = [text rangeOfString:@"."];
            if(_range.location!=NSNotFound) {
                return NO;
            }
        }
        if([limitOptions containsObject:[NSNumber numberWithInt:3]] || [limitOptions containsObject:@"3"]){
             return sobotValidateFloatWithNum(text,2);
        }
        if([limitOptions containsObject:[NSNumber numberWithInt:4]] || [limitOptions containsObject:@"4"]){
             return sobotValidateRuleNotBlank(text);
        }
        if([limitOptions containsObject:[NSNumber numberWithInt:5]] || [limitOptions containsObject:@"5"]){
             return sobotValidateNumber(text);
        }
        if([limitOptions containsObject:[NSNumber numberWithInt:6]] || [limitOptions containsObject:@"6"]){
            if(sobotConvertToString(text).length > [model.limitChar intValue]){
                return NO;
            }
        }
        if([limitOptions containsObject:[NSNumber numberWithInt:7]] || [limitOptions containsObject:@"7"]){
//            return sobotValidateEmail(text);
        }
        if([limitOptions containsObject:[NSNumber numberWithInt:8]] || [limitOptions containsObject:@"8"]){
            if(sobotConvertToString(text).length >= 11){
                return NO;
            }
            return sobotValidateNumber(text);
        }
    }
    return YES;
}


/**
 计算Label高度
 
 @param label 要计算的label，设置了值
 @param width label的最大宽度
 @param type 是否从新设置宽，1设置，0不设置
 */
- (CGSize )autoHeightOfLabel:(UILabel *)label with:(CGFloat )width{
    CGSize maximumLabelSize = CGSizeMake(width, FLT_MAX);
    CGSize expectedLabelSize = [label sizeThatFits:maximumLabelSize];
    //adjust the label the the new height.
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    label.frame = newFrame;
    [label updateConstraintsIfNeeded];
    return expectedLabelSize;
}

-(void)textFieldDidChangeBegin:(UITextField *) textField{
    if(self.delegate && [self.delegate respondsToSelector:@selector(didKeyboardWillShow:view1:view2:)]){
        [self.delegate didKeyboardWillShow:self.indexPath view1:nil view2:textField];
    }
    [self checkLabelState:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if([self getLitmitTypeWithModel:_cusModel] == ZCEditLimitType_special) {
        if (!sobotValidateRuleNotBlank(string)) {
            return NO;
        }
    }
    if([self getLitmitTypeWithModel:_cusModel] == ZCEditLimitType_noPoint) {
        if ([string isEqualToString:@"."]) {
            return NO;
        }
    }
    // 判断是否有小数点
    if ([textField.text containsString:@"."]) {
        self.isHaveDian = YES;
    }else{
        self.isHaveDian = NO;
    }
    if (string.length > 0) {
        //当前输入的字符
        unichar single = [string characterAtIndex:0];
        // 只能有一个小数点
        if([self getLitmitTypeWithModel:_cusModel] == ZCEditLimitType_onlyTwo) {
            if (self.isHaveDian && single == '.') {
                return NO;
            }
        }
          // 小数点后最多能输入两位
        if([self getLitmitTypeWithModel:_cusModel] == ZCEditLimitType_onlyTwo) {
            if (self.isHaveDian) {
                NSRange ran = [textField.text rangeOfString:@"."];
                    // 由于range.location是NSUInteger类型的，所以这里不能通过(range.location - ran.location)>2来判断
                if (range.location > ran.location) {
                    if ([textField.text pathExtension].length > 1) {

                        return NO;
                    }
                }
            }
        }
    }
    return YES;
}

- (ZCEditLimitType )getLitmitTypeWithModel:(ZCOrderCusFiledsModel *)model {
     if(model != nil ){
            NSArray *limitOptions = nil;
            if([model.limitOptions isKindOfClass:[NSString class]]){
                NSString *limitOption =  sobotConvertToString(model.limitOptions);
                limitOption = [limitOption stringByReplacingOccurrencesOfString:@"[" withString:@""];
                limitOption = [limitOption stringByReplacingOccurrencesOfString:@"]" withString:@""];
                limitOptions = [limitOption componentsSeparatedByString:@","];
            }else if([model.limitOptions isKindOfClass:[NSArray class]]){
                limitOptions = model.limitOptions;
            }
            if([limitOptions containsObject:[NSNumber numberWithInt:2]] || [limitOptions containsObject:@"2"]){
                    return ZCEditLimitType_noPoint;
            }
            if([limitOptions containsObject:[NSNumber numberWithInt:3]] || [limitOptions containsObject:@"3"]){
                 return ZCEditLimitType_onlyTwo;
            }
         if([limitOptions containsObject:[NSNumber numberWithInt:4]] || [limitOptions containsObject:@"4"]){
              return ZCEditLimitType_special;
         }
     }
    return ZCEditLimitType_other;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    // 失去焦点
    [self checkLabelState:NO];
}

-(void)textFieldDidChange:(UITextField *)textField{
    if(![self checkContentValid:textField.text model:_cusModel]){
        textField.text= [textField.text substringToIndex:textField.text.length - 1];
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(itemCreateCusCellOnClick:dictValue:dict:indexPath:)]) {
        [self.delegate itemCreateCusCellOnClick:ZCOrderCreateItemTypeOnlyEdit dictValue:sobotConvertToString(textField.text) dict:self.tempDict indexPath:self.indexPath];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}
@end
