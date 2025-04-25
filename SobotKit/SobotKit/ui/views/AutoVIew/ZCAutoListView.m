//
//  ZCAutoListView.m
//  SobotKit
//
//  Created by zhangxy on 2018/1/22.
//  Copyright © 2018年 zhichi. All rights reserved.
//

#import "ZCAutoListView.h"
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClient.h>
#import "ZCUIKitTools.h"
#import "ZCUICore.h"
#import "ZCAutoListCell.h"
#define LineHeight 36

@interface ZCAutoListView()<UITableViewDelegate,UITableViewDataSource>{
    BOOL isLoading;
    int timeSpace;
    NSDate *startDate;
}

@property(nonatomic,strong) NSMutableArray *listArray;
@property(nonatomic,strong) NSMutableDictionary *dict;
@property (nonatomic,strong) UITableView * listTable;
@property (nonatomic,strong) NSString * searchText;
@property(nonatomic,copy) void(^BackCellClick)(NSString * text) ;
@end

@implementation ZCAutoListView

+(ZCAutoListView *) getAutoListView{
    static ZCAutoListView *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(_instance == nil){
            _instance = [[ZCAutoListView alloc] initPrivate];
        }
    });
    return _instance;
}

-(void)setCellClick:(void (^)(NSString *))CellClick{
//    if(_BackCellClick==nil){
//        _BackCellClick = CellClick;
//    }
}
- (void)addTopShadowToView:(UIView *)view {
    // 启用阴影
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = UIColorFromKitModeColorAlpha(SobotColorBlack, 0.06).CGColor; // 阴影颜色
    view.layer.shadowOpacity = 1; // 阴影透明度
    view.layer.shadowOffset = CGSizeMake(0, -2); // 阴影偏移量，x为0，y为负值表示向上阴影
    view.layer.shadowRadius = 2.0; // 阴影模糊半径
    
    // 可选：设置圆角
//    view.layer.cornerRadius = 10.0;
//    
//    // 可选：添加底部边框以增强视觉效果
//    view.layer.borderWidth = 0.5;
//    view.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

-(id)initPrivate{
    self = [super initWithFrame:CGRectMake(0, 0, 0, 0)];
    if(self){
        _dict = [[NSMutableDictionary alloc] init];
        _listArray = [[NSMutableArray alloc] init];
        _listTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 8, ScreenWidth, 0) style:UITableViewStylePlain];
        _listTable.dataSource = self;
        _listTable.delegate = self;
        _listTable.bounces = NO;
        [_listTable setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark1)];
        [_listTable setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [_listTable setSeparatorColor:UIColorFromModeColor(SobotColorBgLine)];
        [_listTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_listTable registerClass:[ZCAutoListCell class] forCellReuseIdentifier:@"ZCAutoListCell"];
        if(iOS7){
            [_listTable setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        }
        UIView *view =[ [UIView alloc]init];
        view.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
        [_listTable setTableFooterView:view];
        [self addSubview:_listTable];
        _listArray  = [[NSMutableArray alloc] init];
        [self addTopShadowToView:_listTable];
    }
    return self;
}

-(id)init{
    return [self initPrivate];
}



-(void)showWithText:(NSString *) searchText view:(UIView *) bottomView{
    if(sobotConvertToString(searchText).length == 0){
        [self dissmiss];
        return;
    }
    // 先动态的修改一遍数据 实时变化
    if(bottomView == nil){
        [self dissmiss];
        return;
    }
    if(startDate == nil){
        startDate = [NSDate date];
    }else{
        NSDate *currtDate = [NSDate date];
        NSTimeInterval distanceBetweenDates = [currtDate timeIntervalSinceDate:startDate];
//        CGFloat hours = distanceBetweenDates / 3600;
        // 小于1秒不执行
        if (distanceBetweenDates<1) {
//            startDate = [NSDate date];
            return;
        }
        startDate = [NSDate date];
    }
    _searchText = searchText;
    _bottomView = bottomView;
//    SLog(@"当前输入要搜索的内容文案 ========== sssssssssssssssssssssss %@  %@", _searchText,searchText);
    NSMutableArray *arr  = [[_dict objectForKey:searchText] mutableCopy];
    if(!sobotIsNull(arr)&& arr.count>0){
        if (_listArray.count>0) {
            [_listArray removeAllObjects];
        }
        _listArray = arr;
        [self setlistTableFrameWith];
    }else{
        if(isLoading){
            return;
        }
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:0];
        [dict setValue:sobotConvertToString(searchText) forKey:@"question"];
        [dict setObject:[NSString stringWithFormat:@"%d",[self getZCLibConfig].robotFlag] forKey:@"robotFlag"];
        [ZCLibServer getrobotGuess:[self getZCLibConfig] Parms:dict start:^(SobotChatMessage *message) {
            self->isLoading = YES;
        } success:^(NSDictionary *dict, ZCMessageSendCode sendCode) {
            self->isLoading = NO;
            // 本地缓存 收索数据
            if(self->_dict.count > 10){
                [self->_dict removeAllObjects];
            }
            if ([dict[@"code"] intValue] == 1) {
                NSArray * arr = @[];
                if([self getZCLibConfig].aiAgent){
                    arr = dict[@"data"];
                }else{
                    arr = dict[@"data"][@"respInfoList"];
                }
                if (!sobotIsNull(arr) && arr.count>0) {
                    if (self->_listArray.count>0) {
                        [self->_listArray removeAllObjects];
                    }
                    for(NSDictionary *item in arr){
                        NSString *highlight = sobotConvertToString(item[@"highlight"]);
                        if(highlight.length == 0){
                            continue;
                        }
                        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithData:[highlight  dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
                        [attrStr addAttribute:NSFontAttributeName value:SobotFont14 range:NSMakeRange(0, attrStr.length)];
                        [attrStr enumerateAttributesInRange:NSMakeRange(0, attrStr.length) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
                            if ([attrs objectForKey:@"NSColor"]) {
                                id markColor = [attrs valueForKey:@"NSColor"];
                                if ([self getRedFor:markColor] == 0 && [self getGreenFor:markColor] == 0 && [self getBlueFor:markColor] == 0) {
                                    [attrStr addAttribute:NSForegroundColorAttributeName
                                                   value:UIColorFromModeColor(SobotColorTextMain)
                                                   range:range];
                                }
                            }
                        }];
                        
                        [self->_listArray addObject:@{@"attr":attrStr,@"item":item}];
                    }
//                    if (self.isAllowShow) {
                        [self->_dict setObject:self->_listArray forKey:searchText];
                        [self setlistTableFrameWith];
//                    }
                  
                }else{
                   [self dissmiss];
                    return ;
                }
            }
        } fail:^(NSString *errorMsg, ZCMessageSendCode errorCode) {
            self->isLoading = NO;
            if (self->_listArray.count == 0) {
                [self dissmiss];
                return;
            }
        }];
    }
}

