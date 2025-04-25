//
//  ZCLeaveEditView.m
//  SobotKit
//
//  Created by lizh on 2022/9/5.
//

#import "ZCLeaveEditView.h"
#import <SobotCommon/SobotCommon.h>
#import <SobotCommon/SobotDataTimePickView.h>
#import <SobotChatClient/SobotChatClient.h>
#import "ZCUIKitTools.h"
#import "ZCUICore.h"
#import "SobotHtmlFilter.h"
#import "ZCOrderContentCell.h"
#define cellOrderContentIdentifier @"ZCOrderContentCell"
#import "ZCOrderOnlyEditCell.h"
#define cellOrderSingleIdentifier @"ZCOrderOnlyEditCell"
#import "ZCOrderEditCell.h"
#define cellEditIdentifier @"ZCOrderEditCell"
#import "ZCOrderCheckCell.h"
#define cellCheckIdentifier @"ZCOrderCheckCell"
#import "ZCOrderCheckMoreCell.h"
#define cellCheckMoreIdentifier @"ZCOrderCheckMoreCell"
#import "ZCCheckTypeView.h"
#import "ZCPageSheetView.h"
#import "ZCCheckMulCusFieldView.h"
#import "ZCCheckCusFieldView.h"
#import "ZCLeaveRegionSheetView.h"
#import "ZCZHPickView.h"
#import "ZCVideoPlayer.h"
#import <AVFoundation/AVFoundation.h>
@interface ZCLeaveEditView ()<UINavigationControllerDelegate,UITableViewDelegate,UITableViewDataSource,SobotEmojiLabelDelegate,ZCOrderCreateCellDelegate,ZCZHPickViewDelegate,SobotActionSheetViewDelegate,UIGestureRecognizerDelegate>
{
    // 呼叫的电话号码
    NSString *callURL;
    NSMutableArray *imageURLArr;
    CGPoint contentoffset;// 记录list的偏移量
    SobotXHImageViewer *xh;
    ZCOrderCusFiledsModel *curEditModel;
    // 时间加日期
    SobotDataTimePickView *picker;
    ZCLeaveRegionSheetView *vc;
}
@property(nonatomic,strong) ZCOrderModel * model;
@property(nonatomic, assign) BOOL isSend;
/** 系统相册相机图片 */
@property(nonatomic,strong)UIImagePickerController *zc_imagepicker;
@property(nonatomic,strong)UITableView *listTable;
@property(nonatomic,strong)NSMutableArray *listArray;
@property(nonatomic,strong)NSMutableArray *imageArr;
@property(nonatomic,strong)NSMutableArray *imagePathArr;// 存储本地图片路径
@property(nonatomic,strong)NSMutableArray *imageReplyArr;
@property(nonatomic,strong)UITextView *tempTextView;
@property(nonatomic,strong)UITextField *tempTextField;
@property(nonatomic,assign) BOOL isReplyPhoto;// 是否是回复的图片
@property (nonatomic,strong) ZCZHPickView *pickView; // 日期控件

///////////////////////////////////// 以下为约束属性 ////////////////////////////////////////////////
@property (nonatomic,strong)NSLayoutConstraint *listViewPT;
@property (nonatomic,strong)NSLayoutConstraint *listViewPL;
@property (nonatomic,strong)NSLayoutConstraint *listViewPR;
@property (nonatomic,strong)NSLayoutConstraint *listViewPB;
@property (nonatomic,strong)NSLayoutConstraint *commitBtnEW;



//留言成功页面相关
@property (nonatomic,strong)UIImageView *img;
@property (nonatomic,strong)UILabel *titleLab;
@property (nonatomic,strong)UILabel *tiplab;
@property (nonatomic,strong)UIButton *comBtn;
@property (nonatomic,strong)UIButton *recordBtn;
@property (nonatomic,strong)NSLayoutConstraint *imgPT;
@property (nonatomic,strong)NSLayoutConstraint *comBtnMT;

@end


@implementation ZCLeaveEditView

-(id)initWithFrame:(CGRect) frame withController:(UIViewController *) vc{
    self = [super initWithFrame:frame];
    if(self){
        _isSend = NO;
        _exController = vc;
        _listArray = [[NSMutableArray alloc] init];
        _model = [ZCOrderModel new];
        [self createSubViews];
//        [self addLeaveMsgSuccessView];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didRotate:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)didRotate:(NSNotification *)notification {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
        // 横屏
//        NSLog(@"横屏");
        
    } else if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown) {
        // 竖屏
//        NSLog(@"竖屏");
    }
    if (!sobotIsNull(picker)) {
        [picker pickViewDismiss];
    }
    if (!sobotIsNull(vc)) {
        [vc closeSheetView];
    }
    if (!sobotIsNull(_pickView)) {
        [_pickView remove];
    }
}

-(void)createSubViews{
    
    // 先创建提交按钮，悬浮到底部
    UIButton * commitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [commitBtn setTitle:SobotKitLocalString(@"提交") forState:UIControlStateNormal];
    [commitBtn setTitle:SobotKitLocalString(@"提交") forState:UIControlStateSelected];
    [commitBtn setTitleColor:[ZCUIKitTools zcgetLeaveSubmitTextColor] forState:UIControlStateNormal];
    [commitBtn setTitleColor:[ZCUIKitTools zcgetLeaveSubmitTextColor] forState:UIControlStateHighlighted];
    UIImage * img = [self createImageWithColor:[ZCUIKitTools zcgetServerConfigBtnBgColor]];
    [commitBtn setBackgroundImage:img forState:UIControlStateNormal];
    [commitBtn setBackgroundImage:img forState:UIControlStateSelected];
    commitBtn.tag = 1001;
    [commitBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    commitBtn.layer.masksToBounds = YES;
    commitBtn.layer.cornerRadius = 4.0f;
    commitBtn.titleLabel.font = SobotFont17;
//     commitBtn.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self addSubview:commitBtn];
   [self addConstraint:sobotLayoutPaddingLeft(20, commitBtn, self)];
   [self addConstraint:sobotLayoutEqualHeight(40, commitBtn, NSLayoutRelationEqual)];
   self.commitBtnEW = sobotLayoutEqualWidth(ScreenWidth - 40, commitBtn, NSLayoutRelationEqual);
   [self addConstraint:self.commitBtnEW];
    [self addConstraint:sobotLayoutPaddingBottom(0, commitBtn, self)];
    
    
    self.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
    _listTable = (SobotTableView*)[SobotUITools createTableWithView:self delegate:self style:UITableViewStyleGrouped];
     _listTable.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
     _listTable.sectionFooterHeight = 0;
     [self addSubview:_listTable];
     [_listTable registerClass:[ZCOrderCheckCell class] forCellReuseIdentifier:cellCheckIdentifier];
     [_listTable registerClass:[ZCOrderContentCell class] forCellReuseIdentifier:cellOrderContentIdentifier];
     [_listTable registerClass:[ZCOrderEditCell class] forCellReuseIdentifier:cellEditIdentifier];
     [_listTable registerClass:[ZCOrderOnlyEditCell class] forCellReuseIdentifier:cellOrderSingleIdentifier];
    [_listTable registerClass:[ZCOrderCheckMoreCell class] forCellReuseIdentifier:cellCheckMoreIdentifier];
    // 分割线的隐藏
    _listTable.separatorColor = UIColor.clearColor;
    //可以省略不设置
    _listTable.rowHeight = UITableViewAutomaticDimension;
    self.listViewPT = sobotLayoutPaddingTop(0, _listTable, self);
    [self addConstraint:self.listViewPT];
    self.listViewPL = sobotLayoutPaddingLeft(0, _listTable, self);
    [self addConstraint:self.listViewPL];
    self.listViewPR = sobotLayoutPaddingRight(0, _listTable, self);
    [self addConstraint:self.listViewPR];
    self.listViewPB =  sobotLayoutPaddingBottom(0, _listTable, self);
    self.listViewPB = sobotLayoutMarginBottom(-20, _listTable, commitBtn);
    [self addConstraint:self.listViewPB];
     UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHideKeyboard)];
     gestureRecognizer.numberOfTapsRequired = 1;
     gestureRecognizer.cancelsTouchesInView = NO;
    gestureRecognizer.delegate = self;
     [_listTable addGestureRecognizer:gestureRecognizer];
     
     // 提交按钮
//     UIView * footView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 300)];
//    footView.userInteractionEnabled = YES;
//     footView.backgroundColor = [UIColor clearColor];
//     // 区尾添加提交按钮 2.7.1改版
//     UIButton * commitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//     [commitBtn setTitle:SobotKitLocalString(@"提交") forState:UIControlStateNormal];
//     [commitBtn setTitle:SobotKitLocalString(@"提交") forState:UIControlStateSelected];
//     [commitBtn setTitleColor:[ZCUIKitTools zcgetLeaveSubmitTextColor] forState:UIControlStateNormal];
//     [commitBtn setTitleColor:[ZCUIKitTools zcgetLeaveSubmitTextColor] forState:UIControlStateHighlighted];
//     UIImage * img = [self createImageWithColor:[ZCUIKitTools zcgetServerConfigBtnBgColor]];
//     [commitBtn setBackgroundImage:img forState:UIControlStateNormal];
//     [commitBtn setBackgroundImage:img forState:UIControlStateSelected];
//     commitBtn.tag = 1001;
//     [commitBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
//     commitBtn.layer.masksToBounds = YES;
//     commitBtn.layer.cornerRadius = 4.0f;
//     commitBtn.titleLabel.font = SobotFont17;
////     commitBtn.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
//     [footView addSubview:commitBtn];
//    [footView addConstraint:sobotLayoutPaddingTop(20, commitBtn, footView)];
//    [footView addConstraint:sobotLayoutPaddingLeft(20, commitBtn, footView)];
////    [footView addConstraint:sobotLayoutPaddingRight(-20, commitBtn, footView)];
//    [footView addConstraint:sobotLayoutEqualHeight(40, commitBtn, NSLayoutRelationEqual)];
//    self.commitBtnEW = sobotLayoutEqualWidth(ScreenWidth - 40, commitBtn, NSLayoutRelationEqual);
//    [footView addConstraint:self.commitBtnEW];
//    _listTable.tableFooterView = footView;
}

