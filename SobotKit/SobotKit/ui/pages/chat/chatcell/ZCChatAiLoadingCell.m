//
//  ZCChatAiLoadingCell.m
//  SobotKit
//
//  Created by lizh on 2025/3/25.
//

#import "ZCChatAiLoadingCell.h"
#import "ZCUIKitTools.h"
#import <SobotChatClient/SobotChatClient.h>
#import "SobotHtmlFilter.h"
#import <SobotCommon/SobotXHCacheManager.h>


@interface ZCChatAiLoadingCell(){
    
}

// 聊天气泡里面的内容
@property(nonatomic,strong) UIView *chatConentView;
@property(nonatomic,strong) NSLayoutConstraint *layoutBottom;
@property(nonatomic,strong) NSLayoutConstraint *layoutHeight;
@property(nonatomic,strong) NSLayoutConstraint *layoutWidth;
@property(nonatomic,strong) UIView *lastView;
@property(nonatomic,strong) NSLayoutConstraint *linkLayoutHeight;

@property(nonatomic,strong) SobotImageView *loadView;
@property(nonatomic,strong) NSLayoutConstraint *loadViewH;
@property(nonatomic,strong) NSLayoutConstraint *loadViewW;
@property(nonatomic,strong) NSLayoutConstraint *chatConentViewH;

@end
@implementation ZCChatAiLoadingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}



-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _chatConentView = [[UIView alloc] init];
        [self.contentView addSubview:_chatConentView];
        _chatConentView.userInteractionEnabled = YES;
        [self.contentView addConstraint:sobotLayoutPaddingTop(ZCChatPaddingVSpace, _chatConentView, self.ivBgView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingHSpace, _chatConentView, self.ivBgView)];
        _layoutBottom = sobotLayoutMarginBottom(-ZCChatCellItemSpace, _chatConentView, self.lblSugguest);
        [self.contentView addConstraint:_layoutBottom];
        _layoutWidth = sobotLayoutEqualWidth(0, _chatConentView, NSLayoutRelationEqual);
        [self.contentView addConstraint:_layoutWidth];
        _chatConentViewH = sobotLayoutEqualHeight(10, _chatConentView, NSLayoutRelationEqual);
        [self.contentView addConstraint:_chatConentViewH];
//        [self createLoadView];
    }
    return self;
}

-(void)createLoadView{
    _loadView = ({
        SobotImageView *iv = [[SobotImageView alloc] init];
        [_chatConentView addSubview:iv];
        [_chatConentView addConstraint:sobotLayoutEqualCenterY(0, iv, _chatConentView)];
        self.loadViewW = sobotLayoutEqualWidth(19, iv, NSLayoutRelationEqual);
        [_chatConentView addConstraint:self.loadViewW];
        self.loadViewH = sobotLayoutEqualHeight(3.5, iv, NSLayoutRelationEqual);
        [_chatConentView addConstraint:self.loadViewH];
        [_chatConentView addConstraint:sobotLayoutPaddingLeft(0, iv, _chatConentView)];
        NSBundle *sBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"SobotKit" ofType:@"bundle"]];
        NSString  *filePath = [sBundle pathForResource:@"Light/zcicon_writering_animate" ofType:@"gif"];
        NSData  *imageData = [NSData dataWithContentsOfFile:filePath];
        [iv setImage:[SobotImageTools sobotAnimatedGIFWithData:imageData]];
        iv;
    });
}

-(void)initDataToView:(SobotChatMessage *) message time:(NSString *) showTime{
    [super initDataToView:message time:showTime];
    _lastView = nil;
    _loadView.hidden = YES;
    CGSize s = CGSizeMake(0, 0);
    [self createLoadView];
    _lastView.hidden = NO;
    s.width = 19 ;
    _loadViewW.constant = 19;
    _loadViewH.constant = 3.5;
    s.height = 22 ;
    
    // 需要设置宽度，否则无法点击
    _layoutWidth.constant = s.width;
    if(s.height == 0){
        _layoutBottom.constant = 0;
    }
    
    [_chatConentView layoutIfNeeded];
    [self setChatViewBgState:s];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
@end
