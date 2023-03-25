//
//  ZCUIChatListCell.m
//  SobotKit
//
//  Created by zhangxy on 2022/9/29.
//

#import "ZCUIChatListCell.h"
#import "ZCUICore.h"
#import "ZCUIKitTools.h"

@implementation ZCUIChatListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        
        _ivHeader = [[SobotImageView alloc] init];
        [_ivHeader setContentMode:UIViewContentModeScaleAspectFill];
        [_ivHeader.layer setMasksToBounds:YES];
        [_ivHeader setBackgroundColor:[UIColor clearColor]];
        _ivHeader.layer.cornerRadius=4.0f;
        _ivHeader.layer.masksToBounds=YES;
        _ivHeader.layer.borderWidth = 0.5f;
        _ivHeader.layer.borderColor = [ZCUIKitTools zcgetChatBackgroundColor].CGColor;
        [self.contentView addSubview:_ivHeader];
        [self.contentView addConstraints:sobotLayoutSize(50, 50, _ivHeader, NSLayoutRelationEqual)];
        [self.contentView addConstraints:sobotLayoutPaddingWithAll(5, 0, 5, 0, _ivHeader, self.contentView)];
        
        
        _lblTime=[[UILabel alloc] init];
        [_lblTime setTextAlignment:NSTextAlignmentRight];
        [_lblTime setFont:[ZCUIKitTools zcgetListKitTimeFont]];
        [_lblTime setTextColor:[ZCUIKitTools zcgetTimeTextColor]];
        [_lblTime setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_lblTime];
        _lblTime.hidden=NO;
        [self.contentView addConstraints:sobotLayoutSize(85, 50, _lblTime, NSLayoutRelationEqual)];
        [self.contentView addConstraint:sobotLayoutPaddingTop(5, _lblTime, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-5, _lblNickName, self.contentView)];
        
        
        
        _lblNickName =[[UILabel alloc] init];
        [_lblNickName setBackgroundColor:[UIColor clearColor]];
        [_lblNickName setTextAlignment:NSTextAlignmentLeft];
        [_lblNickName setFont:[ZCUIKitTools zcgetListKitTitleFont]];
        [_lblNickName setTextColor:[ZCUIKitTools zcgetChatTextViewColor]];
        [_lblNickName setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_lblNickName];
        _lblNickName.hidden=NO;
        [self.contentView addConstraint:sobotLayoutPaddingTop(5, _lblNickName, self.contentView)];
        [self.contentView addConstraint:sobotLayoutMarginLeft(5, _lblNickName, _ivHeader)];
        [self.contentView addConstraint:sobotLayoutMarginRight(-5, _lblNickName, _lblTime)];
        
        _lblLastMsg =[[UILabel alloc] init];
        [_lblLastMsg setBackgroundColor:[UIColor clearColor]];
        [_lblLastMsg setTextAlignment:NSTextAlignmentLeft];
        [_lblLastMsg setFont:[ZCUIKitTools zcgetListKitDetailFont]];
        [_lblLastMsg setTextColor:[ZCUIKitTools zcgetServiceNameTextColor]];
        _lblLastMsg.numberOfLines = 1;
        [_lblLastMsg setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_lblLastMsg];
        _lblLastMsg.hidden=NO;
        
        [self.contentView addConstraint:sobotLayoutMarginTop(5, _lblLastMsg, _lblNickName)];
        [self.contentView addConstraint:sobotLayoutMarginLeft(5, _lblLastMsg, _ivHeader)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-5, _lblLastMsg, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(-5, _lblLastMsg, self.contentView)];
        [self.contentView addConstraint:sobotLayoutEqualHeight(25, _lblLastMsg, NSLayoutRelationEqual)];

        _lblUnRead =[[UILabel alloc] init];
        [_lblUnRead setBackgroundColor:[UIColor clearColor]];
        [_lblUnRead setTextAlignment:NSTextAlignmentCenter];
        [_lblUnRead setFont:[ZCUIKitTools zcgetListKitTimeFont]];
        [_lblUnRead setTextColor:[UIColor whiteColor]];
        [_lblUnRead setBackgroundColor:UIColorFromModeColor(SobotColorRed)];
        _lblUnRead.layer.cornerRadius = 10;
        _lblUnRead.layer.masksToBounds = YES;
        [self.contentView addSubview:_lblUnRead];
        _lblUnRead.hidden=YES;
        
        
        [self.contentView addConstraint:sobotLayoutPaddingTop(3, _lblUnRead,  self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(40, _lblUnRead, self.contentView)];
        [self.contentView addConstraints:sobotLayoutSize(20, 20, _lblUnRead, NSLayoutRelationEqual)];

        
        
        self.userInteractionEnabled=YES;
    }
    return self;
}

