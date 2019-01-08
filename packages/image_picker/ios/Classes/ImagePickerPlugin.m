// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ImagePickerPlugin.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>
#import <UIKit/UIKit.h>

@interface FLTImagePickerPlugin () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property(nullable, copy, nonatomic) FlutterResult result;
@property(nullable, copy, nonatomic) NSDictionary *arguments;
@property(strong, nonatomic) UIImagePickerController *imagePickerController;
@property(strong, nonatomic) UIViewController *viewController;

@end

typedef enum : NSUInteger {
  SOURCE_CAMERA = 0,
  SOURCE_GALLERY = 1,
} SOURCE;

@implementation FLTImagePickerPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/image_picker"
                                  binaryMessenger:[registrar messenger]];
  UIViewController *viewController =
      [UIApplication sharedApplication].delegate.window.rootViewController;
  FLTImagePickerPlugin *instance =
      [[FLTImagePickerPlugin alloc] initWithViewController:viewController];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithViewController:(UIViewController *)viewController {
  self = [super init];
  if (self) {
    self.viewController = viewController;
    self.imagePickerController = [[UIImagePickerController alloc] init];
  }
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if (self.result) {
    self.result([FlutterError errorWithCode:@"multiple_request"
                                    message:@"Cancelled by a second request"
                                    details:nil]);
    self.result = nil;
  }

  if ([@"pickImage" isEqualToString:call.method]) {
    self.imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.imagePickerController.delegate = self;
    self.imagePickerController.mediaTypes = @[ (NSString *)kUTTypeImage ];

    self.result = result;
    self.arguments = call.arguments;

    int imageSource = [[self.arguments objectForKey:@"source"] intValue];

    switch (imageSource) {
      case SOURCE_CAMERA:
        [self showCamera];
        break;
      case SOURCE_GALLERY:
        [self showPhotoLibrary];
        break;
      default:
        result([FlutterError errorWithCode:@"invalid_source"
                                   message:@"Invalid image source."
                                   details:nil]);
        break;
    }
  } else if ([@"pickVideo" isEqualToString:call.method]) {
    self.imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.imagePickerController.delegate = self;
    self.imagePickerController.mediaTypes = @[
      (NSString *)kUTTypeMovie, (NSString *)kUTTypeAVIMovie, (NSString *)kUTTypeVideo,
      (NSString *)kUTTypeMPEG4
    ];
    self.imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;

    self.result = result;
    self.arguments = call.arguments;

    int imageSource = [[self.arguments objectForKey:@"source"] intValue];

    switch (imageSource) {
      case SOURCE_CAMERA:
        [self showCamera];
        break;
      case SOURCE_GALLERY:
        [self showPhotoLibrary];
        break;
      default:
        result([FlutterError errorWithCode:@"invalid_source"
                                   message:@"Invalid video source."
                                   details:nil]);
        break;
    }
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)showCamera {
  // Camera is not available on simulators
  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self.viewController presentViewController:self.imagePickerController
                                      animated:YES
                                    completion:nil];
  } else {
    [[[UIAlertView alloc] initWithTitle:@"Error"
                                message:@"Camera not available."
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
  }
}

- (void)showPhotoLibrary {
  // No need to check if SourceType is available. It always is.
  self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  [self.viewController presentViewController:self.imagePickerController
                                    animated:YES
                                  completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker
    didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info {
  [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
  // By checking self.result, we avoid a crash where user can tap the image multiple times and the
  // delegate method was triggered multile times, which leads to self.result gets called when it is
  // already set to nil.
  if (!self.result) {
    return;
  }
  // We place the code outside of the completion handler to make the completion
  // happening concurrently, which results a faster user experience.
  NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
  UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
  if (videoURL != nil) {
    NSData *data = [NSData dataWithContentsOfURL:videoURL];
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *tmpFile = [NSString stringWithFormat:@"image_picker_%@.MOV", guid];
    NSString *tmpDirectory = NSTemporaryDirectory();
    NSString *tmpPath = [tmpDirectory stringByAppendingPathComponent:tmpFile];

    if ([[NSFileManager defaultManager] createFileAtPath:tmpPath contents:data attributes:nil]) {
      self.result(tmpPath);
    } else {
      self.result([FlutterError errorWithCode:@"create_error"
                                      message:@"Temporary file could not be created"
                                      details:nil]);
    }
  } else {
    if (image == nil) {
      image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    image = [self normalizedImage:image];

    NSNumber *maxWidth = [self.arguments objectForKey:@"maxWidth"];
    NSNumber *maxHeight = [self.arguments objectForKey:@"maxHeight"];

    if (maxWidth != (id)[NSNull null] || maxHeight != (id)[NSNull null]) {
      image = [self scaledImage:image maxWidth:maxWidth maxHeight:maxHeight];
    }

    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *tmpFile = [NSString stringWithFormat:@"image_picker_%@.jpg", guid];
    NSString *tmpDirectory = NSTemporaryDirectory();
    NSString *tmpPath = [tmpDirectory stringByAppendingPathComponent:tmpFile];

    if ([[NSFileManager defaultManager] createFileAtPath:tmpPath contents:data attributes:nil]) {
      self.result(tmpPath);
    } else {
      self.result([FlutterError errorWithCode:@"create_error"
                                      message:@"Temporary file could not be created"
                                      details:nil]);
    }
  }

  self.result = nil;
  self.arguments = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
  [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
  self.result(nil);

  self.result = nil;
  self.arguments = nil;
}

// The way we save images to the tmp dir currently throws away all EXIF data
// (including the orientation of the image). That means, pics taken in portrait
// will not be orientated correctly as is. To avoid that, we rotate the actual
// image data.
// TODO(goderbauer): investigate how to preserve EXIF data.
- (UIImage *)normalizedImage:(UIImage *)image {
  if (image.imageOrientation == UIImageOrientationUp) return image;

  UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
  [image drawInRect:(CGRect){0, 0, image.size}];
  UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return normalizedImage;
}

- (UIImage *)scaledImage:(UIImage *)image
                maxWidth:(NSNumber *)maxWidth
               maxHeight:(NSNumber *)maxHeight {
  double originalWidth = image.size.width;
  double originalHeight = image.size.height;

  bool hasMaxWidth = maxWidth != (id)[NSNull null];
  bool hasMaxHeight = maxHeight != (id)[NSNull null];

  double width = hasMaxWidth ? MIN([maxWidth doubleValue], originalWidth) : originalWidth;
  double height = hasMaxHeight ? MIN([maxHeight doubleValue], originalHeight) : originalHeight;

  bool shouldDownscaleWidth = hasMaxWidth && [maxWidth doubleValue] < originalWidth;
  bool shouldDownscaleHeight = hasMaxHeight && [maxHeight doubleValue] < originalHeight;
  bool shouldDownscale = shouldDownscaleWidth || shouldDownscaleHeight;

  if (shouldDownscale) {
    double downscaledWidth = floor((height / originalHeight) * originalWidth);
    double downscaledHeight = floor((width / originalWidth) * originalHeight);

    if (width < height) {
      if (!hasMaxWidth) {
        width = downscaledWidth;
      } else {
        height = downscaledHeight;
      }
    } else if (height < width) {
      if (!hasMaxHeight) {
        height = downscaledHeight;
      } else {
        width = downscaledWidth;
      }
    } else {
      if (originalWidth < originalHeight) {
        width = downscaledWidth;
      } else if (originalHeight < originalWidth) {
        height = downscaledHeight;
      }
    }
  }

  UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, 1.0);
  [image drawInRect:CGRectMake(0, 0, width, height)];

  UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  return scaledImage;
}

@end
