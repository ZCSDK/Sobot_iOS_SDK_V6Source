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

-(id)initPrivate{
    self = [super initWithFrame:CGRectMake(0, 0, 0, 0)];
    if(self){
        _dict = [[NSMutableDictionary alloc] init];
        _listArray = [[NSMutableArray alloc] init];
        _listTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0) style:UITableViewStylePlain];
        _listTable.dataSource = self;
        _listTable.delegate = self;
        [_listTable setBackgroundColor:[UIColor clearColor]];
        [_listTable setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [_listTable setSeparatorColor:UIColorFromModeColor(SobotColorBgLine)];
        [_listTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        if(iOS7){
            [_listTable setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        }
        UIView *view =[ [UIView alloc]init];
        view.backgroundColor = [UIColor clearColor];
        [_listTable setTableFooterView:view];
        [self addSubview:_listTable];
        _listArray  = [[NSMutableArray alloc] init];
        [self setTableSeparatorInset];
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
    _bottomView = bottomView;
    _searchText = searchText;
    NSMutableArray *arr  = [[_dict objectForKey:searchText] mutableCopy];
    if(!sobotIsNull(arr)&& arr.count>0){
        if (_listArray.count>0) {
            [_listArray removeAllObjects];
        }
        _listArray = arr;
        [self setlistTableFrameWith];
    }else{
        if(isLoading){
            NSLog(@"66666666666");
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
                NSArray * arr = dict[@"data"][@"respInfoList"];
                if (arr.count>0) {
                    if (self->_listArray.count>0) {
                        [self->_listArray removeAllObjects];
                    }
                    for(NSDictionary *item in arr){
                        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithData:[item[@"highlight"]  dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
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
    CGFloat height = _listArray.count * LineHeight;
    if(_listArray.count > 3){
        height = 3 * LineHeight + LineHeight /2;
    }
    
    UIWindow * window = [SobotUITools getCurWindow];
    CGRect rect= [_bottomView convertRect:_bottomView.bounds toView:window];
    CGRect sheetViewF = CGRectMake(0,rect.origin.y - height, rect.size.width, height);
    self.frame = sheetViewF;
    [self.listTable setFrame:CGRectMake(0, 0, ScreenWidth, height)];
    [[SobotUITools getCurWindow] addSubview:self];
    [_listTable reloadData];
}

-(void)dissmiss{
    CGRect sheetViewF = self.frame;
    sheetViewF.size.height = 0;
    self.frame = sheetViewF;
    [self removeFromSuperview];
}

/**
 *  设置UITableView分割线空隙
 */
-(void)setTableSeparatorInset{
    UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, 0, 0);
    if ([_listTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [_listTable setSeparatorInset:inset];
    }
    if ([_listTable respondsToSelector:@selector(setLayoutMargins:)]) {
        [_listTable setLayoutMargins:inset];
    }
}

#pragma mark -- tableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    if(indexPath.row==_listArray.count-1){
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
        
        if([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
            [cell setPreservesSuperviewLayoutMargins:NO];
        }
    }
    
    cell.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark1);
    cell.textLabel.font = SobotFont14;
    cell.textLabel.textColor = UIColorFromKitModeColor(SobotColorTextMain);
    if(_listArray[indexPath.row][@"attr"]){
        cell.textLabel.attributedText = _listArray[indexPath.row][@"attr"];
    }else{
        cell.textLabel.text = sobotConvertToString(_listArray[indexPath.row][@"item"][@"question"]);
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
//            text = [dic objectForKey:@"question"];
//        }
    }
    if(_delegate && [_delegate respondsToSelector:@selector(autoViewCellItemClick:)]){
        [_delegate autoViewCellItemClick:text];
    }
    if (_BackCellClick) {
        _BackCellClick(text);
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return LineHeight;
}

-(ZCLibConfig *) getZCLibConfig{
    return [[ZCPlatformTools sharedInstance] getPlatformInfo].config;
}

@end
