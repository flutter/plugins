// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;
@import webview_flutter_wkwebview;

// OCMock library doesn't generate a valid modulemap.
#import <OCMock/OCMock.h>

static bool feq(CGFloat a, CGFloat b) { return fabs(b - a) < FLT_EPSILON; }

@interface FLTWebViewTests : XCTestCase

@property(strong, nonatomic) NSObject<FlutterBinaryMessenger> *mockBinaryMessenger;

@end

@implementation FLTWebViewTests {
  WKWebView *_mockWebView;
  FLTWebViewController *_testWebViewController;
}

- (void)setUp {
  self.mockBinaryMessenger = OCMProtocolMock(@protocol(FlutterBinaryMessenger));
  _mockWebView = OCMClassMock(WKWebView.class);
  _testWebViewController = [[FLTWebViewController alloc] init];
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
  FLTWebViewFactory *factory =
      [[FLTWebViewFactory alloc] initWithMessenger:self.mockBinaryMessenger];
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

- (void)testLoadUrl {
  [_testWebViewController webView:_mockWebView
                          loadUrl:@"https://www.google.com"
                      withHeaders:@{@"a" : @"header"}];

  NSURL *nsUrl = [NSURL URLWithString:@"https://www.google.com"];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:nsUrl];
  [request setAllHTTPHeaderFields:@{@"a" : @"header"}];
  OCMVerify([_mockWebView loadRequest:request]);
}

- (void)testCanGoBack {
  OCMStub([_mockWebView canGoBack]).andReturn(NO);
  XCTAssertEqualObjects([_testWebViewController webViewCanGoBack:_mockWebView], @(NO));
}

- (void)testCanGoForward {
  OCMStub([_mockWebView canGoForward]).andReturn(YES);
  XCTAssertEqualObjects([_testWebViewController webViewCanGoForward:_mockWebView], @(YES));
}

- (void)testGoBack {
  [_testWebViewController webViewGoBack:_mockWebView];
  OCMVerify([_mockWebView goBack]);
}

- (void)testGoForward {
  [_testWebViewController webViewGoForward:_mockWebView];
  OCMVerify([_mockWebView goForward]);
}

- (void)testReload {
  [_testWebViewController webViewReload:_mockWebView];
  OCMVerify([_mockWebView reload]);
}

- (void)testCurrentUrlForWebView {
  OCMStub([_mockWebView URL]).andReturn([NSURL URLWithString:@"https://www.google.com"]);
  XCTAssertEqualObjects([_testWebViewController currentUrlForWebView:_mockWebView],
                        @"https://www.google.com");
}

- (void)testEvaluateJavaScript {
  OCMStub([_mockWebView evaluateJavaScript:@"run javascript;"
                         completionHandler:[OCMArg checkWithBlock:^BOOL(id obj) {
                           void (^resultBlock)(id, NSError *) = obj;
                           resultBlock(@"returnValue", nil);
                           return YES;
                         }]]);

  __block NSString *resultValue;
  [_testWebViewController webView:_mockWebView
               evaluateJavaScript:@"run javascript;"
                           result:^(id _Nullable result) {
                             resultValue = result;
                           }];

  XCTAssertEqualObjects(resultValue, @"returnValue");
}

- (void)testTitleForWebView {
  OCMStub([_mockWebView title]).andReturn(@"My Title");
  XCTAssertEqualObjects([_testWebViewController titleForWebView:_mockWebView], @"My Title");
}
@end
