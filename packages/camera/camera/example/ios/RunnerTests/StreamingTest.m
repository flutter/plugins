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
@property FlutterEventSink eventSink;
@end

@interface FLTCam : NSObject <FlutterTexture,
                              AVCaptureVideoDataOutputSampleBufferDelegate,
                              AVCaptureAudioDataOutputSampleBufferDelegate>
@property(assign, nonatomic) int streamingPendingFrames;
@property(assign, nonatomic) int maxStreamingPendingFrames;
@property(assign, nonatomic) BOOL isStreamingImages;
@property(nonatomic) FLTImageStreamHandler *imageStreamHandler;
- (void)captureOutput:(AVCaptureOutput *)output
    didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
           fromConnection:(AVCaptureConnection *)connection;
@end

@interface CameraPlugin (Private)
@property(retain, nonatomic) FLTCam *camera;
@end

@interface StreamingTests : XCTestCase
@end

@implementation StreamingTests

- (void)testStreamingPendingFrames {
  CameraPlugin *camera = [[CameraPlugin alloc] initWithRegistry:nil messenger:nil];

  // Set up mocks for initWithCameraName method
  id avCaptureDeviceInputMock = OCMClassMock([AVCaptureDeviceInput class]);
  OCMStub([avCaptureDeviceInputMock deviceInputWithDevice:[OCMArg any] error:[OCMArg anyObjectRef]])
      .andReturn([AVCaptureInput alloc]);
  id avCaptureSessionMock = OCMClassMock([AVCaptureSession class]);
  OCMStub([avCaptureSessionMock alloc]).andReturn(avCaptureSessionMock);
  OCMStub([avCaptureSessionMock canSetSessionPreset:[OCMArg any]]).andReturn(YES);

  // Set up method calls
  FlutterMethodCall *createCall = [FlutterMethodCall
      methodCallWithMethodName:@"create"
                     arguments:@{@"resolutionPreset" : @"medium", @"enableAudio" : @(1)}];
  FlutterMethodCall *startCall = [FlutterMethodCall methodCallWithMethodName:@"startImageStream"
                                                                   arguments:nil];
  FlutterMethodCall *receivedCall =
      [FlutterMethodCall methodCallWithMethodName:@"receivedImageStreamData" arguments:nil];

  // Set up sampleBuffer
  CVPixelBufferRef pixelBuffer;
  CVPixelBufferCreate(kCFAllocatorDefault, 100, 100, kCVPixelFormatType_32BGRA, nil, &pixelBuffer);
  CMVideoFormatDescriptionRef formatDescription;
  CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer,
                                               &formatDescription);
  CMSampleBufferRef sampleBuffer;
  CMSampleBufferCreateReadyWithImageBuffer(kCFAllocatorDefault, pixelBuffer, formatDescription,
                                           &kCMTimingInfoInvalid, &sampleBuffer);

  // Start streaming
  [camera handleMethodCallAsync:createCall result:nil];
  [camera handleMethodCallAsync:startCall result:nil];
  camera.camera.imageStreamHandler.eventSink = ^(id _Nullable event) {
  };

  // Waiting for streaming to start
  FLTCam *cam = [camera camera];
  while (!cam.isStreamingImages) {
    [NSThread sleepForTimeInterval:0.001];
  }

  // Initial value
  XCTAssertEqual(cam.streamingPendingFrames, 0);

  // Emulate receiving a video frame
  [camera.camera captureOutput:nil didOutputSampleBuffer:sampleBuffer fromConnection:nil];
  XCTAssertEqual(cam.streamingPendingFrames, 1);

  // ReceivedCall reduces streamingPendingFrames
  [camera handleMethodCallAsync:receivedCall result:nil];
  XCTAssertEqual(cam.streamingPendingFrames, 0);

  // Don't exceed maxStreamingPendingFrames
  for (int i = 0; i < cam.maxStreamingPendingFrames + 2; i++) {
    [camera.camera captureOutput:nil didOutputSampleBuffer:sampleBuffer fromConnection:nil];
  }
  XCTAssertEqual(cam.streamingPendingFrames, cam.maxStreamingPendingFrames);
}

@end
