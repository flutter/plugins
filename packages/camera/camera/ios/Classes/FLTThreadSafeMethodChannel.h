// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Wrapper for FlutterMethodChannel that always invokes messages on the main thread
 */
@interface FLTThreadSafeMethodChannel : NSObject

/**
 * Creates a FLTThreadSafeMethodChannel by wrapping a FlutterMethodChannel object.
 * @param channel The FlutterMethodChannel object to be wrapped.
 */
- (instancetype)initWithMethodChannel:(FlutterMethodChannel *)channel;

/**
 * Invokes the specified flutter method with the specified arguments on main thread.
 */
- (void)invokeMethod:(NSString *)method arguments:(nullable id)arguments;

@end

NS_ASSUME_NONNULL_END
