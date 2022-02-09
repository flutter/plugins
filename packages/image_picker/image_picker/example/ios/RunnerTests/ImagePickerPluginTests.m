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

@end

@implementation ImagePickerPluginTests

- (void)testPluginPickImageDeviceBack {
  id mockUIImagePicker = OCMClassMock([UIImagePickerController class]);
  id mockAVCaptureDevice = OCMClassMock([AVCaptureDevice class]);
  // UIImagePickerControllerSourceTypeCamera is supported
  OCMStub(ClassMethod(
              [mockUIImagePicker isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]))
      .andReturn(YES);

  // UIImagePickerControllerCameraDeviceRear is supported
  OCMStub(ClassMethod(
              [mockUIImagePicker isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]))
      .andReturn(YES);

  // AVAuthorizationStatusAuthorized is supported
  OCMStub([mockAVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo])
      .andReturn(AVAuthorizationStatusAuthorized);

  // Run test
  FLTImagePickerPlugin *plugin = [FLTImagePickerPlugin new];
  FlutterMethodCall *call =
      [FlutterMethodCall methodCallWithMethodName:@"pickImage"
                                        arguments:@{@"source" : @(0), @"cameraDevice" : @(0)}];
  UIImagePickerController *controller = [[UIImagePickerController alloc] init];
  [plugin setImagePickerControllerOverrides:@[ controller ]];
  [plugin handleMethodCall:call
                    result:^(id _Nullable r){
                    }];

  XCTAssertEqual(controller.cameraDevice, UIImagePickerControllerCameraDeviceRear);
}

- (void)testPluginPickImageDeviceFront {
  id mockUIImagePicker = OCMClassMock([UIImagePickerController class]);
  id mockAVCaptureDevice = OCMClassMock([AVCaptureDevice class]);
  // UIImagePickerControllerSourceTypeCamera is supported
  OCMStub(ClassMethod(
              [mockUIImagePicker isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]))
      .andReturn(YES);

  // UIImagePickerControllerCameraDeviceFront is supported
  OCMStub(ClassMethod(
              [mockUIImagePicker isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]))
      .andReturn(YES);

  // AVAuthorizationStatusAuthorized is supported
  OCMStub([mockAVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo])
      .andReturn(AVAuthorizationStatusAuthorized);

  // Run test
  FLTImagePickerPlugin *plugin = [FLTImagePickerPlugin new];
  FlutterMethodCall *call =
      [FlutterMethodCall methodCallWithMethodName:@"pickImage"
                                        arguments:@{@"source" : @(0), @"cameraDevice" : @(1)}];
  UIImagePickerController *controller = [[UIImagePickerController alloc] init];
  [plugin setImagePickerControllerOverrides:@[ controller ]];
  [plugin handleMethodCall:call
                    result:^(id _Nullable r){
                    }];

  XCTAssertEqual(controller.cameraDevice, UIImagePickerControllerCameraDeviceFront);
}

- (void)testPluginPickVideoDeviceBack {
  id mockUIImagePicker = OCMClassMock([UIImagePickerController class]);
  id mockAVCaptureDevice = OCMClassMock([AVCaptureDevice class]);
  // UIImagePickerControllerSourceTypeCamera is supported
  OCMStub(ClassMethod(
              [mockUIImagePicker isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]))
      .andReturn(YES);

  // UIImagePickerControllerCameraDeviceRear is supported
  OCMStub(ClassMethod(
              [mockUIImagePicker isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]))
      .andReturn(YES);

  // AVAuthorizationStatusAuthorized is supported
  OCMStub([mockAVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo])
      .andReturn(AVAuthorizationStatusAuthorized);

  // Run test
  FLTImagePickerPlugin *plugin = [FLTImagePickerPlugin new];
  FlutterMethodCall *call =
      [FlutterMethodCall methodCallWithMethodName:@"pickVideo"
                                        arguments:@{@"source" : @(0), @"cameraDevice" : @(0)}];
  UIImagePickerController *controller = [[UIImagePickerController alloc] init];
  [plugin setImagePickerControllerOverrides:@[ controller ]];
  [plugin handleMethodCall:call
                    result:^(id _Nullable r){
                    }];

  XCTAssertEqual(controller.cameraDevice, UIImagePickerControllerCameraDeviceRear);
}

