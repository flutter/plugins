// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FIAPaymentQueueHandler.h"

@interface FIAPaymentQueueHandler ()

@property(strong, nonatomic) SKPaymentQueue *queue;
@property(nullable, copy, nonatomic) TransactionsUpdated transactionsUpdated;
@property(nullable, copy, nonatomic) TransactionsRemoved transactionsRemoved;
@property(nullable, copy, nonatomic) RestoreTransactionFailed restoreTransactionFailed;
@property(nullable, copy, nonatomic)
    RestoreCompletedTransactionsFinished paymentQueueRestoreCompletedTransactionsFinished;
@property(nullable, copy, nonatomic) ShouldAddStorePayment shouldAddStorePayment;
@property(nullable, copy, nonatomic) UpdatedDownloads updatedDownloads;

@property(strong, nonatomic)
    NSMutableDictionary<NSString *, SKPaymentTransaction *> *transactionsSetter;

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
  self = [super init];
  if (self) {
    _queue = queue;
    _transactionsUpdated = transactionsUpdated;
    _transactionsRemoved = transactionsRemoved;
    _restoreTransactionFailed = restoreTransactionFailed;
    _paymentQueueRestoreCompletedTransactionsFinished = restoreCompletedTransactionsFinished;
    _shouldAddStorePayment = shouldAddStorePayment;
    _updatedDownloads = updatedDownloads;
    _transactionsSetter = [NSMutableDictionary dictionary];
  }
  return self;
}

- (void)startObservingPaymentQueue {
  [_queue addTransactionObserver:self];
}

- (BOOL)addPayment:(SKPayment *)payment {
  if (self.transactionsSetter[payment.productIdentifier]) {
    return NO;
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

#pragma mark - observing

// Sent when the transaction array has changed (additions or state changes).  Client should check
// state of transactions and finish as appropriate.
- (void)paymentQueue:(SKPaymentQueue *)queue
    updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
  for (SKPaymentTransaction *transaction in transactions) {
    if (transaction.transactionState != SKPaymentTransactionStatePurchasing) {
      // Use product identifier instead of transaction identifier for few reasons:
      // 1. Only transactions with purchased state and failed state will have a transaction id, it
      //    will become impossible for clients to finish deferred transactions when needed.
      // 2. Using product identifiers can help prevent clients from purchasing the same
      //    subscription more than once by accident.
      self.transactionsSetter[transaction.payment.productIdentifier] = transaction;
    }
  }
  // notify dart through callbacks.
  self.transactionsUpdated(transactions);
}

// Sent when transactions are removed from the queue (via finishTransaction:).
- (void)paymentQueue:(SKPaymentQueue *)queue
    removedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
  for (SKPaymentTransaction *transaction in transactions) {
    [self.transactionsSetter removeObjectForKey:transaction.payment.productIdentifier];
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

#pragma mark - getter

- (NSDictionary<NSString *, SKPaymentTransaction *> *)transactions {
  return [self.transactionsSetter copy];
}

@end
