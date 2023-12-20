//
//  ZCChatMessageInfoFileView.m
//  SobotKit
//
//  Created by lizh on 2023/11/23.
//

#import "ZCChatMessageInfoFileView.h"

@interface ZCChatMessageInfoFileView ()

@property(nonatomic,strong)UIView *fileBgView;
@property(nonatomic,strong)SobotImageView *iconImg;
@property(nonatomic,strong)UILabel *fileName;
@property(nonatomic,strong)UILabel *sizeLab;
@property(nonatomic,strong)SobotButton *objBtn;

@end
@implementation ZCChatMessageInfoFileView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        self.userInteractionEnabled = YES;
        [self layoutSubViewUI];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self layoutSubViewUI];
    }
    return self;
}

-(void)layoutSubViewUI{

    _fileBgView = ({
        UIView *iv = [[UIView alloc]init];
        [self addSubview:iv];
        iv.layer.cornerRadius = 0.5;
        iv.layer.borderWidth = 0.5;
        iv.layer.masksToBounds = YES;
        iv.layer.borderColor = UIColorFromKitModeColor(@"0xD9D9D9").CGColor;
        [self addConstraint:sobotLayoutPaddingTop(0, iv, self)];
        [self addConstraint:sobotLayoutEqualHeight(70, iv, NSLayoutRelationEqual)];
        [self addConstraint:sobotLayoutPaddingLeft(42, iv, self)];
        [self addConstraint:sobotLayoutPaddingRight(-42, iv, self)];
        [self addConstraint:sobotLayoutPaddingBottom(0, iv, self)];
        iv;
    });
      
    // 文件图标
    _iconImg = ({
        SobotImageView *iv = [[SobotImageView alloc]init];
        [self.fileBgView addSubview:iv];
        [_fileBgView addConstraint:sobotLayoutPaddingTop(15, iv, _fileBgView)];
        [_fileBgView addConstraint:sobotLayoutPaddingLeft(15, iv, _fileBgView)];
        [_fileBgView addConstraint:sobotLayoutEqualWidth(40, iv, NSLayoutRelationEqual)];
        [_fileBgView addConstraint:sobotLayoutEqualHeight(40, iv, NSLayoutRelationEqual)];
        iv;
    });
       
    _fileName = ({
        UILabel *iv = [[UILabel alloc]init];
        [_fileBgView addSubview:iv];
        iv.textColor = UIColorFromKitModeColor(SobotColorTextMain);
        iv.font = SobotFontBold12;
        iv.numberOfLines = 1;
        [_fileBgView addConstraint:sobotLayoutPaddingTop(15, iv, _fileBgView)];
        [_fileBgView addConstraint:sobotLayoutPaddingRight(-15, iv, _fileBgView)];
        [_fileBgView addConstraint:sobotLayoutMarginLeft(10, iv, _iconImg)];
        iv;
    });
    
    _sizeLab = ({
        UILabel *iv = [[UILabel alloc]init];
        [_fileBgView addSubview:iv];
        iv.textColor = UIColorFromKitModeColor(SobotColorTextSub);
        iv.font = SobotFont10;
        iv.numberOfLines = 1;
        [_fileBgView addConstraint:sobotLayoutMarginTop(7, iv, _fileName)];
        [_fileBgView addConstraint:sobotLayoutMarginLeft(10, iv, _iconImg)];
        [_fileBgView addConstraint:sobotLayoutPaddingRight(-15, iv, _fileBgView)];
        iv;
    });
        
       
    _objBtn = ({
        SobotButton *iv = [SobotButton buttonWithType:UIButtonTypeCustom];
        [iv setBackgroundColor:[UIColor clearColor]];
        [_fileBgView addSubview:iv];
        [_fileBgView addConstraint:sobotLayoutPaddingTop(0, iv, _fileBgView)];
        [_fileBgView addConstraint:sobotLayoutPaddingLeft(0, iv, _fileBgView)];
        [_fileBgView addConstraint:sobotLayoutPaddingRight(0, iv, _fileBgView)];
        [_fileBgView addConstraint:sobotLayoutPaddingBottom(0, iv, _fileBgView)];
        [iv addTarget:self action:@selector(fileClick:) forControlEvents:UIControlEventTouchUpInside];
        iv;
    });

}

-(CGFloat)dataToView:(SobotChatMessage *)model{
    [_iconImg setImage:[ZCUIKitTools getFileIcon:model.richModel.url fileType:(int)model.richModel.fileType]];
    _fileName.text = sobotConvertToString(model.richModel.fileName);
    _sizeLab.text = sobotConvertToString(model.richModel.fileSize);
    _objBtn.obj = model;
    // 先更新约束 在获取高度
    [self layoutIfNeeded];
    CGRect f = self.fileBgView.frame;
    return f.size.height + f.origin.y;
}

#pragma mark - 打开文件
-(void)fileClick:(SobotButton*)sender{
    SobotChatMessage *model = (SobotChatMessage*)(sender.obj);
    if(self.delegate && [self.delegate respondsToSelector:@selector(onViewEvent:dict:obj:)]){
        [self.delegate onViewEvent:ZCChatMessageInfoViewEventOpenFile dict:@{} obj:model];
    }
}


@end
