//
//  ZCReplyLeaveView.m
//  SobotKit
//
//  Created by xuhan on 2019/12/4.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import "ZCReplyLeaveView.h"
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClient.h>
#import "ZCUIPlaceHolderTextView.h"

#import "ZCUIKitTools.h"
#import "ZCUICore.h"
@interface ZCReplyLeaveView()<UITextViewDelegate,SobotActionSheetViewDelegate>{
    UIButton *delButton;
    UIButton *submitButton;
    CGFloat pageH;
}

@property (nonatomic, strong) UIView *backGroundView;
@property (nonatomic, assign) float viewWidth;
@property (nonatomic, assign) float viewHeight;
@property (nonatomic, strong) UIScrollView *fileScrollView; // 放图片
@property (nonatomic, strong) SobotImageView * imageView;
@property (nonatomic, strong) UIImagePickerController *zc_imagepicker;
// 中间滚动视图
@property (nonatomic, strong) UIScrollView *contScrollView;

@property (nonatomic, strong) UIView *fileItemsView;
@property (nonatomic, strong) UILabel *tipLab;
// 滑块的内容视图
@property (nonatomic, strong) UIView *scView;
// 每一个图片的宽高
@property (nonatomic, assign) CGFloat itemW;
// 获取图片的最终高度
@property (nonatomic, strong) NSLayoutConstraint *fileItemsViewH;;
// 滑块视图的内容
@property (nonatomic, strong) UIView *sbgView;
//中间滑动模块的高度
@property (nonatomic, strong) NSLayoutConstraint *scontH;
// 当前是否显示键盘了
@property (nonatomic, assign) BOOL isShowKeyboard;
// 键盘的高度
@property (nonatomic, assign) CGFloat keyboardHeight;
// 上一次计算完之后的高度
@property (nonatomic, assign) CGFloat lastFileH;
// 输入框也要动态高度计算 默认 100
@property (nonatomic, strong) NSLayoutConstraint *textDescH;
// 上一次的输入框的高度
@property (nonatomic, assign) CGFloat lastTextH;

// 上传附件的按钮
@property (nonatomic,strong) UIButton *fileButton;
@property (nonatomic, strong) UIView *fileBtnBgView;
@property (nonatomic, strong) UILabel *filelab;
@property (nonatomic,strong) UIImageView *iconImg;

@property (nonatomic,strong)NSLayoutConstraint *fileBtnBgViewMT;
@property (nonatomic,strong)NSLayoutConstraint *fileBgViewW;
// 正在请求接口
@property(nonatomic,assign) BOOL isLoading;
@end

@implementation ZCReplyLeaveView

#pragma mark - init

-(ZCReplyLeaveView *)initActionSheetWithView:(UIView *)view{
    self = [super init];
       if (self) {
           self.viewWidth = view.frame.size.width;
           self.viewHeight = ScreenHeight;
           self.frame = CGRectMake(0, 0, self.viewWidth, self.viewHeight);
           self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
           self.autoresizesSubviews = YES;
           self.backgroundColor = SobotColorFromRGBAlpha(0x000000, 0.6);
           self.userInteractionEnabled = YES;
           UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareViewDismiss:)];
           [self addGestureRecognizer:tapGesture];
           self.lastTextH = 100;
           [self createSubviews];
       }
    return self;
}

