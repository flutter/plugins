// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Queue-specific context data to be associated with the capture session queue.
extern const char *FLTCaptureSessionQueueSpecific;

/// A class that contains dispatch queue related helper functions.
@interface QueueHelper : NSObject

/// Ensure the given block to be run on the main queue.
/// If caller site is already on the main queue, the block will be run synchronously. Otherwise, the
/// block will be dispatch asynchronously to the main queue.
/// @param block the block to be run on the main queue.
+ (void)ensureToRunOnMainQueue:(void (^)(void))block;

/// Sets the queue-specific context data for a given queue.
/// @param specific the queue-specific context data.
/// @param queue the queue to be associated with the context data.
+ (void)setSpecific:(const char *)specific forQueue:(dispatch_queue_t)queue;

/// Check if the caller is on a certain queue specified by its queue-specifc context data.
/// @returns YES if the caller is on a certain queue specified by its queue-specific context data.
/// NO otherwise.
+ (BOOL)isCurrentlyOnQueueWithSpecific:(const char *)specific;

@end

NS_ASSUME_NONNULL_END
