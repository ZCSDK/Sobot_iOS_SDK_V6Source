//
//  ZCChatWheelFlowLayout.h
//  SobotKit
//
//  Created by zhangxy on 2022/9/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZCChatWheelFlowLayoutDelegate <UICollectionViewDelegateFlowLayout>

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout cellCenteredAtIndexPath:(NSIndexPath *)indexPath page:(int)page;

@end
@interface ZCChatWheelFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, weak) id<ZCChatWheelFlowLayoutDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
