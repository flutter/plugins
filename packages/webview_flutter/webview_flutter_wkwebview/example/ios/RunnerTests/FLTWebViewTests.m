// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;
@import webview_flutter_wkwebview;
@import webview_flutter_wkwebview.Test;

// OCMock library doesn't generate a valid modulemap.
#import <OCMock/OCMock.h>

static bool feq(CGFloat a, CGFloat b) { return fabs(b - a) < FLT_EPSILON; }

@interface FLTWebViewTests : XCTestCase

@property(strong, nonatomic) NSObject<FlutterBinaryMessenger> *mockBinaryMessenger;

@property(strong, nonatomic) FLTCookieManager *mockCookieManager;

@end

@implementation FLTWebViewTests

- (void)setUp {
  [super setUp];
  self.mockBinaryMessenger = OCMProtocolMock(@protocol(FlutterBinaryMessenger));
  self.mockCookieManager = OCMClassMock(FLTCookieManager.class);
}

- (void)testCanInitFLTWebViewController {
  FLTWebViewController *controller =
      [[FLTWebViewController alloc] initWithFrame:CGRectMake(0, 0, 300, 400)
                                   viewIdentifier:1
                                        arguments:nil
                                  binaryMessenger:self.mockBinaryMessenger];
  XCTAssertNotNil(controller);
}

- (void)testCanInitFLTWebViewFactory {
  FLTWebViewFactory *factory = [[FLTWebViewFactory alloc] initWithMessenger:self.mockBinaryMessenger
                                                              cookieManager:self.mockCookieManager];
  XCTAssertNotNil(factory);
}

- (void)webViewContentInsetBehaviorShouldBeNeverOnIOS11 {
  if (@available(iOS 11, *)) {
    FLTWebViewController *controller =
        [[FLTWebViewController alloc] initWithFrame:CGRectMake(0, 0, 300, 400)
                                     viewIdentifier:1
                                          arguments:nil
                                    binaryMessenger:self.mockBinaryMessenger];
    UIView *view = controller.view;
    XCTAssertTrue([view isKindOfClass:WKWebView.class]);
    WKWebView *webView = (WKWebView *)view;
    XCTAssertEqual(webView.scrollView.contentInsetAdjustmentBehavior,
                   UIScrollViewContentInsetAdjustmentNever);
  }
}

- (void)testWebViewScrollIndicatorAticautomaticallyAdjustsScrollIndicatorInsetsShouldbeNoOnIOS13 {
  if (@available(iOS 13, *)) {
    FLTWebViewController *controller =
        [[FLTWebViewController alloc] initWithFrame:CGRectMake(0, 0, 300, 400)
                                     viewIdentifier:1
                                          arguments:nil
                                    binaryMessenger:self.mockBinaryMessenger];
    UIView *view = controller.view;
    XCTAssertTrue([view isKindOfClass:WKWebView.class]);
    WKWebView *webView = (WKWebView *)view;
    XCTAssertFalse(webView.scrollView.automaticallyAdjustsScrollIndicatorInsets);
  }
}

- (void)testContentInsetsSumAlwaysZeroAfterSetFrame {
  FLTWKWebView *webView = [[FLTWKWebView alloc] initWithFrame:CGRectMake(0, 0, 300, 400)];
  webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 300, 0);
  XCTAssertFalse(UIEdgeInsetsEqualToEdgeInsets(webView.scrollView.contentInset, UIEdgeInsetsZero));
  webView.frame = CGRectMake(0, 0, 300, 200);
  XCTAssertTrue(UIEdgeInsetsEqualToEdgeInsets(webView.scrollView.contentInset, UIEdgeInsetsZero));
  XCTAssertTrue(CGRectEqualToRect(webView.frame, CGRectMake(0, 0, 300, 200)));

  if (@available(iOS 11, *)) {
    // After iOS 11, we need to make sure the contentInset compensates the adjustedContentInset.
    UIScrollView *partialMockScrollView = OCMPartialMock(webView.scrollView);
    UIEdgeInsets insetToAdjust = UIEdgeInsetsMake(0, 0, 300, 0);
    OCMStub(partialMockScrollView.adjustedContentInset).andReturn(insetToAdjust);
    XCTAssertTrue(UIEdgeInsetsEqualToEdgeInsets(webView.scrollView.contentInset, UIEdgeInsetsZero));
    webView.frame = CGRectMake(0, 0, 300, 100);
    XCTAssertTrue(feq(webView.scrollView.contentInset.bottom, -insetToAdjust.bottom));
    XCTAssertTrue(CGRectEqualToRect(webView.frame, CGRectMake(0, 0, 300, 100)));
  }
}

