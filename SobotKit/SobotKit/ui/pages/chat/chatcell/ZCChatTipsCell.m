//
//  ZCChatTipsCell.m
//  SobotKit
//
//  Created by zhangxy on 2022/9/19.
//

#import "ZCChatTipsCell.h"
#import "SobotHtmlFilter.h"

@interface ZCChatTipsCell()


@property(nonatomic,strong) SobotEmojiLabel *lblMessage;
//@property(nonatomic,strong) NSLayoutConstraint *layoutWidth;
@property(nonatomic,strong) UIImageView     *lineView;
@end

@implementation ZCChatTipsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self createItemViews];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self createItemViews];
    }
    return self;
}

-(void)initDataToView:(SobotChatMessage *)message time:(NSString *)showTime{
    self.tempModel = message;
    self.ivHeader.hidden = YES;
    _lblMessage.text = @"";
    
    CGSize s = CGSizeZero;
    [self HandleHTMLTagsWith:message];
//    if(text.length > 0){
//        [_lblMessage setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
//        [_lblMessage setLinkColor:[ZCUIKitTools zcgetChatLeftLinkColor]];
//
//        [_lblMessage setText:text];
//    self.maxWidth = ScreenWidth - 20;
//        s = [_lblMessage preferredSizeWithMaxWidth:self.maxWidth];
////    }
//    _layoutWidth.constant = s.width;
        
    if(message.action == SobotMessageActionTypeNewMessage){
        _lineView.hidden = NO;
        _lblMessage.backgroundColor = [ZCUIKitTools zcgetLeftChatColor];
    }else{
        _lineView.hidden = YES;
        _lblMessage.backgroundColor = UIColor.clearColor;
    }
    [_lblMessage layoutIfNeeded];
}

