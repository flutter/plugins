// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <SafariServices/SafariServices.h>

#import "UrlLauncherPlugin.h"

API_AVAILABLE(ios(9.0))
@interface FLTUrlLaunchSession : NSObject <SFSafariViewControllerDelegate>

@property(copy, nonatomic) FlutterResult flutterResult;
@property(strong, nonatomic) NSURL *url;
@property(strong, nonatomic) SFSafariViewController *safari;
@property(nonatomic, copy) void (^didFinish)(void);

@end

@implementation FLTUrlLaunchSession

- (instancetype)initWithUrl:url withFlutterResult:result {
  self = [super init];
  if (self) {
    self.url = url;
    self.flutterResult = result;
    if (@available(iOS 9.0, *)) {
      self.safari = [[SFSafariViewController alloc] initWithURL:url];
      self.safari.delegate = self;
    }
  }
  return self;
}

- (void)safariViewController:(SFSafariViewController *)controller
      didCompleteInitialLoad:(BOOL)didLoadSuccessfully API_AVAILABLE(ios(9.0)) {
  if (didLoadSuccessfully) {
    self.flutterResult(nil);
  } else {
    self.flutterResult([FlutterError
        errorWithCode:@"Error"
              message:[NSString stringWithFormat:@"Error while launching %@", self.url]
              details:nil]);
  }
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller API_AVAILABLE(ios(9.0)) {
  [controller dismissViewControllerAnimated:YES completion:nil];
  self.didFinish();
}

- (void)close {
  [self safariViewControllerDidFinish:self.safari];
}

@end

API_AVAILABLE(ios(9.0))
@interface FLTUrlLauncherPlugin ()

@property(strong, nonatomic) FLTUrlLaunchSession *currentSession;

@end

@interface FLTUrlLauncherPlugin ()

@property(strong, nonatomic) UIViewController *viewController;

@end

@implementation FLTUrlLauncherPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/url_launcher"
                                  binaryMessenger:registrar.messenger];
  UIViewController *viewController =
      [UIApplication sharedApplication].delegate.window.rootViewController;
  FLTUrlLauncherPlugin *plugin =
      [[FLTUrlLauncherPlugin alloc] initWithViewController:viewController];
  [registrar addMethodCallDelegate:plugin channel:channel];
}

- (instancetype)initWithViewController:(UIViewController *)viewController {
  self = [super init];
  if (self) {
    self.viewController = viewController;
  }
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *url = call.arguments[@"url"];
  if ([@"canLaunch" isEqualToString:call.method]) {
    result(@([self canLaunchURL:url]));
  } else if ([@"launch" isEqualToString:call.method]) {
    NSNumber *useSafariVC = call.arguments[@"useSafariVC"];
    if (useSafariVC.boolValue) {
      if (@available(iOS 9.0, *)) {
        [self launchURLInVC:url result:result];
      } else {
        [self launchURL:url call:call result:result];
      }
    } else {
      [self launchURL:url call:call result:result];
    }
  } else if ([@"closeWebView" isEqualToString:call.method]) {
    if (@available(iOS 9.0, *)) {
      [self closeWebViewWithResult:result];
    } else {
      result([FlutterError
          errorWithCode:@"API_NOT_AVAILABLE"
                message:@"SafariViewController related api is not availabe for version <= IOS9"
                details:nil]);
    }
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (BOOL)canLaunchURL:(NSString *)urlString {
  NSURL *url = [NSURL URLWithString:urlString];
  UIApplication *application = [UIApplication sharedApplication];
  return [application canOpenURL:url];
}

- (void)launchURL:(NSString *)urlString
             call:(FlutterMethodCall *)call
           result:(FlutterResult)result {
  NSURL *url = [NSURL URLWithString:urlString];
  UIApplication *application = [UIApplication sharedApplication];

  if (@available(iOS 10.0, *)) {
    NSNumber *universalLinksOnly = call.arguments[@"universalLinksOnly"] ?: @0;
    NSDictionary *options = @{UIApplicationOpenURLOptionUniversalLinksOnly : universalLinksOnly};
    [application openURL:url
                  options:options
        completionHandler:^(BOOL success) {
          result(@(success));
        }];
  } else {
    BOOL success = [application openURL:url];
    result(@(success));
  }
}

- (void)launchURLInVC:(NSString *)urlString result:(FlutterResult)result API_AVAILABLE(ios(9.0)) {
  NSURL *url = [NSURL URLWithString:urlString];
  self.currentSession = [[FLTUrlLaunchSession alloc] initWithUrl:url withFlutterResult:result];
  __weak typeof(self) weakSelf = self;
  self.currentSession.didFinish = ^(void) {
    weakSelf.currentSession = nil;
  };
  [self.viewController presentViewController:self.currentSession.safari
                                    animated:YES
                                  completion:nil];
}

- (void)closeWebViewWithResult:(FlutterResult)result API_AVAILABLE(ios(9.0)) {
  if (self.currentSession != nil) {
    [self.currentSession close];
  }
  result(nil);
}

@end
