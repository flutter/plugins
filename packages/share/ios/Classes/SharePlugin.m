// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "SharePlugin.h"

static NSString *const PLATFORM_CHANNEL = @"plugins.flutter.io/share";

@interface ShareData : NSObject <UIActivityItemSource>

@property(readonly, nonatomic, copy) NSString *subject;
@property(readonly, nonatomic, copy) NSString *text;

- (instancetype)initWithSubject:(NSString *)subject text:(NSString *)text NS_DESIGNATED_INITIALIZER;

- (instancetype)init __attribute__((unavailable("Use initWithSubject:text: instead")));

@end

@implementation ShareData

- (instancetype)init {
  [super doesNotRecognizeSelector:_cmd];
  return nil;
}

- (instancetype)initWithSubject:(NSString *)subject text:(NSString *)text {
  self = [super init];
  if (self) {
    _subject = subject;
    _text = text;
  }
  return self;
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
  return @"";
}

- (id)activityViewController:(UIActivityViewController *)activityViewController
         itemForActivityType:(UIActivityType)activityType {
  return _text;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController
              subjectForActivityType:(UIActivityType)activityType {
  return [_subject isKindOfClass:NSNull.class] ? nil : _subject;
}

@end

@implementation FLTSharePlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *shareChannel =
      [FlutterMethodChannel methodChannelWithName:PLATFORM_CHANNEL
                                  binaryMessenger:registrar.messenger];

  [shareChannel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
    if ([@"share" isEqualToString:call.method]) {
      NSDictionary *arguments = [call arguments];
      NSString *shareText = arguments[@"text"];
      NSString *shareSubject = arguments[@"subject"];

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

      CGRect originRect = CGRectZero;
      if (originX != nil && originY != nil && originWidth != nil && originHeight != nil) {
        originRect = CGRectMake([originX doubleValue], [originY doubleValue],
                                [originWidth doubleValue], [originHeight doubleValue]);
      }

      [self share:shareText
                 subject:shareSubject
          withController:[UIApplication sharedApplication].keyWindow.rootViewController
                atSource:originRect];
      result(nil);
    } else {
      result(FlutterMethodNotImplemented);
    }
  }];
}

+ (void)share:(NSString *)shareText
           subject:(NSString *)subject
    withController:(UIViewController *)controller
          atSource:(CGRect)origin {
  ShareData *data = [[ShareData alloc] initWithSubject:subject text:shareText];
  UIActivityViewController *activityViewController =
      [[UIActivityViewController alloc] initWithActivityItems:@[ data ] applicationActivities:nil];
  activityViewController.popoverPresentationController.sourceView = controller.view;
  if (!CGRectIsEmpty(origin)) {
    activityViewController.popoverPresentationController.sourceRect = origin;
  }
  [controller presentViewController:activityViewController animated:YES completion:nil];
}

@end
