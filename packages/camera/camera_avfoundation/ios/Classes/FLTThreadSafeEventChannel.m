// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTThreadSafeEventChannel.h"
#import "QueueUtils.h"

@interface FLTThreadSafeEventChannel ()
@property(nonatomic, strong) FlutterEventChannel *channel;
@end

@implementation FLTThreadSafeEventChannel

- (instancetype)initWithEventChannel:(FlutterEventChannel *)channel {
  self = [super init];
  if (self) {
    _channel = channel;
  }
  return self;
}

- (void)setStreamHandler:(NSObject<FlutterStreamHandler> *)handler
              completion:(void (^)(void))completion {
  // WARNING: Should not use weak self, because FLTThreadSafeEventChannel is a local variable
  // (retained within call stack, but not in the heap). FLTEnsureToRunOnMainQueue may trigger a
  // context switch (when calling from background thread), in which case using weak self will always
  // result in a nil self. Alternative to using strong self, we can also create a local strong
  // variable to be captured by this block.
  FLTEnsureToRunOnMainQueue(^{
    [self.channel setStreamHandler:handler];
    completion();
  });
}

@end
