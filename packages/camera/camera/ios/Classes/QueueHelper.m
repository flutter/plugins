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

+ (dispatch_queue_t)createQueueWithLabel:(const char *)label specific:(const char *)specific {
  dispatch_queue_t queue = dispatch_queue_create(label, NULL);
  dispatch_queue_set_specific(queue, specific, (void *)specific, NULL);
  return queue;
}

+ (BOOL)isCurrentlyOnQueueWithSpecific:(const char *)specific {
  return dispatch_get_specific(specific);
}

@end
