// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera;
@import XCTest;
@import AVFoundation;
#import <OCMock/OCMock.h>
#import "MockFLTThreadSafeFlutterResult.h"

@interface CameraPlugin (Test)
- (void)handleMethodCallAsync:(FlutterMethodCall *)call
                                      result:(FLTThreadSafeFlutterResult *)result;
@end

@interface CameraMethodChannelTests : XCTestCase
@property(readonly, nonatomic) CameraPlugin *camera;
@property(readonly, nonatomic) MockFLTThreadSafeFlutterResult *resultObject;
@end

@implementation CameraMethodChannelTests

- (void)setUp {
  _camera = [[CameraPlugin alloc] init];
  XCTestExpectation *expectation =
      [[XCTestExpectation alloc] initWithDescription:@"Result finished"];

  // Set up mocks for initWithCameraName method
  id avCaptureDeviceInputMock = OCMClassMock([AVCaptureDeviceInput class]);
  OCMStub([avCaptureDeviceInputMock deviceInputWithDevice:[OCMArg any] error:[OCMArg anyObjectRef]])
      .andReturn([AVCaptureInput alloc]);

  id avCaptureSessionMock = OCMClassMock([AVCaptureSession class]);
  OCMStub([avCaptureSessionMock alloc]).andReturn(avCaptureSessionMock);
  OCMStub([avCaptureSessionMock canSetSessionPreset:[OCMArg any]]).andReturn(YES);

  _resultObject = [[MockFLTThreadSafeFlutterResult alloc] initWithExpectation:expectation];
}

- (void)testCreate_ShouldCallResultOnMainThread {
  // Set up method call
  FlutterMethodCall *call = [FlutterMethodCall
      methodCallWithMethodName:@"create"
                     arguments:@{@"resolutionPreset" : @"medium", @"enableAudio" : @(1)}];

  
  [self->_camera handleMethodCallAsync:call result:self->_resultObject];

  // Verify the result
  NSDictionary *dictionaryResult = (NSDictionary *)_resultObject.receivedResult;
  XCTAssertNotNil(dictionaryResult);
  XCTAssert([[dictionaryResult allKeys] containsObject:@"cameraId"]);
}

@end
