//
//  ZCChatAiCustomCardCell.m
//  SobotKit
//
//  Created by lizh on 2025/3/19.
//

#import "ZCChatAiCustomCardCell.h"
#import <SobotCommon/SobotCommon.h>
#import "ZCChatAiCustomCardView.h"
#import "ZCChatAiCardView.h"
@interface  ZCChatAiCustomCardCell()<ZCChatAiCardViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic,strong) SobotEmojiLabel * titleLab;
@property (nonatomic,strong) SobotButton *moreBtn;
@property (nonatomic,strong) UIView *contentBgView;

@property (nonatomic,strong) UIView *moreLine;
@property(nonatomic,strong) NSLayoutConstraint *moreLineH;
@property(nonatomic,strong) NSLayoutConstraint *moreBtnH;
@property (nonatomic,strong) NSLayoutConstraint * layoutTitleHeight;
@property (nonatomic,strong) NSLayoutConstraint * layoutTitleWidth;
@property (nonatomic,strong) NSLayoutConstraint *moreLineMT;
@end

@implementation ZCChatAiCustomCardCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self creatView];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self creatView];
    }
    return self;
}


-(SobotEmojiLabel *)titleLab{
    if(!_titleLab){
        _titleLab = [ZCChatBaseCell createRichLabel];
        _titleLab.textColor = [ZCUIKitTools zcgetLeftChatTextColor];
        _titleLab.numberOfLines = 0;
        _titleLab.textColor = UIColorFromKitModeColor(SobotColorTextMain);
        _titleLab.font = SobotFont14;
    }
    return _titleLab;
}


