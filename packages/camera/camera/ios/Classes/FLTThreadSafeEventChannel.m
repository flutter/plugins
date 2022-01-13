// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTThreadSafeEventChannel.h"

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
  void (^block)(void) = ^{
    [self.channel setStreamHandler:handler];
    completion();
  };

  if (!NSThread.isMainThread) {
    dispatch_async(dispatch_get_main_queue(), block);
  } else {
    block();
  }
}

@end
