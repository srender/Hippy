//
//  HippyBaseListView4DataSource.h
//  HippyDemo
//
//  Created by K-slay on 2020/10/27.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HippyVirtualNode.h"

@interface HippyBaseCollectionViewDataSource : NSObject

- (void)setDataSource:(NSArray <HippyVirtualCollectionCell *> *)dataSource;
- (HippyVirtualCollectionCell *)cellForIndexPath:(NSIndexPath *)indexPath;
- (HippyVirtualCollectionCell *)headerForSection:(NSInteger)section;
- (NSInteger)numberOfSection;
- (NSInteger)numberOfCellForSection:(NSInteger)section;
- (NSIndexPath *)indexPathOfCell:(HippyVirtualCollectionCell *)cell;
- (NSIndexPath *)indexPathForFlatIndex:(NSInteger)index;

@end

