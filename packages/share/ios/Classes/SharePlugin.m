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
    NSDictionary *arguments = [call arguments];
    NSNumber *originX = arguments[@"originX"];
    NSNumber *originY = arguments[@"originY"];
    NSNumber *originWidth = arguments[@"originWidth"];
    NSNumber *originHeight = arguments[@"originHeight"];

    CGRect originRect;
    if (originX != nil && originY != nil && originWidth != nil && originHeight != nil) {
      originRect = CGRectMake([originX doubleValue], [originY doubleValue],
                              [originWidth doubleValue], [originHeight doubleValue]);
    }

    if ([@"share" isEqualToString:call.method]) {
      NSString *shareText = arguments[@"text"];

      if (shareText.length == 0) {
        result([FlutterError errorWithCode:@"error"
                                   message:@"Non-empty text expected"
                                   details:nil]);
        return;
      }

      [self share:@[ shareText ]
          withController:[UIApplication sharedApplication].keyWindow.rootViewController
                atSource:originRect];
      result(nil);
    } else if ([@"shareFile" isEqualToString:call.method]) {
      NSString *path = arguments[@"path"];
      NSString *mimeType = arguments[@"mimeType"];
      NSString *subject = arguments[@"subject"];
      NSString *text = arguments[@"text"];

      if (path.length == 0) {
        result([FlutterError errorWithCode:@"error"
                                   message:@"Non-empty path expected"
                                   details:nil]);
        return;
      }

      [self shareFile:path
            withMimeType:mimeType
             withSubject:subject
                withText:text
          withController:[UIApplication sharedApplication].keyWindow.rootViewController
                atSource:originRect];
      result(nil);
    } else {
      result(FlutterMethodNotImplemented);
    }
  }];
}

+ (void)share:(NSArray *)shareItems
    withController:(UIViewController *)controller
          atSource:(CGRect)origin {
  UIActivityViewController *activityViewController =
      [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
  activityViewController.popoverPresentationController.sourceView = controller.view;
  if (!CGRectIsEmpty(origin)) {
    activityViewController.popoverPresentationController.sourceRect = origin;
  }
  [controller presentViewController:activityViewController animated:YES completion:nil];
}

+ (void)shareFile:(id)path
      withMimeType:(id)mimeType
       withSubject:(NSString *)subject
          withText:(NSString *)text
    withController:(UIViewController *)controller
          atSource:(CGRect)origin {
  NSMutableArray *items = [[NSMutableArray alloc] init];

  if (subject != nil && subject.length != 0) {
    [items addObject:subject];
  }
  if (text != nil && text.length != 0) {
    [items addObject:text];
  }

  if ([mimeType hasPrefix:@"image/"]) {
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    [items addObject:image];
  } else {
    NSURL *url = [NSURL fileURLWithPath:path];
    [items addObject:url];
  }

  [self share:items withController:controller atSource:origin];
}

@end
