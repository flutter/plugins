//
//  SampleBufferQueueTests.m
//  RunnerTests
//
//  Created by Huan Lin on 1/27/22.
//  Copyright © 2022 The Flutter Authors. All rights reserved.
//

@import camera;
@import camera.Test;
@import AVFoundation;
@import XCTest;
#import <OCMock/OCMock.h>

@interface SampleBufferQueueTests : XCTestCase

@end

@implementation SampleBufferQueueTests

- (void)testSampleBufferDelegateCallbackMustRunOnCaptureSessionQueue {
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
