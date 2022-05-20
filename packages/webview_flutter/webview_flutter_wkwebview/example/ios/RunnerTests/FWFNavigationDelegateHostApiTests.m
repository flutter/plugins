// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;
@import webview_flutter_wkwebview;

#import <OCMock/OCMock.h>

// Used to test that a FlutterBinaryMessenger with a strong reference to a host api won't
// lead to a circular reference.
@interface FWFTestMessenger : NSObject <FlutterBinaryMessenger>
@property(strong, nullable) id hostAPI;
@end

@implementation FWFTestMessenger
- (void)cleanUpConnection:(FlutterBinaryMessengerConnection)connection {
}

- (void)sendOnChannel:(nonnull NSString *)channel message:(NSData *_Nullable)message {
}

- (void)sendOnChannel:(nonnull NSString *)channel
              message:(NSData *_Nullable)message
          binaryReply:(FlutterBinaryReply _Nullable)callback {
}

- (FlutterBinaryMessengerConnection)setMessageHandlerOnChannel:(nonnull NSString *)channel
                                          binaryMessageHandler:
                                              (FlutterBinaryMessageHandler _Nullable)handler {
  return 0;
}
@end

@interface FWFNavigationDelegateHostApiTests : XCTestCase
@end

@implementation FWFNavigationDelegateHostApiTests
- (void)testCreateWithIdentifier {
  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] initWithDeallocCallback:^(long identifier) {}];
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
  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] initWithDeallocCallback:^(long identifier) {}];
  FWFNavigationDelegateHostApiImpl *hostAPI = [[FWFNavigationDelegateHostApiImpl alloc]
      initWithBinaryMessenger:OCMProtocolMock(@protocol(FlutterBinaryMessenger))
              instanceManager:instanceManager];

  FlutterError *error;
  [hostAPI createWithIdentifier:@0 error:&error];
  FWFNavigationDelegate *navigationDelegate =
      (FWFNavigationDelegate *)[instanceManager instanceForIdentifier:0];
  id mockDelegate = OCMPartialMock(navigationDelegate);

  FWFNavigationDelegateFlutterApiImpl *flutterApi = [[FWFNavigationDelegateFlutterApiImpl alloc]
      initWithBinaryMessenger:OCMProtocolMock(@protocol(FlutterBinaryMessenger))
              instanceManager:instanceManager];
  id mockFlutterApi = OCMPartialMock(flutterApi);

  OCMStub([mockDelegate navigationDelegateApi]).andReturn(mockFlutterApi);

  WKWebView *mockWebView = OCMClassMock([WKWebView class]);
  OCMStub([mockWebView URL]).andReturn([NSURL URLWithString:@"https://flutter.dev/"]);
  [instanceManager addFlutterCreatedInstance:mockWebView withIdentifier:1];

  [mockDelegate webView:mockWebView didFinishNavigation:OCMClassMock([WKNavigation class])];
  OCMVerify([mockFlutterApi didFinishNavigationForDelegateWithIdentifier:@0
                                                       webViewIdentifier:@1
                                                                     URL:@"https://flutter.dev/"
                                                              completion:OCMOCK_ANY]);
}
@end
