//
//  ZCUIAskTableCell.h
//  SobotKit
//
//  Created by lizh on 2024/11/6.
//

#import <UIKit/UIKit.h>
#import "ZCUIKitTools.h"
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClientDefines.h>
#import <SobotChatClient/ZCOrderCusFiledsModel.h>
#import "ZCOrderOnlyEditCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZCUIAskTableCellDelegate <NSObject>

@optional
-(void)itemCreateCellOnClick:(ZCOrderCreateItemType) type dictKey:(NSString *) key model:(ZCOrderModel *) model withButton:(UIButton *)button;

-(void)itemCreateCusCellOnClick:(ZCOrderCreateItemType) type dictValue:(NSString *) value dict:(NSDictionary *) dict indexPath:(NSIndexPath *)indexPath;

-(void)didKeyboardWillShow:(NSIndexPath *)indexPath view1:(UITextView *)textview view2:(UITextField *) textField;

@end


@interface ZCUIAskTableCell : UITableViewCell
@property (nonatomic,strong) UILabel *labelName;
@property (nonatomic,strong) UITextField *fieldContent;
@property (nonatomic,strong) UIImageView *imgArrow;
@property (nonatomic,strong) UILabel *valueLab;
@property (nonatomic,weak) id <ZCUIAskTableCellDelegate> delegate;
@property(nonatomic,weak) NSIndexPath  *indexPath;
@property(nonatomic,strong) NSDictionary *tempDict;
@property(nonatomic,assign) BOOL isHaveDian;
@property(nonatomic,strong) UIView *lineView;
// 实际自定义字段
@property(nonatomic,strong) SobotFormNodeRespVosModel *editModel;

@property(nonatomic,strong)UIButton *clickBtn;

-(void)initDataToView:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
