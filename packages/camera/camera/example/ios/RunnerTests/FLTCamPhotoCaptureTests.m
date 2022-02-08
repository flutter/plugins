// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera;
@import camera.Test;
@import AVFoundation;
@import XCTest;
#import <OCMock/OCMock.h>

@interface FLTCamPhotoCaptureTests : XCTestCase

@end

@implementation FLTCamPhotoCaptureTests

- (void)testCaptureToFile_savePhotoDelegateReferencesMustBeAccessedOnCaptureSessionQueue {
  XCTestExpectation *setReferenceExpectation =
      [self expectationWithDescription:
                @"FLTSavePhotoDelegate references must be set on capture session queue."];
  XCTestExpectation *clearReferenceExpectation =
      [self expectationWithDescription:
                @"FLTSavePhotoDelegate references must be cleared on capture session queue."];

  dispatch_queue_t captureSessionQueue = dispatch_queue_create("capture_session_queue", NULL);
  const char *captureSessionQueueSpecific = "capture_session_queue";
  dispatch_queue_set_specific(captureSessionQueue, captureSessionQueueSpecific,
                              (void *)captureSessionQueueSpecific, NULL);
  FLTCam *cam = [self createFLTCamWithCaptureSessionQueue:captureSessionQueue];

  // settings.uniqueID is used as the key for `inProgressSavePhotoDelegates` dictionary
  AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettings];
  id mockSettings = OCMClassMock([AVCapturePhotoSettings class]);
  OCMStub([mockSettings photoSettings]).andReturn(settings);

  // We need to make sure the delegate reference is actually saved in a real dictionary, so that we
  // can call its completion handler later. Must use a partial mock, in order to forward invocation
  // to the real object.
  id mockDelegates = OCMPartialMock([NSMutableDictionary dictionary]);
  OCMStub([mockDelegates setObject:OCMOCK_ANY forKeyedSubscript:OCMOCK_ANY])
      .andDo(^(NSInvocation *invocation) {
        if (dispatch_get_specific(captureSessionQueueSpecific)) {
          FLTSavePhotoDelegate *delegate;
          // Index 0 and 1 are `self` and `_cmd`.
          [invocation getArgument:&delegate atIndex:2];
          if (delegate) {
            [setReferenceExpectation fulfill];
          } else {
            [clearReferenceExpectation fulfill];
          }
        }
      })
      .andForwardToRealObject();
  cam.inProgressSavePhotoDelegates = mockDelegates;

  id mockOutput = OCMClassMock([AVCapturePhotoOutput class]);
  OCMStub([mockOutput capturePhotoWithSettings:OCMOCK_ANY delegate:OCMOCK_ANY])
      .andDo(^(NSInvocation *invocation) {
        FLTSavePhotoDelegate *delegate = cam.inProgressSavePhotoDelegates[@(settings.uniqueID)];
        XCTAssertNotNil(delegate, @"Delegate reference must be saved to the dictionary.");
        // Completion runs on IO queue.
        dispatch_queue_t ioQueue = dispatch_queue_create("io_queue", NULL);
        dispatch_async(ioQueue, ^{
          NSString *filePath = @"test";
          delegate.completionHandler(nil, filePath);
        });
      });
  cam.capturePhotoOutput = mockOutput;

  // `FLTCam::captureToFile` runs on capture session queue.
  dispatch_async(captureSessionQueue, ^{
    [cam captureToFile:OCMClassMock([FLTThreadSafeFlutterResult class])];
  });

  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testCaptureToFile_mustReportErrorToResultIfSavePhotoDelegateCompletionsWithError {
  XCTestExpectation *errorExpectation =
      [self expectationWithDescription:
                @"Must send error to result if save photo delegate completes with error."];

  dispatch_queue_t captureSessionQueue = dispatch_queue_create("capture_session_queue", NULL);
  FLTCam *cam = [self createFLTCamWithCaptureSessionQueue:captureSessionQueue];

  AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettings];
  id mockSettings = OCMClassMock([AVCapturePhotoSettings class]);
  OCMStub([mockSettings photoSettings]).andReturn(settings);

  NSError *error = [NSError errorWithDomain:@"test" code:0 userInfo:nil];
  id mockResult = OCMClassMock([FLTThreadSafeFlutterResult class]);
  OCMStub([mockResult sendError:error]).andDo(^(NSInvocation *invocation) {
    [errorExpectation fulfill];
  });

  id mockOutput = OCMClassMock([AVCapturePhotoOutput class]);
  OCMStub([mockOutput capturePhotoWithSettings:OCMOCK_ANY delegate:OCMOCK_ANY])
      .andDo(^(NSInvocation *invocation) {
        FLTSavePhotoDelegate *delegate = cam.inProgressSavePhotoDelegates[@(settings.uniqueID)];
        // Completion runs on IO queue.
        dispatch_queue_t ioQueue = dispatch_queue_create("io_queue", NULL);
        dispatch_async(ioQueue, ^{
          delegate.completionHandler(error, nil);
        });
      });
  cam.capturePhotoOutput = mockOutput;

  // `FLTCam::captureToFile` runs on capture session queue.
  dispatch_async(captureSessionQueue, ^{
    [cam captureToFile:mockResult];
  });

  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testCaptureToFile_mustReportPathToResultIfSavePhotoDelegateCompletionsWithPath {
  XCTestExpectation *pathExpectation =
      [self expectationWithDescription:
                @"Must send file path to result if save photo delegate completes with file path."];

  dispatch_queue_t captureSessionQueue = dispatch_queue_create("capture_session_queue", NULL);
  FLTCam *cam = [self createFLTCamWithCaptureSessionQueue:captureSessionQueue];

  AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettings];
  id mockSettings = OCMClassMock([AVCapturePhotoSettings class]);
  OCMStub([mockSettings photoSettings]).andReturn(settings);

  NSString *filePath = @"test";
  id mockResult = OCMClassMock([FLTThreadSafeFlutterResult class]);
  OCMStub([mockResult sendSuccessWithData:filePath]).andDo(^(NSInvocation *invocation) {
    [pathExpectation fulfill];
  });

  id mockOutput = OCMClassMock([AVCapturePhotoOutput class]);
  OCMStub([mockOutput capturePhotoWithSettings:OCMOCK_ANY delegate:OCMOCK_ANY])
      .andDo(^(NSInvocation *invocation) {
        FLTSavePhotoDelegate *delegate = cam.inProgressSavePhotoDelegates[@(settings.uniqueID)];
        // Completion runs on IO queue.
        dispatch_queue_t ioQueue = dispatch_queue_create("io_queue", NULL);
        dispatch_async(ioQueue, ^{
          delegate.completionHandler(nil, filePath);
        });
      });
  cam.capturePhotoOutput = mockOutput;

  // `FLTCam::captureToFile` runs on capture session queue.
  dispatch_async(captureSessionQueue, ^{
    [cam captureToFile:mockResult];
  });
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

/// Creates an `FLTCam` that runs its operations on a given capture session queue.
- (FLTCam *)createFLTCamWithCaptureSessionQueue:(dispatch_queue_t)captureSessionQueue {
  id inputMock = OCMClassMock([AVCaptureDeviceInput class]);
  OCMStub([inputMock deviceInputWithDevice:[OCMArg any] error:[OCMArg setTo:nil]])
      .andReturn(inputMock);

  id sessionMock = OCMClassMock([AVCaptureSession class]);
  OCMStub([sessionMock alloc]).andReturn(sessionMock);
  OCMStub([sessionMock addInputWithNoConnections:[OCMArg any]]);  // no-op
  OCMStub([sessionMock canSetSessionPreset:[OCMArg any]]).andReturn(YES);

  return [[FLTCam alloc] initWithCameraName:@"camera"
                           resolutionPreset:@"medium"
                                enableAudio:true
                                orientation:UIDeviceOrientationPortrait
                        captureSessionQueue:captureSessionQueue
                                      error:nil];
}

@end
