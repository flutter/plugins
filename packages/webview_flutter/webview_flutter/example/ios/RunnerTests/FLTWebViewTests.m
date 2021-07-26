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
- (bool)postUrl:(NSString *)url withBody:(FlutterStandardTypedData *)postData;
- (void)onPostUrl:(FlutterMethodCall *)call result:(FlutterResult)result;
- (bool)postRequest:(NSDictionary<NSString *, id> *)request;
@end

@interface MockFLTWebViewControllerForOnPostUrl : FLTWebViewController
- (instancetype)initWithPostRequest:(BOOL)postRequestResult;
@end

@implementation MockFLTWebViewControllerForOnPostUrl {
  bool _postRequestResult;
}

- (instancetype)initWithPostRequest:(bool)postRequestResult {
  _postRequestResult = postRequestResult;
  return self;
}

- (bool)postRequest:(NSDictionary<NSString *, id> *)request {
  return _postRequestResult;
}

@end

@interface MockFLTWebViewControllerForPostRequest : FLTWebViewController
- (instancetype)initWithPostUrl:(BOOL)postUrlResult;
@end

@implementation MockFLTWebViewControllerForPostRequest {
  bool _postUrlResult;
}

- (instancetype)initWithPostUrl:(bool)postUrlResult {
  _postUrlResult = postUrlResult;
  return self;
}

- (bool)postUrl:(NSString *)url withBody:(FlutterStandardTypedData *)postData {
  return _postUrlResult;
}

@end

@interface MockWKWebViewForPostUrl : FLTWKWebView
@property(nonatomic, nullable) NSMutableURLRequest *receivedResult;
@end

@implementation MockWKWebViewForPostUrl

- (WKNavigation *)loadRequest:(NSMutableURLRequest *)request {
  _receivedResult = request;
  return nil;
}

@end

@interface MockFLTWebViewController : FLTWebViewController

@end

@implementation MockFLTWebViewController {
  MockWKWebViewForPostUrl *mockFLTWKWebView;
}

- (FLTWKWebView *)createFLTWKWebViewWithFrame:(CGRect)frame
                                configuration:(WKWebViewConfiguration *)configuration
                           navigationDelegate:(FLTWKNavigationDelegate *)navigationDelegate {
  mockFLTWKWebView = [MockWKWebViewForPostUrl new];
  return mockFLTWKWebView;
}

- (MockWKWebViewForPostUrl *)getResultObject {
  return mockFLTWKWebView;
}

@end

@interface FLTWebViewTests : XCTestCase

@property(strong, nonatomic) NSObject<FlutterBinaryMessenger> *mockBinaryMessenger;

@end

@implementation FLTWebViewTests

- (void)setUp {
  [super setUp];
  self.mockBinaryMessenger = OCMProtocolMock(@protocol(FlutterBinaryMessenger));
  _resultObject = [MockWKWebViewForPostUrl new];
}

- (void)testPostUrl_should_return_false_when_url_is_nil {
  // Initialise data
  NSString *url = nil;
  NSString *str = [NSString stringWithFormat:@"name=%@&pass=%@", @"john", @"123"];
  NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
  FlutterStandardTypedData *postData = [FlutterStandardTypedData typedDataWithBytes:data];

  FLTWebViewController *controller = [[FLTWebViewController alloc] initWithWebView:_resultObject];

  // Run test
  bool result = [controller postUrl:url withBody:postData];

  XCTAssertFalse(result);
}

- (void)testPostUrl_should_return_true_when_url_is_not_nil {
  // Initialise data
  NSString *url = @"http://example.com";
  NSString *str = [NSString stringWithFormat:@"name=%@&pass=%@", @"john", @"123"];
  NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
  FlutterStandardTypedData *postData = [FlutterStandardTypedData typedDataWithBytes:data];

  FLTWebViewController *controller = [[FLTWebViewController alloc] initWithWebView:_resultObject];

  // Run test
  bool result = [controller postUrl:url withBody:postData];
  NSString *decodedHTTPBody = [[NSString alloc] initWithData:_resultObject.receivedResult.HTTPBody
                                                    encoding:NSUTF8StringEncoding];

  XCTAssertTrue(result);
  XCTAssertTrue([decodedHTTPBody isEqualToString:str]);
  XCTAssertTrue([_resultObject.receivedResult.HTTPMethod isEqualToString:@"POST"]);
  XCTAssertTrue([_resultObject.receivedResult.URL.absoluteString isEqualToString:url]);
}

