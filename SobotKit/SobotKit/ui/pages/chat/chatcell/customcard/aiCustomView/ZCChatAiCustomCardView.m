//
//  ZCChatAiCustomCardView.m
//  SobotKit
//
//  Created by lizh on 2025/3/19.
//

#import "ZCChatAiCustomCardView.h"
#import <SobotCommon/SobotCommon.h>
#import "ZCUIKitTools.h"
#import "ZCUICore.h"
#import <SobotChatClient/SobotChatClient.h>
@interface ZCChatAiCustomCardView()
{
    
}
@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UILabel *orderLab;
@property (nonatomic,strong) SobotImageView *iconImg;
@property (nonatomic,strong) UILabel *titelLab;
@property (nonatomic,strong) UILabel *descLab;
@property (nonatomic,strong) UILabel *leftNumLab;
@property (nonatomic,strong) UILabel *rightNumLab;
@property (nonatomic,strong) UIView *lineView;
// 按钮的背景
@property (nonatomic,strong) UIView *btnBgView;
// 自定义字段
@property (nonatomic,strong) UIView *fileView;

@property(nonatomic,strong) UIView *supView;
@property(nonatomic,assign) CGFloat maxW;
@property(nonatomic,strong) UIView *lastView;

@property(nonatomic,strong) UIView *fileLineView;

@property(nonatomic,strong) SobotButton *clickBtn;

// 约束
@property(nonatomic,strong) NSLayoutConstraint *iconImgW;
@property(nonatomic,strong) NSLayoutConstraint *iconImgH;
@property(nonatomic,strong) NSLayoutConstraint *iconImgL;
@property(nonatomic,strong) NSLayoutConstraint *iconImgMT;
@property(nonatomic,strong) NSLayoutConstraint *orderLabT;

@property(nonatomic,strong) NSLayoutConstraint *titelLabML;
@property(nonatomic,strong) NSLayoutConstraint *titelLabMT;

@property(nonatomic,strong) NSLayoutConstraint *descLabML;
@property(nonatomic,strong) NSLayoutConstraint *rightNumLabMT;

@property(nonatomic,strong) NSLayoutConstraint *fileLineViewH;
@property(nonatomic,strong) NSLayoutConstraint *fileViewMT;
@property(nonatomic,strong) NSLayoutConstraint *leftNumMT;
@property(nonatomic,strong) NSLayoutConstraint *descLabMT;

@property(nonatomic,assign) BOOL isHistory;
@property(nonatomic,assign) BOOL isUnBtn;
@end

@implementation ZCChatAiCustomCardView

-(UIView *)updateDict:(SobotChatCustomCardInfo* )dict maxW:(CGFloat)maxW supView:(UIView *)supView lastView:(UIView*)lastView isHistory:(BOOL)isHistory isUnBtn:(BOOL)isUnBtn{
    _supView = supView;
    _maxW = maxW;
    _lastView = lastView;
    _cardModel = dict;
    _isHistory = isHistory;
    _isUnBtn = isUnBtn;
    [self createSubViews];
    [_bgView layoutIfNeeded];
    return _bgView;
}

-(ZCChatAiCustomCardView*)initWithDict:(SobotChatCustomCardInfo* )dict maxW:(CGFloat)maxW supView:(UIView *)supView lastView:(UIView*)lastView {
    self = [super init];
    if (self) {
        _supView = supView;
        _maxW = maxW;
        _lastView = supView;
        _cardModel = dict;
        [self createSubViews];
        [_bgView layoutIfNeeded];
    }
    return self;
}

