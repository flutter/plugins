// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTThreadSafeEventChannel.h"

@implementation FLTThreadSafeEventChannel {
  FlutterEventChannel *_channel;
}

- (instancetype)initWithEventChannel:(FlutterEventChannel *)channel {
  self = [super init];
  if (self) {
    _channel = channel;
  }
  return self;
}

- (void)setStreamHandler:(NSObject<FlutterStreamHandler> *)handler {
  if (!NSThread.isMainThread) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self->_channel setStreamHandler:handler];
    });
  } else {
    [_channel setStreamHandler:handler];
  }
}

@end
