// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>

@interface FLTThreadSafeFlutterResult : NSObject
- (id _Nonnull)initWithResult:(FlutterResult _Nonnull)result;
- (void)success;
- (void)successWithData:(id _Nonnull)data;
- (void)error:(NSError* _Nonnull)error;
- (void)notImplemented;
- (void)errorWithCode:(NSString* _Nonnull)code
              message:(NSString* _Nullable)message
              details:(id _Nullable)details;
@end