- (void)testLoadFileSucceeds {
  NSString *testFilePath = @"/assets/file.html";
  NSURL *url = [NSURL fileURLWithPath:testFilePath isDirectory:NO];
  XCTestExpectation *resultExpectation =
      [self expectationWithDescription:@"Should return successful result over the method channel."];
  FLTWebViewController *controller =
      [[FLTWebViewController alloc] initWithFrame:CGRectMake(0, 0, 300, 400)
                                   viewIdentifier:1
                                        arguments:nil
                                  binaryMessenger:self.mockBinaryMessenger];
  FLTWKWebView *mockWebView = OCMClassMock(FLTWKWebView.class);
  controller.webView = mockWebView;
  [controller onMethodCall:[FlutterMethodCall methodCallWithMethodName:@"loadFile"
                                                             arguments:testFilePath]
                    result:^(id _Nullable result) {
                      XCTAssertNil(result);
                      [resultExpectation fulfill];
                    }];

  [self waitForExpectations:@[ resultExpectation ] timeout:30.0];
  OCMVerify([mockWebView loadFileURL:url
             allowingReadAccessToURL:[url URLByDeletingLastPathComponent]]);
}

- (void)testLoadFileFailsWithInvalidPath {
  NSArray *resultExpectations = @[
    [self expectationWithDescription:@"Should return failed result when argument is nil."],
    [self expectationWithDescription:
              @"Should return failed result when argument is not of type NSString*."],
    [self expectationWithDescription:
              @"Should return failed result when argument is an empty string."],
  ];

  FLTWebViewController *controller =
      [[FLTWebViewController alloc] initWithFrame:CGRectMake(0, 0, 300, 400)
                                   viewIdentifier:1
                                        arguments:nil
                                  binaryMessenger:self.mockBinaryMessenger];
  FLTWKWebView *mockWebView = OCMClassMock(FLTWKWebView.class);
  controller.webView = mockWebView;
  [controller onMethodCall:[FlutterMethodCall methodCallWithMethodName:@"loadFile" arguments:nil]
                    result:^(id _Nullable result) {
                      FlutterError *expected =
                          [FlutterError errorWithCode:@"loadFile_failed"
                                              message:@"Failed parsing file path."
                                              details:@"Argument is nil."];
                      [FLTWebViewTests assertFlutterError:result withExpected:expected];
                      [resultExpectations[0] fulfill];
                    }];
  [controller onMethodCall:[FlutterMethodCall methodCallWithMethodName:@"loadFile" arguments:@(10)]
                    result:^(id _Nullable result) {
                      FlutterError *expected =
                          [FlutterError errorWithCode:@"loadFile_failed"
                                              message:@"Failed parsing file path."
                                              details:@"Argument is not of type NSString."];
                      [FLTWebViewTests assertFlutterError:result withExpected:expected];
                      [resultExpectations[1] fulfill];
                    }];
  [controller onMethodCall:[FlutterMethodCall methodCallWithMethodName:@"loadFile" arguments:@""]
                    result:^(id _Nullable result) {
                      FlutterError *expected =
                          [FlutterError errorWithCode:@"loadFile_failed"
                                              message:@"Failed parsing file path."
                                              details:@"Argument contains an empty string."];
                      [FLTWebViewTests assertFlutterError:result withExpected:expected];
                      [resultExpectations[2] fulfill];
                    }];

  [self waitForExpectations:resultExpectations timeout:1.0];
  OCMReject([mockWebView loadFileURL:[OCMArg any] allowingReadAccessToURL:[OCMArg any]]);
}

- (void)testLoadFlutterAssetSucceeds {
  NSBundle *mockBundle = OCMPartialMock([NSBundle mainBundle]);
  NSString *filePath = [FlutterDartProject lookupKeyForAsset:@"assets/file.html"];
  NSURL *url = [NSURL URLWithString:[@"file:///" stringByAppendingString:filePath]];
  [OCMStub([mockBundle URLForResource:[filePath stringByDeletingPathExtension]
                        withExtension:@"html"]) andReturn:(url)];

  XCTestExpectation *resultExpectation =
      [self expectationWithDescription:@"Should return successful result over the method channel."];
  FLTWebViewController *controller =
      [[FLTWebViewController alloc] initWithFrame:CGRectMake(0, 0, 300, 400)
                                   viewIdentifier:1
                                        arguments:nil
                                  binaryMessenger:self.mockBinaryMessenger];
  FLTWKWebView *mockWebView = OCMClassMock(FLTWKWebView.class);
  controller.webView = mockWebView;
  [controller onMethodCall:[FlutterMethodCall methodCallWithMethodName:@"loadFlutterAsset"
                                                             arguments:@"assets/file.html"]
                    result:^(id _Nullable result) {
                      XCTAssertNil(result);
                      [resultExpectation fulfill];
                    }];

  [self waitForExpectations:@[ resultExpectation ] timeout:1.0];
  OCMVerify([mockWebView loadFileURL:url
             allowingReadAccessToURL:[url URLByDeletingLastPathComponent]]);
}

