// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTImagePickerPhotoAssetUtil.h"
#import "FLTImagePickerImageUtil.h"
#import "FLTImagePickerMetaDataUtil.h"

#import <MobileCoreServices/MobileCoreServices.h>;

@implementation FLTImagePickerPhotoAssetUtil

+ (PHAsset *)getAssetFromImagePickerInfo:(NSDictionary *)info {
  if (@available(iOS 11, *)) {
    return [info objectForKey:UIImagePickerControllerPHAsset];
  }
  NSURL *referenceURL = [info objectForKey:UIImagePickerControllerReferenceURL];
  PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsWithALAssetURLs:@[ referenceURL ]
                                                                 options:nil];
  return result.firstObject;
}

+ (NSString *)saveImageWithOriginalImageData:(NSData *)originalImageData
                                       image:(UIImage *)image
                                    maxWidth:(NSNumber *)maxWidth
                                   maxHeight:(NSNumber *)maxHeight {
  NSString *suffix = kFLTImagePickerDefaultSuffix;
  FLTImagePickerMIMEType type = kFLTImagePickerMIMETypeDefault;
  NSDictionary *metaData = nil;
  // Getting the image type from the original image data if necessary.
  if (originalImageData) {
    type = [FLTImagePickerMetaDataUtil getImageMIMETypeFromImageData:originalImageData];
    suffix =
        [FLTImagePickerMetaDataUtil imageTypeSuffixFromType:type] ?: kFLTImagePickerDefaultSuffix;
    metaData = [FLTImagePickerMetaDataUtil getMetaDataFromImageData:originalImageData];
  }
  if (type == FLTImagePickerMIMETypeGIF) {
    GIFInfo gifInfo = [FLTImagePickerImageUtil scaledGIFImage:originalImageData
                                                     maxWidth:maxWidth
                                                    maxHeight:maxHeight];

    return [self saveImageWithMetaData:metaData gifInfo:gifInfo suffix:suffix];
  } else {
    return [self saveImageWithMetaData:metaData image:image suffix:suffix type:type];
  }
}

+ (NSString *)saveImageWithPickerInfo:(nullable NSDictionary *)info image:(UIImage *)image {
  NSDictionary *metaData = info[UIImagePickerControllerMediaMetadata];
  return [self saveImageWithMetaData:metaData
                               image:image
                              suffix:kFLTImagePickerDefaultSuffix
                                type:kFLTImagePickerMIMETypeDefault];
}

+ (NSString *)saveImageWithMetaData:(NSDictionary *)metaData
                            gifInfo:(GIFInfo)gifInfo
                             suffix:(NSString *)suffix {
  NSString *path = [self temporaryFilePath:suffix];
  return [self saveImageWithMetaData:metaData gifInfo:gifInfo path:path];
}

+ (NSString *)saveImageWithMetaData:(NSDictionary *)metaData
                              image:(UIImage *)image
                             suffix:(NSString *)suffix
                               type:(FLTImagePickerMIMEType)type {
  CGImagePropertyOrientation orientation = (CGImagePropertyOrientation)[metaData[(
      __bridge NSString *)kCGImagePropertyOrientation] integerValue];
  UIImage *newImage = [UIImage
      imageWithCGImage:[image CGImage]
                 scale:1.0
           orientation:
               [FLTImagePickerMetaDataUtil
                   getNormalizedUIImageOrientationFromCGImagePropertyOrientation:orientation]];

  NSData *data = [FLTImagePickerMetaDataUtil convertImage:newImage usingType:type quality:nil];
  if (metaData) {
    data = [FLTImagePickerMetaDataUtil updateMetaData:metaData toImage:data];
  }

  return [self createFile:data suffix:suffix];
}

+ (NSString *)saveImageWithMetaData:(NSDictionary *)metaData
                            gifInfo:(GIFInfo)gifInfo
                               path:(NSString *)path {
  CGImageDestinationRef destination = CGImageDestinationCreateWithURL(
      (CFURLRef)[NSURL fileURLWithPath:path], kUTTypeGIF, gifInfo.images.count, NULL);

  NSDictionary *frameProperties = [NSDictionary
      dictionaryWithObject:[NSDictionary
                               dictionaryWithObject:[NSNumber numberWithFloat:gifInfo.interval]
                                             forKey:(NSString *)kCGImagePropertyGIFDelayTime]
                    forKey:(NSString *)kCGImagePropertyGIFDictionary];

  NSMutableDictionary *gifMetaProperties = [NSMutableDictionary dictionaryWithDictionary:metaData];
  NSMutableDictionary *gifProperties =
      (NSMutableDictionary *)gifMetaProperties[(NSString *)kCGImagePropertyGIFDictionary];
  if (gifMetaProperties == nil) {
    gifProperties = [NSMutableDictionary dictionary];
  }

  gifProperties[(NSString *)kCGImagePropertyGIFLoopCount] = [NSNumber numberWithFloat:0];

  CGImageDestinationSetProperties(destination, (CFDictionaryRef)gifMetaProperties);

  CGImagePropertyOrientation orientation = (CGImagePropertyOrientation)[metaData[(
      __bridge NSString *)kCGImagePropertyOrientation] integerValue];

  for (NSInteger index = 0; index < gifInfo.images.count; index++) {
    UIImage *image = (UIImage *)[gifInfo.images objectAtIndex:index];
    UIImage *newImage = [UIImage
        imageWithCGImage:[image CGImage]
                   scale:1.0
             orientation:
                 [FLTImagePickerMetaDataUtil
                     getNormalizedUIImageOrientationFromCGImagePropertyOrientation:orientation]];

    CGImageDestinationAddImage(destination, newImage.CGImage, (CFDictionaryRef)frameProperties);
  }

  CGImageDestinationFinalize(destination);
  CFRelease(destination);

  return path;
}

+ (NSString *)temporaryFilePath:(NSString *)suffix {
  NSString *fileExtension = [@"image_picker_%@" stringByAppendingString:suffix];
  NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString];
  NSString *tmpFile = [NSString stringWithFormat:fileExtension, guid];
  NSString *tmpDirectory = NSTemporaryDirectory();
  NSString *tmpPath = [tmpDirectory stringByAppendingPathComponent:tmpFile];
  return tmpPath;
}

+ (NSString *)createFile:(NSData *)data suffix:(NSString *)suffix {
  NSString *tmpPath = [self temporaryFilePath:suffix];
  if ([[NSFileManager defaultManager] createFileAtPath:tmpPath contents:data attributes:nil]) {
    return tmpPath;
  } else {
    nil;
  }
  return tmpPath;
}

@end
