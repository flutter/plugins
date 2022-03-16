// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "Stubs.h"

@import in_app_purchase_storekit;

@interface PaymentQueueTest : XCTestCase

@property(strong, nonatomic) NSDictionary *periodMap;
@property(strong, nonatomic) NSDictionary *discountMap;
@property(strong, nonatomic) NSDictionary *productMap;
@property(strong, nonatomic) NSDictionary *productResponseMap;

@end

@implementation PaymentQueueTest

- (void)setUp {
  self.periodMap = @{@"numberOfUnits" : @(0), @"unit" : @(0)};
  self.discountMap = @{
    @"price" : @1.0,
    @"currencyCode" : @"USD",
    @"numberOfPeriods" : @1,
    @"subscriptionPeriod" : self.periodMap,
    @"paymentMode" : @1
  };
  self.productMap = @{
    @"price" : @1.0,
    @"currencyCode" : @"USD",
    @"productIdentifier" : @"123",
    @"localizedTitle" : @"title",
    @"localizedDescription" : @"des",
    @"subscriptionPeriod" : self.periodMap,
    @"introductoryPrice" : self.discountMap,
    @"subscriptionGroupIdentifier" : @"com.group"
  };
  self.productResponseMap =
      @{@"products" : @[ self.productMap ], @"invalidProductIdentifiers" : [NSNull null]};
}

- (void)testTransactionPurchased {
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"expect to get purchased transcation."];
  SKPaymentQueueStub *queue = [[SKPaymentQueueStub alloc] init];
  queue.testState = SKPaymentTransactionStatePurchased;
  __block SKPaymentTransactionStub *tran;
  FIAPaymentQueueHandler *handler = [[FIAPaymentQueueHandler alloc] initWithQueue:queue
      transactionsUpdated:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
        SKPaymentTransaction *transaction = transactions[0];
        tran = (SKPaymentTransactionStub *)transaction;
        [expectation fulfill];
      }
      transactionRemoved:nil
      restoreTransactionFailed:nil
      restoreCompletedTransactionsFinished:nil
      shouldAddStorePayment:^BOOL(SKPayment *_Nonnull payment, SKProduct *_Nonnull product) {
        return YES;
      }
      updatedDownloads:nil
      transactionCache:OCMClassMock(FIATransactionCache.class)];
  SKPayment *payment =
      [SKPayment paymentWithProduct:[[SKProductStub alloc] initWithMap:self.productResponseMap]];
  [handler startObservingPaymentQueue];
  [handler addPayment:payment];
  [self waitForExpectations:@[ expectation ] timeout:5];
  XCTAssertEqual(tran.transactionState, SKPaymentTransactionStatePurchased);
  XCTAssertEqual(tran.transactionIdentifier, @"fakeID");
}

- (void)testTransactionFailed {
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"expect to get failed transcation."];
  SKPaymentQueueStub *queue = [[SKPaymentQueueStub alloc] init];
  queue.testState = SKPaymentTransactionStateFailed;
  __block SKPaymentTransactionStub *tran;
  FIAPaymentQueueHandler *handler = [[FIAPaymentQueueHandler alloc] initWithQueue:queue
      transactionsUpdated:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
        SKPaymentTransaction *transaction = transactions[0];
        tran = (SKPaymentTransactionStub *)transaction;
        [expectation fulfill];
      }
      transactionRemoved:nil
      restoreTransactionFailed:nil
      restoreCompletedTransactionsFinished:nil
      shouldAddStorePayment:^BOOL(SKPayment *_Nonnull payment, SKProduct *_Nonnull product) {
        return YES;
      }
      updatedDownloads:nil
      transactionCache:OCMClassMock(FIATransactionCache.class)];

  SKPayment *payment =
      [SKPayment paymentWithProduct:[[SKProductStub alloc] initWithMap:self.productResponseMap]];
  [handler startObservingPaymentQueue];
  [handler addPayment:payment];
  [self waitForExpectations:@[ expectation ] timeout:5];
  XCTAssertEqual(tran.transactionState, SKPaymentTransactionStateFailed);
  XCTAssertEqual(tran.transactionIdentifier, nil);
}

