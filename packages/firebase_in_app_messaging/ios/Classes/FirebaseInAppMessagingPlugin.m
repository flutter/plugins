// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FirebaseInAppMessagingPlugin.h"

#import <Firebase/Firebase.h>

@implementation FirebaseInAppMessagingPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/firebase_in_app_messaging"
                                  binaryMessenger:[registrar messenger]];
  FirebaseInAppMessagingPlugin *instance = [[FirebaseInAppMessagingPlugin alloc] init];
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
  }
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([@"triggerEvent" isEqualToString:call.method]) {
    NSString *eventName = call.arguments[@"eventName"];
    FIRInAppMessaging *fiam = [FIRInAppMessaging inAppMessaging];
    [fiam triggerEvent:eventName];
    result(nil);
  } else if ([@"setMessagesSuppressed" isEqualToString:call.method]) {
    NSNumber *suppress = [NSNumber numberWithBool:call.arguments];
    FIRInAppMessaging *fiam = [FIRInAppMessaging inAppMessaging];
    fiam.messageDisplaySuppressed = [suppress boolValue];
    result(nil);
  } else if ([@"setAutomaticDataCollectionEnabled" isEqualToString:call.method]) {
    NSNumber *enabled = [NSNumber numberWithBool:call.arguments];
    FIRInAppMessaging *fiam = [FIRInAppMessaging inAppMessaging];
    fiam.automaticDataCollectionEnabled = [enabled boolValue];
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
