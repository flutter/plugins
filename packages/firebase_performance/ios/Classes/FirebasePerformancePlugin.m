// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FirebasePerformancePlugin.h"

#import <Firebase/Firebase.h>

@interface FLTFirebasePerformancePlugin ()
@property(nonatomic, retain) NSMutableDictionary *traces;
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
    if (![FIRApp defaultApp]) {
      [FIRApp configure];
      _traces = [[NSMutableDictionary alloc] init];
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
}

@end
