// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import XCTest;
@import os.log;

@interface GoogleMapsUITests : XCTestCase
@property(nonatomic, strong) XCUIApplication* app;
@end

@implementation GoogleMapsUITests

- (void)setUp {
  self.continueAfterFailure = NO;

  self.app = [[XCUIApplication alloc] init];
  [self.app launch];

  [self
      addUIInterruptionMonitorWithDescription:@"Permission popups"
                                      handler:^BOOL(XCUIElement* _Nonnull interruptingElement) {
                                        if (@available(iOS 14, *)) {
                                          XCUIElement* locationPermission =
                                              interruptingElement.buttons[@"Allow While Using App"];
                                          if (![locationPermission
                                                  waitForExistenceWithTimeout:30.0]) {
                                            XCTFail(@"Failed due to not able to find "
                                                    @"locationPermission button");
                                          }
                                          [locationPermission tap];

                                        } else {
                                          XCUIElement* allow =
                                              interruptingElement.buttons[@"Allow"];
                                          if (![allow waitForExistenceWithTimeout:30.0]) {
                                            XCTFail(@"Failed due to not able to find Allow button");
                                          }
                                          [allow tap];
                                        }
                                        return YES;
                                      }];
}

// Temporarily disabled due to https://github.com/flutter/flutter/issues/93325
- (void)skip_testUserInterface {
  XCUIApplication* app = self.app;
  XCUIElement* userInteface = app.staticTexts[@"User interface"];
  if (![userInteface waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find User interface");
  }
  [userInteface tap];
  XCUIElement* platformView = app.otherElements[@"platform_view[0]"];
  if (![platformView waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find platform view");
  }
  XCUIElement* compass = app.buttons[@"disable compass"];
  if (![compass waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find compass button");
  }
  [compass tap];
}

@end