- (void)testPluginPickVideoDeviceFront {
  id mockUIImagePicker = OCMClassMock([UIImagePickerController class]);
  id mockAVCaptureDevice = OCMClassMock([AVCaptureDevice class]);

  // UIImagePickerControllerSourceTypeCamera is supported
  OCMStub(ClassMethod(
              [mockUIImagePicker isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]))
      .andReturn(YES);

  // UIImagePickerControllerCameraDeviceFront is supported
  OCMStub(ClassMethod(
              [mockUIImagePicker isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]))
      .andReturn(YES);

  // AVAuthorizationStatusAuthorized is supported
  OCMStub([mockAVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo])
      .andReturn(AVAuthorizationStatusAuthorized);

  // Run test
  FLTImagePickerPlugin *plugin = [FLTImagePickerPlugin new];
  FlutterMethodCall *call =
      [FlutterMethodCall methodCallWithMethodName:@"pickVideo"
                                        arguments:@{@"source" : @(0), @"cameraDevice" : @(1)}];
  UIImagePickerController *controller = [[UIImagePickerController alloc] init];
  [plugin setImagePickerControllerOverrides:@[ controller ]];
  [plugin handleMethodCall:call
                    result:^(id _Nullable r){
                    }];

  XCTAssertEqual(controller.cameraDevice, UIImagePickerControllerCameraDeviceFront);
}

- (void)testPickMultiImageShouldUseUIImagePickerControllerOnPreiOS14 {
  if (@available(iOS 14, *)) {
    return;
  }

  id mockUIImagePicker = OCMClassMock([UIImagePickerController class]);
  id photoLibrary = OCMClassMock([PHPhotoLibrary class]);
  OCMStub(ClassMethod([photoLibrary authorizationStatus]))
      .andReturn(PHAuthorizationStatusAuthorized);

  FLTImagePickerPlugin *plugin = [FLTImagePickerPlugin new];
  [plugin setImagePickerControllerOverrides:@[ mockUIImagePicker ]];
  FlutterMethodCall *call = [FlutterMethodCall methodCallWithMethodName:@"pickMultiImage"
                                                              arguments:@{
                                                                @"maxWidth" : @(100),
                                                                @"maxHeight" : @(200),
                                                                @"imageQuality" : @(50),
                                                              }];

  [plugin handleMethodCall:call
                    result:^(id _Nullable r){
                    }];

  OCMVerify(times(1),
            [mockUIImagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary]);
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
  UIImagePickerController *controller = [[UIImagePickerController alloc] init];
  plugin.imagePickerControllerOverrides = @[ controller ];
  [plugin handleMethodCall:call
                    result:^(id _Nullable r){
                    }];
  plugin.result = ^(id result) {

  };

  // To ensure the flow does not crash by multiple cancel call
  [plugin imagePickerControllerDidCancel:controller];
  [plugin imagePickerControllerDidCancel:controller];
}

#pragma mark - Test video duration

- (void)testPickingVideoWithDuration {
  FLTImagePickerPlugin *plugin = [FLTImagePickerPlugin new];
  FlutterMethodCall *call = [FlutterMethodCall
      methodCallWithMethodName:@"pickVideo"
                     arguments:@{@"source" : @(0), @"cameraDevice" : @(0), @"maxDuration" : @95}];
  UIImagePickerController *controller = [[UIImagePickerController alloc] init];
  [plugin setImagePickerControllerOverrides:@[ controller ]];
  [plugin handleMethodCall:call
                    result:^(id _Nullable r){
                    }];
  XCTAssertEqual(controller.videoMaximumDuration, 95);
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
