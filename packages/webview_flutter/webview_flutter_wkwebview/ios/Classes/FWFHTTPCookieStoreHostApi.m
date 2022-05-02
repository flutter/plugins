// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FWFHTTPCookieStoreHostApi.h"
#import "FWFDataConverters.h"
#import "FWFWebsiteDataStoreHostApi.h"

@interface FWFHTTPCookieStoreHostApiImpl ()
@property(nonatomic) FWFInstanceManager *instanceManager;
@end

@implementation FWFHTTPCookieStoreHostApiImpl
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _instanceManager = instanceManager;
  }
  return self;
}

- (WKHTTPCookieStore *)HTTPCookieStoreForIdentifier:(NSNumber *)instanceId  API_AVAILABLE(ios(11.0)){
  return (WKHTTPCookieStore
          *)[self.instanceManager instanceForIdentifier:instanceId.longValue];
}


- (void)createFromWebsiteDataStoreWithIdentifier:(nonnull NSNumber *)instanceId
                             dataStoreIdentifier:(nonnull NSNumber *)websiteDataStoreInstanceId
                                           error:(FlutterError * _Nullable __autoreleasing * _Nonnull)error {
  if (@available(iOS 11.0, *)) {
    WKWebsiteDataStore *dataStore = (WKWebsiteDataStore *)[self.instanceManager instanceForIdentifier:websiteDataStoreInstanceId.longValue];
    [self.instanceManager addInstance:dataStore.httpCookieStore
                       withIdentifier:instanceId.longValue];
  } else {
    // Fallback on earlier versions
  }
}

- (void)setCookieForStoreWithIdentifier:(nonnull NSNumber *)instanceId cookie:(nonnull FWFNSHttpCookieData *)cookie completion:(nonnull void (^)(FlutterError * _Nullable))completion {
  NSHTTPCookie *nsCookie = FWFNSHTTPCookieFromCookieData(cookie);
  
  if (@available(iOS 11.0, *)) {
    [[self HTTPCookieStoreForIdentifier:instanceId] setCookie:nsCookie
                                            completionHandler:^{
      completion(nil);
     }
    ];
  } else {
    // Fallback on earlier versions
  }
}
@end
