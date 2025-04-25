//
//  ZCChatStepOnBaseCell.m
//  SobotKit
//
//  Created by lizh on 2024/4/9.
//

#import "ZCChatStepOnBaseCell.h"
#import "ZCChatStepOnCell.h"

@interface ZCChatStepOnBaseCell ()<ZCChatStepOnCellDelegate>
{
//    NSLayoutConstraint *layoutWidth;
//    NSLayoutConstraint *layoutBgWidth;
}
@property(nonatomic,strong) ZCChatStepOnCell *stepOnView;// 点踩的展示
@property(nonatomic,strong) SobotEmojiLabel *tipLabel; //点踩提示语
@property(nonatomic,strong) UIView *labBgView; // 文字气泡背景
@property(nonatomic,strong) UIView *refrenceView;
@property(nonatomic,strong) NSLayoutConstraint *linkBgViewEH;
@property(nonatomic,strong) NSLayoutConstraint *layoutHeight;
@property(nonatomic,strong) NSLayoutConstraint *layoutReferenceW;
@property(nonatomic,strong) NSLayoutConstraint *layoutMessageLeft;

@property(nonatomic,strong) NSLayoutConstraint *layoutMessageTop;
@property(nonatomic,strong) NSLayoutConstraint *layoutMessageH;

@property(nonatomic,strong) NSLayoutConstraint *refrenceViewH;
@property(nonatomic,strong) NSLayoutConstraint *tipLabelW;

@property(nonatomic,assign) CGFloat rvH;
@end

@implementation ZCChatStepOnBaseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self createItemViews];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self createItemViews];
    }
    return self;
}

#pragma mark -- 创建子视图
-(void)createItemViews{
    
    _labBgView = ({
        UIView *iv = [[UIView alloc]init];
        [self.contentView addSubview:iv];
        [self.contentView addConstraint:sobotLayoutPaddingTop(0, iv, self.ivBgView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(0, iv, self.ivBgView)];
//        layoutWidth = sobotLayoutEqualWidth(1, iv, NSLayoutRelationEqual);
//        _layoutHeight = sobotLayoutEqualHeight(10, iv, NSLayoutRelationEqual);
//        [self.contentView addConstraint:layoutWidth];
//        [self.contentView addConstraint:_layoutHeight];
        [iv setBackgroundColor:[ZCUIKitTools zcgetLeftChatColor]];
        iv.layer.cornerRadius = 4;
        iv.layer.masksToBounds = YES;
        iv;
    });

    // 提示文案
    _tipLabel = ({
        SobotEmojiLabel *iv = [[SobotEmojiLabel alloc] initWithFrame:CGRectZero];
        iv.numberOfLines = 0;
        iv.font = SobotFont14;
        iv.lineBreakMode = NSLineBreakByTruncatingTail;
        iv.backgroundColor = [UIColor clearColor];
        iv.isNeedAtAndPoundSign = NO;
        iv.disableEmoji = NO;
        iv.lineSpacing = 3;
        iv.verticalAlignment = 0;
        iv.textColor = [ZCUIKitTools zcgetLeftChatTextColor];
        [self.labBgView addSubview:iv];
        [self.labBgView addConstraint:sobotLayoutPaddingTop(ZCChatPaddingVSpace, iv, self.labBgView)];
        [self.labBgView addConstraint:sobotLayoutPaddingBottom(-ZCChatPaddingVSpace, iv, self.labBgView)];
        [self.labBgView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingHSpace, iv, self.labBgView)];
        [self.labBgView addConstraint:sobotLayoutPaddingRight(-ZCChatPaddingHSpace, iv, self.labBgView)];
        self.tipLabelW = sobotLayoutEqualWidth(0, iv, NSLayoutRelationEqual);
        [self.labBgView addConstraint:self.tipLabelW];
        iv;
    });

    _refrenceView = [[UIView alloc] init];
    [self.contentView addSubview:_refrenceView];
    _layoutReferenceW = sobotLayoutEqualWidth(240, self.refrenceView, NSLayoutRelationEqual);
    _layoutReferenceW.priority = UILayoutPriorityDefaultHigh;
    [self.contentView addConstraint:_layoutReferenceW];
    _layoutMessageTop = sobotLayoutMarginTop(10, _refrenceView, self.labBgView);
    _layoutMessageLeft = sobotLayoutPaddingLeft(ZCChatPaddingHSpace, _refrenceView, self.contentView);
    [self.contentView addConstraint:_layoutMessageTop];
    [self.contentView addConstraint:_layoutMessageLeft];
    [self.contentView addConstraint:sobotLayoutPaddingBottom(0, _refrenceView, self.lblSugguest)];
    
}

