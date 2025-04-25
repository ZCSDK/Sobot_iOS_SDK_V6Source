//
//  ZCLeaveRegionSheetView.m
//  SobotOrderSDK
//
//  Created by zhangxy on 2024/3/26.
//

#import "ZCLeaveRegionSheetView.h"
#import "ZCLeaveRegionCell.h"
#import <SobotCommon/SobotCommon.h>
#import "ZCUIKitTools.h"
#define ZCLeaveRegionTitleHeight   52


@interface ZCLeaveRegionSheetView()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIGestureRecognizerDelegate>{
    BOOL isHideSearch;
    
    int page;
    int checkLevel;
    
    UIView *footerV;
    int totalCount;
}

@property (nonatomic,strong) NSMutableArray *mulArr;


@property (nonatomic,strong) UIView *topView;

@property (nonatomic,strong) UILabel *titleLab;

@property (nonatomic,strong) UIButton *closeBtn;

@property (nonatomic,strong) UIButton *saveBtn;// 保存按钮

@property (nonatomic,strong) UILabel *labTips;
@property(nonatomic, strong) UIView *topSearchView;
@property(nonatomic, strong) UIView *searchView;
@property(nonatomic, strong) UIView *searchLineView;


@property (nonatomic,strong)NSLayoutConstraint *layoutSearchH;


@property (nonatomic,strong) UILabel *holderLabel;


@property(nonatomic,strong)NSMutableArray   *dataArray;

@property(nonatomic,strong)UIView *btmMainView;
@property(nonatomic,strong)UILabel *labChecked;

@property(nonatomic,strong)UILabel *labNullResult;

@property(nonatomic,strong)ZCLeaveRegionEntity   *checkModel;

// 当搜索时，存储临时的列表选项
@property(nonatomic,strong)ZCLeaveRegionEntity   *tempCheckModel;

@property(nonatomic,strong)UIColor *commitBtnBgColor;
@property(nonatomic,strong)UIColor *commitBtnTitleColor;

@end

@implementation ZCLeaveRegionSheetView

-(void)createSubView{
    UIView *btmView = [[UIView alloc] init];
    btmView.backgroundColor = UIColorFromModeColor(SobotColorBgMain);
    [self addSubview:btmView];
    
    [self addConstraint:sobotLayoutPaddingLeft(0, btmView, self)];
    [self addConstraint:sobotLayoutPaddingRight(0, btmView, self)];
    [self addConstraint:sobotLayoutPaddingBottom(0, btmView, self)];
    [self addConstraint:sobotLayoutEqualHeight(XBottomBarHeight, btmView, NSLayoutRelationEqual)];
    
    [self createSuperView];
    
    self.textField.placeholder = SobotLocalString(@"搜索");
    
    self.btnCommit.enabled = false;
    self.btnCommit.backgroundColor = UIColorFromModeColorAlpha(SobotColorTheme, 0.3);
    [self hideBottomView];
    
    self.typeVeiwH.constant = 0;
    // 注册cell
    self.listTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.listTable.rowHeight = UITableViewAutomaticDimension;
    [self.listTable registerClass:[ZCLeaveRegionCell class] forCellReuseIdentifier:@"ZCLeaveRegionCell"];
    ((SobotTableView*)self.listTable).SobotRefreshFooter = [SobotRefreshFooterView footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];

    footerV = [[UIView alloc] init];
    footerV.frame = CGRectMake(0, 0, ScreenWidth, 60);
    footerV.backgroundColor = UIColor.clearColor;
    self.listTable.tableFooterView = footerV;
    
    [self addConstraint:sobotLayoutPaddingBottom(-XBottomBarHeight, self.listTable, self)];
    _dataArray = [[NSMutableArray alloc] init];
    
    
    _labNullResult = [[UILabel alloc] init];
    _labNullResult.textAlignment = NSTextAlignmentCenter;
    _labNullResult.textColor = UIColorFromModeColor(SobotColorTextSub);
    _labNullResult.backgroundColor = UIColor.clearColor;
    _labNullResult.text = SobotLocalString(@"无结果");
    _labNullResult.font = SobotFont14;
    [self.listTable addSubview:_labNullResult];
    [self.listTable addConstraint:sobotLayoutEqualCenterY(0,_labNullResult,self.listTable)];
    [self.listTable addConstraint:sobotLayoutEqualCenterX(0,_labNullResult,self.listTable)];
    
    _labNullResult.hidden = YES;
    
    [self getRegionList:@"0"];
}




