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
  return (WKWebsiteDataStore *)[self.instanceManager instanceForIdentifier:instanceId.longValue];
}

- (void)createFromWebViewConfigurationWithIdentifier:(nonnull NSNumber *)instanceId
                             configurationIdentifier:(nonnull NSNumber *)configurationInstanceId
                                               error:(FlutterError *_Nullable *_Nonnull)error {
  WKWebViewConfiguration *configuration = (WKWebViewConfiguration *)[self.instanceManager
      instanceForIdentifier:configurationInstanceId.longValue];
  [self.instanceManager addInstance:configuration.websiteDataStore
                     withIdentifier:instanceId.longValue];
}

- (void)createDefaultDataStoreWithIdentifier:(nonnull NSNumber *)instanceId
                                       error:(FlutterError *_Nullable __autoreleasing *_Nonnull)
                                                 error {
  [self.instanceManager addInstance:[WKWebsiteDataStore defaultDataStore]
                     withIdentifier:instanceId.longValue];
}

- (void)
    removeDataFromDataStoreWithIdentifier:(nonnull NSNumber *)instanceId
                                  ofTypes:
                                      (nonnull NSArray<FWFWKWebsiteDataTypeEnumData *> *)dataTypes
                            modifiedSince:(nonnull NSNumber *)modificationTimeInSecondsSinceEpoch
                               completion:(nonnull void (^)(NSNumber *_Nullable,
                                                            FlutterError *_Nullable))completion {
  NSMutableSet<NSString *> *stringDataTypes = [NSMutableSet set];
  for (FWFWKWebsiteDataTypeEnumData *type in dataTypes) {
    [stringDataTypes addObject:FWFWKWebsiteDataTypeFromEnumData(type)];
  }

  WKWebsiteDataStore *dataStore = [self websiteDataStoreForIdentifier:instanceId];
  [dataStore
      fetchDataRecordsOfTypes:stringDataTypes
            completionHandler:^(NSArray<WKWebsiteDataRecord *> *records) {
              [dataStore
                  removeDataOfTypes:stringDataTypes
                      modifiedSince:[NSDate dateWithTimeIntervalSince1970:
                                                modificationTimeInSecondsSinceEpoch.doubleValue]
                  completionHandler:^{
                    completion(@(records.count > 0), nil);
                  }];
            }];
}
@end
