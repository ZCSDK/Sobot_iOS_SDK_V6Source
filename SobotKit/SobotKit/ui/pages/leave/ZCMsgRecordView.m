//
//  ZCMsgRecordView.m
//  SobotKit
//
//  Created by lizh on 2022/9/7.
//

#import "ZCMsgRecordView.h"
#import "ZCUIKitTools.h"
#import "ZCMsgRecordCell.h"
#define cellIdentifier @"ZCMsgRecordCell"
@interface ZCMsgRecordView ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) UITableView * listView;
@property (nonatomic,strong) NSMutableArray * listArray;
//当页面的list数据为空时，给它一个带提示的占位图。
@property(nonatomic,strong) UIView *placeholderView;


@property (nonatomic,strong)NSLayoutConstraint *listR;
@property (nonatomic,strong)NSLayoutConstraint *listB;
@property (nonatomic,strong)NSLayoutConstraint *listY;
@property (nonatomic,strong)NSLayoutConstraint *listL;


@end

@implementation ZCMsgRecordView

-(id)initWithFrame:(CGRect)frame withController:(UIViewController *) vc{
    self = [super initWithFrame:frame];
    if(self){
        _listArray = [NSMutableArray arrayWithCapacity:0];
//        self.backgroundColor = [ZCUIKitTools zcgetChatBackgroundColor];
        //UIColorFromRGB(0xF9FAFB);
        self.backgroundColor = [UIColor clearColor];
        [self createListView];
    }
    return self;
}


//- (void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    [self loadData];
//}

-(void)createListView{
    _listView = (SobotTableView *)[SobotUITools createTableWithView:self delegate:self];
    [self addSubview:_listView];
    [_listView registerClass:[ZCMsgRecordCell class] forCellReuseIdentifier:cellIdentifier];
    _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //可以省略不设置
    _listView.rowHeight = UITableViewAutomaticDimension;
    self.listB = sobotLayoutPaddingBottom(0, self.listView, self);
    self.listL = sobotLayoutPaddingLeft(0, self.listView, self);
    self.listR = sobotLayoutPaddingRight(0, self.listView, self);
    self.listY = sobotLayoutPaddingTop(0, self.listView, self);
    [self addConstraint:self.listY];
    [self addConstraint:self.listB];
    [self addConstraint:self.listL];
    [self addConstraint:self.listR];
//    _listView.backgroundColor = [UIColor clearColor];
    _listView.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
//    if (!Sobot_iPhoneX) {
//        // 添加底部区尾
//        UIView * bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, NavBarHeight)];
//        bgView.backgroundColor = UIColor.clearColor;
//        _listView.tableFooterView = bgView;
//    }
    // 加载数据
    [self getOrerStatusList];
    [self loadData];
}

-(ZCLibConfig *)getCurConfig{
    return [[ZCPlatformTools sharedInstance] getPlatformInfo].config;
}

-(void)getOrerStatusList{
    [ZCLibServer getOrderStatusList:[self getCurConfig] start:^(NSString * _Nonnull urlString) {
        
    } success:^(NSDictionary * _Nonnull dict, ZCNetWorkCode sendCode) {
        
    } failed:^(NSString * _Nonnull errorMessage, ZCNetWorkCode errorCode) {
        
    } finish:^(NSString * _Nonnull jsonString) {
        
    }];
}


-(void)loadData{
    __weak ZCMsgRecordView *weakSelf = self;
    [ZCLibServer postUserTicketInfoListWithConfig:[self getCurConfig] start:^(NSString * _Nonnull url, NSDictionary * _Nonnull params) {
        
    } success:^(NSDictionary * _Nonnull dict, NSMutableArray * _Nonnull itemArray, ZCNetWorkCode sendCode) {
        @try{
            if (dict && itemArray.count >0) {
                [weakSelf removePlaceholderView];
                [weakSelf.listArray removeAllObjects];
                weakSelf.listArray = itemArray;
                [weakSelf.listView reloadData];
                if (itemArray.count == 0) {
                    [weakSelf createPlaceholderView:SobotKitLocalString(@"暂无相关信息") message:@"" image:nil withView:self.listView action:nil];
                }
            }else{
                [weakSelf createPlaceholderView:SobotKitLocalString(@"暂无相关信息") message:@"" image:nil withView:self.listView action:nil];
            }
            
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    } failed:^(NSString * _Nonnull errorMessage, ZCNetWorkCode errorCode) {
        [weakSelf createPlaceholderView:SobotKitLocalString(@"暂无相关信息") message:@"" image:nil withView:self.listView action:nil];
    }];
}

// 返回section数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

// 返回section下得行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _listArray.count;
}

// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZCMsgRecordCell * cell = (ZCMsgRecordCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[ZCMsgRecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if ( indexPath.row > _listArray.count -1) {
        return cell;
    }
    ZCRecordListModel * model = _listArray[indexPath.row];
    [cell initWithDict:model with:self.listView.frame.size.width index:indexPath.row];
    // 去掉选中时的背景色
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

// table 行的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZCRecordListModel * model = _listArray[indexPath.row];
    [_listArray enumerateObjectsUsingBlock:^( ZCRecordListModel * item, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([item.ticketCode isEqual:model.ticketCode]) {
            model.newFlag = 1;
            *stop = YES;
        }
    }];
    [self.listView reloadData];
    if (self.jumpMsgDetailBlock) {
        self.jumpMsgDetailBlock(model);
    }
}

#pragma mark -- 刷新数据
-(void)updataWithHeight:(CGFloat)height viewWidth:(CGFloat)w{
    CGRect lf = self.listView.frame;
    lf.size.height = height;
    CGRect selfF = self.frame;
    selfF.size.width = w;
    selfF.size.height = height;
    self.frame = selfF;
    self.listView.frame = lf;
    [self.listView reloadData];
}

#pragma mark -- 处理占位 空态
- (void)createPlaceholderView:(NSString *)title message:(NSString *)message image:(UIImage *)image withView:(UIView *)superView action:(void (^)(UIButton *button)) clickblock{
    if (_placeholderView) {
        [_placeholderView removeFromSuperview];
        _placeholderView = nil;
    }
    if(superView==nil){
        superView=self;
    }
    _placeholderView = [[UIView alloc]initWithFrame:superView.frame];
    [_placeholderView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
    [_placeholderView setAutoresizesSubviews:YES];
    [_placeholderView setBackgroundColor:[UIColor clearColor]];
    [superView addSubview:_placeholderView];
    CGRect pf = CGRectMake(0, 0, superView.bounds.size.width, 0);
    UIImageView *icon = [[UIImageView alloc]initWithImage: [SobotUITools getSysImageByName:@"robot_default"]];
    if(image){
        [icon setImage:image];
    }
    [icon setContentMode:UIViewContentModeCenter];
    [icon setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    icon.frame = CGRectMake(0,0, pf.size.width, image.size.height);
    [_placeholderView addSubview:icon];
    
    CGFloat y= icon.frame.size.height+20;
    if(title){
        CGFloat height=[self getHeightContain:title font:SobotFont14 Width:pf.size.width];
        
        UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(0, y, pf.size.width, height)];
        [lblTitle setText:title];
        [lblTitle setFont:SobotFont14];
        [lblTitle setTextColor:[ZCUIKitTools zcgetTextPlaceHolderColor]];
        [lblTitle setTextAlignment:NSTextAlignmentCenter];
        [lblTitle setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [lblTitle setNumberOfLines:0];
        [lblTitle setBackgroundColor:[UIColor clearColor]];
        [_placeholderView addSubview:lblTitle];
        y=y+height+5;
    }
    
    if(message){
        UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(0, y, pf.size.width, 20)];
        [lblTitle setText:message];
        [lblTitle setFont:SobotFont12];
        [lblTitle setTextAlignment:NSTextAlignmentCenter];
        [lblTitle setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [lblTitle setAutoresizesSubviews:YES];
        [lblTitle setBackgroundColor:[UIColor clearColor]];
        [_placeholderView addSubview:lblTitle];
        y=y+25;
    }
    
    pf.size.height= y;
    
    [_placeholderView setFrame:pf];
    [_placeholderView setCenter:CGPointMake(superView.center.x, superView.bounds.size.height/2-80)];
}


- (void)removePlaceholderView{
    if (_placeholderView && _placeholderView!=nil) {
        [_placeholderView removeFromSuperview];
        _placeholderView = nil;
    }
}

-(CGFloat)getHeightContain:(NSString *)string font:(UIFont *)font Width:(CGFloat) width
{
    if(string==nil){
        return 0;
    }
    //转化为格式字符串
    NSAttributedString *astr = [[NSAttributedString alloc]initWithString:string attributes:@{NSFontAttributeName:font}];
    CGSize contansize=CGSizeMake(width, CGFLOAT_MAX);
    if(iOS7){
        CGRect rec = [astr boundingRectWithSize:contansize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
        return rec.size.height;
    }else{
        CGSize s=[string sizeWithFont:font constrainedToSize:contansize lineBreakMode:NSLineBreakByCharWrapping];
        return s.height;
    }
}
@end
