// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera.Test;
@import AVFoundation;
#import <XCTest/XCTest.h>

@interface ResolutionPresetTests : XCTestCase

@end

@implementation ResolutionPresetTests

- (void)testFLTGetFLTResolutionPresetForString {
  XCTAssertEqual(FLTResolutionPresetVeryLow, FLTGetFLTResolutionPresetForString(@"veryLow"));
  XCTAssertEqual(FLTResolutionPresetLow, FLTGetFLTResolutionPresetForString(@"low"));
  XCTAssertEqual(FLTResolutionPresetMedium, FLTGetFLTResolutionPresetForString(@"medium"));
  XCTAssertEqual(FLTResolutionPresetHigh, FLTGetFLTResolutionPresetForString(@"high"));
  XCTAssertEqual(FLTResolutionPresetVeryHigh, FLTGetFLTResolutionPresetForString(@"veryHigh"));
  XCTAssertEqual(FLTResolutionPresetUltraHigh, FLTGetFLTResolutionPresetForString(@"ultraHigh"));
  XCTAssertEqual(FLTResolutionPresetMax, FLTGetFLTResolutionPresetForString(@"max"));
  XCTAssertThrows(FLTGetFLTFlashModeForString(@"unknown"));
}

@end
