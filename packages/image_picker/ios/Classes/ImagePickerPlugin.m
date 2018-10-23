// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ImagePickerPlugin.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>
#import <UIKit/UIKit.h>

@interface FLTImagePickerPlugin () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@end

static const int SOURCE_CAMERA = 0;
static const int SOURCE_GALLERY = 1;

@implementation FLTImagePickerPlugin {
  FlutterResult _result;
  NSDictionary *_arguments;
  UIImagePickerController *_imagePickerController;
  UIViewController *_viewController;
}

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
    _viewController = viewController;
    _imagePickerController = [[UIImagePickerController alloc] init];
  }
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if (_result) {
    _result([FlutterError errorWithCode:@"multiple_request"
                                message:@"Cancelled by a second request"
                                details:nil]);
    _result = nil;
  }

  if ([@"pickImage" isEqualToString:call.method]) {
    _imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    _imagePickerController.delegate = self;
    _imagePickerController.mediaTypes = @[ (NSString *)kUTTypeImage ];

    _result = result;
    _arguments = call.arguments;

    int imageSource = [[_arguments objectForKey:@"source"] intValue];

    switch (imageSource) {
      case SOURCE_CAMERA:
        [self showCamera];
        break;
      case SOURCE_GALLERY: {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
          if (status == PHAuthorizationStatusAuthorized) {
            [self showPhotoLibrary];
          } else {
            result(nil);
          }
        }];
        break;
      }
      default: {
        result([FlutterError errorWithCode:@"invalid_source"
                                   message:@"Invalid image source."
                                   details:nil]);
        break;
      }
    }
  } else if ([@"pickVideo" isEqualToString:call.method]) {
    _imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    _imagePickerController.delegate = self;
    _imagePickerController.mediaTypes = @[
      (NSString *)kUTTypeMovie, (NSString *)kUTTypeAVIMovie, (NSString *)kUTTypeVideo,
      (NSString *)kUTTypeMPEG4
    ];
    _imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;

    _result = result;
    _arguments = call.arguments;

    int imageSource = [[_arguments objectForKey:@"source"] intValue];

    switch (imageSource) {
      case SOURCE_CAMERA:
        [self showCamera];
        break;
      case SOURCE_GALLERY: {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
          if (status == PHAuthorizationStatusAuthorized) {
            [self showPhotoLibrary];
          } else {
            result(nil);
          }
        }];
        break;
      }
      default: {
        result([FlutterError errorWithCode:@"invalid_source"
                                   message:@"Invalid video source."
                                   details:nil]);
        break;
      }
    }
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)showCamera {
  // Camera is not available on simulators
  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    [_viewController presentViewController:_imagePickerController animated:YES completion:nil];
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
  _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  [_viewController presentViewController:_imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker
    didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info {
  NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
  UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
  [_imagePickerController dismissViewControllerAnimated:YES completion:nil];
  // The method dismissViewControllerAnimated does not immediately prevent further
  // didFinishPickingMediaWithInfo invocations. A nil check is necessary to prevent below code to
  // be unwantly executed multiple times and cause a crash.
  if (!_result) {
    return;
  }
  if (videoURL != nil) {
    NSData *data = [NSData dataWithContentsOfURL:videoURL];
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *tmpFile = [NSString stringWithFormat:@"image_picker_%@.MOV", guid];
    NSString *tmpDirectory = NSTemporaryDirectory();
    NSString *tmpPath = [tmpDirectory stringByAppendingPathComponent:tmpFile];

    if ([[NSFileManager defaultManager] createFileAtPath:tmpPath contents:data attributes:nil]) {
      _result(tmpPath);
    } else {
      _result([FlutterError errorWithCode:@"create_error"
                                  message:@"Temporary file could not be created"
                                  details:nil]);
    }
  } else {
    NSURL *assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsWithALAssetURLs:@[ assetURL ]
                                                                   options:nil];
    PHAsset *asset = result.firstObject;

    if (image == nil) {
      image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    image = [self normalizedImage:image];

    NSNumber *maxWidth = [_arguments objectForKey:@"maxWidth"];
    NSNumber *maxHeight = [_arguments objectForKey:@"maxHeight"];

    bool isScaled = false;

    if (maxWidth != (id)[NSNull null] || maxHeight != (id)[NSNull null]) {
      isScaled = true;
      image = [self scaledImage:image maxWidth:maxWidth maxHeight:maxHeight];
    }

    [[PHImageManager defaultManager]
        requestImageDataForAsset:asset
                         options:nil
                   resultHandler:^(NSData *_Nullable imageData, NSString *_Nullable dataUTI,
                                   UIImageOrientation orientation, NSDictionary *_Nullable info) {
                     NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString];
                     NSString *tmpFile = [NSString stringWithFormat:@"image_picker_%@", guid];
                     NSString *tmpDirectory = NSTemporaryDirectory();
                     NSString *tmpPath = [tmpDirectory stringByAppendingPathComponent:tmpFile];

                     uint8_t c;
                     [imageData getBytes:&c length:1];
                     switch (c) {
                       case 0x47:
                         // image/gif
                         if (isScaled == true) {
                           // TODO When scaled, animation disappears. Drawing as JPEG.
                           [self createImageFileAtPath:[tmpPath stringByAppendingString:@".gif"]
                                              contents:UIImageJPEGRepresentation(image, 1)];
                         } else {
                           [self createImageFileAtPath:[tmpPath stringByAppendingString:@".gif"]
                                              contents:imageData];
                         }
                         break;
                       case 0x89:
                         // image/png
                         [self createImageFileAtPath:[tmpPath stringByAppendingString:@".png"]
                                            contents:UIImagePNGRepresentation(image)];
                         break;
                       case 0xff:
                         // image/jpeg
                         [self createImageFileAtPath:[tmpPath stringByAppendingString:@".jpeg"]
                                            contents:UIImageJPEGRepresentation(image, 1)
                                                with:asset];
                         break;
                       case 0x49:
                         // image/tiff
                         // TODO Drawing as JPEG.
                         [self createImageFileAtPath:[tmpPath stringByAppendingString:@".tiff"]
                                            contents:UIImageJPEGRepresentation(image, 1)
                                                with:asset];
                         break;
                       case 0x4d:
                         // image/tiff
                         // TODO Drawing as JPEG.
                         [self createImageFileAtPath:[tmpPath stringByAppendingString:@".tiff"]
                                            contents:UIImageJPEGRepresentation(image, 1)
                                                with:asset];
                         break;
                       default:
                         // Drawing as JPEG.
                         [self createImageFileAtPath:[tmpPath stringByAppendingString:@".jpeg"]
                                            contents:UIImageJPEGRepresentation(image, 1)
                                                with:asset];
                         break;
                     }
                   }];
  }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
  [_imagePickerController dismissViewControllerAnimated:YES completion:nil];
  _result(nil);

  _result = nil;
  _arguments = nil;
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

- (void)createImageFileAtPath:(NSString *)path contents:(NSData *)data {
  if ([[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil]) {
    _result(path);
  } else {
    _result([FlutterError errorWithCode:@"create_error"
                                message:@"Temporary file could not be created"
                                details:nil]);
  }
  _result = nil;
  _arguments = nil;
}

- (void)createImageFileAtPath:(NSString *)path contents:(NSData *)data with:(PHAsset *)asset {
  NSMutableDictionary *exifDict = [self fetchExifFrom:asset];
  NSMutableDictionary *gpsDict = [self fetchGpsFrom:asset];

  NSMutableData *imageData = [NSMutableData data];
  CGImageSourceRef cgImage = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
  CGImageDestinationRef destination = CGImageDestinationCreateWithData(
      (__bridge CFMutableDataRef)imageData, CGImageSourceGetType(cgImage), 1, nil);
  CGImageDestinationAddImageFromSource(
      destination, cgImage, 0,
      (__bridge CFDictionaryRef)[NSDictionary
          dictionaryWithObjectsAndKeys:exifDict,
                                       (__bridge NSString *)kCGImagePropertyExifDictionary, gpsDict,
                                       (__bridge NSString *)kCGImagePropertyGPSDictionary, nil]);
  CGImageDestinationFinalize(destination);

  [imageData writeToFile:path atomically:YES];

  CFRelease(cgImage);
  CFRelease(destination);

  _result(path);
  _result = nil;
  _arguments = nil;
}

- (NSMutableDictionary *)fetchExifFrom:(PHAsset *)asset {
  NSMutableDictionary *result = [NSMutableDictionary dictionary];
  NSDate *creationDate = asset.creationDate;

  NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
  [outputFormatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
  NSString *original = [outputFormatter stringFromDate:creationDate];
  [result setObject:original forKey:(__bridge NSString *)kCGImagePropertyExifDateTimeOriginal];
  [result setObject:original forKey:(__bridge NSString *)kCGImagePropertyExifDateTimeDigitized];
  return result;
}

- (NSMutableDictionary *)fetchGpsFrom:(PHAsset *)asset {
  NSMutableDictionary *result = [NSMutableDictionary dictionary];
  CLLocation *location = asset.location;
  CGFloat latitude = location.coordinate.latitude;
  NSString *gpsLatitudeRef;
  if (latitude < 0) {
    latitude = -latitude;
    gpsLatitudeRef = @"S";
  } else {
    gpsLatitudeRef = @"N";
  }
  [result setObject:gpsLatitudeRef forKey:(__bridge NSString *)kCGImagePropertyGPSLatitudeRef];
  [result setObject:@(latitude) forKey:(__bridge NSString *)kCGImagePropertyGPSLatitude];

  CGFloat longitude = location.coordinate.longitude;
  NSString *gpsLongitudeRef;
  if (longitude < 0) {
    longitude = -longitude;
    gpsLongitudeRef = @"W";
  } else {
    gpsLongitudeRef = @"E";
  }
  [result setObject:gpsLongitudeRef forKey:(__bridge NSString *)kCGImagePropertyGPSLongitudeRef];
  [result setObject:@(longitude) forKey:(__bridge NSString *)kCGImagePropertyGPSLongitude];

  CGFloat altitude = location.altitude;
  if (!isnan(altitude)) {
    NSString *gpsAltitudeRef;
    if (altitude < 0) {
      altitude = -altitude;
      gpsAltitudeRef = @"1";
    } else {
      gpsAltitudeRef = @"0";
    }
    [result setObject:gpsAltitudeRef forKey:(__bridge NSString *)kCGImagePropertyGPSAltitudeRef];
    [result setObject:@(altitude) forKey:(__bridge NSString *)kCGImagePropertyGPSAltitude];
  }
  return result;
}

@end
