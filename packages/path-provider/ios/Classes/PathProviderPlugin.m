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
        NSString* dirPath = [self getTemporaryDirectory];
        if (dirPath) {
          result(dirPath);
        } else {
          result([FlutterError errorWithCode:@"ERROR"
                                     message:@"Could not find temp dir"
                                     details:nil]);
        }
      } else if ([@"getApplicationDocumentsDirectory" isEqualToString:call.method]) {
        NSString* dirPath = [self getApplicationDocumentsDirectory];
        if (dirPath) {
          result(dirPath);
        } else {
          result([FlutterError errorWithCode:@"ERROR"
                                     message:@"Could not find app documents dir"
                                     details:nil]);
        }
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
