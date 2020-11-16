//
//  HippyBaseListItemView4.m
//  HippyDemo
//
//  Created by K-slay on 2020/10/27.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "HippyBaseListItemView4.h"
#import "UIView+Hippy.h"

@implementation HippyBaseListItemView4

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
