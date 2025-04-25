//
//  ZCZHPickView.m
//  ZCZHPickView
//
//  Created by liudianling on 14-11-18.
//  Copyright (c) 2014年 赵恒志. All rights reserved.
//
#import "ZCZHPickView.h"
#import <SobotCommon/SobotCommon.h>
#import <SobotChatClient/SobotChatClient.h>
#define ZHToobarHeight 52

#import "ZCUIKitTools.h"
#define ZCCommitHeight 40
@interface ZCZHPickView ()<UIPickerViewDelegate,UIPickerViewDataSource>
@property(nonatomic,copy)NSString *plistName;
@property(nonatomic,strong)NSArray *plistArray;
@property(nonatomic,assign)BOOL isLevelArray;
@property(nonatomic,assign)BOOL isLevelString;
@property(nonatomic,assign)BOOL isLevelDic;
@property(nonatomic,strong)NSDictionary *levelTwoDic;
@property (nonatomic,strong) UIButton * rightBtn;
@property (nonatomic,strong) UIButton * commitBtn;
@property (nonatomic,strong) UIView * commitBgView;
@property (nonatomic,strong) UIView * toolbarView;
@property (nonatomic,strong) UILabel * labelTitle;
@property(nonatomic,strong)UIPickerView *pickerView;
@property(nonatomic,strong)UIDatePicker *datePicker;
@property(nonatomic,assign)NSDate *defaulDate;
@property(nonatomic,assign)BOOL isHaveNavControler;
@property(nonatomic,assign)NSInteger pickeviewHeight;
@property(nonatomic,copy)NSString *resultString;
@property(nonatomic,strong)NSMutableArray *componentArray;
@property(nonatomic,strong)NSMutableArray *dicKeyArray;
@property(nonatomic,copy)NSMutableArray *state;
@property(nonatomic,copy)NSMutableArray *city;
@property(nonatomic,strong)NSLayoutConstraint *labTitleEH;
@end

/**
 * 新版UI 确认按钮在右上角 ，取消在左上角
 * 使用文字， 去掉图片 注意国际化
 * 去掉底部确认按钮 整体布局
 * 需要考虑标题文案换行场景
 * 列间距调整
 */


@implementation ZCZHPickView

-(NSArray *)plistArray{
    if (_plistArray==nil) {
        _plistArray=[[NSArray alloc] init];
    }
    return _plistArray;
}

-(NSArray *)componentArray{

    if (_componentArray==nil) {
        _componentArray=[[NSMutableArray alloc] init];
    }
    return _componentArray;
}

-(void)dismisView{
    [self remove];
}

-(instancetype)initPickviewWithPlistName:(NSString *)plistName isHaveNavControler:(BOOL)isHaveNavControler{
    self=[super init];
    if (self) {
        _plistName=plistName;
        self.plistArray=[self getPlistArrayByplistName:plistName];
        [self setUpPickView];
        [self setFrameWith:isHaveNavControler];
    }
    return self;
}
-(instancetype)initPickviewWithArray:(NSArray *)array isHaveNavControler:(BOOL)isHaveNavControler{
    self=[super init];
    if (self) {
        self.plistArray=array;
        [self setArrayClass:array];
        [self setUpPickView];
        [self setFrameWith:isHaveNavControler];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame DatePickWithDate:(NSDate *)defaulDate datePickerMode:(UIDatePickerMode)datePickerMode isHaveNavControler:(BOOL)isHaveNavControler{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpToolBar];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismisView)];
        [self addGestureRecognizer:tap];
        _defaulDate = defaulDate;
        [self setUpDatePickerWithdatePickerMode:(UIDatePickerMode)datePickerMode];
        [self setFrameWith:isHaveNavControler];
    }
    return self;
}

