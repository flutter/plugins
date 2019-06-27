// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FirebasePerformancePlugin.h"

#import <Firebase/Firebase.h>

@interface FLTFirebasePerformancePlugin ()
@property(nonatomic, retain) NSMutableDictionary *traces;
@property(nonatomic, retain) NSMutableDictionary *httpMetrics;
@end

@implementation FLTFirebasePerformancePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/firebase_performance"
                                  binaryMessenger:[registrar messenger]];
  FLTFirebasePerformancePlugin *instance = [[FLTFirebasePerformancePlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)init {
  self = [super init];
  if (self) {
    if (![FIRApp appNamed:@"__FIRAPP_DEFAULT"]) {
      NSLog(@"Configuring the default Firebase app...");
      [FIRApp configure];
      NSLog(@"Configured the default Firebase app %@.", [FIRApp defaultApp].name);
    }

    _traces = [[NSMutableDictionary alloc] init];
    _httpMetrics = [[NSMutableDictionary alloc] init];
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

  NSDictionary *metrics = call.arguments[@"metrics"];
  [metrics enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSNumber *value, BOOL *stop) {
    [trace setIntValue:[value longLongValue] forMetric:key];
  }];

  NSDictionary *attributes = call.arguments[@"attributes"];
  [attributes enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
    [trace setValue:value forAttribute:key];
  }];

  [trace stop];
  [_traces removeObjectForKey:handle];
  result(nil);
}

- (void)handleHttpMetricStart:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSNumber *handle = call.arguments[@"handle"];
  NSURL *url = [NSURL URLWithString:call.arguments[@"url"]];

  NSNumber *httpMethod = call.arguments[@"httpMethod"];
  FIRHTTPMethod method;
  switch ([httpMethod intValue]) {
    case 0:
      method = FIRHTTPMethodCONNECT;
      break;
    case 1:
      method = FIRHTTPMethodDELETE;
      break;
    case 2:
      method = FIRHTTPMethodGET;
      break;
    case 3:
      method = FIRHTTPMethodHEAD;
      break;
    case 4:
      method = FIRHTTPMethodOPTIONS;
      break;
    case 5:
      method = FIRHTTPMethodPATCH;
      break;
    case 6:
      method = FIRHTTPMethodPOST;
      break;
    case 7:
      method = FIRHTTPMethodPUT;
      break;
    case 8:
      method = FIRHTTPMethodTRACE;
      break;
    default:
      method = [httpMethod intValue];
      break;
  }

  FIRHTTPMetric *metric = [[FIRHTTPMetric alloc] initWithURL:url HTTPMethod:method];
  [_httpMetrics setObject:metric forKey:handle];
  [metric start];
  result(nil);
}

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
    [metric setValue:value forAttribute:key];
  }];

  [metric stop];
  [_httpMetrics removeObjectForKey:handle];
  result(nil);
}

@end
