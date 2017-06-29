// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "DeviceInfoPlugin.h"

@implementation DeviceInfoPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/device_info"
                                  binaryMessenger:[registrar messenger]];
  DeviceInfoPlugin* instance = [[DeviceInfoPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getIosDeviceInfo" isEqualToString:call.method]) {
    UIDevice* device = [UIDevice currentDevice];
    result(@{
      @"name" : [device name],
      @"systemName" : [device systemName],
      @"systemVersion" : [device systemVersion],
      @"model" : [device model],
      @"localizedModel" : [device localizedModel],
      @"identifierForVendor" : [[device identifierForVendor] UUIDString],
    });
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