- (void)testTransactionRestored {
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"expect to get restored transcation."];
  SKPaymentQueueStub *queue = [[SKPaymentQueueStub alloc] init];
  queue.testState = SKPaymentTransactionStateRestored;
  __block SKPaymentTransactionStub *tran;
  FIAPaymentQueueHandler *handler = [[FIAPaymentQueueHandler alloc] initWithQueue:queue
      transactionsUpdated:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
        SKPaymentTransaction *transaction = transactions[0];
        tran = (SKPaymentTransactionStub *)transaction;
        [expectation fulfill];
      }
      transactionRemoved:nil
      restoreTransactionFailed:nil
      restoreCompletedTransactionsFinished:nil
      shouldAddStorePayment:^BOOL(SKPayment *_Nonnull payment, SKProduct *_Nonnull product) {
        return YES;
      }
      updatedDownloads:nil
      transactionCache:OCMClassMock(FIATransactionCache.class)];

  SKPayment *payment =
      [SKPayment paymentWithProduct:[[SKProductStub alloc] initWithMap:self.productResponseMap]];
  [handler startObservingPaymentQueue];
  [handler addPayment:payment];
  [self waitForExpectations:@[ expectation ] timeout:5];
  XCTAssertEqual(tran.transactionState, SKPaymentTransactionStateRestored);
  XCTAssertEqual(tran.transactionIdentifier, @"fakeID");
}

- (void)testTransactionPurchasing {
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"expect to get purchasing transcation."];
  SKPaymentQueueStub *queue = [[SKPaymentQueueStub alloc] init];
  queue.testState = SKPaymentTransactionStatePurchasing;
  __block SKPaymentTransactionStub *tran;
  FIAPaymentQueueHandler *handler = [[FIAPaymentQueueHandler alloc] initWithQueue:queue
      transactionsUpdated:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
        SKPaymentTransaction *transaction = transactions[0];
        tran = (SKPaymentTransactionStub *)transaction;
        [expectation fulfill];
      }
      transactionRemoved:nil
      restoreTransactionFailed:nil
      restoreCompletedTransactionsFinished:nil
      shouldAddStorePayment:^BOOL(SKPayment *_Nonnull payment, SKProduct *_Nonnull product) {
        return YES;
      }
      updatedDownloads:nil
      transactionCache:OCMClassMock(FIATransactionCache.class)];

  SKPayment *payment =
      [SKPayment paymentWithProduct:[[SKProductStub alloc] initWithMap:self.productResponseMap]];
  [handler startObservingPaymentQueue];
  [handler addPayment:payment];
  [self waitForExpectations:@[ expectation ] timeout:5];
  XCTAssertEqual(tran.transactionState, SKPaymentTransactionStatePurchasing);
  XCTAssertEqual(tran.transactionIdentifier, nil);
}

- (void)testTransactionDeferred {
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"expect to get deffered transcation."];
  SKPaymentQueueStub *queue = [[SKPaymentQueueStub alloc] init];
  queue.testState = SKPaymentTransactionStateDeferred;
  __block SKPaymentTransactionStub *tran;
  FIAPaymentQueueHandler *handler = [[FIAPaymentQueueHandler alloc] initWithQueue:queue
      transactionsUpdated:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
        SKPaymentTransaction *transaction = transactions[0];
        tran = (SKPaymentTransactionStub *)transaction;
        [expectation fulfill];
      }
      transactionRemoved:nil
      restoreTransactionFailed:nil
      restoreCompletedTransactionsFinished:nil
      shouldAddStorePayment:^BOOL(SKPayment *_Nonnull payment, SKProduct *_Nonnull product) {
        return YES;
      }
      updatedDownloads:nil
      transactionCache:OCMClassMock(FIATransactionCache.class)];
  SKPayment *payment =
      [SKPayment paymentWithProduct:[[SKProductStub alloc] initWithMap:self.productResponseMap]];
  [handler startObservingPaymentQueue];
  [handler addPayment:payment];
  [self waitForExpectations:@[ expectation ] timeout:5];
  XCTAssertEqual(tran.transactionState, SKPaymentTransactionStateDeferred);
  XCTAssertEqual(tran.transactionIdentifier, nil);
}

