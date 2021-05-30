// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTWKProgressionDelegate.h"

NSString *const FLTWKEstimatedProgressKeyPath = @"estimatedProgress";

@implementation FLTWKProgressionDelegate {
  FlutterMethodChannel *_methodChannel;
}

- (instancetype)initWithWebView:(WKWebView *)webView channel:(FlutterMethodChannel *)channel {
  self = [super init];
  if (self) {
    _methodChannel = channel;
    [webView addObserver:self
              forKeyPath:FLTWKEstimatedProgressKeyPath
                 options:NSKeyValueObservingOptionNew
                 context:nil];
  }
  return self;
}

- (void)stopObservingProgress:(WKWebView *)webView {
  [webView removeObserver:self forKeyPath:FLTWKEstimatedProgressKeyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(void *)context {
  if ([keyPath isEqualToString:FLTWKEstimatedProgressKeyPath]) {
    NSNumber *newValue =
        change[NSKeyValueChangeNewKey] ?: 0;          // newValue is anywhere between 0.0 and 1.0
    int newValueAsInt = [newValue floatValue] * 100;  // Anywhere between 0 and 100
    [_methodChannel invokeMethod:@"onProgress" arguments:@{@"progress" : @(newValueAsInt)}];
  }
}

@end
