// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FirebasePerformancePlugin.h"

@interface FLTTrace ()
@property FIRTrace *trace;
@property id<FlutterPluginRegistrar> registrar;
@property FlutterMethodChannel *channel;
@end

@implementation FLTTrace
+ (void)registerWithRegistrar:(nonnull NSObject<FlutterPluginRegistrar> *)registrar {}

- (instancetype _Nonnull)initWithTrace:(FIRTrace *)trace
                             registrar:(NSObject<FlutterPluginRegistrar> *_Nonnull)registrar
                               channel:(FlutterMethodChannel *)channel {
  self = [self init];
  if (self) {
    _registrar = registrar;
    _channel = channel;
    _trace = trace;
  }

  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([@"Trace#start" isEqualToString:call.method]) {
    [self start:result];
  } else if ([@"Trace#stop" isEqualToString:call.method]) {
    [self stop:result];
  } else if ([@"Trace#setMetric" isEqualToString:call.method]) {
    [self setMetric:call result:result];
  } else if ([@"Trace#incrementMetric" isEqualToString:call.method]) {
    [self incrementMetric:call result:result];
  } else if ([@"Trace#getMetric" isEqualToString:call.method]) {
    [self getMetric:call result:result];
  } else if ([@"Trace#putAttribute" isEqualToString:call.method]) {
    [self putAttribute:call result:result];
  } else if ([@"Trace#removeAttribute" isEqualToString:call.method]) {
    [self removeAttribute:call result:result];
  } else if ([@"Trace#getAttributes" isEqualToString:call.method]) {
    [self getAttributes:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)start:(FlutterResult)result {
  [_trace start];
  result(nil);
}

- (void)stop:(FlutterResult)result {
  [_trace stop];
  [_registrar addMethodCallDelegate:nil channel:_channel];
  result(nil);
}

- (void)setMetric:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *name = call.arguments[@"name"];
  NSNumber *value = call.arguments[@"value"];

  [_trace setIntValue:value.longValue forMetric:name];
  result(nil);
}

- (void)incrementMetric:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *name = call.arguments[@"name"];
  NSNumber *value = call.arguments[@"value"];

  [_trace incrementMetric:name byInt:value.longValue];
  result(nil);
}

- (void)getMetric:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *name = call.arguments[@"name"];

  int64_t metric = [_trace valueForIntMetric:name];
  result(@(metric));
}

- (void)putAttribute:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *name = call.arguments[@"name"];
  NSString *value = call.arguments[@"value"];

  [_trace setValue:value forAttribute:name];
  result(nil);
}

- (void)removeAttribute:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *name = call.arguments[@"name"];

  [_trace removeAttribute:name];
  result(nil);
}

- (void)getAttributes:(FlutterResult)result {
  result(_trace.attributes);
}
@end