- (void)testLoadFlutterAssetFailsWithInvalidKey {
  NSArray *resultExpectations = @[
    [self expectationWithDescription:@"Should return failed result when argument is nil."],
    [self expectationWithDescription:
              @"Should return failed result when argument is not of type NSString*."],
    [self expectationWithDescription:
              @"Should return failed result when argument is an empty string."],
  ];

  FLTWebViewController *controller =
      [[FLTWebViewController alloc] initWithFrame:CGRectMake(0, 0, 300, 400)
                                   viewIdentifier:1
                                        arguments:nil
                                  binaryMessenger:self.mockBinaryMessenger];
  FLTWKWebView *mockWebView = OCMClassMock(FLTWKWebView.class);
  controller.webView = mockWebView;
  [controller onMethodCall:[FlutterMethodCall methodCallWithMethodName:@"loadFlutterAsset"
                                                             arguments:nil]
                    result:^(id _Nullable result) {
                      FlutterError *expected =
                          [FlutterError errorWithCode:@"loadFlutterAsset_invalidKey"
                                              message:@"Supplied asset key is not valid."
                                              details:@"Argument is nil."];
                      [FLTWebViewTests assertFlutterError:result withExpected:expected];
                      [resultExpectations[0] fulfill];
                    }];
  [controller onMethodCall:[FlutterMethodCall methodCallWithMethodName:@"loadFlutterAsset"
                                                             arguments:@(10)]
                    result:^(id _Nullable result) {
                      FlutterError *expected =
                          [FlutterError errorWithCode:@"loadFlutterAsset_invalidKey"
                                              message:@"Supplied asset key is not valid."
                                              details:@"Argument is not of type NSString."];
                      [FLTWebViewTests assertFlutterError:result withExpected:expected];
                      [resultExpectations[1] fulfill];
                    }];
  [controller onMethodCall:[FlutterMethodCall methodCallWithMethodName:@"loadFlutterAsset"
                                                             arguments:@""]
                    result:^(id _Nullable result) {
                      FlutterError *expected =
                          [FlutterError errorWithCode:@"loadFlutterAsset_invalidKey"
                                              message:@"Supplied asset key is not valid."
                                              details:@"Argument contains an empty string."];
                      [FLTWebViewTests assertFlutterError:result withExpected:expected];
                      [resultExpectations[2] fulfill];
                    }];

  [self waitForExpectations:resultExpectations timeout:1.0];
  OCMReject([mockWebView loadFileURL:[OCMArg any] allowingReadAccessToURL:[OCMArg any]]);
}

- (void)testLoadFlutterAssetFailsWithParsingError {
  NSBundle *mockBundle = OCMPartialMock([NSBundle mainBundle]);
  NSString *filePath = [FlutterDartProject lookupKeyForAsset:@"assets/file.html"];
  [OCMStub([mockBundle URLForResource:[filePath stringByDeletingPathExtension]
                        withExtension:@"html"]) andReturn:(nil)];

  XCTestExpectation *resultExpectation =
      [self expectationWithDescription:@"Should return failed result over the method channel."];
  FLTWebViewController *controller =
      [[FLTWebViewController alloc] initWithFrame:CGRectMake(0, 0, 300, 400)
                                   viewIdentifier:1
                                        arguments:nil
                                  binaryMessenger:self.mockBinaryMessenger];
  FLTWKWebView *mockWebView = OCMClassMock(FLTWKWebView.class);
  controller.webView = mockWebView;
  [controller
      onMethodCall:[FlutterMethodCall methodCallWithMethodName:@"loadFlutterAsset"
                                                     arguments:@"assets/file.html"]
            result:^(id _Nullable result) {
              FlutterError *expected = [FlutterError
                  errorWithCode:@"loadFlutterAsset_invalidKey"
                        message:@"Failed parsing file path for supplied key."
                        details:[NSString
                                    stringWithFormat:
                                        @"Failed to convert path '%@' into NSURL for key '%@'.",
                                        filePath, @"assets/file.html"]];
              [FLTWebViewTests assertFlutterError:result withExpected:expected];
              [resultExpectation fulfill];
            }];

  [self waitForExpectations:@[ resultExpectation ] timeout:1.0];
  OCMReject([mockWebView loadFileURL:[OCMArg any] allowingReadAccessToURL:[OCMArg any]]);
}

