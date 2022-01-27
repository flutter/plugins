// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera.Test;
@import AVFoundation;
#import <XCTest/XCTest.h>

@interface ExposureModeTests : XCTestCase

@end

@implementation ExposureModeTests

- (void)testFLTGetStringForFLTExposureMode {
  XCTAssertEqualObjects(@"auto", FLTGetStringForFLTExposureMode(FLTExposureModeAuto));
  XCTAssertEqualObjects(@"locked", FLTGetStringForFLTExposureMode(FLTExposureModeLocked));
  XCTAssertThrows(FLTGetStringForFLTExposureMode(-1));
}

- (void)testFLTGetFLTExposureModeForString {
  XCTAssertEqual(FLTExposureModeAuto, FLTGetFLTExposureModeForString(@"auto"));
  XCTAssertEqual(FLTExposureModeLocked, FLTGetFLTExposureModeForString(@"locked"));
  XCTAssertThrows(FLTGetFLTExposureModeForString(@"unknown"));
}

@end
