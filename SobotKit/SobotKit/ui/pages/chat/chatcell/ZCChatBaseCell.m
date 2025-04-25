//
//  ZCChatBaseCell.m
//  SobotKit
//
//  Created by zhangxy on 2022/9/1.
//

#import "ZCChatBaseCell.h"
#import "ZCUIKitTools.h"
#import <SobotChatClient/SobotChatClient.h>
#import "ZCActionSheet.h"
#import "ZCVideoPlayer.h"
#import "SobotHtmlFilter.h"

#define SobotLayoutidentifierOff @"off"

#define SobotChatStepTopSize 28

@interface ZCChatBaseCell()<ZCActionSheetDelegate,SobotEmojiLabelDelegate>
{
    CGSize tempSize;
    
    NSString *copyUrl;
    
    // 按钮连续重复点击
    BOOL isBtnClick;
}

@property(nonatomic,strong) NSLayoutConstraint *layoutTimeHeight;
@property(nonatomic,strong) NSLayoutConstraint *layoutChatBgPadingLeft;
@property(nonatomic,strong) NSLayoutConstraint *layoutChatBgPadingRight;
@property(nonatomic,strong) NSLayoutConstraint *layoutChatBgWidth;

@property(nonatomic,strong) NSLayoutConstraint *layoutAvatarRight;
@property(nonatomic,strong) NSLayoutConstraint *layoutAvatarLeft;
@property(nonatomic,strong) NSLayoutConstraint *layoutAvatarEH;
@property(nonatomic,strong) NSLayoutConstraint *layoutAvatarEW;
@property(nonatomic,strong) NSLayoutConstraint *layoutAvatarTop;

@property(nonatomic,strong) NSLayoutConstraint *layoutNameLeft;
@property(nonatomic,strong) NSLayoutConstraint *layoutNameRight;
@property(nonatomic,strong) NSLayoutConstraint *layoutNameEH;


@property(nonatomic,strong) NSLayoutConstraint *layoutSugguestWidth;
@property(nonatomic,strong) NSLayoutConstraint *layoutSugguestHeight;
@property(nonatomic,strong) NSLayoutConstraint *layoutSugguestBottom;


@property(nonatomic,strong) NSLayoutConstraint *layoutTheTopW;
@property(nonatomic,strong) NSLayoutConstraint *layoutTheTopHeight;
@property(nonatomic,strong) NSLayoutConstraint *layoutSetOnSpace;
@property(nonatomic,strong) NSLayoutConstraint *layoutSetOnW;
@property(nonatomic,strong) NSLayoutConstraint *layoutSetOnHeight;

@property(nonatomic,strong) NSLayoutConstraint *layoutBtmTheTopW;// 顶
@property(nonatomic,strong) NSLayoutConstraint *layoutBtmTheTopH;// 顶
@property(nonatomic,strong) NSLayoutConstraint *layoutBtmSetOnLeft;// 踩
@property(nonatomic,strong) NSLayoutConstraint *layoutBtmSetOnH;// 踩
@property(nonatomic,strong) NSLayoutConstraint *layoutBtmSetOnW;// 踩


@property(nonatomic,strong) NSLayoutConstraint *layoutTurnTop;
@property(nonatomic,strong) NSLayoutConstraint *layoutTurnLeft;
@property(nonatomic,strong) NSLayoutConstraint *layoutTurnHeight;

@property(nonatomic,strong) NSLayoutConstraint *layoutleaveIconPB;

@property(nonatomic,strong) SobotXHImageViewer *imageViewer;
@property(nonatomic,strong) NSString *coderURLStr;
@property(nonatomic,strong) UIMenuController *menuController;

@property(nonatomic,strong) SobotImageView *tempPicView;


@end

@implementation ZCChatBaseCell

#pragma mark 传家views
-(void)createItemsView{
    
    // 头像/昵称/内容框
    // showType:0仅内容，1头像+昵称，2头像 3昵称
    int showType = 1;//[ZCUICore getUICore].kitInfo.showChatLeftNameHeader;
    _lblTime=({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentCenter];
        [iv setFont:[ZCUIKitTools zcgetListKitTimeFont]];
        [iv setTextColor:[ZCUIKitTools zcgetTimeTextColor]];
        [iv setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:iv];
        [self.contentView addConstraints:sobotLayoutPaddingView(0, 0, SobotSpace16, -SobotSpace16, iv, self.contentView)];
        _layoutTimeTop = sobotLayoutPaddingTop(SobotSpace20, iv, self.contentView);
        _layoutTimeHeight = sobotLayoutEqualHeight(0, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:_layoutTimeHeight];
        [self.contentView addConstraint:_layoutTimeTop];
        iv;
    });
    
    
    _ivHeader =({
        SobotImageView *iv = [[SobotImageView alloc] init];
        [iv setContentMode:UIViewContentModeScaleAspectFill];
        [iv.layer setMasksToBounds:YES];
//        [iv setBackgroundColor:[UIColor lightGrayColor]];
        [iv setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:iv];
        iv.layer.masksToBounds = YES;
//        iv.layer.borderColor = UIColor.grayColor.CGColor;
        iv.layer.borderColor = [UIColor clearColor].CGColor;
        iv.layer.borderWidth = 1.0f;
        iv.layer.cornerRadius = 15.0f;
//        [self.contentView addConstraints:sobotLayoutSize(30, 30, iv, NSLayoutRelationEqual)];
        self.layoutAvatarEH = sobotLayoutEqualWidth(32, iv, NSLayoutRelationEqual);
        self.layoutAvatarEW = sobotLayoutEqualHeight(32, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.layoutAvatarEW];
        [self.contentView addConstraint:self.layoutAvatarEH];
        
        // 显示时间时是20，不显示时间时是24
        _layoutAvatarTop = sobotLayoutMarginTop(SobotSpace20, iv, _lblTime);
        [self.contentView addConstraint:_layoutAvatarTop];
        _layoutAvatarLeft = sobotLayoutPaddingLeft(ZCChatMarginHSpace, iv, self.contentView);
        _layoutAvatarLeft.priority = UILayoutPriorityDefaultHigh;
        _layoutAvatarRight = sobotLayoutPaddingRight(-ZCChatMarginHSpace, iv, self.contentView);
        _layoutAvatarRight.priority = UILayoutPriorityDefaultLow;
        [self.contentView addConstraint:_layoutAvatarRight];
        [self.contentView addConstraint:_layoutAvatarLeft];
        
        if(showType == 0 || showType == 3){
            iv.hidden = YES;
        }
        iv;
        
    });
    
    _lblNickName = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:iv];
        iv.font = SobotFont12;
        [iv setTextColor:UIColorFromKitModeColor(SobotColorTextSubDark)];
        
        CGFloat space = ZCChatPaddingHSpace + ZCChatItemSpace8 + 32;
        _layoutNameLeft = sobotLayoutPaddingLeft(space, iv, self.contentView);
        _layoutNameRight = sobotLayoutPaddingRight(-ZCChatPaddingHSpace, iv, self.contentView);
        [self.contentView addConstraint:_layoutNameLeft];
        [self.contentView addConstraint:_layoutNameRight];
        [self.contentView addConstraint:sobotLayoutPaddingTop(0, iv, self.ivHeader)];
        _layoutNameEH = sobotLayoutEqualHeight(0, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:_layoutNameEH];
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            iv.textAlignment = NSTextAlignmentRight;
        }else{
            iv.textAlignment = NSTextAlignmentLeft;
        }
        iv;
    });
    
    _ivBgView = ({
        UIImageView *iv = [[UIImageView alloc]init];
        iv.contentMode = UIViewContentModeScaleToFill;
        [iv.layer setMasksToBounds:YES];
        iv.layer.cornerRadius = 5.0f;
        [iv setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:iv];
        
        self.ivBgViewMT = sobotLayoutMarginTop(ZCChatItemSpace2, iv, _lblNickName);
        [self.contentView addConstraint:self.ivBgViewMT];
        
        // 直接与昵称组件的左右对齐
        _layoutChatBgPadingLeft = sobotLayoutPaddingLeft(0, iv, self.lblNickName);
        _layoutChatBgPadingLeft.priority = UILayoutPriorityDefaultHigh;
        _layoutChatBgPadingRight = sobotLayoutPaddingRight(0, iv, self.lblNickName);
        _layoutChatBgPadingRight.priority = UILayoutPriorityDefaultLow;
        [self.contentView addConstraint:_layoutChatBgPadingLeft];
        [self.contentView addConstraint:_layoutChatBgPadingRight];
        _layoutChatBgWidth = sobotLayoutEqualWidth(0, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:_layoutChatBgWidth];
        NSLayoutConstraint *lb = sobotLayoutPaddingBottom(ZCChatPaddingVSpace, iv, self.contentView);
        lb.priority = UILayoutPriorityDefaultLow;
        [self.contentView addConstraint:lb];
        iv;
    });
    
//    _lblSugguest = ({
//        SobotEmojiLabel *iv = [ZCChatBaseCell createRichLabel];
//        iv.textInsets = UIEdgeInsetsMake(0, ZCChatPaddingHSpace, 0, ZCChatPaddingHSpace);
//        [self.contentView addSubview:iv];
//        _layoutSugguestBottom=sobotLayoutPaddingBottom(0, iv, self.ivBgView);
//        [self.contentView addConstraint:_layoutSugguestBottom];
//        if ([ZCUIKitTools getSobotIsRTLLayout]) {
//            [self.contentView addConstraint:sobotLayoutPaddingRight(0, iv, self.ivBgView)];
//        }else{
//            [self.contentView addConstraint:sobotLayoutPaddingLeft(0, iv, self.ivBgView)];
//        }
//        _layoutSugguestWidth = sobotLayoutEqualWidth(0, iv, NSLayoutRelationEqual);
//        _layoutSugguestHeight = sobotLayoutEqualHeight(0, iv, NSLayoutRelationEqual);
//        iv.delegate = self;
//        [self.contentView addConstraint:_layoutSugguestWidth];
//        [self.contentView addConstraint:_layoutSugguestHeight];
//        iv;
//    });
    
    _lblSugguest = ({
        UIView *iv = [[UIView alloc] init];
        [self.contentView addSubview:iv];
        _layoutSugguestBottom=sobotLayoutPaddingBottom(0, iv, self.ivBgView);
        [self.contentView addConstraint:_layoutSugguestBottom];
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            [self.contentView addConstraint:sobotLayoutPaddingRight(0, iv, self.ivBgView)];
        }else{
            [self.contentView addConstraint:sobotLayoutPaddingLeft(0, iv, self.ivBgView)];
        }
        _layoutSugguestWidth = sobotLayoutEqualWidth(0, iv, NSLayoutRelationEqual);
        _layoutSugguestHeight = sobotLayoutEqualHeight(0, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:_layoutSugguestWidth];
        [self.contentView addConstraint:_layoutSugguestHeight];
        iv;
    });
    
    _btnAddingMsg = ({
        
        NSBundle *sBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"SobotKit" ofType:@"bundle"]];
        NSString  *filePath = [sBundle pathForResource:@"Light/zcicon_writering_animate" ofType:@"gif"];
        NSData  *imageData = [NSData dataWithContentsOfFile:filePath];
        
        UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
        [iv setBackgroundColor:[UIColor clearColor]];
        [iv setContentEdgeInsets:UIEdgeInsetsZero];
        [iv setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [iv setImage:[SobotImageTools sobotAnimatedGIFWithData:imageData] forState:0];
//        [iv setTitle:@". . ." forState:0];
//        [iv.imageView setAnimationImages:[NSArray arrayWithObjects:
//                                              SobotKitGetImage(@"zcicon_pop_voice_receive_anime_1"),
//                                              SobotKitGetImage(@"zcicon_pop_voice_receive_anime_2"),
//                                              SobotKitGetImage(@"zcicon_pop_voice_receive_anime_3"),
////                                              [ZCUITools zcuiGetBundleImage:@"zcicon_pop_voice_receive_anime_4"],
////                                              [ZCUITools zcuiGetBundleImage:@"zcicon_pop_voice_receive_anime_5"],
//                                              nil]];
//        iv.imageView.animationDuration = .8f;
//        iv.imageView.animationRepeatCount = 0;
//        [iv.imageView startAnimating];
        [iv.titleLabel setFont:SobotFontBold16];
        iv.layer.masksToBounds=YES;
        [self.contentView addSubview:iv];
        iv.hidden=YES;
        // 只可能在左边
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            [self.contentView addConstraint:sobotLayoutPaddingRight(-ZCChatPaddingHSpace, iv, self.ivBgView)];
        }else{
            [self.contentView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingHSpace, iv, self.ivBgView)];
        }
        [self.contentView addConstraint:sobotLayoutPaddingBottom(-ZCChatPaddingVSpace, iv, _ivBgView)];
        [self.contentView addConstraints:sobotLayoutSize(20, 4, iv, NSLayoutRelationEqual)];
        
        iv;
    });
    
    _btnReSend = ({
        UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
        [iv setBackgroundColor:[UIColor clearColor]];
        iv.layer.cornerRadius=3;
        iv.layer.masksToBounds=YES;
        [iv setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [iv setImageEdgeInsets:UIEdgeInsetsMake(3, 10, 3, 0)];
        iv.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:iv];
        iv.hidden=YES;
        
        [iv addTarget:self action:@selector(clickReSend:) forControlEvents:UIControlEventTouchUpInside];
        // 只可能在右边
        [self.contentView addConstraint:sobotLayoutPaddingTop(ZCChatMarginVSpace+4, iv, _ivBgView)];
        [self.contentView addConstraints:sobotLayoutSize(20, 20, iv, NSLayoutRelationEqual)];
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            [self.contentView addConstraint:sobotLayoutMarginLeft(8, iv, _ivBgView)];
        }else{
            [self.contentView addConstraint:sobotLayoutMarginRight(-8, iv, _ivBgView)];
        }
        iv;
    });
    
    _btnReadStatus = ({
        UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
        [iv setBackgroundColor:[UIColor clearColor]];
        iv.imageView.contentMode = UIViewContentModeScaleAspectFit;
        iv.titleLabel.font = SobotFont12;
        [iv setTitleColor:[ZCUIKitTools zcgetRightChatColor] forState:0];
        [iv setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        iv.layer.cornerRadius=3;
        iv.layer.masksToBounds=YES;
        [self.contentView addSubview:iv];
        iv.hidden=YES;
        _layoutReadStateBtm = sobotLayoutPaddingBottom(0, iv, _ivBgView);
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            _layoutReadStateR  = sobotLayoutMarginLeft(6, iv, _ivBgView);
        }else{
            _layoutReadStateR  = sobotLayoutMarginRight(-6, iv, _ivBgView);
        }
        // 只可能在右边
        [self.contentView addConstraint:_layoutReadStateBtm];
        [self.contentView addConstraint:_layoutReadStateR];
        [self.contentView addConstraint:sobotLayoutEqualHeight(18, iv, NSLayoutRelationEqual)];
        
        iv;
    });
    
    // 2.7.4新增 2.8.0 改成文字
    _leaveIcon = ({
        UILabel *iv = [[UILabel alloc]init];
    //        _leaveIcon = ZCSTLocalString(@"留言消息");
        iv.text = SobotKitLocalString(@"留言消息");
        iv.textColor = [ZCUIKitTools zcgetServerConfigBtnBgColor];
        iv.font = SobotFont12;
        [iv setTextAlignment:NSTextAlignmentRight];
        [self.contentView addSubview:iv];
        iv.hidden = YES;
        // 只可能在右边
        [self.contentView addConstraint:sobotLayoutEqualCenterY(0, iv, self.ivBgView)];
        [self.contentView addConstraints:sobotLayoutSize(90, 24, iv, NSLayoutRelationEqual)];
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            [self.contentView addConstraint:sobotLayoutMarginLeft(10, iv, _ivBgView)];
        }else{
            [self.contentView addConstraint:sobotLayoutMarginRight(-10, iv, _ivBgView)];
        }
        iv;
    });
    
    
    _btnStepOn = ({
        UIButton *iv =  [self createItemButton:ZCChatCellClickTypeStepOn title:@""];
        [self.contentView addSubview:iv];
        iv.hidden=YES;
        
        // 只会在左边
        _layoutSetOnHeight = sobotLayoutEqualHeight(SobotChatStepTopSize, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:_layoutSetOnHeight];
        _layoutSetOnW = sobotLayoutEqualWidth(SobotChatStepTopSize,iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:_layoutSetOnW];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(0, iv, self.ivBgView)];
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            [self.contentView addConstraint:sobotLayoutMarginRight(-ZCChatItemSpace8, iv, _ivBgView)];
        }else{
            [self.contentView addConstraint:sobotLayoutMarginLeft(ZCChatItemSpace8, iv, _ivBgView)];
        }
        iv;
    });
    
    _btnTheTop = ({
        UIButton *iv =  [self createItemButton:ZCChatCellClickTypeTheTop title:@""];
        [self.contentView addSubview:iv];
        iv.hidden=YES;
        _layoutTheTopHeight = sobotLayoutEqualHeight(SobotChatStepTopSize, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:_layoutTheTopHeight];
        _layoutSetOnSpace = sobotLayoutMarginBottom(-ZCChatMarginVSpace, iv, _btnStepOn);
        [self.contentView addConstraint:_layoutSetOnSpace];
        _layoutTheTopW = sobotLayoutEqualWidth(SobotChatStepTopSize,iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:_layoutTheTopW];
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            [self.contentView addConstraint:sobotLayoutMarginRight(-ZCChatItemSpace8, iv, _ivBgView)];
        }else{
            [self.contentView addConstraint:sobotLayoutMarginLeft(ZCChatItemSpace8, iv, _ivBgView)];
        }
        iv;
    });
    
    
    _btnBtmTheTop = ({
        NSString *originalString = SobotKitLocalString(@"顶");
        NSString *capitalizedString = originalString.length > 0 ? [originalString stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[originalString substringToIndex:1] uppercaseString]] : originalString;
//        UIButton *iv =  [self createItemButton:ZCChatCellClickTypeTheTop title:capitalizedString];
        UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
//        iv.backgroundColor =UIColorFromModeColor(SobotColorBgMainDark2);
        [iv.titleLabel setFont:SobotFont12];
        [iv setTitle:capitalizedString forState:0];
        [iv setTitleColor:UIColor.clearColor forState:UIControlStateNormal];
        if (![ZCUICore getUICore].getLibConfig.aiAgent) {
            iv.layer.cornerRadius = 14.0f;
            iv.layer.borderWidth = 0.75f;
            iv.layer.masksToBounds = YES;
            if([SobotUITools getSobotThemeMode] != SobotThemeMode_Dark){
                iv.layer.borderColor = [ZCUIKitTools zcgetCommentButtonLineColor].CGColor;
            }
        }
//        iv.clipsToBounds = NO;
       
        iv.tag = ZCChatCellClickTypeTheTop;

        [self.contentView addSubview:iv];
        iv.hidden=YES;
        
        [self.contentView addConstraint:sobotLayoutMarginTop(10, iv, _ivBgView)];
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            [self.contentView addConstraint:sobotLayoutPaddingRight(0, iv, self.ivBgView)];
        }else{
            [self.contentView addConstraint:sobotLayoutPaddingLeft(0, iv, self.ivBgView)];
        }
        _layoutBtmTheTopW = sobotLayoutEqualWidth(0, iv, NSLayoutRelationEqual);
        _layoutBtmTheTopH = sobotLayoutEqualHeight(SobotChatStepTopSize, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:_layoutBtmTheTopW];
        [self.contentView addConstraint:_layoutBtmTheTopH];
        
