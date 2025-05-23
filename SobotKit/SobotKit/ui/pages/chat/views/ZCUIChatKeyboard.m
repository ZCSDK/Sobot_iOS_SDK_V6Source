//
//  ZCUIChatKeyboard.m
//  SobotKit
//
//  Created by zhangxy on 2022/9/1.
//

#import "ZCUIChatKeyboard.h"
#import "ZCUIKitTools.h"
#import "ZCUICore.h"
#import "ZCVideoViewController.h"
#import "ZCAutoListView.h"
#import "SobotSatisfactionView.h"

#import "ZCLibCusMenu.h"
#import "EmojiBoardView.h"
#import "ZCStatusLab.h"
#import "ZCObjButton.h"
#import "SobotImageButton.h"
#define BottomButtonItemHSpace 20
#define BottomButtonItemVSpace 8
#define SobotKeyboardBtnWidth 40

#define EmojiViewHeight 270 //  2.8.0  270
#define EmojiViewHorizontalHeight 120

typedef NS_ENUM(NSInteger, BottomButtonClickTag) {
   /** 转人工 */
   BUTTON_CONNECT_USER   = 2,
   /** 相机相册 */
   BUTTON_ADDPHOTO       = 3,
   /** 录语音 */
   BUTTON_ADDVOICE       = 4,
   /** 转人工按钮的tag值（2中状态下的图标）*/
   BUTTON_ToKeyboard     = 5,
   /** 新会话（原重新接入）*/
   BUTTON_RECONNECT_USER = 7,
   /** 满意度 */
   BUTTON_SATISFACTION   = 8,
   /** 留言 */
   BUTTON_LEAVEMESSAGE   = 9,
   /** 更多 */
   BUTTON_ADDMORE        = 10,
   /** 表情键盘 */
   BUTTON_ADDFACEVIEW    = 11,
    
    // 相机
    BUTTON_AddPhotoCamera      = 12,
    
    // 添加文件
    BUTTON_AddDocumentFile     = 13,
    
    // 添加位置
    BUTTON_AddLocation     = 14,
    /** 录音  */  // 评价使用了6
    BUTTON_VoiceToRECORD  = 15,
    // 视频
    BUTTON_AddVideo = 16,
};


@interface ZCUIChatKeyboard()<UITextViewDelegate,UIGestureRecognizerDelegate,UIDocumentPickerDelegate,EmojiBoardDelegate,SobotKeyboardRecordDelegate,ZCAutoListViewDelegate>{
    CGFloat startTableY;
    int allSubMenuSize;
    
    
    // 创建更多菜单后，动态计算出，不在是固定高度
    CGFloat countMoreHeight;
    
    BOOL showRichKeyboard;
    
}

// 整个聊天页面View，即ZCChatView
@property (nonatomic , strong) UIView *ppView;



/** 聊天页中UITableView 用于界面键盘高度处理 */
@property (nonatomic,strong) UITableView *zc_listTable;

@property (nonatomic,strong) ZCStatusLab *robotVioceTipLabel;

// 当前引用消息
@property (nonatomic,strong) SobotChatMessage *referenceMessage;


@property (nonatomic,strong) UIScrollView *zc_moreView;
@property (nonatomic,strong) UIPageControl *facePageControl;

@property (nonatomic,strong) EmojiBoardView *emojiView;
@property (nonatomic,strong) UITapGestureRecognizer *tapRecognizer;


// 当显示表情或更多键盘时，bottom底部线条
@property (nonatomic,strong) UIImageView *bottomlineView;
@property (nonatomic,strong) UIButton * _Nullable btnVoicePress;


@property (nonatomic,strong) UIView * referenceView;
@property (nonatomic,strong) UILabel *labReferencMessage;
@property (nonatomic,strong) UIButton *btnClearReferenceMsg;
@property (nonatomic,strong) NSLayoutConstraint * layoutReferenceH;
@property (nonatomic,strong) NSLayoutConstraint * layoutReferenceBottom;


// 转人工按钮，可变约束
//@property (nonatomic,strong) NSLayoutConstraint *btnConnectUserConsLeft;
//@property (nonatomic,strong) NSLayoutConstraint *btnConnectUserConsWidth;

// 切换语言按钮，可变约束
@property (nonatomic,strong) NSLayoutConstraint *btnVoiceConsLeft;
@property (nonatomic,strong) NSLayoutConstraint *btnVoiceConsWidth;

// 表情按钮，可变约束
@property (nonatomic,strong) NSLayoutConstraint *btnFaceConsRight;
@property (nonatomic,strong) NSLayoutConstraint *btnFaceConsWidth;

// 更多按钮 可变约束
@property (nonatomic,strong) NSLayoutConstraint *btnMoreConsRight;
@property (nonatomic,strong) NSLayoutConstraint *btnMoreConsWidth;

// 底部输入框父view底部间距
@property (nonatomic,strong) NSLayoutConstraint *viewBottomConsSpace;
// 底部输入框父view高度，输入框高度变化时使用
// 4.1.0版本去除此约束，有chat_textView的高度控制整体高度
//@property (nonatomic,strong) NSLayoutConstraint *viewBottomConsHeight;

// 输入框高度
@property (nonatomic,strong) NSLayoutConstraint *chatTextConsHeight;

// 更多键盘高度
@property (nonatomic,strong) NSLayoutConstraint *viewMoreConsHeight;

// 表情键盘高度
@property (nonatomic,strong) NSLayoutConstraint *viewEmojiConsHeight;

// 重建会话/0或104
@property (nonatomic,strong) NSLayoutConstraint *viewReConnectConsHeight;

@property (nonatomic,strong) ZCVideoViewController *videoVC;// 临时变量 解决没有开启权限 进入拍照页面

@end

@implementation ZCUIChatKeyboard

