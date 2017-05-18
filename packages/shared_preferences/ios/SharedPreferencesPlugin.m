// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "SharedPreferencesPlugin.h"

static NSString *const CHANNEL_NAME = @"plugins.flutter.io/shared_preferences";

@implementation SharedPreferencesPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:CHANNEL_NAME binaryMessenger:registrar.messenger];
  [channel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
    NSString *method = [call method];
    NSDictionary *arguments = [call arguments];

    if ([method isEqualToString:@"getAll"]) {
      result(getAllPrefs());
    } else if ([method isEqualToString:@"setBool"]) {
      NSString *key = arguments[@"key"];
      NSNumber *value = arguments[@"value"];
      [[NSUserDefaults standardUserDefaults] setBool:value.boolValue forKey:key];
      result(nil);
    } else if ([method isEqualToString:@"setInt"]) {
      NSString *key = arguments[@"key"];
      NSNumber *value = arguments[@"value"];
      // int type in Dart can come to native side in a variety of forms
      // It is best to store it as is and send it back when needed.
      // Platform channel will handle the conversion.
      [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
      result(nil);
    } else if ([method isEqualToString:@"setDouble"]) {
      NSString *key = arguments[@"key"];
      NSNumber *value = arguments[@"value"];
      [[NSUserDefaults standardUserDefaults] setDouble:value.doubleValue forKey:key];
      result(nil);
    } else if ([method isEqualToString:@"setString"]) {
      NSString *key = arguments[@"key"];
      NSString *value = arguments[@"value"];
      [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
      result(nil);
    } else if ([method isEqualToString:@"setStringList"]) {
      NSString *key = arguments[@"key"];
      NSArray *value = arguments[@"value"];
      [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
      result(nil);
    } else if ([method isEqualToString:@"commit"]) {
      result([NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults] synchronize]]);
    } else if ([method isEqualToString:@"clear"]) {
      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
      for (NSString *key in getAllPrefs()) {
        [defaults removeObjectForKey:key];
      }
      result([NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults] synchronize]]);
    } else {
      result(FlutterMethodNotImplemented);
    }
  }];
}

#pragma mark - Private

static NSMutableDictionary *getAllPrefs() {
  NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
  NSDictionary *prefs = [[NSUserDefaults standardUserDefaults] persistentDomainForName:appDomain];
  NSMutableDictionary *filteredPrefs = [NSMutableDictionary dictionary];
  if (prefs != nil) {
    for (NSString *candidateKey in prefs) {
      if ([candidateKey hasPrefix:@"flutter."]) {
        [filteredPrefs setObject:prefs[candidateKey] forKey:candidateKey];
      }
    }
  }
  return filteredPrefs;
}

@end