//        [ZCUIKitTools setViewRTLtransForm:iv];
        iv.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
        iv;
    });
    
//    [self createOpenSubViewIsOn:NO isSel:NO enabled:YES];
    
    _btnBtmStepOn = ({
        NSString *originalString = SobotKitLocalString(@"踩");
        NSString *capitalizedString = originalString.length > 0 ? [originalString stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[originalString substringToIndex:1] uppercaseString]] : originalString;
//        UIButton *iv =  [self createItemButton:ZCChatCellClickTypeStepOn title:capitalizedString];
        UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
//        iv.backgroundColor =UIColorFromModeColor(SobotColorBgMainDark2);
        [iv.titleLabel setFont:SobotFont12];
        [iv setTitle:capitalizedString forState:0];
        [iv setTitleColor:UIColor.clearColor forState:UIControlStateNormal];
        if (![ZCUICore getUICore].getLibConfig.aiAgent) {
            iv.layer.cornerRadius = 14.0f;
            iv.layer.borderWidth = 0.75f;
            iv.layer.masksToBounds = YES;
            //        iv.clipsToBounds = NO;
            if([SobotUITools getSobotThemeMode] != SobotThemeMode_Dark){
                iv.layer.borderColor = [ZCUIKitTools zcgetCommentButtonLineColor].CGColor;
            }
        }
        iv.tag = ZCChatCellClickTypeStepOn;
        [self.contentView addSubview:iv];
        iv.hidden=YES;
        
        [self.contentView addConstraint:sobotLayoutMarginTop(10, iv, _ivBgView)];
        // 只会在左边
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            _layoutBtmSetOnLeft = sobotLayoutMarginRight(-8,iv, self.btnBtmTheTop);
        }else{
            _layoutBtmSetOnLeft = sobotLayoutMarginLeft(8,iv, self.btnBtmTheTop);
        }
        [self.contentView addConstraint:_layoutBtmSetOnLeft];
        _layoutBtmSetOnW = sobotLayoutEqualWidth(0, iv, NSLayoutRelationEqual);
        _layoutBtmSetOnH = sobotLayoutEqualHeight(SobotChatStepTopSize, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:_layoutBtmSetOnW];
        [self.contentView addConstraint:_layoutBtmSetOnH];
        
//        [ZCUIKitTools setViewRTLtransForm:iv];
        iv.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
        iv;
    });
    
//    [self createOpenSubViewIsOn:YES isSel:NO enabled:YES];
    
    
    _btnTurnUser =({
//        UIButton *iv = [self createItemButton:ZCChatCellClickTypeConnectUser title:SobotKitLocalString(@"转人工")];
        
        UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
        iv.backgroundColor =UIColorFromModeColor(SobotColorBgMainDark2);
        [iv.titleLabel setFont:SobotFont12];
        [iv setTitle:SobotKitLocalString(@"转人工") forState:0];
        [iv setTitleColor:UIColor.clearColor forState:UIControlStateNormal];
        iv.layer.cornerRadius = 14.0f;
        iv.layer.borderWidth = 0.75f;
        if([SobotUITools getSobotThemeMode] != SobotThemeMode_Dark){
            iv.layer.borderColor = [ZCUIKitTools zcgetCommentButtonLineColor].CGColor;
        }
        iv.tag = ZCChatCellClickTypeConnectUser;
        
        [self.contentView addSubview:iv];
        iv.hidden=YES;
        
        // 只会在左边
        _layoutTurnTop = sobotLayoutMarginTop(10, iv, _ivBgView);
        [self.contentView addConstraint:_layoutTurnTop];
        
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            _layoutTurnLeft = sobotLayoutMarginRight(-8, iv, self.btnBtmStepOn);
        }else{
            _layoutTurnLeft = sobotLayoutMarginLeft(8, iv, self.btnBtmStepOn);
        }
        [self.contentView addConstraint:_layoutTurnLeft];
        
        CGFloat w1 = [self getBtnWidth:iv];
        [self.contentView addConstraint:sobotLayoutEqualWidth(w1, iv, NSLayoutRelationEqual)];
        
        self.layoutPaddingBtm = sobotLayoutPaddingBottom(-ZCChatPaddingVSpace, iv, self.contentView);
        self.layoutPaddingBtm.priority = UILayoutPriorityDefaultHigh;
        [self.contentView addConstraint:self.layoutPaddingBtm];
        
        _layoutTurnHeight = sobotLayoutEqualHeight(SobotChatStepTopSize, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:_layoutTurnHeight];
        _layoutTurnHeight.constant = 0;
        _layoutTurnTop.constant = 0;
        
//        [ZCUIKitTools setViewRTLtransForm:iv];
        iv.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
        iv;
    });
    
    _activityView=({
        UIActivityIndicatorView *iv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.contentView addSubview:iv];
        [self.contentView addConstraint:sobotLayoutEqualCenterX(0, iv, _btnReSend)];
        [self.contentView addConstraint:sobotLayoutEqualCenterY(0, iv, _btnReSend)];
        iv;
    });
    
//    _sendUpLoadView = ({
//        UIActivityIndicatorView *iv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//        [self.contentView addSubview:iv];
//        [self.contentView addConstraint:sobotLayoutEqualCenterY(0, iv, self.ivBgView)];
//        iv.hidden = YES;
//        if ([ZCUIKitTools getSobotIsRTLLayout]) {
//            [self.contentView addConstraint:sobotLayoutMarginRight(-10, iv, _ivBgView)];
//        }else{
//            [self.contentView addConstraint:sobotLayoutMarginLeft(10, iv, _ivBgView)];
//        }
//        iv;
//    });
    
    _ivLayerView = [[UIImageView alloc] init];
    self.userInteractionEnabled=YES;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(doLongPress:)];
    longPress.minimumPressDuration = 0.5f; // 设置响应时长
    self.ivBgView.userInteractionEnabled = YES;
//    [self.ivBgView addGestureRecognizer:longPress];
    self.contentView.userInteractionEnabled = YES;
    [self.contentView addGestureRecognizer:longPress];
}

-(CGFloat) getBtnWidth:(UIButton *) btn{
//    CGFloat w = [SobotUITools getWidthContain:btn.titleLabel.text font:btn.titleLabel.font Height:20] + 32;
    NSString *originalString = btn.titleLabel.text;
    NSString *capitalizedString = originalString.length > 0 ? [originalString stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[originalString substringToIndex:1] uppercaseString]] : originalString;
    
    CGFloat w1 = [SobotUITools getWidthContain:capitalizedString font:SobotFont12 Height:20];
    w1 = w1 + 14 + 4 + 12*2;
    
    return w1;
}


