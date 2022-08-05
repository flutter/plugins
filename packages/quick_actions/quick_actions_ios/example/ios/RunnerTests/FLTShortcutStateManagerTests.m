// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import quick_actions_ios;
@import quick_actions_ios.Test;
@import XCTest;
#import <OCMock/OCMock.h>
#import "Fixtures.h"

@interface FLTShortcutStateManagerTests : XCTestCase
@end

@implementation FLTShortcutStateManagerTests

- (void)testSetShortcutItems_shouldSetItem {
  id mockApplication = OCMPartialMock([UIApplication sharedApplication]);
  OCMStub([mockApplication sharedApplication]).andReturn(mockApplication);

  FLTShortcutStateManager *shortcutStateManager = [[FLTShortcutStateManager alloc] init];
  [shortcutStateManager setShortcutItems:@[ Fixtures.searchTheThingRawItem ]];

  OCMVerify([mockApplication setShortcutItems:@[ Fixtures.searchTheThingShortcutItem ]]);
}

- (void)testSetShortcutItems_shouldSetItemWithoutIcon {
  id mockApplication = OCMPartialMock([UIApplication sharedApplication]);
  OCMStub([mockApplication sharedApplication]).andReturn(mockApplication);

  NSDictionary *rawItem = Fixtures.searchTheThingRawItem_noIcon;
  UIApplicationShortcutItem *expectedItem = Fixtures.searchTheThingShortcutItem_noIcon;
  FLTShortcutStateManager *shortcutStateManager = [[FLTShortcutStateManager alloc] init];
  [shortcutStateManager setShortcutItems:@[ rawItem ]];

  OCMVerify([mockApplication setShortcutItems:@[ expectedItem ]]);
}

@end
