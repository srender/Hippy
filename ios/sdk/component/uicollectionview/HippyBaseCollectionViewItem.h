//
//  HippyBaseCollectionViewItem.h
//  HippyDemo
//
//  Created by K-slay on 2020/11/15.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HippyComponent.h"

NS_ASSUME_NONNULL_BEGIN

@interface HippyBaseCollectionViewItem : UIView

@property (nonatomic, strong) id type;
@property (nonatomic, assign) BOOL isSticky;
@property (nonatomic, copy) HippyDirectEventBlock onAppear;
@property (nonatomic, copy) HippyDirectEventBlock onDisappear;

@end


NS_ASSUME_NONNULL_END
