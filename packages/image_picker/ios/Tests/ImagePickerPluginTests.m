// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ImagePickerTestImages.h"

@import image_picker;
@import XCTest;

@interface ImagePickerPluginTests : XCTestCase
@end

@implementation ImagePickerPluginTests

#pragma mark - Test camera devices, no op on simulators
- (void)testPluginPickImageDeviceBack {
  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    return;
  }
  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewController:[UIViewController new]];
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
  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    return;
  }
  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewController:[UIViewController new]];
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
  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    return;
  }
  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewController:[UIViewController new]];
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
  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    return;
  }
  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewController:[UIViewController new]];
  FlutterMethodCall *call =
      [FlutterMethodCall methodCallWithMethodName:@"pickVideo"
                                        arguments:@{@"source" : @(0), @"cameraDevice" : @(1)}];
  [plugin handleMethodCall:call
                    result:^(id _Nullable r){
                    }];
  XCTAssertEqual([plugin getImagePickerController].cameraDevice,
                 UIImagePickerControllerCameraDeviceFront);
}

@end
