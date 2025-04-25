//
//  ZCLeaveDetailHeaderCell.m
//  SobotKit
//
//  Created by lizh on 2025/1/16.
//

#import "ZCLeaveDetailHeaderCell.h"
#import "ZCUIKitTools.h"
#import <SobotCommon/SobotCommon.h>
#import "SobotHtmlFilter.h"
#import <SobotChatClient/SobotChatClient.h>
#import "ZCShadowBorderView.h"

// 新版数据过滤掉了之前老版中的附件
@interface ZCLeaveDetailHeaderCell()
{
    
}
// 这里取外层列表返回的时间字段
@property(nonatomic,strong)ZCRecordListModel *showModel;
//@property(nonatomic,strong)UIView *bgView;
@property(nonatomic,strong)UIView *headerConView;
@property(nonatomic,strong)UILabel *statusLab;
@property(nonatomic,strong)UILabel *timeLab;
@property(nonatomic,strong)UILabel *titleLab;
@property(nonatomic,strong)UIView *lineView;
@property(nonatomic,strong)UIButton *openBtn;


@property(nonatomic,strong)NSLayoutConstraint *statusW;
@property(nonatomic,strong)NSLayoutConstraint *titleH;
@property(nonatomic,strong)NSLayoutConstraint *btnH;
@property(nonatomic,strong)NSLayoutConstraint *lineH;
@end

@implementation ZCLeaveDetailHeaderCell

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
    _headerConView = ({
        ZCShadowBorderView *iv = [[ZCShadowBorderView alloc]init];
        iv.shadowLayerType = 1;
        iv.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
        [self.contentView addSubview:iv];
        [self.contentView addConstraint:sobotLayoutPaddingTop(16, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(16, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-16, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(-7, iv, self.contentView)];
        iv;
    });
    
    _statusLab = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.headerConView addSubview:iv];
        iv.text = @"";
        iv.font = SobotFont12;
        iv.textAlignment = NSTextAlignmentCenter;
        [self.headerConView addConstraint:sobotLayoutPaddingTop(3, iv, self.headerConView)];
        [self.headerConView addConstraint:sobotLayoutPaddingRight(0, iv, self.headerConView)];
        [self.headerConView addConstraint:sobotLayoutEqualHeight(24, iv, NSLayoutRelationEqual)];
        self.statusW = sobotLayoutEqualWidth(52, iv, NSLayoutRelationEqual);
        [self.headerConView addConstraint:self.statusW];
        iv;
    });
    
    _timeLab = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.headerConView addSubview:iv];
        iv.textColor = UIColorFromKitModeColor(SobotColorTextSub1);
        iv.font = SobotFont14;
        iv.textAlignment = NSTextAlignmentLeft;
        [self.headerConView addConstraint:sobotLayoutPaddingTop(20, iv, self.headerConView)];
        [self.headerConView addConstraint:sobotLayoutPaddingLeft(20, iv, self.headerConView)];
        [self.headerConView addConstraint:sobotLayoutEqualHeight(22, iv, NSLayoutRelationEqual)];
        [self.headerConView addConstraint:sobotLayoutMarginRight(-5, iv, self.statusLab)];
        iv;
    });
    
    _titleLab = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.headerConView addSubview:iv];
        iv.textColor = UIColorFromKitModeColor(SobotColorTextMain);
        iv.font = SobotFont14;
        [self.headerConView addConstraint:sobotLayoutPaddingLeft(20, iv, self.headerConView)];
        [self.headerConView addConstraint:sobotLayoutPaddingRight(-20, iv, self.headerConView)];
        [self.headerConView addConstraint:sobotLayoutMarginTop(4, iv, self.timeLab)];
        iv.numberOfLines = 2;
        self.titleH = sobotLayoutEqualHeight(44, iv, NSLayoutRelationEqual);
        [self.headerConView addConstraint:self.titleH];
        iv;
    });
    
    _lineView = ({
        UIView *iv = [[UIView alloc]init];
        [self.headerConView addSubview:iv];
        iv.backgroundColor = UIColorFromKitModeColor(SobotColorBgTopLine);
        [self.headerConView addConstraint:sobotLayoutMarginTop(20, iv, self.titleLab)];
        [self.headerConView addConstraint:sobotLayoutPaddingLeft(0, iv, self.headerConView)];
        [self.headerConView addConstraint:sobotLayoutPaddingRight(0, iv, self.headerConView)];
        self.lineH = sobotLayoutEqualHeight(0.5, iv, NSLayoutRelationEqual);
        [self.headerConView addConstraint:self.lineH];
        iv.hidden = YES;
        iv;
    });
    
    _openBtn = ({
        UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.headerConView addSubview:iv];
        [iv setTitle:SobotKitLocalString(@"展开全部") forState:0];
        [iv setTitleColor:[ZCUIKitTools zcgetServerConfigBtnBgColor] forState:0];
        iv.titleLabel.font = SobotFont14;
        [iv addTarget:self action:@selector(openAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.headerConView addConstraint:sobotLayoutMarginTop(0, iv, self.lineView)];
        [self.headerConView addConstraint:sobotLayoutPaddingLeft(0, iv, self.headerConView)];
        [self.headerConView addConstraint:sobotLayoutPaddingRight(0, iv, self.headerConView)];
        [self.headerConView addConstraint:sobotLayoutPaddingBottom(0, iv, self.headerConView)];
        self.btnH = sobotLayoutEqualHeight(46, iv, NSLayoutRelationEqual);
        [self.headerConView addConstraint:self.btnH];
        iv.tag = 0;
        iv.hidden = YES;
        iv;
    });
    
}

