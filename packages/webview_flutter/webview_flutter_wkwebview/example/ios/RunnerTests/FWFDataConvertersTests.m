// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;
@import webview_flutter_wkwebview;

@interface FWFDataConvertersTests : XCTestCase
@end

@implementation FWFDataConvertersTests
- (void)testFWFNSURLRequestFromRequestData {
  NSURLRequest *request = FWFNSURLRequestFromRequestData([FWFNSUrlRequestData
              makeWithUrl:@"https://flutter.dev"
               httpMethod:@"post"
                 httpBody:[FlutterStandardTypedData typedDataWithBytes:[NSData data]]
      allHttpHeaderFields:@{@"a" : @"header"}]);

  XCTAssertEqualObjects(request.URL, [NSURL URLWithString:@"https://flutter.dev"]);
  XCTAssertEqualObjects(request.HTTPMethod, @"POST");
  XCTAssertEqualObjects(request.HTTPBody, [NSData data]);
  XCTAssertEqualObjects(request.allHTTPHeaderFields, @{@"a" : @"header"});
}

- (void)testFWFNSHTTPCookieFromCookieData {
  NSHTTPCookie *cookie = FWFNSHTTPCookieFromCookieData([FWFNSHttpCookieData
      makeWithPropertyKeys:@[ [FWFNSHttpCookiePropertyKeyEnumData
                               makeWithValue:FWFNSHttpCookiePropertyKeyEnumName] ]
            propertyValues:@[ @"cookieName" ]]);
  XCTAssertEqualObjects(cookie,
                        [NSHTTPCookie cookieWithProperties:@{NSHTTPCookieName : @"cookieName"}]);
}

- (void)testFWFWKUserScriptFromScriptData {
  WKUserScript *userScript = FWFWKUserScriptFromScriptData([FWFWKUserScriptData
       makeWithSource:@"mySource"
        injectionTime:[FWFWKUserScriptInjectionTimeEnumData
                          makeWithValue:FWFWKUserScriptInjectionTimeEnumAtDocumentStart]
      isMainFrameOnly:@NO]);

  XCTAssertEqualObjects(userScript.source, @"mySource");
  XCTAssertEqual(userScript.injectionTime, WKUserScriptInjectionTimeAtDocumentStart);
  XCTAssertEqual(userScript.isForMainFrameOnly, NO);
}
@end
