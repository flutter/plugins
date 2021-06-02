// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import os.log;
@import XCTest;

@interface PathProviderUITests : XCTestCase
@property(nonatomic, strong) XCUIApplication* app;
@end

@implementation PathProviderUITests

- (void)setUp {
  self.continueAfterFailure = NO;

  self.app = [[XCUIApplication alloc] init];
  [self.app launch];
}

- (void)testDirectories {
  XCUIApplication* app = self.app;

  XCUIElement* tempButton = app.buttons[@"Get Temporary Directory"];
  if (![tempButton waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find temp button");
  }
  [tempButton tap];

  XCUIElement* tempPath = [app.staticTexts
      elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label ENDSWITH '/Library/Caches'"]];
  if (![tempPath waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find temp path");
  }

  [app.buttons[@"Get Application Documents Directory"] tap];
  XCUIElement* appDocumentsPath = [app.staticTexts
      elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label ENDSWITH '/Documents'"]];
  if (![appDocumentsPath waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find app documents path");
  }

  [app.buttons[@"Get Application Support Directory"] tap];
  XCUIElement* appSupportPath = [app.staticTexts
      elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label ENDSWITH '/Library/Application Support'"]];
  if (![appSupportPath waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find app support path");
  }

  [app.buttons[@"Get Application Library Directory"] tap];
  XCUIElement* appLibraryPath = [app.staticTexts
      elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label ENDSWITH '/Library'"]];
  if (![appLibraryPath waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find app library path");
  }
}

@end