#pragma mark -- 配置大模型 显示在右边点踩 按钮的的状态和图片
-(void)setOnAndTopButtonAtRight:(int)tag sel:(BOOL)isSel enabled:(BOOL)isEnabled btn:(UIButton *)iv{
    if(tag == ZCChatCellClickTypeTheTop){
        if ([ZCUICore getUICore].getLibConfig.aiAgent) {
            if ([ZCUICore getUICore].getLibConfig.realuateButtonStyle) {
                UIImage *img1 = SobotKitGetImage(@"zcicon_useful_nor_heart");
                UIImage *img2 = SobotKitGetImage(@"zcicon_useful_sel_heart");
                // 心
                if (isSel) {
                    [iv setImage:img2 forState:UIControlStateNormal];
                    [iv setImage:img2 forState:UIControlStateHighlighted];
                    [iv setImage:img2 forState:UIControlStateSelected];
                }else{
                    [iv setImage:img1 forState:UIControlStateNormal];
                    [iv setImage:img2 forState:UIControlStateHighlighted];
                    [iv setImage:img2 forState:UIControlStateSelected];
                }
            }else{
                // 手
                UIImage *img1 = SobotKitGetImage(@"zcicon_useful_nor_new_ai");
                UIImage *img2 = SobotKitGetImage(@"zcicon_useful_sel_ai_shou");
                if (isSel) {
                    [iv setImage:img2 forState:UIControlStateNormal];
                    [iv setImage:img2 forState:UIControlStateHighlighted];
                    [iv setImage:img2 forState:UIControlStateSelected];
                }else{
                    [iv setImage:img1 forState:UIControlStateNormal];
                    [iv setImage:img2 forState:UIControlStateHighlighted];
                    [iv setImage:img2 forState:UIControlStateSelected];
                }
            }
            
            iv.layer.masksToBounds = YES;
            [iv setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        }else{
            if([SobotUITools getSobotThemeMode] != SobotThemeMode_Dark){
                iv.layer.borderColor = [ZCUIKitTools zcgetCommentButtonLineColor].CGColor;
                iv.clipsToBounds = YES; // 确保边框不会被背景图片覆盖
                iv.layer.cornerRadius = 14.0f;
                iv.layer.borderWidth = 0.75f;
            }
            [iv setImage:SobotKitGetImage(@"zcicon_useful_nor_new") forState:UIControlStateNormal];
            [iv setImage:SobotKitGetImage(@"zcicon_useful_sel") forState:UIControlStateHighlighted];
            [iv setImage:SobotKitGetImage(@"zcicon_useful_sel") forState:UIControlStateSelected];
        }
        
        [iv addTarget:self action:@selector(connectWithStepOnWithTheTop:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:iv];
    }else if(tag == ZCChatCellClickTypeStepOn){
        if ([ZCUICore getUICore].getLibConfig.aiAgent) {
            if ([ZCUICore getUICore].getLibConfig.realuateButtonStyle) {
                UIImage *img1 = SobotKitGetImage(@"zcicon_useless_nol_heart");
                UIImage *img2 = SobotKitGetImage(@"zcicon_useless_sel_heart");
                if (isSel) {
                    [iv setImage:img2 forState:UIControlStateNormal];
                    [iv setImage:img2 forState:UIControlStateHighlighted];
                    [iv setImage:img2 forState:UIControlStateSelected];
                }else{
                    [iv setImage:img1 forState:UIControlStateNormal];
                    [iv setImage:img2 forState:UIControlStateHighlighted];
                    [iv setImage:img2 forState:UIControlStateSelected];
                }
            }else{
                UIImage *img1 = SobotKitGetImage(@"zcicon_useless_nol_new_ai");
                UIImage *img2 = SobotKitGetImage(@"zcicon_useless_sel_ai");
                if (isSel) {
                    [iv setImage:img2 forState:UIControlStateNormal];
                    [iv setImage:img2 forState:UIControlStateHighlighted];
                    [iv setImage:img2 forState:UIControlStateSelected];
                }else{
                    [iv setImage:img1 forState:UIControlStateNormal];
                    [iv setImage:img2 forState:UIControlStateHighlighted];
                    [iv setImage:img2 forState:UIControlStateSelected];
                }
            }
            iv.layer.masksToBounds = YES;
            [iv setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        }
    }
}

// 踩、赞、转人工
-(UIButton *)createItemButton:(int ) tag title:(NSString *) text{
    
    UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
    iv.backgroundColor =UIColorFromModeColor(SobotColorBgMainDark2);
    [iv.titleLabel setFont:SobotFont12];
    [iv setTitleColor:UIColorFromModeColor(SobotColorTextMain) forState:UIControlStateNormal];
    iv.tag = tag;
    if(tag == ZCChatCellClickTypeTheTop){
        if ([ZCUICore getUICore].getLibConfig.aiAgent) {
            if ([ZCUICore getUICore].getLibConfig.realuateButtonStyle) {
                UIImage *img1 = SobotKitGetImage(@"zcicon_useful_nor_heart");
                UIImage *img2 = SobotKitGetImage(@"zcicon_useful_sel_heart");
                // 心
                [iv setImage:img1 forState:UIControlStateNormal];
                [iv setImage:img2 forState:UIControlStateHighlighted];
                [iv setImage:img2 forState:UIControlStateSelected];
            }else{
                // 手
                UIImage *img1 = SobotKitGetImage(@"zcicon_useful_nor_new_ai");
                UIImage *img2 = SobotKitGetImage(@"zcicon_useful_sel_ai_shou");
                [iv setImage:img1 forState:UIControlStateNormal];
                [iv setImage:img2 forState:UIControlStateHighlighted];
                [iv setImage:img2 forState:UIControlStateSelected];
            }
            
            iv.layer.masksToBounds = YES;
            [iv setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        }else{
            if([SobotUITools getSobotThemeMode] != SobotThemeMode_Dark){
                iv.layer.borderColor = [ZCUIKitTools zcgetCommentButtonLineColor].CGColor;
                iv.clipsToBounds = YES; // 确保边框不会被背景图片覆盖
                iv.layer.cornerRadius = 14.0f;
                iv.layer.borderWidth = 0.75f;
            }
            [iv setImage:SobotKitGetImage(@"zcicon_useful_nor_new") forState:UIControlStateNormal];
            [iv setImage:SobotKitGetImage(@"zcicon_useful_sel") forState:UIControlStateHighlighted];
            [iv setImage:SobotKitGetImage(@"zcicon_useful_sel") forState:UIControlStateSelected];
        }
        
        [iv addTarget:self action:@selector(connectWithStepOnWithTheTop:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:iv];
    }else if(tag == ZCChatCellClickTypeStepOn){
        if ([ZCUICore getUICore].getLibConfig.aiAgent) {
            if ([ZCUICore getUICore].getLibConfig.realuateButtonStyle) {
                UIImage *img1 = SobotKitGetImage(@"zcicon_useless_nol_heart");
                UIImage *img2 = SobotKitGetImage(@"zcicon_useless_sel_heart");
                [iv setImage:img1 forState:UIControlStateNormal];
                [iv setImage:img2 forState:UIControlStateHighlighted];
                [iv setImage:img2 forState:UIControlStateSelected];
            }else{
                UIImage *img1 = SobotKitGetImage(@"zcicon_useless_nol_new_ai");
                UIImage *img2 = SobotKitGetImage(@"zcicon_useless_sel_ai");
                [iv setImage:img1 forState:UIControlStateNormal];
                [iv setImage:img2 forState:UIControlStateHighlighted];
                [iv setImage:img2 forState:UIControlStateSelected];
            }
            iv.layer.masksToBounds = YES;
            [iv setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        }else{
            if([SobotUITools getSobotThemeMode] != SobotThemeMode_Dark){
                iv.layer.borderColor = [ZCUIKitTools zcgetCommentButtonLineColor].CGColor;
                iv.clipsToBounds = YES; // 确保边框不会被背景图片覆盖
                iv.layer.cornerRadius = 14.0f;
                iv.layer.borderWidth = 0.75f;
            }
            [iv setImage:SobotKitGetImage(@"zcicon_useless_nol_new") forState:UIControlStateNormal];
            [iv setImage:SobotKitGetImage(@"zcicon_useless_sel") forState:UIControlStateHighlighted];
            [iv setImage:SobotKitGetImage(@"zcicon_useless_sel") forState:UIControlStateSelected];
        }
        [iv addTarget:self action:@selector(connectWithStepOnWithTheTop:) forControlEvents:UIControlEventTouchUpInside];
    }else if(tag == ZCChatCellClickTypeConnectUser){
        if([SobotUITools getSobotThemeMode] != SobotThemeMode_Dark){
            iv.layer.borderColor = [ZCUIKitTools zcgetCommentButtonLineColor].CGColor;
            iv.clipsToBounds = YES; // 确保边框不会被背景图片覆盖
            iv.layer.cornerRadius = 14.0f;
            iv.layer.borderWidth = 0.75f;
        }
        [iv setImage:SobotKitGetImage(@"icon_fast_transfer") forState:UIControlStateNormal];
        [iv setImage:SobotKitGetImage(@"icon_fast_transfer") forState:UIControlStateHighlighted];
        [iv setImage:SobotKitGetImage(@"icon_fast_transfer") forState:UIControlStateSelected];
        [iv addTarget:self action:@selector(connectWithStepOnWithTheTop:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    CGFloat it = 7.5;
    if(sobotConvertToString(text).length > 0){
//        [SobotUITools sobotButon:iv hSpace:4 top:it rtl:SobotKitIsRTLLayout];
//        [iv.imageView setContentMode:UIViewContentModeScaleAspectFit];
        // 半圆
        iv.layer.cornerRadius = 14.0f;
    }
    [iv setTitle:text forState:0];
    [iv setContentMode:UIViewContentModeRight];
    
    return iv;
}

#pragma mark -- 绘制图片 大小
-(UIImage *)drawRectImg:(CGSize)size img:(UIImage *)img{
    UIImage *originalImage = img;
    // 调整图片大小
    UIGraphicsBeginImageContext(size);
    [originalImage drawInRect:CGRectMake(0, 0, size.width,size.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // 设置按钮图片
    return  resizedImage;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self createItemsView];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self createItemsView];
    }
    return self;
}


-(void)reSetBaseLayoutConstraint{
    // 移除的约束，都让其等于11
    // 不移除的约束,不能等于11
    _ivHeader.hidden = YES;
    _lblNickName.hidden = YES;
    [_lblNickName setText:@""];
    
    BOOL isShowHeader = NO;
    if(self.tempModel.senderType != 0  && !self.tempModel.isEmptyHeader){
        isShowHeader = YES;
        _ivHeader.hidden = NO;
        NSString *senderName = sobotConvertToString(self.tempModel.senderName);
        if(sobotConvertToString(self.tempModel.servantName).length > 0){
            senderName = sobotConvertToString(self.tempModel.servantName);
        }
        if(senderName.length > 0 && [ZCUICore getUICore].getLibConfig.showStaffNick){
            _lblNickName.hidden = NO;
            [_lblNickName setText:senderName];
        }
    }
    
    
    if(!self.tempModel.isShowSenderFlag){
        _ivHeader.hidden = YES;
        _lblNickName.hidden = YES;
        [_lblNickName setText:@""];
    }
    
    if (!self.isRight && ![ZCUICore getUICore].getLibConfig.showFace) {
        _ivHeader.hidden = YES;// 左边 并且 设置 不显示客服头像
    }
    
    if (self.tempModel.action == SobotMessageActionTypeLanguage) {
        _ivHeader.hidden = YES;
        _lblNickName.hidden = YES;
        [_lblNickName setText:@""];
    }

    // 特殊情况 25系统消息
    if (self.tempModel.isEmptyHeader) {
        _ivHeader.hidden = YES;
        _lblNickName.hidden = YES;
        [_lblNickName setText:@""];
    }
    
    // 判断左右
    if(self.isRight){
        // 设置头像、昵称、气泡
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            _layoutAvatarLeft.priority = UILayoutPriorityDefaultHigh;
            _layoutAvatarRight.priority = UILayoutPriorityDefaultLow;
            _layoutChatBgPadingLeft.priority = UILayoutPriorityDefaultHigh;
            _layoutChatBgPadingRight.priority = UILayoutPriorityDefaultLow;
        }else{
            _layoutAvatarLeft.priority = UILayoutPriorityDefaultLow;
            _layoutAvatarRight.priority = UILayoutPriorityDefaultHigh;
            _layoutChatBgPadingLeft.priority = UILayoutPriorityDefaultLow;
            _layoutChatBgPadingRight.priority = UILayoutPriorityDefaultHigh;
        }
    }else{
        // 设置头像、昵称、气泡
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            _layoutAvatarRight.priority = UILayoutPriorityDefaultHigh;
            _layoutAvatarLeft.priority = UILayoutPriorityDefaultLow;
            _layoutChatBgPadingRight.priority = UILayoutPriorityDefaultHigh;
            _layoutChatBgPadingLeft.priority = UILayoutPriorityDefaultLow;
        }else{
            _layoutAvatarRight.priority = UILayoutPriorityDefaultLow;
            _layoutAvatarLeft.priority = UILayoutPriorityDefaultHigh;
            _layoutChatBgPadingRight.priority = UILayoutPriorityDefaultLow;
            _layoutChatBgPadingLeft.priority = UILayoutPriorityDefaultHigh;
        }
    }
    // isShowSenderFlag 隐藏头像时，间距依然要设置
    if(!_ivHeader.hidden ||(!self.tempModel.isShowSenderFlag && self.tempModel.senderType != 0)){
        _layoutAvatarEH.constant = 32;
        _layoutAvatarEW.constant = 32;
        if(_ivHeader.isHidden){
            _layoutAvatarEH.constant = 0;
            _layoutAvatarEW.constant = 0;
        }
        // 显示头像
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            if(!self.isRight){
                self.layoutNameLeft.constant = ZCChatPaddingHSpace;
                self.layoutNameRight.constant = -(ZCChatPaddingHSpace + ZCChatItemSpace8 + 32);
//                if (_ivHeader.isHidden) {
//                    self.layoutNameRight.constant = -ZCChatPaddingHSpace;
//                }
            }else{
                self.layoutNameRight.constant = -ZCChatPaddingHSpace;
                self.layoutNameLeft.constant = ZCChatPaddingHSpace + ZCChatItemSpace8 + 32;
            }
        }else{
            if(self.isRight){
                self.layoutNameLeft.constant = ZCChatPaddingHSpace;
                self.layoutNameRight.constant = -(ZCChatPaddingHSpace + ZCChatItemSpace8 + 32);
                if (_ivHeader.isHidden) {
                    self.layoutNameRight.constant = -ZCChatPaddingHSpace;
                }
            }else{
                self.layoutNameRight.constant = -ZCChatPaddingHSpace;
                self.layoutNameLeft.constant = ZCChatPaddingHSpace + ZCChatItemSpace8 + 32;
            }
        }
    }else{
        _layoutAvatarEH.constant = 0;
        _layoutAvatarEW.constant = 0;
        // 不显示头像
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            if(!self.isRight){
                self.layoutNameRight.constant = -ZCChatPaddingHSpace;
                self.layoutNameLeft.constant = ZCChatPaddingHSpace + ZCChatItemSpace8 + 32;
            }else{
                self.layoutNameLeft.constant = ZCChatPaddingHSpace;
                self.layoutNameRight.constant = -(ZCChatPaddingHSpace + ZCChatItemSpace8 + 32);
            }
        }else{
            if(self.isRight){
                self.layoutNameRight.constant = -ZCChatPaddingHSpace;
                self.layoutNameLeft.constant = ZCChatPaddingHSpace + ZCChatItemSpace8 + 32;
            }else{
                self.layoutNameLeft.constant = ZCChatPaddingHSpace;
                self.layoutNameRight.constant = -(ZCChatPaddingHSpace + ZCChatItemSpace8 + 32);
            }
        }
    }
    
    // 显示昵称
    if(_lblNickName.isHidden){
        _ivBgViewMT.constant = 0;
        _layoutNameEH.constant = 0;
    }else{
        _layoutNameEH.constant = 20;
        _ivBgViewMT.constant = ZCChatItemSpace2;
    }
}


+(SobotEmojiLabel *) createRichLabel{
    return [self createRichLabel:nil];
}
+(SobotEmojiLabel *) createRichLabel:(id _Nullable) delegate{
    SobotEmojiLabel *tempRichLabel = [[SobotEmojiLabel alloc] initWithFrame:CGRectZero];
    tempRichLabel.numberOfLines = 0;
    tempRichLabel.font = [ZCUIKitTools zcgetKitChatFont];
    tempRichLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    tempRichLabel.textColor = [UIColor whiteColor];
    tempRichLabel.backgroundColor = [UIColor clearColor];
    tempRichLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    //        _lblTextMsg.textInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    
    tempRichLabel.isNeedAtAndPoundSign = NO;
    tempRichLabel.disableEmoji = NO;
    tempRichLabel.lineSpacing = [ZCUIKitTools zcgetChatLineSpacing];
    
    tempRichLabel.verticalAlignment = SobotAttributedLabelVerticalAlignmentCenter;
    // 当是右侧语言时，右对齐
    if([ZCUIKitTools getSobotIsRTLLayout]){
        tempRichLabel.textAlignment = NSTextAlignmentRight;
    }else{
        tempRichLabel.textAlignment = NSTextAlignmentLeft;
    }
    if(delegate != nil){
        tempRichLabel.delegate = delegate;
    }
    return tempRichLabel;
}


+(BOOL) isRightChat:(SobotChatMessage *) model{
    // 0,自己，1机器人，2客服
    if(model.senderType==0){
        return YES;
    }else{
        return NO;
    }
}


-(void)initDataToView:(SobotChatMessage *) message time:(NSString *) showTime{
//    _sendUpLoadView.hidden = YES;
//    [_sendUpLoadView stopAnimating];
    
    _tempModel = message;
    isBtnClick = NO;
    // 0,自己，1机器人，2客服
    if(message.senderType==0){
        _isRight = YES;
    }else{
        _isRight = NO;
    }
    
    [self resetCellView];
    
    
    _layoutTimeHeight.constant = 0;
    _layoutTimeTop.constant = 0;
    if(![@"" isEqual:sobotConvertToString(showTime)]){
        [_lblTime setText:showTime];
        _layoutTimeHeight.constant = 30;
        _layoutTimeTop.constant = 10;
        _lblTime.hidden=NO;
        
        _layoutAvatarTop.constant = 20;
    }else{
        _layoutTimeTop.constant = 0;
        _layoutTimeHeight.constant = 0;
        _layoutAvatarTop.constant = 12;
    }
    if(message.action == SobotMessageActionTypeSelLanguage){
        _ivHeader.hidden = YES;
        _lblNickName.text = @"";
        return;
    }
    UIImage *placeHoldImage = nil;
    // 0,自己，1机器人，2客服
    if(message.senderType==0){
        [_lblNickName setTextAlignment:NSTextAlignmentRight];
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            [_lblNickName setTextAlignment:NSTextAlignmentLeft];
        }
        _isRight = YES;
        _contentPadding = UIEdgeInsetsMake(ZCChatPaddingVSpace, -ZCChatPaddingVSpace, ZCChatPaddingHSpace, -ZCChatPaddingHSpace);
        placeHoldImage = SobotKitGetImage(@"zcicon_useravatar_nol");
//        [_lblSugguest setTextColor:[ZCUIKitTools zcgetRightChatTextColor]];
//        [_lblSugguest setLinkColor:[ZCUIKitTools zcgetChatRightlinkColor]];
    }else{
        _isRight = NO;
//        [_lblSugguest setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
//        [_lblSugguest setLinkColor:[ZCUIKitTools zcgetChatLeftLinkColor]];
        _contentPadding = UIEdgeInsetsMake(ZCChatPaddingVSpace, -ZCChatPaddingVSpace, ZCChatPaddingHSpace, -ZCChatPaddingHSpace);
        [_lblNickName setTextAlignment:NSTextAlignmentLeft];
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            [_lblNickName setTextAlignment:NSTextAlignmentRight];
        }
        if(message.senderType == 1){
            placeHoldImage = SobotKitGetImage(@"zcicon_turnserver_nol");
        }else{
            placeHoldImage = SobotKitGetImage(@"zcicon_useravatart_girl");
        }
        
        [self.btnAddingMsg setTintColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        [self.btnAddingMsg setTitleColor:[ZCUIKitTools zcgetLeftChatTextColor] forState:0];
    }
    
    // 切换语言不显示头像和昵称
    if (message.action == SobotMessageActionTypeLanguage) {
        _ivHeader.hidden = YES;
        [_lblNickName setText:@""];
    }
   
    [self reSetBaseLayoutConstraint];
    
    if(!_ivHeader.hidden){
        if(sobotConvertToString(message.servantFace).length > 0){
            [_ivHeader loadWithURL:[NSURL URLWithString:sobotConvertToString(message.servantFace)] placeholer:placeHoldImage showActivityIndicatorView:NO];
        }else{
            [_ivHeader loadWithURL:[NSURL URLWithString:sobotConvertToString(message.senderFace)] placeholer:placeHoldImage showActivityIndicatorView:NO];
        }
    }
    CGFloat headerSpace = 0;
    if(!_ivHeader.hidden ||(!self.tempModel.isShowSenderFlag && self.tempModel.senderType != 0)){
        // 这里需要处理个特殊场景，客服连续发送的第二条消息不展示头像，但是左边间距是一样的，宽度也要保持一样
//        if (!_ivHeader.hidden) {
            headerSpace = 32+8;
//        }
    }
    
    // 减去左右
    self.maxWidth = self.viewWidth - fabs(_layoutNameLeft.constant) - fabs(_layoutNameRight.constant) - headerSpace - 36;
    
    
    // 普通消息，添加设置坐标
    CGSize s = CGSizeZero;
//    _lblSugguest.text = @"";
    [_lblSugguest.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if(message.msgType != SobotMessageTypeTipsText){
        if(message.richModel.type == SobotMessageRichJsonTypeApplet){
            NSLog(@"%@",[message getModelDisplaySugestionText]);
        }
        NSString *text = [message getModelDisplaySugestionText];
        // 不是多伦的模版4，不是热点问题
        if((sobotConvertToString(text).length > 0 && message.richModel.type != SobotMessageTypeHotGuide && message.richModel.type !=SobotMessageRichJsonTypeLoop) || (message.richModel.type ==SobotMessageRichJsonTypeLoop  && !sobotIsNull(message.richModel.richContent) && message.richModel.richContent.templateId == 4)){

            _layoutSugguestBottom.constant = -ZCChatPaddingVSpace;
            
//            [ZCChatBaseCell configHtmlText:text label:_lblSugguest right:self.isRight];
//            s = [_lblSugguest preferredSizeWithMaxWidth:self.maxWidth-ZCChatPaddingHSpace*2];
            
            s = [self addSugguestViews:_lblSugguest w:self.maxWidth];
        }else{
            if(message.msgType==SobotMessageTypeVideo || message.msgType== SobotMessageTypePhoto){
                _layoutSugguestBottom.constant = 0;
            }else{
                _layoutSugguestBottom.constant = -(ZCChatPaddingVSpace - ZCChatCellItemSpace);
            }
        }
    }
    
    self.btnAddingMsg.hidden = YES;
//    if(self.tempModel.senderType!=0 && ![self getZCLibConfig].isArtificial){
//        if(self.tempModel.isReceiving){
//            self.btnAddingMsg.hidden = NO;
//            // 添加20的间隔，用于显示发送动画
//            _layoutSugguestBottom.constant = _layoutSugguestBottom.constant - 14;
//        }
//    }
   
    _lblSugguest.hidden = NO;
    _layoutSugguestHeight.constant = s.height;
    _layoutSugguestWidth.constant = s.width;
//    self.ivBgViewMT.constant = ZCChatCellItemSpace;
    
}


#pragma mark 最后设置气泡的位置
-(void)reSetOnOrTurnUser{
    _btnTheTop.hidden = YES;
    _btnStepOn.hidden = YES;
    _btnTurnUser.hidden = YES;
    _btnBtmStepOn.hidden = YES;
    _btnBtmTheTop.hidden = YES;
    _btnBtmTheTop.selected = NO;
    _btnBtmStepOn.selected = NO;
    _btnTheTop.selected = NO;
    _btnStepOn.selected = NO;
    
    _layoutTurnTop.constant = 0;
    _layoutTurnHeight.constant = 0;
    _btnTurnUserBgH.constant = 0;
    _btnTurnUserImg.image = nil;
    _btnTurnUserLab.text = @"";
    
    _layoutBtmSetOnW.constant = 0;
    _layoutBtmTheTopW.constant = 0;
    
    _btnBtmTheTopBgViewH.constant = 0;
    _btnBtmStepOnImgBgViewH.constant = 0;
    _btnBtmTheTopImg.image = nil;
    _btnBtmTheTopLab.text = @"";
    _btnBtmStepOnImg.image = nil;
    _btnBtmStepOnLab.text = @"";
    
    _layoutBtmSetOnLeft.constant = 0;
    
    _layoutSetOnHeight.constant = 0;
    _layoutSetOnSpace.constant = 0;
    _layoutTheTopHeight.constant = 0;
    // 不是人工，切不是自己发送的消息
    if(_tempModel.senderType!=0 && (_tempModel.commentType == 2 || _tempModel.commentType == 3 || ![self getZCLibConfig].isArtificial)){
        if(_tempModel.commentType > 0){
            if([self getZCLibConfig].realuateStyle){
                // 显示赞
                if(_tempModel.commentType == 1 || _tempModel.commentType == 2 || _tempModel.commentType == 4){
                    _btnBtmTheTop.hidden = NO;
                    [self createOpenSubViewIsOn:NO isSel:NO enabled:YES];
                    _btnBtmTheTop.enabled = YES;
                    if(_tempModel.commentType == 2){
                        _btnBtmTheTop.selected = YES;
                        [self createOpenSubViewIsOn:NO isSel:YES enabled:NO];
                    }
                    if(_tempModel.commentType == 4){
                        _btnBtmTheTop.selected = YES;
                        _btnBtmTheTop.enabled = NO;
                        [self createOpenSubViewIsOn:NO isSel:YES enabled:NO];
                    }
                }
                
                if(_tempModel.commentType == 1 || _tempModel.commentType == 3 || _tempModel.commentType == 4){
                    // 显示踩
                    _btnBtmStepOn.hidden = NO;
                    [self createOpenSubViewIsOn:YES isSel:NO enabled:YES];
                    _btnBtmStepOn.enabled = YES;
                    if(_tempModel.commentType == 3){
                        _btnBtmStepOn.selected = YES;
                        [self createOpenSubViewIsOn:YES isSel:YES enabled:NO];
                    }
                    if(_tempModel.commentType == 4){
                        _btnBtmStepOn.selected = YES;
                        _btnBtmStepOn.enabled = NO;
                        [self createOpenSubViewIsOn:YES isSel:YES enabled:NO];
                    }
                }
            }else{
                // 右边显示
                // 显示赞
                if(_tempModel.commentType == 1 || _tempModel.commentType == 2 || _tempModel.commentType == 4){
                    _btnTheTop.hidden = NO;
                    _btnTheTop.enabled = YES;
                    [self setOnAndTopButtonAtRight:(int)_btnTheTop.tag sel:NO enabled:YES btn:_btnTheTop];
                    if(_tempModel.commentType == 2){
                        _btnTheTop.selected = YES;
//                        _btnTheTop.enabled = NO;
                        [self setOnAndTopButtonAtRight:(int)_btnTheTop.tag sel:YES enabled:NO btn:_btnTheTop];
                    }
                    if(_tempModel.commentType == 4){
                        _btnTheTop.selected = YES;
                        _btnTheTop.enabled = NO;
                        [self setOnAndTopButtonAtRight:(int)_btnTheTop.tag sel:YES enabled:NO btn:_btnTheTop];
                    }
                }
                
                if(_tempModel.commentType == 1 || _tempModel.commentType == 3 || _tempModel.commentType == 4){
                    // 显示踩
                    _btnStepOn.hidden = NO;
                    _btnStepOn.enabled = YES;
                    [self setOnAndTopButtonAtRight:(int)_btnStepOn.tag sel:NO enabled:YES btn:_btnStepOn];
                    if(_tempModel.commentType == 3){
                        _btnStepOn.selected = YES;
//                        _btnStepOn.enabled = NO;
                        [self setOnAndTopButtonAtRight:(int)_btnStepOn.tag sel:YES enabled:NO btn:_btnStepOn];
                    }
                    if(_tempModel.commentType == 4){
                        _btnStepOn.selected = YES;
                        _btnStepOn.enabled = NO;
                        [self setOnAndTopButtonAtRight:(int)_btnStepOn.tag sel:YES enabled:NO btn:_btnStepOn];
                    }
                }
               
            }
        }
        
        // 右边情况
        if(!_btnStepOn.hidden){
            _layoutSetOnW.constant = SobotChatStepTopSize;
            _layoutSetOnHeight.constant = SobotChatStepTopSize;
        }
        if(!_btnTheTop.hidden){
            _layoutTheTopHeight.constant = SobotChatStepTopSize;
            _layoutTheTopW.constant = SobotChatStepTopSize;
            
            if(!_btnStepOn.hidden){
                _layoutSetOnSpace.constant = -8;
            }else{
                _layoutSetOnSpace.constant = 0;
            }
        }
        
        CGFloat w = [self getBtnWidth:self.btnBtmTheTop];
        CGFloat w2 = [self getBtnWidth:self.btnBtmStepOn];
        CGFloat w3 = [self getBtnWidth:self.btnTurnUser];
        
        if ([ZCUICore getUICore].getLibConfig.aiAgent) {
            w = 28;
            w2 = 28;
        }
        // 底部踩赞宽度相同
        if(!_btnBtmTheTop.hidden){
            // 赞
            _layoutBtmTheTopH.constant = SobotChatStepTopSize;
            _layoutBtmTheTopW.constant = w;
            // 赞的子元素全部显示
            _btnBtmTheTopBgViewH.constant = 28;
            
            // 只要有一个显示，就要设置转人工的高度和顶约束
            _layoutTurnTop.constant = 10;
            _layoutTurnHeight.constant = SobotChatStepTopSize;
        }
        if(!_btnBtmStepOn.hidden){
            // 踩
            _layoutBtmSetOnH.constant = SobotChatStepTopSize;
            _layoutBtmSetOnW.constant = w2;
            // 显示踩的子元素
            _btnBtmStepOnImgBgViewH.constant = 28;
            
            if(!_btnBtmTheTop.hidden){
                if(w < w2){
                    w = w2;
                }
                
                _layoutBtmSetOnLeft.constant = 8;
                if ([ZCUICore getUICore].getLibConfig.aiAgent) {
                    _layoutBtmSetOnLeft.constant = 12;
                }
                if ([ZCUIKitTools getSobotIsRTLLayout]) {
                    _layoutBtmSetOnLeft.constant = -8;
                    if ([ZCUICore getUICore].getLibConfig.aiAgent) {
                        _layoutBtmSetOnLeft.constant = -12;
                    }
                }
                _layoutBtmTheTopW.constant = w;
                _layoutBtmSetOnW.constant = w;
            }else{
                _layoutBtmSetOnLeft.constant = 0;
            }
            
            // 只要有一个显示，就要设置转人工的高度和顶约束
            _layoutTurnTop.constant = 10;
            _layoutTurnHeight.constant = SobotChatStepTopSize;
        }
        
        
        if(self.tempModel.showTurnUser){
            _btnTurnUser.hidden = NO;
            _layoutTurnHeight.constant = SobotChatStepTopSize;
            if(_layoutTurnLeft){
                [self.contentView removeConstraint:_layoutTurnLeft];
            }
            
            // 转人工要换行
            if((_layoutBtmSetOnW.constant + _layoutBtmTheTopW.constant + w3) > self.maxWidth){
                _layoutTurnTop.constant = SobotChatStepTopSize + 10 + 8;
                if ([ZCUIKitTools getSobotIsRTLLayout]) {
                    _layoutTurnLeft = sobotLayoutPaddingRight(0, self.btnTurnUser, self.btnBtmTheTop);
                }else{
                    _layoutTurnLeft = sobotLayoutPaddingLeft(0, self.btnTurnUser, self.btnBtmTheTop);
                }
            }else{
                _layoutTurnTop.constant = 10;
                if(_btnBtmStepOn.hidden && _btnBtmTheTop.hidden){
                    if ([ZCUIKitTools getSobotIsRTLLayout]) {
                        _layoutTurnLeft = sobotLayoutMarginRight(0, self.btnTurnUser, self.btnBtmStepOn);
                    }else{
                        _layoutTurnLeft = sobotLayoutMarginLeft(0, self.btnTurnUser, self.btnBtmStepOn);
                    }
                }else{
                    if ([ZCUIKitTools getSobotIsRTLLayout]) {
                        _layoutTurnLeft = sobotLayoutMarginRight(-8, self.btnTurnUser, self.btnBtmStepOn);
                    }else{
                        _layoutTurnLeft = sobotLayoutMarginLeft(8, self.btnTurnUser, self.btnBtmStepOn);
                    }
                }
            }
            [self.contentView addConstraint:_layoutTurnLeft];
            [self createTureBtn:YES];
        }
    }
    
}
-(void)setChatViewBgState:(CGSize)size{
    self.ivBgView.layer.borderWidth = 0;
    UIImage *bgImage = [UIImage new];
    // 0,自己，1机器人，2客服
    if(self.tempModel.senderType==0){
        _isRight = YES;
        // 右边气泡背景图片
        bgImage = SobotKitGetImage(@"zcicon_pop_green_normal");
        bgImage=[bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(21, 21, 21, 21)];
        
        [_ivBgView setBackgroundColor:[ZCUIKitTools zcgetRightChatColor]];
        
        self.ivBgView.image = nil;
    }else{
        _isRight = NO;
        bgImage = SobotKitGetImage(@"zcicon_pop_green_left_normal");
        bgImage=[bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(21, 21, 21, 21)];
        
        [_ivBgView setBackgroundColor:[ZCUIKitTools zcgetLeftChatColor]];
        self.ivBgView.image = nil;
    }
    
    if(_layoutSugguestWidth.constant < size.width || _layoutSugguestHeight.constant == 0){
        _layoutSugguestWidth.constant = size.width;
        
    }
    // 转人工的宽度
    if(_layoutSugguestWidth.constant < 100){
        if(self.tempModel.showTurnUser && self.tempModel.commentType > 0 && self.tempModel.senderType == 1){
            _layoutSugguestWidth.constant = 100;
        }
    }
    
    
    _layoutSugguestWidth.constant = _layoutSugguestWidth.constant + ZCChatPaddingHSpace*2;
    
    
    
    _layoutChatBgWidth.constant = _layoutSugguestWidth.constant;
    
    _btnReadStatus.hidden = YES;
    _leaveIcon.hidden = YES;
    _btnReSend.hidden = YES;
    
    // 自己、设置发送状态
    if(_tempModel.senderType==0){
        _layoutTurnTop.constant = 0;
        _layoutTurnHeight.constant = 0;
        
        if(_tempModel.sendStatus==1){
            if(self.tempModel.msgType != SobotMessageTypePhoto && self.tempModel.msgType != SobotMessageTypeFile){
                [self.btnReSend setHidden:NO];
                [self.btnReSend setImage:nil forState:UIControlStateNormal];
                _activityView.hidden = NO;
                _activityView.center = self.btnReSend.center;
                [_activityView startAnimating];
            }else{
                // 发送文件时，不显示发送的动画，由发送进度代替,
                [_activityView stopAnimating];
                _activityView.hidden = YES;
            }
            // 上传音频文件有翻译的回调时间
//            if (self.tempModel.msgType == SobotMessageTypeSound) {
//                [_sendUpLoadView startAnimating];
//                _sendUpLoadView.hidden = NO;
//            }else{
//                [_sendUpLoadView stopAnimating];
//                _sendUpLoadView.hidden = YES;
//            }
            
            
        }else if(_tempModel.sendStatus==2){
            [self.btnReSend setHidden:NO];
            [self.btnReSend setBackgroundColor:[UIColor clearColor]];
            [self.btnReSend setImage:SobotKitGetImage(@"zcicon_transvoice_fail") forState:UIControlStateNormal];
            _activityView.hidden=YES;
            [_activityView stopAnimating];
            
//            [_sendUpLoadView stopAnimating];
//            _sendUpLoadView.hidden = YES;
        }else{
            // 无需添加权限，如果没有权限，应该是0(未标记)状态
//            if(([ZCUICore getUICore].getLibConfig.readFlag == 1 && [ZCUICore getUICore].getLibConfig.isArtificial) || ([ZCUICore getUICore].getLibConfig.adminReadFlag == 1 && ![ZCUICore getUICore].getLibConfig.isArtificial) ){
                if(_tempModel.readStatus == 1){
                    _btnReadStatus.hidden = NO;
                    [_btnReadStatus setTitleColor:[ZCUIKitTools zcgetRightChatColor] forState:0];
//                    [_btnReadStatus setTitle:SobotKitLocalString(@"未读") forState:0];
            UIImage *img = [SobotImageTools changeImageColor:SobotKitGetImage(@"zcicon_chat_unread") color:[ZCUIKitTools zcgetServerConfigBtnBgColor]];
//                   /* UIImage *img = [[SobotImageTools sobotScaleToSize:CGSizeMake(14, 14) with:SobotKitGetImage(@"zcicon_chat_unread")]*/ imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    [_btnReadStatus setImage:img forState:UIControlStateNormal];
//                    _btnReadStatus.imageView.tintColor = [ZCUIKitTools zcgetServerConfigBtnBgColor];
                }else if(_tempModel.readStatus == 2){
                    // 强制指定图片大小
                    _btnReadStatus.hidden = NO;
                    [_btnReadStatus setTitleColor:UIColorFromKitModeColor(SobotColorTextSub1) forState:0];
//                    [_btnReadStatus setTitle:SobotKitLocalString(@"已读") forState:0];
                    [_btnReadStatus setImage:SobotKitGetImage(@"zcicon_chat_read") forState:UIControlStateNormal];
                    _btnReadStatus.imageView.tintColor = UIColor.clearColor;
                }
//            }
        }
        // 是否是用户发送的 留言转离线消息
        if (_tempModel.leaveMsgFlag == 1) {
            _leaveIcon.hidden = NO;
        }
    }
    
    // 设置踩、赞、转人工
    [self reSetOnOrTurnUser];
    
    [self.ivBgView setNeedsLayout];
    [self.contentView layoutIfNeeded];
   
//    //设置尖角
//    // 此处设置后，图片的大小与实际frame不一致
//    [_ivLayerView setImage:bgImage];
//    [self.ivLayerView setFrame:self.ivBgView.bounds];
//    CALayer *layer              = self.ivLayerView.layer;
//    layer.frame                 = (CGRect){{0,0},self.ivLayerView.layer.frame.size};
//    self.ivBgView.layer.mask = layer;
        
    [self layoutIfNeeded];
#pragma mark
    if (self.isRight) {
        // 处理右侧聊天气泡的 渐变色
//        [_ivBgView setBackgroundColor:[ZCUIKitTools zcgetRobotBackGroundColorWithSize:CGSizeMake(self.ivBgView.bounds.size.width, self.ivBgView.bounds.size.height * 2)]];
        [_ivBgView setBackgroundColor:[ZCUIKitTools zcgetRightChatColorWithSize:CGSizeMake(self.ivBgView.bounds.size.width, self.ivBgView.bounds.size.height * 2)]];
    }
}

-(void)setChatViewBgState:(CGSize)size isSetBgColor:(BOOL)isSetBgColor{
    [self setChatViewBgState:size];
    if(!isSetBgColor){
        [_ivBgView setBackgroundColor:UIColor.clearColor];        
        self.ivBgView.layer.masksToBounds = YES;
        self.ivBgView.layer.borderWidth = 1.0f;
//        self.ivBgView.layer.shadowColor = [ZCUIKitTools zcgetChatBottomLineColor].CGColor;
//        self.ivBgView.layer.shadowOpacity = 0.9;
//        self.ivBgView.layer.shadowRadius = 8;
//        self.ivBgView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        [self.ivBgView setBackgroundColor:[ZCUIKitTools zcgetChatBackgroundColor]];
        self.ivBgView.layer.cornerRadius = 8.0f;
        self.ivBgView.layer.borderColor = [ZCUIKitTools zcgetChatBottomLineColor].CGColor;
    }
}

-(void)resetCellView{
    _lblTime.hidden=YES;
    [_lblTime setText:@""];
    
    _activityView.hidden=YES;
    
    _btnReSend.hidden=YES;
    
    [_activityView stopAnimating];
    [_activityView setHidden:YES];
    
    if(_ivBgView){
        _ivBgView.hidden=NO;
        [_ivBgView.layer.mask removeFromSuperlayer];
    }
    
    if(_ivHeader){
        _ivHeader.image = nil;
    }
    if(_lblNickName){
        _lblNickName.text = @"";
    }
    
    if(_lblSugguest){
        _layoutSugguestWidth.constant = 0;
        _layoutSugguestHeight.constant = 0;
    }
}
-(void)headerClick:(UITapGestureRecognizer *)gesture{
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeHeader text:@"" obj:nil];
    }
}

#pragma mark 踩赞/转人工
-(void)connectWithStepOnWithTheTop:(UIButton *) btn{
    if ([ZCUICore getUICore].getLibConfig.aiAgent) {
        if ([ZCUICore getUICore].getLibConfig.isArtificial) {
            // 人工不能点
            return;
        }
    }
    if(btn.tag == ZCChatCellClickTypeStepOn || btn.tag == ZCChatCellClickTypeTheTop){
        // 说明已经处理过了
        if(self.tempModel.commentType != 1){
            return;
        }
        
        if(isBtnClick){
            return;
        }
        isBtnClick = YES;
    }
    
//    if ([ZCUICore getUICore].getLibConfig.aiAgent) {
//        // 选中的没有边框
//        btn.layer.borderWidth = 0;
//    }
    
    // 此处包含转人工事件
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
        [self.delegate cellItemClick:self.tempModel type:btn.tag text:@"" obj:nil];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(ZCLibConfig *)getZCLibConfig{
    return [[ZCPlatformTools sharedInstance] getPlatformInfo].config;
}

// 链接点击
- (void)SobotEmojiLabel:(SobotEmojiLabel*)emojiLabel didSelectLink:(NSString*)link withType:(SobotEmojiLabelLinkType)type{
   [self doClickURL:link text:@""];
}

// 链接点击
-(void)attributedLabel:(SobotEmojiLabel *)label didSelectLinkWithURL:(NSURL *)url{
    // 此处得到model 对象对应的值
    NSString *textStr = label.text;
    
    if (label.text) {
        NSString *leaveUpMsg = [NSString stringWithFormat:@"%@ %@",SobotKitLocalString(@"您的留言状态有"),SobotKitLocalString(@"更新")];
        leaveUpMsg = [leaveUpMsg stringByReplacingOccurrencesOfString:@" " withString:@" "];// 处理特殊空格国际化下字符串不相同的问题
        if ([sobotConvertToString(label.text) hasSuffix:SobotKitLocalString(@"留言")] && (url.absoluteString.length ==0 || [@"sobot://leavemessage" isEqual:url.absoluteString] )) {
            [self turnLeverMessageVC];
        }else if ([sobotConvertToString(label.text) hasSuffix:leaveUpMsg] && (url.absoluteString.length ==0 || [leaveUpMsg isEqual:url.absoluteString] || [SobotKitLocalString(@"更新") isEqual:url.absoluteString])){
            [self turnLeverMsgRecordVC];
        }else if(url.absoluteString && [url.absoluteString hasPrefix:@"sobot:"]){
            int index = [[url.absoluteString stringByReplacingOccurrencesOfString:@"sobot://" withString:@""] intValue];
            if(index > 0 && self.tempModel.robotAnswer.suggestionList.count>=index){
                textStr = [self.tempModel.robotAnswer.suggestionList objectAtIndex:index-1][@"question"];
            }
        }
        
    }
    [self doClickURL:url.absoluteString text:textStr];
}

- (void)turnLeverMessageVC{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]) {
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeLeaveMessage  text:@"" obj:nil];
    }
}
- (void)turnLeverMsgRecordVC{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]) {
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeLeaveRecordPage text:@"" obj:nil];
    }
}

