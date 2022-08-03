// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "PartiallyMockedMapView.h"

@interface PartiallyMockedMapView ()

@property(nonatomic, assign) NSInteger frameObserverCount;

@end

@implementation PartiallyMockedMapView

- (void)addObserver:(NSObject *)observer
         forKeyPath:(NSString *)keyPath
            options:(NSKeyValueObservingOptions)options
            context:(void *)context {
  [super addObserver:observer forKeyPath:keyPath options:options context:context];

  if ([keyPath isEqualToString:@"frame"]) {
    ++self.frameObserverCount;
  }
}

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
  [super removeObserver:observer forKeyPath:keyPath];

  if ([keyPath isEqualToString:@"frame"]) {
    --self.frameObserverCount;
  }
}

@end
