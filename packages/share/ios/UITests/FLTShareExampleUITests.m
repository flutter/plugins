// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <XCTest/XCTest.h>

@interface FLTShareExampleUITests : XCTestCase

@end

@implementation FLTShareExampleUITests

- (void)setUp {
    self.continueAfterFailure = NO;
}


- (void)testShareWithEmptyOrigin {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app launch];

    XCUIElement* shareWithEmptyOriginButton =
        [app.buttons elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label == %@", @"Share With Empty Origin"]];
    if (![shareWithEmptyOriginButton waitForExistenceWithTimeout:30]) {
      NSLog(@"%@", app.debugDescription);
      XCTFail(@"Failed due to not able to find shareWithEmptyOriginButton with %@ seconds", @(30));
    }

    XCTAssertNotNil(shareWithEmptyOriginButton);
    [shareWithEmptyOriginButton tap];

    // Find the copy button indicates the share sheet is up
    XCUIElement* copyButtonOnShareSheet =
        [app.cells elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label == %@", @"Copy"]];
    if (![copyButtonOnShareSheet waitForExistenceWithTimeout:30]) {
      NSLog(@"%@", app.debugDescription);
      XCTFail(@"Failed due to not able to find copyButtonOnShareSheet with %@ seconds", @(30));
    }
    XCTAssertNotNil(copyButtonOnShareSheet);
}

@end