#pragma mark - 布局
- (void)createSubviews {
    self.backGroundView = [[UIView alloc] init];
    self.backGroundView.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
    self.backGroundView.layer.masksToBounds = YES;
    [self addSubview:self.backGroundView];
    
    float textDesc_height;
        
    // 整体按约束布局，提供横竖屏的最大高度
    pageH = 301 + XBottomBarHeight;
    self.backGroundView.frame = CGRectMake(0, self.viewHeight, self.viewWidth, pageH);
//    self.itemW = (_viewWidth-32-3*8)/4;
    self.itemW = 0;
    if (self.viewHeight > self.viewWidth) {
        // 竖屏
        textDesc_height = 112;
    }else {
        pageH = _viewHeight - NavBarHeight -52-XBottomBarHeight;
        // 横屏
        textDesc_height = 40;
    }
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setText:SobotKitLocalString(@"回复")];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    titleLabel.numberOfLines = 0;
    [titleLabel setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark1)];
    [titleLabel setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
    [titleLabel setFont:SobotFontBold17];
    [self.backGroundView addSubview:titleLabel];
    [self.backGroundView addConstraint:sobotLayoutPaddingTop(0, titleLabel, self.backGroundView)];
    [self.backGroundView addConstraint:sobotLayoutPaddingLeft(16, titleLabel, self.backGroundView)];
    [self.backGroundView addConstraint:sobotLayoutPaddingRight(-16, titleLabel, self.backGroundView)];
    [self.backGroundView addConstraint:sobotLayoutEqualHeight(52, titleLabel, NSLayoutRelationEqual)];
    // 线条
     UIView *topline = [[UIView alloc]init];
    topline.backgroundColor = UIColorFromKitModeColor(SobotColorBgTopLine);
    [titleLabel addSubview:topline];
    [titleLabel addConstraint:sobotLayoutPaddingLeft(-16, topline, titleLabel)];
    [titleLabel addConstraint:sobotLayoutPaddingRight(16, topline, titleLabel)];
    [titleLabel addConstraint:sobotLayoutEqualHeight(0.5, topline, NSLayoutRelationEqual)];
    [titleLabel addConstraint:sobotLayoutPaddingBottom(0, topline, titleLabel)];
    
    _contScrollView = ({
        UIScrollView *iv =[[UIScrollView alloc]init];
        [self.backGroundView addSubview:iv];
        iv.showsHorizontalScrollIndicator = NO;
        iv.showsVerticalScrollIndicator = YES;
        iv.alwaysBounceVertical = NO;
        iv.alwaysBounceHorizontal = NO;
        iv.pagingEnabled = NO;
        iv.bounces = NO;
        iv.scrollEnabled = YES;
        iv.delegate = self;
        iv.userInteractionEnabled = YES;
        [self.backGroundView addConstraint:sobotLayoutMarginTop(0, iv, titleLabel)];
        [self.backGroundView addConstraint:sobotLayoutPaddingLeft(0, iv, self.backGroundView)];
        [self.backGroundView addConstraint:sobotLayoutPaddingRight(0, iv, self.backGroundView)];
        self.scontH = sobotLayoutEqualHeight(pageH-52-XBottomBarHeight-50, iv, NSLayoutRelationEqual);
        [self.backGroundView addConstraint:self.scontH];
        [self.contScrollView setContentSize:CGSizeMake(0, pageH-52-XBottomBarHeight-50)];
//        iv.backgroundColor = UIColor.greenColor;
        iv;
    });
    
    _sbgView = ({
        UIView *iv = [[UIView alloc]init];
        [self.contScrollView addSubview:iv];
        iv.backgroundColor = UIColor.clearColor;
        [self.contScrollView addConstraint:sobotLayoutPaddingTop(0, iv, self.contScrollView)];
        [self.contScrollView addConstraint:sobotLayoutPaddingLeft(0, iv, self.contScrollView)];
        [self.contScrollView addConstraint:sobotLayoutPaddingBottom(0, iv, self.contScrollView)];
        [self.contScrollView addConstraint:sobotLayoutEqualWidth(_viewWidth, iv, NSLayoutRelationEqual)];
        iv;
    });
    
//   输入框
    _textDesc = ({
        ZCUITextView *iv = [[ZCUITextView alloc]init];
        [_sbgView addSubview:iv];
        iv.placeholder = SobotKitLocalString(@"请输入");
        [iv setPlaceholderColor:UIColorFromKitModeColor(SobotColorTextSub1)];
        iv.placeholederFont = SobotFont14;
        [iv setFont:SobotFont14];
        [iv setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
        iv.delegate = self;
        iv.placeholederFont = SobotFont14;
        iv.showsVerticalScrollIndicator = YES;
        [iv setBackgroundColor:UIColor.clearColor];
        [_sbgView addConstraint:sobotLayoutPaddingTop(12, iv, _sbgView)];
        [_sbgView addConstraint:sobotLayoutPaddingLeft(12, iv, _sbgView)];
        [_sbgView addConstraint:sobotLayoutPaddingRight(-12, iv, _sbgView)];
        self.textDescH = sobotLayoutEqualHeight(100, iv, NSLayoutRelationEqual);
        [_sbgView addConstraint:self.textDescH];
//        iv.backgroundColor = UIColor.redColor;
        iv;
    });
        
    if(SobotKitIsRTLLayout){
        [self.textDesc setTextAlignment:NSTextAlignmentRight];
    }
    
    // 这里需要计算宽度
    NSString *tip = SobotKitLocalString(@"上传附件");
    CGFloat w1 = [SobotUITools getWidthContain:tip font:SobotFont12 Height:20];
    // 左右间距
    w1 = w1 + 42;
    if (w1 <90) {
        w1 = 90;
    }
    
    _fileBtnBgView = ({
        UIView *iv = [[UIView alloc]init];
        [self.sbgView addSubview:iv];
        iv.layer.masksToBounds = YES;
        iv.layer.cornerRadius = 4;
        iv.layer.borderWidth = 1;
        iv.layer.borderColor = UIColorFromKitModeColor(SobotColorBgTopLine).CGColor;
        self.fileBtnBgViewMT = sobotLayoutMarginTop(17, iv, self.textDesc);
        [self.sbgView addConstraint:self.fileBtnBgViewMT];
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            [self.sbgView addConstraint:sobotLayoutPaddingRight(-16, iv, self.sbgView)];
        }else{
            [self.sbgView addConstraint:sobotLayoutPaddingLeft(16, iv, self.sbgView)];
        }
        self.fileBgViewW = sobotLayoutEqualWidth(w1, iv, NSLayoutRelationEqual);
        [self.sbgView addConstraint:self.fileBgViewW];
        [self.sbgView addConstraint:sobotLayoutEqualHeight(28, iv, NSLayoutRelationEqual)];
        iv;
    });
    
    _iconImg = ({
        UIImageView *iv = [[UIImageView alloc]init];
        [self.fileBtnBgView addSubview:iv];
        iv.contentMode = UIViewContentModeScaleAspectFit;
        [self.fileBtnBgView addConstraint:sobotLayoutEqualWidth(14, iv, NSLayoutRelationEqual)];
        [self.fileBtnBgView addConstraint:sobotLayoutEqualHeight(14, iv, NSLayoutRelationEqual)];
        [self.fileBtnBgView addConstraint:sobotLayoutPaddingLeft(12, iv, self.fileBtnBgView)];
        [self.fileBtnBgView addConstraint:sobotLayoutPaddingTop(7, iv, self.fileBtnBgView)];
        [iv setImage:[SobotUITools getSysImageByName:@"zcicon_upfile"]];
        iv;
    });
    
    _filelab = ({
        UILabel *iv = [[UILabel alloc]init];
        iv.text = SobotKitLocalString(@"上传附件");
        iv.textColor = UIColorFromKitModeColor(SobotColorTextMain);
        iv.font = SobotFont12;
        [self.fileBtnBgView addSubview:iv];
        [self.fileBtnBgView addConstraint:sobotLayoutPaddingRight(-12, iv, self.fileBtnBgView)];
        [self.fileBtnBgView addConstraint:sobotLayoutMarginLeft(4, iv, self.iconImg)];
        [self.fileBtnBgView addConstraint:sobotLayoutEqualHeight(20, iv, NSLayoutRelationEqual)];
        [self.fileBtnBgView addConstraint:sobotLayoutPaddingTop(4, iv, self.fileBtnBgView)];
        iv;
    });
    
    _fileButton = ({
        UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.fileBtnBgView addSubview:iv];
        [iv addTarget:self action:@selector(photoSelecte) forControlEvents:UIControlEventTouchUpInside];
        [self.fileBtnBgView addConstraint:sobotLayoutPaddingLeft(0, iv, self.fileBtnBgView)];
        [self.fileBtnBgView addConstraint:sobotLayoutPaddingRight(0, iv, self.fileBtnBgView)];
        [self.fileBtnBgView addConstraint:sobotLayoutPaddingTop(0, iv, self.fileBtnBgView)];
        [self.fileBtnBgView addConstraint:sobotLayoutPaddingBottom(0, iv, self.fileBtnBgView)];
        iv;
    });
    NSString *text = [NSString stringWithFormat:@"%@%@%@%@%@",SobotKitLocalString(@"最多上传"),@"15",SobotKitLocalString(@"个，"),SobotKitLocalString(@"大小不超过"),@"50M"];
    CGFloat th = [SobotUITools getHeightContain:text font:SobotFont12 Width:ScreenWidth-32];
    if (th <20) {
        th = 20;
    }
    
    _tipLab = ({
        UILabel *iv = [[UILabel alloc]init];
//        iv.text = SobotKitLocalString(@"最多上传 15 个，大小不超过 50M");
        iv.text = text;
        iv.textColor = UIColorFromKitModeColor(SobotColorTextSub1);
        iv.numberOfLines = 0;
        iv.font = SobotFont12;
        [_sbgView addSubview:iv];
        [_sbgView addConstraint:sobotLayoutMarginTop(6, iv, self.fileBtnBgView)];
        [_sbgView addConstraint:sobotLayoutPaddingLeft(16, iv, _sbgView)];
        [_sbgView addConstraint:sobotLayoutPaddingRight(-16, iv, _sbgView)];
//        [_sbgView addConstraint:sobotLayoutPaddingBottom(-16, iv, _sbgView)];
        // 下面的视图去做间距
        iv;
    });
    
    
    // 中间添加部分
    _fileItemsView = ({
        UIView *iv = [[UIView alloc]init];
        [_sbgView addSubview:iv];
        [_sbgView addConstraint:sobotLayoutMarginTop(16, iv, self.tipLab)];
        [_sbgView addConstraint:sobotLayoutPaddingLeft(16, iv, _sbgView)];
        [_sbgView addConstraint:sobotLayoutPaddingRight(-16, iv, _sbgView)];
        self.fileItemsViewH = sobotLayoutEqualHeight(self.itemW, iv, NSLayoutRelationEqual);
        [_sbgView addConstraint:self.fileItemsViewH];
        [_sbgView addConstraint:sobotLayoutPaddingBottom(0, iv, _sbgView)];
//        iv.backgroundColor = UIColor.purpleColor;
        iv;
    });
    self.lastFileH = self.itemW;
        
    [self reloadFileItemView];

    
