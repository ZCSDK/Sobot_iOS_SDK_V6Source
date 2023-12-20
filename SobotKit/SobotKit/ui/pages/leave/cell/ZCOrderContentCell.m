//
//  ZCOrderContentCell.m
//  SobotKit
//
//  Created by lizh on 2022/9/13.
//

#import "ZCOrderContentCell.h"
#import <SobotCommon/SobotCommon.h>
#import "ZCUIKitTools.h"
#import "ZCActionSheet.h"
@interface ZCOrderContentCell()<UITextViewDelegate,ZCActionSheetDelegate,UITextFieldDelegate>
{
    SobotImageView *imageView;
    UIButton *delButton;
}

@property(nonatomic,strong)NSLayoutConstraint *textViewEH;
@property(nonatomic,strong)NSLayoutConstraint *fileScrollViewPB;
@property(nonatomic,strong)NSLayoutConstraint *textDescPB;

@property(nonatomic,strong)NSLayoutConstraint *fileScrollViewPL;
@property(nonatomic,strong)NSLayoutConstraint *fileScrollViewPR;
@property(nonatomic,strong)NSLayoutConstraint *fileScrollViewEH;
@property(nonatomic,strong)NSLayoutConstraint *fileScrollViewMT;
@end

@implementation ZCOrderContentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self createItemsView];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.userInteractionEnabled=YES;
        [self createItemsView];
        self.backgroundColor = [ZCUIKitTools zcgetLightGrayDarkBackgroundColor];
    }
    return self;
}

