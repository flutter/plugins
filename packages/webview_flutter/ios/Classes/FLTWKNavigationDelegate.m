// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTWKNavigationDelegate.h"

@implementation FLTWKNavigationDelegate {
  FlutterMethodChannel *_methodChannel;
}

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel {
  self = [super init];
  if (self) {
    _methodChannel = channel;
  }
  return self;
}

- (void)webView:(WKWebView *)webView
    decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
                    decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
  if (!self.hasDartNavigationDelegate) {
    decisionHandler(WKNavigationActionPolicyAllow);
    return;
  }
  NSDictionary *arguments = @{
    @"url" : navigationAction.request.URL.absoluteString,
    @"isForMainFrame" : @(navigationAction.targetFrame.isMainFrame)
  };
  [_methodChannel invokeMethod:@"navigationRequest"
                     arguments:arguments
                        result:^(id _Nullable result) {
                          if ([result isKindOfClass:[FlutterError class]]) {
                            NSLog(@"navigationRequest has unexpectedly completed with an error, "
                                  @"allowing navigation.");
                            decisionHandler(WKNavigationActionPolicyAllow);
                            return;
                          }
                          if (result == FlutterMethodNotImplemented) {
                            NSLog(@"navigationRequest was unexepectedly not implemented: %@, "
                                  @"allowing navigation.",
                                  result);
                            decisionHandler(WKNavigationActionPolicyAllow);
                            return;
                          }
                          if (![result isKindOfClass:[NSNumber class]]) {
                            NSLog(@"navigationRequest unexpectedly returned a non boolean value: "
                                  @"%@, allowing navigation.",
                                  result);
                            decisionHandler(WKNavigationActionPolicyAllow);
                            return;
                          }
                          NSNumber *typedResult = result;
                          decisionHandler([typedResult boolValue] ? WKNavigationActionPolicyAllow
                                                                  : WKNavigationActionPolicyCancel);
                        }];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
  [_methodChannel invokeMethod:@"onPageFinished" arguments:@{@"url" : webView.URL.absoluteString}];
}

// copied from
// https://github.com/chromium/chromium/blob/master/ios/web/web_state/ui/web_kit_constants.h
typedef NS_ENUM(NSInteger, WebKitError) {
  // Can not change location URL.
  WebKitErrorCannotShowUrl = 101,
};

- (NSString *)parseErrorCode:(NSInteger)errorCode {
  switch (errorCode) {
    case WebKitErrorCannotShowUrl:
    case NSURLErrorNotConnectedToInternet:
    case NSURLErrorCannotFindHost:
    case NSURLErrorUnsupportedURL:
    case NSURLErrorBadURL:
      return @"connect";
    case NSURLErrorSecureConnectionFailed:
    case NSURLErrorServerCertificateUntrusted:
    case NSURLErrorServerCertificateHasBadDate:
    case NSURLErrorServerCertificateNotYetValid:
    case NSURLErrorServerCertificateHasUnknownRoot:
      return @"failedSslHandshake";
    case NSURLErrorHTTPTooManyRedirects:
      return @"redirectLoop";
    default:
      return @"unknown";
  }
}

- (void)webView:(WKWebView *)webView
    didFailProvisionalNavigation:(WKNavigation *)navigation
                       withError:(NSError *)error {
  [_methodChannel invokeMethod:@"onReceivedError"
                     arguments:@{
                       @"isConnectError" : @YES,
                       @"url" : error.userInfo[NSURLErrorFailingURLStringErrorKey]
                           ?: webView.URL.absoluteString ?: [NSNull null],
                       @"description" : [error localizedDescription],
                       @"connectErrorType" : [self parseErrorCode:error.code],
                     }];
}

- (void)webView:(WKWebView *)webView
    didFailNavigation:(WKNavigation *)navigation
            withError:(NSError *)error {
  [_methodChannel invokeMethod:@"onReceivedError"
                     arguments:@{
                       @"isConnectError" : @YES,
                       @"url" : webView.URL.absoluteString,
                       @"description" : [error localizedDescription],
                       @"connectErrorType" : [self parseErrorCode:error.code],
                     }];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
  [_methodChannel invokeMethod:@"onPageStarted"
                     arguments:@{
                       @"url" : webView.URL.absoluteString ?: [NSNull null],
                     }];
}

- (void)webView:(WKWebView *)webView
    decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse
                      decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
  if ([navigationResponse.response isKindOfClass:[NSHTTPURLResponse class]]) {
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
    if (response.statusCode >= 400 && response.statusCode < 600) {
      [_methodChannel invokeMethod:@"onReceivedError"
                         arguments:@{
                           @"isConnectError" : @NO,
                           @"url" : response.URL.absoluteString,
                           @"statusCode" : @(response.statusCode),
                           @"description" :
                               [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode],
                         }];
    }
  }

  decisionHandler(WKNavigationResponsePolicyAllow);
}

@end
