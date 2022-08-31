// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTQuickActionsPlugin.h"
#import "FLTQuickActionsPlugin_Test.h"
#import "FLTShortcutStateManager.h"

static NSString *const kChannelName = @"plugins.flutter.io/quick_actions_ios";

@interface FLTQuickActionsPlugin ()
@property(nonatomic, strong) FlutterMethodChannel *channel;
/// The type of the shortcut item selected when launching the app.
@property(nonatomic, strong, nullable) NSString *launchingShortcutType;
@property(nonatomic, strong) FLTShortcutStateManager *shortcutStateManager;
@end

@implementation FLTQuickActionsPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:kChannelName
                                  binaryMessenger:[registrar messenger]];
  FLTQuickActionsPlugin *instance =
      [[FLTQuickActionsPlugin alloc] initWithChannel:channel
                                shortcutStateManager:[[FLTShortcutStateManager alloc] init]];
  [registrar addMethodCallDelegate:instance channel:channel];
  [registrar addApplicationDelegate:instance];
}

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel
           shortcutStateManager:(FLTShortcutStateManager *)shortcutStateManager {
  if ((self = [super init])) {
    _channel = channel;
    _shortcutStateManager = shortcutStateManager;
  }
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([call.method isEqualToString:@"setShortcutItems"]) {
    [self.shortcutStateManager setShortcutItems:call.arguments];
    result(nil);
  } else if ([call.method isEqualToString:@"clearShortcutItems"]) {
    [self.shortcutStateManager setShortcutItems:@[]];
    result(nil);
  } else if ([call.method isEqualToString:@"getLaunchAction"]) {
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)dealloc {
  [_channel setMethodCallHandler:nil];
  _channel = nil;
}

- (BOOL)application:(UIApplication *)application
    performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem
               completionHandler:(void (^)(BOOL succeeded))completionHandler
    API_AVAILABLE(ios(9.0)) {
  [self handleShortcut:shortcutItem.type];
  return YES;
}

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  UIApplicationShortcutItem *shortcutItem =
      launchOptions[UIApplicationLaunchOptionsShortcutItemKey];
  if (shortcutItem) {
    // Keep hold of the shortcut type and handle it in the
    // `applicationDidBecomeActure:` method once the Dart MethodChannel
    // is initialized.
    self.launchingShortcutType = shortcutItem.type;

    // Return NO to indicate we handled the quick action to ensure
    // the `application:performActionFor:` method is not called (as
    // per Apple's documentation:
    // https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1622935-application?language=objc).
    return NO;
  }
  return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  if (self.launchingShortcutType) {
    [self handleShortcut:self.launchingShortcutType];
    self.launchingShortcutType = nil;
  }
}

#pragma mark Private functions

- (void)handleShortcut:(NSString *)shortcut {
  [self.channel invokeMethod:@"launch" arguments:shortcut];
}

@end
