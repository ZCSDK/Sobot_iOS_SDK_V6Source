//
//  ZCCircleProgressView.m
//  SobotKit
//
//  Created by zhangxy on 2018/12/3.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import "ZCCircleProgressView.h"
#import <SobotChatClient/SobotChatClient.h>

NSString * const ZCProgressViewProgressAnimationKey = @"ZCProgressViewProgressAnimationKey";

@interface ZCCircularProgressView : UIView

- (void)updateProgress:(CGFloat)progress;
- (CAShapeLayer *)shapeLayer;

@end

@interface ZCCircleProgressView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) ZCCircularProgressView *progressView;
@property (nonatomic, assign) int valueLabelProgressPercentDifference;
@property (nonatomic, strong) NSTimer *valueLabelUpdateTimer;
@property (nonatomic, strong) NSTimer *longPressTimer;

@end

@implementation ZCCircleProgressView
@synthesize tintColor = _tintColor;

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedSetup];
    }
    return self;
}

- (void)sharedSetup {
    self.progressView = [[ZCCircularProgressView alloc] initWithFrame:self.bounds];
    self.progressView.shapeLayer.fillColor = [UIColor clearColor].CGColor;
    [self addSubview:self.progressView];
    
    [self resetDefaults];
}

- (void)resetDefaults {
    
    self.fillChangedBlock = nil;
    self.didSelectBlock    = nil;
    self.progressChangedBlock = nil;
    self.centralView = nil;
    
    _fillOnTouch = YES;
    _progress = 0.0;
    _animationDuration = 0.3f;
    _longPressDuration = 0.0f;
    _longPressCancelsSelect = NO;
    
    self.borderWidth = 1.0f;
    self.lineWidth = 2.0f;
    
    [self setupGestureRecognizer];
    
    [self tintColorDidChange];
}

- (void)setupGestureRecognizer {
    // while this is a long press gesture, it is actually recognizing any presses < longPressDuration
    _gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(touchDetected:)];
    _gestureRecognizer.delegate = self;
    _gestureRecognizer.minimumPressDuration = 0.0;
    [self addGestureRecognizer:_gestureRecognizer];
}

#pragma mark - Public Accessors


- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    self.progressView.shapeLayer.borderWidth = borderWidth;
}

- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
    self.progressView.shapeLayer.lineWidth = lineWidth;
}

- (void)setCentralView:(UIView *)centralView {
    if (_centralView != centralView) {
        [_centralView removeFromSuperview];
        _centralView = centralView;
        [self addSubview:self.centralView];
    }
}

#pragma mark - Color

- (void)tintColorDidChange {
    if ([[self superclass] instancesRespondToSelector: @selector(tintColorDidChange)]) {
        [super tintColorDidChange];
    }
    
    UIColor *tintColor = self.tintColor;
    
    self.progressView.shapeLayer.strokeColor = tintColor.CGColor;
    self.progressView.shapeLayer.borderColor = tintColor.CGColor;
}

- (UIColor*) tintColor
{
    if (_tintColor == nil) {
//        _tintColor = [UIColor colorWithRed: 0.0 green: 122.0/255.0 blue: 1.0 alpha: 1.0];
        _tintColor = SobotRgbColor(0,122,255);
        
    }
    return _tintColor;
}

- (void) setTintColor:(UIColor *)tintColor
{
    [self willChangeValueForKey: @"tintColor"];
    _tintColor = tintColor;
    [self didChangeValueForKey: @"tintColor"];
    [self tintColorDidChange];
}

- (UIColor*) fillColor
{
    if (_fillColor == nil) {
        return _tintColor;
    }
    return _fillColor;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.progressView.frame = self.bounds;
    self.centralView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

#pragma mark - Progress Control

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    
    progress = MAX( MIN(progress, 1.0), 0.0); // keep it between 0 and 1
    
    if (_progress == progress) {
        return;
    }
    
    if (animated) {
        
        [self animateToProgress:progress];
        
    } else {
        
        [self stopAnimation];
        _progress = progress;
        [self.progressView updateProgress:_progress];
        
    }
    
    if (self.progressChangedBlock) {
        self.progressChangedBlock(self, _progress);
    }
}

- (void)setProgress:(CGFloat)progress {
    [self setProgress:progress animated:NO];
}

- (void)setAnimationDuration:(CFTimeInterval)animationDuration {
    if (_animationDuration < 0)
        return;
    
    _animationDuration = animationDuration;
}

- (void)animateToProgress:(CGFloat)progress {
    [self stopAnimation];
    
    // Add shape animation
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.duration = self.animationDuration;
    animation.fromValue = @(self.progress);
    animation.toValue = @(progress);
    animation.delegate = self;
    [self.progressView.layer addAnimation:animation forKey:ZCProgressViewProgressAnimationKey];
    
    // Add timer to update valueLabel
    _valueLabelProgressPercentDifference = (progress - self.progress) * 100;
    CFTimeInterval timerInterval =  self.animationDuration / ABS(_valueLabelProgressPercentDifference);
    self.valueLabelUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:timerInterval
                                                                  target:self
                                                                selector:@selector(onValueLabelUpdateTimer:)
                                                                userInfo:nil
                                                                 repeats:YES];
    
    
    _progress = progress;
}

- (void)stopAnimation {
    // Stop running animation
    [self.progressView.layer removeAnimationForKey:ZCProgressViewProgressAnimationKey];
    
    // Stop timer
    [self.valueLabelUpdateTimer invalidate];
    self.valueLabelUpdateTimer = nil;
}

