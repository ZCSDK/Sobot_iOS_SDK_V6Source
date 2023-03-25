//
//  ZCChatWheelCollectionCell.m
//  SobotKit
//
//  Created by zhangxy on 2022/9/21.
//

#import "ZCChatWheelCollectionCell.h"
#import "ZCUIKitTools.h"
#import <SobotChatClient/SobotChatClient.h>
#import "ZCChatBaseCell.h"

@interface ZCChatWheelCollectionCell()

@property(nonatomic,strong) NSLayoutConstraint *layoutBgBottom;
@property(nonatomic,strong) NSLayoutConstraint *layoutTitleTop;
@property(nonatomic,strong) NSLayoutConstraint *layoutTitleHeight;

@property(nonatomic,strong) NSLayoutConstraint *layoutImageHeight;
@property(nonatomic,strong) NSLayoutConstraint *layoutImageWidth;
@property(nonatomic,strong) NSLayoutConstraint *layoutImageLeft;

@end

@implementation ZCChatWheelCollectionCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = UIColor.clearColor;
        [self createViews];
        self.bgView.backgroundColor = UIColorFromModeColor(SobotColorBgMainDark3);
        
        [self.contentView addConstraint:sobotLayoutPaddingTop(0, self.bgView, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(0, self.bgView, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(0, self.bgView, self.contentView)];
        _layoutBgBottom = sobotLayoutPaddingBottom(0, self.bgView, self.contentView);
        [self.contentView addConstraint:_layoutBgBottom];
//        [self.contentView addConstraints:sobotLayoutPaddingWithAll(0, 0, 0, 0, self.bgView, self.contentView)];
        _layoutTitleTop = sobotLayoutPaddingTop(0, self.labTitle, self.bgView);
        [self.bgView addConstraint:_layoutTitleTop];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingHSpace, self.labTitle, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatPaddingHSpace, self.labTitle, self.bgView)];
        _layoutTitleHeight = sobotLayoutEqualHeight(34, self.labTitle, NSLayoutRelationEqual);
        _layoutTitleHeight.priority = UILayoutPriorityDefaultLow;
        [self.bgView addConstraint:_layoutTitleHeight];
        
        _layoutImageHeight = sobotLayoutEqualHeight(60, self.posterView, NSLayoutRelationEqual);
        _layoutImageWidth = sobotLayoutEqualWidth(60, self.posterView, NSLayoutRelationEqual);
        _layoutImageLeft = sobotLayoutPaddingLeft(ZCChatPaddingHSpace, self.posterView, self.bgView);
        [self.bgView addConstraint:_layoutImageWidth];
        [self.bgView addConstraint:_layoutImageHeight];
        [self.bgView addConstraint:_layoutImageLeft];
        [self.bgView addConstraint:sobotLayoutMarginTop(ZCChatCellItemSpace, self.posterView, self.labTitle)];
//        [self.bgView addConstraint:sobotLayoutPaddingBottom(-ZCChatPaddingVSpace, self.posterView, self.bgView)];
         
         
        [self.bgView addConstraint:sobotLayoutPaddingTop(0, self.labDesc, self.posterView)];
        [self.bgView addConstraint:sobotLayoutMarginLeft(ZCChatCellItemSpace, self.labDesc, self.posterView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatPaddingHSpace, self.labDesc, self.bgView)];
        
        
       [self.bgView addConstraint:sobotLayoutPaddingBottom(-ZCChatCellItemSpace, self.labLabel, self.posterView)];
       [self.bgView addConstraint:sobotLayoutMarginLeft(ZCChatCellItemSpace, self.labLabel, self.posterView)];
        [self.bgView addConstraint:sobotLayoutEqualWidth(80, self.labLabel, NSLayoutRelationEqual)];
        
        
       [self.bgView addConstraint:sobotLayoutPaddingBottom(-ZCChatCellItemSpace, self.labTag, self.posterView)];
       [self.bgView addConstraint:sobotLayoutMarginLeft(ZCChatCellItemSpace, self.labTag, self.labLabel)];
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
        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        [iv setFont:SobotFont14];
        [self.bgView addSubview:iv];
        iv;
    });
    
    _labTag = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentRight];
        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        [iv setFont:SobotFont14];
        [self.bgView addSubview:iv];
        iv;
    });
    _labDesc = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        [iv setFont:SobotFont14];
        [self.bgView addSubview:iv];
        iv;
    });
    _labLabel = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:[ZCUIKitTools zcgetChatLeftLinkColor]];
        [iv setFont:SobotFont14];
        [self.bgView addSubview:iv];
        iv;
    });
    
}


