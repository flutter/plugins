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

@property(strong, nonatomic) NSMutableDictionary *transactionsSetter;

// Store in cache and flush to the dart later after we are sure the observer is set in dart.
// This should only handle the case when app launches and there are unfinished transactions or
// the case when user initiated the payment flow from App Store.
@property(copy, nonatomic) NSArray *transactionsToUpdate;
@property(strong, nonatomic) SKPayment *paymentShouldBeAdded;
@property(strong, nonatomic) SKProduct *productShouldBePaied;

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
    self.queue = queue;
    self.transactionsUpdated = transactionsUpdated;
    self.transactionsRemoved = transactionsRemoved;
    self.restoreTransactionFailed = restoreTransactionFailed;
    self.paymentQueueRestoreCompletedTransactionsFinished = restoreCompletedTransactionsFinished;
    self.shouldAddStorePayment = shouldAddStorePayment;
    self.updatedDownloads = updatedDownloads;
    self.transactionsSetter = [NSMutableDictionary new];
    [queue addTransactionObserver:self];
  }
  return self;
}

- (void)addPayment:(SKPayment *)payment {
  [self.queue addPayment:payment];
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

- (void)setObserverDidSet:(BOOL)observerDidSet {
  _observerDidSet = observerDidSet;
  if (observerDidSet) {
    if (self.transactionsUpdated) {
      [self paymentQueue:self.queue updatedTransactions:self.transactionsToUpdate];
      self.transactionsToUpdate = nil;
    }
    if (@available(iOS 11.0, *)) {
      if (self.paymentShouldBeAdded && self.productShouldBePaied) {
        [self paymentQueue:self.queue
            shouldAddStorePayment:self.paymentShouldBeAdded
                       forProduct:self.productShouldBePaied];
        self.paymentShouldBeAdded = nil;
        self.productShouldBePaied = nil;
      }
    }
  }
}

#pragma mark - observing
// Sent when the transaction array has changed (additions or state changes).  Client should check
// state of transactions and finish as appropriate.
- (void)paymentQueue:(SKPaymentQueue *)queue
    updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
  if (!self.observerDidSet) {
    self.transactionsToUpdate = transactions;
    return;
  }
  for (SKPaymentTransaction *transaction in transactions) {
    if (transaction.transactionIdentifier) {
      [self.transactionsSetter setObject:transaction forKey:transaction.transactionIdentifier];
    }
  }
  // notify dart through callbacks.
  self.transactionsUpdated(transactions);
}

// Sent when transactions are removed from the queue (via finishTransaction:).
- (void)paymentQueue:(SKPaymentQueue *)queue
    removedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
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
  if (!self.observerDidSet) {
    self.paymentShouldBeAdded = payment;
    self.productShouldBePaied = product;
    return NO;
  }
  return (self.shouldAddStorePayment(payment, product));
}

#pragma mark - getter

- (NSDictionary *)transactions {
  return self.transactionsSetter;
}

@end
