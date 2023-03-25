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

@interface ZCChatBaseCell()<ZCActionSheetDelegate>
{
    CGSize tempSize;
    
    NSString *copyUrl;
    
    // 按钮连续重复点击
    BOOL isBtnClick;
}

@property(nonatomic,strong) NSLayoutConstraint *layoutTimeHeight;
@property(nonatomic,strong) NSLayoutConstraint *layoutTimeTop;
@property(nonatomic,strong) NSLayoutConstraint *layoutChatBgPadingLeft;
@property(nonatomic,strong) NSLayoutConstraint *layoutChatBgPadingRight;
@property(nonatomic,strong) NSLayoutConstraint *layoutChatBgWidth;

@property(nonatomic,strong) NSLayoutConstraint *layoutAvatarRight;
@property(nonatomic,strong) NSLayoutConstraint *layoutAvatarLeft;
@property(nonatomic,strong) NSLayoutConstraint *layoutAvatarEH;
@property(nonatomic,strong) NSLayoutConstraint *layoutAvatarEW;

@property(nonatomic,strong) NSLayoutConstraint *layoutNameLeft;
@property(nonatomic,strong) NSLayoutConstraint *layoutNameRight;
@property(nonatomic,strong) NSLayoutConstraint *layoutNameTop;

@property(nonatomic,strong) NSLayoutConstraint *layoutSugguestWidth;
@property(nonatomic,strong) NSLayoutConstraint *layoutSugguestHeight;
@property(nonatomic,strong) NSLayoutConstraint *layoutSugguestBottom;

@property(nonatomic,strong) NSLayoutConstraint *layoutTurnTop;
@property(nonatomic,strong) NSLayoutConstraint *layoutTurnHeight;

@property(nonatomic,strong) NSLayoutConstraint *layoutTheTopHeight;
@property(nonatomic,strong) NSLayoutConstraint *layoutSetOnSpace;
@property(nonatomic,strong) NSLayoutConstraint *layoutSetOnHeight;

@property(nonatomic,strong) NSLayoutConstraint *layoutleaveIconPB;

