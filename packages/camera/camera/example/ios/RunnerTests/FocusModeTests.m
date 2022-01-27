// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera.Test;
@import AVFoundation;
#import <XCTest/XCTest.h>

@interface FocusModeTests : XCTestCase

@end

@implementation FocusModeTests

- (void)testFLTGetStringForFLTFocusMode {
  
  XCTAssertEqualObjects(@"auto", FLTGetStringForFLTFocusMode(FLTFocusModeAuto));
  XCTAssertEqualObjects(@"locked", FLTGetStringForFLTFocusMode(FLTFocusModeLocked));
  XCTAssertThrows(FLTGetStringForFLTFocusMode(-1));
  
}

- (void)testFLTGetFLTFocusModeForString {
  XCTAssertEqual(FLTFocusModeAuto, FLTGetFLTFocusModeForString(@"auto"));
  XCTAssertEqual(FLTFocusModeLocked, FLTGetFLTFocusModeForString(@"locked"));
  XCTAssertThrows(FLTGetFLTFocusModeForString(@"unknown"));
}

@end
