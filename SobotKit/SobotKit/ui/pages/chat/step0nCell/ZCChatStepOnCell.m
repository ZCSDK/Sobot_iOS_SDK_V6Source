//
//  ZCChatStepOnCell.m
//  SobotKit
//
//  Created by lizh on 2024/4/3.
//

#import "ZCChatStepOnCell.h"
#import "ZCChatBaseCell.h"
#import "ZCShadowBorderView.h"
#import "ZCUITextView.h"
@interface ZCChatStepOnCell()<UITextViewDelegate>

@property(nonatomic,strong) ZCShadowBorderView *contentView; // 内容视图
@property(nonatomic,strong) ZCUITextView *textView; // 输入框
@property(nonatomic,strong) UIView *btnBgView;// 按钮背景view
@property(nonatomic,strong) UIView *btnView;// 标签内容视图
@property(nonatomic,strong) UIView *lineView;// 线条
@property(nonatomic,strong) UIButton *commitBtn;//提交按钮
@property(nonatomic,copy) NSString *textStr;
@property(nonatomic,strong) NSMutableArray *btnArray;// 记录
@property(nonatomic,copy) NSString *tipStr;// 选中的标签
@property(nonatomic,copy) NSString *tagId;// 选中的标签id

// 大模型机器人提交接口使用
@property(nonatomic,copy) NSString *realuateTagLan;
@property(nonatomic,copy) NSString *realuateSubmitWordLan;

@property(nonatomic,strong) NSLayoutConstraint *btnViewPT;
@property(nonatomic,strong) NSLayoutConstraint *btnViewH;
@property(nonatomic,strong) NSLayoutConstraint *textViewMT;

@property(nonatomic,strong) SobotChatMessage *tempMsg;

@property(nonatomic,strong) UIView *bgTView;

@property(nonatomic,assign) CGFloat keyBoardHeight;
@end

@implementation ZCChatStepOnCell

