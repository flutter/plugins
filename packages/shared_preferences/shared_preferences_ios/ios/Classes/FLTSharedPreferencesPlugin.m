// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTSharedPreferencesPlugin.h"
#import "messages.g.h"

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

@interface FLTSharedPreferencesPlugin () <SharedPreferencesApi>
@end

@implementation FLTSharedPreferencesPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FLTSharedPreferencesPlugin *plugin = [[FLTSharedPreferencesPlugin alloc] init];
  SharedPreferencesApiSetup(registrar.messenger, plugin);
}

- (nullable NSNumber *)clearWithError:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  for (NSString *key in getAllPrefs()) {
    [defaults removeObjectForKey:key];
  }
  return @YES;
}

- (nullable NSDictionary<NSString *, id> *)getAllWithError:
    (FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  return getAllPrefs();
}

- (nullable NSNumber *)removeKey:(nonnull NSString *)key
                           error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
  return @YES;
}

- (nullable NSNumber *)setBoolKey:(nonnull NSString *)key
                            value:(nonnull NSNumber *)value
                            error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  [[NSUserDefaults standardUserDefaults] setBool:value.boolValue forKey:key];
  return @YES;
}

- (nullable NSNumber *)setDoubleKey:(nonnull NSString *)key
                              value:(nonnull NSNumber *)value
                              error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  [[NSUserDefaults standardUserDefaults] setDouble:value.doubleValue forKey:key];
  return @YES;
}

- (nullable NSNumber *)setIntKey:(nonnull NSString *)key
                           value:(nonnull NSNumber *)value
                           error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  // int type in Dart can come to native side in a variety of forms
  // It is best to store it as is and send it back when needed.
  // Platform channel will handle the conversion.
  [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
  return @YES;
}

- (nullable NSNumber *)setStringKey:(nonnull NSString *)key
                              value:(nonnull NSString *)value
                              error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
  return @YES;
}

- (nullable NSNumber *)setStringListKey:(nonnull NSString *)key
                                  value:(nonnull NSArray<NSString *> *)value
                                  error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
  return @YES;
}

@end
