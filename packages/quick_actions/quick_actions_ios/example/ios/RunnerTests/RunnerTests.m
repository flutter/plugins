// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import quick_actions_ios;
@import quick_actions_ios.Test;
@import XCTest;
#import <OCMock/OCMock.h>

@interface QuickActionsTests : XCTestCase
@end

@implementation QuickActionsTests

- (void)testPlugin {
  FLTQuickActionsPlugin *plugin =
      [[FLTQuickActionsPlugin alloc] initWithChannel:OCMClassMock([FlutterMethodChannel class])];
  XCTAssertNotNil(plugin);
}

@end
