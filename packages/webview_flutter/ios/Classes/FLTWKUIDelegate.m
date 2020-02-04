// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTWKUIDelegate.h"

@implementation FLTWKUIDelegate {
  FlutterMethodChannel* _methodChannel;
}

- (instancetype)initWithChannel:(FlutterMethodChannel*)channel {
  self = [super init];
  if (self) {
    _methodChannel = channel;
  }
  return self;
}

#pragma mark - WKUIDelegate conformance

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
  [_methodChannel invokeMethod:@"onJsAlert" arguments:@{@"url": webView.URL.absoluteString, @"message": message} result:^(id  _Nullable result) {
    completionHandler();
  }];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler
{
  [_methodChannel invokeMethod:@"onJsConfirm" arguments:@{@"url": webView.URL.absoluteString, @"message": message} result:^(id  _Nullable result) {
    NSNumber* b = result;
    completionHandler([b boolValue]);
  }];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *result))completionHandler
{
  [_methodChannel invokeMethod:@"onJsPrompt" arguments:@{@"url": webView.URL.absoluteString, @"message": prompt, @"defaultText": defaultText} result:^(id  _Nullable result) {
    NSString *str = result;
    completionHandler(str);
  }];
}

@end
