//
//  HippyBaseListView4.h
//  HippyDemo
//
//  Created by K-slay on 2020/10/27.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HippyScrollView.h"
#import "HippyBridge.h"
#import "HippyUIManager.h"
#import "HippyBaseCollectionViewProtocol.h"
#import "HippyBaseCollectionViewDataSource.h"

@interface HippyBaseCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, assign) UIView *cellView;
@property (nonatomic, weak) HippyVirtualCollectionCell *node;

@end

NS_ASSUME_NONNULL_BEGIN
@interface HippyBaseCollectionView : UIView <HippyBaseCollectionViewProtocol, HippyScrollableProtocol, UICollectionViewDelegate, UICollectionViewDataSource, HippyInvalidating>
//@interface HippyBaseListView : UIView <HippyBaseListView4Protocol, HippyScrollableProtocol, UITableViewDelegate, UITableViewDataSource, HippyInvalidating>
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
@property (nonatomic, strong, readonly) HippyBaseCollectionViewDataSource *dataSource;
@property (nonatomic, assign) NSTimeInterval scrollEventThrottle;
@property (nonatomic, assign) UICollectionViewFlowLayout *flowLayout;


- (void)reloadData;
- (Class)listViewCellClass;
- (instancetype)initWithBridge:(HippyBridge *)bridge;
- (void)scrollToContentOffset:(CGPoint)point animated:(BOOL)animated;
- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated;
@end

NS_ASSUME_NONNULL_END
