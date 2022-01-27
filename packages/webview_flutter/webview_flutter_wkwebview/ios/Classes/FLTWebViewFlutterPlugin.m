// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTWebViewFlutterPlugin.h"
#import "FLTCookieManager.h"
#import "FlutterWebView.h"

@implementation FLTWebViewFlutterPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  [FLTCookieManager registerWithRegistrar:registrar];
  FLTWebViewFactory *webviewFactory =
      [[FLTWebViewFactory alloc] initWithMessenger:registrar.messenger
                                     cookieManager:[FLTCookieManager instance]];
  [registrar registerViewFactory:webviewFactory withId:@"plugins.flutter.io/webview"];
}

@end
