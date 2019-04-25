// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FirebasePerformancePlugin.h"

@interface FLTFirebasePerformance ()
@property id<FlutterPluginRegistrar> registrar;
@property FIRPerformance *performance;
@end

@implementation FLTFirebasePerformance
+ (void)registerWithRegistrar:(nonnull NSObject<FlutterPluginRegistrar> *)registrar {}

- (instancetype _Nonnull)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *_Nonnull)registrar {
  self = [self init];
  if (self) {
    _performance = [FIRPerformance sharedInstance];
    _registrar = registrar;
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
  NSNumber *enable = call.arguments;
  [_performance setDataCollectionEnabled:[enable boolValue]];
  result(nil);
}

- (void)newTrace:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *traceName = call.arguments[@"traceName"];
  FIRTrace *trace = [_performance traceWithName:traceName];

  NSString *channelName = call.arguments[@"channelName"];
  FlutterMethodChannel* channel = [FlutterMethodChannel
                                   methodChannelWithName:channelName
                                   binaryMessenger:[_registrar messenger]];

  FLTTrace *delegate = [[FLTTrace alloc] initWithTrace:trace registrar:_registrar channel:channel];
  [_registrar addMethodCallDelegate:delegate channel:channel];
  result(nil);
}

- (void)newHttpMetric:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *httpMethod = call.arguments[@"httpMethod"];
  FIRHTTPMethod method = [FLTFirebasePerformance parseHttpMethod:httpMethod];

  NSString *urlString = call.arguments[@"url"];
  NSURL *url = [NSURL URLWithString:urlString];

  FIRHTTPMetric *metric = [[FIRHTTPMetric alloc] initWithURL:url HTTPMethod:method];

  NSString *channelName = call.arguments[@"channelName"];
  FlutterMethodChannel *channel = [FlutterMethodChannel
                                   methodChannelWithName:channelName
                                   binaryMessenger:[_registrar messenger]];

  FLTHttpMetric *delegate = [[FLTHttpMetric alloc] initWithHTTPMetric:metric
                                                            registrar:_registrar
                                                              channel:channel];
  [_registrar addMethodCallDelegate:delegate channel:channel];
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
