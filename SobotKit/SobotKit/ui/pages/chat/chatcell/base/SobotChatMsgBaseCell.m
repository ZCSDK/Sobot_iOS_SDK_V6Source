//
//  SobotChatMsgBaseCell.m
//  SobotKit
//
//  Created by zhangxy on 2025/1/17.
//

#import "SobotChatMsgBaseCell.h"

@interface SobotChatMsgBaseCell()<SobotEmojiLabelDelegate>
{
    
}

@property(nonatomic,strong) NSLayoutConstraint *layoutAvatarEH;
@property(nonatomic,strong) NSLayoutConstraint *layoutAvatarEW;
@property(nonatomic,strong) NSLayoutConstraint *layoutAvatarEHR;
@property(nonatomic,strong) NSLayoutConstraint *layoutAvatarEWR;

// 头像
@property (nonatomic,strong) SobotImageView *ivHeader;
@property (nonatomic,strong) SobotImageView *ivHeaderRight;

/**
 *  名称
 */
@property (nonatomic,strong) UILabel            *lblNickName;
@property (nonatomic,strong) NSLayoutConstraint *layoutNameLeft;
@property (nonatomic,strong) NSLayoutConstraint *layoutNameRight;
@property (nonatomic,strong) NSLayoutConstraint *layoutNameEH;

@property (nonatomic,strong) NSLayoutConstraint *layoutChatBgViewT;
@property (nonatomic,strong) NSLayoutConstraint *layoutChatBgViewL;
@property (nonatomic,strong) NSLayoutConstraint *layoutChatBgViewR;

@property (nonatomic,strong) NSLayoutConstraint *layoutBtmL;
@property (nonatomic,strong) NSLayoutConstraint *layoutBtmR;


@property (nonatomic,strong) NSLayoutConstraint *layoutSugguestTop;
@property (nonatomic,strong) NSLayoutConstraint *layoutSugguestWidth;
@property (nonatomic,strong) NSLayoutConstraint *layoutSugguestBottom;

@end

