//
//  ZCSelLeaveViewCell.m
//  SobotKit
//
//  Created by lizh on 2025/1/13.
//

#import "ZCSelLeaveViewCell.h"
#import "ZCUIKitTools.h"

@interface ZCSelLeaveViewCell()
{
    
}
@property(nonatomic,strong) UILabel *titleLab;
@property(nonatomic,strong) UILabel *msgTipLab;
@property(nonatomic,strong) NSLayoutConstraint *msgTipLabMT;
@property(nonatomic,strong) NSLayoutConstraint *msgTipLabEH;
@end

@implementation ZCSelLeaveViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self createItemsView];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.userInteractionEnabled=YES;
        [self createItemsView];
//        self.backgroundColor = [ZCUIKitTools zcgetLightGrayDarkBackgroundColor];
        self.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

#pragma mark - 布局子控件
-(void)createItemsView{
    // 423 新版UI改版 左右16间距
    // 新版UI 标题全部显示 换行展示全部 高度要自适应增加 行高大于等于22
    _titleLab = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.contentView addSubview:iv];
        iv.font = SobotFont14;
        iv.textColor = UIColorFromKitModeColor(SobotColorTextMain);
        iv.numberOfLines = 0;
        [self.contentView addConstraint:sobotLayoutPaddingLeft(16, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-16, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingTop(7, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutEqualHeight(22, iv, NSLayoutRelationGreaterThanOrEqual)];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(-7-4, iv, self.contentView)];
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            iv.textAlignment = NSTextAlignmentRight;
        }
        iv;
    });
}

-(void)initDataToView:(ZCWsTemplateModel *) model{
    _titleLab.text = sobotConvertToString(model.templateName);
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        self.contentView.backgroundColor = UIColorFromKitModeColor(SobotColorBgF5);
    }else{
        self.contentView.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
    }
}

// 配置cell高亮状态
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        self.contentView.backgroundColor = UIColorFromKitModeColor(SobotColorBgF5);
    } else {
        // 增加延迟消失动画效果，提升用户体验
        [UIView animateWithDuration:0.1 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.contentView.backgroundColor = UIColor.clearColor;
        } completion:nil];
    }
}

@end
