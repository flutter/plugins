// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ImagePickerPhotoAssetUtil.h"
#import "ImagePickerMetaDataUtil.h"

@implementation ImagePickerPhotoAssetUtil

+ (PHAsset *)getAssetFromImagePickerInfo:(NSDictionary *)info {
  if (@available(iOS 11, *)) {
    return [info objectForKey:UIImagePickerControllerPHAsset];
  }
  NSURL *referenceURL = [info objectForKey:UIImagePickerControllerReferenceURL];
  PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsWithALAssetURLs:@[ referenceURL ]
                                                                 options:nil];
  return result.firstObject;
}

+ (NSString *)saveImageWithOriginalImageData:(NSData *)originalImageData image:(UIImage *)image {
  NSString *suffix = kFlutterImagePickerDefaultSuffix;
  FlutterImagePickerMIMEType type = kFlutterImagePickerMIMETypeDefault;
  NSDictionary *metaData = nil;
  // Getting the image type from the original image data if necessary.
  if (originalImageData) {
    type = [ImagePickerMetaDataUtil getImageMIMETypeFromImageData:originalImageData];
    suffix =
        [ImagePickerMetaDataUtil imageTypeSuffixFromType:type] ?: kFlutterImagePickerDefaultSuffix;
    metaData = [ImagePickerMetaDataUtil getMetaDataFromImageData:originalImageData];
  }
  return [self saveImageWithMetaData:metaData image:image suffix:suffix type:type];
}

+ (NSString *)saveImageWithPickerInfo:(nullable NSDictionary *)info image:(UIImage *)image {
  NSDictionary *metaData = info[UIImagePickerControllerMediaMetadata];
  return [self saveImageWithMetaData:metaData
                               image:image
                              suffix:kFlutterImagePickerDefaultSuffix
                                type:kFlutterImagePickerMIMETypeDefault];
}

+ (NSString *)saveImageWithMetaData:(NSDictionary *)metaData
                              image:(UIImage *)image
                             suffix:(NSString *)suffix
                               type:(FlutterImagePickerMIMEType)type {
  CGImagePropertyOrientation orientation = (CGImagePropertyOrientation)[metaData[(
      __bridge NSString *)kCGImagePropertyOrientation] integerValue];
  UIImage *newImage = [UIImage
      imageWithCGImage:[image CGImage]
                 scale:1.0
           orientation:
               [ImagePickerMetaDataUtil
                   getNormalizedUIImageOrientationFromCGImagePropertyOrientation:orientation]];

  NSData *data = [ImagePickerMetaDataUtil convertImage:newImage usingType:type quality:nil];
  if (metaData) {
    data = [ImagePickerMetaDataUtil updateMetaData:metaData toImage:data];
  }

  NSString *fileExtension = [@"image_picker_%@" stringByAppendingString:suffix];
  NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString];
  NSString *tmpFile = [NSString stringWithFormat:fileExtension, guid];
  NSString *tmpDirectory = NSTemporaryDirectory();
  NSString *tmpPath = [tmpDirectory stringByAppendingPathComponent:tmpFile];
  if ([[NSFileManager defaultManager] createFileAtPath:tmpPath contents:data attributes:nil]) {
    return tmpPath;
  } else {
    nil;
  }
  return tmpPath;
}

@end
