// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>

/**
 Wrapper object that always delivers the result on the main thread.
 */
@interface FLTThreadSafeFlutterResult : NSObject

/**
 Initialize with a FlutterResult object.
 @param result The FlutterResult object that the result will be given to.
 */
- (id _Nonnull)initWithResult:(FlutterResult _Nonnull)result;

/**
 Send a successful result without any data.
 */
- (void)success;

/**
 Send a successful result with data.
 @param data Result data that is send to the Flutter Dart side.
 */
- (void)successWithData:(id _Nonnull)data;

/**
 Send an error as result
 @param error Error that will be send as FlutterError.
 */
- (void)error:(NSError* _Nonnull)error;

/**
 Send a FlutterError as result.
 */
- (void)errorWithCode:(NSString* _Nonnull)code
              message:(NSString* _Nullable)message
              details:(id _Nullable)details;

/**
 Send FlutterMethodNotImplemented as result.
 */
- (void)notImplemented;
@end
