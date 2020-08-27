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
- (instancetype)initWithFile:(NSString *)path
                    mimeType:(NSString *)mimeType NS_DESIGNATED_INITIALIZER;

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

- (instancetype)initWithFile:(NSString *)path mimeType:(NSString *)mimeType {
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
  if (!_path || !_mimeType) {
    return _text;
  }

  if ([_mimeType hasPrefix:@"image/"]) {
    UIImage *image = [UIImage imageWithContentsOfFile:_path];
    return image;
  } else {
    NSURL *url = [NSURL fileURLWithPath:_path];
    return url;
  }
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController
              subjectForActivityType:(UIActivityType)activityType {
  return _subject;
}

- (UIImage *)activityViewController:(UIActivityViewController *)activityViewController
      thumbnailImageForActivityType:(UIActivityType)activityType
                      suggestedSize:(CGSize)suggestedSize {
  if (!_path || !_mimeType || ![_mimeType hasPrefix:@"image/"]) {
    return nil;
  }

  UIImage *image = [UIImage imageWithContentsOfFile:_path];
  return [self imageWithImage:image scaledToSize:suggestedSize];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
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

    CGRect originRect = CGRectZero;
    if (originX && originY && originWidth && originHeight) {
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
    } else if ([@"shareFiles" isEqualToString:call.method]) {
      NSArray *paths = arguments[@"paths"];
      NSArray *mimeTypes = arguments[@"mimeTypes"];
      NSString *subject = arguments[@"subject"];
      NSString *text = arguments[@"text"];

      if (paths.count == 0) {
        result([FlutterError errorWithCode:@"error"
                                   message:@"Non-empty paths expected"
                                   details:nil]);
        return;
      }

      for (NSString *path in paths) {
        if (path.length == 0) {
          result([FlutterError errorWithCode:@"error"
                                     message:@"Each path must not be empty"
                                     details:nil]);
          return;
        }
      }

      [self shareFiles:paths
            withMimeType:mimeTypes
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

+ (void)shareFiles:(NSArray *)paths
      withMimeType:(NSArray *)mimeTypes
       withSubject:(NSString *)subject
          withText:(NSString *)text
    withController:(UIViewController *)controller
          atSource:(CGRect)origin {
  NSMutableArray *items = [[NSMutableArray alloc] init];

  if (text || subject) {
    [items addObject:[[ShareData alloc] initWithSubject:subject text:text]];
  }

  for (int i = 0; i < [paths count]; i++) {
    NSString *path = paths[i];
    NSString *pathExtension = [path pathExtension];
    NSString *mimeType = mimeTypes[i];
    if ([pathExtension.lowercaseString isEqualToString:@"jpg"] ||
        [pathExtension.lowercaseString isEqualToString:@"jpeg"] ||
        [pathExtension.lowercaseString isEqualToString:@"png"] ||
        [mimeType.lowercaseString isEqualToString:@"image/jpg"] ||
        [mimeType.lowercaseString isEqualToString:@"image/jpeg"] ||
        [mimeType.lowercaseString isEqualToString:@"image/png"]) {
      UIImage *image = [UIImage imageWithContentsOfFile:path];
      [items addObject:image];
    } else {
      [items addObject:[[ShareData alloc] initWithFile:path mimeType:mimeType]];
    }
  }

  [self share:items withController:controller atSource:origin];
}

@end
