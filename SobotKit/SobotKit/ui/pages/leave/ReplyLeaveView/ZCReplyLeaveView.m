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
}

@property (nonatomic, strong) UIView *backGroundView;
@property (nonatomic, assign) float viewWidth;
@property (nonatomic, assign) float viewHeight;
@property (nonatomic, strong) UIScrollView *fileScrollView; // 放图片
@property (nonatomic, strong) SobotImageView * imageView;
@property (nonatomic, strong) UIImagePickerController *zc_imagepicker;

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
           [self createSubviews];
       }
    return self;
}

#pragma mark - 布局
- (void)createSubviews {
    self.backGroundView = [[UIView alloc] init];
    self.backGroundView.frame = CGRectMake(0, self.viewHeight, self.viewWidth, 0);
    self.backGroundView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    self.backGroundView.autoresizesSubviews = YES;
    self.backGroundView.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
    self.backGroundView.layer.masksToBounds = YES;
    [self addSubview:self.backGroundView];
    float titleLabel_height = 60;
    float topline_height = 0.5;
    CGSize cannelButtonSize = CGSizeMake(30, 30);
    float cannelButton_margin_left = 10;
    float textDesc_margin = 20;
    float topline_1_margin_bottom;
    float textDesc_height;
    if (self.viewHeight > self.viewWidth) {
        textDesc_height = 104;
        topline_1_margin_bottom = 40;
    }else {
        textDesc_height = 40;
        topline_1_margin_bottom = 10;
    }
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.viewWidth, titleLabel_height)];
    [titleLabel setText:SobotKitLocalString(@"回复")];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark1)];
    [titleLabel setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
    [titleLabel setFont:SobotFontBold17];
    [self.backGroundView addSubview:titleLabel];

    // 线条
     UIView *topline = [[UIView alloc]initWithFrame:CGRectMake(0, titleLabel_height, self.viewWidth, topline_height)];
     topline.backgroundColor = [ZCUIKitTools zcgetChatBottomLineColor];
     [self.backGroundView addSubview:topline];
    
    // 右上角的删除按钮
    UIButton *cannelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cannelButton setFrame:CGRectMake(self.viewWidth - cannelButtonSize.width - cannelButton_margin_left, (titleLabel_height - cannelButtonSize.height)/2, cannelButtonSize.height,cannelButtonSize.width)];
    [cannelButton setImage:[SobotUITools getSysImageByName:@"zcicon_sf_close"] forState:UIControlStateNormal];
    cannelButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cannelButton addTarget:self action:@selector(tappedCancel) forControlEvents:UIControlEventTouchUpInside];
    [self.backGroundView addSubview:cannelButton];
    
//   输入框
    self.textDesc = [[ZCUIPlaceHolderTextView alloc]init];
    self.textDesc.frame = CGRectMake(textDesc_margin, CGRectGetMaxY(titleLabel.frame) + topline_height + textDesc_margin, self.viewWidth - textDesc_margin*2, textDesc_height);
    self.textDesc.placeholder = SobotKitLocalString(@"请输入您的回复内容");
    [self.textDesc setPlaceholderColor:UIColorFromKitModeColor(SobotColorTextSub1)];
    [self.textDesc setFont:SobotFont14];
    [self.textDesc setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
    self.textDesc.delegate = self;
    self.textDesc.placeholederFont = SobotFont14;
    self.textDesc.layer.cornerRadius = 4.0f;
    self.textDesc.layer.masksToBounds = YES;
    [self.textDesc setBackgroundColor:[ZCUIKitTools zcgetLeftChatColor]];
    self.textDesc.textContainerInset = UIEdgeInsetsMake(10, 10, 0, 10);
    [self.backGroundView addSubview:self.textDesc];
    if(sobotIsRTLLayout()){
        [self.textDesc setTextAlignment:NSTextAlignmentRight];
    }
    
    self.fileScrollView = [[UIScrollView alloc]init];
    self.fileScrollView.frame = CGRectMake(20, CGRectGetMaxY(self.textDesc.frame) + 20, ScreenWidth - topline_1_margin_bottom, 70);
    self.fileScrollView.scrollEnabled = YES;
    self.fileScrollView.userInteractionEnabled = YES;
    self.fileScrollView.pagingEnabled = NO;
    self.fileScrollView.backgroundColor = [UIColor clearColor];
    [self.backGroundView addSubview:self.fileScrollView];
    [self reloadScrollView];
//   线条
    UIView *topline_1 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.fileScrollView.frame) + 40, self.viewWidth, topline_height)];
    topline_1.backgroundColor =[ZCUIKitTools zcgetCommentButtonLineColor];
    [self.backGroundView addSubview:topline_1];