- (void)configureCellWithPostURL:(NSDictionary *)model message:(SobotChatMessage *)message{
    [_posterView loadWithURL:[NSURL URLWithString:sobotUrlEncodedString(model[@"thumbnail"])] placeholer:SobotKitGetImage(@"zcicon_default_goods") showActivityIndicatorView:YES];
    [_labTitle setText:sobotConvertToString(model[@"title"])];// [NSString stringWithFormat:@"我是标题%@",item[@"row"]] zcicon_avatar_robot
    [_labDesc setText:sobotConvertToString(model[@"summary"])];// [NSString stringWithFormat:@"我是描述%@",item[@"desc"]]
    [_labTag setText:sobotConvertToString(model[@"tag"])];
    [_labLabel setText:sobotConvertToString(model[@"label"])];
    [_labTitle setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
    
    _labTag.hidden = NO;
    _labLabel.hidden = NO;
    _labDesc.hidden = NO;
    _posterView.hidden = NO;
    _labTitle.textAlignment = NSTextAlignmentLeft;
    _bgView.layer.cornerRadius = 4;
    int templeteId = message.richModel.richContent.templateId;
    _layoutTitleTop.constant = ZCChatPaddingVSpace;
    if(templeteId == 0){
        
        // 大图，有标题
        [_labDesc setTextColor:[ZCUIKitTools zcgetTextPlaceHolderColor]];
        
        _layoutImageHeight.constant = 60;
        _layoutImageWidth.constant = 60;
        
        _layoutBgBottom.constant = 0;
        
    }
    else if(templeteId == 1){
        _layoutBgBottom.constant = - ZCChatCellItemSpace;
        _layoutTitleTop.constant = 0;
        // 单行
        if(!message.isHistory){
            [_labTitle setTextColor:[ZCUIKitTools zcgetChatLeftLinkColor]];
        }
        _labTitle.numberOfLines = 1;
//        _layoutTitleTop.constant = ZCChatCellItemSpace;
        _labTitle.textAlignment = NSTextAlignmentCenter;
        _bgView.layer.cornerRadius = 15;
        _layoutTitleHeight.constant = 30;
        // 显示连接样式时，需要显示序号
        if(message.richModel.richContent.showLinkStyle){
            _labTitle.numberOfLines = 2;
            _bgView.layer.cornerRadius = 17;
            _layoutTitleHeight.constant = 34;
            // 自动折行设置
            _labTitle.lineBreakMode = NSLineBreakByCharWrapping;
            [_labTitle setText:[NSString stringWithFormat:@"%d、%@",(int)self.indexPath.row+1,sobotConvertToString(model[@"title"])]];
            [_labTitle sizeToFit];
        }
        // 撑起lab的高度
        _layoutImageHeight.constant = 0;
        _labTag.hidden = YES;
        _labLabel.hidden = YES;
        _labDesc.hidden = YES;
    }else if(templeteId == 2){
        
        _layoutBgBottom.constant = 0;
            _layoutTitleTop.constant = 0;
            _layoutTitleHeight.constant = 0;

            [_labDesc setText:_labTitle.text];
            _labTitle.text = @"";
            // 小图，无标题
            [_labDesc setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
            _layoutImageHeight.constant = 50;
            _layoutImageWidth.constant = 50;
    }
}

@end
