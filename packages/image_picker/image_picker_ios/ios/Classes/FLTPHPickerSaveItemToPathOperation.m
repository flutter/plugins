// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

#import "FLTPHPickerSaveItemToPathOperation.h"
#import "FLTPHPickerSaveItemToPathOperation_Test.h"

API_AVAILABLE(ios(14))
@interface FLTPHPickerSaveItemToPathOperation ()

@property(strong, nonatomic) PHPickerResult *result;
@property(strong, nonatomic) PHAsset *asset;
@property(assign, nonatomic) NSNumber *maxImageHeight;
@property(assign, nonatomic) NSNumber *maxImageWidth;
@property(assign, nonatomic) NSNumber *desiredImageQuality;

@end

typedef void (^GetSavedPath)(NSString *);

@implementation FLTPHPickerSaveItemToPathOperation {
  BOOL executing;
  BOOL finished;
  GetSavedPath getSavedPath;
}

- (instancetype)initWithResult:(PHPickerResult *)result
                maxImageHeight:(NSNumber *)maxImageHeight
                 maxImageWidth:(NSNumber *)maxImageWidth
           desiredImageQuality:(NSNumber *)desiredImageQuality
                savedPathBlock:(GetSavedPath)savedPathBlock API_AVAILABLE(ios(14)) {
  if (self = [super init]) {
    if (result) {
      self.result = result;
      self.maxImageHeight = maxImageHeight;
      self.maxImageWidth = maxImageWidth;
      self.desiredImageQuality = desiredImageQuality;
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

- (instancetype)initWithAsset:(PHAsset *)asset
               maxImageHeight:(NSNumber *)maxImageHeight
                maxImageWidth:(NSNumber *)maxImageWidth
          desiredImageQuality:(NSNumber *)desiredImageQuality
               savedPathBlock:(GetSavedPath)savedPathBlock {
  if (self = [super init]) {
    if (asset) {
      self.asset = asset;
      self.maxImageHeight = maxImageHeight;
      self.maxImageWidth = maxImageWidth;
      self.desiredImageQuality = desiredImageQuality;
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
  getSavedPath(savedPath);
  [self setExecuting:NO];
  [self setFinished:YES];
}

- (void)start {
  if ([self isCancelled]) {
    [self setFinished:YES];
    return;
  }
  [self setExecuting:YES];
  if (self.result != nil) {
    [self startForResult];
  } else if (self.asset != nil) {
    [self startForAsset];
  }
}

- (void)startForResult {
  if (@available(iOS 14, *)) {
    if ([self.result.itemProvider hasItemConformingToTypeIdentifier:@"public.movie"]) {
      NSString *typeIdentifier = self.result.itemProvider.registeredTypeIdentifiers.firstObject;
      [self.result.itemProvider
          loadFileRepresentationForTypeIdentifier:typeIdentifier
                                completionHandler:^(NSURL *_Nullable videoURL,
                                                    NSError *_Nullable error) {
                                  [self processVideo:videoURL];
                                }];
    } else if ([self.result.itemProvider hasItemConformingToTypeIdentifier:@"public.image"]) {
      if ([self.result.itemProvider hasItemConformingToTypeIdentifier:UTTypeWebP.identifier]) {
        [self.result.itemProvider
            loadDataRepresentationForTypeIdentifier:UTTypeWebP.identifier
                                  completionHandler:^(NSData *_Nullable data,
                                                      NSError *_Nullable error) {
                                    UIImage *image = [[UIImage alloc] initWithData:data];
                                    [self processImage:image];
                                  }];
      } else {
        [self.result.itemProvider
            loadObjectOfClass:[UIImage class]
            completionHandler:^(__kindof id<NSItemProviderReading> _Nullable image,
                                NSError *_Nullable error) {
              if ([image isKindOfClass:[UIImage class]]) {
                [self processImage:image];
              }
            }];
      }
    }
  } else {
    [self setFinished:YES];
  }
}

- (void)startForAsset {
  switch (self.asset.mediaType) {
    case PHAssetMediaTypeImage: {
      [[PHImageManager defaultManager] requestImageForAsset:self.asset
                                                 targetSize:CGSizeMake(0, 0)
                                                contentMode:PHImageContentModeDefault
                                                    options:nil
                                              resultHandler:^(UIImage *image, NSDictionary *info) {
                                                [self processImage:image];
                                              }];
      break;
    }
    case PHAssetMediaTypeVideo: {
      PHVideoRequestOptions *options = [PHVideoRequestOptions new];
      options.version = PHVideoRequestOptionsVersionOriginal;
      [[PHImageManager defaultManager]
          requestAVAssetForVideo:self.asset
                         options:options
                   resultHandler:^(AVAsset *_Nullable asset, AVAudioMix *_Nullable audioMix,
                                   NSDictionary *_Nullable info) {
                     NSURL *url = nil;
                     if ([asset isKindOfClass:[AVURLAsset class]]) {
                       url = ((AVURLAsset *)asset).URL;
                     }
                     [self processVideo:url];
                   }];
      break;
    }
    default: {
      [self setFinished:YES];
      break;
    }
  }
}

/**
 * Processes the image.
 */
- (void)processImage:(UIImage *)localImage {
  PHAsset *originalAsset = self.asset;
  if (originalAsset == nil) {
    if (@available(iOS 14, *)) {
      originalAsset = [FLTImagePickerPhotoAssetUtil getAssetFromPHPickerResult:self.result];
    }
  }

  if (self.maxImageWidth != nil || self.maxImageHeight != nil) {
    localImage = [FLTImagePickerImageUtil scaledImage:localImage
                                             maxWidth:self.maxImageWidth
                                            maxHeight:self.maxImageHeight
                                  isMetadataAvailable:originalAsset != nil];
  }
  if (originalAsset) {
    void (^resultHandler)(NSData *imageData, NSString *dataUTI, NSDictionary *info) =
        ^(NSData *_Nullable imageData, NSString *_Nullable dataUTI, NSDictionary *_Nullable info) {
          // maxWidth and maxHeight are used only for GIF images.
          NSString *savedPath = [FLTImagePickerPhotoAssetUtil
              saveImageWithOriginalImageData:imageData
                                       image:localImage
                                    maxWidth:self.maxImageWidth
                                   maxHeight:self.maxImageHeight
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

/**
 * Processes the video.
 */
- (void)processVideo:(NSURL *)videoURL {
  if (videoURL == nil) {
    return;
  }
  NSString *fileName = [videoURL lastPathComponent];
  NSURL *destination =
      [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];

  if ([[NSFileManager defaultManager] isReadableFileAtPath:[videoURL path]]) {
    NSError *error;
    if (![[videoURL path] isEqualToString:[destination path]]) {
      [[NSFileManager defaultManager] copyItemAtURL:videoURL toURL:destination error:&error];
      if (error) {
        if (error.code != NSFileWriteFileExistsError) {
          return;
        }
      }
    }
    [self completeOperationWithPath:[destination path]];
  }
}

@end

@implementation FLTPHPickerSaveItemToPathOperationFactory
+ (FLTPHPickerSaveItemToPathOperation *)operationWithResult:(PHPickerResult *)result
                                             maxImageHeight:(NSNumber *)maxImageHeight
                                              maxImageWidth:(NSNumber *)maxImageWidth
                                        desiredImageQuality:(NSNumber *)desiredImageQuality
                                             savedPathBlock:(GetSavedPath)savedPathBlock
    API_AVAILABLE(ios(14)) {
  return [[FLTPHPickerSaveItemToPathOperation alloc] initWithResult:result
                                                     maxImageHeight:maxImageHeight
                                                      maxImageWidth:maxImageWidth
                                                desiredImageQuality:desiredImageQuality
                                                     savedPathBlock:savedPathBlock];
}

+ (FLTPHPickerSaveItemToPathOperation *)operationWithAsset:(PHAsset *)asset
                                            maxImageHeight:(NSNumber *)maxImageHeight
                                             maxImageWidth:(NSNumber *)maxImageWidth
                                       desiredImageQuality:(NSNumber *)desiredImageQuality
                                            savedPathBlock:(GetSavedPath)savedPathBlock {
  return [[FLTPHPickerSaveItemToPathOperation alloc] initWithAsset:asset
                                                    maxImageHeight:maxImageHeight
                                                     maxImageWidth:maxImageWidth
                                               desiredImageQuality:desiredImageQuality
                                                    savedPathBlock:savedPathBlock];
}
@end
