// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera;
@import camera.Test;
@import XCTest;
@import AVFoundation;
#import <OCMock/OCMock.h>
#import "MockFLTThreadSafeFlutterResult.h"

@interface AVCaptureDeviceMock : AVCaptureDevice

@end

@implementation AVCaptureDeviceMock {
  NSString *_mockId;
  AVCaptureDevicePosition _mockPosition;
}
- (AVCaptureDevicePosition)position {
  return _mockPosition;
}
- (NSString *)uniqueID {
  return _mockId;
}
- (id)initWithId:(NSString *)localId position:(AVCaptureDevicePosition)localPosition {
  _mockId = localId;
  _mockPosition = localPosition;
  return self;
}

@end

@interface AvailableCamerasTest : XCTestCase
@end

@implementation AvailableCamerasTest

- (void)testAvailableCamerasShouldReturnAllCamerasOnMultiCameraIPhone {
  CameraPlugin *camera = [[CameraPlugin alloc] initWithRegistry:nil messenger:nil];
  XCTestExpectation *expectation =
      [[XCTestExpectation alloc] initWithDescription:@"Result finished"];

  // iPhone 13 Cameras:
  id wideAngleCamera = [[AVCaptureDeviceMock alloc] initWithId:@"0"
                                                      position:AVCaptureDevicePositionBack];
  id frontFacingCamera = [[AVCaptureDeviceMock alloc] initWithId:@"1"
                                                        position:AVCaptureDevicePositionFront];
  id ultraWideCamera = [[AVCaptureDeviceMock alloc] initWithId:@"2"
                                                      position:AVCaptureDevicePositionBack];
  id telephotoCamera = [[AVCaptureDeviceMock alloc] initWithId:@"3"
                                                      position:AVCaptureDevicePositionBack];

  NSMutableArray *requiredTypes = [NSMutableArray array];
  [requiredTypes addObjectsFromArray:@[
    AVCaptureDeviceTypeBuiltInWideAngleCamera, AVCaptureDeviceTypeBuiltInTelephotoCamera
  ]];
  if (@available(iOS 13.0, *)) {
    [requiredTypes addObject:AVCaptureDeviceTypeBuiltInUltraWideCamera];
  }

  id discoverySessionMock = OCMClassMock([AVCaptureDeviceDiscoverySession class]);
  OCMStub([discoverySessionMock discoverySessionWithDeviceTypes:requiredTypes
                                                      mediaType:AVMediaTypeVideo
                                                       position:AVCaptureDevicePositionUnspecified])
      .andReturn(discoverySessionMock);

  NSMutableArray *cameras = [NSMutableArray array];
  [cameras addObjectsFromArray:@[ wideAngleCamera, frontFacingCamera, telephotoCamera ]];
  if (@available(iOS 13.0, *)) {
    [cameras addObject:ultraWideCamera];
  }
  OCMStub([discoverySessionMock devices]).andReturn([NSArray arrayWithArray:cameras]);

  MockFLTThreadSafeFlutterResult *resultObject =
      [[MockFLTThreadSafeFlutterResult alloc] initWithExpectation:expectation];

  // Set up method call
  FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"availableCameras"
                                                              arguments:nil];

  [camera handleMethodCallAsync:call result:resultObject];

  // Verify the result
  NSDictionary *dictionaryResult = (NSDictionary *)resultObject.receivedResult;
  if (@available(iOS 13.0, *)) {
    XCTAssertTrue([dictionaryResult count] == 4);
  } else {
    XCTAssertTrue([dictionaryResult count] == 3);
  }
}
- (void)testAvailableCamerasShouldReturnOneCameraOnSingleCameraIPhone {
  CameraPlugin *camera = [[CameraPlugin alloc] initWithRegistry:nil messenger:nil];
  XCTestExpectation *expectation =
      [[XCTestExpectation alloc] initWithDescription:@"Result finished"];

  // iPhone 8 Cameras:
  id wideAngleCamera = [[AVCaptureDeviceMock alloc] initWithId:@"0"
                                                      position:AVCaptureDevicePositionBack];
  id frontFacingCamera = [[AVCaptureDeviceMock alloc] initWithId:@"1"
                                                        position:AVCaptureDevicePositionFront];

  NSMutableArray *requiredTypes = [NSMutableArray array];
  [requiredTypes addObjectsFromArray:@[
    AVCaptureDeviceTypeBuiltInWideAngleCamera, AVCaptureDeviceTypeBuiltInTelephotoCamera
  ]];
  if (@available(iOS 13.0, *)) {
    [requiredTypes addObject:AVCaptureDeviceTypeBuiltInUltraWideCamera];
  }

  id discoverySessionMock = OCMClassMock([AVCaptureDeviceDiscoverySession class]);
  OCMStub([discoverySessionMock discoverySessionWithDeviceTypes:requiredTypes
                                                      mediaType:AVMediaTypeVideo
                                                       position:AVCaptureDevicePositionUnspecified])
      .andReturn(discoverySessionMock);

  NSMutableArray *cameras = [NSMutableArray array];
  [cameras addObjectsFromArray:@[ wideAngleCamera, frontFacingCamera ]];
  OCMStub([discoverySessionMock devices]).andReturn([NSArray arrayWithArray:cameras]);

  MockFLTThreadSafeFlutterResult *resultObject =
      [[MockFLTThreadSafeFlutterResult alloc] initWithExpectation:expectation];

  // Set up method call
  FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"availableCameras"
                                                              arguments:nil];

  [camera handleMethodCallAsync:call result:resultObject];

  // Verify the result
  NSDictionary *dictionaryResult = (NSDictionary *)resultObject.receivedResult;
  XCTAssertTrue([dictionaryResult count] == 2);
}

@end
