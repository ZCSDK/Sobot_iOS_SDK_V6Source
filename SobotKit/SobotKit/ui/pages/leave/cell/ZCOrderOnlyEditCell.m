//
//  ZCOrderOnlyEditCell.m
//  SobotKit
//
//  Created by lizh on 2022/9/13.
//

#import "ZCOrderOnlyEditCell.h"
#import <SobotChatClient/SobotChatClient.h>
#import <SobotCommon/SobotCommon.h>
#import <SobotCommon/SobotSheetAreaCodeView.h>
#import "ZCUIKitTools.h"


@interface  ZCOrderOnlyEditCell()<UITextFieldDelegate>
{
    SobotSheetAreaCodeView *areaCodeView;
}
@property(nonatomic,strong) NSString *labelNameStr;
@property(nonatomic,strong) ZCOrderCusFiledsModel *cusModel;
@property(nonatomic,assign) BOOL isHaveDian;

@property(nonatomic,strong) NSLayoutConstraint *fieldContentPL;
@property(nonatomic,strong) NSLayoutConstraint *fieldContentPT;
@property(nonatomic,strong) NSLayoutConstraint *fieldContentPR;

@property(nonatomic,strong) UIButton *btnTag;
@property(nonatomic,strong) UIImageView *btnTagImg;
@property(nonatomic,strong) NSMutableDictionary *checkItem;
@property(nonatomic,strong) NSMutableArray *areaCodeArray;

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
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didRotate:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    }
    return self;
}
- (void)didRotate:(NSNotification *)notification {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
        
    } else if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown) {
        // 竖屏
    }
    if (!sobotIsNull(areaCodeView)) {
        [areaCodeView closeSheetView];
    }
    
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
        self.fieldContentPL = sobotLayoutPaddingLeft(EditCellHSpec, iv, self.contentView);
        [self.contentView addConstraint:self.fieldContentPL];
        self.fieldContentPR = sobotLayoutPaddingRight(-EditCellHSpec, iv, self.contentView);
        // 这里是动态的高，需要考虑标题的高度
        self.fieldContentPT = sobotLayoutMarginTop(EditCellMT, iv, self.labelName);
        [self.contentView addConstraint:self.fieldContentPT];
        [self.contentView addConstraint:self.fieldContentPR];
        [self.contentView addConstraint:sobotLayoutEqualHeight(EditCellTitleH, iv, NSLayoutRelationEqual)];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(-EditCellPT, iv, self.contentView)];
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            iv.textAlignment = NSTextAlignmentRight;
        }else{
            iv.textAlignment = NSTextAlignmentLeft;
        }
        iv;
    });
    _btnTag = ({
        UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
        [iv setTitleColor:UIColorFromKitModeColor(SobotColorTextSub1) forState:0];
        [iv.titleLabel setFont:SobotFont14];
        [iv setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [iv setTitle:@"+86" forState:0];
        [iv setBackgroundColor:UIColor.clearColor];
        [iv addTarget:self action:@selector(getAreaCode:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:iv];
        [self.contentView addConstraint:sobotLayoutPaddingTop(0, iv, self.fieldContent)];
        [self.contentView addConstraint:sobotLayoutEqualHeight(EditCellTitleH, iv, NSLayoutRelationEqual)];
        [self.contentView addConstraint:sobotLayoutEqualWidth(75, iv, NSLayoutRelationEqual)];
        iv.hidden = YES;
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            [self.contentView addConstraint:sobotLayoutPaddingRight(-EditCellHSpec, iv, self.contentView)];
        }else{
            [self.contentView addConstraint:sobotLayoutPaddingLeft(EditCellHSpec, iv, self.contentView)];
        }
        iv;
    });
    
    _btnTagImg = ({
        UIImageView *iv = [[UIImageView  alloc] initWithImage:SobotKitGetImage(@"sobot_arrow_down")];
        iv.contentMode = UIViewContentModeScaleAspectFit;
        [iv setBackgroundColor:UIColor.clearColor];
        [self.btnTag addSubview:iv];
        [self.btnTag addConstraint:sobotLayoutPaddingRight(0, iv, self.btnTag)];
        [self.btnTag addConstraint:sobotLayoutEqualCenterY(0, iv, self.btnTag)];
        [self.btnTag addConstraints:sobotLayoutSize(10,6.5, iv, NSLayoutRelationEqual)];
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
            self.lineViewPL.constant = 16;
            [self.contentView addConstraint:sobotLayoutPaddingRight(0, iv, self.contentView)];
        }
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
//    [_fieldContent setPlaceholder:dict[@"placeholder"]];
    [_fieldContent setPlaceholder:@""];
    
    _btnTag.hidden = YES;
    
    // 标题固定取一开始显示的，后面不在处理 * 也在前面处理好
    self.labelNameStr = dict[@"dictDesc"];
    NSString *tempstr = sobotConvertToString(self.labelNameStr);
    NSMutableAttributedString *att = [self getOtherColorString:@"*" Color:[UIColor redColor] withString:tempstr];
    self.labelName.attributedText = att;
    
    [self checkLabelState:NO];
    
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSForegroundColorAttributeName] = UIColorFromModeColor(SobotColorTextSub1);
    //NSAttributedString:带有属性的文字（叫富文本，可以让你的文字丰富多彩）但是这个是不可变的带有属性的文字，创建完成之后就不可以改变了  所以需要可变的
    NSString *tipText = SobotKitLocalString(@"请输入");
    if (sobotConvertToString([dict objectForKey:@"placeholder"]).length >0) {
        tipText = sobotConvertToString([dict objectForKey:@"placeholder"]);
    }
    NSMutableAttributedString *placeHolder = [[NSMutableAttributedString alloc]initWithString:tipText attributes:attrs];
    _fieldContent.attributedPlaceholder = placeHolder;
    
    if(!sobotIsNull(dict[@"dictValue"])){
        [_fieldContent setText:dict[@"dictValue"]];
    }
    
    // 先执行一遍 查看是否要显示 符合就显示 UI提的
    [self checkLabelState:YES];
}

