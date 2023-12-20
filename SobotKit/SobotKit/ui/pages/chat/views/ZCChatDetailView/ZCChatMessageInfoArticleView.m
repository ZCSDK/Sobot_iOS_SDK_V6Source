//
//  ZCChatMessageInfoArticleView.m
//  SobotKit
//
//  Created by lizh on 2023/11/23.
//

#import "ZCChatMessageInfoArticleView.h"

@interface  ZCChatMessageInfoArticleView()<SobotEmojiLabelDelegate>

@property(nonatomic,strong)UIView *articleView;
@property(nonatomic,strong)SobotImageView *logoView;
@property(nonatomic,strong)UILabel *articelTitleLab;
@property(nonatomic,strong)UILabel *descLab;
@property(nonatomic,strong)UIView *artLineView;
@property(nonatomic,strong)SobotImageView *nextView;
@property(nonatomic,strong)SobotEmojiLabel *lookMoreLab;
@property(nonatomic,strong)SobotButton *fileBtn;

@property(nonatomic,strong)NSLayoutConstraint *logoViewEH;

@end

@implementation ZCChatMessageInfoArticleView

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
    // 文章
    _articleView = ({
        UIView *iv = [[UIView alloc]init];
        [self addSubview:iv];
        [self addConstraint:sobotLayoutPaddingTop(0, iv, self)];
        [self addConstraint:sobotLayoutEqualWidth(226, iv, NSLayoutRelationEqual)];
        [self addConstraint:sobotLayoutPaddingLeft(42, iv, self)];
        iv;
    });
        
    _logoView = ({
        SobotImageView *iv = [[SobotImageView alloc]init];
        [_articleView addSubview:iv];
        [_articleView addConstraint:sobotLayoutPaddingTop(0, iv, _articleView)];
        [_articleView addConstraint:sobotLayoutPaddingLeft(0, iv, _articleView)];
        [_articleView addConstraint:sobotLayoutPaddingRight(0, iv, _articleView)];
        self.logoViewEH = sobotLayoutEqualHeight(0, iv, NSLayoutRelationEqual);
        [_articleView addConstraint:self.logoViewEH];
        iv;
    });

    _articelTitleLab = ({
        UILabel *iv = [[UILabel alloc]init];
        [_articleView addSubview:iv];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setFont:SobotFont14];
        [iv setTextColor:UIColorFromKitModeColor(@"0x0DAEAF")]; // 0x515a7c
        [iv setBackgroundColor:[UIColor clearColor]];
        iv.numberOfLines = 1;
        [_articleView addConstraint:sobotLayoutMarginTop(12, iv, _logoView)];
        [_articleView addConstraint:sobotLayoutPaddingLeft(15, iv, _articleView)];
        [_articleView addConstraint:sobotLayoutPaddingRight(-15, iv, _articleView)];
        iv;
    });
       
    _descLab = ({
        // 描述
        UILabel *iv = [[UILabel alloc]init];
        [_articleView addSubview:iv];
        iv.textColor = UIColorFromModeColor(SobotColorTextMain);
        iv.font = [UIFont systemFontOfSize:14];
        iv.numberOfLines = 2;
        iv.lineBreakMode = NSLineBreakByTruncatingTail;
        [_articleView addConstraint:sobotLayoutMarginTop(5, iv, _articelTitleLab)];
        [_articleView addConstraint:sobotLayoutPaddingLeft(15, iv, _articleView)];
        [_articleView addConstraint:sobotLayoutPaddingRight(-15, iv, _articleView)];
        iv;
    });
       
    _artLineView = ({
        //线条
        UIView *iv = [[UIView alloc]init];
        [_articleView addSubview:iv];
        iv.backgroundColor = UIColorFromModeColor(SobotColorBgLine);
        [_articleView addConstraint:sobotLayoutMarginTop(12, iv, _descLab)];
        [_articleView addConstraint:sobotLayoutPaddingLeft(15, iv, _articleView)];
        [_articleView addConstraint:sobotLayoutPaddingRight(-15, iv, _articleView)];
        [_articleView addConstraint:sobotLayoutEqualHeight(1, iv, NSLayoutRelationEqual)];
        iv;
    });
       
    _nextView = ({
        SobotImageView *iv = [[SobotImageView alloc]init];
        [iv setBackgroundColor:[UIColor clearColor]];
        [iv setContentMode:UIViewContentModeScaleAspectFill];
        [iv setImage:[UIImage imageNamed:@"zcicon_arrow_reply"]];
        [_articleView addSubview:iv];
        [_articleView addConstraint:sobotLayoutPaddingRight(-15, iv, _articleView)];
        [_articleView addConstraint:sobotLayoutMarginTop(10, iv, _artLineView)];
        [_articleView addConstraint:sobotLayoutEqualHeight(9, iv, NSLayoutRelationEqual)];
        [_articleView addConstraint:sobotLayoutEqualWidth(5, iv, NSLayoutRelationEqual)];
        iv;
    });
    
    _lookMoreLab = ({
        SobotEmojiLabel *iv = [[SobotEmojiLabel alloc] initWithFrame:CGRectZero];
        [_articleView addSubview:iv];
        iv.numberOfLines = 1;
        iv.font = SobotFont14;
        iv.delegate = self;
        iv.lineBreakMode = NSLineBreakByTruncatingTail;
        iv.textColor = UIColorFromModeColor(SobotColorTextMain);
        iv.isNeedAtAndPoundSign = NO;
        iv.disableEmoji = NO;
        iv.lineSpacing = 3.0f;
        [_articleView addConstraint:sobotLayoutMarginRight(-5,iv, _nextView)];
        [_articleView addConstraint:sobotLayoutEqualCenterY(0, iv, _nextView)];
        [_articleView addConstraint:sobotLayoutPaddingLeft(15, iv, _nextView)];
        [_articleView addConstraint:sobotLayoutPaddingBottom(-10, iv, _articleView)];
        iv;
    });
        
        
    _fileBtn = ({
        SobotButton *iv = [SobotButton buttonWithType:UIButtonTypeCustom];
        [iv setBackgroundColor:[UIColor clearColor]];
        [_articleView addSubview:iv];
        [iv addTarget:self action:@selector(articelClick:) forControlEvents:UIControlEventTouchUpInside];
        [_articleView addConstraint:sobotLayoutPaddingLeft(0, iv, _articleView)];
        [_articleView addConstraint:sobotLayoutPaddingRight(0, iv, _articleView)];
        [_articleView addConstraint:sobotLayoutPaddingTop(0, iv, _articleView)];
        [_articleView addConstraint:sobotLayoutPaddingBottom(0, iv, _articleView)];
        iv;
    });
       
}

-(CGFloat)dataToView:(SobotChatMessage *)model{
    _fileBtn.obj = sobotConvertToString(model.richModel.richContent.richMoreUrl);
    _descLab.text = sobotConvertToString(model.richModel.richContent.desc);
    _articelTitleLab.text = sobotConvertToString(model.richModel.richContent.title);
    if (sobotConvertToString(model.richModel.richContent.snapshot).length > 0) {
        // 有图片
        self.logoViewEH.constant = 137;
    }else{
        self.logoViewEH.constant = 10;
    }
    // 先更新约束 在获取高度
    [self layoutIfNeeded];
    CGRect f = self.lookMoreLab.frame;
    SLog(@"计算的高度：-----%@", NSStringFromCGRect(f));
    return f.size.height + f.origin.y + 10;
}

#pragma mark --文章的点击事件
-(void)articelClick:(SobotButton *)sender{
    NSString *url = sobotConvertToString(sender.obj);
    if (sobotConvertToString(url).length == 0) {
        return;
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(onViewEvent:dict:obj:)]){
        [self.delegate onViewEvent:ZCChatMessageInfoViewEventOpenUrl dict:@{} obj:sobotConvertToString(url)];
    }
}
@end