+(ZCChatStepOnCell *)createViewWithMaxWidth:(CGFloat)maxWidth tempMsg:(SobotChatMessage*)tempMsg isRight:(BOOL)isRight delegate:(id)delegate;
{
    ZCChatStepOnCell *cell = nil;
    cell = [[ZCChatStepOnCell alloc] init];
    if(cell!=nil){
        cell.delegate = delegate;
        cell.maxWidth = maxWidth;
        [cell dataToView:tempMsg];
    }
    return cell;
}

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    // 绿色背景view
//    _topBgView = ({
//        UIView *iv = [[UIView alloc]init];
//        [self addSubview:iv];
//        iv.backgroundColor = [ZCUIKitTools zcgetRightChatColor];
//        iv.layer.cornerRadius = 8;
//        iv.layer.masksToBounds = YES;
//        [self addConstraint:sobotLayoutPaddingTop(5, iv, self)];
//        [self addConstraint:sobotLayoutPaddingLeft(0, iv, self)];
//        [self addConstraint:sobotLayoutPaddingRight(0, iv, self)];
//        [self addConstraint:sobotLayoutPaddingBottom(0, iv, self)];
//        iv;
//    });
    
    _contentView = ({
        ZCShadowBorderView *iv = [[ZCShadowBorderView alloc]init];
        iv.shadowLayerType = 1;
        [self addSubview:iv];
        iv.backgroundColor = [ZCUIKitTools zcgetChatBackgroundColor];//UIColorFromKitModeColor(SobotColorWhite);
        iv.topBgColor = [ZCUIKitTools zcgetServerConfigBtnBgColor];
//        iv.layer.cornerRadius = 8;
//        iv.layer.masksToBounds = YES;
//        iv.layer.borderColor = UIColorFromKitModeColor(SobotColorBgLine).CGColor;
//        iv.layer.borderWidth = 0.5;
        [self addConstraint:sobotLayoutPaddingTop(0, iv, self)];
        [self addConstraint:sobotLayoutPaddingLeft(0, iv, self)];
        [self addConstraint:sobotLayoutPaddingRight(0, iv, self)];
        [self addConstraint:sobotLayoutPaddingBottom(0, iv, self)];
        iv;
    });
    
    _btnView = ({
        UIView *iv = [[UIView alloc]init];
        [self.contentView addSubview:iv];
        self.btnViewPT = sobotLayoutPaddingTop(23, iv, self.contentView);
        [self.contentView addConstraint:self.btnViewPT];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(0, iv, self.contentView)];
        self.btnViewH = sobotLayoutEqualHeight(1, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.btnViewH];
        iv;
    });
    
    _bgTView = ({
        UIView *iv = [[UIView alloc]init];
        iv.backgroundColor = UIColorFromKitModeColor(SobotColorBgF5);
        [self.contentView addSubview:iv];
        [self.contentView addConstraint:sobotLayoutEqualHeight(80, iv, NSLayoutRelationEqual)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(20, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-20, iv, self.contentView)];
        self.textViewMT = sobotLayoutMarginTop(16, iv, self.btnView);
        [self.contentView addConstraint:self.textViewMT];
        iv;
    });
    
    _textView = ({
        ZCUITextView *iv = [[ZCUITextView alloc]init];
        [iv setTextColor:UIColorFromModeColor(SobotColorTextMain)];
        [self.bgTView addSubview:iv];
//        iv.labX = 5;
//        [iv setTextContainerInset:UIEdgeInsetsMake(8, 10, 8, 10)];
//        iv.placeholder = SobotKitLocalString(@"请描述您不满意的原因");
        [self.bgTView addConstraint:sobotLayoutEqualHeight(80, iv, NSLayoutRelationEqual)];
        [self.bgTView addConstraint:sobotLayoutPaddingLeft(8, iv, self.bgTView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-8, iv, self.bgTView)];
        [self.contentView addConstraint:sobotLayoutPaddingTop(0, iv, self.bgTView)];
        iv.delegate = self;
        iv.layer.cornerRadius = 5;
        iv.layer.masksToBounds = YES;
//        iv.layer.borderColor = UIColorFromKitModeColor(SobotColorBgLine).CGColor;
        iv.backgroundColor = UIColorFromKitModeColor(SobotColorBgF5);
//        iv.layer.borderWidth = 1;
        iv.font = SobotFont14;
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            iv.textAlignment = NSTextAlignmentRight;
        }else{
            iv.textAlignment = NSTextAlignmentLeft;
        }
        iv;
    });
    
    _lineView = ({
        UIView *iv = [[UIView alloc]init];
        iv.backgroundColor = UIColorFromKitModeColor(SobotColorBgLine);
        [self.contentView addSubview:iv];
        [self.contentView addConstraint:sobotLayoutMarginTop(20, iv, self.textView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutEqualHeight(1, iv, NSLayoutRelationEqual)];
        iv;
    });
    
    _commitBtn = ({
        UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:iv];
        [iv addTarget:self action:@selector(commitAction:) forControlEvents:UIControlEventTouchUpInside];
        [iv setTitleColor:[ZCUIKitTools zcgetServerConfigBtnBgColor] forState:UIControlStateNormal];
        [iv setTitle:SobotKitLocalString(@"提交") forState:0];
        iv.titleLabel.font = SobotFontBold14;
        [self.contentView addConstraint:sobotLayoutMarginTop(0, iv, self.lineView)];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutEqualHeight(46, iv, NSLayoutRelationEqual)];
        iv.enabled = NO;// 默认不可点击
        iv;
    });
        
    self.btnArray = [NSMutableArray array];
    if (self.btnArray) {
        [self.btnArray removeAllObjects];
    }
    [self changeCommitBtnState];

}

