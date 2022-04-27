// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import os.log;
@import XCTest;

@interface VideoPlayerUITests : XCTestCase
@property(nonatomic, strong) XCUIApplication *app;
@end

@implementation VideoPlayerUITests

- (void)setUp {
  self.continueAfterFailure = NO;

  self.app = [[XCUIApplication alloc] init];
  [self.app launch];
}

- (void)testPlayVideo {
  XCUIApplication *app = self.app;

  XCUIElement *remoteTab = [app.otherElements
      elementMatchingPredicate:[NSPredicate predicateWithFormat:@"selected == YES"]];
  XCTAssertTrue([remoteTab waitForExistenceWithTimeout:30.0]);
  XCTAssertTrue([remoteTab.label containsString:@"Remote"]);

  XCUIElement *playButton = app.staticTexts[@"Play"];
  XCTAssertTrue([playButton waitForExistenceWithTimeout:30.0]);
  [playButton tap];

  XCUIElement *playbackSpeed1x = app.staticTexts[@"1.0x\nPlayback speed"];
  BOOL foundPlaybackSpeed1x = [playbackSpeed1x waitForExistenceWithTimeout:30.0];
  if (!foundPlaybackSpeed1x) {
    // Some old flutter version uses a different accessibility value for tooltips.
    // We try to find the button if the old accessibility value is used.
    // TODO(cyanglaz): Remove this when the new accessibility value is supported on flutter/stable
    // https://github.com/flutter/flutter/issues/102771
    playbackSpeed1x = app.staticTexts[@"Playback speed\n1.0x\n"];
    foundPlaybackSpeed1x = [playbackSpeed1x waitForExistenceWithTimeout:30.0];
  }
  XCTAssertTrue(foundPlaybackSpeed1x);
  [playbackSpeed1x tap];

  XCUIElement *playbackSpeed5xButton = app.buttons[@"5.0x"];
  XCTAssertTrue([playbackSpeed5xButton waitForExistenceWithTimeout:30.0]);
  [playbackSpeed5xButton tap];

  XCUIElement *playbackSpeed5x = app.staticTexts[@"5.0x\nPlayback speed"];
  BOOL foundPlaybackSpeed5x = [playbackSpeed5x waitForExistenceWithTimeout:30.0];
  if (!foundPlaybackSpeed5x) {
    // Some old flutter version uses a different accessibility value for tooltips.
    // We try to find the button if the old accessibility value is used.
    // TODO(cyanglaz): Remove this when the new accessibility value is supported on flutter/stable
    // https://github.com/flutter/flutter/issues/102771
    playbackSpeed5x = app.staticTexts[@"Playback speed\n5.0x\n"];
    foundPlaybackSpeed5x = [playbackSpeed5x waitForExistenceWithTimeout:30.0];
  }
  XCTAssertTrue(foundPlaybackSpeed5x);
  [playbackSpeed5x tap];

  // Cycle through tabs.
  for (NSString *tabName in @[ @"Asset", @"Remote" ]) {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"label BEGINSWITH %@", tabName];
    XCUIElement *unselectedTab = [app.staticTexts elementMatchingPredicate:predicate];
    XCTAssertTrue([unselectedTab waitForExistenceWithTimeout:30.0]);
    XCTAssertFalse(unselectedTab.isSelected);
    [unselectedTab tap];

    XCUIElement *selectedTab = [app.otherElements
        elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label BEGINSWITH %@", tabName]];
    XCTAssertTrue([selectedTab waitForExistenceWithTimeout:30.0]);
    XCTAssertTrue(selectedTab.isSelected);
  }
}

@end
