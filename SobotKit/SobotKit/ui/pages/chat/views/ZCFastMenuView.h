//
//  ZCFastMenuView.h
//  SobotKit
//
//  Created by zhangxy on 2022/9/20.
//

#import <UIKit/UIKit.h>
#import "ZCLibCusMenu.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZCFastMenuView : UIView

@property(nonatomic,strong) void(^fastMenuBlock)(ZCLibCusMenu *menu);
@property(nonatomic,strong) void(^fastMenuRefreshDataBlock)(CGFloat height);
-(id)initWithSuperView:(UIView *) view;
-(void)refreshData;
-(void)clearDataUpdateUIForNewSession;


-(NSString *)getMenuUrl:(NSString *) menuUrl paramFlag:(NSString *)paramFlag;

@end

NS_ASSUME_NONNULL_END
