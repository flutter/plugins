// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera.Test;
@import AVFoundation;
#import <XCTest/XCTest.h>

@interface FLTFlashModeTests : XCTestCase

@end

@implementation FLTFlashModeTests

- (void)testFLTGetFLTFlashModeForString {
  XCTAssertEqual(FLTFlashModeOff, FLTGetFLTFlashModeForString(@"off"));
  XCTAssertEqual(FLTFlashModeAuto, FLTGetFLTFlashModeForString(@"auto"));
  XCTAssertEqual(FLTFlashModeAlways, FLTGetFLTFlashModeForString(@"always"));
  XCTAssertEqual(FLTFlashModeTorch, FLTGetFLTFlashModeForString(@"torch"));
  XCTAssertThrows(FLTGetFLTFlashModeForString(@"unkwown"));
}

- (void)testFLTGetAVCaptureFlashModeForFLTFlashMode {
  XCTAssertEqual(AVCaptureFlashModeOff, FLTGetAVCaptureFlashModeForFLTFlashMode(FLTFlashModeOff));
  XCTAssertEqual(AVCaptureFlashModeAuto, FLTGetAVCaptureFlashModeForFLTFlashMode(FLTFlashModeAuto));
  XCTAssertEqual(AVCaptureFlashModeOn, FLTGetAVCaptureFlashModeForFLTFlashMode(FLTFlashModeAlways));
  XCTAssertEqual(-1, FLTGetAVCaptureFlashModeForFLTFlashMode(FLTFlashModeTorch));
}

@end
