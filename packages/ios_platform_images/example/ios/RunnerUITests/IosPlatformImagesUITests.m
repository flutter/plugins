// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import os.log;
@import XCTest;

@interface IosPlatformImagesUITests : XCTestCase
@property(nonatomic, strong) XCUIApplication* app;
@end

@implementation IosPlatformImagesUITests

- (void)setUp {
  self.continueAfterFailure = NO;

  self.app = [[XCUIApplication alloc] init];
  [self.app launch];
}

- (void)testImage {
  XCUIApplication* app = self.app;

  XCUIElement* image = app.images[@"Flutter logo"];
  if (![image waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find logo");
  }

  XCTAssertTrue(CGSizeEqualToSize(image.frame.size, CGSizeMake(101.0, 125.0)));
}

@end