#pragma mark -- 点击展开和收起事件
-(void)openAction:(UIButton*)sender{
    if (sender.tag == 0) {
        self.showModel.isOpen = YES;
        if (self.headerBlock) {
            self.headerBlock(self.showModel, YES);
        }
    }else{
        self.showModel.isOpen = NO;
        if (self.headerBlock) {
            self.headerBlock(self.showModel, NO);
        }
    }
}

//
-(void)initWithData:(ZCRecordListModel *)model IndexPath:(NSUInteger)row isOpen:(BOOL)isOpen{
    if (row == 0 && !sobotIsNull(model)) {
        self.showModel = model;
        _timeLab.text = sobotConvertToString(sobotDateTransformString(@"YYYY-MM-dd HH:mm:ss", sobotStringFormateDate(model.timeStr)));
        _statusLab.text = [[ZCPlatformTools sharedInstance] getOrderStatus:self.showModel.ticketStatus];
        _statusLab.backgroundColor = [[ZCPlatformTools sharedInstance] getOrderStatusTypeBgColor:self.showModel.ticketStatus bg:YES];
        _statusLab.textColor = [[ZCPlatformTools sharedInstance] getOrderStatusTypeBgColor:self.showModel.ticketStatus bg:NO];
        // 重新计算宽度
        CGFloat sw = [ZCUIKitTools getLabelTextWidthWith:sobotConvertToString(_statusLab.text) font:SobotFont12 hight:24];
        self.statusW.constant = sw +16;
        // 切圆角的事情都放到 layoutSubviews中去做
        NSString *msg = sobotConvertToString(model.content);
        if ([self isContaintImage:msg]) {
            msg = [self filterHtmlImage:msg];
        }
        CGFloat th = [SobotUITools getHeightContain:sobotConvertToString(msg) font:SobotFont14 Width:ScreenWidth - 40-32];
        
        _titleLab.text = sobotConvertToString(msg);
        if (isOpen) {
            // 显示展开内容
            self.lineView.hidden = NO;
            self.openBtn.hidden = NO;
            self.titleH.constant = th +10;
            self.titleLab.numberOfLines = 0;
            [self.openBtn setTitle:SobotKitLocalString(@"收起") forState:0];
            self.openBtn.tag = 1;
            self.btnH.constant = 46;
            self.lineH.constant = 0.5;
        }else{
            [self.openBtn setTitle:SobotKitLocalString(@"展开全部") forState:0];
            self.openBtn.tag = 0;
            if (th>35) {
                self.lineView.hidden = NO;
                self.openBtn.hidden = NO;
                self.btnH.constant = 46;
                self.lineH.constant = 0.5;
                self.titleH.constant = 44;
                self.titleLab.numberOfLines =0;
            }else{
                self.titleH.constant = th;
                self.titleLab.numberOfLines = 2;
                self.lineView.hidden = YES;
                self.openBtn.hidden = YES;
                self.btnH.constant = 0;
                self.lineH.constant = 0;
            }
        }
    }
    [self.contentView layoutIfNeeded];
}

#pragma mark - 过滤图片标签
-(NSString *)filterHtmlImage:(NSString *)tmp{
    NSString *picStr = [NSString stringWithFormat:@"[%@]",SobotKitLocalString(@"图片")];
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:@"<img.*?/>" options:0 error:nil];
    tmp  = [regularExpression stringByReplacingMatchesInString:tmp options:0 range:NSMakeRange(0, tmp.length) withTemplate:picStr];
    return tmp;
    
}

#pragma mark - 是否包含图片
-(BOOL)isContaintImage:(NSString *)srcString{
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:@"<img.*?/>" options:0 error:nil];
    NSArray *result = [regularExpression matchesInString:srcString options:NSMatchingReportCompletion range:NSMakeRange(0, srcString.length)];
    return result.count;
}


-(void)layoutSubviews{
    [super layoutSubviews];
    // 重新绘制状态的圆角
    [ZCUIKitTools addRoundedCorners:UIRectCornerTopRight|UIRectCornerBottomLeft withRadii:CGSizeMake(8, 8) withView:self.statusLab];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