//    提交按钮
    submitButton = ({
        UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
        iv.backgroundColor = [ZCUIKitTools zcgetServerConfigBtnBgColor];
        iv.layer.cornerRadius = 4;
        [iv setTitleColor:[ZCUIKitTools zcgetRobotBtnTitleColor] forState:UIControlStateNormal];
        [iv setTitle:SobotKitLocalString(@"提交") forState:UIControlStateNormal];
        [iv addTarget:self action:@selector(submitButtonClick) forControlEvents:UIControlEventTouchUpInside];
        iv.titleLabel.font = SobotFont16;
        [self.backGroundView addSubview:iv];
        [self.backGroundView addConstraint:sobotLayoutMarginTop(10, iv, self.contScrollView)];
        [self.backGroundView addConstraint:sobotLayoutPaddingLeft(16, iv, self.backGroundView)];
        [self.backGroundView addConstraint:sobotLayoutPaddingRight(-16, iv, self.backGroundView)];
        [self.backGroundView addConstraint:sobotLayoutEqualHeight(40, iv, NSLayoutRelationEqual)];
        iv;
    });

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    UITapGestureRecognizer * tapGesture_1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureClick_1)];
    [self.backGroundView addGestureRecognizer:tapGesture_1];
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureClick)];
    [self.backGroundView addGestureRecognizer:tapGesture];
}

- (void)tapGestureClick_1{
    [self tappedCancel:YES];
}

- (void)tapGestureClick{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

#pragma mark - 显示

- (void)showInView:(UIView *)view{
    [view addSubview:self];
    [UIView animateWithDuration:0.25f animations:^{
        float x = 0;
        float w = self.backGroundView.frame.size.width;
        CGFloat navh = NavBarHeight;
        if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
            navh = 0;
        }
        // 这里
        self.backGroundView.frame = CGRectMake(x,self.viewHeight- self->pageH-navh,w,self->pageH);
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - 点击
- (void)submitButtonClick{
    if (self.isLoading) {
        return;
    }
    _isLoading = YES;
    submitButton.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->submitButton.enabled = YES;
    });
//    判断输入框是否为空 请填写回复内容
    if(self.textDesc.text.length == 0 || sobotTrimString(self.textDesc.text).length == 0){
        [[SobotToast shareToast] showToast:SobotKitLocalString(@"回复内容不能为空") duration:1.0 view:self position:SobotToastPositionCenter];
        _isLoading = NO;
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:sobotConvertToString(self.textDesc.text) forKey:@"replyContent"];
    [dic setObject:sobotConvertToString(self.ticketId) forKey:@"ticketId"];
    [dic setObject:sobotConvertToString([self getCurConfig].companyID) forKey:@"companyId"];
    if(_imageArr.count>0){
        NSString *fileStr = @"";
        for (NSDictionary *model in _imageArr) {
            fileStr = [fileStr stringByAppendingFormat:@"%@;",sobotConvertToString(model[@"fileUrl"])];
        }
        fileStr = [fileStr substringToIndex:fileStr.length-1];
        [dic setObject:sobotConvertToString(fileStr) forKey:@"fileStr"];
    }
    
    __block ZCReplyLeaveView *saveSelf = self;
      [ZCLibServer replyLeaveMessage:[[ZCPlatformTools sharedInstance] getPlatformInfo].config replayParam:dic start:^{
          
      } success:^(NSDictionary *dict, NSMutableArray *itemArray, ZCNetWorkCode sendCode) {
          [self tappedCancel:NO];
          if ([self.delegate respondsToSelector:@selector(replySuccess)]) {
              [self.delegate replySuccess];
          }
          self->_isLoading = NO;
      } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
          self->_isLoading = NO;
          [[SobotToast shareToast] showToast:SobotKitLocalString(@"提交失败") duration:1.0f view:saveSelf position:SobotToastPositionCenter];
      }];
}

