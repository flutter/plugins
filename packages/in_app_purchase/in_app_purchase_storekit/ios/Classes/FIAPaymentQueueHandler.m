// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FIAPaymentQueueHandler.h"
#import "FIAPPaymentQueueDelegate.h"
#import "FIATransactionCache.h"

@interface FIAPaymentQueueHandler ()

/// The SKPaymentQueue instance connected to the App Store and responsible for processing
/// transactions.
@property(strong, nonatomic) SKPaymentQueue *queue;

/// Callback method that is called each time the App Store indicates transactions are updated.
@property(nullable, copy, nonatomic) TransactionsUpdated transactionsUpdated;

/// Callback method that is called each time the App Store indicates transactions are removed.
@property(nullable, copy, nonatomic) TransactionsRemoved transactionsRemoved;

/// Callback method that is called each time the App Store indicates transactions failed to restore.
@property(nullable, copy, nonatomic) RestoreTransactionFailed restoreTransactionFailed;

/// Callback method that is called each time the App Store indicates restoring of transactions has
/// finished.
@property(nullable, copy, nonatomic)
    RestoreCompletedTransactionsFinished paymentQueueRestoreCompletedTransactionsFinished;

/// Callback method that is called each time an in-app purchase has been initiated from the App
/// Store.
@property(nullable, copy, nonatomic) ShouldAddStorePayment shouldAddStorePayment;

/// Callback method that is called each time the App Store indicates downloads are updated.
@property(nullable, copy, nonatomic) UpdatedDownloads updatedDownloads;

/// The transaction cache responsible for caching transactions.
///
/// Keeps track of transactions that arrive when the Flutter client is not
/// actively observing for transactions.
@property(strong, nonatomic, nonnull) FIATransactionCache *transactionCache;

/// Indicates if the Flutter client is observing transactions.
///
/// When the client is not observing, transactions are cached and send to the
/// client as soon as it starts observing. The Flutter client can start
/// observing by sending a startObservingPaymentQueue message and stop by
/// sending a stopObservingPaymentQueue message.
@property(atomic, assign, readwrite) BOOL isObservingTransactions;

@end

@implementation FIAPaymentQueueHandler

- (instancetype)initWithQueue:(nonnull SKPaymentQueue *)queue
                     transactionsUpdated:(nullable TransactionsUpdated)transactionsUpdated
                      transactionRemoved:(nullable TransactionsRemoved)transactionsRemoved
                restoreTransactionFailed:(nullable RestoreTransactionFailed)restoreTransactionFailed
    restoreCompletedTransactionsFinished:
        (nullable RestoreCompletedTransactionsFinished)restoreCompletedTransactionsFinished
                   shouldAddStorePayment:(nullable ShouldAddStorePayment)shouldAddStorePayment
                        updatedDownloads:(nullable UpdatedDownloads)updatedDownloads {
  return [[FIAPaymentQueueHandler alloc] initWithQueue:queue
                                   transactionsUpdated:transactionsUpdated
                                    transactionRemoved:transactionsRemoved
                              restoreTransactionFailed:restoreTransactionFailed
                  restoreCompletedTransactionsFinished:restoreCompletedTransactionsFinished
                                 shouldAddStorePayment:shouldAddStorePayment
                                      updatedDownloads:updatedDownloads
                                      transactionCache:[[FIATransactionCache alloc] init]];
}

- (instancetype)initWithQueue:(nonnull SKPaymentQueue *)queue
                     transactionsUpdated:(nullable TransactionsUpdated)transactionsUpdated
                      transactionRemoved:(nullable TransactionsRemoved)transactionsRemoved
                restoreTransactionFailed:(nullable RestoreTransactionFailed)restoreTransactionFailed
    restoreCompletedTransactionsFinished:
        (nullable RestoreCompletedTransactionsFinished)restoreCompletedTransactionsFinished
                   shouldAddStorePayment:(nullable ShouldAddStorePayment)shouldAddStorePayment
                        updatedDownloads:(nullable UpdatedDownloads)updatedDownloads
                        transactionCache:(nonnull FIATransactionCache *)transactionCache {
  self = [super init];
  if (self) {
    _queue = queue;
    _transactionsUpdated = transactionsUpdated;
    _transactionsRemoved = transactionsRemoved;
    _restoreTransactionFailed = restoreTransactionFailed;
    _paymentQueueRestoreCompletedTransactionsFinished = restoreCompletedTransactionsFinished;
    _shouldAddStorePayment = shouldAddStorePayment;
    _updatedDownloads = updatedDownloads;
    _transactionCache = transactionCache;

    [_queue addTransactionObserver:self];
    if (@available(iOS 13.0, macOS 10.15, *)) {
      queue.delegate = self.delegate;
    }
  }
  return self;
}

