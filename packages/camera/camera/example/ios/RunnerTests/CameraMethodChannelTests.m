// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera;
@import XCTest;
@import AVFoundation;
#import <OCMock/OCMock.h>

@interface FLTThreadSafeFlutterResult : NSObject
@property(readonly, nonatomic) FlutterResult flutterResult;
@end

@interface MockFLTThreadSafeFlutterResult : FLTThreadSafeFlutterResult
@property(nonatomic, copy, readonly) void (^resultCallback)(id result);
@end

@implementation MockFLTThreadSafeFlutterResult
- (id)initWithResultCallback:(void (^)(id))callback {
  self = [super init];
  _resultCallback = callback;
  return self;
}
- (void)send:(id)result {
  NSLog(@"getting result");
  _resultCallback(result);
}
@end

@interface CameraPlugin (Test)
- (void)handleMethodCallWithThreadSafeResult:(FlutterMethodCall *)call
                                      result:(FLTThreadSafeFlutterResult *)result;
@end

@interface CameraMethodChannelTests : XCTestCase
@property(readonly, nonatomic) CameraPlugin *camera;
@property(readonly, nonatomic) NSNotificationCenter *notificationCenter;
@end

@implementation CameraMethodChannelTests

- (void)setUp {
  _camera = [[CameraPlugin alloc] init];
  _notificationCenter = [[NSNotificationCenter alloc] init];
}

- (void)tearDown {
  // Put teardown code here. This method is called after the invocation of each test method in the
  // class.
}

- (void)testCreate_ShouldCallResultOnMainThread {
  // Setup mocks for initWithCameraName method
  id avCaptureDeviceInputMock = OCMClassMock([AVCaptureDeviceInput class]);
  OCMStub([avCaptureDeviceInputMock deviceInputWithDevice:[OCMArg any] error:[OCMArg anyObjectRef]])
      .andReturn([AVCaptureInput alloc]);

  id avCaptureSessionMock = OCMClassMock([AVCaptureSession class]);
  OCMStub([avCaptureSessionMock alloc]).andReturn(avCaptureSessionMock);
  OCMStub([avCaptureSessionMock canSetSessionPreset:[OCMArg any]]).andReturn(YES);

  // Setup method call
  NSString *notificationName = @"resultNotification";
  XCTNSNotificationExpectation *notificationExpectation =
      [[XCTNSNotificationExpectation alloc] initWithName:notificationName
                                                  object:nil
                                      notificationCenter:_notificationCenter];

  FlutterMethodCall *call = [FlutterMethodCall
      methodCallWithMethodName:@"create"
                     arguments:@{@"resolutionPreset" : @"medium", @"enableAudio" : @(1)}];
  __block id result = nil;
  MockFLTThreadSafeFlutterResult *resultObject =
      [[MockFLTThreadSafeFlutterResult alloc] initWithResultCallback:^(id actualResult) {
        result = actualResult;
        [self->_notificationCenter postNotificationName:notificationName object:nil];
      }];

  // Call handleMethodCall
  [_camera handleMethodCallWithThreadSafeResult:call result:resultObject];

  // Don't expect a result yet
  XCTAssertNil(result);

  [self waitForExpectations:[NSArray arrayWithObject:notificationExpectation] timeout:1];

  // Expect a result after waiting for thread to switch
  XCTAssertNotNil(result);

  // Verify the result
  NSDictionary *dictionaryResult = (NSDictionary *)result;
  XCTAssertNotNil(dictionaryResult);
  XCTAssert([[dictionaryResult allKeys] containsObject:@"cameraId"]);
}

@end
