//
//  ZCChatHotCollectionCell.m
//  SobotKit
//
//  Created by zhangxy on 2022/9/21.
//

#import "ZCChatHotCollectionCell.h"
#import "ZCChatBaseCell.h"


@interface ZCChatHotCollectionCell()

@property (strong, nonatomic) UIView *bgView; //背景
@property (strong, nonatomic) SobotImageView *posterView;// 图片
@property (strong, nonatomic) UILabel *labTitle; //标题

@property (strong, nonatomic) NSLayoutConstraint *layoutTitleHeight;
@end

@implementation ZCChatHotCollectionCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView setBackgroundColor:[ZCUIKitTools zcgetChatBackgroundColor]];
        [self createViews];

        [self.contentView addConstraints:sobotLayoutPaddingWithAll(0, 0, 0, 0, self.bgView, self.contentView)];
        
        [self.bgView addConstraints:sobotLayoutSize(34, 42, self.posterView, NSLayoutRelationEqual)];
        [self.bgView addConstraint:sobotLayoutEqualCenterY(0, self.posterView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatCellItemSpace, self.posterView, self.bgView)];
        
        [self.bgView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingHSpace, self.labTitle, self.bgView)];
        [self.bgView addConstraint:sobotLayoutMarginRight(0, self.labTitle, self.posterView)];
        _layoutTitleHeight = sobotLayoutEqualHeight(34, self.labTitle, NSLayoutRelationEqual);
        [self.bgView addConstraint:_layoutTitleHeight];
        [self.bgView addConstraint:sobotLayoutEqualCenterY(0, self.labTitle, self.bgView)];
    }
    return self;
}

-(void)prepareForReuse{
    [super prepareForReuse];
    _posterView.image = nil;
}
-(void)createViews{
    _bgView = ({
        UIView *iv = [[UIView alloc] init];
        [iv setBackgroundColor:UIColor.clearColor];
        [self.contentView addSubview:iv];
        iv;
    });
    
    _posterView = ({
        SobotImageView *iv = [[SobotImageView alloc] init];
        iv.contentMode = UIViewContentModeCenter;
        [iv setImage:SobotKitGetImage(@"zcicon_arrow_right_record")];
        [self.bgView addSubview:iv];
        iv;
    });
    _labTitle = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        [iv setFont:SobotFont14];
        [self.bgView addSubview:iv];
        iv;
    });
}


- (void)configureCellWithPostURL:(NSDictionary *)model message:(SobotChatMessage *)message{
    
    [_posterView setImage:SobotKitGetImage(@"zcicon_arrow_right_record")];
//    [_posterView loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(model[@"thumbnail"])] placeholer:SobotKitGetImage(@"zcicon_default_goods") showActivityIndicatorView:YES];
    [_labTitle setText:sobotConvertToString(model[@"title"])];
}

@end
