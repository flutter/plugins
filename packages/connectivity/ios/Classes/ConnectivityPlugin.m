// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ConnectivityPlugin.h"

#import "Reachability/Reachability.h"

@implementation ConnectivityPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/connectivity"
                                  binaryMessenger:[registrar messenger]];
  ConnectivityPlugin* instance = [[ConnectivityPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([call.method isEqualToString:@"check"]) {
    // This is supposed to be quick. Another way of doing this would be to signup for network
    // connectivity changes. However that depends on the app being in background and the code
    // gets more involved. So for now, this will do.
    NetworkStatus status =
        [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    switch (status) {
      case NotReachable:
        result(@"none");
        break;
      case ReachableViaWiFi:
        result(@"wifi");
        break;
      case ReachableViaWWAN:
        result(@"mobile");
        break;
    }
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
