//
//  ZCChatReferenceCell.m
//  SobotKit
//
//  Created by zhangxy on 2023/11/16.
//

#import "ZCChatReferenceCell.h"

#import "ZCChatReferenceTextCell.h"
#import "ZCChatReferenceImageCell.h"
#import "ZCChatReferenceFileCell.h"
#import "ZCChatReferenceGoodCell.h"
#import "ZCChatReferenceSoundCell.h"
#import "ZCChatReferenceRichCell.h"
#import "ZCChatReferenceAppletCell.h"
#import "ZCChatReferenceCustomCardCell.h"
#import "ZCChatReferenceCustomVerticalCell.h"

// 横向间隔
static int const ZCReferenceHSpace = 8;
static int const ZCReferenceVSpace = 3;

@interface ZCChatReferenceCell(){
    
}

@property(nonatomic,strong) NSLayoutConstraint *layoutTopTextTop;
@property(nonatomic,strong) NSLayoutConstraint *layoutCustomViewTop;
@property(nonatomic,strong) NSLayoutConstraint *layoutBtmTextTop;

@property(nonatomic,assign) CGFloat contentMaxWidth;
@end

@implementation ZCChatReferenceCell

+(ZCChatReferenceCell *)createViewUseFactory:(SobotChatMessage *)message mainModel:(nonnull SobotChatMessage *)parentMessage maxWidth:(CGFloat)maxWidth{
    ZCChatReferenceCell *cell = nil;
    if(message.msgType == SobotMessageTypeText){
        cell = [[ZCChatReferenceTextCell alloc] init];
    }else if(message.msgType == SobotMessageTypePhoto || message.msgType == SobotMessageTypeVideo){
        cell = [[ZCChatReferenceImageCell alloc] init];
    }else if (message.msgType == SobotMessageTypeFile){
        cell = [[ZCChatReferenceFileCell alloc]init];
    }else if(message.richModel.type == SobotMessageRichJsonTypeGoods){
        cell = [[ZCChatReferenceGoodCell alloc]init];
    }else if (message.msgType == SobotMessageTypeSound){
        cell = [[ZCChatReferenceSoundCell alloc]init];
    }else if(message.richModel.type == SobotMessageRichJsonTypeText){
        cell = [[ZCChatReferenceRichCell alloc] init];
    }else if (message.richModel.type == SobotMessageRichJsonTypeApplet||
              message.richModel.type == SobotMessageRichJsonTypeArticle||
              message.richModel.type == SobotMessageRichJsonTypeLocation){
        cell = [[ZCChatReferenceAppletCell alloc]init];
    }else if (message.richModel.type == SobotMessageRichJsonTypeCustomCard){
        if(message.richModel.customCard.cardStyle == 0){
            // 水平
            cell = [[ZCChatReferenceCustomCardCell alloc]init];
        }else if(message.richModel.customCard.cardStyle == 1){
            // 列表
            cell = [[ZCChatReferenceCustomVerticalCell alloc]init];
        }
       
    }else{
        cell = [[ZCChatReferenceCell alloc] init];
    }
    if(cell!=nil){
        cell.maxWidth = maxWidth;
        cell.parentMessage = parentMessage;
        [cell dataToView:message];
    }
    return cell;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        self.userInteractionEnabled = YES;
        [self layoutSubViewUI];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self layoutSubViewUI];
    }
    return self;
}

