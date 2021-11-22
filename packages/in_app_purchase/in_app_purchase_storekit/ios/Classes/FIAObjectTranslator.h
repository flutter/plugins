// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FIAObjectTranslator : NSObject

// Converts an instance of SKProduct into a dictionary.
+ (NSDictionary *)getMapFromSKProduct:(SKProduct *)product;

// Converts an instance of SKProductSubscriptionPeriod into a dictionary.
+ (NSDictionary *)getMapFromSKProductSubscriptionPeriod:(SKProductSubscriptionPeriod *)period
    API_AVAILABLE(ios(11.2));

// Converts an instance of SKProductDiscount into a dictionary.
+ (NSDictionary *)getMapFromSKProductDiscount:(SKProductDiscount *)discount
    API_AVAILABLE(ios(11.2));

// Converts an array of SKProductDiscount instances into an array of dictionaries.
+ (nonnull NSArray *)getMapArrayFromSKProductDiscounts:
    (nonnull NSArray<SKProductDiscount *> *)productDiscounts API_AVAILABLE(ios(12.2));

// Converts an instance of SKProductsResponse into a dictionary.
+ (NSDictionary *)getMapFromSKProductsResponse:(SKProductsResponse *)productResponse;

// Converts an instance of SKPayment into a dictionary.
+ (NSDictionary *)getMapFromSKPayment:(SKPayment *)payment;

// Converts an instance of NSLocale into a dictionary.
+ (NSDictionary *)getMapFromNSLocale:(NSLocale *)locale;

// Creates an instance of the SKMutablePayment class based on the supplied dictionary.
+ (SKMutablePayment *)getSKMutablePaymentFromMap:(NSDictionary *)map;

// Converts an instance of SKPaymentTransaction into a dictionary.
+ (NSDictionary *)getMapFromSKPaymentTransaction:(SKPaymentTransaction *)transaction;

// Converts an instance of NSError into a dictionary.
+ (NSDictionary *)getMapFromNSError:(NSError *)error;

// Converts an instance of SKStorefront into a dictionary.
+ (NSDictionary *)getMapFromSKStorefront:(SKStorefront *)storefront
    API_AVAILABLE(ios(13), macos(10.15), watchos(6.2));

// Converts the supplied instances of SKStorefront and SKPaymentTransaction into a dictionary.
+ (NSDictionary *)getMapFromSKStorefront:(SKStorefront *)storefront
                 andSKPaymentTransaction:(SKPaymentTransaction *)transaction
    API_AVAILABLE(ios(13), macos(10.15), watchos(6.2));

// Creates an instance of the SKPaymentDiscount class based on the supplied dictionary.
+ (nullable SKPaymentDiscount *)getSKPaymentDiscountFromMap:(NSDictionary *)map
                                                  withError:(NSString *_Nullable *_Nullable)error
    API_AVAILABLE(ios(12.2));

@end
;

NS_ASSUME_NONNULL_END
