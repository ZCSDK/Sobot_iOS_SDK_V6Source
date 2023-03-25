//
//  ZCChatWheelCollection2Cell.m
//  SobotKit
//
//  Created by zhangxy on 2022/9/29.
//

#import "ZCChatWheelCollection2Cell.h"

#import "ZCUIKitTools.h"
#import <SobotChatClient/SobotChatClient.h>
#import "ZCChatBaseCell.h"

@interface ZCChatWheelCollection2Cell()

@property(nonatomic,strong) NSLayoutConstraint *layoutImageHeight;
@property(nonatomic,strong) NSLayoutConstraint *layoutImageWidth;
@property(nonatomic,strong) NSLayoutConstraint *layoutImageLeft;

@end

@implementation ZCChatWheelCollection2Cell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = UIColor.clearColor;
        [self createViews];
        self.bgView.backgroundColor = UIColorFromModeColor(SobotColorBgMainDark3);
        
        
        [self.contentView addConstraints:sobotLayoutPaddingWithAll(0, 0, 0, 0, self.bgView, self.contentView)];
        
        
        _layoutImageHeight = sobotLayoutEqualHeight(60, self.posterView, NSLayoutRelationEqual);
        _layoutImageWidth = sobotLayoutEqualWidth(60, self.posterView, NSLayoutRelationEqual);
        _layoutImageLeft = sobotLayoutPaddingLeft(ZCChatPaddingHSpace, self.posterView, self.bgView);
        [self.bgView addConstraint:_layoutImageWidth];
//        [self.bgView addConstraint:_layoutImageHeight];
        [self.bgView addConstraint:_layoutImageLeft];
        [self.bgView addConstraint:sobotLayoutPaddingTop(ZCChatPaddingVSpace, self.posterView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingBottom(-ZCChatPaddingVSpace, self.posterView, self.bgView)];
        
        [self.bgView addConstraint:sobotLayoutPaddingTop(0, self.labTitle, self.posterView)];
        [self.bgView addConstraint:sobotLayoutMarginLeft(ZCChatCellItemSpace, self.labTitle, self.posterView)];
        [self.bgView addConstraint:sobotLayoutMarginRight(-3, self.labTitle, self.labTag)];
        

        [self.bgView addConstraint:sobotLayoutPaddingBottom(0, self.labDesc, self.posterView)];
        [self.bgView addConstraint:sobotLayoutMarginLeft(ZCChatCellItemSpace, self.labDesc, self.posterView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatPaddingHSpace, self.labDesc, self.bgView)];
        
        
       [self.bgView addConstraint:sobotLayoutPaddingTop(0, self.labTag, self.posterView)];
        [self.bgView addConstraint:sobotLayoutEqualWidth(30, self.labTag, NSLayoutRelationGreaterThanOrEqual)];
       [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatPaddingHSpace, self.labTag, self.bgView)];
        
        
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
        [iv setBackgroundColor:[ZCUIKitTools zcgetLightGrayBackgroundColor]];
        iv.layer.cornerRadius = 4;
        iv.layer.masksToBounds = YES;
        [self.contentView addSubview:iv];
        iv;
    });
    
    _posterView = ({
        SobotImageView *iv = [[SobotImageView alloc] init];
        iv.layer.cornerRadius = 4.0f;
        iv.layer.masksToBounds = YES;
        iv.contentMode = UIViewContentModeScaleAspectFill;
        [self.bgView addSubview:iv];
        iv;
    });
    _labTitle = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:UIColorFromModeColor(SobotColorTextMain)];
        [iv setFont:SobotFont14];
        [self.bgView addSubview:iv];
        iv;
    });
    
    _labTag = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentRight];
        [iv setTextColor:[ZCUIKitTools zcgetTimeTextColor]];
        [iv setFont:SobotFont14];
        [self.bgView addSubview:iv];
        iv;
    });
    _labDesc = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
        iv.numberOfLines = 2;
        [iv setTextColor:[ZCUIKitTools zcgetTimeTextColor]];
        [iv setFont:SobotFont14];
        [self.bgView addSubview:iv];
        iv;
    });
}


- (void)configureCellWithPostURL:(NSDictionary *)model message:(SobotChatMessage *)message{
    [_posterView loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(model[@"thumbnail"])] placeholer:SobotKitGetImage(@"zcicon_default_goods") showActivityIndicatorView:YES];
    [_labTitle setText:sobotConvertToString(model[@"title"])];// [NSString stringWithFormat:@"我是标题%@",item[@"row"]] zcicon_avatar_robot
    [_labDesc setText:sobotConvertToString(model[@"summary"])];// [NSString stringWithFormat:@"我是描述%@",item[@"desc"]]
    [_labTag setText:sobotConvertToString(model[@"label"])];
//    [_labLabel setText:sobotConvertToString(model[@"label"])];
    
    
    if(sobotConvertToString(model[@"thumbnail"]).length <= 0){
        _layoutImageLeft.constant = ZCChatPaddingHSpace - ZCChatCellItemSpace;
        _layoutImageWidth.constant = 0;
    }else{
        
        _layoutImageLeft.constant = ZCChatPaddingHSpace;
        _layoutImageWidth.constant = 60;
    }
}

@end
