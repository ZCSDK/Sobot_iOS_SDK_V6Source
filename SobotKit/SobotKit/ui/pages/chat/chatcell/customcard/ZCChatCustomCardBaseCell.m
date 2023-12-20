//
//  ZCChatCustomCardBaseCell.m
//  SobotKit
//
//  Created by zhangxy on 2023/6/12.
//

#import "ZCChatCustomCardBaseCell.h"
#import "ZCChatBaseCell.h"

@interface ZCChatCustomCardBaseCell()


@end

@implementation ZCChatCustomCardBaseCell
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _listArray = [[NSMutableArray alloc] init];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self.contentView setBackgroundColor:[ZCUIKitTools zcgetChatBackgroundColor]];
        
        _listArray = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)initDataToView:(SobotChatMessage *)message time:(NSString *)showTime{
    [super initDataToView:message time:showTime];
    
    
    _cardModel = message.richModel.customCard;
}

-(void)menuButton:(SobotButton *)btn{
    [self menuItemClickButton:btn.obj tag:(int)btn.tag];
}


-(void)menuItemClickButton:(SobotChatCustomCardMenu *) menu tag:(int ) tag{
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:text:obj:)]){
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemClickCusCardInfoButoon text:sobotConvertIntToString(tag)  obj:menu];
    }
}
@end
