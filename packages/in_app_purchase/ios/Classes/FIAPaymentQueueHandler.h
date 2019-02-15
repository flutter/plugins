// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const TestingProductID;

typedef void (^TransactionsUpdated)(NSArray<SKPaymentTransaction *> *transactions);
typedef void (^TransactionsRemoved)(NSArray<SKPaymentTransaction *> *transactions);
typedef void (^RestoreTransactionFailed)(NSError *error);
typedef void (^RestoreCompletedTransactionsFinished)(void);
typedef BOOL (^ShouldAddStorePayment)(SKPayment *payment, SKProduct *product);
typedef void (^UpdatedDownloads)(NSArray<SKDownload *> *downloads);

@interface FIAPaymentQueueHandler : NSObject <SKPaymentTransactionObserver>

@property (copy, nonatomic, readonly) NSDictionary *transactions;

- (instancetype)initWithQueue:(nonnull SKPaymentQueue *)queue
                     transactionsUpdated:(nullable TransactionsUpdated)transactionsUpdated
                      transactionRemoved:(nullable TransactionsRemoved)transactionsRemoved
                restoreTransactionFailed:(nullable RestoreTransactionFailed)restoreTransactionFailed
    restoreCompletedTransactionsFinished:
        (nullable RestoreCompletedTransactionsFinished)restoreCompletedTransactionsFinished
                   shouldAddStorePayment:(nullable ShouldAddStorePayment)shouldAddStorePayment
                        updatedDownloads:(nullable UpdatedDownloads)updatedDownloads;
- (void)addPayment:(SKPayment *)payment;
- (void)finishTransaction:(SKPaymentTransaction *)transaction;

// Enable testing.

// Because payment object in transaction is not KVC, we cannot mock the payment object in the
// transaction. So there is no easay way to create stubs and test the handler.
// When set to true, we always this a constant TestingProductID as product ID
// when storing and accessing the completion block from self.completionMap
@property(assign, nonatomic) BOOL testing;

@end

NS_ASSUME_NONNULL_END
