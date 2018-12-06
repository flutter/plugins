// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ConnectivityPlugin.h"

#import "Reachability/Reachability.h"

#import "SystemConfiguration/CaptiveNetwork.h"

@interface FLTConnectivityPlugin () <FlutterStreamHandler>
@end

@implementation FLTConnectivityPlugin {
  FlutterEventSink _eventSink;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FLTConnectivityPlugin* instance = [[FLTConnectivityPlugin alloc] init];

  FlutterMethodChannel* channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/connectivity"
                                  binaryMessenger:[registrar messenger]];
  [registrar addMethodCallDelegate:instance channel:channel];

  FlutterEventChannel* streamChannel =
      [FlutterEventChannel eventChannelWithName:@"plugins.flutter.io/connectivity_status"
                                binaryMessenger:[registrar messenger]];
  [streamChannel setStreamHandler:instance];
}

- (NSString*)getWifiName {
  NSString* wifiName = nil;
  NSArray* interFaceNames = (__bridge_transfer id)CNCopySupportedInterfaces();

  for (NSString* name in interFaceNames) {
    NSDictionary* info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)name);
    if (info[@"SSID"]) {
      wifiName = info[@"SSID"];
    }
  }

  return wifiName;
}

- (NSString*)statusFromReachability:(Reachability*)reachability {
  NetworkStatus status = [reachability currentReachabilityStatus];
  switch (status) {
    case NotReachable:
      return @"none";
    case ReachableViaWiFi:
      return @"wifi";
    case ReachableViaWWAN:
      return @"mobile";
  }
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([call.method isEqualToString:@"check"]) {
    // This is supposed to be quick. Another way of doing this would be to
    // signup for network
    // connectivity changes. However that depends on the app being in background
    // and the code
    // gets more involved. So for now, this will do.
    result([self statusFromReachability:[Reachability reachabilityForInternetConnection]]);
  } else if ([call.method isEqualToString:@"wifiName"]) {
    result([self getWifiName]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)onReachabilityDidChange:(NSNotification*)notification {
  Reachability* curReach = [notification object];
  _eventSink([self statusFromReachability:curReach]);
}

#pragma mark FlutterStreamHandler impl

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
  _eventSink = eventSink;
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(onReachabilityDidChange:)
                                               name:kReachabilityChangedNotification
                                             object:nil];
  [[Reachability reachabilityForInternetConnection] startNotifier];
  return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
  [[Reachability reachabilityForInternetConnection] stopNotifier];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  _eventSink = nil;
  return nil;
}

@end
