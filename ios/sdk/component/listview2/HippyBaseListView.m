#import "HippyBaseListView.h"
#import "HippyBridge.h"
#import "HippyRootView.h"
#import "UIView+Hippy.h"
#import "HippyScrollProtocol.h"
#import "HippyHeaderRefresh.h"
#import "HippyFooterRefresh.h"
#import "UIView+AppearEvent.h"

#define CELL_TAG 10101

@implementation HippyBaseListViewCell

- (instancetype)initWithStyle:(UICollectionViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [ super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (UIView *)cellView
{
    return [self.contentView viewWithTag: CELL_TAG]
}

- (void)setCellView:(UIView *)cellView
{
    UIView *selfCellView = [self cellView];
    if(selfCellView != cellView){
        [selfCellView removeFromSuperview];
        cellView.tag = CELL_TAG;
        [self.contentView addSubview: cellView];
    }
}
@end

@interface HippyBaseListView() <HippyScrollProtocol,HippyRefreshDelegate>

@end

@implementation HippyBaseListView{
    __weak HippyBridge *_bridge;
    __weak HippyRootView *_rootView;
    NSHashTable * _scrollListeners;
    BOOL _isInitialListReady;
    NSUInteger _preNumberOfRows;
    NSTimeInterval _lastScrollDispatchTime;
    NSArray<HippyVirtualNode *> *_subNodes;
    //估计不需要 UICollection不存在
    HippyHeaderRefresh *_headerRefreshView;
    HippyFooterRefresh *_footerRefreshView;
}

@synthesize node = _node;

- (instancetype)initWithBridge(HippyBridge *)bridge
{
    if(self = [super initWithFrame:CGRectZero]){
        _bridge = bridge;
        _scrollListeners = [NSHashTable weakObjectsHashTable];
        _dataSource = [HippyBaseListViewDataSource new];
        _isInitialListReady = NO;
        _preNumberOfRows = 0;
        _preloadItemNumber = 1;
        [self initCollectionView]
    }
}


- (void)invalidate
{
	[_scrollListeners removeAllObjects];
}

- (Class)listViewCellClass
{
	return [HippyBaseListViewCell class];
}

- (void)initCollectionView
{
    if(_collectionView == nil){
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero style:UICollectionViewStylePlain]
    }
}