-(NSArray *)getPlistArrayByplistName:(NSString *)plistName{
    NSString *path= [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
    NSArray * array=[[NSArray alloc] initWithContentsOfFile:path];
    [self setArrayClass:array];
    return array;
}

-(void)setArrayClass:(NSArray *)array{
    _dicKeyArray=[[NSMutableArray alloc] init];
    for (id levelTwo in array) {
        if ([levelTwo isKindOfClass:[NSArray class]]) {
            _isLevelArray=YES;
            _isLevelString=NO;
            _isLevelDic=NO;
        }else if ([levelTwo isKindOfClass:[NSString class]]){
            _isLevelString=YES;
            _isLevelArray=NO;
            _isLevelDic=NO;
            
        }else if ([levelTwo isKindOfClass:[NSDictionary class]])
        {
            _isLevelDic=YES;
            _isLevelString=NO;
            _isLevelArray=NO;
            _levelTwoDic=levelTwo;
            [_dicKeyArray addObject:[_levelTwoDic allKeys] ];
        }
    }
}

-(void)setFrameWith:(BOOL)isHaveNavControler{
    CGFloat toolViewX = 0;
    CGFloat toolViewH = ScreenHeight;// _pickeviewHeight+ZHToobarHeight;
    CGFloat toolViewY ;
    if (isHaveNavControler) {
        toolViewY= [UIScreen mainScreen].bounds.size.height-toolViewH-50;
    }else {
        toolViewY= [UIScreen mainScreen].bounds.size.height-toolViewH;
    }
    CGFloat toolViewW = [UIScreen mainScreen].bounds.size.width;
    [self setBackgroundColor:UIColorFromModeColorAlpha(SobotColorBlack, 0.4)];
    self.frame = CGRectMake(toolViewX, 0, toolViewW, toolViewH);
}
-(void)setUpPickView{
    
    if (_pickerView!= nil) {
        [_pickerView removeFromSuperview];
    }
    
    _pickerView = [[UIPickerView alloc] init];
    [_pickerView setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark1)];
    _pickerView.delegate=self;
    _pickerView.dataSource=self;
    _pickeviewHeight = _pickerView.frame.size.height;
    _pickerView.frame=CGRectMake(0, self.frame.size.height - _pickeviewHeight - XBottomBarHeight -ZCCommitHeight ,_pickerView.frame.size.width, _pickerView.frame.size.height);
    [self addSubview:_pickerView];
    [self ToolbarWithPickViewFrame];
}

-(void)setUpDatePickerWithdatePickerMode:(UIDatePickerMode)datePickerMode{
    self.autoresizesSubviews = YES;
    if (_datePicker != nil) {
        [_datePicker removeFromSuperview];
    }
        
    _datePicker =[[UIDatePicker alloc] init];
    _datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:sobotGetCurrentLanguages()];
    _datePicker.datePickerMode = datePickerMode;
    // 兼容iOS 14
    if(sobotGetSystemDoubleVersion()>=13.4){
        _datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    }
    
    [_datePicker setValue:UIColorFromKitModeColor(SobotColorTextMain) forKey:@"textColor"];
    [_datePicker setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark1)];
    if (_defaulDate) {
        [_datePicker setDate:_defaulDate];
    }
    [_datePicker setMinimumDate:[[NSDate date] dateByAddingTimeInterval:-1000*60*60*24*365]];
    _pickeviewHeight = _datePicker.frame.size.height;
    _datePicker.frame=CGRectMake(0, ScreenHeight - _pickeviewHeight ,self.frame.size.width, _datePicker.frame.size.height);
    _datePicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:_datePicker];
    [self ToolbarWithPickViewFrame];
    
    CGRect bgF = CGRectMake(0, ScreenHeight - _pickeviewHeight - ZCCommitHeight-XBottomBarHeight-ZCCommitHeight, ScreenWidth, _pickeviewHeight + ZCCommitHeight + XBottomBarHeight);
    _commitBgView = [[UIView alloc] initWithFrame:bgF];
    _commitBgView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:_commitBgView];
    [_commitBgView setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark1)];
    
//    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 1)];
//    lineView.backgroundColor = [ZCUIKitTools zcgetCommentButtonLineColor];
//    lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
//    [_commitBgView addSubview:lineView];
    
    _commitBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    _commitBtn.frame = CGRectMake(16 ,0, ScreenWidth - 32, 40);
    _commitBtn.layer.cornerRadius = 4.0f;
    _commitBtn.layer.masksToBounds = YES;
    _commitBtn.titleLabel.font = SobotFont16;
    [_commitBtn setBackgroundColor:[ZCUIKitTools zcgetServerConfigBtnBgColor]];
    [_commitBtn setTitleColor:[ZCUIKitTools zcgetRobotBtnTitleColor] forState:UIControlStateNormal];
    [_commitBtn addTarget:self action:@selector(doneClick) forControlEvents:UIControlEventTouchUpInside];
    [_commitBtn setTitle:SobotKitLocalString(@"确定") forState:UIControlStateNormal];
    _commitBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    [_commitBgView addSubview:_commitBtn];
}

