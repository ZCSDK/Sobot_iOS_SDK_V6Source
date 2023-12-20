//
//  ZCChatFileCell.m
//  SobotKit
//
//  Created by zhangxy on 2022/9/22.
//

#import "ZCChatFileCell.h"


#import "ZCUICore.h"
#import "ZCCircleProgressView.h"

@interface ZCChatFileCell(){
    
}

@property(nonatomic,strong) NSLayoutConstraint *layoutBgWidth;

@property (strong, nonatomic) UIView *bgView; //
@property (nonatomic,strong) SobotImageView *logoView;
@property (strong, nonatomic) ZCCircleProgressView *progressView;

@property (strong, nonatomic) UILabel *labTitle; //标题
@property (strong, nonatomic) UILabel *labDesc; //标题
@property (strong, nonatomic) UIButton *btnCancle; //标题
@end

@implementation ZCChatFileCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self createViews];
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self createViews];
        
        //设置点击事件
        UITapGestureRecognizer *tapGesturer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bgViewClick:)];
        self.bgView.userInteractionEnabled=YES;
        [self.bgView addGestureRecognizer:tapGesturer];
        
        //设置点击事件
        _layoutBgWidth = sobotLayoutEqualWidth(ScreenWidth, self.bgView, NSLayoutRelationEqual);
        [self.contentView addConstraint:_layoutBgWidth];
        [self.contentView addConstraint:sobotLayoutPaddingTop(ZCChatPaddingVSpace, self.bgView, self.ivBgView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(ZCChatPaddingHSpace, self.bgView, self.ivBgView)];
        [self.contentView addConstraint:sobotLayoutMarginBottom(-ZCChatCellItemSpace, self.bgView, self.lblSugguest)];
        
        
        [self.bgView addConstraints:sobotLayoutSize(34, 40, self.logoView, NSLayoutRelationEqual)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(0, self.logoView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingTop(0, self.logoView, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingBottom(0, self.logoView, self.bgView)];
        
        [self.bgView addConstraint: sobotLayoutPaddingTop(0, self.labTitle, self.bgView)];
        [self.bgView addConstraint:sobotLayoutMarginLeft(ZCChatPaddingVSpace, self.labTitle, self.logoView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-0, self.labTitle, self.bgView)];
        
        [self.bgView addConstraint: sobotLayoutMarginTop(ZCChatCellItemSpace, self.labDesc, self.labTitle)];
        [self.bgView addConstraint:sobotLayoutMarginLeft(ZCChatPaddingVSpace, self.labDesc, self.logoView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-0, self.labDesc, self.bgView)];
        
        [self.contentView addConstraint:sobotLayoutMarginRight(-10, self.btnCancle, self.ivBgView)];
        [self.contentView addConstraint:sobotLayoutEqualCenterY(0, self.btnCancle, self.ivBgView)];
        [self.contentView addConstraints:sobotLayoutSize(20, 20, self.btnCancle, NSLayoutRelationEqual)];
    }
    return self;
}


-(void)createViews{
    _bgView = ({
        UIView *iv = [[UIView alloc] init];
        [iv setBackgroundColor:UIColor.clearColor];
        [self.contentView addSubview:iv];
        iv;
    });
    _logoView = ({
        SobotImageView *iv = [[SobotImageView alloc] init];
        iv.layer.masksToBounds = YES;
        iv.contentMode = UIViewContentModeScaleAspectFill;
        //设置点击事件
        iv.userInteractionEnabled=YES;
        [self.bgView addSubview:iv];
        iv;
    });
    _progressView = ({
        ZCCircleProgressView *iv = [[ZCCircleProgressView alloc] init];
        iv.layer.masksToBounds = YES;
        //设置点击事件
        iv.userInteractionEnabled=YES;
        [self.logoView addSubview:iv];
        
        [self.logoView addConstraints:sobotLayoutSize(30, 30, iv, NSLayoutRelationEqual)];
        [self.logoView addConstraint:sobotLayoutEqualCenterX(0, iv, self.logoView)];
        [self.logoView addConstraint:sobotLayoutEqualCenterY(0, iv, self.logoView)];
        
        iv.hidden = YES;
        iv;
    });
    _labTitle = ({
        UILabel *iv = [[UILabel alloc] init];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        iv.numberOfLines = 1;
        [iv setFont:SobotFontBold14];
        [self.bgView addSubview:iv];
        iv;
    });
    
    
    _labDesc = ({
        UILabel *iv = [[UILabel alloc] init];
        iv.numberOfLines = 0;
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        [iv setFont:SobotFont14];
        [self.bgView addSubview:iv];
        iv;
    });
    
    _btnCancle = ({
        UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:iv];
        [iv setImage:SobotKitGetImage(@"zcicon_close_down") forState:UIControlStateNormal];
        [iv addTarget:self action:@selector(cancelSendMsg:) forControlEvents:UIControlEventTouchUpInside];
        iv.hidden = YES;
        iv;
        
    });
    
}


-(void)cancelSendMsg:(UIButton *)sender{
    //    NSLog(@"取消发送文件\\");
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]) {
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemCancelFile text:@"" obj:self.tempModel];
    }
    _btnCancle.hidden = YES;
}
-(void)initDataToView:(SobotChatMessage *)message time:(NSString *)showTime{
    [super initDataToView:message time:showTime];
    
    [_logoView setImage:[ZCUIKitTools getFileIcon:message.richModel.url fileType:(int)message.richModel.fileType]];
    [_labDesc setText:message.richModel.fileSize];
    [_labTitle setText:sobotTrimString(message.richModel.fileName)];
    
    _btnCancle.hidden = YES;
    if (message.isHistory) {
        _progressView.progress = 1.0;
        _progressView.hidden = YES;
    }else{
        
        if(message.sendStatus == 1){
            _progressView.hidden = NO;
            [_progressView setProgress:message.progress];
            _btnCancle.hidden = NO;
        }else{
            [_progressView setProgress:1.0];
            _progressView.hidden = YES;
        }
    }

    _layoutBgWidth.constant = self.maxWidth;
    [self.bgView layoutIfNeeded];
    [self setChatViewBgState:CGSizeMake(self.maxWidth,CGRectGetMaxY(_bgView.frame))];
}


-(void)bgViewClick:(UITapGestureRecognizer *) tap{
    NSString * link = self.tempModel.richModel.url;
    
    if(sobotConvertToString(link).length  == 0){
        return;
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeOpenFile text:sobotConvertToString(link)  obj:sobotConvertToString(link)];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
