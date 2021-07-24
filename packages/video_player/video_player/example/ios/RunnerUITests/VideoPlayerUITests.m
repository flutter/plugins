// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import os.log;
@import XCTest;

@interface VideoPlayerUITests : XCTestCase
@property(nonatomic, strong) XCUIApplication* app;
@end

@implementation VideoPlayerUITests

- (void)setUp {
  self.continueAfterFailure = NO;

  self.app = [[XCUIApplication alloc] init];
  [self.app launch];
}

- (void)testTabs {
  XCUIApplication* app = self.app;

  XCUIElement* remoteTab = [app.otherElements
      elementMatchingPredicate:[NSPredicate predicateWithFormat:@"selected == YES"]];
  if (![remoteTab waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find selected Remote tab");
  }
  XCTAssertTrue([remoteTab.label containsString:@"Remote"]);

  for (NSString* tabName in @[ @"Asset", @"List example" ]) {
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"label BEGINSWITH %@", tabName];
    XCUIElement* unselectedTab = [app.staticTexts elementMatchingPredicate:predicate];
    if (![unselectedTab waitForExistenceWithTimeout:30.0]) {
      os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
      XCTFail(@"Failed due to not able to find unselected %@ tab", tabName);
    }
    XCTAssertFalse(unselectedTab.isSelected);
    [unselectedTab tap];

    XCUIElement* selectedTab = [app.otherElements
        elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label BEGINSWITH %@", tabName]];
    if (![selectedTab waitForExistenceWithTimeout:30.0]) {
      os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
      XCTFail(@"Failed due to not able to find selected %@ tab", tabName);
    }
    XCTAssertTrue(selectedTab.isSelected);
  }
}

@end