- (void)creatView
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.userInteractionEnabled = YES;
    [self.contentView addSubview:self.titleLab];
    
    [self.contentView addConstraints:sobotLayoutPaddingView(ZCChatPaddingVSpace, 0, ZCChatPaddingHSpace, 0, self.titleLab,self.ivBgView)];
    _layoutTitleWidth = sobotLayoutEqualWidth(ZCChatPaddingHSpace*2, self.titleLab, NSLayoutRelationEqual);
    _layoutTitleHeight = sobotLayoutEqualHeight(22, self.titleLab, NSLayoutRelationEqual);
    [self.contentView addConstraint:_layoutTitleWidth];
    [self.contentView addConstraint:_layoutTitleHeight];
    
    _contentBgView = ({
        UIView *iv = [[UIView alloc]init];
        iv.userInteractionEnabled = YES;
//        iv.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark3);
        [self.contentView addSubview:iv];
        [self.contentView addConstraint:sobotLayoutMarginTop(14, iv, _titleLab)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingHSpace, iv, self.ivBgView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-ZCChatPaddingHSpace, iv, self.ivBgView)];
        iv;
        
    });
    
    _moreLine = ({
        UIView *iv = [[UIView alloc]init];
        [self.contentView addSubview:iv];
        iv.backgroundColor = UIColorFromModeColor(SobotColorBgTopLine);
        [self.contentView addConstraint:sobotLayoutPaddingLeft(0, iv, self.ivBgView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(0, iv, self.ivBgView)];
        self.moreLineMT = sobotLayoutMarginTop(8, iv, self.contentBgView);
        self.moreLineMT.priority = UILayoutPriorityDefaultHigh;
        [self.contentView addConstraint:self.moreLineMT];
        self.moreLineH = sobotLayoutEqualHeight(0.75, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.moreLineH];
        iv.hidden = YES;
        iv;
    });
    
    _moreBtn = ({
        SobotButton *iv = [SobotButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:iv];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(0, iv, self.ivBgView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(0, iv, self.ivBgView)];
        [self.contentView addConstraint:sobotLayoutMarginTop(0, iv, _moreLine)];
        NSLayoutConstraint *moreBtnPB = sobotLayoutPaddingBottom(0, iv, self.ivBgView);
        moreBtnPB.priority = UILayoutPriorityDefaultHigh;
        [self.contentView addConstraint:moreBtnPB];
        CGFloat btnH = [SobotUITools getMaxHeightContain:SobotKitLocalString(@"查看更多") font:SobotFont14 width:self.maxWidth];
        btnH = btnH + 24;
        self.moreBtnH = sobotLayoutEqualHeight(btnH, iv, NSLayoutRelationEqual);
        self.moreBtnH.priority = UILayoutPriorityDefaultHigh;
        [iv addTarget:self action:@selector(moreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [iv setTitle:SobotKitLocalString(@"查看更多") forState:0];
        iv.titleLabel.font = SobotFont14;
        [iv setTitleColor:[ZCUIKitTools zcgetServerConfigBtnBgColor] forState:0];
        [self.contentView addConstraint:self.moreBtnH];
        iv.hidden = YES;
        iv;
    });
}

#pragma mark - cell data
-(void)initDataToView:(SobotChatMessage *)message time:(NSString *)showTime{
    [super initDataToView:message time:showTime];
    
    NSString * text = sobotConvertToString(message.richModel.customCard.cardGuide);
    text = [text stringByReplacingOccurrencesOfString:@"&#x27;" withString:@"’"];
    [ZCChatBaseCell configHtmlText:text label:self.titleLab right:self.isRight];
    CGSize size = [self.titleLab preferredSizeWithMaxWidth:self.maxWidth];
    if(size.height < 22){
        size.height = 22;
    }
    _layoutTitleWidth.constant = self.maxWidth;
    _layoutTitleHeight.constant = size.height;
    
    CGSize lastSize = size;
    [self.contentBgView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (!sobotIsNull(message.richModel.customCard) && message.richModel.customCard.customCards.count >0) {
        UIView *lastCardView = nil;
        CGFloat count = message.richModel.customCard.customCards.count;
        if (count >3) {
            count = 3;
        }
        for (int i = 0; i<count; i++) {
            SobotChatCustomCardInfo *cardInfo = message.richModel.customCard.customCards[i];
            
            ZCChatAiCardView *newView = [[ZCChatAiCardView alloc]initWithDict:cardInfo maxW:self.maxWidth-32 supView:_contentBgView lastView:nil isHistory:message.isHistory isUnBtn:NO];
            newView.delegate = self;
            [_contentBgView addSubview:newView];
            [self.contentBgView addConstraint:sobotLayoutPaddingLeft(0, newView, _contentBgView)];
            [self.contentBgView addConstraint:sobotLayoutPaddingRight(0, newView, _contentBgView)];
            if (lastCardView) {
                [_contentBgView addConstraint:sobotLayoutMarginTop(12, newView, lastCardView)];
            }else{
                [_contentBgView addConstraint:sobotLayoutPaddingTop(0, newView, _contentBgView)];
            }
            CGFloat  mt = 0;
            if (sobotIsNull(lastCardView)) {
            }else{
                mt = 12;
            }
            [newView layoutIfNeeded];
            lastSize.height = lastSize.height + newView.frame.size.height +mt;
            lastCardView = newView;
        }
        if (!sobotIsNull(lastCardView)) {
            [_contentBgView addConstraint:sobotLayoutPaddingBottom(-8, lastCardView, _contentBgView)];
            lastSize.height = lastSize.height + 8;
        }
    }
    
    if (!sobotIsNull(message.richModel.customCard) && message.richModel.customCard.customCards.count >3) {
        // 显示
        CGFloat btnH = [SobotUITools getMaxHeightContain:SobotKitLocalString(@"查看更多") font:SobotFont14 width:self.maxWidth];
        btnH = btnH + 24;
        self.moreBtnH.constant = btnH;
        self.moreLineH.constant = 0.75;
        lastSize.height  = lastSize.height + btnH;
        self.moreLineMT.constant = 8;
        self.moreBtn.hidden = NO;
        self.moreLine.hidden = NO;
    }else{
        self.moreBtn.hidden = YES;
        self.moreLine.hidden = YES;
        // 不显示
        self.moreBtnH.constant = 0;
        self.moreLineH.constant = 0;
        self.moreLineMT.constant = 0;
    }
    [_contentBgView layoutIfNeeded];
    [self setChatViewBgState:CGSizeMake(self.maxWidth,lastSize.height)];
}



#pragma mark -- 查看更多
-(void)moreBtnClick:(SobotButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]) {
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickLookMoreCard text:@"" obj:nil];
    }
}

#pragma mark -- 实现代理方法
-(void)clickType:(int)type obj:(NSObject *)obj Menu:(nonnull SobotChatCustomCardMenu *)menu{
    if (type == 1 || type == 3) {
        SobotChatCustomCardInfo *cardModel = (SobotChatCustomCardInfo *)obj;
        if (self.delegate && [self.delegate respondsToSelector:@selector(aiRobotCellItemClick:type:text:obj:Menu:)]) {
            [self.delegate aiRobotCellItemClick:self.tempModel type:ZCChatCellClickTypeAiRobotBtnClickSendMsg text:[NSString stringWithFormat:@"%d",type] obj:cardModel Menu:menu];
        }
    }else if(type == 2){
        // 打开链接
        [[ZCUICore getUICore] dealWithLinkClickWithLick:sobotConvertToString(menu.menuLink) viewController:[SobotUITools getCurrentVC]];
    }
}


#pragma mark -- 手势冲突
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"] || [NSStringFromClass([touch.view class]) isEqualToString:@"SobotButton"]){
        return NO;
    }
    return YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
