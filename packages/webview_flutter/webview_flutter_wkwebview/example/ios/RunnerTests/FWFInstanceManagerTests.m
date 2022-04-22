// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <XCTest/XCTest.h>
@import webview_flutter_wkwebview;

@interface FWFInstanceManagerTests : XCTestCase
@end

@implementation FWFInstanceManagerTests
- (void)testAddInstance {
  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  NSObject *object = [[NSObject alloc] init];

  [instanceManager addInstance:object withIdentifier:5];
  XCTAssertEqualObjects([instanceManager instanceForIdentifier:5], object);
  XCTAssertEqual([instanceManager identifierForInstance:object], 5);
}

- (void)testRemoveInstance {
  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  NSObject *object = [[NSObject alloc] init];
  [instanceManager addInstance:object withIdentifier:5];

  [instanceManager removeInstance:object];
  XCTAssertNil([instanceManager instanceForIdentifier:5]);
  XCTAssertEqual([instanceManager identifierForInstance:object], NSNotFound);
}

- (void)testRemoveInstanceWithIdentifier {
  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  NSObject *object = [[NSObject alloc] init];
  [instanceManager addInstance:object withIdentifier:5];

  [instanceManager removeInstanceWithIdentifier:5];
  XCTAssertNil([instanceManager instanceForIdentifier:5]);
  XCTAssertEqual([instanceManager identifierForInstance:object], NSNotFound);
}
@end
