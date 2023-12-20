//
//  SobotRatingView.m
//  SobotKit
//
//  Created by zhangxy on 2023/8/21.
//

#import "SobotRatingView.h"
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClientCache.h>
#import "ZCUIKitTools.h"

@interface SobotRatingView(){
    /**
     *  unselectedImage     没有选择时的图片
     *  fullySelectedImage  全部选择时的图片
     */
    UIImage *unselectedImage, *fullySelectedImage;
    
    /**
     *  代理
     */
    id<SobotRatingViewDelegate> viewDelegate;

    float starRating, lastRating;
    
    BOOL isShowLRTip;
    int count;
    BOOL isMulRows;
    
    BOOL addFrame;
    
    BOOL isReSet;
}

@property(nonatomic,strong) NSMutableArray *starView;


@end

@implementation SobotRatingView


-(instancetype)init{
    self = [super init];
    if (self) {
        
        self.backgroundColor = UIColor.clearColor;
    }
    return self;
}


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        self.userInteractionEnabled = YES;
        
        if(frame.size.height > 0){
            addFrame = YES;
        }
    }
    return self;
}


#pragma mark 横竖屏适配
-(void)viewOrientationChange{
    if(_starView!=nil){
        isReSet = YES;
        [_starView makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_starView removeAllObjects];
        [self createSubViews];
        [self displayRating:starRating];
        
    }
}
// 适配iOS 13以上的横竖屏切换
// 横竖屏切换时，需要重新画
-(void)safeAreaInsetsDidChange{
//    UIEdgeInsets e = self.safeAreaInsets;
//
//    if(e.left > 0 || e.right > 0){
//        // 横屏
//        SLog(@"执行了横屏:l:%f-r:%f", e.left,e.right);
//        if(isMulRows){
//            [_starView makeObjectsPerformSelector:@selector(removeFromSuperview)];
//            [_starView removeAllObjects];
//            [self createSubViews];
//        }
//    }else{
//        // 竖屏
////        SLog(@"执行了竖屏:t:%f-b:%f", e.top,e.bottom);
//        if(!isMulRows && count > 6){
//            [_starView makeObjectsPerformSelector:@selector(removeFromSuperview)];
//            [_starView removeAllObjects];
//            [self createSubViews];
//        }
//    }
    if(_starView!=nil){
        isReSet = YES;
        [_starView makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_starView removeAllObjects];
        [self createSubViews];
        [self displayRating:starRating];
        
    }
}



-(void)setImagesDeselected:(NSString *)deselectedImage
              fullSelected:(NSString *)fullSelectedImage
                     count:(int)countScore showLRTip:(BOOL) isShowLRTipF andDelegate:(id<SobotRatingViewDelegate>)d{
    unselectedImage = [SobotUITools getSysImageByName:deselectedImage];// [UIImage imageNamed:deselectedImage];
    
    fullySelectedImage = [SobotUITools getSysImageByName:fullSelectedImage]; //[UIImage imageNamed:fullSelectedImage];
    viewDelegate = d;
    
    
    _starView = [[NSMutableArray alloc] init];
    starRating = 0;
    lastRating = 0;
    count = countScore;
    isShowLRTip = isShowLRTipF;
    
    if(count > 5){
        // 增加0
        count = count + 1;
    }
    
    [self createSubViews];
}