-(void)createItemViews{
    _lblMessage = [ZCChatBaseCell createRichLabel];
    _lblMessage.delegate = self;
    _lblMessage.textAlignment = NSTextAlignmentCenter;
    _lblMessage.numberOfLines = 0;
    _lblMessage.textInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    _lblMessage.font = SobotFont12;
    _lblMessage.textColor = UIColorFromKitModeColor(SobotColorTextSubDark);
    [self.contentView addSubview:_lblMessage];
//    _layoutWidth = sobotLayoutEqualWidth(20, _lblMessage, NSLayoutRelationEqual);
    [self.contentView addConstraint:sobotLayoutEqualCenterX(0, _lblMessage, self.contentView)];
    [self.contentView addConstraints:sobotLayoutPaddingView(ZCChatPaddingVSpace, -ZCChatPaddingVSpace, 16, -16, _lblMessage, self.contentView)];
    
    _lineView = [[UIImageView alloc] init];
    [_lineView setBackgroundColor:UIColorFromModeColor(SobotColorBgLine)];
    [self.contentView insertSubview:_lineView belowSubview:self.ivBgView];
    [self.contentView addConstraints:sobotLayoutPaddingView(0,0, ZCChatPaddingHSpace, -ZCChatPaddingHSpace, _lineView, self.contentView)];
    [self.contentView addConstraint:sobotLayoutEqualHeight(1, _lineView, NSLayoutRelationEqual)];
    [self.contentView addConstraint:sobotLayoutEqualCenterY(0, _lineView, _lblMessage)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// 处理标签
- (void)HandleHTMLTagsWith:(SobotChatMessage *) model{
    NSString  *text = [ZCChatTipsCell getSysTipsText:model];
    
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    [ZCChatBaseCell configHtmlText:text label:_lblMessage right:NO isTip:YES];
    
//    [SobotHtmlCore filterHtml:text result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
//        // zcgetTipLayerTextColor  zcgetLeftChatTextColor
//        if (text1 != nil && text1.length > 0) {
//            if ([text1 hasPrefix:[NSString stringWithFormat:@"%@",SobotKitLocalString(@"您好，客服")]]) {
//                [self->_lblMessage setLinkColor:UIColorFromModeColor(SobotColorTextSub)];
//            }
//            [SobotHtmlFilter setHtml:text1 attrs:arr view:self->_lblMessage textColor:[ZCUIKitTools zcgetTimeTextColor] textFont:self->_lblMessage.font linkColor:[ZCUIKitTools zcgetChatLeftLinkColor]];
//        }else{
//            self->_lblMessage.attributedText = [[NSAttributedString alloc] initWithString:@""];
//        }
//
//    }];
    
    if ([sobotConvertToString( model.tipsMessage) hasPrefix:sobotConvertToString([ZCUICore getUICore].getLibConfig.userOutWord)] || [sobotConvertToString( model.tipsMessage) hasPrefix:sobotConvertToString([ZCUICore getUICore].getLibConfig.adminNonelineTitle)]) {
        [self setTipCellAnimateTransformWith:model];
    }
 
    // 处理工单留言提醒
    NSString *leaveUpMsg = [NSString stringWithFormat:@"%@ %@",SobotKitLocalString(@"您的留言状态有"),SobotKitLocalString(@"更新")];
    // 国际化译文中的空格需要处理  会导致判断失效
//    tempStr = [tempStr stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    leaveUpMsg = [leaveUpMsg stringByReplacingOccurrencesOfString:@" " withString:@" "];
    if ([leaveUpMsg isEqualToString:sobotConvertToString(text)]) {
        NSString *update = SobotKitLocalString(@"更新");
        [_lblMessage addLinkToURL:[NSURL URLWithString:update] withRange:NSMakeRange(leaveUpMsg.length - update.length, update.length)];
    }
    
}


+(NSString *)getSysTipsText:(SobotChatMessage *) model{
    // 处理HTML标签
    NSString  *text = [SobotHtmlCore filterHTMLTag:sobotConvertToString(model.tipsMessage)] ;
    while ([sobotConvertToString(text) hasPrefix:@"\n"]) {
        text=[text substringWithRange:NSMakeRange(1, text.length-1)];
    }
    
    if ([sobotConvertToString(text) hasPrefix:[NSString stringWithFormat:@"%@",SobotKitLocalString(@"您好，客服")]]) {
        // 留言标签的处理
        //        NSString nikeNameStr = SobotKitLocalString(@"昵称");
//        text = [text stringByReplacingOccurrencesOfString:@"[" withString:@"<a href='昵称'>"];
//        text = [text stringByReplacingOccurrencesOfString:@"]" withString:@"</a>"];
        
                text = [text stringByReplacingOccurrencesOfString:@"[" withString:@" "];
                text = [text stringByReplacingOccurrencesOfString:@"]" withString:@" "];
    }
    
    if ([sobotConvertToString(text) hasSuffix:SobotKitLocalString(@"留言")]) {
        // 留言标签的处理
        text = [text stringByReplacingOccurrencesOfString:SobotKitLocalString(@"留言") withString:[NSString stringWithFormat:@"<a href='sobot://leavemessage'>%@</a>",SobotKitLocalString(@"留言")]];
    }
    
    if ([sobotConvertToString(text) hasSuffix:SobotKitLocalString(@"重建会话")]) {
        // 如果有重建会话的时候，点击重新开始会话
        text = [text stringByReplacingOccurrencesOfString:SobotKitLocalString(@"重建会话") withString:[NSString stringWithFormat:@"<a href='sobot://newsessionchat'>%@</a>",SobotKitLocalString(@"重建会话")]];
    }
    
    if ([sobotConvertToString(text) hasPrefix:SobotKitLocalString(@"未解决问题？点击")]) {
        if (!model.isHistory) {
            // 转人工客服处理
            text = [text stringByReplacingOccurrencesOfString:SobotKitLocalString(@"转人工服务") withString:[NSString stringWithFormat:@"<a href='sobot://insterTrunMsg'>%@</a>",SobotKitLocalString(@"转人工服务")]];
        }
    }
    
    if ([sobotConvertToString(text) hasSuffix:SobotKitLocalString(@"继续排队")]) {
        if (!model.isHistory) {
            // 转人工客服处理
            text = [text stringByReplacingOccurrencesOfString:SobotKitLocalString(@"继续排队") withString:[NSString stringWithFormat:@"<a href='sobot://continueWaiting'>%@</a>",SobotKitLocalString(@"继续排队")]];
        }
    }
    
    return text;
}

- (void)setTipCellAnimateTransformWith:(SobotChatMessage *)model{
    //*2.0.0版本新加 新会话键盘样式出现时，未发送成功的消息不能在发送，提示离线或者会话结束。
    if ((model.msgType == SobotMessageTypeTipsText && !model.isRead)|| ((model.action==ZCReceivedMessageOfflineToLong || model.action == ZCReceivedMessageOfflineByClose) && !model.isRead)){
        [UIView animateWithDuration:0.1 animations:^{
            
            self.ivBgView.layer.transform = CATransform3DMakeTranslation(-20, 0, 0);
            self->_lblMessage.layer.transform = CATransform3DMakeTranslation(-20, 0, 0);
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.1 animations:^{
                
                self.ivBgView.layer.transform = CATransform3DMakeTranslation(20, 0, 0);
                self->_lblMessage.layer.transform = CATransform3DMakeTranslation(20, 0, 0);
            } completion:^(BOOL finished) {
                model.isRead = YES;
                [UIView animateWithDuration:0.1 animations:^{
                    
                    self.ivBgView.layer.transform = CATransform3DMakeTranslation(-20, 0, 0);
                    self->_lblMessage.layer.transform = CATransform3DMakeTranslation(-20, 0, 0);
                } completion:^(BOOL finished) {
                    self.ivBgView.layer.transform = CATransform3DMakeTranslation(0, 0, 0);
                    self->_lblMessage.layer.transform = CATransform3DMakeTranslation(0, 0, 0);
                }];
            }];
            
        }];
    }
}

@end