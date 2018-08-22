// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <SafariServices/SafariServices.h>

#import "UrlLauncherPlugin.h"

@interface FLTUrlLaunchSession : NSObject<SFSafariViewControllerDelegate>
@property(nonatomic) UIStatusBarStyle previousStatusBarStyle;
@end

@implementation FLTUrlLaunchSession {
  NSURL *_url;
  FlutterResult _flutterResult;
}

- (instancetype)initWithUrl:url withFlutterResult:result {
  self = [super init];
  if (self) {
    _url = url;
    _flutterResult = result;
  }
  return self;
}

- (void)safariViewController:(SFSafariViewController *)controller
      didCompleteInitialLoad:(BOOL)didLoadSuccessfully {
  if (_previousStatusBarStyle != nil) {
    UIApplication *application = [UIApplication sharedApplication];
    application.statusBarStyle = _previousStatusBarStyle;
  }
  if (didLoadSuccessfully) {
    _flutterResult(nil);
  } else {
    _flutterResult([FlutterError
        errorWithCode:@"Error"
              message:[NSString stringWithFormat:@"Error while launching %@", _url]
              details:nil]);
  }
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
  [controller dismissViewControllerAnimated:YES completion:nil];
}

@end

@implementation FLTUrlLauncherPlugin {
  UIViewController *_viewController;
  FLTUrlLaunchSession *_currentSession;
  UIStatusBarStyle _previousStatusBarStyle;
}

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
    _viewController = viewController;
  }
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *url = call.arguments[@"url"];
  if ([@"canLaunch" isEqualToString:call.method]) {
    result(@([self canLaunchURL:url]));
  } else if ([@"launch" isEqualToString:call.method]) {
    NSNumber *useSafariVC = call.arguments[@"useSafariVC"];
    NSString *brightness = call.arguments[@"statusBarBrightness"];
    UIApplication *application = [UIApplication sharedApplication];
    _previousStatusBarStyle = application.statusBarStyle;
    if ([brightness isEqualToString:@"Brightness.light"]) {
      application.statusBarStyle = UIStatusBarStyleDefault;
    } else if ([brightness isEqualToString:@"Brightness.dark"]) {
      application.statusBarStyle = UIStatusBarStyleLightContent;
    }
    if (useSafariVC.boolValue) {
      [self launchURLInVC:url result:result];
    } else {
      [self launchURL:url result:result];
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

- (void)launchURL:(NSString *)urlString result:(FlutterResult)result {
  NSURL *url = [NSURL URLWithString:urlString];
  UIApplication *application = [UIApplication sharedApplication];
  if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
    [application openURL:url
        options:@{}
        completionHandler:^(BOOL success) {
          if (self->_previousStatusBarStyle != nil) {
            UIApplication *application = [UIApplication sharedApplication];
            application.statusBarStyle = self->_previousStatusBarStyle;
          }
          if (success) {
            result(nil);
          } else {
            result([FlutterError
                errorWithCode:@"Error"
                      message:[NSString stringWithFormat:@"Error while launching %@", url]
                      details:nil]);
          }
        }];
  } else {
    BOOL success = [application openURL:url];
    if (success) {
      result(nil);
    } else {
      result([FlutterError
          errorWithCode:@"Error"
                message:[NSString stringWithFormat:@"Error while launching %@", url]
                details:nil]);
    }
  }
}

- (void)launchURLInVC:(NSString *)urlString result:(FlutterResult)result {
  NSURL *url = [NSURL URLWithString:urlString];

  SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:url];
  _currentSession = [[FLTUrlLaunchSession alloc] initWithUrl:url withFlutterResult:result];
  _currentSession.previousStatusBarStyle = _previousStatusBarStyle;
  safari.delegate = _currentSession;
  [_viewController presentViewController:safari animated:YES completion:nil];
}

@end