- (void)testFinishTransaction {
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"handler.transactions should be empty."];
  SKPaymentQueueStub *queue = [[SKPaymentQueueStub alloc] init];
  queue.testState = SKPaymentTransactionStateDeferred;
  __block FIAPaymentQueueHandler *handler = [[FIAPaymentQueueHandler alloc] initWithQueue:queue
      transactionsUpdated:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
        XCTAssertEqual(transactions.count, 1);
        SKPaymentTransaction *transaction = transactions[0];
        [handler finishTransaction:transaction];
      }
      transactionRemoved:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
        XCTAssertEqual(transactions.count, 1);
        [expectation fulfill];
      }
      restoreTransactionFailed:nil
      restoreCompletedTransactionsFinished:nil
      shouldAddStorePayment:^BOOL(SKPayment *_Nonnull payment, SKProduct *_Nonnull product) {
        return YES;
      }
      updatedDownloads:nil
      transactionCache:OCMClassMock(FIATransactionCache.class)];
  SKPayment *payment =
      [SKPayment paymentWithProduct:[[SKProductStub alloc] initWithMap:self.productResponseMap]];
  [handler startObservingPaymentQueue];
  [handler addPayment:payment];
  [self waitForExpectations:@[ expectation ] timeout:5];
}

- (void)testStartObservingPaymentQueueShouldNotProcessTransactionsWhenCacheIsEmpty {
  FIATransactionCache *mockCache = OCMClassMock(FIATransactionCache.class);
  FIAPaymentQueueHandler *handler =
      [[FIAPaymentQueueHandler alloc] initWithQueue:[[SKPaymentQueueStub alloc] init]
          transactionsUpdated:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
            XCTFail("transactionsUpdated callback should not be called when cache is empty.");
          }
          transactionRemoved:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
            XCTFail("transactionRemoved callback should not be called when cache is empty.");
          }
          restoreTransactionFailed:nil
          restoreCompletedTransactionsFinished:nil
          shouldAddStorePayment:^BOOL(SKPayment *_Nonnull payment, SKProduct *_Nonnull product) {
            return YES;
          }
          updatedDownloads:^(NSArray<SKDownload *> *_Nonnull downloads) {
            XCTFail("updatedDownloads callback should not be called when cache is empty.");
          }
          transactionCache:mockCache];

  [handler startObservingPaymentQueue];

  OCMVerify(times(1), [mockCache getObjectsForKey:TransactionCacheKeyUpdatedTransactions]);
  OCMVerify(times(1), [mockCache getObjectsForKey:TransactionCacheKeyUpdatedDownloads]);
  OCMVerify(times(1), [mockCache getObjectsForKey:TransactionCacheKeyRemovedTransactions]);
}

- (void)
    testStartObservingPaymentQueueShouldNotProcessTransactionsWhenCacheContainsEmptyTransactionArrays {
  FIATransactionCache *mockCache = OCMClassMock(FIATransactionCache.class);
  FIAPaymentQueueHandler *handler =
      [[FIAPaymentQueueHandler alloc] initWithQueue:[[SKPaymentQueueStub alloc] init]
          transactionsUpdated:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
            XCTFail("transactionsUpdated callback should not be called when cache is empty.");
          }
          transactionRemoved:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
            XCTFail("transactionRemoved callback should not be called when cache is empty.");
          }
          restoreTransactionFailed:nil
          restoreCompletedTransactionsFinished:nil
          shouldAddStorePayment:^BOOL(SKPayment *_Nonnull payment, SKProduct *_Nonnull product) {
            return YES;
          }
          updatedDownloads:^(NSArray<SKDownload *> *_Nonnull downloads) {
            XCTFail("updatedDownloads callback should not be called when cache is empty.");
          }
          transactionCache:mockCache];

  OCMStub([mockCache getObjectsForKey:TransactionCacheKeyUpdatedTransactions]).andReturn(@[]);
  OCMStub([mockCache getObjectsForKey:TransactionCacheKeyUpdatedDownloads]).andReturn(@[]);
  OCMStub([mockCache getObjectsForKey:TransactionCacheKeyRemovedTransactions]).andReturn(@[]);

  [handler startObservingPaymentQueue];

  OCMVerify(times(1), [mockCache getObjectsForKey:TransactionCacheKeyUpdatedTransactions]);
  OCMVerify(times(1), [mockCache getObjectsForKey:TransactionCacheKeyUpdatedDownloads]);
  OCMVerify(times(1), [mockCache getObjectsForKey:TransactionCacheKeyRemovedTransactions]);
}