-(NSString *)getQuestion:(NSDictionary *)model{
    if(model){
        NSMutableDictionary *recDict = [NSMutableDictionary dictionaryWithDictionary:model];
        [recDict removeObjectForKey:@"title"];
        return [SobotCache dataTOjsonString:recDict];
    }
    return @"";
}
// 链接点击
-(void)doClickURL:(NSString *)url text:(NSString * )htmlText{
  
    // 解码
    url = [url stringByRemovingPercentEncoding];

    if(url){
        url=[url stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        // 用户引导说辞的分类的点击事件
        NSString *leaveUpMsg = [NSString stringWithFormat:@"%@ %@",SobotKitLocalString(@"您的留言状态有"),SobotKitLocalString(@"更新")];
        leaveUpMsg = [leaveUpMsg stringByReplacingOccurrencesOfString:@" " withString:@" "];// 处理特殊空格国际化下字符串不相同的问题
        if ([sobotConvertToString(htmlText) hasSuffix:SobotKitLocalString(@"留言")] || [@"sobot://leavemessage" isEqual:url]) {
            [self turnLeverMessageVC];
        }else if ([leaveUpMsg isEqual:url] || [SobotKitLocalString(@"更新") isEqual:url]){
            [self turnLeverMsgRecordVC];
        }else if([url hasPrefix:@"sobot://newsessionchat"]){
            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
                [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeNewSession text:@"" obj:@""];
            }
        }else if([url hasPrefix:@"sobot://insterTrunMsg"]){
            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
                [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeInsterTurn text:@"" obj:@""];
            }
        }else if([url hasPrefix:@"sobot://resendleavemessage"]){
            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
                [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemResendLeaveMsg text:@"" obj:@""];
            }
        }else if([url hasPrefix:@"sobot://continueWaiting"]){
            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
                [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemContinueWaiting text:@"" obj:@""];
            }
        }else if([url hasPrefix:@"sobot://showallsensitive"]){
            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
                [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemShowallsensitive text:@"" obj:@""];
            }
        }else if([url hasPrefix:@"sobot:"]){
            int index = [[url stringByReplacingOccurrencesOfString:@"sobot://" withString:@""] intValue];
            
            if(index > 0 && self.tempModel.robotAnswer.suggestionList.count>=index){
                if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
                    [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemChecked text:@"" obj:self.tempModel.robotAnswer.suggestionList[index-1]];
                }
                return;
            }
            
            if(index > 0 && self.tempModel.richModel.richContent.interfaceRetList.count>=index){
                
                // 单独处理对象
                NSDictionary * dict = @{@"requestText": self.tempModel.richModel.richContent.interfaceRetList[index-1][@"title"],
                                        @"question":[self getQuestion:self.tempModel.richModel.richContent.interfaceRetList[index-1]],
                                        @"questionFlag":@"2",
                                        @"title":self.tempModel.richModel.richContent.interfaceRetList[index-1][@"title"],
                                        @"ishotguide":@"0"
                                        };
                if ([self getZCLibConfig].isArtificial) {
                    dict = @{@"title":self.tempModel.richModel.richContent.interfaceRetList[index-1][@"title"],@"ishotguide":@"0"};
                }
                
                if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
                    [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemGuide text:@"" obj:dict];
                }
            }
            
            
        }else if ([url hasPrefix:@"robot:"]){
            // 处理 机器人回复的 技能组点选事件
            
//          3.0.8 如果当前 已转人工 ， 不可点击
            if([self getZCLibConfig].isArtificial){
                return;
            }
            
            int index = [[url stringByReplacingOccurrencesOfString:@"robot://" withString:@""] intValue];
            if(index > 0 && self.tempModel.robotAnswer.groupList.count>=index){
                if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
                    [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeGroupItemChecked text:@"" obj:[NSString stringWithFormat:@"%d",index-1]];
                }
            }
        }else if([url hasPrefix:@"zc_refresh_newdata"]){
            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
                [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeNewDataGroup text:@"" obj:url];
            }
        }else{
            // 这里需要处理一下，是否用户做了拦截，拦截 就不在对url做处理，用户有自己的处理规则
//            if([[ZCUICore getUICore] LinkClickBlock] == nil || ![ZCUICore getUICore].LinkClickBlock(ZCLinkClickTypeURL,url,[UIViewController new])){
                // 跳转链接的时候 url编码 处理中文
//                url = sobotUrlEncodedString(url);
//            }
            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
                [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeOpenURL text:htmlText obj:url];
            }
        }
    }
}

