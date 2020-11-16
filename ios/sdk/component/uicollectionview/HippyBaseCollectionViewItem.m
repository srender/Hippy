//
//  HippyBaseCollectionViewItem.m
//  HippyDemo
//
//  Created by K-slay on 2020/11/15.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "HippyBaseCollectionViewItem.h"
#import "UIView+Hippy.h"

@implementation HippyBaseCollectionViewItem

- (void)hippySetFrame:(CGRect)frame
{
    [super hippySetFrame: frame];
    self.frame = self.bounds;
}

- (void)viewAppearEvent {
    if (self.onAppear) {
        self.onAppear(@{});
    }
}

- (void)viewDisappearEvent {
    if (self.onDisappear) {
        self.onDisappear(@{});
    }
}

@end