-(id)initConfigView:(UIView *)unitView table:(UITableView *)listTable fastView:(UIView *)fastView{
    self = [self init];
    if(self){
        _ppView       = unitView;
        _zc_listTable = listTable;
        startTableY   = listTable.frame.origin.y;
        
        self.fastView = fastView;
        
        _zc_moreView = [[UIScrollView  alloc] init];
        _zc_moreView.pagingEnabled = YES;
        _zc_moreView.showsHorizontalScrollIndicator = NO;
        _zc_moreView.showsVerticalScrollIndicator = YES;
        _zc_moreView.delegate = self;
        _zc_moreView.backgroundColor = UIColor.clearColor;
        [_ppView addSubview:_zc_moreView];
                
        //添加PageControl
        _facePageControl = [[UIPageControl alloc]initWithFrame:CGRectZero];
        [_facePageControl addTarget:self
                             action:@selector(pageChange:)
                   forControlEvents:UIControlEventValueChanged];
        _facePageControl.pageIndicatorTintColor=[UIColor lightGrayColor];
//        _facePageControl.currentPageIndicatorTintColor=[UIColor darkGrayColor];
        _facePageControl.currentPageIndicatorTintColor = [ZCUIKitTools zcgetServerConfigBtnBgColor];
//        if([SobotUITools getSobotThemeMode] == SobotThemeMode_Dark){
//            _facePageControl.pageIndicatorTintColor = [ZCUIKitTools zcgetTextPlaceHolderColor];
//        }else{
//            _facePageControl.pageIndicatorTintColor = UIColorFromModeColor(SobotColorBgMainDark1);
//        }
        _facePageControl.currentPage = 0;
        [_ppView addSubview:_facePageControl];
        _facePageControl.hidden = YES;
                
        _emojiView = [[EmojiBoardView alloc] initWithBoardHeight:EmojiViewHeight pW:[self getSourceViewWidth]];
        _emojiView.backgroundColor = UIColor.clearColor;
        _emojiView.delegate = self;
        [_ppView addSubview:_emojiView];
        [self zc_bottomView];
        
        // 顶部线条
        UIImageView *lineView=[[UIImageView alloc] init];
        lineView.backgroundColor = [ZCUIKitTools zcgetChatBottomLineColor];
//        lineView.backgroundColor = [UIColor redColor];
        [_zc_bottomView addSubview:lineView];
        [_zc_bottomView addConstraint:sobotLayoutPaddingLeft(0, lineView, _zc_bottomView)];
        [_zc_bottomView addConstraint:sobotLayoutPaddingRight(0, lineView, _zc_bottomView)];
        [_zc_bottomView addConstraint:sobotLayoutPaddingTop(0, lineView, _zc_bottomView)];
        [_zc_bottomView addConstraint:sobotLayoutEqualHeight(1.0f, lineView, NSLayoutRelationEqual)];
        
        _referenceView = [[UIView alloc] init];
        _referenceView.backgroundColor = UIColorFromKitModeColor(SobotColorBgF5);
        _referenceView.layer.cornerRadius = 4.0f;
        [_zc_bottomView addSubview:_referenceView];
        [_zc_bottomView addConstraint:sobotLayoutPaddingLeft(16, _referenceView, _zc_bottomView)];
        [_zc_bottomView addConstraint:sobotLayoutPaddingRight(-16, _referenceView, _zc_bottomView)];
        
        _layoutReferenceBottom = sobotLayoutPaddingBottom(0, _referenceView, _zc_bottomView);
        [_zc_bottomView addConstraint:_layoutReferenceBottom];
        _layoutReferenceH = sobotLayoutEqualHeight(0, _referenceView, NSLayoutRelationEqual);
        [_zc_bottomView addConstraint:_layoutReferenceH];
        
        _zc_chatTextView = [[ZCUIPlaceHolderTextView alloc] init];
//        _zc_chatTextView.layer.cornerRadius                      = 16;
//        _zc_chatTextView.layer.masksToBounds                     = YES;
//        _zc_chatTextView.layer.borderColor                       = [ZCUIKitTools zcgetChatBottomLineColor].CGColor;
        if (iOS7) {
            // 关闭UITextView 非连续布局属性
            // 添加如下代码，会有：UITextView 0x7ff34a967c00 is switching to TextKit 1 compatibility mode because its layoutManager was accessed. Break on void _UITextViewEnablingCompatibilityMode(UITextView *__strong, BOOL) to debug.
            _zc_chatTextView.layoutManager.allowsNonContiguousLayout = false;
            _zc_chatTextView.layoutManager.usesFontLeading = false;
        }
        _zc_chatTextView.font                                    = [ZCUIKitTools zcgetListKitTitleFont];
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        // UI觉的小 改大一点
        paragraphStyle.lineSpacing = 5;//[ZCUIKitTools zcgetChatLineSpacing];// 字体的行间距
        NSDictionary *attributes = @{
                                         NSFontAttributeName:[ZCUIKitTools zcgetListKitTitleFont],
                                         NSParagraphStyleAttributeName:paragraphStyle
                                         };
        _zc_chatTextView.typingAttributes = attributes;
        _zc_chatTextView.textColor                               = [ZCUIKitTools zcgetChatTextViewColor];
        _zc_chatTextView.returnKeyType                           = UIReturnKeySend;
        _zc_chatTextView.enablesReturnKeyAutomatically = YES;

        _zc_chatTextView.autoresizesSubviews                     = YES;
        _zc_chatTextView.delegate                                = self;
        _zc_chatTextView.textAlignment                           = NSTextAlignmentLeft;
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            _zc_chatTextView.textAlignment = NSTextAlignmentRight;
        }
        [_zc_chatTextView setBackgroundColor:UIColor.clearColor];
        [_zc_chatTextView setPlaceholderColor:UIColorFromModeColor(SobotColorTextSub1)];
        _zc_chatTextView.delegate = self;
        _zc_chatTextView.textContainerInset = UIEdgeInsetsMake(10, 8, 10, 0);
//        _zc_chatTextView.textContainerInset = UIEdgeInsetsMake(10, 0, 10, 0);
        [_zc_bottomView addSubview:_zc_chatTextView];
        _zc_chatTextView.placeholederFont = SobotFont14;
//        _zc_chatTextView.tintColor = UIColor.redColor;// UIColorFromKitModeColorAlpha(SobotColorTextMain, 0.1);
        _zc_chatTextView.indicatorStyle = UIScrollViewIndicatorStyleDefault;  
        //        _btnConnectUser = [self createButton:BUTTON_CONNECT_USER];
//        [_zc_bottomView addSubview:_btnConnectUser];
        
        _btnVoice = [self createButton:BUTTON_ADDVOICE];
        [_zc_bottomView addSubview:_btnVoice];
        
        _btnFace = [self createButton:BUTTON_ADDFACEVIEW];
        [_zc_bottomView addSubview:_btnFace];
        
        _btnMore = [self createButton:BUTTON_ADDMORE];
        [_zc_bottomView addSubview:_btnMore];
        
        _btnVoicePress = [self createButton:BUTTON_VoiceToRECORD];
        _btnVoicePress.userInteractionEnabled = YES;
        _btnVoicePress.layer.cornerRadius     = 2;
        _btnVoicePress.layer.masksToBounds    = YES;
//        _zc_pressedButton.layer.borderWidth      = 0.75f;
        //        _btnVoicePress.layer.borderColor      = [ZCUIKitTools zcgetChatBottomLineColor].CGColor;
        _btnVoicePress.titleLabel.font        = [ZCUIKitTools zcgetVoiceButtonFont];
        [_btnVoicePress setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [_btnVoicePress setTitle:SobotKitLocalString(@"按住 说话") forState:UIControlStateNormal];
        [_btnVoicePress setTitleColor:UIColorFromModeColor(SobotColorTextMain) forState:UIControlStateNormal];
//        [_btnVoicePress setBackgroundColor:UIColorFromKitModeColor(SobotColorBgF5)];
        
        [_btnVoicePress setBackgroundImage:[SobotImageTools sobotImageWithColor:UIColorFromKitModeColor(SobotColorBgMain)] forState:UIControlStateNormal];
        [_btnVoicePress setBackgroundImage:[SobotImageTools sobotImageWithColor:UIColorFromKitModeColor(SobotColorBgF5)] forState:UIControlStateSelected];
        [_btnVoicePress setBackgroundImage:[SobotImageTools sobotImageWithColor:UIColorFromKitModeColor(SobotColorBgF5)] forState:UIControlStateHighlighted];
        
        [_zc_bottomView addSubview:_btnVoicePress];
        _btnVoicePress.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        [_btnVoicePress addTarget:self action:@selector(btnTouchDown:) forControlEvents:UIControlEventTouchDown];
        [_btnVoicePress addTarget:self action:@selector(btnTouchDownRepeat:) forControlEvents:UIControlEventTouchDownRepeat];
        [_btnVoicePress addTarget:self action:@selector(btnTouchMoved:withEvent:) forControlEvents:UIControlEventTouchDragInside];
        [_btnVoicePress addTarget:self action:@selector(btnTouchMoved:withEvent:) forControlEvents:UIControlEventTouchDragOutside];
        [_btnVoicePress addTarget:self action:@selector(btnTouchMoved:withEvent:) forControlEvents:UIControlEventTouchDragEnter];
        [_btnVoicePress addTarget:self action:@selector(btnTouchEnd:withEvent:) forControlEvents:UIControlEventTouchUpInside];
        [_btnVoicePress addTarget:self action:@selector(btnTouchCancel:) forControlEvents:UIControlEventTouchCancel];
        [_btnVoicePress addTarget:self action:@selector(btnTouchCancel:) forControlEvents:UIControlEventTouchUpOutside];
        
        
        CGFloat spaceBottom = 10;
        CGFloat hSpace = 4;
        
        _btnVoiceConsLeft = sobotLayoutPaddingLeft(hSpace, _btnVoice, _zc_bottomView);
        _btnVoiceConsWidth = sobotLayoutEqualWidth(SobotKeyboardBtnWidth, _btnVoice, NSLayoutRelationEqual);
        [_zc_bottomView addConstraint:_btnVoiceConsLeft];
        [_zc_bottomView addConstraint:_btnVoiceConsWidth];
        [_zc_bottomView addConstraint:sobotLayoutEqualHeight(SobotKeyboardBtnWidth, _btnVoice, NSLayoutRelationEqual)];
//        [_zc_bottomView addConstraint:sobotLayoutPaddingBottom(-spaceBottom, _btnVoice, _zc_bottomView)];
        [_zc_bottomView addConstraint:sobotLayoutMarginBottom(-spaceBottom, _btnVoice, _referenceView)];
        
        [_zc_bottomView addConstraint:sobotLayoutPaddingTop(0, _btnMore, _btnVoice)];
        _btnMoreConsWidth = sobotLayoutEqualWidth(SobotKeyboardBtnWidth, _btnMore, NSLayoutRelationEqual);
        [_zc_bottomView addConstraint:_btnMoreConsWidth];
        [_zc_bottomView addConstraint:sobotLayoutEqualHeight(SobotKeyboardBtnWidth, _btnMore, NSLayoutRelationEqual) ];
        _btnMoreConsRight = sobotLayoutPaddingRight(-hSpace, _btnMore, _zc_bottomView) ;
        [_zc_bottomView addConstraint:_btnMoreConsRight];
        
        
        
        [_zc_bottomView addConstraint:sobotLayoutPaddingTop(0, _btnFace, _btnVoice)];
        _btnFaceConsRight = sobotLayoutMarginRight(0, _btnFace, _btnMore) ;
        _btnFaceConsWidth = sobotLayoutEqualWidth(SobotKeyboardBtnWidth, _btnFace, NSLayoutRelationEqual);
        [_zc_bottomView addConstraint:_btnFaceConsWidth];
        [_zc_bottomView addConstraint:sobotLayoutEqualHeight(SobotKeyboardBtnWidth, _btnFace, NSLayoutRelationEqual) ];
        [_zc_bottomView addConstraint:_btnFaceConsRight];
        
        CGFloat kx = (SobotKeyboardBtnWidth - 35)/2;
        _chatTextConsHeight = sobotLayoutEqualHeight(35, _zc_chatTextView, NSLayoutRelationEqual);
        _chatTextConsHeight.priority = UILayoutPriorityDefaultHigh;
        [_zc_bottomView addConstraint:_chatTextConsHeight];
        [_zc_bottomView addConstraint:sobotLayoutPaddingTop(spaceBottom+kx, _zc_chatTextView, _zc_bottomView)];
        [_zc_bottomView addConstraint:sobotLayoutMarginLeft(0, _zc_chatTextView, _btnVoice)];
        [_zc_bottomView addConstraint:sobotLayoutMarginRight(0, _zc_chatTextView, _btnFace)];
        [_zc_bottomView addConstraint:sobotLayoutMarginBottom(-kx-spaceBottom, _zc_chatTextView, _referenceView)];
        
        // 设置_btnVoicePress 与 chattext相同坐标
        [_zc_bottomView addConstraint:sobotLayoutPaddingTop(0, _btnVoicePress, _btnVoice)];
        [_zc_bottomView addConstraint:sobotLayoutMarginLeft(0, _btnVoicePress, _btnVoice)];
        [_zc_bottomView addConstraint:sobotLayoutMarginRight(0, _btnVoicePress, _btnFace)];
        [_zc_bottomView addConstraint:sobotLayoutEqualHeight(SobotKeyboardBtnWidth, _btnVoicePress, NSLayoutRelationEqual)];
        
        [_ppView addConstraint:sobotLayoutPaddingLeft(0, _zc_moreView, _ppView)];
        [_ppView addConstraint:sobotLayoutPaddingRight(0, _zc_moreView, _ppView)];
        [_ppView addConstraint:sobotLayoutPaddingBottom(0, _zc_moreView, _ppView)];
        _viewMoreConsHeight = sobotLayoutEqualHeight(0, _zc_moreView, NSLayoutRelationEqual);
        [_ppView addConstraint:_viewMoreConsHeight];
        
//        [_ppView addConstraints:sobotLayoutPaddingView(0, -10, 10, -10, _facePageControl, _ppView)];
        
        [_ppView addConstraint:sobotLayoutPaddingLeft(0, _emojiView, _ppView)];
        [_ppView addConstraint:sobotLayoutPaddingRight(0, _emojiView, _ppView)];
        [_ppView addConstraint:sobotLayoutPaddingBottom(0, _emojiView, _ppView)];
        _viewEmojiConsHeight = sobotLayoutEqualHeight(0, _emojiView, NSLayoutRelationEqual);
        [_ppView addConstraint:_viewEmojiConsHeight];
        
        
        _zc_reConnectView = [[UIView alloc] init];
        [_zc_reConnectView setBackgroundColor:[ZCUIKitTools zcgetChatBgBottomColor]];
        [_ppView addSubview:_zc_reConnectView];
        
        
        _viewReConnectConsHeight = sobotLayoutEqualHeight(0, _zc_reConnectView, NSLayoutRelationEqual);
        [_zc_reConnectView addConstraint:_viewReConnectConsHeight];
        [_ppView addConstraint:sobotLayoutPaddingLeft(0, _zc_reConnectView, _ppView)];
        [_ppView addConstraint:sobotLayoutPaddingRight(0, _zc_reConnectView, _ppView)];
        [_ppView addConstraint:sobotLayoutPaddingBottom(0, _zc_reConnectView, _ppView)];
        
        
        _bottomlineView = [[UIImageView alloc]init];
        _bottomlineView.backgroundColor = [ZCUIKitTools zcgetChatBottomLineColor];
        [_zc_bottomView addSubview:_bottomlineView];
        
        [_zc_bottomView addConstraint:sobotLayoutPaddingLeft(0, _bottomlineView, _zc_bottomView)];
        [_zc_bottomView addConstraint:sobotLayoutPaddingRight(0, _bottomlineView, _zc_bottomView)];
        [_zc_bottomView addConstraint:sobotLayoutPaddingBottom(0, _bottomlineView, _zc_bottomView)];
        [_bottomlineView addConstraint:sobotLayoutEqualHeight(1.0f, _bottomlineView,NSLayoutRelationEqual)];
        _bottomlineView.hidden = YES;
        
        [self createMoreItems];
        
        if([ZCUICore getUICore].kitInfo.isOpenRecord && [ZCUICore getUICore].kitInfo.isOpenRobotVoice){
            [self createVioceTipLabel];
        }
        
        _btnVoicePress.hidden = YES;
        // 设置按钮图片
        [self setItemButtonDefaultStatus];
        
        [self handleKeyboard];
        
        
        [[ZCUICore getUICore] setInputListener:self.zc_chatTextView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didRotate:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    }
    return self;
}

-(UIView *)zc_bottomView{
    if(!_zc_bottomView){
        _zc_bottomView = [[UIView alloc] init];
        [_zc_bottomView setBackgroundColor:[ZCUIKitTools zcgetChatBgBottomColor]];
        [_ppView addSubview:_zc_bottomView];
        
        _viewBottomConsSpace = sobotLayoutPaddingBottom(0, _zc_bottomView, _ppView);
        [_ppView addConstraint:sobotLayoutPaddingLeft(0, _zc_bottomView, _ppView)];
        [_ppView addConstraint:sobotLayoutPaddingRight(0, _zc_bottomView, _ppView)];
        [_ppView addConstraint:_viewBottomConsSpace];
//        _viewBottomConsHeight = sobotLayoutEqualHeight(BottomHeight, _zc_bottomView, NSLayoutRelationEqual);
//        [_ppView addConstraint:_viewBottomConsHeight];
    }
    return _zc_bottomView;
}

-(UIView *)createVioceTipLabel{
    if (!_robotVioceTipLabel) {
        _robotVioceTipLabel = [[ZCStatusLab alloc]init];
//        _vioceTipLabel.backgroundColor = UIColorFromRGBAlpha(0xa1a6b3, 0.9);
        _robotVioceTipLabel.backgroundColor = UIColorFromModeColorAlpha(SobotColorTextSub, 0.9);
        _robotVioceTipLabel.textColor = UIColorFromModeColor(SobotColorWhite);
        _robotVioceTipLabel.font = SobotFont12;
        _robotVioceTipLabel.textAlignment = NSTextAlignmentCenter;
        _robotVioceTipLabel.text = SobotKitLocalString(@"机器人咨询模式下，语音将自动转化为文字发送");
        [_ppView addSubview:_robotVioceTipLabel];
        _robotVioceTipLabel.hidden = YES;
        _robotVioceTipLabel.numberOfLines = 0;
        _robotVioceTipLabel.textInsets = UIEdgeInsetsMake(10.f, 15.0f, 10.f, 15.0f);
        
      CGFloat lh = [SobotUITools getHeightContain:SobotKitLocalString(@"机器人咨询模式下，语音将自动转化为文字发送") font:SobotFont12 Width:_ppView.frame.size.width-30];
        [_ppView addConstraint:sobotLayoutEqualHeight(lh + 20, _robotVioceTipLabel, NSLayoutRelationEqual)];
        [_ppView addConstraint:sobotLayoutPaddingLeft(0, _robotVioceTipLabel, _ppView)];
        [_ppView addConstraint:sobotLayoutPaddingRight(0, _robotVioceTipLabel, _ppView)];
        if(self.fastView){
            [_ppView addConstraint:sobotLayoutMarginBottom(0, _robotVioceTipLabel,self.fastView)];
            
        }else{
            [_ppView addConstraint:sobotLayoutMarginBottom(0, _robotVioceTipLabel, _zc_bottomView)];
        }
    }
    return _robotVioceTipLabel;
}

-(UIButton *) createButton:(BottomButtonClickTag) tag{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = UIColor.clearColor;
    [btn setContentEdgeInsets:UIEdgeInsetsZero];
    [btn setImageEdgeInsets:UIEdgeInsetsZero];
    [btn setTitleEdgeInsets:UIEdgeInsetsZero];
    btn.tag = tag;
//    btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    btn.contentHorizontalAlignment= UIControlContentHorizontalAlignmentFill;//水平方向拉伸
    btn.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;//垂直方向拉伸
    [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}


-(void)setInitConfig:(ZCLibConfig *)config{
    
    if(_robotVioceTipLabel){
        _robotVioceTipLabel.text = SobotKitLocalString(@"机器人咨询模式下，语音将自动转化为文字发送");
    }
    if(_btnVoicePress){
        [_btnVoicePress setTitle:SobotKitLocalString(@"按住 说话") forState:UIControlStateNormal];
    }
    if([ZCUIKitTools getSobotIsRTLLayout]){
        self.zc_chatTextView.textAlignment = NSTextAlignmentRight;
        self.zc_chatTextView.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
    }else{
        self.zc_chatTextView.textAlignment = NSTextAlignmentLeft;
        self.zc_chatTextView.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
    }
    if([self getLibConfig].isArtificial){
        [self setKeyboardMenuByStatus:ZCKeyboardStatusUser];
    }else{
        if([self getLibConfig].type == 2){
            if([self getLibConfig].ustatus == -2){
                [self setKeyboardMenuByStatus:ZCKeyboardStatusWaiting];
            }else{
                if ([self getLibConfig].ustatus != 1) {
//                    [self setKeyboardMenuByStatus:ZCKeyboardStatusNewSession];
                    [self setKeyboardMenuByStatus:ZCKeyboardStatusRobot];
                }
            }
        }else{
            [self setKeyboardMenuByStatus:ZCKeyboardStatusRobot];
            
        }
    }
}
-(ZCLibConfig *)getLibConfig{
    return [[ZCPlatformTools sharedInstance] getPlatformInfo].config;
}

-(void)setKeyboardMenuByStatus:(ZCKeyboardViewStatus )status{
    [ZCUICore getUICore].isKeyboardNewSession = NO;
    _curKeyboardStatus = status;
    
    _zc_chatTextView.editable = YES;
    _zc_reConnectView.hidden = YES;
    _btnVoice.hidden = YES;
    _btnFace.hidden = YES;
    if(_robotVioceTipLabel){
        _robotVioceTipLabel.hidden = YES;
    }
        
    // 新会话初始化时的键盘高度，需要还原一下
    _viewReConnectConsHeight.constant = 0;
    _chatTextConsHeight.constant = 35;
    
//    ZCLibConfig *config = [self getLibConfig];
    // 接入方式,1只有机器人,2.仅人工 3.智能客服-机器人优先 4智能客服-人工客服优先',
    if(_curKeyboardStatus == ZCKeyboardStatusRobot){
//        [_zc_chatTextView setPlaceholder:[self getLibConfig].robotDoc];
        _zc_chatTextView.placeholder = [self getLibConfig].robotDoc;
        // 4.0.5机器人也可以发emoji
        _btnFace.hidden = NO;
        
        if([ZCUICore getUICore].kitInfo.isOpenRecord && [ZCUICore getUICore].kitInfo.isOpenRobotVoice){
            _btnVoice.hidden = NO;
        }
        if([self getMoreBtnTitles].count == 0){
            _btnMore.hidden = YES;
        }else{
            _btnMore.hidden = NO;
        }
    }else if(_curKeyboardStatus == ZCKeyboardStatusUser){
//        [_zc_chatTextView setPlaceholder:[self getLibConfig].customDoc];
        _zc_chatTextView.placeholder = [self getLibConfig].customDoc;
        NSLog(@" [self getLibConfig].customDoc ===%@",[self getLibConfig].customDoc);
        _btnFace.hidden = NO;
        // 隐藏转人工按钮
//        _btnConnectUser.hidden = YES;
        
        if([ZCUICore getUICore].kitInfo.isOpenRecord){
            _btnVoice.hidden = NO;
        }
        if([self getMoreBtnTitles].count == 0){
            _btnMore.hidden = YES;
        }else{
            _btnMore.hidden = NO;
        }
    }else if(_curKeyboardStatus == ZCKeyboardStatusNewSession){
        [self showReConnectView];
        [ZCUICore getUICore].isKeyboardNewSession = YES;
    }else if(_curKeyboardStatus == ZCKeyboardStatusWaiting){
        _zc_chatTextView.editable = NO;
        _zc_chatTextView.placeholder = sobotConvertToString([self getLibConfig].waitDoc).length == 0 ?  SobotKitLocalString(@"排队中...") : sobotConvertToString([self getLibConfig].waitDoc);
        if([self getMoreBtnTitles].count == 0){
            _btnMore.hidden = YES;
        }else{
            _btnMore.hidden = NO;
        }
    }
    
//    if(sobotConvertToString(_zc_chatTextView.placeholder).length == 0){
//        _zc_chatTextView.placeholder = SobotKitLocalString(@"请输入");
//    }
    
    if(!_btnVoice.isHidden){
        if(_zc_recordView == nil){
            _zc_recordView=[[SobotKeyboardRecordView alloc] initRecordView:self];
            _zc_recordView.hidden = YES;
            [_ppView addSubview:_zc_recordView];
            [_ppView addConstraint:sobotLayoutPaddingLeft(0, _zc_recordView, _ppView)];
            [_ppView addConstraint:sobotLayoutPaddingRight(0, _zc_recordView, _ppView)];
            [_ppView addConstraint:sobotLayoutMarginBottom(0, _zc_recordView, _zc_bottomView)];
            [_ppView addConstraint:sobotLayoutEqualHeight(220, _zc_recordView, NSLayoutRelationEqual)];
            // 渐变色 换图片
            [self setGradientBackgroundForView:_zc_recordView];
        }
    }
    
    // 设置转人工按钮显影
    [self displayButtonStatus:BUTTON_CONNECT_USER];
    // 设置按钮显影
    [self displayButtonStatus:BUTTON_ADDVOICE];
    // 设置转人工按钮显影
    [self displayButtonStatus:BUTTON_ADDFACEVIEW];
    // 更多按钮的显影
    [self displayButtonStatus:BUTTON_ADDMORE];
}

- (void)setGradientBackgroundForView:(UIView *)view {
    // 创建一个 CAGradientLayer
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    // 设置渐变的颜色（这里是从红色到黄色）
    
    gradientLayer.colors = @[(id)UIColorFromModeColorAlpha(SobotColorBgMainDark1, 0.01).CGColor,(id)UIColorFromModeColorAlpha(SobotColorBgMainDark1, 0.8).CGColor, (id)[UIColor whiteColor].CGColor, (id)[UIColor whiteColor].CGColor];
    // 如果是夜间模式
    if ([SobotUITools getSobotThemeMode] == SobotThemeMode_Dark) {
        // 当前是暗夜模式
        gradientLayer.colors = @[(id)UIColorFromModeColorAlpha(@"#262626", 0.8).CGColor, (id)UIColorFromKitModeColor(@"#262626").CGColor, (id)UIColorFromKitModeColor(@"#262626").CGColor];
    }
    
    // 设置渐变的起始点和结束点（默认是从左到右）
    gradientLayer.startPoint = CGPointMake(0.5, 0);   // 从左上角开始
    gradientLayer.endPoint = CGPointMake(0.5, 1);     // 到右下角结束
    // 设置渐变图层的尺寸与视图相同
    gradientLayer.frame = CGRectMake(0, 0, ScreenWidth, 220);
    // 将渐变图层添加到视图的layer上
    [view.layer insertSublayer:gradientLayer atIndex:0];
}

-(CGFloat) getSourceViewHeight{
    CGFloat height = SobotViewHeight(_ppView);
    if(height <= 0){
        [_ppView layoutIfNeeded];
    }
    height = SobotViewHeight(_ppView);
    return height;
}

-(CGFloat) getSourceViewWidth{
    CGFloat width = SobotViewWidth(_ppView);
    if(width <= 0){
        [_ppView layoutIfNeeded];
    }
    width = SobotViewWidth(_ppView);
    return width;
}


//停止滚动的时候
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [_facePageControl setCurrentPage:_zc_moreView.contentOffset.x / [self getSourceViewWidth]];
    // 更新页码
    [_facePageControl updateCurrentPageDisplay];
}

- (void)pageChange:(id)sender {
    [_zc_moreView setContentOffset:CGPointMake(_facePageControl.currentPage * [self getSourceViewWidth], 0) animated:YES];
    [_facePageControl setCurrentPage:_facePageControl.currentPage];
}
#pragma mark 常用方法
-(ZCLibConfig *)getZCLibConfig{
    return [[ZCPlatformTools sharedInstance] getPlatformInfo].config;
}

-(void)doSendMessage{
    NSString *text=_zc_chatTextView.text;
    // 过滤空格
    text = sobotTrimString(text);
    if([@"" isEqual:sobotConvertToString(text)]){
        [_zc_chatTextView setText:@""];
        [self textChanged:_zc_chatTextView];
        return;
    }
    
//    if(_isConnectioning){
//        return;
//    }
    
    // 最多发送1000字符
    if(text.length > 1000){
        text = [text substringToIndex:1000];
    }
    
    [_zc_chatTextView setText:@""];
    


    [[ZCAutoListView getAutoListView] dissmiss];
    [self textChanged:_zc_chatTextView];
    [self sendMessageOrFile:text type:SobotMessageTypeText duration:@"" dict:nil];
}


-(void) sendMessageOrFile:(NSString *)filePath type:(SobotMessageType) type duration:(NSString *)duration dict:(NSDictionary * _Nullable) dict{
    if (_curKeyboardStatus == ZCKeyboardStatusNewSession) {
        // 发送提示消息“本次会话已结束”
        [[ZCUICore getUICore] addMessageToList:SobotMessageActionTypeOverWord content:@"" type:SobotMessageTypeTipsText dict:nil];
        return;
    }
    if(type == SobotMessageTypeText){
        // 此页面只能发送普通基础类型，所以写死了SobotMessageRichJsonTypeText
        // 添加引用消息
        [[ZCUICore getUICore] sendMessage:filePath type:type exParams:dict duration:duration richType:SobotMessageRichJsonTypeText obj:self.referenceMessage];
        
        // 发送完，取消引用消息
        [self hideReferenceView];
    }else{
        // 此页面只能发送普通基础类型，所以写死了SobotMessageRichJsonTypeText
        [[ZCUICore getUICore] sendMessage:filePath type:type exParams:dict duration:duration richType:SobotMessageRichJsonTypeText];
    }
}



-(void)showTableFrameByKeyboardChanged{
    [[ZCUICore getUICore] keyboardOnClick:ZCShowTextHeightChanged];
    // 2.8.5版本移到此处，以前写在键盘隐藏处，不符合逻辑
    [self addAutoListView];
}


#pragma mark 页面点击事件
-(void)buttonClick:(SobotButton *) btn{
    showRichKeyboard = NO;
    [[ZCAutoListView getAutoListView] dissmiss];
    // 排队中，键盘不让操作
    if(_curKeyboardStatus == ZCKeyboardStatusWaiting){
        return;
    }
    [_zc_chatTextView setHidden:NO];
    
    // 执行转人工
    if(btn.tag == BUTTON_CONNECT_USER){
        [[ZCUICore getUICore] checkUserServiceWithType:ZCTurnType_BtnClick model:nil];
    }
    
    // 录音
    if(btn.tag == BUTTON_ADDVOICE){
        [self hideKeyboard];
        
//        [self setItemButtonDefaultStatus];
        [self setItemButtonDefaultStatusVoicePress];
        if(_btnVoicePress.isHidden){
            [_zc_chatTextView setHidden:YES];
           _btnVoicePress.hidden = NO;
            _robotVioceTipLabel.hidden = YES;
            
            [UIView animateWithDuration:0.25 animations:^{
                self->_chatTextConsHeight.constant = 35; // 重置此高度
            }];
            
            if([ZCUICore getUICore].kitInfo.isOpenRecord && [ZCUICore getUICore].kitInfo.isOpenRobotVoice && ![ZCUICore getUICore].getLibConfig.isArtificial){
                _robotVioceTipLabel.hidden = NO;
            }
            
            [_btnVoice setImage:SobotKitGetImage(@"zcicon_keyboard_normal") forState:UIControlStateNormal];
        }else{
            // 重新计算输入框的约束，对应显示时的35高度设置
            [self textViewDidChange:_zc_chatTextView];
            _btnVoicePress.hidden = YES;
            _robotVioceTipLabel.hidden = YES;
            [_zc_chatTextView setHidden:NO];
        }
        
    }
    
    // 显示表情
    if(btn.tag == BUTTON_ADDFACEVIEW){
        _facePageControl.hidden = YES;// 查看更多的时候再判断是否显示
        BOOL isShowFaceView = NO;
        // 已经有显示了，判断当前是否显示的表情
        if(_zc_keyBoardHeight > 0){
            if(_viewEmojiConsHeight.constant == 0 || _emojiView.hidden){
                isShowFaceView = YES;
            }
        }else{
            isShowFaceView = YES;
        }
        
        [self setItemButtonDefaultStatus];
        if(isShowFaceView){
            showRichKeyboard = YES;
            [self hideKeyboard];
            _zc_moreView.hidden = YES;
            _bottomlineView.hidden = YES;
            _btnVoicePress.hidden = YES;
            [_zc_listTable addGestureRecognizer:_tapRecognizer];
            _zc_keyBoardHeight = EmojiViewHeight;
            if (SobotViewHeight(self->_ppView) < SobotViewWidth(self->_ppView)) {
                _zc_keyBoardHeight = EmojiViewHorizontalHeight;
            }
            [_emojiView refreshItemsView:_zc_keyBoardHeight];
            
            [_btnFace setImage:SobotKitGetImage(@"zcicon_keyboard_normal") forState:UIControlStateNormal];

            [UIView animateWithDuration:0.25 animations:^{
                self.emojiView.hidden = NO;
                self.viewEmojiConsHeight.constant = self.zc_keyBoardHeight;

                self.viewBottomConsSpace.constant = -self.zc_keyBoardHeight;

                [self.ppView layoutIfNeeded];
                [self.zc_bottomView layoutIfNeeded];
                [self showTableFrameByKeyboardChanged];
            }];
        }else{
            // 不显示的时候，切换到键盘
            [_zc_chatTextView becomeFirstResponder];
        }
    }
    
    // 点击更多
    if(btn.tag == BUTTON_ADDMORE){
        _facePageControl.hidden = YES;// 查看更多的时候再判断是否显示
        BOOL isShowMoreView = NO;
        // 当前是否显示的更多键盘
        if(_zc_keyBoardHeight > 0){
            if(_viewMoreConsHeight.constant == 0 || _zc_moreView.hidden){
                isShowMoreView = YES;
            }
        }else{
            isShowMoreView = YES;
        }

        [self setItemButtonDefaultStatus];
        if(isShowMoreView){
            showRichKeyboard = YES;
            [self hideKeyboard];
            _emojiView.hidden = YES;
            _zc_moreView.hidden = NO;
            _bottomlineView.hidden = NO;
            if(_tapRecognizer){
                [_zc_listTable addGestureRecognizer:_tapRecognizer];
            }
            [self createMoreItems];
            _zc_keyBoardHeight = countMoreHeight;
            
            [_btnMore setImage:SobotKitGetImage(@"zcicon_add_clear") forState:UIControlStateNormal];
            
            [UIView animateWithDuration:0.25 animations:^{
                _viewMoreConsHeight.constant = _zc_keyBoardHeight;
                
                _viewBottomConsSpace.constant = -_zc_keyBoardHeight;
                [_zc_moreView layoutIfNeeded];
                //            [self createMoreItems];
                [_ppView layoutIfNeeded];
                [_zc_bottomView layoutIfNeeded];
                [self showTableFrameByKeyboardChanged];
            }];
        }else{
            [self hideKeyboard];
        }
    }
    
    // 选择照片
    if(btn.tag == BUTTON_ADDPHOTO){
//        if ([ZCUICore getUICore].aiAgentAsking && ![[ZCUICore getUICore] getLibConfig].isArtificial) {
//            return;
//        }
        [self getPhotoByType:SobotImagePickerPicture];
    }
    
    // 相机拍摄
    if(btn.tag == BUTTON_AddPhotoCamera){
//        if ([ZCUICore getUICore].aiAgentAsking && ![[ZCUICore getUICore] getLibConfig].isArtificial) {
//            return;
//        }
        [self getPhotoByType:SobotImagePickerCamera];
    }
    
    // 相册中的视频
    if(btn.tag == BUTTON_AddVideo){
//        if ([ZCUICore getUICore].aiAgentAsking && ![[ZCUICore getUICore] getLibConfig].isArtificial) {
//            return;
//        }
        [self getPhotoByType:SobotImagePickerVideo];
    }
    
    // 文件系统选择
    if(btn.tag == BUTTON_AddDocumentFile){
//        if ([ZCUICore getUICore].aiAgentAsking && ![[ZCUICore getUICore] getLibConfig].isArtificial) {
//            return;
//        }
        // 选择文件
        NSArray *arr = @[@"public.data",@"public.content",@"public.audiovisual-content",@"public.movie",@"public.audiovisual-content",@"public.video",@"public.audio",@"public.text",@"public.data",@"public.zip-archive",@"com.pkware.zip-archive",@"public.composite-content",@"public.text"];
        // 限制类型
        UIDocumentPickerViewController *docPciter = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:arr inMode:UIDocumentPickerModeImport];
        // 所有类型
        //        UIDocumentPickerViewController* docPciter =  [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.data"] inMode:UIDocumentPickerModeImport];
        docPciter.delegate = self;
        if(sobotGetSystemDoubleVersion()>=11.0){
            if (@available(iOS 11.0, *)) {
                docPciter.allowsMultipleSelection = NO;
            } else {
                // Fallback on earlier versions
            }
        } else {
            // Fallback on earlier versions
        }
        docPciter.modalPresentationStyle = UIModalPresentationFullScreen;
        // 处理导航栏和状态栏的透明的问题,并重写他的navc代理方法
        if (iOS7) {
            docPciter.edgesForExtendedLayout = UIRectEdgeNone;
        }
        [[SobotUITools getCurrentVC] presentViewController:docPciter animated:YES completion:^{
            
        }];
    }
    // 位置
    if(btn.tag == BUTTON_AddLocation){
        
        //  链接处理：
        [[ZCUICore getUICore] dealWithLinkClickWithLick:@"sobot://sendLocation" viewController:[SobotUITools getCurrentVC]];
    }
    
    // 留言
    if(btn.tag == BUTTON_LEAVEMESSAGE){
        [[ZCUICore getUICore] goLeavePage];
    }
    if(btn.tag == BUTTON_RECONNECT_USER){
        [[ZCUICore getUICore] keyboardOnClick:ZCShowStatusReConnectClick];
    }
    
    // 评价
    if(btn.tag == BUTTON_EVALUATION){
        BOOL isEvalutionAdmin = [ZCUICore getUICore].getLibConfig.isArtificial;
        if(_curKeyboardStatus == ZCKeyboardStatusNewSession){
            isEvalutionAdmin = [ZCUICore getUICore].isAdminServerBeforeCloseSession;
        }
        
        [[ZCUICore getUICore] checkSatisfacetion:isEvalutionAdmin type:SobotSatisfactionFromSrouceNewSession];
        
//        SobotSatisfactionView *view = [[SobotSatisfactionView alloc] initActionSheetWith:nil config:nil cView:nil];
//        [view showSatisfactionView];
    }
    
    // 自定义事件
    if(btn.tag >= 1000){
        ZCLibCusMenu *menu = btn.obj;
        if(![@"" isEqual:menu.url]){
            [[ZCUICore getUICore] dealWithLinkClickWithLick:menu.url viewController:[SobotUITools getCurrentVC]];
        }
    }
}

