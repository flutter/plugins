// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "AndroidAlarmManagerPlugin.h"

@implementation FLTAndroidAlarmManagerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/android_alarm_manager"
                                  binaryMessenger:[registrar messenger]
                                            codec:[FlutterJSONMethodCodec sharedInstance]];
  FLTAndroidAlarmManagerPlugin* instance = [[FLTAndroidAlarmManagerPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  result(FlutterMethodNotImplemented);
}

@end
