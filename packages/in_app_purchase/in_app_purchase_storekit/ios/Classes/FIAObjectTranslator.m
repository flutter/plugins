// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FIAObjectTranslator.h"

#pragma mark - SKProduct Coders

@implementation FIAObjectTranslator

+ (NSDictionary *)getMapFromSKProduct:(SKProduct *)product {
  if (!product) {
    return nil;
  }
  NSMutableDictionary *map = [[NSMutableDictionary alloc] initWithDictionary:@{
    @"localizedDescription" : product.localizedDescription ?: [NSNull null],
    @"localizedTitle" : product.localizedTitle ?: [NSNull null],
    @"productIdentifier" : product.productIdentifier ?: [NSNull null],
    @"price" : product.price.description ?: [NSNull null]

  }];
  // TODO(cyanglaz): NSLocale is a complex object, want to see the actual need of getting this
  // expanded to a map. Matching android to only get the currencySymbol for now.
  // https://github.com/flutter/flutter/issues/26610
  [map setObject:[FIAObjectTranslator getMapFromNSLocale:product.priceLocale] ?: [NSNull null]
          forKey:@"priceLocale"];
  if (@available(iOS 11.2, *)) {
    [map setObject:[FIAObjectTranslator
                       getMapFromSKProductSubscriptionPeriod:product.subscriptionPeriod]
                       ?: [NSNull null]
            forKey:@"subscriptionPeriod"];
  }
  if (@available(iOS 11.2, *)) {
    [map setObject:[FIAObjectTranslator getMapFromSKProductDiscount:product.introductoryPrice]
                       ?: [NSNull null]
            forKey:@"introductoryPrice"];
  }
  if (@available(iOS 12.2, *)) {
    [map setObject:[FIAObjectTranslator getMapArrayFromSKProductDiscounts:product.discounts]
            forKey:@"discounts"];
  }
  if (@available(iOS 12.0, *)) {
    [map setObject:product.subscriptionGroupIdentifier ?: [NSNull null]
            forKey:@"subscriptionGroupIdentifier"];
  }
  return map;
}

+ (NSDictionary *)getMapFromSKProductSubscriptionPeriod:(SKProductSubscriptionPeriod *)period {
  if (!period) {
    return nil;
  }
  return @{@"numberOfUnits" : @(period.numberOfUnits), @"unit" : @(period.unit)};
}

+ (nonnull NSArray *)getMapArrayFromSKProductDiscounts:
    (nonnull NSArray<SKProductDiscount *> *)productDiscounts {
  NSMutableArray *discountsMapArray = [[NSMutableArray alloc] init];

  for (SKProductDiscount *productDiscount in productDiscounts) {
    [discountsMapArray addObject:[FIAObjectTranslator getMapFromSKProductDiscount:productDiscount]];
  }

  return discountsMapArray;
}

+ (NSDictionary *)getMapFromSKProductDiscount:(SKProductDiscount *)discount {
  if (!discount) {
    return nil;
  }
  NSMutableDictionary *map = [[NSMutableDictionary alloc] initWithDictionary:@{
    @"price" : discount.price.description ?: [NSNull null],
    @"numberOfPeriods" : @(discount.numberOfPeriods),
    @"subscriptionPeriod" :
            [FIAObjectTranslator getMapFromSKProductSubscriptionPeriod:discount.subscriptionPeriod]
        ?: [NSNull null],
    @"paymentMode" : @(discount.paymentMode),
  }];
  if (@available(iOS 12.2, *)) {
    [map setObject:discount.identifier ?: [NSNull null] forKey:@"identifier"];
    [map setObject:@(discount.type) forKey:@"type"];
  }

  // TODO(cyanglaz): NSLocale is a complex object, want to see the actual need of getting this
  // expanded to a map. Matching android to only get the currencySymbol for now.
  // https://github.com/flutter/flutter/issues/26610
  [map setObject:[FIAObjectTranslator getMapFromNSLocale:discount.priceLocale] ?: [NSNull null]
          forKey:@"priceLocale"];
  return map;
}

