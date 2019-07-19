// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTCookieManager.h"

@implementation FLTCookieManager {
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FLTCookieManager *instance = [[FLTCookieManager alloc] init];

  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/cookie_manager"
                                  binaryMessenger:[registrar messenger]];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([[call method] isEqualToString:@"clearCookies"]) {
    [self clearCookies:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)getCookies:(FlutterResult)result API_AVAILABLE(ios(11.0)) {
  [cookieStore getAllCookies:^(NSArray<NSHTTPCookie *> *cookies) {
    NSArray *serialized = [CookieDto manyToDictionary:[CookieDto manyFromNSHTTPCookies:cookies]];
    result(serialized);
  }];
}

- (void)setCookies:(FlutterMethodCall *)call result:(FlutterResult)result API_AVAILABLE(ios(11.0)) {
  NSArray<CookieDto *> *cookieDtos = [CookieDto manyFromDictionaries:[call arguments]];
  for (CookieDto *cookieDto in cookieDtos) {
    [cookieStore setCookie:[cookieDto toNSHTTPCookie]
         completionHandler:^(){
         }];
  }
}

- (void)clearCookies:(FlutterResult)result API_AVAILABLE(ios(11.0)) {
  [cookieStore getAllCookies:^(NSArray<NSHTTPCookie *> *allCookies) {
    for (NSHTTPCookie *cookie in allCookies) {
      [cookieStore deleteCookie:cookie
              completionHandler:^(){
              }];
    }
  }];
}

@end