#pragma mark - 键盘收起
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return [textField resignFirstResponder];
}

-(void)textViewDidChange:(UITextView *)textView{
    CGSize contentSize = textView.contentSize;
    if (contentSize.height > 100) {
        self.textDescH.constant = contentSize.height;
    }else{
        self.textDescH.constant = 100;
    }
    if (self.lastTextH != self.textDescH.constant) {
        [self setScrollViewFrameChange:NO];
    }
}


#pragma mark - tools
-(ZCLibConfig *)getCurConfig{
    return [[ZCPlatformTools sharedInstance] getPlatformInfo].config;
}

#pragma mark - 隐藏

// 隐藏弹出层
- (void)shareViewDismiss:(UITapGestureRecognizer *) gestap{
    CGPoint point = [gestap locationInView:self];
    CGRect f=self.backGroundView.frame;
    
    if(point.x<f.origin.x || point.x>(f.origin.x+f.size.width) ||
       point.y<f.origin.y || point.y>(f.origin.y+f.size.height)){
        [self tappedCancel:YES];
    }
}

- (void)tappedCancel{
    if ([self.delegate respondsToSelector:@selector(closeWithReplyStr:)]) {
        [self.delegate closeWithReplyStr:self.textDesc.text];
    }
    [self tappedCancel:YES];
}

/**
 *  关闭弹出层
 */
- (void)tappedCancel:(BOOL) isClose{
    NSUserDefaults *defaultDict = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@_%@_%@",[self getCurConfig].cid,[self getCurConfig].uid,self.ticketId];
    if (isClose) {
        // 不是提交成功的，关闭页面要做缓存处理
        if (self.imageArr.count == 0 && self.imagePathArr.count == 0 && self.textDesc.text.length == 0) {
            // 都没有值 没有必要存
        }else{
            NSMutableArray *imageArr = [NSMutableArray array];
            if (!sobotIsNull(self.imageArr)) {
                imageArr = self.imageArr;
            }
            NSMutableArray *imagepath = [NSMutableArray array];
            if (!sobotIsNull(self.imagePathArr)) {
                imagepath = self.imagePathArr;
            }
            NSString *text = @"";
            if (self.textDesc.text.length >0) {
                text = self.textDesc.text;
            }
            // 这里做中间变量是为了存储的时候不能出现 nil的异常
            NSDictionary *dict = @{@"images":imageArr,@"imagepath":imagepath,@"text":sobotConvertToString(text)};
            [defaultDict setObject:dict forKey:key];
        }
    }else{
        // 提交成功了，清理掉之前缓冲的数据
        if (!sobotIsNull([defaultDict objectForKey:key])) {
           [defaultDict removeObjectForKey:key];
        }
    }
    // 移除通知
    [[NSNotificationCenter defaultCenter]removeObserver:self];
//    [UIView animateWithDuration:0 animations:^{
        [self.backGroundView setFrame:CGRectMake(_backGroundView.frame.origin.x,self.viewHeight ,self.backGroundView.frame.size.width,self.backGroundView.frame.size.height)];
//        self.alpha = 0;
//    } completion:^(BOOL finished) {
//        if (finished) {
            [self removeFromSuperview];
//        }
}

#pragma mark - 键盘事件

-(void)keyBoardWillShow:(NSNotification *) notification{
    self.isShowKeyboard = YES;
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat keyboardHeight = [[[notification userInfo] objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue].size.height;
    self.keyboardHeight = keyboardHeight ;
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationDelegate:self];
    {
//        CGRect  sheetViewFrame = self.backGroundView.frame;
//        float h = XBottomBarHeight;
//        sheetViewFrame.origin.y = self.viewHeight - keyboardHeight - self.backGroundView.frame.size.height + h;
//        self.backGroundView.frame = sheetViewFrame;
        [self setScrollViewFrameChange:YES];
        [self.contScrollView setContentOffset:CGPointMake(0, 0)];
    }
    // commit animations
    [UIView commitAnimations];
}

//键盘隐藏
- (void)keyBoardWillHide:(NSNotification *)notification {
    self.isShowKeyboard = NO;
    self.keyboardHeight = 0;
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView beginAnimations:@"bottomBarDown" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView commitAnimations];
    [UIView animateWithDuration:0.25 animations:^{
//        CGRect sheetFrame = self.backGroundView.frame;
//        sheetFrame.origin.y = self.viewHeight - self.backGroundView.frame.size.height;
//        self.backGroundView.frame = sheetFrame;
        [self setScrollViewFrameChange:YES];
    }];
}

#pragma mark - 手势冲突的代理

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIButton class]]  ||  [touch.view isMemberOfClass:[UIImageView class]]){
        return NO;
    }
    return YES;
}

