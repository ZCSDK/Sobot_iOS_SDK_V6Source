//
//  ZCLeaveDetailCell.m
//  SobotKit
//
//  Created by lizh on 2022/9/8.
//

#import "ZCLeaveDetailCell.h"
#import "ZCUIKitTools.h"
#import <SobotCommon/SobotCommon.h>
#import "SobotHtmlFilter.h"
#import <SobotChatClient/SobotChatClient.h>
#import "ZCReplyFileView.h"
#import "ZCVideoPlayer.h"
#import "ZCDocumentLookController.h"
@interface ZCLeaveDetailCell()<SobotEmojiLabelDelegate>
{
    ZCRecordListModel *tempModel;// 临时的变量
}

@property (nonatomic,strong) UILabel *timeLab;
@property (nonatomic,strong) UIButton *statusIcon; // 受理状态图标
@property (nonatomic,strong) UILabel *statusLab;
@property (nonatomic,strong) SobotEmojiLabel *replycont;// 回复内容
@property (nonatomic,strong) UIView *lineView; // 竖线条
@property (nonatomic,strong) UIView *infoCardView;//图片卡片显示
@property (nonatomic,strong) UIView *infoCardLineView;//图片卡片白线
@property (nonatomic,strong) UIButton *detailBtn;//跳转webview显示详情的按钮
@property(nonatomic,strong) void (^btnClickBlock)(ZCRecordListModel *model);//评价按钮点击回调
@property(nonatomic,strong) void (^LookdetailClickBlock)(ZCRecordListModel *model,NSString *urlStr);//显示详细按钮点击回调
@property (nonatomic,strong) UIView *lineView_0;//
@property (nonatomic,strong) UIView *lineView_1;//

@property (nonatomic,strong) UIView *bgHeightView;// 最后撑开的高度

@property (nonatomic,strong) NSLayoutConstraint *timeLabPT;
@property (nonatomic,strong) NSLayoutConstraint *statusIconPT;
@property (nonatomic,strong) NSLayoutConstraint *statusIconPL;
@property (nonatomic,strong) NSLayoutConstraint *statusIconEH;
@property (nonatomic,strong) NSLayoutConstraint *statusIconEW;

@property (nonatomic,strong) NSLayoutConstraint *lineViewPT;
@property (nonatomic,strong) NSLayoutConstraint *lineViewPL;
@property (nonatomic,strong) NSLayoutConstraint *lineViewEH;
@property (nonatomic,strong) NSLayoutConstraint *lineViewEW;

@property (nonatomic,strong) NSLayoutConstraint *statusLabPT;

@property (nonatomic,strong) NSLayoutConstraint *infoCardViewMT;
@property (nonatomic,strong) NSLayoutConstraint *infoCardViewPL;
@property (nonatomic,strong) NSLayoutConstraint *infoCardViewPR;
@property (nonatomic,strong) NSLayoutConstraint *infoCardViewEH;

@property (nonatomic,strong) NSLayoutConstraint *replycontMT;
@property (nonatomic,strong) NSLayoutConstraint *replycontPL;
@property (nonatomic,strong) NSLayoutConstraint *replycontPR;
@property (nonatomic,strong) NSLayoutConstraint *replycontEH;

@property (nonatomic,strong) NSLayoutConstraint *infoCardLineViewMT;
@property (nonatomic,strong) NSLayoutConstraint *infoCardLineViewPL;
@property (nonatomic,strong) NSLayoutConstraint *infoCardLineViewPR;

@property (nonatomic,strong) NSLayoutConstraint *bgHeightViewEH;

