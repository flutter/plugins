// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FIAObjectTranslator.h"

#pragma mark - SKProduct Coders

@implementation SKProduct (Coder)

- (NSDictionary *)toMap {
  NSMutableDictionary *map = [[NSMutableDictionary alloc] initWithDictionary:@{
    @"localizedDescription" : self.localizedDescription ?: [NSNull null],
    @"localizedTitle" : self.localizedTitle ?: [NSNull null],
    @"productIdentifier" : self.productIdentifier ?: [NSNull null],
    @"downloadable" : @(self.downloadable),
    @"price" : self.price ?: [NSNull null],
    @"downloadContentLengths" : self.downloadContentLengths ?: [NSNull null],
    @"downloadContentVersion" : self.downloadContentVersion ?: [NSNull null]

  }];
  // TODO(cyanglaz): NSLocale is a complex object, want to see the actual need of getting this
  // expanded to a map. Matching android to only get the currencySymbol for now.
  // https://github.com/flutter/flutter/issues/26610
  [map setObject:[self.priceLocale toMap] ?: [NSNull null] forKey:@"priceLocale"];
  if (@available(iOS 11.2, *)) {
    [map setObject:[self.subscriptionPeriod toMap] ?: [NSNull null] forKey:@"subscriptionPeriod"];
  }
  if (@available(iOS 11.2, *)) {
    [map setObject:[self.introductoryPrice toMap] ?: [NSNull null] forKey:@"introductoryPrice"];
  }
  if (@available(iOS 12.0, *)) {
    [map setObject:self.subscriptionGroupIdentifier ?: [NSNull null]
            forKey:@"subscriptionGroupIdentifier"];
  }
  return map;
}

@end

@implementation SKProductSubscriptionPeriod (Coder)

- (NSDictionary *)toMap {
  return @{@"numberOfUnits" : @(self.numberOfUnits), @"unit" : @(self.unit)};
}

@end

@implementation SKProductDiscount (Coder)

- (NSDictionary *)toMap {
  NSMutableDictionary *map = [[NSMutableDictionary alloc] initWithDictionary:@{
    @"price" : self.price ?: [NSNull null],
    @"numberOfPeriods" : @(self.numberOfPeriods),
    @"subscriptionPeriod" : [self.subscriptionPeriod toMap] ?: [NSNull null],
    @"paymentMode" : @(self.paymentMode)
  }];

  // TODO(cyanglaz): NSLocale is a complex object, want to see the actual need of getting this
  // expanded to a map. Matching android to only get the currencySymbol for now.
  // https://github.com/flutter/flutter/issues/26610
  [map setObject:[self.priceLocale toMap] ?: [NSNull null] forKey:@"priceLocale"];
  return map;
}

@end

@implementation SKProductsResponse (Coder)

- (NSDictionary *)toMap {
  NSMutableArray *productsMapArray = [NSMutableArray new];
  for (SKProduct *product in self.products) {
    [productsMapArray addObject:[product toMap]];
  }
  return @{
    @"products" : productsMapArray,
    @"invalidProductIdentifiers" : self.invalidProductIdentifiers ?: @[]
  };
}

@end

@implementation SKPayment (Coder)

- (NSDictionary *)toMap {
  NSMutableDictionary *map = [[NSMutableDictionary alloc] initWithDictionary:@{
    @"productIdentifier" : self.productIdentifier ?: [NSNull null],
    @"requestData" : self.requestData ? [[NSString alloc] initWithData:self.requestData
                                                              encoding:NSUTF8StringEncoding]
                                      : [NSNull null],
    @"quantity" : @(self.quantity),
    @"applicationUsername" : self.applicationUsername ?: [NSNull null]
  }];
  if (@available(iOS 8.3, *)) {
    [map setObject:@(self.simulatesAskToBuyInSandbox) forKey:@"simulatesAskToBuyInSandbox"];
  }
  return map;
}

@end

@implementation NSLocale (Coder)

- (nullable NSDictionary *)toMap {
  NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
  [map setObject:[self objectForKey:NSLocaleCurrencySymbol] ?: [NSNull null]
          forKey:@"currencySymbol"];
  return map;
}

@end

@implementation SKMutablePayment (Coder)

- (instancetype)initWithMap:(NSDictionary *)map {
  self = [self init];
  if (self) {
    self.productIdentifier = map[@"productIdentifier"];
    NSString *utf8String = map[@"requestData"];
    self.requestData = [utf8String dataUsingEncoding:NSUTF8StringEncoding];
    self.quantity = [map[@"quantity"] integerValue];
    self.applicationUsername = map[@"applicationUsername"];
    if (@available(iOS 8.3, *)) {
      self.simulatesAskToBuyInSandbox = [map[@"simulatesAskToBuyInSandbox"] boolValue];
    }
  }
  return self;
}

@end

@implementation SKPaymentTransaction (Coder)

- (NSDictionary *)toMap {
  NSMutableDictionary *map = [[NSMutableDictionary alloc] initWithDictionary:@{
    @"error" : [self.error toMap] ?: [NSNull null],
    @"payment" : self.payment ? [self.payment toMap] : [NSNull null],
    @"originalTransaction" : self.originalTransaction ? [self.originalTransaction toMap]
                                                      : [NSNull null],
    @"transactionTimeStamp" : self.transactionDate ? @(self.transactionDate.timeIntervalSince1970)
                                                   : [NSNull null],
    @"transactionIdentifier" : self.transactionIdentifier ?: [NSNull null],
    @"transactionState" : @(self.transactionState)
  }];
  NSMutableArray *downloads = [NSMutableArray new];
  for (SKDownload *download in self.downloads) {
    [downloads addObject:[download toMap]];
  }
  [map setObject:downloads forKey:@"downloads"];
  return map;
}

@end

@implementation SKDownload (Coder)

- (NSDictionary *)toMap {
  NSMutableDictionary *map = [[NSMutableDictionary alloc] initWithDictionary:@{
    @"contentLength" : @(self.contentLength),
    @"contentIdentifier" : self.contentIdentifier ?: [NSNull null],
    @"contentURL" : self.contentURL.absoluteString ?: [NSNull null],
    @"contentVersion" : self.contentVersion ?: [NSNull null],
    @"error" : [self.error toMap] ?: @{},
    @"progress" : @(self.progress),
    @"timeRemaining" : @(self.timeRemaining),
    @"downloadTimeUnKnown" : @(self.timeRemaining == SKDownloadTimeRemainingUnknown),
    @"transactionID" : self.transaction.transactionIdentifier ?: [NSNull null]
  }];
  if (@available(iOS 12.0, *)) {
    [map setObject:@(self.state) forKey:@"state"];
  } else {
    [map setObject:@(self.downloadState) forKey:@"state"];
  }
  return map;
}

@end

@implementation NSError (Coder)

- (NSDictionary *)toMap {
  return
      @{@"code" : @(self.code), @"domain" : self.domain ?: @"", @"userInfo" : self.userInfo ?: @{}};
}

@end
