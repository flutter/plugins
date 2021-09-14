// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import share;
@import XCTest;

@interface ShareTests : XCTestCase
@end

@implementation ShareTests

- (void)testPlugin {
  FLTSharePlugin* plugin = [[FLTSharePlugin alloc] init];
  XCTAssertNotNil(plugin);
}

@end
