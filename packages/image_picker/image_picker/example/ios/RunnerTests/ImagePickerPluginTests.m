// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ImagePickerTestImages.h"

@import image_picker;
@import image_picker.Test;
@import XCTest;
#import <OCMock/OCMock.h>

@interface MockViewController : UIViewController
@property(nonatomic, retain) UIViewController *mockPresented;
@end

@implementation MockViewController
@synthesize mockPresented;

- (UIViewController *)presentedViewController {
  return mockPresented;
}

@end

@interface ImagePickerPluginTests : XCTestCase
@property(readonly, nonatomic) id mockUIImagePicker;
@property(readonly, nonatomic) id mockAVCaptureDevice;
@end

@implementation ImagePickerPluginTests

- (void)setUp {
  _mockUIImagePicker = OCMClassMock([UIImagePickerController class]);
  _mockAVCaptureDevice = OCMClassMock([AVCaptureDevice class]);
}

- (void)testPluginPickImageDeviceBack {
  // UIImagePickerControllerSourceTypeCamera is supported
  OCMStub(ClassMethod(
              [_mockUIImagePicker isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]))
      .andReturn(YES);

  // UIImagePickerControllerCameraDeviceRear is supported
  OCMStub(ClassMethod(
              [_mockUIImagePicker isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]))
      .andReturn(YES);

  // AVAuthorizationStatusAuthorized is supported
  OCMStub([_mockAVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo])
      .andReturn(AVAuthorizationStatusAuthorized);

  // Run test
  FLTImagePickerPlugin *plugin = [FLTImagePickerPlugin new];
  FlutterMethodCall *call =
      [FlutterMethodCall methodCallWithMethodName:@"pickImage"
                                        arguments:@{@"source" : @(0), @"cameraDevice" : @(0)}];
  [plugin handleMethodCall:call
                    result:^(id _Nullable r){
                    }];

  XCTAssertEqual([plugin getImagePickerController].cameraDevice,
                 UIImagePickerControllerCameraDeviceRear);
}

- (void)testPluginPickImageDeviceFront {
  // UIImagePickerControllerSourceTypeCamera is supported
  OCMStub(ClassMethod(
              [_mockUIImagePicker isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]))
      .andReturn(YES);

  // UIImagePickerControllerCameraDeviceFront is supported
  OCMStub(ClassMethod([_mockUIImagePicker
              isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]))
      .andReturn(YES);

  // AVAuthorizationStatusAuthorized is supported
  OCMStub([_mockAVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo])
      .andReturn(AVAuthorizationStatusAuthorized);

  // Run test
  FLTImagePickerPlugin *plugin = [FLTImagePickerPlugin new];
  FlutterMethodCall *call =
      [FlutterMethodCall methodCallWithMethodName:@"pickImage"
                                        arguments:@{@"source" : @(0), @"cameraDevice" : @(1)}];
  [plugin handleMethodCall:call
                    result:^(id _Nullable r){
                    }];

  XCTAssertEqual([plugin getImagePickerController].cameraDevice,
                 UIImagePickerControllerCameraDeviceFront);
}

- (void)testPluginPickVideoDeviceBack {
  // UIImagePickerControllerSourceTypeCamera is supported
  OCMStub(ClassMethod(
              [_mockUIImagePicker isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]))
      .andReturn(YES);

  // UIImagePickerControllerCameraDeviceRear is supported
  OCMStub(ClassMethod(
              [_mockUIImagePicker isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]))
      .andReturn(YES);

  // AVAuthorizationStatusAuthorized is supported
  OCMStub([_mockAVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo])
      .andReturn(AVAuthorizationStatusAuthorized);

  // Run test
  FLTImagePickerPlugin *plugin = [FLTImagePickerPlugin new];
  FlutterMethodCall *call =
      [FlutterMethodCall methodCallWithMethodName:@"pickVideo"
                                        arguments:@{@"source" : @(0), @"cameraDevice" : @(0)}];
  [plugin handleMethodCall:call
                    result:^(id _Nullable r){
                    }];

  XCTAssertEqual([plugin getImagePickerController].cameraDevice,
                 UIImagePickerControllerCameraDeviceRear);
}

