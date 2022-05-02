// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FWFPreferencesHostApi.h"
#import "FWFWebViewConfigurationHostApi.h"

@interface FWFPreferencesHostApiImpl ()
@property(nonatomic) FWFInstanceManager *instanceManager;
@end

@implementation FWFPreferencesHostApiImpl
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _instanceManager = instanceManager;
  }
  return self;
}

- (WKPreferences *)preferencesForIdentifier:(NSNumber *)instanceId {
  return (WKPreferences *)[self.instanceManager instanceForIdentifier:instanceId.longValue];
}

- (void)createWithIdentifier:(nonnull NSNumber *)instanceId
                       error:(FlutterError *_Nullable *_Nonnull)error {
  WKPreferences *preferences = [[WKPreferences alloc] init];
  [self.instanceManager addInstance:preferences withIdentifier:instanceId.longValue];
}

- (void)createFromWebViewConfigurationWithIdentifier:(nonnull NSNumber *)instanceId
                             configurationIdentifier:(nonnull NSNumber *)configurationInstanceId
                                               error:(FlutterError *_Nullable *_Nonnull)error {
  WKWebViewConfiguration *configuration = (WKWebViewConfiguration *)[self.instanceManager
      instanceForIdentifier:configurationInstanceId.longValue];
  [self.instanceManager addInstance:configuration.preferences withIdentifier:instanceId.longValue];
}

- (void)setJavaScriptEnabledForPreferencesWithIdentifier:(nonnull NSNumber *)instanceId
                                               isEnabled:(nonnull NSNumber *)enabled
                                                   error:(FlutterError *_Nullable *_Nonnull)error {
  [[self preferencesForIdentifier:instanceId] setJavaScriptEnabled:enabled.boolValue];
}
@end
