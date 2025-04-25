//
//  ZCOrderCheckMoreCell.m
//  SobotKit
//
//  Created by lizh on 2025/1/8.
// 

#import "ZCOrderCheckMoreCell.h"
#import <SobotChatClient/SobotChatClient.h>
#import <SobotCommon/SobotCommon.h>
#import "ZCUIKitTools.h"

@interface ZCOrderCheckMoreCell()
// 选项组件
@property (nonatomic,strong) UIView *itemView;
@property(nonatomic,strong) NSLayoutConstraint *labelContentPT;
@property(nonatomic,strong) NSLayoutConstraint *labelContentPB;
@property(nonatomic,strong) NSLayoutConstraint *itemMT;
@property(nonatomic,strong) NSLayoutConstraint *itemEH;
@end
@implementation ZCOrderCheckMoreCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self createItemsView];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.userInteractionEnabled=YES;
        [self createItemsView];
        self.backgroundColor = [ZCUIKitTools zcgetLightGrayDarkBackgroundColor];
    }
    return self;
}

-(void)createItemsView{
    
    self.labelName = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.contentView addSubview:iv];
        iv.font = SobotFont14;
        iv.numberOfLines = 0;
        iv.textColor = UIColorFromKitModeColor(SobotColorTextSub);
        
        self.labelNamePT = sobotLayoutPaddingTop(EditCellPT, iv, self.contentView);
        [self.contentView addConstraint:self.labelNamePT];
        self.labelNameEH = sobotLayoutEqualHeight(EditCellTitleH, iv, NSLayoutRelationGreaterThanOrEqual);
        [self.contentView addConstraint:self.labelNameEH];
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            [self.contentView addConstraint:sobotLayoutPaddingLeft(36, iv, self.contentView)];
            [self.contentView addConstraint:sobotLayoutPaddingRight(-EditCellHSpec, iv, self.contentView)];
            iv.textAlignment = NSTextAlignmentRight;
        }else{
            iv.textAlignment = NSTextAlignmentLeft;
            [self.contentView addConstraint:sobotLayoutPaddingLeft(EditCellHSpec, iv, self.contentView)];
            [self.contentView addConstraint:sobotLayoutPaddingRight(-EditCellHSpec, iv, self.contentView)];
        }
        iv;
    });
    
    _itemView = ({
        UIView *iv = [[UIView alloc]init];
        [self.contentView addSubview:iv];
        [iv setBackgroundColor:[UIColor clearColor]];
        self.itemMT = sobotLayoutMarginTop(8, iv, self.labelName);
        [self.contentView addConstraint:self.itemMT];
        NSLayoutConstraint *bgPB = sobotLayoutPaddingBottom(-EditCellPT, iv, self.contentView);
        [self.contentView addConstraint:bgPB];
        self.itemEH = sobotLayoutEqualHeight(EditCellTitleH, iv, NSLayoutRelationGreaterThanOrEqual);
        [self.contentView addConstraint:self.itemEH];
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            [self.contentView addConstraint:sobotLayoutPaddingLeft(36, iv, self.contentView)];
            [self.contentView addConstraint:sobotLayoutPaddingRight(-EditCellHSpec, iv, self.contentView)];
        }else{
            [self.contentView addConstraint:sobotLayoutPaddingLeft(EditCellHSpec, iv, self.contentView)];
            [self.contentView addConstraint:sobotLayoutPaddingRight(-36, iv, self.contentView)];
        }
        iv;
    });
    
    _imgArrow = ({
       UIImageView *iv = [[UIImageView alloc]init];
        iv.image = [SobotUITools getSysImageByName:@"zcicon_arrow_right_record"];
        [self.contentView addSubview:iv];
        [self.contentView addConstraint:sobotLayoutEqualCenterY(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutEqualHeight(12, iv, NSLayoutRelationEqual)];
        [self.contentView addConstraint:sobotLayoutEqualWidth(7, iv, NSLayoutRelationEqual)];
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            [self.contentView addConstraint:sobotLayoutPaddingLeft(16, iv, self.contentView)];
            iv.transform = CGAffineTransformMakeRotation(M_PI);  // M_PI_4 是 45 度
        }else{
            [self.contentView addConstraint:sobotLayoutPaddingRight(-16, iv, self.contentView)];
        }
        iv;
    });
    
    _labelContent = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.contentView addSubview:iv];
        [iv setTextColor:UIColorFromKitModeColor(SobotColorTextSub1)];
        [iv setFont:SobotFont14];
        iv.numberOfLines = 1;
        self.labelContentPT = sobotLayoutMarginTop(EditCellMT, iv, self.labelName);
        [self.contentView addConstraint:self.labelContentPT];
        [self.contentView addConstraint:sobotLayoutEqualHeight(EditCellTitleH, iv, NSLayoutRelationEqual)];
        if (![ZCUIKitTools getSobotIsRTLLayout]) {
            [self.contentView addConstraint:sobotLayoutPaddingLeft(EditCellHSpec, iv, self.contentView)];
            [self.contentView addConstraint:sobotLayoutPaddingRight(-EditCellHSpec, iv, self.contentView)];
        }else{
            [self.contentView addConstraint:sobotLayoutPaddingLeft(36, iv, self.contentView)];
            [self.contentView addConstraint:sobotLayoutPaddingRight(-EditCellHSpec, iv, self.contentView)];
        }
        iv;
    });
    
    self.lineView = ({
        UIView *iv = [[UIView alloc]init];
        [self.contentView addSubview:iv];
        iv.backgroundColor = UIColorFromKitModeColor(SobotColorBgTopLine);
        self.lineViewPL = sobotLayoutPaddingLeft(16, iv, self.contentView);
        [self.contentView addConstraint:self.lineViewPL];
        [self.contentView addConstraint:sobotLayoutPaddingRight(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutEqualHeight(0.5, iv, NSLayoutRelationEqual)];
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            self.lineViewPL.constant = 0;
            [self.contentView addConstraint:sobotLayoutPaddingRight(-EditCellHSpec, iv, self.contentView)];
        }else{
            [self.contentView addConstraint:sobotLayoutPaddingRight(0, iv, self.contentView)];
        }
        iv;
    });
}


