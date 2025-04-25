//
//  ZCOrderContentCell.h
//  SobotKit
//
//  Created by lizh on 2022/9/13.
//

#import "ZCOrderCreateCell.h"
//#import "ZCUIPlaceHolderTextView.h"
#import "ZCUITextView.h"
NS_ASSUME_NONNULL_BEGIN

@interface ZCOrderContentCell : ZCOrderCreateCell

@property(nonatomic,strong) UILabel *tipLab;// 问题描述

@property(weak,nonatomic) NSMutableArray *imageArr;

@property (nonatomic,strong) ZCUITextView *textDesc;

@property (nonatomic,strong) UIScrollView *fileScrollView;

@property (nonatomic,strong) NSMutableArray * imagePathArr;

@property (nonatomic,assign) BOOL enclosureShowFlag;// 是否显示添加附件按钮

@property (nonatomic,assign) BOOL ticketContentShowFlag;// 是否显示输入框 有输入框是否显示 *
@property (nonatomic,assign) BOOL ticketContentFillFlag;// 输入框是否必填

// 刷新附件
- (void)reloadScrollView;
@end

NS_ASSUME_NONNULL_END