@property(nonatomic,strong) SobotXHImageViewer *imageViewer;
@property(nonatomic,strong) NSString *coderURLStr;
@property(nonatomic,strong) UIMenuController *menuController;
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
        [self.contentView addConstraints:sobotLayoutPaddingView(0, 0, 1, -1, iv, self.contentView)];
        _layoutTimeTop = sobotLayoutPaddingTop(ZCChatMarginVSpace/2, iv, self.contentView);
        _layoutTimeHeight = sobotLayoutEqualHeight(0, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:_layoutTimeHeight];
        [self.contentView addConstraint:_layoutTimeTop];
        iv;
    });
    
    
    _ivHeader =({
        SobotImageView *iv = [[SobotImageView alloc] init];
        [iv setContentMode:UIViewContentModeScaleAspectFit];
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
        self.layoutAvatarEH = sobotLayoutEqualWidth(30, iv, NSLayoutRelationEqual);
        self.layoutAvatarEW = sobotLayoutEqualHeight(30, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.layoutAvatarEW];
        [self.contentView addConstraint:self.layoutAvatarEH];
        [self.contentView addConstraint:sobotLayoutMarginTop(ZCChatMarginVSpace, iv, _lblTime)];
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
        if(showType == 0 || showType == 2){
            iv.hidden = YES;
        }else{
            CGFloat space = ZCChatMarginHSpace;
            if(showType == 1){
                space = ZCChatMarginHSpace + ZCChatMarginVSpace + 30;
            }
            _layoutNameLeft = sobotLayoutPaddingLeft(space, iv, self.contentView);
            _layoutNameRight = sobotLayoutPaddingRight(-space, iv, self.contentView);
            _layoutNameTop = sobotLayoutMarginTop(ZCChatMarginVSpace, iv, _lblTime);
            [self.contentView addConstraint:_layoutNameLeft];
            [self.contentView addConstraint:_layoutNameRight];
            [self.contentView addConstraint:_layoutNameTop];
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
        
        [self.contentView addConstraint:sobotLayoutMarginTop(ZCChatCellItemSpace, iv, _lblNickName)];
        
        CGFloat space = ZCChatMarginHSpace;
        if(showType == 1 || showType == 2){
            space =  ZCChatMarginHSpace + ZCChatMarginVSpace + 30;
        }
        _layoutChatBgPadingLeft = sobotLayoutPaddingLeft(space, iv, self.contentView);
        _layoutChatBgPadingLeft.priority = UILayoutPriorityDefaultHigh;
        _layoutChatBgPadingRight = sobotLayoutPaddingRight(-space, iv, self.contentView);
        _layoutChatBgPadingRight.priority = UILayoutPriorityDefaultLow;
        [self.contentView addConstraint:_layoutChatBgPadingLeft];
        [self.contentView addConstraint:_layoutChatBgPadingRight];
        _layoutChatBgWidth = sobotLayoutEqualWidth(0, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:_layoutChatBgWidth];
        NSLayoutConstraint *lb = sobotLayoutPaddingBottom(-ZCChatMarginVSpace, iv, self.contentView);
        lb.priority = UILayoutPriorityDefaultLow;
        [self.contentView addConstraint:lb];
        
        iv;
    });
    
    _lblSugguest = ({
        SobotEmojiLabel *iv = [ZCChatBaseCell createRichLabel];
        iv.textInsets = UIEdgeInsetsMake(0, ZCChatPaddingHSpace, 0, ZCChatPaddingHSpace);
        [self.contentView addSubview:iv];
        _layoutSugguestBottom=sobotLayoutPaddingBottom(0, iv, self.ivBgView);
        [self.contentView addConstraint:_layoutSugguestBottom];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(0, iv, self.ivBgView)];
        _layoutSugguestWidth = sobotLayoutEqualWidth(0, iv, NSLayoutRelationEqual);
        _layoutSugguestHeight = sobotLayoutEqualHeight(0, iv, NSLayoutRelationEqual);
        iv.delegate = self;
        [self.contentView addConstraint:_layoutSugguestWidth];
        [self.contentView addConstraint:_layoutSugguestHeight];
        
        iv;
    });
    
    _btnReSend = ({
        UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
        [iv setBackgroundColor:[UIColor clearColor]];
        iv.layer.cornerRadius=3;
        iv.layer.masksToBounds=YES;
        [self.contentView addSubview:iv];
        iv.hidden=YES;
        
        [iv addTarget:self action:@selector(clickReSend:) forControlEvents:UIControlEventTouchUpInside];
        // 只可能在右边
        [self.contentView addConstraint:sobotLayoutPaddingTop(ZCChatMarginVSpace, iv, _ivBgView)];
        [self.contentView addConstraint:sobotLayoutMarginRight(-14, iv, _ivBgView)];
        [self.contentView addConstraints:sobotLayoutSize(20, 20, iv, NSLayoutRelationEqual)];
        
        iv;
    });
    
    // 2.7.4新增 2.8.0 改成文字
    _leaveIcon = ({
        UILabel *iv = [[UILabel alloc]init];
    //        _leaveIcon = ZCSTLocalString(@"留言消息");
        iv.text = SobotKitLocalString(@"留言消息");
        iv.textColor = [ZCUIKitTools zcgetRobotBtnBgColor];
        iv.font = SobotFont12;
        [iv setTextAlignment:NSTextAlignmentRight];
        [self.contentView addSubview:iv];
        iv.hidden = YES;
        // 只可能在右边
        [self.contentView addConstraint:sobotLayoutEqualCenterY(0, iv, self.ivBgView)];
        [self.contentView addConstraint:sobotLayoutMarginRight(-10, iv, _ivBgView)];
        [self.contentView addConstraints:sobotLayoutSize(90, 24, iv, NSLayoutRelationEqual)];
        iv;
    });
    
    _btnTurnUser =({
        UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
        [iv setBackgroundColor:UIColorFromModeColor(SobotColorBgMainDark2)];
        [iv setTitle:SobotKitLocalString(@"转人工") forState:UIControlStateNormal];
        iv.tag = ZCChatCellClickTypeConnectUser;
        if([SobotUITools getSobotThemeMode] != SobotThemeMode_Dark){
//            iv.layer.borderColor = UIColorFromModeColor(SobotColorYellow).CGColor;
            
            iv.layer.borderColor = [ZCUIKitTools zcgetCommentButtonLineColor].CGColor;
        }
        
        iv.layer.cornerRadius = 15.0f;
        iv.layer.borderWidth = 0.75f;
        iv.layer.masksToBounds = YES;
        
        [iv setImage:SobotKitGetImage(@"icon_fast_transfer") forState:UIControlStateNormal];
        [iv setImage:SobotKitGetImage(@"icon_fast_transfer") forState:UIControlStateHighlighted];
        iv.imageEdgeInsets = UIEdgeInsetsMake(0,10.0, 0, 0);
        iv.titleEdgeInsets = UIEdgeInsetsMake(0, 15.0, 0, 0);
        NSString *lan = [ZCLibClient getZCLibClient].libInitInfo.absolute_language;
        if(sobotIsNull(lan)){
            lan = sobotGetLanguagePrefix();
        }
        
        if ([sobotConvertToString(lan) hasPrefix:@"ar"]) {
            iv.imageEdgeInsets = UIEdgeInsetsMake(0,0, 0, 10);
            iv.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15);
        }
        
        
        [iv.titleLabel setFont:SobotFont14];
        [iv setTitleColor:UIColorFromModeColor(SobotColorTextMain) forState:UIControlStateNormal];
        [iv addTarget:self action:@selector(connectWithStepOnWithTheTop:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:iv];
        iv.hidden=YES;
        
        // 只会在左边
        _layoutTurnTop = sobotLayoutMarginTop(ZCChatMarginVSpace, iv, _ivBgView);
        _layoutTurnHeight = sobotLayoutEqualHeight(30, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:_layoutTurnTop];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(0, iv, _ivBgView)];
        [self.contentView addConstraint:sobotLayoutEqualWidth(100, iv, NSLayoutRelationEqual)];
        
        NSLayoutConstraint *layotBottom = sobotLayoutPaddingBottom(-ZCChatMarginVSpace, iv, self.contentView);
        layotBottom.priority = UILayoutPriorityDefaultHigh;
        [self.contentView addConstraint:layotBottom];
        
        [self.contentView addConstraint:_layoutTurnHeight];
        _layoutTurnHeight.constant = 0;
        _layoutTurnTop.constant = 0;
        iv;
    });
    
    
    _btnStepOn = ({
        UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
        iv.backgroundColor =UIColorFromModeColor(SobotColorBgMainDark2);
        iv.layer.cornerRadius = 16.0f;
        iv.layer.shadowOpacity= 1;
        iv.layer.shadowColor = UIColorFromModeColorAlpha(SobotColorTextMain, 0.15).CGColor;
        iv.layer.shadowOffset = CGSizeZero;//投影偏移
        iv.layer.shadowRadius = 2;
        
        //        [_btnStepOn setTitle:@"无用" forState:UIControlStateNormal]; zcicon_useless_nol zcicon_useless_sel
        iv.tag = ZCChatCellClickTypeStepOn;
    //        [_btnStepOn.titleLabel setFont:[ZCUITools zcgetListKitDetailFont]];
        [iv setContentMode:UIViewContentModeRight];
        [iv setImage:SobotKitGetImage(@"zcicon_useless_nol") forState:UIControlStateNormal];
        [iv setImage:SobotKitGetImage(@"zcicon_useless_sel") forState:UIControlStateHighlighted];
        [iv setImage:SobotKitGetImage(@"zcicon_useless_sel") forState:UIControlStateSelected];
        [iv addTarget:self action:@selector(connectWithStepOnWithTheTop:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:iv];
        iv.hidden=YES;
        
        // 只会在左边
        _layoutSetOnHeight = sobotLayoutEqualHeight(32, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:_layoutSetOnHeight];
        [self.contentView addConstraint:sobotLayoutEqualWidth(32,iv, NSLayoutRelationEqual)];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(0, iv, self.ivBgView)];
        [self.contentView addConstraint:sobotLayoutMarginLeft(ZCChatMarginVSpace, iv, _ivBgView)];
        iv;
    });
    
    _btnTheTop = ({
        UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
    //        [_btnTheTop setBackgroundColor:[UIColor clearColor]];
        [iv setContentMode:UIViewContentModeRight];
        iv.backgroundColor = UIColorFromModeColor(SobotColorBgMainDark2);
    //        [_btnTheTop.titleLabel setFont:[ZCUITools zcgetListKitDetailFont]];
        iv.layer.cornerRadius = 16.0f;
        iv.layer.shadowOpacity= 1;
        iv.layer.shadowColor = UIColorFromModeColorAlpha(SobotColorTextMain, 0.15).CGColor;
        iv.layer.shadowOffset = CGSizeZero;//投影偏移
        iv.layer.shadowRadius = 2;
        
        [iv setImage:SobotKitGetImage(@"zcicon_useful_nol") forState:UIControlStateNormal];
        [iv setImage:SobotKitGetImage(@"zcicon_useful_sel") forState:UIControlStateHighlighted];
        [iv setImage:SobotKitGetImage(@"zcicon_useful_sel") forState:UIControlStateSelected];
        iv.tag = ZCChatCellClickTypeTheTop;
        [iv addTarget:self action:@selector(connectWithStepOnWithTheTop:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:iv];
        iv.hidden=YES;
        
        _layoutTheTopHeight = sobotLayoutEqualHeight(32, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:_layoutTheTopHeight];
        
        _layoutSetOnSpace = sobotLayoutMarginBottom(-ZCChatMarginVSpace, iv, _btnStepOn);
        [self.contentView addConstraint:_layoutSetOnSpace];
        [self.contentView addConstraint:sobotLayoutEqualWidth(32,iv, NSLayoutRelationEqual)];
//        [self.contentView addConstraint:sobotLayoutMarginTop(0, iv, _ivBgView)];
        [self.contentView addConstraint:sobotLayoutMarginLeft(ZCChatMarginVSpace, iv, _ivBgView)];
        iv;
    });
    
    _activityView=({
        UIActivityIndicatorView *iv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.contentView addSubview:iv];
        [self.contentView addConstraint:sobotLayoutEqualCenterX(0, iv, _btnReSend)];
        [self.contentView addConstraint:sobotLayoutEqualCenterY(0, iv, _btnReSend)];
        iv;
    });
    _ivLayerView = [[UIImageView alloc] init];
    self.userInteractionEnabled=YES;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(doLongPress:)];
    self.ivBgView.userInteractionEnabled = YES;
    [self.ivBgView addGestureRecognizer:longPress];
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
    _ivHeader.hidden = NO;
    if(self.isRight){
        if(_ivHeader && !_ivHeader.isHidden){
            _layoutAvatarLeft.priority = UILayoutPriorityDefaultLow;
            _layoutAvatarRight.priority = UILayoutPriorityDefaultHigh;
        }else{
            [self.contentView removeConstraint:self.layoutAvatarEW];
            [self.contentView removeConstraint:self.layoutAvatarEW];
            self.layoutAvatarEW = sobotLayoutEqualWidth(0, self.ivHeader, NSLayoutRelationEqual);
            self.layoutAvatarEH = sobotLayoutEqualHeight(0, self.ivHeader, NSLayoutRelationEqual);
            [self.contentView addConstraint:self.layoutAvatarEW];
            [self.contentView addConstraint:self.layoutAvatarEH];
        }
        
        _layoutChatBgPadingLeft.priority = UILayoutPriorityDefaultLow;
        _layoutChatBgPadingRight.priority = UILayoutPriorityDefaultHigh;
        
        CGFloat space = ZCChatMarginHSpace;
//        if(self.tempModel.isShowSenderFlag){
//            space = ZCChatMarginHSpace + ZCChatMarginVSpace + 30;
//
//        }
        _layoutChatBgPadingRight.constant = - space;
        _layoutNameLeft.constant = space;
        _layoutNameRight.constant = -space;
    }else{
        if(_ivHeader && !_ivHeader.isHidden){
            _layoutAvatarRight.priority = UILayoutPriorityDefaultLow;
            _layoutAvatarLeft.priority = UILayoutPriorityDefaultHigh;
        }else{
            [self.contentView removeConstraint:self.layoutAvatarEW];
            [self.contentView removeConstraint:self.layoutAvatarEW];
            self.layoutAvatarEW = sobotLayoutEqualWidth(0, self.ivHeader, NSLayoutRelationEqual);
            self.layoutAvatarEH = sobotLayoutEqualHeight(0, self.ivHeader, NSLayoutRelationEqual);
            [self.contentView addConstraint:self.layoutAvatarEW];
            [self.contentView addConstraint:self.layoutAvatarEH];
        }
        
        _layoutChatBgPadingRight.priority = UILayoutPriorityDefaultLow;
        _layoutChatBgPadingLeft.priority = UILayoutPriorityDefaultHigh;
        
        
        CGFloat space = ZCChatMarginHSpace;
        if([ZCUICore getUICore].getLibConfig.showFace){
            space = ZCChatMarginHSpace + ZCChatMarginVSpace + 30;
        }
        
        _layoutChatBgPadingLeft.constant = space;
        _layoutNameLeft.constant = space;
        _layoutNameRight.constant = -space;
    }
    
    if(self.tempModel.senderType != 0 ){
        _layoutNameTop.constant = ZCChatMarginVSpace - ZCChatCellItemSpace;
        _ivHeader.hidden = NO;
        NSString *senderName = sobotConvertToString(self.tempModel.senderName);
        if(sobotConvertToString(self.tempModel.servantName).length > 0){
            senderName = sobotConvertToString(self.tempModel.servantName);
        }
        if(senderName.length > 0 && !_lblNickName.isHidden){
            _layoutNameTop.constant = ZCChatMarginVSpace;
            [_lblNickName setText:senderName];
        }
    }else{
        _layoutNameTop.constant = ZCChatMarginVSpace - ZCChatCellItemSpace;
        [_lblNickName setText:@""];
        _ivHeader.hidden = YES;
    }
    
    if(!self.tempModel.isShowSenderFlag){
        _ivHeader.hidden = YES;
        [_lblNickName setText:@""];
        _layoutNameTop.constant = ZCChatMarginVSpace - ZCChatCellItemSpace;
    }
}


