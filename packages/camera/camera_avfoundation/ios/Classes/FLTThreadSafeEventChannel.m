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
  __weak typeof(self) weakSelf = self;
  FLTEnsureToRunOnMainQueue(^{
    typeof(self) strongSelf = weakSelf;
    if (!strongSelf) return;
    [strongSelf.channel setStreamHandler:handler];
    completion();
  });
}

@end
