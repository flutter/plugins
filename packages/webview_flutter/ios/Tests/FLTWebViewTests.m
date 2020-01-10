// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import OCMock;
@import XCTest;
@import webview_flutter;

@interface FLTWebViewTests : XCTestCase

@property(strong, nonatomic) NSObject<FlutterBinaryMessenger> *mockBinaryMessenger;

@end

@implementation FLTWebViewTests

- (void)setUp {
  [super setUp];
  self.mockBinaryMessenger = OCMProtocolMock(@protocol(FlutterBinaryMessenger));
}

- (void)canInitFLTWebViewController {
  FLTWebViewController *controller =
      [[FLTWebViewController alloc] initWithFrame:CGRectMake(0, 0, 300, 400)
                                   viewIdentifier:1
                                        arguments:nil
                                  binaryMessenger:self.mockBinaryMessenger];
  XCTAssertNotNil(controller);
}

- (void)canInitFLTWebViewFactory {
  FLTWebViewFactory *factory =
      [[FLTWebViewFactory alloc] initWithMessenger:self.mockBinaryMessenger];
  XCTAssertNotNil(factory);
}

@end
