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
#import "ZCUICore.h"
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

@property(nonatomic,strong) SobotImageView *imgCompanyLogo;

@property(nonatomic,strong) UILabel *titleLab;//中部标题
@property(nonatomic,strong) UILabel *contentLab;// 内容视图；
@property(nonatomic,assign) BOOL islandspace;// 是否是横屏
@property(nonatomic,assign) int imgSizeType;// 1.默认40 2 宽度 100
// 约束部分
@property(nonatomic,strong)NSLayoutConstraint *imgAvatarCY;
@property(nonatomic,strong)NSLayoutConstraint *imgAvatarEW;
@property(nonatomic,strong)NSLayoutConstraint *imgAvatarEH;
// 左或者右
@property(nonatomic,strong)NSLayoutConstraint *imgAvatarLOR;
@property(nonatomic,strong)NSLayoutConstraint *imgLogoEH;

@property(nonatomic,strong)NSLayoutConstraint *nickLabCY;
@property(nonatomic,strong)NSLayoutConstraint *companyLabCY;
@property(nonatomic,strong)NSLayoutConstraint *titleLabCY;

@property(nonatomic,strong)NSLayoutConstraint *nickLabL;
@property(nonatomic,strong)NSLayoutConstraint *nickLabR;
@property(nonatomic,strong)NSLayoutConstraint *companyLabL;
@property(nonatomic,strong)NSLayoutConstraint *companyLabR;

@property(nonatomic,strong)NSLayoutConstraint *imgCompanyLogoCX;
// 是否阿语镜像过
@property(nonatomic,assign)BOOL arRTL;
// 是否切换语言 从阿语 其他到其他语言 处理过镜像反转了
@property(nonatomic,assign)BOOL otherRTL;
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
        [self addConstraint:sobotLayoutPaddingLeft(8, iv, self)];
        [self addConstraint:sobotLayoutPaddingRight(-8, iv, self)];
        iv.hidden = YES;
        iv;
    });
    
    _imgAvatar = ({
        SobotImageView *iv = [[SobotImageView alloc] init];
//        [iv setContentMode:UIViewContentModeScaleAspectFill];
        [iv setContentMode:UIViewContentModeScaleAspectFit];
        [iv setBackgroundColor:[UIColor clearColor]];
        iv.layer.cornerRadius= 32/2;
        iv.layer.masksToBounds=YES;
//        iv.layer.borderWidth = 0.5f;
//        iv.layer.borderColor = UIColorFromKitModeColor(SobotColorWhite).CGColor;
        [self addSubview:iv];
        self.imgAvatarCY = sobotLayoutEqualCenterY(0, iv, self);
        [self addConstraint:self.imgAvatarCY];
        self.imgAvatarEW = sobotLayoutEqualWidth(32, iv, NSLayoutRelationEqual);
        [self addConstraint:self.imgAvatarEW];
        self.imgAvatarEH = sobotLayoutEqualHeight(32, iv, NSLayoutRelationEqual);
        [self addConstraint:self.imgAvatarEH];
        self.imgAvatarLOR = sobotLayoutPaddingLeft(0, iv, self);
        [self addConstraint:self.imgAvatarLOR];
        iv.hidden = YES;
        iv;
    });
    
    
    _imgCompanyLogo = ({
        SobotImageView *iv = [[SobotImageView alloc] init];
        [iv setContentMode:UIViewContentModeScaleAspectFit];
        [iv setBackgroundColor:[UIColor clearColor]];
        [self addSubview:iv];
        [self addConstraint:sobotLayoutEqualCenterY(0, iv, self)];
        self.imgCompanyLogoCX = sobotLayoutEqualCenterX(0, iv, self);
        [self addConstraint:self.imgCompanyLogoCX];
        [self addConstraint:sobotLayoutEqualWidth(100, iv, NSLayoutRelationEqual)];
        self.imgLogoEH = sobotLayoutEqualHeight(40, iv, NSLayoutRelationEqual);
        [self addConstraint:self.imgLogoEH];
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
        _nickLabL = sobotLayoutMarginLeft(8, iv, self.imgAvatar);
        [self addConstraint:_nickLabL];
        _nickLabR = sobotLayoutPaddingRight(-8, iv, self);
        [self addConstraint:_nickLabR];
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
        _companyLabL = sobotLayoutMarginLeft(8, iv, self.imgAvatar);
        [self addConstraint:_companyLabL];
        _companyLabR = sobotLayoutPaddingRight(-8, iv, self);
        [self addConstraint:_companyLabR];
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
            
            [_imgCompanyLogo setImage:img];
        }else{
            [_imgAvatar loadWithURL:[NSURL URLWithString:sobotConvertToString(imageUrl)] placeholer:nil showActivityIndicatorView:YES];
            
            
            [_imgCompanyLogo loadWithURL:[NSURL URLWithString:sobotConvertToString(imageUrl)] placeholer:nil showActivityIndicatorView:YES];
        }
    }
}

