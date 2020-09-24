
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

@interface HippyBaseListView : UIView <HippyBaseListViewProtocol, HippyScrollableProtocol , UICollectionViewDelegate , UICollectionViewDataSource , HippyInvalidating>
@property (nonatomic, copy) HippyDirectEventBlock initialListReady;
@property (nonatomic, copy) HippyDirectEventBlock onScrollBeginDrag;
@property (nonatomic, copy) HippyDirectEventBlock onScroll;
@property (nonatomic, copy) HippyDirectEventBlock onScrollEndDrag;
@property (nonatomic, copy) HippyDirectEventBlock onMomentumScrollBegin;
@property (nonatomic, copy) HippyDirectEventBlock onMomentumScrollEnd;
@property (nonatomic, copy) HippyDirectEventBlock onRowWillDisplay;
@property (nonatomic, copy) HippyDirectEventBlock onEndReached;
@property (nonatomic, assign) NSUInteger preloadItemNumber;
@property (nonatomic, assign) CGFloat initialContentOffset;
@property (nonatomic, assign) BOOL manualScroll;
@property (nonatomic, assign) BOOL bounces;
@property (nonatomic, assign) BOOL showScrollIndicator;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong, readonly) HippyBaseListViewDataSource *dataSource;
@property (nonatomic, assign) NSTimeInterval scrollEventThrottle;

- (void)reloadData;
- (Class)listViewCellClass;
- (instancetype)initWithBridge:(HippyBridge *)bridge;
- (void)scrollToContentOffset:(CGPoint)point animated:(BOOL)animated;
- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated;
@end
