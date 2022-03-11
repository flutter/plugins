// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTPathProviderPlugin.h"

NSString *GetDirectoryOfType(NSSearchPathDirectory dir) {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(dir, NSUserDomainMask, YES);
  return paths.firstObject;
}

@implementation FLTPathProviderPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/path_provider_ios"
                                  binaryMessenger:registrar.messenger];
  [channel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
    if ([@"getTemporaryDirectory" isEqualToString:call.method]) {
      result([self getTemporaryDirectory]);
    } else if ([@"getApplicationDocumentsDirectory" isEqualToString:call.method]) {
      result([self getApplicationDocumentsDirectory]);
    } else if ([@"getApplicationSupportDirectory" isEqualToString:call.method]) {
      result([self getApplicationSupportDirectory]);
    } else if ([@"getLibraryDirectory" isEqualToString:call.method]) {
      result([self getLibraryDirectory]);
    } else {
      result(FlutterMethodNotImplemented);
    }
  }];
}

+ (NSString *)getTemporaryDirectory {
  return GetDirectoryOfType(NSCachesDirectory);
}

+ (NSString *)getApplicationDocumentsDirectory {
  return GetDirectoryOfType(NSDocumentDirectory);
}

+ (NSString *)getApplicationSupportDirectory {
  return GetDirectoryOfType(NSApplicationSupportDirectory);
}

+ (NSString *)getLibraryDirectory {
  return GetDirectoryOfType(NSLibraryDirectory);
}

@end
