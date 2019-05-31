// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FirebasePerformancePlugin+Internal.h"

@implementation FLTFirebasePerformancePlugin
static NSMutableDictionary<NSNumber *, id<MethodCallHandler>> *methodHandlers;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  methodHandlers = [NSMutableDictionary new];

  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/firebase_performance"
                                  binaryMessenger:[registrar messenger]];

  FLTFirebasePerformancePlugin *instance = [FLTFirebasePerformancePlugin new];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)init {
  self = [super init];
  if (self) {
    if (![FIRApp defaultApp]) {
      [FIRApp configure];
      _traces = [[NSMutableDictionary alloc] init];
    }
  }

  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([@"FirebasePerformance#instance" isEqualToString:call.method]) {
    NSNumber *handle = call.arguments[@"handle"];
    FLTFirebasePerformance *performance = [FLTFirebasePerformance sharedInstance];

    [FLTFirebasePerformancePlugin addMethodHandler:handle methodHandler:performance];
    result(nil);
  } else {
<<<<<<< HEAD
    result(FlutterMethodNotImplemented);
  }
}

- (void)handleTraceStart:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSNumber *handle = call.arguments[@"handle"];
  NSString *name = call.arguments[@"name"];

  FIRTrace *trace = [[FIRPerformance sharedInstance] traceWithName:name];
  [_traces setObject:trace forKey:handle];
  [trace start];
  result(nil);
}

- (void)handleTraceStop:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSNumber *handle = call.arguments[@"handle"];
  FIRTrace *trace = [_traces objectForKey:handle];

  NSDictionary *counters = call.arguments[@"counters"];
  [counters enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSNumber *value, BOOL *stop) {
    [trace incrementCounterNamed:key by:[value integerValue]];
  }];

  NSDictionary *attributes = call.arguments[@"attributes"];
  [attributes enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
    [trace setValue:key forAttribute:value];
  }];

  [trace stop];
  [_traces removeObjectForKey:handle];
  result(nil);
=======
    NSNumber *handle = call.arguments[@"handle"];

    if (![handle isEqual:[NSNull null]]) {
      [methodHandlers[handle] handleMethodCall:call result:result];
    } else {
      result(FlutterMethodNotImplemented);
    }
  }
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
}

+ (void)addMethodHandler:(NSNumber *)handle methodHandler:(id<MethodCallHandler>)handler {
  if (methodHandlers[handle]) {
    NSString *reason =
        [[NSString alloc] initWithFormat:@"Object for handle already exists: %d", handle.intValue];
    @throw [[NSException alloc] initWithName:NSInvalidArgumentException reason:reason userInfo:nil];
  }

  methodHandlers[handle] = handler;
}

<<<<<<< HEAD
- (void)handleHttpMetricStop:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSNumber *handle = call.arguments[@"handle"];
  FIRHTTPMetric *metric = [_httpMetrics objectForKey:handle];

  NSNumber *responseCode = call.arguments[@"httpResponseCode"];
  NSNumber *requestPayloadSize = call.arguments[@"requestPayloadSize"];
  NSString *responseContentType = call.arguments[@"responseContentType"];
  NSNumber *responsePayloadSize = call.arguments[@"responsePayloadSize"];

  if (![responseCode isEqual:[NSNull null]]) metric.responseCode = [responseCode integerValue];
  if (![requestPayloadSize isEqual:[NSNull null]])
    metric.requestPayloadSize = [requestPayloadSize longValue];
  if (![responseContentType isEqual:[NSNull null]])
    metric.responseContentType = responseContentType;
  if (![responsePayloadSize isEqual:[NSNull null]])
    metric.responsePayloadSize = [responsePayloadSize longValue];

  NSDictionary *attributes = call.arguments[@"attributes"];
  [attributes enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
    [metric setValue:key forAttribute:value];
  }];

  [metric stop];
  [_httpMetrics removeObjectForKey:handle];
  result(nil);
=======
+ (void)removeMethodHandler:(NSNumber *)handle {
  [methodHandlers removeObjectForKey:handle];
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
}
@end