- (void)testStartObservingPaymentQueueShouldProcessTransactionsForItemsInCache {
  XCTestExpectation *updateTransactionsExpectation =
      [self expectationWithDescription:
                @"transactionsUpdated callback should be called with one transaction."];
  XCTestExpectation *removeTransactionsExpectation =
      [self expectationWithDescription:
                @"transactionsRemoved callback should be called with one transaction."];
  XCTestExpectation *updateDownloadsExpectation =
      [self expectationWithDescription:
                @"downloadsUpdated callback should be called with one transaction."];
  SKPaymentTransaction *mockTransaction = OCMClassMock(SKPaymentTransaction.class);
  SKDownload *mockDownload = OCMClassMock(SKDownload.class);
  FIATransactionCache *mockCache = OCMClassMock(FIATransactionCache.class);
  FIAPaymentQueueHandler *handler =
      [[FIAPaymentQueueHandler alloc] initWithQueue:[[SKPaymentQueueStub alloc] init]
          transactionsUpdated:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
            XCTAssertEqualObjects(transactions, @[ mockTransaction ]);
            [updateTransactionsExpectation fulfill];
          }
          transactionRemoved:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
            XCTAssertEqualObjects(transactions, @[ mockTransaction ]);
            [removeTransactionsExpectation fulfill];
          }
          restoreTransactionFailed:nil
          restoreCompletedTransactionsFinished:nil
          shouldAddStorePayment:^BOOL(SKPayment *_Nonnull payment, SKProduct *_Nonnull product) {
            return YES;
          }
          updatedDownloads:^(NSArray<SKDownload *> *_Nonnull downloads) {
            XCTAssertEqualObjects(downloads, @[ mockDownload ]);
            [updateDownloadsExpectation fulfill];
          }
          transactionCache:mockCache];

  OCMStub([mockCache getObjectsForKey:TransactionCacheKeyUpdatedTransactions]).andReturn(@[
    mockTransaction
  ]);
  OCMStub([mockCache getObjectsForKey:TransactionCacheKeyUpdatedDownloads]).andReturn(@[
    mockDownload
  ]);
  OCMStub([mockCache getObjectsForKey:TransactionCacheKeyRemovedTransactions]).andReturn(@[
    mockTransaction
  ]);

  [handler startObservingPaymentQueue];

  [self waitForExpectations:@[
    updateTransactionsExpectation, removeTransactionsExpectation, updateDownloadsExpectation
  ]
                    timeout:5];
  OCMVerify(times(1), [mockCache getObjectsForKey:TransactionCacheKeyUpdatedTransactions]);
  OCMVerify(times(1), [mockCache getObjectsForKey:TransactionCacheKeyUpdatedDownloads]);
  OCMVerify(times(1), [mockCache getObjectsForKey:TransactionCacheKeyRemovedTransactions]);
  OCMVerify(times(1), [mockCache clear]);
}