-(BOOL)checkLabelState:(BOOL)showSmall{
    BOOL isSmall = [super checkLabelState:showSmall text:_fieldContent.text];
    self.btnTag.hidden = YES;
    if(!isSmall){
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            self.fieldContentPR.constant = -EditCellHSpec;
        }else{
            self.fieldContentPL.constant = EditCellHSpec;
        }
    }else{
        
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            self.fieldContentPR.constant = -EditCellHSpec;
        }else{
            self.fieldContentPL.constant = EditCellHSpec;
        }
        // 当时是手机号时，显示选择时区效果
        if([self.tempDict[@"dictName"] isEqualToString:@"ticketTel"]){
            if ([ZCUIKitTools getSobotIsRTLLayout]) {
                self.fieldContentPR.constant = -105;
            }else{
                self.fieldContentPL.constant = 105;
            }
            _btnTag.hidden = NO;
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


/***
 以下手机区号选择UI
 */
-(void)getAreaCode:(UIButton *) sender{
    [self getAreaList];
    
}
-(void)getAreaList{
    if(self.areaCodeArray && self.areaCodeArray.count > 0){
        [self openAreaView];
        return;
    }
    NSString *jsonPath =  [[NSBundle mainBundle] pathForResource:@"SobotKit.bundle/countrycode.json" ofType:nil];
    if(sobotCheckFileIsExsis(jsonPath)){
       NSData *data=[NSData dataWithContentsOfFile:jsonPath];
       NSArray *itemArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        if(itemArray && [itemArray isKindOfClass:[NSArray class]]){
            if(self.areaCodeArray == nil){
                self.areaCodeArray = [[NSMutableArray alloc] init];
            }
            
            for(NSDictionary *tItem in itemArray){
                NSMutableDictionary *item  = [[NSMutableDictionary alloc] initWithDictionary:tItem];
                item[@"title"] = sobotConvertToString(item[@"phone_code"]);
                if(self.tempModel.regionCode && [item[@"phone_code"] isEqual:self.tempModel.regionCode]){
                    item[@"check"] = @"1";
                    self.checkItem = item;
                }else{
                    item[@"check"] = @"0";
                }
                [self.areaCodeArray addObject:item];
            }
            
            if(self.areaCodeArray.count > 0){
                [self openAreaView];
            }
        }
    }
}

-(void)openAreaView{
    areaCodeView = [[SobotSheetAreaCodeView alloc] initAlterView:SobotLocalString(@"区号")];
    areaCodeView.listArray = self.areaCodeArray;
    areaCodeView.checkItem = self.checkItem;
    areaCodeView.showType = 0;
    [areaCodeView hideTypeView];
    areaCodeView.customColor = [ZCUIKitTools zcgetServerConfigBtnBgColor];
    [areaCodeView.btnCommit setBackgroundColor:[ZCUIKitTools zcgetServerConfigBtnBgColor]];
    [areaCodeView.btnCommit setTitleColor:[ZCUIKitTools zcgetLeaveSubmitTextColor] forState:0];
    
    [areaCodeView showInView:nil];
    
    [areaCodeView setChooseResultBlock:^(id  _Nullable item, NSString * _Nonnull names, NSString * _Nonnull ids) {
        SLog(@"当前选择:%@", item);
        self.tempModel.regionCode = sobotConvertToString(item[@"phone_code"]);
        [self.btnTag setTitle:sobotConvertToString(item[@"phone_code"]) forState:0];
    }];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
