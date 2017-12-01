// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FirebaseAnalyticsPlugin.h"

#import "Firebase/Firebase.h"

@implementation FLTFirebaseAnalyticsPlugin {
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"firebase_analytics"
                                  binaryMessenger:[registrar messenger]];
  FLTFirebaseAnalyticsPlugin *instance = [[FLTFirebaseAnalyticsPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)init {
  self = [super init];
  if (self) {
    if (![FIRApp defaultApp]) {
      [FIRApp configure];
    }
  }
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([@"logEvent" isEqualToString:call.method]) {
    NSString *eventName = call.arguments[@"name"];
    id parameterMap = call.arguments[@"parameters"];

    if (parameterMap != [NSNull null]) {
      [FIRAnalytics logEventWithName:eventName parameters:parameterMap];
    } else {
      [FIRAnalytics logEventWithName:eventName parameters:nil];
    }

    result(nil);
  } else if ([@"setUserId" isEqualToString:call.method]) {
    NSString *userId = call.arguments;
    [FIRAnalytics setUserID:userId];
    result(nil);
  } else if ([@"setCurrentScreen" isEqualToString:call.method]) {
    NSString *screenName = call.arguments[@"screenName"];
    NSString *screenClassOverride = call.arguments[@"screenClassOverride"];
    [FIRAnalytics setScreenName:screenName screenClass:screenClassOverride];
    result(nil);
  } else if ([@"setUserProperty" isEqualToString:call.method]) {
    NSString *name = call.arguments[@"name"];
    NSString *value = call.arguments[@"value"];
    [FIRAnalytics setUserPropertyString:value forName:name];
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
