// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTThreadSafeMethodChannel.h"

@implementation FLTThreadSafeMethodChannel {
  FlutterMethodChannel *_channel;
}

- (instancetype)initWithMethodChannel:(FlutterMethodChannel *)channel {
  self = [super init];
  if (self) {
    _channel = channel;
  }
  return self;
}

- (void)invokeMethod:(NSString *)method arguments:(id)arguments {
  if (!NSThread.isMainThread) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self->_channel invokeMethod:method arguments:arguments];
    });
  } else {
    [_channel invokeMethod:method arguments:arguments];
  }
}

@end
