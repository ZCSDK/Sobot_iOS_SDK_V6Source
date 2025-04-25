//
//  UIPlaceHolderTextView.m
//  Tutu
//
//  Created by zhangxinyao on 14-11-21.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "ZCUIPlaceHolderTextView.h"
#import <SobotKit/SobotKit.h>

@interface ZCUIPlaceHolderTextView  ()

@end

@implementation ZCUIPlaceHolderTextView
@synthesize placeholder =_placeholder;
@synthesize placeholderColor;
@synthesize LineSpacing;
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _placeHolderLabel = nil;
    placeholderColor = nil;
    _placeholder = nil;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setPlaceholder:@""];
    [self setPlaceholderColor:[UIColor lightGrayColor]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    if( (self = [super initWithFrame:frame]) )
    {
        self.sx = -1;
        [self setPlaceholder:@""];
        [self setPlaceholderColor:[UIColor lightGrayColor]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)textChanged:(NSNotification *)notification
{
    if([[self placeholder] length] == 0)
    {
        return;
    }
    
    if([[self text] length] == 0)
    {
        [[self viewWithTag:999] setAlpha:1];
    }
    else
    {
        [[self viewWithTag:999] setAlpha:0];
    }
    [self setNeedsDisplay];
}


- (void)setText:(NSString *)text {
    [super setText:text];
    [self textChanged:nil];
}

- (void)drawRect:(CGRect)rect
{
    if( [[self placeholder] length] > 0 )
    {
        if ( _placeHolderLabel == nil )
        {
            _placeHolderLabel = [[SobotEmojiLabel alloc] initWithFrame:CGRectMake(10, 10, self.bounds.size.width - 20, 0)];
            CGRect phlab = _placeHolderLabel.frame;
            _placeHolderLabel.lineBreakMode = NSLineBreakByWordWrapping;
            _placeHolderLabel.font = self.placeholederFont ? self.placeholederFont:SobotFont12;
            _placeHolderLabel.backgroundColor = [UIColor clearColor];
            _placeHolderLabel.textColor = self.placeholderColor;
            _placeHolderLabel.alpha = 0;
            _placeHolderLabel.numberOfLines = 0;
            _placeHolderLabel.tag = 999;
            if (self.placeholderLinkColor) {
                [_placeHolderLabel setLinkColor:self.placeholderLinkColor];
            }
            NSString *text =self.placeholder;
            if (_type == 1) {
                _placeHolderLabel.text = text;
            }else{
                _placeHolderLabel.text = text;
            }
            CGFloat sp = 20;
            if (self.sx>=0) {
                sp = self.sx *2;
            }
            CGSize optimalSize = [self.placeHolderLabel preferredSizeWithMaxWidth:self.bounds.size.width-sp];
            phlab.size.height = optimalSize.height;
            _placeHolderLabel.frame = CGRectMake(10, 10, self.bounds.size.width - 20, phlab.size.height);
            if (self.sx >=0) {
                _placeHolderLabel.frame = CGRectMake(self.sx, 10, self.bounds.size.width - self.sx*2, phlab.size.height);
            }
            _placeHolderLabel.backgroundColor = [UIColor clearColor];
            UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(textViewBeginEditing:)];
            [_placeHolderLabel addGestureRecognizer:tap];
            [self addSubview:_placeHolderLabel];
            if(SobotKitIsRTLLayout){
                [_placeHolderLabel setTextAlignment:NSTextAlignmentRight];
            }
            if(self.contentSize.height < optimalSize.height){
                self.contentSize = CGSizeMake(self.bounds.size.width, optimalSize.height + sp);
                if (self.sx >= 0) {
                    CGRect sf = self.frame;
                    sf.origin.x = sf.origin.x -self.sx-1;
                    self.frame = sf;
                }
            }
        }
        [self sendSubviewToBack:_placeHolderLabel];
    }
    
    if( [[self text] length] == 0 && [[self placeholder] length] > 0 )
    {
        [[self viewWithTag:999] setAlpha:1];
    }
    [super drawRect:rect];
}

- (void)setPlaceholederFont:(UIFont *)placeholederFont{
    _placeholederFont = placeholederFont;
    [self setNeedsDisplay];
}
-(void)setPlaceholder:(NSString *)textPlaceholder{
    _placeholder = textPlaceholder;
    if(!sobotIsNull(self.placeHolderLabel)){
        self.placeHolderLabel.text = _placeholder;
        CGRect phlab = _placeHolderLabel.frame;
        CGFloat sp = 20;
        if (self.sx>=0) {
            sp = self.sx *2;
        }
        CGSize optimalSize = [self.placeHolderLabel preferredSizeWithMaxWidth:self.bounds.size.width-sp];
        phlab.size.height = optimalSize.height;
        _placeHolderLabel.frame = CGRectMake(10, 10, self.bounds.size.width - 20, phlab.size.height);
        if (self.sx >=0) {
            _placeHolderLabel.frame = CGRectMake(self.sx, 10, self.bounds.size.width - self.sx*2, phlab.size.height);
        }
        if(self.contentSize.height < optimalSize.height){
            self.contentSize = CGSizeMake(self.bounds.size.width, optimalSize.height + sp);
        }
        if (self.sx >= 0) {
            CGRect sf = self.frame;
            sf.origin.x = sf.origin.x -self.sx-1;
            self.frame = sf;
        }
    }
    [self setNeedsDisplay];
}

// 点击占位文字的label 让textview成为第一响应者
- (void)textViewBeginEditing:(UITapGestureRecognizer *)tap{
    [self becomeFirstResponder];
}


-(NSMutableAttributedString *)getOtherColorString:(NSString *)string Color:(UIColor *)Color withString:(NSString *)originalString
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]init];
    NSMutableString *temp = [NSMutableString stringWithString:sobotConvertToString(originalString)];
    str = [[NSMutableAttributedString alloc] initWithString:temp];
    if (string.length) {
        NSRange range = [temp rangeOfString:sobotConvertToString(string)];
        [str addAttribute:NSForegroundColorAttributeName value:Color range:range];
        return str;
    }
    return str;
}



@end
