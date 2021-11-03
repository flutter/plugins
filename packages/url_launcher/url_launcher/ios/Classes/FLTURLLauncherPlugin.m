// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <SafariServices/SafariServices.h>

#import "FLTURLLauncherPlugin.h"

API_AVAILABLE(ios(9.0))
@interface FLTURLLaunchSession : NSObject <SFSafariViewControllerDelegate>

@property(copy, nonatomic) FlutterResult flutterResult;
@property(strong, nonatomic) NSURL *url;
@property(strong, nonatomic) SFSafariViewController *safari;
@property(nonatomic, copy) void (^didFinish)(void);

@end

@implementation FLTURLLaunchSession

- (instancetype)initWithUrl:url withFlutterResult:result {
  self = [super init];
  if (self) {
    self.url = url;
    self.flutterResult = result;
    self.safari = [[SFSafariViewController alloc] initWithURL:url];
    self.safari.delegate = self;
  }
  return self;
}

- (void)safariViewController:(SFSafariViewController *)controller
      didCompleteInitialLoad:(BOOL)didLoadSuccessfully API_AVAILABLE(ios(9.0)) {
  if (didLoadSuccessfully) {
    self.flutterResult(@YES);
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
@interface FLTURLLauncherPlugin ()

@property(strong, nonatomic) FLTURLLaunchSession *currentSession;

@end

@implementation FLTURLLauncherPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/url_launcher"
                                  binaryMessenger:registrar.messenger];
  FLTURLLauncherPlugin *plugin = [[FLTURLLauncherPlugin alloc] init];
  [registrar addMethodCallDelegate:plugin channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *url = call.arguments[@"url"];
  if ([@"canLaunch" isEqualToString:call.method]) {
    result(@([self canLaunchURL:url]));
  } else if ([@"launch" isEqualToString:call.method]) {
    NSNumber *useSafariVC = call.arguments[@"useSafariVC"];
    if (useSafariVC.boolValue) {

          [self launchURLInVC:url call:call result:result];

    } else {
      [self launchURL:url call:call result:result];
    }
  } else if ([@"closeWebView" isEqualToString:call.method]) {
    [self closeWebViewWithResult:result];
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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    BOOL success = [application openURL:url];
#pragma clang diagnostic pop
    result(@(success));
  }
}

- (void)launchURLInVC:(NSString *)urlString
                 call:(FlutterMethodCall *)call
               result:(FlutterResult)result API_AVAILABLE(ios(9.0)) {
  NSURL *url = [NSURL URLWithString:urlString];
  self.currentSession = [[FLTURLLaunchSession alloc] initWithUrl:url withFlutterResult:result];
  __weak typeof(self) weakSelf = self;
  self.currentSession.didFinish = ^(void) {
    weakSelf.currentSession = nil;
  };
    NSString *style = call.arguments[@"uiModalPresentationStyle"];

  [self setPresentationStyleFromInput:self.currentSession.safari input:style];
  [self.topViewController presentViewController:self.currentSession.safari
                                       animated:YES
                                     completion:nil];
}

- (void)closeWebViewWithResult:(FlutterResult)result API_AVAILABLE(ios(9.0)) {
  if (self.currentSession != nil) {
    [self.currentSession close];
  }
  result(nil);
}

- (UIViewController *)topViewController {
  return [self topViewControllerFromViewController:[UIApplication sharedApplication]
                                                       .keyWindow.rootViewController];
}

/**
 * This method recursively iterate through the view hierarchy
 * to return the top most view controller.
 *
 * It supports the following scenarios:
 *
 * - The view controller is presenting another view.
 * - The view controller is a UINavigationController.
 * - The view controller is a UITabBarController.
 *
 * @return The top most view controller.
 */
- (UIViewController *)topViewControllerFromViewController:(UIViewController *)viewController {
  if ([viewController isKindOfClass:[UINavigationController class]]) {
    UINavigationController *navigationController = (UINavigationController *)viewController;
    return [self
        topViewControllerFromViewController:[navigationController.viewControllers lastObject]];
  }
  if ([viewController isKindOfClass:[UITabBarController class]]) {
    UITabBarController *tabController = (UITabBarController *)viewController;
    return [self topViewControllerFromViewController:tabController.selectedViewController];
  }
  if (viewController.presentedViewController) {
    return [self topViewControllerFromViewController:viewController.presentedViewController];
  }
  return viewController;
}

- (void)setPresentationStyleFromInput:(UIViewController *)viewController input:(NSString *)input {
    NSString *passedPresentationStyle = [input componentsSeparatedByString:@"."][1];
    NSMutableDictionary *presentationStyles = [[NSMutableDictionary alloc] init];


    if (@available(iOS 13.0, *)) {
        [presentationStyles setObject:@"automatic" forKey:[NSNumber numberWithInt:UIModalPresentationAutomatic]];
    }
    [presentationStyles setObject:[NSNumber numberWithInt:UIModalPresentationFullScreen] forKey:@"fullScreen"];
    [presentationStyles setObject:[NSNumber numberWithInt:UIModalPresentationPageSheet] forKey:@"pageSheet"];
    [presentationStyles setObject:[NSNumber numberWithInt:UIModalPresentationFormSheet] forKey:@"formSheet"];
    [presentationStyles setObject:[NSNumber numberWithInt:UIModalPresentationCurrentContext] forKey:@"currentContext"];
    [presentationStyles setObject:[NSNumber numberWithInt:UIModalPresentationOverFullScreen] forKey:@"overFullScreen"];
    [presentationStyles setObject:[NSNumber numberWithInt:UIModalPresentationOverCurrentContext] forKey:@"overCurrentContext"];
    [presentationStyles setObject:[NSNumber numberWithInt:UIModalPresentationPopover] forKey:@"popover"];

    NSNumber *presentationStyle = [presentationStyles objectForKey:passedPresentationStyle];
    if (presentationStyle != nil) {
        viewController.modalPresentationStyle = presentationStyle.intValue;
    }
}
@end
