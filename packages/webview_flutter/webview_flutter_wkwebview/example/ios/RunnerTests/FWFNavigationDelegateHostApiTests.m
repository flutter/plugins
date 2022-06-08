// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;
@import webview_flutter_wkwebview;

#import <OCMock/OCMock.h>

@interface FWFNavigationDelegateHostApiTests : XCTestCase
@end

@implementation FWFNavigationDelegateHostApiTests
- (void)testCreateWithIdentifier {
  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  FWFNavigationDelegateHostApiImpl *hostAPI = [[FWFNavigationDelegateHostApiImpl alloc]
      initWithBinaryMessenger:OCMProtocolMock(@protocol(FlutterBinaryMessenger))
              instanceManager:instanceManager];

  FlutterError *error;
  [hostAPI createWithIdentifier:@0 error:&error];
  FWFNavigationDelegate *navigationDelegate =
      (FWFNavigationDelegate *)[instanceManager instanceForIdentifier:0];

  XCTAssertTrue([navigationDelegate conformsToProtocol:@protocol(WKNavigationDelegate)]);
  XCTAssertNil(error);
}

- (void)testDidFinishNavigation {
  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  FWFNavigationDelegateHostApiImpl *hostAPI = [[FWFNavigationDelegateHostApiImpl alloc]
      initWithBinaryMessenger:OCMProtocolMock(@protocol(FlutterBinaryMessenger))
              instanceManager:instanceManager];

  FlutterError *error;
  [hostAPI createWithIdentifier:@0 error:&error];
  FWFNavigationDelegate *navigationDelegate =
      (FWFNavigationDelegate *)[instanceManager instanceForIdentifier:0];
  id mockDelegate = OCMPartialMock(navigationDelegate);

  FWFNavigationDelegateFlutterApiImpl *flutterAPI = [[FWFNavigationDelegateFlutterApiImpl alloc]
      initWithBinaryMessenger:OCMProtocolMock(@protocol(FlutterBinaryMessenger))
              instanceManager:instanceManager];
  id mockFlutterApi = OCMPartialMock(flutterAPI);

  OCMStub([mockDelegate navigationDelegateAPI]).andReturn(mockFlutterApi);

  WKWebView *mockWebView = OCMClassMock([WKWebView class]);
  OCMStub([mockWebView URL]).andReturn([NSURL URLWithString:@"https://flutter.dev/"]);
  [instanceManager addDartCreatedInstance:mockWebView withIdentifier:1];

  [mockDelegate webView:mockWebView didFinishNavigation:OCMClassMock([WKNavigation class])];
  OCMVerify([mockFlutterApi didFinishNavigationForDelegateWithIdentifier:@0
                                                       webViewIdentifier:@1
                                                                     URL:@"https://flutter.dev/"
                                                              completion:OCMOCK_ANY]);
}
@end
