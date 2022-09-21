// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "FIATransactionCache.h"

@class SKPaymentTransaction;

NS_ASSUME_NONNULL_BEGIN

typedef void (^TransactionsUpdated)(NSArray<SKPaymentTransaction *> *transactions);
typedef void (^TransactionsRemoved)(NSArray<SKPaymentTransaction *> *transactions);
typedef void (^RestoreTransactionFailed)(NSError *error);
typedef void (^RestoreCompletedTransactionsFinished)(void);
typedef BOOL (^ShouldAddStorePayment)(SKPayment *payment, SKProduct *product);
typedef void (^UpdatedDownloads)(NSArray<SKDownload *> *downloads);

@interface FIAPaymentQueueHandler : NSObject <SKPaymentTransactionObserver>

@property(NS_NONATOMIC_IOSONLY, weak, nullable) id<SKPaymentQueueDelegate> delegate API_AVAILABLE(
    ios(13.0), macos(10.15), watchos(6.2));

/// Creates a new FIAPaymentQueueHandler initialized with an empty
/// FIATransactionCache.
///
/// @param queue The SKPaymentQueue instance connected to the App Store and
///              responsible for processing transactions.
/// @param transactionsUpdated Callback method that is called each time the App
///                            Store indicates transactions are updated.
/// @param transactionsRemoved Callback method that is called each time the App
///                            Store indicates transactions are removed.
/// @param restoreTransactionFailed Callback method that is called each time
///                                 the App Store indicates transactions failed
///                                 to restore.
/// @param restoreCompletedTransactionsFinished Callback method that is called
///                                             each time the App Store
///                                             indicates restoring of
///                                             transactions has finished.
/// @param shouldAddStorePayment Callback method that is called each time an
///                              in-app purchase has been initiated from the
///                              App Store.
/// @param updatedDownloads Callback method that is called each time the App
///                         Store indicates downloads are updated.
- (instancetype)initWithQueue:(nonnull SKPaymentQueue *)queue
                     transactionsUpdated:(nullable TransactionsUpdated)transactionsUpdated
                      transactionRemoved:(nullable TransactionsRemoved)transactionsRemoved
                restoreTransactionFailed:(nullable RestoreTransactionFailed)restoreTransactionFailed
    restoreCompletedTransactionsFinished:
        (nullable RestoreCompletedTransactionsFinished)restoreCompletedTransactionsFinished
                   shouldAddStorePayment:(nullable ShouldAddStorePayment)shouldAddStorePayment
                        updatedDownloads:(nullable UpdatedDownloads)updatedDownloads
    DEPRECATED_MSG_ATTRIBUTE(
        "Use the "
        "'initWithQueue:transactionsUpdated:transactionsRemoved:restoreTransactionsFinished:"
        "shouldAddStorePayment:updatedDownloads:transactionCache:' message instead.");

/// Creates a new FIAPaymentQueueHandler.
///
/// The "transactionsUpdated", "transactionsRemoved" and "updatedDownloads"
/// callbacks are only called while actively observing transactions. To start
/// observing transactions send the "startObservingPaymentQueue" message.
/// Sending the "stopObservingPaymentQueue" message will stop actively
/// observing transactions. When transactions are not observed they are cached
/// to the "transactionCache" and will be delivered via the
/// "transactionsUpdated", "transactionsRemoved" and "updatedDownloads"
/// callbacks as soon as the "startObservingPaymentQueue" message arrives.
///
/// Note: cached transactions that are not processed when the application is
/// killed will be delivered again by the App Store as soon as the application
/// starts again.
///
/// @param queue The SKPaymentQueue instance connected to the App Store and
///              responsible for processing transactions.
/// @param transactionsUpdated Callback method that is called each time the App
///                            Store indicates transactions are updated.
/// @param transactionsRemoved Callback method that is called each time the App
///                            Store indicates transactions are removed.
/// @param restoreTransactionFailed Callback method that is called each time
///                                 the App Store indicates transactions failed
///                                 to restore.
/// @param restoreCompletedTransactionsFinished Callback method that is called
///                                             each time the App Store
///                                             indicates restoring of
///                                             transactions has finished.
/// @param shouldAddStorePayment Callback method that is called each time an
///                              in-app purchase has been initiated from the
///                              App Store.
/// @param updatedDownloads Callback method that is called each time the App
///                         Store indicates downloads are updated.
/// @param transactionCache An empty [FIATransactionCache] instance that is
///                         responsible for keeping track of transactions that
///                         arrive when not actively observing transactions.
- (instancetype)initWithQueue:(nonnull SKPaymentQueue *)queue
                     transactionsUpdated:(nullable TransactionsUpdated)transactionsUpdated
                      transactionRemoved:(nullable TransactionsRemoved)transactionsRemoved
                restoreTransactionFailed:(nullable RestoreTransactionFailed)restoreTransactionFailed
    restoreCompletedTransactionsFinished:
        (nullable RestoreCompletedTransactionsFinished)restoreCompletedTransactionsFinished
                   shouldAddStorePayment:(nullable ShouldAddStorePayment)shouldAddStorePayment
                        updatedDownloads:(nullable UpdatedDownloads)updatedDownloads
                        transactionCache:(nonnull FIATransactionCache *)transactionCache;
// Can throw exceptions if the transaction type is purchasing, should always used in a @try block.
- (void)finishTransaction:(nonnull SKPaymentTransaction *)transaction;
- (void)restoreTransactions:(nullable NSString *)applicationName;
- (void)presentCodeRedemptionSheet;
- (NSArray<SKPaymentTransaction *> *)getUnfinishedTransactions;

// This method needs to be called before any other methods.
- (void)startObservingPaymentQueue;
// Call this method when the Flutter app is no longer listening
- (void)stopObservingPaymentQueue;

// Appends a payment to the SKPaymentQueue.
//
// @param payment Payment object to be added to the payment queue.
// @return whether "addPayment" was successful.
- (BOOL)addPayment:(SKPayment *)payment;

// Displays the price consent sheet.
//
// The price consent sheet is only displayed when the following
// it true:
// - You have increased the price of the subscription in App Store Connect.
// - The subscriber has not yet responded to a price consent query.
// Otherwise the method has no effect.
- (void)showPriceConsentIfNeeded API_AVAILABLE(ios(13.4));

@end

NS_ASSUME_NONNULL_END
