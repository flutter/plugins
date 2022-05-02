// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FWFWebsiteDataStoreHostApi.h"
#import "FWFDataConverters.h"
#import "FWFWebViewConfigurationHostApi.h"

@interface FWFWebsiteDataStoreHostApiImpl ()
@property(nonatomic) FWFInstanceManager *instanceManager;
@end

@implementation FWFWebsiteDataStoreHostApiImpl
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _instanceManager = instanceManager;
  }
  return self;
}

- (WKWebsiteDataStore *)websiteDataStoreForIdentifier:(NSNumber *)instanceId {
  return (WKWebsiteDataStore*)[self.instanceManager instanceForIdentifier:instanceId.longValue];
}

- (void)createFromWebViewConfigurationWithIdentifier:(nonnull NSNumber *)instanceId
                             configurationIdentifier:(nonnull NSNumber *)configurationInstanceId
                                               error:(FlutterError *_Nullable *_Nonnull)error {
  WKWebViewConfiguration *configuration = (WKWebViewConfiguration *)[self.instanceManager instanceForIdentifier:configurationInstanceId.longValue];
  [self.instanceManager addInstance:configuration.websiteDataStore withIdentifier:instanceId.longValue];
}


- (void)removeDataFromDataStoreWithIdentifier:(nonnull NSNumber *)instanceId
                dataTypes:(nonnull NSArray<FWFWKWebsiteDataTypeEnumData *> *)dataTypes
                since:(nonnull NSNumber *)since
                error:(FlutterError *_Nullable *_Nonnull) error {
  return [[self websiteDataStoreForIdentifier:instanceId] removeDataOfTypes:dataTypes since:since];
}
@end
