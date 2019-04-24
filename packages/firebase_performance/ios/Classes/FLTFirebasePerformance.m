// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FirebasePerformancePlugin.h"

@interface FLTFirebasePerformance ()
@property id<FlutterBinaryMessenger> binaryMessenger;
@end

@implementation FLTFirebasePerformance
+ (void)registerWithRegistrar:(nonnull NSObject<FlutterPluginRegistrar> *)registrar {}

- (instancetype _Nonnull)initWithMessenger:(NSObject<FlutterBinaryMessenger> *_Nonnull)messenger {
  self = [self init];
  if (self) {
    _binaryMessenger = messenger;
  }

  return self;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    if (![FIRApp appNamed:@"__FIRAPP_DEFAULT"]) {
      NSLog(@"Configuring the default Firebase app...");
      [FIRApp configure];
      NSLog(@"Configured the default Firebase app %@.", [FIRApp defaultApp].name);
    }
  }

  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([@"FirebasePerformance#isPerformanceCollectionEnabled" isEqualToString:call.method]) {
    result(@([[FIRPerformance sharedInstance] isDataCollectionEnabled]));
  } else if ([@"FirebasePerformance#setPerformanceCollectionEnabled" isEqualToString:call.method]) {
    NSNumber *enable = call.arguments;
    [[FIRPerformance sharedInstance] setDataCollectionEnabled:[enable boolValue]];
    result(nil);
  } else if ([@"Trace#start" isEqualToString:call.method]) {
    [self handleTraceStart:call result:result];
  } else if ([@"Trace#stop" isEqualToString:call.method]) {
    [self handleTraceStop:call result:result];
  } else if ([@"HttpMetric#start" isEqualToString:call.method]) {
    [self handleHttpMetricStart:call result:result];
  } else if ([@"HttpMetric#stop" isEqualToString:call.method]) {
    [self handleHttpMetricStop:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}
@end
