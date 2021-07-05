// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@import in_app_purchase_ios;

NS_ASSUME_NONNULL_BEGIN
API_AVAILABLE(ios(11.2), macos(10.13.2))
@interface SKProductSubscriptionPeriodStub : SKProductSubscriptionPeriod
- (instancetype)initWithMap:(NSDictionary *)map;
@end

API_AVAILABLE(ios(11.2), macos(10.13.2))
@interface SKProductDiscountStub : SKProductDiscount
- (instancetype)initWithMap:(NSDictionary *)map;
@end

@interface SKProductStub : SKProduct
- (instancetype)initWithMap:(NSDictionary *)map;
@end

@interface SKProductRequestStub : SKProductsRequest
- (instancetype)initWithProductIdentifiers:(NSSet<NSString *> *)productIdentifiers;
- (instancetype)initWithFailureError:(NSError *)error;
@end

@interface SKProductsResponseStub : SKProductsResponse
- (instancetype)initWithMap:(NSDictionary *)map;
@end

@interface InAppPurchasePluginStub : InAppPurchasePlugin
@end

@interface SKPaymentQueueStub : SKPaymentQueue
@property(assign, nonatomic) SKPaymentTransactionState testState;
@property(strong, nonatomic, nullable) id<SKPaymentTransactionObserver> observer;
@end

@interface SKPaymentTransactionStub : SKPaymentTransaction
- (instancetype)initWithMap:(NSDictionary *)map;
- (instancetype)initWithState:(SKPaymentTransactionState)state;
- (instancetype)initWithState:(SKPaymentTransactionState)state payment:(SKPayment *)payment;
@end

@interface SKMutablePaymentStub : SKMutablePayment
- (instancetype)initWithMap:(NSDictionary *)map;
@end

@interface NSErrorStub : NSError
- (instancetype)initWithMap:(NSDictionary *)map;
@end

@interface FIAPReceiptManagerStub : FIAPReceiptManager
// Indicates whether getReceiptData of this stub is going to return an error.
// Setting this to true will let getReceiptData give a basic NSError and return nil.
@property(assign, nonatomic) BOOL returnError;
@end

@interface SKReceiptRefreshRequestStub : SKReceiptRefreshRequest
- (instancetype)initWithFailureError:(NSError *)error;
@end

API_AVAILABLE(ios(13.0), macos(10.15))
@interface SKStorefrontStub : SKStorefront
- (instancetype)initWithMap:(NSDictionary *)map;
@end

NS_ASSUME_NONNULL_END
