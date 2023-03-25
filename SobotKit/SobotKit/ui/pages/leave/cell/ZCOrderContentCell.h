//
//  ZCOrderContentCell.h
//  SobotKit
//
//  Created by lizh on 2022/9/13.
//

#import "ZCOrderCreateCell.h"
#import "ZCUIPlaceHolderTextView.h"
NS_ASSUME_NONNULL_BEGIN

@interface ZCOrderContentCell : ZCOrderCreateCell
@property(weak,nonatomic) NSMutableArray *imageArr;

@property (nonatomic,strong) ZCUIPlaceHolderTextView *textDesc;

@property (nonatomic,strong) UIScrollView *fileScrollView;

@property (nonatomic,strong) NSMutableArray * imagePathArr;

@property (nonatomic,assign) BOOL enclosureShowFlag;// 是否显示添加附件按钮

// 刷新附件
- (void)reloadScrollView;
@end

NS_ASSUME_NONNULL_END
