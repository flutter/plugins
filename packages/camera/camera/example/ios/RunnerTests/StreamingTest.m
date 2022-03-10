// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera;
@import camera.Test;
@import XCTest;
@import AVFoundation;
#import <OCMock/OCMock.h>
#import "MockFLTThreadSafeFlutterResult.h"

@interface FLTImageStreamHandler : NSObject <FlutterStreamHandler>
- (instancetype)initWithCaptureSessionQueue:(dispatch_queue_t)captureSessionQueue;
@property FlutterEventSink eventSink;
@end

@interface StreamingTests : XCTestCase
@property(readonly, nonatomic) FLTCam *camera;
@end

@implementation StreamingTests

- (void)setUp {
  // set up mocks
  id inputMock = OCMClassMock([AVCaptureDeviceInput class]);
  OCMStub([inputMock deviceInputWithDevice:[OCMArg any] error:[OCMArg setTo:nil]])
      .andReturn(inputMock);

  id sessionMock = OCMClassMock([AVCaptureSession class]);
  OCMStub([sessionMock alloc]).andReturn(sessionMock);
  OCMStub([sessionMock addInputWithNoConnections:[OCMArg any]]);
  OCMStub([sessionMock canSetSessionPreset:[OCMArg any]]).andReturn(YES);

  // create a camera
  dispatch_queue_t captureSessionQueue = dispatch_queue_create("capture_session_queue", NULL);
  dispatch_queue_set_specific(captureSessionQueue, FLTCaptureSessionQueueSpecific,
                              (void *)FLTCaptureSessionQueueSpecific, NULL);
  _camera = [[FLTCam alloc] initWithCameraName:@"camera"
                              resolutionPreset:@"medium"
                                   enableAudio:true
                                   orientation:UIDeviceOrientationPortrait
                           captureSessionQueue:captureSessionQueue
                                         error:nil];
}

// Set up a sampleBuffer
- (CMSampleBufferRef)sampleBuffer {
  CVPixelBufferRef pixelBuffer;
  CVPixelBufferCreate(kCFAllocatorDefault, 100, 100, kCVPixelFormatType_32BGRA, nil, &pixelBuffer);
  CMVideoFormatDescriptionRef formatDescription;
  CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer,
                                               &formatDescription);
  CMSampleBufferRef sampleBuffer;
  CMSampleBufferCreateReadyWithImageBuffer(kCFAllocatorDefault, pixelBuffer, formatDescription,
                                           &kCMTimingInfoInvalid, &sampleBuffer);

  return sampleBuffer;
}

- (void)testExceedMaxStreamingPendingFramesCount {
  XCTestExpectation *streamingExpectation = [self
      expectationWithDescription:@"Must not receive more than MaxStreamingPendingFramesCount"];

  id handlerMock = OCMClassMock([FLTImageStreamHandler class]);
  OCMStub([handlerMock alloc]).andReturn(handlerMock);
  OCMStub([handlerMock initWithCaptureSessionQueue:[OCMArg any]]).andReturn(handlerMock);
  OCMStub([handlerMock eventSink]).andReturn(^(id event) {
    [streamingExpectation fulfill];
  });

  id messenger = OCMProtocolMock(@protocol(FlutterBinaryMessenger));
  [_camera startImageStreamWithMessenger:messenger];

  streamingExpectation.expectedFulfillmentCount = 4;
  for (int i = 0; i < 10; i++) {
    [_camera captureOutput:nil didOutputSampleBuffer:[self sampleBuffer] fromConnection:nil];
  }

  [self waitForExpectationsWithTimeout:3.0 handler:nil];
}

- (void)testReceivedImageStreamData {
  XCTestExpectation *streamingExpectation =
      [self expectationWithDescription:
                @"Must be able to receive again when receivedImageStreamData is called"];

  id handlerMock = OCMClassMock([FLTImageStreamHandler class]);
  OCMStub([handlerMock alloc]).andReturn(handlerMock);
  OCMStub([handlerMock initWithCaptureSessionQueue:[OCMArg any]]).andReturn(handlerMock);
  OCMStub([handlerMock eventSink]).andReturn(^(id event) {
    [streamingExpectation fulfill];
  });

  id messenger = OCMProtocolMock(@protocol(FlutterBinaryMessenger));
  [_camera startImageStreamWithMessenger:messenger];

  streamingExpectation.expectedFulfillmentCount = 5;
  for (int i = 0; i < 10; i++) {
    [_camera captureOutput:nil didOutputSampleBuffer:[self sampleBuffer] fromConnection:nil];
  }

  [_camera receivedImageStreamData];
  [_camera captureOutput:nil didOutputSampleBuffer:[self sampleBuffer] fromConnection:nil];

  [self waitForExpectationsWithTimeout:3.0 handler:nil];
}

@end
