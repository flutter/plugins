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
  } else if ([[call method] isEqualToString:@"setCookies"]) {
    [self setCookies:call result:result];
  } else if ([[call method] isEqualToString:@"getCookies"]) {
    [self getCookies:call result:result];
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
    result([FlutterError
        errorWithCode:@"not supported"
              message:@"Clearing cookies is not supported for Flutter WebViews prior to iOS 9."
              details:nil]);
  }
}

- (void)setCookies:(FlutterMethodCall *)call result:(FlutterResult)result {
  if (@available(iOS 11.0, *)) {
    NSMutableArray<NSHTTPCookie *> *cookies = [[NSMutableArray<NSHTTPCookie *> alloc] init];
    for (NSDictionary *input in call.arguments) {
      [cookies addObject:[self dictionaryToCookie:input]];
    }
    WKWebsiteDataStore *dataStore = [WKWebsiteDataStore defaultDataStore];
    WKHTTPCookieStore *cookieStore = [dataStore httpCookieStore];
    __block int counter = 0;

    for (NSHTTPCookie *cookie in cookies) {
      [cookieStore setCookie:cookie
           completionHandler:^{
             counter += 1;
             if (counter == cookies.count) {
               result(nil);
             }
           }];
    }
  } else {
    NSLog(@"Setting cookies is not supported for Flutter WebViews prior to iOS 11.");
    result([FlutterError
        errorWithCode:@"not supported"
              message:@"Setting cookies is not supported for Flutter WebViews prior to iOS 11."
              details:nil]);
  }
}

- (void)getCookies:(FlutterMethodCall *)call result:(FlutterResult)result {
  if (@available(iOS 11.0, *)) {
    WKWebsiteDataStore *dataStore = [WKWebsiteDataStore defaultDataStore];
    [[dataStore httpCookieStore] getAllCookies:^(NSArray<NSHTTPCookie *> *cookies) {
      NSMutableArray<NSDictionary *> *allCookies = [[NSMutableArray<NSDictionary *> alloc] init];
      for (NSHTTPCookie *cookie in cookies) {
        [allCookies addObject:[self cookieToDictionary:cookie]];
      }
      result(allCookies);
    }];
  } else {
    NSLog(@"Getting cookies is not supported for Flutter WebViews prior to iOS 11.");
    result([FlutterError
        errorWithCode:@"not supported"
              message:@"Getting cookies is not supported for Flutter WebViews prior to iOS 11."
              details:nil]);
  }
}

- (NSDictionary *)cookieToDictionary:(NSHTTPCookie *)cookie {
  NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
  [result addEntriesFromDictionary:@{
    @"name" : cookie.name,
    @"value" : cookie.value,
    @"domain" : cookie.domain,
    @"path" : cookie.path,
    @"secure" : [NSNumber numberWithBool:cookie.isSecure],
    @"httpOnly" : [NSNumber numberWithBool:cookie.isHTTPOnly],
  }];
  if ([cookie expiresDate] != nil) {
    [result setValue:[NSNumber numberWithDouble:[[cookie expiresDate] timeIntervalSince1970]]
              forKey:@"expires"];
  }

  return result;
}

- (NSHTTPCookie *)dictionaryToCookie:(NSDictionary *)input {
  NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
  [properties setValue:input[@"value"] forKey:NSHTTPCookieValue];
  [properties setValue:input[@"name"] forKey:NSHTTPCookieName];

  if (input[@"domain"] != nil) {
    [properties setValue:input[@"domain"] forKey:NSHTTPCookieDomain];
  }

  if (input[@"path"] != nil) {
    [properties setValue:input[@"path"] forKey:NSHTTPCookiePath];
  } else {
    [properties setValue:@"/" forKey:NSHTTPCookiePath];
  }

  if (input[@"expires"] != nil) {
    NSNumber *expires = [input valueForKey:@"expires"];
    [properties setValue:[NSDate dateWithTimeIntervalSince1970:[expires doubleValue]]
                  forKey:NSHTTPCookieExpires];
  }

  NSNumber *secure = input[@"secure"];
  if ([secure isEqualToNumber:@1]) {
    [properties setValue:@true forKey:NSHTTPCookieSecure];
  }

  // seems to be an undocumented property 🤷‍♂️
  NSNumber *httpOnly = input[@"httpOnly"];
  if ([httpOnly isEqualToNumber:@1]) {
    [properties setValue:@true forKey:@"HttpOnly"];
  }
  NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:properties];
  return cookie;
}

@end
