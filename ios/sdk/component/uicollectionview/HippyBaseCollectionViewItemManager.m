//
//  HippyBaseListItemView4Manager.m
//  HippyDemo
//
//  Created by K-slay on 2020/10/27.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "HippyBaseCollectionViewItemManager.h"
#import "HippyBaseCollectionViewItem.h"
#import "HippyVirtualNode.h"

@implementation HippyBaseCollectionViewItemManager

HIPPY_EXPORT_MODULE(CollectionViewItem)

HIPPY_EXPORT_VIEW_PROPERTY(type, id)
HIPPY_EXPORT_VIEW_PROPERTY(isSticky, BOOL)
HIPPY_EXPORT_VIEW_PROPERTY(onAppear, HippyDirectEventBlock)
HIPPY_EXPORT_VIEW_PROPERTY(onDisappear, HippyDirectEventBlock)

- (UIView *)view
{
    return [HippyBaseCollectionViewItem new];
}

- (HippyVirtualNode *)node:(NSNumber *)tag name:(NSString *)name props:(NSDictionary *)props
{
    return [HippyVirtualCollectionCell createNode: tag viewName: name props: props];
}

@end