- (void)testPluginPickVideoDeviceFront {
  // UIImagePickerControllerSourceTypeCamera is supported
  OCMStub(ClassMethod(
              [_mockUIImagePicker isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]))
      .andReturn(YES);

  // UIImagePickerControllerCameraDeviceFront is supported
  OCMStub(ClassMethod([_mockUIImagePicker
              isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]))
      .andReturn(YES);

  // AVAuthorizationStatusAuthorized is supported
  OCMStub([_mockAVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo])
      .andReturn(AVAuthorizationStatusAuthorized);

  // Run test
  FLTImagePickerPlugin *plugin = [FLTImagePickerPlugin new];
  FlutterMethodCall *call =
      [FlutterMethodCall methodCallWithMethodName:@"pickVideo"
                                        arguments:@{@"source" : @(0), @"cameraDevice" : @(1)}];
  [plugin handleMethodCall:call
                    result:^(id _Nullable r){
                    }];

  XCTAssertEqual([plugin getImagePickerController].cameraDevice,
                 UIImagePickerControllerCameraDeviceFront);
}

#pragma mark - Test camera devices, no op on simulators

- (void)testPluginPickImageDeviceCancelClickMultipleTimes {
  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    return;
  }
  FLTImagePickerPlugin *plugin = [FLTImagePickerPlugin new];
  FlutterMethodCall *call =
      [FlutterMethodCall methodCallWithMethodName:@"pickImage"
                                        arguments:@{@"source" : @(0), @"cameraDevice" : @(1)}];
  [plugin handleMethodCall:call
                    result:^(id _Nullable r){
                    }];
  plugin.result = ^(id result) {

  };
  // To ensure the flow does not crash by multiple cancel call
  [plugin imagePickerControllerDidCancel:[plugin getImagePickerController]];
  [plugin imagePickerControllerDidCancel:[plugin getImagePickerController]];
}

#pragma mark - Test video duration

- (void)testPickingVideoWithDuration {
  FLTImagePickerPlugin *plugin = [FLTImagePickerPlugin new];
  FlutterMethodCall *call = [FlutterMethodCall
      methodCallWithMethodName:@"pickVideo"
                     arguments:@{@"source" : @(0), @"cameraDevice" : @(0), @"maxDuration" : @95}];
  [plugin handleMethodCall:call
                    result:^(id _Nullable r){
                    }];
  XCTAssertEqual([plugin getImagePickerController].videoMaximumDuration, 95);
}

- (void)testViewController {
  UIWindow *window = [UIWindow new];
  MockViewController *vc1 = [MockViewController new];
  window.rootViewController = vc1;

  UIViewController *vc2 = [UIViewController new];
  vc1.mockPresented = vc2;

  FLTImagePickerPlugin *plugin = [FLTImagePickerPlugin new];
  XCTAssertEqual([plugin viewControllerWithWindow:window], vc2);
}

- (void)testPluginMultiImagePathIsNil {
  FLTImagePickerPlugin *plugin = [FLTImagePickerPlugin new];

  dispatch_semaphore_t resultSemaphore = dispatch_semaphore_create(0);
  __block FlutterError *pickImageResult = nil;

  plugin.result = ^(id _Nullable r) {
    pickImageResult = r;
    dispatch_semaphore_signal(resultSemaphore);
  };
  [plugin handleSavedPathList:nil];

  dispatch_semaphore_wait(resultSemaphore, DISPATCH_TIME_FOREVER);

  XCTAssertEqualObjects(pickImageResult.code, @"create_error");
}

- (void)testPluginMultiImagePathHasNullItem {
  FLTImagePickerPlugin *plugin = [FLTImagePickerPlugin new];
  NSMutableArray *pathList = [NSMutableArray new];

  [pathList addObject:[NSNull null]];

  dispatch_semaphore_t resultSemaphore = dispatch_semaphore_create(0);
  __block FlutterError *pickImageResult = nil;

  plugin.result = ^(id _Nullable r) {
    pickImageResult = r;
    dispatch_semaphore_signal(resultSemaphore);
  };
  [plugin handleSavedPathList:pathList];

  dispatch_semaphore_wait(resultSemaphore, DISPATCH_TIME_FOREVER);

  XCTAssertEqualObjects(pickImageResult.code, @"create_error");
}

- (void)testPluginMultiImagePathHasItem {
  FLTImagePickerPlugin *plugin = [FLTImagePickerPlugin new];
  NSString *savedPath = @"test";
  NSMutableArray *pathList = [NSMutableArray new];

  [pathList addObject:savedPath];

  dispatch_semaphore_t resultSemaphore = dispatch_semaphore_create(0);
  __block id pickImageResult = nil;

  plugin.result = ^(id _Nullable r) {
    pickImageResult = r;
    dispatch_semaphore_signal(resultSemaphore);
  };
  [plugin handleSavedPathList:pathList];

  dispatch_semaphore_wait(resultSemaphore, DISPATCH_TIME_FOREVER);

  XCTAssertEqual(pickImageResult, pathList);
}

@end