+ (NSDictionary *)getMapFromSKProductsResponse:(SKProductsResponse *)productResponse {
  if (!productResponse) {
    return nil;
  }
  NSMutableArray *productsMapArray = [NSMutableArray new];
  for (SKProduct *product in productResponse.products) {
    [productsMapArray addObject:[FIAObjectTranslator getMapFromSKProduct:product]];
  }
  return @{
    @"products" : productsMapArray,
    @"invalidProductIdentifiers" : productResponse.invalidProductIdentifiers ?: @[]
  };
}

+ (NSDictionary *)getMapFromSKPayment:(SKPayment *)payment {
  if (!payment) {
    return nil;
  }
  NSMutableDictionary *map = [[NSMutableDictionary alloc] initWithDictionary:@{
    @"productIdentifier" : payment.productIdentifier ?: [NSNull null],
    @"requestData" : payment.requestData ? [[NSString alloc] initWithData:payment.requestData
                                                                 encoding:NSUTF8StringEncoding]
                                         : [NSNull null],
    @"quantity" : @(payment.quantity),
    @"applicationUsername" : payment.applicationUsername ?: [NSNull null]
  }];
  [map setObject:@(payment.simulatesAskToBuyInSandbox) forKey:@"simulatesAskToBuyInSandbox"];
  return map;
}

+ (NSDictionary *)getMapFromNSLocale:(NSLocale *)locale {
  if (!locale) {
    return nil;
  }
  NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
  [map setObject:[locale objectForKey:NSLocaleCurrencySymbol] ?: [NSNull null]
          forKey:@"currencySymbol"];
  [map setObject:[locale objectForKey:NSLocaleCurrencyCode] ?: [NSNull null]
          forKey:@"currencyCode"];
  [map setObject:[locale objectForKey:NSLocaleCountryCode] ?: [NSNull null] forKey:@"countryCode"];
  return map;
}

+ (SKMutablePayment *)getSKMutablePaymentFromMap:(NSDictionary *)map {
  if (!map) {
    return nil;
  }
  SKMutablePayment *payment = [[SKMutablePayment alloc] init];
  payment.productIdentifier = map[@"productIdentifier"];
  NSString *utf8String = map[@"requestData"];
  payment.requestData = [utf8String dataUsingEncoding:NSUTF8StringEncoding];
  payment.quantity = [map[@"quantity"] integerValue];
  payment.applicationUsername = map[@"applicationUsername"];
  payment.simulatesAskToBuyInSandbox = [map[@"simulatesAskToBuyInSandbox"] boolValue];
  return payment;
}

+ (NSDictionary *)getMapFromSKPaymentTransaction:(SKPaymentTransaction *)transaction {
  if (!transaction) {
    return nil;
  }
  NSMutableDictionary *map = [[NSMutableDictionary alloc] initWithDictionary:@{
    @"error" : [FIAObjectTranslator getMapFromNSError:transaction.error] ?: [NSNull null],
    @"payment" : transaction.payment ? [FIAObjectTranslator getMapFromSKPayment:transaction.payment]
                                     : [NSNull null],
    @"originalTransaction" : transaction.originalTransaction
        ? [FIAObjectTranslator getMapFromSKPaymentTransaction:transaction.originalTransaction]
        : [NSNull null],
    @"transactionTimeStamp" : transaction.transactionDate
        ? @(transaction.transactionDate.timeIntervalSince1970)
        : [NSNull null],
    @"transactionIdentifier" : transaction.transactionIdentifier ?: [NSNull null],
    @"transactionState" : @(transaction.transactionState)
  }];

  return map;
}

+ (NSDictionary *)getMapFromNSError:(NSError *)error {
  if (!error) {
    return nil;
  }

  NSMutableDictionary *userInfo = [NSMutableDictionary new];
  for (NSErrorUserInfoKey key in error.userInfo) {
    id value = error.userInfo[key];
    userInfo[key] = [FIAObjectTranslator encodeNSErrorUserInfo:value];
  }
  return @{@"code" : @(error.code), @"domain" : error.domain ?: @"", @"userInfo" : userInfo};
}