#pragma mark EmojiLabel链接点击事件
// 链接点击
- (void)attributedLabel:(SobotAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    // 此处得到model 对象对应的值
    [self doClickURL:url.absoluteString text:@""];
}

- (void)SobotEmojiLabel:(SobotEmojiLabel*)emojiLabel didSelectLink:(NSString*)link withType:(SobotEmojiLabelLinkType)type{
    [self doClickURL:link text:@""];
}

// 链接点击
-(void)doClickURL:(NSString *)url text:(NSString * )htmlText{
    if(url){
        url=[url stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        [[ZCUICore getUICore] dealWithLinkClickWithLick:url viewController:_exController];
    }
}

#pragma mark - tabelView delegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self allHideKeyBoard];
}

// 返回section数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _listArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

// 返回section高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        SobotEmojiLabel *label = [[SobotEmojiLabel alloc] initWithFrame:CGRectMake(15, 12, ScreenWidth-30, 0)];
        [label setFont:SobotFont14];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextAlignment:NSTextAlignmentLeft];
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            [label setTextAlignment:NSTextAlignmentRight];
        }
        [label setTextColor:UIColorFromKitModeColor(SobotColorHeaderText)];
        label.numberOfLines = 0;
        label.isNeedAtAndPoundSign = NO;
        label.disableEmoji = NO;
        label.lineSpacing = 3.0f;
        [label setLinkColor:[ZCUIKitTools zcgetChatLeftLinkColor]];
//        label.delegate = self;
         __block CGSize  labSize = CGSizeZero;
        NSString *text = _msgTxt;//[self getCurConfig].msgTxt;
        text = [SobotHtmlCore removeAllHTMLTag:text];
        NSString *msg = text;
//        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithData:[msg dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
//                                                                 documentAttributes:nil
//                                                                            error:nil];
//        [ZCLeaveEditView setDisplayAttributedString:attrString label:label color:UIColorFromKitModeColor(SobotColorHeaderText)];
//        [SobotHtmlCore filterHtml:text result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
//            if (text1 !=nil && text1.length > 0) {
//                 label.attributedText =   [SobotHtmlFilter setHtml:text1 attrs:arr view:label textColor:UIColorFromKitModeColor(SobotColorTextSub) textFont:SobotFont14 linkColor:[ZCUIKitTools zcgetChatLeftLinkColor]];
//            }else{
//                 label.attributedText = [[NSAttributedString alloc] initWithString:@""];
//            }
            label.text = msg;
            labSize  = [label preferredSizeWithMaxWidth:ScreenWidth-32];
//        }];
        return labSize.height + 20;
    }
    return 0;
}

// 返回section 的View
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    if (section == 0) {
        [view setBackgroundColor:UIColorFromKitModeColor(SobotColorHeaderBg)];
        SobotEmojiLabel *label = [[SobotEmojiLabel alloc] initWithFrame:CGRectMake(15, 10, ScreenWidth-30, 0)];
        [label setFont:SobotFont14];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextAlignment:NSTextAlignmentLeft];
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            [label setTextAlignment:NSTextAlignmentRight];
        }
//        [label setTextColor:UIColorFromKitModeColor(SobotColorTextSub)];
        [label setTextColor:UIColorFromKitModeColor(SobotColorHeaderText)];
        label.numberOfLines = 0;
        label.isNeedAtAndPoundSign = NO;
        label.disableEmoji = NO;
        label.lineSpacing = 3.0f;
        [label setLinkColor:[ZCUIKitTools zcgetChatLeftLinkColor]];
        label.delegate = self;
         __block CGSize  labSize = CGSizeZero;
        NSString *text = _msgTxt;
        if(sobotConvertToString([ZCUICore getUICore].kitInfo.leaveMsgGuideContent).length > 0){
            text = SobotKitLocalString(sobotConvertToString([ZCUICore getUICore].kitInfo.leaveMsgGuideContent));
        }
        text = [SobotHtmlCore removeAllHTMLTag:text];
        NSString *msg = text;
//        msg = [msg stringByAppendingString:@"<a href=\"https://www.w3school.com.cn\">访问 w3school.com.cn!</a>"];
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithData:[msg dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
//                                                                     documentAttributes:nil
//                                                                                error:nil];
            // 当异步任务完成时，如果需要更新UI，可以回到主线程
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [ZCLeaveEditView setDisplayAttributedString:attrString label:label color:UIColorFromKitModeColor(SobotColorHeaderText)];
                label.text = msg;
                labSize  =  [label preferredSizeWithMaxWidth:ScreenWidth-32];
                label.frame = CGRectMake(16, 10, labSize.width, labSize.height);
                [view addSubview:label];
                CGRect VF = view.frame;
                VF.size.height = labSize.height + 10;
                view.frame = VF;
                [SobotUITools setRTLFrame:label];
//            });
//        });
    }
    return view;
}

// 返回section下得行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_listArray==nil){
        return 0;
    }
    NSDictionary *sectionDict = _listArray[section];
    return ((NSMutableArray *)sectionDict[@"arr"]).count;
}

// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZCOrderCreateCell *cell = nil;
    // 0，特殊行   1 单行文本 2 多行文本 3 日期 4 时间 5 数值 6 下拉列表 7 复选框 8 单选框 9 级联字段
    NSDictionary *itemDict = _listArray[indexPath.section][@"arr"][indexPath.row];
    int type = [itemDict[@"dictType"] intValue];
    if(type == 0){
        cell = (ZCOrderContentCell*)[tableView dequeueReusableCellWithIdentifier:cellOrderContentIdentifier];
        if (cell == nil) {
            cell = [[ZCOrderContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellOrderContentIdentifier];
        }
        cell.isReply = YES;
        ((ZCOrderContentCell *)cell).imageArr = _imageArr;
        ((ZCOrderContentCell *)cell).imagePathArr = _imagePathArr;
        ((ZCOrderContentCell *)cell).enclosureShowFlag = self.enclosureShowFlag;
        ((ZCOrderContentCell *)cell).ticketContentFillFlag = self.ticketContentFillFlag;
        ((ZCOrderContentCell *)cell).ticketContentShowFlag = self.ticketContentShowFlag;
    }else if(type == 1 || type ==5){
        cell = (ZCOrderOnlyEditCell*)[tableView dequeueReusableCellWithIdentifier:cellOrderSingleIdentifier];
        if (cell == nil) {
            cell = [[ZCOrderOnlyEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellOrderSingleIdentifier];
        }
    }else if(type == 2){
        cell = (ZCOrderEditCell*)[tableView dequeueReusableCellWithIdentifier:cellEditIdentifier];
        if (cell == nil) {
            cell = [[ZCOrderEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellEditIdentifier];
        }
    }else if (type == 7){
        cell = (ZCOrderCheckMoreCell*)[tableView dequeueReusableCellWithIdentifier:cellCheckMoreIdentifier];
        if (cell == nil) {
            cell = [[ZCOrderCheckMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellCheckMoreIdentifier];
        }
    }else{
        cell = (ZCOrderCheckCell*)[tableView dequeueReusableCellWithIdentifier:cellCheckIdentifier];
        if (cell == nil) {
            cell = [[ZCOrderCheckCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellCheckIdentifier];
        }
    }
    [cell setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark1)];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.tableWidth = self.listTable.frame.size.width;
    cell.delegate = self;
    cell.tempModel = _model;
    cell.tempDict = itemDict;
    cell.indexPath = indexPath;
    [cell initDataToView:itemDict];
    return cell;
}

// table 行的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *itemDict = _listArray[indexPath.section][@"arr"][indexPath.row];
    if([itemDict[@"propertyType"] intValue]==3){
        return;
    }
    NSString *dictName = itemDict[@"dictName"];
    // 多级 工单分类
    if([@"ticketType" isEqual:dictName]){
        __block ZCLeaveEditView *myself = self;
        ZCCheckTypeView *typeVC = [[ZCCheckTypeView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0)];
        ZCPageSheetView *sheetView = [[ZCPageSheetView alloc] initWithTitle:SobotKitLocalString(@"选择") superView:self showView:typeVC type:ZCPageSheetTypeLong];
        typeVC.typeId = @"-1";
        typeVC.parentView = nil;
        typeVC.listArray = _typeArr;
        typeVC.selTypeId = self.model.ticketType;
        typeVC.orderTypeCheckBlock = ^(ZCLibTicketTypeModel *tempmodel) {
            if(tempmodel){
                myself.model.ticketType = tempmodel.typeId;
                myself.model.ticketTypeName = tempmodel.typeName;
                [self refreshViewData];
                
                [sheetView dissmisPageSheet];
            }
        };
        [sheetView showSheet:typeVC.frame.size.height animation:YES block:^{
            
        }];
        return;
    }
    
    // 0，特殊行   1 单行文本 2 多行文本 3 日期 4 时间 5 数值 6 下拉列表 7 复选框 8 单选框 9 级联字段
    int propertyType = [itemDict[@"propertyType"] intValue];
    if(propertyType == 1){
        int index = [itemDict[@"code"] intValue];
        curEditModel = _coustomArr[index];
        int fieldType = [curEditModel.fieldType intValue];
        if(fieldType == 4){
           _pickView = [[ZCZHPickView alloc] initWithFrame:self.frame DatePickWithDate:[NSDate new]  datePickerMode:UIDatePickerModeTime isHaveNavControler:NO];
            [_pickView setTitle:SobotKitLocalString(@"时间")];
            _pickView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
            _pickView.delegate = self;
            [_pickView show];
        }
        if(fieldType == 9){
            __block ZCLeaveEditView *myself = self;
            ZCCheckMulCusFieldView *typeVC = [[ZCCheckMulCusFieldView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0)];
            typeVC.preModel = curEditModel;
            if(sobotConvertToString(self->curEditModel.fieldName).length > 0){
                typeVC.pageTitle = sobotConvertToString(self->curEditModel.fieldName);
            }else{
                typeVC.pageTitle = SobotKitLocalString(@"选择");
            }
            
            ZCPageSheetView *sheetView = [[ZCPageSheetView alloc] initWithTitle:SobotKitLocalString(@"选择") superView:self showView:typeVC type:ZCPageSheetTypeLong];
            typeVC.parentDataId = @"";
            typeVC.parentView = nil;
            typeVC.allArray = curEditModel.detailArray;
            typeVC.orderCusFiledCheckBlock = ^(ZCOrderCusFieldsDetailModel *model, NSString *dataIds,NSString *dataNames) {
                self->curEditModel.fieldValue = dataNames;
                self->curEditModel.fieldSaveValue = dataIds;
                [myself refreshViewData];
                [sheetView dissmisPageSheet];
            };
            [sheetView showSheet:typeVC.frame.size.height animation:YES block:^{

            }];
            return;
        }
        if(fieldType == 12){
            // 日期时间
            NSString *checkTimezoneId = @"";
            NSString *checkTimezoneValue = @"";
            if(sobotConvertToString(curEditModel.fieldSaveValue).length > 0){
                NSArray *tempArray = [sobotConvertToString(curEditModel.fieldSaveValue) componentsSeparatedByString:@","];
                if(tempArray.count > 1){
                    checkTimezoneId = sobotConvertToString(tempArray[0]);
                }
            }
            if(sobotConvertToString(curEditModel.fieldValue).length > 0){
                NSArray *tempArray = [sobotConvertToString(curEditModel.fieldValue) componentsSeparatedByString:@","];
                if([curEditModel.fieldValue containsString:@"\n"]){
                    tempArray = [sobotConvertToString(curEditModel.fieldValue) componentsSeparatedByString:@"\n"];
                }
                if(tempArray.count > 1){
                    checkTimezoneValue = sobotConvertToString(tempArray[0]);
                }
            }
            NSString *language = sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.absolute_language);
            if(language.length == 0){
                language = sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.locale);
            }
            if(language.length == 0){
                language = sobotGetLanguagePrefix();
            }
            
            picker = [[SobotDataTimePickView alloc] initWithFrame:CGRectZero];
            picker.language = language;
            picker.region = 1;//[picker.language hasPrefix:@"zh"]?0:1;
            picker.checkedTimeZone = @{@"timezoneId":sobotConvertToString(checkTimezoneId),@"title":sobotConvertToString(checkTimezoneValue),@"timezoneValue":sobotConvertToString(checkTimezoneValue)};
            picker.isMustFlag = [sobotConvertToString(curEditModel.fillFlag) intValue] == 1;
            picker.existMinute = YES;
            picker.server_host = [[ZCLibClient getZCLibClient] getCurApiHost];
            [picker setOnCommitBlock:^(int action, NSString * _Nonnull resultText, NSString * _Nullable timezoneId, id  _Nullable timeZone) {
                SLog(@"%@,%@",timezoneId,resultText);
                if(action == 1){
                    NSString *text = resultText;
                    NSString *value = resultText;
                    
                    
                    if(sobotConvertToString(timezoneId).length > 0){
                        value = [NSString stringWithFormat:@"%@,%@",timezoneId,resultText];
                        text = [NSString stringWithFormat:@"%@,%@",timezoneId,resultText];
                        NSDictionary *r = timeZone;
                        if(r && [r isKindOfClass:[NSDictionary class]] && sobotConvertToString(r[@"timezoneValue"]).length > 0){
                            text = [NSString stringWithFormat:@"%@,%@",sobotConvertToString(r[@"timezoneValue"]),resultText];
                        }
                    }
                    self->curEditModel.fieldValue = text;
                    self->curEditModel.fieldSaveValue = value;
                    [self refreshViewData];
                }
            }];
            
            picker.pageTitle = curEditModel.fieldName;
            picker.btnBgColor = [ZCUIKitTools zcgetServerConfigBtnBgColor];
            picker.btnTitleColor = [ZCUIKitTools zcgetRobotBtnTitleColor];
            picker.isRTL = [ZCUIKitTools getSobotIsRTLLayout];
            [picker pickViewShow];
            return;
        }
        if(fieldType == 3){
            _pickView = [[ZCZHPickView alloc] initWithFrame:self.frame DatePickWithDate:[NSDate new]  datePickerMode:UIDatePickerModeDate isHaveNavControler:NO];
            [_pickView setTitle:SobotKitLocalString(@"日期")];
            _pickView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
            _pickView.delegate = self;
            [_pickView show];
        }
        
        if(fieldType == 11){
            // 地区
            vc = [[ZCLeaveRegionSheetView alloc] initAlterView:self->curEditModel.fieldName];
            vc.pageTitle = self->curEditModel.fieldName;
            vc.fieldModel = self->curEditModel;
            [vc setChooseResultBlock:^(id  _Nullable model, NSString * _Nonnull names, NSString * _Nonnull ids) {
                if(model){
                    self->curEditModel.fieldValue = [names stringByReplacingOccurrencesOfString:@"/" withString:@","];
                    self->curEditModel.fieldSaveValue = [ids stringByReplacingOccurrencesOfString:@"/" withString:@","];;
                    [self refreshViewData];
                }
            }];
            [vc setBtnCommitBgColor:[ZCUIKitTools zcgetServerConfigBtnBgColor]];
            [vc setBtnCommitTitleColor:[ZCUIKitTools zcgetRobotBtnTitleColor]];
            [vc showInView:nil];
            return;
        }
        if(fieldType == 6 || fieldType == 7 || fieldType == 8){
            ZCCheckCusFieldView *vc = [[ZCCheckCusFieldView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0)];
            vc.preModel = curEditModel;
            vc.orderCusFiledCheckBlock = ^(ZCOrderCusFieldsDetailModel *model, NSMutableArray *arr) {
                self->curEditModel.fieldValue = model.dataName;
                self->curEditModel.fieldSaveValue = model.dataValue;
                if(fieldType == 7){
                    NSString *dataName = @"";
                    NSString *dataIds = @"";
                    for (ZCOrderCusFieldsDetailModel *item in arr) {
                        dataName = [dataName stringByAppendingFormat:@",%@",item.dataName];
                        dataIds = [dataIds stringByAppendingFormat:@",%@",item.dataValue];
                    }
                    if(dataName.length>0){
                        dataName = [dataName substringWithRange:NSMakeRange(1, dataName.length-1)];
                        dataIds = [dataIds substringWithRange:NSMakeRange(1, dataIds.length-1)];
                    }
                    self->curEditModel.fieldValue = dataName;
                    self->curEditModel.fieldSaveValue = dataIds;
                }
                [self refreshViewData];
            };
            ZCPageSheetView *sheetView = [[ZCPageSheetView alloc] initWithTitle:SobotKitLocalString(@"选择") superView:self showView:vc type:ZCPageSheetTypeLong];
            [sheetView showSheet:vc.frame.size.height animation:YES block:^{

            }];
            return;
        }
    }
}



#pragma mark 日期控件
-(void)toobarDonBtnHaveClick:(ZCZHPickView *)pickView resultString:(NSString *)resultString{
    if(curEditModel && ([curEditModel.fieldType intValue]==4 || [curEditModel.fieldType intValue]==3)){
        curEditModel.fieldValue = resultString;
        curEditModel.fieldSaveValue = resultString;
        [self refreshViewData];
    }
}

#pragma mark UITableViewCell 行点击事件处理
-(void)itemCreateCusCellOnClick:(ZCOrderCreateItemType)type dictValue:(NSString *)value dict:(NSDictionary *)dict indexPath:(NSIndexPath *)indexPath{
    // 单行或多行文本，是自定义字段，需要单独处理_coustomArr对象的内容
    if(type == ZCOrderCreateItemTypeOnlyEdit || type == ZCOrderCreateItemTypeMulEdit){
        int propertyType = [dict[@"propertyType"] intValue];
        if(propertyType == 1){
            int index = [dict[@"code"] intValue];
            ZCOrderCusFiledsModel *temModel = _coustomArr[index];
            temModel.fieldValue = value;
            temModel.fieldSaveValue = value;
            // 这里要重新处理数据 *
            NSString * titleStr = sobotConvertToString(temModel.fieldName);
            if([sobotConvertToString(temModel.fillFlag) intValue] == 1){
                titleStr = [NSString stringWithFormat:@"* %@",titleStr];
            }
            NSMutableArray *arr1 = _listArray[indexPath.section][@"arr"];
            arr1[indexPath.row] = @{@"code":[NSString stringWithFormat:@"%d",index],
                                    @"dictName":sobotConvertToString(temModel.fieldName),
                                    @"dictDesc":sobotConvertToString(titleStr),
                                    @"placeholder":sobotConvertToString(temModel.fieldRemark),
                                    @"dictValue":sobotConvertToString(temModel.fieldValue),
                                    @"dictType":sobotConvertToString(temModel.fieldType),
                                    @"propertyType":@"1"
                                    };
        }
        if (propertyType == 0) {
            ZCLibConfig *libConfig = [[ZCUICore getUICore] getLibConfig];
            NSMutableArray * arr4 = _listArray[indexPath.section][@"arr"];
            if([@"ticketEmail" isEqual:dict[@"dictName"]]){
                _model.email = value;
                NSString * text = [NSString stringWithFormat:@"%@(%@)",SobotKitLocalString(@"请输入邮箱地址"),SobotKitLocalString(@"选填")];
                NSString * title = SobotKitLocalString(@"邮箱");
                if( libConfig.emailFlag){
                    text = [NSString stringWithFormat:@"%@(%@)",SobotKitLocalString(@"请输入邮箱地址"),SobotKitLocalString(@"必填")];
                    title = [NSString stringWithFormat:@"* %@",SobotKitLocalString(@"邮箱")];
                }
               arr4[indexPath.row] = @{@"code":@"1",
                                  @"dictName":@"ticketEmail",
                                  @"dictDesc":title,
                                  @"placeholder":text,
                                  @"dictValue":sobotConvertToString(_model.email),
                                  @"dictType":@"1",
                                  @"propertyType":@"0"
                                  };
                
            }
            if([@"ticketTel" isEqual:dict[@"dictName"]]){
                _model.tel = value;
                NSString * text = [NSString stringWithFormat:@"%@(%@)",SobotKitLocalString(@"请输入手机号码"),SobotKitLocalString(@"选填")];
                NSString * title = SobotKitLocalString(@"手机");
                if ( libConfig.telFlag) {
                    text =  [NSString stringWithFormat:@"%@(%@)",SobotKitLocalString(@"请输入手机号码"),SobotKitLocalString(@"必填")];
                    title = [NSString stringWithFormat:@"* %@",SobotKitLocalString(@"手机")];
                }
                arr4[indexPath.row] = @{@"code":@"1",
                                        @"dictName":@"ticketTel",
                                        @"dictDesc":title,
                                        @"placeholder":text,
                                        @"dictValue":sobotConvertToString(_model.tel),
                                        @"dictType":@"1",
                                        @"propertyType":@"0"
                                        };
                
            }
            
            if([@"ticketTitle" isEqual:dict[@"dictName"]]){
                 _model.ticketTitle = value;
                NSString * text = [NSString stringWithFormat:@"%@",SobotKitLocalString(@"请输入")];
                  NSString * title = [NSString stringWithFormat:@"* %@",SobotKitLocalString(@"标题")];
                 arr4[indexPath.row] = @{@"code":@"1",
                                    @"dictName":@"ticketTitle",
                                    @"dictDesc":title,
                                    @"placeholder":text,
                                    @"dictValue":sobotConvertToString(_model.ticketTitle),
                                    @"dictType":@"1",
                                    @"propertyType":@"0"
                  };
             }
        }
    }
}

