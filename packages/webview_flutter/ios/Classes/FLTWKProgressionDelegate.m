// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTWKProgressionDelegate.h"

NSString *const FLTWKEstimatedProgressKeyPath = @"estimatedProgress";

@implementation FLTWKProgressionDelegate {
  FlutterMethodChannel *_methodChannel;
  NSInteger _updateScreenshotPercentageThreshold;
  NSInteger _lastUpdateProgress;
}

- (instancetype)initWithWebView:(WKWebView *)webView channel:(FlutterMethodChannel *)channel {
  self = [super init];
  if (self) {
    _methodChannel = channel;
    _updateScreenshotPercentageThreshold = 10;
    _lastUpdateProgress = 0;
      
    [webView addObserver:self
              forKeyPath:FLTWKEstimatedProgressKeyPath
                 options:NSKeyValueObservingOptionNew
                 context:nil];
  }
  return self;
}

- (void)updateScreenshot {
    [_screenshotDelegate takeScreenshot];
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
    [_methodChannel invokeMethod:@"onProgress"
                       arguments:@{@"progress" : [NSNumber numberWithInt:newValueAsInt]}];
      
      if(_lastUpdateProgress > newValueAsInt) {
          _lastUpdateProgress = 0;
      }
      NSInteger diff = newValueAsInt - _lastUpdateProgress;
      if (diff > _updateScreenshotPercentageThreshold) {
          _lastUpdateProgress = newValueAsInt;
          [self updateScreenshot];
      }
  }
}

@end
