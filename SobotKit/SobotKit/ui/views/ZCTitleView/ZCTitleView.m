//
//  ZCTitleView.m
//  SobotKit
//
//  Created by lizh on 2022/9/21.
//

#import "ZCTitleView.h"
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClient.h>
#import "ZCUIKitTools.h"

//#define ImgWidth 32

@interface ZCTitleView()
{
    CGFloat lastSize;
    CGFloat maxWidth;
    CGFloat selfFrame;
}
@property(nonatomic,strong) UILabel *nickLab;// 客服昵称
@property(nonatomic,strong) UILabel *companyLab;// 企业昵称
@property(nonatomic,strong) SobotImageView *imgAvatar;
@property(nonatomic,strong) UILabel *titleLab;//中部标题
@property(nonatomic,strong) UILabel *contentLab;// 内容视图；
@property(nonatomic,assign) BOOL islandspace;// 是否是横屏
@property(nonatomic,assign) int imgWidth;
@property(nonatomic,assign) int imgSizeType;// 1.默认40 2 宽度 100
// 约束部分
@property(nonatomic,strong)NSLayoutConstraint *imgAvatarCY;
@property(nonatomic,strong)NSLayoutConstraint *imgAvatarEW;
@property(nonatomic,strong)NSLayoutConstraint *imgAvatarEH;
@property(nonatomic,strong)NSLayoutConstraint *imgAvatarPL;
@property(nonatomic,strong)NSLayoutConstraint *nickLabCY;
@property(nonatomic,strong)NSLayoutConstraint *companyLabCY;
@property(nonatomic,strong)NSLayoutConstraint *titleLabCY;
@end
@implementation ZCTitleView


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        self.userInteractionEnabled = YES;
        self.backgroundColor = UIColor.clearColor;
        [self layoutTitleUI];
    }
    return self;
}

-(void)layoutTitleUI{
    if(self.islandspace){
        self.imgWidth = 32;
    }else{
        self.imgWidth = 40;
    }
    
    // 系统导航栏的约束 通过内容视图来撑
    _contentLab = ({
        UILabel *iv = [[UILabel alloc]init];
        [self addSubview:iv];
        iv.backgroundColor = [UIColor clearColor];
        iv.numberOfLines = 0;
        iv.text = @"..........................................................................................................................................................................................................";
        [self addConstraint:sobotLayoutPaddingLeft(0, iv, self)];
        [self addConstraint:sobotLayoutPaddingRight(0, iv, self)];
        [self addConstraint:sobotLayoutEqualCenterY(0, iv, self)];
        [self addConstraint:sobotLayoutEqualCenterX(0, iv, self)];
        iv.textColor = UIColor.clearColor;
        iv;
    });
    
    _titleLab = ({
        UILabel *iv = [[UILabel alloc]init];
        iv = [[UILabel alloc] init];
        [iv setBackgroundColor:UIColor.clearColor];
        [iv setTextAlignment:NSTextAlignmentCenter];
        [iv setFont:[ZCUIKitTools zcgetTitleFont]];
        [iv setTextColor:[ZCUIKitTools zcgetTopViewTextColor]];
        iv.numberOfLines = 1;
        [self addSubview:iv];
        self.titleLabCY = sobotLayoutEqualCenterY(0, iv, self);
        [self addConstraint:self.titleLabCY];
        [self addConstraint:sobotLayoutEqualHeight(20, iv, NSLayoutRelationEqual)];
        [self addConstraint:sobotLayoutPaddingLeft(0, iv, self)];
        [self addConstraint:sobotLayoutPaddingRight(0, iv, self)];
        iv.hidden = YES;
        iv;
    });
    
    _imgAvatar = ({
        SobotImageView *iv = [[SobotImageView alloc] init];
        [iv setContentMode:UIViewContentModeScaleAspectFill];
        [iv setBackgroundColor:[UIColor clearColor]];
        iv.layer.cornerRadius= self.imgWidth/2;
        iv.layer.masksToBounds=YES;
//        iv.layer.borderWidth = 0.5f;
//        iv.layer.borderColor = UIColorFromKitModeColor(SobotColorWhite).CGColor;
        [self addSubview:iv];
        self.imgAvatarCY = sobotLayoutEqualCenterY(0, iv, self);
        [self addConstraint:self.imgAvatarCY];
        self.imgAvatarEW = sobotLayoutEqualWidth(self.imgWidth, iv, NSLayoutRelationEqual);
        [self addConstraint:self.imgAvatarEW];
        self.imgAvatarEH = sobotLayoutEqualHeight(self.imgWidth, iv, NSLayoutRelationEqual);
        [self addConstraint:self.imgAvatarEH];
        [self addConstraint:sobotLayoutPaddingLeft(0, iv, self)];
        iv.hidden = YES;
        iv;
    });
    
    _nickLab = ({
        UILabel *iv = [[UILabel alloc]init];
        iv = [[UILabel alloc] init];
        [iv setBackgroundColor:UIColor.clearColor];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setFont:SobotFont14];
        [iv setTextColor:[ZCUIKitTools zcgetTopViewTextColor]];
        iv.numberOfLines = 1;
        [self addSubview:iv];
        [self addConstraint:sobotLayoutMarginLeft(5, iv, self.imgAvatar)];
        [self addConstraint:sobotLayoutPaddingRight(0, iv, self)];
        self.nickLabCY = sobotLayoutEqualCenterY(-4-12, iv, self);
        [self addConstraint:self.nickLabCY];
        iv.hidden = YES;
        iv;
    });
    
    _companyLab = ({
        UILabel *iv = [[UILabel alloc]init];
        iv = [[UILabel alloc] init];
        [iv setBackgroundColor:UIColor.clearColor];
        [iv setTextAlignment:NSTextAlignmentLeft];
        [iv setFont:SobotFont12];
        [iv setTextColor:[ZCUIKitTools zcgetTopViewTextColor]];
        iv.numberOfLines = 1;
        [self addSubview:iv];
        [self addConstraint:sobotLayoutMarginLeft(5, iv, self.imgAvatar)];
        [self addConstraint:sobotLayoutPaddingRight(0, iv, self)];
        self.companyLabCY = sobotLayoutEqualCenterY(4+12, iv, self);
        [self addConstraint:self.companyLabCY];
        iv.hidden = YES;
        iv;
    });
    
}


