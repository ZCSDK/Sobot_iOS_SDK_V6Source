//
//  ZCOrderEditCell.m
//  SobotKit
//
//  Created by lizh on 2022/9/14.
//

#import "ZCOrderEditCell.h"
#import <SobotChatClient/SobotChatClient.h>
#import <SobotCommon/SobotCommon.h>
#import "ZCUIKitTools.h"

@interface  ZCOrderEditCell()<UITextViewDelegate>
@property(nonatomic,strong) NSString *labelNameStr;
@property(nonatomic,strong) UIView *bgView;

@property(nonatomic,strong) NSLayoutConstraint *textContentPT;
@property(nonatomic,strong) NSLayoutConstraint *textContentPL;
@property(nonatomic,strong) NSLayoutConstraint *textContentPR;
@property(nonatomic,strong) NSLayoutConstraint *textContentEH;
@end

@implementation ZCOrderEditCell

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
    // 内容视图
    _bgView = ({
        UIView *iv = [[UIView alloc]init];
        [self.contentView addSubview:iv];
        iv.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:iv];
        [self.contentView addConstraint:sobotLayoutPaddingTop(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutEqualHeight(76, iv, NSLayoutRelationEqual)];
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
    
    _textContent = ({
        ZCUIPlaceHolderTextView *iv = [[ZCUIPlaceHolderTextView alloc]init];
        iv.placeholder = @"";
        iv.placeholederFont = SobotFont14;
        [iv setPlaceholderColor:UIColorFromKitModeColor(SobotColorTextSub1)];
        [iv setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
        [iv setFont:SobotFontBold14];
        [iv setBackgroundColor:UIColor.clearColor];
        iv.delegate = self;
        [self.contentView addSubview:iv];
        self.textContentPT = sobotLayoutPaddingTop(37, iv, self.contentView);
        [self.contentView addConstraint:self.textContentPT];
        self.textContentPL = sobotLayoutPaddingLeft(20, iv, self.contentView);
        [self.contentView addConstraint:self.textContentPL];
        self.textContentPR = sobotLayoutPaddingRight(-20, iv, self.contentView);
        [self.contentView addConstraint:self.textContentPR];
        self.textContentEH = sobotLayoutEqualHeight(36, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.textContentEH];
        iv;
    });
    
    [self.contentView sendSubviewToBack:self.bgView];
}

-(void)initDataToView:(NSDictionary *)dict{
    self.labelName.frame = CGRectMake(20, 12, self.tableWidth - 40, 0);
    if (self.labelNamePT) {
        [self.contentView removeConstraint:self.labelNamePT];
    }
    self.labelNamePT = sobotLayoutPaddingTop(12, self.labelName, self.contentView);
    [self.contentView addConstraint:self.labelNamePT];
    [self autoHeightOfLabel:self.labelName with:self.tableWidth - 40];
    
    [_textContent setText:@""];
    if(!sobotIsNull(dict[@"dictValue"])){
        [_textContent setText:dict[@"dictValue"]];
    }
    [self checkLabelState:NO];
    self.labelNameStr = dict[@"dictDesc"];
    NSString *string = [NSString stringWithFormat:@"%@  %@",self.labelNameStr,SobotKitLocalString(@"请输入")];
    self.labelName.attributedText = [self getOtherColorString:string colorArray:@[[UIColor redColor],UIColorFromKitModeColor(SobotColorTextSub1)] withStringArray:@[@"*",SobotKitLocalString(@"请输入")]];
    if(self.textContent.text.length> 0){
        self.labelName.text = @"";
    }
}

-(void)textViewDidChange:(ZCUIPlaceHolderTextView *)textView{
    if (self.delegate && [self.delegate respondsToSelector:@selector(itemCreateCusCellOnClick:dictValue:dict:indexPath:)]) {
        [self.delegate itemCreateCusCellOnClick:ZCOrderCreateItemTypeOnlyEdit dictValue:sobotConvertToString(textView.text) dict:self.tempDict indexPath:self.indexPath];
    }
}

-(BOOL)checkLabelState:(BOOL) showSmall{
    BOOL isSmall = [super checkLabelState:showSmall text:_textContent.text];
    if (self.textContentPT) {
        [self.contentView removeConstraint:self.textContentPT];
    }
    if (self.textContentPR) {
        [self.contentView removeConstraint:self.textContentPR];
    }
    if (self.textContentPL) {
        [self.contentView removeConstraint:self.textContentPL];
    }
    if(!isSmall){
        self.textContentPL = sobotLayoutPaddingLeft(70, self.textContent, self.contentView);
        self.textContentPT = sobotLayoutPaddingTop(17, self.textContent, self.contentView);
        [self.contentView addConstraint:self.textContentPL];
        [self.contentView addConstraint:self.textContentPT];
        NSString *string = self.labelNameStr;
        if (string) {
            NSString *string = [NSString stringWithFormat:@"%@  %@",self.labelNameStr,SobotKitLocalString(@"请输入")];
            self.labelName.attributedText = [self getOtherColorString:string colorArray:@[[UIColor redColor],UIColorFromKitModeColor(SobotColorTextSub1)] withStringArray:@[@"*",SobotKitLocalString(@"请输入")]];
        }
    }else{
        self.textContentPL = sobotLayoutPaddingLeft(17, self.textContent, self.contentView);
        self.textContentPT = sobotLayoutPaddingTop(29, self.textContent, self.contentView);
        [self.contentView addConstraint:self.textContentPL];
        [self.contentView addConstraint:self.textContentPT];
        NSString *string = self.labelNameStr;
        if (string) {
            self.labelName.attributedText = [self getOtherColorString:@"*" Color:[UIColor redColor] withString:string];
        }
    }
    return isSmall;
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    if(self.delegate && [self.delegate respondsToSelector:@selector(didKeyboardWillShow:view1:view2:)]){
        [self.delegate didKeyboardWillShow:self.indexPath view1:textView view2:nil];
    }
    [self checkLabelState:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    // 失去焦点
    [self checkLabelState:NO];
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
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    label.frame = newFrame;
    [label updateConstraintsIfNeeded];
    return expectedLabelSize;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
