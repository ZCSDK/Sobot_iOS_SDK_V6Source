//
//  ZCSkillGroup3Cell.m
//  SobotKit
//
//  Created by lizh on 2025/1/22.
//

#import "ZCSkillGroup3Cell.h"
#import "ZCUIKitTools.h"
@interface ZCSkillGroup3Cell()
{
    
}
@property(nonatomic,strong) UIView *bgView;
@property(nonatomic,strong) UILabel *titleLab;
@property(nonatomic,strong) UILabel *msgTipLab;
@property(nonatomic,strong) NSLayoutConstraint *msgTipLabMT;
@property(nonatomic,strong) NSLayoutConstraint *msgTipLabEH;
@property(nonatomic,strong) SobotImageView *iconImg;
@property(nonatomic,strong) SobotButton *clickBtn;
@end

@implementation ZCSkillGroup3Cell

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
    }
    return self;
}

#pragma mark - 布局子控件
-(void)createItemsView{
    
    _bgView = ({
        UIView *iv = [[UIView alloc]init];
        [self.contentView addSubview:iv];
        iv.layer.cornerRadius = 8;
        iv.layer.masksToBounds = YES;
        iv.layer.borderWidth = 1;
        iv.layer.borderColor = UIColorFromKitModeColor(SobotColorBgTopLine).CGColor;
        [self.contentView addConstraint:sobotLayoutPaddingTop(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(16, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-16, iv, self.contentView)];
        NSLayoutConstraint *bgpb = sobotLayoutPaddingBottom(-16, iv, self.contentView);
//        bgpb.priority = UILayoutPriorityDefaultHigh;
        [self.contentView addConstraint:bgpb];
        iv;
    });
    
    _iconImg = ({
        SobotImageView *iv = [[SobotImageView alloc]init];
        [self.bgView addSubview:iv];
        [self.bgView addConstraints:sobotLayoutSize(40, 40, iv, NSLayoutRelationEqual)];
        [self.bgView addConstraint:sobotLayoutPaddingTop(13, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(10, iv, self.bgView)];
        iv;
    });
    
    _titleLab = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.bgView addSubview:iv];
        iv.font = SobotFontBold14;
        iv.textColor = UIColorFromKitModeColor(SobotColorTextMain);
        iv.numberOfLines = 0;
        [self.bgView addConstraint:sobotLayoutMarginLeft(8, iv, self.iconImg)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-16, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingTop(10, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutEqualHeight(22, iv, NSLayoutRelationGreaterThanOrEqual)];
        iv;
    });
    _msgTipLab = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.bgView addSubview:iv];
        iv.textColor = UIColorFromKitModeColor(SobotColorTextSub1);
        iv.font = SobotFont14;
        iv.numberOfLines = 0;
        [self.bgView addConstraint:sobotLayoutMarginLeft(8, iv, self.iconImg)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-16, iv, self.bgView)];
        self.msgTipLabMT = sobotLayoutMarginTop(2, iv, self.titleLab);
        [self.bgView addConstraint:self.msgTipLabMT];
        self.msgTipLabEH = sobotLayoutEqualHeight(20, iv, NSLayoutRelationGreaterThanOrEqual);
        [self.bgView addConstraint:self.msgTipLabEH];
        NSLayoutConstraint *msgpb = sobotLayoutPaddingBottom(-10, iv, self.bgView);
        msgpb.priority = UILayoutPriorityDefaultHigh;
        [self.bgView addConstraint:msgpb];
        iv.text = @"";
        iv;
    });
    
    _clickBtn = ({
        SobotButton *iv = [SobotButton buttonWithType:UIButtonTypeCustom];
        iv.backgroundColor = UIColor.clearColor;
        [self.bgView addSubview:iv];
        [self.bgView addConstraint:sobotLayoutPaddingTop(0, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(0, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(0, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingBottom(0, iv, self.bgView)];
        [iv addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [iv addTarget:self action:@selector(buttonStateChanged:) forControlEvents:UIControlEventAllEvents];
        iv;
    });
}

// 状态变更时触发
- (void)buttonStateChanged:(UIButton *)sender {
    if (sender.isHighlighted) {
//        _bgView.layer.borderColor = [ZCUIKitTools zcgetServerConfigBtnBgColor].CGColor;
        _bgView.backgroundColor = UIColorFromKitModeColor(SobotColorBgF5);
    } else {
        _bgView.backgroundColor = UIColor.clearColor;
//        _bgView.layer.borderColor = UIColorFromKitModeColor(SobotColorBgTopLine).CGColor;
    }
}

-(void)initDataToView:(ZCLibSkillSet *) model{
    _titleLab.text = @"";
    _msgTipLab.text = @"";
    _clickBtn.obj = @"";
    [self.iconImg loadWithURL:[NSURL URLWithString:sobotConvertToString(model.groupPic)] placeholer:nil showActivityIndicatorView:NO];
    _titleLab.text = sobotConvertToString(model.groupName);
    _msgTipLab.text = sobotConvertToString(model.desc);
    _clickBtn.obj = model;
}

#pragma mark -- 单行点击事件
-(void)btnClick:(SobotButton *)sender{
    ZCLibSkillSet *model = (ZCLibSkillSet*)sender.obj;
    if (self.delegate && [self.delegate respondsToSelector:@selector(jumpGroupModel:)]) {
        [self.delegate jumpGroupModel:model];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
