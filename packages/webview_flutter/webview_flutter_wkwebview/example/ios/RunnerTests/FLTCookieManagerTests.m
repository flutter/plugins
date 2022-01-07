// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;
@import webview_flutter_wkwebview;
@import webview_flutter_wkwebview.Test;

// OCMock library doesn't generate a valid modulemap.
#import <OCMock/OCMock.h>

@interface FLTCookieManagerTests : XCTestCase

@end

@implementation FLTCookieManagerTests

- (void)setUp {
  [super setUp];
}

- (void)testSetCookieForResultSetsCookieAndReturnsResultOnIOS11 {
  if (@available(iOS 11.0, *)) {
    // Setup
    XCTestExpectation *resultExpectation = [self
        expectationWithDescription:@"Should return success result when setting cookie completes."];
    [FLTCookieManager.instance setHttpCookieStore:OCMClassMock(WKHTTPCookieStore.class)];
    NSDictionary *arguments = @{
      @"name" : @"foo",
      @"value" : @"bar",
      @"domain" : @"flutter.dev",
      @"path" : @"/",
    };
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:@{
      NSHTTPCookieName : arguments[@"name"],
      NSHTTPCookieValue : arguments[@"value"],
      NSHTTPCookieDomain : arguments[@"domain"],
      NSHTTPCookiePath : arguments[@"path"],
    }];
    [OCMStub([FLTCookieManager.instance.httpCookieStore setCookie:[OCMArg isEqual:cookie]
                                                completionHandler:[OCMArg any]])
        andDo:^(NSInvocation *invocation) {
          void (^setCookieCompletionHandler)(void);
          [invocation getArgument:&setCookieCompletionHandler atIndex:3];
          setCookieCompletionHandler();
        }];
    // Run
    [[FLTCookieManager instance]
        setCookieForResult:^(id _Nullable result) {
          XCTAssertNil(result);
          [resultExpectation fulfill];
        }
                 arguments:arguments];
    // Verify
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
  }
}

- (void)testSetCookieForDataSetsCookieOnIOS11 {
  if (@available(iOS 11.0, *)) {
    // Setup
    WKHTTPCookieStore *mockHttpCookieStore = OCMClassMock(WKHTTPCookieStore.class);
    [FLTCookieManager.instance setHttpCookieStore:mockHttpCookieStore];
    NSDictionary *cookieData = @{
      @"name" : @"foo",
      @"value" : @"bar",
      @"domain" : @"flutter.dev",
      @"path" : @"/",
    };
    // Run
    [[FLTCookieManager instance] setCookieForData:cookieData];
    // Verify
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:@{
      NSHTTPCookieName : cookieData[@"name"],
      NSHTTPCookieValue : cookieData[@"value"],
      NSHTTPCookieDomain : cookieData[@"domain"],
      NSHTTPCookiePath : cookieData[@"path"],
    }];
    OCMVerify([mockHttpCookieStore setCookie:[OCMArg isEqual:cookie]
                           completionHandler:[OCMArg any]]);
  }
}

- (void)testSetCookiesForDataSetsCookiesOnIOS11 {
  if (@available(iOS 11.0, *)) {
    // Setup
    WKHTTPCookieStore *mockHttpCookieStore = OCMClassMock(WKHTTPCookieStore.class);
    [FLTCookieManager.instance setHttpCookieStore:mockHttpCookieStore];
    NSArray<NSDictionary *> *cookieDatas = @[
      @{
        @"name" : @"foo1",
        @"value" : @"bar1",
        @"domain" : @"flutter.dev",
        @"path" : @"/",
      },
      @{
        @"name" : @"foo2",
        @"value" : @"bar2",
        @"domain" : @"flutter2.dev",
        @"path" : @"/2",
      }
    ];
    // Run
    [[FLTCookieManager instance] setCookiesForData:cookieDatas];
    // Verify
    NSHTTPCookie *cookie1 = [NSHTTPCookie cookieWithProperties:@{
      NSHTTPCookieName : cookieDatas[0][@"name"],
      NSHTTPCookieValue : cookieDatas[0][@"value"],
      NSHTTPCookieDomain : cookieDatas[0][@"domain"],
      NSHTTPCookiePath : cookieDatas[0][@"path"],
    }];

    OCMVerify([mockHttpCookieStore setCookie:[OCMArg isEqual:cookie1]
                           completionHandler:[OCMArg any]]);
    NSHTTPCookie *cookie2 = [NSHTTPCookie cookieWithProperties:@{
      NSHTTPCookieName : cookieDatas[1][@"name"],
      NSHTTPCookieValue : cookieDatas[1][@"value"],
      NSHTTPCookieDomain : cookieDatas[1][@"domain"],
      NSHTTPCookiePath : cookieDatas[1][@"path"],
    }];
    OCMVerify([mockHttpCookieStore setCookie:[OCMArg isEqual:cookie2]
                           completionHandler:[OCMArg any]]);
  }
}

@end
