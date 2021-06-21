// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ImagePickerTestImages.h"

@import image_picker;
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

@interface FLTImagePickerPlugin (Test)
@property(copy, nonatomic) FlutterResult result;
- (void)handleSavedPath:(NSString *)path;
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
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

- (void)tearDown {
  // Put teardown code here. This method is called after the invocation of each test method in the
  // class.
}

- (void)testPluginPickImageDeviceBack {
  // UIImagePickerControllerSourceTypeCamera is supported
  OCMStub(ClassMethod(
              [_mockUIImagePicker isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]))
      .andReturn(true);

  // UIImagePickerControllerCameraDeviceRear is supported
  OCMStub(ClassMethod(
              [_mockUIImagePicker isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]))
      .andReturn(true);

  // AVAuthorizationStatusAuthorized is supported
  OCMStub([_mockAVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]).andReturn(3);

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
      .andReturn(true);

  // UIImagePickerControllerCameraDeviceFront is supported
  OCMStub(ClassMethod([_mockUIImagePicker
              isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]))
      .andReturn(true);

  // AVAuthorizationStatusAuthorized is supported
  OCMStub([_mockAVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]).andReturn(3);

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
      .andReturn(true);

  // UIImagePickerControllerCameraDeviceRear is supported
  OCMStub(ClassMethod(
              [_mockUIImagePicker isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]))
      .andReturn(true);

  // AVAuthorizationStatusAuthorized is supported
  OCMStub([_mockAVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]).andReturn(3);

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
      .andReturn(true);

  // UIImagePickerControllerCameraDeviceFront is supported
  OCMStub(ClassMethod([_mockUIImagePicker
              isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]))
      .andReturn(true);

  // AVAuthorizationStatusAuthorized is supported
  OCMStub([_mockAVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]).andReturn(3);

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

- (void)testPluginPickImageSelectMultipleTimes {
  FLTImagePickerPlugin *plugin = [FLTImagePickerPlugin new];
  FlutterMethodCall *call =
      [FlutterMethodCall methodCallWithMethodName:@"pickImage"
                                        arguments:@{@"source" : @(0), @"cameraDevice" : @(0)}];
  [plugin handleMethodCall:call
                    result:^(id _Nullable r){
                    }];
  plugin.result = ^(id result) {

  };
  [plugin handleSavedPath:@"test"];
  [plugin handleSavedPath:@"test"];
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

@end
