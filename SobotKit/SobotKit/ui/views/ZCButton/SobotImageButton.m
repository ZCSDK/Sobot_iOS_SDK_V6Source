//
//  SobotImageButton.m
//  SobotKit
//
//  Created by zhangxy on 2024/12/23.
//

#import "SobotImageButton.h"
#import "ZCUIKitTools.h"

@interface SobotImageButton()<UIGestureRecognizerDelegate>{
    
}

@property(nonatomic,strong) NSLayoutConstraint *layoutTop;
@property(nonatomic,strong) NSLayoutConstraint *layoutBtm;
@property(nonatomic,strong) NSLayoutConstraint *layoutLeft;
@property(nonatomic,strong) NSLayoutConstraint *layoutRight;
@property(nonatomic,strong) NSLayoutConstraint *layoutCenterSpace;

@property(nonatomic,strong) UILongPressGestureRecognizer *longPress;
@property (readwrite, nonatomic, weak) id target;
@property (readwrite, nonatomic) SEL action;
/**
 图片和文字中间的间隔:默认3
 */
@property(nonatomic,assign) CGFloat centerSpace;

//  0:图片在上方，1:图片在下方
@property(nonatomic,assign) SobotImgBtnLocation imageLocation;

// 绘制内部视图时的外边距
@property(nonatomic,assign) UIEdgeInsets contentEdgeInsets;

// 展示图片的尺寸
@property(nonatomic,assign) CGSize imageSize;

// 按下效果
@property(nonatomic, unsafe_unretained) CGFloat oldAlpha;


@end

@implementation SobotImageButton

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.autoresizesSubviews = YES;
        [self createSubViews];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self createSubViews];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    // 左右的时候，需要计算居中
    if(self.imageLocation == SobotImgBtnLocationLeft || self.imageLocation == SobotImgBtnLocationRight){
        // 重新计算一下文字的宽度
        [self.titleLabel sizeToFit];
        CGFloat tw = self.titleLabel.frame.size.width;
        
        CGFloat imgW = self.imageView.frame.size.width;
        CGFloat fw = self.frame.size.width;
        
        CGFloat lrw = fw - tw - imgW - self.centerSpace;
//        if(lrw > 0 && lrw > self.contentEdgeInsets.left){
            self.layoutLeft.constant = lrw/2;
            self.layoutRight.constant =  -lrw/2;
//        }
        
    }
}

#pragma mark 创建View
-(void)createSubViews{
    // 记住原始alpha值
    self.oldAlpha = self.alpha;
    
    // 设置默认值
    _centerSpace = 4.0f;
    _contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.userInteractionEnabled = YES;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.numberOfLines = 0;
    [self addSubview:_titleLabel];
    
    _imageView = [[SobotImageView alloc] init];
    [_imageView setContentMode:UIViewContentModeScaleAspectFit];
    _imageView.userInteractionEnabled = YES;
    [self addSubview:_imageView];
    
    // 不可见button，方便点击事件对象传输
    _clickBtn = (SobotButton*)[SobotUITools createZCButton];
    _clickBtn.obj = self.objTag;
    _clickBtn.backgroundColor = UIColor.clearColor;
    _clickBtn.hidden = NO;
    [self addSubview:_clickBtn];
    
    [self addConstraints:sobotLayoutPaddingWithAll(0, 0, 0, 0, _clickBtn, self)];
    
    // 添加点击事件
    [_clickBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];

    // 添加状态监听，改变文字和图片颜色
    [_clickBtn addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
    
    // 添加点击事件
//    [self setupLongPress];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"state"]) {
        UIButton *button = (UIButton *)object;
        NSLog(@"按钮状态变化: %ld", (long)button.state);
        if(button.isSelected || button.isHighlighted){
            [self setSelected:YES];
        }else{
            [self setSelected:NO];
        }
    }
}

-(void)btnClick:(SobotButton *) sender{
    [self performAction];
    if(_TapClickPicBlock){
        _TapClickPicBlock(UIGestureRecognizerStateEnded,true);
    }
}