- (void)didAddImage{
    SobotActionSheetView *mysheet = [[SobotActionSheetView alloc]initWithDelegate:self title:@"" CancelTitle:SobotKitLocalString(@"取消") OtherTitles:SobotKitLocalString(@"拍摄"), SobotKitLocalString(@"从相册选择"), nil];
    [mysheet show];
}

- (void)actionSheet:(SobotActionSheetView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        // 相机
        [self getPhotoByType:1];
    }
    if(buttonIndex == 2){
        // 相册
        [self getPhotoByType:0];
    }
}

#pragma mark 发送图片相关
/**
 *  根据类型获取图片
 *  @param buttonIndex 2，来源照相机，1来源相册
 */
-(void)getPhotoByType:(NSInteger) buttonIndex{
    __weak ZCLeaveEditView *_myselft = self;
    [[SobotImagePickerTools shareImagePickerTools] getPhotoByType:buttonIndex onlyPhoto:NO byUIImagePickerController:_exController block:^(NSString * _Nullable filePath, SobotImagePickerFileType type, NSDictionary * _Nullable duration) {
        if(type == SobotImagePickerFileTypeImage){
            [_myselft updateloadFile:filePath type:SobotMessageTypePhoto dict:duration];
        }else{
            [_myselft converToMp4:duration withInfoDic:duration];
        }
    }];
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)updateloadFile:(NSString *)filePath type:(SobotMessageType) type dict:(NSDictionary *) cover{
    __weak  ZCLeaveEditView *_myself  = self;
     [ZCLibServer fileUploadForLeave:filePath config:[[ZCUICore getUICore] getLibConfig] start:^{
        [[SobotToast shareToast] showProgress:[NSString stringWithFormat:@"%@...",SobotKitLocalString(@"上传中")]  with:_myself];
    } success:^(NSString * _Nonnull fileURL, ZCNetWorkCode code) {
        [[SobotToast shareToast] dismisProgress];
                  if (sobotIsNull(_myself.imageArr)) {
                      _myself.imageArr = [NSMutableArray arrayWithCapacity:0];
                  }
                  if (sobotIsNull(_myself.imagePathArr)) {
                      _myself.imagePathArr = [NSMutableArray arrayWithCapacity:0];
                  }
                  [_myself.imagePathArr addObject:filePath];
                  NSDictionary * dic = @{@"fileUrl":fileURL};
                      if(type == SobotMessageTypeVideo){
                          dic = @{@"cover":cover[@"cover"],@"fileUrl":fileURL};
                          [_myself.imageArr addObject:dic];
                      }else{
                          [_myself.imageArr addObject:dic];
                      }
                  [_myself.listTable reloadData];
    } fail:^(ZCNetWorkCode errorCode) {
        [[SobotToast shareToast] showToast:SobotKitLocalString(@"网络错误，请检查网络后重试") duration:1.0f view:_myself position:SobotToastPositionCenter];
    }];
}


- (NSString *)URLDecodedString:(NSString *) url
{
    NSString *result = [(NSString *)url stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    return [result stringByRemovingPercentEncoding];
}

-(void) converToMp4:(NSDictionary *)dict withInfoDic:(NSDictionary *)infoDic{
    #pragma mark - 注意这里的路径变化
    NSURL *videoUrl = dict[@"video"];
    NSString *coverImg = dict[@"image"];
    NSMutableDictionary *infoMutDic = [infoDic mutableCopy];
    [infoMutDic setValue:coverImg forKey:@"cover"];
//    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:videoUrl options:nil];
    [[SobotToast shareToast] showToast:SobotKitLocalString(@"视频处理中，请稍候!") duration:1.0 view:self  position:SobotToastPositionCenter];
    __weak  ZCLeaveEditView *keyboardSelf  = self;
    
//        sobotCheckPathAndCreate(sobotGetDocumentsFilePath(@"/sobot/"));
//        NSString *resultPath=sobotGetDocumentsFilePath(fname);
    if (!sobotIsNull(videoUrl)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [keyboardSelf updateloadFile:[keyboardSelf URLDecodedString:[videoUrl absoluteString]] type:SobotMessageTypeVideo dict:infoMutDic];
        });
    }
    
//    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
//    NSString * fname = [NSString stringWithFormat:@"/sobot/output-%ld.mp4",(long)[NSDate date].timeIntervalSince1970];
//    sobotCheckPathAndCreate(sobotGetDocumentsFilePath(@"/sobot/"));
//    NSString *resultPath=sobotGetDocumentsFilePath(fname);
//    exportSession.outputURL = [NSURL fileURLWithPath:resultPath];
//    exportSession.outputFileType = AVFileTypeMPEG4;
//    exportSession.shouldOptimizeForNetworkUse = YES;
//    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
//     {
//         switch (exportSession.status) {
//             case AVAssetExportSessionStatusCompleted:{
//                                  NSLog(@"AVAssetExportSessionStatusCompleted%@",[NSThread currentThread]);
//                 // 主队列回调
//                 dispatch_async(dispatch_get_main_queue(), ^{
//                     [keyboardSelf updateloadFile:[self URLDecodedString:resultPath] type:SobotMessageTypeVideo dict:infoMutDic];
//                 });
//             }
//                 break;
//             case AVAssetExportSessionStatusUnknown:
//                                  NSLog(@"AVAssetExportSessionStatusUnknown");
//                 break;
//
//             case AVAssetExportSessionStatusWaiting:
//
//                                  NSLog(@"AVAssetExportSessionStatusWaiting");
//                 break;
//
//             case AVAssetExportSessionStatusExporting:
//
//                                  NSLog(@"AVAssetExportSessionStatusExporting");
//
//                 break;
//             case AVAssetExportSessionStatusFailed:
//
//                                  NSLog(@"AVAssetExportSessionStatusFailed");
//
//                 break;
//             case AVAssetExportSessionStatusCancelled:
//
//                 break;
//         }
//     }];
}


#pragma mark - cell 代理 预览附件
-(void)itemCreateCellOnClick:(ZCOrderCreateItemType)type dictKey:(NSString *)key model:(ZCOrderModel *)model withButton:(UIButton *)button{
    if(type == ZCOrderCreateItemTypeAddPhoto || type == ZCOrderCreateItemTypeAddReplyPhoto){
        if(type == ZCOrderCreateItemTypeAddReplyPhoto){
            _isReplyPhoto = YES;
        }else{
            _isReplyPhoto = NO;
        }
        [self didAddImage];
    }
    
    // 点击删除图片
    if(type == ZCOrderCreateItemTypeDeletePhoto){
        [_imageArr removeObjectAtIndex:[key intValue]];
        [_imagePathArr removeObjectAtIndex:[key intValue]];
        [_listTable reloadData];
        // 这里重新刷新数据源
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ZCOrderContentCellReload" object:nil];
    }
    
    if(type == ZCOrderCreateItemTypeDesc || type == ZCOrderCreateItemTypeTitle || type == ZCOrderCreateItemTypeReplyType){
        _model = model;
    }
    
    if(type == ZCOrderCreateItemTypeLookAtPhoto || type == ZCOrderCreateItemTypeLookAtReplyPhoto){
        // 浏览图片
        if(type == ZCOrderCreateItemTypeLookAtReplyPhoto){
            NSInteger currentInt = [key intValue];
            NSString *imgPathStr;
            if(sobotCheckFileIsExsis([_imagePathArr objectAtIndex:currentInt])){
                imgPathStr = [_imagePathArr objectAtIndex:currentInt];
            }
            NSDictionary *imgDic = [_imageArr objectAtIndex:currentInt];
//            NSString *imgFileStr =  sobotConvertToString(imgDic[@"fileUrl"]);
            NSString *imgFileStr =  sobotConvertToString(imgDic[@"cover"]);
            if (imgFileStr.length>0) {
                imgFileStr =  sobotConvertToString(imgDic[@"fileUrl"]);
                //        视频预览
                NSURL *imgUrl = [NSURL fileURLWithPath:imgFileStr];
                UIWindow *window = [SobotUITools getCurWindow];
                ZCVideoPlayer *player = [[ZCVideoPlayer alloc] initWithFrame:window.bounds withShowInView:window url:imgUrl Image:button.imageView.image];
                [player showControlsView];
            }else{
                //     图片预览
                UIImageView *picTempView=(UIImageView*)button.imageView ;
                CGRect f = [picTempView convertRect:picTempView.bounds toView:nil];
                SobotImageView *newPicView = [[SobotImageView alloc] init];
                newPicView.image = picTempView.image;
                newPicView.frame = f;
                newPicView.layer.masksToBounds = NO;
                xh = [[SobotXHImageViewer alloc] initWithImageViewersobotHxWillDismissWithSelectedViewBlock:^(SobotXHImageViewer *imageViewer, UIImageView *selectedView) {
                    
                } sobotHxDidDismissWithSelectedViewBlock:^(SobotXHImageViewer *imageViewer, UIImageView *selectedView) {
                    [selectedView setNeedsDisplay];
                    [selectedView removeFromSuperview];
                } sobotHxDidChangeToImageViewBlock:^(SobotXHImageViewer *imageViewer, UIImageView *selectedView) {
                    
                }];
                NSMutableArray *photos = [[NSMutableArray alloc] init];
                [photos addObject:newPicView];
                xh.disableTouchDismiss = NO;
                [xh showWithImageViews:photos selectedView:newPicView];
            }
        }else{
            
        }
    }
}