// 设置按钮显影的状态和位置
-(void)displayButtonStatus:(BottomButtonClickTag) tag{
//    if(tag == BUTTON_CONNECT_USER){
//        if(_btnConnectUser.hidden){
//            _btnConnectUserConsWidth.constant = 0;
//            [_btnConnectUser updateConstraints];
//        }else{
//            _btnConnectUserConsWidth.constant = SobotKeyboardBtnWidth;
//            [_btnConnectUser updateConstraints];
//        }
//    }
    if(tag == BUTTON_ADDVOICE){
        if(_btnVoice.hidden){
            _btnVoiceConsWidth.constant = 0;
            [_btnVoice updateConstraints];
        }else{
            _btnVoiceConsWidth.constant = SobotKeyboardBtnWidth;
            [_btnVoice updateConstraints];
        }
    }
    if(tag == BUTTON_ADDFACEVIEW){
        if(_btnFace.hidden){
            _btnFaceConsWidth.constant = 0;
            [_btnFace updateConstraints];
        }else{
            _btnFaceConsWidth.constant = SobotKeyboardBtnWidth;
            [_btnFace updateConstraints];
        }
    }
    if(tag == BUTTON_ADDMORE){
        if(_btnMore.hidden){
            _btnMoreConsWidth.constant = 0;
        }else{
            _btnMoreConsWidth.constant = SobotKeyboardBtnWidth;
        }
        [_btnMore updateConstraints];
    }
}