-(void)createButtomView{
    _btmMainView = [[UIView alloc] init];
    _btmMainView.backgroundColor = UIColorFromModeColor(SobotColorBgMain);
    [self addSubview:_btmMainView];
    
    // 此处不要此约束
//    [self addConstraint:sobotLayoutMarginTop(0, bottom, _listTable)];
    [self addConstraint:sobotLayoutPaddingLeft(0, _btmMainView, self)];
    [self addConstraint:sobotLayoutPaddingRight(0, _btmMainView, self)];
    [self addConstraint:sobotLayoutPaddingBottom(0, _btmMainView, self)];
    self.layoutBtmH = sobotLayoutEqualHeight(60+XBottomBarHeight, _btmMainView, NSLayoutRelationEqual);
    [self addConstraint:self.layoutBtmH];
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(16, 10, ScreenWidth - 32, 40);
    btn.tag = SobotButtonClickCommit;
    [btn setTitle:SobotLocalString(@"确认") forState:0];
    btn.titleLabel.font = SobotFont14;
    btn.backgroundColor = UIColorFromModeColor(SobotColorTheme);
    [btn setTitleColor:UIColorFromModeColor(SobotColorTextWhite) forState:0];
    [btn addTarget:self action:@selector(buttonCommit) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = 4.0f;
    btn.layer.masksToBounds = YES;
    [_btmMainView addSubview:btn];

    self.btnCommit = btn;

    self.layoutBtmContentH = sobotLayoutEqualHeight(40, btn, NSLayoutRelationEqual);
    [_btmMainView addConstraint:self.layoutBtmContentH];
    [_btmMainView addConstraint:sobotLayoutPaddingTop(10, btn, _btmMainView)];
    [_btmMainView addConstraint:sobotLayoutPaddingLeft(20, btn, _btmMainView)];
    [_btmMainView addConstraint:sobotLayoutPaddingRight(-20, btn, _btmMainView)];
    
    
    _labChecked = [[UILabel alloc] init];
    _labChecked.numberOfLines = 0;
    _labChecked.textAlignment = NSTextAlignmentLeft;
    _labChecked.textColor = UIColorFromModeColor(SobotColorTextSub);
    _labChecked.backgroundColor = UIColorFromModeColor(SobotColorBgMain);
    _labChecked.font = SobotFont14;
    [self addSubview:_labChecked];
    [self addConstraint:sobotLayoutPaddingLeft(20, _labChecked, self)];
    [self addConstraint:sobotLayoutPaddingRight(-20, _labChecked, self)];
    [self addConstraint:sobotLayoutMarginBottom(0, _labChecked, _btmMainView)];
    
}

-(void)setBtnCommitTitleColor:(UIColor*)titleColor{
    if (!sobotIsNull(self.btnCommit)) {
        [self.btnCommit setTitleColor:titleColor forState:0];
        self.commitBtnTitleColor = titleColor;
    }
}
-(void)setBtnCommitBgColor:(UIColor*)bgColor{
    if (!sobotIsNull(self.btnCommit)) {
        [self.btnCommit setBackgroundColor:bgColor];
        self.commitBtnBgColor = bgColor;
    }
}

-(void)loadData{
    [self.btnCommit setTitle:SobotLocalString(@"确定") forState:0];
}

-(void)loadMoreData{
    if(sobotConvertToString(self.textField.text).length == 0){
        [((SobotTableView*)self.listTable).SobotRefreshFooter sobotEndRefresh];
    }else{
        page = page + 1;
        // 说明已经没有了
        if(self.searchArray.count%50!=0 || self.searchArray.count == totalCount){
            [((SobotTableView*)self.listTable).SobotRefreshFooter sobotEndRefresh];
            return;
        }
        [self searchRegion:sobotConvertToString(self.textField.text)];
    }
}

-(void)setFieldModel:(ZCOrderCusFiledsModel *)fieldModel{
    _fieldModel = fieldModel;
    if(_fieldModel && sobotConvertToString(_fieldModel.fieldValue).length > 0){
        _checkModel = [[ZCLeaveRegionEntity alloc] init];
        NSArray *arrVaus =  [sobotConvertToString(_fieldModel.fieldValue) componentsSeparatedByString:@","];
        NSArray *arrKeys =  [sobotConvertToString(_fieldModel.fieldSaveValue) componentsSeparatedByString:@","];
        for(int i=0;i<arrVaus.count;i++){
            // 把每一次选择的等级都记录上
            if(i == 0){
                self.checkModel.province = arrVaus[i];
                self.checkModel.provinceCode = arrKeys[i];
            }else if(i == 1){
                self.checkModel.city = arrVaus[i];
                self.checkModel.cityCode = arrKeys[i];
            }else if(i == 2){
                self.checkModel.area = arrVaus[i];
                self.checkModel.areaCode = arrKeys[i];
                self.checkModel.curId = arrKeys[i];
            }else if(i == 3){
                self.checkModel.street = arrVaus[i];
                self.checkModel.streetCode = arrKeys[i];
            }
            self.checkModel.curId = arrKeys[i];
        }
        self.checkModel.level = (int)arrKeys.count;
        checkLevel = 0;
//            item.value = [ids stringByReplacingOccurrencesOfString:@"/" withString:@","];
//            item.text = [names stringByReplacingOccurrencesOfString:@"/" withString:@","];
        
    }
    
}

-(void)reSetViewHeight{
    if (ScreenWidth >ScreenHeight) {
        self.listVeiwH.constant = 200;
    }else{
        self.listVeiwH.constant = 487;
    }
    [self setNeedsLayout];
}

-(void)buttonCommit{
    // 提交
    if(self.ChooseResultBlock){
        self.ChooseResultBlock(self.checkModel, [self getCheckModelTitle:NO], [self getCheckModelCode:NO]);
    }
    [self closeSheetView];
}


-(void)createTypeItems{
    [self.typeView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // 如果当前只有一级，不显示显示返回按钮
    if(([@"0" isEqual:self.checkModel.curId] || checkLevel == 0 || self.fieldModel.regionalLevel == 1) && sobotConvertToString(self.textField.text).length == 0){
        self.typeVeiwH.constant = 0;
        [self.typeView setNeedsLayout];
        return;
    }else{
        self.typeVeiwH.constant = 47.5;
    }
    
    UIButton *btn = [self createTypeBtn:sobotConvertToString(self.textField.text).length > 0];
    [self.typeView addSubview:btn];
    [self.typeView addConstraint:sobotLayoutPaddingLeft(5, btn, self.typeView)];
    [self.typeView addConstraint:sobotLayoutEqualWidth(ScreenWidth - 40, btn, NSLayoutRelationLessThanOrEqual)];
    [self.typeView addConstraint:sobotLayoutEqualCenterY(0, btn, self.typeView)];
    
    [btn sizeToFit];
}

-(UIButton *) createTypeBtn:(BOOL ) isSearch{
    SobotButton *btn = [SobotButton buttonWithType:UIButtonTypeCustom];
    NSString *title = @"";
    [btn setTitleColor:UIColorFromModeColor(SobotColorTextSub) forState:0];
    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    btn.titleLabel.font = SobotFont12;
    btn.titleLabel.numberOfLines = 0;
    if(self.checkModel && self.checkModel > 0){
        btn.tag = self.checkModel.level;
        btn.obj = self.checkModel.curId;
        title = [self getCheckModelTitle:YES];
    }
    if(!isSearch){
        [btn setImage:SobotGetImage(@"zcicon_back_lightgrey") forState:0];
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 5)];
        [btn setContentEdgeInsets:UIEdgeInsetsMake(0, 5, 0, -5)];
        [btn addTapHandle:^(SobotButton * _Nonnull btnObj) {
            int curLevel = (int)btnObj.tag;
            if(curLevel == 0){
                curLevel = self->checkLevel;
            }
            NSString *code = @"";
            if(curLevel > 0){
                curLevel = curLevel - 1;
            }
            
            if(curLevel>0 && curLevel == self.fieldModel.regionalLevel-1){
                curLevel = curLevel - 1;
            }
            
            self.checkModel.level = curLevel;
            self.checkModel.curId = code;
            if(curLevel == 0){
                code = @"0";
            }else if(curLevel == 1){
                code = sobotConvertToString(self.checkModel.provinceCode);
            }else if(curLevel == 2){
                code = sobotConvertToString(self.checkModel.cityCode);
            }else if(curLevel == 3){
                code = sobotConvertToString(self.checkModel.cityCode);
            }else if(curLevel == 4){
                code = sobotConvertToString(self.checkModel.cityCode);
            }else{
                code = @"0";
            }
            btnObj.obj = code;
            btnObj.tag = curLevel;
            
            self->checkLevel = curLevel;
            
            [btnObj setTitle:[self getCheckModelTitle:YES] forState:0];
            
            if([@"0" isEqual:code]){
                [self createTypeItems];
            }
            
            self.btnCommit.enabled = false;
            if (self.commitBtnBgColor) {
                UIColor *colorWithAlpha = [self.commitBtnBgColor colorWithAlphaComponent:0.3]; // 50% 透明度
                self.btnCommit.backgroundColor = colorWithAlpha;
            }else{
                self.btnCommit.backgroundColor = UIColorFromModeColorAlpha(SobotColorTheme, 0.3);
            }
            [self hideBottomView];
            [self getRegionList:code];
            
        }];
    }else{
        title = @"";
        if(self.fieldModel.regionalLevel == 1){
            title = [title stringByAppendingString:SobotLocalString(@"搜索全部省")];
        }else if(self.fieldModel.regionalLevel == 2){
            title = [title stringByAppendingString:SobotLocalString(@"搜索全部市")];
        }else if(self.fieldModel.regionalLevel == 3){
            title = [title stringByAppendingString:SobotLocalString(@"搜索全部县（区）")];
        }else if(self.fieldModel.regionalLevel == 4){
            title = [title stringByAppendingString:SobotLocalString(@"搜索全部街道")];
        }
    }
    [btn setTitle:title forState:0];
    
    return btn;
}


