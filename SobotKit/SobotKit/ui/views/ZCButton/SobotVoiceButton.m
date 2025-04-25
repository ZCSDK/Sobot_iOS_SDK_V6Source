//
//  SobotVoiceButton.m
//  SobotKit
//
//  Created by lizh on 2025/2/21.
//

#import "SobotVoiceButton.h"

@implementation SobotVoiceButton

// 重写layoutSubviews方法，手动设置按钮子控件的位置
- (void)layoutSubviews {
    [super layoutSubviews];

    // 获取到按钮的实际大小 图片在右，文字在左侧，靠边间距都是16px
    CGRect btnImgF = self.imageView.frame;
    CGRect btnTitleF = self.titleLabel.frame;
    
    btnImgF.origin.x = 16;
    btnTitleF.origin.x = self.frame.size.width - 30;
    
    self.titleLabel.frame = btnTitleF;
    self.imageView.frame = btnImgF;
}




@end
