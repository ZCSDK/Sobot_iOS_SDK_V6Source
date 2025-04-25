//
//  ZCQuickLeaveView.m
//  SobotKit
//
//  Created by zhangxy on 2022/4/20.
//  Copyright © 2022 zhichi. All rights reserved.
//

#import "ZCQuickLeaveView.h"
#import "ZCLeaveEditView.h"
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClient.h>
#import "ZCUIKitTools.h"
@interface ZCQuickLeaveView(){
    CGFloat viewWidth;
    CGFloat viewHeight;
}
@property (nonatomic,strong) UIView * backGroundView;
@property (nonatomic,strong) ZCLeaveEditView * leaveEditView;
@property (nonatomic,strong) UIViewController * controller;

@end


@implementation ZCQuickLeaveView


-(ZCQuickLeaveView *)initActionSheet:(UIView *)view withController:(UIViewController *)exController{
    self = [super init];
    if (self) {
        viewWidth = view.frame.size.width;
        viewHeight = ScreenHeight;
        _controller = exController;
        
        self.frame = CGRectMake(0, 0, viewWidth, viewHeight);
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.autoresizesSubviews = YES;
        self.backgroundColor = UIColorFromModeColorAlpha(SobotColorBlack, 0.6);
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareViewDismiss:)];
        [self addGestureRecognizer:tapGesture];
        
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews{
    CGFloat bw=viewWidth;
    self.backGroundView = [[UIView alloc] initWithFrame:CGRectMake((viewWidth - bw) / 2.0, viewHeight, bw, 0)];
    self.backGroundView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
    self.backGroundView.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
    self.backGroundView.layer.masksToBounds = YES;
    [self addSubview:self.backGroundView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, bw-32, 52)];
    [titleLabel setText:SobotKitLocalString(@"填写信息")];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    self.backGroundView.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
    [titleLabel setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
    [titleLabel setFont:SobotFontBold16];
    [self.backGroundView addSubview:titleLabel];
    
    // 线条
     UIView *topline = [[UIView alloc]initWithFrame:CGRectMake(0, 52, viewWidth, 0.5)];
     topline.backgroundColor = [ZCUIKitTools zcgetCommentButtonLineColor];
     topline.autoresizingMask = UIViewAutoresizingFlexibleWidth;
     [self.backGroundView addSubview:topline];
    
    // 左上角的删除按钮
//    UIButton *cannelButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [cannelButton setFrame:CGRectMake(viewWidth - 40, (52 - 30)/2, 30,30)];
//    cannelButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
//    [cannelButton setImage:[SobotUITools getSysImageByName:@"zcicon_sf_close"] forState:UIControlStateNormal];
//    cannelButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    [cannelButton addTarget:self action:@selector(closePage) forControlEvents:UIControlEventTouchUpInside];
//    [self.backGroundView addSubview:cannelButton];
    
    self.leaveEditView = [[ZCLeaveEditView alloc] initWithFrame:CGRectMake(0, 52, bw, viewHeight- 200 - 52) withController:_controller];
    [self.backGroundView addSubview:_leaveEditView];
    
    [UIView animateWithDuration:0.25f animations:^{
        [self->_backGroundView setFrame:CGRectMake(self.backGroundView.frame.origin.x, self->viewHeight - CGRectGetMaxY(self->_leaveEditView.frame) - XBottomBarHeight - 20,self->_backGroundView.frame.size.width, CGRectGetMaxY(self->_leaveEditView.frame)+XBottomBarHeight + 20)];
        // 设置顶部圆角
        [ZCUIKitTools addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadii:CGSizeMake(8, 8) withView:self->_backGroundView];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)showEditView{
    _leaveEditView.ticketTitleShowFlag = _ticketTitleShowFlag;
    _leaveEditView.tickeTypeFlag = _tickeTypeFlag;
    _leaveEditView.typeArr = _typeArr;
    _leaveEditView.ticketTypeId = _ticketTypeId;
    _leaveEditView.msgTmp = _msgTmp;
    _leaveEditView.msgTxt = _msgTxt;
    _leaveEditView.templateldIdDic = _templateldIdDic;
    _leaveEditView.emailFlag = _emailFlag;
    _leaveEditView.emailShowFlag = _emailShowFlag;
    _leaveEditView.telFlag = _telFlag;
    _leaveEditView.telShowFlag = _telShowFlag;
    _leaveEditView.enclosureFlag = _enclosureFlag;
    _leaveEditView.enclosureShowFlag = _enclosureShowFlag;
    _leaveEditView.ticketContentFillFlag = _ticketContentFillFlag;
    _leaveEditView.ticketContentShowFlag = _ticketContentShowFlag;
    _leaveEditView.coustomArr = _coustomArr;
    _leaveEditView.fromSheetView = YES;
    _leaveEditView.ticketFrom = @"21";
    __block ZCQuickLeaveView *safeSelf = self;
    [_leaveEditView setPageChangedBlock:^(id  _Nonnull object, int code) {
        //code==1 添加成功,code == 2点击完成，跳转页面
        if(code == 1){
            [safeSelf tappedCancel];
        }
        if(code == 3001 || code == 3002){
            [safeSelf tappedCancel];
        }
        
        if(_closeBlock){
            _closeBlock(1,2);
        }
        
        if(safeSelf.resultBlock){
            safeSelf.resultBlock(code,safeSelf.leaveEditView.uploadMessage);
        }
    }];
    [_leaveEditView loadCustomFields];
    [[SobotUITools getCurWindow] addSubview:self];
}


// 隐藏弹出层
- (void)shareViewDismiss:(UITapGestureRecognizer *) gestap{
    CGPoint point = [gestap locationInView:self];
    CGRect f=self.backGroundView.frame;
    if(point.x<f.origin.x || point.x>(f.origin.x+f.size.width) ||
       point.y<f.origin.y || point.y>(f.origin.y+f.size.height)){
        if(_closeBlock){
            _closeBlock(0,1);
        }
        
        [self tappedCancel:YES];
    }
}
-(void)closePage{
    if(_closeBlock){
        _closeBlock(0,0);
    }
    [self tappedCancel];
}



- (void)tappedCancel{
    [self tappedCancel:YES];
}

/**
 *  关闭弹出层
 */
- (void)tappedCancel:(BOOL) isClose{
    // 移除通知
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.backGroundView setFrame:CGRectMake(_backGroundView.frame.origin.x,viewHeight ,self.backGroundView.frame.size.width,self.backGroundView.frame.size.height)];
    [self removeFromSuperview];
}


@end