-(NSString *)getCheckModelTitle:(BOOL) existsLast{
    return [self getCheckModelTitle:existsLast model:self.checkModel];
}

-(NSString *)getCheckModelTitle:(BOOL) existsLast model:(ZCLeaveRegionEntity *) model{
    NSString *title = @"";
    int maxLevel = model.level;
    if(maxLevel == 0){
        maxLevel = checkLevel;
    }
    for(int i=1;i<=maxLevel;i++){
        if(i>self.fieldModel.regionalLevel){
            break;
        }
        if(existsLast && (i == (checkLevel+1) || i==self.fieldModel.regionalLevel)){
            break;
        }
        if(i == 1){
            title = sobotConvertToString(model.province);
        }else if(i == 2){
            title = [title stringByAppendingFormat:@"/%@",model.city];
        }else if(i == 3){
            title = [title stringByAppendingFormat:@"/%@",model.area];
        }else if(i == 4){
            title = [title stringByAppendingFormat:@"/%@",model.street];
        }
    }
    return title;
}




-(NSString *)getCheckModelCode:(BOOL) existsLast{
    NSString *title = @"";
    for(int i=1;i<=self.checkModel.level;i++){
        if(i>self.fieldModel.regionalLevel){
            break;
        }
        if(existsLast && i == self.fieldModel.regionalLevel){
            break;
        }
        if(i == 1){
            title = sobotConvertToString(self.checkModel.provinceCode);
        }else if(i == 2){
            title = [title stringByAppendingFormat:@"/%@",self.checkModel.cityCode];
        }else if(i == 3){
            title = [title stringByAppendingFormat:@"/%@",self.checkModel.areaCode];
        }else if(i == 4){
            title = [title stringByAppendingFormat:@"/%@",self.checkModel.streetCode];
        }
    }
    return title;
}