-(void)initDataToView:(SobotChatMessage *) message time:(NSString *) showTime{
    message.senderType = 1;
    // 头像昵称都隐藏
    message.senderName = @"";
    [super initDataToView:message time:showTime];
    self.ivHeader.hidden = YES;
    _tipLabel.text = @"";
    NSString *text = @"";
//    self->_layoutHeight.constant = 0;
    // 历史记录接口返回
    text = sobotConvertToString(message.robotTipMsg);
    _tipLabel.text = text;
    _tipLabel.numberOfLines = 0;
    CGSize s = CGSizeZero;
    CGFloat maxContentWidth = self.maxWidth +ZCChatPaddingHSpace*2;
    if(text.length > 0){
        if([self isRight]){
            [_tipLabel setTextColor:[ZCUIKitTools zcgetRightChatTextColor]];
            [_tipLabel setLinkColor:[ZCUIKitTools zcgetChatRightlinkColor]];
        }else{
            [_tipLabel setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
            [_tipLabel setLinkColor:[ZCUIKitTools zcgetChatLeftLinkColor]];
        }
        s = [text sizeWithFont:SobotFont14 constrainedToSize:CGSizeMake(self.maxWidth, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
        
    }
   
//    _layoutMessageH.constant = s.height;
//    layoutWidth.constant = s.width + ZCChatPaddingHSpace*2;
    _tipLabelW.constant = s.width;
//    _layoutHeight.constant = s.height + ZCChatPaddingVSpace*2;
    _layoutMessageTop.constant = 0;
    
//    if (_stepOnView) {
//        [_stepOnView respondsToSelector:@selector(removeFromSuperview)];
//    }
    
    // 是否显示 点踩输入框部分  只有1 是回显的
    if([sobotConvertToString(message.submitStatus) intValue] == 1){
        [self.stepOnView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        CGFloat maxCW = self.viewWidth - ZCChatPaddingHSpace*2;
        if(maxCW > 500){
            maxCW = 500;
            _layoutMessageLeft.constant = self.viewWidth - 500/2;
        }
        
        _layoutReferenceW.constant = maxCW;
        _layoutMessageTop.constant = 10;
        _stepOnView = [ZCChatStepOnCell createViewWithMaxWidth:maxCW tempMsg:message isRight:self.isRight delegate:self];
        _stepOnView.maxWidth = maxCW;
        if(!sobotIsNull(_stepOnView)){
            [self.refrenceView addSubview:_stepOnView];
            [self.refrenceView addConstraint:sobotLayoutPaddingTop(0, _stepOnView, self.refrenceView)];
            [self.refrenceView addConstraint:sobotLayoutPaddingLeft(0, _stepOnView, self.refrenceView)];
            [self.refrenceView addConstraint:sobotLayoutEqualWidth(maxCW, _stepOnView, NSLayoutRelationEqual)];
            [self.refrenceView addConstraint:sobotLayoutPaddingBottom(0, _stepOnView, self.refrenceView)];
            self.refrenceViewH = sobotLayoutEqualHeight(self.rvH, _stepOnView, NSLayoutRelationEqual);
        }
    }else{
        if (self.refrenceViewH) {
            self.refrenceViewH.constant = 0;
        }
        self.layoutReferenceW.constant = 0;
        [self.refrenceView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    [self setChatViewBgState:CGSizeMake(s.width, s.height)];
    [self.ivBgView setBackgroundColor:UIColor.clearColor];
    self.ivBgView.image = nil;
    _tipLabel.numberOfLines = 0;
//    self.ivBgViewMT.constant = 0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setDisplayAttributedString:(NSMutableAttributedString *) attr label:(UILabel *) label guide:(BOOL)isGuide{
    UIColor *textColor = [ZCUIKitTools zcgetLeftChatTextColor];
    UIColor *linkColor = [ZCUIKitTools zcgetChatLeftLinkColor];
    if(self.isRight){
        textColor = [ZCUIKitTools zcgetRightChatTextColor];
        linkColor = [ZCUIKitTools zcgetChatRightlinkColor];
    }
    NSMutableAttributedString* attributedString = [attr mutableCopy];
    [attributedString beginEditing];
    [attributedString enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0,attributedString.length) options:0 usingBlock:^(id value,NSRange range,BOOL *stop) {
        UIFont *font = value;
        // 替换固定默认文字大小
        if(font.pointSize == 15){
//            NSLog(@"----替换了字体");
            [attributedString removeAttribute:NSFontAttributeName range:range];
            [attributedString addAttribute:NSFontAttributeName value:label.font range:range];
        }
    }];
    [attributedString enumerateAttribute:NSForegroundColorAttributeName inRange:NSMakeRange(0,attributedString.length) options:0 usingBlock:^(id value,NSRange range,BOOL *stop) {
        UIColor *color = value;
        NSString *hexColor = [ZCUIKitTools getHexStringByColor:color];
//                                NSLog(@"***\n%@",hexColor);
        // 替换固定整体文字颜色
        if([@"ff0001" isEqual:hexColor]){
            [attributedString removeAttribute:NSForegroundColorAttributeName range:range];
            [attributedString addAttribute:NSForegroundColorAttributeName value:textColor range:range];
        }
        // 替换固定连接颜色
        if([@"ff0002" isEqual:hexColor]){
            [attributedString removeAttribute:NSForegroundColorAttributeName range:range];
            [attributedString addAttribute:NSForegroundColorAttributeName value:linkColor range:range];
        }
    }];
    
    //Hack for italic/skew effect to custom fonts
    __block NSMutableDictionary *rangeIDict = [[NSMutableDictionary alloc] init];
    [attributedString enumerateAttribute:NSParagraphStyleAttributeName inRange:NSMakeRange(0,attributedString.length) options:0 usingBlock:^(id value,NSRange range,BOOL *stop) {
         if (value) {
             NSMutableParagraphStyle *myStyle = (NSMutableParagraphStyle *)value;
             if (myStyle.minimumLineHeight == 101) {
                 // 保存加粗的标签位置，如果相同位置有斜体，需要设置为斜体加粗
                 [rangeIDict setObject:@"YES" forKey:NSStringFromRange(range)];
                 [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:label.font.pointSize weight:UIFontWeightBold] range:range];
             }
         }
     }];
    
    [attributedString enumerateAttribute:NSParagraphStyleAttributeName inRange:NSMakeRange(0,attributedString.length) options:0 usingBlock:^(id value,NSRange range,BOOL *stop) {
         if (value) {
             NSMutableParagraphStyle *myStyle = (NSMutableParagraphStyle *)value;
             if (myStyle.minimumLineHeight == 99) {
                 UIFont *textFont = label.font;
                 CGAffineTransform matrix =  CGAffineTransformMake(1, 0, tanf(10 * (CGFloat)M_PI / 180), 1, 0, 0);
                 UIFont *font = [UIFont systemFontOfSize:textFont.pointSize];
                 // 相同的位置，有加粗
                 if ([@"YES" isEqual:[rangeIDict objectForKey:NSStringFromRange(range)]]) {
                    font = [UIFont boldSystemFontOfSize:textFont.pointSize];
                 }
                 NSString *fontName = font.fontName;
                 if([fontName hasSuffix:@"SFUI-Regular"]){
                     fontName = @"TimesNewRomanPSMT";
                 }
                 UIFontDescriptor *desc = [UIFontDescriptor fontDescriptorWithName:fontName matrix:matrix];
                 [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithDescriptor:desc size:textFont.pointSize] range:range];
             }
         }
     }];
    
    // 文本段落排版格式
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle alloc] init];
    textStyle.lineBreakMode = NSLineBreakByWordWrapping; // 结尾部分的内容以……方式省略
    if (isGuide) {
        textStyle.lineSpacing = [ZCUIKitTools zcgetChatGuideLineSpacing]; // 调整行间距
    }else{
        textStyle.lineSpacing = [ZCUIKitTools zcgetChatLineSpacing]; // 调整行间距
    }
    NSMutableDictionary *textAttributes = [[NSMutableDictionary alloc] init];
    // NSParagraphStyleAttributeName 文本段落排版格式
    [textAttributes setValue:textStyle forKey:NSParagraphStyleAttributeName];
    // 设置段落样式
    [attributedString addAttributes:textAttributes range:NSMakeRange(0, attributedString.length)];
    [attributedString endEditing];
    label.text = [attributedString copy];
}

-(void)commitRealuateTagInfo:(NSString*)tagId tipStr:(NSString*)tipStr text:(NSString *)text msg:(SobotChatMessage *)msg answer:(NSString *)answer realuateTagLan:(NSString*)realuateTagLan realuateSubmitWordLan:(NSString *)realuateSubmitWordLan{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellCommitRealuateTagInfo:tipStr:text:msg:answer:realuateTagLan:realuateSubmitWordLan:)]) {
        [self.delegate cellCommitRealuateTagInfo:tagId tipStr:tipStr text:text msg:msg answer:answer realuateTagLan:realuateTagLan realuateSubmitWordLan:realuateSubmitWordLan];
    }
}

// 更新内容高度 刷新约束
-(void)updataHeight:(CGFloat)contentH{
    self.refrenceViewH.constant = contentH;
    self.rvH = contentH;
    [self.refrenceView layoutIfNeeded];
}

-(void)setListViewScrollHeight:(CGFloat)H{
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateListViewHeight:)]) {
        [self.delegate updateListViewHeight:H];
    }
}
@end
