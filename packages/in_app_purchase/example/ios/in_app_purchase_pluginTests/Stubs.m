// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "Stubs.h"

@implementation SKProductSubscriptionPeriodStub

- (instancetype)initWithMap:(NSDictionary *)map {
  self = [super init];
  if (self) {
    [self setValue:map[@"numberOfUnits"] ?: @(0) forKey:@"numberOfUnits"];
    [self setValue:map[@"unit"] ?: @(0) forKey:@"unit"];
  }
  return self;
}

@end

@implementation SKProductDiscountStub

- (instancetype)initWithMap:(NSDictionary *)map {
  self = [super init];
  if (self) {
    [self setValue:map[@"price"] ?: [NSNull null] forKey:@"price"];
    NSLocale *locale = NSLocale.systemLocale;
    [self setValue:locale ?: [NSNull null] forKey:@"priceLocale"];
    [self setValue:map[@"numberOfPeriods"] ?: @(0) forKey:@"numberOfPeriods"];
    SKProductSubscriptionPeriodStub *subscriptionPeriodSub =
        [[SKProductSubscriptionPeriodStub alloc] initWithMap:map[@"subscriptionPeriod"]];
    [self setValue:subscriptionPeriodSub forKey:@"subscriptionPeriod"];
    [self setValue:map[@"paymentMode"] ?: @(0) forKey:@"paymentMode"];
  }
  return self;
}

@end

@implementation SKProductStub

- (instancetype)initWithMap:(NSDictionary *)map {
  self = [super init];
  if (self) {
    [self setValue:map[@"productIdentifier"] ?: [NSNull null] forKey:@"productIdentifier"];
    [self setValue:map[@"localizedDescription"] ?: [NSNull null] forKey:@"localizedDescription"];
    [self setValue:map[@"localizedTitle"] ?: [NSNull null] forKey:@"localizedTitle"];
    [self setValue:map[@"downloadable"] ?: @NO forKey:@"downloadable"];
    [self setValue:map[@"price"] ?: [NSNull null] forKey:@"price"];
    NSLocale *locale = NSLocale.systemLocale;
    [self setValue:locale ?: [NSNull null] forKey:@"priceLocale"];
    [self setValue:map[@"downloadContentLengths"] ?: @(0) forKey:@"downloadContentLengths"];
    SKProductSubscriptionPeriodStub *period =
        [[SKProductSubscriptionPeriodStub alloc] initWithMap:map[@"subscriptionPeriod"]];
    [self setValue:period ?: [NSNull null] forKey:@"subscriptionPeriod"];
    SKProductDiscountStub *discount =
        [[SKProductDiscountStub alloc] initWithMap:map[@"introductoryPrice"]];
    [self setValue:discount ?: [NSNull null] forKey:@"introductoryPrice"];
    [self setValue:map[@"subscriptionGroupIdentifier"] ?: [NSNull null]
            forKey:@"subscriptionGroupIdentifier"];
  }
  return self;
}

@end

@interface SKProductRequestStub ()

@property(strong, nonatomic) NSSet *identifers;
@property(strong, nonatomic) NSError *error;

@end

@implementation SKProductRequestStub

- (instancetype)initWithProductIdentifiers:(NSSet<NSString *> *)productIdentifiers {
  self = [super initWithProductIdentifiers:productIdentifiers];
  self.identifers = productIdentifiers;
  return self;
}

- (instancetype)initWithFailureError:(NSError *)error {
  self = [super init];
  self.error = error;
  return self;
}

- (void)start {
  NSMutableArray *productArray = [NSMutableArray new];
  for (NSString *identifier in self.identifers) {
    [productArray addObject:@{@"productIdentifier" : identifier}];
  }
  SKProductsResponseStub *response =
      [[SKProductsResponseStub alloc] initWithMap:@{@"products" : productArray}];
  if (self.error) {
    [self.delegate request:self didFailWithError:self.error];
  } else {
    [self.delegate productsRequest:self didReceiveResponse:response];
  }
  [self.delegate requestDidFinish:self];
}

@end

@implementation SKProductsResponseStub

- (instancetype)initWithMap:(NSDictionary *)map {
  self = [super init];
  if (self) {
    NSMutableArray *products = [NSMutableArray new];
    for (NSDictionary *productMap in map[@"products"]) {
      SKProductStub *product = [[SKProductStub alloc] initWithMap:productMap];
      [products addObject:product];
    }
    [self setValue:products forKey:@"products"];
  }
  return self;
}

@end

@interface InAppPurchasePluginStub ()

@end

@implementation InAppPurchasePluginStub

- (SKProductRequestStub *)getProductRequestWithIdentifiers:(NSSet *)identifiers {
  return [[SKProductRequestStub alloc] initWithProductIdentifiers:identifiers];
}

@end

@implementation SKPaymentTransactionStub

- (instancetype)initWithID:(NSString *)identifier {
  self = [super init];
  if (self) {
    [self setValue:identifier forKey:@"transactionIdentifier"];
  }
  return self;
}

- (instancetype)initWithMap:(NSDictionary *)map {
  self = [super init];
  if (self) {
    [self setValue:map[@"transactionIdentifier"] forKey:@"transactionIdentifier"];
    [self setValue:map[@"transactionState"] forKey:@"transactionState"];
    if (map[@"originalTransaction"] && !
                                       [map[@"originalTransaction"] isKindOfClass:[NSNull class]]) {
      [self setValue:[[SKPaymentTransactionStub alloc] initWithMap:map[@"originalTransaction"]]
              forKey:@"originalTransaction"];
    }
    [self setValue:map[@"error"] ? [[NSErrorStub alloc] initWithMap:map[@"error"]] : [NSNull null]
            forKey:@"error"];
    [self setValue:[NSDate dateWithTimeIntervalSince1970:[map[@"transactionTimeStamp"] doubleValue]]
            forKey:@"transactionDate"];
    NSMutableArray *downloads = [NSMutableArray new];
    for (NSDictionary *downloadMap in map[@"downloads"]) {
      [downloads addObject:[[SKDownloadStub alloc] initWithMap:downloadMap]];
    }
    [self setValue:downloads forKey:@"downloads"];
  }
  return self;
}

@end

@implementation SKDownloadStub

- (instancetype)initWithMap:(NSDictionary *)map {
  self = [super init];
  if (self) {
    [self setValue:map[@"state"] forKey:@"downloadState"];
    [self setValue:map[@"contentIdentifier"] ?: [NSNull null] forKey:@"contentIdentifier"];
    [self setValue:map[@"contentLength"] ?: [NSNull null] forKey:@"contentLength"];
    [self setValue:[NSURL URLWithString:map[@"contentURL"]] ?: [NSNull null] forKey:@"contentURL"];
    [self setValue:map[@"error"] ? [[NSErrorStub alloc] initWithMap:map[@"error"]] : [NSNull null]
            forKey:@"error"];
    [self setValue:map[@"progress"] ?: [NSNull null] forKey:@"progress"];
    [self setValue:map[@"timeRemaining"] ?: [NSNull null] forKey:@"timeRemaining"];
    [self setValue:[[SKPaymentTransactionStub alloc] initWithID:map[@"transactionID"]]
                       ?: [NSNull null]
            forKey:@"transaction"];
  }
  return self;
}

@end

@implementation NSErrorStub

- (instancetype)initWithMap:(NSDictionary *)map {
  return [self initWithDomain:[map objectForKey:@"domain"]
                         code:[[map objectForKey:@"code"] integerValue]
                     userInfo:[map objectForKey:@"userInfo"]];
}

@end
