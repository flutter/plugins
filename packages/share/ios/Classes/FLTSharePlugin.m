// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTSharePlugin.h"

static NSString *const PLATFORM_CHANNEL = @"plugins.flutter.io/share";

@interface ShareData : NSObject <UIActivityItemSource>

@property(readonly, nonatomic, copy) NSString *subject;
@property(readonly, nonatomic, copy) NSString *text;
@property(readonly, nonatomic, copy) NSString *path;
@property(readonly, nonatomic, copy) NSString *mimeType;

- (instancetype)initWithSubject:(NSString *)subject text:(NSString *)text NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithFile:(NSString *)path mimeType:(NSString *)mimeType NS_DESIGNATED_INITIALIZER;

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
    _subject = [subject isKindOfClass:NSNull.class] ? @"" : subject;
    _text = text;
  }
  return self;
}

- (instancetype)initWithFile:(NSString *)path
                    mimeType:(NSString *)mimeType {
  self = [super init];
  if (self) {
    _path = path;
    _mimeType = mimeType;
  }
  return self;
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
  return @"";
}

- (id)activityViewController:(UIActivityViewController *)activityViewController
         itemForActivityType:(UIActivityType)activityType {
  if (_path != nil && _mimeType != nil) {
    if ([_mimeType hasPrefix:@"image/"]) {
      UIImage *image = [UIImage imageWithContentsOfFile:_path];
      return image;
    } else {
      NSURL *url = [NSURL fileURLWithPath:_path];
      return url;
    }
  }

  return _text;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController
              subjectForActivityType:(UIActivityType)activityType {
  return _subject;
}

- (UIImage *)activityViewController:(UIActivityViewController *)activityViewController
       thumbnailImageForActivityType:(UIActivityType)activityType
                       suggestedSize:(CGSize)suggestedSize {
    if (_path != nil
        && _mimeType != nil
        && [_mimeType hasPrefix:@"image/"]) {
      UIImage *image = [UIImage imageWithContentsOfFile:_path];
      return [self imageWithImage:image scaledToSize:suggestedSize];
    }
    return nil;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end

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
      NSString *shareSubject = arguments[@"subject"];

      if (shareText.length == 0) {
        result([FlutterError errorWithCode:@"error"
                                   message:@"Non-empty text expected"
                                   details:nil]);
        return;
      }

      [self shareText:shareText
                 subject:shareSubject
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

+ (void)shareText:(NSString *)shareText
           subject:(NSString *)subject
    withController:(UIViewController *)controller
          atSource:(CGRect)origin {
  ShareData *data = [[ShareData alloc] initWithSubject:subject text:shareText];
  [self share:@[ data ] withController:controller atSource:origin];
}

+ (void)shareFile:(id)path
      withMimeType:(id)mimeType
       withSubject:(NSString *)subject
          withText:(NSString *)text
    withController:(UIViewController *)controller
          atSource:(CGRect)origin {
  NSArray *items = @[
    [[ShareData alloc] initWithSubject:subject text:text],
    [[ShareData alloc] initWithFile:path mimeType:mimeType]
  ];
  [self share:items withController:controller atSource:origin];
}

@end
