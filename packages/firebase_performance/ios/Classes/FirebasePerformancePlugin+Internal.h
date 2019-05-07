// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FirebasePerformancePlugin.h"

@interface FLTFirebasePerformancePlugin (Internal)
+ (void)addMethodHandler:(NSNumber *_Nonnull)handle
           methodHandler:(id<FlutterPlugin> _Nonnull)handler;
+ (void)removeMethodHandler:(NSNumber *_Nonnull)handle;
@end

@interface FLTFirebasePerformance : NSObject <FlutterPlugin>
+ (instancetype _Nonnull)sharedInstance;
@end

@interface FLTTrace : NSObject <FlutterPlugin>
- (instancetype _Nonnull)initWithTrace:(FIRTrace *_Nonnull)trace;
@end

@interface FLTHttpMetric : NSObject <FlutterPlugin>
- (instancetype _Nonnull)initWithHTTPMetric:(FIRHTTPMetric *_Nonnull)metric;
@end