// 重新发送
-(IBAction)clickReSend:(UIButton *)sender{
    [SobotUITools showAlert:nil message:SobotKitLocalString(@"重新发送") cancelTitle:SobotKitLocalString(@"取消") viewController:[SobotUITools getCurrentVC] confirm:^(NSInteger buttonTag) {
        if(self->_delegate && [self->_delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
            [self->_delegate cellItemClick:self->_tempModel type:ZCChatCellClickTypeReSend text:@"" obj:nil];
        }
    } buttonTitles:SobotKitLocalString(@"发送"), nil];
}

-(void)playVideo:(SobotButton *)btn{
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeTouchImageYES text:@"" obj:nil];
    }
    
    
    id item =  btn.obj;
    
    NSString *msg = sobotUrlEncodedString(self.tempModel.richModel.url);
    
    if(!sobotIsNull(item) && [item isKindOfClass:[SobotChatRichContent class]]){
        msg = sobotConvertToString(((SobotChatRichContent*)item).msg);
    }
    NSURL *url = [NSURL URLWithString:msg];
    // 如果是本地视频，需要使用下面方式创建NSURL
    if(sobotCheckFileIsExsis(msg)){
        url = [NSURL fileURLWithPath:msg];
    }
    
    
    ZCVideoPlayer *player = [[ZCVideoPlayer alloc] initWithFrame:sobotGetCurWindow().bounds withShowInView:sobotGetCurWindow() url:url Image:nil];
    [player showControlsView];
}