// 显示重新建立会话
-(void)showReConnectView{
    [self hideReferenceView];// 先回收掉引用的消息
    
    // 会话结束，清空输入框内容
    [_zc_chatTextView setText:@""];
    
    // 先回收键盘，并影藏掉其他键盘页面
    [self hideKeyboard];
    if (!sobotIsNull(self.zc_moreView)) {
        self.zc_moreView.hidden = YES;
        _bottomlineView.hidden = YES;
    }
    // 移除所有view
    [_zc_reConnectView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _zc_reConnectView.hidden = NO;
    
    UIView *line = [[UIView alloc]init];
    line.backgroundColor = [ZCUIKitTools zcgetChatBottomLineColor];
    [_zc_reConnectView addSubview:line];
    
    // 顶部线条
    [_zc_reConnectView addConstraint:sobotLayoutPaddingLeft(0, line, _zc_reConnectView)];
    [_zc_reConnectView addConstraint:sobotLayoutPaddingRight(0, line, _zc_reConnectView)];
    [_zc_reConnectView addConstraint:sobotLayoutPaddingTop(0, line, _zc_reConnectView)];
    [_zc_reConnectView addConstraint:sobotLayoutEqualHeight(1, line,NSLayoutRelationEqual)];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    if(![ZCUICore getUICore].kitInfo.hideBottomEvaluation && ![ZCUICore getUICore].kitInfo.hideBottomEvaluation) {
        [items addObject:@(BUTTON_EVALUATION)];
    }
    
    if ([self getZCLibConfig].msgFlag == 0 && ![ZCUICore getUICore].kitInfo.hideBottomLeave) {
        // 2.8.9人工状态，留言转离线消息，不处理
        if(!([self getZCLibConfig].isArtificial && [self getZCLibConfig].msgToTicketFlag == 2)){
            [items addObject:@(BUTTON_LEAVEMESSAGE)];
        }
    }
    [items addObject:@(BUTTON_RECONNECT_USER)];
    CGFloat w = ScreenWidth;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // 当前是 iPad
//        NSLog(@"这是 iPad");
        w = [self getSourceViewWidth];
    } else {
        // 当前不是 iPad
//        NSLog(@"这不是 iPad");
    }
    CGFloat itemW = (w - 48 - (items.count-1) * 16)/items.count;
    UIButton *preBtn = nil;
    for(int i=0;i<items.count;i++){
        UIButton *btn = [self addReConnectItems:[items[i] intValue]];
        [_zc_reConnectView addConstraint:sobotLayoutPaddingTop(0, btn,_zc_reConnectView)];
        [_zc_reConnectView addConstraint:sobotLayoutEqualHeight(86, btn, NSLayoutRelationEqual)];
        [_zc_reConnectView addConstraint:sobotLayoutEqualWidth(itemW, btn, NSLayoutRelationEqual)];
        if(preBtn!=nil){
            [_zc_reConnectView addConstraint:sobotLayoutMarginLeft(16, btn, preBtn)];
        }else{
            
            [_zc_reConnectView addConstraint:sobotLayoutPaddingLeft(24, btn, _zc_reConnectView)];
        }
        
        preBtn = btn;
    }
    
    _viewReConnectConsHeight.constant = ZCConnectBottomHeight;
    _chatTextConsHeight.constant = 35 + (ZCConnectBottomHeight - 60);
    
    [_zc_reConnectView layoutIfNeeded];
    [_zc_bottomView layoutIfNeeded];
    [_ppView layoutIfNeeded];
    
}

// 设置转人工/语音/表情/更多按钮图片
-(void)setItemButtonDefaultStatus{
    // 设置图标
    [_btnFace setImage:SobotKitGetImage(@"zcicon_expression_normal") forState:UIControlStateNormal];
    
    // 设置图标
    [_btnVoice setImage:SobotKitGetImage(@"zcicon_voice_normal") forState:UIControlStateNormal];
    // 回复默认 语音提示消息隐藏掉
    _robotVioceTipLabel.hidden = YES;
    // 按住说话 也影藏掉
    _btnVoicePress.hidden = YES;
    [_btnMore setImage:SobotKitGetImage(@"zcicon_add") forState:UIControlStateNormal];
    [UIView beginAnimations:@"rotation1" context:nil];
    [UIView setAnimationDuration:0.25];
    self.btnMore.imageView.transform = CGAffineTransformMakeRotation(0);
    [UIView commitAnimations];
}

-(void)setItemButtonDefaultStatusVoicePress{
    // 设置图标
    [_btnFace setImage:SobotKitGetImage(@"zcicon_expression_normal") forState:UIControlStateNormal];
    
    // 设置图标
    [_btnVoice setImage:SobotKitGetImage(@"zcicon_voice_normal") forState:UIControlStateNormal];
    // 回复默认 语音提示消息隐藏掉
//    _robotVioceTipLabel.hidden = YES;
//    // 按住说话 也影藏掉
//    _btnVoicePress.hidden = YES;
    [_btnMore setImage:SobotKitGetImage(@"zcicon_add") forState:UIControlStateNormal];
    [UIView beginAnimations:@"rotation1" context:nil];
    [UIView setAnimationDuration:0.25];
    self.btnMore.imageView.transform = CGAffineTransformMakeRotation(0);
    [UIView commitAnimations];
}

// 添加重建会话按钮
-(UIButton *)addReConnectItems:(NSInteger ) tag{
    
    UIButton *btn1 = [SobotUITools createZCButton];
    btn1.titleLabel.font = SobotFont12;
    btn1.tag = tag;
    
    UIImageView *imgview = [[UIImageView alloc]init];
    imgview.contentMode = UIViewContentModeScaleAspectFit;
    [btn1 addSubview:imgview];
    [btn1 addConstraint:sobotLayoutPaddingTop(13, imgview, btn1)];
    [btn1 addConstraint:sobotLayoutEqualWidth(30, imgview, NSLayoutRelationEqual)];
    [btn1 addConstraint:sobotLayoutEqualHeight(30, imgview, NSLayoutRelationEqual)];
    [btn1 addConstraint:sobotLayoutEqualCenterX(0, imgview, btn1)];
    
    UILabel *lab = [[UILabel alloc]init];
    lab.font = SobotFont12;
    lab.textColor = UIColorFromModeColor(SobotColorTextSub);
    lab.textAlignment = NSTextAlignmentCenter;
    lab.numberOfLines = 2;
    lab.lineBreakMode = NSLineBreakByTruncatingTail;
    [btn1 addSubview:lab];
    [btn1 addConstraint:sobotLayoutPaddingLeft(0, lab, btn1)];
    [btn1 addConstraint:sobotLayoutPaddingRight(0, lab, btn1)];
    [btn1 addConstraint:sobotLayoutMarginTop(10, lab, imgview)];
    
    if(tag == BUTTON_LEAVEMESSAGE){
//        [btn1 setTitle:SobotKitLocalString(@"留言") forState:0];
//        [btn1 setImage:SobotKitGetImage(@"zcicon_bottombar_message") forState:UIControlStateNormal];
        lab.text = SobotKitLocalString(@"留言");
        [imgview setImage:SobotKitGetImage(@"zcicon_bottombar_message")];
    }
    else if(tag == BUTTON_RECONNECT_USER){
//        [btn1 setTitle:SobotKitLocalString(@"重建会话") forState:0];
//        [btn1 setImage:SobotKitGetImage(@"zcicon_bottombar_conversation") forState:UIControlStateNormal];
        lab.text = SobotKitLocalString(@"重建会话");
        [imgview setImage:SobotKitGetImage(@"zcicon_bottombar_conversation")];
    }else if(tag == BUTTON_EVALUATION){
//        [btn1 setTitle:SobotKitLocalString(@"评价") forState:0];
//        [btn1 setImage:SobotKitGetImage(@"zcicon_bottombar_satisfaction") forState:UIControlStateNormal];
        lab.text = SobotKitLocalString(@"服务评价");
        [imgview setImage:SobotKitGetImage(@"zcicon_bottombar_satisfaction")];
    }
    
    [btn1 addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];

    [_zc_reConnectView addSubview:btn1];
    return btn1;
}

#pragma mark 自动提醒
-(void)addAutoListView{
    // 没有文字的时候 销毁掉
    if (sobotConvertToString(_zc_chatTextView.text).length == 0) {
        [[ZCAutoListView getAutoListView] dissmiss];
    }
//    [[NSUserDefaults standardUserDefaults] boolForKey:Sobot_isEnableAutoTips]
    if ([[ZCUICore getUICore] getLibConfig].robotGuessFlag && ![self getZCLibConfig].isArtificial) {
        [ZCAutoListView getAutoListView].delegate = self;
        [[ZCAutoListView getAutoListView] showWithText:_zc_chatTextView.text  view:_zc_bottomView];
    }
}
-(void)autoViewCellItemClick:(NSString *)text{
//    if ([ZCUICore getUICore].aiAgentAsking && ![[ZCUICore getUICore] getLibConfig].isArtificial) {
//        return;
//    }
    [self sendMessageOrFile:text type:SobotMessageTypeText duration:@"" dict:nil];
    [self.zc_chatTextView setText:@""];
    [self textChanged:_zc_chatTextView];
    [[ZCAutoListView getAutoListView] dissmiss];
}