#pragma mark -- 提交的状态
-(void)changeCommitBtnState{
    if (self.tempMsg.realuateConfigInfo.chatRealuateTagInfoList.count > 0) {
       // 有标签 标签和输入框
        if (self.tipStr.length >0 || self.textStr.length >0) {
            self.commitBtn.enabled = YES;
            self.commitBtn.alpha = 1.0f;
            [self.commitBtn setTitleColor:[ZCUIKitTools zcgetServerConfigBtnBgColor] forState:UIControlStateNormal];
        }else{
            self.commitBtn.enabled = NO;
            self.commitBtn.alpha = .5f;
            [self.commitBtn setTitleColor:[ZCUIKitTools zcgetServerConfigBtnBgColor] forState:UIControlStateNormal];
        }
    }else{
        // 没有标签
        if (self.textStr.length >0) {
            self.commitBtn.enabled = YES;
            self.commitBtn.alpha = 1.0f;
            [self.commitBtn setTitleColor:[ZCUIKitTools zcgetServerConfigBtnBgColor] forState:UIControlStateNormal];
        }else{
            self.commitBtn.enabled = NO;
            self.commitBtn.alpha = .5f;
            [self.commitBtn setTitleColor:[ZCUIKitTools zcgetServerConfigBtnBgColor] forState:UIControlStateNormal];
        }
    }
}



#pragma mark -- 提交
-(void)commitAction:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(commitRealuateTagInfo:tipStr:text:msg:answer:realuateTagLan:realuateSubmitWordLan:)]) {
        [self.delegate commitRealuateTagInfo:self.tagId tipStr:self.tipStr text:self.textStr msg:self.tempMsg answer:self.tempMsg.content realuateTagLan:self.realuateTagLan realuateSubmitWordLan:self.realuateSubmitWordLan];
    }
    [self hideKeyBoard];
}

#pragma mark -- 全局回收键盘
- (void)hideKeyBoard
{
    for (UIWindow* window in [UIApplication sharedApplication].windows)
    {
        for (UIView* view in window.subviews)
        {
            [self dismissAllKeyBoardInView:view];
        }
    }
}

-(BOOL) dismissAllKeyBoardInView:(UIView *)view
{
    if([view isFirstResponder])
    {
        [view resignFirstResponder];
        return YES;
    }
    for(UIView *subView in view.subviews)
    {
        if([self dismissAllKeyBoardInView:subView])
        {
            return YES;
        }
    }
    return NO;
}

-(void)dataToView:(SobotChatMessage*)tempMsg{
    self.tempMsg = tempMsg;
    // 按钮的区域的高度
    CGFloat btnViewH = 0;
    self.btnViewPT.constant = 0;
    if (tempMsg.realuateConfigInfo.chatRealuateTagInfoList.count > 0) {
        self.btnViewPT.constant = 23;
        // 默认高度
        CGFloat itemX = 20;
        CGFloat itemY = 0;
        // 有标签框
        CGFloat lastH = 0;
        for (int i = 0; i<tempMsg.realuateConfigInfo.chatRealuateTagInfoList.count; i++) {
            ZCRealuateTagInfo *tagInfo = tempMsg.realuateConfigInfo.chatRealuateTagInfoList[i];
            CGRect cg = [self createBtn:tagInfo itemY:itemY itemX:itemX lastH:lastH];
            lastH = cg.size.height;
            if (i != 0 && itemY <cg.origin.y) {
                itemY = cg.origin.y;
            }
            itemX = cg.origin.x + cg.size.width + 8;
        }
        btnViewH = itemY + lastH;
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            [ZCUIKitTools setViewRTLtransForm:self.btnView];
        }
    }else{
        self.textViewMT.constant = 23;
    }
    self.btnViewH.constant = btnViewH;
    _textView.placeholder = sobotConvertToString(tempMsg.realuateConfigInfo.realuateEvaluateWord);
    self.realuateSubmitWordLan = sobotConvertToString(tempMsg.realuateConfigInfo.realuateSubmitWordLan);
}