- (void)onValueLabelUpdateTimer:(NSTimer *)timer {
    if (_valueLabelProgressPercentDifference > 0) {
        _valueLabelProgressPercentDifference--;
    } else {
        _valueLabelProgressPercentDifference++;
    }
}

#pragma mark - Highlighting

- (void)addFill {
    if (self.fillOnTouch) {
        // update the layer model
        self.progressView.layer.backgroundColor = [self fillColor].CGColor;
        
        // call block
        if (self.fillChangedBlock) {
            self.fillChangedBlock(self, YES, NO);
        }
    }
}

- (void)removeFillAnimated:(BOOL)animated {
    if (self.fillOnTouch) {
        
        // add the fade-out animation
        if (animated) {
            CABasicAnimation *highlightAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
            highlightAnimation.fromValue           = (id)self.progressView.layer.backgroundColor;
            highlightAnimation.toValue             = (id)[UIColor clearColor].CGColor;
            highlightAnimation.removedOnCompletion = NO;
            [self.progressView.layer addAnimation:highlightAnimation forKey:@"backgroundColor"];
        }
        
        // update the layer model.
        self.progressView.layer.backgroundColor = [UIColor clearColor].CGColor;
        
        // call block
        if (self.fillChangedBlock) {
            self.fillChangedBlock(self, NO, animated);
        }
    }
}

- (void)removeFill {
    [self removeFillAnimated:YES];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self.progressView updateProgress:_progress];
    [self.valueLabelUpdateTimer invalidate];
    self.valueLabelUpdateTimer = nil;
}

#pragma mark - Gesture Recognizers

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (self.centralView && [touch.view isDescendantOfView:self.centralView] && self.centralView.userInteractionEnabled) {
        return NO;
    }
    
    return YES;
}

- (void)touchDetected:(UILongPressGestureRecognizer *)gestureRecognizer {
    
    CGPoint touch = [gestureRecognizer locationOfTouch:0 inView:self];
    
    if (UIGestureRecognizerStateBegan == gestureRecognizer.state) {    // press is being held down
        
        [self addFill];
        
        [self startLongPressTimer];
        
    } else if (UIGestureRecognizerStateChanged == gestureRecognizer.state) {    // press was recognized, but then moved
        
        if (CGRectContainsPoint(self.bounds, touch)) {
            
            [self addFill];
            
            if (self.longPressTimer == nil) {
                [self startLongPressTimer];
            }
            
        } else {
            
            [self removeFillAnimated:NO];
            
            [self stopLongPressTimer];
        }
        
    } else if (UIGestureRecognizerStateEnded == gestureRecognizer.state) { // the touch has been picked up
        
        if (CGRectContainsPoint(self.bounds, touch)) {
            
            [self removeFill];
            
            if (self.didSelectBlock) {
                self.didSelectBlock(self);
            }
            
        } else {
            
            [self removeFillAnimated:NO];
            
        }
        
        [self stopLongPressTimer];
        
    } else {
        
        [self removeFillAnimated:NO];
        
        [self stopLongPressTimer];
        
    }
    
}

- (void)stopLongPressTimer
{
    if (self.longPressTimer != nil) {
        [self.longPressTimer invalidate];
        self.longPressTimer = nil;
    }
}

- (void)startLongPressTimer
{
    if (self.longPressDuration > 0.0) {
        [self.longPressTimer invalidate];
        self.longPressTimer = [NSTimer scheduledTimerWithTimeInterval:_longPressDuration
                                                               target:self
                                                             selector:@selector(longPressTimerFired:)
                                                             userInfo:nil
                                                              repeats:NO];
    }
}

- (void)longPressTimerFired:(NSTimer *)timer {
    if (_longPressCancelsSelect) {
        _gestureRecognizer.enabled = NO;
        _gestureRecognizer.enabled = YES;
    }
    
    if (self.didLongPressBlock) {
        self.didLongPressBlock(self);
    }
}

- (void)setLongPressDuration:(CGFloat)longPressDuration
{
    longPressDuration = MAX(0.0, longPressDuration); // keep it above 0.0
    
    if (_longPressDuration == longPressDuration) {
        return;
    } else {
        _longPressDuration = longPressDuration;
    }
}

@end

#pragma mark - ZCCircularProgressView

@implementation ZCCircularProgressView

+ (Class)layerClass {
    return CAShapeLayer.class;
}

- (CAShapeLayer *)shapeLayer {
    return (CAShapeLayer *)self.layer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self updateProgress:0];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.shapeLayer.cornerRadius = self.frame.size.width / 2.0f;
    self.shapeLayer.path = [self layoutPath].CGPath;
}

- (UIBezierPath *)layoutPath {
    const double TWO_M_PI = 2.0 * M_PI;
    const double startAngle = 0.75 * TWO_M_PI;
    const double endAngle = startAngle + TWO_M_PI;
    
    CGFloat width = self.frame.size.width;
    CGFloat borderWidth = self.shapeLayer.borderWidth;
    return [UIBezierPath bezierPathWithArcCenter:CGPointMake(width/2.0f, width/2.0f)
                                          radius:width/2.0f - borderWidth
                                      startAngle:startAngle
                                        endAngle:endAngle
                                       clockwise:YES];
}

- (void)updateProgress:(CGFloat)progress {
    [self updatePath:progress];
}

- (void)updatePath:(CGFloat)progress {
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    self.shapeLayer.strokeEnd = progress;
    [CATransaction commit];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
