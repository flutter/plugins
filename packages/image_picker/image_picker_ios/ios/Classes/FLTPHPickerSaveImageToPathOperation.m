// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

#import "FLTPHPickerSaveImageToPathOperation.h"

API_AVAILABLE(ios(14))
@interface FLTPHPickerSaveImageToPathOperation ()

@property(strong, nonatomic) PHPickerResult *result;
@property(assign, nonatomic) NSNumber *maxHeight;
@property(assign, nonatomic) NSNumber *maxWidth;
@property(assign, nonatomic) NSNumber *desiredImageQuality;
@property(assign, nonatomic) BOOL requestFullMetadata;

@end

typedef void (^GetSavedPath)(NSString *);

@implementation FLTPHPickerSaveImageToPathOperation {
  BOOL executing;
  BOOL finished;
  GetSavedPath getSavedPath;
}

- (instancetype)initWithResult:(PHPickerResult *)result
                     maxHeight:(NSNumber *)maxHeight
                      maxWidth:(NSNumber *)maxWidth
           desiredImageQuality:(NSNumber *)desiredImageQuality
                  fullMetadata:(BOOL)fullMetadata
                savedPathBlock:(GetSavedPath)savedPathBlock API_AVAILABLE(ios(14)) {
  if (self = [super init]) {
    if (result) {
      self.result = result;
      self.maxHeight = maxHeight;
      self.maxWidth = maxWidth;
      self.desiredImageQuality = desiredImageQuality;
      self.requestFullMetadata = fullMetadata;
      getSavedPath = savedPathBlock;
      executing = NO;
      finished = NO;
    } else {
      return nil;
    }
    return self;
  } else {
    return nil;
  }
}

- (BOOL)isConcurrent {
  return YES;
}

- (BOOL)isExecuting {
  return executing;
}

- (BOOL)isFinished {
  return finished;
}

- (void)setFinished:(BOOL)isFinished {
  [self willChangeValueForKey:@"isFinished"];
  self->finished = isFinished;
  [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)isExecuting {
  [self willChangeValueForKey:@"isExecuting"];
  self->executing = isExecuting;
  [self didChangeValueForKey:@"isExecuting"];
}

- (void)completeOperationWithPath:(NSString *)savedPath {
  [self setExecuting:NO];
  [self setFinished:YES];
  getSavedPath(savedPath);
}

- (void)start {
  if ([self isCancelled]) {
    [self setFinished:YES];
    return;
  }
  if (@available(iOS 14, *)) {
    [self setExecuting:YES];

    if ([self.result.itemProvider hasItemConformingToTypeIdentifier:UTTypeWebP.identifier]) {
      [self.result.itemProvider
          loadDataRepresentationForTypeIdentifier:UTTypeWebP.identifier
                                completionHandler:^(NSData *_Nullable data,
                                                    NSError *_Nullable error) {
                                  UIImage *image = [[UIImage alloc] initWithData:data];
                                  [self processImage:image];
                                }];
      return;
    }

    [self.result.itemProvider
        loadObjectOfClass:[UIImage class]
        completionHandler:^(__kindof id<NSItemProviderReading> _Nullable image,
                            NSError *_Nullable error) {
          if ([image isKindOfClass:[UIImage class]]) {
            [self processImage:image];
          }
        }];
  } else {
    [self setFinished:YES];
  }
}

/**
 * Processes the image.
 */
- (void)processImage:(UIImage *)localImage API_AVAILABLE(ios(14)) {
  PHAsset *originalAsset;
  // Only if requested, fetch the full "PHAsset" metadata, which requires  "Photo Library Usage"
  // permissions.
  if (self.requestFullMetadata) {
    originalAsset = [FLTImagePickerPhotoAssetUtil getAssetFromPHPickerResult:self.result];
  }

  if (self.maxWidth != nil || self.maxHeight != nil) {
    localImage = [FLTImagePickerImageUtil scaledImage:localImage
                                             maxWidth:self.maxWidth
                                            maxHeight:self.maxHeight
                                  isMetadataAvailable:originalAsset != nil];
  }
  if (originalAsset) {
    void (^resultHandler)(NSData *imageData, NSString *dataUTI, NSDictionary *info) =
        ^(NSData *_Nullable imageData, NSString *_Nullable dataUTI, NSDictionary *_Nullable info) {
          // maxWidth and maxHeight are used only for GIF images.
          NSString *savedPath = [FLTImagePickerPhotoAssetUtil
              saveImageWithOriginalImageData:imageData
                                       image:localImage
                                    maxWidth:self.maxWidth
                                   maxHeight:self.maxHeight
                                imageQuality:self.desiredImageQuality];
          [self completeOperationWithPath:savedPath];
        };
    if (@available(iOS 13.0, *)) {
      [[PHImageManager defaultManager]
          requestImageDataAndOrientationForAsset:originalAsset
                                         options:nil
                                   resultHandler:^(NSData *_Nullable imageData,
                                                   NSString *_Nullable dataUTI,
                                                   CGImagePropertyOrientation orientation,
                                                   NSDictionary *_Nullable info) {
                                     resultHandler(imageData, dataUTI, info);
                                   }];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
      [[PHImageManager defaultManager]
          requestImageDataForAsset:originalAsset
                           options:nil
                     resultHandler:^(NSData *_Nullable imageData, NSString *_Nullable dataUTI,
                                     UIImageOrientation orientation, NSDictionary *_Nullable info) {
                       resultHandler(imageData, dataUTI, info);
                     }];
#pragma clang diagnostic pop
    }
  } else {
    // Image picked without an original asset (e.g. User pick image without permission)
    NSString *savedPath =
        [FLTImagePickerPhotoAssetUtil saveImageWithPickerInfo:nil
                                                        image:localImage
                                                 imageQuality:self.desiredImageQuality];
    [self completeOperationWithPath:savedPath];
  }
}

@end