#pragma mark 发送文件相关
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller{
    
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url{
//    NSString *filePath = url.absoluteString;
//    [SobotLog logDebug:@"%@",filePath];
}
//- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls{
//    if(urls.count > 0){
//        NSURL *url = urls[0];
//        //        NSString *mate = [self mimeWithString:url];
//        //
//        NSString *urlStr = url.absoluteString;
//        if ([urlStr hasPrefix:@"file:///"]) {
//            urlStr = [urlStr stringByReplacingOccurrencesOfString:@"file://" withString:@""];
//        }
//        url = [NSURL URLWithString:urlStr];
//        [SobotLog logHeader:SobotLogHeader info:@"%@\n%@\n",url.absoluteString,sobotUrlDecodedString(url.absoluteString)];
//    
//        //获取文件的大小 不能大于50M
//        NSData *data = [NSData dataWithContentsOfURL:url];
//        if(data){
//            NSString * size =  [NSString stringWithFormat:@"%.2f",data.length*1.0/1024];
//            if ([size intValue] > 1024*50) {
//                // 弹提示
//                [[SobotToast shareToast] showToast:SobotKitLocalString(@"不能上传50M以上的文件") duration:2.0f position:SobotToastPositionCenter];
//                return;
//            }
//        }
//        [self sendMessageOrFile:sobotUrlDecodedString(url.absoluteString) type:SobotMessageTypeFile duration:@"" dict:nil];
//    }
//}
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls{
    if(urls.count > 0){
        NSURL *url = urls[0];
        //        NSString *mate = [self mimeWithString:url];
        //
        NSString *urlStr = url.absoluteString;
        
// 处理获取文件大小并上传的问题
        //通过文件协调工具来得到新的文件地址，以此得到文件保护功能
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
        NSError *error;
        
        [fileCoordinator coordinateReadingItemAtURL:urls.firstObject options:0 error:&error byAccessor:^(NSURL *newURL) {
            //读取文件
            NSString *fileName = [newURL lastPathComponent];
            NSError *error = nil;
            NSData *fileData = [NSData dataWithContentsOfURL:newURL options:NSDataReadingMappedIfSafe error:&error];
            if (error) {
                //读取出错
            } else {
                NSString * size =  [NSString stringWithFormat:@"%.2f",fileData.length*1.0/1024];
                if ([size intValue] > 1024*50) {
                    // 弹提示
                    [[SobotToast shareToast] showToast:SobotKitLocalString(@"不能上传50M以上的文件") duration:2.0f position:SobotToastPositionCenter];
                    return;
                }
                NSLog(@"上传===%@",fileName);
                //上传
                //                [self uploadingWithFileData:fileData fileName:fileName fileURL:newURL];
                NSString *fileUrl = urlStr;
                if ([fileUrl hasPrefix:@"file:///"]) {
                    fileUrl = [urlStr stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                    NSURL *furl = [NSURL URLWithString:fileUrl];
                    // 先回收键盘
                    [self sendMessageOrFile:sobotUrlDecodedString(url.absoluteString) type:SobotMessageTypeFile duration:@"" dict:nil];
                }
            }
        }];
        [urls.firstObject stopAccessingSecurityScopedResource];
        
//        if ([urlStr hasPrefix:@"file:///"]) {
//            urlStr = [urlStr stringByReplacingOccurrencesOfString:@"file://" withString:@""];
//        }
//        url = [NSURL URLWithString:urlStr];
//        [SobotLog logHeader:SobotLogHeader info:@"%@\n%@\n",url.absoluteString,[self URLDecodedString:url.absoluteString]];
//
//        //        [self hideKeyboard];
//        //获取文件的大小 不能大于50M
//
//        NSURL *Kurl = [NSURL URLWithString:sobotUrlEncodedString(url.absoluteString)];
//        NSURLRequest *request = [NSURLRequest requestWithURL:Kurl];
//
//        // 只有响应头中才有其真实属性 也就是MIME
//        NSURLResponse *response = nil;
//        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
//
//        NSString * size =  [NSString stringWithFormat:@"%.2f",data.length*1.0/1024];
//        if ([size intValue] > 1024*50) {
//            // 弹提示
//            [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"不能上传50M以上的文件") duration:2.0f view:_zc_sourceView position:ZCToastPositionCenter];
//            return;
//        }
//
//        // 先回收键盘
//        [self sendMessageOrFile:[self URLDecodedString:url.absoluteString] type:ZCMessageTypeFile duration:@""];
    }
}


#pragma mark 录音相关事件触发
-(void)btnTouchDown:(id)sender{
    [SobotLog logDebug:@"按下了"];
    
    // 这里要处理 在录音前关闭上一个还没有播放完的录音消息，以免造成录音是空的没有声音的问题
    [[NSNotificationCenter defaultCenter] postNotificationName:Sobot_ChatSDK_START_RECORD object:nil];
    
    [SobotUITools isOpenVoicePermissions:^(BOOL isResult) {
        if(!isResult){
            NSString *aleartMsg = @"";
            aleartMsg = SobotKitLocalString(@"请在《设置 - 隐私 - 麦克风》选项中，允许访问您的麦克风");
            
            [SobotUITools showAlert:nil message:aleartMsg cancelTitle:SobotKitLocalString(@"取消") titleArray:nil viewController:[SobotUITools getCurrentVC] confirm:^(NSInteger buttonTag) {
                if(buttonTag == 0){
                    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 18) {
                        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                                if (success) {
                                    NSLog(@"URL successfully opened.");
                                } else {
                                    NSLog(@"Failed to open URL.");
                                }
                            }];
                    }else{
                        if ([[UIApplication sharedApplication] canOpenURL:url]) {
                           [[UIApplication sharedApplication] openURL:url];
                        }
                    }
                }
            }];
            
            
            return;
        }else{
            if(self->_zc_recordView!=nil){
                [self->_zc_recordView showInView];
            }
            
            [self->_zc_recordView didChangeState:RecordStart];
            
            [self setRecordButtonState:RecordStart];
        }
    }];
    
}
-(void)btnTouchDownRepeat:(id)sender{
    [SobotLog logDebug:@"按下了,重复了"];
}
-(void)btnTouchMoved:(UIButton *)sender withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGFloat boundsExtension = 5.0f;
    CGRect outerBounds = CGRectInset(sender.bounds, -1 * boundsExtension, -1 * boundsExtension);
    BOOL touchOutside = !CGRectContainsPoint(outerBounds, [touch locationInView:sender]);
    if (touchOutside) {
        BOOL previewTouchInside = CGRectContainsPoint(outerBounds, [touch previousLocationInView:sender]);
        if (previewTouchInside) {
            // UIControlEventTouchDragExit
            [SobotLog logDebug:@"拖出了"];
            // 暂停，抬起就取消
            [_zc_recordView didChangeState:RecordPause];
//            [_zc_pressedButton setBackgroundImage:nil forState:UIControlStateNormal];
            [self setRecordButtonState:RecordPause];
        } else {
            // UIControlEventTouchDragOutside
            
        }
    } else {
        BOOL previewTouchOutside = !CGRectContainsPoint(outerBounds, [touch previousLocationInView:sender]);
        if (previewTouchOutside) {
            // UIControlEventTouchDragEnter
            
            [SobotLog logDebug:@"拖入"];
            
            // 接着录音
            [_zc_recordView didChangeState:RecordStart];
            
            [self setRecordButtonState:RecordStart];
        } else {
            // UIControlEventTouchDragInside
        }
    }
}


-(void)btnTouchCancel:(UIButton *)sender{
    
    [SobotLog logDebug:@"取消"];
    
    if(_zc_recordView){
//        _zc_recordView.hidden = YES;
        // 取消发送
        [_zc_recordView didChangeState:RecordCancel];
        
        //停止录音
        [self closeRecord:sender];
    }
    
}
-(void)btnTouchEnd:(UIButton *)sender withEvent:(UIEvent *)event{
//    NSLog(@"RecordCancel%@",event);
    UITouch *touch = [[event allTouches] anyObject];
    CGFloat boundsExtension = 5.0f;
    CGRect outerBounds = CGRectInset(sender.bounds, -1 * boundsExtension, -1 * boundsExtension);
    BOOL touchOutside = !CGRectContainsPoint(outerBounds, [touch locationInView:sender]);
    int duration = (int)_zc_recordView.currentTime;
    
    if (touchOutside) {
        // UIControlEventTouchUpOutside
        [SobotLog logDebug:@"取消ccc"];
        
        if(_zc_recordView){
//            _zc_recordView.hidden = YES;
            [self closeRecord:sender];
            // 取消发送
            [_zc_recordView didChangeState:RecordCancel];
        }
    } else {
        // UIControlEventTouchUpInside
        [SobotLog logDebug:@"结束了"];
        
        if (duration < 1 && [[ZCUICore getUICore] getRecordModel]) { 
            // 先显示时间过短 秒点秒松开状态下
            [_zc_recordView didChangeState:RecordComplete];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 取消发送
                [self->_zc_recordView didChangeState:RecordCancel];
#pragma mark - 这里加延迟是为了 增加弹窗 “录音时间过短” 的显示时间， closeRecord 方法会销毁掉弹窗
                [self closeRecord:sender];
            });
            // 这里处理异常情况下 录音按钮没有恢复默认状态的场景 （秒点录音按钮之后秒松开）
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self->_btnVoice.enabled = YES;
                self->_btnMore.enabled = YES;
                self->_btnFace.enabled = YES;
                [self->_btnVoicePress setTitle:SobotKitLocalString(@"按住 说话") forState:UIControlStateNormal];
            });
        }else{
            // 发送
            [self closeRecord:sender];
            [_zc_recordView didChangeState:RecordComplete];
        }
    
    }
    
}


-(void)setRecordButtonState:(SobotKeyboardRecordState) state{
//    [_btnVoicePress setBackgroundColor:UIColorFromModeColor(SobotColorTextSub)];
    if(state == RecordCancel){
        [_btnVoicePress setTitle:SobotKitLocalString(@"按住 说话") forState:UIControlStateNormal];
        _btnVoice.enabled = YES;
        _btnMore.enabled = YES;
        _btnFace.enabled = YES;
    }
    if(state == RecordStart){
        [_btnVoicePress setTitle:SobotKitLocalString(@"松开 发送") forState:UIControlStateNormal];
        _btnVoice.enabled = NO;
        _btnMore.enabled = NO;
        _btnFace.enabled = NO;
        
    }
    if(state == RecordPause){
        [_btnVoicePress setTitle:SobotKitLocalString(@"松开 取消") forState:UIControlStateNormal];
    }
}

-(BOOL) isKeyboardRecord{
    if(!sobotIsNull(_zc_recordView)){
        return !_zc_recordView.hidden;
    }
    return NO;
}

-(void)closeRecord:(UIButton *) sender{
    //停止录音
    
    int duration = (int)_zc_recordView.currentTime;
    [_zc_recordView dismissRecordView];
    
    [self setRecordButtonState:RecordCancel];
    if(duration<1){
        [SobotLog logDebug:@"当前的时长：%d",duration];
        // 当前记录的语音时间为 0秒，秒点击触发事件，关闭计时器
        sender.enabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.25f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            sender.enabled = YES;
        });
    }
}


#pragma mark 录音完成，上传录音
-(void)recordComplete:(NSString *)filePath videoDuration:(CGFloat)duration{
    NSDate  *date = [NSDate dateWithTimeIntervalSince1970:duration];
    NSString *time=sobotDateTransformString(@"mm:ss", date);
    [self sendMessageOrFile:filePath type:SobotMessageTypeSound duration:time dict:nil];
}


- (void)recordCompleteType:(SobotKeyboardRecordState )type videoDuration:(CGFloat)duration{
    if (type == RecordStart) {
        [self sendMessageOrFile:@"" type:SobotMessageTypeStartSound duration:[NSString stringWithFormat:@"%d",(int)duration] dict:nil];
//        [[ZCUICore getUICore] sendMessage:@"" questionId:@"" type:ZCMessagetypeStartSound duration:[NSString stringWithFormat:@"%d",(int)duration]];
    }else if(type == RecordCancel){
        // 录音结束了，要恢复按钮的状态
        [self updateBtnVoicePressStatus];
        
#pragma mark - 这里加延时的原因  当用户秒点 “按住 说话” 之后秒释放 创建的闪烁语音cell还没有在主线程上UI刷新完成，这时候销毁的事件已经触发，导致语音闪烁cell并没有真正的移除掉
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self sendMessageOrFile:@"" type:SobotMessageTypeCancelSound duration:[NSString stringWithFormat:@"%d",(int)duration] dict:nil];
            });
    }
}

#pragma mark 设置录音按钮为可点击状态
-(void)updateBtnVoicePressStatus{
    self->_btnVoice.enabled = YES;
    self->_btnMore.enabled = YES;
    self->_btnFace.enabled = YES;
    [self->_btnVoicePress setTitle:SobotKitLocalString(@"按住 说话") forState:UIControlStateNormal];
}
#pragma mark -- 表情键盘代理事件
/**
 *  表情键盘点击
 *
 *  @param faceTag 表情
 *  @param name    表情
 *  @param itemId  第几个
 */
-(void)onEmojiItemClick:(NSString *)faceTag faceName:(NSString *)name index:(NSInteger)itemId{
//    if ([_zc_chatTextView.text isEqualToString:_zc_chatTextView.placeholder]) {
//        _zc_chatTextView.text=[NSString stringWithFormat:@"%@",name];
//    }else{
        _zc_chatTextView.text=[NSString stringWithFormat:@"%@%@",_zc_chatTextView.text,name];
//    }
    [self textChanged:_zc_chatTextView];
}

