// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <XCTest/XCTest.h>
@import webview_flutter_wkwebview;

@interface FLTWFInstanceManagerTests : XCTestCase
@end

@implementation FLTWFInstanceManagerTests {
  FLTWFInstanceManager *_instanceManager;
}

- (void)setUp {
  _instanceManager = [[FLTWFInstanceManager alloc] init];
}

- (void)testAddInstance {
  NSObject *object = [[NSObject alloc] init];

  [_instanceManager addInstance:object instanceID:23];
  XCTAssertEqualObjects([_instanceManager instanceForID:23], object);
  XCTAssertEqualObjects([_instanceManager instanceIDForInstance:object], @(23));
}

- (void)testRemoveInstance {
  NSObject *object = [[NSObject alloc] init];
  [_instanceManager addInstance:object instanceID:46];

  [_instanceManager removeInstance:object];
  XCTAssertNil([_instanceManager instanceForID:46]);
  XCTAssertNil([_instanceManager instanceIDForInstance:object]);
}

- (void)testRemoveInstanceWithID {
  NSObject *object = [[NSObject alloc] init];
  [_instanceManager addInstance:object instanceID:69];

  [_instanceManager removeInstanceWithID:69];
  XCTAssertNil([_instanceManager instanceForID:69]);
  XCTAssertNil([_instanceManager instanceIDForInstance:object]);
}
@end
