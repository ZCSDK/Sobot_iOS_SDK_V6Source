//
//  ZCUIAskTableCell.m
//  SobotKit
//
//  Created by lizh on 2024/11/6.
//

#import "ZCUIAskTableCell.h"
#import "ZCOrderOnlyEditCell.h"

@interface ZCUIAskTableCell()<UITextFieldDelegate>

@end

@implementation ZCUIAskTableCell

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
    _labelName = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.contentView addSubview:iv];
        iv.textColor = UIColorFromModeColor(SobotColorTextSub);
        iv.font = SobotFont14;
        [self.contentView addConstraint:sobotLayoutPaddingLeft(16, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingTop(12, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-16, iv, self.contentView)];
        iv;
    });
    
    _imgArrow = ({
        UIImageView *iv = [[UIImageView alloc]init];
        [self.contentView addSubview:iv];
//        [iv setImage:SobotKitGetImage(@"")];
        iv.image = [SobotUITools getSysImageByName:@"zcicon_arrow_right_record"];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-20, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutEqualCenterY(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutEqualHeight(14, iv, NSLayoutRelationEqual)];
        [self.contentView addConstraint:sobotLayoutEqualWidth(7, iv, NSLayoutRelationEqual)];
        iv.hidden = YES;
        iv;
    });
    
    _fieldContent = ({
        UITextField *iv = [[UITextField alloc]init];
        [self.contentView addSubview:iv];
        iv.placeholder = @"请输入";
        iv.textColor = UIColorFromKitModeColor(SobotColorTextMain);
        NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
        attrs[NSForegroundColorAttributeName] = UIColorFromModeColor(SobotColorTextSub);
        //NSAttributedString:带有属性的文字（叫富文本，可以让你的文字丰富多彩）但是这个是不可变的带有属性的文字，创建完成之后就不可以改变了  所以需要可变的
        NSMutableAttributedString *placeHolder = [[NSMutableAttributedString alloc]initWithString:@"请输入" attributes:attrs];
        iv.attributedPlaceholder = placeHolder;
        
        [iv setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
        [iv setFont:SobotFont14];
        [iv setBorderStyle:UITextBorderStyleNone];
        [iv setBackgroundColor:UIColor.clearColor];
        [iv addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        iv.delegate = self;
        [iv addTarget:self action:@selector(textFieldDidChangeBegin:) forControlEvents:UIControlEventEditingDidBegin];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(16, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingTop(38, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutEqualHeight(22, iv, NSLayoutRelationEqual)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-16, iv, self.contentView)];
        iv;
    });
    
    _valueLab = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.contentView addSubview:iv];
        iv.font = SobotFont14;
        iv.textColor = UIColorFromKitModeColor(SobotColorTextSub1);
        [self.contentView addConstraint:sobotLayoutPaddingTop(38, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(16, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-16, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutEqualHeight(22, iv, NSLayoutRelationEqual)];
        iv.hidden = YES;
        iv;
    });
    
    _lineView = ({
        UIView *iv = [[UIView alloc]init];
        [self.contentView addSubview:iv];
        iv.backgroundColor = UIColorFromKitModeColor(SobotColorBgF5);
        [self.contentView addConstraint:sobotLayoutPaddingLeft(16, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutEqualHeight(1, iv, NSLayoutRelationEqual)];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(0, iv, self.contentView)];
        iv;
    });

    _clickBtn = ({
        UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
        [iv addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [iv setBackgroundColor:UIColor.clearColor];
        [self.contentView addSubview:iv];
        [self.contentView addConstraint:sobotLayoutPaddingTop(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(0, iv, self.contentView)];
        iv.hidden = YES;
        iv;
    });
}

#pragma mark -- 点击事件选择单选 解决手势冲突问题
-(void)buttonClick:(UIButton*)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(itemCreateCusCellOnClick:dictValue:dict:indexPath:)]) {
        [self.delegate itemCreateCusCellOnClick:ZCOrderCreateItemTypeSelAsk dictValue:@"" dict:self.tempDict indexPath:self.indexPath];
    }
}

