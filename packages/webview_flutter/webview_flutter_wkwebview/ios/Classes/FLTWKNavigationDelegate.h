// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FLTWKNavigationDelegate : NSObject <WKNavigationDelegate>

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel;

/**
 * Whether to delegate navigation decisions over the method channel.
 */
@property(nonatomic, assign) BOOL hasDartNavigationDelegate;

/**
 * Whether to allow zoom functionality on the WebView.
 */
@property(nonatomic, assign) BOOL shouldEnableZoom;

@end

NS_ASSUME_NONNULL_END