// 添加点击事件
//-(void)setupLongPress
//{
//   self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPress:)];
//   self.longPress.minimumPressDuration = 0;
//    self.longPress.delegate = self;
//   [self addGestureRecognizer:self.longPress];
//}


//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
//    if([NSStringFromClass([touch.view class]) isEqualToString:@"UIButton"]){
//        return NO;
//    }
//    return YES;
//}
//
//-(void)didLongPress:(UILongPressGestureRecognizer *)gesture
//{
//   if (gesture.state == UIGestureRecognizerStateBegan
//       || gesture.state == UIGestureRecognizerStateChanged){
//       [self setSelected:YES];
//   }else{
//       [self setSelected:NO];
//   }
//    // 点击事件
//    if(gesture.state == UIGestureRecognizerStateEnded){
//        [self performAction];
//        if(_TapClickPicBlock){
//            _TapClickPicBlock(gesture.state,true);
//        }
//    }else{
//        if(_TapClickPicBlock){
//            _TapClickPicBlock(gesture.state,false);
//        }
//    }
//}

- (void) performAction
{
    if(self.target && self.action){
        __strong id target = self.target;
        if (target && [target respondsToSelector:_action]) {
            [target performSelectorOnMainThread:_action withObject:self.clickBtn waitUntilDone:YES];
        }
    }
}

-(void)setObjTag:(id)objTag{
    _objTag = objTag;
    self.clickBtn.obj = objTag;
}

-(void)addTarget:(id)target action:(SEL)action{
    _target = target;
    _action = action;
    
    
}

