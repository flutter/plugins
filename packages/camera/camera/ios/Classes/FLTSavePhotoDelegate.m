// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTSavePhotoDelegate.h"

@implementation FLTSavePhotoDelegate

- (instancetype)initWithPath:(NSString *)path
                      result:(FLTThreadSafeFlutterResult *)result
                     ioQueue:(dispatch_queue_t)ioQueue {
  self = [super init];
  NSAssert(self, @"super init cannot be nil");
  _path = path;
  _selfReference = self;
  _result = result;
  _ioQueue = ioQueue;
  return self;
}

- (void)handlePhotoCaptureResultWithError:(NSError *)error
                        photoDataProvider:(NSData * (^)(void))photoDataProvider {
  self.selfReference = nil;
  if (error) {
    [self.result sendError:error];
    return;
  }
  dispatch_async(self.ioQueue, ^{
    NSData *data = photoDataProvider();
    NSError *ioError;
    if ([data writeToFile:self.path options:NSDataWritingAtomic error:&ioError]) {
      [self.result sendSuccessWithData:self.path];
    } else {
      [self.result sendErrorWithCode:@"IOError"
                             message:@"Unable to write file"
                             details:ioError.localizedDescription];
    }
  });
}

- (void)captureOutput:(AVCapturePhotoOutput *)output
    didFinishProcessingPhotoSampleBuffer:(CMSampleBufferRef)photoSampleBuffer
                previewPhotoSampleBuffer:(CMSampleBufferRef)previewPhotoSampleBuffer
                        resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings
                         bracketSettings:(AVCaptureBracketedStillImageSettings *)bracketSettings
                                   error:(NSError *)error API_AVAILABLE(ios(10)) {
  [self handlePhotoCaptureResultWithError:error
                        photoDataProvider:^NSData * {
                          return [AVCapturePhotoOutput
                              JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer
                                                    previewPhotoSampleBuffer:
                                                        previewPhotoSampleBuffer];
                        }];
}

- (void)captureOutput:(AVCapturePhotoOutput *)output
    didFinishProcessingPhoto:(AVCapturePhoto *)photo
                       error:(NSError *)error API_AVAILABLE(ios(11.0)) {
  [self handlePhotoCaptureResultWithError:error
                        photoDataProvider:^NSData * {
                          return [photo fileDataRepresentation];
                        }];
}

@end