-(void)dataToView:(ZCPlatformInfo *)info{
    if(info){
        NSString * text = sobotConvertToString(info.lastMsg);
        // 过滤标签
        text = [text stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
        text = [text stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
        text = [text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
        text = [text stringByReplacingOccurrencesOfString:@"<BR/>" withString:@"\n"];
        text = [text stringByReplacingOccurrencesOfString:@"<BR />" withString:@"\n"];
        text = [text stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
        text = [text stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
        text = [text stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
        
        _lblLastMsg.text = text;
        _lblNickName.text = sobotConvertToString(info.platformName);


        if (sobotConvertToString(info.lastDate).length >17) {
            // 处理时间，如果是当日 显示 时间 否者显示日期
            if ([[self getCurrentTimes] isEqualToString:sobotDateTransformString(@"YYYY-MM-dd", sobotStringFormateDate(info.lastDate))]) {
                _lblTime.text = sobotDateTransformString(@"HH:mm", sobotStringFormateDate(info.lastDate));
            }else{
                _lblTime.text = sobotDateTransformString(SobotKitLocalString(@"MM月dd日"), sobotStringFormateDate(info.lastDate));
            }
        }else{
            long long t = [sobotConvertToString(info.lastDate) longLongValue];
            if(info.lastDate.length > 10){
                t = t/1000;
            }
            NSString * times  = [NSString stringWithFormat:@"%lld",t];
            
            // 处理时间，如果是当日 显示 时间 否者显示日期
            if ([[self getCurrentTimes] isEqualToString:[self getTimeFromTimesTamp:times withType:1]]) {
                _lblTime.text =  [self getTimeFromTimesTamp:times withType:2];
            }else{
                _lblTime.text =  [self getTimeFromTimesTamp:times withType:3];
            }
        }
        

        // 不是中文时，不显示时间
//        if([ZCUICore getUICore].kitInfo.hideChatTime && (![zcGetLanguagePrefix() hasPrefix:@"zh-"] || ![[ZCLibClient getZCLibClient].libInitInfo.absolute_language hasPrefix:@"zh-"])){
        if([ZCUICore getUICore].kitInfo.hideChatTime){
            _lblTime.text = @"";
        }
        
        NSString *url = [sobotConvertToString(info.avatar) stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [_ivHeader loadWithURL:[NSURL URLWithString:url] placeholer:SobotKitGetImage(@"zcicon_useravatar_nol") showActivityIndicatorView:NO];
        _lblUnRead.hidden = YES;
        if(info.unRead>0){
            _lblUnRead.hidden = NO;
            
            if(info.unRead>99){
                _lblUnRead.text = @"99+";
            }else{
                _lblUnRead.text = [NSString stringWithFormat:@"%d",info.unRead];
            }
        }
    }
    [self setBackgroundColor:UIColorFromModeColor(SobotColorBgMainDark2)];
    [self setFrame:CGRectMake(0, 0, ScreenWidth, 60)];
}

-(NSString*)getCurrentTimes{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
//    [formatter setDateFormat:SOBOT_FORMATE_DATETIME];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    
    //现在时间,你可以输出来看下是什么格式
    
    NSDate *datenow = [NSDate date];
    
    //----------将nsdate按formatter格式转成nsstring
    
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    
//    NSLog(@"currentTimeString =  %@",currentTimeString);
    
    return currentTimeString;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSString *)getTimeFromTimesTamp:(NSString *)timeStr withType:(int)type{
    
    
    double time = [timeStr doubleValue];
    
    NSDate *myDate = [NSDate dateWithTimeIntervalSince1970:time];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    if (type == 1) {
        [formatter setDateFormat:@"YYYY-MM-dd"];
    }else if (type == 2){
      [formatter setDateFormat:@"HH:mm"];
    }else if (type == 3){
        [formatter setDateFormat:SobotKitLocalString(@"MM月dd日")];
    }
    
    
    //将时间转换为字符串
    NSString *timeS = [formatter stringFromDate:myDate];
    
    return timeS;
    
}



@end