-(void)refreshData:(BOOL ) isSearch{
    if(self.fieldModel.regionalLevel < 1){
        self.fieldModel.regionalLevel = 3;
    }
    // 检查一次，数据是否加载完成
    [self.listArray removeAllObjects];
    
    footerV.frame = CGRectMake(0, 0, ScreenWidth, 60);
    if(isSearch){
        for(ZCLeaveRegionEntity *m in self.searchArray){
            //            if(sobotConvertToString(m.name).length > 0){
            //                [self.searchArray addObject:@{@"title":sobotConvertToString(m.name),@"check":@(0)}];
            //            }else{
            //                [self.searchArray addObject:@{@"title":sobotConvertToString(m.province),@"check":@(0)}];
            //            }
            [self.listArray addObject:m];
            
            //            if(sobotConvertToString(m.name).length > 0){
            //                [self.listArray addObject:@{@"title":sobotConvertToString(m.name),@"check":@(0)}];
            //            }else{
            //                [self.listArray addObject:@{@"title":sobotConvertToString(m.province),@"check":@(0)}];
            //            }
            
        }
        
        if(self.searchArray.count > 0){
            _labNullResult.hidden = YES;
        }else{
            _labNullResult.hidden = NO;
        }
        
        _labChecked.hidden = NO;
        if([self getCheckModelTitle:NO].length == 0){
            if([self getCheckModelTitle:NO model:self.tempCheckModel].length > 0){
                _labChecked.text = [NSString stringWithFormat:@"%@:%@",SobotLocalString(@"已选"),[self getCheckModelTitle:NO model:self.tempCheckModel]];
                
                _labChecked.hidden = NO;
            }else{
                
                _labChecked.hidden = YES;
            }
        }else{
            _labChecked.hidden = NO;
            _labChecked.text = [NSString stringWithFormat:@"%@:%@",SobotLocalString(@"已选"),[self getCheckModelTitle:NO]];
        }
        
        if(!_labChecked.hidden){
            
            footerV.frame = CGRectMake(0, 0, ScreenWidth, 60+30);
        }
    }else{
        _labNullResult.hidden = YES;
        for(ZCLeaveRegionEntity *m in _dataArray){
            [self.listArray addObject:m];
        }
        _labChecked.hidden = YES;
    }
    
    [self.listTable reloadData];
}


-(void)getRegionList:(NSString *) pid{
    [ZCLibServer getLeaveRegionList:pid start:^(NSString * _Nonnull urlString) {
        
    } success:^(NSDictionary * _Nonnull dict, ZCNetWorkCode sendCode) {
        if([@"000000" isEqual:dict[@"retCode"]]){
            NSArray *items = dict[@"items"];
            [self.dataArray removeAllObjects];
            NSString *checkCode = @"";
            if(self.checkModel){
                checkCode = [NSString stringWithFormat:@"%@/%@/%@/%@",self.checkModel.provinceCode,self.checkModel.cityCode,self.checkModel.areaCode,self.checkModel.streetCode];
            }
            for(NSDictionary *item in items){
                ZCLeaveRegionEntity *m = [[ZCLeaveRegionEntity alloc] initWithMyDict:item];
                
                if(self.checkModel && checkCode.length > 0 && [checkCode rangeOfString:m.curId].location != NSNotFound){
                    if(m.level == self.fieldModel.regionalLevel){
                        // 最后一级
                    }else if(m.level < self.fieldModel.regionalLevel){
                        // 被选中的父类
                    }
                    // 被选中的插入到第一位
                    [self.dataArray insertObject:m atIndex:0];
                    
                }else{
                    [self.dataArray addObject:m];
                }
            }
            
            [self refreshData:NO];
        }
    } failed:^(NSString * _Nonnull errorMessage, ZCNetWorkCode errorCode) {
        
    } finish:^(id  _Nonnull response, NSData * _Nonnull data) {
        
    }];
}


-(void)textChangAction:(UITextField *)textField{
    NSString *searchText = sobotConvertToString(textField.text);
    if(searchText.length > 0){
        [self createTypeItems];
        page = 1;
        totalCount = 0;
        [self searchRegion:searchText];
    }else{
        if(self.tempCheckModel){
            self.checkModel = self.tempCheckModel;
            self.tempCheckModel = nil;
        }
        [self createTypeItems];
        [self refreshData:NO];
    }
}