#pragma mark --- 图片浏览代理
-(void)getCurPage:(NSInteger)curPage{
    
}

-(void)delCurPage:(NSInteger)curPage{
    [_imageArr removeObjectAtIndex:curPage];
    [_imagePathArr removeObjectAtIndex:curPage];
    [_listTable reloadData];
}

/**
 计算Label高度
 
 @param label 要计算的label，设置了值
 @param width label的最大宽度
 @param type 是否从新设置宽，1设置，0不设置
 */
- (CGSize )autoHeightOfLabel:(UILabel *)label with:(CGFloat )width{
    //Calculate the expected size based on the font and linebreak mode of your label
    // FLT_MAX here simply means no constraint in height
    CGSize maximumLabelSize = CGSizeMake(width, FLT_MAX);
    CGSize expectedLabelSize = [label sizeThatFits:maximumLabelSize];
    //adjust the label the the new height.
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    label.frame = newFrame;
    [label updateConstraintsIfNeeded];
    return expectedLabelSize;
}

#pragma mark - 加载数据
-(void)loadCustomFields{
    NSString * templateId = @"1";
    if (self.templateldIdDic != nil && [[self.templateldIdDic allKeys] containsObject:@"templateId"]) {
        templateId = self.templateldIdDic[@"templateId"];
    }
    __weak ZCLeaveEditView *safeView = self;
    NSDictionary *params = @{@"uid":sobotConvertToString([[ZCUICore getUICore] getLibConfig].uid),
                             @"templateld":sobotConvertToString(templateId)
    };
    [ZCLibServer postTemplateFieldInfoWithParams:params result:^(ZCNetWorkCode code, id  _Nullable message, id  _Nonnull object, NSDictionary * _Nonnull dict) {
        if (code == ZC_NETWORK_SUCCESS) {
           
            NSMutableArray *cusFieldArray = (NSMutableArray *)object;
            if (!sobotIsNull(cusFieldArray)) {
                safeView.coustomArr = [NSMutableArray arrayWithCapacity:0];
                safeView.coustomArr = cusFieldArray;
            }
        }
            // 布局子页面
            [safeView refreshViewData];
    } finish:^(id  _Nullable message) {
        
    }];
}

#pragma mark - 刷新数据
-(void)refreshViewData{
    [_listArray removeAllObjects];
    //    NSDictionary *dict = [ZCJSONDataTools getObjectData:_model];
    // 0，特殊行   1 单行文本 2 多行文本 3 日期 4 时间 5 数值 6 下拉列表 7 复选框 8 单选框 9 级联字段
    // propertyType == 1是自定义字段，0固定字段, 3不可点击
    NSMutableArray *arr0 = [[NSMutableArray alloc] init];
    if ( _ticketTitleShowFlag) {
//        NSString * text = SobotKitLocalString(@"请输入标题（必填）");
//        NSString * text = [NSString stringWithFormat:@"%@%@(%@))",SobotKitLocalString(@"请输入"),SobotKitLocalString(@"标题"),SobotKitLocalString(@"必填")];
        NSString *text = SobotKitLocalString(@"请输入");
        NSString * title = [NSString stringWithFormat:@"* %@",SobotKitLocalString(@"标题")];
       
        [arr0 addObject:@{@"code":@"1",
                          @"dictName":@"ticketTitle",
                          @"dictDesc":title,
                          @"placeholder":text,
                          @"dictValue":sobotConvertToString(_model.ticketTitle),
                          @"dictType":@"1",
                          @"propertyType":@"0"
        }];
    }
    if (arr0.count>0) {
        [_listArray addObject:@{@"sectionName":@"",@"arr":arr0}];
    }
    NSMutableArray *arr1 = [[NSMutableArray alloc] init];
    [arr1 addObject:@{@"code":@"2",
                      @"dictName":@"ticketType",
                      @"dictDesc":[NSString stringWithFormat:@"* %@",SobotKitLocalString(@"问题分类")],
                      @"placeholder":@"",
                      @"dictValue":sobotConvertToString(_model.ticketTypeName),
                      @"dictType":@"3",
                      @"propertyType":@"0"
                      }];
    if (_typeArr.count && _tickeTypeFlag == 1) {
       [_listArray addObject:@{@"sectionName":SobotKitLocalString(@"问题分类"),@"arr":arr1}];
    }
    
    NSMutableArray *arr2 = [[NSMutableArray alloc] init];
    if (_coustomArr.count >0) {
        int index = 0;
        for (ZCOrderCusFiledsModel *cusModel in _coustomArr) {
            NSString *propertyType = @"1";
            if ([sobotConvertToString(cusModel.openFlag) intValue] == 0) {
                propertyType = @"3";
                cusModel.fieldType = @"3";
            }
            NSString * titleStr = sobotConvertToString(cusModel.fieldName);
            if([sobotConvertToString(cusModel.fillFlag) intValue] == 1){
                titleStr = [NSString stringWithFormat:@"* %@",titleStr];
            }
            NSString *dataValue = sobotConvertToString(cusModel.fieldValue);
            if ([sobotConvertToString(cusModel.fieldType) intValue] == 9 && sobotConvertToString(dataValue).length >0) {
                dataValue = [dataValue stringByReplacingOccurrencesOfString:@"," withString:@"/"];
            }
            [arr2 addObject:@{@"code":[NSString stringWithFormat:@"%d",index],
                              @"dictName":sobotConvertToString(cusModel.fieldName),
                              @"dictDesc":sobotConvertToString(titleStr),
                              @"placeholder":sobotConvertToString(cusModel.fieldRemark),
                              @"dictValue":dataValue,
                              @"dictType":sobotConvertToString(cusModel.fieldType),
                              @"propertyType":propertyType,
                              @"model":cusModel
                              }];
            index = index + 1;
        }
         [_listArray addObject:@{@"sectionName":SobotKitLocalString(@"自定义字段"),@"arr":arr2}];
    }
    
    //    留言相关 1显示 0不显示
    //    telShowFlag 电话是否显示
    //    telFlag 电话是否必填
    //    enclosureShowFlag 附件是否显示
    //    enclosureFlag 附件是否必填
    //    emailFlag 邮箱是否必填
    //    emailShowFlag 邮箱是否显示
    //    ticketStartWay 工单发起方式 1邮箱，2手机
//    ZCLibConfig *libConfig = [self getCurConfig];
    
    NSString * tmp = @"";
    if (_msgTmp != nil) {
        tmp = _msgTmp;
    }
    // 过滤标签
    tmp = [SobotHtmlCore filterHTMLTag:tmp];
    while ([tmp hasPrefix:@"\n"]) {
        tmp=[tmp substringWithRange:NSMakeRange(1, tmp.length-1)];
    }
    
    if(sobotConvertToString([ZCUICore getUICore].kitInfo.leaveContentPlaceholder).length > 0){
        tmp = SobotKitLocalString(sobotConvertToString([ZCUICore getUICore].kitInfo.leaveContentPlaceholder));
    }
    // 描述和附件在一个控件中
    if (self.ticketContentShowFlag || self.enclosureShowFlag) {
        NSMutableArray *arr3 = [[NSMutableArray alloc] init];
        [arr3 addObject:@{@"code":@"1",
                          @"dictName":@"ticketReplyContent",
//                          @"dictDesc":SobotKitLocalString(@"回复内容"),
                          @"dictDesc":[NSString stringWithFormat:@"* %@",SobotKitLocalString(@"问题描述")],
                          @"placeholder":tmp,//  libConfig.msgTmp
                          @"dictValue":sobotConvertToString(_model.ticketDesc),
                          @"dictType":@"0",
                          @"propertyType":@"0"
                          }];
        [_listArray addObject:@{@"sectionName":SobotKitLocalString(@"回复"),@"arr":arr3}];
    }
    NSMutableArray *arr4 = [[NSMutableArray alloc] init];
    if ( _emailShowFlag) {
//        NSString * text = [NSString stringWithFormat:@"%@",SobotKitLocalString(@"请输入邮箱地址"),SobotKitLocalString(@"选填")];
        NSString * title = SobotKitLocalString(@"邮箱");
        NSString *text = SobotKitLocalString(@"请输入");
        if( _emailFlag){
//            text = [NSString stringWithFormat:@"%@(%@)",SobotKitLocalString(@"请输入邮箱地址"),SobotKitLocalString(@"必填")];
            title = [NSString stringWithFormat:@"* %@",SobotKitLocalString(@"邮箱")];
        }
        [arr4 addObject:@{@"code":@"1",
                          @"dictName":@"ticketEmail",
                          @"dictDesc":title,
                          @"placeholder":text,
                          @"dictValue":sobotConvertToString(_model.email),
                          @"dictType":@"1",
                          @"propertyType":@"0"
                          }];
    }
    
    if ( _telShowFlag) {
//        NSString * text = [NSString stringWithFormat:@"%@(%@)",SobotKitLocalString(@"请输入手机号码"),SobotKitLocalString(@"选填")];
        NSString * title = SobotKitLocalString(@"手机");
        NSString *text = SobotKitLocalString(@"请输入");
        if ( _telFlag) {
//            text = [NSString stringWithFormat:@"%@(%@)",SobotKitLocalString(@"请输入手机号码"),SobotKitLocalString(@"必填")];
            title = [NSString stringWithFormat:@"* %@",SobotKitLocalString(@"手机")];
        }
        [arr4 addObject:@{@"code":@"1",
                          @"dictName":@"ticketTel",
                          @"dictDesc":title,
                          @"placeholder":text,
                          @"dictValue":sobotConvertToString(_model.tel),
                          @"dictType":@"1",
                          @"propertyType":@"0"
                          }];
    }
    if (arr4.count>0) {
        [_listArray addObject:@{@"sectionName":@"",@"arr":arr4}];
    }

    [_listTable reloadData];
}