// 表情键盘执行删除
-(void)emojiAction:(EmojiBoardActionType)action{
    if(action==EmojiActionDel){
        NSString *text = _zc_chatTextView.text;
        // 如果内容与预置相同，则清理掉
//        if ([text isEqualToString:_zc_chatTextView.placeholder]) {
//            _zc_chatTextView.text = @"";
//            [self textChanged:_zc_chatTextView];
//            return;
//        }
        NSInteger lenght=text.length;
        if(lenght>0){
            // 如果是表情内容，则整体删除
//            NSInteger end=-1;
//            NSString *lastStr= [text substringWithRange:NSMakeRange(lenght-1, 1)];
//            if([lastStr isEqualToString:@"]"]){
//                NSRange range=[text rangeOfString:@"[" options:NSBackwardsSearch];
//                end=range.location;
//                NSString *faceStr = [text substringFromIndex:end];
//                if([[[ZCUICore getUICore] allExpressionDict] objectForKey:faceStr]==nil){
//                    end = lenght - 1;
//                }
//
//                text=[text substringToIndex:end];
//                _zc_chatTextView.text=text;
//            }else{
                [_zc_chatTextView deleteBackward];
//            }
            
            
            [self textChanged:_zc_chatTextView];
        }
    }else if(action==EmojiActionSend){
        [self doSendMessage];
    }
}

#pragma mark -- 发送图片视频
/**
 *  根据类型获取图片
 *
 *  @param type 点击类型
 */
-(void)getPhotoByType:(SobotImagePickerType) type{
    if(type == SobotImagePickerCamera){
        [self judgmentAuthority];
        return;
    }
    
    [[SobotImagePickerTools shareImagePickerTools] getPhotoByType:type onlyPhoto:NO byUIImagePickerController:[SobotUITools getCurrentVC] start:^(UIImagePickerController * _Nonnull vc) {
        
        if ([vc.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
            // 是否设置相册背景图片
            if ([ZCUIKitTools zcgetPhotoLibraryBgImage]) {
                // 图片是否存在
                if (SobotKitGetImage(@"zcicon_navcbgImage")) {
                    
                    [vc.navigationBar setBarTintColor:[UIColor colorWithPatternImage:SobotKitGetImage(@"zcicon_navcbgImage")]];
                }else{
                    [vc.navigationBar setBarTintColor:[ZCUIKitTools zcgetBgBannerColor]];
                    [vc.navigationBar setTranslucent:YES];
                    [vc.navigationBar setTintColor:[ZCUIKitTools  zcgetTextNolColor]];
                }
            }else{
                // 不设置默认治随主题色
                [vc.navigationBar setBarTintColor:[ZCUIKitTools zcgetBgBannerColor]];
            }
            
            [vc.navigationBar setTranslucent:YES];
        }else{
            [vc.navigationBar setBackgroundColor:[ZCUIKitTools zcgetBgBannerColor]];
        }
        //[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0]
        [vc.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[ZCUIKitTools zcgetTopViewTextColor], NSForegroundColorAttributeName,[ZCUIKitTools zcgetTitleFont], NSFontAttributeName, nil]];
        
        vc.view.backgroundColor = UIColorFromModeColor(SobotColorBgMain);
        // 是否显示预览页面
        vc.allowsEditing=[ZCUICore getUICore].kitInfo.showPhotoPreview;

    }block:^(NSString * _Nullable filePath, SobotImagePickerFileType type, NSDictionary * _Nullable duration) {
        if(type == SobotImagePickerFileTypeVideo){
//            ,SobotImagePickerFileTypeVideo, @{@"video":[NSURL URLWithString:resultPath],@"image":filePath})
            [self sendMessageOrFile:filePath type:SobotMessageTypeVideo duration:@"" dict:@{@"cover":duration[@"image"]}];
        }else if(type == SobotImagePickerFileTypeImage){
            [self sendMessageOrFile:filePath type:SobotMessageTypePhoto duration:@"" dict:nil];
        }
    }];
}


- (void)judgmentAuthority{
    
   NSString *authStatustr =  [SobotCache getLocalParamter:@"sobot_AVAuthorizationStatus"];
    if(sobotConvertToString(authStatustr).length > 0){
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if( authStatus == AVAuthorizationStatusNotDetermined || authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *aleartMsg = @"";
                aleartMsg = SobotKitLocalString(@"请在《设置 - 隐私 - 相机》选项中，允许访问您的相机");
                
                [SobotUITools showAlert:nil message:aleartMsg cancelTitle:SobotKitLocalString(@"取消") titleArray:nil viewController:[SobotUITools getCurrentVC] confirm:^(NSInteger buttonTag) {
                    // 没有权限 并且进入了 拍照页面 退出
                    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
                    if(authStatus == AVAuthorizationStatusNotDetermined || authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
                        if(!sobotIsNull(self.videoVC)){
                            [self.videoVC dismissViewControllerAnimated:YES completion:nil];
                        }
                        // 没有权限才去跳转，有就不跳转了
                        if(buttonTag == 0){
                            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 18) {
                                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                                        if (success) {
                                            NSLog(@"URL successfully opened.");
                                        } else {
                                            NSLog(@"Failed to open URL.");
                                        }
                                    }];
                            }else{
                                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                                   [[UIApplication sharedApplication] openURL:url];
                                }
                            }
                        }
                    }
                }];
            });
            return;
        }
        
    }

    [self openCamera];
}

- (void)openCamera{
    __weak  ZCUIChatKeyboard *keyboardSelf  = self;
    ZCVideoViewController *vc = [[ZCVideoViewController alloc] init];
    self.videoVC = vc;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [vc setOperationResultBlock:^(id  _Nonnull item) {
        if([item isKindOfClass:[UIImage class]]){
            [ZCUIChatKeyboard sendImage:item withView:keyboardSelf.ppView result:^(NSString * _Nullable filePath, SobotImagePickerFileType type, NSDictionary * _Nullable duration) {
                [keyboardSelf sendMessageOrFile:filePath type:SobotMessageTypePhoto duration:@"" dict:nil];
            }];
        }else{
            
            NSDictionary *video = (NSDictionary *)item;
            if (video == nil) {
                return ;
            }
            NSURL *videoUrl = video[@"video"];
            if (videoUrl != nil) {
                NSString *filePath = sobotConvertToString(video[@"image"]);
                NSString *videoUrlStr = videoUrl.absoluteString;
                if ([videoUrlStr hasPrefix:@"file:///"]) {
                    videoUrlStr = [videoUrlStr stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                    videoUrl = [NSURL URLWithString:videoUrlStr];
                }
                [keyboardSelf sendMessageOrFile:sobotUrlDecodedString(videoUrl.absoluteString) type:SobotMessageTypeVideo duration:@"" dict:@{@"cover":filePath}];
            }
        }
    }];
    [[SobotUITools getCurrentVC] presentViewController:vc animated:YES completion:^{
        
    }];
    
}


+(void)sendImage:(UIImage *) image withView:(UIView *)zc_sourceView result:(DidFinishPickingMediaBlock)finshBlock{
    
    UIImage *originImage = image;
    if (image.imageOrientation != UIImageOrientationUp){
        // 这里需要注意iOS17的问题 size 里面不能有为0的场景
        if(image.size.width >0 && image.size.height >0){
            UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
            [image drawInRect:(CGRect){0, 0, image.size}];
            originImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
    }
    
    if (originImage) {
        NSData * imageData =UIImageJPEGRepresentation(originImage, 0.75f);
        NSString * fname = [NSString stringWithFormat:@"/sobot/image100%ld.jpg",(long)[NSDate date].timeIntervalSince1970];
        sobotCheckPathAndCreate(sobotGetDocumentsFilePath(@"/sobot/"));
        NSString *fullPath=sobotGetDocumentsFilePath(fname);
        [imageData writeToFile:fullPath atomically:YES];
        CGFloat mb=imageData.length/1024/1024;
        if(mb>20){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[SobotToast shareToast] showToast:SobotKitLocalString(@"图片大小需小于20M!") duration:1.0  position:SobotToastPositionCenter];
                });
            return;
        }
        
        if (finshBlock) {
            finshBlock(fullPath,SobotImagePickerFileTypeImage,nil);
        }
    }
}

