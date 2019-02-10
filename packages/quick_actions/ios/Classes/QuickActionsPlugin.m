// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "QuickActionsPlugin.h"

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
  if ([call.method isEqualToString:@"setShortcutItems"]) {
    setShortcutItems(call.arguments);
    result(nil);
  } else if ([call.method isEqualToString:@"clearShortcutItems"]) {
    [UIApplication sharedApplication].shortcutItems = @[];
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)dealloc {
  [self.channel setMethodCallHandler:nil];
  self.channel = nil;
}

- (BOOL)application:(UIApplication *)application
    performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem
               completionHandler:(void (^)(BOOL succeeded))completionHandler {
  [self.channel invokeMethod:@"launch" arguments:shortcutItem.type];
  return YES;
}

#pragma mark Private functions

static void setShortcutItems(NSArray *items) {
  NSMutableArray *newShortcuts = [[NSMutableArray alloc] init];

  for (id item in items) {
    UIApplicationShortcutItem *shortcut = deserializeShortcutItem(item);
    [newShortcuts addObject:shortcut];
  }

  [UIApplication sharedApplication].shortcutItems = newShortcuts;
}

static UIApplicationShortcutItem *deserializeShortcutItem(NSDictionary *serialized) {
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