-(void)layoutSubViewUI{
    _viewLeftLine = ({
        UIView *v = [[UIView alloc] init];
        [self addSubview:v];
        v.backgroundColor = UIColorFromKitModeColorAlpha(SobotColorWhite, 0.4);
        
        [self addConstraint:sobotLayoutPaddingTop(0, v, self)];
        [self addConstraint:sobotLayoutPaddingLeft(0, v, self)];
        NSLayoutConstraint *lineBtm = sobotLayoutPaddingBottom(0, v, self);
        lineBtm.priority = UILayoutPriorityDefaultLow;
        [self addConstraint:lineBtm];
        NSLayoutConstraint *lineW = sobotLayoutEqualWidth(2, v,NSLayoutRelationEqual);
        lineW.priority = UILayoutPriorityDefaultHigh;
        [self addConstraint:lineW];
        
        v;
    });
    
    _labName = ({
        UILabel *v = [[UILabel alloc] init];
        v.font = SobotFont14;
        v.textColor = UIColorFromModeColor(SobotColorTextSub);
        v.textAlignment = NSTextAlignmentLeft;
        [self addSubview:v];
        [self addConstraint:sobotLayoutPaddingTop(0, v, self)];
        [self addConstraint:sobotLayoutMarginLeft(ZCReferenceHSpace, v, self.viewLeftLine)];
        [self addConstraint:sobotLayoutPaddingRight(0, v, self)];
        
        v;
    });
    _labTopText = ({
        UILabel *v = [[UILabel alloc] init];
        v.font = SobotFont14;
        v.textColor = UIColorFromModeColor(SobotColorTextSub);
        v.textAlignment = NSTextAlignmentLeft;
        [self addSubview:v];
        _layoutTopTextTop = sobotLayoutMarginTop(ZCReferenceVSpace, v, self.labName);
        _layoutTopTextTop.priority = UILayoutPriorityDefaultHigh;
        [self addConstraint:_layoutTopTextTop];
        [self addConstraint:sobotLayoutMarginLeft(ZCReferenceHSpace, v, self.viewLeftLine)];
        [self addConstraint:sobotLayoutPaddingRight(0, v, self)];
        
        v;
    });
    _viewContent = ({
        UIView *v = [[UIView alloc] init];
        v.backgroundColor = UIColor.clearColor;
        [self addSubview:v];
        _layoutCustomViewTop = sobotLayoutMarginTop(ZCReferenceVSpace, v, self.labTopText);
        _layoutCustomViewTop.priority = UILayoutPriorityDefaultHigh;
        [self addConstraint:_layoutCustomViewTop];
        [self addConstraint:sobotLayoutMarginLeft(ZCReferenceHSpace, v, self.viewLeftLine)];
        [self addConstraint:sobotLayoutPaddingRight(0, v, self)];
        
        v;
    });
    
    _labBottomText = ({
        UILabel *v = [[UILabel alloc] init];
        v.font = SobotFont14;
        v.textColor = UIColorFromModeColor(SobotColorTextSub);
        v.textAlignment = NSTextAlignmentLeft;
        [self addSubview:v];
        _layoutBtmTextTop = sobotLayoutMarginTop(ZCReferenceVSpace, v, self.viewContent);
        _layoutBtmTextTop.priority = UILayoutPriorityDefaultHigh;
        [self addConstraint:_layoutBtmTextTop];
        [self addConstraint:sobotLayoutMarginLeft(ZCReferenceHSpace, v, self.viewLeftLine)];
        [self addConstraint:sobotLayoutPaddingRight(0, v, self)];
        NSLayoutConstraint *layoutTB = sobotLayoutPaddingBottom(0, v, self);
        layoutTB.priority = UILayoutPriorityDefaultLow;
        [self addConstraint:layoutTB];
        
        v;
    });
    
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
    [self addGestureRecognizer:tap];
}



-(void)tapClick:(UITapGestureRecognizer *) tap{
    [self viewEvent:ZCChatReferenceCellEventOpen state:0 obj:nil];
}



