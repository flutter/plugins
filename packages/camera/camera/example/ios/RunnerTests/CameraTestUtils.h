// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera;

NS_ASSUME_NONNULL_BEGIN

@interface CameraTestUtils : NSObject

/// Creates an `FLTCam` that runs its capture session operations on a given queue.
/// @param captureSessionQueue the capture session queue
/// @return an FLTCam object.
+ (FLTCam *)createFLTCamWithCaptureSessionQueue:(dispatch_queue_t)captureSessionQueue;

/// Creates a test sample buffer.
/// @return a test sample buffer.
+ (CMSampleBufferRef)createTestSampleBuffer;

@end

NS_ASSUME_NONNULL_END
