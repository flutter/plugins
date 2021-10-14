// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FLTWebViewController : NSObject <FlutterPlatformView, WKUIDelegate>

- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger;

- (FlutterError *_Nullable)webView:(WKWebView *)webView
                           loadUrl:(NSString *)url
                       withHeaders:(NSDictionary<NSString *, NSString *> *)headers;
- (NSNumber *)webViewCanGoBack:(WKWebView *)webView;
- (NSNumber *)webViewCanGoForward:(WKWebView *)webView;
- (void)webViewGoBack:(WKWebView *)webView;
- (void)webViewGoForward:(WKWebView *)webView;
- (void)webViewReload:(WKWebView *)webView;
- (NSString *)currentUrlForWebView:(WKWebView *)webView;
- (void)webView:(WKWebView *)webView
    evaluateJavaScript:(NSString *)jsString
                result:(FlutterResult)result;
- (NSString *)titleForWebView:(WKWebView *)webView;
- (void)webView:(WKWebView *)webView scrollTo:(NSNumber *)x y:(NSNumber *)y;
- (void)webView:(WKWebView *)webView scrollBy:(NSNumber *)x y:(NSNumber *)y;
- (NSNumber *)scrollXForWebView:(WKWebView *)webView;
- (NSNumber *)scrollYForWebView:(WKWebView *)webView;
@end

@interface FLTWebViewFactory : NSObject <FlutterPlatformViewFactory>
- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messenger;
@end

/**
 * The WkWebView used for the plugin.
 *
 * This class overrides some methods in `WKWebView` to serve the needs for the plugin.
 */
@interface FLTWKWebView : WKWebView
@end

NS_ASSUME_NONNULL_END