@end
@implementation ZCLeaveDetailCell

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
    
    _bgHeightView = ({
        UIView *iv = [[UIView alloc]init];
        [self.contentView addSubview:iv];
        iv.backgroundColor = [UIColor clearColor];
        [self.contentView addConstraint:sobotLayoutPaddingTop(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(0, iv,self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(0, iv, self.contentView)];
        self.bgHeightViewEH = sobotLayoutEqualHeight(0, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.bgHeightViewEH];
        iv;
    });
    
    _timeLab = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.contentView addSubview:iv];
        iv.textColor = UIColorFromKitModeColor(SobotColorTextSub);
        iv.font = SobotFont10;
        iv.numberOfLines = 2;
        iv.textAlignment = NSTextAlignmentCenter;
        self.timeLabPT = sobotLayoutPaddingTop(10, iv, self.contentView);
        [self.contentView addConstraint:self.timeLabPT];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(20, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutEqualHeight(36, iv, NSLayoutRelationEqual)];
        [self.contentView addConstraint:sobotLayoutEqualWidth(38, iv, NSLayoutRelationEqual)];
        iv;
    });
    
    _statusIcon = ({
        UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:iv];
        self.statusIconPT = sobotLayoutPaddingLeft(68, iv, self.contentView);
        self.statusIconPL = sobotLayoutPaddingTop(12, iv, self.contentView);
        self.statusIconEH = sobotLayoutEqualWidth(8, iv, NSLayoutRelationEqual);
        self.statusIconEW = sobotLayoutEqualHeight(8, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.statusIconPT];
        [self.contentView addConstraint:self.statusIconPL];
        [self.contentView addConstraint:self.statusIconEH];
        [self.contentView addConstraint:self.statusIconEW];
        iv;
    });
    
    _lineView = ({
        UIView *iv = [[UIView alloc]init];
        [self.contentView addSubview:iv];
        self.lineViewPT = sobotLayoutPaddingLeft(0, iv, self.contentView);
        self.lineViewPL = sobotLayoutPaddingTop(0, iv, self.contentView);
        self.lineViewEH = sobotLayoutEqualWidth(0, iv, NSLayoutRelationEqual);
        self.lineViewEW = sobotLayoutEqualHeight(0, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.lineViewPT];
        [self.contentView addConstraint:self.lineViewPL];
        [self.contentView addConstraint:self.lineViewEW];
        [self.contentView addConstraint:self.lineViewEH];
        iv;
    });
    
    _statusLab = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.contentView addSubview:iv];
        iv.font = SobotFont14;
        [self.contentView addConstraint:sobotLayoutPaddingLeft(92, iv, self.contentView)];
        self.statusLabPT = sobotLayoutPaddingTop(10, iv, self.contentView);
        [self.contentView addConstraint:self.statusLabPT];
        [self.contentView addConstraint:sobotLayoutEqualWidth(160, iv, NSLayoutRelationEqual)];
        [self.contentView addConstraint:sobotLayoutEqualHeight(20, iv, NSLayoutRelationEqual)];
        iv;
    });
    
    _infoCardView = ({
        UIView *iv = [[UIView alloc]init];
        [self.contentView addSubview:iv];
        iv.backgroundColor = UIColorFromKitModeColor(SobotColorBgSub2Dark1);
        iv.layer.cornerRadius = 4.0f;
        iv.layer.masksToBounds = YES;
        self.infoCardViewMT = sobotLayoutMarginTop(2, iv, self.statusLab);
        self.infoCardViewPL = sobotLayoutPaddingTop(92, iv, self.contentView);
        self.infoCardViewPR = sobotLayoutPaddingRight(-10, iv, self.contentView);
        self.infoCardViewEH = sobotLayoutEqualHeight(0, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.infoCardViewMT];
        [self.contentView addConstraint:self.infoCardViewPR];
        [self.contentView addConstraint:self.infoCardViewPL];
        [self.contentView addConstraint:self.infoCardViewEH];
        iv.hidden = YES;
        iv;
    });
    
    _replycont = ({
        SobotEmojiLabel *iv = [[SobotEmojiLabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        [self.contentView addSubview:iv];
        iv.font = SobotFont14;
        iv.numberOfLines = 0;
        iv.lineSpacing = 3;
        iv.delegate = self;
        iv.isNeedAtAndPoundSign = NO;
        iv.disableEmoji = NO;
        [iv setLinkColor:[ZCUIKitTools zcgetChatLeftLinkColor]];
        iv.verticalAlignment = SobotAttributedLabelVerticalAlignmentCenter;
        iv.lineBreakMode = NSLineBreakByTruncatingTail;
        self.replycontMT = sobotLayoutMarginTop(SobotNumber(2), iv, self.statusLab);
        self.replycontPL = sobotLayoutPaddingLeft(92, iv, self.contentView);
        self.replycontPR = sobotLayoutPaddingRight(-15, iv, self.contentView);
        self.replycontEH = sobotLayoutEqualHeight(SobotNumber(20), iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.replycontMT];
        [self.contentView addConstraint:self.replycontEH];
        [self.contentView addConstraint:self.replycontPL];
        [self.contentView addConstraint:self.replycontPR];
        iv;
    });
    
    _infoCardLineView = ({
        UIView *iv = [[UIView alloc]init];
        [self.contentView addSubview:iv];
        iv.backgroundColor = [ZCUIKitTools zcgetCommentButtonLineColor];
        self.infoCardLineViewMT = sobotLayoutMarginTop(11, iv, self.replycont);
        self.infoCardLineViewPL = sobotLayoutPaddingLeft(92+15, iv, self.contentView);
        self.infoCardLineViewPR = sobotLayoutPaddingRight(-25, iv, self.contentView);
        [self.contentView addConstraint:self.infoCardLineViewPL];
        [self.contentView addConstraint:self.infoCardLineViewMT];
        [self.contentView addConstraint:self.infoCardLineViewPR];
        [self.contentView addConstraint:sobotLayoutEqualHeight(1, iv, NSLayoutRelationEqual)];
        iv.hidden = YES;
        iv;
    });
    
    _detailBtn = ({
        UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:iv];
        [iv setTitle:SobotKitLocalString(@"查看详情") forState:UIControlStateNormal];
        [iv setTitleColor:SobotColorFromRGB(0x45B2E6) forState:UIControlStateNormal];
        [iv addTarget:self action:@selector(showDetailAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_detailBtn];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(92, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutMarginTop(11, iv, self.infoCardLineView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-20, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutEqualHeight(18, iv, NSLayoutRelationEqual)];
        iv.hidden = YES;
        iv;
    });
    
    _lineView_0 = ({
        UIView *iv = [[UIView alloc]init];
        [self.contentView addSubview:iv];
        iv.backgroundColor = [ZCUIKitTools zcgetChatBottomLineColor];
        [self.contentView addConstraint:sobotLayoutPaddingTop(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutEqualHeight(0.25, iv, NSLayoutRelationEqual)];
        iv.hidden = YES;
        iv;
    });
    
    _lineView_1 = ({
        UIView *iv = [[UIView alloc]init];
        [self.contentView addSubview:iv];
        iv.backgroundColor = [ZCUIKitTools zcgetChatBottomLineColor];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(-0.25, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutEqualHeight(0.25, iv, NSLayoutRelationEqual)];
        iv.hidden = YES;
        iv;
    });
}

-(void)initWithData:(ZCRecordListModel *)model IndexPath:(NSUInteger)row count:(int)count{
    tempModel = model;
    // 回执
    _timeLab.text = @"";
    _statusLab.text = @"";
    _replycont.text = @"";
    CGFloat bgH = 0; // 最终高度值
    
    CGFloat cy = 10;
    if(row == 0){
        cy = 21;
    }
     //@"2018-04-11 22:22:22";
    NSString *timeText = sobotDateTransformString(@"MM-dd HH:mm", sobotStringFormateDate(model.timeStr));
    if(sobotConvertToString(model.replyTimeStr).length > 8){
        timeText = sobotDateTransformString(@"MM-dd HH:mm", sobotStringFormateDate(model.replyTimeStr));
    }
    
    if (self.timeLabPT) {
        [self.contentView removeConstraint:self.timeLabPT];
    }
    self.timeLabPT = sobotLayoutPaddingTop(cy -2, self.timeLab, self.contentView);
    [self.contentView addConstraint:self.timeLabPT];
    
    // 完成、关闭
    CGFloat  lineY = 0;
    if (self.statusIconPT) {
        [self.contentView removeConstraint:self.statusIconPT];
    }
    if (self.statusIconEW) {
        [self.contentView removeConstraint:self.statusIconEW];
    }
    if (self.statusIconEH) {
        [self.contentView removeConstraint:self.statusIconEH];
    }
    if (self.statusIconPL) {
        [self.contentView removeConstraint:self.statusIconPL];
    }
    if(row == 0){
        if(model.flag == 3){
            [_statusIcon setImage:[SobotUITools getSysImageByName:@"zcicon_addleavemsgStatus_3"] forState:0];
            self.statusIconPL = sobotLayoutPaddingLeft(64, self.statusIcon, self.contentView);
            self.statusIconPT = sobotLayoutPaddingTop(cy+2, self.statusIcon, self.contentView);
            self.statusIconEW = sobotLayoutEqualHeight(16, self.statusIcon, NSLayoutRelationEqual);
            self.statusIconEH = sobotLayoutEqualWidth(16, self.statusIcon, NSLayoutRelationEqual);
            _statusIcon.imageView.layer.cornerRadius = 5.0f;
            _statusIcon.imageView.layer.masksToBounds  =  YES;
            lineY = 50;
        }
        else if (model.flag == 2){
            [_statusIcon setImage:[SobotUITools getSysImageByName:@"zcicon_addleavemsgStatus_2"] forState:0];
            self.statusIconPL = sobotLayoutPaddingLeft(64, self.statusIcon, self.contentView);
            self.statusIconPT = sobotLayoutPaddingTop(cy+2, self.statusIcon, self.contentView);
            self.statusIconEW = sobotLayoutEqualHeight(16, self.statusIcon, NSLayoutRelationEqual);
            self.statusIconEH = sobotLayoutEqualWidth(16, self.statusIcon, NSLayoutRelationEqual);
            _statusIcon.imageView.layer.cornerRadius = 5.0f;
            _statusIcon.imageView.layer.masksToBounds  =  YES;
            lineY = 50;
        }
        else if (model.flag == 1){
            [_statusIcon setImage:[SobotUITools getSysImageByName:@"zcicon_addleavemsgStatus_1"] forState:0];
            self.statusIconPL = sobotLayoutPaddingLeft(64, self.statusIcon, self.contentView);
            self.statusIconPT = sobotLayoutPaddingTop(cy+2, self.statusIcon, self.contentView);
            self.statusIconEW = sobotLayoutEqualHeight(16, self.statusIcon, NSLayoutRelationEqual);
            self.statusIconEH = sobotLayoutEqualWidth(16, self.statusIcon, NSLayoutRelationEqual);
            _statusIcon.imageView.layer.cornerRadius = 5.0f;
            _statusIcon.imageView.layer.masksToBounds  =  YES;
            lineY = 50;
        }
    }else{
        [_statusIcon setImage:[SobotUITools getSysImageByName:@"zciocn_point_old"] forState:0];
        self.statusIconPL = sobotLayoutPaddingLeft(68, self.statusIcon, self.contentView);
        self.statusIconPT = sobotLayoutPaddingTop(cy+6, self.statusIcon, self.contentView);
        self.statusIconEW = sobotLayoutEqualHeight(8, self.statusIcon, NSLayoutRelationEqual);
        self.statusIconEH = sobotLayoutEqualWidth(8, self.statusIcon, NSLayoutRelationEqual);
        _statusIcon.imageView.layer.cornerRadius = 2.0f;
        _statusIcon.imageView.layer.masksToBounds  =  YES;
        [_statusIcon setBackgroundColor:UIColor.clearColor];
        lineY = 0;
    }
    
    [self.contentView addConstraint:self.statusIconPL];
    [self.contentView addConstraint:self.statusIconPT];
    [self.contentView addConstraint:self.statusIconEW];
    [self.contentView addConstraint:self.statusIconEH];
    
    if (self.statusLabPT) {
        [self.contentView removeConstraint:self.statusLabPT];
    }
    self.statusLabPT = sobotLayoutPaddingTop(cy, self.statusLab, self.contentView);
    [self.contentView addConstraint:self.statusLabPT];
    bgH = cy + 20;// 计算状态字段后的高度
    _statusLab.text = SobotKitLocalString(@"已创建");
    [_statusLab setTextAlignment:NSTextAlignmentLeft];
    [_statusLab setTextColor:UIColorFromKitModeColor(SobotColorTextSub)];
    // 测试数据
//    model.replyContent = @"测试数据收到了副科级拉开了客服拉卡数据收到了副科级拉开了客服拉卡拉卡世纪东方拉数据收到了副科级拉开了客服拉卡拉卡世纪东方拉数据收到了副科级拉开了客服拉卡拉卡世纪东方拉数据收到了副科级拉开了客服拉卡拉卡世纪东方拉数据收到了副科级拉开了客服拉卡拉卡世纪东方拉数据收到了副科级拉开了客服拉卡拉卡世纪东方拉拉卡世纪东方拉卡拉角色的会计分录卡机的水立方开讲啦肯定是埃里克点击分类卡机了开始的减肥蓝卡队数据发";
    NSString *tmp = sobotConvertToString(model.replyContent);
    // 过滤标签 改为过滤图片
//    tmp = [self filterHtmlImage:tmp];
    BOOL isCardView = NO;
    //1 创建了  2 受理了 3 关闭了
    switch (model.flag) {
        case 1:
             _statusLab.text = SobotKitLocalString(@"已创建");
            tmp = @"";
            break;
        case 2:
             _statusLab.text = SobotKitLocalString(@"受理中");
            _timeLab.text =  timeText;
            if (model.startType == 0) {
                tmp = @"";//ZCSTLocalString(@"客服回复");
                if (model.replyContent.length > 0) {
                    tmp = sobotConvertToString(model.replyContent);
                    isCardView = [self isContaintImage:tmp];
                    tmp = [self filterHtmlImage:tmp];
                }
            }else if (model.startType == 1){
                _statusLab.text = SobotKitLocalString(@"我的回复");
                if (model.replyContent.length > 0) {
                    tmp = sobotConvertToString(model.replyContent);
                    
                    isCardView = [self isContaintImage:tmp];
                    tmp = [self filterHtmlImage:tmp];
                }else{
                    tmp = SobotKitLocalString(@"无");
                }
            }
            break;
        case 3:{
            if (model.startType == 1){
                _statusLab.text = SobotKitLocalString(@"我的回复");
                if (model.replyContent.length > 0) {
                    tmp = sobotConvertToString(model.replyContent);
                    
                    isCardView = [self isContaintImage:tmp];
                    tmp = [self filterHtmlImage:tmp];
                }else{
                    tmp = SobotKitLocalString(@"无");
                }
            }else{
                [_statusLab setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
                _statusLab.text = SobotKitLocalString(@"已完成");
            }
            tmp = sobotConvertToString(model.content);
            isCardView = [self isContaintImage:tmp];
            tmp = [self filterHtmlImage:tmp];
        }
            break;
        default:
            break;
    }
    
    if (self.replycontPL) {
        [self.contentView removeConstraint:self.replycontPL];
    }
    if (self.replycontMT) {
        [self.contentView removeConstraint:self.replycontMT];
    }
    
   if(isCardView){
       _replycont.frame = CGRectMake(92 + 15, CGRectGetMaxY(_statusLab.frame) + SobotNumber(2) + 11, ScreenWidth - 92 - 30 - 30, SobotNumber(20));
       self.replycontPL = sobotLayoutPaddingLeft(92 + 15, self.replycont, self.contentView);
       self.replycontMT = sobotLayoutMarginTop(SobotNumber(2) + 11, self.replycont, self.statusLab);
       bgH = bgH + SobotNumber(2) + 11;
   }else{
       _replycont.frame = CGRectMake(92, CGRectGetMaxY(_statusLab.frame) + SobotNumber(2), ScreenWidth - 92 - 30, SobotNumber(20));
       self.replycontPL = sobotLayoutPaddingLeft(92 , self.replycont, self.contentView);
       self.replycontMT = sobotLayoutMarginTop(SobotNumber(2), self.replycont, self.statusLab);
       bgH = bgH + SobotNumber(2);
   }
    [self.contentView addConstraint:self.replycontMT];
    [self.contentView addConstraint:self.replycontPL];
    
    if(row == 0 ){
        [_replycont setTextColor:UIColorFromKitModeColor(SobotColorTextMain)];
        _timeLab.textColor = UIColorFromKitModeColor(SobotColorTextMain);
    }else{
        [_replycont setTextColor:UIColorFromKitModeColor(SobotColorTextSub)];
        _timeLab.textColor = UIColorFromKitModeColor(SobotColorTextSub);
    }
    // 富文本赋值
    NSString *text = [self getHtmlAttrStringWithText:tmp chatMsg:[SobotChatMessage new]];
    if(text.length == 0){
        _replycont.text = @"";
    }else{
        UIColor *textColor = [ZCUIKitTools zcgetLeftChatTextColor];
        UIColor *linkColor = [ZCUIKitTools zcgetChatLeftLinkColor];
            [SobotHtmlCore filterHtml:text result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
                if (text1 != nil && text1.length > 0) {
                    NSMutableAttributedString *attr;
                    UIFont *font = [ZCUIKitTools zcgetKitChatFont];
                    attr = [SobotHtmlFilter setHtml:text1 attrs:arr view: self->_replycont textColor:textColor textFont:font linkColor:linkColor];
                    self->_replycont.attributedText = attr;
                }else{
                    self->_replycont.attributedText = [[NSAttributedString alloc] initWithString:@""];
                }
            }];
    }

    if ([timeText containsString:@" "]) {
       if (model.replyTimeStrAttr) {
           _timeLab.attributedText = model.replyTimeStrAttr;
       }else{
           _timeLab.text = timeText;
       }
   }
    
    CGRect replyf = _replycont.frame;
    // 留言回复内容的高度
    CGRect rf = [self getTextRectWith:replyf.size.width AddLabel:_replycont];
    [self.contentView removeConstraint:self.replycontEH];
    self.replycontEH = sobotLayoutEqualHeight(rf.size.height, self.replycont, NSLayoutRelationEqual);
    [self.contentView addConstraint:self.replycontEH];
    
    if (isCardView) {
        self.infoCardView.hidden = NO;
        self.infoCardLineView.hidden = NO;
        self.detailBtn.hidden = NO;
        self.infoCardLineView.hidden = NO;
        
        if (self.infoCardViewEH) {
            [self.contentView removeConstraint:self.infoCardViewEH];
        }
        self.infoCardViewEH = sobotLayoutEqualHeight(rf.size.height + 63, self.infoCardView, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.infoCardViewEH];
        
        self.infoCardViewPL = sobotLayoutPaddingLeft(92, self.infoCardView, self.contentView);
        self.infoCardViewPR = sobotLayoutPaddingRight(-20, self.infoCardView, self.contentView);
        self.infoCardViewMT = sobotLayoutMarginTop(2, self.infoCardView, self.statusLab);
        self.infoCardViewEH = sobotLayoutEqualHeight(rf.size.height + 63, self.infoCardView, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.infoCardViewPL];
        [self.contentView addConstraint:self.infoCardViewPR];
        [self.contentView addConstraint:self.infoCardViewMT];
        [self.contentView addConstraint:self.infoCardViewEH];
                
        self.infoCardLineViewPR = sobotLayoutPaddingRight(-25, self.infoCardLineView, self.contentView);
        self.infoCardLineViewPL = sobotLayoutPaddingLeft(92+15, self.infoCardLineView, self.contentView);
        self.infoCardLineViewMT = sobotLayoutMarginTop(11, self.infoCardLineView, self.replycont);
        
        [self.contentView addConstraint:self.infoCardLineViewPR];
        [self.contentView addConstraint:self.infoCardLineViewPL];
        [self.contentView addConstraint:self.infoCardLineViewMT];
        bgH = bgH + rf.size.height + 63 + 10 + 2;
    }else{
        self.infoCardView.hidden = YES;
        self.infoCardLineView.hidden = YES;
        self.detailBtn.hidden = YES;
        self.infoCardLineView.hidden = YES;
        bgH = bgH + 10 + rf.size.height ;
    }
    
//    2.8.2 如果 有附件：
    for (UIView *view in [self.contentView subviews]) {
        if ([view isKindOfClass:[ZCReplyFileView class]]) {
            [view removeFromSuperview];
        }
    }
    
    if(model.fileList.count > 0 && model.flag != 1) {
        float fileBgView_margin_left = 92;
        float fileBgView_margin_top = 0;
        float fileBgView_margin_right = 20;
        float fileBgView_margin = 10;
//      宽度固定为  （屏幕宽度 - 60)/3
        CGSize fileViewRect = CGSizeMake((ScreenWidth - 60)/3, 85);
//      算一下每行多少个 ，
        float nums = (ScreenWidth - fileBgView_margin_left - fileBgView_margin_right)/(fileViewRect.width + fileBgView_margin);
        NSInteger numInt = floor(nums);
//      行数：
        NSInteger rows = ceil(model.fileList.count/(float)numInt);
        for (int i = 0 ; i < model.fileList.count;i++) {
            NSDictionary *modelDic = model.fileList[i];
            NSMutableDictionary *mutDic = [modelDic mutableCopy];
            [mutDic setValue:[NSString stringWithFormat:@"%lu",(unsigned long)row] forKey:@"cellIndex"];
            //           当前列数
            NSInteger currentColumn = i%numInt;
//           当前行数
            NSInteger currentRow = i/numInt;
            float x = fileBgView_margin_left + (fileViewRect.width + fileBgView_margin)*currentColumn;
            float y = bgH + fileBgView_margin_top + (fileViewRect.height + fileBgView_margin)*currentRow;
            float w = fileViewRect.width;
            float h = fileViewRect.height;
            
            ZCReplyFileView *fileBgView = [[ZCReplyFileView alloc]initWithDic:mutDic withFrame:CGRectMake(x, y, w, h)];
            fileBgView.layer.cornerRadius = 4;
            fileBgView.layer.masksToBounds = YES;
                
            [fileBgView setClickBlock:^(NSDictionary * _Nonnull modelDic, UIImageView * _Nonnull imgView) {
               NSString *fileType = modelDic[@"fileType"];
               NSString *fileUrlStr = modelDic[@"fileUrl"];
//                NSArray *imgArray = [[NSArray alloc]initWithObjects:fileUrlStr, nil];
                if ([fileType isEqualToString:@"jpg"] ||
                    [fileType isEqualToString:@"png"] ||
                    [fileType isEqualToString:@"gif"] ) {
                    //     图片预览
                    UIImageView *picView = imgView;
                    CALayer *calayer = picView.layer.mask;
                    [picView.layer.mask removeFromSuperlayer];
                    SobotXHImageViewer *xh= [[SobotXHImageViewer alloc] initWithImageViewersobotHxWillDismissWithSelectedViewBlock:^(SobotXHImageViewer *imageViewer, UIImageView *selectedView) {
                        
                    } sobotHxDidDismissWithSelectedViewBlock:^(SobotXHImageViewer *imageViewer, UIImageView *selectedView) {
                        selectedView.layer.mask = calayer;
                        [selectedView setNeedsDisplay];
                    } sobotHxDidChangeToImageViewBlock:^(SobotXHImageViewer *imageViewer, UIImageView *selectedView) {
                        
                    }];
                    NSMutableArray *photos = [[NSMutableArray alloc] init];
                    [photos addObject:picView];
                    xh.disableTouchDismiss = NO;
                    [xh showWithImageViews:photos selectedView:picView];
                }
                else if ([fileType isEqualToString:@"mp4"]){
                    NSURL *imgUrl = [NSURL URLWithString:fileUrlStr];
                     UIWindow *window = [SobotUITools getCurWindow];
                     ZCVideoPlayer *player = [[ZCVideoPlayer alloc] initWithFrame:window.bounds withShowInView:window url:imgUrl Image:nil];
                     [player showControlsView];
                }else{
                    SobotChatMessage *message = [[SobotChatMessage alloc]init];
                    SobotChatContent *rich = [[SobotChatContent alloc]init];
                    rich.url = fileUrlStr;
                    
                    /**
                    * 13 doc文件格式
                    * 14 ppt文件格式
                    * 15 xls文件格式
                    * 16 pdf文件格式
                    * 17 mp3文件格式
                    * 18 mp4文件格式
                    * 19 压缩文件格式
                    * 20 txt文件格式
                    * 21 其他文件格式
                    */
                    if ([fileType isEqualToString:@"doc"] || [fileType isEqualToString:@"docx"] ) {
                        rich.fileType = 13;
                    }
                    else if ([fileType isEqualToString:@"ppt"] || [fileType isEqualToString:@"pptx"]){
                        rich.fileType = 14;
                    }
                    else if ([fileType isEqualToString:@"xls"] || [fileType isEqualToString:@"xlsx"]){
                        rich.fileType = 15;
                    }
                    else if ([fileType isEqualToString:@"pdf"]){
                        rich.fileType = 16;
                    }
                    else if ([fileType isEqualToString:@"mp3"]){
                        rich.fileType = 17;
                    }
//                    else if ([fileType isEqualToString:@"mp4"]){
//                        rich.fileType = 18;
//                    }
                    else if ([fileType isEqualToString:@"zip"]){
                        rich.fileType = 19;
                    }
                    else if ([fileType isEqualToString:@"txt"]){
                        rich.fileType = 20;
                    }
                    else{
                        rich.fileType = 21;
                    }
                    message.richModel = rich;
                    message.richModel.content = modelDic[@"fileName"];
                    ZCDocumentLookController *docVc = [[ZCDocumentLookController alloc]init];
                    docVc.message = message;
                    [self openNewPage:docVc];
                }
            }];
            [self.contentView addSubview:fileBgView];
        }
//        h = h + (fileViewRect.height + fileBgView_margin_top)*rows + 30;
        bgH = bgH + (fileViewRect.height + fileBgView_margin_top)*rows + 30;
    }
    
    [self.contentView removeConstraint:self.lineViewEH];
    [self.contentView removeConstraint:self.lineViewPT];
    [self.contentView removeConstraint:self.lineViewEW];
    [self.contentView removeConstraint:self.lineViewPL];
    if(model.flag == 1){
        self.lineViewEH = sobotLayoutEqualHeight(cy, self.lineView, NSLayoutRelationEqual);
        self.lineViewPL = sobotLayoutPaddingLeft(72, self.lineView, self.contentView);
        self.lineViewPT = sobotLayoutPaddingTop(lineY, self.lineView, self.contentView);
        self.lineViewEW = sobotLayoutEqualWidth(0.75, self.lineView, NSLayoutRelationEqual);
        bgH = bgH + 20;
    }else{
        self.lineViewEH = sobotLayoutEqualHeight(bgH - lineY + 2, self.lineView, NSLayoutRelationEqual);
        self.lineViewPL = sobotLayoutPaddingLeft(72, self.lineView, self.contentView);
        self.lineViewPT = sobotLayoutPaddingTop(lineY, self.lineView, self.contentView);
        self.lineViewEW = sobotLayoutEqualWidth(0.75, self.lineView, NSLayoutRelationEqual);
    }
    [self.contentView addConstraint:self.lineViewEH];
    [self.contentView addConstraint:self.lineViewPT];
    [self.contentView addConstraint:self.lineViewEW];
    [self.contentView addConstraint:self.lineViewPL];
    
    if(row == 0 ){
        if (count == 1) {
            _lineView.hidden = YES;
        }else{
            _lineView.hidden = NO;
        }
        _statusLab.textColor = UIColorFromKitModeColor(SobotColorTextMain);
        _replycont.textColor = UIColorFromKitModeColor(SobotColorTextMain);
    }else{
        _lineView.hidden = NO;
        _statusLab.textColor = UIColorFromKitModeColor(SobotColorTextSub);
        _replycont.textColor = UIColorFromKitModeColor(SobotColorTextSub);
    }
    
    if (row == 0) {
        _lineView_0.hidden = NO;
        _lineView_1.hidden = YES;
    }
    else if (row == count -1){
        _lineView_0.hidden = YES;
        _lineView_1.hidden = NO;
    }else{
        _lineView_0.hidden = YES;
        _lineView_1.hidden = YES;
    }
    
    if (count == 1) {
        _lineView_0.hidden = NO;
        _lineView_1.hidden = NO;
    }

    _lineView.backgroundColor = UIColorFromKitModeColor(SobotColorBgLine);
//    self.frame = self.contentView.frame;
    if (self.bgHeightViewEH) {
        [self.contentView removeConstraint:self.bgHeightViewEH];
    }
    self.bgHeightViewEH = sobotLayoutEqualHeight(bgH, self.bgHeightView, NSLayoutRelationEqual);
    [self.contentView addConstraint:self.bgHeightViewEH];
    if(sobotIsRTLLayout()){
        [_statusLab setTextAlignment:NSTextAlignmentRight];
        [_replycont setTextAlignment:NSTextAlignmentRight];
        for(UIView *v in self.contentView.subviews){
            [SobotUITools setRTLFrame:v];
        }
    }
}

-(void)setShowDetailClickCallback:(void (^)(ZCRecordListModel *model,NSString *urlStr))_detailClickBlock{
    _LookdetailClickBlock = _detailClickBlock;
}

-(void)showDetailAction:(UIButton *)btn{
    if (self.LookdetailClickBlock) {
        self.LookdetailClickBlock(tempModel,nil);
    }
}


#pragma mark -- 计算文本高度
-(CGRect)getTextRectWith:(CGFloat)width  AddLabel:(UILabel *)label{
    CGSize size = [self autoHeightOfLabel:label with:width];
    CGRect labelF = label.frame;
    labelF.size.height = size.height;
    label.frame = labelF;
    return labelF;
}

/**
 计算Label高度
 
 @param label 要计算的label，设置了值
 @param width label的最大宽度
 @param type 是否从新设置宽，1设置，0不设置
 */
- (CGSize )autoHeightOfLabel:(UILabel *)label with:(CGFloat )width{
    CGSize maximumLabelSize = CGSizeMake(width, FLT_MAX);
    CGSize expectedLabelSize = [label sizeThatFits:maximumLabelSize];// 返回最佳的视图大小
    //adjust the label the the new height.
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    label.frame = newFrame;
    [label updateConstraintsIfNeeded];
    return expectedLabelSize;
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark -- 转成可识别的HTML属性串
- (NSString *)getHtmlAttrStringWithText:(NSString *)text chatMsg:(SobotChatMessage *)chatMsg{
    text = [text stringByReplacingOccurrencesOfString:@"<font color='red'>" withString:@"<a href=\"sobot://color\">"];
    text = [text stringByReplacingOccurrencesOfString:@"</font>" withString:@"</a>"];
    if(![@"" isEqual:text]){
        
        while ([text hasPrefix:@"\n"]) {
            text=[text substringWithRange:NSMakeRange(1, text.length-1)];
        }
        while ([text hasSuffix:@"\n"]) {
            text=[text substringWithRange:NSMakeRange(0, text.length-1)];
        }
    }
    text = [SobotHtmlCore filterHTMLTag:text];
    return text;
}

#pragma mark - tools 获取当前控制器
- (UIViewController *)getControllerFromView:(UIView *)view {
    // 遍历响应者链。返回第一个找到视图控制器
    UIResponder *responder = view;
    while ((responder = [responder nextResponder])){
        if ([responder isKindOfClass: [UIViewController class]]){
            return (UIViewController *)responder;
        }
    }
    // 如果没有找到则返回nil
    return nil;
}

-(void)openNewPage:(UIViewController *) vc{
    if([self getControllerFromView:self] && [[self getControllerFromView:self] isKindOfClass:[UIViewController class]]){
        if ([self getControllerFromView:self].navigationController) {
            [[self getControllerFromView:self].navigationController pushViewController:vc animated:YES];
        }else{
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [[self getControllerFromView:self]  presentViewController:nav animated:YES completion:^{
                
            }];
        }
    }
}

#pragma mark EmojiLabel链接点击事件
- (void)SobotEmojiLabel:(SobotEmojiLabel*)emojiLabel didSelectLink:(NSString*)link withType:(SobotEmojiLabelLinkType)type{
    link=[link stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    if (link) {
        NSURL *url = [NSURL URLWithString:link];
        [[ZCUICore getUICore] dealWithLinkClickWithLick:url.absoluteString viewController:[self getControllerFromView:self]];
    }
}

// 链接点击
- (void)attributedLabel:(SobotAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    //  链接处理：
    [[ZCUICore getUICore] dealWithLinkClickWithLick:url.absoluteString viewController:[self getControllerFromView:self]];
}


#pragma mark - gesture delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return ![self.replycont containslinkAtPoint:[touch locationInView:self.replycont]];
}

@end
