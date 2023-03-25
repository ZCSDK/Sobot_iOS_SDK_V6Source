//
//  ZCMsgRecordView.h
//  SobotKit
//
//  Created by lizh on 2022/9/7.
//

#import <SobotKit/SobotKit.h>
#import <SobotChatClient/SobotChatClient.h>

typedef void(^JumpMsgDetailVCBlock)(ZCRecordListModel* model);

NS_ASSUME_NONNULL_BEGIN

@interface ZCMsgRecordView : UIView
@property (nonatomic,copy) JumpMsgDetailVCBlock  jumpMsgDetailBlock;
-(id)initWithFrame:(CGRect)frame withController:(UIViewController *) vc;
-(void)updataWithHeight:(CGFloat)height viewWidth:(CGFloat)w;
-(void)loadData;// 刷新数据
@end

NS_ASSUME_NONNULL_END
