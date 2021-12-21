// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTCookieManager.h"
#import "FLTCookieManager_Test.h"

@implementation FLTCookieManager {
  WKHTTPCookieStore *_httpCookieStore API_AVAILABLE(macos(10.13), ios(11.0));
}

+ (FLTCookieManager *)instance {
  static FLTCookieManager *instance = nil;
  if (instance == nil) {
    instance = [[FLTCookieManager alloc] init];
  }
  return instance;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/cookie_manager"
                                  binaryMessenger:[registrar messenger]];
  [registrar addMethodCallDelegate:[self instance] channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([[call method] isEqualToString:@"clearCookies"]) {
    [self clearCookies:result];
  } else if ([[call method] isEqualToString:@"setCookie"]) {
    [self setCookieForResult:result arguments:[call arguments]];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)clearCookies:(FlutterResult)result {
  if (@available(iOS 9.0, *)) {
    NSSet<NSString *> *websiteDataTypes = [NSSet setWithObject:WKWebsiteDataTypeCookies];
    WKWebsiteDataStore *dataStore = [WKWebsiteDataStore defaultDataStore];

    void (^deleteAndNotify)(NSArray<WKWebsiteDataRecord *> *) =
        ^(NSArray<WKWebsiteDataRecord *> *cookies) {
          BOOL hasCookies = cookies.count > 0;
          [dataStore removeDataOfTypes:websiteDataTypes
                        forDataRecords:cookies
                     completionHandler:^{
                       result(@(hasCookies));
                     }];
        };

    [dataStore fetchDataRecordsOfTypes:websiteDataTypes completionHandler:deleteAndNotify];
  } else {
    // support for iOS8 tracked in https://github.com/flutter/flutter/issues/27624.
    NSLog(@"Clearing cookies is not supported for Flutter WebViews prior to iOS 9.");
  }
}

- (void)setCookiesForData:(NSArray<NSDictionary *> *)cookies {
  for (id cookie in cookies) {
    [self setCookieForData:cookie];
  }
}

- (void)setCookieForData:(NSDictionary *)cookieData {
  if (@available(iOS 11.0, *)) {
    if (!_httpCookieStore) {
      _httpCookieStore = [[WKWebsiteDataStore defaultDataStore] httpCookieStore];
    }
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:@{
      NSHTTPCookieName : cookieData[@"name"],
      NSHTTPCookieValue : cookieData[@"value"],
      NSHTTPCookieDomain : cookieData[@"domain"],
      NSHTTPCookiePath : cookieData[@"path"],
    }];
    [_httpCookieStore setCookie:cookie
              completionHandler:^{
              }];
  } else {
    NSLog(@"Setting cookies is not supported for Flutter WebViews prior to iOS 11.");
  }
}

- (void)setCookieForResult:(FlutterResult)result arguments:(NSDictionary *)arguments {
  if (@available(iOS 11.0, *)) {
    if (!_httpCookieStore) {
      _httpCookieStore = [[WKWebsiteDataStore defaultDataStore] httpCookieStore];
    }
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:@{
      NSHTTPCookieName : arguments[@"name"],
      NSHTTPCookieValue : arguments[@"value"],
      NSHTTPCookieDomain : arguments[@"domain"],
      NSHTTPCookiePath : arguments[@"path"],
    }];
    [_httpCookieStore setCookie:cookie
              completionHandler:^{
                result(nil);
              }];
  } else {
    NSLog(@"Setting cookies is not supported for Flutter WebViews prior to iOS 11.");
    result(nil);
  }
}

@end
