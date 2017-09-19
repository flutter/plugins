// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "SharePlugin.h"

static NSString *const PLATFORM_CHANNEL = @"plugins.flutter.io/share";

@implementation SharePlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *shareChannel =
  [FlutterMethodChannel methodChannelWithName:PLATFORM_CHANNEL
                              binaryMessenger:registrar.messenger];
  
  [shareChannel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
    if ([@"share" isEqualToString:call.method]) {
      [self share:call
   withController:[UIApplication sharedApplication].keyWindow.rootViewController];
      result(nil);
    } else {
      result([FlutterError errorWithCode:@"UNKNOWN_METHOD"
                                 message:@"Unknown share method called"
                                 details:nil]);
    }
  }];
}

+ (void)share:(FlutterMethodCall *)call withController:(UIViewController *)controller {
  UIActivityViewController *activityViewController =
  [[UIActivityViewController alloc] initWithActivityItems:@[ call.arguments[@"text"] ]
                                    applicationActivities:nil];
  [controller presentViewController:activityViewController animated:YES completion:nil];
  UIPopoverPresentationController *popContronller = [activityViewController popoverPresentationController];
  if (popContronller != nil) {
    NSNumber *x = call.arguments[@"tapX"];
    NSNumber *y = call.arguments[@"tapY"];
    if ((x != nil) && (y != nil)) {
      popContronller.sourceRect = CGRectMake(x.floatValue, y.floatValue, 0, 0);
    }
    else {
      popContronller.sourceRect = CGRectZero;
    }
  }
  popContronller.sourceView = controller.view;
}
@end
