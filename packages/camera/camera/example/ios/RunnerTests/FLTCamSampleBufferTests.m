// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera;
@import camera.Test;
@import AVFoundation;
@import XCTest;
#import <OCMock/OCMock.h>

@interface FLTCamSampleBufferTests : XCTestCase

@end

@implementation FLTCamSampleBufferTests

- (void)testSampleBufferCallbackQueueMustBeCaptureSessionQueue {
  id inputMock = OCMClassMock([AVCaptureDeviceInput class]);
  OCMStub([inputMock deviceInputWithDevice:[OCMArg any] error:[OCMArg setTo:nil]])
      .andReturn(inputMock);

  id sessionMock = OCMClassMock([AVCaptureSession class]);
  OCMStub([sessionMock alloc]).andReturn(sessionMock);
  OCMStub([sessionMock addInputWithNoConnections:[OCMArg any]]);  // no-op
  OCMStub([sessionMock canSetSessionPreset:[OCMArg any]]).andReturn(YES);

  dispatch_queue_t captureSessionQueue = dispatch_queue_create("testing", NULL);
  FLTCam *cam = [[FLTCam alloc] initWithCameraName:@"camera"
                                  resolutionPreset:@"medium"
                                       enableAudio:true
                                       orientation:UIDeviceOrientationPortrait
                               captureSessionQueue:captureSessionQueue
                                             error:nil];
  XCTAssertEqual(captureSessionQueue, cam.captureVideoOutput.sampleBufferCallbackQueue);
}

@end