#pragma mark - 是否显示更多按钮
-(NSMutableArray *)getMoreBtnTitles{
    NSMutableArray *titles = [NSMutableArray array];
    ZCLibCusMenu *menu1 = [[ZCLibCusMenu alloc] init];
    menu1.imgName = @"zcicon_bottombar_satisfaction";
    menu1.imgNamePress = @"zcicon_bottombar_satisfaction";
    menu1.extModelType = 2;
    menu1.title = SobotKitLocalString(@"服务评价");
    menu1.lableId = BUTTON_EVALUATION;
    
    ZCLibCusMenu *menu2 = [[ZCLibCusMenu alloc] init];
    menu2.imgName = @"zcicon_bottombar_message";
    menu2.imgNamePress = @"zcicon_bottombar_message";
    menu2.title = SobotKitLocalString(@"留言");
    menu2.extModelType = 1;
    menu2.lableId = BUTTON_LEAVEMESSAGE;
    
    ZCLibCusMenu *menu3 = [[ZCLibCusMenu alloc] init];
    menu3.imgName = @"zcicon_sendpictures";
    menu3.imgNamePress = @"zcicon_sendpictures";
    menu3.title = SobotKitLocalString(@"图片");
    menu3.extModelType = 7;
    menu3.lableId = BUTTON_ADDPHOTO;
    
    ZCLibCusMenu *menu4 = [[ZCLibCusMenu alloc] init];
    menu4.imgName = @"zcicon_takingpictures";
    menu4.imgNamePress = @"zcicon_takingpictures";
    menu4.title = SobotKitLocalString(@"拍摄");
    menu4.extModelType = 9;
    menu4.lableId = BUTTON_AddPhotoCamera;
    
    ZCLibCusMenu *menu5 = [[ZCLibCusMenu alloc] init];
    menu5.imgName = @"zcicon_choose";
    menu5.imgNamePress = @"zcicon_choose";
    menu5.title = SobotKitLocalString(@"文件");
    menu5.extModelType = 3;
    menu5.lableId = BUTTON_AddDocumentFile;
    
    ZCLibCusMenu *menu7 = [[ZCLibCusMenu alloc] init];
    menu7.imgName = @"zcicon_takingvideo";
    menu7.imgNamePress = @"zcicon_takingvideo";
    menu7.title = SobotKitLocalString(@"视频");
    menu7.extModelType = 8;
    menu7.lableId = BUTTON_AddVideo;
    
    NSString *version= [UIDevice currentDevice].systemVersion;
//    （1.留言 2 服务评价 3文件 (4表情  5截图  6自定义跳转链接) 7 图片 8 视频 9 拍摄）
    // 初始化接口返回的
    NSMutableArray *modelList = [ZCUICore getUICore].getLibConfig.appExtModelList;
    if([self getLibConfig].isArtificial){
        modelList = [ZCUICore getUICore].getLibConfig.appExtModelManList;
    }
    if(!sobotIsNull(modelList) && modelList.count > 0){
        for (ZCLibExtModel *extModel in modelList) {
            if([extModel.extModelType intValue] == 1){
                menu2.extModelPhoto = extModel.extModelPhoto;
                menu2.title = SobotKitLocalString(sobotConvertToString(extModel.extModelName));
                menu2.isSave = YES;
                if ([self getZCLibConfig].msgFlag == 0) {
                    [titles addObject:menu2];
                }
            }else if ([extModel.extModelType intValue] == 2){
                menu1.extModelPhoto = extModel.extModelPhoto;
                menu1.title = SobotKitLocalString(sobotConvertToString(extModel.extModelName));
                menu1.isSave = YES;
                [titles addObject:menu1];
            }else if ([extModel.extModelType intValue] == 3){
                menu5.extModelPhoto = extModel.extModelPhoto;
                menu5.title = SobotKitLocalString(sobotConvertToString(extModel.extModelName));
                menu5.isSave = YES;
                // [self getZCLibConfig].isArtificial &&
                if ( version.doubleValue >= 12.0) {
                    [titles addObject:menu5];
                }
            }else if ([extModel.extModelType intValue] == 7){
                menu3.extModelPhoto = extModel.extModelPhoto;
                menu3.title = SobotKitLocalString(sobotConvertToString(extModel.extModelName));
                menu3.isSave = YES;
//                if ([self getZCLibConfig].isArtificial) {
                    [titles addObject:menu3];
//                }
            }else if ([extModel.extModelType intValue] == 8){
                menu7.extModelPhoto = extModel.extModelPhoto;
                menu7.title = SobotKitLocalString(sobotConvertToString(extModel.extModelName));
                menu7.isSave = YES;
//                if ([self getZCLibConfig].isArtificial) {
                    [titles addObject:menu7];
//                }
            }else if ([extModel.extModelType intValue] == 9){
                menu4.extModelPhoto = extModel.extModelPhoto;
                menu4.title = SobotKitLocalString(sobotConvertToString(extModel.extModelName));
                menu4.isSave = YES;
//                if ([self getZCLibConfig].isArtificial) {
                    [titles addObject:menu4];
//                }
            }
        }
    }
    
    
    // 机器人的模式
//    if (![self getZCLibConfig].isArtificial || [ZCUICore getUICore].isAfterConnectUser) {
//        if ([self getZCLibConfig].msgFlag == 0) {
////            titles = [NSMutableArray arrayWithObjects:menu2,menu1, nil];
//            if(menu2.isSave){
//                [titles addObject:menu2];
//            }
//            if(menu1.isSave){
//                [titles addObject:menu1];
//            }
//        }else{
////            titles = [NSMutableArray arrayWithObjects:menu1, nil];
//            if(menu1.isSave){
//                [titles addObject:menu1];
//            }
//        }
//    }else{
//        //        titles = [NSMutableArray arrayWithObjects:menu3,menu5,menu4,menu1, nil];
//        //人工的模式
//        NSString *version= [UIDevice currentDevice].systemVersion;
//        if(version.doubleValue >= 12.0) {
//            // 针对 12.0 以上的iOS系统进行处理
//            // 是否开启留言,并且不是留言转离线消息
//           if ([self getZCLibConfig].msgFlag == 0 && [self getZCLibConfig].msgToTicketFlag != 2) {
////               titles = [NSMutableArray arrayWithObjects:menu3,menu4,menu5,menu2,menu1, nil];
//               if(menu3.isSave){
//                   [titles addObject:menu3];
//               }
//               if(menu4.isSave){
//                   [titles addObject:menu4];
//               }
//               if(menu5.isSave){
//                   [titles addObject:menu5];
//               }
//               if(menu2.isSave){
//                   [titles addObject:menu2];
//               }
//               if(menu1.isSave){
//                   [titles addObject:menu1];
//               }
//               if(menu7.isSave){
//                   [titles addObject:menu7];
//               }
//           }else{
////               titles = [NSMutableArray arrayWithObjects:menu3,menu4,menu5,menu1, nil];
//               if(menu3.isSave){
//                   [titles addObject:menu3];
//               }
//               if(menu4.isSave){
//                   [titles addObject:menu4];
//               }
//               if(menu5.isSave){
//                   [titles addObject:menu5];
//               }
//               if(menu1.isSave){
//                   [titles addObject:menu1];
//               }
//               if(menu7.isSave){
//                   [titles addObject:menu7];
//               }
//           }
//            
//        }else{
//            // 针对 12.0 以下的iOS系统进行处理
//            if ([self getZCLibConfig].msgFlag == 0 && [self getZCLibConfig].msgToTicketFlag != 2) {
////                titles = [NSMutableArray arrayWithObjects:menu3,menu4,menu2,menu1, nil];
//                if(menu3.isSave){
//                    [titles addObject:menu3];
//                }
//                if(menu4.isSave){
//                    [titles addObject:menu4];
//                }
//                if(menu2.isSave){
//                    [titles addObject:menu2];
//                }
//                if(menu1.isSave){
//                    [titles addObject:menu1];
//                }
//                if(menu7.isSave){
//                    [titles addObject:menu7];
//                }
//            }else{
////                titles = [NSMutableArray arrayWithObjects:menu3,menu4,menu1, nil];
//                if(menu3.isSave){
//                    [titles addObject:menu3];
//                }
//                if(menu4.isSave){
//                    [titles addObject:menu4];
//                }
//                if(menu1.isSave){
//                    [titles addObject:menu1];
//                }
//                if(menu7.isSave){
//                    [titles addObject:menu7];
//                }
//            }
//        }
//       
//       // 发送定位
//        if([ZCUICore getUICore].kitInfo.canSendLocation){
//            ZCLibCusMenu *menu6 = [[ZCLibCusMenu alloc] init];
//            menu6.imgName = @"zcicon_location";
//            menu6.imgNamePress = @"zcicon_location";
//            menu6.title = SobotKitLocalString(@"位置");
//            menu6.lableId = BUTTON_AddLocation;
//            [titles addObject:menu6];
//        }
//    }

    
    if([ZCUICore getUICore].kitInfo.cusMoreArray!=nil && [ZCUICore getUICore].kitInfo.cusMoreArray.count > 0 && [self getZCLibConfig].isArtificial) {
        for (ZCLibCusMenu  *item in [ZCUICore getUICore].kitInfo.cusMoreArray) {
            item.lableId = 1000;
            if(item.extModelType == 1){
                menu2.extModelPhoto = item.extModelPhoto;
            }else if (item.extModelType == 2){
                menu1.extModelPhoto = item.extModelPhoto;
            }else if (item.extModelType == 3){
                menu5.extModelPhoto = item.extModelPhoto;
            }else if (item.extModelType == 7){
                menu3.extModelPhoto = item.extModelPhoto;
            }else if (item.extModelType == 8){
                menu7.extModelPhoto = item.extModelPhoto;
            }else if (item.extModelType == 9){
                menu4.extModelPhoto = item.extModelPhoto;
            }else{
                [titles addObject:item];
            }
        }
    }
    if([ZCUICore getUICore].kitInfo.cusRobotMoreArray!=nil && [ZCUICore getUICore].kitInfo.cusRobotMoreArray.count > 0 && ![self getZCLibConfig].isArtificial) {
        for (ZCLibCusMenu  *item in [ZCUICore getUICore].kitInfo.cusRobotMoreArray) {
            item.lableId = 1000;
            if(item.extModelType == 1){
                menu2.extModelPhoto = item.extModelPhoto;
            }else if (item.extModelType == 2){
                menu1.extModelPhoto = item.extModelPhoto;
            }else if (item.extModelType == 3){
                menu5.extModelPhoto = item.extModelPhoto;
            }else if (item.extModelType == 7){
                menu3.extModelPhoto = item.extModelPhoto;
            }else if (item.extModelType == 8){
                menu7.extModelPhoto = item.extModelPhoto;
            }else if (item.extModelType == 9){
                menu4.extModelPhoto = item.extModelPhoto;
            }else{
                [titles addObject:item];
            }
        }
    }
    
    
    if([ZCUICore getUICore].kitInfo.hideMenuSatisfaction){
        [titles removeObject:menu1];
    }
    // 隐藏所有留言，或人工状态隐藏留言
    if([ZCUICore getUICore].kitInfo.hideMenuLeave || ([ZCUICore getUICore].kitInfo.hideMenuManualLeave && [self getZCLibConfig].isArtificial)){
        [titles removeObject:menu2];
    }
    if([ZCUICore getUICore].kitInfo.hideMenuPicture){
        [titles removeObject:menu3];// 删除图片
        [titles removeObject:menu7];// 删除视频
    }
    if([ZCUICore getUICore].kitInfo.hideMenuCamera){
        [titles removeObject:menu4];
    }
    if([ZCUICore getUICore].kitInfo.hideMenuFile){
        [titles removeObject:menu5];
    }
    return titles;
}

#pragma mark -- More 图片、拍摄、满意度 按钮模块
- (void)createMoreItems{
    if (self.zc_moreView != nil) {
        [_zc_moreView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        _facePageControl.hidden = YES;
    }
    NSMutableArray *titles = [self getMoreBtnTitles];
    allSubMenuSize = titles.count;
    [self creatButtonForArray:titles];
    
    [_zc_moreView layoutIfNeeded];
}

#pragma mark -- 创建满意度、留言、相册、评价等按钮
- (void)creatButtonForArray:(NSArray *)titles{
    countMoreHeight = 0;
    if(titles.count == 0){
        return;
    }
    CGFloat width = [self getSourceViewWidth];
    int columns = 3;
    int rows = 2;
    if ([self getSourceViewHeight] < [self getSourceViewWidth]) {
        columns = 6;
        rows = 1;
    }
    
    CGFloat itemW = (width - 24*2 - 16*(columns-1))/columns;
    int allSize  = (int)titles.count;
    if(allSize <= columns){
        rows = 1;
    }
    int pageSize        = rows * columns;
    int pageNum         = (allSize%pageSize==0) ? (allSize/pageSize) : (allSize/pageSize+1);

    
    CGFloat maxPageH = 0;
    for(int i = 0;i<pageNum;i++){
        
        CGFloat pageH = 0;
        // 每一行的最大高
        CGFloat lineH = 0;
        for(int j=0;j<pageSize;j++){
            // 没有了
            if((i*pageSize+j)>=allSize){
                if(lineH > 0){
                    pageH = pageH + lineH;
                }
                break;
            }
            
            if(j%columns == 0 && j > 0){
                pageH = pageH + lineH;
                // 重新计算另一行的最大高度
                lineH = 0;
            }
            
            //计算每一个表情按钮的坐标和在哪一屏
            CGFloat mx = i * width + (j%columns) * itemW + 24 + (j%columns)*16;
            
            int c = j/columns;
            CGFloat my = pageH + 24 + c*20;
            
            
            ZCLibCusMenu *menu = titles[i*pageSize+j];
            
            SobotImageButton *imgBtn = [[SobotImageButton alloc] init];
            imgBtn.backgroundColor = UIColor.clearColor;
            [_zc_moreView addSubview:imgBtn];
            imgBtn.titleLabel.font = SobotFont12;
            imgBtn.titleColor = UIColorFromKitModeColor(SobotColorTextMain);
            imgBtn.image = SobotKitGetImage(@"zcicon_bottombar_conversation");
           //    imgBtn.titleColorSelected = UIColorFromKitModeColor(SobotColorTextSub);
           //    imgBtn.imageSelected = SobotKitGetImage(@"zcicon_bottombar_satisfaction");
            imgBtn.titleLabel.text = sobotConvertToString(menu.title);
            imgBtn.clickBtn.tag = menu.lableId;
            imgBtn.clickBtn.obj = menu;
            
            if(sobotConvertToString(menu.extModelPhoto).length > 0){
                [imgBtn.imageView loadWithURL:[NSURL URLWithString:sobotConvertToString(menu.extModelPhoto)] placeholer:SobotKitGetImage(sobotConvertToString(menu.imgName)) showActivityIndicatorView:NO];
            }else{
                [imgBtn.imageView setImage:SobotKitGetImage(sobotConvertToString(menu.imgName))];
            }
            [imgBtn configLocation:0 inset:UIEdgeInsetsMake(0, 0, 0, 0) space:10 imageSize:CGSizeMake(30, 30)];
            [imgBtn addTarget:self action:@selector(buttonClick:)];
            
            [_zc_moreView addConstraint:sobotLayoutEqualWidth(itemW, imgBtn, NSLayoutRelationEqual)];
            [_zc_moreView addConstraints:sobotLayoutPaddingView(my, 0, mx, 0, imgBtn, _zc_moreView)];
            
            [imgBtn layoutIfNeeded];
            
            CGFloat curH = imgBtn.frame.size.height;
            if(curH > lineH){
                lineH = curH;
            }
            
            // 最后一个，添加本行高度
            if(lineH > 0 && j == (pageSize-1)){
                pageH = pageH + lineH;
            }
        }
        if(maxPageH < pageH){
            maxPageH = pageH;
        }
    }
    
    countMoreHeight = maxPageH + 48 + (rows-1)*20;
    _zc_moreView.contentSize = CGSizeMake(pageNum * width, 0);
    if(pageNum > 1){
        _facePageControl.numberOfPages = pageNum;
        [_facePageControl setFrame:CGRectMake([self getSourceViewWidth]/2-150, [self getSourceViewHeight]-30, 300, 20)];
        _facePageControl.hidden = NO;
        _facePageControl.currentPageIndicatorTintColor = [ZCUIKitTools zcgetServerConfigBtnBgColor];
//        _facePageControl.backgroundColor = UIColor.redColor;
        
        countMoreHeight = countMoreHeight + 20;
    }
    
}


-(SobotButton *)createItemMenuButton:(ZCLibCusMenu *) menu{
    SobotButton * buttons = (SobotButton*)[SobotUITools createZCButton];
    buttons.tag = menu.lableId;
    buttons.obj = menu;
    buttons.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [buttons.titleLabel setBackgroundColor:[UIColor clearColor]];
    [buttons.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [buttons addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
//    [buttons setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 10, 0)];
//    [buttons setImage:SobotKitGetImage(menu.imgName) forState:UIControlStateNormal];
    
    UILabel *lbl = [[UILabel alloc] init];
    [lbl setText:menu.title];
    [lbl setFont:SobotFont12];
    lbl.numberOfLines = 2;
    [lbl setTextAlignment:NSTextAlignmentCenter];
//    [lbl setTextColor:[ZCUIKitTools zcgetTextNolColor]];
    [lbl setTextColor:UIColorFromModeColor(SobotColorTextMain)];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [buttons addSubview:lbl];

    CGFloat lbh = [SobotUITools getHeightContain:sobotConvertToString(menu.title) font:SobotFont12 Width:80];
    CGFloat lh = 21;
    if (lbh >= 30) {
        lh = 30;
        [lbl setFont:SobotFont8];
    }else if (lbh >= 21){
        lh = 30;
    }
    
    [buttons addConstraint:sobotLayoutEqualHeight(lh, lbl, NSLayoutRelationEqual)];
    [buttons addConstraints:sobotLayoutPaddingView(0, -5, 1, -1, lbl, buttons)];
    
    SobotImageView *iconView = [[SobotImageView alloc]init];
    [buttons addSubview:iconView];
    [buttons addConstraint:sobotLayoutEqualHeight(30, iconView, NSLayoutRelationEqual)];
    [buttons addConstraint:sobotLayoutEqualWidth(30, iconView, NSLayoutRelationEqual)];
    [buttons addConstraint:sobotLayoutEqualCenterY(-10, iconView, buttons)];
    [buttons addConstraint:sobotLayoutEqualCenterX(0, iconView, buttons)];
    iconView.contentMode = 3;
    if(sobotConvertToString(menu.extModelPhoto).length > 0){
        [iconView loadWithURL:[NSURL URLWithString:sobotConvertToString(menu.extModelPhoto)] placeholer:SobotKitGetImage(sobotConvertToString(menu.imgName)) showActivityIndicatorView:NO];
    }else{
        [iconView setImage:SobotKitGetImage(sobotConvertToString(menu.imgName))];
    }
    
    return buttons;
}

#pragma mark 发送监听 UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if ([@"\n" isEqualToString:text] == YES)
    {
        //        [textView resignFirstResponder];
//        if ([ZCUICore getUICore].aiAgentAsking && ![[ZCUICore getUICore] getLibConfig].isArtificial) {
//            return NO;
//        }
        [self doSendMessage];
        return NO;
    }
    
    //    [SobotLog logDebug:@"%@",[[UITextInputMode currentInputMode]primaryLanguage]];
    // 不输入Emoji
    if ([[[UIApplication sharedApplication]textInputMode].primaryLanguage isEqualToString:@"emoji"]) {
        return NO;
    }
    
    
    if([text length]==0){
        if(range.length<1){
            return YES;
        }else{
            
            [self textChanged:_zc_chatTextView];
        }
    }else{
        // 大于1000不让继续输入
        if([textView.text length] >= 1000){
            return NO;
        }
    }
    return YES;
}

#pragma mark textChanged
-(void)textChanged:(id) sender{
    [self textViewDidChange:_zc_chatTextView];
    
}

//
-(void)textViewDidBeginEditing:(UITextView *)textView{
    if(![textView.window isKeyWindow]){
        [textView.window makeKeyAndVisible];
    }
    //    WSLog(@"键盘开始输入=====");
    
    // 当textview开始编辑的时候 影藏 _phototView
    [UIView animateWithDuration:0.25 animations:^{
        
    } completion:^(BOOL finished) {
    
        [self hideAllViewWithOutKeyboard];
        
        [self addAutoListView];
        
    }];
}


-(void)textViewDidChange:(UITextView *)textView{
    CGFloat textContentSizeHeight = _zc_chatTextView.contentSize.height;
    if (iOS7) {
        CGRect textFrame = [[_zc_chatTextView layoutManager]usedRectForTextContainer:[_zc_chatTextView textContainer]];
        if (textFrame.size.height <35) {
            textFrame.size.height = 35;
        }
        textContentSizeHeight = textFrame.size.height;
        // 满行以后，会抖动，不加也不影响
        if(textContentSizeHeight > 35){
            textContentSizeHeight = textContentSizeHeight + 10;
        }
    }
    [ZCUICore getUICore].isKeyBoardIsClear = NO;
    //发送完成重置
    if(_zc_chatTextView.text==nil || [@"" isEqual:_zc_chatTextView.text]){
        textContentSizeHeight=35;
        [_zc_chatTextView setContentOffset:CGPointMake(0, 0)];
        [ZCUICore getUICore].isKeyBoardIsClear = YES;
    }
    
    // 判断文字过小
    if(textContentSizeHeight<35){
        textContentSizeHeight=35;
    }
    // 每次不一样先销毁 再创建
    [self addAutoListView];
    
    // 已经最大行高了
    if (textContentSizeHeight > [self getTextMaxHeiht] && _zc_chatTextView.frame.size.height >= [self getTextMaxHeiht]) {
        [_zc_chatTextView setContentOffset:CGPointMake(0, textContentSizeHeight-_zc_chatTextView.frame.size.height)];
        return;
    }
    
    CGFloat lastHeight = SobotViewHeight(_zc_chatTextView);
    
    CGFloat textHegiht = 35;
    // 计算应该改变多少行高
    if(textContentSizeHeight>35){
        float x=textContentSizeHeight-35;
        if(textContentSizeHeight>[self getTextMaxHeiht]){
            x = [self getTextMaxHeiht] - 35;
        }
        textHegiht = 35 + x;
    }
    
    // 已经更改过了
    if(lastHeight == textHegiht){
        return;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self->_chatTextConsHeight.constant = textHegiht;
    }];
    
    self->_viewBottomConsSpace.constant = -self->_zc_keyBoardHeight;
    [self->_zc_chatTextView updateConstraints];
    [self->_zc_bottomView updateConstraints];
    [self->_btnMore updateConstraints];
    [self->_btnFace updateConstraints];
    [self showTableFrameByKeyboardChanged];
}

-(int)getTextLines{
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = 5; //[ZCUIKitTools zcgetChatLineSpacing];// 字体的行间距
    NSDictionary *attributes = @{
                                     NSFontAttributeName:[ZCUIKitTools zcgetListKitTitleFont],
                                     NSParagraphStyleAttributeName:paragraphStyle
                                     };
    CGSize lineSize = [_zc_chatTextView.text sizeWithAttributes:attributes];// [_zc_chatTextView.text sizeWithFont:_zc_chatTextView.font];
    return ceil(_zc_chatTextView.contentSize.height/lineSize.height);
}

-(CGFloat) getTextMaxHeiht{
    return  160;
//    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
//    paragraphStyle.lineSpacing = 5;//[ZCUIKitTools zcgetChatLineSpacing];// 字体的行间距
//    NSDictionary *attributes = @{
//                                     NSFontAttributeName:[ZCUIKitTools zcgetListKitTitleFont],
//                                     NSParagraphStyleAttributeName:paragraphStyle
//                                     };
//    _zc_chatTextView.typingAttributes = attributes;
//    CGSize lineSize = [_zc_chatTextView.text sizeWithAttributes:attributes];//[_zc_chatTextView.text sizeWithFont:_zc_chatTextView.font];
////    return lineSize.height*6+12;
//    return lineSize.height*4+12 + 4;
    
}

-(CGFloat) getKeyboardHeight{
    return _zc_keyBoardHeight;
}


-(void)hideAllViewWithOutKeyboard{
    
    CGFloat emojiViewHeight = EmojiViewHeight;
    if (SobotViewHeight(self->_ppView) < SobotViewWidth(self->_ppView)) {
        emojiViewHeight = EmojiViewHorizontalHeight;
    }
    
    self->_viewMoreConsHeight.constant = countMoreHeight;
    self->_viewEmojiConsHeight.constant = emojiViewHeight;
    
    // 隐藏除系统键盘的其他视图
    self.zc_moreView.hidden = YES;
    _bottomlineView.hidden = YES;
    self.emojiView.hidden = YES;
    
    // 恢复原始值
    [self->_zc_moreView updateConstraints];
    [self->_emojiView updateConstraints];
    
    
    [[ZCAutoListView getAutoListView] dissmiss];
}

#pragma mark 键盘隐藏 keyboard notification
-(void)hideKeyboard{
    [_zc_listTable removeGestureRecognizer:_tapRecognizer];
    if(self->_zc_keyBoardHeight > 0){
        [self setItemButtonDefaultStatus];
    }
    [self->_zc_chatTextView resignFirstResponder];
    
    [[ZCAutoListView getAutoListView] dissmiss];
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self->_zc_keyBoardHeight = 0;
        self->_viewBottomConsSpace.constant = 0;
        self->_viewMoreConsHeight.constant = 0;
        self->_viewEmojiConsHeight.constant = 0;
        self->_zc_moreView.hidden=YES;
        self->_bottomlineView.hidden = YES;
        self->_emojiView.hidden=YES;
        [self->_zc_bottomView layoutIfNeeded];
        [self->_ppView layoutIfNeeded];
    }];
    
}