// 点击查看大图
-(void) imgTouchUpInside:(UITapGestureRecognizer *)recognizer{
    UIImageView *picTempView=(UIImageView*)recognizer.view;
    // 当前显示的为视频，不支持查看封面大图
    if(picTempView.tag == 101){
        return;
    }
    
    CGRect f = [picTempView convertRect:picTempView.bounds toView:nil];
    
    UIImageView *bgView = [[UIImageView alloc] init];
    [bgView setImage:self.ivLayerView.image];
    // 设置尖角
    [bgView setFrame:f];
    CALayer *layer              = bgView.layer;
    layer.frame                 = (CGRect){{0,0},bgView.layer.frame.size};
        
    SobotImageView *newPicView = [[SobotImageView alloc] init];
    newPicView.image = picTempView.image;
    newPicView.frame = f;
    newPicView.layer.masksToBounds = NO;
//    newPicView.layer.cornerRadius = 15;
    
    newPicView.layer.mask = layer;
    CALayer *calayer = newPicView.layer.mask;
    [newPicView.layer.mask removeFromSuperlayer];
    
    
    __weak ZCChatBaseCell *weakSelf = self;
    
    SobotXHImageViewer *xh=[[SobotXHImageViewer alloc] initWithImageViewersobotHxWillDismissWithSelectedViewBlock:^(SobotXHImageViewer *imageViewer, UIImageView *selectedView) {
        
    } sobotHxDidDismissWithSelectedViewBlock:^(SobotXHImageViewer *imageViewer, UIImageView *selectedView) {
        selectedView.layer.mask = calayer;
        [selectedView setNeedsDisplay];
        [selectedView removeFromSuperview];
        self->_tempPicView = nil;
        if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
            [weakSelf.delegate cellItemClick:weakSelf.tempModel type:ZCChatCellClickTypeTouchImageNO text:@"" obj:self];
        }
    } sobotHxDidChangeToImageViewBlock:^(SobotXHImageViewer *imageViewer, UIImageView *selectedView) {
        
    }];
    
    
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    [photos addObject:newPicView];
    
    xh.delegate = self;
    xh.disableTouchDismiss = NO;
    _imageViewer = xh;
    self.tempPicView = newPicView;
    [xh showWithImageViews:photos selectedView:newPicView];
    
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeTouchImageYES text:@"" obj:xh];
    }
    // 添加长按手势，保存图片
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressAction:)];
    [xh addGestureRecognizer:longPress];
    
}

#pragma mark -- 保存图片到相册
- (void)longPressAction:(UILongPressGestureRecognizer*)longPress{
    //    NSLog(@"长按保存");
    if (longPress.state != UIGestureRecognizerStateBegan) {
        return;
    }
//    _tempImageView = (ZCUIXHImageViewer *)longPress.view;
    NSString *str = [SobotUITools sobotReadCoderURLStrDetectorWith:self.tempPicView.image];// 这里记录临时变量，获取img
    if (str && ![ZCUICore getUICore].kitInfo.hideQRCode) {
        ZCActionSheet *mysheet = [[ZCActionSheet alloc] initWithDelegate:self selectedColor:nil CancelTitle:SobotKitLocalString(@"取消") OtherTitles:SobotKitLocalString(@"保存图片"),SobotKitLocalString(@"识别二维码"), nil];
        mysheet.tag = 100;
        _coderURLStr = str;
        [mysheet show];
    }else{
        ZCActionSheet *mysheet = [[ZCActionSheet alloc] initWithDelegate:self selectedColor:nil CancelTitle:SobotKitLocalString(@"取消") OtherTitles:SobotKitLocalString(@"保存图片"), nil];
        [mysheet show];
    }
    
}

- (void)actionSheet:(ZCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        // 保存图片到相册
        UIImageWriteToSavedPhotosAlbum(_imageViewer.currentImage, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
    }
    else if (buttonIndex == 2){
        [_imageViewer dismissWithAnimate];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(self->_delegate && [self->_delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
                [self->_delegate cellItemClick:self->_tempModel type:ZCChatCellClickTypeOpenURL text:self->_coderURLStr obj:self->_coderURLStr];
            }
        });
    }
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *msg = nil;
    if (error != NULL) {
        msg = SobotKitLocalString(@"保存失败");
    }else{
        msg = SobotKitLocalString(@"保存成功");
    }
    [[SobotToast shareToast] showToast:msg duration:1.0 position:SobotToastPositionCenter];
}

    
+(void)configHtmlText:(NSString *) text label:(SobotEmojiLabel *)label right:(BOOL) isRight{
    if(isRight){
        [label setTextColor:[ZCUIKitTools zcgetRightChatTextColor]];
        [label setLinkColor:[ZCUIKitTools zcgetChatRightlinkColor]];
    }else{
        [label setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        [label setLinkColor:[ZCUIKitTools zcgetChatLeftLinkColor]];
    }
    [SobotHtmlCore filterHtml:text result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
        if (isRight) {
            if (text1 != nil && text1.length > 0) {
                label.attributedText =   [SobotHtmlFilter setHtml:text1 attrs:arr view:label textColor:[ZCUIKitTools zcgetRightChatTextColor] textFont:[ZCUIKitTools zcgetKitChatFont] linkColor:[ZCUIKitTools zcgetChatRightlinkColor]];
            }else{
                label.attributedText =   [[NSAttributedString alloc] initWithString:@""];
            }
            
        }else{
            if (text1 != nil && text1.length > 0) {
                label.attributedText =    [SobotHtmlFilter setHtml:text1 attrs:arr view:label textColor:[ZCUIKitTools zcgetLeftChatTextColor] textFont:[ZCUIKitTools zcgetKitChatFont] linkColor:[ZCUIKitTools zcgetChatLeftLinkColor]];
            }else{
                label.attributedText =   [[NSAttributedString alloc] initWithString:@""];
            }
        }
    }];
    
}
-(void)getLinkValues:(NSString *) link name:(NSString *)name result:(void(^)(NSString *title,NSString *desc,NSString *icon)) block{
    
    
    
    NSDictionary *item = [SobotCache getLocalParamter:[NSString stringWithFormat:@"%@%@",Sobot_CacheURLHeader,sobotConvertToString(link)]];
    if(!sobotIsNull(item) && item.count > 0){
        if(block){
            block(sobotConvertToString(item[@"title"]),sobotConvertToString(item[@"desc"]),sobotConvertToString([item objectForKey:@"imgUrl"]));
        }
        return;
    }
    
    [ZCLibServer getHtmlAnalysisWithURL:sobotConvertToString(link) start:^(NSString *url){
        
    } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
        if (!sobotIsNull(dict)) {
            NSDictionary *data = [dict objectForKey:@"data"];
            NSString *title = sobotConvertToString([data objectForKey:@"title"]);
            NSString *desc = sobotConvertToString([data objectForKey:@"desc"]);
            NSString *imgUrl = sobotConvertToString([data objectForKey:@"imgUrl"]);
            if(title.length > 0 || imgUrl.length >0){
                if (sobotConvertToString(title).length == 0) {
                    if (sobotConvertToString(name).length >0) {
                        title = sobotConvertToString(name);
                    }else{
                        title = sobotConvertToString(link);
                    }
                }
                if (sobotConvertToString(desc).length == 0) {
                    desc = sobotConvertToString(link);
                }
                NSDictionary *dataDic = @{@"title":sobotConvertToString(title),
                                          @"desc":sobotConvertToString(desc),
                                          @"imgUrl":sobotConvertToString(imgUrl),
                };
                [SobotCache addObject:dataDic forKey:[NSString stringWithFormat:@"%@%@",Sobot_CacheURLHeader,sobotConvertToString(link)]];
            }
            
            [[ZCUICore getUICore] addMessage:nil reload:YES];
            
//            if(block){
//                block(title,desc,imgUrl);
//            }
        }
    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
        NSString *title = name;
        NSString *desc = link;
        if(name.length == 0){
            title = link;
            desc = @"";
        }
        NSDictionary *dataDic = @{@"title":sobotConvertToString(title),
                                  @"desc":sobotConvertToString(desc),
                                  @"imgUrl":@""
        };
        
        [SobotCache addObject:dataDic forKey:[NSString stringWithFormat:@"%@%@",Sobot_CacheURLHeader,sobotConvertToString(link)]];
        
        [[ZCUICore getUICore] addMessage:nil reload:YES];
//        // 解析失败了
//        if(block){
//            block(title,desc,@"");
//        }
    
    }];
}


