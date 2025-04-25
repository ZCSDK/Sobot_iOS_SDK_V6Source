//
//  ZCSkillGroup1Cell.m
//  SobotKit
//
//  Created by lizh on 2025/1/22.
//

#import "ZCSkillGroup1Cell.h"


@interface ZCSkillGroup1Cell()
{
    
}

@property(nonatomic,strong) UILabel *titleLab;
@property(nonatomic,strong) UILabel *msgTipLab;
@property(nonatomic,strong) NSLayoutConstraint *msgTipLabMT;
@property(nonatomic,strong) NSLayoutConstraint *msgTipLabEH;
@end

@implementation ZCSkillGroup1Cell

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
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

#pragma mark - 布局子控件
-(void)createItemsView{
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
        iv;
    });
    _msgTipLab = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.contentView addSubview:iv];
        iv.textColor = UIColorFromKitModeColor(SobotColorTextSub1);
        iv.font = SobotFont12;
        iv.numberOfLines = 0;
        [self.contentView addConstraint:sobotLayoutPaddingLeft(16, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-16, iv, self.contentView)];
        self.msgTipLabMT = sobotLayoutMarginTop(2, iv, self.titleLab);
        [self.contentView addConstraint:self.msgTipLabMT];
        self.msgTipLabEH = sobotLayoutEqualHeight(20, iv, NSLayoutRelationGreaterThanOrEqual);
        [self.contentView addConstraint:self.msgTipLabEH];
        // 多加4个间距是为了整个cell的高度+ 4
        [self.contentView addConstraint:sobotLayoutPaddingBottom(-7-4, iv, self.contentView)];
//        NSString *string = [NSString stringWithFormat:@"%@，%@%@",SobotKitLocalString(@"暂无客服在线"),SobotKitLocalString(@"您可以"),SobotKitLocalString(@"留言")];
        NSString *string = SobotKitLocalString(@"暂无客服在线，点击进行留言。");
        iv.text = string;
        iv;
    });
}

-(void)initDataToView:(ZCLibSkillSet *) model{
    _msgTipLab.text = @"";
    _titleLab.text = @"";
    // 这里是切换机器人 没有留言的问题
    _titleLab.text = sobotConvertToString(model.groupName);
    self.msgTipLabMT.constant = 0;
    self.msgTipLabEH.constant = 0;
    if (!model.isOnline && [[ZCPlatformTools sharedInstance] getPlatformInfo].config.msgFlag == 0) {
        self.msgTipLabMT.constant = 4;
        self.msgTipLabEH.constant = 20;
//        NSString *string = [NSString stringWithFormat:@"%@，%@%@",SobotKitLocalString(@"暂无客服在线"),SobotKitLocalString(@"您可以"),SobotKitLocalString(@"留言")];
        NSString *string = SobotKitLocalString(@"暂无客服在线，点击进行留言。");
        self.msgTipLab.text = string;
    }

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
