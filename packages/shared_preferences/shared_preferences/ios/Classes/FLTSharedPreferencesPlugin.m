// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTSharedPreferencesPlugin.h"

static NSString *const CHANNEL_NAME = @"plugins.flutter.io/shared_preferences";

@implementation FLTSharedPreferencesPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:CHANNEL_NAME
                                                              binaryMessenger:registrar.messenger];
  [channel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
    NSString *method = [call method];
    NSDictionary *arguments = [call arguments];

    if ([method isEqualToString:@"getAll"]) {
      NSString *suiteName = arguments[@"suiteName"];
      result(getAllPrefs(suiteName));
    } else if ([method isEqualToString:@"setBool"]) {
      NSString *key = arguments[@"key"];
      NSNumber *value = arguments[@"value"];
      NSString *suiteName = arguments[@"suiteName"];
      [[[NSUserDefaults alloc] initWithSuiteName:suiteName] setBool:value.boolValue forKey:key];
      result(@YES);
    } else if ([method isEqualToString:@"setInt"]) {
      NSString *key = arguments[@"key"];
      NSNumber *value = arguments[@"value"];
      NSString *suiteName = arguments[@"suiteName"];
      // int type in Dart can come to native side in a variety of forms
      // It is best to store it as is and send it back when needed.
      // Platform channel will handle the conversion.
      [[[NSUserDefaults alloc] initWithSuiteName:suiteName] setValue:value forKey:key];
      result(@YES);
    } else if ([method isEqualToString:@"setDouble"]) {
      NSString *key = arguments[@"key"];
      NSNumber *value = arguments[@"value"];
      NSString *suiteName = arguments[@"suiteName"];
      [[[NSUserDefaults alloc] initWithSuiteName:suiteName] setDouble:value.doubleValue forKey:key];
      result(@YES);
    } else if ([method isEqualToString:@"setString"]) {
      NSString *key = arguments[@"key"];
      NSString *value = arguments[@"value"];
      NSString *suiteName = arguments[@"suiteName"];
      [[[NSUserDefaults alloc] initWithSuiteName:suiteName] setValue:value forKey:key];
      result(@YES);
    } else if ([method isEqualToString:@"setStringList"]) {
      NSString *key = arguments[@"key"];
      NSArray *value = arguments[@"value"];
      NSString *suiteName = arguments[@"suiteName"];
      [[[NSUserDefaults alloc] initWithSuiteName:suiteName] setValue:value forKey:key];
      result(@YES);
    } else if ([method isEqualToString:@"commit"]) {
      // synchronize is deprecated.
      // "this method is unnecessary and shouldn't be used."
      result(@YES);
    } else if ([method isEqualToString:@"remove"]) {
      NSString *suiteName = arguments[@"suiteName"];
      [[[NSUserDefaults alloc] initWithSuiteName:suiteName] removeObjectForKey:arguments[@"key"]];
      result(@YES);
    } else if ([method isEqualToString:@"clear"]) {
      NSString *suiteName = arguments[@"suiteName"];
      NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:suiteName];
      for (NSString *key in getAllPrefs(suiteName)) {
        [defaults removeObjectForKey:key];
      }
      result(@YES);
    } else {
      result(FlutterMethodNotImplemented);
    }
  }];
}

#pragma mark - Private

static NSMutableDictionary *getAllPrefs(NSString *suiteName) {
  NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
  NSDictionary *prefs = [[[NSUserDefaults alloc] initWithSuiteName:suiteName] persistentDomainForName:appDomain];
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
