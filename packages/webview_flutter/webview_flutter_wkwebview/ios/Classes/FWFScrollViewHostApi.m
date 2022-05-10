// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FWFScrollViewHostApi.h"
#import "FWFWebViewHostApi.h"

@interface FWFScrollViewHostApiImpl ()
@property(nonatomic) FWFInstanceManager *instanceManager;
@end

@implementation FWFScrollViewHostApiImpl
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _instanceManager = instanceManager;
  }
  return self;
}

- (UIScrollView *)scrollViewForIdentifier:(NSNumber *)instanceId {
  return (UIScrollView *)[self.instanceManager instanceForIdentifier:instanceId.longValue];
}

- (void)createFromWebViewWithIdentifier:(nonnull NSNumber *)instanceId
                      webViewIdentifier:(nonnull NSNumber *)webViewInstanceId
                                  error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  WKWebView *webView =
      (WKWebView *)[self.instanceManager instanceForIdentifier:webViewInstanceId.longValue];
  [self.instanceManager addInstance:webView.scrollView withIdentifier:instanceId.longValue];
}

- (NSArray<NSNumber *> *)
    contentOffsetForScrollViewWithIdentifier:(nonnull NSNumber *)instanceId
                                       error:(FlutterError *_Nullable *_Nonnull)error {
  CGPoint point = [[self scrollViewForIdentifier:instanceId] contentOffset];
  return @[ @(point.x), @(point.y) ];
}

- (void)scrollByForScrollViewWithIdentifier:(nonnull NSNumber *)instanceId
                                          x:(nonnull NSNumber *)x
                                          y:(nonnull NSNumber *)y
                                      error:(FlutterError *_Nullable *_Nonnull)error {
  UIScrollView *scrollView = [self scrollViewForIdentifier:instanceId];
  CGPoint contentOffset = scrollView.contentOffset;
  [scrollView setContentOffset:CGPointMake(contentOffset.x + x.doubleValue,
                                           contentOffset.y + y.doubleValue)];
}

- (void)setContentOffsetForScrollViewWithIdentifier:(nonnull NSNumber *)instanceId
                                                toX:(nonnull NSNumber *)x
                                                  y:(nonnull NSNumber *)y
                                              error:(FlutterError *_Nullable *_Nonnull)error {
  [[self scrollViewForIdentifier:instanceId]
      setContentOffset:CGPointMake(x.doubleValue, y.doubleValue)];
}
@end
