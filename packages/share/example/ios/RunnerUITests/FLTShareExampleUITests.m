// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <XCTest/XCTest.h>
#import <os/log.h>

static const NSInteger kSecondsToWaitWhenFindingElements = 30;

@interface FLTShareExampleUITests : XCTestCase

@end

@implementation FLTShareExampleUITests

- (void)setUp {
  self.continueAfterFailure = NO;
}

- (void)testShareWithEmptyOrigin {
  XCUIApplication* app = [[XCUIApplication alloc] init];
  [app launch];

  XCUIElement* shareWithEmptyOriginButton = [app.buttons
      elementMatchingPredicate:[NSPredicate
                                   predicateWithFormat:@"label == %@", @"Share With Empty Origin"]];
  if (![shareWithEmptyOriginButton waitForExistenceWithTimeout:kSecondsToWaitWhenFindingElements]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find shareWithEmptyOriginButton with %@ seconds",
            @(kSecondsToWaitWhenFindingElements));
  }

  XCTAssertNotNil(shareWithEmptyOriginButton);
  [shareWithEmptyOriginButton tap];

  // Find the share popup.
  XCUIElement* activityListView = [app.otherElements
      elementMatchingPredicate:[NSPredicate
                                   predicateWithFormat:@"identifier == %@", @"ActivityListView"]];
  if (![activityListView waitForExistenceWithTimeout:kSecondsToWaitWhenFindingElements]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find activityListView with %@ seconds",
            @(kSecondsToWaitWhenFindingElements));
  }
  XCTAssertNotNil(activityListView);
}

@end
