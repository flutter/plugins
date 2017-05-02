// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "PathProviderPlugin.h"

NSString* GetDirectoryOfType(NSSearchPathDirectory dir) {
  NSArray* paths = NSSearchPathForDirectoriesInDomains(dir, NSUserDomainMask, YES);
  if (paths.count == 0)
    return nil;
  return paths.firstObject;
}

@implementation PathProviderPlugin {
}

- (instancetype)initWithController:(FlutterViewController *)controller {
  self = [super init];
  if (self) {
    FlutterMethodChannel *channel = [FlutterMethodChannel
        methodChannelWithName:@"plugins.flutter.io/path_provider"
              binaryMessenger:controller];
    [channel setMethodCallHandler:^(FlutterMethodCall *call,
                                    FlutterResult result) {
      if ([@"getTemporaryDirectory" isEqualToString:call.method]) {
        result([self getTemporaryDirectory]);
      } else if ([@"getApplicationDocumentsDirectory" isEqualToString:call.method]) {
        result([self getApplicationDocumentsDirectory]);
      } else {
        result(FlutterMethodNotImplemented);
      }
    }];
  }
  return self;
}

- (NSString*)getTemporaryDirectory {
  return GetDirectoryOfType(NSCachesDirectory);
}

- (NSString*)getApplicationDocumentsDirectory {
  return GetDirectoryOfType(NSDocumentDirectory);
}

@end
