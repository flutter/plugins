// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;
@import webview_flutter_wkwebview;
@import webview_flutter_wkwebview.Test;

// OCMock library doesn't generate a valid modulemap.
#import <OCMock/OCMock.h>

@interface FLTWKNavigationDelegateTests : XCTestCase

@property(strong, nonatomic) FlutterMethodChannel *mockMethodChannel;
@property(strong, nonatomic) FLTWKNavigationDelegate *navigationDelegate;
@property(strong, nonatomic) WKNavigation *navigation;

@end

@implementation FLTWKNavigationDelegateTests

NSString *const zoomDisablingJavascript =
    @"var meta = document.createElement('meta');"
    @"meta.name = 'viewport';"
    @"meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0,"
    @"user-scalable=no';"
    @"var head = document.getElementsByTagName('head')[0];head.appendChild(meta);";

- (void)setUp {
  self.mockMethodChannel = OCMClassMock(FlutterMethodChannel.class);
  self.navigationDelegate =
      [[FLTWKNavigationDelegate alloc] initWithChannel:self.mockMethodChannel];
}

- (void)testWebViewWebContentProcessDidTerminateCallsRecourseErrorChannel {
  if (@available(iOS 9.0, *)) {
    // `webViewWebContentProcessDidTerminate` is only available on iOS 9.0 and above.
    WKWebView *webview = OCMClassMock(WKWebView.class);
    [self.navigationDelegate webViewWebContentProcessDidTerminate:webview];
    OCMVerify([self.mockMethodChannel
        invokeMethod:@"onWebResourceError"
           arguments:[OCMArg checkWithBlock:^BOOL(NSDictionary *args) {
             XCTAssertEqualObjects(args[@"errorType"], @"webContentProcessTerminated");
             return true;
           }]]);
  }
}

- (void)testWebViewWebEvaluateJavaScriptSourceIsCorrectWhenShouldEnableZoomIsFalse {
  WKWebView *webview = OCMClassMock(WKWebView.class);
  WKNavigation *navigation = OCMClassMock(WKNavigation.class);
  NSURL *testUrl = [[NSURL alloc] initWithString:@"www.example.com"];
  OCMStub([webview URL]).andReturn(testUrl);

  self.navigationDelegate.shouldEnableZoom = false;
  [self.navigationDelegate webView:webview didFinishNavigation:navigation];
  OCMVerify([webview evaluateJavaScript:zoomDisablingJavascript completionHandler:nil]);
}

- (void)testWebViewWebEvaluateJavaScriptShouldNotBeCalledWhenShouldEnableZoomIsTrue {
  WKWebView *webview = OCMClassMock(WKWebView.class);
  WKNavigation *navigation = OCMClassMock(WKNavigation.class);
  NSURL *testUrl = [[NSURL alloc] initWithString:@"www.example.com"];
  OCMStub([webview URL]).andReturn(testUrl);

  self.navigationDelegate.shouldEnableZoom = true;

  OCMReject([webview evaluateJavaScript:zoomDisablingJavascript completionHandler:nil]);
  [self.navigationDelegate webView:webview didFinishNavigation:navigation];
}

@end