//    提交按钮
    submitButton = [[UIButton alloc]init];
    submitButton.frame = CGRectMake(20, CGRectGetMaxY(topline_1.frame) + 10, self.viewWidth - 40, 44);
    submitButton.backgroundColor = [ZCUIKitTools zcgetLeaveSubmitImgColor];
    submitButton.layer.cornerRadius = 22;
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitButton setTitle:SobotKitLocalString(@"提交") forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(submitButtonClick) forControlEvents:UIControlEventTouchUpInside];
    submitButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [self.backGroundView addSubview:submitButton];
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
        float bottomHeight = 0.0;
        if (![ZCUICore getUICore].kitInfo.navcBarHidden) {
            bottomHeight = 44 + 30;
        }
        float x = 0;
        float h = CGRectGetMaxY(submitButton.frame) + XBottomBarHeight + bottomHeight;
        float y = self.viewHeight - h;
        float w = self.backGroundView.frame.size.width;
        self.backGroundView.frame = CGRectMake(x,y,w,h);
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - 点击
- (void)submitButtonClick{
//    判断输入框是否为空 请填写回复内容
    if(self.textDesc.text.length == 0 || sobotTrimString(self.textDesc.text).length == 0){
        [[SobotToast shareToast] showToast:SobotKitLocalString(@"回复内容不能为空") duration:1.0 view:self position:SobotToastPositionCenter];
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
          [self tappedCancel:YES];
          if ([self.delegate respondsToSelector:@selector(replySuccess)]) {
              [self.delegate replySuccess];
          }
      } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
          [[SobotToast shareToast] showToast:SobotKitLocalString(@"提交失败") duration:1.0f view:saveSelf position:SobotToastPositionCenter];
      }];
}

#pragma mark - 键盘收起
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return [textField resignFirstResponder];
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
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat keyboardHeight = [[[notification userInfo] objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue].size.height;
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationDelegate:self];
    {
        CGRect  sheetViewFrame = self.backGroundView.frame;
        float h = XBottomBarHeight;
        sheetViewFrame.origin.y = self.viewHeight - keyboardHeight - self.backGroundView.frame.size.height + h;
        self.backGroundView.frame = sheetViewFrame;
    }
    
    // commit animations
    [UIView commitAnimations];
}

//键盘隐藏
- (void)keyBoardWillHide:(NSNotification *)notification {
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView beginAnimations:@"bottomBarDown" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView commitAnimations];
    [UIView animateWithDuration:0.25 animations:^{
        CGRect sheetFrame = self.backGroundView.frame;
        sheetFrame.origin.y = self.viewHeight - self.backGroundView.frame.size.height;
        
        self.backGroundView.frame = sheetFrame;
    }];
}

#pragma mark - 手势冲突的代理

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIButton class]]  ||  [touch.view isMemberOfClass:[UIImageView class]]){
        return NO;
    }
    return YES;
}

