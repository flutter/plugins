// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FWFWebViewHostApi.h"
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
@property(nonatomic) FWFInstanceManager *instanceManager;
@end

@implementation FWFWebViewHostApiImpl
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _instanceManager = instanceManager;
  }
  return self;
}

- (FWFWebView *)getWebViewInstance:(NSNumber *)instanceId {
  return (FWFWebView *)[self.instanceManager instanceForIdentifier:instanceId.longValue];
}

- (void)webViewWithInstanceId:(nonnull NSNumber *)instanceId
                  loadRequest:(nonnull FWFNSUrlRequestData *)request
                        error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  NSURLRequest *urlRequest = FWFNSURLRequestFromRequestData(request);
  if (!urlRequest) {
    *error = [FlutterError errorWithCode:@"CreateNSURLRequestFailure"
                                 message:@"Failed instantiating an NSURLRequest."
                                 details:[NSString stringWithFormat:@"Url was: '%@'", request.url]];
    return;
  }
  [[self getWebViewInstance:instanceId] loadRequest:urlRequest];
}

- (void)webViewWithInstanceId:(nonnull NSNumber *)instanceId
           setCustomUserAgent:(nullable NSString *)userAgent
                        error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  [[self getWebViewInstance:instanceId] setCustomUserAgent:userAgent];
}

- (nullable NSNumber *)
    webViewWithInstanceIdCanGoBack:(nonnull NSNumber *)instanceId
                             error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  return @([self getWebViewInstance:instanceId].canGoBack);
}

- (nullable NSString *)
    urlForWebViewWithInstanceId:(nonnull NSNumber *)instanceId
                          error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  return [self getWebViewInstance:instanceId].URL.absoluteString;
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
