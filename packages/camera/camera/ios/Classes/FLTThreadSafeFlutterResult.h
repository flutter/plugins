// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>

/**
 * Wrapper for FlutterResult  that always delivers the result on the main thread.
 */
@interface FLTThreadSafeFlutterResult : NSObject

/**
 * Initializes with a FlutterResult object.
 * @param result The FlutterResult object that the result will be given to.
 */
- (nonnull id)initWithResult:(nonnull FlutterResult)result;

/**
 * Sends a successful result without any data.
 */
- (void)success;

/**
 * Sends a successful result with data.
 * @param data Result data that is send to the Flutter Dart side.
 */
- (void)successWithData:(nonnull id)data;

/**
 * Sends an NSError as result
 * @param error Error that will be send as FlutterError.
 */
- (void)error:(nonnull NSError*)error;

/**
 * Sends a FlutterError as result.
 */
- (void)errorWithCode:(nonnull NSString*)code
              message:(nullable NSString*)message
              details:(nullable id)details;

/**
 * Sends FlutterMethodNotImplemented as result.
 */
- (void)notImplemented;
@end
