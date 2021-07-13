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

@interface CameraMethodChannelTests : XCTestCase
@property(readonly, nonatomic) CameraPlugin *camera;
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

@implementation CameraMethodChannelTests

- (void)setUp {
  _camera = [[CameraPlugin alloc] init];
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
  dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

  FlutterMethodCall *call = [FlutterMethodCall
      methodCallWithMethodName:@"create"
                     arguments:@{@"resolutionPreset" : @"medium", @"enableAudio" : @(1)}];
  __block id result = nil;
  MockFLTThreadSafeFlutterResult *resultObject =
      [[MockFLTThreadSafeFlutterResult alloc] initWithResultCallback:^(id actualResult) {
        result = actualResult;
        dispatch_semaphore_signal(semaphore);
      }];

  // Call handleMethodCall
  [_camera handleMethodCallWithThreadSafeResult:call result:resultObject];

  // Don't expect a result yet
  XCTAssertNil(result);

  while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                             beforeDate:[NSDate dateWithTimeIntervalSinceNow:0]];
  }
  // Expect a result after waiting for thread to switch
  XCTAssertNotNil(result);

  // Verify the result
  NSDictionary *dictionaryResult = (NSDictionary *)result;
  XCTAssertNotNil(dictionaryResult);
  XCTAssert([[dictionaryResult allKeys] containsObject:@"cameraId"]);
}

@end
