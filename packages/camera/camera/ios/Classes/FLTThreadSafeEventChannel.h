// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * A thread safe wrapper for FlutterEventChannel that can be called from any thread, by dispatching
 * its underlying engine APIs to the main thread.
 */
@interface FLTThreadSafeEventChannel : NSObject

/**
 * Creates a FLTThreadSafeEventChannel by wrapping a FlutterEventChannel object.
 * @param channel The FlutterEventChannel object to be wrapped.
 */
- (instancetype)initWithEventChannel:(FlutterEventChannel *)channel;

/*
 * Registers a handler for stream setup requests from the Flutter side on main thread.
 # Completion block runs on main thread.
 */
- (void)setStreamHandler:(nullable NSObject<FlutterStreamHandler> *)handler
              completion:(void (^)(void))completion;

@end

NS_ASSUME_NONNULL_END