- (void)startObservingPaymentQueue {
  self.isObservingTransactions = true;

  [self processCachedTransactions];
}

- (void)stopObservingPaymentQueue {
  self.isObservingTransactions = false;
}

- (void)processCachedTransactions {
  NSArray *cachedObjects =
      [self.transactionCache getObjectsForKey:TransactionCacheKeyUpdatedTransactions];
  if (cachedObjects) {
    self.transactionsUpdated(cachedObjects);
    [self.transactionCache removeObjectsForKey:TransactionCacheKeyUpdatedTransactions];
  }

  cachedObjects = [self.transactionCache getObjectsForKey:TransactionCacheKeyUpdatedDownloads];
  if (cachedObjects) {
    self.updatedDownloads(cachedObjects);
    [self.transactionCache removeObjectsForKey:TransactionCacheKeyUpdatedDownloads];
  }

  cachedObjects = [self.transactionCache getObjectsForKey:TransactionCacheKeyRemovedTransactions];
  if (cachedObjects) {
    self.transactionsRemoved(cachedObjects);
    [self.transactionCache removeObjectsForKey:TransactionCacheKeyRemovedTransactions];
  }
}

- (BOOL)addPayment:(SKPayment *)payment {
  for (SKPaymentTransaction *transaction in self.queue.transactions) {
    if ([transaction.payment.productIdentifier isEqualToString:payment.productIdentifier]) {
      return NO;
    }
  }
  [self.queue addPayment:payment];
  return YES;
}

- (void)finishTransaction:(SKPaymentTransaction *)transaction {
  [self.queue finishTransaction:transaction];
}

- (void)restoreTransactions:(nullable NSString *)applicationName {
  if (applicationName) {
    [self.queue restoreCompletedTransactionsWithApplicationUsername:applicationName];
  } else {
    [self.queue restoreCompletedTransactions];
  }
}

- (void)presentCodeRedemptionSheet {
  if (@available(iOS 14, *)) {
    [self.queue presentCodeRedemptionSheet];
  } else {
    NSLog(@"presentCodeRedemptionSheet is only available on iOS 14 or newer");
  }
}

- (void)showPriceConsentIfNeeded {
  [self.queue showPriceConsentIfNeeded];
}

#pragma mark - observing

// Sent when the transaction array has changed (additions or state changes).  Client should check
// state of transactions and finish as appropriate.
- (void)paymentQueue:(SKPaymentQueue *)queue
    updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
  if (!self.isObservingTransactions) {
    [_transactionCache addObjects:transactions forKey:TransactionCacheKeyUpdatedTransactions];
    return;
  }

  // notify dart through callbacks.
  self.transactionsUpdated(transactions);
}

// Sent when transactions are removed from the queue (via finishTransaction:).
- (void)paymentQueue:(SKPaymentQueue *)queue
    removedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
  if (!self.isObservingTransactions) {
    [_transactionCache addObjects:transactions forKey:TransactionCacheKeyRemovedTransactions];
    return;
  }
  self.transactionsRemoved(transactions);
}

// Sent when an error is encountered while adding transactions from the user's purchase history back
// to the queue.
- (void)paymentQueue:(SKPaymentQueue *)queue
    restoreCompletedTransactionsFailedWithError:(NSError *)error {
  self.restoreTransactionFailed(error);
}

// Sent when all transactions from the user's purchase history have successfully been added back to
// the queue.
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
  self.paymentQueueRestoreCompletedTransactionsFinished();
}

// Sent when the download state has changed.
- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray<SKDownload *> *)downloads {
  if (!self.isObservingTransactions) {
    [_transactionCache addObjects:downloads forKey:TransactionCacheKeyUpdatedDownloads];
    return;
  }
  self.updatedDownloads(downloads);
}

// Sent when a user initiates an IAP buy from the App Store
- (BOOL)paymentQueue:(SKPaymentQueue *)queue
    shouldAddStorePayment:(SKPayment *)payment
               forProduct:(SKProduct *)product {
  return (self.shouldAddStorePayment(payment, product));
}

- (NSArray<SKPaymentTransaction *> *)getUnfinishedTransactions {
  return self.queue.transactions;
}

@end