@implementation SobotChatMsgBaseCell


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
    [super createItemsView];
    
    _ivHeader =({
        SobotImageView *iv = [[SobotImageView alloc] init];
        [iv setContentMode:UIViewContentModeScaleAspectFill];
        [iv.layer setMasksToBounds:YES];
        [iv setBackgroundColor:[UIColor clearColor]];
        [self.chatView addSubview:iv];
        iv.layer.masksToBounds = YES;
        iv.layer.borderColor = [UIColor clearColor].CGColor;
        iv.layer.borderWidth = 1.0f;
        iv.layer.cornerRadius = 16.0f;
        self.layoutAvatarEH = sobotLayoutEqualWidth(32, iv, NSLayoutRelationEqual);
        self.layoutAvatarEW = sobotLayoutEqualHeight(32, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.layoutAvatarEW];
        [self.contentView addConstraint:self.layoutAvatarEH];
        
        
        [self.chatView addConstraint:sobotLayoutPaddingTop(0, iv, self.chatView)];
        [self.chatView addConstraint:sobotLayoutPaddingLeft(0, iv, self.chatView)];
        
        
        iv;
        
    });
    _ivHeaderRight =({
        SobotImageView *iv = [[SobotImageView alloc] init];
        [iv setContentMode:UIViewContentModeScaleAspectFill];
        [iv.layer setMasksToBounds:YES];
//        [iv setBackgroundColor:[UIColor lightGrayColor]];
        [iv setBackgroundColor:[UIColor clearColor]];
        [self.chatView addSubview:iv];
        iv.layer.masksToBounds = YES;
        iv.layer.borderColor = [UIColor clearColor].CGColor;
        iv.layer.borderWidth = 1.0f;
        iv.layer.cornerRadius = 16.0f;
        self.layoutAvatarEHR = sobotLayoutEqualWidth(32, iv, NSLayoutRelationEqual);
        self.layoutAvatarEWR = sobotLayoutEqualHeight(32, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.layoutAvatarEWR];
        [self.contentView addConstraint:self.layoutAvatarEHR];
        
        
        [self.chatView addConstraint:sobotLayoutPaddingTop(0, iv, self.chatView)];
        [self.chatView addConstraint:sobotLayoutPaddingRight(0, iv, self.chatView)];
        
        
        iv;
        
    });
    
    _lblNickName = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setBackgroundColor:[UIColor clearColor]];
        [self.chatView addSubview:iv];
        iv.font = SobotFont12;
        [iv setTextColor:UIColorFromKitModeColor(SobotColorTextSubDark)];
        
        _layoutNameLeft = sobotLayoutMarginLeft(SobotSpaceInLine, iv, self.ivHeader);
        _layoutNameRight = sobotLayoutMarginRight(-SobotSpaceInLine, iv, self.ivHeaderRight);
        [self.contentView addConstraint:_layoutNameLeft];
        [self.contentView addConstraint:_layoutNameRight];
        [self.contentView addConstraint:sobotLayoutPaddingTop(0, iv, self.ivHeader)];
        _layoutNameEH = sobotLayoutEqualHeight(0, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:_layoutNameEH];
        iv;
    });
    
    _chatMsgBgView = ({
        UIView *iv = [[UIView alloc] init];
        iv.backgroundColor = UIColor.clearColor;
        [self.chatView addSubview:iv];
        
        _layoutChatBgViewT = sobotLayoutMarginTop(SobotSpace2, iv, self.lblNickName);
        _layoutChatBgViewL = sobotLayoutPaddingLeft(0, iv, self.lblNickName);
        _layoutChatBgViewR = sobotLayoutPaddingRight(0, iv, self.lblNickName);
        
        [self.chatView addConstraint:_layoutChatBgViewT];
        [self.chatView addConstraint:_layoutChatBgViewL];
        [self.chatView addConstraint:_layoutChatBgViewR];
        
        iv;
    });
    
    
    _chatLeftView = ({
        UIView *iv = [[UIView alloc] init];
        iv.backgroundColor = UIColor.clearColor;
        [self.chatView addSubview:iv];
        
        [self.chatView addConstraint:sobotLayoutPaddingBottom(0, iv, self.chatMsgBgView)];
        [self.chatView addConstraint:sobotLayoutMarginRight(-SobotSpaceInLine, iv, self.chatMsgBgView)];
        
        iv;
    });
    
    _chatRightView = ({
        UIView *iv = [[UIView alloc] init];
        iv.backgroundColor = UIColor.clearColor;
        [self.chatView addSubview:iv];
        
        _layoutChatBgViewT = sobotLayoutMarginTop(SobotSpace2, iv, self.lblNickName);
        _layoutChatBgViewL = sobotLayoutPaddingLeft(0, iv, self.lblNickName);
        _layoutChatBgViewR = sobotLayoutPaddingRight(0, iv, self.lblNickName);
        
        [self.chatView addConstraint:sobotLayoutPaddingBottom(0, iv, self.chatMsgBgView)];
        [self.chatView addConstraint:sobotLayoutMarginLeft(SobotSpaceInLine, iv, self.chatMsgBgView)];
        
        iv;
    });
    
    _chatBtmView = ({
        UIView *iv = [[UIView alloc] init];
        iv.backgroundColor = UIColor.clearColor;
        [self.chatView addSubview:iv];
        
        _layoutBtmT = sobotLayoutMarginTop(0, iv, self.chatMsgBgView);
        [self.chatView addConstraint:sobotLayoutPaddingLeft(0, iv, self.chatMsgBgView)];
        [self.chatView addConstraint:sobotLayoutPaddingLeft(0, iv, self.chatMsgBgView)];
        [self.chatView addConstraint:_layoutBtmT];
        
        iv;
    });
    _chatBtmManualView = ({
        UIView *iv = [[UIView alloc] init];
        iv.backgroundColor = UIColor.clearColor;
        [self.chatView addSubview:iv];
        
        [self.chatView addConstraint:sobotLayoutPaddingLeft(0, iv, self.chatMsgBgView)];
        [self.chatView addConstraint:sobotLayoutMarginTop(SobotSpace10, iv, self.chatBtmView)];
        [self.chatView addConstraint:sobotLayoutPaddingBottom(-SobotChatMarginVSpace, iv, self.chatView)];
        
        iv;
    });
    
    
    _chatMsgView = ({
        UIView *iv = [[UIView alloc] init];
        iv.backgroundColor = UIColor.clearColor;
        [self.chatView addSubview:iv];
        _layoutChatMsgLeft = sobotLayoutPaddingLeft(SobotChatMarginHSpace, iv, self.chatMsgBgView);
        _layoutChatMsgRight = sobotLayoutPaddingRight(SobotChatMarginHSpace, iv, self.chatMsgBgView);
        [self.chatView addConstraint:_layoutChatMsgLeft];
        [self.chatView addConstraint:_layoutChatMsgRight];
        [self.chatView addConstraint:sobotLayoutPaddingTop(SobotChatMarginVSpace, iv, self.chatMsgBgView)];
        
        iv;
    });
    
    
    _lblSugguest = ({
        SobotEmojiLabel *iv = [SobotChatMsgBaseCell createRichLabel];
        iv.textInsets = UIEdgeInsetsMake(0, 0, 0, SobotChatMarginHSpace);
        [self.chatMsgBgView addSubview:iv];
        _layoutSugguestBottom=sobotLayoutPaddingBottom(0, iv, self.chatMsgBgView);
        [self.chatMsgBgView addConstraint:_layoutSugguestBottom];
        _layoutSugguestWidth = sobotLayoutEqualWidth(0, iv, NSLayoutRelationEqual);
        _layoutSugguestHeight = sobotLayoutEqualHeight(0, iv, NSLayoutRelationEqual);
        [self.chatMsgBgView addConstraint:sobotLayoutPaddingLeft(SobotChatMarginHSpace, iv, self.chatMsgBgView)];
        iv.delegate = self;
        [self.contentView addConstraint:_layoutSugguestWidth];
        [self.contentView addConstraint:_layoutSugguestHeight];
        
        iv;
    });
    
}

