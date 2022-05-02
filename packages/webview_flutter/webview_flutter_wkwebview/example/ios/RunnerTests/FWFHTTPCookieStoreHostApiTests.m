// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;
@import webview_flutter_wkwebview;

#import <OCMock/OCMock.h>

@interface FWFHTTPCookieStoreHostApiTests : XCTestCase
@end

@implementation FWFHTTPCookieStoreHostApiTests

- (void)testSetCookie API_AVAILABLE(ios(11.0)) {
  WKHTTPCookieStore *mockHttpCookieStore = OCMClassMock([WKHTTPCookieStore class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockHttpCookieStore withIdentifier:0];

  FWFHTTPCookieStoreHostApiImpl *hostApi =
      [[FWFHTTPCookieStoreHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FWFNSHttpCookieData *cookieData = [FWFNSHttpCookieData makeWithProperties:@{
    [FWFNSHttpCookiePropertyKeyEnumData makeWithValue:FWFNSHttpCookiePropertyKeyEnumName]:@"hello"
  }];
  FlutterError *__block blockError;
  [hostApi setCookieForStoreWithIdentifier:@0
                                    cookie:cookieData
                                completion:^(FlutterError *error) {
    blockError = error;
  }];
  OCMVerify([mockHttpCookieStore setCookie:[NSHTTPCookie cookieWithProperties:@{
    NSHTTPCookieName: @"hello"
  }] completionHandler:OCMOCK_ANY]);
  XCTAssertNil(blockError);
}

@end
