// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera.Test;
@import AVFoundation;
#import <XCTest/XCTest.h>

@interface VideoFormatTests : XCTestCase

@end

@implementation VideoFormatTests

- (void)testFLTGetVideoFormatFromString {
  
  XCTAssertEqual(kCVPixelFormatType_32BGRA, FLTGetVideoFormatFromString(@"bgra8888"));
  XCTAssertEqual(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange, FLTGetVideoFormatFromString(@"yuv420"));
  XCTAssertEqual(kCVPixelFormatType_32BGRA, FLTGetVideoFormatFromString(@"unknown"));
  
}

@end