+(SobotEmojiLabel *) createRichLabel{
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
        _layoutTimeTop.constant = ZCChatMarginVSpace;
        _lblTime.hidden=NO;
    }
    CGFloat headerSpace = 0;
    
    UIImage *placeHoldImage = nil;
    // 0,自己，1机器人，2客服
    if(message.senderType==0){
        [_lblNickName setTextAlignment:NSTextAlignmentRight];
        _isRight = YES;
        _contentPadding = UIEdgeInsetsMake(ZCChatPaddingVSpace, -ZCChatPaddingVSpace, ZCChatPaddingHSpace, -ZCChatPaddingHSpace);
        placeHoldImage = SobotKitGetImage(@"zcicon_useravatar_nol");
        [_lblSugguest setTextColor:[ZCUIKitTools zcgetRightChatTextColor]];
        [_lblSugguest setLinkColor:[ZCUIKitTools zcgetChatRightlinkColor]];
        headerSpace = 0;
    }else{
        _isRight = NO;
        [_lblSugguest setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        [_lblSugguest setLinkColor:[ZCUIKitTools zcgetChatLeftLinkColor]];
        _contentPadding = UIEdgeInsetsMake(ZCChatPaddingVSpace, -ZCChatPaddingVSpace, ZCChatPaddingHSpace, -ZCChatPaddingHSpace);
        [_lblNickName setTextAlignment:NSTextAlignmentLeft];
        if(message.senderType == 1){
            placeHoldImage = SobotKitGetImage(@"zcicon_turnserver_nol");
        }else{
            placeHoldImage = SobotKitGetImage(@"zcicon_useravatart_girl");
        }
       
        if(!_ivHeader.hidden){
            headerSpace = 40;
        }
    }
    [self reSetBaseLayoutConstraint];
    
    // 减去左右
    self.maxWidth = self.viewWidth - 66 - ZCChatMarginHSpace - headerSpace - ZCChatPaddingHSpace*2;
    
    if(!_ivHeader.hidden){
        if(sobotConvertToString(message.servantFace).length > 0){
            [_ivHeader loadWithURL:[NSURL URLWithString:sobotConvertToString(message.servantFace)] placeholer:placeHoldImage];
        }else{
            [_ivHeader loadWithURL:[NSURL URLWithString:sobotConvertToString(message.senderFace)] placeholer:placeHoldImage];
        }
    }
    
    // 普通消息，添加设置坐标
    CGSize s = CGSizeZero;
    _lblSugguest.text = @"";
    if(message.msgType != SobotMessageTypeTipsText){
        NSString *text = [message getModelDisplaySugestionText];
        // 不是多伦的模版4，不是热点问题
        if((sobotConvertToString(text).length > 0 && message.richModel.type != SobotMessageTypeHotGuide && message.richModel.type !=SobotMessageRichJsonTypeLoop) || (message.richModel.type ==SobotMessageRichJsonTypeLoop && message.richModel.richContent.templateId==4)){
            
            _layoutSugguestBottom.constant = -ZCChatPaddingVSpace;
            [ZCChatBaseCell configHtmlText:text label:_lblSugguest right:self.isRight];
            s = [_lblSugguest preferredSizeWithMaxWidth:self.maxWidth];
        }else{
            if(message.msgType==SobotMessageTypeVideo || message.msgType== SobotMessageTypePhoto){
                _layoutSugguestBottom.constant = 0;
            }else{
                _layoutSugguestBottom.constant = -(ZCChatPaddingVSpace - ZCChatCellItemSpace);
            }
        }
    }
    _lblSugguest.hidden = NO;
    _layoutSugguestHeight.constant = s.height;
    _layoutSugguestWidth.constant = s.width;
}


