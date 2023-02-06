// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import CoreLocation;
@import XCTest;
@import os.log;

@interface GoogleMapsUITests : XCTestCase
@property(nonatomic, strong) XCUIApplication *app;
@end

@implementation GoogleMapsUITests

- (void)setUp {
  self.continueAfterFailure = NO;

  self.app = [[XCUIApplication alloc] init];
  [self.app launch];

  [self
      addUIInterruptionMonitorWithDescription:@"Permission popups"
                                      handler:^BOOL(XCUIElement *_Nonnull interruptingElement) {
                                        if (@available(iOS 14, *)) {
                                          XCUIElement *locationPermission =
                                              interruptingElement.buttons[@"Allow While Using App"];
                                          if (![locationPermission
                                                  waitForExistenceWithTimeout:30.0]) {
                                            XCTFail(@"Failed due to not able to find "
                                                    @"locationPermission button");
                                          }
                                          [locationPermission tap];

                                        } else {
                                          XCUIElement *allow =
                                              interruptingElement.buttons[@"Allow"];
                                          if (![allow waitForExistenceWithTimeout:30.0]) {
                                            XCTFail(@"Failed due to not able to find Allow button");
                                          }
                                          [allow tap];
                                        }
                                        return YES;
                                      }];
}

- (void)testUserInterface {
  XCUIApplication *app = self.app;
  XCUIElement *userInteface = app.staticTexts[@"User interface"];
  if (![userInteface waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find User interface");
  }
  [userInteface tap];

  XCUIElement *platformView = app.otherElements[@"platform_view[0]"];
  if (![platformView waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find platform view");
  }

  // There is a known bug where the permission popups interruption won't get fired until a tap
  // happened in the app. We expect a permission popup so we do a tap here.
  // iOS 16 has a bug where if the app itself is directly tapped: [app tap], the first button
  // (disable compass) in the app is also tapped, so instead we tap a arbitrary location in the app
  // instead.
  XCUICoordinate *coordinate = [app coordinateWithNormalizedOffset:CGVectorMake(0, 0)];
  [coordinate tap];
  XCUIElement *compass = app.buttons[@"disable compass"];
  if (![compass waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find disable compass button");
  }

  [self forceTap:compass];
}

- (void)testMapCoordinatesPage {
  XCUIApplication *app = self.app;
  XCUIElement *mapCoordinates = app.staticTexts[@"Map coordinates"];
  if (![mapCoordinates waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find 'Map coordinates''");
  }
  [mapCoordinates tap];

  XCUIElement *platformView = app.otherElements[@"platform_view[0]"];
  if (![platformView waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find platform view");
  }

  XCUIElement *titleBar = app.otherElements[@"Map coordinates"];
  if (![titleBar waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find title bar");
  }

  NSPredicate *visibleRegionPredicate =
      [NSPredicate predicateWithFormat:@"label BEGINSWITH 'VisibleRegion'"];
  XCUIElement *visibleRegionText =
      [app.staticTexts elementMatchingPredicate:visibleRegionPredicate];
  if (![visibleRegionText waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find Visible Region label'");
  }

  // Validate visible region does not change when scrolled under safe areas.
  // https://github.com/flutter/flutter/issues/107913

  // Example -33.79495661816674, 151.313996873796
  CLLocationCoordinate2D originalNortheast;
  // Example -33.90900557679571, 151.10800322145224
  CLLocationCoordinate2D originalSouthwest;
  [self validateVisibleRegion:visibleRegionText.label
                    northeast:&originalNortheast
                    southwest:&originalSouthwest];
  XCTAssertGreaterThan(originalNortheast.latitude, originalSouthwest.latitude);
  XCTAssertGreaterThan(originalNortheast.longitude, originalSouthwest.longitude);

  XCTAssertLessThan(originalNortheast.latitude, 0);
  XCTAssertLessThan(originalSouthwest.latitude, 0);
  XCTAssertGreaterThan(originalNortheast.longitude, 0);
  XCTAssertGreaterThan(originalSouthwest.longitude, 0);

  // Drag the map upward to under the title bar.
  [platformView pressForDuration:0 thenDragToElement:titleBar];

  CLLocationCoordinate2D draggedNortheast;
  CLLocationCoordinate2D draggedSouthwest;
  [self validateVisibleRegion:visibleRegionText.label
                    northeast:&draggedNortheast
                    southwest:&draggedSouthwest];
  XCTAssertEqual(originalNortheast.latitude, draggedNortheast.latitude);
  XCTAssertEqual(originalNortheast.longitude, draggedNortheast.longitude);
  XCTAssertEqual(originalSouthwest.latitude, draggedSouthwest.latitude);
  XCTAssertEqual(originalSouthwest.latitude, draggedSouthwest.latitude);
}

- (void)validateVisibleRegion:(NSString *)label
                    northeast:(CLLocationCoordinate2D *)northeast
                    southwest:(CLLocationCoordinate2D *)southwest {
  // String will be "VisibleRegion:\nnortheast: LatLng(-33.79495661816674,
  // 151.313996873796),\nsouthwest: LatLng(-33.90900557679571, 151.10800322145224)"
  NSScanner *scan = [NSScanner scannerWithString:label];

  // northeast
  [scan scanString:@"VisibleRegion:\nnortheast: LatLng(" intoString:NULL];
  double northeastLatitude;
  [scan scanDouble:&northeastLatitude];
  [scan scanString:@", " intoString:NULL];
  XCTAssertNotEqual(northeastLatitude, 0);
  double northeastLongitude;
  [scan scanDouble:&northeastLongitude];
  XCTAssertNotEqual(northeastLongitude, 0);

  [scan scanString:@"),\nsouthwest: LatLng(" intoString:NULL];
  double southwestLatitude;
  [scan scanDouble:&southwestLatitude];
  XCTAssertNotEqual(southwestLatitude, 0);
  [scan scanString:@", " intoString:NULL];
  double southwestLongitude;
  [scan scanDouble:&southwestLongitude];
  XCTAssertNotEqual(southwestLongitude, 0);
  *northeast = CLLocationCoordinate2DMake(northeastLatitude, northeastLongitude);
  *southwest = CLLocationCoordinate2DMake(southwestLatitude, southwestLongitude);
}

- (void)testMapClickPage {
  XCUIApplication *app = self.app;
  XCUIElement *mapClick = app.staticTexts[@"Map click"];
  if (![mapClick waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find 'Map click''");
  }
  [mapClick tap];

  XCUIElement *platformView = app.otherElements[@"platform_view[0]"];
  if (![platformView waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find platform view");
  }

  [platformView tap];

  XCUIElement *tapped = app.staticTexts[@"Tapped"];
  if (![tapped waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find 'tapped''");
  }

  [platformView pressForDuration:5.0];

  XCUIElement *longPressed = app.staticTexts[@"Long pressed"];
  if (![longPressed waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find 'longPressed''");
  }
}

- (void)forceTap:(XCUIElement *)button {
  // iOS 16 introduced a bug where hittable is NO for buttons. We force hit the location of the
  // button if that is the case. It is likely similar to
  // https://github.com/flutter/flutter/issues/113377.
  if (button.isHittable) {
    [button tap];
    return;
  }
  XCUICoordinate *coordinate = [button coordinateWithNormalizedOffset:CGVectorMake(0, 0)];
  [coordinate tap];
}

@end