// 根据配置设置页面约束
-(void)configLocation:(SobotImgBtnLocation)imageLocation inset:(UIEdgeInsets)contentEdgeInsets space:(CGFloat)centerSpace imageSize:(CGSize)imageSize{
    _imageLocation = imageLocation;
    _contentEdgeInsets = contentEdgeInsets;
    _centerSpace = centerSpace;
    _imageSize = imageSize;
    
    // 上下、图片在上
    if(imageLocation == SobotImgBtnLocationUp){
        _layoutTop  = sobotLayoutPaddingTop(_contentEdgeInsets.top, _imageView, self);
        _layoutBtm  = sobotLayoutPaddingBottom(-_contentEdgeInsets.bottom, _titleLabel, self);
        _layoutCenterSpace = sobotLayoutMarginTop(_centerSpace, _titleLabel, _imageView);
        
        _layoutLeft  = sobotLayoutPaddingLeft(_contentEdgeInsets.left, _titleLabel, self);
        _layoutRight  = sobotLayoutPaddingRight(-_contentEdgeInsets.right, _titleLabel, self);
        [self addConstraint:sobotLayoutEqualCenterX(0, _imageView, self)];
    }else if(imageLocation == SobotImgBtnLocationDown){
        // 上下、图片在下
        _layoutTop  = sobotLayoutPaddingTop(_contentEdgeInsets.top, _titleLabel, self);
        _layoutBtm  = sobotLayoutPaddingBottom(-_contentEdgeInsets.bottom, _imageView, self);
        _layoutCenterSpace = sobotLayoutMarginTop(_centerSpace, _imageView, _titleLabel);
        
        _layoutLeft  = sobotLayoutPaddingLeft(_contentEdgeInsets.left, _titleLabel, self);
        _layoutRight  = sobotLayoutPaddingRight(-_contentEdgeInsets.right, _titleLabel, self);
        [self addConstraint:sobotLayoutEqualCenterX(0, _imageView, self)];
    }else if(imageLocation == SobotImgBtnLocationLeft){
        // 左右、图片在左
        _layoutTop  = sobotLayoutPaddingTop(_contentEdgeInsets.top, _imageView, self);
        _layoutBtm  = sobotLayoutPaddingBottom(-_contentEdgeInsets.bottom, _imageView, self);
        _layoutCenterSpace = sobotLayoutMarginLeft(_centerSpace, _titleLabel, _imageView);
        
//        _layoutLeft  = sobotLayoutRelationAttribute(_contentEdgeInsets.left, _imageView, self, NSLayoutAttributeLeft, NSLayoutAttributeLeft, NSLayoutRelationGreaterThanOrEqual);
//        _layoutRight  = sobotLayoutRelationAttribute(-_contentEdgeInsets.right, _titleLabel, self, NSLayoutAttributeRight, NSLayoutAttributeRight, NSLayoutRelationGreaterThanOrEqual);
        
        _layoutLeft  = sobotLayoutPaddingLeft(_contentEdgeInsets.left, _imageView, self);
        _layoutRight  = sobotLayoutPaddingRight(-_contentEdgeInsets.right, _titleLabel, self);
        [self addConstraint:sobotLayoutEqualCenterY(0, _titleLabel, self)];
    }else if(imageLocation == SobotImgBtnLocationRight){
        // 左右、图片在右
        _layoutTop  = sobotLayoutPaddingTop(_contentEdgeInsets.top, _imageView, self);
        _layoutBtm  = sobotLayoutPaddingBottom(-_contentEdgeInsets.bottom, _imageView, self);
        _layoutCenterSpace = sobotLayoutMarginLeft(_centerSpace, _imageView,_titleLabel);
        
//        _layoutLeft  = sobotLayoutRelationAttribute(_contentEdgeInsets.left, _titleLabel, self, NSLayoutAttributeLeft, NSLayoutAttributeLeft, NSLayoutRelationGreaterThanOrEqual);
//        _layoutRight  = sobotLayoutRelationAttribute(-_contentEdgeInsets.right, _imageView, self, NSLayoutAttributeRight, NSLayoutAttributeRight, NSLayoutRelationGreaterThanOrEqual);
        
        
        _layoutLeft  = sobotLayoutPaddingLeft(_contentEdgeInsets.left, _titleLabel, self);
        _layoutRight  = sobotLayoutPaddingRight(-_contentEdgeInsets.right, _imageView, self);
        [self addConstraint:sobotLayoutEqualCenterY(0, _titleLabel, self)];
    }
    
    
    [self addConstraints:sobotLayoutSize(imageSize.width, imageSize.height, _imageView, NSLayoutRelationEqual)];
    
    [self addConstraint:_layoutTop];
    [self addConstraint:_layoutLeft];
    [self addConstraint:_layoutRight];
    [self addConstraint:_layoutBtm];
    [self addConstraint:_layoutCenterSpace];
}

// 设置选中状态
-(void)setSelected:(BOOL)selected{
    _selected = selected;
    
    [self changeViewProperty];
}

-(void)setImage:(UIImage *)image{
    _image = image;
    [_imageView setImage:image];
    [self changeViewProperty];
}
-(void)setImageSelected:(UIImage *)imageSelected{
    _imageSelected = imageSelected;
    [_imageView setHighlightedImage:imageSelected];
    [self changeViewProperty];
}

-(void)setTitleColor:(UIColor *)titleColor{
    _titleColor = titleColor;
    [_titleLabel setTextColor:_titleColor];
    [self changeViewProperty];
}
-(void)setTitleColorSelected:(UIColor *)titleColorSelected{
    _titleColorSelected = titleColorSelected;
    
    [_titleLabel setHighlightedTextColor:_titleColorSelected];
    [self changeViewProperty];
}

-(void)changeViewProperty{
    if(_selected){
        // 这里设置子控件的，不然控件会变透明态
        if(sobotIsNull(_imageSelected)){
            self.imageView.alpha = self.oldAlpha * 0.6;
        }
        if(sobotIsNull(_titleColorSelected)){
            self.titleLabel.alpha = self.oldAlpha * 0.6;
        }
    }else{
        self.imageView.alpha = self.oldAlpha;
        self.titleLabel.alpha = self.oldAlpha;
    }
    [_imageView setHighlighted:_selected];
    [_titleLabel setHighlighted:_selected];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
