// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This header is available in the Test module. Import via "@import webview_flutter_wkwebview.Test;"

#import <webview_flutter_wkwebview/FLTCookieManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface FLTCookieManager ()

@property(nonatomic, strong)
    WKHTTPCookieStore *httpCookieStore API_AVAILABLE(macos(10.13), ios(11.0));

- (void)setCookieForResult:(FlutterResult)result arguments:(NSDictionary *)arguments;

@end

NS_ASSUME_NONNULL_END
