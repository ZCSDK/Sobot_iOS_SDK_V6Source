//
//  ZCChatReferenceTextCell.m
//  SobotKit
//
//  Created by zhangxy on 2023/11/16.
//

#import "ZCChatReferenceTextCell.h"
#define ZCChatCellItemSpace 5
@interface  ZCChatReferenceTextCell()<SobotEmojiLabelDelegate>
@property (strong, nonatomic) UIView *bgView; 
@end

@implementation ZCChatReferenceTextCell


-(void)layoutSubViewUI{
    [super layoutSubViewUI];
    self.viewContent.backgroundColor = UIColor.clearColor;
    [self.viewContent.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _bgView = ({
        UIView *iv = [[UIView alloc] init];
        [iv setBackgroundColor:UIColor.clearColor];
        [self.viewContent addSubview:iv];
        [self.viewContent addConstraint:sobotLayoutPaddingRight(0, iv, self.viewContent)];
        [self.viewContent addConstraint:sobotLayoutPaddingTop(0, iv, self.viewContent)];
        [self.viewContent addConstraint:sobotLayoutPaddingLeft(0, iv, self.viewContent)];
        [self.viewContent addConstraint:sobotLayoutPaddingBottom(0, iv, self.viewContent)];
        iv;
    });
}

-(void)dataToView:(SobotChatMessage *)message{
    [super dataToView:message];
    [self addText:sobotConvertToString(message.richModel.content) view:self.bgView maxWidth:self.maxWidth showType:1 lastMsg:YES model:message];
}

-(CGFloat)addText:(NSString *)content view:(UIView *) superView maxWidth:(CGFloat ) cMaxWidth showType:(int )showType lastMsg:(BOOL )isLast model:(SobotChatMessage *)model{
    NSString *text = content;
    // 最后一行过滤所有换行，不是最后一行过滤一个换行
    if(isLast){
        while ([text hasSuffix:@"\n"]){
            text = [text substringToIndex:text.length - 1];
            while ([text hasSuffix:@" "]){
                text = [text substringToIndex:text.length - 1];
            }
        }
        while ([text hasSuffix:@"<br>"]){
            text = [text substringToIndex:text.length - 4];
            while ([text hasSuffix:@" "]){
                text = [text substringToIndex:text.length - 1];
            }
        }
        
        while ([text hasSuffix:@" "]){
            text = [text substringToIndex:text.length - 1];
        }
    }
    if(text.length == 0){
        return 0;
    }
    
    SobotEmojiLabel *tipLabel = [self createRichLabel];
    tipLabel.font = [ZCUIKitTools zcgetKitChatFont];
    tipLabel.numberOfLines = 3;
    tipLabel.lineBreakMode = 4;
    tipLabel.delegate = self;
 
    UIColor *textColor = [ZCUIKitTools zcgetLeftChatTextColor];
    UIColor *linkColor = [ZCUIKitTools zcgetChatLeftLinkColor];
    if([self isRight]){
        textColor = [ZCUIKitTools zcgetRightChatTextColor];
        linkColor = [ZCUIKitTools zcgetChatRightlinkColor];
    }
    [tipLabel setTextColor:textColor];
    [tipLabel setLinkColor:linkColor];

    tipLabel.textAlignment = NSTextAlignmentLeft;
    [superView addSubview:tipLabel];
 
    // 最后一行过滤所有换行，不是最后一行过滤一个换行
    if(isLast){
        while ([text hasSuffix:@"\n"]){
            text = [text substringToIndex:text.length - 1];
        }
    }
    text = [SobotHtmlCore filterHTMLTag:text];
    if(model.sendType != 0){
        text = [ZCUIKitTools removeAllHTMLTag:text];
    }
    tipLabel.text = text;
    
    CGSize s2 = [tipLabel preferredSizeWithMaxWidth:cMaxWidth];
    
    [superView addConstraint:sobotLayoutPaddingLeft(0, tipLabel, superView)];
    [superView addConstraint:sobotLayoutPaddingRight(0, tipLabel, superView)];
    [superView addConstraint:sobotLayoutPaddingTop(0, tipLabel, superView)];
   
    if (sobotIsUrl(text, [ZCUIKitTools zcgetUrlRegular]) && showType == 1) {
        // 显示超链卡片  引用的超链样式不同于聊天消息
        superView.userInteractionEnabled = YES;
        tipLabel.hidden = YES;
        CGSize links = CGSizeMake(cMaxWidth, 40);
        SobotView *linkBgView = [[SobotView alloc]init];
        linkBgView.layer.cornerRadius = 4;
        linkBgView.layer.masksToBounds = YES;
       
        if(self.parentMessage.sendType == 0){
            // 右边
            linkBgView.backgroundColor = UIColorFromModeColorAlpha(SobotColorWhite, 0.14);
        }else{
            // 左边
            linkBgView.backgroundColor = UIColorFromModeColor(SobotColorWhite);
        }
        
        [superView addSubview:linkBgView];
        
        linkBgView.objTag = text;
        
        // 覆盖上面的明文链接
        [superView addConstraint:sobotLayoutPaddingTop(0, linkBgView, tipLabel)];
        [superView addConstraint:sobotLayoutPaddingLeft(0,linkBgView, superView)];
        [superView addConstraint:sobotLayoutPaddingRight(0, linkBgView, superView)];
        [superView addConstraint:sobotLayoutEqualHeight(40, linkBgView, NSLayoutRelationEqual)];
        [superView addConstraint:sobotLayoutPaddingBottom(0, linkBgView, superView)];
        
        SobotButton *btn = [SobotButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundColor:[UIColor clearColor]];
        [linkBgView addSubview:btn];
        [btn addTarget:self action:@selector(urlTextClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.obj = text;
        [linkBgView addConstraints:sobotLayoutPaddingWithAll(0, 0, 0, 0, btn, linkBgView)];
        
        UILabel *linktitleLab = [[UILabel alloc]init];
        linktitleLab.font = SobotFont13;
        linktitleLab.text = sobotConvertToString(text);
        linktitleLab.textColor = [ZCUIKitTools zcgetLeftChatTextColor];
        if(self.isRight){
            linktitleLab.textColor = [ZCUIKitTools zcgetRightChatTextColor];
        }
        [linkBgView addSubview:linktitleLab];
        linktitleLab.numberOfLines = 1;
        linktitleLab.lineBreakMode = 4;
        [superView addConstraint:sobotLayoutEqualHeight(20, linktitleLab, NSLayoutRelationEqual)];
        NSLayoutConstraint *rightTitle = sobotLayoutPaddingRight(-35, linktitleLab, linkBgView);
        [linkBgView addConstraint:rightTitle];
        [linkBgView addConstraint:sobotLayoutPaddingLeft(10, linktitleLab, linkBgView)];
        [linkBgView addConstraint:sobotLayoutEqualCenterY(0, linktitleLab, linkBgView)];
        
        SobotImageView *icon = [[SobotImageView alloc]init];
        [icon loadWithURL:[NSURL URLWithString:@""] placeholer:SobotKitGetImage(@"zcicon_url_icon")];
        [linkBgView addSubview:icon];
        [superView addConstraints:sobotLayoutSize(20,20, icon, NSLayoutRelationEqual)];
        [linkBgView addConstraint:sobotLayoutPaddingRight(-10, icon, linkBgView)];
        [linkBgView addConstraint:sobotLayoutEqualCenterY(0, icon, linkBgView)];
        
        [self showContent:@"" view:linkBgView btm:nil isMaxWidth:YES customViewWidth:0];
        return 40;
    }
    
    [superView addConstraint:sobotLayoutPaddingBottom(0, tipLabel, superView)];
    
    [self showContent:@"" view:self.viewContent btm:nil isMaxWidth:NO customViewWidth:s2.width+8*2];// 16个间隙是文本控件左右间距
    return s2.height;
}


#pragma mark -- 点击超链事件
-(void)urlTextClick:(SobotButton*)sender{
    NSString *url = (NSString*)sender.obj;
    if(sobotConvertToString(url).length >0){
        [self doClickURL:url text:@""];
    }
}

// 链接点击
- (void)SobotEmojiLabel:(SobotEmojiLabel*)emojiLabel didSelectLink:(NSString*)link withType:(SobotEmojiLabelLinkType)type{
   [self doClickURL:link text:@""];
}

// 链接点击
-(void)doClickURL:(NSString *)url text:(NSString * )htmlText{
    if(url){
        url=[url stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        // 用户引导说辞的分类的点击事件
        NSString *leaveUpMsg = [NSString stringWithFormat:@"%@ %@",SobotKitLocalString(@"您的留言状态有"),SobotKitLocalString(@"更新")];
        leaveUpMsg = [leaveUpMsg stringByReplacingOccurrencesOfString:@" " withString:@" "];// 处理特殊空格国际化下字符串不相同的问题
        if ([sobotConvertToString(htmlText) hasSuffix:SobotKitLocalString(@"留言")] || [@"sobot://leavemessage" isEqual:url]) {
//            [self turnLeverMessageVC];
        }else if ([leaveUpMsg isEqual:url] || [SobotKitLocalString(@"更新") isEqual:url]){
//            [self turnLeverMsgRecordVC];
        }else if([url hasPrefix:@"sobot://newsessionchat"]){
//            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
//                [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeNewSession text:@"" obj:@""];
//            }
        }else if([url hasPrefix:@"sobot://insterTrunMsg"]){
//            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
//                [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeInsterTurn text:@"" obj:@""];
//            }
        }else if([url hasPrefix:@"sobot://resendleavemessage"]){
//            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
//                [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemResendLeaveMsg text:@"" obj:@""];
//            }
        }else if([url hasPrefix:@"sobot://continueWaiting"]){
//            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
//                [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemContinueWaiting text:@"" obj:@""];
//            }
        }else if([url hasPrefix:@"sobot://showallsensitive"]){
//            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
//                [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemShowallsensitive text:@"" obj:@""];
//            }
        }else if([url hasPrefix:@"sobot:"]){
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
            
            
        }else if ([url hasPrefix:@"robot:"]){
            // 处理 机器人回复的 技能组点选事件
            
//          3.0.8 如果当前 已转人工 ， 不可点击
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
        }else if([url hasPrefix:@"zc_refresh_newdata"]){
//            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
//                [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeNewDataGroup text:@"" obj:url];
//            }
        }else{
            // 超链点击事件
            [self viewEvent:ZCChatReferenceCellEventOpenURL state:0 obj:sobotConvertToString(url)];
        }
    }
}

-(SobotEmojiLabel *) createRichLabel{
    SobotEmojiLabel *tempRichLabel = [[SobotEmojiLabel alloc] initWithFrame:CGRectZero];
    tempRichLabel.numberOfLines = 0;
    tempRichLabel.font = [UIFont systemFontOfSize:14];
    tempRichLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    tempRichLabel.textColor = [UIColor whiteColor];
    tempRichLabel.backgroundColor = [UIColor clearColor];
    tempRichLabel.isNeedAtAndPoundSign = NO;
    tempRichLabel.disableEmoji = NO;
    tempRichLabel.lineSpacing = 3;
    tempRichLabel.verticalAlignment = 0;
    return tempRichLabel;
}

@end
