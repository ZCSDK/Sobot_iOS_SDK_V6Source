//
//  ZCMsgDetailsNoDataCell.m
//  SobotKit
//
//  Created by lizh on 2025/1/21.
//

#import "ZCMsgDetailsNoDataCell.h"
#import "ZCUIKitTools.h"
#import <SobotCommon/SobotCommon.h>
#import "SobotHtmlFilter.h"
#import <SobotChatClient/SobotChatClient.h>
@interface ZCMsgDetailsNoDataCell()

@property (nonatomic,strong)UILabel *tipLab;
@property (nonatomic,strong)UIImageView *iconImg;
@property (nonatomic,strong)UIView *centerView;
@property (nonatomic,strong)NSLayoutConstraint *centerViewH;
@end

@implementation ZCMsgDetailsNoDataCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self createItemsView];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.userInteractionEnabled=YES;
        [self createItemsView];
    }
    return self;
}

-(void)createItemsView{
    
    _centerView =({
        UIView *iv = [[UIView alloc]init];
        [self.contentView addSubview:iv];
        [self.contentView addConstraint:sobotLayoutPaddingTop(145, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(0, iv, self.contentView)];
//        self.centerViewH = sobotLayoutEqualHeight(300, iv, NSLayoutRelationEqual);
//        [self.contentView addConstraint:self.centerViewH];
        iv;
    });
    
    _iconImg = ({
        UIImageView *iv = [[UIImageView alloc]init];
        [self.centerView addSubview:iv];
        [self.centerView addConstraint:sobotLayoutPaddingTop(0, iv, self.centerView)];
        [self.centerView addConstraints:sobotLayoutSize(102, 46, iv, NSLayoutRelationEqual)];
        [self.centerView addConstraint:sobotLayoutEqualCenterX(0, iv, self.centerView)];
        [iv setImage:[SobotUITools getSysImageByName:@"zcicon_no_relply"]];
        iv;
    });
    
    _tipLab = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.centerView addSubview:iv];
        iv.textColor =UIColorFromKitModeColor(SobotColorTextSub1);
        iv.font = SobotFont14;
        iv.numberOfLines = 0;
        iv.text = SobotKitLocalString(@"暂无回复");
        iv.textAlignment = NSTextAlignmentCenter;
        [self.centerView addConstraint:sobotLayoutMarginTop(12, iv, self.iconImg)];
        [self.centerView addConstraint:sobotLayoutEqualCenterX(0, iv, self.centerView)];
        [self.centerView addConstraint:sobotLayoutPaddingLeft(16, iv, self.centerView)];
        [self.centerView addConstraint:sobotLayoutPaddingRight(-16, iv, self.centerView)];
        [self.centerView addConstraint:sobotLayoutPaddingBottom(-6, iv, self.centerView)];
        [self.centerView addConstraint:sobotLayoutEqualHeight(22, iv, NSLayoutRelationGreaterThanOrEqual)];
        iv;
    });
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
