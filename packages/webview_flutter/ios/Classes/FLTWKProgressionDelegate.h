// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FLTWKProgressionDelegate : NSObject

- (instancetype)initWithWebView:(WKWebView *)webView channel:(FlutterMethodChannel *)channel;

- (void)stopObservingProgress:(WKWebView *)webView;

@end

NS_ASSUME_NONNULL_END