#pragma mark - 刷新
-(void)setNickTitle:(NSString *)nickTitle companyTitle:(NSString*)companyTitle title:(NSString *)title image:(NSString *)imageUrl topBarType:(int)topBarType{
    
    if (self.imgAvatarLOR) {
        [self removeConstraint:self.imgAvatarLOR];
    }
    if (self.nickLabL) {
        [self removeConstraint:self.nickLabL];
    }
    if (self.nickLabR) {
        [self removeConstraint:self.nickLabR];
    }
    
    if (self.companyLabL) {
        [self removeConstraint:self.companyLabL];
    }
    if (self.companyLabR) {
        [self removeConstraint:self.companyLabR];
    }
    
    // 先处理镜像  通过约束强制转换
    if ([ZCUIKitTools getSobotIsRTLLayout]) {
        self.imgAvatarLOR = sobotLayoutPaddingRight(0, _imgAvatar, self);
        [self addConstraint:self.imgAvatarLOR];
        _nickLabL = sobotLayoutMarginRight(-8, _nickLab, self.imgAvatar);
        [self addConstraint:_nickLabL];
        _nickLabR = sobotLayoutPaddingLeft(8, _nickLab, self);
        [self addConstraint:_nickLabR];
        
        _companyLabL = sobotLayoutMarginRight(-8, _companyLab, self.imgAvatar);
        [self addConstraint:_companyLabL];
        _companyLabR = sobotLayoutPaddingLeft(8, _companyLab, self);
        [self addConstraint:_companyLabR];
        [_nickLab setTextAlignment:NSTextAlignmentRight];
        [_companyLab setTextAlignment:NSTextAlignmentRight];
    }else{
        // 非镜像的
        self.imgAvatarLOR = sobotLayoutPaddingLeft(0, _imgAvatar, self);
        [self addConstraint:self.imgAvatarLOR];
        _nickLabL = sobotLayoutMarginLeft(8, _nickLab, self.imgAvatar);
        [self addConstraint:_nickLabL];
        _nickLabR = sobotLayoutPaddingRight(-8, _nickLab, self);
        [self addConstraint:_nickLabR];
        
        _companyLabL = sobotLayoutMarginLeft(8, _companyLab, self.imgAvatar);
        [self addConstraint:_companyLabL];
        _companyLabR = sobotLayoutPaddingRight(-8, _companyLab, self);
        [self addConstraint:_companyLabR];
        [_nickLab setTextAlignment:NSTextAlignmentLeft];
        [_companyLab setTextAlignment:NSTextAlignmentLeft];
    }
    
    _imgAvatar.hidden = YES;
    _titleLab.hidden = YES;
    _companyLab.hidden = YES;
    _nickLab.hidden = YES;
    _imgCompanyLogo.hidden = YES;
    _nickLabL.constant = 0;
    _companyLabL.constant = 0;
    _imgSizeType = topBarType;
    [_nickLab setFont:SobotFontBold14];
    [_companyLab setFont:SobotFont12];
    
    // 排队中。。。 链接中 、暂无客服
    if (sobotConvertToString(title).length > 0) {
        _titleLab.hidden = NO;
        _titleLab.text = sobotConvertToString(title);
        return;
    }
    
    // 头像
    if (sobotConvertToString(imageUrl).length > 0) {
        [self addImgWithUrl:imageUrl];
        if (self.imgSizeType == 1) {
            _imgAvatar.hidden = NO;
            self.imgAvatarEW.constant = 32;
            self.imgAvatarEH.constant = 32;
            self.imgAvatar.layer.cornerRadius = self.imgAvatarEH.constant/2;
            self.imgAvatar.contentMode = UIViewContentModeScaleAspectFill;
            if ([ZCUIKitTools getSobotIsRTLLayout]) {
                _nickLabL.constant = -8;
                _companyLabL.constant = -8;
            }else{
                _nickLabL.constant = 8;
                _companyLabL.constant = 8;
            }
        }else{
            self.imgAvatarEW.constant = 0;
            _imgCompanyLogo.contentMode = UIViewContentModeScaleAspectFit; // 企业图标是长条状
            _imgCompanyLogo.hidden = NO;
            self.imgLogoEH.constant = 40;
            if(self.islandspace){
                self.imgLogoEH.constant = 32;
            }
        }
    }else{
        // 不显示头像
        self.imgAvatarEW.constant = 0;
    }
    
    // 昵称 和 企业名称
    if (sobotConvertToString(nickTitle).length > 0 && sobotConvertToString(companyTitle).length >0) {
        // 昵称和企业名称都有
        self.nickLab.hidden = NO;
        self.companyLab.hidden = NO;
        if (self.nickLabCY) {
            self.nickLabCY.constant = -8;
            self.nickLab.text = sobotConvertToString(nickTitle);
        }
        if (self.companyLabCY) {
            self.companyLabCY.constant = 8;
            self.companyLab.text = sobotConvertToString(companyTitle);
        }
    }else if(sobotConvertToString(nickTitle).length > 0 && sobotConvertToString(companyTitle).length ==0){
        // 有昵称，没有企业名称
        self.nickLab.hidden = NO;
        self.nickLabCY.constant = 0;
        self.nickLab.text = sobotConvertToString(nickTitle);
        
        // 只有一行，设置大字体
        self.nickLab.font = [ZCUIKitTools zcgetTitleFont];
    }else if(sobotConvertToString(nickTitle).length == 0 && sobotConvertToString(companyTitle).length >0){
        // 有企业名称，没有昵称
        self.companyLab.hidden = NO;
        self.companyLabCY.constant = 0;
        self.companyLab.text = sobotConvertToString(companyTitle);
        // 只有一行，设置大字体
        self.companyLab.font = [ZCUIKitTools zcgetTitleFont];
    }
    
#pragma mark - 处理文字是否要居中显示
    if (_imgAvatar.hidden) {
        if (_imgSizeType == 1) {
            if (!_nickLab.hidden && !_companyLab.hidden) {
                _nickLab.textAlignment = NSTextAlignmentCenter;
                _companyLab.textAlignment = NSTextAlignmentCenter;
                _nickLab.font = SobotFontBold15;
                _companyLab.font = SobotFont12;
            }else if (!_nickLab.hidden && _companyLab.hidden){
                // 只有昵称文字靠边显示
//                _nickLab.textAlignment = NSTextAlignmentCenter;
                _nickLab.font = SobotFont16;
                if ([ZCUIKitTools getSobotIsRTLLayout]) {
                    _nickLab.textAlignment = NSTextAlignmentRight;
                }else{
                    _nickLab.textAlignment = NSTextAlignmentLeft;
                }
            }else if(_nickLab.hidden && !_companyLab.hidden){
                _companyLab.font = SobotFont16;
//                _companyLab.textAlignment = NSTextAlignmentCenter;
                if ([ZCUIKitTools getSobotIsRTLLayout]) {
                    _companyLab.textAlignment = NSTextAlignmentRight;
                }else{
                    _companyLab.textAlignment = NSTextAlignmentLeft;
                }
            }
        }else if(_imgSizeType == 2){
            if (!_companyLab.hidden) {
                _companyLab.font = SobotFont16;
                _companyLab.textAlignment = NSTextAlignmentCenter;
            }
        }
    }else{
        // 此情况应该不存在，存在此情况则不存在logo居中情况
        if ([ZCUIKitTools getSobotIsRTLLayout]) {
            self.companyLab.textAlignment = NSTextAlignmentRight;
            self.nickLab.textAlignment = NSTextAlignmentRight;
        }
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
        if (@available(iOS 13.0, *)) {
            if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
                // 执行操作
                _imgAvatar.layer.borderColor = UIColorFromKitModeColor(SobotColorWhite).CGColor;
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

#pragma mark - 刷新子控件 横竖屏切换的时候 高度和大小不一样
-(void)setlayout:(BOOL)landspace{
    self.islandspace = landspace;
    if(!_imgAvatar.hidden){
        self.imgAvatarEH.constant = 32;
        self.imgAvatarEW.constant = 32;
    }
    if(!_imgCompanyLogo.hidden){
        if(landspace){
            self.imgLogoEH.constant = 32;
        }else{
            self.imgLogoEH.constant = 40;
        }
    }
    if(!_titleLab.hidden){
        if(landspace){
            self.titleLabCY.constant = 0;
        }else{
            self.titleLabCY.constant = -10;
        }
    }
}

-(void)setLogoImgLayrightItem:(NSArray*)rightItem leftItem:(NSArray *)leftItem{
    int count = (int)(rightItem.count + leftItem.count);
    if (count >2) {
        if (rightItem.count >leftItem.count) {
            _imgCompanyLogoCX.constant = (int)(rightItem.count -leftItem.count)*40/2;
        }else{
            _imgCompanyLogoCX.constant = -(int)(leftItem.count-rightItem.count)*40/2;
        }
    }
}

@end
