// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import google_sign_in;
@import XCTest;

@interface GoogleSignInTests : XCTestCase
@end

@implementation GoogleSignInTests

- (void)testPlugin {
  FLTGoogleSignInPlugin* plugin = [[FLTGoogleSignInPlugin alloc] init];
  XCTAssertNotNil(plugin);
}

@end
