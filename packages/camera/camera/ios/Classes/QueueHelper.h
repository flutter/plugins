// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Queue-specific context data to be associated with the capture session queue.
extern const char *FLTCaptureSessionQueueSpecific;

/// A class that contains dispatch queue related helper functions.
@interface QueueHelper : NSObject

/// Ensures the given block to be run on the main queue.
/// If caller site is already on the main queue, the block will be run synchronously. Otherwise, the
/// block will be dispatched asynchronously to the main queue.
/// @param block the block to be run on the main queue.
+ (void)ensureToRunOnMainQueue:(void (^)(void))block;

/// Creates a dispatch queue with a label and queue-specific context data.
/// @param label label for debugging purpose.
/// @param specific queue-specific context data.
/// @return the created dispatch queue with the given label and queue-specific context data.
+ (dispatch_queue_t)createQueueWithLabel:(const char *)label specific:(const char *)specific;

/// Checks if the caller is on a certain queue specified by its queue-specifc context data.
/// @param specific queue-specific context data.
/// @return YES if the caller is on a certain queue specified by its queue-specific context data;
/// NO otherwise.
+ (BOOL)isCurrentlyOnQueueWithSpecific:(const char *)specific;

@end

NS_ASSUME_NONNULL_END
