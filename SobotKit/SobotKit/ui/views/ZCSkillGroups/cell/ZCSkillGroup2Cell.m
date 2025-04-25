//
//  ZCSkillGroup2Cell.m
//  SobotKit
//
//  Created by lizh on 2025/1/22.
//

#import "ZCSkillGroup2Cell.h"

#define celllp 24
#define cellSp 16
#define cellMT 20
#define cellPT 4
#define ItemHW  50
@interface ZCSkillGroup2Cell()

@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UILabel *maxLab;

@end

@implementation ZCSkillGroup2Cell

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
    _bgView = ({
        UIView *iv = [[UIView alloc]init];
        [self.contentView addSubview:iv];
        [self.contentView addConstraint:sobotLayoutPaddingTop(cellPT, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(0, iv, self.contentView)];
        NSLayoutConstraint *bgpb = sobotLayoutPaddingBottom(0, iv, self.contentView);
        bgpb.priority = UILayoutPriorityDefaultHigh;
        [self.contentView addConstraint:bgpb];
        iv;
    });
}

#pragma mark -- 九宫格布局
-(void)initDataToView:(NSMutableArray *)listArray{
    // 先移除，后添加
    [[self.bgView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (!sobotIsNull(listArray) && [listArray isKindOfClass:[NSMutableArray class]] && listArray.count >0) {
        float fileBgView_margin_left = 24;
        float fileBgView_margin = 16;
//      宽度固定为  （屏幕宽度 - 60)/3
        CGSize fileViewRect = CGSizeMake((ScreenWidth -24*2-16*2)/3, 76);
//      算一下每行多少个 ，
        float nums = 3;
        if ([UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height) {
            NSLog(@"当前是横屏");
            nums = 6;
            fileViewRect = CGSizeMake((ScreenWidth -24*2-16*5)/6, 76);
        } else {
            NSLog(@"当前不是横屏");
        }
        NSInteger numInt = floor(nums);
//      行数：
//        NSInteger rows = ceil(listArray.count/(float)numInt);
        // 一行中最高的那个lael
        UILabel *maxHLab;
        // 最大行高的button;
        UIButton *maxHBtn;
        // 一行中最大的高度
        CGFloat rowMaxH = 0;
        // 最后一个行view
        UIView *lastRowView;
        for (int i = 0 ; i < listArray.count;i++) {
            ZCLibSkillSet *model = listArray[i];
            // 当前列数
            NSInteger currentColumn = i%numInt;
//           当前行数
//            NSInteger currentRow = i/numInt;
            float x = fileBgView_margin_left + (fileViewRect.width + fileBgView_margin)*currentColumn;
            float w = fileViewRect.width;
            
            if (x == fileBgView_margin_left) {
                if (!sobotIsNull(lastRowView)) {
                    // 换行了 设置上一个最大行高
                    [lastRowView addConstraint:sobotLayoutPaddingBottom(0, maxHBtn, lastRowView)];
                    // 回执默认
                    maxHLab = nil;
                    maxHBtn = nil;
                    rowMaxH = 0;
                }
                
                // 第一列
                UIView *rowBgView = [[UIView alloc]init];
                [self.bgView addSubview:rowBgView];
                if (sobotIsNull(lastRowView)) {
                    [self.bgView addConstraint:sobotLayoutPaddingTop(0, rowBgView, self.bgView)];
                }else{
                    [self.bgView addConstraint:sobotLayoutMarginTop(20, rowBgView, lastRowView)];
                }
                [self.bgView addConstraint:sobotLayoutPaddingLeft(0, rowBgView, self.bgView)];
                [self.bgView addConstraint:sobotLayoutPaddingRight(0, rowBgView, self.bgView)];
                lastRowView = rowBgView;
            }
            
            
            // 布局单个item
            UIButton *itemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [lastRowView addSubview:itemBtn];
            [lastRowView addConstraint:sobotLayoutPaddingTop(0, itemBtn, lastRowView)];
            [lastRowView addConstraint:sobotLayoutPaddingLeft(x, itemBtn, lastRowView)];
            [lastRowView addConstraint:sobotLayoutEqualWidth(w, itemBtn, NSLayoutRelationEqual)];
//            itemBtn.backgroundColor = UIColor.purpleColor;
            
            SobotImageView *icon = [[SobotImageView alloc]init];
            [itemBtn addSubview:icon];
            [itemBtn addConstraints:sobotLayoutSize(50, 50, icon, NSLayoutRelationEqual)];
            [itemBtn addConstraint:sobotLayoutPaddingTop(0, icon, itemBtn)];
            [itemBtn addConstraint:sobotLayoutEqualCenterX(0, icon, itemBtn)];
            [icon loadWithURL:[NSURL URLWithString:sobotConvertToString(model.groupPic)] placeholer:nil showActivityIndicatorView:NO];
            
            UILabel *titleLab = [[UILabel alloc]init];
            [itemBtn addSubview:titleLab];
            titleLab.textColor = UIColorFromKitModeColor(SobotColorTextMain);
            titleLab.font = SobotFont14;
            titleLab.numberOfLines = 0;
            titleLab.textAlignment = NSTextAlignmentCenter;
            titleLab.text = sobotConvertToString(model.groupName);
            [itemBtn addConstraint:sobotLayoutMarginTop(4, titleLab, icon)];
            [itemBtn addConstraint:sobotLayoutEqualHeight(22, titleLab, NSLayoutRelationGreaterThanOrEqual)];
            [itemBtn addConstraint:sobotLayoutPaddingLeft(0, titleLab, itemBtn)];
            [itemBtn addConstraint:sobotLayoutEqualWidth(w, titleLab, NSLayoutRelationEqual)];
//            titleLab.backgroundColor = UIColor.yellowColor;
            [itemBtn addConstraint:sobotLayoutPaddingBottom(0, titleLab, itemBtn)];
            // 点击响应区域
            SobotButton *clickBtn = [SobotButton buttonWithType:UIButtonTypeCustom];
            [itemBtn addSubview:clickBtn];
            clickBtn.obj = model;
            [clickBtn setBackgroundColor:UIColor.clearColor];
            [clickBtn addTarget:self action:@selector(clickBtnAction:) forControlEvents:UIControlEventTouchUpInside];
            [itemBtn addConstraint:sobotLayoutPaddingTop(0, clickBtn, itemBtn)];
            [itemBtn addConstraint:sobotLayoutPaddingLeft(0, clickBtn, itemBtn)];
            [itemBtn addConstraint:sobotLayoutPaddingRight(0, clickBtn, itemBtn)];
            [itemBtn addConstraint:sobotLayoutPaddingBottom(0, clickBtn, itemBtn)];
            
            // 获取高度
            CGFloat th = [SobotUITools getHeightContain:sobotConvertToString(model.groupName) font:SobotFont14 Width:w];
            if (th >= rowMaxH) {
                rowMaxH = th;
                if (rowMaxH < 22) {
                    rowMaxH = 22;
                }
                maxHLab = titleLab;
                maxHBtn = itemBtn;
            }
            if (i == listArray.count -1) {
                [self.bgView addConstraint:sobotLayoutPaddingBottom(-10, lastRowView, self.bgView)];
                // 最后一个  设置最大高度
                if (i == 0) {
                    // 只有一个
                    [lastRowView addConstraint:sobotLayoutPaddingBottom(0, maxHBtn, lastRowView)];
                }else{
                    [lastRowView addConstraint:sobotLayoutPaddingBottom(0, maxHBtn, lastRowView)];
                }
            }
        }
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGRect bgf = self.bgView.frame;
    if (bgf.size.height >0) {
        CGFloat maxH = bgf.size.height +16;
        if (self.delegate && [self.delegate respondsToSelector:@selector(getMaxH:)]) {
            [self.delegate getMaxH:maxH];
        }
    }
}

#pragma mark -- 点击事件
-(void)clickBtnAction:(SobotButton*)sender{
    ZCLibSkillSet *model = (ZCLibSkillSet*)sender.obj;
    if (self.delegate && [self.delegate respondsToSelector:@selector(jumpGroupModel:)]) {
        [self.delegate jumpGroupModel:model];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        self.contentView.backgroundColor =  UIColor.clearColor;
    }else{
        self.contentView.backgroundColor = UIColor.clearColor;
    }
}

// 配置cell高亮状态
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        self.contentView.backgroundColor = UIColor.clearColor;
    } else {
        // 增加延迟消失动画效果，提升用户体验
        [UIView animateWithDuration:0.1 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.contentView.backgroundColor = UIColor.clearColor;
        } completion:nil];
    }
}


@end
