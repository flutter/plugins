// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "UrlLauncherPlugin.h"

@implementation UrlLauncherPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/url_launcher"
                                  binaryMessenger:registrar.messenger];
  [channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
    NSString* url = call.arguments;
    if ([@"canLaunch" isEqualToString:call.method]) {
      result(@([self canLaunchURL:url]));
    } else if ([@"launch" isEqualToString:call.method]) {
      [self launchURL:url result:result];
    } else {
      result(FlutterMethodNotImplemented);
    }
  }];
}

+ (BOOL)canLaunchURL:(NSString*)urlString {
  NSURL* url = [NSURL URLWithString:urlString];
  UIApplication* application = [UIApplication sharedApplication];
  return [application canOpenURL:url];
}

+ (void)launchURL:(NSString*)urlString result:(FlutterResult)result {
  NSURL* url = [NSURL URLWithString:urlString];
  UIApplication* application = [UIApplication sharedApplication];

// Using ifdef as workaround to support running with Xcode 7.0 and sdk version 9
// where the dynamic check fails.
#if __IPHONE_OS_VERSION_MIN_REQUIRED > __IPHONE_9_0
  [application openURL:url
      options:@{}
      completionHandler:^(BOOL success) {
        [self sendResult:success result:result url:url];
      }];
#else
  [self sendResult:[application openURL:url] result:result url:url];
#endif
}

+ (void)sendResult:(BOOL)success result:(FlutterResult)result url:(NSURL*)url {
  if (success) {
    result(nil);
  } else {
    result([FlutterError errorWithCode:@"Error"
                               message:[NSString stringWithFormat:@"Error while launching %@", url]
                               details:nil]);
  }
}

@end
