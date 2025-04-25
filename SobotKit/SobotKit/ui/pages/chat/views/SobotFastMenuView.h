//
//  SobotFastMenuView.h
//  SobotKit
//
//  Created by zhangxy on 2024/8/6.
//

#import <UIKit/UIKit.h>
#import "ZCLibCusMenu.h"

NS_ASSUME_NONNULL_BEGIN

@interface SobotFastMenuView : UIView


@property(nonatomic,strong) void(^fastMenuBlock)(ZCLibCusMenu *menu);
@property(nonatomic,strong) void(^fastMenuRefreshDataBlock)(CGFloat height);
-(id)initWithSuperView:(UIView *) view;


/// 更新快捷菜单数据,如果已经加载过则不重新加载
-(void)refreshData;

/// 更新快捷菜单数据
/// - Parameter reLoadData: 是否重新加载
-(void)refreshData:(BOOL) reLoadData;
-(void)clearDataUpdateUIForNewSession;


-(NSString *)getMenuUrl:(NSString *) menuUrl paramFlag:(NSString *)paramFlag;

@end

NS_ASSUME_NONNULL_END