-(void)reloadFileItemViews:(BOOL)isShowClear{
    // 先移除，后添加
    [[self.fileItemsView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSUInteger assetCount = self.imageArr.count;
    UIView *lastView;
    for (int i = 0; i<assetCount; i++) {
        UIView *itemView = [[UIView alloc]init];
        [self.fileItemsView addSubview:itemView];
        itemView.backgroundColor = UIColorFromKitModeColor(SobotColorBgSub);
        itemView.layer.cornerRadius = 4;
        itemView.layer.masksToBounds = YES;
        if (sobotIsNull(lastView)) {
            [self.fileItemsView addConstraint:sobotLayoutPaddingTop(0, itemView, self.fileItemsView)];
        }else{
            [self.fileItemsView addConstraint:sobotLayoutMarginTop(8, itemView, lastView)];
        }
        [self.fileItemsView addConstraint:sobotLayoutPaddingLeft(0, itemView, self.fileItemsView)];
        [self.fileItemsView addConstraint:sobotLayoutPaddingRight(0, itemView, self.fileItemsView)];
        [self.fileItemsView addConstraint:sobotLayoutEqualHeight(64, itemView, NSLayoutRelationEqual)];
        lastView = itemView;
        if (i == assetCount -1) {
            [self.fileItemsView addConstraint:sobotLayoutPaddingBottom(0, itemView, self.fileItemsView)];
            if (i == 0) {
                self.fileItemsViewH.constant = 64;
                self.itemW = 64;
            }else{
                self.fileItemsViewH.constant = 64*(i+1) + (8*i);
                self.itemW = 64*(i+1) + (8*i);
            }
            
            SLog(@"00000000------%f", self.fileItemsViewH.constant);
        }
        // 子控件
        UIButton *icon = [[UIButton alloc]init];
        [itemView addSubview:icon];
        icon.layer.cornerRadius = 4;
        icon.layer.masksToBounds = YES;
        icon.backgroundColor = UIColor.clearColor;
        [itemView addConstraint:sobotLayoutEqualWidth(40, icon, NSLayoutRelationEqual)];
        [itemView addConstraint:sobotLayoutEqualHeight(40, icon, NSLayoutRelationEqual)];
        [itemView addConstraint:sobotLayoutPaddingLeft(12, icon, itemView)];
        [itemView addConstraint:sobotLayoutEqualCenterY(0, icon, itemView)];
        icon.tag = 100+ i;
        
//        CGFloat size = 0;
        // 就从本地取
        if(sobotCheckFileIsExsis([_imagePathArr objectAtIndex:i])){
            UIImage *localImage=[UIImage imageWithContentsOfFile:[_imagePathArr objectAtIndex:i]];
            [icon setImage:localImage forState:0];
        }
        
        NSDictionary *imgDic = [_imageArr objectAtIndex:i];
        NSString *imgFileStr =  sobotConvertToString(imgDic[@"cover"]);
        if (imgFileStr.length>0) {
            UIImage *localImage=[UIImage imageWithContentsOfFile:imgFileStr];
            [icon setImage:localImage forState:0];
        }
        icon.imageView.contentMode = UIViewContentModeScaleAspectFit;
        UILabel *subTip = [[UILabel alloc]init];
        [itemView addSubview:subTip];
        subTip.textColor = UIColorFromKitModeColor(SobotColorTextMain);
        subTip.font = SobotFont14;
        subTip.numberOfLines = 1;
        [itemView addConstraint:sobotLayoutPaddingRight(-12, subTip, itemView)];
        [itemView addConstraint:sobotLayoutMarginLeft(8, subTip, icon)];
        [itemView addConstraint:sobotLayoutPaddingTop(12, subTip, itemView)];
        [itemView addConstraint:sobotLayoutEqualHeight(22, subTip, NSLayoutRelationEqual)];
        subTip.text = sobotConvertToString([_imagePathArr objectAtIndex:i]);
        subTip.lineBreakMode = NSLineBreakByTruncatingMiddle;
        subTip.text = sobotConvertToString([imgDic objectForKey:@"fileUrl"]);
        // UI要显示最后一级的
        NSString *tip = sobotConvertToString([_imagePathArr objectAtIndex:i]);
        if (tip.length >0) {
            NSArray *tipArr = [tip componentsSeparatedByString:@"/"];
            if (!sobotIsNull(tipArr) && tipArr.count >0) {
                subTip.text = sobotConvertToString([tipArr lastObject]);
            }
        }
        subTip.tag = 100 + i;
        
        UILabel *sizeLab = [[UILabel alloc]init];
        [itemView addSubview:sizeLab];
        sizeLab.font = SobotFont12;
        sizeLab.textColor = UIColorFromKitModeColor(SobotColorTextSub1);
        [itemView addConstraint:sobotLayoutMarginTop(0, sizeLab, subTip)];
        [itemView addConstraint:sobotLayoutEqualHeight(20, sizeLab, NSLayoutRelationEqual)];
        [itemView addConstraint:sobotLayoutMarginLeft(8, sizeLab, icon)];
        [itemView addConstraint:sobotLayoutPaddingRight(-12, sizeLab, itemView)];
        sizeLab.tag = 100 +i;
        
        // 整个点击事件
        SobotButton *clickBtn = [SobotButton buttonWithType:UIButtonTypeCustom];
        [itemView addSubview:clickBtn];
        clickBtn.backgroundColor = UIColor.clearColor;
        clickBtn.tag = 100 +i;
        clickBtn.obj = icon;
        [itemView addSubview:clickBtn];
        [itemView addConstraint:sobotLayoutPaddingTop(0, clickBtn, itemView)];
        [itemView addConstraint:sobotLayoutPaddingLeft(0, clickBtn, itemView)];
        [itemView addConstraint:sobotLayoutPaddingRight(-25, clickBtn, itemView)];
        [itemView addConstraint:sobotLayoutPaddingBottom(0, clickBtn, itemView)];
        // 点击放大图片，进入图片
        [clickBtn addTarget:self action:@selector(tapBrowser:) forControlEvents:UIControlEventTouchUpInside];
        
        if (isShowClear) {
            // 显示删除按钮
            UIImageView *btnDel = [[UIImageView alloc] init];
            [itemView addSubview:btnDel];
            [btnDel setImage:[SobotUITools getSysImageByName:@"zcicon_close_del"]];
            btnDel.contentMode = UIViewContentModeScaleAspectFill;
            btnDel.tag = 100 + i;
            // 点击放大图片，进入图片
            [itemView addConstraint:sobotLayoutPaddingTop(0, btnDel, itemView)];
            [itemView addConstraint:sobotLayoutPaddingRight(0, btnDel, itemView)];
            [itemView addConstraint:sobotLayoutEqualWidth(20, btnDel, NSLayoutRelationEqual)];
            [itemView addConstraint:sobotLayoutEqualHeight(20, btnDel, NSLayoutRelationEqual)];
            // 增大响应面积
            UIButton *btnDelbig = [UIButton buttonWithType:UIButtonTypeCustom];
            btnDelbig.tag = 100 + i;
            [btnDelbig addTarget:self action:@selector(tapDelFiles:) forControlEvents:UIControlEventTouchUpInside];
            [itemView addSubview:btnDelbig];
            [itemView addConstraint:sobotLayoutPaddingTop(0, btnDelbig, itemView)];
            [itemView addConstraint:sobotLayoutPaddingRight(0, btnDelbig, itemView)];
            [itemView addConstraint:sobotLayoutEqualWidth(50, btnDelbig, NSLayoutRelationEqual)];
            [itemView addConstraint:sobotLayoutEqualHeight(50, btnDelbig, NSLayoutRelationEqual)];
        }
        
        if (i == assetCount-1) {
            // 最后一个获取最大高度
//            self.fileItemsViewH.constant = itemY + itemH;
            self.fileItemsViewH.constant = 64*(i+1) + (8*i);
            self.itemW = 64*(i+1) + (8*i);
            SLog(@"00000000------%f", self.fileItemsViewH.constant);
            // 换一行的时候才改变 或者最后yi列
            [self setScrollViewFrameChange:NO];
            CGPoint bottomOffset = CGPointMake(0, self->_contScrollView.contentSize.height - self->_scontH.constant);
            [self->_contScrollView setContentOffset:bottomOffset animated:NO];
        }
    }
    if (assetCount == 0) {
        self.fileItemsViewH.constant = 0;
        self.itemW = 0;
        [self setScrollViewFrameChange:NO];
        CGPoint bottomOffset = CGPointMake(0, self->_contScrollView.contentSize.height - self->_scontH.constant);
        [self->_contScrollView setContentOffset:bottomOffset animated:NO];
    }
    if (assetCount == 15) {
        _fileBtnBgView.backgroundColor = UIColorFromKitModeColor(SobotColorBgGray);
    }else{
        _fileBtnBgView.backgroundColor = UIColor.clearColor;
    }
    
    
}


#pragma mark -- 新版 图片附件
-(void)reloadFileItemView{
    [self reloadFileItemViews:YES];
    // 下面是第一版UI 4格的场景
//    // 先移除，后添加
//    [[self.fileItemsView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
//    // 加一是为了有个添加button 最多15个 + 1个添加按钮
//    NSUInteger assetCount = self.imageArr.count +1 ;
//    CGFloat itemW = self.itemW;
//    CGFloat itemH = self.itemW;
//    CGFloat itemX = 0;
//    CGFloat itemY = 0;
//    CGFloat itemSpec = 8;
//    // 列
//    int kColCount = 4;
//    for (int i = 0; i<assetCount; i++) {
//        // 所在的行
//        int row = i/kColCount;
//        // 所在的列
//        int col = i%kColCount;
//        // 0 1 2 3
//        itemX = col *(itemW + itemSpec);
//        // 第 0行 1 2 3 的Y值
//        itemY = row *(itemH +itemSpec);
//        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
//        btn.frame = CGRectMake(itemX,itemY, itemW, itemH);
//        btn.layer.cornerRadius = 2;
//        btn.layer.masksToBounds = YES;
//        [self.fileItemsView addSubview:btn];
//        btn.backgroundColor = UIColorFromKitModeColor(SobotColorBgF5);
//        
//        // UIButton
//        if (i == self.imageArr.count){
//            // 最后一个Button
//            [btn setImage: [SobotUITools getSysImageByName:@"zcicon_add_photo_new"]  forState:UIControlStateNormal];
//            // 添加图片的点击事件
//            [btn addTarget:self action:@selector(photoSelecte) forControlEvents:UIControlEventTouchUpInside];
//            if (assetCount == 16) {
//                btn.frame = CGRectZero;
//                assetCount = 15;
//            }
//            [btn.imageView setContentMode:UIViewContentModeScaleAspectFit];
//        }else{
//            [btn.imageView setContentMode:UIViewContentModeScaleAspectFill];
//            // 就从本地取
//            if(sobotCheckFileIsExsis([_imagePathArr objectAtIndex:i])){
//                UIImage *localImage=[UIImage imageWithContentsOfFile:[_imagePathArr objectAtIndex:i]];
//                [btn setImage:localImage forState:UIControlStateNormal];
//            }
//            
//            NSDictionary *imgDic = [_imageArr objectAtIndex:i];
//            NSString *imgFileStr =  sobotConvertToString(imgDic[@"cover"]);
//            if (imgFileStr.length>0) {
//                UIImage *localImage=[UIImage imageWithContentsOfFile:imgFileStr];
//                [btn setImage:localImage forState:UIControlStateNormal];
//            }
//            btn.tag = 100+i;
//            // 点击放大图片，进入图片
//            [btn addTarget:self action:@selector(tapBrowser:) forControlEvents:UIControlEventTouchUpInside];
//                btn.layer.borderColor = UIColorFromKitModeColor(SobotColorBgLine).CGColor;
//        }
//        
//        // 删除按钮
//        if (i != self.imageArr.count){
//            UIButton *btnDel = [UIButton buttonWithType:UIButtonTypeCustom];
//            btnDel.imageView.contentMode = UIViewContentModeScaleAspectFit;
//            btnDel.frame = CGRectMake(itemW-10,0, 10, 10);
//            [btnDel setImage:[SobotUITools getSysImageByName:@"zcicon_close_del"] forState:0];
//            btnDel.tag = 100 + i;
//            // 点击放大图片，进入图片
//            [btnDel addTarget:self action:@selector(tapDelFiles:) forControlEvents:UIControlEventTouchUpInside];
//            [btn addSubview:btnDel];
//            
//            // 增大响应面积
//            UIButton *btnDelbig = [UIButton buttonWithType:UIButtonTypeCustom];
//            btnDelbig.frame = CGRectMake(itemW-25,0, 25, 25);
//            btnDelbig.tag = 100 + i;
//            [btnDelbig addTarget:self action:@selector(tapDelFiles:) forControlEvents:UIControlEventTouchUpInside];
//            [btn addSubview:btnDelbig];
//        }
//        
//        if (i == assetCount-1) {
//            // 最后一个获取最大高度
//            self.fileItemsViewH.constant = itemY + itemH;
//            SLog(@"00000000------%f", self.fileItemsViewH.constant);
//            // 换一行的时候才改变 或者最后yi列
//            [self setScrollViewFrameChange:NO];
//            CGPoint bottomOffset = CGPointMake(0, self->_contScrollView.contentSize.height - self->_scontH.constant);
//            [self->_contScrollView setContentOffset:bottomOffset animated:NO];
//        }
//    }
}

#pragma mark -- 动态计算中间滑块的高度和偏移量
-(void)setScrollViewFrameChange:(BOOL)isKeyboardChange{
    if (self.lastFileH != self.fileItemsViewH.constant || self.lastTextH != self.textDescH.constant) {
        if (self.lastFileH != self.fileItemsViewH.constant) {
            // 上一次的高度和这一次的不一样，item 个数有变化，要重新计算高度
            CGFloat changeH = self.fileItemsViewH.constant - self.lastFileH;
            // 内容的高度有变化
            self.lastFileH = self.fileItemsViewH.constant;
            // 大于1行，动态增加高度，不能大于80%
            CGFloat h = changeH;
            CGFloat maxH = _viewHeight*0.8 - self.keyboardHeight;
            CGFloat maxSH = maxH - 52 - 50 -XBottomBarHeight ;
            // 重新计算最外层的view;
            CGRect bgF = self.backGroundView.frame;
            if (self.scontH.constant + h > maxSH) {
                self.scontH.constant = maxSH;
            }else{
                self.scontH.constant = self.scontH.constant + h;
            }
            bgF.size.height = 52 + 50 + self.scontH.constant +XBottomBarHeight;
            // 这里差一个导航栏的高度
            CGFloat navh = NavBarHeight;
            if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
                navh = 0;
            }
            bgF.origin.y = self.viewHeight - bgF.size.height-self.keyboardHeight -navh;
            [self.backGroundView setFrame:bgF];
        }else{
           // 输入框发生变化了
            // 上一次的高度和这一次的不一样，item 个数有变化，要重新计算高度
            CGFloat changeH = self.textDescH.constant - self.lastTextH;
            // 内容的高度有变化
            self.lastTextH = self.textDescH.constant;
            // 大于1行，动态增加高度，不能大于80%
            CGFloat h = changeH;
            CGFloat maxH = _viewHeight*0.8 - self.keyboardHeight;
            CGFloat maxSH = maxH - 52 - 50 -XBottomBarHeight ;
            // 重新计算最外层的view;
            CGRect bgF = self.backGroundView.frame;
            if (self.scontH.constant + h > maxSH) {
                self.scontH.constant = maxSH;
            }else{
                self.scontH.constant = self.scontH.constant + h;
            }
            bgF.size.height = 52 + 50 + self.scontH.constant +XBottomBarHeight;
            // 这里差一个导航栏的高度
            CGFloat navh = NavBarHeight;
            if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
                navh = 0;
            }
            bgF.origin.y = self.viewHeight - bgF.size.height-self.keyboardHeight -navh;
            [self.backGroundView setFrame:bgF];
        }
    }else{
        // 内容高度无变化 键盘发生变化了
        if (isKeyboardChange) {
            CGRect textF = self.textDesc.frame;
            CGRect tipF = self.tipLab.frame;
            CGFloat contenH = self.fileItemsViewH.constant + textF.size.height + 17+28 + 6 +16 + tipF.size.height;
            
            
            // 获取当前的内容视图的大小
            CGFloat maxH = _viewHeight*0.8 - self.keyboardHeight;
            CGFloat maxSH = maxH - 52 - 50 -XBottomBarHeight;
            CGRect bgF = self.backGroundView.frame;
            if (contenH > maxSH) {
                self.scontH.constant = maxSH;
            }else{
                self.scontH.constant = contenH;
            }
            bgF.size.height = 52 + 50 + self.scontH.constant +XBottomBarHeight;
            // 这里差一个导航栏的高度
            CGFloat navh = NavBarHeight;
            if ([ZCUICore getUICore].kitInfo.navcBarHidden) {
                navh = 0;
            }
            bgF.origin.y = self.viewHeight - bgF.size.height - self.keyboardHeight-navh;
            [self.backGroundView setFrame:bgF];
        }
    }
    
    CGRect textF = self.textDesc.frame;
    CGRect tipF = self.tipLab.frame;
    // 新版UI改版
    CGFloat contenH = self.fileItemsViewH.constant + textF.size.height + 17+28+6+16+tipF.size.height;
    // 偏移量滚动到底部
    self->_contScrollView.contentSize = CGSizeMake(self->_viewWidth,contenH);
    
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [ZCUIKitTools addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadii:CGSizeMake(8, 8) withView:self.backGroundView];
}

