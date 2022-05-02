// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;
@import webview_flutter_wkwebview;

#import <OCMock/OCMock.h>

@interface FWFWebViewConfigurationHostApiTests : XCTestCase
@end

@implementation FWFWebViewConfigurationHostApiTests
- (void)testCreateWithIdentifier {
  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  FWFWebViewConfigurationHostApiImpl *hostApi =
      [[FWFWebViewConfigurationHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi createWithIdentifier:@0 error:&error];
  WKWebViewConfiguration *configuration =
      (WKWebViewConfiguration *)[instanceManager instanceForIdentifier:0];
  XCTAssertTrue([configuration isKindOfClass:[WKWebViewConfiguration class]]);
  XCTAssertNil(error);
}

- (void)testCreateFromWebViewWithIdentifier {
  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  FWFWebViewConfigurationHostApiImpl *hostApi =
      [[FWFWebViewConfigurationHostApiImpl alloc] initWithInstanceManager:instanceManager];

  WKWebView *mockWebView = OCMClassMock([WKWebView class]);
  OCMStub([mockWebView configuration]).andReturn(OCMClassMock([WKWebViewConfiguration class]));
  [instanceManager addInstance:mockWebView withIdentifier:0];

  FlutterError *error;
  [hostApi createFromWebViewWithIdentifier:@1 webViewIdentifier:@0 error:&error];
  WKWebViewConfiguration *configuration =
      (WKWebViewConfiguration *)[instanceManager instanceForIdentifier:1];
  XCTAssertTrue([configuration isKindOfClass:[WKWebViewConfiguration class]]);
  XCTAssertNil(error);
}

- (void)testSetAllowsInlineMediaPlayback {
  WKWebViewConfiguration *mockWebViewConfiguration = OCMClassMock([WKWebViewConfiguration class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockWebViewConfiguration withIdentifier:0];

  FWFWebViewConfigurationHostApiImpl *hostApi =
      [[FWFWebViewConfigurationHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi setAllowsInlineMediaPlaybackForConfigurationWithIdentifier:@0
                                                            isAllowed:@NO
                                                                error:&error];
  OCMVerify([mockWebViewConfiguration setAllowsInlineMediaPlayback:NO]);
  XCTAssertNil(error);
}

- (void)testSetMediaTypesRequiringUserActionForPlayback {
  WKWebViewConfiguration *mockWebViewConfiguration = OCMClassMock([WKWebViewConfiguration class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockWebViewConfiguration withIdentifier:0];

  FWFWebViewConfigurationHostApiImpl *hostApi =
      [[FWFWebViewConfigurationHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi
      setMediaTypesRequiresUserActionForConfigurationWithIdentifier:@0
                                                           forTypes:@[
                                                             [FWFWKAudiovisualMediaTypeEnumData
                                                                 makeWithValue:
                                                                     FWFWKAudiovisualMediaTypeEnumAudio],
                                                             [FWFWKAudiovisualMediaTypeEnumData
                                                                 makeWithValue:
                                                                     FWFWKAudiovisualMediaTypeEnumVideo]
                                                           ]
                                                              error:&error];
  OCMVerify([mockWebViewConfiguration
      setMediaTypesRequiringUserActionForPlayback:(WKAudiovisualMediaTypeAudio |
                                                   WKAudiovisualMediaTypeVideo)]);
  XCTAssertNil(error);
}
@end
