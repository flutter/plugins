// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;
@import webview_flutter_wkwebview;

#import <OCMock/OCMock.h>

@interface FWFUIDelegateHostApiTests : XCTestCase
@end

@implementation FWFUIDelegateHostApiTests
- (void)testCreateWithIdentifier {
  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  FWFUIDelegateHostApiImpl *hostApi =
      [[FWFUIDelegateHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi createWithIdentifier:@0 error:&error];
  FWFUIDelegate *delegate = (FWFUIDelegate *)[instanceManager instanceForIdentifier:0];

  XCTAssertTrue([delegate conformsToProtocol:@protocol(WKUIDelegate)]);
  XCTAssertNil(error);
}
@end