- (void)handleKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    // 横屏需要添加 keyboardFrameDidChange监听
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameDidChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAnywhere:)];
    
    _tapRecognizer.delegate  = self;
    _ppView.userInteractionEnabled=YES;
    _zc_bottomView.userInteractionEnabled = YES;
}

-(void)removeKeyboardObserver{
    [self hideKeyboard];
    _tapRecognizer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark 手势代理 冲突的问题
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([NSStringFromClass([touch.view superclass]) isEqualToString:@"UIResponder"]) {
        return NO;
    }
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"SobotEmojiLabel"]) {
        [self performSelector:@selector(hideKeyboard) withObject:nil afterDelay:0.35];
        return NO;
    }
    
    return YES;
}

//屏幕点击事件
- (void)didTapAnywhere:(UITapGestureRecognizer *)recognizer {
    [self hideKeyboard];
}


#pragma mark -  //键盘隐藏
- (void)keyboardWillHide:(NSNotification *)notification {
    if(_zc_keyBoardHeight == 0){
        return;
    }
    
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [[ZCAutoListView getAutoListView] dissmiss];
    if(!showRichKeyboard){
        _zc_keyBoardHeight = 0;
    }
    if(!_zc_chatTextView.isFirstResponder){
       return ;
    }
    
    // 显示其它键盘，重复执行会抖动
    if(showRichKeyboard){
        return;
    }
    
    
    self->_viewBottomConsSpace.constant = 0;
    
    UIViewAnimationCurve curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    UIViewAnimationOptions options = (UIViewAnimationOptions)curve << 16;
    [UIView animateWithDuration:animationDuration delay:0.0 options:options animations:^{
        [self->_zc_bottomView layoutIfNeeded];
        [self->_zc_listTable layoutIfNeeded];
        [self->_ppView layoutIfNeeded];
    } completion:^(BOOL finished) {
        
        [self showTableFrameByKeyboardChanged];
    }];
}

#pragma mark -  //键盘显示
- (void)keyboardWillShow:(NSNotification *)notification {
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    _zc_keyBoardHeight = [[[notification userInfo] objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue].size.height;
    [ZCUICore getUICore].zc_keyBoardHeight = _zc_keyBoardHeight;
    if(_zc_keyBoardHeight > 0){
        _zc_keyBoardHeight = _zc_keyBoardHeight - XBottomBarHeight;
    }
    if(!_zc_chatTextView.isFirstResponder){
        return ;
    }
    
    // 设置按钮原本的图标
    [self setItemButtonDefaultStatus];
    self->_viewBottomConsSpace.constant = -self->_zc_keyBoardHeight;
    [self->_zc_bottomView layoutIfNeeded];
    [self->_zc_listTable layoutIfNeeded];
    [self->_ppView layoutIfNeeded];
    UIViewAnimationCurve curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    UIViewAnimationOptions options = (UIViewAnimationOptions)curve << 16;
    [UIView animateWithDuration:animationDuration delay:0.0 options:options animations:^{
        
    } completion:^(BOOL finished) {
        [self showTableFrameByKeyboardChanged];
    }];
    [_zc_listTable addGestureRecognizer:_tapRecognizer];
}


// 显示引用消息
-(void)showReferenceMessage:(SobotChatMessage *) rModel{
    if([self getLibConfig].msgAppointFlag == 0){
        [self hideReferenceView];
        return;
    }
    _layoutReferenceH.constant = 40;
    _layoutReferenceBottom.constant = -7;
    self.referenceMessage = rModel;
    
    [self createReferenceSubViews];
    
    if(!sobotIsNull(rModel)){
        NSString *tips = @"";
        if(rModel.senderType == 0 && rModel.appointType == 0){
            tips = SobotKitLocalString(@"我");
        }else if(rModel.senderType == 1){
//            tips = SobotKitLocalString(@"机器人");// SDK是 用户视角，除了自己都显示客服
            tips = SobotKitLocalString(@"客服");
        }else{
            tips = SobotKitLocalString(@"客服");
        }
        _labReferencMessage.text = [SobotHtmlCore removeAllHTMLTag:[NSString stringWithFormat:@"%@ : %@",tips, [ZCPlatformTools getLastMessage:rModel urlRegular:[ZCUIKitTools zcgetUrlRegular]]]];
        
        // 引用的时候，直接显示键盘
        [self.zc_chatTextView becomeFirstResponder];
    }else{
        _labReferencMessage.text = @"";
    }
    // 切换输入框的样式并且拉起键盘
    if(!_btnVoicePress.isHidden){
        [self buttonClick:(SobotButton*)_btnVoice];
        [_zc_chatTextView becomeFirstResponder];
    }
}

-(void)hideReferenceView{
    if(_labReferencMessage!=nil){
        _labReferencMessage.text = @"";
        _btnClearReferenceMsg.hidden = YES;
    }
    self.referenceMessage = nil;
    _layoutReferenceH.constant = 0;
    _layoutReferenceBottom.constant = 0;
}

-(void)createReferenceSubViews{
    if(_labReferencMessage!=nil){
        _btnClearReferenceMsg.hidden = NO;
        return;
    }
    
    _labReferencMessage = ({
        UILabel *iv = [[UILabel  alloc] init];
        iv.numberOfLines = 1;
        iv.textColor = UIColorFromKitModeColor(SobotColorTextSub);
        iv.font = SobotFont13;
        [iv setTextAlignment:NSTextAlignmentLeft];
        [self.referenceView addSubview:iv];
        iv.text = @"";
        
        [_referenceView addConstraint:sobotLayoutPaddingLeft(12, iv, _referenceView)];
        [_referenceView addConstraint:sobotLayoutPaddingRight(-38, iv, _referenceView)];
        [_referenceView addConstraint:sobotLayoutEqualCenterY(0, iv, _referenceView)];
        
        iv;
    });
    
    _btnClearReferenceMsg = ({
        UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
        iv.backgroundColor = UIColor.clearColor;
        [iv setImage:SobotKitGetImage(@"zcicon_add_clear") forState:UIControlStateNormal];
        iv.contentHorizontalAlignment= UIControlContentHorizontalAlignmentFill;//水平方向拉伸
        iv.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;//垂直方向拉伸
        [self.referenceView addSubview:iv];
        
        [_referenceView addConstraints:sobotLayoutSize(14, 14, iv, NSLayoutRelationEqual)];
        [_referenceView addConstraint:sobotLayoutPaddingRight(-12, iv, _referenceView)];
        [_referenceView addConstraint:sobotLayoutEqualCenterY(0, iv, _referenceView)];
        
        [iv addTarget:self action:@selector(hideReferenceView) forControlEvents:UIControlEventTouchUpInside];
        
        iv;
    });
}

-(void)hideKeyboardUI{
//    if (self.plView) {
//        [self.plView setHidden:YES];
//    }
    
}
-(void)showKeyboardUI{
//    if (self.plView) {
//        [self.plView setHidden:NO];
//    }
   
}

- (void)dealloc{
    [[ZCAutoListView getAutoListView] dissmiss];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    //    NSLog(@"键盘被清理掉了");
}
//-(void)keyboardFrameDidChange:(NSNotification*)notice{
//    NSDictionary * userInfo = notice.userInfo;
//    NSValue * endFrameValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    //    CGRect endFrame = endFrameValue.CGRectValue;
    //    NSLog(@"%@",NSStringFromCGRect(endFrame));
//}

- (void)didRotate:(NSNotification *)notification {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
        // 横屏
//        NSLog(@"横屏");
    } else if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown) {
        // 竖屏
//        NSLog(@"竖屏");
    }
    if (_viewReConnectConsHeight.constant >0) {
        [self showReConnectView];
    }
}


@end
