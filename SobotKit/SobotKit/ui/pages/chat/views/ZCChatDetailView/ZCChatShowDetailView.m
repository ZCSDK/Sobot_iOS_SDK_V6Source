//
//  ZCChatShowDetailView.m
//  SobotKit
//
//  Created by zhangxy on 2023/11/23.
//

#import "ZCChatShowDetailView.h"
#import "ZCChatMessageInfoView.h"
#import "ZCVideoPlayer.h"
@interface ZCChatShowDetailView()<UIGestureRecognizerDelegate,ZCChatMessageInfoViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,strong) SobotChatMessage *model;


@property(nonatomic,strong)UIScrollView *mainView;


@property(nonatomic,strong)ZCChatMessageInfoView *infoView;
@property(nonatomic,strong)NSLayoutConstraint *layoutCW;
@property(nonatomic,strong)NSLayoutConstraint *layoutTop;
@property(nonatomic,strong)NSLayoutConstraint *layoutCY;

@end

@implementation ZCChatShowDetailView

-(ZCChatShowDetailView *)initChatDetailViewWithModel:(SobotChatMessage *)model obj:(id _Nullable) obj{
    self = [super init];
    if (self) {
        self.model = model;
        
        self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.autoresizesSubviews = YES;
        [[SobotUITools getCurWindow] addSubview:self];
        self.backgroundColor = UIColorFromModeColor(SobotColorBgMain);
//        self.backgroundColor = UIColor.greenColor;
        self.userInteractionEnabled = YES;

        [self createTableView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCloseView)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        
        
        
    }
    return self;
}

-(void)createTableView{
    
    _mainView = [[UIScrollView alloc] init];
//    _mainView.backgroundColor = UIColor.redColor;
    _mainView.showsHorizontalScrollIndicator = NO;
    _mainView.bounces = NO;
    _mainView.scrollEnabled = YES;
    _mainView.showsVerticalScrollIndicator = YES;
    _mainView.alwaysBounceHorizontal = NO;
    [self addSubview:_mainView];
    [self addConstraint:sobotLayoutPaddingLeft(0, self.mainView, self)];
    [self addConstraint:sobotLayoutPaddingRight(0, self.mainView, self)];
    [self addConstraint:sobotLayoutPaddingTop(0, self.mainView, self)];
    [self addConstraint:sobotLayoutPaddingBottom(0, self.mainView, self)];
    
    
    
    _infoView = [ZCChatMessageInfoView createViewUseFactory:self.model];
    _infoView.delegate = self;
//    _infoView.backgroundColor = UIColor.yellowColor;
    [self.mainView addSubview:_infoView];
    [self.mainView addConstraint:sobotLayoutPaddingLeft(0, self.infoView, self.mainView)];
    _layoutCW = sobotLayoutEqualWidth(ScreenWidth, self.infoView, NSLayoutRelationEqual);
    [self.mainView addConstraint:_layoutCW];
    
    CGFloat h = [_infoView dataToView:self.model];
    _layoutTop = sobotLayoutPaddingTop(0, self.infoView, self.mainView);
    if(h < (ScreenHeight-NavBarHeight -XBottomBarHeight)){
        self.layoutCY = sobotLayoutEqualCenterY(0, self.infoView, self.mainView);
        [self.mainView addConstraint:self.layoutCY];
    }else{
        [self.mainView addConstraint:_layoutTop];
    }

    [self.mainView setContentSize:CGSizeMake(0, h)];
}


-(void)safeAreaInsetsDidChange{
    
    if(!sobotIsNull(_infoView)){
        [_infoView layoutIfNeeded];
        CGFloat h = CGRectGetHeight(_infoView.frame);
        if(self.layoutTop){
            [self.mainView removeConstraint:self.layoutCY];
        }
        if(self.layoutCY){
            [self.mainView removeConstraint:self.layoutCY];
        }
        _layoutTop = sobotLayoutPaddingTop(0, self.infoView, self.mainView);
       
    //    if(h < (ScreenHeight-ScreenHeight-NavBarHeight -XBottomBarHeight)){
    //        _layoutTop.constant = (ScreenHeight-h)/2;
    //    }
        
        if(h < (ScreenHeight-NavBarHeight -XBottomBarHeight)){
            self.layoutCY = sobotLayoutEqualCenterY(0, self.infoView, self.mainView);
            [self.mainView addConstraint:self.layoutCY];
        }else{
            [self.mainView addConstraint:_layoutTop];
        }
        
        _layoutCW.constant = ScreenWidth;
    }   
}

#pragma mark -- 添加显示
- (void)showInView:(UIView *)view{
    [[SobotUITools getCurWindow] addSubview:self];
    // 计算最终高度 重新布局约束
}


#pragma mark -- 关闭页面
- (void)dismissView{
    [self removeFromSuperview];
}

-(void)tapCloseView{
    [self dismissView];
}

#pragma mark 子页面代理
-(void)onViewEvent:(ZCChatMessageInfoViewEvent)type dict:(NSDictionary *)dict obj:(id)obj{
    if(type == ZCChatMessageInfoViewEventOpenUrl){
        NSString *url = sobotConvertToString(obj);
        if(url.length >0){
            if([ZCUICore getUICore].detailViewBlock){
                [ZCUICore getUICore].detailViewBlock(nil, ZCChatCellClickTypeOpenURL, sobotConvertToString(url));
            }
        }
    }else if(type == ZCChatMessageInfoViewEventOpenVideo){
        NSString *url = sobotConvertToString(obj);
        NSURL *fileurl ;
        if(![url hasPrefix:@"http"]){
            fileurl = [NSURL fileURLWithPath:url];
        }
        ZCVideoPlayer *player = [[ZCVideoPlayer alloc] initWithFrame:sobotGetCurWindow().bounds withShowInView:sobotGetCurWindow() url:fileurl Image:nil];
        [player showControlsView];
    }else if (type == ZCChatMessageInfoViewEventOpenFile){
        SobotChatMessage *model = (SobotChatMessage*)(obj);
        if([ZCUICore getUICore].detailViewBlock){
            [ZCUICore getUICore].detailViewBlock(model, ZCChatCellClickTypeOpenFile, nil);
        }    
    }
    [self tapCloseView];
}

#pragma mark -- 手势冲突的代理
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[SobotButton class]] || [touch.view isMemberOfClass:[SobotEmojiLabel class]] ){
        return NO;
    }
    return YES;
}
@end
