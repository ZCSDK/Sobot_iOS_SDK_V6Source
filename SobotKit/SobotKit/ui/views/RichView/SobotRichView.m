//
//  SobotRichView.m
//  SobotKit
//
//  Created by zhangxy on 2024/12/26.
//

#import "SobotRichView.h"
#import "ZCUIKitTools.h"
#import "SobotRichtTextTools.h"
#import <SobotCommon/SobotXHCacheManager.h>


@interface SobotRichView ()<UITextViewDelegate>

@property (strong, nonatomic) NSLayoutConstraint *layoutOutH;
@property (strong, nonatomic) NSLayoutConstraint *layoutH;

@property (nonatomic, copy) NSArray *imgUrls;

@end






@implementation SobotRichView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self createBgView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self createBgView];
    }
    return self;
}


-(void)layoutSubviews{
    [super layoutSubviews];
    
}

-(void)createBgView{
    self.userInteractionEnabled = YES;
    self.autoresizesSubviews = YES;
    
    _layoutOutH = sobotLayoutEqualHeight(0, self, NSLayoutRelationEqual);
    [self addConstraint:_layoutOutH];
    _imgUrls = [[NSMutableArray alloc] init];
    _textView =   [[UITextView alloc] init];
    _textView.font = SobotFont16;
    _textView.scrollEnabled = NO;
    _textView.backgroundColor = UIColor.clearColor;
    [self addSubview:_textView];
    _layoutH = sobotLayoutEqualHeight(0, _textView, NSLayoutRelationEqual);
    _layoutH.priority = UILayoutPriorityDefaultHigh;
    [self addConstraint:_layoutH];
    [self addConstraint:sobotLayoutPaddingTop(0, _textView, self)];
    [self addConstraint:sobotLayoutPaddingLeft(0, _textView, self)];
    [self addConstraint:sobotLayoutPaddingRight(0, _textView, self)];
    
    self.textView.editable = YES;
    self.textView.delegate = self;
    self.textView.textContainer.lineFragmentPadding = 0;
    self.textView.textContainerInset = UIEdgeInsetsZero;
    
    //
    self.textView.layoutManager.usesFontLeading = NO;
    self.textView.layoutManager.allowsNonContiguousLayout = NO;
    
    
    // 添加点击手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.textView addGestureRecognizer:tapGesture];
    
}

#pragma mark - 图片点击处理

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    // 获取点击位置
    CGPoint location = [gesture locationInView:self.textView];
    
    // 获取点击位置的字符索引
    UITextPosition *position = [self.textView closestPositionToPoint:location];
    UITextRange *textRange = [self.textView characterRangeAtPoint:location];
    NSInteger characterIndex = [self.textView offsetFromPosition:self.textView.beginningOfDocument toPosition:textRange.start];
    
    // 检查是否点击了图片
    [self.textView.attributedText enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, self.textView.attributedText.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        if (value && [value isKindOfClass:[NSTextAttachment class]]) {
            if (NSLocationInRange(characterIndex, range)) {
                NSTextAttachment *attachment = value;
                UIImage *image = attachment.image;
                if (image) {
                    NSLog(@"Image clicked: %@", image);
                    [self showImage:image];
                }
            }
        }
    }];
}

- (void)showImage:(UIImage *)image {
    // 显示图片（例如在弹窗中）
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Image" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, 100, 100);
    [alert.view addSubview:imageView];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
//    [self presentViewController:alert animated:YES completion:nil];
}

-(void)addAttrToView:(NSAttributedString *) attr imgs:(NSArray *) imgs width:(CGFloat) width{
    // 记录开始时间
    __block CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    CGFloat h = [SobotRichtTextTools heightForAttr:attr width:width];
    
    self.layoutH.constant = h;
    self.layoutOutH.constant = h + 20;
    self.textView.attributedText = attr;
    self.imgUrls = imgs;
    // 记录结束时间
    CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();

    // 计算执行时间
    NSTimeInterval executionTime = endTime - startTime;
    NSLog(@"%@优化后耗时: %f 秒: %@",[NSThread currentThread],executionTime,NSStringFromCGRect(self.textView.frame));
    
    if(self->_RefreshUIBlock){
        self->_RefreshUIBlock(attr,h);
    }
}

