//
//  HippyBaseCollectionViewManager.m
//  HippyDemo
//
//  Created by K-slay on 2020/11/15.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "HippyBaseCollectionViewManager.h"
#import "HippyBaseCollectionView.h"
#import "HippyVirtualNode.h"
@implementation HippyBaseCollectionViewManager

HIPPY_EXPORT_MODULE(CollectionView)

HIPPY_EXPORT_VIEW_PROPERTY(scrollEventThrottle, NSTimeInterval)
HIPPY_EXPORT_VIEW_PROPERTY(initialListReady, HippyDirectEventBlock);
HIPPY_EXPORT_VIEW_PROPERTY(onScrollBeginDrag, HippyDirectEventBlock)
HIPPY_EXPORT_VIEW_PROPERTY(onScroll, HippyDirectEventBlock)
HIPPY_EXPORT_VIEW_PROPERTY(onScrollEndDrag, HippyDirectEventBlock)
HIPPY_EXPORT_VIEW_PROPERTY(onMomentumScrollBegin, HippyDirectEventBlock)
HIPPY_EXPORT_VIEW_PROPERTY(onMomentumScrollEnd, HippyDirectEventBlock)
HIPPY_EXPORT_VIEW_PROPERTY(onRowWillDisplay, HippyDirectEventBlock)
HIPPY_EXPORT_VIEW_PROPERTY(onEndReached, HippyDirectEventBlock)
HIPPY_EXPORT_VIEW_PROPERTY(preloadItemNumber, NSUInteger)
HIPPY_EXPORT_VIEW_PROPERTY(bounces, BOOL)
HIPPY_EXPORT_VIEW_PROPERTY(initialContentOffset, CGFloat)
HIPPY_EXPORT_VIEW_PROPERTY(showScrollIndicator, BOOL)
HIPPY_EXPORT_VIEW_PROPERTY(scrollEnabled, BOOL)
HIPPY_EXPORT_VIEW_PROPERTY(listScrollDirection, NSString)

- (UIView *)view
{
    return [[HippyBaseCollectionView alloc] initWithBridge: self.bridge];
}

- (HippyVirtualNode *)node:(NSNumber *)tag name:(NSString *)name props:(NSDictionary *)props
{
    return [HippyVirtualCollectionList createNode: tag viewName: name props: props];
}

HIPPY_EXPORT_METHOD(scrollToIndex:(nonnull NSNumber *)hippyTag
                                    xIndex:(__unused NSNumber *)xIndex
                                    yIndex:(__unused NSNumber *)yIndex
                                    animation:(nonnull NSNumber *)animation)
{
    [self.bridge.uiManager addUIBlock:
     ^(__unused HippyUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry){
         HippyBaseCollectionView *view = (HippyBaseCollectionView *)viewRegistry[hippyTag];
         if (view == nil) return ;
         if (![view isKindOfClass:[HippyBaseCollectionView class]]) {
             HippyLogError(@"Invalid view returned from registry, expecting HippyBaseListView, got: %@", view);
         }
         [view scrollToIndex: yIndex.integerValue animated: [animation boolValue]];
     }];
}

HIPPY_EXPORT_METHOD(scrollToContentOffset:(nonnull NSNumber *)hippyTag
                                    x:(nonnull NSNumber *)x
                                    y:(nonnull NSNumber *)y
                                    animation:(nonnull NSNumber *)animation)
{
    [self.bridge.uiManager addUIBlock:
     ^(__unused HippyUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry){
         HippyBaseCollectionView *view = (HippyBaseCollectionView *)viewRegistry[hippyTag];
         if (view == nil) return ;
         if (![view isKindOfClass:[HippyBaseCollectionView class]]) {
             HippyLogError(@"Invalid view returned from registry, expecting HippyBaseListView, got: %@", view);
         }
         [view scrollToContentOffset:CGPointMake([x floatValue], [y floatValue]) animated: [animation boolValue]];
     }];
}



@end
