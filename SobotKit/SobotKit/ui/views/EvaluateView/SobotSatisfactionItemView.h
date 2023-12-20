//
//  SobotSatisfactionItemView.h
//  SobotKit
//
//  Created by zhangxy on 2023/8/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SobotSatisfactionItemView : UIView

-(CGFloat)getHeight;

// 刷新数据
-(void)clearData;
-(void)viewOrientationChange;

// 刷新数据
-(void)refreshData:(NSArray *)titles;
-(void)refreshData:(NSArray *)titles withCheckLabels:(NSString *_Nullable )labels;
-(NSString *)getSeletedTitle;

@end

NS_ASSUME_NONNULL_END