-(void)addTextToView:(NSString *) text imgWidth:(CGFloat) imgWidth{
    // 记录开始时间
    __block CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    
    CGFloat contentWidth = imgWidth;
    if(imgWidth <= 0){
        imgWidth = self.frame.size.width;
    }
    _textView.text = text;
    CGFloat h = [SobotUITools getHeightContain:text font:self.textView.font Width:imgWidth];
    self.layoutH.constant = h;
    self.layoutOutH.constant = h + 20;
    NSString *html = [SobotRichtTextTools addImgStyle:contentWidth text:text];
    
    [SobotRichtTextTools asyncHtmlToAttr:html result:^(NSAttributedString *attr, NSArray *imgUrls, BOOL finish) {
        
        CGFloat h = [SobotRichtTextTools heightForAttr:attr width:imgWidth];
        
        self.layoutH.constant = h;
        self.layoutOutH.constant = h + 20;
        self.textView.attributedText = attr;
        self.imgUrls = imgUrls;
        // 记录结束时间
        CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();

        // 计算执行时间
        NSTimeInterval executionTime = endTime - startTime;
        NSLog(@"%@优化后耗时: %f 秒: %@",[NSThread currentThread], executionTime,NSStringFromCGRect(self.textView.frame));
        
        if(self->_RefreshUIBlock){
            self->_RefreshUIBlock(attr,h);
        }
    }];
}


// 通过点击的 textAttachment filename 与 本地存储的图片 path 对比
// 从而找到对应点击的图片索引
- (void)tapImage1:(NSTextAttachment*)textAttachment {
    NSString *fileName = textAttachment.fileWrapper.filename;
    if (!fileName) {
        return;
    }
    
    for (NSInteger i=0; i<self.imgUrls.count; i++) {
        NSString *imgUrl = self.imgUrls[i];
        NSString *key = [SobotRichtTextTools storeKeyForUrl:imgUrl];
//        NSString *path = [[SDImageCache sharedImageCache] cachePathForKey:key];
        
//        NSString *path = [] [[SDImageCache sharedImageCache] cachePathForKey:key];
//        if (path && [path containsString:fileName]) {
        if([[SobotXHCacheManager cacheManagerWithIdentifier:@"sobot" type:@".png"] existsDataForURL:[NSURL URLWithString:key]]) {
            NSURL *localURL = [[SobotXHCacheManager cacheManagerWithIdentifier:@"sobot" type:@".png"] existsDataForURLToLocalPath:[NSURL URLWithString:key]];
            NSLog(@"选中Url: %@", imgUrl);
            NSLog(@"选中FileURL: %@",localURL);
            NSLog(@"选中index: %@", @(i));
            
            NSLog(@"你点击了第%@张图片\n%@",@(i),imgUrl);
            if(_TapClickBlock){
                _TapClickBlock(imgUrl,fileName);
            }
            break;
        }
    }
}

// 通过遍历所有 NSAttachmentAttributeName 与点击的 textAttachment 对比
// 从而找到对应点击的图片索引
- (void)tapImage2:(NSTextAttachment*)textAttachment {
    __block NSInteger index = 0;
    [self.textView.attributedText enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, self.textView.attributedText.length) options:(NSAttributedStringEnumerationLongestEffectiveRangeNotRequired) usingBlock:^(NSTextAttachment *attachment, NSRange range, BOOL * _Nonnull stop) {
        
        if (attachment) {

            if (attachment==textAttachment) {
                *stop = YES;
            } else {
                index++;
            }
        }
    }];
    
    if (index < self.imgUrls.count) {
        NSString *fileName = textAttachment.fileWrapper.filename;
        NSLog(@"你点击了第%@张图片\n%@",@(index),self.imgUrls[index]);
        if(_TapClickBlock){
            _TapClickBlock(self.imgUrls[index],fileName);
        }
    }
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction  API_AVAILABLE(ios(10.0)){
    
//    NSLog(@"imgUrls: %@", self.imgUrls);
    
    // 处理图片点击
//    UIImage *image = textAttachment.image;
//    if (image) {
//        NSLog(@"Image clicked: %@", image);
//        [self showImage:image];
//    }
    
    [self tapImage1:textAttachment];
    
//    [self tapImage2:textAttachment];
    return NO; // 返回 NO 阻止默认行为
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction  API_AVAILABLE(ios(10.0)){
    // 点击 URL 交互拦截
    NSLog(@"URL:%@",URL);
    return YES;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



@end
