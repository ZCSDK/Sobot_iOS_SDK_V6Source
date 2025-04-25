//
//  ZCChatMessageInfoView.m
//  SobotKit
//
//  Created by zhangxy on 2023/11/23.
//

#import "ZCChatMessageInfoView.h"
#import "ZCChatMessageInfoTextView.h"
#import "ZCChatMessageInfoImgView.h"
#import "ZCChatMessageInfoFileView.h"
#import "ZCChatMessageInfoRichTextView.h"
#import "ZCChatMessageInfoArticleView.h"
@implementation ZCChatMessageInfoView

+(ZCChatMessageInfoView *)createViewUseFactory:(SobotChatMessage *)message{
    ZCChatMessageInfoView *view = nil;
    if(message.msgType == SobotMessageTypeText){
        view = [[ZCChatMessageInfoTextView alloc]init];
    }else if(message.msgType == SobotMessageTypePhoto || message.msgType == SobotMessageTypeVideo){
        view = [[ZCChatMessageInfoImgView alloc] init];
    }else if (message.msgType == 4){
        view = [[ZCChatMessageInfoFileView alloc]init];
    }else if (message.msgType == 5 && message.richModel.type == SobotMessageRichJsonTypeArticle){
        view = [[ZCChatMessageInfoArticleView alloc]init];
    }else{
        view = [[ZCChatMessageInfoRichTextView alloc] init];
    }
    if(view!=nil){
        [view dataToView:message];
    }
    return view;
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
//    _labTopText = ({
//        UILabel *v = [[UILabel alloc] init];
//        v.font = SobotFont14;
//        v.numberOfLines = 0;
//        v.textColor = UIColorFromModeColor(SobotColorTextSub);
//        v.textAlignment = NSTextAlignmentLeft;
//        v.backgroundColor = UIColor.labelColor;
//        [self addSubview:v];
//        [self addConstraint:sobotLayoutPaddingTop(5,v, self)];
//        [self addConstraint:sobotLayoutPaddingLeft(0, v, self)];
//        [self addConstraint:sobotLayoutPaddingRight(0, v, self)];
//        
//        v;
//    });
//    _viewContent = ({
//        UIView *v = [[UIView alloc] init];
//        v.backgroundColor = UIColor.clearColor;
//        [self addSubview:v];
//        
//        [self addConstraint:sobotLayoutMarginTop(5,v, _labTopText)];
//        [self addConstraint:sobotLayoutPaddingLeft(0, v, self)];
//        [self addConstraint:sobotLayoutPaddingRight(0, v, self)];
//        
//        v;
//    });
//    _labTopText2 = ({
//        UILabel *v = [[UILabel alloc] init];
//        v.font = SobotFont14;
//        v.numberOfLines = 0;
//        v.textColor = UIColorFromModeColor(SobotColorTextSub);
//        v.textAlignment = NSTextAlignmentLeft;
//        v.backgroundColor = UIColor.lightGrayColor;
//        [self addSubview:v];
//        [self addConstraint:sobotLayoutMarginTop(5,v, self.viewContent)];
//        [self addConstraint:sobotLayoutPaddingLeft(0, v, self)];
//        [self addConstraint:sobotLayoutPaddingRight(0, v, self)];
//        
//        v;
//    });
//    _labTopText3 = ({
//        UILabel *v = [[UILabel alloc] init];
//        v.font = SobotFont14;
//        v.numberOfLines = 0;
//        v.textColor = UIColorFromModeColor(SobotColorTextSub);
//        v.backgroundColor = UIColor.linkColor;
//        v.textAlignment = NSTextAlignmentLeft;
//        [self addSubview:v];
//        [self addConstraint:sobotLayoutMarginTop(5,v, self.labTopText2)];
//        [self addConstraint:sobotLayoutPaddingLeft(0, v, self)];
//        [self addConstraint:sobotLayoutPaddingRight(0, v, self)];
//        [self addConstraint:sobotLayoutPaddingBottom(-5, v, self)];
//        
//        v;
//    });
    
    
}


-(CGFloat ) dataToView:(SobotChatMessage *)model{
//    self.labTopText.text = sobotConvertToString(model.content);
//    self.labTopText2.text = sobotConvertToString(model.content);
//    self.labTopText3.text = sobotConvertToString(model.content);
    
    // 先更新约束 在获取高度
    [self layoutIfNeeded];
    CGRect f = self.labTopText3.frame;
    
    SLog(@"计算的高度：-----%@", NSStringFromCGRect(f));
    return f.size.height + f.origin.y;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)touchesEnded:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(onViewTouch)]){
        [self.delegate onViewTouch];
    
        return;
    }
    [super touchesEnded:touches withEvent:event];
}
@end