-(void)setUpToolBar{
    _toolbarView = [self setToolbarViewSubView];
    [self ToolbarWithPickViewFrame];
    [self addSubview:_toolbarView];
}

-(UIToolbar *)setToolbarStyle{
    UIToolbar *toolbar=[[UIToolbar alloc] init];
    UIBarButtonItem *lefttem=[[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"  %@",SobotKitLocalString(@"取消")] style:UIBarButtonItemStylePlain target:self action:@selector(remove)];
    UIBarButtonItem *centerSpace=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *right=[[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"%@  ",SobotKitLocalString(@"确定")] style:UIBarButtonItemStylePlain target:self action:@selector(doneClick)];
    toolbar.items=@[lefttem,centerSpace,right];
    [self setTintColor:[ZCUIKitTools zcgetTextNolColor]];
    return toolbar;
}

-(UIView*)setToolbarViewSubView{
    _toolbarView = [[UIView alloc]init];
    
    // 取消按钮 不显示，新版UI只显示标题
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
////    btn.frame = CGRectMake(self.frame.size.width-58, 20, 48, 20);
//    [btn setTitleColor:self.tintColor forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(remove) forControlEvents:UIControlEventTouchUpInside];
//    [btn setTitle:SobotKitLocalString(@"取消") forState:0];
//    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
//    [btn setTitleColor:[ZCUIKitTools zcgetServerConfigBtnBgColor] forState:0];
////    [btn setImage:[SobotUITools getSysImageByName:@"zcicon_sf_close"] forState:0];
//    btn.titleLabel.font = SobotFont14;
//    [_toolbarView addSubview:btn];
//    [_toolbarView addConstraint:sobotLayoutPaddingLeft(16, btn, _toolbarView)];
//    [_toolbarView addConstraint:sobotLayoutEqualCenterY(0, btn, _toolbarView)];
//    [_toolbarView addConstraint:sobotLayoutEqualWidth(50, btn, NSLayoutRelationEqual)];
//    [_toolbarView addConstraint:sobotLayoutEqualHeight(52, btn, NSLayoutRelationEqual)];
//    _rightBtn = btn;
    
    // 标题
//    UILabel *labTitle = [[UILabel alloc] initWithFrame:CGRectMake(58, 10, ScreenWidth - 58*2, 40)];
    UILabel *labTitle = [[UILabel alloc] init];
    labTitle.textColor     = UIColorFromKitModeColor(SobotColorTextMain);
    labTitle.textAlignment = NSTextAlignmentCenter;
    labTitle.numberOfLines = 0;
    labTitle.font = SobotFontBold16;
    [_toolbarView addSubview:labTitle];
    
    [_toolbarView addConstraint:sobotLayoutPaddingLeft(16, labTitle, _toolbarView)];
    [_toolbarView addConstraint:sobotLayoutPaddingRight(-16, labTitle, _toolbarView)];
    [_toolbarView addConstraint:sobotLayoutEqualCenterY(0, labTitle, _toolbarView)];
    self.labTitleEH = sobotLayoutEqualHeight(24, labTitle, NSLayoutRelationGreaterThanOrEqual);
    [_toolbarView addConstraint:self.labTitleEH];
    _labelTitle = labTitle;
    
    // 确认按钮
//    _commitBtn= [UIButton buttonWithType:UIButtonTypeCustom];
//    [_commitBtn setBackgroundColor:UIColor.clearColor];
//    [_commitBtn setTitleColor:[ZCUIKitTools zcgetServerConfigBtnBgColor] forState:UIControlStateNormal];
//    [_commitBtn addTarget:self action:@selector(doneClick) forControlEvents:UIControlEventTouchUpInside];
//    [_commitBtn setTitle:SobotKitLocalString(@"确定") forState:UIControlStateNormal];
//    [_commitBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
//    _commitBtn.titleLabel.font = SobotFont14;
//    [_toolbarView addSubview:_commitBtn];
//    [_toolbarView addConstraint:sobotLayoutPaddingRight(-16,_commitBtn, _toolbarView)];
//    [_toolbarView addConstraint:sobotLayoutEqualCenterY(0, _commitBtn, _toolbarView)];
//    [_toolbarView addConstraint:sobotLayoutEqualWidth(50, _commitBtn, NSLayoutRelationEqual)];
//    [_toolbarView addConstraint:sobotLayoutEqualHeight(52, _commitBtn, NSLayoutRelationEqual)];
    return _toolbarView;
}

