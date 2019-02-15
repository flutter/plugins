// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FIAPaymentQueueHandler.h"

NSString *const TestingProductID = @"testing";

@interface FIAPaymentQueueHandler ()

@property(strong, nonatomic) SKPaymentQueue *queue;
@property(nullable, copy, nonatomic) TransactionsUpdated transactionsUpdated;
@property(nullable, copy, nonatomic) TransactionsRemoved transactionsRemoved;
@property(nullable, copy, nonatomic) RestoreTransactionFailed restoreTransactionFailed;
@property(nullable, copy, nonatomic)
    RestoreCompletedTransactionsFinished paymentQueueRestoreCompletedTransactionsFinished;
@property(nullable, copy, nonatomic) ShouldAddStorePayment shouldAddStorePayment;
@property(nullable, copy, nonatomic) UpdatedDownloads updatedDownloads;

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
  }
  return self;
}

- (void)addPayment:(SKPayment *)payment {
  NSString *productID = payment.productIdentifier;
  if (self.testing) {
    productID = TestingProductID;
  }
  [self.queue addPayment:payment];
}

#pragma mark - observing
// Sent when the transaction array has changed (additions or state changes).  Client should check
// state of transactions and finish as appropriate.
- (void)paymentQueue:(SKPaymentQueue *)queue
    updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
  // notify dart through callbacks.
  if (self.transactionsUpdated) {
    self.transactionsUpdated(transactions);
  }
  for (SKPaymentTransaction *transaction in transactions) {
    switch (transaction.transactionState) {
        // The following three states indicates that the transaction has been complete.
        // We mark the transaction to be finished and send the signal back to dart.
      case SKPaymentTransactionStatePurchased:
      case SKPaymentTransactionStateFailed:
      case SKPaymentTransactionStateRestored:
        // mark finished transaction as finished as required by OBJC api.
        [queue finishTransaction:transaction];
        break;
      default:
        break;
    }
  }
}

// Sent when transactions are removed from the queue (via finishTransaction:).
- (void)paymentQueue:(SKPaymentQueue *)queue
    removedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
  if (self.transactionsRemoved) {
    self.transactionsRemoved(transactions);
  }
}

// Sent when an error is encountered while adding transactions from the user's purchase history back
// to the queue.
- (void)paymentQueue:(SKPaymentQueue *)queue
    restoreCompletedTransactionsFailedWithError:(NSError *)error {
  if (self.restoreTransactionFailed) {
    self.restoreTransactionFailed(error);
  }
}

// Sent when all transactions from the user's purchase history have successfully been added back to
// the queue.
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
  if (self.paymentQueueRestoreCompletedTransactionsFinished) {
    self.paymentQueueRestoreCompletedTransactionsFinished();
  }
}

// Sent when the download state has changed.
- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray<SKDownload *> *)downloads {
  if (self.updatedDownloads) {
    self.updatedDownloads(downloads);
  }
}

// Sent when a user initiates an IAP buy from the App Store
- (BOOL)paymentQueue:(SKPaymentQueue *)queue
    shouldAddStorePayment:(SKPayment *)payment
               forProduct:(SKProduct *)product {
  if (self.shouldAddStorePayment) {
    return (self.shouldAddStorePayment(payment, product));
  }
  return YES;
}

@end
