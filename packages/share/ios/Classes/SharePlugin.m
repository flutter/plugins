// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "SharePlugin.h"

static NSString *const PLATFORM_CHANNEL = @"plugins.flutter.io/share";

@implementation FLTSharePlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *shareChannel =
      [FlutterMethodChannel methodChannelWithName:PLATFORM_CHANNEL
                                  binaryMessenger:registrar.messenger];

  [shareChannel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
    if ([@"share" isEqualToString:call.method]) {
      NSDictionary *arguments = [call arguments];
      NSString *shareText = arguments[@"text"];

      if (shareText.length == 0) {
        result([FlutterError errorWithCode:@"error"
                                   message:@"Non-empty text expected"
                                   details:nil]);
        return;
      }

      NSNumber *originX = arguments[@"originX"];
      NSNumber *originY = arguments[@"originY"];
      NSNumber *originWidth = arguments[@"originWidth"];
      NSNumber *originHeight = arguments[@"originHeight"];

      CGRect originRect;
      if (originX != nil && originY != nil && originWidth != nil && originHeight != nil) {
        originRect = CGRectMake([originX doubleValue], [originY doubleValue],
                                [originWidth doubleValue], [originHeight doubleValue]);
      }

      [self share:shareText
          withController:[UIApplication sharedApplication].keyWindow.rootViewController
                atSource:originRect];
      result(nil);
    } else {
      result(FlutterMethodNotImplemented);
    }
  }];
}

+ (void)share:(id)sharedItems
    withController:(UIViewController *)controller
          atSource:(CGRect)origin {
  UIActivityViewController *activityViewController =
      [[UIActivityViewController alloc] initWithActivityItems:@[ sharedItems ]
                                        applicationActivities:nil];
  activityViewController.popoverPresentationController.sourceView = controller.view;
  if (!CGRectIsEmpty(origin)) {
    activityViewController.popoverPresentationController.sourceRect = origin;
  }
  [controller presentViewController:activityViewController animated:YES completion:nil];
}

@end
