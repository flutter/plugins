#import "FlutterCookieManager.h"

@implementation FlutterCookieManager {
}

- (instancetype)init:(NSObject<FlutterBinaryMessenger>*)messenger {
  if ([super init]) {
    FlutterMethodChannel* channel = [FlutterMethodChannel
        methodChannelWithName:@"plugins.flutter.io/cookie_manager"
              binaryMessenger:messenger];
    [channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
      __weak __typeof__(self) weakSelf = self;
      [weakSelf onMethodCall:call result:result];
    }];
  }
  return self;
}

- (void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([[call method] isEqualToString:@"clearCookies"]) {
    [self clearCookies:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)clearCookies:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
  for (NSHTTPCookie *cookie in [storage cookies]) {
    [storage deleteCookie:cookie];
  }
  [[NSUserDefaults standardUserDefaults] synchronize];
  result(nil);
}

@end
