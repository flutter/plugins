// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import quick_actions;
@import XCTest;

@interface QuickActionsTests : XCTestCase
@end

@implementation QuickActionsTests

- (void)testPlugin {
  FLTQuickActionsPlugin* plugin = [[FLTQuickActionsPlugin alloc] init];
  XCTAssertNotNil(plugin);
}

@end