-(void)createItemsView{
    
    _textDesc = ({
        ZCUIPlaceHolderTextView *iv = [[ZCUIPlaceHolderTextView alloc]init];
        iv.placeholder = @"";
        [iv setPlaceholderColor:UIColorFromKitModeColor(SobotColorTextSub1)];
        [iv setFont:SobotFont14];
        [iv setTextColor:UIColorFromKitModeColor(SobotColorTextSub)];
        iv.delegate = self;
        iv.placeholederFont = SobotFont14;
        iv.layer.cornerRadius = 4.0f;
        iv.layer.masksToBounds = YES;
        [iv setBackgroundColor:[ZCUIKitTools zcgetLeftChatColor]];
        iv.textContainerInset = UIEdgeInsetsMake(10, 10, 0, 10);
        [self.contentView addSubview:iv];
        [self.contentView addConstraint:sobotLayoutPaddingTop(20, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingLeft(20, iv, self.contentView)];
        [self.contentView addConstraint:sobotLayoutPaddingRight(-20, iv, self.contentView)];
        self.textViewEH = sobotLayoutEqualHeight(154, iv, NSLayoutRelationEqual);
        [self.contentView addConstraint:self.textViewEH];
        iv;
    });
    
    _fileScrollView = ({
        UIScrollView *iv = [[UIScrollView alloc]init];
        iv.scrollEnabled = YES;
        iv.userInteractionEnabled = YES;
        iv.showsVerticalScrollIndicator = NO;
        iv.pagingEnabled = NO;
        [self.contentView addSubview:iv];
        self.fileScrollViewPL = sobotLayoutPaddingLeft(20, iv, self.contentView);
        self.fileScrollViewPR = sobotLayoutPaddingRight(-20, iv, self.contentView);
        self.fileScrollViewMT = sobotLayoutMarginTop(10, iv, self.textDesc);
        self.fileScrollViewEH = sobotLayoutEqualHeight(80, iv, NSLayoutRelationEqual);
        self.fileScrollViewPB = sobotLayoutPaddingBottom(0, iv, self.contentView);
        [self.contentView addConstraint:self.fileScrollViewPB];
        [self.contentView addConstraint:self.fileScrollViewPL];
        [self.contentView addConstraint:self.fileScrollViewPR];
        [self.contentView addConstraint:self.fileScrollViewMT];
        [self.contentView addConstraint:self.fileScrollViewEH];
        iv;
    });
}

- (NSMutableArray *)imageArr{
    if (!_imageArr) {
        _imageArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _imageArr;
}

-(ZCLibConfig *)getCurConfig{
    return [[ZCPlatformTools sharedInstance] getPlatformInfo].config;
}

-(void)initDataToView:(NSDictionary *)dict{
    _textDesc.text   = @"";
    UILabel * detailLab = [[UILabel alloc]initWithFrame:CGRectMake(20, 12 + 10, self.tableWidth-80, 102)];
    detailLab.numberOfLines = 0;
    __block CGFloat DH = CGRectGetHeight(detailLab.frame);
    [SobotHtmlCore filterHtml:dict[@"placeholder"] result:^(NSString * _Nonnull text1, NSMutableArray * _Nonnull arr, NSMutableArray * _Nonnull links) {
        self->_textDesc.placeholder = text1;
       CGRect labelF  = [self getTextRectWith:text1 WithMaxWidth:self.tableWidth WithlineSpacing:0 AddLabel:detailLab];
        DH = labelF.size.height;
        self->_textDesc.placeholderLinkColor = UIColorFromKitModeColor(SobotColorTextSub1);
    }];
    
    if (DH > 102) {
        if (self.textViewEH) {
            self.textViewEH.constant = DH +20;
        }
    }
    [_textDesc setText:sobotConvertToString(self.tempModel.ticketDesc)];

    if (_enclosureShowFlag) {
        _fileScrollView.frame = CGRectMake(20, CGRectGetMaxY(_textDesc.frame) + 10, self.tableWidth - 40, 80);
        [self reloadScrollView];
    }
    if(sobotIsRTLLayout()){
        [_textDesc setTextAlignment:NSTextAlignmentRight];
    }
}


- (void)reloadScrollView{
    // 先移除，后添加
    [[self.fileScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // 加一是为了有个添加button
    NSUInteger assetCount = self.imageArr.count +1 ;
    CGFloat width = (self.fileScrollView.frame.size.width - 5*3)/4;

    CGFloat heigth = 60;
    CGFloat x = 0;
    NSUInteger countX = 0;
    if(sobotIsRTLLayout()){
        countX = (assetCount < 4) ? 4 : assetCount;
    }
    
    for (NSInteger i = 0; i < assetCount; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        x = (width + 5)*i;
        if(sobotIsRTLLayout()){
            x = (width + 5)* (countX - i - 1);
        }
        btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        btn.frame = CGRectMake(x,0, width, heigth);
        imageView.frame = btn.frame;
        // UIButton
        if (i == self.imageArr.count){
            // 最后一个Button
            [btn setImage: [SobotUITools getSysImageByName:@"zcicon_add_photo"]  forState:UIControlStateNormal];
            // 添加图片的点击事件
            [btn addTarget:self action:@selector(photoSelecte) forControlEvents:UIControlEventTouchUpInside];
            if (assetCount == 11) {
                assetCount = 10;
                btn.frame = CGRectZero;
            }
            [btn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        }else{
            [btn.imageView setContentMode:UIViewContentModeScaleAspectFill];
            // 就从本地取
            if(sobotCheckFileIsExsis([_imagePathArr objectAtIndex:i])){
                UIImage *localImage=[UIImage imageWithContentsOfFile:[_imagePathArr objectAtIndex:i]];
                [btn setImage:localImage forState:UIControlStateNormal];
            }
            NSDictionary *imgDic = [_imageArr objectAtIndex:i];
            NSString *imgFileStr =  sobotConvertToString(imgDic[@"cover"]);
            if (imgFileStr.length>0) {
                UIImage *localImage=[UIImage imageWithContentsOfFile:imgFileStr];
                [btn setImage:localImage forState:UIControlStateNormal];
            }
            btn.tag = i;
            // 点击放大图片，进入图片
            [btn addTarget:self action:@selector(tapBrowser:) forControlEvents:UIControlEventTouchUpInside];
                btn.layer.borderColor = UIColorFromKitModeColor(SobotColorBgLine).CGColor;
        }
        btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        [self.fileScrollView addSubview:btn];
        if (i != self.imageArr.count){
            UIButton *btnDel = [UIButton buttonWithType:UIButtonTypeCustom];
            btnDel.imageView.contentMode = UIViewContentModeScaleAspectFit;
            x = (width + 5)*i + width - 24;
            if(sobotIsRTLLayout()){
                x = (width + 5)* (countX - i - 1) + width - 24;
            }
            btnDel.frame = CGRectMake(x,4, 20, 20);
            [btnDel setImage:[SobotUITools getSysImageByName:@"zcicon_close_down"] forState:0];
            btnDel.tag = 100 + i;
            // 点击放大图片，进入图片
            [btnDel addTarget:self action:@selector(tapDelFiles:) forControlEvents:UIControlEventTouchUpInside];
            [self.fileScrollView addSubview:btnDel];
        }
    }
    
    if(assetCount >= 4){
        self.fileScrollView.scrollEnabled = YES;
    }else{
        self.fileScrollView.scrollEnabled = NO;
    }
    // 设置contentSize
    self.fileScrollView.contentSize = CGSizeMake((width+5)*assetCount,self.fileScrollView.frame.size.height);
    if(assetCount > 4){
        if(sobotIsRTLLayout()){
            [self.fileScrollView setContentOffset:CGPointMake(0, 0)];
            
        }else{
            [self.fileScrollView setContentOffset:CGPointMake(self.fileScrollView.contentSize.width - self.fileScrollView.frame.size.width, 0)];
        }
    }
}


#pragma mark - 选择图片
// 添加图片
- (void)photoSelecte{
    if (self.delegate && [self.delegate respondsToSelector:@selector(itemCreateCellOnClick:dictKey:model:withButton:)]) {
        if(self.isReply){
            [self.delegate  itemCreateCellOnClick:ZCOrderCreateItemTypeAddReplyPhoto dictKey:@"dictContentImages" model:self.tempModel withButton:nil];
        }else{
        [self.delegate  itemCreateCellOnClick:ZCOrderCreateItemTypeAddPhoto dictKey:@"dictContentImages" model:self.tempModel withButton:nil];
        }
    }
    [_textDesc resignFirstResponder];
}


//预览图片
- (void)tapBrowser:(UIButton *)btn{
    // 点击图片浏览器 放大图片
//    NSLog(@"点击图片浏览器 放大图片");
    if (self.delegate && [self.delegate respondsToSelector:@selector(itemCreateCellOnClick:dictKey:model:withButton:)]) {
        if(self.isReply){
            [self.delegate  itemCreateCellOnClick:ZCOrderCreateItemTypeLookAtReplyPhoto dictKey: [NSString stringWithFormat:@"%d",(int)btn.tag] model:self.tempModel withButton:btn];
        }else{
            [self.delegate  itemCreateCellOnClick:ZCOrderCreateItemTypeLookAtPhoto dictKey:[NSString stringWithFormat:@"%d",(int)btn.tag]  model:self.tempModel withButton:btn];
        }
    }
    [_textDesc resignFirstResponder];
}

- (void)tapDelFiles:(UIButton *)btn{
    // 点击图片浏览器 放大图片
    //    NSLog(@"点击图片浏览器 放大图片");
    delButton = btn;
    NSString *tip = SobotKitLocalString(@"要删除这张图片吗？");
   NSInteger currentInt = btn.tag - 100;
   if(currentInt < _imagePathArr.count){
       NSString *file  = _imagePathArr[currentInt];
       if([file hasSuffix:@".mp4"]){
           tip = SobotKitLocalString(@"要删除这个视频吗?");
       }
   }
    ZCActionSheet *mysheet = [[ZCActionSheet alloc] initWithDelegate:self selectedColor:UIColorFromKitModeColor(SobotColorRed) showTitle:tip CancelTitle:SobotKitLocalString(@"取消") OtherTitles:SobotKitLocalString(@"删除"), nil];
    mysheet.tag = 3;
    mysheet.selectIndex = 2;
    [mysheet show];
    [_textDesc resignFirstResponder];
}

- (void)actionSheet:(ZCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(actionSheet.tag == 3){
        if(buttonIndex == 2){
            if (self.delegate && [self.delegate respondsToSelector:@selector(itemCreateCellOnClick:dictKey:model:withButton:)]) {
                   if(self.isReply){
                       [self.delegate  itemCreateCellOnClick:ZCOrderCreateItemTypeDeletePhoto dictKey: [NSString stringWithFormat:@"%d",(int)delButton.tag - 100]  model:self.tempModel withButton:nil];
                   }else{
                       [self.delegate  itemCreateCellOnClick:ZCOrderCreateItemTypeDeletePhoto dictKey:[NSString stringWithFormat:@"%d",(int)delButton.tag - 100]   model:self.tempModel withButton:nil];
                   }
            }
        }
    }
}
-(void)textViewDidChange:(ZCUIPlaceHolderTextView *)textView{
    self.tempModel.ticketDesc = sobotConvertToString(textView.text);
    if (self.delegate && [self.delegate respondsToSelector:@selector(itemCreateCellOnClick:dictKey:model:withButton:)]) {
        [self.delegate  itemCreateCellOnClick:ZCOrderCreateItemTypeTitle dictKey:@"dictDesc" model:self.tempModel withButton:nil];
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    if(self.delegate && [self.delegate respondsToSelector:@selector(didKeyboardWillShow:view1:view2:)]){
        [self.delegate didKeyboardWillShow:self.indexPath view1:textView view2:nil];
    }
}

-(void)textFieldDidChangeBegin:(UITextField *) textField{
    if(self.delegate && [self.delegate respondsToSelector:@selector(didKeyboardWillShow:view1:view2:)]){
        [self.delegate didKeyboardWillShow:self.indexPath view1:nil view2:textField];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - 获取label 最终计算高度
-(CGRect)getTextRectWith:(NSString *)str WithMaxWidth:(CGFloat)width  WithlineSpacing:(CGFloat)LineSpacing AddLabel:(UILabel *)label{
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc]initWithString:str];
    NSMutableParagraphStyle * parageraphStyle = [[NSMutableParagraphStyle alloc]init];
    [parageraphStyle setLineSpacing:LineSpacing];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:parageraphStyle range:NSMakeRange(0, [str length])];
    [attributedString addAttribute:NSFontAttributeName value:label.font range:NSMakeRange(0, str.length)];
    label.attributedText = attributedString;
    // 这里的高度的计算，不能在按 attributedString的属性去计算了，需要拿到label中的
    CGSize size = [self autoHeightOfLabel:label with:width];
    CGRect labelF = label.frame;
    labelF.size.height = size.height;
    label.frame = labelF;
    return labelF;
}


- (CGSize )autoHeightOfLabel:(UILabel *)label with:(CGFloat )width{
    //Calculate the expected size based on the font and linebreak mode of your label
    // FLT_MAX here simply means no constraint in height
    CGSize maximumLabelSize = CGSizeMake(width, FLT_MAX);
    CGSize expectedLabelSize = [label sizeThatFits:maximumLabelSize];
    //adjust the label the the new height.
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    label.frame = newFrame;
    [label updateConstraintsIfNeeded];
    return expectedLabelSize;
}

@end
