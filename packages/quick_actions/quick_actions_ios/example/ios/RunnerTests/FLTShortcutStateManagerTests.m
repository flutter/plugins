// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import quick_actions_ios;
@import quick_actions_ios.Test;
@import XCTest;
#import <OCMock/OCMock.h>

@interface FLTShortcutStateManagerTests : XCTestCase
@end

@implementation FLTShortcutStateManagerTests

- (void)testSetShortcutItems_shouldSetItem {
  id mockApplication = OCMPartialMock([UIApplication sharedApplication]);
  OCMStub([mockApplication sharedApplication]).andReturn(mockApplication);

  FLTShortcutStateManager *shortcutStateManager = [[FLTShortcutStateManager alloc] init];

  NSDictionary *rawItem = @{
    @"type" : @"SearchTheThing",
    @"localizedTitle" : @"Search the thing",
    @"icon" : @"search_the_thing.png",
  };

  [shortcutStateManager setShortcutItems:@[ rawItem ]];

  UIApplicationShortcutItem *expectedItem = [[UIApplicationShortcutItem alloc]
           initWithType:@"SearchTheThing"
         localizedTitle:@"Search the thing"
      localizedSubtitle:nil
                   icon:[UIApplicationShortcutIcon
                            iconWithTemplateImageName:@"search_the_thing.png"]
               userInfo:nil];

  OCMVerify([mockApplication setShortcutItems:@[ expectedItem ]]);
}

- (void)testSetShortcutItems_shouldSetItemWithoutIcon {
  id mockApplication = OCMPartialMock([UIApplication sharedApplication]);
  OCMStub([mockApplication sharedApplication]).andReturn(mockApplication);

  NSDictionary *rawItem = @{
    @"type" : @"SearchTheThing",
    @"localizedTitle" : @"Search the thing",
    // Dart's null value is passed to iOS as `NSNull`.
    // The key value pair is still present in the dictionary.
    @"icon" : [NSNull null],
  };
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
