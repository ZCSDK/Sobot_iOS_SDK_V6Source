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
    CGFloat iwidth;
    CGFloat iheight;
    CGFloat mulSp ;
}

@property(nonatomic,strong) NSMutableArray *starView;
@property(nonatomic,strong) NSLayoutConstraint *layoutStartLeft1;
@property(nonatomic,strong) NSLayoutConstraint *layoutStartLeft2;


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

-(void)createSatisfieViews{
    if(count == 2){
        [_starView removeAllObjects];
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        UIView *centerV = [[UIView alloc] init];
        centerV.backgroundColor = UIColor.clearColor;
        [self addSubview:centerV];
        [self addConstraints:sobotLayoutSize(8, 1, centerV, NSLayoutRelationEqual)];
        [self addConstraint:sobotLayoutEqualCenterX(0, centerV, self)];
        [self addConstraint:sobotLayoutPaddingTop(0, centerV, self)];
        
        
        // 最大宽度120，左右间距10
        CGSize s1 = [SobotUITools getSizeContain:SobotKitLocalString(@"满意") font:SobotFont14 Width:CGSizeMake(100, CGFLOAT_MAX)];
        CGSize s2 = [SobotUITools getSizeContain:SobotKitLocalString(@"不满意") font:SobotFont14 Width:CGSizeMake(100, CGFLOAT_MAX)];
        CGFloat itemH = 66;
        if(s1.height > 22){
            itemH = 66 + (s1.height - 22);
        }else if(s2.height > 22){
            itemH = 66 + (s2.height - 22);
        }
        
        for(int index=1;index<=2;index++){
            UIButton *ss = [[UIButton alloc] init];
            ss.backgroundColor = UIColor.clearColor;
            ss.tag = 100+index;
            [self addSubview:ss];
            [ss setTitle:@"" forState:0];
            
            [ss addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addConstraint:sobotLayoutEqualWidth(120, ss, NSLayoutRelationEqual)];
            [self addConstraint:sobotLayoutEqualHeight(itemH, ss, NSLayoutRelationEqual)];
            [self addConstraint:sobotLayoutPaddingTop(0, ss, self)];
            if(index == 1){
                [self addConstraint:sobotLayoutMarginRight(0, ss, centerV)];
            }else{
                [self addConstraint:sobotLayoutMarginLeft(0, ss, centerV)];
            }
            
            [_starView addObject:ss];
            
            
            UIImageView *ssImg = [[UIImageView alloc] init];
            [ssImg setContentMode:UIViewContentModeScaleAspectFill];
            ssImg.backgroundColor = UIColor.clearColor;
            ssImg.tag = 300+index;
            [ss addSubview:ssImg];
            
            [ss addConstraint:sobotLayoutEqualCenterX(0, ssImg, ss)];
            [ss addConstraint:sobotLayoutPaddingTop(0, ssImg, ss)];
            [ss addConstraints:sobotLayoutSize(36, 36, ssImg, NSLayoutRelationEqual)];
            
            UILabel *lab = [[UILabel alloc] init];
            [lab setTextColor:UIColorFromKitModeColor(SobotColorTextSub)];
            lab.tag = 200+index;
            lab.numberOfLines = 0;
            lab.backgroundColor = UIColor.clearColor;
            lab.textAlignment = NSTextAlignmentCenter;
            [lab setFont:SobotFont14];
            [ss addSubview:lab];
            
            [ss addConstraint:sobotLayoutMarginTop(8, lab, ssImg)];
            [ss addConstraint:sobotLayoutPaddingLeft(10, lab, ss)];
            [ss addConstraint:sobotLayoutPaddingRight(-10, lab, ss)];
            [ss addConstraint:sobotLayoutEqualHeight(22, lab, NSLayoutRelationGreaterThanOrEqual)];
            
            
            if(index == 1){
                [ssImg setImage:SobotKitGetImage(@"zcicon_satisfied")];
                [lab setText:SobotKitLocalString(@"满意")];
            }else{
                [ssImg setImage:SobotKitGetImage(@"zcicon_dissatisfied")];
                [lab setText:SobotKitLocalString(@"不满意")];
            }
            
            if(index == 1){
                [self addConstraint:sobotLayoutPaddingBottom(0, ss, self)];
            }
        }
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    if(self.alignLeft){
        if(_layoutStartLeft1!=nil){
            _layoutStartLeft1.constant = 0;
        }
        if(_layoutStartLeft2!=nil){
            _layoutStartLeft2.constant =  mulSp;//iwidth/2;
        }
    }else{
        CGFloat maxW = self.frame.size.width;
        if(_layoutStartLeft1!=nil){
            CGFloat space = 24;
            CGFloat startX = 0;
            if(viewDelegate == nil){
                _layoutStartLeft1.constant = 0;
            }else{
                
                if (count == 5) {
                    space = 24;
                    startX = (maxW -  iwidth*count - space*(count - 1) ) /2;
                }
                if(count > 6){
                    space = 20;
                    startX = (maxW -  iwidth*6 - space*5 )/2;
                }
                CGFloat startX = (maxW - iwidth*count - space*(count-1))/2;
                
                _layoutStartLeft1.constant = startX;
            }
        }
        if(_layoutStartLeft2!=nil){
            CGFloat space = 20;
            CGFloat startX = (maxW -  iwidth*6 - space*5 )/2 + iwidth/2;
            _layoutStartLeft2.constant = startX;
        }
    }
}

-(void)createSubViews{
    [_starView removeAllObjects];
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if(count == 2){
        [self createSatisfieViews];
        return;
    }
    
    UIView *topView = nil;
    
    CGFloat spaceTop = 0;
    if(isShowLRTip){
        UILabel *lab1 = [self createLabel:YES title:SobotKitLocalString(@"非常不满意")];
        lab1.textColor = UIColorFromKitModeColor(SobotColorTextSub1);
        UILabel *lab2 = [self createLabel:NO title:SobotKitLocalString(@"非常满意")];
        [self addConstraint:sobotLayoutMarginLeft(0, lab2, lab1)];
        lab2.textColor = UIColorFromKitModeColor(SobotColorTextSub1);
        
        topView = lab1;
        spaceTop = 8;
    }
    
    CGFloat space = 10;
    
    isMulRows = NO;
    iwidth = 32;
    // 有父类宽度时再设置
    CGFloat startX = 0;
    
    // 这里处理5星的间距
    if (count == 5) {
        startX = 0;
        iwidth = 32;
        space = 24;
        startX = 0;
    }
    
    if(count > 6){
        self.alignLeft = YES;
        isMulRows = YES;
        iwidth = 32;// (self.frame.size.width- space*5) / 6;
        startX = 0;
        space = 20;
        // 10 分的间距 这里计算有问题
        if (self.isFullWidth) {
            space = (ScreenWidth - 42*2 - iwidth*6)/5;
        }
       
        if (self.isFullWidth) {
            mulSp = (ScreenWidth - 42*2 - iwidth*5 -space*4)/2;
        }
    }
    
    CGFloat itemH = 32;
    if(isMulRows){
        itemH = 32;
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
//            [lab setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMain)];
            [lab setBackgroundColor:UIColorFromModeColor(SobotColorBgF5)];
            [self addSubview:lab];
//            [lab setTextColor:[ZCUIKitTools getNotifitionTopViewLabelColor]];
            [lab setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
            lab.layer.cornerRadius = 8;
            lab.layer.borderColor = UIColorFromKitModeColor(SobotColorBgLine).CGColor;
//             lab.layer.borderWidth = 1.0f;
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
            // 这里需要区分是否是多行，并且是第一行  间距8 其他的上间距20
            if (isShowLRTip && i<=6 && isMulRows) {
                [self addConstraint:sobotLayoutMarginTop(spaceTop, ss, topView)];
            }else{
                [self addConstraint:sobotLayoutMarginTop(space, ss, topView)];
            }
        }else{
            [self addConstraint:sobotLayoutPaddingTop(spaceTop, ss, self)];
        }
        
        if(preView == nil){
            _layoutStartLeft1 = sobotLayoutPaddingLeft(startX, ss, self);
            if(self.alignLeft){
                _layoutStartLeft1.constant = 0;
            }
            [self addConstraint:_layoutStartLeft1];
        }else if(i==7 && isMulRows){
//            _layoutStartLeft2 = sobotLayoutPaddingLeft(iwidth/2+startX, ss, self);
            _layoutStartLeft2 = sobotLayoutPaddingLeft(mulSp, ss, self);
//            if(self.alignLeft){
//                _layoutStartLeft2.constant = iwidth/2;
//            }
            [self addConstraint:_layoutStartLeft2];
        }else{
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
        }else if([ss isKindOfClass:[UIButton class]]){
            UILabel *lab = [self viewWithTag:200+index];
            
            UIImageView *ssImg = [self viewWithTag:300+index];
            if(index == rating){
                [(UIButton *)ss setSelected:YES];
                [lab setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
                
                if(index == 1){
                    [ssImg setImage:SobotKitGetImage(@"zcicon_satisfied_checked")];
                }else{
                    [ssImg setImage:SobotKitGetImage(@"zcicon_dissatisfied_checked")];
                }
                
            }else{
                [(UIButton *)ss setSelected:NO];
                [lab setTextColor:UIColorFromKitModeColor(SobotColorTextSub)];
                
                if(index == 1){
                    [ssImg setImage:SobotKitGetImage(@"zcicon_satisfied")];
                }else{
                    [ssImg setImage:SobotKitGetImage(@"zcicon_dissatisfied")];
                }
            }
        }else{
            if(index==rating){
                // 只有选择中的才显示
                ((UILabel *)ss).layer.borderColor = [UIColor clearColor].CGColor;
                ((UILabel *)ss).layer.borderWidth = 0;
                [ss setBackgroundColor:UIColorFromKitModeColor(SobotColorHeaderText)];
                [(UILabel *)ss setTextColor:UIColorFromKitModeColor(SobotColorWhite)];
            }else{
                [(UILabel *)ss setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
                [ss setBackgroundColor:UIColorFromKitModeColor(SobotColorBgF5)];
                ((UILabel *)ss).layer.borderColor = UIColorFromKitModeColor(SobotColorBgLine).CGColor;;
                ((UILabel *)ss).layer.borderWidth = 0;
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
    if(viewDelegate && [viewDelegate respondsToSelector:@selector(ratingChangedWithTap:)]){
        [viewDelegate ratingChangedWithTap:tap.view.tag-100];
    }
    
}

-(void)btnClick:(UIButton *) btn{
    [self displayRating:btn.tag-100];
    if(viewDelegate && [viewDelegate respondsToSelector:@selector(ratingChangedWithTap:)]){
        [viewDelegate ratingChangedWithTap:btn.tag-100];
    }
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
