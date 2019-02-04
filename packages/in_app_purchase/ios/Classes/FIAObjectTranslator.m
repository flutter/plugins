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
  if (@available(iOS 10.0, *)) {
    // TODO(cyanglaz): NSLocale is a complex object, want to see the actual need of getting this
    // expanded to a map. Matching android to only get the currencyCode for now.
    // https://github.com/flutter/flutter/issues/26610
    [map setObject:self.priceLocale.currencyCode ?: [NSNull null] forKey:@"currencyCode"];
  }
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

  if (@available(iOS 10.0, *)) {
    // TODO(cyanglaz): NSLocale is a complex object, want to see the actual need of getting this
    // expanded to a map. Matching android to only get the currencyCode for now.
    // https://github.com/flutter/flutter/issues/26610
    [map setObject:self.priceLocale.currencyCode ?: [NSNull null] forKey:@"currencyCode"];
  }
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
