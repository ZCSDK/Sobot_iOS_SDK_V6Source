//
//  ZCSettingCell.m
//  SobotKitFrameworkTest
//
//  Created by lizhihui on 2017/11/21.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import "ZCSettingCell.h"

#import "EntityConvertUtils.h"

@implementation ZCSettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = UIColor.whiteColor;
    // Initialization code
    _titleLab.textColor = UIColorFromRGB(0x3D4966);
    _titleLab.font = [UIFont systemFontOfSize:15];
    
    _detailLab.textColor = UIColorFromRGB(0x3D4966);
    _detailLab.font = [UIFont systemFontOfSize:13];
    _img.image = [UIImage imageNamed:@"next_icon"];
    
    CGRect imgF = _img.frame;
    imgF.origin.x = [[UIScreen mainScreen] bounds].size.width - imgF.size.width - 15;
    _img.frame = imgF;
    
    
    CGRect detailF = _detailLab.frame;
    detailF.origin.x = _img.frame.origin.x - detailF.size.width -10;
    _detailLab.frame = detailF;
    
}

-(void)initWithNSDictionary:(NSDictionary*)dict{
    self.backgroundColor = UIColor.whiteColor;
    _titleLab.text = dict[@"dictName"];
    _detailLab.text = dict[@"dictValue"];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
