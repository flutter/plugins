// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "PackageInfoPlugin.h"

@implementation FLTPackageInfoPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/package_info"
                                  binaryMessenger:[registrar messenger]];
  FLTPackageInfoPlugin* instance = [[FLTPackageInfoPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([call.method isEqualToString:@"getAll"]) {
    NSString* displayName =
        [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    // Cannot put nil into a map so return an empty string.
    if (displayName == nil) {
      displayName = @"";
    }
    result(@{
      @"appName" : displayName,
      @"packageName" : [[NSBundle mainBundle] bundleIdentifier],
      @"version" : [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
      @"buildNumber" : [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]
    });
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
