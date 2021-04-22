// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <XCTest/XCTest.h>
#import <os/log.h>

static const int kElementWaitingTime = 30;

@interface RunnerUITests : XCTestCase

@end

@implementation RunnerUITests

- (void)setUp {
  [super setUp];
  self.continueAfterFailure = NO;
}

- (void)testQuickActionWithFreshStart {
  XCUIApplication *app = [[XCUIApplication alloc] init];
  [app launch];
  [app terminate];

  XCUIApplication *springboard =
      [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];
  XCUIElement *quickActionsAppIcon = springboard.icons[@"quick_actions_example"];
  if (![quickActionsAppIcon waitForExistenceWithTimeout:kElementWaitingTime]) {
    os_log_error(OS_LOG_DEFAULT, "%@", springboard.debugDescription);
    XCTFail(@"Failed due to not able to find the example app from springboard with %@ seconds",
            @(kElementWaitingTime));
  }

  [quickActionsAppIcon pressForDuration:2];
  XCUIElement *actionTwo = springboard.buttons[@"Action two"];
  if (![actionTwo waitForExistenceWithTimeout:kElementWaitingTime]) {
    os_log_error(OS_LOG_DEFAULT, "%@", springboard.debugDescription);
    XCTFail(@"Failed due to not able to find the actionTwo button from springboard with %@ seconds",
            @(kElementWaitingTime));
  }

  [actionTwo tap];

  XCUIElement *actionTwoConfirmation = app.otherElements[@"action_two"];
  if (![actionTwoConfirmation waitForExistenceWithTimeout:kElementWaitingTime]) {
    os_log_error(OS_LOG_DEFAULT, "%@", springboard.debugDescription);
    XCTFail(@"Failed due to not able to find the actionTwoConfirmation in the app with %@ seconds",
            @(kElementWaitingTime));
  }
  XCTAssertTrue(actionTwoConfirmation.exists);

  [app terminate];
}

- (void)testQuickActionWhenAppIsInBackground {
  XCUIApplication *app = [[XCUIApplication alloc] init];
  [app launch];

  XCUIElement *actionsReady = app.otherElements[@"actions ready"];
  if (![actionsReady waitForExistenceWithTimeout:kElementWaitingTime]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find the actionsReady in the app with %@ seconds",
            @(kElementWaitingTime));
  }

  [[XCUIDevice sharedDevice] pressButton:XCUIDeviceButtonHome];

  XCUIApplication *springboard =
      [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];
  XCUIElement *quickActionsAppIcon = springboard.icons[@"quick_actions_example"];
  if (![quickActionsAppIcon waitForExistenceWithTimeout:kElementWaitingTime]) {
    os_log_error(OS_LOG_DEFAULT, "%@", springboard.debugDescription);
    XCTFail(@"Failed due to not able to find the example app from springboard with %@ seconds",
            @(kElementWaitingTime));
  }

  [quickActionsAppIcon pressForDuration:2];
  XCUIElement *actionOne = springboard.buttons[@"Action one"];
  if (![actionOne waitForExistenceWithTimeout:kElementWaitingTime]) {
    os_log_error(OS_LOG_DEFAULT, "%@", springboard.debugDescription);
    XCTFail(@"Failed due to not able to find the actionOne button from springboard with %@ seconds",
            @(kElementWaitingTime));
  }

  [actionOne tap];

  XCUIElement *actionOneConfirmation = app.otherElements[@"action_one"];
  if (![actionOneConfirmation waitForExistenceWithTimeout:kElementWaitingTime]) {
    os_log_error(OS_LOG_DEFAULT, "%@", springboard.debugDescription);
    XCTFail(@"Failed due to not able to find the actionOneConfirmation in the app with %@ seconds",
            @(kElementWaitingTime));
  }
  XCTAssertTrue(actionOneConfirmation.exists);

  [app terminate];
}

@end