-(void)reloadScrollView{
    [self reloadFileItemView];
}
#pragma mark - 增加 图片附件
//- (void)reloadScrollView{
//    // 先移除，后添加
//    [[self.fileScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
//    // 加一是为了有个添加button
//    NSUInteger assetCount = self.imageArr.count +1 ;
//    
//    CGFloat width = (self.fileScrollView.frame.size.width - 5*3)/4;
//    CGFloat heigth = 60;
//    NSUInteger countX = 0;
//    CGFloat x = 0;
//    if(SobotKitIsRTLLayout){
//       countX = (assetCount < 4) ? 4 : assetCount;
//    }
//    for (NSInteger i = 0; i < assetCount; i++) {
//        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
//        x=(width + 5)*i;
//        if(SobotKitIsRTLLayout){
//            x = (width + 5)* (countX - i - 1);
//        }
//        btn.frame = CGRectMake(x,0, width, heigth);
//        btn.layer.cornerRadius = 2;
//        btn.layer.masksToBounds = YES;
//        
//        self.imageView.frame = btn.frame;
//        
//        // UIButton
//        if (i == self.imageArr.count){
//            // 最后一个Button
//            [btn setImage: [SobotUITools getSysImageByName:@"zcicon_add_photo"]  forState:UIControlStateNormal];
//            // 添加图片的点击事件
//            [btn addTarget:self action:@selector(photoSelecte) forControlEvents:UIControlEventTouchUpInside];
//            if (assetCount == 11) {
//                btn.frame = CGRectZero;
//                assetCount = 10;
//            }
//            [btn.imageView setContentMode:UIViewContentModeScaleAspectFit];
//        }else{
//            [btn.imageView setContentMode:UIViewContentModeScaleAspectFill];
//            // 就从本地取
//            if(sobotCheckFileIsExsis([_imagePathArr objectAtIndex:i])){
//                UIImage *localImage=[UIImage imageWithContentsOfFile:[_imagePathArr objectAtIndex:i]];
//                [btn setImage:localImage forState:UIControlStateNormal];
//            }
//            
//            NSDictionary *imgDic = [_imageArr objectAtIndex:i];
//            NSString *imgFileStr =  sobotConvertToString(imgDic[@"cover"]);
//            if (imgFileStr.length>0) {
//                UIImage *localImage=[UIImage imageWithContentsOfFile:imgFileStr];
//                [btn setImage:localImage forState:UIControlStateNormal];
//            }
//            
//            btn.tag = 100+i;
//            // 点击放大图片，进入图片
//            [btn addTarget:self action:@selector(tapBrowser:) forControlEvents:UIControlEventTouchUpInside];
//                btn.layer.borderColor = UIColorFromKitModeColor(SobotColorBgLine).CGColor;
//        }
//        [self.fileScrollView addSubview:btn];
//        if (i != self.imageArr.count){
//            UIButton *btnDel = [UIButton buttonWithType:UIButtonTypeCustom];
//            btnDel.imageView.contentMode = UIViewContentModeScaleAspectFit;
//            x = (width + 5)*i + width - 24;
//            if(SobotKitIsRTLLayout){
//                x = (width + 5)* (countX - i - 1) + width - 24;
//            }
//            btnDel.frame = CGRectMake(x,4, 20, 20);
//            [btnDel setImage:[SobotUITools getSysImageByName:@"zcicon_close_down"] forState:0];
//            btnDel.tag = 100 + i;
//            // 点击放大图片，进入图片
//            [btnDel addTarget:self action:@selector(tapDelFiles:) forControlEvents:UIControlEventTouchUpInside];
//            [self.fileScrollView addSubview:btnDel];
//        }
//        
//       
//    }
//    
//    
//    if(assetCount >= 4){
//        self.fileScrollView.scrollEnabled = YES;
//    }else{
//        self.fileScrollView.scrollEnabled = NO;
//    }
//    // 设置contentSize
//    self.fileScrollView.contentSize = CGSizeMake((width+5)*assetCount, CGRectGetMaxY([[self.fileScrollView.subviews lastObject] frame]));
//    if(assetCount > 4){
//        if(SobotKitIsRTLLayout){
//            [self.fileScrollView setContentOffset:CGPointMake(0, 0)];
//        }else{
//            [self.fileScrollView setContentOffset:CGPointMake(self.fileScrollView.contentSize.width - self.fileScrollView.frame.size.width, 0)];
//        }
//    }
//}

