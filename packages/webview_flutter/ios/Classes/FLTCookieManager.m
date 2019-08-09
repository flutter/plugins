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
  } else if ([[call method] isEqualToString:@"setCookie"]) {
    [self setCookie:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)clearCookies:(FlutterResult)result {
  if (@available(iOS 9.0, *)) {
    [self clearCookiesIos9AndLater:result];
  } else {
    // support for iOS8 tracked in https://github.com/flutter/flutter/issues/27624.
    NSLog(@"Clearing cookies is not supported for Flutter WebViews prior to iOS 9.");
  }
}

- (void)clearCookiesIos9AndLater:(FlutterResult)result {
  NSSet *websiteDataTypes = [NSSet setWithArray:@[ WKWebsiteDataTypeCookies ]];
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
}

- (void)setCookie:(FlutterMethodCall *)call result:(FlutterResult)result {
  if (@available(iOS 9.0, *)) {
    [self setCookieIos9AndLater:call result:result];
  } else {
    NSLog(@"Setting cookie is not supported for Flutter WebViews prior to iOS 9.");
  }
}

- (void)setCookieIos9AndLater:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = [call arguments];
    NSString *url = arguments[@"url"];
    NSString *name = arguments[@"name"];
    NSString *value = arguments[@"value"];
    if (url == nil || name == nil || value == nil) {
      result([FlutterError errorWithCode:@"error"
                                 message:@"Missing required Argument"
                                 details:nil]);
      return;
    }

    NSString *domain = [NSURL URLWithString:url].host;
    NSDate *expires = [NSDate dateWithTimeIntervalSinceNow: 60 * 60 * 24 * 365];

    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:
                            @{
                              NSHTTPCookieOriginURL: url,
                              NSHTTPCookieName: name,
                              NSHTTPCookieValue: value,
                              NSHTTPCookieDomain: domain,
                              NSHTTPCookiePath: @"/",
                              NSHTTPCookieSecure: @YES,
                              NSHTTPCookieExpires: expires,
                              }];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    result(@YES);
}

@end
