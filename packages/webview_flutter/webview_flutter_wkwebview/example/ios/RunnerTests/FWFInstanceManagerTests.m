// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <XCTest/XCTest.h>
@import webview_flutter_wkwebview;

@interface FWFInstanceManagerTests : XCTestCase
@end

@implementation FWFInstanceManagerTests
- (void)testAddFlutterCreatedInstance {
  FWFInstanceManager *instanceManager =
      [[FWFInstanceManager alloc] initWithDeallocCallback:^(long identifier){
      }];
  NSObject *object = [[NSObject alloc] init];

  [instanceManager addFlutterCreatedInstance:object withIdentifier:0];
  XCTAssertEqualObjects([instanceManager instanceForIdentifier:0], object);
  XCTAssertEqual([instanceManager identifierForInstance:object identifierWillBePassedToFlutter:NO],
                 0);
}

- (void)testAddHostCreatedInstance {
  FWFInstanceManager *instanceManager =
      [[FWFInstanceManager alloc] initWithDeallocCallback:^(long identifier){
      }];
  NSObject *object = [[NSObject alloc] init];
  [instanceManager addHostCreatedInstance:object];

  long identifier = [instanceManager identifierForInstance:object
                           identifierWillBePassedToFlutter:NO];
  XCTAssertNotEqual(identifier, NSNotFound);
  XCTAssertEqualObjects([instanceManager instanceForIdentifier:identifier], object);
}

- (void)testRemoveStrongReferenceWithIdentifier {
  FWFInstanceManager *instanceManager =
      [[FWFInstanceManager alloc] initWithDeallocCallback:^(long identifier){
      }];
  NSObject *object = [[NSObject alloc] init];

  [instanceManager addFlutterCreatedInstance:object withIdentifier:0];

  XCTAssertEqualObjects([instanceManager removeStrongReferenceWithIdentifier:0], object);
  XCTAssertEqual([instanceManager strongInstanceCount], 0);
}
@end
