//
//  ZCChatDetailView.m
//  SobotKit
//
//  Created by lizh on 2023/11/17.
//

#import "ZCChatDetailView.h"

#import "ZCChatDetailViewCell.h"

@interface ZCChatDetailView()<UIGestureRecognizerDelegate,ZCChatDetailViewCellDelegate,UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong) SobotTableView *listTable;

@property (nonatomic,strong)NSLayoutConstraint *listViewEH;
@property (nonatomic,strong)NSLayoutConstraint *listViewEW;
@property (nonatomic,strong)NSLayoutConstraint *listViewPR;
@property (nonatomic,strong)NSLayoutConstraint *listViewPT;
@property (nonatomic,strong) SobotChatMessage *model;
@property(nonatomic,strong)NSMutableArray *listArray;
@property (nonatomic,strong) UIView *contentView;
@property (nonatomic,strong)NSLayoutConstraint *contentEW;
@end

@implementation ZCChatDetailView

-(ZCChatDetailView *)initChatDetailViewWithModel:(SobotChatMessage *)model withView:(UIView *)view{
    self = [super init];
    if (self) {
//        self.frame = CGRectMake(0, 0, 0, 0);
        
        self.backgroundColor = UIColorFromModeColor(SobotColorBgMain); //UIColorFromModeColor(SobotColorBlack, 0.6);
        self.userInteractionEnabled = YES;

        UIWindow *window = [SobotUITools getCurWindow];
        [window addSubview:self];
        
        [window addConstraint:sobotLayoutPaddingTop(0, self, window)];
        [window addConstraint:sobotLayoutPaddingLeft(0, self, window)];
        [window addConstraint:sobotLayoutPaddingRight(0, self, window)];
        [window addConstraint:sobotLayoutPaddingBottom(0, self, window)];
        
        [self createTableView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeSheetView)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        self.listArray = [NSMutableArray array];
        [self.listArray addObject:model];
        self.model = model;
        [self.listTable reloadData];
    }
    return self;
}

-(void)createTableView{
    
    _contentView = ({
        UIView *iv = [[UIView alloc]init];
        [self addSubview:iv];
        iv.backgroundColor = UIColor.clearColor;
        [self addConstraint:sobotLayoutPaddingTop(0, iv, self)];
        [self addConstraint:sobotLayoutPaddingLeft(0, iv, self)];
        self.contentEW = sobotLayoutEqualWidth(ScreenWidth, iv, NSLayoutRelationEqual);
        [self addConstraint:self.contentEW];
        [self addConstraint:sobotLayoutPaddingBottom(0, iv, self)];
        iv;
    });
      
    _listTable = (SobotTableView *)[SobotUITools createTableWithView:self delegate:self];
    [self.contentView addSubview:_listTable];
    // 注册cell
    [_listTable registerClass:[ZCChatDetailViewCell class] forCellReuseIdentifier:@"ZCChatDetailViewCell"];
    _listTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    _listTable.rowHeight = UITableViewAutomaticDimension;


    self.listViewEH = sobotLayoutEqualHeight(100, self.listTable, NSLayoutRelationEqual);
    _listTable.backgroundColor = UIColor.redColor;
    [self.contentView addConstraint:self.listViewEH];
    self.listViewPT = sobotLayoutPaddingTop(NavBarHeight, self.listTable, self.contentView);
    [self.contentView addConstraint:self.listViewPT];
    [self.contentView addConstraint:sobotLayoutPaddingLeft(0, self.listTable, self.contentView)];
    [self.contentView addConstraint:sobotLayoutPaddingRight(0, self.listTable, self.contentView)];
    
    if (iOS7) {
        _listTable.backgroundView = nil;
    }
    [_listTable setSeparatorColor:SobotColorFromRGB(0xdadada)];
}


#pragma mark UITableView delegate Start
// 返回section数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

// 返回section下得行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_listArray==nil && _listArray.count == 0){
        return 0;
    }
    return _listArray.count;
}


// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZCChatDetailViewCell *cell = (ZCChatDetailViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ZCChatDetailViewCell"];
    if (cell == nil) {
        cell = [[ZCChatDetailViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCChatDetailViewCell"];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
//    if(_listArray.count < indexPath.row){
//        return cell;
//    }
    cell.delegate = self;
    [cell initWithDataModel:_model];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark UITableView delegate end

#pragma mark cell的代理事件
-(void)btnClickType:(ZCChatCellClickType)type dict:(NSDictionary *)dict obj:(id)obj{
    
}

-(void)updateContentHeight:(CGFloat)height{
    self.listViewEH.constant = height;
    NSLog(@"获取到展示内容的高度");
    [self updateHeightWith:height];
}

-(void)updateLoadData{
    [self.listTable reloadData];
}

#pragma mark -- 添加显示
- (void)showInView:(UIView *)view{
    [self hideKeyBoard];
//    [[SobotUITools getCurWindow] addSubview:self];
    // 计算最终高度 重新布局约束
//    [self.listTable reloadData];
}

#pragma mark -- 获取到最终的高度
-(CGFloat)updateHeightWith:(CGFloat)height{
    if( height >=ScreenHeight-NavBarHeight){
        height = ScreenHeight-NavBarHeight;
        self.listViewEH.constant = height;
        self.listViewPT.constant = NavBarHeight;
        self.listTable.scrollEnabled = YES;
    }else{
        self.listTable.scrollEnabled = NO;
        self.listViewEH.constant = height;
        self.listViewPT.constant =  ScreenHeight/2 - height/2;
    }
    return 0;
}

#pragma mark -- 横竖屏切换
- (void)updateChangeFrame:(CGFloat)y{
    self.contentEW.constant = ScreenWidth;
    CGFloat height = self.listViewEH.constant;
    [self updateHeightWith:height];
}

#pragma mark -- 关闭页面
- (void)closeSheetView{
    [self removeFromSuperview];
}

-(void)closeDetailView{
    [self closeSheetView];
}

- (void)hideKeyBoard
{
    for (UIWindow* window in [UIApplication sharedApplication].windows)
    {
        for (UIView* view in window.subviews)
        {
            [self dismissAllKeyBoardInView:view];
        }
    }
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

@end
