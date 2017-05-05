// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "SharePlugin.h"

static NSString *const PLATFORM_CHANNEL = @"plugins.flutter.io/share";

@implementation SharePlugin

- (instancetype)initWithFlutterViewController:
    (FlutterViewController *)flutterViewController {
  FlutterMethodChannel *shareChannel = [FlutterMethodChannel
      methodChannelNamed:PLATFORM_CHANNEL
         binaryMessenger:flutterViewController
                   codec:[FlutterStandardMethodCodec sharedInstance]];

  [shareChannel setMethodCallHandler:^(FlutterMethodCall *call,
                                       FlutterResultReceiver result) {
    if ([@"share" isEqualToString:call.method]) {
      UIActivityViewController *activityViewController =
          [[UIActivityViewController alloc] initWithActivityItems:@[call.arguments]
                                            applicationActivities:nil];
      [flutterViewController presentViewController:activityViewController
                                          animated:YES
                                        completion:nil];
      result(nil, nil);
    } else {
      result(nil, [FlutterError errorWithCode:@"UNKNOWN_METHOD"
                                      message:@"Unknown share method called"
                                      details:nil]);
    }
  }];
}

@end