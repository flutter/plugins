// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTWKHistoryDelegate.h"

NSString *const keyPath = @"URL";

@implementation FLTWKHistoryDelegate {
  FlutterMethodChannel *_methodChannel;
}

- (instancetype)initWithWebView:(id)webView channel:(FlutterMethodChannel *)channel {
  self = [super init];
  if (self) {
    _methodChannel = channel;
    [webView addObserver:self
              forKeyPath:keyPath
                 options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                 context:nil];
  }

  return self;
}

- (void)stopObserving:(WKWebView *)webView {
  [webView removeObserver:self forKeyPath:keyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  if ([change[NSKeyValueChangeNewKey] isKindOfClass:[NSURL class]]) {
    NSURL *newUrl = change[NSKeyValueChangeNewKey];
    [_methodChannel invokeMethod:@"onUpdateVisitedHistory"
                       arguments:@{@"url" : [newUrl absoluteString]}];
  }
}

@end
