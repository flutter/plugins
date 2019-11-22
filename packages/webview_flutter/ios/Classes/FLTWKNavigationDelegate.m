// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTWKNavigationDelegate.h"

@implementation FLTWKNavigationDelegate {
  FlutterMethodChannel* _methodChannel;
}

- (instancetype)initWithChannel:(FlutterMethodChannel*)channel {
  self = [super init];
  if (self) {
    _methodChannel = channel;
  }
  return self;
}

#pragma mark - WKNavigationDelegate conformance

- (void)webView:(WKWebView*)webView didStartProvisionalNavigation:(WKNavigation*)navigation {
  [_methodChannel invokeMethod:@"onPageStarted" arguments:@{@"url" : webView.URL.absoluteString}];
}

- (void)webView:(WKWebView*)webView
    decidePolicyForNavigationAction:(WKNavigationAction*)navigationAction
                    decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
  if (!self.hasDartNavigationDelegate) {
    decisionHandler(WKNavigationActionPolicyAllow);
    return;
  }
  NSDictionary* arguments = @{
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
                          NSNumber* typedResult = result;
                          decisionHandler([typedResult boolValue] ? WKNavigationActionPolicyAllow
                                                                  : WKNavigationActionPolicyCancel);
                        }];
}

- (void)webView:(WKWebView*)webView didFinishNavigation:(WKNavigation*)navigation {
  [_methodChannel invokeMethod:@"onPageFinished" arguments:@{@"url" : webView.URL.absoluteString}];
}
@end
