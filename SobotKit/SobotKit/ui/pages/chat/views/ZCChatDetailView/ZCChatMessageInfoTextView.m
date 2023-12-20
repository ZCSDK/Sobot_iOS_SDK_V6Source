//
//  ZCChatMessageInfoTextView.m
//  SobotKit
//
//  Created by lizh on 2023/11/23.
//

#import "ZCChatMessageInfoTextView.h"

@interface  ZCChatMessageInfoTextView()<SobotEmojiLabelDelegate>
@property(nonatomic,strong)SobotEmojiLabel *lblTextMsg;
@property(nonatomic,strong)SobotChatMessage *msgModel;
@end

@implementation ZCChatMessageInfoTextView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        self.userInteractionEnabled = YES;
        [self layoutSubViewUI];
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self layoutSubViewUI];
    }
    return self;
}

-(void)layoutSubViewUI{
    
    _lblTextMsg = ({
        SobotEmojiLabel *iv = [[SobotEmojiLabel alloc] initWithFrame:CGRectZero];
        iv.numberOfLines = 0;
        iv.font = SobotFont16;
        iv.delegate = self;
        iv.lineBreakMode = NSLineBreakByTruncatingTail;
        iv.textColor = UIColorFromKitModeColor(SobotColorTextMain);
        iv.backgroundColor = [UIColor clearColor];
        iv.isNeedAtAndPoundSign = NO;
        iv.disableEmoji = NO;
        iv.lineSpacing = 3.0f;
        iv.verticalAlignment = SobotAttributedLabelVerticalAlignmentCenter;
        [self addSubview:iv];
        [self addConstraint:sobotLayoutPaddingTop(0, iv, self)];
        [self addConstraint:sobotLayoutPaddingLeft(42, iv, self)];
        [self addConstraint:sobotLayoutPaddingRight(-42, iv, self)];
        [self addConstraint:sobotLayoutPaddingBottom(0, iv, self)];
        iv;
    });
}


-(CGFloat ) dataToView:(SobotChatMessage *)model{
    self.msgModel = model;
    NSString *text = [self filterSpecialHTML:model.richModel.content];
    NSMutableDictionary *dict = [_lblTextMsg getTextADict:text];
    if(dict){
        text = dict[@"text"];
    }
    // 测试调试
//    text = @"方法一:禁用全局侧滑返回手势 可以在你的应用程序的整个导航控制器中禁用侧滑返回手势。 Swift 代码示例: // 在导航控制器的根视图控制器中 overridefuncviewDidLoad(){super.viewDidLoad()self.navigationController?.interactivePopGestureRecognizer?.isEnabled=false} Objective-C 代码示例: // 在导航控制器的根视图控制器中 -(void)viewDidLoad{[super viewDidLoad];self.navigationController.interactivePopGestureRecognizer.enabled=NO;}方法二:在特定视图控制器中禁用侧滑返回手势 如果你只想在特定的视图控制器中禁用侧滑返回手势,可以在这些视图控制器的 viewDidLo...更多";
    if(model.displayMsgAttr!=nil){
        [self setDisplayAttributedString:model.displayMsgAttr label:_lblTextMsg guide:NO];
    }else{
        _lblTextMsg.text = text;
        if(dict){
            NSArray *arr = dict[@"arr"];
            // 添加链接样式
            for (NSDictionary *item in arr) {
                NSString *text = item[@"htmlText"];
                int loc = [item[@"realFromIndex"] intValue];
                // 一定要在设置text文本之后设置
                [_lblTextMsg addLinkToURL:[NSURL URLWithString:item[@"url"]] withRange:NSMakeRange(loc, text.length)];
            }
        }
    }
                
    CGSize size =  [_lblTextMsg sizeThatFits:CGSizeMake(ScreenWidth -42*2, CGFLOAT_MAX)];
    // 先更新约束 在获取高度
    [self layoutIfNeeded];
    CGRect f = self.lblTextMsg.frame;
    f.size = size;
    return f.size.height + f.origin.y;
}


#pragma mark -- 过滤html标签
-(NSString *)filterSpecialHTML:(NSString *) text{
    NSMutableString *textString = [[NSMutableString alloc] initWithString:sobotConvertToString(text)];
    @try {
        [textString replaceOccurrencesOfString:@"<br />" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, textString.length)];
        [textString replaceOccurrencesOfString:@"<br/>;" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, textString.length)];
        [textString replaceOccurrencesOfString:@"<br>" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, textString.length)];
        [textString replaceOccurrencesOfString:@"&nbsp;" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, textString.length)];
        [textString replaceOccurrencesOfString:@"<p>" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, textString.length)];
        [textString replaceOccurrencesOfString:@"</p>" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, textString.length)];
        [textString replaceOccurrencesOfString:@"amp;" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, textString.length)];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
   
    return (NSString *) textString;
}

-(void)setDisplayAttributedString:(NSMutableAttributedString *) attr label:(UILabel *) label guide:(BOOL)isGuide{

    UIColor *linkColor = [ZCUIKitTools zcgetChatLeftLinkColor];
    if(_msgModel.sendType == 0){
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
            [attributedString addAttribute:NSForegroundColorAttributeName value:UIColorFromKitModeColor(SobotColorTextMain) range:range];
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

#pragma mark -- 超链点击事件
// 链接点击
- (void)SobotEmojiLabel:(SobotEmojiLabel*)emojiLabel didSelectLink:(NSString*)link withType:(SobotEmojiLabelLinkType)type{
   [self doClickURL:link text:@""];
}
// 链接点击
-(void)doClickURL:(NSString *)url text:(NSString * )htmlText{
    if(url){
        url=[url stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        if(self.delegate && [self.delegate respondsToSelector:@selector(onViewEvent:dict:obj:)]){
            [self.delegate onViewEvent:ZCChatMessageInfoViewEventOpenUrl dict:@{} obj:sobotConvertToString(url)];
        }
    }
}


@end