#pragma mark 最后设置气泡的位置
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
    
    if(_layoutSugguestWidth.constant < size.width){
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
    
    _leaveIcon.hidden = YES;
    _btnReSend.hidden = YES;
    _btnTheTop.hidden = YES;
    _btnStepOn.hidden = YES;
    _btnTurnUser.hidden = YES;
    _layoutTurnTop.constant = 0;
    _layoutTurnHeight.constant = 0;
    
    _layoutSetOnHeight.constant = 0;
    _layoutSetOnSpace.constant = 0;
    _layoutTheTopHeight.constant = 0;
    
    // 自己、设置发送状态
    if(_tempModel.senderType==0){
        _layoutTurnTop.constant = 0;
        _layoutTurnHeight.constant = 0;
        
        if(_tempModel.sendStatus==1){
            if(self.tempModel.msgType != SobotMessageTypePhoto && self.tempModel.msgType != SobotMessageTypeFile){
                // 发送文件时，不显示发送的动画，由发送进度代替,
                [_activityView stopAnimating];
                _activityView.hidden = YES;
            }else{
                [self.btnReSend setHidden:NO];
                _activityView.hidden = NO;
                _activityView.center = self.btnReSend.center;
                [_activityView startAnimating];
            }
        }else if(_tempModel.sendStatus==2){
            [self.btnReSend setHidden:NO];
            [self.btnReSend setBackgroundColor:[UIColor clearColor]];
            [self.btnReSend setImage:SobotKitGetImage(@"zcicon_send_fail") forState:UIControlStateNormal];
            _activityView.hidden=YES;
            [_activityView stopAnimating];
        }
        // 是否是用户发送的 留言转离线消息
        if (_tempModel.leaveMsgFlag == 1) {
            _leaveIcon.hidden = NO;
        }
    }else{
        if(![self getZCLibConfig].isArtificial){
            if(self.tempModel.showTurnUser){
                _btnTurnUser.hidden = NO;
                _layoutTurnTop.constant = 5;
                _layoutTurnHeight.constant = 30;
            }
            
            // 是否显示踩/赞
            if(self.tempModel.senderType == 1){
                
                /**
                 机器人评价
                 0，不处理，1新添加(可赞、可踩)，2已赞，3已踩，4 超时下线之后不能在评价
                 */
                if(self.tempModel.commentType == 4 || self.tempModel.commentType == 1){
                    _layoutSetOnSpace.constant = -ZCChatMarginVSpace;
                    _layoutSetOnHeight.constant = 32;
                    _layoutTheTopHeight.constant = 32;
                    
                    _btnTheTop.hidden = NO;
                    _btnStepOn.hidden = NO;
                    _btnTheTop.selected = NO;
                    _btnStepOn.selected = NO;
                    
                    
                    if(size.height < 64 && _layoutSugguestHeight.constant == 0){
                        _layoutSugguestHeight.constant = 64+ZCChatCellItemSpace - size.height - ZCChatPaddingVSpace*2;
                    }
                }
                if(self.tempModel.commentType == 2){
                    _btnTheTop.hidden = NO;
                    _layoutSetOnSpace.constant = 0;
                    _layoutTheTopHeight.constant = 32;
                    _btnTheTop.selected = YES;
                }
                if(self.tempModel.commentType == 3){
                    _layoutSetOnSpace.constant = 0;
                    _layoutSetOnHeight.constant = 32;
                    _btnStepOn.hidden = NO;
                    _btnStepOn.selected = YES;
                }
            }
        }
    }
    
    [self.contentView layoutIfNeeded];
   
//    //设置尖角
//    // 此处设置后，图片的大小与实际frame不一致
//    [_ivLayerView setImage:bgImage];
//    [self.ivLayerView setFrame:self.ivBgView.bounds];
//    CALayer *layer              = self.ivLayerView.layer;
//    layer.frame                 = (CGRect){{0,0},self.ivLayerView.layer.frame.size};
//    self.ivBgView.layer.mask = layer;
        
    [self layoutIfNeeded];

    if (self.isRight) {
        // 处理右侧聊天气泡的 渐变色
        [_ivBgView setBackgroundColor:[ZCUIKitTools zcgetRobotBackGroundColorWithSize:CGSizeMake(self.ivBgView.bounds.size.width, self.ivBgView.bounds.size.height * 2)]];
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
        }else if([url hasPrefix:@"sobot://continueWaiting"]){
            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
                [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemContinueWaiting text:@"" obj:@""];
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
    
    ZCVideoPlayer *player = [[ZCVideoPlayer alloc] initWithFrame:sobotGetCurWindow().bounds withShowInView:sobotGetCurWindow() url:[NSURL URLWithString:msg] Image:nil];
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
    NSString *str = [SobotUITools sobotReadCoderURLStrDetectorWith:_imageViewer.currentImage];
    if (str) {
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
        //        msg = @"保存失败";
    }else{
        msg = SobotKitLocalString(@"已保存到系统相册");
        [[SobotToast shareToast] showToast:msg position:SobotToastPositionCenter Image:SobotKitGetImage(@"zcicon_successful")];
    }
    
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
-(void)getLinkValues:(NSString *) link result:(void(^)(NSString *title,NSString *desc,NSString *icon)) block{
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
            if(title.length > 0){
                [SobotCache addObject:data forKey:[NSString stringWithFormat:@"%@%@",Sobot_CacheURLHeader,sobotConvertToString(link)]];
            }
            
            if(block){
                block(title,desc,imgUrl);
            }
        }
    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
        [SobotHtmlCore websiteFilter:sobotConvertToString(link) result:^(NSString * _Nonnull url, NSString * _Nonnull iconUrl, NSString * _Nonnull title, NSString * _Nonnull desc, NSDictionary * _Nullable dict) {
            
            if(sobotConvertToString(title).length > 0){
                [SobotCache addObject:@{@"title":title,@"desc":desc,@"imgUrl":iconUrl} forKey:[NSString stringWithFormat:@"%@%@",Sobot_CacheURLHeader,sobotConvertToString(link)]];
            }
            
            if(block){
                block(sobotConvertToString(item[@"title"]),sobotConvertToString(item[@"desc"]),sobotConvertToString(@""));
            }
        }];
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

#pragma mark - gesture delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
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
    
    if(self.tempModel.msgType != SobotMessageTypeText){
        SobotView *iv = recognizer.view;
        if([iv isKindOfClass:[SobotView class]]){
            copyUrl = iv.objTag;
        }
    }else{
        copyUrl = self.tempModel.richModel.content;
    }
    
    if(sobotConvertToString(copyUrl).length == 0){
        [self didChangeBgColorWithsIsSelect:NO];
        return;
    }
    
    [self didChangeBgColorWithsIsSelect:YES];
    
    
    [self becomeFirstResponder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuControllerWillHideWithClick) name:UIMenuControllerDidHideMenuNotification object:nil];
    
    _menuController = [UIMenuController sharedMenuController];
    UIMenuItem *copyItem = [[UIMenuItem alloc]initWithTitle:SobotKitLocalString(@"复制") action:@selector(doCopy)];
    [_menuController setMenuItems:@[copyItem]];
    [_menuController setArrowDirection:(UIMenuControllerArrowDefault)];
    // 设置frame cell的位置
    CGRect tf     = _ivBgView.frame;
    CGRect rect = CGRectMake(tf.origin.x, tf.origin.y, tf.size.width, 1);
    
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
    
    if (isSelected) {
        if (self.isRight) {
            [self.ivBgView setBackgroundColor:[ZCUIKitTools zcgetRightChatSelectdeColor]];
        }else{
            [self.ivBgView setBackgroundColor:[ZCUIKitTools zcgetLeftChatSelectedColor]];
        }
    }else{
        if (self.isRight) {
            // 右边气泡绿色
//            [self.ivBgView setBackgroundColor:[ZCUIKitTools zcgetRightChatColor]];
            [_ivBgView setBackgroundColor:[ZCUIKitTools zcgetRobotBackGroundColorWithSize:CGSizeMake(self.ivBgView.bounds.size.width, self.ivBgView.bounds.size.height * 2)]];
        }else{
            // 左边的气泡颜色
            [self.ivBgView setBackgroundColor:[ZCUIKitTools zcgetLeftChatColor]];
        }
        if(_menuController){
            [_menuController setTargetRect:CGRectMake(0, 0, 0, 0) inView:self];
        }
    }
    [self.ivBgView setNeedsDisplay];
    
}

//复制
-(void)doCopy{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:sobotConvertToString(copyUrl)];
    [[SobotToast shareToast] showToast:SobotKitLocalString(@"复制成功！") duration:1.0f position:SobotToastPositionCenter];
    [self didChangeBgColorWithsIsSelect:NO];
}


#pragma mark - UIMenuController 必须实现的两个方法
- (BOOL)canBecomeFirstResponder{
    return YES;
}

/*
 *  根据action,判断UIMenuController是否显示对应aciton的title
 */
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (action == @selector(doCopy) ) {
        return YES;
    }
    return NO;
}

@end
