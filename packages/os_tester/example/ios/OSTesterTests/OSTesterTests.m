// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>

@import EarlGrey;

@interface OSTesterTests : XCTestCase

@end

@implementation OSTesterTests

- (void)setUp {
  [super setUp];
  
//  AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//  [delegate resetApplicationForTesting];
}

- (void)tearDown {
}

- (void)testExample {
  // Runs widget tests in tests/ folder of the example.
  [[EarlGrey selectElementWithMatcher:grey_accessibilityLabel(@"TEST")] performAction:grey_tap()];
  [[EarlGrey selectElementWithMatcher:grey_accessibilityLabel(@"Done")] performAction:grey_tap()];
}

- (void)testPlugin {
  // Runs widget tests in tests/ folder of the plugin.
}

@end
