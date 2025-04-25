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
@interface ZCLeaveDetailCell()<SobotEmojiLabelDelegate,UIGestureRecognizerDelegate>
{
    ZCRecordListDetailModel *tempModel;// 临时的变量
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
@property (nonatomic,strong) NSLayoutConstraint *lineViewPB;

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
@property (nonatomic,strong) UIView *fileItemView;
@property (nonatomic,strong) NSLayoutConstraint *fileItemViewMT;
@property (nonatomic,strong) NSLayoutConstraint *fileItemViewEH;

// 当有查看详情时使用这个label 方便处理约束关联的问题
@property (nonatomic,strong) SobotEmojiLabel *cardlab;
@property (nonatomic,strong) NSLayoutConstraint *infoCardLineViewH;
@property (nonatomic,strong) NSLayoutConstraint *cardlabMT;
@property (nonatomic,strong) NSLayoutConstraint *detailBtnH;
// 上面线条
@property (nonatomic,strong) UIView *toplineView;
@property (nonatomic,strong) NSLayoutConstraint *toplineViewMB;
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
    // 老版的逻辑 计算最后的高度，会有误差
//    _bgHeightView = ({
//        UIView *iv = [[UIView alloc]init];
//        [self.contentView addSubview:iv];
//        iv.backgroundColor = [UIColor clearColor];
//        [self.contentView addConstraint:sobotLayoutPaddingTop(0, iv, self.contentView)];
//        [self.contentView addConstraint:sobotLayoutPaddingRight(0, iv,self.contentView)];
//        [self.contentView addConstraint:sobotLayoutPaddingLeft(0, iv, self.contentView)];
//        [self.contentView addConstraint:sobotLayoutPaddingBottom(0, iv, self.contentView)];
//        self.bgHeightViewEH = sobotLayoutEqualHeight(0, iv, NSLayoutRelationEqual);
//        [self.contentView addConstraint:self.bgHeightViewEH];
//        iv;
//    });
   // 状态图标
    _statusIcon = ({
        UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:iv];
        self.statusIconPT = sobotLayoutPaddingLeft(16, iv, self.contentView);
        self.statusIconPL = sobotLayoutPaddingTop(25, iv, self.contentView);
        self.statusIconEH = sobotLayoutEqualWidth(5, iv, NSLayoutRelationEqual);
        self.statusIconEW = sobotLayoutEqualHeight(5, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.statusIconPT];
        [self.contentView addConstraint:self.statusIconPL];
        [self.contentView addConstraint:self.statusIconEH];
        [self.contentView addConstraint:self.statusIconEW];
        iv.imageView.layer.cornerRadius = 2.5f;
        iv.imageView.layer.masksToBounds  =  YES;
        [iv setBackgroundColor:UIColor.clearColor];
        [iv setImage:[SobotUITools getSysImageByName:@"zciocn_point_old"] forState:0];
        iv;
    });
    // 左边线条
    _lineView = ({
        UIView *iv = [[UIView alloc]init];
        [self.contentView addSubview:iv];
        iv.backgroundColor = UIColorFromKitModeColor(SobotColorBgTopLine);
        self.lineViewPL = sobotLayoutPaddingLeft(18.5, iv, self.contentView);
        self.lineViewPT = sobotLayoutMarginTop(2, iv, self.statusIcon);
        self.lineViewEW = sobotLayoutEqualWidth(0.75, iv, NSLayoutRelationEqual);
        self.lineViewPB = sobotLayoutPaddingBottom(0, iv, self.contentView);
        [self.contentView addConstraint:self.lineViewPB];
        [self.contentView addConstraint:self.lineViewPT];
        [self.contentView addConstraint:self.lineViewPL];
        [self.contentView addConstraint:self.lineViewEW];
        iv;
    });
    
    _toplineView = ({
        UIView *iv = [[UIView alloc]init];
        [self.contentView addSubview:iv];
        iv.backgroundColor = UIColorFromKitModeColor(SobotColorBgTopLine);
        [self.contentView addConstraint:sobotLayoutPaddingTop(0, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(18.5, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutEqualWidth(0.75, iv, NSLayoutRelationEqual)];
        self.toplineViewMB = sobotLayoutMarginBottom(-2, iv, _statusIcon);
        [self.contentView addConstraint:self.toplineViewMB];
        iv;
    });
    
    // 回复了您
    _statusLab = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.contentView addSubview:iv];
        iv.textColor = UIColorFromKitModeColor(SobotColorTextMain);
        iv.font = SobotFontBold14;
        _statusLab.numberOfLines = 0;
        _statusLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addConstraint:sobotLayoutPaddingLeft(36, iv, self.contentView)];
        self.statusLabPT = sobotLayoutPaddingTop(16, iv, self.contentView);
        [self.contentView addConstraint:self.statusLabPT];
        [self.contentView addConstraint:sobotLayoutEqualHeight(22, iv, NSLayoutRelationEqual)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-20, iv, self.contentView)];
        iv;
    });
    
    // 时间
    _timeLab = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.contentView addSubview:iv];
        iv.textAlignment = NSTextAlignmentLeft;
        iv.textColor = UIColorFromKitModeColor(SobotColorTextSub1);
        iv.font = SobotFont12;
        iv.numberOfLines = 0;
        self.timeLabPT = sobotLayoutMarginTop(0, iv, self.statusLab);
        [self.contentView addConstraint:self.timeLabPT];
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            iv.textAlignment = NSTextAlignmentRight;
        }
        [self.contentView addConstraint:sobotLayoutPaddingLeft(36, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutEqualHeight(20, iv, NSLayoutRelationEqual)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-20, iv, self.contentView)];
        iv;
    });
    
    // 正常回复的内容文案
    _replycont = ({
        SobotEmojiLabel *iv = [[SobotEmojiLabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        [self.contentView addSubview:iv];
        iv.font = SobotFont14;
        iv.numberOfLines = 0;
        iv.delegate = self;
        iv.isNeedAtAndPoundSign = NO;
        iv.disableEmoji = NO;
        [iv setLinkColor:[ZCUIKitTools zcgetChatLeftLinkColor]];
        iv.verticalAlignment = SobotAttributedLabelVerticalAlignmentCenter;
        iv.textColor = UIColorFromKitModeColor(SobotColorTextMain);
        iv.lineBreakMode = NSLineBreakByTruncatingTail;
        self.replycontMT = sobotLayoutMarginTop(4, iv, self.timeLab);
        self.replycontPL = sobotLayoutPaddingLeft(36, iv, self.contentView);
        self.replycontPR = sobotLayoutPaddingRight(-15, iv, self.contentView);
//        self.replycontEH = sobotLayoutEqualHeight(20, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.replycontMT];
//        [self.contentView addConstraint:self.replycontEH];
        [self.contentView addConstraint:self.replycontPL];
        [self.contentView addConstraint:self.replycontPR];
        iv;
    });
    
    // 查看详情的卡片
    _infoCardView = ({
        UIView *iv = [[UIView alloc]init];
        [self.contentView addSubview:iv];
//        iv.backgroundColor = UIColorFromKitModeColor(SobotColorBgSub2Dark1);
        iv.backgroundColor = UIColorFromKitModeColor(SobotColorBgSub);
        iv.layer.cornerRadius = 4.0f;
        iv.layer.masksToBounds = YES;
        self.infoCardViewMT = sobotLayoutMarginTop(12, iv, self.timeLab);
        self.infoCardViewPL = sobotLayoutPaddingLeft(36, iv, self.contentView);
        self.infoCardViewPR = sobotLayoutPaddingRight(-16, iv, self.contentView);
//        self.infoCardViewEH = sobotLayoutEqualHeight(1, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.infoCardViewMT];
        [self.contentView addConstraint:self.infoCardViewPR];
        [self.contentView addConstraint:self.infoCardViewPL];
//        [self.contentView addConstraint:self.infoCardViewEH];
        iv.hidden = YES;
        iv;
    });
    
    _cardlab = ({
        SobotEmojiLabel *iv = [[SobotEmojiLabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        [self.infoCardView addSubview:iv];
        iv.font = SobotFont14;
        iv.numberOfLines = 0;
        iv.delegate = self;
        iv.isNeedAtAndPoundSign = NO;
        iv.disableEmoji = NO;
        [iv setLinkColor:[ZCUIKitTools zcgetChatLeftLinkColor]];
        iv.verticalAlignment = SobotAttributedLabelVerticalAlignmentCenter;
        iv.textColor = UIColorFromKitModeColor(SobotColorTextMain);
        iv.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.infoCardView addConstraint:sobotLayoutPaddingLeft(16, iv, self.infoCardView)];
        [self.infoCardView addConstraint:sobotLayoutPaddingRight(-16, iv, self.infoCardView)];
        self.cardlabMT = sobotLayoutPaddingTop(16, iv, self.infoCardView);
        [self.infoCardView addConstraint:self.cardlabMT];
        iv;
    });
    
    // 查看更多上面的线条
    _infoCardLineView = ({
        UIView *iv = [[UIView alloc]init];
        [self.infoCardView addSubview:iv];
        iv.backgroundColor = UIColorFromKitModeColor(SobotColorBgTopLine);
        self.infoCardLineViewMT = sobotLayoutMarginTop(16, iv, self.cardlab);
        self.infoCardLineViewPL = sobotLayoutPaddingLeft(16, iv, self.infoCardView);
        self.infoCardLineViewPR = sobotLayoutPaddingRight(-16, iv, self.infoCardView);
        [self.infoCardView addConstraint:self.infoCardLineViewPL];
        [self.infoCardView addConstraint:self.infoCardLineViewMT];
        [self.infoCardView addConstraint:self.infoCardLineViewPR];
        self.infoCardLineViewH = sobotLayoutEqualHeight(1, iv, NSLayoutRelationEqual);
        [self.infoCardView addConstraint:self.infoCardLineViewH];
        iv.hidden = YES;
        iv;
    });
    //  查看详情的按钮
    _detailBtn = ({
        UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.infoCardView addSubview:iv];
        [iv setTitle:SobotKitLocalString(@"查看详情") forState:UIControlStateNormal];
//        [iv setTitleColor:SobotColorFromRGB(0x45B2E6) forState:UIControlStateNormal];
        [iv setTitleColor:[ZCUIKitTools zcgetServerConfigBtnBgColor] forState:UIControlStateNormal];
        [iv addTarget:self action:@selector(showDetailAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.infoCardView addConstraint:sobotLayoutPaddingLeft(0, iv, self.infoCardView)];
        [self.infoCardView addConstraint:sobotLayoutMarginTop(0, iv, self.infoCardLineView)];
        [self.infoCardView addConstraint:sobotLayoutPaddingRight(0, iv, self.infoCardView)];
        self.detailBtnH = sobotLayoutEqualHeight(40, iv, NSLayoutRelationEqual);
        [self.infoCardView addConstraint:self.detailBtnH];
        [self.infoCardView addConstraint:sobotLayoutPaddingBottom(0, iv, self.infoCardView)];
        iv;
    });
    
    // 最下面附件的view
    _fileItemView = ({
        UIView *iv = [[UIView alloc]init];
        [self.contentView addSubview:iv];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(36, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-16, iv, self.contentView)];
        self.fileItemViewEH = sobotLayoutEqualHeight(0, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.fileItemViewEH];
        self.fileItemViewMT = sobotLayoutMarginTop(12, iv, self.infoCardView);
        [self.contentView addConstraint:self.fileItemViewMT];
//        iv.backgroundColor = UIColor.purpleColor;
        [self.contentView addConstraint:sobotLayoutPaddingBottom(0, iv, self.contentView)];
        iv;
    });
    
    self.contentView.userInteractionEnabled = YES;
}

-(void)initWithData:(ZCRecordListDetailModel *)model IndexPath:(NSUInteger)row count:(int)count{
    tempModel = model;
    // 先移除，后添加
    [[self.fileItemView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.fileItemViewEH.constant = 0;
    // 回执
    _timeLab.text = @"";
    _statusLab.text = @"";
    _replycont.text = @"";
    _cardlab.text = @"";

    if (self.fileItemViewMT) {
        [self.contentView removeConstraint:self.fileItemViewMT];
    }
    
     //@"2018-04-11 22:22:22";
    NSString *timeText = sobotDateTransformString(@"MM-dd HH:mm", sobotStringFormateDate(model.replyTime));
    if(sobotConvertToString(model.replyTimeStr).length > 8){
        timeText = sobotDateTransformString(@"MM-dd HH:mm", sobotStringFormateDate(model.replyTimeStr));
    }
    _timeLab.text = timeText;
    // 测试数据
//    model.replyContent = @"测试数据收到了副科级拉开了客服拉卡数据收到了副科级拉开了客服拉卡拉卡世纪东方拉数据收到了副科级拉开了客服拉卡拉卡世纪东方拉数据收到了副科级拉开了客服拉卡拉卡世纪东方拉数据收到了副科级拉开了客服拉卡拉卡世纪东方拉数据收到了副科级拉开了客服拉卡拉卡世纪东方拉数据收到了副科级拉开了客服拉卡拉卡世纪东方拉拉卡世纪东方拉卡拉角色的会计分录卡机的水立方开讲啦肯定是埃里克点击分类卡机了开始的减肥蓝卡队数据发";
    NSString *tmp = sobotConvertToString(model.replyContent);
    // 过滤标签 改为过滤图片
//    tmp = [self filterHtmlImage:tmp];
    BOOL isCardView = NO;
    // 您的回复 和 回复了您
//    startType; // 0 客服  1客户
    if ([sobotConvertToString(model.startType) intValue] == 0) {
        _statusLab.text = SobotKitLocalString(@"回复了您");
        tmp = @"";
        if (model.replyContent.length > 0) {
            tmp = sobotConvertToString(model.replyContent);
            isCardView = [self isContaintImage:tmp];
            tmp = [self filterHtmlImage:tmp];
        }else{
            tmp = SobotKitLocalString(@"无");
        }
    }else if ([sobotConvertToString(model.startType) intValue] == 1){
        _statusLab.text = SobotKitLocalString(@"您的回复");
        if (model.replyContent.length > 0) {
            tmp = sobotConvertToString(model.replyContent);
            isCardView = [self isContaintImage:tmp];
            tmp = [self filterHtmlImage:tmp];
        }else{
            tmp = SobotKitLocalString(@"无");
        }
    }
    
    if (isCardView) {
        self.fileItemViewMT = sobotLayoutMarginTop(12, _fileItemView, self.infoCardView);
        self.infoCardView.hidden = NO;
        self.replycont.hidden = YES;
        self.replycontMT.constant = 0;
        self.infoCardViewMT.constant = 12;
        self.cardlabMT.constant = 16;
        self.infoCardLineViewMT.constant = 16;
        self.infoCardLineViewH.constant = 1;
        self.detailBtnH.constant = 40;
        
        // 富文本赋值
        NSString *text = [self getHtmlAttrStringWithText:tmp chatMsg:[SobotChatMessage new]];
        if(text.length == 0){
            _cardlab.text = @"";
        }else{
            UIColor *textColor = [ZCUIKitTools zcgetLeftChatTextColor];
            UIColor *linkColor = [ZCUIKitTools zcgetChatLeftLinkColor];
                [SobotHtmlCore filterHtml:text result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
                    if (text1 != nil && text1.length > 0) {
                        NSMutableAttributedString *attr;
                        UIFont *font = [ZCUIKitTools zcgetKitChatFont];
                        attr = [SobotHtmlFilter setHtml:text1 attrs:arr view: self->_cardlab textColor:textColor textFont:font linkColor:linkColor];
                        self->_cardlab.attributedText = attr;
                    }else{
                        self->_cardlab.attributedText = [[NSAttributedString alloc] initWithString:@""];
                    }
                }];
        }
    }else{
        self.fileItemViewMT = sobotLayoutMarginTop(12, _fileItemView, self.replycont);
        self.infoCardView.hidden = YES;
        self.replycont.hidden = NO;
        self.replycontMT.constant = 4;
        self.infoCardViewMT.constant = 0;
        self.cardlabMT.constant = 0;
        self.infoCardLineViewMT.constant = 0;
        self.infoCardLineViewH.constant = 0;
        self.detailBtnH.constant = 0;
        
        // 富文本赋值
        NSString *text = [self getHtmlAttrStringWithText:tmp chatMsg:[SobotChatMessage new]];
        if(text.length == 0){
            _replycont.text = @"";
            _cardlab.text = @"";
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
    }
    [self.contentView addConstraint:self.fileItemViewMT];
    
    if (model.fileList.count >0) {
        self.fileItemViewMT.constant = 12;
        UIView *lastView;
        for (int i = 0; i<model.fileList.count; i++) {
            UIView *itemView = [[UIView alloc]init];
            NSDictionary *modelDic = model.fileList[i];
//            NSMutableDictionary *mutDic = [modelDic mutableCopy];
            [self.fileItemView addSubview:itemView];
            itemView.backgroundColor = UIColorFromKitModeColor(SobotColorBgSub);
            itemView.layer.cornerRadius = 4;
            itemView.layer.masksToBounds = YES;
            if (sobotIsNull(lastView)) {
                [self.fileItemView addConstraint:sobotLayoutPaddingTop(0, itemView, self.fileItemView)];
            }else{
                [self.fileItemView addConstraint:sobotLayoutMarginTop(8, itemView, lastView)];
            }
            [self.fileItemView addConstraint:sobotLayoutPaddingLeft(0, itemView, self.fileItemView)];
            [self.fileItemView addConstraint:sobotLayoutPaddingRight(0, itemView, self.fileItemView)];
            [self.fileItemView addConstraint:sobotLayoutEqualHeight(64, itemView, NSLayoutRelationEqual)];
            lastView = itemView;
            // 子控件
            SobotImageView *icon = [[SobotImageView alloc]init];
            [itemView addSubview:icon];
            icon.layer.cornerRadius = 4;
            icon.layer.masksToBounds = YES;
            icon.backgroundColor = UIColor.clearColor;
            [itemView addConstraint:sobotLayoutEqualWidth(40, icon, NSLayoutRelationEqual)];
            [itemView addConstraint:sobotLayoutEqualHeight(40, icon, NSLayoutRelationEqual)];
            [itemView addConstraint:sobotLayoutPaddingLeft(12, icon, itemView)];
            [itemView addConstraint:sobotLayoutEqualCenterY(0, icon, itemView)];
            icon.tag = 100+ i;
            icon.contentMode = UIViewContentModeScaleAspectFit;
            
            UIButton *imgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [icon addSubview:imgBtn];
            imgBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
            [icon addConstraint:sobotLayoutPaddingTop(0, imgBtn, icon)];
            [icon addConstraint:sobotLayoutPaddingLeft(0, imgBtn, icon)];
            [icon addConstraint:sobotLayoutPaddingRight(0, imgBtn, icon)];
            [icon addConstraint:sobotLayoutPaddingBottom(0, imgBtn, icon)];

            NSString *fileType = sobotConvertToString(modelDic[@"fileType"]);
            NSString *fileUrlStr = sobotUrlEncodedString(sobotConvertToString(modelDic[@"fileUrl"]));
            NSString *fileName = sobotConvertToString(modelDic[@"fileName"]);
            NSString *cellIndexStr = sobotConvertToString(modelDic[@"cellIndex"]);
            UIColor *titleColor;
            if (cellIndexStr.length > 0 && [cellIndexStr isEqualToString:@"0"]) {
                titleColor = UIColorFromKitModeColor(SobotColorTextMain);
            }else{
                titleColor = UIColorFromKitModeColor(SobotColorTextSub);
            }
            fileUrlStr = sobotValidURLString(fileUrlStr);
            
            NSURL *fileUrl = [NSURL URLWithString:fileUrlStr];
            NSString *iconImgStr;
            if ([fileType isEqualToString:@"xls"] || [fileType isEqualToString:@"xlsx"]) {
                iconImgStr = @"zcicon_file_excel";
            }
            else if([fileType isEqualToString:@"mp3"]){
                iconImgStr = @"zcicon_file_mp3";
            }
            else if([fileType isEqualToString:@"mp4"]){
                iconImgStr = @"zcicon_file_mp4";
            }
            else if([fileType isEqualToString:@"pdf"]){
                iconImgStr = @"zcicon_file_pdf";
            }
            else if([fileType isEqualToString:@"ppt"] || [fileType isEqualToString:@"pptx"]){
                iconImgStr = @"zcicon_file_ppt";
            }
            else if([fileType isEqualToString:@"txt"]){
                iconImgStr = @"zcicon_file_txt";
            }
            else if([fileType isEqualToString:@"doc"] || [fileType isEqualToString:@"docx"]){
                iconImgStr = @"zcicon_file_word";
            }
            else if([fileType isEqualToString:@"zip"] || [fileType isEqualToString:@"rar"]){
                iconImgStr = @"zcicon_file_zip";
            }
            else{
                iconImgStr = @"zcicon_file_unknow";
            }
            if ([[fileType lowercaseString] isEqualToString:@"jpg"]
                || [[fileType lowercaseString] isEqualToString:@"jpeg"]
                || [[fileType lowercaseString] isEqualToString:@"png"]
                ||[[fileType lowercaseString] isEqualToString:@"gif"]) {
                [icon loadWithURL:fileUrl placeholer:nil showActivityIndicatorView:YES completionBlock:^(UIImage *image, NSURL *url, NSError *error) {
                    if (image !=nil) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            icon.image = image;
                            [imgBtn setImage:image forState:0];
                        });
                    }
                }];
            }else{
                // 显示图标
                [icon setImage:[SobotUITools getSysImageByName:iconImgStr]];
                [imgBtn setImage:[SobotUITools getSysImageByName:iconImgStr] forState:0];
            }
            
            UILabel *subTip = [[UILabel alloc]init];
            [itemView addSubview:subTip];
            subTip.textColor = UIColorFromKitModeColor(SobotColorTextMain);
            subTip.font = SobotFont14;
            subTip.numberOfLines = 1;
            [itemView addConstraint:sobotLayoutPaddingRight(-12, subTip, itemView)];
            [itemView addConstraint:sobotLayoutMarginLeft(8, subTip, icon)];
            [itemView addConstraint:sobotLayoutPaddingTop(12, subTip, itemView)];
            [itemView addConstraint:sobotLayoutEqualHeight(22, subTip, NSLayoutRelationEqual)];
            subTip.lineBreakMode = NSLineBreakByTruncatingMiddle;
            subTip.text = sobotConvertToString(fileName);
            subTip.tag = 100 + i;
            
            UILabel *sizeLab = [[UILabel alloc]init];
            [itemView addSubview:sizeLab];
            sizeLab.font = SobotFont12;
            sizeLab.textColor = UIColorFromKitModeColor(SobotColorTextSub1);
            [itemView addConstraint:sobotLayoutMarginTop(0, sizeLab, subTip)];
            [itemView addConstraint:sobotLayoutEqualHeight(20, sizeLab, NSLayoutRelationEqual)];
            [itemView addConstraint:sobotLayoutMarginLeft(8, sizeLab, icon)];
            [itemView addConstraint:sobotLayoutPaddingRight(-12, sizeLab, itemView)];
            sizeLab.tag = 100 +i;
            
            // 整个点击事件
            SobotButton *clickBtn = [SobotButton buttonWithType:UIButtonTypeCustom];
            [itemView addSubview:clickBtn];
            clickBtn.backgroundColor = UIColor.clearColor;
            clickBtn.tag = 100 +i;
            clickBtn.obj = @{@"icon":imgBtn,@"dict":modelDic};
            [itemView addSubview:clickBtn];
            [itemView addConstraint:sobotLayoutPaddingTop(0, clickBtn, itemView)];
            [itemView addConstraint:sobotLayoutPaddingLeft(0, clickBtn, itemView)];
            [itemView addConstraint:sobotLayoutPaddingRight(0, clickBtn, itemView)];
            [itemView addConstraint:sobotLayoutPaddingBottom(0, clickBtn, itemView)];
            // 点击放大图片，进入图片
            [clickBtn addTarget:self action:@selector(tapBrowser:) forControlEvents:UIControlEventTouchUpInside];
            if (i == model.fileList.count -1) {
                // 最后一个
                if (i == 0 ) {
//                    bgH = bgH +64;
                    self.fileItemViewEH.constant = 64;
                }else{
//                    bgH = bgH + (i+1)*64 + i*8;
                    self.fileItemViewEH.constant = (i+1)*64 + i*8;
                }
            }
        }
    }else{
        self.fileItemViewMT.constant = 0;
    }
    
    // 下面是9宫格的实现方案，如果需要 使用下面的代码
//    if(model.fileList.count > 0) {
//        float fileBgView_margin_left = 36;
//        float fileBgView_margin_top =12;
//        float fileBgView_margin_right = 20;
//        float fileBgView_margin = 8;
////      宽度固定为  （屏幕宽度 - 60)/3
//        CGSize fileViewRect = CGSizeMake((ScreenWidth -36)/5, 75);
////      算一下每行多少个 ，
//        float nums = (ScreenWidth - fileBgView_margin_left - fileBgView_margin_right)/(fileViewRect.width + fileBgView_margin);
//        NSInteger numInt = floor(nums);
////      行数：
//        NSInteger rows = ceil(model.fileList.count/(float)numInt);
//        for (int i = 0 ; i < model.fileList.count;i++) {
//            NSDictionary *modelDic = model.fileList[i];
//            NSMutableDictionary *mutDic = [modelDic mutableCopy];
//            [mutDic setValue:[NSString stringWithFormat:@"%lu",(unsigned long)row] forKey:@"cellIndex"];
//            //           当前列数
//            NSInteger currentColumn = i%numInt;
////           当前行数
//            NSInteger currentRow = i/numInt;
//            float x = fileBgView_margin_left + (fileViewRect.width + fileBgView_margin)*currentColumn;
//            float y = bgH + fileBgView_margin_top + (fileViewRect.height + fileBgView_margin)*currentRow;
//            float w = fileViewRect.width;
//            float h = fileViewRect.height;
//            
//            ZCReplyFileView *fileBgView = [[ZCReplyFileView alloc]initWithDic:mutDic withFrame:CGRectMake(x, y, w, h)];
//            fileBgView.layer.cornerRadius = 4;
//            fileBgView.layer.masksToBounds = YES;
//                
//            [fileBgView setClickBlock:^(NSDictionary * _Nonnull modelDic, UIImageView * _Nonnull imgView) {
//               NSString *fileType = modelDic[@"fileType"];
//               NSString *fileUrlStr = sobotUrlEncodedString(modelDic[@"fileUrl"]);
////                NSArray *imgArray = [[NSArray alloc]initWithObjects:fileUrlStr, nil];
//                if ([fileType isEqualToString:@"jpg"] ||
//                    [fileType isEqualToString:@"jpeg"] ||
//                    [fileType isEqualToString:@"png"] ||
//                    [fileType isEqualToString:@"gif"] ) {
//                    //     图片预览
//                    UIImageView *picView = imgView;
//                    CALayer *calayer = picView.layer.mask;
//                    [picView.layer.mask removeFromSuperlayer];
//                    SobotXHImageViewer *xh= [[SobotXHImageViewer alloc] initWithImageViewersobotHxWillDismissWithSelectedViewBlock:^(SobotXHImageViewer *imageViewer, UIImageView *selectedView) {
//                        
//                    } sobotHxDidDismissWithSelectedViewBlock:^(SobotXHImageViewer *imageViewer, UIImageView *selectedView) {
//                        selectedView.layer.mask = calayer;
//                        [selectedView setNeedsDisplay];
//                    } sobotHxDidChangeToImageViewBlock:^(SobotXHImageViewer *imageViewer, UIImageView *selectedView) {
//                        
//                    }];
//                    NSMutableArray *photos = [[NSMutableArray alloc] init];
//                    [photos addObject:picView];
//                    xh.disableTouchDismiss = NO;
//                    [xh showWithImageViews:photos selectedView:picView];
//                }
//                else if ([fileType isEqualToString:@"mp4"]){
//                    NSURL *imgUrl = [NSURL URLWithString:fileUrlStr];
//                     UIWindow *window = [SobotUITools getCurWindow];
//                     ZCVideoPlayer *player = [[ZCVideoPlayer alloc] initWithFrame:window.bounds withShowInView:window url:imgUrl Image:nil];
//                     [player showControlsView];
//                }else{
//                    SobotChatMessage *message = [[SobotChatMessage alloc]init];
//                    SobotChatContent *rich = [[SobotChatContent alloc]init];
//                    rich.url = fileUrlStr;
//                    
//                    /**
//                    * 13 doc文件格式
//                    * 14 ppt文件格式
//                    * 15 xls文件格式
//                    * 16 pdf文件格式
//                    * 17 mp3文件格式
//                    * 18 mp4文件格式
//                    * 19 压缩文件格式
//                    * 20 txt文件格式
//                    * 21 其他文件格式
//                    */
//                    if ([fileType isEqualToString:@"doc"] || [fileType isEqualToString:@"docx"] ) {
//                        rich.fileType = 13;
//                    }
//                    else if ([fileType isEqualToString:@"ppt"] || [fileType isEqualToString:@"pptx"]){
//                        rich.fileType = 14;
//                    }
//                    else if ([fileType isEqualToString:@"xls"] || [fileType isEqualToString:@"xlsx"]){
//                        rich.fileType = 15;
//                    }
//                    else if ([fileType isEqualToString:@"pdf"]){
//                        rich.fileType = 16;
//                    }
//                    else if ([fileType isEqualToString:@"mp3"]){
//                        rich.fileType = 17;
//                    }
////                    else if ([fileType isEqualToString:@"mp4"]){
////                        rich.fileType = 18;
////                    }
//                    else if ([fileType isEqualToString:@"zip"]){
//                        rich.fileType = 19;
//                    }
//                    else if ([fileType isEqualToString:@"txt"]){
//                        rich.fileType = 20;
//                    }
//                    else{
//                        rich.fileType = 21;
//                    }
//                    message.richModel = rich;
//                    message.richModel.content = modelDic[@"fileName"];
//                    ZCDocumentLookController *docVc = [[ZCDocumentLookController alloc]init];
//                    docVc.message = message;
//                    [self openNewPage:docVc];
//                }
//            }];
//            [self.contentView addSubview:fileBgView];
//        }
//        bgH = bgH + (fileViewRect.height + fileBgView_margin_top)*rows;
//    }
    
    if (row == 1) {
        //第一条
//        self.lineViewPT.constant = 0;
        self.toplineView.backgroundColor = UIColor.clearColor;
    }else{
//        self.lineViewPT.constant = -30;
//        self.toplineView.backgroundColor = UIColor.clearColor;
        self.toplineView.backgroundColor = UIColorFromKitModeColor(SobotColorBgTopLine);
    }
    
//    if (row == count -1) {
//        self.lineViewPB.constant = -5;
//    }
    
//    self.bgHeightViewEH.constant = bgH;
    if(SobotKitIsRTLLayout){
        [_statusLab setTextAlignment:NSTextAlignmentRight];
        [_replycont setTextAlignment:NSTextAlignmentRight];
        for(UIView *v in self.contentView.subviews){
            [SobotUITools setRTLFrame:v];
        }
    }
}

