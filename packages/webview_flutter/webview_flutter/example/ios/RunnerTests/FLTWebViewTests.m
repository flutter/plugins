// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;
@import webview_flutter;

// OCMock library doesn't generate a valid modulemap.
#import <OCMock/OCMock.h>

static bool feq(CGFloat a, CGFloat b) { return fabs(b - a) < FLT_EPSILON; }

@interface FLTWebViewController (Test)
- (NSURLRequest *)buildNSURLRequest:(NSString *)method
                          arguments:(NSDictionary<NSString *, id> *)arguments;
- (void)onPostUrl:(FlutterMethodCall *)call result:(FlutterResult)result;
- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger;

@end

@interface MockFLTWKWebView : FLTWKWebView
@property(nonatomic, nullable) NSMutableURLRequest *receivedResult;
@end

@implementation MockFLTWKWebView

- (WKNavigation *)loadRequest:(NSMutableURLRequest *)request {
  _receivedResult = request;
  return nil;
}

@end

@interface MockFLTWebViewController : FLTWebViewController

@end

@implementation MockFLTWebViewController {
  MockFLTWKWebView *mockFLTWKWebView;
}

- (FLTWKWebView *)createFLTWKWebViewWithFrame:(CGRect)frame
                                configuration:(WKWebViewConfiguration *)configuration
                           navigationDelegate:(FLTWKNavigationDelegate *)navigationDelegate {
  mockFLTWKWebView = [MockFLTWKWebView new];
  return mockFLTWKWebView;
}

- (MockFLTWKWebView *)getResultObject {
  return mockFLTWKWebView;
}

@end

@interface MockFLTWebViewControllerForOnPostUrl : FLTWebViewController
- (instancetype)initWithBuildNSURLRequest:(NSURLRequest *)buildNSURLRequestResult;
@end

@implementation MockFLTWebViewControllerForOnPostUrl {
  NSURLRequest *_buildNSURLRequestResult;
}

- (instancetype)initWithBuildNSURLRequest:(NSURLRequest *)buildNSURLRequestResult {
  _buildNSURLRequestResult = buildNSURLRequestResult;
  return self;
}

- (NSURLRequest *)buildNSURLRequest:(NSString *)method
                          arguments:(NSDictionary<NSString *, id> *)arguments {
  return _buildNSURLRequestResult;
}

@end

@interface FLTWebViewTests : XCTestCase

@property(strong, nonatomic) NSObject<FlutterBinaryMessenger> *mockBinaryMessenger;

@end

@implementation FLTWebViewTests

- (void)setUp {
  [super setUp];
  self.mockBinaryMessenger = OCMProtocolMock(@protocol(FlutterBinaryMessenger));
}

- (void)testbuildNSURLRequest_should_return_nil_when_arguments_is_nil {
  id arguments = nil;

  MockFLTWebViewController *mockController =
      [[MockFLTWebViewController alloc] initWithFrame:CGRectMake(0, 0, 300, 400)
                                       viewIdentifier:1
                                            arguments:nil
                                      binaryMessenger:self.mockBinaryMessenger];

  id result = [mockController buildNSURLRequest:@"POST" arguments:arguments];

  XCTAssertNil(result);
}

- (void)testbuildNSURLRequest_should_return_nil_when_url_is_not_NSString {
  NSError *url = [NSError new];
  NSDictionary<NSString *, id> *arguments = @{@"url" : url};

  FLTWebViewController *controller =
      [[FLTWebViewController alloc] initWithFrame:CGRectMake(0, 0, 300, 400)
                                   viewIdentifier:1
                                        arguments:nil
                                  binaryMessenger:self.mockBinaryMessenger];

  id result = [controller buildNSURLRequest:@"POST" arguments:arguments];

  XCTAssertNil(result);
}

- (void)testbuildNSURLRequest_should_return_nil_when_url_is_not_valid {
  NSString *url = @"#<>%";
  NSDictionary<NSString *, id> *arguments = @{@"url" : url};

  FLTWebViewController *controller =
      [[FLTWebViewController alloc] initWithFrame:CGRectMake(0, 0, 300, 400)
                                   viewIdentifier:1
                                        arguments:nil
                                  binaryMessenger:self.mockBinaryMessenger];

  id result = [controller buildNSURLRequest:@"POST" arguments:arguments];

  XCTAssertNil(result);
}