#pragma mark - 增加 图片附件
- (void)reloadScrollView{
    // 先移除，后添加
    [[self.fileScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // 加一是为了有个添加button
    NSUInteger assetCount = self.imageArr.count +1 ;
    
    CGFloat width = (self.fileScrollView.frame.size.width - 5*3)/4;
    CGFloat heigth = 60;
    NSUInteger countX = 0;
    CGFloat x = 0;
    if(sobotIsRTLLayout()){
       countX = (assetCount < 4) ? 4 : assetCount;
    }
    for (NSInteger i = 0; i < assetCount; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        x=(width + 5)*i;
        if(sobotIsRTLLayout()){
            x = (width + 5)* (countX - i - 1);
        }
        btn.frame = CGRectMake(x,0, width, heigth);
        btn.layer.cornerRadius = 2;
        btn.layer.masksToBounds = YES;
        
        self.imageView.frame = btn.frame;
        
        // UIButton
        if (i == self.imageArr.count){
            // 最后一个Button
            [btn setImage: [SobotUITools getSysImageByName:@"zcicon_add_photo"]  forState:UIControlStateNormal];
            // 添加图片的点击事件
            [btn addTarget:self action:@selector(photoSelecte) forControlEvents:UIControlEventTouchUpInside];
            if (assetCount == 11) {
                btn.frame = CGRectZero;
                assetCount = 10;
            }
            [btn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        }else{
            [btn.imageView setContentMode:UIViewContentModeScaleAspectFill];
            // 就从本地取
            if(sobotCheckFileIsExsis([_imagePathArr objectAtIndex:i])){
                UIImage *localImage=[UIImage imageWithContentsOfFile:[_imagePathArr objectAtIndex:i]];
                [btn setImage:localImage forState:UIControlStateNormal];
            }
            
            NSDictionary *imgDic = [_imageArr objectAtIndex:i];
            NSString *imgFileStr =  sobotConvertToString(imgDic[@"cover"]);
            if (imgFileStr.length>0) {
                UIImage *localImage=[UIImage imageWithContentsOfFile:imgFileStr];
                [btn setImage:localImage forState:UIControlStateNormal];
            }
            
            btn.tag = 100+i;
            // 点击放大图片，进入图片
            [btn addTarget:self action:@selector(tapBrowser:) forControlEvents:UIControlEventTouchUpInside];
                btn.layer.borderColor = UIColorFromKitModeColor(SobotColorBgLine).CGColor;
        }
        [self.fileScrollView addSubview:btn];
        if (i != self.imageArr.count){
            UIButton *btnDel = [UIButton buttonWithType:UIButtonTypeCustom];
            btnDel.imageView.contentMode = UIViewContentModeScaleAspectFit;
            x = (width + 5)*i + width - 24;
            if(sobotIsRTLLayout()){
                x = (width + 5)* (countX - i - 1) + width - 24;
            }
            btnDel.frame = CGRectMake(x,4, 20, 20);
            [btnDel setImage:[SobotUITools getSysImageByName:@"zcicon_close_down"] forState:0];
            btnDel.tag = 100 + i;
            // 点击放大图片，进入图片
            [btnDel addTarget:self action:@selector(tapDelFiles:) forControlEvents:UIControlEventTouchUpInside];
            [self.fileScrollView addSubview:btnDel];
        }
    }
    
    
    if(assetCount >= 4){
        self.fileScrollView.scrollEnabled = YES;
    }else{
        self.fileScrollView.scrollEnabled = NO;
    }
    // 设置contentSize
    self.fileScrollView.contentSize = CGSizeMake((width+5)*assetCount, CGRectGetMaxY([[self.fileScrollView.subviews lastObject] frame]));
    if(assetCount > 4){
        if(sobotIsRTLLayout()){
            [self.fileScrollView setContentOffset:CGPointMake(0, 0)];
        }else{
            [self.fileScrollView setContentOffset:CGPointMake(self.fileScrollView.contentSize.width - self.fileScrollView.frame.size.width, 0)];
        }
    }
}

#pragma mark - 选择图片相关

// 添加图片
- (void)photoSelecte{
    SobotActionSheetView *mysheet = [[SobotActionSheetView alloc]initWithDelegate:self title:@"" CancelTitle:SobotKitLocalString(@"取消") OtherTitles:SobotKitLocalString(@"拍摄"), SobotKitLocalString(@"从相册选择"), nil];
    [mysheet show];
    [_textDesc resignFirstResponder];
}


//预览图片
- (void)tapBrowser:(UIButton *)btn{
    if([self.delegate respondsToSelector:@selector(replyLeaveViewPreviewImg:)]){
        [self.delegate replyLeaveViewPreviewImg:btn];
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
            buttonIndex = 1; // 相机
        }
        if (buttonIndex == 3) {
            buttonIndex = 0;// 相册
        }
        if ([self.delegate respondsToSelector:@selector(replyLeaveViewPickImg:)]) {
            [self.delegate replyLeaveViewPickImg:buttonIndex];
        }
    }
}

@end