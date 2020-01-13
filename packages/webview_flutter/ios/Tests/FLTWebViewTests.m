// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import OCMock;
@import XCTest;
@import webview_flutter;

bool feq(CGFloat a, CGFloat b) {
  return fabs(b-a) < FLT_EPSILON;
}

@interface FLTWebViewTests : XCTestCase

@property(strong, nonatomic) NSObject<FlutterBinaryMessenger> *mockBinaryMessenger;

@end

@implementation FLTWebViewTests

- (void)setUp {
  [super setUp];
  self.mockBinaryMessenger = OCMProtocolMock(@protocol(FlutterBinaryMessenger));
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

- (void)testWebViewContentInsetsSumAlways0 {
  FLTWebViewController *controller =
      [[FLTWebViewController alloc] initWithFrame:CGRectMake(0, 0, 300, 400)
                                   viewIdentifier:1
                                        arguments:nil
                                  binaryMessenger:self.mockBinaryMessenger];
  UIView *view = controller.view;
  XCTAssertTrue([view isKindOfClass:WKWebView.class]);
  WKWebView *webView = (WKWebView *)view;
  [[NSNotificationCenter defaultCenter] postNotificationName:UIKeyboardWillChangeFrameNotification object:self];
  webView.frame = CGRectMake(0, 0, 300, 300);

  XCTNSNotificationExpectation *expectation = [[XCTNSNotificationExpectation alloc] initWithName:UIKeyboardWillChangeFrameNotification];

  XCTWaiter *waiter = [XCTWaiter new];
  NSLog(@"~~~> %@", @(webView.scrollView.contentInset));
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

    NSLog(@"~~~? %@", @(webView.scrollView.contentInset));

    if (@available(iOS 11, *)) {
      UIEdgeInsets contentInset = webView.scrollView.contentInset;
      UIEdgeInsets adjustedContentInset = webView.scrollView.adjustedContentInset;
      XCTAssertTrue(feq(contentInset.top, -adjustedContentInset.top));
      XCTAssertTrue(feq(contentInset.left, -adjustedContentInset.left));
      XCTAssertTrue(feq(contentInset.bottom, -adjustedContentInset.bottom));
      XCTAssertTrue(feq(contentInset.right, -adjustedContentInset.right));
    } else {
      XCTAssertTrue(UIEdgeInsetsEqualToEdgeInsets(webView.scrollView.contentInset, UIEdgeInsetsZero));
    }
  });
  [waiter waitForExpectations:@[expectation] timeout:5];
}

@end