#pragma mark -- 提交事件
-(IBAction)buttonClick:(UIButton *) sender{
    // 提交
    if(sender.tag == 1001){
        // 标题
        if (_ticketTitleShowFlag) {
            if (sobotTrimString(_model.ticketTitle).length == 0) {
                [[SobotToast shareToast] showToast:[NSString stringWithFormat:@"%@ %@",SobotKitLocalString(@"标题"),SobotKitLocalString(@"不能为空")] duration:1.0f view:self  position:SobotToastPositionCenter];
                return;
            }
            
        }
        
        // 工单类型
        if (_typeArr.count>0 && _tickeTypeFlag == 1) {
            if ([@"" isEqualToString:sobotConvertToString(_model.ticketType)]) {
                [[SobotToast shareToast] showToast:SobotKitLocalString(@"选择分类") duration:1.0f view:self position:SobotToastPositionCenter];
                return;
            }
            
        }
        
        NSMutableArray *cusFields = [NSMutableArray arrayWithCapacity:0];
        // 自定义字段
        for (ZCOrderCusFiledsModel *cusModel in _coustomArr) {
            if([cusModel.fillFlag intValue] == 1 && sobotIsNull(cusModel.fieldValue)){
                [[SobotToast shareToast] showToast:[NSString stringWithFormat:@"%@%@",cusModel.fieldName,SobotKitLocalString(@"不能为空")] duration:1.0f view:self position:SobotToastPositionCenter];
                return;
            }
            
            if(![self checkContentValid:cusModel.fieldSaveValue model:cusModel]){
                [[SobotToast shareToast] showToast:[NSString stringWithFormat:@"%@%@",cusModel.fieldName,SobotKitLocalString(@"格式不正确")] duration:1.0f view:self position:SobotToastPositionCenter];
                return;
            }
            if(!sobotIsNull(cusModel.fieldSaveValue) || sobotConvertToString(cusModel.fieldValue).length > 0){
                if(!sobotIsNull(cusModel.fieldSaveValue)){
                    [cusFields addObject:@{@"id":sobotConvertToString(cusModel.fieldId),
                                           @"text":sobotConvertToString(cusModel.fieldValue),
                                           @"value":sobotConvertToString(cusModel.fieldSaveValue)
                                           }];
                }else{
                    [cusFields addObject:@{@"id":sobotConvertToString(cusModel.fieldId),
                                           @"value":sobotConvertToString(cusModel.fieldValue)
                                           }];
                }
            }
        }
         // 显示邮箱
        if (_emailShowFlag) {
            // 必填
            if (_emailFlag) {
                if (sobotTrimString(_model.email).length>0) {
                     if(!sobotValidateEmail(_model.email)){
                        [[SobotToast shareToast] showToast:SobotKitLocalString(@"请输入正确的邮箱") duration:1.0f view:self position:SobotToastPositionCenter];
                        return;
                     }
                }else{
                    [[SobotToast shareToast] showToast:SobotKitLocalString(@"邮箱不能为空") duration:1.0f view:self position:SobotToastPositionCenter];
                    return;
                }
            }else{
              // 非必填
                if(sobotTrimString(_model.email).length>0){
                    if(!sobotValidateEmail(_model.email)){
                        [[SobotToast shareToast] showToast:SobotKitLocalString(@"请输入正确的邮箱") duration:1.0f view:self position:SobotToastPositionCenter];
                        return;
                    }
                }
            }
        }
        
        // 显示 手机
        if (_telShowFlag && _telFlag &&  sobotTrimString(_model.tel).length==0) {
            // 必填
            [[SobotToast shareToast] showToast:SobotKitLocalString(@"手机号不能为空") duration:1.0f view:self position:SobotToastPositionCenter];
            return;
        }
        // 附件
        if (self.enclosureShowFlag && self.enclosureFlag && _imagePathArr.count<=0) {
            [[SobotToast shareToast] showToast:SobotKitLocalString(@"请上传附件") duration:1.0f view:self position:SobotToastPositionCenter];
            return;
        }
        // 提交留言内容
        if (_model.ticketDesc.length<=0
            && self.ticketContentShowFlag
            && self.ticketContentFillFlag) {
            [[SobotToast shareToast] showToast:SobotKitLocalString(@"请填写问题描述")  duration:1.0f view:self position:SobotToastPositionCenter];
            return;
        }
        // 留言不能大于3000字
        if (_model.ticketDesc.length >3000) {
//            [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"问题描述，最多只能输入3000字符") duration:1.0f view:self.view position:ZCToastPositionCenter];
//            return;
        }
        [self UpLoadWith:cusFields];
        [self allHideKeyBoard];
    }
}

// 提交请求
- (void)UpLoadWith:(NSMutableArray*)arr{
    if(_isSend){
        return;
    }
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:sobotConvertToString(_model.ticketDesc) forKey:@"ticketContent"];
    
    if(_ticketTitleShowFlag){
        [dic setValue:sobotConvertToString(_model.ticketTitle) forKey:@"ticketTitle"];
    }
    
    if(_emailFlag || _emailShowFlag){
        [dic setValue:sobotConvertToString(_model.email) forKey:@"customerEmail"];
        
    }
    if ( _telFlag || _telShowFlag) {
      [dic setValue:sobotConvertToString(_model.tel) forKey:@"customerPhone"];
    }
    if(sobotConvertToString(_model.regionCode).length > 0){
        [dic setValue:sobotConvertToString(_model.regionCode) forKey:@"regionCode"];
    }
    
    if(!sobotIsNull([ZCUICore getUICore].kitInfo.leaveCusFieldArray) && [ZCUICore getUICore].kitInfo.leaveCusFieldArray.count > 0){
        if(arr == nil){
            arr = [[NSMutableArray alloc] init];
        }
        for (NSDictionary *item in [ZCUICore getUICore].kitInfo.leaveCusFieldArray) {
            [arr addObject:item];
        }
        
    }
    // 添加自定义字段
    if (arr.count > 0) {
         [dic setValue:sobotConvertToString([SobotCache dataTOjsonString:arr]) forKey:@"extendFields"];
    }
    
    // 2.8.6新增对接字段，可以设置订单、城市等固定字段
    if(!sobotIsNull([ZCUICore getUICore].kitInfo.leaveParamsExtends) && [ZCUICore getUICore].kitInfo.leaveParamsExtends.count > 0){
        [dic setValue:sobotConvertToString([SobotCache dataTOjsonString:[ZCUICore getUICore].kitInfo.leaveParamsExtends]) forKey:@"paramsExtends"];
    }
    
    // 工单类型
    if ( _tickeTypeFlag == 2 ) {
        [dic setValue:sobotConvertToString(_ticketTypeId) forKey:@"ticketTypeId"];
    }else{
        [dic setValue:sobotConvertToString(_model.ticketType) forKey:@"ticketTypeId"];
    }
    
    if(_imageArr.count>0){
        NSString *fileStr = @"";
        for (int i = 0; i < _imageArr.count; i++) {
            
            NSDictionary *model = _imageArr[i];
            
            NSString *fileUrlStr = sobotConvertToString(model[@"fileUrl"]);
            if (fileUrlStr.length > 0) {
                fileStr = [fileStr stringByAppendingFormat:@"%@;",fileUrlStr];
            }
            
        }
        
        fileStr = [fileStr substringToIndex:fileStr.length-1];
        [dic setObject:sobotConvertToString(fileStr) forKey:@"fileStr"];
    }
    
    // 技能组ID
    [dic setObject:sobotConvertToString([ZCUICore getUICore].kitInfo.leaveMsgGroupId) forKey:@"groupId"];
    
    NSString * templateId = @"1";
    if (self.templateldIdDic != nil && [[self.templateldIdDic allKeys] containsObject:@"templateId"]) {
        templateId = self.templateldIdDic[@"templateId"];
    }
    
    [dic setObject:sobotConvertToString(_ticketFrom).length > 0 ?sobotConvertToString(_ticketFrom):@"4" forKey:@"ticketFrom"];
    [dic setObject:sobotConvertToString(templateId) forKey:@"templateId"];
    
    _isSend = YES;
    __weak ZCLeaveEditView *safeSelf = self;
    [ZCLibServer sendLeaveMessage:dic config:[[ZCUICore getUICore] getLibConfig] start:^(NSString * _Nonnull url, NSDictionary * _Nonnull paramters) {
    
    } resultBlock:^(ZCNetWorkCode code, id  _Nullable obj, NSDictionary * _Nullable dict, NSString * _Nullable jsonString) {
        safeSelf.isSend = NO;
        if (code == ZC_NETWORK_SUCCESS) {
            // 手机号格式错误
            int status = [(NSString *)obj intValue];
            if (status ==0) {
                if (sobotConvertToString(jsonString).length >0) {
                    [[SobotToast shareToast] showToast:sobotConvertToString(jsonString) duration:1.0f view:safeSelf position:SobotToastPositionCenter];
                }
            }else{
                // 如果是弹出的方式保存留言，保存一下存储数据
                if(safeSelf.fromSheetView){
                    safeSelf.uploadMessage = @"";
                    for (NSDictionary *item in safeSelf.listArray) {
                        for (NSDictionary *subItem in item[@"arr"]) {
                            NSString *value = subItem[@"dictValue"];
                            NSString *dictName = subItem[@"dictName"];
                            NSString *dictDesc =  [subItem[@"dictDesc"] stringByReplacingOccurrencesOfString:@"*" withString:@""];
                            if([@"ticketTitle" isEqual:dictName]){
                                value = self->_model.ticketTitle;
                            }
                            if([@"ticketReplyContent" isEqual:dictName]){
                                value = self->_model.ticketDesc;
                            }
                            if([@"ticketType" isEqual:dictName]){
                                value = self->_model.ticketTypeName;
                            }
                            
                            if([@"ticketEmail" isEqual:dictName]){
                                value = self->_model.email;
                            }
                            
                            if([@"ticketTel" isEqual:dictName]){
                                value = self->_model.tel;
                            }
                            if(sobotConvertToString(value).length == 0){
                                value = @"--";
                            }
                            if(safeSelf.uploadMessage.length == 0){
                                safeSelf.uploadMessage = [safeSelf.uploadMessage stringByAppendingFormat:@"%@$:$%@",dictDesc,value];
                            }else{
                                safeSelf.uploadMessage = [safeSelf.uploadMessage stringByAppendingFormat:@"$\n$%@$:$%@",dictDesc,value];
                            }
                            if([@"ticketReplyContent" isEqual:dictName]){
                                for (int i=0;i<self->_imageArr.count;i++) {
                                    NSDictionary *files = self->_imageArr[i];
                                    NSString *fileName = [files[@"fileUrl"] lastPathComponent];
                                    if(i==0){
                                        safeSelf.uploadMessage = [safeSelf.uploadMessage stringByAppendingFormat:@"$\n$%@$:$%@",SobotKitLocalString(@"附件"),fileName];
                                    }else{
                                        safeSelf.uploadMessage = [safeSelf.uploadMessage stringByAppendingFormat:@"\n%@",fileName];
                                    }
                                }
                            }
                        }
                    }
                }
                
                // 提交成功之后，是否直接退出  2.7.0修改 新增提示页面。 清空记录
                self->_model = [[ZCOrderModel alloc] init];
                [safeSelf refreshViewData];
                [self->_imageArr removeAllObjects];
                [self->_imagePathArr removeAllObjects];
                if(self->_pageChangedBlock){
                    self->_pageChangedBlock(safeSelf,1);
                }
                // 添加留言成功TODO
                [self addLeaveMsgSuccessView];
            }
        }else{
           [[SobotToast shareToast] showToast:sobotConvertToString(jsonString) duration:1.0f view:safeSelf position:SobotToastPositionCenter];
        }
    } finish:^(id  _Nonnull response, NSData * _Nonnull data) {
        safeSelf.isSend = NO;
    }];
}