#pragma mark -- 创建btn
-(CGRect)createBtn:(ZCRealuateTagInfo*)tagInfo itemY:(CGFloat)itemY itemX:(CGFloat)itemX lastH:(CGFloat)lastH{
    SobotButton *btn = [SobotButton buttonWithType:UIButtonTypeCustom];
    [self.btnView addSubview:btn];
//    [btn setTitle:sobotConvertToString(tagInfo.realuateTag) forState:0];
//    // 大模型机器人使用
//    if (sobotConvertToString(tagInfo.realuateTagLan).length >0) {
//        [btn setTitle:sobotConvertToString(tagInfo.realuateTagLan) forState:0];
//    }
    [btn setTitleColor:UIColorFromKitModeColor(SobotColorTextMain) forState:0];
    [btn setTitleColor:[ZCUIKitTools zcgetServerConfigBtnBgColor] forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = SobotFont14;
    btn.titleEdgeInsets = UIEdgeInsetsMake(4, 14, 8, 14);
    btn.obj = tagInfo;
    btn.layer.borderWidth = 1;
    btn.titleLabel.numberOfLines = 0;
    btn.layer.cornerRadius = 4;
    btn.layer.masksToBounds = YES;
    // 定义富文本属性
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineHeightMultiple = 1.3; // 行高倍数
//    style.minimumLineHeight = 8;
    style.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attrs = @{
        NSFontAttributeName: SobotFont14,
        NSForegroundColorAttributeName: UIColorFromKitModeColor(SobotColorTextMain),
        NSParagraphStyleAttributeName: style
    };
    NSDictionary *selAttrs = @{
        NSFontAttributeName: SobotFont14,
        NSForegroundColorAttributeName: [ZCUIKitTools zcgetServerConfigBtnBgColor],
        NSParagraphStyleAttributeName: style
    };
    
    NSString *tagName = sobotConvertToString(tagInfo.realuateTag);
    if (sobotConvertToString(tagInfo.realuateTagLan).length >0) {
        tagName = sobotConvertToString(tagInfo.realuateTagLan);
    }
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:tagName attributes:attrs];
    NSAttributedString *seltitle = [[NSAttributedString alloc] initWithString:tagName attributes:selAttrs];
    [btn setAttributedTitle:title forState:0];
    [btn setAttributedTitle:seltitle forState:UIControlStateSelected];
    btn.layer.borderColor = UIColorFromKitModeColor(SobotColorBgLine).CGColor;
    // 获取 x 和 y  宽 和高 需要计算
    btn.frame = CGRectMake(itemX, itemY, self.maxWidth-16, 30);
    // self.maxWidth - ZCChatPaddingHSpace*2 -40 -28
//    CGSize size = [btn.titleLabel.text sizeWithFont:SobotFont14 constrainedToSize:CGSizeMake(self.maxWidth - ZCChatPaddingHSpace*2 -40  , FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    CGSize size = [self heightForAttributedString:title maxWidth:self.maxWidth - ZCChatPaddingHSpace*2 -40];
    
    CGFloat itemH = size.height +16 ;
    
    if (itemH <32) {
        itemH = 32;
    }
    // 这里多加16的间距
    if (itemX + size.width + 16 +16> self.maxWidth +ZCChatPaddingHSpace*2 - 40 && itemX != 20) {
        itemX = 20;
        itemY = itemY + 8 + lastH;
    }
        
    btn.frame = CGRectMake(itemX, itemY, size.width + 28, itemH);
    if (tagInfo.isSel) {
        btn.layer.borderColor = [ZCUIKitTools zcgetServerConfigBtnBgColor].CGColor;
    }else{
        btn.layer.borderColor = UIColorFromKitModeColor(SobotColorBgLine).CGColor;
    }
    btn.titleLabel.contentMode = UIViewContentModeCenter; // 关键属性
    
    // 动态调整 Label 高度并垂直居中
    [self.btnArray addObject:btn];
    return CGRectMake(itemX,itemY, size.width + 28, itemH);
}

// 计算 NSAttributedString 的文本高度
- (CGSize)heightForAttributedString:(NSAttributedString *)attributedString
                          maxWidth:(CGFloat)maxWidth {
    // 1. 定义文本容器的约束尺寸（宽度固定，高度不限）
    CGSize constraintSize = CGSizeMake(maxWidth, CGFLOAT_MAX);
    // 2. 计算文本的矩形区域
    CGRect boundingRect = [attributedString boundingRectWithSize:constraintSize
                                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                         context:nil];
    // 3. 向上取整并返回高度（避免小数误差）
    return CGSizeMake(ceilf(boundingRect.size.width), ceilf(boundingRect.size.height));
}


