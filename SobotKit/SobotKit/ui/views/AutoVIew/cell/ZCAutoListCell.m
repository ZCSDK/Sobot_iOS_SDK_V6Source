//
//  ZCAutoListCell.m
//  SobotKit
//
//  Created by lizh on 2025/3/6.
//

#import "ZCAutoListCell.h"

@interface ZCAutoListCell()
@property(nonatomic,strong)UILabel *titleLab;
@end


@implementation ZCAutoListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self createItemsView];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.userInteractionEnabled=YES;
        [self createItemsView];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

-(void)createItemsView{
    _titleLab = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.contentView addSubview:iv];
        iv.textColor = UIColorFromKitModeColor(SobotColorTextMain);
        iv.font = SobotFont14;
        iv.lineBreakMode = NSLineBreakByTruncatingTail;
        iv.numberOfLines = 1;
        [self.contentView addConstraint:sobotLayoutPaddingLeft(16, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-16, iv, self.contentView)];
//        [self.contentView addConstraint:sobotLayoutEqualCenterY(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutEqualHeight(36, iv, NSLayoutRelationEqual)];
        [self.contentView addConstraint:sobotLayoutPaddingTop(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingTop(0, iv, self.contentView)];
        iv;
    });
}

-(void)initDataToView:(NSString *) text attributedText:(NSAttributedString*)attributedText;{
    if (sobotConvertToString(text).length >0) {
        _titleLab.text = text;
    }else{
        _titleLab.attributedText = attributedText;
    }
    _titleLab.lineBreakMode = NSLineBreakByTruncatingTail;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        self.contentView.backgroundColor =  UIColorFromKitModeColor(SobotColorBgF5);
    }else{
        self.contentView.backgroundColor = UIColor.clearColor;
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
