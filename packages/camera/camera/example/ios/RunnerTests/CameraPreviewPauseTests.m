// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera;
@import XCTest;
@import AVFoundation;
#import <OCMock/OCMock.h>

@interface FLTCam : NSObject <FlutterTexture,
                              AVCaptureVideoDataOutputSampleBufferDelegate,
                              AVCaptureAudioDataOutputSampleBufferDelegate>
@property(assign, nonatomic) BOOL isPreviewPaused;
- (void)pausePreviewWithResult:(FlutterResult)result;
- (void)resumePreviewWithResult:(FlutterResult)result;
@end

@interface CameraPreviewPauseTests : XCTestCase
@property(readonly, nonatomic) FLTCam* camera;
@end

@implementation CameraPreviewPauseTests

- (void)setUp {
  _camera = [[FLTCam alloc] init];
}

- (void)testPausePreviewWithResult_shouldPausePreview {
  XCTestExpectation* resultExpectation =
      [self expectationWithDescription:@"Succeeding result with nil value"];
  [_camera pausePreviewWithResult:^void(id _Nullable result) {
    XCTAssertNil(result);
    [resultExpectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:2.0 handler:nil];
  XCTAssertTrue(_camera.isPreviewPaused);
}

- (void)testResumePreviewWithResult_shouldResumePreview {
  XCTestExpectation* resultExpectation =
      [self expectationWithDescription:@"Succeeding result with nil value"];
  [_camera resumePreviewWithResult:^void(id _Nullable result) {
    XCTAssertNil(result);
    [resultExpectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:2.0 handler:nil];
  XCTAssertFalse(_camera.isPreviewPaused);
}

@end
