//
//  ZCShadowRadiusView.m
//  SobotKit
//
//  Created by zhangxy on 2025/1/9.
//

#import "ZCShadowRadiusView.h"
#import "ZCUIKitTools.h"


@interface ZCShadowRadiusView(){
    
}
@property(nonatomic,strong) UIView *contentBgView;
@end

@implementation ZCShadowRadiusView


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
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
//    if(_contentBgView!=nil){
//        [_contentBgView removeFromSuperview];
//    }
//    
//    //空白view
//    _contentBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
//    [self addSubview:_contentBgView];
    [self setBackgroundColor:[UIColor clearColor]];
}

-(void)updateBgFrame{
    if(self.shadowRadius<=0){
        self.shadowRadius = 2;
    }
    
    // 避免阴影被切掉
    self.layer.masksToBounds = NO;
    if(self.maxRadius){
        self.layer.backgroundColor = [ZCUIKitTools zcgetChatBackgroundColor].CGColor;
        self.layer.shadowColor = [UIColor colorWithRed:22/255.0 green:22/255.0 blue:22/255.0 alpha:0.1000].CGColor;
        self.layer.shadowOffset = CGSizeMake(0,0.5);
        self.layer.shadowOpacity = 1;
        self.layer.shadowRadius = self.shadowRadius;
    }else{
        self.layer.backgroundColor = [ZCUIKitTools zcgetChatBackgroundColor].CGColor;
        self.layer.cornerRadius = 2;
        self.layer.shadowColor = [UIColor colorWithRed:22/255.0 green:22/255.0 blue:22/255.0 alpha:0.1000].CGColor;
        self.layer.shadowOffset = CGSizeMake(0,0.5);
        self.layer.shadowOpacity = 1;
        self.layer.shadowRadius = self.shadowRadius;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
