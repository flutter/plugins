// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;
@import webview_flutter_wkwebview;

#import <OCMock/OCMock.h>

@interface FWFScriptMessageHandlerHostApiTests : XCTestCase
@end

@implementation FWFScriptMessageHandlerHostApiTests
- (void)testCreateWithIdentifier {
  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  FWFScriptMessageHandlerHostApiImpl *hostApi =
      [[FWFScriptMessageHandlerHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi createWithIdentifier:@0 error:&error];

  FWFScriptMessageHandler *scriptMessageHandler =
      (FWFScriptMessageHandler *)[instanceManager instanceForIdentifier:0];

  XCTAssertTrue([scriptMessageHandler conformsToProtocol:@protocol(WKScriptMessageHandler)]);
  XCTAssertNil(error);
}
@end
