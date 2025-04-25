//
//  SobotChatBaseCell.m
//  SobotKit
//
//  Created by zhangxy on 2025/1/17.
//

#import "SobotChatBaseCell.h"

@interface SobotChatBaseCell()
{
    
}

@property(nonatomic,strong) NSLayoutConstraint *layoutTimeHeight;
@property(nonatomic,strong) NSLayoutConstraint *layoutTimeTop;
@property(nonatomic,strong) NSLayoutConstraint *layoutChatViewTop;


@end

@implementation SobotChatBaseCell


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

-(void)createItemsView{
    _lblTime=({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentCenter];
        [iv setFont:[ZCUIKitTools zcgetListKitTimeFont]];
        [iv setTextColor:[ZCUIKitTools zcgetTimeTextColor]];
        [iv setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:iv];
        [self.contentView addConstraints:sobotLayoutPaddingView(0, 0, SobotChatPaddingHSpace, -SobotChatPaddingHSpace, iv, self.contentView)];
        _layoutTimeTop = sobotLayoutPaddingTop(SobotSpace20, iv, self.contentView);
        _layoutTimeHeight = sobotLayoutEqualHeight(0, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:_layoutTimeHeight];
        [self.contentView addConstraint:_layoutTimeTop];
        iv;
    });
    
    _chatView = ({
        UIView *iv = [[UIView alloc] init];
        iv.backgroundColor = UIColor.clearColor;
        [self.contentView addSubview:iv];
        
        _layoutChatViewTop = sobotLayoutMarginTop(SobotChatMarginVSpace, iv, self.lblTime);
        _layoutChatViewPL = sobotLayoutPaddingLeft(SobotChatPaddingHSpace, iv, self.contentView);
        _layoutChatViewPL = sobotLayoutPaddingRight(-SobotChatPaddingHSpace, iv, self.contentView);
        
        [self.contentView addConstraint:_layoutChatViewTop];
        [self.contentView addConstraint:_layoutChatViewPL];
        [self.contentView addConstraint:_layoutChatViewPR];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(-SobotChatPaddingVSpace, iv, self.contentView)];
        
        iv;
    });
}

-(void)initDataToView:(SobotChatMessage *) message time:(NSString *) showTime{
    self.tempModel = message;
    
    [_lblTime setText:sobotConvertToString(showTime)];
    if(sobotConvertToString(showTime).length > 0){
        _layoutChatViewTop.constant = 20;
        _layoutTimeTop.constant = 20;
        _layoutTimeHeight.constant = 20;
    }else{
        _layoutChatViewTop.constant = 12;
        _layoutTimeTop.constant = 0;
        _layoutTimeHeight.constant = 0;
    }
    self.isShowHeader = NO;
    self.isRight = NO;
    if(message && message.sendType == 0){
        self.isRight = YES;
        
        // 是否显示头像
        if (message.isEmptyHeader || ![ZCUICore getUICore].getLibConfig.showFace || self.tempModel.action == SobotMessageActionTypeLanguage) {
            self.isShowHeader = NO;
        }else{
            self.isShowHeader = YES;
        }
    }
    
    self.maxWidth = self.viewWidth - 60;
    if(self.isShowHeader){
        self.maxWidth = self.viewWidth - 92;
    }
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
