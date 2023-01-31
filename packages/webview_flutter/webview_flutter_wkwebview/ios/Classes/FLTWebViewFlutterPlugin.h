// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FLTWebViewFlutterPlugin : NSObject <FlutterPlugin>
/**
Retrieves the `WKWebView` that is associated with `identifer`.

See the Dart method `WebKitWebViewController.webViewIdentifier` to get the identifier of an
underlying `WKWebView`.

@param identifier The associated identifier of the `WebView`.
@param registry The plugin registry the `FLTWebViewFlutterPlugin` should belong to. If
       the registry doesn't contain an attached instance of `FLTWebViewFlutterPlugin`,
       this method returns nil.
@return The `WKWebView` associated with `identifier` or nil if a `WKWebView` instance associated
with `identifier` could not be found.
*/
+ (nullable WKWebView *)webViewForIdentifier:(long)identifier
                          withPluginRegistry:(id<FlutterPluginRegistry>)registry;
@end

NS_ASSUME_NONNULL_END