- (void)testLoadHtmlStringSucceedsWithBaseUrl {
  NSURL *baseUrl = [NSURL URLWithString:@"https://flutter.dev"];
  XCTestExpectation *resultExpectation =
      [self expectationWithDescription:@"Should return successful result over the method channel."];
  FLTWebViewController *controller =
      [[FLTWebViewController alloc] initWithFrame:CGRectMake(0, 0, 300, 400)
                                   viewIdentifier:1
                                        arguments:nil
                                  binaryMessenger:self.mockBinaryMessenger];
  FLTWKWebView *mockWebView = OCMClassMock(FLTWKWebView.class);
  controller.webView = mockWebView;
  [controller onMethodCall:[FlutterMethodCall methodCallWithMethodName:@"loadHtmlString"
                                                             arguments:@{
                                                               @"html" : @"some HTML string",
                                                               @"baseUrl" : @"https://flutter.dev"
                                                             }]
                    result:^(id _Nullable result) {
                      XCTAssertNil(result);
                      [resultExpectation fulfill];
                    }];

  [self waitForExpectations:@[ resultExpectation ] timeout:30.0];
  OCMVerify([mockWebView loadHTMLString:@"some HTML string" baseURL:baseUrl]);
}

- (void)testLoadHtmlStringSucceedsWithoutBaseUrl {
  XCTestExpectation *resultExpectation =
      [self expectationWithDescription:@"Should return successful result over the method channel."];
  FLTWebViewController *controller =
      [[FLTWebViewController alloc] initWithFrame:CGRectMake(0, 0, 300, 400)
                                   viewIdentifier:1
                                        arguments:nil
                                  binaryMessenger:self.mockBinaryMessenger];
  FLTWKWebView *mockWebView = OCMClassMock(FLTWKWebView.class);
  controller.webView = mockWebView;
  [controller
      onMethodCall:[FlutterMethodCall methodCallWithMethodName:@"loadHtmlString"
                                                     arguments:@{@"html" : @"some HTML string"}]
            result:^(id _Nullable result) {
              XCTAssertNil(result);
              [resultExpectation fulfill];
            }];

  [self waitForExpectations:@[ resultExpectation ] timeout:30.0];
  OCMVerify([mockWebView loadHTMLString:@"some HTML string" baseURL:nil]);
}

- (void)testLoadHtmlStringFailsWithInvalidArgument {
  NSArray *resultExpectations = @[
    [self expectationWithDescription:@"Should return failed result when argument is nil."],
    [self expectationWithDescription:
              @"Should return failed result when argument is not of type NSDictionary*."],
    [self expectationWithDescription:@"Should return failed result when HTML argument is nil."],
    [self expectationWithDescription:
              @"Should return failed result when HTML argument is not of type NSString*."],
    [self expectationWithDescription:
              @"Should return failed result when HTML argument is an empty string."],
  ];

  FLTWebViewController *controller =
      [[FLTWebViewController alloc] initWithFrame:CGRectMake(0, 0, 300, 400)
                                   viewIdentifier:1
                                        arguments:nil
                                  binaryMessenger:self.mockBinaryMessenger];
  FLTWKWebView *mockWebView = OCMClassMock(FLTWKWebView.class);
  controller.webView = mockWebView;
  FlutterError *expected = [FlutterError
      errorWithCode:@"loadHtmlString_failed"
            message:@"Failed parsing arguments."
            details:@"Arguments should be a dictionary containing at least a 'html' element and "
                    @"optionally a 'baseUrl' argument. For example: `@{ @\"html\": @\"some html "
                    @"code\", @\"baseUrl\": @\"https://flutter.dev\" }`"];
  [controller onMethodCall:[FlutterMethodCall methodCallWithMethodName:@"loadHtmlString"
                                                             arguments:nil]
                    result:^(id _Nullable result) {
                      [FLTWebViewTests assertFlutterError:result withExpected:expected];
                      [resultExpectations[0] fulfill];
                    }];
  [controller onMethodCall:[FlutterMethodCall methodCallWithMethodName:@"loadHtmlString"
                                                             arguments:@""]
                    result:^(id _Nullable result) {
                      [FLTWebViewTests assertFlutterError:result withExpected:expected];
                      [resultExpectations[1] fulfill];
                    }];
  [controller onMethodCall:[FlutterMethodCall methodCallWithMethodName:@"loadHtmlString"
                                                             arguments:@{}]
                    result:^(id _Nullable result) {
                      FlutterError *expected =
                          [FlutterError errorWithCode:@"loadHtmlString_failed"
                                              message:@"Failed parsing HTML string argument."
                                              details:@"Argument is nil."];
                      [FLTWebViewTests assertFlutterError:result withExpected:expected];
                      [resultExpectations[2] fulfill];
                    }];
  [controller onMethodCall:[FlutterMethodCall methodCallWithMethodName:@"loadHtmlString"
                                                             arguments:@{
                                                               @"html" : @(42),
                                                             }]
                    result:^(id _Nullable result) {
                      FlutterError *expected =
                          [FlutterError errorWithCode:@"loadHtmlString_failed"
                                              message:@"Failed parsing HTML string argument."
                                              details:@"Argument is not of type NSString."];
                      [FLTWebViewTests assertFlutterError:result withExpected:expected];
                      [resultExpectations[3] fulfill];
                    }];
  [controller onMethodCall:[FlutterMethodCall methodCallWithMethodName:@"loadHtmlString"
                                                             arguments:@{
                                                               @"html" : @"",
                                                             }]
                    result:^(id _Nullable result) {
                      FlutterError *expected =
                          [FlutterError errorWithCode:@"loadHtmlString_failed"
                                              message:@"Failed parsing HTML string argument."
                                              details:@"Argument contains an empty string."];
                      [FLTWebViewTests assertFlutterError:result withExpected:expected];
                      [resultExpectations[4] fulfill];
                    }];

  [self waitForExpectations:resultExpectations timeout:1.0];
  OCMReject([mockWebView loadHTMLString:[OCMArg any] baseURL:[OCMArg any]]);
}

