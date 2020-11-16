//
//  HippyBaseListView4DataSource.m
//  HippyDemo
//
//  Created by K-slay on 2020/10/27.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "HippyBaseCollectionViewDataSource.h"

@implementation HippyBaseCollectionViewDataSource {
    NSMutableArray *_sections;
}

- (instancetype)init
{
    if (self = [super init]) {
        _sections = [NSMutableArray new];
    }
    return self;
}

- (void)setDataSource:(NSArray <HippyVirtualCollectionCell *> *)dataSource
{
    NSMutableArray *sections = [NSMutableArray new];
    NSMutableArray *lastSection = [NSMutableArray new];
    HippyVirtualCollectionCell * lastStickyCell = nil;
    NSInteger index = 0;
    for (HippyVirtualCollectionCell *cell in dataSource) {
        if (cell.sticky) {
            
            if (lastSection.count == 0) {
                lastStickyCell = cell;
            } else {
                if (lastStickyCell)
                    [sections addObject: @{@"cell": lastSection, @"header": lastStickyCell}];
                else {
                    [sections addObject: @{@"cell": lastSection}];
                }
                lastSection = [NSMutableArray array];
                lastStickyCell = cell;
            }
        } else {
            [lastSection addObject: cell];
        }
        
        if (index == dataSource.count - 1 && lastStickyCell != nil) {
            [sections addObject: @{@"cell": lastSection, @"header": lastStickyCell}];
        }
        
        index++;
    }
    
    if (sections.count == 0 && lastSection.count != 0) {
        [sections addObject: @{@"cell": lastSection}];
        //sections = lastSection;
    }
    
    _sections = sections;
}

- (HippyVirtualCollectionCell *)cellForIndexPath:(NSIndexPath *)indexPath
{
    if (_sections.count > indexPath.section) {
        NSArray *cells = _sections[indexPath.section][@"cell"];
        if (cells.count > indexPath.row) {
            return (HippyVirtualCollectionCell *)cells[indexPath.row];
        }
    }
    return nil;
}

//FIXME: 这个地方默认section只有一个，否则row应该在单次循环后置0。目前ListView暂时不支持多section
- (NSIndexPath *)indexPathOfCell:(HippyVirtualCollectionCell *)cell
{
    NSInteger section = 0;
    NSInteger row = 0;
    for (NSDictionary *sec in _sections) {
        NSArray *cells = sec[@"cell"];
        for (HippyVirtualCollectionCell *node in cells) {
            if ([node isEqual: cell]) {
                break;
            }
            row++;
        }
        if (row != cells.count) {
            break;
        }
        section++;
    }
    
    if (section == _sections.count) {
        return nil;
    }
    return [NSIndexPath indexPathForRow: row inSection: section];
}

- (HippyVirtualCollectionCell *)headerForSection:(NSInteger)section
{
    if (_sections.count > section) {
        HippyVirtualCollectionCell *header = _sections[section][@"header"];
        return header;
    }
    return nil;
}

- (NSInteger)numberOfSection
{
    return _sections.count;
    //_sections.count;
}

- (NSInteger)numberOfCellForSection:(NSInteger)section
{
    
    if (_sections.count > section) {
        NSArray *cells = _sections[section][@"cell"];
        return cells.count;
    }
    return 0;
}

- (NSIndexPath *)indexPathForFlatIndex:(NSInteger)index
{
    NSInteger totalIndex = 0;
    NSInteger sectionIndex = 0;
    NSInteger rowIndex = 0;
    NSIndexPath *indexPath = nil;
    
    for (NSDictionary *section in _sections) {
        rowIndex = 0;
        if (index == totalIndex) {
            indexPath = [NSIndexPath indexPathForRow: 0 inSection: sectionIndex];
            break;
        }
        totalIndex += section[@"header"] == nil ? 0 : 1;
        
        NSArray *cells = section[@"cell"];
        for (__unused HippyVirtualCollectionCell *node in cells) {
            if (totalIndex == index) {
                indexPath = [NSIndexPath indexPathForRow: rowIndex inSection: sectionIndex];
                break;
            }
            rowIndex++;
            totalIndex++;
        }
        
        sectionIndex++;
    }
    
    return indexPath;
}
@end