-(void)searchRegion:(NSString *)searchText{
    // 搜索请求
    [ZCLibServer searchLeaveRegion:searchText regionalLevel:self.fieldModel.regionalLevel page:page start:^(NSString * _Nonnull urlString) {
        
    } success:^(NSDictionary * _Nonnull dict, ZCNetWorkCode sendCode) {
        if(self->page == 1){
            // 显示搜索数据
            if(self.tempCheckModel == nil && sobotConvertToString(self.tempCheckModel.curId).length == 0){
                self.tempCheckModel = self.checkModel;
            }
            [self.searchArray removeAllObjects];
        }
        if([@"000000" isEqual:dict[@"retCode"]]){
            NSArray *items = dict[@"items"];
            for(NSDictionary *item in items){
                ZCLeaveRegionEntity *m = [[ZCLeaveRegionEntity alloc] initWithMyDict:item];
                m.level = self.fieldModel.regionalLevel;
                [self.searchArray addObject:m];
            }
            [self refreshData:YES];
            
            self->totalCount = [dict[@"totalCount"] intValue];
        }
        
        [((SobotTableView*)self.listTable).SobotRefreshFooter sobotEndRefresh];
    } failed:^(NSString * _Nonnull errorMessage, ZCNetWorkCode errorCode) {
        [((SobotTableView*)self.listTable).SobotRefreshFooter sobotEndRefresh];
    } finish:^(NSString * _Nonnull jsonString) {
        
    }];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZCLeaveRegionCell *cell = (ZCLeaveRegionCell*)[tableView dequeueReusableCellWithIdentifier:@"ZCLeaveRegionCell"];
    if (cell == nil) {
        cell = [[ZCLeaveRegionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZCLeaveRegionCell"];
    }
    
    ZCLeaveRegionEntity *model = [self.listArray objectAtIndex:indexPath.row];
    cell.fieldModel = self.fieldModel;
    cell.searchText = sobotConvertToString(self.textField.text);
    cell.checkModel = self.checkModel;
    cell.imgColor = [ZCUIKitTools zcgetServerConfigBtnBgColor];
    [cell initDataToView:model];
    return cell;
}

// 这里需要重写父类的方法，
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSMutableArray *arr = self.listArray[indexPath.section];
//    NSDictionary *itemDict = arr[indexPath.row];
//    SobotOrderUserInfoSheetCell *cell = (SobotOrderUserInfoSheetCell*)[self tableView:tableView cellForRowAtIndexPath:indexPath];
//    return [cell getLastHeight];
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    ZCLeaveRegionEntity *model = [self.listArray objectAtIndex:indexPath.row];
    
    // 搜索
    if(sobotConvertToString(self.textField.text).length > 0){
        self.checkModel = model;
        
        //        if(self.fieldModel){
        //            self.checkModel.level = self.fieldModel.regionalLevel;
        //            // 把每一次选择的等级都记录上
        //            if(self.checkModel.level == 1){
        //                self.checkModel.curId =  self.checkModel.provinceCode;
        //            }else if(self.checkModel.level == 2){
        //                self.checkModel.curId =  self.checkModel.cityCode;
        //            }else if(self.checkModel.level == 3){
        //                self.checkModel.curId =  self.checkModel.areaCode;
        //            }else if(self.checkModel.level == 4){
        //                self.checkModel.curId =  self.checkModel.streetCode;
        //            }
        //        }
        [self.listTable reloadData];
        self.btnCommit.enabled = true;
        if (self.commitBtnBgColor) {
            UIColor *colorWithAlpha = [self.commitBtnBgColor colorWithAlphaComponent:0.3]; // 50% 透明度
            self.btnCommit.backgroundColor = colorWithAlpha;
        }else{
            self.btnCommit.backgroundColor = UIColorFromModeColorAlpha(SobotColorTheme, 1.0);
        }
        [self showBottomView];
    }else{
        checkLevel = model.level;
        // 把每一次选择的等级都记录上
        if(model.level == 1){
            
            if(self.checkModel.provinceCode!=model.curId){
                self.checkModel.city = @"";
                self.checkModel.cityCode = @"";
                self.checkModel.area = @"";
                self.checkModel.areaCode = @"";
                self.checkModel.street = @"";
                self.checkModel.streetCode = @"";
                self.checkModel = model;
                self.checkModel.province = model.name;
                self.checkModel.provinceCode = model.curId;
            }
            
        }else if(model.level == 2){
            if(self.checkModel.cityCode!=model.curId){
                self.checkModel.area = @"";
                self.checkModel.areaCode = @"";
                self.checkModel.street = @"";
                self.checkModel.streetCode = @"";
                self.checkModel.level = model.level;
                self.checkModel.curId = model.curId;
            }
            self.checkModel.city = model.name;
            self.checkModel.cityCode = model.curId;
            
        }else if(model.level == 3){
            if(self.checkModel.areaCode!=model.curId){
                self.checkModel.street = @"";
                self.checkModel.streetCode = @"";
                self.checkModel.level = model.level;
                self.checkModel.curId = model.curId;
            }
            self.checkModel.area = model.name;
            self.checkModel.areaCode = model.curId;
            
        }else if(model.level == 4){
            self.checkModel.street = model.name;
            self.checkModel.streetCode = model.curId;
            
            self.checkModel.level = model.level;
            self.checkModel.curId = model.curId;
        }
        if(model.level < self.fieldModel.regionalLevel){
            [self getRegionList:model.curId];
            // 最后一级
            if(model.level == self.fieldModel.regionalLevel-1){
                [self showBottomView];
            }else{
                [self hideBottomView];
            }
        }else{
            
            self.btnCommit.enabled = true;
            if (self.commitBtnBgColor) {
                self.btnCommit.backgroundColor = self.commitBtnBgColor;
            }else{
                self.btnCommit.backgroundColor = UIColorFromModeColorAlpha(SobotColorTheme, 1.0);
            }
            [self showBottomView];
        }
        
        [self.listTable reloadData];
    }
    
    [self createTypeItems];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(ZCLeaveRegionSheetView *)initAlterView:(NSString *) title{
    self = [super init];
    if (self) {
        if([title hasSuffix:@"*"]){
            title = [title stringByReplacingOccurrencesOfString:@"*" withString:@""];
        }
        self.pageTitle = title;
        self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        self.autoresizesSubviews = YES;
        self.backgroundColor = UIColorFromModeColorAlpha(SobotColorBlack, 0.6);
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        [self createSubView];
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]){
        return NO;
    }
    if([NSStringFromClass([touch.view class]) isEqualToString:@"UIButton"]){
        return NO;
    }
    return YES;
}

-(void)tapClick:(UIGestureRecognizer *) gestap{
    if(_textField){
        [_textField resignFirstResponder];
    }
    
    CGPoint point = [gestap locationInView:self];
    CGRect f=self.topView.frame;
    if(point.x<f.origin.x || point.x>(f.origin.x+f.size.width) ||
       point.y<f.origin.y
//       || point.y>(f.origin.y+f.size.height)
       ){
        [self closeSheetView];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(void)hideAllWithOutTable{
    [self hideSearchView];
    [self hideTypeView];
    [self hideBottomView];
}

-(void)hideTypeView{
    _typeVeiwH.constant = 0;
    self.typeView.hidden = YES;
}
-(void)hideSearchView{
    _layoutSearchH.constant = 0;
    isHideSearch = YES;
    self.searchView.hidden = YES;
    self.topBottomLine.hidden = NO;
}

-(void)hideBottomView{
    _layoutBtmContentH.constant = 0;
    _layoutBtmH.constant = XBottomBarHeight;
    self.btnCommit.hidden = YES;
}

-(void)showBottomView{
    _layoutBtmContentH.constant = 40;
    _layoutBtmH.constant = 60 + XBottomBarHeight;
    self.btnCommit.hidden = NO;
}

-(void)showSaveBtn{
    self.saveBtn.hidden = NO;
}


#pragma mark 显示页面，第一次刷新数据
- (void)showInView:(UIView * _Nullable)view{
    if(sobotIsNull(self.topView)){
        [self createSubView];
    }
    if(view!=nil){
        [view addSubview:self];
    }else{
        [[SobotUITools getCurWindow] addSubview:self];
    }
 
    [self reSetViewHeight];
    
    [self.listTable reloadData];
    
    
    [self loadData];
    
    
    [self addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadii:CGSizeMake(8, 8)  viewRect:CGRectMake(0, 0, ScreenWidth, ZCLeaveRegionTitleHeight) withView:self.topView];
}

-(void)buttonClick:(UIButton *)sender{
//    if(self.tag == 2){
//        // 保存
//        if(_ChooseResultBlock){
//            _ChooseResultBlock(_mulArr,@"",@"");
//        }
//        [self closeSheetView];
//    }else{
        [self closeSheetView];
//    }
}


- (void)closeSheetView{
    
    [self removeFromSuperview];
    
}

/**
 *  设置部分圆角(绝对布局)
 *
 *  @param corners 需要设置为圆角的角 UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerAllCorners
 *  @param radii   需要设置的圆角大小 例如 CGSizeMake(20.0f, 20.0f)
 */
- (void)addRoundedCorners:(UIRectCorner)corners
                withRadii:(CGSize)radii withView:(UIView *) view {
    view.layer.masksToBounds = YES;
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:corners cornerRadii:radii];
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    
    view.layer.mask = shape;
}

/**
 *  设置部分圆角(相对布局)
 *
 *  @param corners 需要设置为圆角的角 UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerAllCorners
 *  @param radii   需要设置的圆角大小 例如 CGSizeMake(20.0f, 20.0f)
 *  @param rect    需要设置的圆角view的rect
 */
- (void)addRoundedCorners:(UIRectCorner)corners
                withRadii:(CGSize)radii
                 viewRect:(CGRect)rect withView:(UIView *) view {
    
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:radii];
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    
    view.layer.mask = shape;
}
#pragma mark 数据处理

/***
 以下是业务开始
 */
-(void)createSuperView{
    if(!sobotIsNull(self.topView)){
        return;
    }
    _mulArr = [[NSMutableArray alloc] init];
    
    [self createTopView:self.pageTitle];
    [self createSearchView];
    [self createTypeView];
    [self createTableView];
    [self createButtomView];
    
    // 当有搜索框的时候，需要隐藏
    self.topBottomLine.hidden = YES;
    
}


-(void)createTopView:(NSString *)pageTitle{
    self.topView = [[UIView alloc]init];
    [self addSubview:self.topView];
    [self.topView setBackgroundColor:UIColorFromModeColor(SobotColorBgMain)];
    [self addConstraint:sobotLayoutPaddingLeft(0, self.topView, self)];
    [self addConstraint:sobotLayoutPaddingRight(0, self.topView, self)];
    [self addConstraint:sobotLayoutEqualHeight(ZCLeaveRegionTitleHeight, self.topView, NSLayoutRelationEqual)];
    
//     标题
    self.titleLab = [[UILabel alloc]init];
    [self.titleLab setTextAlignment:NSTextAlignmentCenter];
    [self.titleLab setFont:SobotFontBold16];
    self.titleLab.text = sobotConvertToString(pageTitle);
    self.titleLab.numberOfLines = 0;
    [self.titleLab setTextColor:UIColorFromModeColor(SobotColorTextMain)];
    [self.titleLab setBackgroundColor:[UIColor clearColor]];
    [self.topView addSubview:self.titleLab];
    [self.topView addConstraint:sobotLayoutPaddingTop(0, self.titleLab, self.topView)];
    [self.topView addConstraint:sobotLayoutPaddingLeft(16, self.titleLab, self.topView)];
    [self.topView addConstraint:sobotLayoutPaddingRight(-16, self.titleLab, self.topView)];
    [self.topView addConstraint:sobotLayoutEqualHeight(ZCLeaveRegionTitleHeight, self.titleLab, NSLayoutRelationEqual)];
    
//     线条
    UIView *iv  = [[UIView alloc]init];
    iv.backgroundColor = UIColorFromModeColor(SobotColorBgTopLine);
    [self.topView addSubview:iv];
    [self.topView addConstraint:sobotLayoutPaddingLeft(0, iv, self.topView)];
    [self.topView addConstraint:sobotLayoutPaddingRight(0, iv, self.topView)];
    [self.topView addConstraint:sobotLayoutEqualHeight(0.5, iv, NSLayoutRelationEqual)];
    [self.topView addConstraint:sobotLayoutPaddingBottom(0, iv, self.topView)];
    
}



-(void)createSearchView{
    _searchArray = [[NSMutableArray alloc] init];
    _defArray = [[NSMutableArray alloc] init];
    
    _searchView = [[UIView alloc] init];
    _searchView.backgroundColor = UIColorFromModeColor(SobotColorBgMain);
    [self addSubview:_searchView];
    
    
    [self addConstraint:sobotLayoutMarginTop(0, _searchView, _topView)];
    [self addConstraint:sobotLayoutPaddingLeft(0, _searchView, self)];
    [self addConstraint:sobotLayoutPaddingRight(0, _searchView, self)];
    _layoutSearchH = sobotLayoutEqualHeight(51+11, _searchView, NSLayoutRelationEqual);
    [self addConstraint:_layoutSearchH];
    
    // 背景
    _topSearchView = [[UIView alloc] init];
    _topSearchView.backgroundColor = UIColorFromModeColor(SobotColorBgF5);
    _topSearchView.layer.cornerRadius = 8.0f;
    _topSearchView.layer.masksToBounds = YES;
    
    
    _textField = [[UITextField alloc] init];
    _textField.backgroundColor = UIColor.clearColor;
    [_textField setTextColor:UIColorFromModeColor(SobotColorTextMain)];
    _textField.delegate = self;
    _textField.font = SobotFont14;
    _textField.returnKeyType = UIReturnKeySearch;
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_textField addTarget:self action:@selector(textChangAction:) forControlEvents:UIControlEventEditingChanged];
    [_searchView addSubview:_topSearchView];
    
    [_topSearchView addSubview:_textField];
        
    _topSearchView.frame = CGRectMake(16, 11, ScreenWidth - 32, 36);
    _topSearchView.layer.cornerRadius = 4.0f;
    
    UIButton *_btnSearchIcon = [SobotButton buttonWithType:UIButtonTypeCustom];
    [_btnSearchIcon setImage:SobotGetImage(@"zcicon_serach") forState:0];
    [_topSearchView addSubview:_btnSearchIcon];
    
    
    // 此处注意顺序，要从右往左设置
//    [_topSearchView addConstraints:sobotLayoutPaddingView(12, -12, 0, 0, _btnSearchIcon, _topSearchView)];
//    [_topSearchView addConstraint:sobotLayoutEqualWidth(16, _btnSearchIcon, NSLayoutRelationEqual)];
//    [_topSearchView addConstraint:sobotLayoutPaddingRight(-15, _btnSearchIcon, _topSearchView)];
//    
//    [_topSearchView addConstraints:sobotLayoutPaddingView(8, -8, 15, 0, _textField, _topSearchView)];
//    [_topSearchView addConstraint:sobotLayoutMarginRight(-6, _textField, _btnSearchIcon)];
    
    [_topSearchView addConstraint:sobotLayoutEqualCenterY(0, _btnSearchIcon, _topSearchView)];
    [_topSearchView addConstraint:sobotLayoutPaddingLeft(13, _btnSearchIcon, _topSearchView)];
    [_topSearchView addConstraint:sobotLayoutEqualWidth(16, _btnSearchIcon, NSLayoutRelationEqual)];
    [_topSearchView addConstraint:sobotLayoutEqualHeight(16, _btnSearchIcon, NSLayoutRelationEqual)];
    
    [_topSearchView addConstraint:sobotLayoutPaddingRight(-8, _textField, _topSearchView)];
    [_topSearchView addConstraint:sobotLayoutMarginLeft(3, _textField, _btnSearchIcon)];
    [_topSearchView addConstraint:sobotLayoutEqualCenterY(0, _textField, _topSearchView)];
    [_topSearchView addConstraint:sobotLayoutEqualHeight(36, _textField, NSLayoutRelationEqual)];
    
//    _searchLineView  = [[UIView alloc] init];
//    [_searchLineView setBackgroundColor:UIColorFromModeColor(SobotColorBgLine)];
//    [_searchView addSubview:_searchLineView];
//    [_searchView addConstraint:sobotLayoutPaddingBottom(0, _searchLineView, _searchView)];
//    [_searchView addConstraint:sobotLayoutPaddingLeft(0, _searchLineView, _searchView)];
//    [_searchView addConstraint:sobotLayoutPaddingRight(0, _searchLineView, _searchView)];
//    [_searchView addConstraint:sobotLayoutEqualHeight(1, _searchLineView, NSLayoutRelationEqual)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


-(void)createTypeView{
    _typeBgView = [[UIView  alloc] init];
    _typeBgView.backgroundColor =  UIColorFromModeColor(SobotColorBgMain);
    [self addSubview:_typeBgView];
    
    
    _typeView = [[UIScrollView alloc]init];
    _typeView.backgroundColor =  UIColorFromModeColor(SobotColorBgMain);
    _typeView.showsVerticalScrollIndicator  = NO;
    _typeView.showsHorizontalScrollIndicator = NO;
    _typeView.bounces = NO;
    [self addSubview:_typeView];
    
    
    [self addConstraint:sobotLayoutMarginTop(0, _typeView, _searchView)];
    [self addConstraint:sobotLayoutPaddingLeft(15, _typeView, self)];
    [self addConstraint:sobotLayoutPaddingRight(-15, _typeView, self)];
    _typeVeiwH = sobotLayoutEqualHeight(46.5, _typeView, NSLayoutRelationEqual);
    [self addConstraint:_typeVeiwH];
    
    
    [self addConstraint:sobotLayoutPaddingLeft(0, _typeBgView, self)];
    [self addConstraint:sobotLayoutPaddingRight(0, _typeBgView, self)];
    [self addConstraint:sobotLayoutPaddingTop(0, _typeBgView, _typeView)];
    [self addConstraint:sobotLayoutPaddingBottom(0, _typeBgView, _typeView)];
    
    
    UIView *lineView = [[UIView alloc]init];
    lineView.backgroundColor = UIColorFromModeColor(SobotColorBgLine);
    [_typeView addSubview:lineView];
    [_typeView addConstraint:sobotLayoutPaddingBottom(0, lineView, _typeView)];
    [_typeView addConstraint:sobotLayoutPaddingLeft(0, lineView, _typeView)];
    [_typeView addConstraint:sobotLayoutPaddingRight(0, lineView, _typeView)];
    [_typeView addConstraint:sobotLayoutEqualHeight(1, lineView, NSLayoutRelationEqual)];
    
    
    UIView *btmLine = [[UIView alloc]init];
    btmLine.backgroundColor = UIColorFromModeColor(@"#09AEB0");
    [_typeView addSubview:btmLine];
    [_typeView addConstraint:sobotLayoutPaddingTop(0, btmLine, _typeView)];
    [_typeView addConstraint:sobotLayoutPaddingLeft(0, btmLine, _typeView)];
    [_typeView addConstraint:sobotLayoutPaddingRight(0, btmLine, _typeView)];
    [_typeView addConstraint:sobotLayoutEqualHeight(1, btmLine, NSLayoutRelationEqual)];
    
    
    _topLineView = [[UIView alloc]initWithFrame:CGRectMake(0, 41, 50, 3)];
    _topLineView.backgroundColor = UIColorFromModeColor(@"#09AEB0");
    [_typeView addSubview:_topLineView];
    _topLineView.hidden = YES;
}



- (void)keyBoardWillShow:(NSNotification *)notification {
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
//    CGFloat keyboardHeight = [[[notification userInfo] objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue].size.height;
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationDelegate:self];
    {
     //设置偏移量
        if (self.listArray.count > 0) {
            [self reSetViewHeight];
        }
    }
    [UIView commitAnimations];
}