-(void)initDataToView:(NSDictionary *)dict{
    _clickBtn.hidden = YES;
    if (!sobotIsNull(dict)) {
        self.tempDict = dict;
        _editModel = (SobotFormNodeRespVosModel*)([dict objectForKey:@"model"]);
        _labelName.text = sobotConvertToString([dict objectForKey:@"dictName"]);
        int dictType = [sobotConvertToString([dict objectForKey:@"dictType"]) intValue];
        // 单选
        if (dictType == 8) {
            _clickBtn.hidden = NO;
            [_fieldContent setHidden:YES];
            [_imgArrow setHidden: NO];
            [_valueLab setHidden:NO];
            if (sobotConvertToString(_editModel.fieldSaveValue).length >0) {
                // 当前有值
                _valueLab.textColor = UIColorFromKitModeColor(SobotColorTextMain);
                _valueLab.text = sobotConvertToString([dict objectForKey:@"dictValue"]);
            }else{
                _valueLab.textColor = UIColorFromKitModeColor(SobotColorTextSub1);
                NSString *tipText = SobotKitLocalString(@"请选择");
                if (sobotConvertToString([dict objectForKey:@"placeholder"]).length >0) {
                    tipText = sobotConvertToString([dict objectForKey:@"placeholder"]);
                }
                _valueLab.text = tipText;
            }
        }else{
            // 先回执空
            _fieldContent.text = @"";
          // 单行
            [_imgArrow setHidden: YES];
            [_valueLab setHidden:YES];
            [_fieldContent setHidden:NO];
            NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
            attrs[NSForegroundColorAttributeName] = UIColorFromModeColor(SobotColorTextSub1);
            //NSAttributedString:带有属性的文字（叫富文本，可以让你的文字丰富多彩）但是这个是不可变的带有属性的文字，创建完成之后就不可以改变了  所以需要可变的
            NSString *tipText = SobotKitLocalString(@"请输入");
            if (sobotConvertToString([dict objectForKey:@"placeholder"]).length >0) {
                tipText = sobotConvertToString([dict objectForKey:@"placeholder"]);
            }
            NSMutableAttributedString *placeHolder = [[NSMutableAttributedString alloc]initWithString:tipText attributes:attrs];
            _fieldContent.attributedPlaceholder = placeHolder;
            if (sobotConvertToString([dict objectForKey:@"dictValue"]).length >0) {
                _fieldContent.text = sobotConvertToString(_editModel.fieldSaveValue);
            }
            
            // 单行文本键盘的配置
            if([dict[@"dictType"] intValue] == 5){
                _fieldContent.keyboardType = UIKeyboardTypeDecimalPad;
            }else{
                _fieldContent.keyboardType = UIKeyboardTypeDefault;
            }
        }
    }
}


#pragma mark -- 输入框事件
-(void)textFieldDidChangeBegin:(UITextField *) textField{
    if(self.delegate && [self.delegate respondsToSelector:@selector(didKeyboardWillShow:view1:view2:)]){
        [self.delegate didKeyboardWillShow:self.indexPath view1:nil view2:textField];
    }
    [self checkLabelState:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if([self getLitmitTypeWithModel:_editModel] == ZCEditLimitType_special) {
        if (!sobotValidateRuleNotBlank(string)) {
            return NO;
        }
    }
    if([self getLitmitTypeWithModel:_editModel] == ZCEditLimitType_noPoint) {
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
        if([self getLitmitTypeWithModel:_editModel] == ZCEditLimitType_onlyTwo) {
            if (self.isHaveDian && single == '.') {
                return NO;
            }
        }
          // 小数点后最多能输入两位
        if([self getLitmitTypeWithModel:_editModel] == ZCEditLimitType_onlyTwo) {
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

- (ZCEditLimitType )getLitmitTypeWithModel:(SobotFormNodeRespVosModel *)model {
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
    if(![self checkContentValid:textField.text model:_editModel]){
        textField.text= [textField.text substringToIndex:textField.text.length - 1];
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(itemCreateCusCellOnClick:dictValue:dict:indexPath:)]) {
        [self.delegate itemCreateCusCellOnClick:ZCOrderCreateItemTypeOnlyEdit dictValue:sobotConvertToString(textField.text) dict:self.tempDict indexPath:self.indexPath];
    }
}

-(BOOL)checkLabelState:(BOOL)showSmall{
    BOOL isSmall = [self checkLabelState:showSmall text:_fieldContent.text];
//    if(!isSmall){
//        self.fieldContentPL.constant = 70;
//        self.fieldContentPT.constant = 17;
//        NSString *string = self.labelNameStr;
//        if (string) {
//            NSString *string = [NSString stringWithFormat:@"%@  %@",self.labelNameStr,SobotKitLocalString(@"请输入")];
//            self.labelName.attributedText = [self getOtherColorString:string colorArray:@[[UIColor redColor],UIColorFromKitModeColor(SobotColorTextSub1)] withStringArray:@[@"*",SobotKitLocalString(@"请输入")]];
//        }
//    }
    return isSmall;
}

#pragma mark - 验证数据格式
-(BOOL)checkContentValid:(NSString *) text model:(SobotFormNodeRespVosModel *) model{
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

-(BOOL)checkLabelState:(BOOL) showSmall text:(NSString *)text{
    if(_labelName){
        // 如果当前是手机号码，并且区号不为空是，也显示编辑态
//        if(sobotConvertToString(self.tempDict[@"dictValue"]).length > 0 || sobotConvertToString(text).length >0 || showSmall || ([self.tempDict[@"dictName"] isEqualToString:@"ticketTel"] && sobotConvertToString(self.tempModel.regionCode).length > 0)){
//            [_labelName setFont:SobotFont12];
//            [_labelName setTextColor:UIColorFromKitModeColor(SobotColorTextSub1)];
//            return YES;
//        }else{
//            [_labelName setFont:SobotFont14];
//            [_labelName setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
//            return NO;
//        }
    }
    return NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
