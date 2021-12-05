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

  // The location permission interception is currently not working.
  // See: https://github.com/flutter/flutter/issues/93325.
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

- (void)testMapCoordinatesPage {
  XCUIApplication* app = self.app;
  XCUIElement* mapCoordinates = app.staticTexts[@"Map coordinates"];
  if (![mapCoordinates waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find 'Map coordinates''");
  }
  [mapCoordinates tap];

  XCUIElement* platformView = app.otherElements[@"platform_view[0]"];
  if (![platformView waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find platform view");
  }

  XCUIElement* getVisibleRegionBoundsButton = app.buttons[@"Get Visible Region Bounds"];
  if (![getVisibleRegionBoundsButton waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find 'Get Visible Region Bounds''");
  }
  [getVisibleRegionBoundsButton tap];
}

- (void)testMapClickPage {
  XCUIApplication* app = self.app;
  XCUIElement* mapClick = app.staticTexts[@"Map click"];
  if (![mapClick waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find 'Map click''");
  }
  [mapClick tap];

  XCUIElement* platformView = app.otherElements[@"platform_view[0]"];
  if (![platformView waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find platform view");
  }

  [platformView tap];

  XCUIElement* tapped = app.staticTexts[@"Tapped"];
  if (![tapped waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find 'tapped''");
  }

  [platformView pressForDuration:5.0];

  XCUIElement* longPressed = app.staticTexts[@"Long pressed"];
  if (![longPressed waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find 'longPressed''");
  }
}

@end