-(void)initDataToView:(SobotChatMessage *) message time:(NSString *) showTime{
    [super initDataToView:message time:showTime];
    
    if(self.isShowHeader){
        self.layoutAvatarEH.constant = 32;
        self.layoutAvatarEW.constant = 32;
        self.layoutAvatarEHR.constant = 32;
        self.layoutAvatarEWR.constant = 32;
        
        self.layoutNameLeft.constant = SobotSpaceInLine;
        self.layoutNameRight.constant = -SobotSpaceInLine;
        self.layoutChatBgViewT.constant = 2;
    }else{
        self.layoutAvatarEH.constant = 0;
        self.layoutAvatarEW.constant = 0;
        self.layoutAvatarEHR.constant = 0;
        self.layoutAvatarEWR.constant = 0;
        self.layoutNameLeft.constant = 0;
        self.layoutNameRight.constant = 0;
        self.layoutChatBgViewT.constant = 0;
    }
    
    // 确定消息气泡的位置
    [self.chatView removeConstraint:_layoutChatBgViewL];
    [self.chatView removeConstraint:_layoutChatBgViewR];
    if(self.isRight){
        [self.chatView addConstraint:_layoutChatBgViewR];
    }else{
        [self.chatView addConstraint:_layoutChatBgViewL];
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
    if(SobotKitIsRTLLayout){
        tempRichLabel.textAlignment = NSTextAlignmentRight;
    }else{
        tempRichLabel.textAlignment = NSTextAlignmentLeft;
    }
    if(delegate != nil){
        tempRichLabel.delegate = delegate;
    }
    return tempRichLabel;
}

#pragma mark EmojiLabel delegate start
// 链接点击
- (void)SobotEmojiLabel:(SobotEmojiLabel*)emojiLabel didSelectLink:(NSString*)link withType:(SobotEmojiLabelLinkType)type{
   [self doClickURL:link text:@""];
}

// 链接点击
-(void)attributedLabel:(SobotEmojiLabel *)label didSelectLinkWithURL:(NSURL *)url{
    // 此处得到model 对象对应的值
    NSString *textStr = label.text;
    
    [self doClickURL:url.absoluteString text:textStr];
}


#pragma mark EmojiLabel delegate end
// 链接点击
-(void)doClickURL:(NSString *)url text:(NSString * )htmlText{
  
    // 解码
    url = [url stringByRemovingPercentEncoding];

//    if(url){
//        url=[url stringByReplacingOccurrencesOfString:@"\"" withString:@""];
//        // 用户引导说辞的分类的点击事件
//        NSString *leaveUpMsg = [NSString stringWithFormat:@"%@ %@",SobotKitLocalString(@"您的留言状态有"),SobotKitLocalString(@"更新")];
//        leaveUpMsg = [leaveUpMsg stringByReplacingOccurrencesOfString:@" " withString:@" "];// 处理特殊空格国际化下字符串不相同的问题
//        if ([sobotConvertToString(htmlText) hasSuffix:SobotKitLocalString(@"留言")] || [@"sobot://leavemessage" isEqual:url]) {
//            [self turnLeverMessageVC];
//        }else if ([leaveUpMsg isEqual:url] || [SobotKitLocalString(@"更新") isEqual:url]){
//            [self turnLeverMsgRecordVC];
//        }else if([url hasPrefix:@"sobot://newsessionchat"]){
//            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
//                [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeNewSession text:@"" obj:@""];
//            }
//        }else if([url hasPrefix:@"sobot://insterTrunMsg"]){
//            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
//                [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeInsterTurn text:@"" obj:@""];
//            }
//        }else if([url hasPrefix:@"sobot://resendleavemessage"]){
//            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
//                [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemResendLeaveMsg text:@"" obj:@""];
//            }
//        }else if([url hasPrefix:@"sobot://continueWaiting"]){
//            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
//                [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemContinueWaiting text:@"" obj:@""];
//            }
//        }else if([url hasPrefix:@"sobot://showallsensitive"]){
//            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
//                [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemShowallsensitive text:@"" obj:@""];
//            }
//        }else if([url hasPrefix:@"sobot:"]){
//            int index = [[url stringByReplacingOccurrencesOfString:@"sobot://" withString:@""] intValue];
//            
//            if(index > 0 && self.tempModel.robotAnswer.suggestionList.count>=index){
//                if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
//                    [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemChecked text:@"" obj:self.tempModel.robotAnswer.suggestionList[index-1]];
//                }
//                return;
//            }
//            
//            if(index > 0 && self.tempModel.richModel.richContent.interfaceRetList.count>=index){
//                
//                // 单独处理对象
//                NSDictionary * dict = @{@"requestText": self.tempModel.richModel.richContent.interfaceRetList[index-1][@"title"],
//                                        @"question":[self getQuestion:self.tempModel.richModel.richContent.interfaceRetList[index-1]],
//                                        @"questionFlag":@"2",
//                                        @"title":self.tempModel.richModel.richContent.interfaceRetList[index-1][@"title"],
//                                        @"ishotguide":@"0"
//                                        };
//                if ([self getZCLibConfig].isArtificial) {
//                    dict = @{@"title":self.tempModel.richModel.richContent.interfaceRetList[index-1][@"title"],@"ishotguide":@"0"};
//                }
//                
//                if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
//                    [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemGuide text:@"" obj:dict];
//                }
//            }
//            
//            
//        }else if ([url hasPrefix:@"robot:"]){
//            // 处理 机器人回复的 技能组点选事件
//            
////          3.0.8 如果当前 已转人工 ， 不可点击
//            if([self getZCLibConfig].isArtificial){
//                return;
//            }
//            
//            int index = [[url stringByReplacingOccurrencesOfString:@"robot://" withString:@""] intValue];
//            if(index > 0 && self.tempModel.robotAnswer.groupList.count>=index){
//                if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
//                    [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeGroupItemChecked text:@"" obj:[NSString stringWithFormat:@"%d",index-1]];
//                }
//            }
//        }else if([url hasPrefix:@"zc_refresh_newdata"]){
//            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
//                [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeNewDataGroup text:@"" obj:url];
//            }
//        }else{
//            // 这里需要处理一下，是否用户做了拦截，拦截 就不在对url做处理，用户有自己的处理规则
//            if([[ZCUICore getUICore] LinkClickBlock] == nil || ![ZCUICore getUICore].LinkClickBlock(ZCLinkClickTypeURL,url,[UIViewController new])){
//                // 跳转链接的时候 url编码 处理中文
//                url = sobotUrlEncodedString(url);
//            }
//            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
//                [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeOpenURL text:htmlText obj:url];
//            }
//        }
//    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