#pragma mark - 留言添加成功后 展示成功页面
-(void)addLeaveMsgSuccessView{
    CGFloat viewWidth = CGRectGetWidth(self.frame);
    if (_successView != nil) {
        _successView.hidden = NO;
        return;
    }
    _successView = [[UIView alloc] initWithFrame:self.bounds];
    _successView.backgroundColor = [ZCUIKitTools zcgetLeaveSuccessViewBgColor];
    [self addSubview:_successView];
    [self addConstraint:sobotLayoutPaddingBottom(0, _successView, self)];
    [self addConstraint:sobotLayoutPaddingTop(0, _successView, self)];
    [self addConstraint:sobotLayoutPaddingLeft(0, _successView, self)];
    [self addConstraint:sobotLayoutPaddingRight(0, _successView, self)];
    _img = [[UIImageView alloc]initWithFrame:CGRectMake(viewWidth/2 - (54/2), 60, 54, 54)];
    if(isLandspace){
        _img.frame = CGRectMake(viewWidth/2 - (54/2), 20, 54, 54);
    }
    _img.layer.cornerRadius = 54/2;
    _img.layer.masksToBounds = YES;
//    _img.image = [[SobotUITools getSysImageByName:@"zcicon_addleavemsgsuccess"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_img setImage:SobotKitGetImage(@"zcicon_addleavemsgsuccess")];
//    _img.tintColor = [ZCUIKitTools zcgetServerConfigBtnBgColor];
    _img.backgroundColor = [ZCUIKitTools zcgetServerConfigBtnBgColor];
    [_successView addSubview:_img];

    
    CGFloat imgT = 150;
    if (isLandspace) {
        imgT = 20;
    }
    self.imgPT = sobotLayoutPaddingTop(imgT, _img, _successView);
    [self.successView addConstraint:self.imgPT];
    [self.successView addConstraint:sobotLayoutEqualWidth(54, _img, NSLayoutRelationEqual)];
    [self.successView addConstraint:sobotLayoutEqualHeight(54, _img, NSLayoutRelationEqual)];
    [self.successView addConstraint:sobotLayoutEqualCenterX(0, _img, _successView)];
    
    _titleLab = [[UILabel alloc]initWithFrame:CGRectMake(16, CGRectGetMaxY(_img.frame)+ (24), viewWidth-32, 32)];
    _titleLab.text = SobotKitLocalString(@"提交成功");
    _titleLab.textAlignment = NSTextAlignmentCenter;
    _titleLab.font = SobotFontBold20;
    _titleLab.textColor = UIColorFromKitModeColor(SobotColorTextMain);
    [_successView addSubview:_titleLab];
    [_successView addConstraint:sobotLayoutMarginTop(24, _titleLab, _img)];
    [_successView addConstraint:sobotLayoutPaddingLeft(16, _titleLab, _successView)];
    [_successView addConstraint:sobotLayoutPaddingRight(-16, _titleLab, _successView)];
    [_successView addConstraint:sobotLayoutEqualHeight(32, _titleLab, NSLayoutRelationEqual)];
        
    CGFloat th = [SobotUITools getHeightContain:SobotKitLocalString(@"工单处理状态更新后将在会话中提醒您") font:SobotFont14 Width:viewWidth-32];
    _tiplab = [[UILabel alloc]initWithFrame:CGRectMake(16, CGRectGetMaxY(_titleLab.frame) + 6, viewWidth - (32), th)];
    _tiplab.textAlignment = NSTextAlignmentCenter;
    _tiplab.font = SobotFont14;
    _tiplab.text = SobotKitLocalString(@"工单处理状态更新后将在会话中提醒您");
    [_tiplab setNumberOfLines:0];
    _tiplab.textColor = UIColorFromKitModeColor(SobotColorTextSub);
    [_successView addSubview:_tiplab];
    [_successView addConstraint:sobotLayoutMarginTop((10), _tiplab, _titleLab)];
    [_successView addConstraint:sobotLayoutPaddingLeft(0, _tiplab, _successView)];
    [_successView addConstraint:sobotLayoutPaddingRight(0, _tiplab,_successView)];
    [_successView addConstraint:sobotLayoutEqualHeight(th, _tiplab, NSLayoutRelationEqual)];
        
    _comBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _comBtn.frame = CGRectMake(16, CGRectGetMaxY(_tiplab.frame) + 40, viewWidth - 32, 40) ;
    if(isLandspace){
        _comBtn.frame = CGRectMake(16, CGRectGetMaxY(_tiplab.frame) + (10), viewWidth - 32, 40) ;
    }
    [_comBtn setTitle:SobotKitLocalString(@"完成") forState:UIControlStateNormal];
    [_comBtn setTitle:SobotKitLocalString(@"完成") forState:UIControlStateSelected];
    UIImage * colorimg = [self createImageWithColor:[ZCUIKitTools zcgetLeaveSubmitImgColor]];
    [_comBtn setBackgroundImage:colorimg forState:UIControlStateNormal];
    [_comBtn setBackgroundImage:colorimg forState:UIControlStateSelected];
    [_comBtn addTarget:self action:@selector(completionBackAction:) forControlEvents:UIControlEventTouchUpInside];
    _comBtn.tag = 3001;
    _comBtn.layer.masksToBounds = YES;
    _comBtn.layer.cornerRadius = 4.0f;
    _comBtn.titleLabel.font = SobotFont16;
    [_successView addSubview:_comBtn];
    CGFloat comBtnT = 40;
    if (isLandspace) {
        comBtnT = 10;
    }
    self.comBtnMT = sobotLayoutMarginTop(comBtnT, _comBtn, _tiplab);
    [_successView addConstraint:self.comBtnMT];
    [_successView addConstraint:sobotLayoutPaddingLeft(16, _comBtn, _successView)];
    [_successView addConstraint:sobotLayoutPaddingRight(-16, _comBtn, _successView)];
    [_successView addConstraint:sobotLayoutEqualHeight(40, _comBtn, NSLayoutRelationEqual)];
    
    _recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _recordBtn.frame = CGRectMake((16), CGRectGetMaxY(_comBtn.frame) + (16), viewWidth - 32,22);
    [_recordBtn setTitle:SobotKitLocalString(@"前往留言记录") forState:UIControlStateNormal];
    [_recordBtn setTitleColor:[ZCUIKitTools zcgetLeaveSubmitImgColor] forState:UIControlStateNormal];
    _recordBtn.tag = 3002;
    [_recordBtn addTarget:self action:@selector(completionBackAction:) forControlEvents:UIControlEventTouchUpInside];
    _recordBtn.titleLabel.font = SobotFont14;
    [_successView addSubview:_recordBtn];
    [_successView addConstraint:sobotLayoutMarginTop(16, _recordBtn, _comBtn)];
    [_successView addConstraint:sobotLayoutEqualHeight(22, _recordBtn, NSLayoutRelationEqual)];
    [_successView addConstraint:sobotLayoutPaddingLeft(16, _recordBtn, _successView)];
    [_successView addConstraint:sobotLayoutPaddingRight(-16, _recordBtn, _successView)];
}

-(void)removeAddLeaveMsgSuccessView{
    if (_successView && _successView!=nil) {
        [_successView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_successView removeFromSuperview];
        _successView = nil;
    }
}

