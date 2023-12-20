//
//  ZCStatusLab.m
//  SobotKit
//
//  Created by lizh on 2023/5/21.
//

#import "ZCStatusLab.h"

@implementation ZCStatusLab

- (instancetype)initWithFrame: (CGRect)frame {
    if (self = [super initWithFrame: frame]) {
        _textInsets = UIEdgeInsetsZero;
    }
    return self;
}

- (void)drawTextInRect: (CGRect)rect {
    [super drawTextInRect: UIEdgeInsetsInsetRect(rect, _textInsets)];
}


@end
