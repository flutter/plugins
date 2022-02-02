// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;
@import Foundation;
@import Flutter;

#import "FLTThreadSafeFlutterResult.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Delegate object that handles photo capture results.
 */
@interface FLTSavePhotoDelegate : NSObject <AVCapturePhotoCaptureDelegate>
/// The file path for the captured photo.
@property(readonly, nonatomic) NSString *path;
/// The thread safe flutter result wrapper to report the result.
@property(readonly, nonatomic) FLTThreadSafeFlutterResult *result;
/// The queue on which captured photos are wrote to disk.
@property(strong, nonatomic) dispatch_queue_t ioQueue;
/// Used to keep the delegate alive until didFinishProcessingPhotoSampleBuffer.
@property(strong, nonatomic, nullable) FLTSavePhotoDelegate *selfReference;

/**
 * Initialize a photo capture delegate.
 * @param path the path for captured photo file.
 * @param result the thread safe flutter result wrapper to report the result.
 * @param ioQueue the queue on which captured photos are wrote to disk.
 */
- (instancetype)initWithPath:(NSString *)path
                      result:(FLTThreadSafeFlutterResult *)result
                     ioQueue:(dispatch_queue_t)ioQueue;
@end

NS_ASSUME_NONNULL_END
