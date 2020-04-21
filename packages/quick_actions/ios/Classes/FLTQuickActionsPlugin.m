// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTQuickActionsPlugin.h"

static NSString *const CHANNEL_NAME = @"plugins.flutter.io/quick_actions";

@interface FLTQuickActionsPlugin ()
@property(nonatomic, retain) FlutterMethodChannel *channel;
@end

@implementation FLTQuickActionsPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:CHANNEL_NAME
                                  binaryMessenger:[registrar messenger]];
  FLTQuickActionsPlugin *instance = [[FLTQuickActionsPlugin alloc] init];
  instance.channel = channel;
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if (@available(iOS 9.0, *)) {
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
  } else {
    NSLog(@"Shortcuts are not supported prior to iOS 9.");
    result(nil);
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
  [self.channel invokeMethod:@"launch" arguments:shortcutItem.type];
  return YES;
}

#pragma mark Private functions

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
