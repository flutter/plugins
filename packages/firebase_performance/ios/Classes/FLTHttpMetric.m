// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FirebasePerformancePlugin.h"

@interface FLTHttpMetric ()
@property FIRHTTPMetric *metric;
@property id<FlutterPluginRegistrar> registrar;
@property FlutterMethodChannel *channel;
@end

@implementation FLTHttpMetric
+ (void)registerWithRegistrar:(nonnull NSObject<FlutterPluginRegistrar> *)registrar {}

- (instancetype _Nonnull)initWithHTTPMetric:(FIRHTTPMetric *)metric
                                  registrar:(NSObject<FlutterPluginRegistrar> *_Nonnull)registrar
                                    channel:(FlutterMethodChannel *)channel {
  self = [self init];
  if (self) {
    _metric = metric;
    _registrar = registrar;
    _channel = channel;
  }

  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([@"HttpMetric#start" isEqualToString:call.method]) {
    [self start:result];
  } else if ([@"HttpMetric#stop" isEqualToString:call.method]) {
    [self stop:result];
  } else if ([@"HttpMetric#httpResponseCode" isEqualToString:call.method]) {
    [self setHttpResponseCode:call result:result];
  } else if ([@"HttpMetric#requestPayloadSize" isEqualToString:call.method]) {
    [self requestPayloadSize:call result:result];
  } else if ([@"HttpMetric#responseContentType" isEqualToString:call.method]) {
    [self responseContentType:call result:result];
  } else if ([@"HttpMetric#responsePayloadSize" isEqualToString:call.method]) {
    [self responsePayloadSize:call result:result];
  } else if ([@"HttpMetric#putAttribute" isEqualToString:call.method]) {
    [self putAttribute:call result:result];
  } else if ([@"HttpMetric#removeAttribute" isEqualToString:call.method]) {
    [self removeAttribute:call result:result];
  } else if ([@"HttpMetric#getAttributes" isEqualToString:call.method]) {
    [self getAttributes:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)start:(FlutterResult)result {
  [_metric start];
  result(nil);
}

- (void)stop:(FlutterResult)result {
  [_metric stop];
  [_registrar addMethodCallDelegate:nil channel:nil];
  result(nil);
}

- (void)setHttpResponseCode:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSNumber *responseCode = call.arguments[@"httpResponseCode"];

  if (![responseCode isEqual:[NSNull null]]) _metric.responseCode = [responseCode integerValue];
  result(nil);
}

- (void)requestPayloadSize:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSNumber *requestPayloadSize = call.arguments[@"requestPayloadSize"];

  if (![requestPayloadSize isEqual:[NSNull null]]) {
    _metric.requestPayloadSize = [requestPayloadSize longValue];
  }
  result(nil);
}

- (void)responseContentType:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *responseContentType = call.arguments[@"responseContentType"];

  if (![responseContentType isEqual:[NSNull null]]) {
    _metric.responseContentType = responseContentType;
  }
  result(nil);
}

- (void)responsePayloadSize:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSNumber *responsePayloadSize = call.arguments[@"responsePayloadSize"];

  if (![responsePayloadSize isEqual:[NSNull null]]) {
    _metric.responsePayloadSize = [responsePayloadSize longValue];
  }
  result(nil);
}

- (void)putAttribute:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *name = call.arguments[@"name"];
  NSString *value = call.arguments[@"value"];

  [_metric setValue:value forAttribute:name];
  result(nil);
}

- (void)removeAttribute:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *name = call.arguments[@"name"];

  [_metric removeAttribute:name];
  result(nil);
}

- (void)getAttributes:(FlutterResult)result {
  result(_metric.attributes);
}
@end
