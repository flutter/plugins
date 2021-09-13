// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import google_maps_flutter;
@import XCTest;

@interface GoogleMapsTests : XCTestCase
@end

@implementation GoogleMapsTests

- (void)testPlugin {
  FLTGoogleMapsPlugin* plugin = [[FLTGoogleMapsPlugin alloc] init];
  XCTAssertNotNil(plugin);
}

@end
