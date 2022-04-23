// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FWFWebViewHostApi.h"
#import <Flutter/Flutter.h>
#import <WebKit/WebKit.h>
#import "FWFDataConverters.h"

@implementation FWFWebView
- (void)setFrame:(CGRect)frame {
  [super setFrame:frame];
  // Prevents the contentInsets to be adjusted by iOS and gives control to Flutter.
  self.scrollView.contentInset = UIEdgeInsetsZero;
  if (@available(iOS 11, *)) {
    // Above iOS 11, adjust contentInset to compensate the adjustedContentInset so the sum will
    // always be 0.
    if (UIEdgeInsetsEqualToEdgeInsets(self.scrollView.adjustedContentInset, UIEdgeInsetsZero)) {
      return;
    }
    UIEdgeInsets insetToAdjust = self.scrollView.adjustedContentInset;
    self.scrollView.contentInset = UIEdgeInsetsMake(-insetToAdjust.top, -insetToAdjust.left,
                                                    -insetToAdjust.bottom, -insetToAdjust.right);
  }
}

- (nonnull UIView *)view {
  return self;
}
@end

@interface FWFWebViewHostApiImpl ()
@property FWFInstanceManager *instanceManager;
@end

@implementation FWFWebViewHostApiImpl
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    self.instanceManager = instanceManager;
  }
  return self;
}

- (void)webView:(nonnull NSNumber *)instanceId
    loadRequest:(nonnull FWFNSUrlRequestData *)request
          error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  FWFWebView *webView =
      (FWFWebView *)[self.instanceManager instanceForIdentifier:instanceId.longValue];
  NSURLRequest *urlRequest = FWFConvertURLRequestData(request);
  if (!urlRequest) {
    *error =
        [FlutterError errorWithCode:@"loadUrl_failed"
                            message:@"Failed parsing the URL"
                            details:[NSString stringWithFormat:@"Request was: '%@'", request.url]];
    return;
  }
  [webView loadRequest:urlRequest];
}

- (void)webView:(nonnull NSNumber *)instanceId
    setCustomUserAgent:(nullable NSString *)userAgent
                 error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  FWFWebView *webView =
      (FWFWebView *)[self.instanceManager instanceForIdentifier:instanceId.longValue];
  [webView setCustomUserAgent:userAgent];
}

- (nullable NSNumber *)webViewCanGoBack:(nonnull NSNumber *)instanceId
                                  error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  FWFWebView *webView =
      (FWFWebView *)[self.instanceManager instanceForIdentifier:instanceId.longValue];
  return @(webView.canGoBack);
}

- (nullable NSString *)webViewUrl:(nonnull NSNumber *)instanceId
                            error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  FWFWebView *webView =
      (FWFWebView *)[self.instanceManager instanceForIdentifier:instanceId.longValue];
  return webView.URL.absoluteString;
}

- (nullable NSNumber *)canGoForwardInstanceId:(nonnull NSNumber *)instanceId
                                        error:(FlutterError *_Nullable __autoreleasing *_Nonnull)
                                                  error {
  // TODO(bparrishMines): Implement
  @throw [NSException exceptionWithName:@"UnsupportedException" reason:nil userInfo:nil];
}

- (void)createInstanceId:(nonnull NSNumber *)instanceId
    configurationInstanceId:(nonnull NSNumber *)configurationInstanceId
                      error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  // TODO(bparrishMines): Implement
  @throw [NSException exceptionWithName:@"UnsupportedException" reason:nil userInfo:nil];
}

- (void)evaluateJavaScriptInstanceId:(nonnull NSNumber *)instanceId
                    javascriptString:(nonnull NSString *)javascriptString
                          completion:(nonnull void (^)(NSString *_Nullable,
                                                       FlutterError *_Nullable))completion {
  // TODO(bparrishMines): Implement
  @throw [NSException exceptionWithName:@"UnsupportedException" reason:nil userInfo:nil];
}

- (nullable NSNumber *)
    getEstimatedProgressInstanceId:(nonnull NSNumber *)instanceId
                             error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  // TODO(bparrishMines): Implement
  @throw [NSException exceptionWithName:@"UnsupportedException" reason:nil userInfo:nil];
}

- (nullable NSString *)getTitleInstanceId:(nonnull NSNumber *)instanceId
                                    error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  // TODO(bparrishMines): Implement
  @throw [NSException exceptionWithName:@"UnsupportedException" reason:nil userInfo:nil];
}

- (void)goBackInstanceId:(nonnull NSNumber *)instanceId
                   error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  // TODO(bparrishMines): Implement
  @throw [NSException exceptionWithName:@"UnsupportedException" reason:nil userInfo:nil];
}

- (void)goForwardInstanceId:(nonnull NSNumber *)instanceId
                      error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  // TODO(bparrishMines): Implement
  @throw [NSException exceptionWithName:@"UnsupportedException" reason:nil userInfo:nil];
}

- (void)loadFileUrlInstanceId:(nonnull NSNumber *)instanceId
                          url:(nonnull NSString *)url
                readAccessUrl:(nonnull NSString *)readAccessUrl
                        error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  // TODO(bparrishMines): Implement
  @throw [NSException exceptionWithName:@"UnsupportedException" reason:nil userInfo:nil];
}

- (void)loadFlutterAssetInstanceId:(nonnull NSNumber *)instanceId
                               key:(nonnull NSString *)key
                             error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  // TODO(bparrishMines): Implement
  @throw [NSException exceptionWithName:@"UnsupportedException" reason:nil userInfo:nil];
}

- (void)loadHtmlStringInstanceId:(nonnull NSNumber *)instanceId
                          string:(nonnull NSString *)string
                         baseUrl:(nullable NSString *)baseUrl
                           error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  // TODO(bparrishMines): Implement
  @throw [NSException exceptionWithName:@"UnsupportedException" reason:nil userInfo:nil];
}

- (void)reloadInstanceId:(nonnull NSNumber *)instanceId
                   error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  // TODO(bparrishMines): Implement
  @throw [NSException exceptionWithName:@"UnsupportedException" reason:nil userInfo:nil];
}

- (void)setAllowsBackForwardNavigationGesturesInstanceId:(nonnull NSNumber *)instanceId
                                                   allow:(nonnull NSNumber *)allow
                                                   error:(FlutterError *_Nullable __autoreleasing
                                                              *_Nonnull)error {
  // TODO(bparrishMines): Implement
  @throw [NSException exceptionWithName:@"UnsupportedException" reason:nil userInfo:nil];
}

- (void)setNavigationDelegateInstanceId:(nonnull NSNumber *)instanceId
           navigationDelegateInstanceId:(nullable NSNumber *)navigationDelegateInstanceId
                                  error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  // TODO(bparrishMines): Implement
  @throw [NSException exceptionWithName:@"UnsupportedException" reason:nil userInfo:nil];
}

- (void)setUIDelegateInstanceId:(nonnull NSNumber *)instanceId
           uiDelegateInstanceId:(nullable NSNumber *)uiDelegateInstanceId
                          error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  // TODO(bparrishMines): Implement
  @throw [NSException exceptionWithName:@"UnsupportedException" reason:nil userInfo:nil];
}

@end
