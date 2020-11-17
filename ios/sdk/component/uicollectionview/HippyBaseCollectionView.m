//
//  HippyBaseListView4.m
//  HippyDemo
//
//  Created by K-slay on 2020/10/27.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "HippyBaseCollectionView.h"
#import "HippyBridge.h"
#import "HippyRootView.h"
#import "UIView+Hippy.h"
#import "HippyScrollProtocol.h"
#import "HippyHeaderRefresh.h"
#import "HippyFooterRefresh.h"
#import "UIView+AppearEvent.h"


#define fDeviceWidth ([UIScreen mainScreen].bounds.size.width)
#define fDeviceHeight ([UIScreen mainScreen].bounds.size.height)
static float AD_height = 150;//广告栏高度

#define CELL_TAG 10102


@implementation HippyBaseCollectionViewCell


- (UIView *)cellView
{
    return [self.contentView viewWithTag: CELL_TAG];
}

- (void)setCellView:(UIView *)cellView
{
    UIView *selfCellView = [self cellView];
    if (selfCellView != cellView) {
        [selfCellView removeFromSuperview];
        cellView.tag = CELL_TAG;
        [self.contentView addSubview: cellView];
    }
}
@end


@interface HippyBaseCollectionView() <HippyScrollProtocol, HippyRefreshDelegate>


@end

@implementation HippyBaseCollectionView {
    __weak HippyBridge *_bridge;
    __weak HippyRootView *_rootView;
    NSHashTable * _scrollListeners;
    BOOL _isInitialListReady;
    NSUInteger _preNumberOfSection;
    NSTimeInterval _lastScrollDispatchTime;
    NSArray<HippyVirtualNode *> *_subNodes;
    HippyHeaderRefresh *_headerRefreshView;
    HippyFooterRefresh *_footerRefreshView;
}

@synthesize node = _node;

- (instancetype)initWithBridge:(HippyBridge *)bridge
{
    if (self = [super initWithFrame: CGRectZero])
    {
        _bridge = bridge;
        _scrollListeners = [NSHashTable weakObjectsHashTable];
        _dataSource = [HippyBaseCollectionViewDataSource new];
        _isInitialListReady = NO;
        _preNumberOfSection = 2;
        _preloadItemNumber = 10;
        [self initCollectionView];
    }
    return self;
}


- (void)invalidate
{
    [_scrollListeners removeAllObjects];
}


- (Class)listViewCellClass
{
    return [HippyBaseCollectionViewCell class];
}

- (void) setPreloadItemNumber:(NSUInteger)preloadItemNumber {
    _preloadItemNumber = MAX(1, preloadItemNumber);
}



- (void)initCollectionView
{
    if (_collectionView == nil) {
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        /*
            1、UICollectionViewScrollDirectionHorizontal  水平滑动
            2、UICollectionViewScrollDirectionVertical  竖直滑动
            */
        //flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        //flowLayout.headerReferenceSize = CGSizeMake(fDeviceWidth, AD_height+10);//头部大小
        //_collectionView.alwaysBounceHorizontal=YES;
        //flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
      
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, fDeviceWidth, fDeviceHeight) collectionViewLayout:flowLayout];
        //_collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
      
        //设置代理
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        //背景颜色
        _collectionView.backgroundColor = [UIColor clearColor];
        //自适应大小
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        
        //竖直方向滚动
        _collectionView.alwaysBounceVertical=YES;
        
        
        //水平方向滑动
        //_collectionView.alwaysBounceHorizontal = YES;
        
        [_collectionView registerClass:[HippyBaseCollectionViewCell class] forCellWithReuseIdentifier:@"HippyBaseCollectionViewCell"];
        
        
        [self addSubview:_collectionView];
    }
}


#pragma mark 定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_dataSource numberOfCellForSection: section];
}



#pragma mark 每个UICollectionView展示的内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HippyVirtualCollectionCell *newNode = [_dataSource cellForIndexPath: indexPath];
    //NSString *identifier = newNode.itemViewType;
    static NSString *cellIdentifier = @"HippyBaseCollectionViewCell";

    HippyBaseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
//    while (cell && !([[(HippyVirtualCollectionCell *)cell.node itemViewType] isEqualToString: newNode.itemViewType])) {
//        // 此处cell还在tableView上，将导致泄漏
//        [cell removeFromSuperview];
//        cell =(HippyBaseCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
//        
//        if (cell == nil) {
//            HippyLogInfo(@"cannot find right cell:%@", @(indexPath.row));
//        }
//    }
//    if (cell.node.cell != cell) {
//        // 此处cell还在tableView上，将导致泄漏
//        [cell removeFromSuperview];
//        cell = nil;
//    }

    if (cell == nil) {
        // cell = [[[self listViewCellClass] alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: identifier];
        cell.collectionView = collectionView;
        cell.cellView = [_bridge.uiManager createViewFromNode:newNode];
    } else {
        UIView *cellView = [_bridge.uiManager updateNode: cell.node withNode: newNode];
        if (cellView == nil) {
            cell.cellView = [_bridge.uiManager createViewFromNode: newNode];
        } else {
            cell.cellView = cellView;
        }
    }
//    cell.node.cell = nil;
//
//    newNode.cell = cell;
//    cell.node = newNode;
    
    //cell.backgroundColor = [UIColor blueColor];
    return cell;
}


- (BOOL)flush
{
    NSNumber *number = self.node.props[@"numberOfSection"];
    if ([number isEqual:[NSNull null]]) {
           return NO;
    }
    
    NSUInteger numberOfSection = [number integerValue];
    NSLog(@"====numberOfSection===:%d",(int)numberOfSection);
    static dispatch_once_t onceToken;
    static NSPredicate *predicate = nil;
    dispatch_once(&onceToken, ^{
        predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            if ([evaluatedObject isKindOfClass:[HippyVirtualCollectionCell class]]) {
                return YES;
            }
            return NO;
        }];
    });
    
    _subNodes = [self.node.subNodes filteredArrayUsingPredicate:predicate];
    
    
    if ([_subNodes count] == numberOfSection) {
        if (numberOfSection == 0 && _preNumberOfSection == numberOfSection) return NO;
        [self reloadData];
        _preNumberOfSection = numberOfSection;
        return YES;
    }
    return NO;
}



- (void)reloadData
{
    [_dataSource setDataSource:(NSArray <HippyVirtualCollectionCell *> *)_subNodes];
    [_collectionView reloadData];
    
//    if (self.initialContentOffset) {
//        [_collectionView setContentOffset:CGPointMake(0, self.initialContentOffset) animated:NO];
//        self.initialContentOffset = 0;
//    }
//
    
    if (!_isInitialListReady) {
        _isInitialListReady = YES;
        if (self.initialListReady) {
            self.initialListReady(@{});
        }
    }
}


- (BOOL)isManualScrolling
{
  return _manualScroll;
}



#pragma mark -Scrollable

- (void)addScrollListener:(NSObject<UIScrollViewDelegate> *)scrollListener
{
    [_scrollListeners addObject: scrollListener];
}

- (void)removeScrollListener:(NSObject<UIScrollViewDelegate> *)scrollListener
{
    [_scrollListeners removeObject: scrollListener];
}

- (UIScrollView *)realScrollView
{
    return self.collectionView;
}

- (CGSize)contentSize
{
    return self.collectionView.contentSize;
}

- (NSHashTable *)scrollListeners
{
    return _scrollListeners;
}


- (void)scrollToContentOffset:(CGPoint)offset animated:(BOOL)animated
{
    [self.collectionView setContentOffset: offset animated: animated];
}


@end


