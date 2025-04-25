//
//  ZCShadowBorderView.m
//  SobotKit
//
//  Created by zhangxy on 2024/12/13.
//

#import "ZCShadowBorderView.h"
#import "ZCUIKitTools.h"

@interface ZCShadowBorderView(){
    
}
@property(nonatomic,strong) UIView *topBgView;
@property(nonatomic,strong) UIView *contentBgView;
@end

@implementation ZCShadowBorderView


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.autoresizesSubviews = YES;
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
    [self updateBgFrame];
}

-(void)createBgView{
    if(_topBgView!=nil){
        [_topBgView removeFromSuperview];
    }
    
    if(_contentBgView!=nil){
        [_contentBgView removeFromSuperview];
    }
    
    
    _topBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    [self addSubview:_topBgView];
    
    //空白view
    _contentBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 3, self.bounds.size.width, self.bounds.size.height-3)];
    [self addSubview:_contentBgView];
}

-(void)updateBgFrame{
    if(_topBgView == nil){
        return;
    }
    _topBgView.frame = self.bounds;
    CGSize size = _topBgView.frame.size;
    if(size.width <= 0 || size.height <= 0){
        return;
    }
    if(self.topBgColor){
        _topBgView.layer.backgroundColor = self.topBgColor.CGColor;
    }else{
        _topBgView.layer.backgroundColor = [ZCUIKitTools zcgetNavBackGroundColorWithSize:self.bounds.size].CGColor;
    }
    
    // 确保阴影不被裁剪
    self.topBgView.layer.cornerRadius = 8.0f;
    if (self.shadowLayerType == 1) {
        [self addShadowToView:self.topBgView];
    }else{
            self.topBgView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1200].CGColor;
            self.topBgView.layer.shadowOffset = CGSizeMake(0,1);
            self.topBgView.layer.shadowOpacity = 1;
            self.topBgView.layer.shadowRadius = 6;
    }
        
    _contentBgView.frame = CGRectMake(0, 3, size.width, size.height-3);
    _contentBgView.layer.cornerRadius = 8.0f;
    if(self.contentBgColor == nil){
        self.contentBgColor = self.backgroundColor;
    }
    _contentBgView.backgroundColor = self.contentBgColor;
    
    self.backgroundColor = UIColor.clearColor;
}

- (void)addShadowToView:(UIView *)view {
    // 设置阴影颜色
    view.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1200].CGColor;
    // 设置阴影透明度（0.0 - 1.0）
    view.layer.shadowOpacity = 1;
    // 设置阴影半径（值越大，阴影越模糊）
    view.layer.shadowRadius = 6;
    // 设置阴影偏移量（width = 左右，height = 上下）
    view.layer.shadowOffset = CGSizeMake(0, 1);
    // 设置阴影路径，只让 **左、右、底部** 有阴影（去掉顶部阴影）
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 6, view.bounds.size.width, view.bounds.size.height - 6)];
    view.layer.shadowPath = shadowPath.CGPath;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