-(void)initDataToView:(NSDictionary *)dict{
    [self checkLabelState:NO];
    self.labelName.attributedText = [self getOtherColorString:@"*" Color:[UIColor redColor] withString:dict[@"dictDesc"]];
    if (!sobotIsNull(self.itemView)) {
        // 先移除后创建，点击取消 取消选中的场景
        [self.itemView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
       if(!sobotIsNull(dict[@"dictValue"])){
           self.itemMT.constant = 8;
//           [_labelContent setText:dict[@"dictValue"]];
//           [_labelContent setTextColor:UIColorFromKitModeColor(SobotColorTextSub)];
//           [_labelContent setFont:SobotFontBold14];
           [self createItemsWith:dict[@"dictValue"]];
           _labelContent.hidden = YES;
       }else{
           self.itemMT.constant = 4;
           [_labelContent setText:@""];
           NSString *plStr = SobotKitLocalString(@"请选择");
           [_labelContent setText:plStr];
           [_labelContent setFont:SobotFont14];
           [_labelContent setTextColor:UIColorFromKitModeColor(SobotColorTextSub1)];
           _labelContent.hidden = NO;
       }
       if([dict[@"propertyType"] intValue] == 3){
           _imgArrow.hidden = YES;
       }else{
           _imgArrow.hidden = NO;
       }
}

-(void)createItemsWith:(NSString*)values{
    // 先移除后创建，点击取消 取消选中的场景
    [self.itemView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (!sobotIsNull(values)) {
        NSArray *titles = [values componentsSeparatedByString:@","];
        if (!sobotIsNull(titles) && [titles isKindOfClass:[NSArray class]] && titles.count >0) {
            CGFloat maxW = ScreenWidth - 28 - 8 -8*2;
            CGFloat x = 0;
            CGFloat y = 0;
            CGFloat spx = 8;
            CGFloat itemH = 28;
            UIView *lastView = nil;
            for (int i = 0; i<titles.count; i++) {
                // 最大宽度 sw - 28 - 8;
                NSString *tipStr = sobotConvertToString(titles[i]);
                // 计算最终的宽度
                CGFloat itemW =[self getLabelTextWidthWith:tipStr];
                // 这里多加2个PX是为了解决上面的方法计算的宽可能有误差，导致显示不全 打点显示了
                itemW = itemW + 16+2;
                // 最大值
                if (itemW > maxW) {
                    itemW = maxW;
                }
                if (sobotIsNull(lastView)) {
                   // 第一个
                }else{
                   // 不是第一个
                    if (x + itemW > maxW) {
                        // 换一行显示
                        x = 0;
                        y = itemH + y + spx;
                    }
                }
                lastView = [self createItemWiewWith:x y:y w:itemW h:itemH tip:tipStr];
                x = lastView.frame.origin.x + lastView.frame.size.width + spx;
                [self.itemView addSubview:lastView];
                self.itemEH.constant = y + itemH;
//                if (i == titles.count -1) {
//                    [self.itemView addConstraint:sobotLayoutPaddingBottom(0, lastView, self.itemView)];
//                }
            }
        }
    }
}

-(UIView *)createItemWiewWith:(CGFloat)x y:(CGFloat)y  w:(CGFloat)itemW h:(CGFloat)h tip:(NSString*)tipStr{
    UIView *tipBgView = [[UIView alloc]init];
    tipBgView.backgroundColor = UIColorFromKitModeColor(SobotColorBgF5);
    tipBgView.layer.cornerRadius = 4;
    tipBgView.layer.masksToBounds = YES;
    tipBgView.frame = CGRectMake(x, y, itemW, h);
    UILabel *tipLab = [[UILabel alloc]init];
    tipLab.font = SobotFont12;
    tipLab.textColor = UIColorFromKitModeColor(SobotColorTextMain);
    tipLab.numberOfLines = 1;
    tipLab.text = tipStr;
    [tipBgView addSubview:tipLab];
    [tipBgView addConstraint:sobotLayoutPaddingTop(4, tipLab, tipBgView)];
    [tipBgView addConstraint:sobotLayoutPaddingLeft(8, tipLab, tipBgView)];
    [tipBgView addConstraint:sobotLayoutPaddingRight(-8, tipLab, tipBgView)];
    [tipBgView addConstraint:sobotLayoutPaddingBottom(-4, tipLab, tipBgView)];
    [tipBgView addConstraint:sobotLayoutEqualHeight(20, tipLab, NSLayoutRelationEqual)];
    return tipBgView;
}

-(BOOL)checkLabelState:(BOOL) showSmall{
    BOOL isSmall = [super checkLabelState:showSmall text:@""];
    return isSmall;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(CGFloat)getLabelTextWidthWith:(NSString *)tip{;
    UIFont *font = [UIFont systemFontOfSize:12];
    CGSize maxSize = CGSizeMake(CGFLOAT_MAX, 20);  // 限制高度为一行
    CGRect textRect = [tip boundingRectWithSize:maxSize
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName: font}
                                         context:nil];
    return textRect.size.width;
}

@end