#pragma mark - 设置图片
-(void)addImgWithUrl:(NSString *)imageUrl{
    if(sobotConvertToString(imageUrl).length > 0){
        UIImage *img = SobotKitGetImage(imageUrl);
        if(img){
            [_imgAvatar setImage:img];
        }else{
            [_imgAvatar loadWithURL:[NSURL URLWithString:sobotConvertToString(imageUrl)]];
        }
    }
}

#pragma mark - 刷新
-(void)setNickTitle:(NSString *)nickTitle companyTitle:(NSString*)companyTitle title:(NSString *)title image:(NSString *)imageUrl topBarType:(int)topBarType{
    _imgAvatar.hidden = YES;
    _titleLab.hidden = YES;
    _companyLab.hidden = YES;
    _nickLab.hidden = YES;
    _imgSizeType = topBarType;
    // 头像
    if (sobotConvertToString(imageUrl).length > 0) {
        _imgAvatar.hidden = NO;
        [self removeConstraint:self.imgAvatarEW];
        [self addImgWithUrl:imageUrl];
        if (self.imgSizeType == 1) {
            self.imgAvatarEW = sobotLayoutEqualWidth(self.imgWidth, self.imgAvatar, NSLayoutRelationEqual);
            self.imgAvatar.layer.cornerRadius = self.imgWidth/2;
            self.imgAvatar.contentMode = UIViewContentModeScaleAspectFill;
        }else{
            self.imgAvatarEW = sobotLayoutEqualWidth(100, self.imgAvatar, NSLayoutRelationEqual);
            self.imgAvatar.layer.cornerRadius = 0;
            self.imgAvatar.contentMode = UIViewContentModeScaleToFill; // 企业图标是长条状
        }
        [self addConstraint:self.imgAvatarEW];
    }else{
        // 不显示头像
        [self removeConstraint:self.imgAvatarEW];
        self.imgAvatarEW = sobotLayoutEqualWidth(0, self.imgAvatar, NSLayoutRelationEqual);
        [self addConstraint:self.imgAvatarEW];
    }
    
    // 排队中。。。 链接中 、暂无客服
    if (sobotConvertToString(title).length > 0) {
        _titleLab.hidden = NO;
        _titleLab.text = sobotConvertToString(title);
        return;
    }
    
    // 昵称 和 企业名称
    if (sobotConvertToString(nickTitle).length > 0 && sobotConvertToString(companyTitle).length >0) {
        self.nickLab.hidden = NO;
        if (self.nickLabCY) {
            [self removeConstraint:self.nickLabCY];
            self.nickLabCY = sobotLayoutEqualCenterY(-8, self.nickLab, self);
            [self addConstraint:self.nickLabCY];
            self.nickLab.text = sobotConvertToString(nickTitle);
        }
        self.companyLab.hidden = NO;
        if (self.companyLabCY) {
            [self removeConstraint:self.companyLabCY];
            self.companyLabCY = sobotLayoutEqualCenterY(8, self.companyLab, self);
            [self addConstraint:self.companyLabCY];
            self.companyLab.text = sobotConvertToString(companyTitle);
        }
    }else if(sobotConvertToString(nickTitle).length > 0 && sobotConvertToString(companyTitle).length ==0){
        self.nickLab.hidden = NO;
        [self removeConstraint:self.nickLabCY];
        self.nickLabCY = sobotLayoutEqualCenterY(0, self.nickLab, self);
        [self addConstraint:self.nickLabCY];
        self.nickLab.text = sobotConvertToString(nickTitle);
    }else if(sobotConvertToString(nickTitle).length == 0 && sobotConvertToString(companyTitle).length >0){
        self.companyLab.hidden = NO;
        [self removeConstraint:self.companyLabCY];
        self.companyLabCY = sobotLayoutEqualCenterY(0, self.companyLab, self);
        [self addConstraint:self.companyLabCY];
        self.companyLab.text = sobotConvertToString(companyTitle);
    }
    
#pragma mark - 处理文字是否要居中显示
    if (_imgAvatar.hidden) {
        if (_imgSizeType == 1) {
            if (!_nickLab.hidden && !_companyLab.hidden) {
                _nickLab.textAlignment = NSTextAlignmentCenter;
                _companyLab.textAlignment = NSTextAlignmentCenter;
                _nickLab.font = SobotFont14;
                _companyLab.font = SobotFont12;
            }else if (!_nickLab.hidden && _companyLab.hidden){
                _nickLab.textAlignment = NSTextAlignmentCenter;
                _nickLab.font = SobotFont16;
            }else if(_nickLab.hidden && !_companyLab.hidden){
                _companyLab.font = SobotFont16;
                _companyLab.textAlignment = NSTextAlignmentCenter;
            }
        }else if(_imgSizeType == 2){
            if (!_companyLab.hidden) {
                _companyLab.font = SobotFont16;
                _companyLab.textAlignment = NSTextAlignmentCenter;
            }
        }
    }else{
        if (_imgSizeType == 2) {
            // 方案二 如果头像和企业昵称同时有 只显示头像不显示昵称
            if (!_companyLab.hidden) {
                _contentLab.hidden = YES;
            }
        }
    }
}

