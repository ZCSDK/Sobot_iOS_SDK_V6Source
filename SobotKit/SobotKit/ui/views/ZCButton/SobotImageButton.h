//
//  SobotImageButton.h
//  SobotKit
//
//  Created by zhangxy on 2024/12/23.
//

#import <UIKit/UIKit.h>
#import <SobotCommon/SobotImageView.h>
#import <SobotCommon/SobotButton.h>

NS_ASSUME_NONNULL_BEGIN

/// 测试用例
/*
 SobotImageButton *imgBtn = [[SobotImageButton alloc] init];
 imgBtn.backgroundColor = UIColor.whiteColor;
//    imgBtn.titleLabel.backgroundColor = UIColor.blueColor;
//    imgBtn.imageView.backgroundColor = UIColor.redColor;
 [self.view addSubview:imgBtn];
 [self.view addConstraints:sobotLayoutPaddingView(100, 0, 120, -120, imgBtn, self.view)];

 imgBtn.titleColor = UIColorFromKitModeColor(SobotColorTextMain);
 imgBtn.image = SobotKitGetImage(@"zcicon_bottombar_conversation");
//    imgBtn.titleColorSelected = UIColorFromKitModeColor(SobotColorTextSub);
//    imgBtn.imageSelected = SobotKitGetImage(@"zcicon_bottombar_satisfaction");
 imgBtn.titleLabel.text = @"文本内容";
 [imgBtn configLocation:1 inset:UIEdgeInsetsMake(3, 3, 3, 3) space:10 imageSize:CGSizeMake(50, 30)];
 
 [imgBtn setTapClickPicBlock:^(UIGestureRecognizerState state, BOOL endState) {
     NSLog(@"按下:%ld---%d",state,endState);
    // endState:YES时，需要处理的正常点击
 }];
 
 */

typedef NS_ENUM(NSInteger,SobotImgBtnLocation) {
    SobotImgBtnLocationUp  = 0,
    SobotImgBtnLocationDown = 1,
    SobotImgBtnLocationLeft = 2,
    SobotImgBtnLocationRight =3
};

@interface SobotImageButton : UIView

// 扩展属性，方便获取业务数据
@property(nonatomic,strong) id objTag;

// 初始化后，会自动创建，仅设置属性即可
@property(nonatomic,strong) SobotImageView *imageView;
@property(nonatomic,strong) SobotButton *clickBtn;
@property(nonatomic,strong) UILabel *titleLabel;

// 当前视图按下和选中时的效果
@property(nonatomic,assign) BOOL selected;

@property(nonatomic,strong) UIColor *titleColor;
@property(nonatomic,strong) UIColor *titleColorSelected;

@property(nonatomic,strong) UIImage *image;
@property(nonatomic,strong) UIImage *imageSelected;



/// 配置图片和文字位置
/// - Parameters:
///   - imageLocation: 0:图片在上方，1:图片在下方(仅支持上下结构)
///   - contentEdgeInsets: 绘制内部视图时的外边距(图片会居中显示)
///   - centerSpace: 上下2个控件之间的间距
///   - imageSize: 图片显示的大小
-(void)configLocation:(SobotImgBtnLocation) imageLocation inset:(UIEdgeInsets) contentEdgeInsets space:(CGFloat) centerSpace imageSize:(CGSize) imageSize;



@property (strong, nonatomic) void(^TapClickPicBlock)(UIGestureRecognizerState state,BOOL endState);


/// 添加点击事件，会在 UIGestureRecognizerStateEnded 时触发
/// - Parameters:
///   - target: target description
///   - action: action description
- (void)addTarget:(nullable id)target action:(SEL)action;


@end

NS_ASSUME_NONNULL_END