+(void)configHtmlText:(NSString *) text label:(SobotEmojiLabel *)label right:(BOOL) isRight isTip:(BOOL)isTip{
    if(isRight){
        [label setTextColor:[ZCUIKitTools zcgetRightChatTextColor]];
        [label setLinkColor:[ZCUIKitTools zcgetChatRightlinkColor]];
    }else{
        [label setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        [label setLinkColor:[ZCUIKitTools zcgetChatLeftLinkColor]];
    }
    UIFont *font = [ZCUIKitTools zcgetKitChatFont];
    if (isTip) {
        [label setTextColor:UIColorFromKitModeColor(SobotColorTextSubDark)];
        [label setLinkColor:[ZCUIKitTools zcgetChatLeftLinkColor]];
        font = SobotFont12;
    }
   
    [SobotHtmlCore filterHtml:text result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
        if (isRight) {
            if (text1 != nil && text1.length > 0) {
                if (isTip) {
                    label.attributedText =   [SobotHtmlFilter setHtml:text1 attrs:arr view:label textColor:[ZCUIKitTools zcgetRightChatTextColor] textFont:font linkColor:[ZCUIKitTools zcgetChatRightlinkColor]];
                }else{
                    label.attributedText =   [SobotHtmlFilter setHtml:text1 attrs:arr view:label textColor:UIColorFromKitModeColor(SobotColorTextSubDark) textFont:font linkColor:[ZCUIKitTools zcgetChatRightlinkColor]];
                }
            }else{
                label.attributedText =   [[NSAttributedString alloc] initWithString:@""];
            }
        }else{
            if (text1 != nil && text1.length > 0) {
                if (isTip) {
                    label.attributedText =    [SobotHtmlFilter setHtml:text1 attrs:arr view:label textColor:UIColorFromKitModeColor(SobotColorTextSubDark) textFont:font linkColor:[ZCUIKitTools zcgetChatLeftLinkColor]];
                }else{
                    label.attributedText =    [SobotHtmlFilter setHtml:text1 attrs:arr view:label textColor:[ZCUIKitTools zcgetLeftChatTextColor] textFont:font linkColor:[ZCUIKitTools zcgetChatLeftLinkColor]];
                }
            }else{
                label.attributedText =   [[NSAttributedString alloc] initWithString:@""];
            }
        }
    }];
}

-(CGSize )addSugguestViews:(UIView *) sView w:(CGFloat )maxW{
    if(sView == nil){
        return CGSizeZero;
    }
    [sView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat w = 0;
    CGFloat h = 0;
    NSMutableArray *arr = [self.tempModel getSuggestionList];
    sView.userInteractionEnabled = YES;
    if(arr.count > 0){
        SobotEmojiLabel *preLab = nil;
        for(NSDictionary *item in arr){
            NSString *title = sobotConvertToString(item[@"title"]);
            NSString *url = sobotConvertToString(item[@"url"]);
            NSString *text = sobotConvertToString(item[@"text"]);
            SobotEmojiLabel *label = [ZCChatBaseCell createRichLabel:self];
            if(self.isRight){
                [label setTextColor:[ZCUIKitTools zcgetRightChatTextColor]];
                [label setLinkColor:[ZCUIKitTools zcgetChatRightlinkColor]];
            }else{
                [label setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
                [label setLinkColor:[ZCUIKitTools zcgetChatLeftLinkColor]];
            }
            
            if(title.length > 0){
                [label setText:title];
            }else{
                [label setText:text];
            }
            
            CGSize itemSize = [label preferredSizeWithMaxWidth:maxW];
            if(w < itemSize.width){
                w = itemSize.width;
            }
            h = h + itemSize.height;
            if(url.length > 0){
                [label addLinkToURL:[NSURL URLWithString:url] withRange:NSMakeRange(0, text.length)];
            }
            [sView addSubview:label];
            
            [sView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingHSpace, label, sView)];
            [sView addConstraint:sobotLayoutPaddingRight(-ZCChatPaddingHSpace, label, sView)];
            if(preLab){
                if(url.length > 0){
                    [sView addConstraint:sobotLayoutMarginTop(10, label, preLab)];
                    h = h + 10;
                }else{
                    [sView addConstraint:sobotLayoutMarginTop([ZCUIKitTools zcgetChatLineSpacing], label, preLab)];
                    h = h + [ZCUIKitTools zcgetChatLineSpacing];
                }
            }else{
                [sView addConstraint:sobotLayoutPaddingTop(0, label, sView)];
//                if(url.length > 0){
//                    [sView addConstraint:sobotLayoutPaddingTop(8, label, sView)];
//                    h = h + 8;
//                }else{
//                    [sView addConstraint:sobotLayoutPaddingTop(4, label, sView)];
//                    h = h + 4;
//                }
            }
            
            preLab = label;
        }
        if(preLab){
            [sView addConstraint:sobotLayoutPaddingBottom(0, preLab, sView)];
            
            [sView layoutIfNeeded];
        }
    }
    
    
    return CGSizeMake(w, h);
}


#pragma mark - gesture delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
//    if([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]){
//        if(![NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]){
//            [self showLongMenu:nil];
//            return NO;
//        }
//    }
    
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"SobotEmojiLabel"]) {
//        if(![@"" isEqualToString:morelink ] && morelink!= nil && self.delegate && [self.delegate respondsToSelector:@selector(cellItemLinkClick:type:obj:)]){
//            [self.delegate cellItemLinkClick:self.lookMoreLabel.text type:ZCChatCellClickTypeOpenURL obj:morelink];
//            return NO;
//        }
        return NO;
    }
    return YES;

}


#pragma mark -- 长按复制
- (void)doLongPress:(UIGestureRecognizer *)recognizer{
    if (recognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    CGPoint p = [recognizer locationInView:self.contentView];
    CGRect tf     = _ivBgView.frame;
    if(p.x>tf.origin.x && p.x < (tf.origin.x + tf.size.width) && p.y>tf.origin.y && p.y < (tf.origin.y + tf.size.height)){
        [self showLongMenu:self.ivBgView];
    }
}

-(void)showLongMenu:(UIView *_Nullable)view{
    
    if(self.tempModel.msgType != SobotMessageTypeText && view!=nil){
        SobotView *iv = (SobotView*)view;
        if([iv isKindOfClass:[SobotView class]]){
            copyUrl = iv.objTag;
        }
    }else{
        copyUrl = self.tempModel.richModel.content;
    }
    
    // 没有复制内容
    if(self.tempModel.msgType == SobotMessageTypeText && sobotConvertToString(copyUrl).length == 0){
        [self didChangeBgColorWithsIsSelect:NO];
        return;
    }
    
    if(_menuController!=nil && _menuController.isMenuVisible){
        [self didChangeBgColorWithsIsSelect:NO];
    }
    
    
    [self becomeFirstResponder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuControllerWillHideWithClick) name:UIMenuControllerDidHideMenuNotification object:nil];
    
    _menuController = [UIMenuController sharedMenuController];
    
    NSMutableArray *menuItems = [[NSMutableArray alloc] init];
    if(self.tempModel.msgType == SobotMessageTypeText){
        UIMenuItem *copyItem = [[UIMenuItem alloc]initWithTitle:SobotKitLocalString(@"复制") action:@selector(doCopy)];
        [menuItems addObject:copyItem];
        [_menuController setMenuItems:@[copyItem]];
    }
    
    SobotChatCustomCard *card = self.tempModel.richModel.customCard; // 订单不能引用
    
    // 没有推荐选项的消息才支持引用
    NSString *displayText = [self.tempModel getModelDisplaySugestionText];
    if(sobotConvertToString(displayText).length == 0 && !self.tempModel.isRobotGuide
       && self.tempModel.action != SobotMessageActionTypeSendGoods
       && self.tempModel.action != SobotMessageActionTypeAdminHelloWord
       && self.tempModel.action != SobotMessageActionTypeRobotHelloWord){
        
        // 当前是新会话键盘弹起 或者会话结束了，就不能发送这个消息了
//        curKeyboardStatus == ZCKeyboardStatusNewSession
        if (![ZCUICore getUICore].isKeyboardNewSession) {
            if([ZCUICore getUICore].getLibConfig.msgAppointFlag == 1){
                if(self.tempModel.msgType == SobotMessageTypeText||
                   self.tempModel.msgType == SobotMessageTypePhoto||
                   self.tempModel.msgType == SobotMessageTypeVideo||
                   self.tempModel.msgType == SobotMessageTypeFile||
                   self.tempModel.msgType == SobotMessageTypeSound||
                   self.tempModel.richModel.type == SobotMessageRichJsonTypeGoods||
                   self.tempModel.richModel.type == SobotMessageRichJsonTypeApplet||
                   self.tempModel.richModel.type == SobotMessageRichJsonTypeArticle||
                   self.tempModel.richModel.type == SobotMessageRichJsonTypeLocation||
                   self.tempModel.richModel.type == SobotMessageRichJsonTypeText||
                   (self.tempModel.richModel.type == SobotMessageRichJsonTypeCustomCard && card.cardStyle == 1)
                   ){
                    UIMenuItem *Item2 = [[UIMenuItem alloc]initWithTitle:SobotKitLocalString(@"引用") action:@selector(doReferenceMessage)];
                    //            if([ZCUICore getUICore].getLibConfig.isArtificial){
                    [menuItems addObject:Item2];
                    //            }
                }
            }
        }
       
    }
    [_menuController setMenuItems:menuItems];
    [_menuController setArrowDirection:(UIMenuControllerArrowDefault)];
    
    if(_menuController.menuItems.count >0){
        if(self.tempModel.msgType != SobotMessageTypeSound){
            [self didChangeBgColorWithsIsSelect:YES];
        }
    }
    
    // 设置frame cell的位置
    CGRect tf     = _ivBgView.frame;
    CGRect rect = CGRectMake(tf.origin.x, tf.origin.y, tf.size.width, tf.size.height);
    
    [_menuController setTargetRect:rect inView:self];
    
    [_menuController setMenuVisible:YES animated:YES];
}

- (void)willHideEditMenu:(id)sender{
    [self didChangeBgColorWithsIsSelect:NO];
}

-(void)menuControllerWillHideWithClick{
    [self didChangeBgColorWithsIsSelect:NO];
}

- (void)didChangeBgColorWithsIsSelect:(BOOL)isSelected{
//    return; //同安卓的一样，不做背景切换，后期需要和V1一样时 在放开
    if (isSelected) {
        if (self.isRight) {
            [self.ivBgView setBackgroundColor:[ZCUIKitTools zcgetRightChatSelectdeColor]];
        }else{
            [self.ivBgView setBackgroundColor:[ZCUIKitTools zcgetLeftChatSelectedColor]];
        }
    }else{
        if (self.isRight) {
            // 右边气泡绿色
//            [_ivBgView setBackgroundColor:[ZCUIKitTools zcgetRobotBackGroundColorWithSize:CGSizeMake(self.ivBgView.bounds.size.width, self.ivBgView.bounds.size.height * 2)]];
            [_ivBgView setBackgroundColor:[ZCUIKitTools zcgetRightChatColorWithSize:CGSizeMake(self.ivBgView.bounds.size.width, self.ivBgView.bounds.size.height * 2)]];
        }else{
            // 左边的气泡颜色
            [self.ivBgView setBackgroundColor:[ZCUIKitTools zcgetLeftChatColor]];
        }
        
        // 这里需要区分是否是语音消息，语音消息气泡颜色不设置
        if(self.tempModel.msgType == SobotMessageTypeSound){
            if([self.tempModel getModelDisplaySugestionText].length == 0){
                self.ivBgView.backgroundColor = UIColor.clearColor;
            }else{
               // 恢复之前的背景色
                if(self.isRight){
                    [_ivBgView setBackgroundColor:[ZCUIKitTools zcgetRightChatColor]];
                }else{
                    [_ivBgView setBackgroundColor:[ZCUIKitTools zcgetLeftChatColor]];
                }
            }
        }
        
        if(_menuController){
//            [_menuController setTargetRect:CGRectMake(0, 0, 0, 0) inView:self];
            [_menuController setMenuVisible:NO animated:NO];
        }
    }
    [self.ivBgView setNeedsDisplay];
    
}

//复制
-(void)doCopy{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:sobotConvertToString(copyUrl)];
    [[SobotToast shareToast] showToast:SobotKitLocalString(@"复制成功") duration:1.0f position:SobotToastPositionCenter];
    [self didChangeBgColorWithsIsSelect:NO];
}

//复制
-(void)doReferenceMessage{
    [self didChangeBgColorWithsIsSelect:NO];
    // 仅调试测试使用
    [[ZCUICore getUICore] doReferenceMessage:self.tempModel];
}

#pragma mark - UIMenuController 必须实现的两个方法
- (BOOL)canBecomeFirstResponder{
    return YES;
}

/*
 *  根据action,判断UIMenuController是否显示对应aciton的title
 */
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (action == @selector(doCopy) || action == @selector(doReferenceMessage) ) {
        return YES;
    }
    return NO;
}

