
#import <UIKit/UIKit.h>
#import "HippyScrollView.h"
#import "HippyBridge.h"
#import "HippyUIManager.h"
#import "HippyBaseListViewProtocol.h"
#import "HippyBaseListViewDataSource.h"

@interface HippyBaseListViewCell : UICollectionViewCell;
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, assign) UIView *cellView;
@property (nonatomic, weak) HippyVirtualCell *node;

@end

