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

  XCUIElement *pipSupportedText = app.staticTexts[@"Pip is supported"];
  XCTAssertTrue([pipSupportedText waitForExistenceWithTimeout:30.0]);

  XCUIElement *pipPrepareButton = app.buttons[@"Prepare"];
  XCTAssertTrue([pipPrepareButton waitForExistenceWithTimeout:30.0]);
  [pipPrepareButton tap];

  XCUIElement *pipStartButton = app.buttons[@"Start PiP"];
  XCTAssertTrue([pipStartButton waitForExistenceWithTimeout:30.0]);
  [pipStartButton tap];

  XCUIElement *pipUIView = app.otherElements[@"PIPUIView"];
  XCTAssertTrue([pipUIView waitForExistenceWithTimeout:30.0]);

  XCUIElement *pipStopButton = app.buttons[@"Stop PiP"];
  XCTAssertTrue([pipStopButton waitForExistenceWithTimeout:30.0]);
  [pipStopButton tap];

  XCTAssertTrue([pipStartButton waitForExistenceWithTimeout:30.0]);

  NSPredicate *find1xButton = [NSPredicate predicateWithFormat:@"label CONTAINS '1.0x'"];
  XCUIElement *playbackSpeed1x = [app.staticTexts elementMatchingPredicate:find1xButton];
  BOOL foundPlaybackSpeed1x = [playbackSpeed1x waitForExistenceWithTimeout:30.0];
  XCTAssertTrue(foundPlaybackSpeed1x);
  [playbackSpeed1x tap];

  XCUIElement *playbackSpeed5xButton = app.buttons[@"5.0x"];
  XCTAssertTrue([playbackSpeed5xButton waitForExistenceWithTimeout:30.0]);
  [playbackSpeed5xButton tap];

  NSPredicate *find5xButton = [NSPredicate predicateWithFormat:@"label CONTAINS '5.0x'"];
  XCUIElement *playbackSpeed5x = [app.staticTexts elementMatchingPredicate:find5xButton];
  BOOL foundPlaybackSpeed5x = [playbackSpeed5x waitForExistenceWithTimeout:30.0];
  XCTAssertTrue(foundPlaybackSpeed5x);

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
