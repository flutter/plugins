// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "QueueHelper.h"

const char *FLTCaptureSessionQueueSpecific = "capture_session_queue";

@implementation QueueHelper

+ (void)ensureToRunOnMainQueue:(void (^)(void))block {
  if (!NSThread.isMainThread) {
    dispatch_async(dispatch_get_main_queue(), block);
  } else {
    block();
  }
}

@end
