// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import file_selector_ios;
@import XCTest;

@interface FileSelectorTests : XCTestCase

@end

@implementation FileSelectorTests

- (void)testPlugin {
  FTLFileSelectorPlugin *plugin = [[FTLFileSelectorPlugin alloc] init];
  XCTAssertNotNil(plugin);
}

@end