-(void)dataToView:(SobotChatMessage *)message{
    self.tempMessage = message;
    
    
    if(_parentMessage.senderType == 2){
        // 当为客服时，对方应该显示我
        if(message.appointType == 1){
            _labName.text = SobotKitLocalString(@"我");
        }else if(message.appointType == 2){
            _labName.text = SobotKitLocalString(@"客服");  // SDK是用户视角 除了自己都显示客服
        }else{
            _labName.text = SobotKitLocalString(@"客服");
        }
    }else{
        if(message.senderType == 0 && message.appointType == 0){
            _labName.text = SobotKitLocalString(@"我");
        }else if(message.senderType == 1 || message.appointType == 2){
    //        _labName.text = SobotKitLocalString(@"机器人");  // SDK是用户视角 除了自己都显示客服
            _labName.text = SobotKitLocalString(@"客服");
        }else{
            _labName.text = SobotKitLocalString(@"客服");
        }
    }
    
    
    
    if(self.parentMessage!=nil){
        if(self.parentMessage.senderType == 0){
            self.isRight = YES;
            self.labTopText.textColor = [ZCUIKitTools zcgetRightChatTextColor];
            _viewLeftLine.backgroundColor =  UIColorFromKitModeColorAlpha(SobotColorWhite, 0.4);
            _labName.textColor  = [ZCUIKitTools zcgetRightChatTextColor];
        }else{
            self.isRight = NO;
            self.labTopText.textColor = [ZCUIKitTools zcgetChatLeftLinkColor];
            self.labName.textColor = [ZCUIKitTools zcgetLeftChatTextColor];
            _viewLeftLine.backgroundColor = UIColorFromKitModeColor(@"#CCCCCC");
        }
    }
    
    // 清理数据
    _layoutTopTextTop.constant = 0;
    _layoutCustomViewTop.constant = 0;
    _layoutBtmTextTop.constant = 0;
    _labTopText.text = @"";
    _labBottomText.text = @"";
}

-(void)viewEvent:(ZCChatReferenceCellEvent)type state:(int) state obj:(id _Nullable) obj{
    if(type == ZCChatReferenceCellEventOpen){
        [[ZCUICore getUICore] showDetailViewWiht:self.tempMessage];
        if(self.delegate && [self.delegate respondsToSelector:@selector(onReferenceCellEvent:type:state:obj:)]){
            [self.delegate onReferenceCellEvent:self.tempMessage type:ZCChatReferenceCellEventCloseKeyboard state:state obj:obj];
        }
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(onReferenceCellEvent:type:state:obj:)]){
        [self.delegate onReferenceCellEvent:self.tempMessage type:type state:state obj:obj];
    }
}

-(void)showContent:(NSString *)topText view:(UIView *)customView btm:(NSString *)bottomText isMaxWidth:(BOOL)isMaxWidth customViewWidth:(CGFloat)width{
    _layoutTopTextTop.constant = 0;
    _layoutCustomViewTop.constant = 0;
    _layoutBtmTextTop.constant = 0;
    
    // 最大高度
    if(customView!=nil){
        _labTopText.numberOfLines = 1;
        _labBottomText.numberOfLines = 1;
        
        _layoutCustomViewTop.constant = ZCReferenceVSpace;
    }else{
        _labTopText.numberOfLines = 3;
        _labBottomText.numberOfLines = 3;
    }
    
    
    // 计算最大宽度
    if(!sobotIsNull(customView)){
        self.contentMaxWidth = CGRectGetWidth(customView.frame);
    }
    if(width >0){
        self.contentMaxWidth = width;
    }
    if(isMaxWidth){
        self.contentMaxWidth = ScreenWidth;
    }
    
    
    CGFloat richWidth = 0;
    // 富文本的消息 需要计算最大宽度
    if(sobotConvertToString(topText).length > 0){
        _labTopText.text = [SobotHtmlCore removeAllHTMLTag:sobotConvertToString(topText)];
        _layoutTopTextTop.constant = ZCReferenceVSpace;
        CGSize s2 = [_labTopText sizeThatFits:CGSizeMake(self.maxWidth-ZCReferenceHSpace, CGFLOAT_MAX)];
        richWidth = s2.width + ZCReferenceHSpace*2;
    }
    
    //
    if(sobotConvertToString(bottomText).length > 0 && sobotConvertToString(topText).length == 0 ){
        _labBottomText.text = [SobotHtmlCore removeAllHTMLTag:sobotConvertToString(bottomText)];
        _layoutTopTextTop.constant = ZCReferenceVSpace;
        CGSize s2 = [_labBottomText sizeThatFits:CGSizeMake(self.maxWidth-ZCReferenceHSpace, CGFLOAT_MAX)];
        if(s2.width > richWidth){
            richWidth = s2.width + ZCReferenceHSpace*2;
        }
    }
    
    // 富文本需要获取最后的宽度
    if(richWidth > self.contentMaxWidth){
        self.contentMaxWidth = richWidth;
    }
    
}

#pragma mark -- 获取最大宽度
-(CGFloat)getContenMaxWidth{
    return self.contentMaxWidth;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
