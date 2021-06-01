// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import XCTest;
@import os.log;

@interface URLLauncherUITests : XCTestCase
@property(nonatomic, strong) XCUIApplication* app;
@end

@implementation URLLauncherUITests

- (void)setUp {
  self.continueAfterFailure = NO;

  self.app = [[XCUIApplication alloc] init];
  [self.app launch];
}

- (void)testLaunch {
  XCUIApplication* app = self.app;

  NSArray<NSString*>* buttonNames = @[
    @"Launch in app", @"Launch in app(JavaScript ON)", @"Launch in app(DOM storage ON)",
    @"Launch a universal link in a native app, fallback to Safari.(Youtube)"
  ];
  for (NSString* buttonName in buttonNames) {
    XCUIElement* button = app.buttons[buttonName];
    if (![button waitForExistenceWithTimeout:30.0]) {
      os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
      XCTFail(@"Failed due to not able to find %@ button", buttonName);
    }
    XCTAssertEqual(app.webViews.count, 0);
    [button tap];
    XCUIElement* webView = app.webViews.firstMatch;
    if (![webView waitForExistenceWithTimeout:30.0]) {
      os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
      XCTFail(@"Failed due to not able to find webview");
    }
    XCTAssertTrue(app.buttons[@"ForwardButton"].exists);
    XCTAssertTrue(app.buttons[@"ShareButton"].exists);
    XCTAssertTrue(app.buttons[@"OpenInSafariButton"].exists);
    [app.buttons[@"Done"] tap];
  }
}

@end