#pragma mark -- 留言创建成功弹层
-(void)completionBackAction:(UIButton *) button{
    if(_pageChangedBlock){
        _pageChangedBlock(self,(int)button.tag);
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    if (self.successView != nil) {
        [self.successView removeConstraint:self.imgPT];
        [self.successView removeConstraint:self.comBtnMT];
        CGFloat imgT = 150;
        if (isLandspace) {
            imgT = (20);
        }
        self.imgPT = sobotLayoutPaddingTop(imgT, _img, _successView);
        [self.successView addConstraint:self.imgPT];
        
        CGFloat comBtnT = 40;
        if (isLandspace) {
            comBtnT = 10;
        }
        self.comBtnMT = sobotLayoutMarginTop(comBtnT, _comBtn, _tiplab);
        [self.successView addConstraint:self.comBtnMT];
    }
    self.commitBtnEW.constant = self.frame.size.width -40;
}

#pragma mark - 验证添加数据是否符合校验
-(BOOL)checkContentValid:(NSString *) text model:(ZCOrderCusFiledsModel *) model{
    if(model != nil && sobotConvertToString(text).length >0){
        NSArray *limitOptions = nil;
        if([model.limitOptions isKindOfClass:[NSString class]]){
            NSString *limitOption =  sobotConvertToString(model.limitOptions);
            limitOption = [limitOption stringByReplacingOccurrencesOfString:@"[" withString:@""];
            limitOption = [limitOption stringByReplacingOccurrencesOfString:@"]" withString:@""];
            limitOptions = [limitOption componentsSeparatedByString:@","];
        }else if([model.limitOptions isKindOfClass:[NSArray class]]){
            limitOptions = model.limitOptions;
        }
        
        if(limitOptions==nil || limitOptions.count == 0){
            if([model.fieldType intValue]== 5){
                return sobotValidateFloat(text);
            }
            return YES;
        }
        
        //限制方式  1禁止输入空格   2 禁止输入小数点  3 小数点后只允许2位  4 禁止输入特殊字符  5只允许输入数字 6最多允许输入字符  7判断邮箱格式  8判断手机格式
        if([limitOptions containsObject:[NSNumber numberWithInt:1]] || [limitOptions containsObject:@"1"]){
            NSRange _range = [text rangeOfString:@" "];
            if(_range.location!=NSNotFound) {
                return NO;
            }
        }
        if([limitOptions containsObject:[NSNumber numberWithInt:2]] || [limitOptions containsObject:@"2"]){
             NSRange _range = [text rangeOfString:@"."];
            if(_range.location!=NSNotFound) {
                return NO;
            }
        }
        if([limitOptions containsObject:[NSNumber numberWithInt:3]] || [limitOptions containsObject:@"3"]){
             return sobotValidateFloatWithNum(text,2);
        }
        if([limitOptions containsObject:[NSNumber numberWithInt:4]] || [limitOptions containsObject:@"4"]){
             return sobotValidateRuleNotBlank(text);
        }
        
        if([limitOptions containsObject:[NSNumber numberWithInt:5]] || [limitOptions containsObject:@"5"]){
             return sobotValidateNumber(text);
        }
        
        if([limitOptions containsObject:[NSNumber numberWithInt:6]] || [limitOptions containsObject:@"6"]){
            if(sobotConvertToString(text).length > [model.limitChar intValue]){
                return NO;
            }
        }
        
        if([limitOptions containsObject:[NSNumber numberWithInt:7]] || [limitOptions containsObject:@"7"]){
            return sobotValidateEmail(text);
        }
        
        if([limitOptions containsObject:[NSNumber numberWithInt:8]] || [limitOptions containsObject:@"8"]){
            return sobotValidateMobileWithRegex(text, [ZCUIKitTools zcgetTelRegular]);
        }
        
    }
    return YES;
}

#pragma mark - 回收键盘
-(void)tapHideKeyboard{
    if(!sobotIsNull(_tempTextView)){
        [_tempTextView resignFirstResponder];
        _tempTextView = nil;
    }else if(!sobotIsNull(_tempTextField)){
        [_tempTextField resignFirstResponder];
        _tempTextField  = nil;
    }else{
        [self allHideKeyBoard];
    }
    if (_listTable.contentSize.height <( ScreenHeight - NavBarHeight)) {
        [_listTable setContentOffset:CGPointMake(0, 0)];
    }
}

- (void)hideKeyboard {
    if(xh){
        [xh dismissWithAnimate];
        xh = nil;
    }
    if(!sobotIsNull(_tempTextView)){
        [_tempTextView resignFirstResponder];
        _tempTextView = nil;
    }else if(!sobotIsNull(_tempTextField)){
        [_tempTextField resignFirstResponder];
        _tempTextField  = nil;
    }else{
        [self allHideKeyBoard];
    }
    if(contentoffset.x != 0 || contentoffset.y != 0){
        // 隐藏键盘，还原偏移量
        [_listTable setContentOffset:contentoffset];
    }
}

- (void)allHideKeyBoard
{
    [self endEditing:true];
}

-(BOOL) dismissAllKeyBoardInView:(UIView *)view
{
    if([view isFirstResponder])
    {
        [view resignFirstResponder];
        return YES;
    }
    for(UIView *subView in view.subviews)
    {
        if([self dismissAllKeyBoardInView:subView])
        {
            return YES;
        }
    }
    return NO;
}

#pragma mark - 颜色转图片
- (UIImage*)createImageWithColor:(UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

#pragma mark -- 销毁页面
-(void)destoryViews{
    [self hideKeyboard];
    [_coustomArr removeAllObjects];
    _coustomArr = nil;
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _exController = nil;
    [self removeFromSuperview];
}

#pragma mark -- 键盘滑动的高度
-(void)didKeyboardWillShow:(NSIndexPath *)indexPath view1:(UITextView *)textview view2:(UITextField *)textField{
    _tempTextView = textview;
    _tempTextField = textField;
    //获取当前cell在tableview中的位置
    CGRect rectintableview = [_listTable rectForRowAtIndexPath:indexPath];
    //获取当前cell在屏幕中的位置
    CGRect rectinsuperview = [_listTable convertRect:rectintableview fromView:[_listTable superview]];
    contentoffset = _listTable.contentOffset;
    if ((rectinsuperview.origin.y+50 - _listTable.contentOffset.y)>200) {
        if(!isLandspace){
            [_listTable setContentOffset:CGPointMake(_listTable.contentOffset.x,((rectintableview.origin.y-_listTable.contentOffset.y)-150)+  _listTable.contentOffset.y) animated:YES];
            contentoffset = CGPointMake(_listTable.contentOffset.x,((rectintableview.origin.y-_listTable.contentOffset.y)-150)+  _listTable.contentOffset.y);
        }
    }
}

#pragma mark - 手势冲突的代理
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIButton class]]){
        return NO;
    }
    return YES;
}


#pragma mark create Views
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"销毁编辑留言");
}


+(void)setDisplayAttributedString:(NSMutableAttributedString *) attr label:(UILabel *)label color:(UIColor*)tColor {
    UIColor *textColor = UIColorFromKitModeColor(SobotColorTextSub);
//    if (!sobotIsNull(tColor)) {
        textColor = tColor;
//    }
  
    UIColor *linkColor = [ZCUIKitTools zcgetRightChatColor];
    NSMutableAttributedString* attributedString = [attr mutableCopy];
    [attributedString beginEditing];
    [attributedString enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0,attributedString.length) options:0 usingBlock:^(id value,NSRange range,BOOL *stop) {
        UIFont *font = value;
        // 替换固定默认文字大小
        if(font.pointSize == 15){
//            NSLog(@"----替换了字体");
            [attributedString removeAttribute:NSFontAttributeName range:range];
            [attributedString addAttribute:NSFontAttributeName value:label.font range:range];
        }
    }];
    [attributedString enumerateAttribute:NSForegroundColorAttributeName inRange:NSMakeRange(0,attributedString.length) options:0 usingBlock:^(id value,NSRange range,BOOL *stop) {
        UIColor *color = value;
        NSString *hexColor = [ZCUIKitTools getHexStringByColor:color];
//                                NSLog(@"***\n%@",hexColor);
        // 替换固定整体文字颜色
        if([@"ff0001" isEqual:hexColor]){
            [attributedString removeAttribute:NSForegroundColorAttributeName range:range];
            [attributedString addAttribute:NSForegroundColorAttributeName value:textColor range:range];
        }
        // 替换固定连接颜色
        if([@"ff0002" isEqual:hexColor]){
            [attributedString removeAttribute:NSForegroundColorAttributeName range:range];
            [attributedString addAttribute:NSForegroundColorAttributeName value:linkColor range:range];
        }
    }];
    
    //Hack for italic/skew effect to custom fonts
    __block NSMutableDictionary *rangeIDict = [[NSMutableDictionary alloc] init];
    [attributedString enumerateAttribute:NSParagraphStyleAttributeName inRange:NSMakeRange(0,attributedString.length) options:0 usingBlock:^(id value,NSRange range,BOOL *stop) {
         if (value) {
             NSMutableParagraphStyle *myStyle = (NSMutableParagraphStyle *)value;
             if (myStyle.minimumLineHeight == 101) {
                 // 保存加粗的标签位置，如果相同位置有斜体，需要设置为斜体加粗
                 [rangeIDict setObject:@"YES" forKey:NSStringFromRange(range)];
                 [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:label.font.pointSize weight:UIFontWeightBold] range:range];
             }
         }
     }];
    
    [attributedString enumerateAttribute:NSParagraphStyleAttributeName inRange:NSMakeRange(0,attributedString.length) options:0 usingBlock:^(id value,NSRange range,BOOL *stop) {
         if (value) {
             NSMutableParagraphStyle *myStyle = (NSMutableParagraphStyle *)value;
             if (myStyle.minimumLineHeight == 99) {
                 UIFont *textFont = label.font;
                 CGAffineTransform matrix =  CGAffineTransformMake(1, 0, tanf(10 * (CGFloat)M_PI / 180), 1, 0, 0);
                 UIFont *font = [UIFont systemFontOfSize:textFont.pointSize];
                 // 相同的位置，有加粗
                 if ([@"YES" isEqual:[rangeIDict objectForKey:NSStringFromRange(range)]]) {
                    font = [UIFont boldSystemFontOfSize:textFont.pointSize];
                 }
                 
                 // 解决 CoreText note: Client requested name ".SFUI-Regular" warning
                 NSString *fontName = font.fontName;
                 if([fontName hasSuffix:@"SFUI-Regular"]){
                     fontName = @"TimesNewRomanPSMT";
                 }
                 UIFontDescriptor *desc = [UIFontDescriptor fontDescriptorWithName:fontName matrix:matrix];
                 [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithDescriptor:desc size:textFont.pointSize] range:range];
             }
         }
     }];
    
    // 文本段落排版格式
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle alloc] init];
    textStyle.lineBreakMode = NSLineBreakByWordWrapping; // 结尾部分的内容以……方式省略
    textStyle.lineSpacing = [ZCUIKitTools zcgetChatLineSpacing]; // 调整行间距
    NSMutableDictionary *textAttributes = [[NSMutableDictionary alloc] init];
    // NSParagraphStyleAttributeName 文本段落排版格式
    [textAttributes setValue:textStyle forKey:NSParagraphStyleAttributeName];
    // 设置段落样式
    [attributedString addAttributes:textAttributes range:NSMakeRange(0, attributedString.length)];
    [attributedString endEditing];
    label.text = [attributedString copy];
}
@end
