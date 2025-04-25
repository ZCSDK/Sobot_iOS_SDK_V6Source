//
//  ZCPageSheetView.h
//  SobotKit
//
//  Created by 张新耀 on 2019/9/4.
//  Copyright © 2019 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN
typedef void(^DissmisBlock)(NSString *msg,int type);

typedef NS_ENUM(NSInteger,ZCPageSheetType) {
    ZCPageSheetTypeDefault = 0,
    ZCPageSheetTypeShort   = 1,
    ZCPageSheetTypeLong    = 2
};

@interface ZCPageSheetView : UIView
// 0 默认 1 询前表单 2.询前表单单选
@property(nonatomic,assign) int  isFromAsk;
@property(nonatomic,copy)DissmisBlock dissmisBlock;

-(instancetype)initWithTitle:(NSString *) title  superView:(UIView *) view showView:(UIView *) contentView type:(ZCPageSheetType) type;

-(void)showSheet:(CGFloat) height animation:(BOOL) animation block:(nonnull void(^)(void))ShowBlock;

-(void)dissmisPageSheet;
// 结束销毁
-(void)dissmisPageSheetCommit;


@end

NS_ASSUME_NONNULL_END
