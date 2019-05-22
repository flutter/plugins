// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ImagePickerMetaDataUtil.h"
#import <Photos/Photos.h>

static const uint8_t kFirstByteJPEG = 0xFF;
static const uint8_t kFirstBytePNG = 0x89;

NSString *const kFlutterImagePickerDefaultSuffix = @".jpg";
const FlutterImagePickerMIMEType kFlutterImagePickerMIMETypeDefault =
    FlutterImagePickerMIMETypeJPEG;

@implementation ImagePickerMetaDataUtil

+ (FlutterImagePickerMIMEType)getImageMIMETypeFromImageData:(NSData *)imageData {
  uint8_t firstByte;
  [imageData getBytes:&firstByte length:1];
  switch (firstByte) {
    case kFirstByteJPEG:
      return FlutterImagePickerMIMETypeJPEG;
    case kFirstBytePNG:
      return FlutterImagePickerMIMETypePNG;
  }
  return FlutterImagePickerMIMETypeOther;
}

+ (NSString *)imageTypeSuffixFromType:(FlutterImagePickerMIMEType)type {
  switch (type) {
    case FlutterImagePickerMIMETypeJPEG:
      return @".jpg";
    case FlutterImagePickerMIMETypePNG:
      return @".png";
    default:
      return nil;
  }
}

+ (NSDictionary *)getMetaDataFromImageData:(NSData *)imageData {
  CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)imageData, NULL);
  NSDictionary *metadata =
      (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source, 0, NULL));
  return metadata;
}

+ (NSData *)updateMetaData:(NSDictionary *)metaData toImage:(NSData *)imageData {
  NSMutableData *mutableData = [NSMutableData data];
  CGImageSourceRef cgImage = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
  CGImageDestinationRef destination = CGImageDestinationCreateWithData(
      (__bridge CFMutableDataRef)mutableData, CGImageSourceGetType(cgImage), 1, nil);
  CGImageDestinationAddImageFromSource(destination, cgImage, 0, (__bridge CFDictionaryRef)metaData);
  CGImageDestinationFinalize(destination);
  CFRelease(cgImage);
  CFRelease(destination);
  return mutableData;
}

+ (NSData *)convertImage:(UIImage *)image
               usingType:(FlutterImagePickerMIMEType)type
                 quality:(nullable NSNumber *)quality {
  if (quality && type != FlutterImagePickerMIMETypeJPEG) {
    @throw [NSException
        exceptionWithName:@"flutter_image_picker_convert_image_exception"
                   reason:[NSString stringWithFormat:@"quality is not available for type %@",
                                                     [ImagePickerMetaDataUtil
                                                         imageTypeSuffixFromType:type]]
                 userInfo:nil];
  }

  switch (type) {
    case FlutterImagePickerMIMETypeJPEG: {
      CGFloat qualityFloat = quality ? quality.floatValue : 1;
      return UIImageJPEGRepresentation(image, qualityFloat);
    }
    case FlutterImagePickerMIMETypePNG:
      return UIImagePNGRepresentation(image);
    default: {
      // converts to JPEG by default.
      CGFloat qualityFloat = quality ? quality.floatValue : 1;
      return UIImageJPEGRepresentation(image, qualityFloat);
    }
  }
}

+ (UIImageOrientation)getNormalizedUIImageOrientationFromCGImagePropertyOrientation:
    (CGImagePropertyOrientation)cgImageOrientation {
  switch (cgImageOrientation) {
    case kCGImagePropertyOrientationUp:
      return UIImageOrientationUp;
    case kCGImagePropertyOrientationDown:
      return UIImageOrientationDown;
    case kCGImagePropertyOrientationLeft:
      return UIImageOrientationRight;
    case kCGImagePropertyOrientationRight:
      return UIImageOrientationLeft;
    case kCGImagePropertyOrientationUpMirrored:
      return UIImageOrientationUpMirrored;
    case kCGImagePropertyOrientationDownMirrored:
      return UIImageOrientationDownMirrored;
    case kCGImagePropertyOrientationLeftMirrored:
      return UIImageOrientationRightMirrored;
    case kCGImagePropertyOrientationRightMirrored:
      return UIImageOrientationLeftMirrored;
    default:
      return UIImageOrientationUp;
  }
  return UIImageOrientationUp;
}

@end
