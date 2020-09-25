#import "HippyBaseListView.h"
#import "HippyBridge.h"
#import "HippyRootView.h"
#import "UIView+Hippy.h"
#import "HippyScrollProtocol.h"
#import "HippyHeaderRefresh.h"
#import "HippyFooterRefresh.h"
#import "UIView+AppearEvent.h"

- (void)initCollectionView
{
    if(_collectionView == nil){
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing  = 1;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[[UICollectionView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 100) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;

    }
    [self addSubview:_collectionView];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}
