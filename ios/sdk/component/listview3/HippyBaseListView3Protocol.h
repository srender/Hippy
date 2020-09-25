//
//  HippyBaseListView3Protocol.h
//  HippyDemo
//
//  Created by K-slay on 2020/9/25.
//  Copyright © 2020 tencent. All rights reserved.
//

#ifndef HippyBaseListView3Protocol_h
#define HippyBaseListView3Protocol_h

#import "HippyVirtualNode.h"

@protocol HippyBaseListView3Protocol <NSObject>

- (BOOL)flush;

@property (nonatomic, strong) HippyVirtualList *node;

@end


#endif /* HippyBaseListView3Protocol_h */

