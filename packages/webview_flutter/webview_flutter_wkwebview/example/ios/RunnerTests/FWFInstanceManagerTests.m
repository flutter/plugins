// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <XCTest/XCTest.h>

@import webview_flutter_wkwebview;
@import webview_flutter_wkwebview.Test;

@interface FWFInstanceManagerTests : XCTestCase
@end

@implementation FWFInstanceManagerTests
- (void)testAddDartCreatedInstance {
  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  NSObject *object = [[NSObject alloc] init];

  [instanceManager addDartCreatedInstance:object withIdentifier:0];
  XCTAssertEqualObjects([instanceManager instanceForIdentifier:0], object);
  XCTAssertEqual([instanceManager identifierWithStrongReferenceForInstance:object], 0);
}

- (void)testAddHostCreatedInstance {
  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  NSObject *object = [[NSObject alloc] init];
  [instanceManager addHostCreatedInstance:object];

  long identifier = [instanceManager identifierWithStrongReferenceForInstance:object];
  XCTAssertNotEqual(identifier, NSNotFound);
  XCTAssertEqualObjects([instanceManager instanceForIdentifier:identifier], object);
}

- (void)testRemoveInstanceWithIdentifier {
  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  NSObject *object = [[NSObject alloc] init];

  [instanceManager addDartCreatedInstance:object withIdentifier:0];

  XCTAssertEqualObjects([instanceManager removeInstanceWithIdentifier:0], object);
  XCTAssertEqual([instanceManager strongInstanceCount], 0);
}
@end
