// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <XCTest/XCTest.h>
#import "FlashMode.h"

@interface FlashModeTests : XCTestCase

@end

@implementation FlashModeTests

- (void)testGetFlashModeForString {
  XCTAssertEqual(FlashModeOff, getFlashModeForString(@"off"));
  XCTAssertEqual(FlashModeAuto, getFlashModeForString(@"auto"));
  XCTAssertEqual(FlashModeAlways, getFlashModeForString(@"always"));
  XCTAssertEqual(FlashModeTorch, getFlashModeForString(@"torch"));
  XCTAssertThrows(getFlashModeForString(@"unkwown"));
}

- (void)testGetAVCaptureFlashModeForFlashMode {
  XCTAssertEqual(AVCaptureFlashModeOff, getAVCaptureFlashModeForFlashMode(FlashModeOff));
  XCTAssertEqual(AVCaptureFlashModeAuto, getAVCaptureFlashModeForFlashMode(FlashModeAuto));
  XCTAssertEqual(AVCaptureFlashModeOn, getAVCaptureFlashModeForFlashMode(FlashModeAlways));
  XCTAssertEqual(-1, getAVCaptureFlashModeForFlashMode(FlashModeTorch));
}

@end
