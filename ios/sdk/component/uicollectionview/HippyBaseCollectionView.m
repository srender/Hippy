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
//        NSString *direction = self.node.props[@"listScrollDirection"];
//        if([ direction isEqualToString:@"horizontal"]){
            // 搭配alwaysBounceHorizontal
            flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//        }else{
//            //搭配alwaysBounceVertical
//            flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
//        }
        
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, fDeviceWidth, fDeviceHeight) collectionViewLayout:flowLayout];
        //_collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        
        [self addSubview:_collectionView];
        //设置代理
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        //背景颜色
        _collectionView.backgroundColor = [UIColor clearColor];
        //自适应大小
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        //水平指示器
        _collectionView.showsHorizontalScrollIndicator = NO;
//
//        if([ direction isEqualToString:@"horizontal"]){
//        //水平方向滑动
            _collectionView.alwaysBounceHorizontal = YES;
//        }else{
//            //竖直方向滚动
//            _collectionView.alwaysBounceVertical=YES;
//        }
//
        
       
        
        [_collectionView registerClass:[HippyBaseCollectionViewCell class] forCellWithReuseIdentifier:@"HippyBaseCollectionViewCell"];
        
    }
}


#pragma mark 定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_dataSource numberOfCellForSection: section];
}

//实现动态 cell 每个item 大小 客户端的flow itemSize决定
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    HippyVirtualCollectionCell *node = (HippyVirtualCollectionCell *)[self.node.subNodes objectAtIndex:indexPath.row];
    return node.frame.size;
}



//-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
//    return UIEdgeInsetsMake(0, 5, 0, 0);
//}


#pragma mark 每个UICollectionView展示的内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"fuck indexpath %d", indexPath.row);
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
    
    //[self initCollectionView];
    
    
    NSNumber *number = self.node.props[@"numberOfSection"];
    //NSString *direction = self.node.props[@"listScrollDirection"];
    
    if ([number isEqual:[NSNull null]]) {
           return NO;
    }
    
//    if(direction === "vertical"){
//        //flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
//    }
    
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
    
    //设置方向 可滑动大小
    
    
    _subNodes = [self.node.subNodes filteredArrayUsingPredicate:predicate];
    
    
    if ([_subNodes count] == numberOfSection) {
        if (numberOfSection == 0 && _preNumberOfSection == numberOfSection) return NO;
        [self reloadData];
        _preNumberOfSection = numberOfSection;
        return YES;
    }
    return NO;
}

//- (UICollectionView *)collectionView
//{
//    if (!_collectionView)
//    {
//        [self initCollectionView];
//    }
//    return _collectionView;
//}

- (void)reloadData
{
    [_dataSource setDataSource:(NSArray <HippyVirtualCollectionCell *> *)_subNodes];
    [self.collectionView reloadData];
    
    if (self.initialContentOffset) {
        [self.collectionView setContentOffset:CGPointMake(0, self.initialContentOffset) animated:NO];
        self.initialContentOffset = 0;
    }

    
    if (!_isInitialListReady) {
        _isInitialListReady = YES;
        if (self.initialListReady) {
            self.initialListReady(@{});
        }
    }
}



- (void) hippySetFrame:(CGRect)frame {
  [super hippySetFrame:frame];
  self.collectionView.frame = self.bounds;
}




- (BOOL)isManualScrolling
{
  return _manualScroll;
}


#pragma mark touch conflict
- (HippyRootView *)rootView
{
    if (_rootView) {
        return _rootView;
    }
    
    UIView *view = [self superview];
    
    while (view && ![view isKindOfClass: [HippyRootView class]]) {
        view = [view superview];
    }
    
    if ([view isKindOfClass: [HippyRootView class]]) {
        _rootView = (HippyRootView *)view;
        return _rootView;
    } else
        return nil;
}

- (void)cancelTouch
{
    HippyRootView *view = [self rootView];
    if (view) {
        [view cancelTouches];
    }
}


#pragma mark -Scrollable

- (void)setScrollEnabled:(BOOL)value
{
    [_collectionView setScrollEnabled:value];
}

- (void)setListScrollDirection:(NSString *)direction
{
    // krisye
    NSLog(@"%@", direction);
}


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
    // CGSizeMake(2000, 80);
    // self.collectionView.contentSize;
}

- (NSHashTable *)scrollListeners
{
    return _scrollListeners;
}


- (void)scrollToContentOffset:(CGPoint)offset animated:(BOOL)animated
{
    [self.collectionView setContentOffset: offset animated: animated];
}


#pragma mark - Scroll

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%ld",indexPath.row);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSTimeInterval now = CACurrentMediaTime();
    if ((self.scrollEventThrottle > 0 && self.scrollEventThrottle < (now - _lastScrollDispatchTime))) {
        if (self.onScroll) {
            self.onScroll([self scrollBodyData]);
        }
        _lastScrollDispatchTime = now;
    }
    
    for (NSObject<UIScrollViewDelegate> *scrollViewListener in _scrollListeners) {
        if ([scrollViewListener respondsToSelector:@selector(scrollViewDidScroll:)]) {
            [scrollViewListener scrollViewDidScroll:scrollView];
        }
    }
    
    [_headerRefreshView scrollViewDidScroll];
    [_footerRefreshView scrollViewDidScroll];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.onScrollBeginDrag) {
        self.onScrollBeginDrag([self scrollBodyData]);
    }
    _manualScroll = YES;
    [self cancelTouch];
    for (NSObject<UIScrollViewDelegate> *scrollViewListener in _scrollListeners) {
        if ([scrollViewListener respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
            [scrollViewListener scrollViewWillBeginDragging:scrollView];
        }
    }
}


- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
  if (velocity.y == 0 && velocity.x == 0)
  {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      self->_manualScroll = NO;
    });
  }
    
    if (self.onScrollEndDrag) {
        self.onScrollEndDrag([self scrollBodyData]);
    }
    
    for (NSObject<UIScrollViewDelegate> *scrollViewListener in _scrollListeners) {
        if ([scrollViewListener respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
            [scrollViewListener scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
        }
    }
}





- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        _manualScroll = NO;
    }
    for (NSObject<UIScrollViewDelegate> *scrollViewListener in _scrollListeners) {
        if ([scrollViewListener respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
            [scrollViewListener scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
        }
    }
    [_headerRefreshView scrollViewDidEndDragging];
    [_footerRefreshView scrollViewDidEndDragging];
}


- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (self.onMomentumScrollBegin) {
        self.onMomentumScrollBegin([self scrollBodyData]);
    }
    for (NSObject<UIScrollViewDelegate> *scrollViewListener in _scrollListeners) {
        if ([scrollViewListener respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
            [scrollViewListener scrollViewWillBeginDecelerating:scrollView];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self->_manualScroll = NO;
    });
    
    if (self.onMomentumScrollEnd) {
        self.onMomentumScrollEnd([self scrollBodyData]);
    }
    
    for (NSObject<UIScrollViewDelegate> *scrollViewListener in _scrollListeners) {
        if ([scrollViewListener respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
            [scrollViewListener scrollViewDidEndDecelerating:scrollView];
        }
    }
}


- (NSDictionary *)scrollBodyData
{
    return @{@"contentOffset": @{@"x": @(self.collectionView.contentOffset.x), @"y": @(self.collectionView.contentOffset.y)}};
}


@end