#pragma mark --预览和打开附件
-(void)tapBrowser:(SobotButton*)sender{
    NSDictionary *dict = (NSDictionary*)sender.obj;
    UIButton *icon = [dict objectForKey:@"icon"];
    NSDictionary *modelDic = [dict objectForKey:@"dict"];
   NSString *fileType = modelDic[@"fileType"];
   NSString *fileUrlStr = sobotUrlEncodedString(modelDic[@"fileUrl"]);
//                NSArray *imgArray = [[NSArray alloc]initWithObjects:fileUrlStr, nil];
    if ([fileType isEqualToString:@"jpg"] ||
        [fileType isEqualToString:@"jpeg"] ||
        [fileType isEqualToString:@"png"] ||
        [fileType isEqualToString:@"gif"] ) {
        //     图片预览
        UIImageView *picView = (UIImageView*)icon.imageView;
        if (sobotIsNull(picView.image)) {
            return;
        }
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
}

- (void)getFileSizeFromURL:(NSString *)urlString completion:(void (^)(int64_t fileSize))completion {
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        completion(-1);
        return;
    }
    // 创建请求，方法为 HEAD
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"HEAD"];
    // 创建会话
    NSURLSession *session = [NSURLSession sharedSession];
    // 发起请求
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
            completion(-1);
            return;
        }
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            // 获取 Content-Length 字段
            NSString *contentLengthString = [httpResponse.allHeaderFields objectForKey:@"Content-Length"];
            if (contentLengthString) {
                int64_t fileSize = [contentLengthString longLongValue];
                completion(fileSize);
            } else {
                completion(-1); // 如果没有 Content-Length 字段，返回 -1
            }
        } else {
            completion(-1); // 如果响应不是 HTTP 响应，返回 -1
        }
    }];
    [task resume];
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