-(void)createSubViews{
    _bgView = ({
        UIView *iv = [[UIView alloc]init];
        iv.userInteractionEnabled = YES;
        iv.backgroundColor = UIColorFromKitModeColor(SobotColorBgMainDark3);
        [_supView addSubview:iv];
       
        if (sobotIsNull(_lastView)) {
            [_supView addConstraint:sobotLayoutPaddingTop(0, iv, _supView)];
        }else{
            [_supView addConstraint:sobotLayoutMarginTop(12, iv, _lastView)];
        }
        [_supView addConstraint:sobotLayoutPaddingLeft(0, iv, _supView)];
        [_supView addConstraint:sobotLayoutPaddingRight(0, iv, _supView)];
        iv.layer.cornerRadius = 4;
        iv.layer.masksToBounds = YES;
        iv;
    });
    
    _orderLab = ({
        UILabel *iv = [[UILabel alloc]init];
        [_bgView addSubview:iv];
        iv.font = SobotFont12;
        iv.numberOfLines = 0;
        iv.text = sobotConvertToString(_cardModel.customCardHeader);
        iv.textColor = UIColorFromKitModeColor(SobotColorTextSub1);
        self.orderLabT = sobotLayoutPaddingTop(8, iv, _bgView);
        [_bgView addConstraint:self.orderLabT];
        [_bgView addConstraint:sobotLayoutPaddingRight(-12, iv, _bgView)];
        [_bgView addConstraint:sobotLayoutPaddingLeft(12, iv, _bgView)];
        iv;
    });
    
    _iconImg = ({
        SobotImageView *iv = [[SobotImageView alloc]init];
        [_bgView addSubview:iv];
        self.iconImgW = sobotLayoutEqualWidth(64, iv, NSLayoutRelationEqual);
        [_bgView addConstraint:self.iconImgW];
        self.iconImgH = sobotLayoutEqualHeight(64, iv, NSLayoutRelationEqual);
        [_bgView addConstraint:self.iconImgH];
        self.iconImgL = sobotLayoutPaddingLeft(12, iv, _bgView);
        [_bgView addConstraint:self.iconImgL];
        self.iconImgMT = sobotLayoutMarginTop(8, iv, _orderLab);
        [_bgView addConstraint:self.iconImgMT];
        iv;
    });
    // 是否显示图片
    BOOL isShowIcon = sobotConvertToString(_cardModel.customCardThumbnail).length >0 ? YES:NO;
    // 有头像 显示头像
    if (isShowIcon) {
        self.iconImgW.constant = 64;
        self.iconImgH.constant = 64;
        [self.iconImg loadWithURL:[NSURL URLWithString:sobotConvertToString(_cardModel.customCardThumbnail)] placeholer:SobotKitGetImage(@"zcicon_default_goods_1")];
    }else{
        self.iconImgW.constant = 0;
        self.iconImgH.constant = 0;
    }
    
    
    _titelLab = ({
        UILabel *iv = [[UILabel alloc]init];
        [_bgView addSubview:iv];
        iv.font = SobotFont12;
        iv.numberOfLines = 2;
        iv.textColor = UIColorFromKitModeColor(SobotColorTextMain);
        self.titelLabML = sobotLayoutMarginLeft(8, iv, _iconImg);
        [_bgView addConstraint:self.titelLabML];
        [_bgView addConstraint:sobotLayoutPaddingRight(-12, iv, _bgView)];
        self.titelLabMT = sobotLayoutMarginTop(8, iv, _orderLab);
        [_bgView addConstraint:self.titelLabMT];
        iv;
    });
    
    if (isShowIcon) {
        self.titelLabML.constant = 8;
    }else{
        self.titelLabML.constant = 0;
    }
    if (sobotConvertToString(_cardModel.customCardName).length >0) {
        _titelLab.text = sobotConvertToString(_cardModel.customCardName);
    }else{
        _titelLab.text = @"";
    }
    
    _descLab = ({
        UILabel *iv = [[UILabel alloc]init];
        [_bgView addSubview:iv];
        iv.font = SobotFont12;
        iv.textColor = UIColorFromKitModeColor(SobotColorTextSub1);
        iv.numberOfLines = 1;
        _descLabML = sobotLayoutMarginLeft(8, iv, _iconImg);
        [_bgView addConstraint:_descLabML];
        [_bgView addConstraint:sobotLayoutPaddingRight(-12, iv, _bgView)];
        self.descLabMT = sobotLayoutMarginTop(4, iv, _titelLab);
        [_bgView addConstraint:self.descLabMT];
        iv;
    });
    
    
    if (isShowIcon) {
        self.descLabML.constant = 8;
    }else{
        self.descLabML.constant = 0;
    }
    
    if (sobotConvertToString(_cardModel.customCardDesc).length >0) {
        _descLab.text = sobotConvertToString(_cardModel.customCardDesc);
        self.descLabMT.constant = 4;
    }else{
        _descLab.text = 0;
        self.descLabMT.constant = 0;
    }

    NSString *leftStr = @"";
    // 商品数
    if (sobotConvertToString(_cardModel.customCardCount).length >0) {
        leftStr = [NSString stringWithFormat:@"%@",sobotConvertToString(_cardModel.customCardCount)];
    }
    NSString *rightStr = @"";
    if (sobotConvertToString(_cardModel.customCardAmountSymbol).length >0 || sobotConvertToString(_cardModel.customCardAmount).length >0 ) {
        rightStr = [NSString stringWithFormat:@"%@%@",sobotConvertToString(_cardModel.customCardAmountSymbol),sobotConvertToString(_cardModel.customCardAmount)];
    }
//    @"合计文案文：$800.99";
    
    CGFloat w1 = [SobotUITools getWidthContain:leftStr font:SobotFont12 Height:20];
    CGFloat w2 = [SobotUITools getWidthContain:rightStr font:SobotFont12 Height:20];
    
    // 是否是多行
    BOOL isMoreLine = NO;
    if (w1+w2>_maxW -24 -8) {
        isMoreLine = YES;
    }
        
    _leftNumLab = ({
        UILabel *iv = [[UILabel alloc]init];
        [_bgView addSubview:iv];
        iv.numberOfLines = 1;
        iv.font = SobotFont12;
        iv.textAlignment = NSTextAlignmentLeft;
        iv.textColor = UIColorFromKitModeColor(SobotColorTextSub1);
        [_bgView addConstraint:sobotLayoutPaddingLeft(12, iv, _bgView)];
        if (isShowIcon) {
            _leftNumMT = sobotLayoutMarginTop(8, iv, _iconImg);
        }else{
            _leftNumMT = sobotLayoutMarginTop(8, iv, _descLab);
        }
        [_bgView addConstraint:_leftNumMT];
        
        if (isMoreLine) {
            [_bgView addConstraint:sobotLayoutPaddingRight(-12, iv, _bgView)];
        }else{
            [_bgView addConstraint:sobotLayoutEqualWidth((_maxW-24-8)/2, iv, NSLayoutRelationEqual)];
        }
        [_bgView addConstraint:sobotLayoutEqualHeight(20, iv, NSLayoutRelationGreaterThanOrEqual)];
        iv;
    });
    
    _rightNumLab = ({
        UILabel *iv = [[UILabel alloc]init];
        [_bgView addSubview:iv];
        iv.numberOfLines = 1;
        iv.font = SobotFont12;
        iv.textAlignment = NSTextAlignmentRight;
        iv.textColor = UIColorFromKitModeColor(SobotColorTextSub1);
        [_bgView addConstraint:sobotLayoutPaddingRight(-12, iv, _bgView)];
        if (isMoreLine) {
            [_bgView addConstraint:sobotLayoutPaddingLeft(12, iv, _bgView)];
            _rightNumLabMT = sobotLayoutMarginTop(4, iv, _leftNumLab);
            [_bgView addConstraint:_rightNumLabMT];
        }else{
            if (isShowIcon) {
                _rightNumLabMT = sobotLayoutMarginTop(8, iv, _iconImg);
            }else{
                _rightNumLabMT = sobotLayoutMarginTop(8, iv, _descLab);
            }
            [_bgView addConstraint:_rightNumLabMT];
            [_bgView addConstraint:sobotLayoutEqualWidth((_maxW-24-8)/2, iv, NSLayoutRelationEqual)];
            [_bgView addConstraint:sobotLayoutEqualHeight(20, iv, NSLayoutRelationGreaterThanOrEqual)];
        }
        iv;
    });
    
    if (leftStr.length >0) {
        _leftNumLab.text = leftStr;
    }else{
        _leftNumMT.constant = 0;
    }
    
    if (rightStr.length >0) {
        _rightNumLab.text = rightStr;
    }else{
        _rightNumLabMT.constant = 0;
    }
    
    _fileView = ({
        UIView *iv = [[UIView alloc]init];
        [_bgView addSubview:iv];
        self.fileViewMT = sobotLayoutMarginTop(8, iv, _rightNumLab);
        [_bgView addConstraint:self.fileViewMT];
        [_bgView addConstraint:sobotLayoutPaddingLeft(12, iv, _bgView)];
        [_bgView addConstraint:sobotLayoutPaddingRight(-12, iv, _bgView)];
        iv;
    });
    
    _fileLineView = ({
        UIView *iv = [[UIView alloc]init];
        [_fileView addSubview:iv];
        iv.backgroundColor = UIColorFromKitModeColor(SobotColorBgTopLine);
        [_fileView addConstraint:sobotLayoutPaddingTop(0, iv, _fileView)];
        [_fileView addConstraint:sobotLayoutPaddingLeft(0, iv, _fileView)];
        [_fileView addConstraint:sobotLayoutPaddingRight(0, iv, _fileView)];
        self.fileLineViewH = sobotLayoutEqualHeight(0.5, iv, NSLayoutRelationEqual);
        [_fileView addConstraint:self.fileLineViewH];
        iv;
    });
    
    if (_fileLineView) {
        [_fileLineView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    if (!sobotIsNull(_cardModel.customField) && _cardModel.customField.count > 0) {
        self.fileViewMT.constant = 8;
        UILabel *lastLab = nil;
        for (int i = 0; i<_cardModel.customField.count; i++) {
            NSDictionary *filedDict = _cardModel.customField[i];
            NSString *key = [[filedDict allKeys] firstObject];
            NSDictionary *map = [filedDict objectForKey:key];
            NSString *value = sobotConvertToString([map objectForKey:@"paramValue"]);
            UILabel *lab = [self createLabWithKey:key value:value lastfile:lastLab];
            lastLab = lab;
        }
        if (!sobotIsNull(lastLab)) {
            [_fileView addConstraint:sobotLayoutPaddingBottom(-8, lastLab, _fileView)];
        }
    }else{
        self.fileLineViewH.constant = 0.75f;
        self.fileViewMT.constant = 0;
    }
    
    if (_isUnBtn) {
        // 不显示按钮
        NSLayoutConstraint *btnBgPB = sobotLayoutPaddingBottom(0, _fileView, _bgView);
        btnBgPB.priority = UILayoutPriorityDefaultHigh;
        [_bgView addConstraint:btnBgPB];
    }else{
        _btnBgView = ({
            UIView *iv = [[UIView alloc]init];
            [_bgView addSubview:iv];
            [_bgView addConstraint:sobotLayoutPaddingLeft(0, iv, _bgView)];
            [_bgView addConstraint:sobotLayoutPaddingRight(0, iv, _bgView)];
            [_bgView addConstraint:sobotLayoutMarginTop(0, iv, _fileView)];
            NSLayoutConstraint *btnBgPB = sobotLayoutPaddingBottom(0, iv, _bgView);
            btnBgPB.priority = UILayoutPriorityDefaultHigh;
            [_bgView addConstraint:btnBgPB];
            iv;
        });
        
        if (!sobotIsNull(_btnBgView)) {
            [_btnBgView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        UIButton *lastBtn = nil;
        if (!sobotIsNull( _cardModel.customMenus) && _cardModel.customMenus.count >0) {
            for (int i = 0; i<_cardModel.customMenus.count; i++) {
                UIButton* iv = [self createCustomBtn:_cardModel.customMenus[i] lastBtn:lastBtn];
                lastBtn = iv;
            }
            if (!sobotIsNull(lastBtn)) {
                [_btnBgView addConstraint:sobotLayoutPaddingBottom(0, lastBtn, _btnBgView)];
            }
        }
    }
    
   
    
    //点击按钮
    _clickBtn =({
        SobotButton *iv = [SobotButton buttonWithType:UIButtonTypeCustom];
        [_bgView addSubview:iv];
        iv.obj = _cardModel;
        iv.tag = 1;
        [iv setBackgroundColor:UIColor.clearColor];
        [iv addTarget:self action:@selector(clickCard:) forControlEvents:UIControlEventTouchUpInside];
        [_bgView addConstraint:sobotLayoutPaddingTop(0, iv, _bgView)];
        [_bgView addConstraint:sobotLayoutPaddingLeft(0, iv, _bgView)];
        [_bgView addConstraint:sobotLayoutPaddingRight(0, iv, _bgView)];
        iv.backgroundColor = UIColor.redColor;
        [_bgView addConstraint:sobotLayoutPaddingBottom(0, iv, _fileView)];
        
        iv;
    });
    
}


#pragma mark -- 循环创建 自定义字段
-(UILabel *)createLabWithKey:(NSString *)key value:(NSString *)value lastfile:(UILabel *)lastFile{
    UILabel *iv = [[UILabel alloc]init];
    iv.font = SobotFont12;
    iv.textColor = UIColorFromKitModeColor(SobotColorTextMain);
    [_fileView addSubview:iv];
    iv.numberOfLines = 0;
    iv.text = [NSString stringWithFormat:@"%@: %@",key,value];
    [_fileView addConstraint:sobotLayoutPaddingLeft(0, iv, _fileView)];
    [_fileView addConstraint:sobotLayoutPaddingRight(0, iv, _fileView)];
    if (lastFile) {
        [_fileView addConstraint:sobotLayoutMarginTop(4, iv, lastFile)];
    }else{
        [_fileView addConstraint:sobotLayoutPaddingTop(8, iv, _fileView)];
    }
    return iv;
}

#pragma mark -- 循环创建按钮
-(UIButton *)createCustomBtn:(SobotChatCustomCardMenu *)menu lastBtn:(UIButton *)lastBtn{
    SobotButton *iv = [SobotButton buttonWithType:UIButtonTypeCustom];
    [iv setTitle:sobotConvertToString(menu.menuName) forState:0];
    [iv setTitleColor:[ZCUIKitTools zcgetServerConfigBtnBgColor] forState:0];
    iv.titleLabel.font = SobotFont14;
    iv.obj = menu;
    [iv addTarget:self action:@selector(customMenusBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_btnBgView addSubview:iv];
    [_btnBgView addConstraint:sobotLayoutPaddingLeft(0, iv, _btnBgView)];
    [_btnBgView addConstraint:sobotLayoutPaddingRight(0, iv, _btnBgView)];
    
    // 按钮的上线间距 12
    CGFloat itemH = [SobotUITools getMaxHeightContain:iv.titleLabel.text font:SobotFont14 width:self.maxW -24];
    itemH = itemH +24;
    [_btnBgView addConstraint:sobotLayoutEqualHeight(itemH, iv, NSLayoutRelationEqual)];
    if (!sobotIsNull(lastBtn)) {
        [_btnBgView addConstraint:sobotLayoutMarginTop(0, iv, lastBtn)];
    }else{
        [_btnBgView addConstraint:sobotLayoutPaddingTop(0, iv, _btnBgView)];
    }
    
    UIView *line = [[UIView alloc]init];
    line.backgroundColor = UIColorFromKitModeColor(SobotColorBgTopLine);
    [iv addSubview:line];
    [iv addConstraint:sobotLayoutPaddingTop(0, line, iv)];
    [iv addConstraint:sobotLayoutPaddingLeft(0, line, iv)];
    [iv addConstraint:sobotLayoutPaddingRight(0, line, iv)];
    [iv addConstraint:sobotLayoutEqualHeight(0.5, line, NSLayoutRelationEqual)];
    return iv;
   
}

#pragma mark -- 点击整个卡片
-(void)clickCard:(SobotButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickType:obj:Menu:)]) {
        [self.delegate clickType:1 obj:_cardModel Menu:nil];
    }
}

#pragma mark -- 点击事件
-(void)customMenusBtnClick:(SobotButton *)sender{
    SobotChatCustomCardMenu *info = (SobotChatCustomCardMenu*)(sender.obj);
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickType:obj:Menu:)]) {
        // 0 发送 1 跳转
        if (info.menuType == 0) {
            [self.delegate clickType:3 obj:_cardModel Menu:info];
        }else{
            [self.delegate clickType:2 obj:_cardModel Menu:info];
        }
    }
}

@end