//键盘隐藏
- (void)keyBoardWillHide:(NSNotification *)notification {
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView beginAnimations:@"bottomBarDown" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView commitAnimations];
    [UIView animateWithDuration:0.25 animations:^{
        //设置偏移量
           if (self.listArray.count > 0) {
               [self reSetViewHeight];
           }
    }];
}

-(void)reSetSuperViewHeight{
    CGFloat bh = self.listArray.count * 44;
    
    if (bh > ScreenHeight*0.5) {
        bh = ScreenHeight*0.5;
    }
    if(bh < (210+XBottomBarHeight)){
        bh = 210+XBottomBarHeight;
    }
    
    self.listVeiwH.constant = bh;
    [self setNeedsLayout];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0 ,ScreenWidth, ZCLeaveRegionTitleHeight) byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.topView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.topView.layer.mask = maskLayer;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    SLog(@"开始编辑");
}



-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [_textField resignFirstResponder];
    return YES;
}


-(void)createTableView{
    _listArray = [[NSMutableArray alloc] init];
    
    _listTable = [SobotUITools createTableWithView:self delegate:self];
    if (iOS7) {
        _listTable.backgroundView = nil;
    }
    
    _listTable.backgroundColor = UIColorFromModeColor(SobotColorBgMain);

    [_listTable setSeparatorColor:UIColorFromModeColor(SobotColorBgLine)];
    [_listTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    [self setTableSeparatorInset];
    
    [self addConstraint:sobotLayoutPaddingLeft(0,_listTable, self)];
    [self addConstraint:sobotLayoutPaddingRight(0,_listTable, self)];
    [self addConstraint:sobotLayoutMarginTop(0,_listTable, self.typeView)];
    _listVeiwH = sobotLayoutEqualHeight(0, _listTable, NSLayoutRelationEqual);
    [self addConstraint:_listVeiwH];
 }


 /**
  *  设置UITableView分割线空隙
  */
 -(void)setTableSeparatorInset{
     UIEdgeInsets inset = UIEdgeInsetsMake(0, 20, 0, 0);
     if ([_listTable respondsToSelector:@selector(setSeparatorInset:)]) {
         [_listTable setSeparatorInset:inset];
     }
     
     if ([_listTable respondsToSelector:@selector(setLayoutMargins:)]) {
         [_listTable setLayoutMargins:inset];
     }
 }


 #pragma mark -- tableView delegate
 - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
     return 1;
 }
 - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
     return _listArray.count;
 }

 - (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
     return 0;
 }
 -(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * bgview = [[UIView alloc] initWithFrame:CGRectZero];
     
     return bgview;
 }




 -(NSMutableAttributedString *)getOtherColorString:(NSString *)string Color:(UIColor *)Color withString:(NSString *)originalString
 {
     NSMutableAttributedString *str = [[NSMutableAttributedString alloc]init];
     
     NSMutableString *temp = [NSMutableString stringWithString:originalString];
     str = [[NSMutableAttributedString alloc] initWithString:temp];
     if (string.length) {
         NSRange range = [temp rangeOfString:string];
         [str addAttribute:NSForegroundColorAttributeName value:Color range:range];
         return str;
         
     }
     return str;
     
 }


