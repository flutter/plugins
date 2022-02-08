// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTQuickActionsPlugin.h"

static NSString *const kChannelName = @"plugins.flutter.io/quick_actions_ios";

@interface FLTQuickActionsPlugin ()
@property(nonatomic, retain) FlutterMethodChannel *channel;
@property(nonatomic, retain) NSString *shortcutType;
@end

@implementation FLTQuickActionsPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:kChannelName
                                  binaryMessenger:[registrar messenger]];
  FLTQuickActionsPlugin *instance = [[FLTQuickActionsPlugin alloc] init];
  instance.channel = channel;
  [registrar addMethodCallDelegate:instance channel:channel];
  [registrar addApplicationDelegate:instance];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([call.method isEqualToString:@"setShortcutItems"]) {
    _setShortcutItems(call.arguments);
    result(nil);
  } else if ([call.method isEqualToString:@"clearShortcutItems"]) {
    [UIApplication sharedApplication].shortcutItems = @[];
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
    self.shortcutType = shortcutItem.type;

    // Return NO to indicate we handled the quick action to ensure
    // the `application:performActionFor:` method is not called (as
    // per Apple's documentation:
    // https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1622935-application?language=objc).
    return NO;
  }
  return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  if (self.shortcutType) {
    [self handleShortcut:self.shortcutType];
    self.shortcutType = nil;
  }
}

#pragma mark Private functions

- (void)handleShortcut:(NSString *)shortcut {
  [self.channel invokeMethod:@"launch" arguments:shortcut];
}

NS_INLINE void _setShortcutItems(NSArray *items) API_AVAILABLE(ios(9.0)) {
  NSMutableArray<UIApplicationShortcutItem *> *newShortcuts = [[NSMutableArray alloc] init];

  for (id item in items) {
    UIApplicationShortcutItem *shortcut = _deserializeShortcutItem(item);
    [newShortcuts addObject:shortcut];
  }

  [UIApplication sharedApplication].shortcutItems = newShortcuts;
}

NS_INLINE UIApplicationShortcutItem *_deserializeShortcutItem(NSDictionary *serialized)
    API_AVAILABLE(ios(9.0)) {
  UIApplicationShortcutIcon *icon =
      [serialized[@"icon"] isKindOfClass:[NSNull class]]
          ? nil
          : [UIApplicationShortcutIcon iconWithTemplateImageName:serialized[@"icon"]];

  return [[UIApplicationShortcutItem alloc] initWithType:serialized[@"type"]
                                          localizedTitle:serialized[@"localizedTitle"]
                                       localizedSubtitle:nil
                                                    icon:icon
                                                userInfo:nil];
}

@end
