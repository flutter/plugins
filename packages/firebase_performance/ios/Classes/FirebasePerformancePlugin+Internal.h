// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FirebasePerformancePlugin.h"

@protocol MethodCallHandler
@required
- (void)handleMethodCall:(FlutterMethodCall *_Nonnull)call result:(FlutterResult _Nonnull)result;
@end

@interface FLTFirebasePerformancePlugin (Internal)
+ (void)addMethodHandler:(NSNumber *_Nonnull)handle
           methodHandler:(id<MethodCallHandler> _Nonnull)handler;
+ (void)removeMethodHandler:(NSNumber *_Nonnull)handle;
@end

@interface FLTFirebasePerformance : NSObject <MethodCallHandler>
+ (instancetype _Nonnull)sharedInstance;
@end

@interface FLTTrace : NSObject <MethodCallHandler>
- (instancetype _Nonnull)initWithTrace:(FIRTrace *_Nonnull)trace;
@end

@interface FLTHttpMetric : NSObject <MethodCallHandler>
- (instancetype _Nonnull)initWithHTTPMetric:(FIRHTTPMetric *_Nonnull)metric;
@end