-(void)createPlaceHolder:(NSString *_Nullable) title message:(NSString *_Nullable) message image:(UIImage *_Nullable) placeImage{
    [self removeHolderView];
    
    self.holderLabel = [[UILabel alloc] init];
    self.holderLabel.font = SobotFont14;
    self.holderLabel.textColor = UIColorFromModeColor(SobotColorTextSub);
    self.holderLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.holderLabel];
    
    [self addConstraint:sobotLayoutMarginTop(80, self.holderLabel, self.searchView)];
    [self addConstraint:sobotLayoutPaddingLeft(10, self.holderLabel, self)];
    [self addConstraint:sobotLayoutPaddingRight(-10, self.holderLabel, self)];
    
    if(self.holderLabel){
        [self.holderLabel setText:title];
    }
}

-(void)removeHolderView{
    if(self.holderLabel){
        [self.holderLabel removeFromSuperview];
    }
}

-(void)viewDidLayoutSubviews{
    [self setTableSeparatorInset];
}


#pragma mark -  //键盘显示
- (void)keyboardWillShow:(NSNotification *)notification {
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat keyBoardHeight = [[[notification userInfo] objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue].size.height;
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationDelegate:self];
    // get a rect for the view frame
    {
        CGFloat bh = self.listArray.count * 44;
        bh = bh + keyBoardHeight;
        if (bh > ScreenHeight*0.75) {
            bh = ScreenHeight*0.55;
        }
        self.listVeiwH.constant = bh;
        [self setNeedsLayout];
    }
    // commit animations
    [UIView commitAnimations];
}

//键盘隐藏
- (void)keyboardWillHide:(NSNotification *)notification {
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView beginAnimations:@"bottomBarDown" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView commitAnimations];
    [UIView animateWithDuration:0.25 animations:^{
        [self reSetViewHeight];
    }];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark UITableView delegate end


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

