//
//  ZCChatReferenceFileCell.m
//  SobotKit
//
//  Created by lizh on 2023/11/24.
//

#import "ZCChatReferenceFileCell.h"

@interface ZCChatReferenceFileCell()

@property(nonatomic,strong) UIView *fileBgView;
@property(nonatomic,strong) SobotImageView *fileIcon;
@property(nonatomic,strong) UILabel *flieNamelab;
@property(nonatomic,strong) SobotChatMessage *tempModel;
@end

@implementation ZCChatReferenceFileCell

-(void)layoutSubViewUI{
    [super layoutSubViewUI];
    // 移除viewcontent的所有子view
    [self.viewContent.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _fileBgView = ({
        UIView *iv = [[UIView alloc]init];
        [self.viewContent addSubview:iv];
        iv.backgroundColor = UIColorFromModeColorAlpha(SobotColorWhite, 0.14);
        [self.viewContent addConstraint:sobotLayoutPaddingTop(0, iv, self.viewContent)];
        [self.viewContent addConstraint:sobotLayoutPaddingLeft(0, iv, self.viewContent)];
        [self.viewContent addConstraint:sobotLayoutPaddingRight(0, iv, self.viewContent)];
        [self.viewContent addConstraint:sobotLayoutPaddingBottom(0, iv, self.viewContent)];
        [self.viewContent addConstraint:sobotLayoutEqualHeight(40, iv, NSLayoutRelationEqual)];
        iv;
    });
    
    _fileIcon = ({
        SobotImageView *iv = [[SobotImageView alloc]init];
        [self.fileBgView addSubview:iv];
        [iv setContentMode:UIViewContentModeScaleAspectFill];
        [self.fileBgView addConstraints:sobotLayoutSize(21, 25, iv, NSLayoutRelationEqual)];
        [self.fileBgView addConstraint:sobotLayoutPaddingLeft(9, iv, self.fileBgView)];
        [self.fileBgView addConstraint:sobotLayoutEqualCenterY(0, iv, self.fileBgView)];
        iv;
    });
   
    _flieNamelab = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.fileBgView addSubview:iv];
        iv.textColor = UIColorFromKitModeColor(SobotColorWhite);
        iv.font = SobotFont13;
        [self.fileBgView addConstraint:sobotLayoutMarginLeft(5, iv, self.fileIcon)];
        [self.fileBgView addConstraint:sobotLayoutEqualCenterY(0, iv, self.fileBgView)];
        [self.fileBgView addConstraint:sobotLayoutPaddingRight(-5, iv, self.fileBgView)];
        iv;
    });
    
    UITapGestureRecognizer *tapGesturer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bgViewClick:)];
    self.fileBgView.userInteractionEnabled=YES;
    [self.fileBgView addGestureRecognizer:tapGesturer];
}
-(void)dataToView:(SobotChatMessage *)message{
    [super dataToView:message];
    self.tempModel = message;
    [_fileIcon setImage:[ZCUIKitTools getFileIcon:message.richModel.url fileType:(int)message.richModel.fileType]];
    [_flieNamelab setText:sobotTrimString(message.richModel.fileName)];
    
    [self showContent:@"" view:_fileBgView btm:nil isMaxWidth:YES customViewWidth:ScreenWidth];
    
    if(self.parentMessage.sendType == 0){
        // 右边
        _fileBgView.backgroundColor = UIColorFromModeColorAlpha(SobotColorWhite, 0.14);
    }else{
        // 左边
        _fileBgView.backgroundColor = UIColorFromModeColor(SobotColorWhite);
    }
}


-(void)bgViewClick:(UITapGestureRecognizer *) tap{
    NSString * link = self.tempModel.richModel.url;
    if(sobotConvertToString(link).length  == 0){
        return;
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(onReferenceCellEvent:type:state:obj:)]){
        [self.delegate onReferenceCellEvent:self.tempModel type:ZCChatReferenceCellEventOpenFileToDocment state:1 obj:nil];
    }
}

@end
