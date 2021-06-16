// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GetPathForPHPPickerImageOperation.h"

API_AVAILABLE(ios(14))
@interface GetPathForPHPPickerImageOperation ()

@property(strong, nonatomic) PHPickerResult *result;
@property(weak, nonatomic) NSMutableArray *pathList;
@property(assign, nonatomic) NSNumber *maxHeight;
@property(assign, nonatomic) NSNumber *maxWidth;
@property(assign, nonatomic) NSNumber *desiredImageQuality;
@property(assign, nonatomic) NSInteger index;

@end

@implementation GetPathForPHPPickerImageOperation {
  BOOL executing;
  BOOL finished;
}

- (instancetype)initWithResult:(PHPickerResult *)result
                      pathlist:(NSMutableArray *)pathList
                     maxHeight:(NSNumber *)maxHeight
                      maxWidth:(NSNumber *)maxWidth
           desiredImageQuality:(NSNumber *)desiredImageQuality
                         index:(NSInteger)index API_AVAILABLE(ios(14)) {
  if (self = [super init]) {
    if (result) {
      self.result = result;
      self.pathList = pathList;
      self.maxHeight = maxHeight;
      self.maxWidth = maxWidth;
      self.desiredImageQuality = desiredImageQuality;
      self.index = index;
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

- (void)completeOperation {
  [self setExecuting:NO];
  [self setFinished:YES];
}

- (void)start {
  if ([self isCancelled]) {
    [self setFinished:YES];
    return;
  }
  [self setExecuting:YES];
  if (@available(iOS 14, *)) {
    [self.result.itemProvider
        loadObjectOfClass:[UIImage class]
        completionHandler:^(__kindof id<NSItemProviderReading> _Nullable image,
                            NSError *_Nullable error) {
          if ([image isKindOfClass:[UIImage class]]) {
            __block UIImage *localImage = image;
            PHAsset *originalAsset =
                [FLTImagePickerPhotoAssetUtil getAssetFromPHPickerResult:self.result];

            if (self.maxWidth != (id)[NSNull null] || self.maxHeight != (id)[NSNull null]) {
              localImage = [FLTImagePickerImageUtil scaledImage:localImage
                                                       maxWidth:self.maxWidth
                                                      maxHeight:self.maxHeight
                                            isMetadataAvailable:originalAsset != nil];
            }
            __block NSString *savedPath;
            if (!originalAsset) {
              // Image picked without an original asset (e.g. User pick image without permission)
              savedPath =
                  [FLTImagePickerPhotoAssetUtil saveImageWithPickerInfo:nil
                                                                  image:localImage
                                                           imageQuality:self.desiredImageQuality];
              self.pathList[self.index] = savedPath;
              [self completeOperation];
            } else {
              [[PHImageManager defaultManager]
                  requestImageDataForAsset:originalAsset
                                   options:nil
                             resultHandler:^(
                                 NSData *_Nullable imageData, NSString *_Nullable dataUTI,
                                 UIImageOrientation orientation, NSDictionary *_Nullable info) {
                               // maxWidth and maxHeight are used only for GIF images.
                               savedPath = [FLTImagePickerPhotoAssetUtil
                                   saveImageWithOriginalImageData:imageData
                                                            image:localImage
                                                         maxWidth:self.maxWidth
                                                        maxHeight:self.maxHeight
                                                     imageQuality:self.desiredImageQuality];
                               self.pathList[self.index] = savedPath;
                               [self completeOperation];
                             }];
            }
          }
        }];
  }
}

@end
