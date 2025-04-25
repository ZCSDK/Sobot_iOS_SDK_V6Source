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
    self.labelName = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.contentView addSubview:iv];
        iv.numberOfLines = 0;
        iv.font = SobotFont14;
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
    
    _textContent = ({
        ZCUITextView *iv = [[ZCUITextView alloc]init];
        iv.placeholder = @"";
        iv.placeholederFont = SobotFont14;
        [iv setPlaceholderColor:UIColorFromKitModeColor(SobotColorTextSub1)];
        [iv setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
        [iv setFont:SobotFontBold14];
        [iv setBackgroundColor:UIColor.clearColor];
        iv.delegate = self;
//        iv.sx = 1;
        [self.contentView addSubview:iv];
        // 这里的10 是为了解决自定义textview的光标高度问题
        self.textContentPT = sobotLayoutMarginTop(EditCellMT-5, iv, self.labelName);
        [self.contentView addConstraint:self.textContentPT];
        self.textContentPL = sobotLayoutPaddingLeft(EditCellHSpec-7, iv, self.contentView);
        [self.contentView addConstraint:self.textContentPL];
        self.textContentPR = sobotLayoutPaddingRight(-EditCellHSpec+7, iv, self.contentView);
        [self.contentView addConstraint:self.textContentPR];
        self.textContentEH = sobotLayoutEqualHeight(62, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.textContentEH];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(-EditCellPT, iv, self.contentView)];
        iv.tintColor = [ZCUIKitTools zcgetServerConfigBtnBgColor];
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
    [_textContent setText:@""];
    if(!sobotIsNull(dict[@"dictValue"])){
        [_textContent setText:dict[@"dictValue"]];
    }
    [self checkLabelState:NO];
    // 标题固定取一开始显示的，后面不在处理 * 也在前面处理好
    self.labelNameStr = dict[@"dictDesc"];
    NSString *tempstr = sobotConvertToString(self.labelNameStr);
    NSMutableAttributedString *att = [self getOtherColorString:@"*" Color:[UIColor redColor] withString:tempstr];
    self.labelName.attributedText = att;
    
    NSString *tipText = SobotKitLocalString(@"请输入");
    if (sobotConvertToString([dict objectForKey:@"placeholder"]).length >0) {
        tipText = sobotConvertToString([dict objectForKey:@"placeholder"]);
    }
    _textContent.placeholder = tipText;
}

-(void)textViewDidChange:(ZCUIPlaceHolderTextView *)textView{
    if (self.delegate && [self.delegate respondsToSelector:@selector(itemCreateCusCellOnClick:dictValue:dict:indexPath:)]) {
        [self.delegate itemCreateCusCellOnClick:ZCOrderCreateItemTypeOnlyEdit dictValue:sobotConvertToString(textView.text) dict:self.tempDict indexPath:self.indexPath];
    }
}

-(BOOL)checkLabelState:(BOOL) showSmall{
    BOOL isSmall = [super checkLabelState:showSmall text:_textContent.text];
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
