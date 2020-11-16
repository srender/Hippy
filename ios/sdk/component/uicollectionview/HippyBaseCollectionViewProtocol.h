//
//  HippyBaseListView4Protocol.h
//  HippyDemo
//
//  Created by K-slay on 2020/10/27.
//  Copyright © 2020 tencent. All rights reserved.
//

#ifndef HippyBaseCollectionViewProtocol_h
#define HippyBaseCollectionViewProtocol_h

#import "HippyVirtualNode.h"

@protocol HippyBaseCollectionViewProtocol <NSObject>

- (BOOL)flush;

@property (nonatomic, strong) HippyVirtualCollectionList *node;

@end


#endif /* HippyBaseListViewProtocol_h */
