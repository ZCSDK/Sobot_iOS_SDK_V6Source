//
//  ZCOrderCreateCell.h
//  SobotKit
//
//  Created by lizh on 2022/9/13.
//

#import <UIKit/UIKit.h>
#import <SobotChatClient/SobotChatClient.h>

// **编辑cell的间距**
// 左右间距 16
#define  EditCellHSpec 16
// 标题行高 22
#define  EditCellTitleH 22
// 单行高度 72
#define  EditCellBGH 72
// 多行高度 112
#define  EditCellMBGH 112
// 标题上间距 12 和下间距 12
#define  EditCellPT 12
// 组件之间的上下间距 4
#define  EditCellMT 4

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,ZCOrderCreateItemType) {
    ZCOrderCreateItemTypeAddPhoto        = 1,// 添加内容图片
    ZCOrderCreateItemTypeAddReplyPhoto   = 2,// 添加内容回复图片
    ZCOrderCreateItemTypeTitle           = 3,// 添加标题
    ZCOrderCreateItemTypeDesc            = 4,// 添加描述
    ZCOrderCreateItemTypeLookAtPhoto     = 5,// 查看大图
    ZCOrderCreateItemTypeLookAtReplyPhoto= 6,// 查看大图
    ZCOrderCreateItemTypeOnlyEdit        = 7,// 单行编辑
    ZCOrderCreateItemTypeMulEdit         = 8,// 多行编辑
    ZCOrderCreateItemTypeReplyType       = 9,// 多行编辑
    ZCOrderCreateItemTypeDeletePhoto     = 10,// 删除文件
    ZCOrderCreateItemTypeSelAsk     = 11,// 询前表单单选
};

@protocol ZCOrderCreateCellDelegate <NSObject>
@optional
-(void)itemCreateCellOnClick:(ZCOrderCreateItemType) type dictKey:(NSString *) key model:(ZCOrderModel *) model withButton:(UIButton *)button;

-(void)itemCreateCusCellOnClick:(ZCOrderCreateItemType) type dictValue:(NSString *) value dict:(NSDictionary *) dict indexPath:(NSIndexPath *)indexPath;

-(void)didKeyboardWillShow:(NSIndexPath *)indexPath view1:(UITextView *)textview view2:(UITextField *) textField;

@end

@interface ZCOrderCreateCell : UITableViewCell

@property (nonatomic,strong) UILabel *labelName;
@property(nonatomic,weak) id<ZCOrderCreateCellDelegate> delegate;
@property(nonatomic,assign) CGFloat tableWidth;
@property(nonatomic,assign) BOOL isReply;
@property(nonatomic,weak) NSIndexPath  *indexPath;
@property(nonatomic,weak) ZCOrderModel   *tempModel;
@property(nonatomic,strong) NSDictionary *tempDict;

@property (nonatomic,strong)NSLayoutConstraint *labelNamePT;
@property (nonatomic,strong)NSLayoutConstraint *labelNameEH;
@property (nonatomic,strong)NSLayoutConstraint *lineViewPL;
@property (nonatomic,strong)UIView *lineView;
-(void)initDataToView:(NSDictionary *) dict;
-(NSMutableAttributedString *)getOtherColorString:(NSString *)string Color:(UIColor *)Color withString:(NSString *)originalString;

- (NSMutableAttributedString *)getOtherColorString:(NSString *)string colorArray:(NSArray<UIColor *> *)colorArray withStringArray:(NSArray<NSString *> *)stringArray;

-(BOOL)checkLabelState:(BOOL) showSmall text:(NSString *) text;
@end

NS_ASSUME_NONNULL_END
