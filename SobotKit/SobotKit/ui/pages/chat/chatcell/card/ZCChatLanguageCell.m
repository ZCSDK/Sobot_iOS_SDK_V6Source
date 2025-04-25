//
//  ZCChatLanguageCell.m
//  SobotKit
//
//  Created by lizh on 2024/10/16.
//

#import "ZCChatLanguageCell.h"
#import <SobotChatClient/ZCLanguageModel.h>
@interface ZCChatLanguageCell()
@property(nonatomic,strong)UIView *bgView;
@property(nonatomic,strong)UILabel *tiplab;
@property(nonatomic,strong)UIView *selContentView;
@property(nonatomic,strong)NSLayoutConstraint *bgViewPT;
@end

@implementation ZCChatLanguageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self createViews];
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self createViews];
    }
    return self;
}


-(void)createViews{
    _bgView = ({
        UIView *iv = [[UIView alloc] init];
        [iv setBackgroundColor:[ZCUIKitTools zcgetLightGrayDarkBackgroundColor]];
        iv.layer.cornerRadius = 4.0f;
        iv.layer.masksToBounds = YES;
        [self.contentView addSubview:iv];
        self.bgViewPT = sobotLayoutPaddingTop(ZCChatMarginVSpace, iv, self.contentView);
        [self.contentView addConstraint:self.bgViewPT];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(ZCChatMarginHSpace, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutEqualWidth(300, iv, NSLayoutRelationEqual)];
        [self.contentView addConstraint:sobotLayoutPaddingBottom(-ZCChatMarginVSpace, iv, self.contentView)];
        iv;
    });
    
    _tiplab = ({
        UILabel *iv = [[UILabel alloc]init];
        [self.bgView addSubview:iv];
        [iv setTextColor:[ZCUIKitTools zcgetLeftChatTextColor]];
        iv.font = SobotFont14;
        iv.text = SobotKitLocalString(@"请选择您要使用的聊天语言：");
        if ([[[ZCUICore getUICore] getLibConfig].language isEqual:@"العربية"] || ([ZCLibClient getZCLibClient].libInitInfo.absolute_language && [sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.absolute_language) isEqualToString:@"ar"])) {
            iv.text = @"الرجاء تحديد اللغة التي تريد الدردشة بها:";
        }
        iv.numberOfLines = 0;
        [self.bgView addConstraint:sobotLayoutPaddingTop(12, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(ZCChatMarginVSpace, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatMarginVSpace, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutEqualHeight(22, iv, NSLayoutRelationGreaterThanOrEqual)];
        iv;
    });
    
    _selContentView = ({
        UIView *iv = [[UIView alloc]init];
        [self.bgView addSubview:iv];
        iv.backgroundColor = UIColor.clearColor;
        [self.bgView addConstraint:sobotLayoutMarginTop(0, iv, self.tiplab)];
        [self.bgView addConstraint:sobotLayoutPaddingLeft(ZCChatMarginVSpace, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingRight(-ZCChatMarginVSpace, iv, self.bgView)];
        [self.bgView addConstraint:sobotLayoutPaddingBottom(0, iv, self.bgView)];
        iv;
    });
    
    
    
}

-(void)initDataToView:(SobotChatMessage *)message time:(NSString *)showTime{
    [super initDataToView:message time:showTime];
    if (![showTime isEqualToString:@""]) {
        self.bgViewPT.constant = ZCChatMarginVSpace + 30;
    }
    if ([[ZCUICore getUICore] getLibConfig].languageArr && [[ZCUICore getUICore] getLibConfig].languageArr.count >0) {
        // 设置中间的列表数据
        UIView *lastView ;
        if ([[ZCUICore getUICore] getLibConfig].languageArr.count <= 6) {
            for (ZCLanguageModel *model in [[ZCUICore getUICore] getLibConfig].languageArr) {
                lastView = [self createLanguageBtn:model lastView:lastView];
            }
        }else{
            for (int i = 0; i<6; i++) {
                ZCLanguageModel *model = [[ZCUICore getUICore] getLibConfig].languageArr[i];
                lastView = [self createLanguageBtn:model lastView:lastView];
            }
        }
        
        if ([[ZCUICore getUICore] getLibConfig].languageArr.count >6) {
            // 更多语言
            ZCLanguageModel *moreModel = [[ZCLanguageModel alloc]init];
            moreModel.lan = 100;
            moreModel.name = SobotKitLocalString(@"更多语言");
            if ([[[ZCUICore getUICore] getLibConfig].language isEqual:@"العربية"] || ([ZCLibClient getZCLibClient].libInitInfo.absolute_language && [sobotConvertToString([ZCLibClient getZCLibClient].libInitInfo.absolute_language) isEqualToString:@"ar"])) {
                moreModel.name = @"المزيد من اللغات";
            }
            moreModel.code = @"";
            lastView = [self createLanguageBtn:moreModel lastView:lastView];
        }
        // 最后一个数据
        if (lastView) {
            [self.selContentView addConstraint:sobotLayoutPaddingBottom(-ZCChatMarginVSpace, lastView, self.selContentView)];
        }
    }
    
//    _layoutBgWidth.constant = self.maxWidth+ZCChatPaddingHSpace*2;
//    [self.bgView layoutIfNeeded];
//    [self setChatViewBgState:CGSizeMake(self.maxWidth,CGRectGetMaxX(_lookMore.frame))];
//    self.ivBgView.backgroundColor = [UIColor clearColor];
}

-(SobotButton *)createLanguageBtn:(ZCLanguageModel *)model lastView:(UIView*)lastView{
    SobotButton *iv = [SobotButton buttonWithType:UIButtonTypeCustom];
    iv.obj = model;
    [self.selContentView addSubview:iv];
    [iv setTitle:sobotConvertToString(model.name) forState:0];
    [iv setTitleColor:[ZCUIKitTools zcgetServerConfigBtnBgColor] forState:0];
    [iv setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMain)];
    iv.titleLabel.font = SobotFont14;
    iv.layer.cornerRadius = 4;
    iv.layer.masksToBounds = YES;
    [iv addTarget:self action:@selector(selLanguageAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.selContentView addConstraint:sobotLayoutEqualHeight(36, iv, NSLayoutRelationEqual)];
    [self.selContentView addConstraint:sobotLayoutPaddingLeft(0, iv, self.selContentView)];
    [self.selContentView addConstraint:sobotLayoutPaddingRight(0, iv, self.selContentView)];
    if (sobotIsNull(lastView)) {
        [self.selContentView addConstraint:sobotLayoutPaddingTop(12, iv, self.selContentView)];
    }else{
        [self.selContentView addConstraint:sobotLayoutMarginTop(12, iv, lastView)];
    }
    return iv;
}

#pragma mark -- 切换语言
-(void)selLanguageAction:(SobotButton*)sender{
    ZCLanguageModel *moreModel = (ZCLanguageModel *)(sender.obj);
    if ([moreModel.name isEqualToString:SobotKitLocalString(@"更多语言")] || [moreModel.name isEqualToString:@"المزيد من اللغات"]) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
            [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeOpenMoreLanguage text:sobotConvertToString(moreModel.code)  obj:moreModel];
        }
    }else{
        sender.enabled = NO;
        if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
            [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeSelLanguage text:sobotConvertToString(moreModel.code)  obj:moreModel];
        }
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


@end