-(void)setlistTableFrameWith{
    // 监听聊天页面是否销毁 ,接口慢或者 异常情况下，显示到了用户的页面上了
    if (![ZCUICore getUICore].isCanShowAutoView || [ZCUICore getUICore].isKeyBoardIsClear) {
        [self dissmiss];
        return;
    }
    
    CGFloat height = _listArray.count * LineHeight +8*2;
    if(_listArray.count >= 4){
        height = 4 * LineHeight + 8*2;
    }
    
    UIWindow * window = [SobotUITools getCurWindow];
    CGRect rect= [_bottomView convertRect:_bottomView.bounds toView:window];
    CGRect sheetViewF = CGRectMake(0,rect.origin.y - height, rect.size.width, height);
    self.frame = sheetViewF;
    self.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
    [self.listTable setFrame:CGRectMake(0, 8, ScreenWidth, height-8*2)];
    [[SobotUITools getCurWindow] addSubview:self];
    [_listTable reloadData];
}

-(void)dissmiss{
    CGRect sheetViewF = self.frame;
    sheetViewF.size.height = 0;
    self.frame = sheetViewF;
    [self removeFromSuperview];
}


#pragma mark -- tableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZCAutoListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZCAutoListCell"];
    if (cell == nil) {
        cell = [[ZCAutoListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCAutoListCell"];
    }
    
    // 异常处理
    if (sobotIsNull(_listArray) || _listArray.count == 0 || _listArray.count -1 < indexPath.row ) {
        return cell;
    }
    
    if(_listArray[indexPath.row][@"attr"]){
        [cell initDataToView:@"" attributedText:_listArray[indexPath.row][@"attr"]];
    }else{
        [cell initDataToView:sobotConvertToString(_listArray[indexPath.row][@"item"][@"question"]) attributedText:@""];
    }
    return cell;
}
- (CGFloat)getRedFor:(id)color
{
    UIColor *myColor = (UIColor *)color;
    const CGFloat *c = CGColorGetComponents(myColor.CGColor);
    return c[0];
}
- (CGFloat)getGreenFor:(id)color
{
    UIColor *myColor = (UIColor *)color;
    const CGFloat *c = CGColorGetComponents(myColor.CGColor);
    return c[1];
}
- (CGFloat)getBlueFor:(id)color
{
    UIColor *myColor = (UIColor *)color;
    const CGFloat *c = CGColorGetComponents(myColor.CGColor);
    return c[2];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
//    NSString * text = _listArray[indexPath.row][@"question"];
    NSString * text;
////    2.8.2 松果反馈： 崩溃
    if (_listArray.count > indexPath.row) {
        NSDictionary *dic = _listArray[indexPath.row];
        text = sobotConvertToString(dic[@"item"][@"question"]);
//        if ([dic objectForKey:@"question"] && !([[dic objectForKey:@"question"] isEqual:[NSNull null]])) {
//            text = [dic objectForKey:@"questio
//        }
    }
    if(_delegate && [_delegate respondsToSelector:@selector(autoViewCellItemClick:)]){
        [_delegate autoViewCellItemClick:text];
    }
    if (_BackCellClick) {
        _BackCellClick(text);
    }
    
}

-(ZCLibConfig *) getZCLibConfig{
    return [[ZCPlatformTools sharedInstance] getPlatformInfo].config;
}

@end