-(void)setTitle:(NSString *)title{
    if(_labelTitle){
        [_labelTitle setText:sobotConvertToString(title)];
    }
}

-(void)addBorderWithColor:(UIColor *)color isBottom:(BOOL) isBottom with:(UIView *) view{
    CGFloat borderWidth = 0.75f;
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    if(isBottom){
        border.frame = CGRectMake(0, view.frame.size.height - borderWidth, self.frame.size.width, borderWidth);
    }else{
        border.frame = CGRectMake(view.frame.size.width - borderWidth,0, borderWidth, self.frame.size.height);
    }
    border.name=@"border";
    [view.layer addSublayer:border];
}

-(void)ToolbarWithPickViewFrame{
    _toolbarView.frame=CGRectMake(0, ScreenHeight - _pickeviewHeight-ZHToobarHeight -XBottomBarHeight-ZCCommitHeight,[UIScreen mainScreen].bounds.size.width, ZHToobarHeight);
//    _rightBtn.frame = CGRectMake(self.frame.size.width - 10 - 48 ,20, 48, 20);
    [_toolbarView setBackgroundColor:UIColorFromKitModeColor(SobotColorBgMainDark1)];
    _toolbarView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    [self addBorderWithColor:UIColorFromKitModeColor(SobotColorBgTopLine) isBottom:YES with:_toolbarView];
}

#pragma mark piackView 数据源方法
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    NSInteger component = 0;
    if (_isLevelArray) {
        component=_plistArray.count;
    } else if (_isLevelString){
        component=1;
    }else if(_isLevelDic){
        component=[_levelTwoDic allKeys].count*2;
    }
    return component;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSArray *rowArray=[[NSArray alloc] init];
    if (_isLevelArray) {
        rowArray=_plistArray[component];
    }else if (_isLevelString){
        rowArray=_plistArray;
    }else if (_isLevelDic){
        NSInteger pIndex = [pickerView selectedRowInComponent:0];
        NSDictionary *dic=_plistArray[pIndex];
        for (id dicValue in [dic allValues]) {
                if ([dicValue isKindOfClass:[NSArray class]]) {
                    if (component%2==1) {
                        rowArray=dicValue;
                    }else{
                        rowArray=_plistArray;
                    }
            }
        }
    }
    return rowArray.count;
}

#pragma mark UIPickerViewdelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSString *rowTitle=nil;
    if (_isLevelArray) {
        rowTitle=_plistArray[component][row];
    }else if (_isLevelString){
        rowTitle=_plistArray[row];
    }else if (_isLevelDic){
        NSInteger pIndex = [pickerView selectedRowInComponent:0];
        NSDictionary *dic=_plistArray[pIndex];
        if(component%2==0)
        {
            rowTitle=_dicKeyArray[row][component];
        }
        for (id aa in [dic allValues]) {
           if ([aa isKindOfClass:[NSArray class]]&&component%2==1){
                NSArray *bb=aa;
                if (bb.count>row) {
                    rowTitle=aa[row];
                }
            }
        }
    }
    return rowTitle;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (_isLevelDic&&component%2==0) {
        [pickerView reloadComponent:1];
        [pickerView selectRow:0 inComponent:1 animated:YES];
    }
    if (_isLevelString) {
        _resultString=_plistArray[row];
        
    }else if (_isLevelArray){
        _resultString=@"";
        if (![self.componentArray containsObject:@(component)]) {
            [self.componentArray addObject:@(component)];
        }
        for (int i=0; i<_plistArray.count;i++) {
            if ([self.componentArray containsObject:@(i)]) {
                NSInteger cIndex = [pickerView selectedRowInComponent:i];
                _resultString=[NSString stringWithFormat:@"%@%@",_resultString,_plistArray[i][cIndex]];
            }else{
                _resultString=[NSString stringWithFormat:@"%@%@",_resultString,_plistArray[i][0]];
                          }
        }
    }else if (_isLevelDic){
        if (component==0) {
          _state =_dicKeyArray[row][0];
        }else{
            NSInteger cIndex = [pickerView selectedRowInComponent:0];
            NSDictionary *dicValueDic=_plistArray[cIndex];
            NSArray *dicValueArray=[dicValueDic allValues][0];
            if (dicValueArray.count>row) {
                _city =dicValueArray[row];
            }
        }
    }
}