// 监听暗黑模式变化
-(void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    [super traitCollectionDidChange:previousTraitCollection];
    if(sobotGetSystemDoubleVersion()>=13){
        // trait发生了改变
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            // 执行操作
            _imgAvatar.layer.borderColor = UIColorFromKitModeColor(SobotColorWhite).CGColor;
        }
    }
}

#pragma mark - 刷新子控件 横竖屏切换的时候 高度和大小不一样
-(void)setlayout:(BOOL)landspace{
    self.islandspace = landspace;
    if(!_imgAvatar.hidden){
        [self removeConstraint:self.imgAvatarEH];
        [self removeConstraint:self.imgAvatarEW];
        CGFloat imgH = self.imgWidth;
        if(landspace){
            self.imgWidth = 32;
            imgH = 32;
            if (self.imgSizeType == 2) {
                self.imgWidth = 100;
            }
        }else{
            self.imgWidth = 40;
            imgH = 40;
            if (self.imgSizeType == 2) {
                self.imgWidth = 100;
            }
        }
        self.imgAvatarEH = sobotLayoutEqualHeight(imgH, self.imgAvatar, NSLayoutRelationEqual);
        self.imgAvatarEW = sobotLayoutEqualWidth(self.imgWidth, self.imgAvatar, NSLayoutRelationEqual);
        if (self.imgSizeType == 1) {
            self.imgAvatar.layer.cornerRadius = self.imgWidth/2;
        }else if(self.imgSizeType == 2){
            self.imgAvatar.layer.cornerRadius = 0;
        }
        [self addConstraint:self.imgAvatarEH];
        [self addConstraint:self.imgAvatarEW];
    }
    if(!_titleLab.hidden){
        [self removeConstraint:self.titleLabCY];
        if(landspace){
            self.titleLabCY = sobotLayoutEqualCenterY(0, self.titleLab, self);
        }else{
            self.titleLabCY = sobotLayoutEqualCenterY(-10, self.titleLab, self);
        }
        [self addConstraint:self.titleLabCY];
    }
}

@end