-(void)btnAction:(SobotButton *)sender{
    sender.selected = !sender.selected;
    NSString *tagid = @"";
    if (sender.selected) {
        self.tipStr = sobotConvertToString(sender.titleLabel.text);
        ZCRealuateTagInfo *taginfo = (ZCRealuateTagInfo*)sender.obj;
        tagid = taginfo.tagId;
        self.tagId = sobotConvertToString(tagid);
        self.realuateTagLan = taginfo.realuateTagLan;
        if (sobotConvertToString(taginfo.realuateTagLan).length >0) {
            // 大模型
            self.tipStr = sobotConvertToString(taginfo.realuateTag);
        }
    }else{
        // 取消选中
        self.tipStr = @"";
        self.tagId = @"";
        self.realuateTagLan = @"";
    }
    for (SobotButton *btn in self.btnArray) {
        ZCRealuateTagInfo *taginfo = (ZCRealuateTagInfo*)btn.obj;
        if ([tagid isEqual:taginfo.tagId]) {
            btn.layer.borderColor = btn.layer.borderColor = [ZCUIKitTools zcgetServerConfigBtnBgColor].CGColor;
            btn.selected = YES;
            [btn setBackgroundImage:[SobotImageTools sobotImageWithColor:[SobotUITools getSobotNewColorWith:[ZCUIKitTools zcgetServerConfigBtnBgColor] alpha:0.1]] forState:UIControlStateSelected];
            [btn setBackgroundImage:[SobotImageTools sobotImageWithColor:[SobotUITools getSobotNewColorWith:[ZCUIKitTools zcgetServerConfigBtnBgColor] alpha:0.1]] forState:UIControlStateHighlighted];
            if (!sender.selected) {
                btn.selected = NO; // 可以取消选中
            }
        }else{
            btn.layer.borderColor = UIColorFromKitModeColor(SobotColorBgLine).CGColor;
            btn.selected = NO;
            [btn setBackgroundImage:[SobotImageTools sobotImageWithColor:UIColor.clearColor] forState:UIControlStateSelected];
            [btn setBackgroundImage:[SobotImageTools sobotImageWithColor:UIColor.clearColor] forState:UIControlStateHighlighted];
        }
    }
    
    [self changeCommitBtnState];
}


-(void)textViewDidChange:(UITextView *)textView{
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    //如果在变化中是高亮部分在变，就不要计算字符了
    if (selectedRange && pos) {
        return;
    }
    if (textView.text.length>1000) {
        textView.text = [textView.text substringToIndex:1000];
    }
    self.textStr = textView.text;
    
    [self changeCommitBtnState];
}



-(void)celltextViewDidBeginEditing:(UITextView *)textView{
    SLog(@"%@", @"textview");
    CGRect superviewRect = [self.textView.superview convertRect:self.textView.frame toView:nil];
    CGPoint textFieldPosition = CGPointMake(superviewRect.origin.x + self.textView.frame.origin.x,
                                            superviewRect.origin.y + self.textView.frame.origin.y);
    if ((ScreenHeight-_keyBoardHeight-XBottomBarHeight) <  textFieldPosition.y ) {
        CGFloat h = (textFieldPosition.y +80 +XBottomBarHeight) - (ScreenHeight-_keyBoardHeight) ;
        if(!self.textView.isFirstResponder){
            return ;
        }
        SLog(@"要刷新高度 %f", h);
        if (self.delegate && [self.delegate respondsToSelector:@selector(setListViewScrollHeight:)]) {
            [self.delegate setListViewScrollHeight:h];
        }
    }
}
#pragma mark -  //键盘显示
- (void)keyboardWillShow:(NSNotification *)notification {
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    self.keyBoardHeight = [[[notification userInfo] objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue].size.height;
    [self celltextViewDidBeginEditing:_textView];
}


@end
