// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera.Test;
@import AVFoundation;
#import <XCTest/XCTest.h>

@interface FLTFlashModeTests : XCTestCase

@end

@implementation FLTFlashModeTests

- (void)testGetFLTFlashModeForString {
  XCTAssertEqual(FLTFlashModeOff, getFLTFlashModeForString(@"off"));
  XCTAssertEqual(FLTFlashModeAuto, getFLTFlashModeForString(@"auto"));
  XCTAssertEqual(FLTFlashModeAlways, getFLTFlashModeForString(@"always"));
  XCTAssertEqual(FLTFlashModeTorch, getFLTFlashModeForString(@"torch"));
  XCTAssertThrows(getFLTFlashModeForString(@"unkwown"));
}

- (void)testGetAVCaptureFlashModeForFLTFlashMode {
  XCTAssertEqual(AVCaptureFlashModeOff, getAVCaptureFlashModeForFLTFlashMode(FLTFlashModeOff));
  XCTAssertEqual(AVCaptureFlashModeAuto, getAVCaptureFlashModeForFLTFlashMode(FLTFlashModeAuto));
  XCTAssertEqual(AVCaptureFlashModeOn, getAVCaptureFlashModeForFLTFlashMode(FLTFlashModeAlways));
  XCTAssertEqual(-1, getAVCaptureFlashModeForFLTFlashMode(FLTFlashModeTorch));
}

@end
