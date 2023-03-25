//
//  ZCSettingCell.h
//  SobotKitFrameworkTest
//
//  Created by lizhihui on 2017/11/21.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZCSettingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *detailLab;
@property (weak, nonatomic) IBOutlet UIImageView *img;


-(void)initWithNSDictionary:(NSDictionary*)dict;
@end