- (void)testTransactionsShouldBeCachedWhenNotObserving {
  SKPaymentQueueStub *queue = [[SKPaymentQueueStub alloc] init];
  FIATransactionCache *mockCache = OCMClassMock(FIATransactionCache.class);
  FIAPaymentQueueHandler *handler = [[FIAPaymentQueueHandler alloc] initWithQueue:queue
      transactionsUpdated:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
        XCTFail("transactionsUpdated callback should not be called when cache is empty.");
      }
      transactionRemoved:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
        XCTFail("transactionRemoved callback should not be called when cache is empty.");
      }
      restoreTransactionFailed:nil
      restoreCompletedTransactionsFinished:nil
      shouldAddStorePayment:^BOOL(SKPayment *_Nonnull payment, SKProduct *_Nonnull product) {
        return YES;
      }
      updatedDownloads:^(NSArray<SKDownload *> *_Nonnull downloads) {
        XCTFail("updatedDownloads callback should not be called when cache is empty.");
      }
      transactionCache:mockCache];

  SKPayment *payment =
      [SKPayment paymentWithProduct:[[SKProductStub alloc] initWithMap:self.productResponseMap]];
  [handler addPayment:payment];

  OCMVerify(times(1), [mockCache addObjects:[OCMArg any]
                                     forKey:TransactionCacheKeyUpdatedTransactions]);
  OCMVerify(never(), [mockCache addObjects:[OCMArg any]
                                    forKey:TransactionCacheKeyUpdatedDownloads]);
  OCMVerify(never(), [mockCache addObjects:[OCMArg any]
                                    forKey:TransactionCacheKeyRemovedTransactions]);
}

- (void)testTransactionsShouldNotBeCachedWhenObserving {
  XCTestExpectation *updateTransactionsExpectation =
      [self expectationWithDescription:
                @"transactionsUpdated callback should be called with one transaction."];
  XCTestExpectation *removeTransactionsExpectation =
      [self expectationWithDescription:
                @"transactionsRemoved callback should be called with one transaction."];
  XCTestExpectation *updateDownloadsExpectation =
      [self expectationWithDescription:
                @"downloadsUpdated callback should be called with one transaction."];
  SKPaymentTransaction *mockTransaction = OCMClassMock(SKPaymentTransaction.class);
  SKDownload *mockDownload = OCMClassMock(SKDownload.class);
  SKPaymentQueueStub *queue = [[SKPaymentQueueStub alloc] init];
  queue.testState = SKPaymentTransactionStatePurchased;
  FIATransactionCache *mockCache = OCMClassMock(FIATransactionCache.class);
  FIAPaymentQueueHandler *handler = [[FIAPaymentQueueHandler alloc] initWithQueue:queue
      transactionsUpdated:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
        XCTAssertEqualObjects(transactions, @[ mockTransaction ]);
        [updateTransactionsExpectation fulfill];
      }
      transactionRemoved:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
        XCTAssertEqualObjects(transactions, @[ mockTransaction ]);
        [removeTransactionsExpectation fulfill];
      }
      restoreTransactionFailed:nil
      restoreCompletedTransactionsFinished:nil
      shouldAddStorePayment:^BOOL(SKPayment *_Nonnull payment, SKProduct *_Nonnull product) {
        return YES;
      }
      updatedDownloads:^(NSArray<SKDownload *> *_Nonnull downloads) {
        XCTAssertEqualObjects(downloads, @[ mockDownload ]);
        [updateDownloadsExpectation fulfill];
      }
      transactionCache:mockCache];

  [handler startObservingPaymentQueue];
  [handler paymentQueue:queue updatedTransactions:@[ mockTransaction ]];
  [handler paymentQueue:queue removedTransactions:@[ mockTransaction ]];
  [handler paymentQueue:queue updatedDownloads:@[ mockDownload ]];

  [self waitForExpectations:@[
    updateTransactionsExpectation, removeTransactionsExpectation, updateDownloadsExpectation
  ]
                    timeout:5];
  OCMVerify(never(), [mockCache addObjects:[OCMArg any]
                                    forKey:TransactionCacheKeyUpdatedTransactions]);
  OCMVerify(never(), [mockCache addObjects:[OCMArg any]
                                    forKey:TransactionCacheKeyUpdatedDownloads]);
  OCMVerify(never(), [mockCache addObjects:[OCMArg any]
                                    forKey:TransactionCacheKeyRemovedTransactions]);
}
@end
