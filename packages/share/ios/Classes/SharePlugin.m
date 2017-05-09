// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "SharePlugin.h"

static NSString *const PLATFORM_CHANNEL = @"plugins.flutter.io/share";

@implementation SharePlugin

- (instancetype)initWithController:
    (FlutterViewController *)controller {
  FlutterMethodChannel *shareChannel = [FlutterMethodChannel
      methodChannelWithName:PLATFORM_CHANNEL
            binaryMessenger:controller];

  [shareChannel setMethodCallHandler:^(FlutterMethodCall *call,
                                       FlutterResult result) {
    if ([@"share" isEqualToString:call.method]) {
      [self share:call.arguments withController:controller];
      result(nil);
    } else {
      result([FlutterError errorWithCode:@"UNKNOWN_METHOD"
                                 message:@"Unknown share method called"
                                 details:nil]);
    }
  }];
}


- (void)share:(id)sharedItems withController:(FlutterViewController *)controller {
  UIActivityViewController *activityViewController =
      [[UIActivityViewController alloc] initWithActivityItems:@[sharedItems]
                                        applicationActivities:nil];
  [controller presentViewController:activityViewController
                            animated:YES
                          completion:nil];
}

@end