#pragma mark --  更新 点踩、点赞 在下方的数据  当前是否是选中的状态
-(void)createOpenSubViewIsOn:(BOOL)isOn isSel:(BOOL)isSel enabled:(BOOL)iSenabled{
    // 这里需要计算宽度
    NSString *originalString = SobotKitLocalString(@"顶");
    if (isOn) {
        originalString = SobotKitLocalString(@"踩");
    }
    
    NSString *capitalizedString = originalString.length > 0 ? [originalString stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[originalString substringToIndex:1] uppercaseString]] : originalString;
    
    CGFloat w1 = [SobotUITools getWidthContain:capitalizedString font:SobotFont12 Height:20];
    // 左右间距
    w1 = w1 + 14 + 4 + 12*2;
    
    if ([ZCUICore getUICore].getLibConfig.aiAgent) {
        // 大模型机器
        w1 = 28; // 固定不显示文字 UI要求
    }
    
    if (isOn) {
        // 踩
        if (!sobotIsNull(_btnBtmStepOnImgBgView)) {
            [_btnBtmStepOnImgBgView removeFromSuperview];
            _btnBtmStepOnImgBgView = nil;
        }
        _btnBtmStepOnImgBgView = ({
            UIView *iv = [[UIView alloc]init];
            [_btnBtmStepOn addSubview:iv];
            [_btnBtmStepOn addConstraint:sobotLayoutEqualCenterX(0, iv, _btnBtmStepOn)];
            [_btnBtmStepOn addConstraint:sobotLayoutEqualCenterY(0, iv, _btnBtmStepOn)];
            self.btnBtmStepOnImgBgViewH = sobotLayoutEqualHeight(28, iv, NSLayoutRelationEqual);
            [_btnBtmStepOn addConstraint:self.btnBtmStepOnImgBgViewH];
            [_btnBtmStepOn addConstraint:sobotLayoutEqualWidth(w1, iv, NSLayoutRelationEqual)];
            iv.layer.cornerRadius = 14;
            iv.layer.masksToBounds = YES;
            iv;
        });
        
        if (!sobotIsNull(_btnBtmStepOnImg)) {
            [_btnBtmStepOnImg removeFromSuperview];
            _btnBtmStepOnImg = nil;
        }
        _btnBtmStepOnImg = ({
            UIImageView *iv = [[UIImageView alloc] init];
            if ([ZCUICore getUICore].getLibConfig.aiAgent && [ZCUICore getUICore].getLibConfig.realuateButtonStyle) {
                // ❤图片
                if (isSel) {
                    [iv setImage:SobotKitGetImage(@"zcicon_useless_sel_heart")];
                }else{
                    [iv setImage:SobotKitGetImage(@"zcicon_useless_nol_heart")];
                }
            }else{
                if ([ZCUICore getUICore].getLibConfig.aiAgent) {
                    if (isSel) {
                        [iv setImage:SobotKitGetImage(@"zcicon_useless_sel_ai")];
                    }else{
                        [iv setImage:SobotKitGetImage(@"zcicon_useless_nol_new_ai")];
                    }
                }else{
                    if (isSel) {
                        [iv setImage:SobotKitGetImage(@"zcicon_useless_sel")];
                    }else{
                        [iv setImage:SobotKitGetImage(@"zcicon_useless_nol_new")];
                    }
                }
            }
            [_btnBtmStepOnImgBgView addSubview:iv];
            
            if ([ZCUICore getUICore].getLibConfig.aiAgent) {
                [_btnBtmStepOnImgBgView addConstraints:sobotLayoutSize(26, 26, iv,NSLayoutRelationEqual)];
                [_btnBtmStepOnImgBgView addConstraint:sobotLayoutEqualCenterX(0, iv, _btnBtmStepOnImgBgView)];
                [_btnBtmStepOnImgBgView addConstraint:sobotLayoutEqualCenterY(0, iv, _btnBtmStepOnImgBgView)];
            }else{
                [_btnBtmStepOnImgBgView addConstraints:sobotLayoutSize(14, 14, iv,NSLayoutRelationEqual)];
                [_btnBtmStepOnImgBgView addConstraint:sobotLayoutPaddingLeft(12, iv, _btnBtmStepOnImgBgView)];
                [_btnBtmStepOnImgBgView addConstraint:sobotLayoutEqualCenterY(0, iv, _btnBtmStepOnImgBgView)];
            }
            iv;
        });
        
        if (!sobotIsNull(_btnBtmStepOnLab)) {
            [_btnBtmStepOnLab removeFromSuperview];
            _btnBtmStepOnLab = nil;
        }
        
        if (![ZCUICore getUICore].getLibConfig.aiAgent) {
            _btnBtmStepOnLab = ({
                UILabel *iv = [[UILabel alloc]init];
                iv.font = SobotFont12;
                iv.textColor = UIColorFromKitModeColor(SobotColorTextMain);
                iv.text = capitalizedString;
                [_btnBtmStepOnImgBgView addSubview:iv];
                [_btnBtmStepOnImgBgView addConstraint:sobotLayoutEqualCenterY(0, iv, _btnBtmStepOnImgBgView)];
                [_btnBtmStepOnImgBgView addConstraint:sobotLayoutPaddingRight(-12, iv, _btnBtmStepOnImgBgView)];
                [_btnBtmStepOnImgBgView addConstraint:sobotLayoutMarginLeft(4, iv, _btnBtmStepOnImg)];
                iv;
            });
        }
        
        if (!sobotIsNull(_btnBtmStepOnClick)) {
            [_btnBtmStepOnClick removeFromSuperview];
            _btnBtmStepOnClick = nil;
        }
        
        if (iSenabled) {
            _btnBtmStepOnClick = ({
                UIButton *iv = [[UIButton alloc]init];
                iv.tag = ZCChatCellClickTypeStepOn;
                [_btnBtmStepOnImgBgView addSubview:iv];
                [iv addTarget:self action:@selector(connectWithStepOnWithTheTop:) forControlEvents:UIControlEventTouchUpInside];
                [_btnBtmStepOnImgBgView addConstraint:sobotLayoutPaddingTop(0, iv, _btnBtmStepOnImgBgView)];
                [_btnBtmStepOnImgBgView addConstraint:sobotLayoutPaddingRight(0, iv, _btnBtmStepOnImgBgView)];
                [_btnBtmStepOnImgBgView addConstraint:sobotLayoutPaddingLeft(0, iv, _btnBtmStepOnImgBgView)];
                [_btnBtmStepOnImgBgView addConstraint:sobotLayoutPaddingRight(0, iv, _btnBtmStepOnImgBgView)];
                iv;
            });
        }
    }else{
        // 顶
        if (!sobotIsNull(_btnBtmTheTopBgView)) {
            [_btnBtmTheTopBgView removeFromSuperview];
            _btnBtmTheTopBgView = nil;
        }
        _btnBtmTheTopBgView = ({
            UIView *iv = [[UIView alloc]init];
            [_btnBtmTheTop addSubview:iv];
            [_btnBtmTheTop addConstraint:sobotLayoutEqualCenterX(0, iv, _btnBtmTheTop)];
            [_btnBtmTheTop addConstraint:sobotLayoutEqualCenterY(0, iv, _btnBtmTheTop)];
            self.btnBtmTheTopBgViewH = sobotLayoutEqualHeight(28, iv, NSLayoutRelationEqual);
            [_btnBtmTheTop addConstraint:self.btnBtmTheTopBgViewH];
            [_btnBtmTheTop addConstraint:sobotLayoutEqualWidth(w1, iv, NSLayoutRelationEqual)];
            iv.layer.cornerRadius = 14;
            iv.layer.masksToBounds = YES;
            iv;
        });
        
        if (!sobotIsNull(_btnBtmTheTopImg)) {
            [_btnBtmTheTopImg removeFromSuperview];
            _btnBtmTheTopImg = nil;
        }
        _btnBtmTheTopImg = ({
            UIImageView *iv = [[UIImageView alloc] init];
            if ([ZCUICore getUICore].getLibConfig.aiAgent && [ZCUICore getUICore].getLibConfig.realuateButtonStyle) {
                // ❤图片
                if (isSel) {
                    [iv setImage:SobotKitGetImage(@"zcicon_useful_sel_heart")];
                }else{
                    [iv setImage:SobotKitGetImage(@"zcicon_useful_nor_heart")];
                    [iv setBackgroundColor:UIColor.clearColor];
                }
            }else{
                if ([ZCUICore getUICore].getLibConfig.aiAgent) {
                    if (isSel) {
                        [iv setImage:SobotKitGetImage(@"zcicon_useful_sel_ai_shou")];
                    }else{
                        [iv setImage:SobotKitGetImage(@"zcicon_useful_nor_new_ai")];
                    }
                }else{
                    if (isSel) {
                        [iv setImage:SobotKitGetImage(@"zcicon_useful_sel")];
                    }else{
                        [iv setImage:SobotKitGetImage(@"zcicon_useful_nor_new")];
                    }
                }
                
            }
            [_btnBtmTheTopBgView addSubview:iv];
            
            if ([ZCUICore getUICore].getLibConfig.aiAgent) {
                [_btnBtmTheTopBgView addConstraints:sobotLayoutSize(26, 26, iv,NSLayoutRelationEqual)];
                [_btnBtmTheTopBgView addConstraint:sobotLayoutEqualCenterY(0, iv, _btnBtmTheTopBgView)];
                [_btnBtmTheTopBgView addConstraint:sobotLayoutEqualCenterX(0, iv, _btnBtmTheTopBgView)];
            }else{
                [_btnBtmTheTopBgView addConstraints:sobotLayoutSize(14, 14, iv,NSLayoutRelationEqual)];
                [_btnBtmTheTopBgView addConstraint:sobotLayoutPaddingLeft(12, iv, _btnBtmTheTopBgView)];
                [_btnBtmTheTopBgView addConstraint:sobotLayoutEqualCenterY(0, iv, _btnBtmTheTopBgView)];
            }
            iv;
        });
        
        if ([ZCUICore getUICore].getLibConfig.aiAgent) {
            if (isSel) {
                [_btnBtmTheTopBgView setBackgroundColor:UIColorFromKitModeColor(@"#FFF5E3")];
            }else{
                [_btnBtmTheTopBgView setBackgroundColor:UIColor.clearColor];
            }
        }
        
        if (!sobotIsNull(_btnBtmTheTopLab)) {
            [_btnBtmTheTopLab removeFromSuperview];
            _btnBtmTheTopLab = nil;
        }
        
        if (![ZCUICore getUICore].getLibConfig.aiAgent) {
            _btnBtmTheTopLab = ({
                UILabel *iv = [[UILabel alloc]init];
                iv.font = SobotFont12;
                iv.textColor = UIColorFromKitModeColor(SobotColorTextMain);
                iv.text = capitalizedString;
                [_btnBtmTheTopBgView addSubview:iv];
                [_btnBtmTheTopBgView addConstraint:sobotLayoutEqualCenterY(0, iv, _btnBtmTheTopBgView)];
                [_btnBtmTheTopBgView addConstraint:sobotLayoutPaddingRight(-12, iv, _btnBtmTheTopBgView)];
                [_btnBtmTheTopBgView addConstraint:sobotLayoutMarginLeft(4, iv, _btnBtmTheTopImg)];
                iv;
            });
        }
        
        if (!sobotIsNull(_btnBtmTheTopClick)) {
            [_btnBtmTheTopClick removeFromSuperview];
            _btnBtmTheTopClick = nil;
        }
        
        // 开交互
        if (iSenabled) {
            _btnBtmTheTopClick = ({
                UIButton *iv = [[UIButton alloc]init];
                iv.tag = ZCChatCellClickTypeTheTop;
                [_btnBtmTheTopBgView addSubview:iv];
                [iv addTarget:self action:@selector(connectWithStepOnWithTheTop:) forControlEvents:UIControlEventTouchUpInside];
                [_btnBtmTheTopBgView addConstraint:sobotLayoutPaddingTop(0, iv, _btnBtmTheTopBgView)];
                [_btnBtmTheTopBgView addConstraint:sobotLayoutPaddingRight(0, iv, _btnBtmTheTopBgView)];
                [_btnBtmTheTopBgView addConstraint:sobotLayoutPaddingLeft(0, iv, _btnBtmTheTopBgView)];
                [_btnBtmTheTopBgView addConstraint:sobotLayoutPaddingRight(0, iv, _btnBtmTheTopBgView)];
                iv;
            });
        }
    }
}

#pragma mark -- 转人工按钮 子视图
-(void)createTureBtn:(BOOL)iSenabled{
    NSString *originalString = SobotKitLocalString(@"转人工");
    CGFloat w1 = [SobotUITools getWidthContain:originalString font:SobotFont12 Height:20];
    // 左右间距
    w1 = w1 + 14 + 4 + 12*2;
    
    if (!sobotIsNull(_btnTurnUserBgView)) {
        [_btnTurnUserBgView removeFromSuperview];
        _btnTurnUserBgView = nil;
    }
    _btnTurnUserBgView = ({
        UIView *iv = [[UIView alloc]init];
        [_btnTurnUser addSubview:iv];
        [_btnTurnUser addConstraint:sobotLayoutEqualCenterX(0, iv, _btnTurnUser)];
        [_btnTurnUser addConstraint:sobotLayoutEqualCenterY(0, iv, _btnTurnUser)];
        self.btnTurnUserBgH = sobotLayoutEqualHeight(20, iv, NSLayoutRelationEqual);
        [_btnTurnUser addConstraint:self.btnTurnUserBgH];
        [_btnTurnUser addConstraint:sobotLayoutEqualWidth(w1, iv, NSLayoutRelationEqual)];
        iv;
    });
    
    if (!sobotIsNull(_btnTurnUserImg)) {
        [_btnTurnUserImg removeFromSuperview];
        _btnTurnUserImg = nil;
    }
    _btnTurnUserImg = ({
        UIImageView *iv = [[UIImageView alloc] init];
        [iv setImage:SobotKitGetImage(@"icon_fast_transfer")];
        [_btnTurnUserBgView addSubview:iv];
        [_btnTurnUserBgView addConstraints:sobotLayoutSize(14, 14, iv,NSLayoutRelationEqual)];
        [_btnTurnUserBgView addConstraint:sobotLayoutPaddingLeft(12, iv, _btnTurnUserBgView)];
        [_btnTurnUserBgView addConstraint:sobotLayoutEqualCenterY(0, iv, _btnTurnUserBgView)];
        iv;
    });
    
    if (!sobotIsNull(_btnTurnUserLab)) {
        [_btnTurnUserLab removeFromSuperview];
        _btnTurnUserLab = nil;
    }
    
    _btnTurnUserLab = ({
        UILabel *iv = [[UILabel alloc]init];
        iv.font = SobotFont12;
        iv.textColor = UIColorFromKitModeColor(SobotColorTextMain);
        iv.text = originalString;
        [_btnTurnUserBgView addSubview:iv];
        [_btnTurnUserBgView addConstraint:sobotLayoutEqualCenterY(0, iv, _btnTurnUserBgView)];
        [_btnTurnUserBgView addConstraint:sobotLayoutPaddingRight(-12, iv, _btnTurnUserBgView)];
        [_btnTurnUserBgView addConstraint:sobotLayoutMarginLeft(4, iv, _btnTurnUserImg)];
        iv;
    });
    
    if (!sobotIsNull(_btnTurnUserClick)) {
        [_btnTurnUserClick removeFromSuperview];
        _btnTurnUserClick = nil;
    }

    // 开交互
    if (iSenabled) {
        _btnTurnUserClick = ({
            UIButton *iv = [[UIButton alloc]init];
            iv.tag = ZCChatCellClickTypeConnectUser;
            [_btnTurnUserBgView addSubview:iv];
            [iv addTarget:self action:@selector(connectWithStepOnWithTheTop:) forControlEvents:UIControlEventTouchUpInside];
            [_btnTurnUserBgView addConstraint:sobotLayoutPaddingTop(0, iv, _btnTurnUserBgView)];
            [_btnTurnUserBgView addConstraint:sobotLayoutPaddingRight(0, iv, _btnTurnUserBgView)];
            [_btnTurnUserBgView addConstraint:sobotLayoutPaddingLeft(0, iv, _btnTurnUserBgView)];
            [_btnTurnUserBgView addConstraint:sobotLayoutPaddingRight(0, iv, _btnTurnUserBgView)];
            iv;
        });
    }
}

@end
