// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import quick_actions_ios;
@import quick_actions_ios.Test;
@import XCTest;
#import <OCMock/OCMock.h>
#import "TestUtils.h"

@interface FLTShortcutStateManagerTests : XCTestCase
@end

@implementation FLTShortcutStateManagerTests

- (void)testSetShortcutItems_shouldSetItem {
  id mockApplication = OCMPartialMock([UIApplication sharedApplication]);
  OCMStub([mockApplication sharedApplication]).andReturn(mockApplication);

  FLTShortcutStateManager *shortcutStateManager = [[FLTShortcutStateManager alloc] init];
  [shortcutStateManager setShortcutItems:@[ TestUtils.searchTheThingRawItem ]];

  OCMVerify([mockApplication setShortcutItems:@[ TestUtils.searchTheThingShortcutItem ]]);
}

- (void)testSetShortcutItems_shouldSetItemWithoutIcon {
  id mockApplication = OCMPartialMock([UIApplication sharedApplication]);
  OCMStub([mockApplication sharedApplication]).andReturn(mockApplication);

  NSMutableDictionary *rawItem =
      TestUtils.searchTheThingRawItem.mutableCopy;
  rawItem[@"icon"] = [NSNull null];

  FLTShortcutStateManager *shortcutStateManager = [[FLTShortcutStateManager alloc] init];
  [shortcutStateManager setShortcutItems:@[ rawItem ]];

  UIApplicationShortcutItem *expectedItem =
      [[UIApplicationShortcutItem alloc] initWithType:@"SearchTheThing"
                                       localizedTitle:@"Search the thing"
                                    localizedSubtitle:nil
                                                 icon:nil
                                             userInfo:nil];
  OCMVerify([mockApplication setShortcutItems:@[ expectedItem ]]);
}

@end