- (void)testOnPostUrl_should_call_result_flutter_error_when_postRequest_return_false {
  MockFLTWebViewControllerForOnPostUrl *mockController =
      [[MockFLTWebViewControllerForOnPostUrl alloc] initWithPostRequest:false];

  __block FlutterError *result = nil;

  [mockController onPostUrl:nil
                     result:^(id _Nullable r) {
                       result = r;
                     }];

  XCTAssertEqualObjects(result.code, @"postUrl_failed");
}

- (void)testOnPostUrl_should_call_result_nil_when_postRequest_return_true {
  MockFLTWebViewControllerForOnPostUrl *mockController =
      [[MockFLTWebViewControllerForOnPostUrl alloc] initWithPostRequest:true];

  __block id result = @"test";

  [mockController onPostUrl:nil
                     result:^(id _Nullable r) {
                       result = r;
                     }];

  XCTAssertEqual(result, nil);
}

- (void)testPostRequest_should_return_false_when_request_is_nil {
  FLTWebViewController *controller = [[FLTWebViewController alloc] initWithWebView:_resultObject];

  bool result = [controller postRequest:nil];

  XCTAssertFalse(result);
}

- (void)testPostRequest_should_return_false_when_postUrl_return_false {
  NSString *url = @"http://example.com";
  NSString *str = [NSString stringWithFormat:@"name=%@&pass=%@", @"john", @"123"];
  NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
  FlutterStandardTypedData *postData = [FlutterStandardTypedData typedDataWithBytes:data];

  FlutterMethodCall *call =
      [FlutterMethodCall methodCallWithMethodName:@"postUrl"
                                        arguments:@{@"url" : url, @"postData" : postData}];

  MockFLTWebViewControllerForPostRequest *mockController =
      [[MockFLTWebViewControllerForPostRequest alloc] initWithPostUrl:false];

  bool result = [mockController postRequest:[call arguments]];

  XCTAssertFalse(result);
}

- (void)testPostRequest_should_return_true_when_postUrl_return_true {
  NSString *url = @"http://example.com";
  NSString *str = [NSString stringWithFormat:@"name=%@&pass=%@", @"john", @"123"];
  NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
  FlutterStandardTypedData *postData = [FlutterStandardTypedData typedDataWithBytes:data];

  FlutterMethodCall *call =
      [FlutterMethodCall methodCallWithMethodName:@"postUrl"
                                        arguments:@{@"url" : url, @"postData" : postData}];

  MockFLTWebViewControllerForPostRequest *mockController =
      [[MockFLTWebViewControllerForPostRequest alloc] initWithPostUrl:true];

  bool result = [mockController postRequest:[call arguments]];

  XCTAssertTrue(result);
}

- (void)testPostRequest_should_return_false_when_url_is_not_NSString {
  NSError *url = [NSError new];
  NSString *str = [NSString stringWithFormat:@"name=%@&pass=%@", @"john", @"123"];
  NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
  FlutterStandardTypedData *postData = [FlutterStandardTypedData typedDataWithBytes:data];

  FlutterMethodCall *call =
      [FlutterMethodCall methodCallWithMethodName:@"postUrl"
                                        arguments:@{@"url" : url, @"postData" : postData}];

  MockFLTWebViewControllerForPostRequest *mockController =
      [[MockFLTWebViewControllerForPostRequest alloc] initWithPostUrl:true];

  bool result = [mockController postRequest:[call arguments]];

  XCTAssertFalse(result);
}

- (void)testPostRequest_should_return_false_when_postData_is_not_FlutterStandardTypedData {
  NSString *url = @"http://example.com";
  NSString *str = [NSString stringWithFormat:@"name=%@&pass=%@", @"john", @"123"];
  NSData *postData = [str dataUsingEncoding:NSUTF8StringEncoding];

  FlutterMethodCall *call =
      [FlutterMethodCall methodCallWithMethodName:@"postUrl"
                                        arguments:@{@"url" : url, @"postData" : postData}];

  MockFLTWebViewControllerForPostRequest *mockController =
      [[MockFLTWebViewControllerForPostRequest alloc] initWithPostUrl:true];

  bool result = [mockController postRequest:[call arguments]];

  XCTAssertFalse(result);
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

@end
