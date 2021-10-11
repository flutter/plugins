// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera;
@import XCTest;
@import AVFoundation;
#import <OCMock/OCMock.h>
#import "MockFLTThreadSafeFlutterResult.h"

@interface FLTCam : NSObject <FlutterTexture,
                              AVCaptureVideoDataOutputSampleBufferDelegate,
                              AVCaptureAudioDataOutputSampleBufferDelegate>
@property(assign, nonatomic) BOOL isPreviewPaused;
- (void)pausePreviewWithResult:(FLTThreadSafeFlutterResult *)result;
- (void)resumePreviewWithResult:(FLTThreadSafeFlutterResult *)result;
@end

@interface CameraPreviewPauseTests : XCTestCase
@property(readonly, nonatomic) FLTCam *camera;
@property(readonly, nonatomic) MockFLTThreadSafeFlutterResult *resultObject;
@end

@implementation CameraPreviewPauseTests

- (void)setUp {
  _camera = [[FLTCam alloc] init];

  XCTestExpectation *expectation =
      [[XCTestExpectation alloc] initWithDescription:@"Result finished"];
  _resultObject = [[MockFLTThreadSafeFlutterResult alloc] initWithExpectation:expectation];
}

- (void)testPausePreviewWithResult_shouldPausePreview {
  [_camera pausePreviewWithResult:_resultObject];
  XCTAssertTrue(_camera.isPreviewPaused);
}

- (void)testResumePreviewWithResult_shouldResumePreview {
  [_camera resumePreviewWithResult:_resultObject];
  XCTAssertFalse(_camera.isPreviewPaused);
}

@end