-(void)remove{
    [self removeFromSuperview];
}

-(void)show{
    [[SobotUITools getCurWindow] addSubview:self];
}

-(void)doneClick
{
    if (_pickerView) {
        if (_resultString) {
           
        }else{
            if (_isLevelString) {
                _resultString=[NSString stringWithFormat:@"%@",_plistArray[0]];
            }else if (_isLevelArray){
                _resultString=@"";
                for (int i=0; i<_plistArray.count;i++) {
                    _resultString=[NSString stringWithFormat:@"%@%@",_resultString,_plistArray[i][0]];
                }
            }else if (_isLevelDic){
                if (_state==nil) {
                     _state =_dicKeyArray[0][0];
                    NSDictionary *dicValueDic=_plistArray[0];
                    _city=[dicValueDic allValues][0][0];
                }
                if (_city==nil){
                    NSInteger cIndex = [_pickerView selectedRowInComponent:0];
                    NSDictionary *dicValueDic=_plistArray[cIndex];
                    _city=[dicValueDic allValues][0][0];
                }
              _resultString=[NSString stringWithFormat:@"%@%@",_state,_city];
           }
        }
    }else if (_datePicker) {
        if(_datePicker.datePickerMode == UIDatePickerModeTime){
            _resultString = sobotDateTransformString(@"HH:mm", _datePicker.date);
        }
        if(_datePicker.datePickerMode == UIDatePickerModeDate){
            _resultString = sobotDateTransformString(@"yyyy-MM-dd", _datePicker.date);
        }
        if(_datePicker.datePickerMode == UIDatePickerModeDateAndTime){
            _resultString = sobotDateTransformString(SOBOT_FORMATE_DATETIME, _datePicker.date);
        }
    }
    if ([self.delegate respondsToSelector:@selector(toobarDonBtnHaveClick:resultString:)]) {
        [self.delegate toobarDonBtnHaveClick:self resultString:_resultString];
    }
    [self removeFromSuperview];
}
/**
 *  设置PickView的颜色
 */
-(void)setPickViewColer:(UIColor *)color{
    _pickerView.backgroundColor=color;
}
/**
 *  设置toobar的文字颜色
 */
-(void)setTintColor:(UIColor *)color{
    
//    _toolbar.tintColor=color;
}
/**
 *  设置toobar的背景颜色
 */
-(void)setToolbarTintColor:(UIColor *)color{
    [_toolbarView setBackgroundColor:color];
//    _toolbar.barTintColor=color;
}
-(void)dealloc{
//    NSLog(@"销毁了");
}


-(void)layoutSubviews{
    [super layoutSubviews];
    [self ToolbarWithPickViewFrame];
    _datePicker.frame = CGRectMake(0, ScreenHeight - _pickeviewHeight-XBottomBarHeight-ZCCommitHeight,self.frame.size.width, _datePicker.frame.size.height);
    // 按钮放到上面了，UI改版
    if(_commitBgView){
        _commitBgView.frame = CGRectMake(0, ScreenHeight - XBottomBarHeight-ZCCommitHeight,self.frame.size.width, XBottomBarHeight+ZCCommitHeight);
    }
    if(_labelTitle){
        _labelTitle.frame = CGRectMake(16, 10, ScreenWidth - 16*2, 52);
        [ZCUIKitTools addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadii:CGSizeMake(8, 8) withView:_toolbarView];
    }
    
}

@end

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 
