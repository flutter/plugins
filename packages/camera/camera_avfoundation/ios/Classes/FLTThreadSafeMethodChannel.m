// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTThreadSafeMethodChannel.h"
#import "QueueUtils.h"

@interface FLTThreadSafeMethodChannel ()
@property(nonatomic, strong) FlutterMethodChannel *channel;
@end

@implementation FLTThreadSafeMethodChannel

- (instancetype)initWithMethodChannel:(FlutterMethodChannel *)channel {
  self = [super init];
  if (self) {
    _channel = channel;
  }
  return self;
}

- (void)invokeMethod:(NSString *)method arguments:(id)arguments {
  __weak typeof(self) weakSelf = self;
  FLTEnsureToRunOnMainQueue(^{
    [weakSelf.channel invokeMethod:method arguments:arguments];
  });
}

@end