+ (id)encodeNSErrorUserInfo:(id)value {
  if ([value isKindOfClass:[NSError class]]) {
    return [FIAObjectTranslator getMapFromNSError:value];
  } else if ([value isKindOfClass:[NSURL class]]) {
    return [value absoluteString];
  } else if ([value isKindOfClass:[NSNumber class]]) {
    return value;
  } else if ([value isKindOfClass:[NSString class]]) {
    return value;
  } else if ([value isKindOfClass:[NSArray class]]) {
    NSMutableArray *errors = [[NSMutableArray alloc] init];
    for (id error in value) {
      [errors addObject:[FIAObjectTranslator encodeNSErrorUserInfo:error]];
    }
    return errors;
  } else {
    return [NSString
        stringWithFormat:
            @"Unable to encode native userInfo object of type %@ to map. Please submit an issue at "
            @"https://github.com/flutter/flutter/issues/new with the title "
            @"\"[in_app_purchase_storekit] "
            @"Unable to encode userInfo of type %@\" and add reproduction steps and the error "
            @"details in "
            @"the description field.",
            [value class], [value class]];
  }
}

+ (NSDictionary *)getMapFromSKStorefront:(SKStorefront *)storefront {
  if (!storefront) {
    return nil;
  }

  NSMutableDictionary *map = [[NSMutableDictionary alloc] initWithDictionary:@{
    @"countryCode" : storefront.countryCode,
    @"identifier" : storefront.identifier
  }];

  return map;
}

+ (NSDictionary *)getMapFromSKStorefront:(SKStorefront *)storefront
                 andSKPaymentTransaction:(SKPaymentTransaction *)transaction {
  if (!storefront || !transaction) {
    return nil;
  }

  NSMutableDictionary *map = [[NSMutableDictionary alloc] initWithDictionary:@{
    @"storefront" : [FIAObjectTranslator getMapFromSKStorefront:storefront],
    @"transaction" : [FIAObjectTranslator getMapFromSKPaymentTransaction:transaction]
  }];

  return map;
}

+ (SKPaymentDiscount *)getSKPaymentDiscountFromMap:(NSDictionary *)map
                                         withError:(NSString **)error {
  if (!map || map.count <= 0) {
    return nil;
  }

  NSString *identifier = map[@"identifier"];
  NSString *keyIdentifier = map[@"keyIdentifier"];
  NSString *nonce = map[@"nonce"];
  NSString *signature = map[@"signature"];
  NSNumber *timestamp = map[@"timestamp"];

  if (!identifier || ![identifier isKindOfClass:NSString.class] ||
      [identifier isEqualToString:@""]) {
    if (error) {
      *error = @"When specifying a payment discount the 'identifier' field is mandatory.";
    }
    return nil;
  }

  if (!keyIdentifier || ![keyIdentifier isKindOfClass:NSString.class] ||
      [keyIdentifier isEqualToString:@""]) {
    if (error) {
      *error = @"When specifying a payment discount the 'keyIdentifier' field is mandatory.";
    }
    return nil;
  }

  if (!nonce || ![nonce isKindOfClass:NSString.class] || [nonce isEqualToString:@""]) {
    if (error) {
      *error = @"When specifying a payment discount the 'nonce' field is mandatory.";
    }
    return nil;
  }

  if (!signature || ![signature isKindOfClass:NSString.class] || [signature isEqualToString:@""]) {
    if (error) {
      *error = @"When specifying a payment discount the 'signature' field is mandatory.";
    }
    return nil;
  }

  if (!timestamp || ![timestamp isKindOfClass:NSNumber.class] || [timestamp intValue] <= 0) {
    if (error) {
      *error = @"When specifying a payment discount the 'timestamp' field is mandatory.";
    }
    return nil;
  }

  SKPaymentDiscount *discount =
      [[SKPaymentDiscount alloc] initWithIdentifier:identifier
                                      keyIdentifier:keyIdentifier
                                              nonce:[[NSUUID alloc] initWithUUIDString:nonce]
                                          signature:signature
                                          timestamp:timestamp];

  return discount;
}

@end
