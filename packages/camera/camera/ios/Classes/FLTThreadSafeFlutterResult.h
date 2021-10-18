// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>

/**
 * Wrapper for FlutterResult  that always delivers the result on the main thread.
 */
@interface FLTThreadSafeFlutterResult : NSObject

/**
 * Gets the original FlutterResult object wrapped by this FLTThreadSafeFlutterResult instance.
 */
@property(readonly, nonatomic, nonnull) FlutterResult flutterResult;

/**
 * Initializes with a FlutterResult object.
 * @param result The FlutterResult object that the result will be given to.
 */
- (nonnull instancetype)initWithResult:(nonnull FlutterResult)result;

/**
 * Sends a successful result without any data.
 */
- (void)sendSuccess;

/**
 * Sends a successful result with data.
 * @param data Result data that is send to the Flutter Dart side.
 */
- (void)sendSuccessWithData:(nonnull id)data;

/**
 * Sends an NSError as result
 * @param error Error that will be send as FlutterError.
 */
- (void)sendError:(nonnull NSError*)error;

/**
 * Sends a FlutterError as result.
 */
- (void)sendErrorWithCode:(nonnull NSString*)code
                  message:(nullable NSString*)message
                  details:(nullable id)details;

/**
 * Sends FlutterMethodNotImplemented as result.
 */
- (void)sendNotImplemented;
@end