- (void)testRunJavascriptFailsForNullString {
  // Setup
  FLTWebViewController *controller =
      [[FLTWebViewController alloc] initWithFrame:CGRectMake(0, 0, 300, 400)
                                   viewIdentifier:1
                                        arguments:nil
                                  binaryMessenger:self.mockBinaryMessenger];
  XCTestExpectation *resultExpectation =
      [self expectationWithDescription:@"Should return error result over the method channel."];

  // Run
  [controller onMethodCall:[FlutterMethodCall methodCallWithMethodName:@"runJavascript"
                                                             arguments:nil]
                    result:^(id _Nullable result) {
                      XCTAssertTrue([result class] == [FlutterError class]);
                      [resultExpectation fulfill];
                    }];

  // Verify
  [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testRunJavascriptRunsStringWithSuccessResult {
  // Setup
  FLTWebViewController *controller =
      [[FLTWebViewController alloc] initWithFrame:CGRectMake(0, 0, 300, 400)
                                   viewIdentifier:1
                                        arguments:nil
                                  binaryMessenger:self.mockBinaryMessenger];
  XCTestExpectation *resultExpectation =
      [self expectationWithDescription:@"Should return successful result over the method channel."];
  FLTWKWebView *mockView = OCMClassMock(FLTWKWebView.class);
  [OCMStub([mockView evaluateJavaScript:[OCMArg any]
                      completionHandler:[OCMArg any]]) andDo:^(NSInvocation *invocation) {
    // __unsafe_unretained: https://github.com/erikdoe/ocmock/issues/384#issuecomment-589376668
    __unsafe_unretained void (^evalResultHandler)(id, NSError *);
    [invocation getArgument:&evalResultHandler atIndex:3];
    evalResultHandler(@"RESULT", nil);
  }];
  controller.webView = mockView;

  // Run
  [controller onMethodCall:[FlutterMethodCall methodCallWithMethodName:@"runJavascript"
                                                             arguments:@"Test JavaScript String"]
                    result:^(id _Nullable result) {
                      XCTAssertNil(result);
                      [resultExpectation fulfill];
                    }];

  // Verify
  [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testRunJavascriptReturnsErrorResultForWKError {
  // Setup
  FLTWebViewController *controller =
      [[FLTWebViewController alloc] initWithFrame:CGRectMake(0, 0, 300, 400)
                                   viewIdentifier:1
                                        arguments:nil
                                  binaryMessenger:self.mockBinaryMessenger];
  XCTestExpectation *resultExpectation =
      [self expectationWithDescription:@"Should return error result over the method channel."];
  NSError *testError =
      [NSError errorWithDomain:@""
                          // Any error code but WKErrorJavascriptResultTypeIsUnsupported
                          code:WKErrorJavaScriptResultTypeIsUnsupported + 1
                      userInfo:@{NSLocalizedDescriptionKey : @"Test Error"}];
  FLTWKWebView *mockView = OCMClassMock(FLTWKWebView.class);
  [OCMStub([mockView evaluateJavaScript:[OCMArg any]
                      completionHandler:[OCMArg any]]) andDo:^(NSInvocation *invocation) {
    // __unsafe_unretained: https://github.com/erikdoe/ocmock/issues/384#issuecomment-589376668
    __unsafe_unretained void (^evalResultHandler)(id, NSError *);
    [invocation getArgument:&evalResultHandler atIndex:3];
    evalResultHandler(nil, testError);
  }];
  controller.webView = mockView;

  // Run
  [controller onMethodCall:[FlutterMethodCall methodCallWithMethodName:@"runJavascript"
                                                             arguments:@"Test JavaScript String"]
                    result:^(id _Nullable result) {
                      XCTAssertTrue([result class] == [FlutterError class]);
                      [resultExpectation fulfill];
                    }];

  // Verify
  [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testRunJavascriptReturnsSuccessForWKErrorJavascriptResultTypeIsUnsupported {
  // Setup
  FLTWebViewController *controller =
      [[FLTWebViewController alloc] initWithFrame:CGRectMake(0, 0, 300, 400)
                                   viewIdentifier:1
                                        arguments:nil
                                  binaryMessenger:self.mockBinaryMessenger];
  XCTestExpectation *resultExpectation =
      [self expectationWithDescription:@"Should return nil result over the method channel."];
  NSError *testError = [NSError errorWithDomain:@""
                                           code:WKErrorJavaScriptResultTypeIsUnsupported
                                       userInfo:@{NSLocalizedDescriptionKey : @"Test Error"}];
  FLTWKWebView *mockView = OCMClassMock(FLTWKWebView.class);
  [OCMStub([mockView evaluateJavaScript:[OCMArg any]
                      completionHandler:[OCMArg any]]) andDo:^(NSInvocation *invocation) {
    // __unsafe_unretained: https://github.com/erikdoe/ocmock/issues/384#issuecomment-589376668
    __unsafe_unretained void (^evalResultHandler)(id, NSError *);
    [invocation getArgument:&evalResultHandler atIndex:3];
    evalResultHandler(nil, testError);
  }];
  controller.webView = mockView;

  // Run
  [controller onMethodCall:[FlutterMethodCall methodCallWithMethodName:@"runJavascript"
                                                             arguments:@"Test JavaScript String"]
                    result:^(id _Nullable result) {
                      XCTAssertNil(result);
                      [resultExpectation fulfill];
                    }];

  // Verify
  [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testRunJavascriptReturningResultFailsForNullString {
  // Setup
  FLTWebViewController *controller =
      [[FLTWebViewController alloc] initWithFrame:CGRectMake(0, 0, 300, 400)
                                   viewIdentifier:1
                                        arguments:nil
                                  binaryMessenger:self.mockBinaryMessenger];
  XCTestExpectation *resultExpectation =
      [self expectationWithDescription:@"Should return error result over the method channel."];

  // Run
  [controller
      onMethodCall:[FlutterMethodCall methodCallWithMethodName:@"runJavascriptReturningResult"
                                                     arguments:nil]
            result:^(id _Nullable result) {
              XCTAssertTrue([result class] == [FlutterError class]);
              [resultExpectation fulfill];
            }];

  // Verify
  [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testRunJavascriptReturningResultRunsStringWithSuccessResult {
  // Setup
  FLTWebViewController *controller =
      [[FLTWebViewController alloc] initWithFrame:CGRectMake(0, 0, 300, 400)
                                   viewIdentifier:1
                                        arguments:nil
                                  binaryMessenger:self.mockBinaryMessenger];
  XCTestExpectation *resultExpectation =
      [self expectationWithDescription:@"Should return successful result over the method channel."];
  FLTWKWebView *mockView = OCMClassMock(FLTWKWebView.class);
  [OCMStub([mockView evaluateJavaScript:[OCMArg any]
                      completionHandler:[OCMArg any]]) andDo:^(NSInvocation *invocation) {
    // __unsafe_unretained: https://github.com/erikdoe/ocmock/issues/384#issuecomment-589376668
    __unsafe_unretained void (^evalResultHandler)(id, NSError *);
    [invocation getArgument:&evalResultHandler atIndex:3];
    evalResultHandler(@"RESULT", nil);
  }];
  controller.webView = mockView;

  // Run
  [controller
      onMethodCall:[FlutterMethodCall methodCallWithMethodName:@"runJavascriptReturningResult"
                                                     arguments:@"Test JavaScript String"]
            result:^(id _Nullable result) {
              XCTAssertTrue([@"RESULT" isEqualToString:result]);
              [resultExpectation fulfill];
            }];

  // Verify
  [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testRunJavascriptReturningResultReturnsErrorResultForWKError {
  // Setup
  FLTWebViewController *controller =
      [[FLTWebViewController alloc] initWithFrame:CGRectMake(0, 0, 300, 400)
                                   viewIdentifier:1
                                        arguments:nil
                                  binaryMessenger:self.mockBinaryMessenger];
  XCTestExpectation *resultExpectation =
      [self expectationWithDescription:@"Should return error result over the method channel."];
  NSError *testError = [NSError errorWithDomain:@""
                                           code:5
                                       userInfo:@{NSLocalizedDescriptionKey : @"Test Error"}];
  FLTWKWebView *mockView = OCMClassMock(FLTWKWebView.class);
  [OCMStub([mockView evaluateJavaScript:[OCMArg any]
                      completionHandler:[OCMArg any]]) andDo:^(NSInvocation *invocation) {
    // __unsafe_unretained: https://github.com/erikdoe/ocmock/issues/384#issuecomment-589376668
    __unsafe_unretained void (^evalResultHandler)(id, NSError *);
    [invocation getArgument:&evalResultHandler atIndex:3];
    evalResultHandler(nil, testError);
  }];
  controller.webView = mockView;

  // Run
  [controller
      onMethodCall:[FlutterMethodCall methodCallWithMethodName:@"runJavascriptReturningResult"
                                                     arguments:@"Test JavaScript String"]
            result:^(id _Nullable result) {
              XCTAssertTrue([result class] == [FlutterError class]);
              [resultExpectation fulfill];
            }];

  // Verify
  [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

+ (void)assertFlutterError:(id)actual withExpected:(FlutterError *)expected {
  XCTAssertTrue([actual class] == [FlutterError class]);
  FlutterError *errorResult = actual;
  XCTAssertEqualObjects(errorResult.code, expected.code);
  XCTAssertEqualObjects(errorResult.message, expected.message);
  XCTAssertEqualObjects(errorResult.details, expected.details);
}

- (void)testBuildNSURLRequestReturnsNilForNonDictionaryValue {
  // Setup
  FLTWebViewController *controller =
      [[FLTWebViewController alloc] initWithFrame:CGRectMake(0, 0, 300, 400)
                                   viewIdentifier:1
                                        arguments:nil
                                  binaryMessenger:self.mockBinaryMessenger];

  // Run
  NSURLRequest *request = [controller buildNSURLRequest:@{@"request" : @"Non Dictionary Value"}];

  // Verify
  XCTAssertNil(request);
}

- (void)testBuildNSURLRequestReturnsNilForMissingURI {
  // Setup
  FLTWebViewController *controller =
      [[FLTWebViewController alloc] initWithFrame:CGRectMake(0, 0, 300, 400)
                                   viewIdentifier:1
                                        arguments:nil
                                  binaryMessenger:self.mockBinaryMessenger];

  // Run
  NSURLRequest *request = [controller buildNSURLRequest:@{@"request" : @{}}];

  // Verify
  XCTAssertNil(request);
}

- (void)testBuildNSURLRequestReturnsNilForInvalidURI {
  // Setup
  FLTWebViewController *controller =
      [[FLTWebViewController alloc] initWithFrame:CGRectMake(0, 0, 300, 400)
                                   viewIdentifier:1
                                        arguments:nil
                                  binaryMessenger:self.mockBinaryMessenger];

  // Run
  NSDictionary *requestData = @{@"uri" : @"invalid uri"};
  NSURLRequest *request = [controller buildNSURLRequest:@{@"request" : requestData}];

  // Verify
  XCTAssertNil(request);
}

- (void)testBuildNSURLRequestBuildsNSMutableURLRequestWithOptionalParameters {
  // Setup
  FLTWebViewController *controller =
      [[FLTWebViewController alloc] initWithFrame:CGRectMake(0, 0, 300, 400)
                                   viewIdentifier:1
                                        arguments:nil
                                  binaryMessenger:self.mockBinaryMessenger];

  // Run
  NSDictionary *requestData = @{
    @"uri" : @"https://flutter.dev",
    @"method" : @"POST",
    @"headers" : @{@"Foo" : @"Bar"},
    @"body" : [FlutterStandardTypedData
        typedDataWithBytes:[@"Test Data" dataUsingEncoding:NSUTF8StringEncoding]],
  };
  NSURLRequest *request = [controller buildNSURLRequest:@{@"request" : requestData}];

  // Verify
  XCTAssertNotNil(request);
  XCTAssertEqualObjects(request.URL.absoluteString, @"https://flutter.dev");
  XCTAssertEqualObjects(request.HTTPMethod, @"POST");
  XCTAssertEqualObjects(request.allHTTPHeaderFields, @{@"Foo" : @"Bar"});
  XCTAssertEqualObjects(request.HTTPBody, [@"Test Data" dataUsingEncoding:NSUTF8StringEncoding]);
}

- (void)testBuildNSURLRequestBuildsNSMutableURLRequestWithoutOptionalParameters {
  // Setup
  FLTWebViewController *controller =
      [[FLTWebViewController alloc] initWithFrame:CGRectMake(0, 0, 300, 400)
                                   viewIdentifier:1
                                        arguments:nil
                                  binaryMessenger:self.mockBinaryMessenger];

  // Run
  NSDictionary *requestData = @{
    @"uri" : @"https://flutter.dev",
  };
  NSURLRequest *request = [controller buildNSURLRequest:@{@"request" : requestData}];

  // Verify
  XCTAssertNotNil(request);
  XCTAssertEqualObjects(request.URL.absoluteString, @"https://flutter.dev");
  XCTAssertEqualObjects(request.HTTPMethod, @"GET");
  XCTAssertNil(request.allHTTPHeaderFields);
  XCTAssertNil(request.HTTPBody);
}

- (void)testOnLoadUrlReturnsErrorResultForInvalidRequest {
  // Setup
  FLTWebViewController *controller =
      [[FLTWebViewController alloc] initWithFrame:CGRectMake(0, 0, 300, 400)
                                   viewIdentifier:1
                                        arguments:nil
                                  binaryMessenger:self.mockBinaryMessenger];
  XCTestExpectation *resultExpectation =
      [self expectationWithDescription:@"Should return error result when request cannot be built"];

  // Run
  FlutterMethodCall *methodCall = [FlutterMethodCall methodCallWithMethodName:@"loadUrl"
                                                                    arguments:@{}];
  [controller onLoadUrl:methodCall
                 result:^(id _Nullable result) {
                   XCTAssertTrue([result class] == [FlutterError class]);
                   [resultExpectation fulfill];
                 }];

  // Verify
  [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testOnLoadUrlLoadsRequestWithSuccessResult {
  // Setup
  FLTWebViewController *controller =
      [[FLTWebViewController alloc] initWithFrame:CGRectMake(0, 0, 300, 400)
                                   viewIdentifier:1
                                        arguments:nil
                                  binaryMessenger:self.mockBinaryMessenger];
  XCTestExpectation *resultExpectation = [self expectationWithDescription:@"Should return nil"];
  FLTWKWebView *mockView = OCMClassMock(FLTWKWebView.class);
  controller.webView = mockView;

  // Run
  FlutterMethodCall *methodCall =
      [FlutterMethodCall methodCallWithMethodName:@"loadUrl"
                                        arguments:@{@"url" : @"https://flutter.dev/"}];
  [controller onLoadUrl:methodCall
                 result:^(id _Nullable result) {
                   XCTAssertNil(result);
                   [resultExpectation fulfill];
                 }];

  // Verify
  OCMVerify([mockView loadRequest:[OCMArg any]]);
  [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testOnLoadRequestReturnsErrorResultForInvalidRequest {
  // Setup
  FLTWebViewController *controller =
      [[FLTWebViewController alloc] initWithFrame:CGRectMake(0, 0, 300, 400)
                                   viewIdentifier:1
                                        arguments:nil
                                  binaryMessenger:self.mockBinaryMessenger];
  XCTestExpectation *resultExpectation =
      [self expectationWithDescription:@"Should return error result when request cannot be built"];

  // Run
  FlutterMethodCall *methodCall = [FlutterMethodCall methodCallWithMethodName:@"loadRequest"
                                                                    arguments:@{}];
  [controller onLoadRequest:methodCall
                     result:^(id _Nullable result) {
                       XCTAssertTrue([result class] == [FlutterError class]);
                       [resultExpectation fulfill];
                     }];

  // Verify
  [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testOnLoadRequestLoadsRequestWithSuccessResult {
  // Setup
  FLTWebViewController *controller =
      [[FLTWebViewController alloc] initWithFrame:CGRectMake(0, 0, 300, 400)
                                   viewIdentifier:1
                                        arguments:nil
                                  binaryMessenger:self.mockBinaryMessenger];
  XCTestExpectation *resultExpectation = [self expectationWithDescription:@"Should return nil"];
  FLTWKWebView *mockView = OCMClassMock(FLTWKWebView.class);
  controller.webView = mockView;

  // Run
  FlutterMethodCall *methodCall = [FlutterMethodCall
      methodCallWithMethodName:@"loadRequest"
                     arguments:@{@"request" : @{@"uri" : @"https://flutter.dev/"}}];
  [controller onLoadRequest:methodCall
                     result:^(id _Nullable result) {
                       XCTAssertNil(result);
                       [resultExpectation fulfill];
                     }];

  // Verify
  OCMVerify([mockView loadRequest:[OCMArg any]]);
  [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testCreateWithFrameShouldSetCookiesOnIOS11 {
  if (@available(iOS 11, *)) {
    // Setup
    FLTWebViewFactory *factory =
        [[FLTWebViewFactory alloc] initWithMessenger:self.mockBinaryMessenger
                                       cookieManager:self.mockCookieManager];
    NSArray<NSDictionary *> *cookies =
        @[ @{@"name" : @"foo", @"value" : @"bar", @"domain" : @"flutter.dev", @"path" : @"/"} ];
    // Run
    [factory createWithFrame:CGRectMake(0, 0, 300, 400)
              viewIdentifier:1
                   arguments:@{@"cookies" : cookies}];
    // Verify
    OCMVerify([_mockCookieManager setCookiesForData:cookies]);
  }
}

@end