-(void)createSubViews{
    
    UIView *topView = nil;
    
    if(isShowLRTip){
        UILabel *lab1 = [self createLabel:YES title:SobotKitLocalString(@"非常不满意")];
        UILabel *lab2 = [self createLabel:NO title:SobotKitLocalString(@"非常满意")];
        [self addConstraint:sobotLayoutMarginLeft(0, lab2, lab1)];
        
        topView = lab1;
    }
    
    CGFloat space = 10;
    CGFloat spaceTop = space;
    [self layoutIfNeeded];
    
    isMulRows = NO;
    CGFloat iwidth = 36;// (self.frame.size.width - space *(count - 1))/count;
    
    CGFloat startX = (self.frame.size.width - iwidth*count - space*(count-1))/2;
    
    
    // 是数字，并且不是横屏时,startX < 0 说明一行显示不下
//    // 从新给星星赋值一个宽度
//    iwidth = 46;
//    startX = (self.frame.size.width - iwidth*count - space*(count-1))/2;
    
    if(count > 6 && startX < 0){
        isMulRows = YES;
        iwidth = 36;// (self.frame.size.width- space*5) / 6;
        
        startX = (self.frame.size.width - iwidth*6 - space*5)/2;
    }
    CGFloat itemH = 36;
    if(isMulRows){
        itemH = 29;
    }
    
    if(viewDelegate == nil){
        startX = 0;
        iwidth = 13;
        itemH = 13;
        spaceTop = 0;
        space = 5;
    }
    
    
    UIView *preView;
    for (int i=1; i<=count; i++) {
        UIView *ss = nil;
        if(isMulRows){
            UILabel *lab = [[UILabel alloc] init];
            [lab setText:[NSString stringWithFormat:@"%d",i-1]];
            [lab setBackgroundColor:UIColorFromKitModeColor(SobotColorWhite)];
            [self addSubview:lab];
            
            [lab setTextColor:[ZCUIKitTools getNotifitionTopViewLabelColor]];
            lab.layer.cornerRadius = 4;
            lab.layer.borderColor = UIColorFromKitModeColor(SobotColorBgLine).CGColor;
             lab.layer.borderWidth = 1.0f;
             lab.textAlignment = NSTextAlignmentCenter;
             lab.layer.masksToBounds = YES;
             lab.font = [ZCUIKitTools zcgetKitChatFont];
            
             ss = lab;
            [self addConstraint:sobotLayoutEqualHeight(itemH, ss, NSLayoutRelationEqual)];
        }else{
            ss = [[UIImageView alloc] initWithImage:unselectedImage];
            [ss setContentMode:UIViewContentModeScaleAspectFit];
            [self addSubview:ss];
            
            [self addConstraint:sobotLayoutEqualHeight(itemH, ss, NSLayoutRelationEqual)];
        }
        
        
        [self addConstraint:sobotLayoutEqualWidth(iwidth, ss, NSLayoutRelationEqual)];
        
        if(topView){
            [self addConstraint:sobotLayoutMarginTop(space, ss, topView)];
        }else{
            [self addConstraint:sobotLayoutPaddingTop(spaceTop, ss, self)];
        }
        
        if(preView == nil){
            [self addConstraint:sobotLayoutPaddingLeft(startX, ss, self)];
        }else if(i==7 && isMulRows){
            [self addConstraint:sobotLayoutPaddingLeft(iwidth/2+startX, ss, self)];
        }
        else{
            [self addConstraint:sobotLayoutMarginLeft(space, ss, preView)];
        }
        [ss setUserInteractionEnabled:YES];
        ss.tag = 100+i;
        UITapGestureRecognizer * tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        [ss addGestureRecognizer:tap1];
        [self addSubview:ss];
        [_starView addObject:ss];
        
        if(i==6 && isMulRows){
            topView = _starView.firstObject;
        }
        
        preView = ss;
    }
    
    UIView *lastView = [_starView lastObject];
    if(!addFrame){
        [self addConstraint:sobotLayoutPaddingBottom(0, lastView, self)];
    }
}


-(void)displayRating:(float)rating {
    for (UIView *ss in _starView) {
        int index = (int)ss.tag - 100;
        if([ss isKindOfClass:[UIImageView class]]){
            if(index<=rating){
                [(UIImageView *)ss setImage:fullySelectedImage];
            }else{
                [(UIImageView *)ss setImage:unselectedImage];
            }
        }else{
            if(index<=rating){
                ((UILabel *)ss).layer.borderColor = [UIColor clearColor].CGColor;
                ((UILabel *)ss).layer.borderWidth = 0;
                [ss setBackgroundColor:UIColorFromKitModeColor(SobotColorYellow)];
                [(UILabel *)ss setTextColor:UIColorFromKitModeColor(SobotColorWhite)];
            }else{
                [(UILabel *)ss setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
                [ss setBackgroundColor:UIColorFromKitModeColor(SobotColorWhite)];
                ((UILabel *)ss).layer.borderColor = UIColorFromKitModeColor(SobotColorBgLine).CGColor;;
                ((UILabel *)ss).layer.borderWidth = 1;
            }
        }
    }
    starRating = rating;
    lastRating = rating;
    
    if(!isReSet){
        if(viewDelegate && [viewDelegate respondsToSelector:@selector(ratingChanged:)]){
            [viewDelegate ratingChanged:starRating];
        }
    }
    isReSet = NO;
}

-(void)clearViews{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self layoutIfNeeded];
}


- (void)tapAction:(UITapGestureRecognizer*)tap{
    [self displayRating:tap.view.tag-100];
}


-(float)rating {
    return starRating;
}


-(UILabel *)createLabel:(BOOL ) isLeft title:(NSString *) text{
    UILabel *lab = [[UILabel alloc] init];
    [lab setTextColor:UIColorFromKitModeColor(SobotColorTextSub)];
    [lab setText:text];
    [lab setFont:[ZCUIKitTools zcgetListKitDetailFont]];
    [self addSubview:lab];
    
    [self addConstraint:sobotLayoutPaddingTop(0, lab, self)];
    [self addConstraint:sobotLayoutEqualHeight(20, lab, NSLayoutRelationEqual)];
    if(isLeft){
        [self addConstraint:sobotLayoutPaddingLeft(0, lab, self)];
        lab.textAlignment = NSTextAlignmentLeft;
    }else{
        [self addConstraint:sobotLayoutPaddingRight(0, lab, self)];
        lab.textAlignment = NSTextAlignmentRight;
    }
    return lab;
}
@end