#pragma mark - 选择图片相关

// 添加图片
- (void)photoSelecte{
    if (_imageArr.count >=15) {
        [SobotProgressHUD showInfoWithStatus:SobotKitLocalString(@"已达上限 15 个")];
        return;
    }
    SobotActionSheetView *mysheet = [[SobotActionSheetView alloc]initWithDelegate:self title:@"" CancelTitle:SobotKitLocalString(@"取消") OtherTitles:SobotKitLocalString(@"拍摄"), SobotKitLocalString(@"从相册选择"), nil];
    [mysheet show];
    [_textDesc resignFirstResponder];
}


//预览图片
- (void)tapBrowser:(SobotButton *)btn{
    if([self.delegate respondsToSelector:@selector(replyLeaveViewPreviewImg:)]){
        [self.delegate replyLeaveViewPreviewImg:btn.obj];
    }
    [_textDesc resignFirstResponder];
}

- (void)tapDelFiles:(UIButton *)btn{
    delButton = btn;
    [_textDesc resignFirstResponder];
    NSString *tip = SobotKitLocalString(@"要删除这张图片吗？");
    NSInteger currentInt = btn.tag - 100;
    if(currentInt < _imagePathArr.count){
        NSString *file  = _imagePathArr[currentInt];
        if([file hasSuffix:@".mp4"]){
            tip = SobotKitLocalString(@"要删除这个视频吗?");
        }
    }
    SobotActionSheetView *mysheet = [[SobotActionSheetView alloc]initWithDelegate:self title:sobotConvertToString(tip) CancelTitle:SobotKitLocalString(@"取消") OtherTitles:SobotKitLocalString(@"删除"), nil];
    mysheet.tag = 3;
    mysheet.selectIndex = 2;
    [mysheet show];
}

- (void)actionSheet:(SobotActionSheetView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(actionSheet.tag == 3){
        if(buttonIndex == 2){
            if ([self.delegate respondsToSelector:@selector(replyLeaveViewDeleteImg:)]) {
               [self.delegate replyLeaveViewDeleteImg:delButton.tag];
           }
        }
    }else{
        if (buttonIndex == 2) {
            buttonIndex = 0; // 相机
        }
        if (buttonIndex == 1) {
            buttonIndex = 1;// 相册
        }
        if ([self.delegate respondsToSelector:@selector(replyLeaveViewPickImg:)]) {
            [self.delegate replyLeaveViewPickImg:buttonIndex];
        }
    }
}

@end
