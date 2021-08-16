// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera;
@import XCTest;
@import AVFoundation;
#import <OCMock/OCMock.h>

@interface FLTThreadSafeFlutterResult ()
@property(readonly, nonatomic) FlutterResult flutterResult;
@end

@interface MockFLTThreadSafeFlutterResult : FLTThreadSafeFlutterResult
@property(readonly, nonatomic) NSNotificationCenter *notificationCenter;
@property(nonatomic, nullable) id receivedResult;
@end

@implementation MockFLTThreadSafeFlutterResult
/**
 * Initializes with a notification center.
 */
- (id)initWithNotificationCenter:(NSNotificationCenter *)notificationCenter {
  self = [super init];
  _notificationCenter = notificationCenter;
  return self;
}

/**
 * Called when result is successful. Sends "successWithData" to the notification center.
 */
- (void)sendSuccessWithData:(id)data {
  _receivedResult = data;
  [self->_notificationCenter postNotificationName:@"successWithData" object:nil];
}
@end

@interface CameraPlugin (Test)
- (void)handleMethodCallWithThreadSafeResult:(FlutterMethodCall *)call
                                      result:(FLTThreadSafeFlutterResult *)result;
@end

@interface CameraMethodChannelTests : XCTestCase
@property(readonly, nonatomic) CameraPlugin *camera;
@property(readonly, nonatomic) MockFLTThreadSafeFlutterResult *resultObject;
@property(readonly, nonatomic) NSNotificationCenter *notificationCenter;
@end

@implementation CameraMethodChannelTests

- (void)setUp {
  _camera = [[CameraPlugin alloc] init];
  _notificationCenter = [[NSNotificationCenter alloc] init];

  // Set up mocks for initWithCameraName method
  id avCaptureDeviceInputMock = OCMClassMock([AVCaptureDeviceInput class]);
  OCMStub([avCaptureDeviceInputMock deviceInputWithDevice:[OCMArg any] error:[OCMArg anyObjectRef]])
      .andReturn([AVCaptureInput alloc]);

  id avCaptureSessionMock = OCMClassMock([AVCaptureSession class]);
  OCMStub([avCaptureSessionMock alloc]).andReturn(avCaptureSessionMock);
  OCMStub([avCaptureSessionMock canSetSessionPreset:[OCMArg any]]).andReturn(YES);

  _resultObject =
      [[MockFLTThreadSafeFlutterResult alloc] initWithNotificationCenter:_notificationCenter];
}

- (void)testCreate_ShouldCallResultOnMainThread {
  // Set up method call
  XCTNSNotificationExpectation *notificationExpectation =
      [[XCTNSNotificationExpectation alloc] initWithName:@"successWithData"
                                                  object:nil
                                      notificationCenter:_notificationCenter];

  FlutterMethodCall *call = [FlutterMethodCall
      methodCallWithMethodName:@"create"
                     arguments:@{@"resolutionPreset" : @"medium", @"enableAudio" : @(1)}];

  [_camera handleMethodCallWithThreadSafeResult:call result:_resultObject];

  // Don't expect a result yet
  XCTAssertNil(_resultObject.receivedResult);

  [self waitForExpectations:[NSArray arrayWithObject:notificationExpectation] timeout:1];

  // Expect a result after waiting for thread to switch
  XCTAssertNotNil(_resultObject.receivedResult);

  // Verify the result
  NSDictionary *dictionaryResult = (NSDictionary *)_resultObject.receivedResult;
  XCTAssertNotNil(dictionaryResult);
  XCTAssert([[dictionaryResult allKeys] containsObject:@"cameraId"]);
}

@end
