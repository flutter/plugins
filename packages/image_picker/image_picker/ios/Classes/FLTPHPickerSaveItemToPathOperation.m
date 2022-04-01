// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#import "FLTPHPickerSaveItemToPathOperation.h"

API_AVAILABLE(ios(14))
@interface FLTPHPickerSaveItemToPathOperation ()

@property(strong, nonatomic) PHPickerResult *result;
@property(assign, nonatomic) NSNumber *maxHeight;
@property(assign, nonatomic) NSNumber *maxWidth;
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
      self.maxHeight = maxImageHeight;
      self.maxWidth = maxImageWidth;
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
  [self setExecuting:NO];
  [self setFinished:YES];
  getSavedPath(savedPath);
}

- (void)processImage API_AVAILABLE(ios(14)) {
  [self.result.itemProvider
      loadObjectOfClass:[UIImage class]
      completionHandler:^(__kindof id<NSItemProviderReading> _Nullable data,
                          NSError *_Nullable error) {
        if ([data isKindOfClass:[UIImage class]]) {
          __block UIImage *localImage = data;
          PHAsset *originalAsset = [self getAssetFromPHPickerResult:self.result];
          if (self.maxWidth != (id)[NSNull null] || self.maxHeight != (id)[NSNull null]) {
            localImage = [FLTImagePickerImageUtil scaledImage:localImage
                                                     maxWidth:self.maxWidth
                                                    maxHeight:self.maxHeight
                                          isMetadataAvailable:originalAsset != nil];
          }
          __block NSString *savedPath;
          if (!originalAsset) {
            // Image picked without an original asset (e.g. User picked an image without
            // permission).
            savedPath = [self saveImageWithPickerInfo:nil
                                                image:localImage
                                         imageQuality:self.desiredImageQuality];
            [self completeOperationWithPath:savedPath];
          } else {
            [[PHImageManager defaultManager]
                requestImageDataForAsset:originalAsset
                                 options:nil
                           resultHandler:^(NSData *_Nullable imageData, NSString *_Nullable dataUTI,
                                           UIImageOrientation orientation,
                                           NSDictionary *_Nullable info) {
                             // maxWidth and maxHeight are used only for GIF images.
                             savedPath =
                                 [self saveImageWithOriginalImageData:imageData
                                                                image:localImage
                                                             maxWidth:self.maxWidth
                                                            maxHeight:self.maxHeight
                                                         imageQuality:self.desiredImageQuality];
                             [self completeOperationWithPath:savedPath];
                           }];
          }
        }
      }];
}

- (void)processVideo API_AVAILABLE(ios(14)) {
  NSString *typeIdentifier = self.result.itemProvider.registeredTypeIdentifiers.firstObject;
  [self.result.itemProvider
      loadFileRepresentationForTypeIdentifier:typeIdentifier
                            completionHandler:^(NSURL *_Nullable videoURL,
                                                NSError *_Nullable error) {
                              if (videoURL == nil) {
                                return;
                              }
                              NSString *fileName = [videoURL lastPathComponent];
                              NSURL *destination = [NSURL
                                  fileURLWithPath:[NSTemporaryDirectory()
                                                      stringByAppendingPathComponent:fileName]];

                              if ([[NSFileManager defaultManager]
                                      isReadableFileAtPath:[videoURL path]]) {
                                NSError *error;
                                if (![[videoURL path] isEqualToString:[destination path]]) {
                                  [[NSFileManager defaultManager] copyItemAtURL:videoURL
                                                                          toURL:destination
                                                                          error:&error];
                                  if (error) {
                                    if (error.code != NSFileWriteFileExistsError) {
                                      return;
                                    }
                                  }
                                }
                                [self completeOperationWithPath:[destination path]];
                              }
                            }];
}

- (void)start {
  if ([self isCancelled]) {
    [self setFinished:YES];
    return;
  }
  if (@available(iOS 14, *)) {
    [self setExecuting:YES];
    NSItemProvider *itemProvider = self.result.itemProvider;
    if ([itemProvider hasItemConformingToTypeIdentifier:@"public.movie"]) {
      [self processVideo];
    } else if ([itemProvider hasItemConformingToTypeIdentifier:@"public.image"]) {
      [self processImage];
    }
  } else {
    [self setFinished:YES];
  }
}

// Wrappers for mocking

- (PHAsset *)getAssetFromPHPickerResult:(PHPickerResult *)result API_AVAILABLE(ios(14)) {
  return [FLTImagePickerPhotoAssetUtil getAssetFromPHPickerResult:result];
}

- (NSString *)saveImageWithPickerInfo:(nullable NSDictionary *)info
                                image:(UIImage *)image
                         imageQuality:(NSNumber *)imageQuality {
  return [FLTImagePickerPhotoAssetUtil saveImageWithPickerInfo:info
                                                         image:image
                                                  imageQuality:imageQuality];
}

- (UIImage *)scaledImage:(UIImage *)image
                maxWidth:(NSNumber *)maxWidth
               maxHeight:(NSNumber *)maxHeight
     isMetadataAvailable:(BOOL)isMetadataAvailable {
  return [FLTImagePickerImageUtil scaledImage:image
                                     maxWidth:maxWidth
                                    maxHeight:maxHeight
                          isMetadataAvailable:isMetadataAvailable];
}

- (NSString *)saveImageWithOriginalImageData:(NSData *)originalImageData
                                       image:(UIImage *)image
                                    maxWidth:(NSNumber *)maxWidth
                                   maxHeight:(NSNumber *)maxHeight
                                imageQuality:(NSNumber *)imageQuality {
  return [FLTImagePickerPhotoAssetUtil saveImageWithOriginalImageData:originalImageData
                                                                image:image
                                                             maxWidth:maxWidth
                                                            maxHeight:maxHeight
                                                         imageQuality:imageQuality];
}

@end
