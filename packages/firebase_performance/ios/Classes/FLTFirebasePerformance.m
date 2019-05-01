// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FirebasePerformancePlugin.h"

@interface FLTFirebasePerformance ()
@property FIRPerformance *performance;
@end

@implementation FLTFirebasePerformance
+ (void)registerWithRegistrar:(nonnull NSObject<FlutterPluginRegistrar> *)registrar {
}

+ (void)sharedInstanceWithCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSNumber *handle = call.arguments[@"handle"];
  [FLTFirebasePerformancePlugin addMethodHandler:handle methodHandler:[FLTFirebasePerformance new]];
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _performance = [FIRPerformance sharedInstance];
  }

  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([@"FirebasePerformance#isPerformanceCollectionEnabled" isEqualToString:call.method]) {
    [self isPerformanceCollectionEnabled:result];
  } else if ([@"FirebasePerformance#setPerformanceCollectionEnabled" isEqualToString:call.method]) {
    [self setPerformanceCollectionEnabled:call result:result];
  } else if ([@"FirebasePerformance#newTrace" isEqualToString:call.method]) {
    [self newTrace:call result:result];
  } else if ([@"FirebasePerformance#newHttpMetric" isEqualToString:call.method]) {
    [self newHttpMetric:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)isPerformanceCollectionEnabled:(FlutterResult)result {
  result(@([_performance isDataCollectionEnabled]));
}

- (void)setPerformanceCollectionEnabled:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSNumber *enable = call.arguments[@"enable"];
  [_performance setDataCollectionEnabled:[enable boolValue]];
  result(nil);
}

- (void)newTrace:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *name = call.arguments[@"name"];
  FIRTrace *trace = [_performance traceWithName:name];
  FLTTrace *handler = [[FLTTrace alloc] initWithTrace:trace];

  NSNumber *handle = call.arguments[@"traceHandle"];
  [FLTFirebasePerformancePlugin addMethodHandler:handle methodHandler:handler];

  result(nil);
}

- (void)newHttpMetric:(FlutterMethodCall *)call result:(FlutterResult)result {
  FIRHTTPMethod method = [FLTFirebasePerformance parseHttpMethod:call.arguments[@"httpMethod"]];
  NSURL *url = [NSURL URLWithString:call.arguments[@"url"]];

  FIRHTTPMetric *metric = [[FIRHTTPMetric alloc] initWithURL:url HTTPMethod:method];
  FLTHttpMetric *handler = [[FLTHttpMetric alloc] initWithHTTPMetric:metric];

  NSNumber *handle = call.arguments[@"httpMetricHandle"];
  [FLTFirebasePerformancePlugin addMethodHandler:handle methodHandler:handler];

  result(nil);
}

+ (FIRHTTPMethod)parseHttpMethod:(NSString *)method {
  if ([@"HttpMethod.Connect" isEqualToString:method]) {
    return FIRHTTPMethodCONNECT;
  } else if ([@"HttpMethod.Delete" isEqualToString:method]) {
    return FIRHTTPMethodDELETE;
  } else if ([@"HttpMethod.Get" isEqualToString:method]) {
    return FIRHTTPMethodGET;
  } else if ([@"HttpMethod.Head" isEqualToString:method]) {
    return FIRHTTPMethodHEAD;
  } else if ([@"HttpMethod.Options" isEqualToString:method]) {
    return FIRHTTPMethodOPTIONS;
  } else if ([@"HttpMethod.Patch" isEqualToString:method]) {
    return FIRHTTPMethodPATCH;
  } else if ([@"HttpMethod.Post" isEqualToString:method]) {
    return FIRHTTPMethodPOST;
  } else if ([@"HttpMethod.Put" isEqualToString:method]) {
    return FIRHTTPMethodPUT;
  } else if ([@"HttpMethod.Trace" isEqualToString:method]) {
    return FIRHTTPMethodTRACE;
  }

  NSString *reason = [NSString stringWithFormat:@"Invalid HttpMethod: %@", method];
  @throw [[NSException alloc] initWithName:NSInvalidArgumentException reason:reason userInfo:nil];
}
@end
