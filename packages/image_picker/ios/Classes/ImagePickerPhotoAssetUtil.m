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
  NSDictionary *exifData = nil;
  // Getting the image type from the original image data if necessary.
  if (originalImageData) {
    type = [ImagePickerMetaDataUtil getImageMIMETypeFromImageData:originalImageData];
    suffix =
        [ImagePickerMetaDataUtil imageTypeSuffixFromType:type] ?: kFlutterImagePickerDefaultSuffix;
    exifData = [ImagePickerMetaDataUtil getEXIFFromImageData:originalImageData];
  }
  return [self saveImageWithExif:exifData image:image suffix:suffix type:type];
}

+ (NSString *)saveImageWithPickerInfo:(nullable NSDictionary *)info image:(UIImage *)image {
  NSDictionary *exif = info[UIImagePickerControllerMediaMetadata]
                           [(__bridge NSString *)kCGImagePropertyExifDictionary];
  return [self saveImageWithExif:exif
                           image:image
                          suffix:kFlutterImagePickerDefaultSuffix
                            type:kFlutterImagePickerMIMETypeDefault];
}

+ (NSString *)saveImageWithExif:(NSDictionary *)exif
                          image:(UIImage *)image
                         suffix:(NSString *)suffix
                           type:(FlutterImagePickerMIMEType)type {
  NSData *data = [ImagePickerMetaDataUtil convertImage:image usingType:type quality:nil];
  if (exif) {
    data = [ImagePickerMetaDataUtil updateEXIFData:exif toImage:data];
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
