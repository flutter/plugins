// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;
@import webview_flutter_wkwebview;

#import <OCMock/OCMock.h>

@interface FWFWebViewHostApiTests : XCTestCase
@end

@implementation FWFWebViewHostApiTests
- (void)testCreateWithIdentifier {
  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  FWFWebViewHostApiImpl *hostApi =
      [[FWFWebViewHostApiImpl alloc] initWithInstanceManager:instanceManager];

  [instanceManager addInstance:[[WKWebViewConfiguration alloc] init] withIdentifier:0];

  FlutterError *error;
  [hostApi createWithIdentifier:@1 configurationIdentifier:@0 error:&error];
  WKWebView *webView = (WKWebView *)[instanceManager instanceForIdentifier:1];
  XCTAssertTrue([webView isKindOfClass:[WKWebView class]]);
  XCTAssertNil(error);
}

- (void)testLoadRequest {
  FWFWebView *mockWebView = OCMClassMock([FWFWebView class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockWebView withIdentifier:0];

  FWFWebViewHostApiImpl *hostApi =
      [[FWFWebViewHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  FWFNSUrlRequestData *requestData = [FWFNSUrlRequestData makeWithUrl:@"https://www.flutter.dev"
                                                           httpMethod:@"get"
                                                             httpBody:nil
                                                  allHttpHeaderFields:@{@"a" : @"header"}];
  [hostApi loadRequestForWebViewWithIdentifier:@0 request:requestData error:&error];

  NSURL *url = [NSURL URLWithString:@"https://www.flutter.dev"];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  request.HTTPMethod = @"get";
  request.allHTTPHeaderFields = @{@"a" : @"header"};
  OCMVerify([mockWebView loadRequest:request]);
  XCTAssertNil(error);
}

- (void)testLoadRequestWithInvalidUrl {
  FWFWebView *mockWebView = OCMClassMock([FWFWebView class]);
  OCMReject([mockWebView loadRequest:OCMOCK_ANY]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockWebView withIdentifier:0];

  FWFWebViewHostApiImpl *hostApi =
      [[FWFWebViewHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  FWFNSUrlRequestData *requestData = [FWFNSUrlRequestData makeWithUrl:@"%invalidUrl%"
                                                           httpMethod:nil
                                                             httpBody:nil
                                                  allHttpHeaderFields:@{}];
  [hostApi loadRequestForWebViewWithIdentifier:@0 request:requestData error:&error];
  XCTAssertNotNil(error);
  XCTAssertEqualObjects(error.code, @"FWFURLRequestParsingError");
  XCTAssertEqualObjects(error.message, @"Failed instantiating an NSURLRequest.");
  XCTAssertEqualObjects(error.details, @"URL was: '%invalidUrl%'");
}

- (void)testSetCustomUserAgent {
  FWFWebView *mockWebView = OCMClassMock([FWFWebView class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockWebView withIdentifier:0];

  FWFWebViewHostApiImpl *hostApi =
      [[FWFWebViewHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi setUserAgentForWebViewWithIdentifier:@0 userAgent:@"userA" error:&error];
  OCMVerify([mockWebView setCustomUserAgent:@"userA"]);
  XCTAssertNil(error);
}

- (void)testURL {
  FWFWebView *mockWebView = OCMClassMock([FWFWebView class]);
  OCMStub([mockWebView URL]).andReturn([NSURL URLWithString:@"https://www.flutter.dev/"]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockWebView withIdentifier:0];

  FWFWebViewHostApiImpl *hostApi =
      [[FWFWebViewHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  XCTAssertEqualObjects([hostApi URLForWebViewWithIdentifier:@0 error:&error],
                        @"https://www.flutter.dev/");
  XCTAssertNil(error);
}

- (void)testCanGoBack {
  FWFWebView *mockWebView = OCMClassMock([FWFWebView class]);
  OCMStub([mockWebView canGoBack]).andReturn(YES);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockWebView withIdentifier:0];

  FWFWebViewHostApiImpl *hostApi =
      [[FWFWebViewHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  XCTAssertEqualObjects([hostApi canGoBackForWebViewWithIdentifier:@0 error:&error], @YES);
  XCTAssertNil(error);
}

- (void)testSetUIDelegate {
  FWFWebView *mockWebView = OCMClassMock([FWFWebView class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockWebView withIdentifier:0];

  FWFWebViewHostApiImpl *hostApi =
      [[FWFWebViewHostApiImpl alloc] initWithInstanceManager:instanceManager];

  id<WKUIDelegate> mockDelegate = OCMProtocolMock(@protocol(WKUIDelegate));
  [instanceManager addInstance:mockDelegate withIdentifier:1];

  FlutterError *error;
  [hostApi setUIDelegateForWebViewWithIdentifier:@0 delegateIdentifier:@1 error:&error];
  OCMVerify([mockWebView setUIDelegate:mockDelegate]);
  XCTAssertNil(error);
}

- (void)testSetNavigationDelegate {
  FWFWebView *mockWebView = OCMClassMock([FWFWebView class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockWebView withIdentifier:0];

  FWFWebViewHostApiImpl *hostApi =
      [[FWFWebViewHostApiImpl alloc] initWithInstanceManager:instanceManager];

  id<WKNavigationDelegate> mockDelegate = OCMProtocolMock(@protocol(WKNavigationDelegate));
  [instanceManager addInstance:mockDelegate withIdentifier:1];
  FlutterError *error;

  [hostApi setNavigationDelegateForWebViewWithIdentifier:@0 delegateIdentifier:@1 error:&error];
  OCMVerify([mockWebView setNavigationDelegate:mockDelegate]);
  XCTAssertNil(error);
}

- (void)testEstimatedProgress {
  FWFWebView *mockWebView = OCMClassMock([FWFWebView class]);
  OCMStub([mockWebView estimatedProgress]).andReturn(34.0);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockWebView withIdentifier:0];

  FWFWebViewHostApiImpl *hostApi =
      [[FWFWebViewHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  XCTAssertEqualObjects([hostApi estimatedProgressForWebViewWithIdentifier:@0 error:&error], @34.0);
  XCTAssertNil(error);
}

- (void)testloadHTMLString {
  FWFWebView *mockWebView = OCMClassMock([FWFWebView class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockWebView withIdentifier:0];

  FWFWebViewHostApiImpl *hostApi =
      [[FWFWebViewHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi loadHTMLForWebViewWithIdentifier:@0
                                 HTMLString:@"myString"
                                    baseURL:@"myBaseUrl"
                                      error:&error];
  OCMVerify([mockWebView loadHTMLString:@"myString" baseURL:[NSURL URLWithString:@"myBaseUrl"]]);
  XCTAssertNil(error);
}

- (void)testLoadFileURL {
  FWFWebView *mockWebView = OCMClassMock([FWFWebView class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockWebView withIdentifier:0];

  FWFWebViewHostApiImpl *hostApi =
      [[FWFWebViewHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi loadFileForWebViewWithIdentifier:@0
                                    fileURL:@"myFolder/apple.txt"
                              readAccessURL:@"myFolder"
                                      error:&error];
  XCTAssertNil(error);
  OCMVerify([mockWebView loadFileURL:[NSURL fileURLWithPath:@"myFolder/apple.txt" isDirectory:NO]
             allowingReadAccessToURL:[NSURL fileURLWithPath:@"myFolder/" isDirectory:YES]

  ]);
}

- (void)testLoadFlutterAsset {
  FWFWebView *mockWebView = OCMClassMock([FWFWebView class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockWebView withIdentifier:0];

  FWFAssetManager *mockAssetManager = OCMClassMock([FWFAssetManager class]);
  OCMStub([mockAssetManager lookupKeyForAsset:@"assets/index.html"])
      .andReturn(@"myFolder/assets/index.html");

  NSBundle *mockBundle = OCMClassMock([NSBundle class]);
  OCMStub([mockBundle URLForResource:@"myFolder/assets/index" withExtension:@"html"])
      .andReturn([NSURL URLWithString:@"webview_flutter/myFolder/assets/index.html"]);

  FWFWebViewHostApiImpl *hostApi =
      [[FWFWebViewHostApiImpl alloc] initWithInstanceManager:instanceManager
                                                      bundle:mockBundle
                                                assetManager:mockAssetManager];

  FlutterError *error;
  [hostApi loadAssetForWebViewWithIdentifier:@0 assetKey:@"assets/index.html" error:&error];

  XCTAssertNil(error);
  OCMVerify([mockWebView
                  loadFileURL:[NSURL URLWithString:@"webview_flutter/myFolder/assets/index.html"]
      allowingReadAccessToURL:[NSURL URLWithString:@"webview_flutter/myFolder/assets/"]]);
}

- (void)testCanGoForward {
  FWFWebView *mockWebView = OCMClassMock([FWFWebView class]);
  OCMStub([mockWebView canGoForward]).andReturn(NO);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockWebView withIdentifier:0];

  FWFWebViewHostApiImpl *hostApi =
      [[FWFWebViewHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  XCTAssertEqualObjects([hostApi canGoForwardForWebViewWithIdentifier:@0 error:&error], @NO);
  XCTAssertNil(error);
}

- (void)testGoBack {
  FWFWebView *mockWebView = OCMClassMock([FWFWebView class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockWebView withIdentifier:0];

  FWFWebViewHostApiImpl *hostApi =
      [[FWFWebViewHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi goBackForWebViewWithIdentifier:@0 error:&error];
  OCMVerify([mockWebView goBack]);
  XCTAssertNil(error);
}

- (void)testGoForward {
  FWFWebView *mockWebView = OCMClassMock([FWFWebView class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockWebView withIdentifier:0];

  FWFWebViewHostApiImpl *hostApi =
      [[FWFWebViewHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi goForwardForWebViewWithIdentifier:@0 error:&error];
  OCMVerify([mockWebView goForward]);
  XCTAssertNil(error);
}

- (void)testReload {
  FWFWebView *mockWebView = OCMClassMock([FWFWebView class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockWebView withIdentifier:0];

  FWFWebViewHostApiImpl *hostApi =
      [[FWFWebViewHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi reloadWebViewWithIdentifier:@0 error:&error];
  OCMVerify([mockWebView reload]);
  XCTAssertNil(error);
}

- (void)testTitle {
  FWFWebView *mockWebView = OCMClassMock([FWFWebView class]);
  OCMStub([mockWebView title]).andReturn(@"myTitle");

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockWebView withIdentifier:0];

  FWFWebViewHostApiImpl *hostApi =
      [[FWFWebViewHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  XCTAssertEqualObjects([hostApi titleForWebViewWithIdentifier:@0 error:&error], @"myTitle");
  XCTAssertNil(error);
}

- (void)testSetAllowsBackForwardNavigationGestures {
  FWFWebView *mockWebView = OCMClassMock([FWFWebView class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockWebView withIdentifier:0];

  FWFWebViewHostApiImpl *hostApi =
      [[FWFWebViewHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi setAllowsBackForwardForWebViewWithIdentifier:@0 isAllowed:@YES error:&error];
  OCMVerify([mockWebView setAllowsBackForwardNavigationGestures:YES]);
  XCTAssertNil(error);
}

- (void)testEvaluateJavaScript {
  FWFWebView *mockWebView = OCMClassMock([FWFWebView class]);

  OCMStub([mockWebView
      evaluateJavaScript:@"runJavaScript"
       completionHandler:([OCMArg invokeBlockWithArgs:@"result", [NSNull null], nil])]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockWebView withIdentifier:0];

  FWFWebViewHostApiImpl *hostApi =
      [[FWFWebViewHostApiImpl alloc] initWithInstanceManager:instanceManager];

  NSString __block *returnValue;
  FlutterError __block *returnError;
  [hostApi evaluateJavaScriptForWebViewWithIdentifier:@0
                                     javaScriptString:@"runJavaScript"
                                           completion:^(id result, FlutterError *error) {
                                             returnValue = result;
                                             returnError = error;
                                           }];

  XCTAssertEqualObjects(returnValue, @"result");
  XCTAssertNil(returnError);
}
@end
