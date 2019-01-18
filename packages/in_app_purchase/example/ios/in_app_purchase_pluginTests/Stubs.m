// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "Stubs.h"

@implementation SKProductSubscriptionPeriodStub

- (instancetype)init {
  self = [super init];
  if (self) {
    [self setValue:@(0) forKey:@"numberOfUnits"];
    [self setValue:@(0) forKey:@"unit"];
  }
  return self;
}

@end

@implementation SKProductDiscountStub

- (instancetype)init {
  self = [super init];
  if (self) {
    [self setValue:@(1.0) forKey:@"price"];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [self setValue:locale forKey:@"priceLocale"];
    [self setValue:@(1) forKey:@"numberOfPeriods"];
    SKProductSubscriptionPeriodStub *subscriptionPeriodSub =
        [[SKProductSubscriptionPeriodStub alloc] init];
    [self setValue:subscriptionPeriodSub forKey:@"subscriptionPeriod"];
    [self setValue:@(1) forKey:@"paymentMode"];
  }
  return self;
}

@end

@implementation SKProductStub

- (instancetype)initWithIdentifier:(NSString *)identifier {
  self = [super init];
  if (self) {
    [self setValue:identifier forKey:@"productIdentifier"];
    [self setValue:@"description" forKey:@"localizedDescription"];
    [self setValue:@"title" forKey:@"localizedTitle"];
    [self setValue:@YES forKey:@"downloadable"];
    [self setValue:@(1.0) forKey:@"price"];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [self setValue:locale forKey:@"priceLocale"];
    [self setValue:@[ @1, @2 ] forKey:@"downloadContentLengths"];
    SKProductSubscriptionPeriodStub *period = [[SKProductSubscriptionPeriodStub alloc] init];
    [self setValue:period forKey:@"subscriptionPeriod"];
    SKProductDiscountStub *discount = [[SKProductDiscountStub alloc] init];
    [self setValue:discount forKey:@"introductoryPrice"];
    [self setValue:@"com.group" forKey:@"subscriptionGroupIdentifier"];
  }
  return self;
}

@end

@interface SKProductRequestStub ()

@property(strong, nonatomic) NSSet *identifers;

@end

@implementation SKProductRequestStub

- (instancetype)initWithProductIdentifiers:(NSSet<NSString *> *)productIdentifiers {
  self = [super initWithProductIdentifiers:productIdentifiers];
  self.identifers = productIdentifiers;
  return self;
}

- (void)start {
  SKProductsResponseStub *response =
      [[SKProductsResponseStub alloc] initWithIdentifiers:self.identifers];
  [self.delegate productsRequest:self didReceiveResponse:response];
}

@end

@implementation SKProductsResponseStub

- (instancetype)initWithIdentifiers:(NSSet *)identifiers {
  self = [super init];
  if (self) {
    NSMutableArray *products = [NSMutableArray new];
    for (NSString *identifier in identifiers) {
      SKProductStub *product = [[SKProductStub alloc] initWithIdentifier:identifier];
      [products addObject:product];
    }
    [self setValue:products forKey:@"products"];
    [self setValue:@[@"1"] forKey:@"invalidIdentifiers"];
  }
  return self;
}

@end

@interface InAppPurchasePluginStub ()

@end

@implementation InAppPurchasePluginStub

- (SKProductsRequest *)getRequestWithIdentifiers:(NSSet *)identifiers {
  return [[SKProductRequestStub alloc] initWithProductIdentifiers:identifiers];
}

@end
