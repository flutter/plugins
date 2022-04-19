// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <XCTest/XCTest.h>
@import webview_flutter_wkwebview;

@interface FLTWebViewFlutterInstanceManagerTests : XCTestCase
@property FLTWebViewFlutterInstanceManager *instanceManager;
@end

@implementation FLTWebViewFlutterInstanceManagerTests
- (void)setUp {
  self.instanceManager = [[FLTWebViewFlutterInstanceManager alloc] init];
}

- (void)testAddInstance {
  NSObject *object = [[NSObject alloc] init];

  [self.instanceManager addInstance:object withIdentifier:23];
  XCTAssertEqualObjects([self.instanceManager instanceForIdentifier:23], object);
  XCTAssertEqual([self.instanceManager identifierForInstance:object], 23);
}

- (void)testRemoveInstance {
  NSObject *object = [[NSObject alloc] init];
  [self.instanceManager addInstance:object withIdentifier:46];

  [self.instanceManager removeInstance:object];
  XCTAssertNil([self.instanceManager instanceForIdentifier:46]);
  XCTAssertEqual([self.instanceManager identifierForInstance:object], -1);
}

- (void)testRemoveInstanceWithIdentifier {
  NSObject *object = [[NSObject alloc] init];
  [self.instanceManager addInstance:object withIdentifier:69];

  [self.instanceManager removeInstanceWithIdentifier:69];
  XCTAssertNil([self.instanceManager instanceForIdentifier:69]);
  XCTAssertEqual([self.instanceManager identifierForInstance:object], -1);
}
@end
