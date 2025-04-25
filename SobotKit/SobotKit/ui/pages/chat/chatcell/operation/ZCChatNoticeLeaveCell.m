//
//  ZCChatNoticeLeaveCell.m
//  SobotKit
//
//  Created by zhangxy on 2022/9/23.
//

#import "ZCChatNoticeLeaveCell.h"

@interface ZCChatNoticeLeaveCell(){
    
}

@property(nonatomic,strong) NSLayoutConstraint *layoutBgWidth;

@property (strong, nonatomic) UIView *bgView;

@end

@implementation ZCChatNoticeLeaveCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self createViews];
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self createViews];
        
        //设置点击事件
        [self.contentView addConstraint:sobotLayoutPaddingTop(0, self.bgView, self.ivBgView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingHSpace, self.bgView, self.ivBgView)];
        [self.contentView addConstraint:sobotLayoutMarginBottom(-ZCChatCellItemSpace, self.bgView, self.lblSugguest)];
        _layoutBgWidth = sobotLayoutEqualWidth(ScreenWidth, self.bgView, NSLayoutRelationEqual);
        [self.contentView addConstraint:_layoutBgWidth];
    }
    return self;
}


-(void)createViews{
    _bgView = ({
        UIView *iv = [[UIView alloc] init];
        [iv setBackgroundColor:UIColor.clearColor];
        [self.contentView addSubview:iv];
        iv;
    });
}


-(void)initDataToView:(SobotChatMessage *)message time:(NSString *)showTime{
    [super initDataToView:message time:showTime];
    
    NSString *uploadMessage = message.richModel.content;
    NSArray *arr = [uploadMessage componentsSeparatedByString:@"$\n$"];
    [_bgView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
   
    CGFloat maxContentWidth = self.maxWidth;
    int i=0;
    CGFloat itemMaxWidth = 0;
    UIView *lastView = nil;
    
    [_bgView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (NSString *text in arr) {
        NSArray *items =  [text componentsSeparatedByString:@"$:$"];
        
        SobotEmojiLabel *subLabel = [ZCChatBaseCell createRichLabel];
        [_bgView addSubview:subLabel];
        subLabel.delegate = self;
        if(self.isRight){
            [subLabel setTextColor:[ZCUIKitTools zcgetTextPlaceHolderColor]];
//            [subLabel setLinkColor:[ZCUITools zcgetChatRightlinkColor]];
        }else{
            [subLabel setTextColor:[ZCUIKitTools zcgetTextPlaceHolderColor]];
//            [subLabel setLinkColor:[ZCUITools zcgetChatLeftLinkColor]];
        }
        if(items.count > 0){
            [ZCChatNoticeLeaveCell setTextColorAndFont:subLabel str:[NSString stringWithFormat:@"%@:\n%@",items[0],items[1]] textArray:items];
        }else{
            [subLabel setText:text];
        }
        CGSize s = [subLabel preferredSizeWithMaxWidth:self.maxWidth];
        if(itemMaxWidth < s.width){
            itemMaxWidth = s.width;
        }
        
        if(lastView){
            [_bgView addConstraint:sobotLayoutMarginTop(ZCChatCellItemSpace, subLabel, lastView)];
        }else{
            [_bgView addConstraint:sobotLayoutPaddingTop(ZCChatMarginVSpace, subLabel, self.bgView)];
        }
        [self.bgView addConstraint:sobotLayoutPaddingLeft(0, subLabel, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, subLabel, self.bgView)];
        
        if(i < (arr.count -1)){
            UIView *lineView = [[UIView  alloc] init];
            [lineView setBackgroundColor:[ZCUIKitTools zcgetLineRichColor]];
            [_bgView addSubview:lineView];
            [_bgView addConstraint:sobotLayoutMarginTop(ZCChatCellItemSpace, lineView, subLabel)];
            [self.bgView addConstraint:sobotLayoutPaddingLeft(0, lineView, self.bgView)];
            [self.bgView addConstraint:sobotLayoutPaddingRight(0, lineView, self.bgView)];
            [self.bgView addConstraint:sobotLayoutEqualHeight(1, lineView, NSLayoutRelationEqual)];
        }
        lastView = subLabel;
        i = i + 1;
    }
    
    [self.bgView addConstraint:sobotLayoutPaddingBottom(0, lastView, self.bgView)];
    
    _layoutBgWidth.constant = itemMaxWidth;
    
    
    [self.bgView layoutIfNeeded];
    [self setChatViewBgState:CGSizeMake(itemMaxWidth,CGRectGetMaxX(lastView.frame))];
    
    self.ivBgView.backgroundColor = [ZCUIKitTools zcgetChatBackgroundColor];
//    self.ivBgView.layer.borderColor = [ZCUIKitTools zcgetButtonThemeBgColor].CGColor;
    self.ivBgView.layer.borderColor = [ZCUIKitTools zcgetServerConfigBtnBgColor].CGColor;
    self.ivBgView.layer.borderWidth = 1.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


/**
 * 设置UILable 的字体和颜色
 @ label            :要设置的控件
 @ str                :要设置的字符串
 @ textArray      :有几个文字需要设置
 @ colorArray     :有几个颜色
 @ fontArray      :有几个字体
 */
+(void)setTextColorAndFont:(SobotEmojiLabel *)label
                        str:(NSString *)string
                  textArray:(NSArray *)textArray
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:string];
    for (int i = 0 ; i < [textArray count]; i++ )
    {
        NSRange range1 = [[str string] rangeOfString:textArray[i]];
        if(i==0){
            range1 = [[str string] rangeOfString:[textArray[i] stringByAppendingString:@":"]];
            [str addAttribute:NSForegroundColorAttributeName value:[ZCUIKitTools zcgetTextPlaceHolderColor] range:range1];
            [str addAttribute:NSFontAttributeName value:[ZCUIKitTools zcgetKitChatFont] range:range1];
        }else{
            [str addAttribute:NSForegroundColorAttributeName value:UIColorFromModeColor(SobotColorTextMain) range:range1];
            [str addAttribute:NSFontAttributeName value:SobotFontBold14 range:range1];
        }
    }
    label.attributedText = str;
}

@end