- (void)testbuildNSURLRequest_should_return_NSURLRequest_when_arguments_are_valid {
  NSString *url = @"http://example.com";
  NSString *str = [NSString stringWithFormat:@"name=%@&pass=%@", @"john", @"123"];
  NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
  FlutterStandardTypedData *postData = [FlutterStandardTypedData typedDataWithBytes:data];

  FlutterMethodCall *call =
      [FlutterMethodCall methodCallWithMethodName:@"postUrl"
                                        arguments:@{@"url" : url, @"postData" : postData}];

  FLTWebViewController *controller =
      [[FLTWebViewController alloc] initWithFrame:CGRectMake(0, 0, 300, 400)
                                   viewIdentifier:1
                                        arguments:nil
                                  binaryMessenger:self.mockBinaryMessenger];

  NSURLRequest *result = [controller buildNSURLRequest:@"POST" arguments:[call arguments]];
  NSString *decodedHTTPBody = [[NSString alloc] initWithData:result.HTTPBody
                                                    encoding:NSUTF8StringEncoding];

  XCTAssertNotNil(result);
  XCTAssertTrue([decodedHTTPBody isEqualToString:str]);
  XCTAssertTrue([result.HTTPMethod isEqualToString:@"POST"]);
  XCTAssertTrue([result.URL.absoluteString isEqualToString:url]);
}

- (void)testOnPostUrl_should_call_result_flutter_error_when_NSURLRequest_is_nil {
  MockFLTWebViewControllerForOnPostUrl *mockController =
      [[MockFLTWebViewControllerForOnPostUrl alloc] initWithBuildNSURLRequest:nil];

  __block FlutterError *result = nil;

  [mockController onPostUrl:nil
                     result:^(id _Nullable r) {
                       result = r;
                     }];

  XCTAssertEqualObjects(result.code, @"postUrl_failed");
}

- (void)testOnPostUrl_should_call_result_nil_when_NSURLRequest_is_not_nil {
  NSString *url = @"http://example.com";
  NSURL *nsUrl = [NSURL URLWithString:url];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:nsUrl];

  MockFLTWebViewControllerForOnPostUrl *mockController =
      [[MockFLTWebViewControllerForOnPostUrl alloc] initWithBuildNSURLRequest:request];

  __block id result = @"test";

  [mockController onPostUrl:nil
                     result:^(id _Nullable r) {
                       result = r;
                     }];

  XCTAssertEqual(result, nil);
}

- (void)testOnPostUrl_should_call_webview_loadRequest_when_NSURLRequest_is_not_nil {
  NSString *url = @"http://example.com";
  NSString *str = [NSString stringWithFormat:@"name=%@&pass=%@", @"john", @"123"];
  NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
  FlutterStandardTypedData *postData = [FlutterStandardTypedData typedDataWithBytes:data];

  FlutterMethodCall *call =
      [FlutterMethodCall methodCallWithMethodName:@"postUrl"
                                        arguments:@{@"url" : url, @"postData" : postData}];

  MockFLTWebViewController *mockController =
      [[MockFLTWebViewController alloc] initWithFrame:CGRectMake(0, 0, 300, 400)
                                       viewIdentifier:1
                                            arguments:nil
                                      binaryMessenger:self.mockBinaryMessenger];

  [mockController onPostUrl:call
                     result:^(id _Nullable r){
                     }];

  NSString *decodedHTTPBody =
      [[NSString alloc] initWithData:[mockController getResultObject].receivedResult.HTTPBody
                            encoding:NSUTF8StringEncoding];

  XCTAssertTrue([decodedHTTPBody isEqualToString:str]);
  XCTAssertTrue(
      [[mockController getResultObject].receivedResult.HTTPMethod isEqualToString:@"POST"]);
  XCTAssertTrue(
      [[mockController getResultObject].receivedResult.URL.absoluteString isEqualToString:url]);
}

// implemetation sinifinda gereksiz methodalari kaldir.
// implementation class ta method commentlerini yaz
// Pr pushla ve mauritten feedback iste.s

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

@end
