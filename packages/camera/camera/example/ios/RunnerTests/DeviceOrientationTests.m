// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera.Test;
@import AVFoundation;
#import <XCTest/XCTest.h>

@interface DeviceOrientationTests : XCTestCase

@end

@implementation DeviceOrientationTests

- (void)testFLTGetUIDeviceOrientationForString {
  XCTAssertEqual(UIDeviceOrientationPortraitUpsideDown,
                 FLTGetUIDeviceOrientationForString(@"portraitDown"));
  XCTAssertEqual(UIDeviceOrientationLandscapeRight,
                 FLTGetUIDeviceOrientationForString(@"landscapeLeft"));
  XCTAssertEqual(UIDeviceOrientationLandscapeLeft,
                 FLTGetUIDeviceOrientationForString(@"landscapeRight"));
  XCTAssertEqual(UIDeviceOrientationPortrait, FLTGetUIDeviceOrientationForString(@"portraitUp"));
  XCTAssertThrows(FLTGetUIDeviceOrientationForString(@"unknown"));
}

- (void)testFLTGetStringForUIDeviceOrientation {
  XCTAssertEqualObjects(@"portraitDown",
                        FLTGetStringForUIDeviceOrientation(UIDeviceOrientationPortraitUpsideDown));
  XCTAssertEqualObjects(@"landscapeLeft",
                        FLTGetStringForUIDeviceOrientation(UIDeviceOrientationLandscapeRight));
  XCTAssertEqualObjects(@"landscapeRight",
                        FLTGetStringForUIDeviceOrientation(UIDeviceOrientationLandscapeLeft));
  XCTAssertEqualObjects(@"portraitUp",
                        FLTGetStringForUIDeviceOrientation(UIDeviceOrientationPortrait));
  XCTAssertEqualObjects(@"portraitUp", FLTGetStringForUIDeviceOrientation(-1));
}

@end
