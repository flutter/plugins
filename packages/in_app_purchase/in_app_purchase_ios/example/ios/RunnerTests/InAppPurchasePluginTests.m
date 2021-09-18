// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "FIAPaymentQueueHandler.h"
#import "Stubs.h"

@import in_app_purchase_ios;

@interface InAppPurchasePluginTest : XCTestCase

@property(strong, nonatomic) FIAPReceiptManagerStub* receiptManagerStub;
@property(strong, nonatomic) InAppPurchasePlugin* plugin;

@end

@implementation InAppPurchasePluginTest

- (void)setUp {
  self.receiptManagerStub = [FIAPReceiptManagerStub new];
  self.plugin = [[InAppPurchasePluginStub alloc] initWithReceiptManager:self.receiptManagerStub];
}

- (void)tearDown {
}

- (void)testInvalidMethodCall {
  XCTestExpectation* expectation =
      [self expectationWithDescription:@"expect result to be not implemented"];
  FlutterMethodCall* call = [FlutterMethodCall methodCallWithMethodName:@"invalid" arguments:NULL];
  __block id result;
  [self.plugin handleMethodCall:call
                         result:^(id r) {
                           [expectation fulfill];
                           result = r;
                         }];
  [self waitForExpectations:@[ expectation ] timeout:5];
  XCTAssertEqual(result, FlutterMethodNotImplemented);
}

- (void)testCanMakePayments {
  XCTestExpectation* expectation = [self expectationWithDescription:@"expect result to be YES"];
  FlutterMethodCall* call =
      [FlutterMethodCall methodCallWithMethodName:@"-[SKPaymentQueue canMakePayments:]"
                                        arguments:NULL];
  __block id result;
  [self.plugin handleMethodCall:call
                         result:^(id r) {
                           [expectation fulfill];
                           result = r;
                         }];
  [self waitForExpectations:@[ expectation ] timeout:5];
  XCTAssertEqual(result, @YES);
}

- (void)testGetProductResponse {
  XCTestExpectation* expectation =
      [self expectationWithDescription:@"expect response contains 1 item"];
  FlutterMethodCall* call = [FlutterMethodCall
      methodCallWithMethodName:@"-[InAppPurchasePlugin startProductRequest:result:]"
                     arguments:@[ @"123" ]];
  __block id result;
  [self.plugin handleMethodCall:call
                         result:^(id r) {
                           [expectation fulfill];
                           result = r;
                         }];
  [self waitForExpectations:@[ expectation ] timeout:5];
  XCTAssert([result isKindOfClass:[NSDictionary class]]);
  NSArray* resultArray = [result objectForKey:@"products"];
  XCTAssertEqual(resultArray.count, 1);
  XCTAssertTrue([resultArray.firstObject[@"productIdentifier"] isEqualToString:@"123"]);
}

- (void)testAddPaymentFailure {
  XCTestExpectation* expectation =
      [self expectationWithDescription:@"result should return failed state"];
  FlutterMethodCall* call =
      [FlutterMethodCall methodCallWithMethodName:@"-[InAppPurchasePlugin addPayment:result:]"
                                        arguments:@{
                                          @"productIdentifier" : @"123",
                                          @"quantity" : @(1),
                                          @"simulatesAskToBuyInSandbox" : @YES,
                                        }];
  SKPaymentQueueStub* queue = [SKPaymentQueueStub new];
  queue.testState = SKPaymentTransactionStateFailed;
  __block SKPaymentTransaction* transactionForUpdateBlock;
  self.plugin.paymentQueueHandler = [[FIAPaymentQueueHandler alloc] initWithQueue:queue
      transactionsUpdated:^(NSArray<SKPaymentTransaction*>* _Nonnull transactions) {
        SKPaymentTransaction* transaction = transactions[0];
        if (transaction.transactionState == SKPaymentTransactionStateFailed) {
          transactionForUpdateBlock = transaction;
          [expectation fulfill];
        }
      }
      transactionRemoved:nil
      restoreTransactionFailed:nil
      restoreCompletedTransactionsFinished:nil
      shouldAddStorePayment:^BOOL(SKPayment* _Nonnull payment, SKProduct* _Nonnull product) {
        return YES;
      }
      updatedDownloads:nil];
  [queue addTransactionObserver:self.plugin.paymentQueueHandler];

  [self.plugin handleMethodCall:call
                         result:^(id r){
                         }];
  [self waitForExpectations:@[ expectation ] timeout:5];
  XCTAssertEqual(transactionForUpdateBlock.transactionState, SKPaymentTransactionStateFailed);
}

- (void)testAddPaymentSuccessWithMockQueue {
  XCTestExpectation* expectation =
      [self expectationWithDescription:@"result should return success state"];
  FlutterMethodCall* call =
      [FlutterMethodCall methodCallWithMethodName:@"-[InAppPurchasePlugin addPayment:result:]"
                                        arguments:@{
                                          @"productIdentifier" : @"123",
                                          @"quantity" : @(1),
                                          @"simulatesAskToBuyInSandbox" : @YES,
                                        }];
  SKPaymentQueueStub* queue = [SKPaymentQueueStub new];
  queue.testState = SKPaymentTransactionStatePurchased;
  __block SKPaymentTransaction* transactionForUpdateBlock;
  self.plugin.paymentQueueHandler = [[FIAPaymentQueueHandler alloc] initWithQueue:queue
      transactionsUpdated:^(NSArray<SKPaymentTransaction*>* _Nonnull transactions) {
        SKPaymentTransaction* transaction = transactions[0];
        if (transaction.transactionState == SKPaymentTransactionStatePurchased) {
          transactionForUpdateBlock = transaction;
          [expectation fulfill];
        }
      }
      transactionRemoved:nil
      restoreTransactionFailed:nil
      restoreCompletedTransactionsFinished:nil
      shouldAddStorePayment:^BOOL(SKPayment* _Nonnull payment, SKProduct* _Nonnull product) {
        return YES;
      }
      updatedDownloads:nil];
  [queue addTransactionObserver:self.plugin.paymentQueueHandler];
  [self.plugin handleMethodCall:call
                         result:^(id r){
                         }];
  [self waitForExpectations:@[ expectation ] timeout:5];
  XCTAssertEqual(transactionForUpdateBlock.transactionState, SKPaymentTransactionStatePurchased);
}

- (void)testAddPaymentWithNullSandboxArgument {
  XCTestExpectation* expectation =
      [self expectationWithDescription:@"result should return success state"];
  XCTestExpectation* simulatesAskToBuyInSandboxExpectation =
      [self expectationWithDescription:@"payment isn't simulatesAskToBuyInSandbox"];
  FlutterMethodCall* call =
      [FlutterMethodCall methodCallWithMethodName:@"-[InAppPurchasePlugin addPayment:result:]"
                                        arguments:@{
                                          @"productIdentifier" : @"123",
                                          @"quantity" : @(1),
                                          @"simulatesAskToBuyInSandbox" : [NSNull null],
                                        }];
  SKPaymentQueueStub* queue = [SKPaymentQueueStub new];
  queue.testState = SKPaymentTransactionStatePurchased;
  __block SKPaymentTransaction* transactionForUpdateBlock;
  self.plugin.paymentQueueHandler = [[FIAPaymentQueueHandler alloc] initWithQueue:queue
      transactionsUpdated:^(NSArray<SKPaymentTransaction*>* _Nonnull transactions) {
        SKPaymentTransaction* transaction = transactions[0];
        if (transaction.transactionState == SKPaymentTransactionStatePurchased) {
          transactionForUpdateBlock = transaction;
          [expectation fulfill];
        }
        if (!transaction.payment.simulatesAskToBuyInSandbox) {
          [simulatesAskToBuyInSandboxExpectation fulfill];
        }
      }
      transactionRemoved:nil
      restoreTransactionFailed:nil
      restoreCompletedTransactionsFinished:nil
      shouldAddStorePayment:^BOOL(SKPayment* _Nonnull payment, SKProduct* _Nonnull product) {
        return YES;
      }
      updatedDownloads:nil];
  [queue addTransactionObserver:self.plugin.paymentQueueHandler];
  [self.plugin handleMethodCall:call
                         result:^(id r){
                         }];
  [self waitForExpectations:@[ expectation, simulatesAskToBuyInSandboxExpectation ] timeout:5];
  XCTAssertEqual(transactionForUpdateBlock.transactionState, SKPaymentTransactionStatePurchased);
}

- (void)testRestoreTransactions {
  XCTestExpectation* expectation =
      [self expectationWithDescription:@"result successfully restore transactions"];
  FlutterMethodCall* call = [FlutterMethodCall
      methodCallWithMethodName:@"-[InAppPurchasePlugin restoreTransactions:result:]"
                     arguments:nil];
  SKPaymentQueueStub* queue = [SKPaymentQueueStub new];
  queue.testState = SKPaymentTransactionStatePurchased;
  __block BOOL callbackInvoked = NO;
  self.plugin.paymentQueueHandler = [[FIAPaymentQueueHandler alloc] initWithQueue:queue
      transactionsUpdated:^(NSArray<SKPaymentTransaction*>* _Nonnull transactions) {
      }
      transactionRemoved:nil
      restoreTransactionFailed:nil
      restoreCompletedTransactionsFinished:^() {
        callbackInvoked = YES;
        [expectation fulfill];
      }
      shouldAddStorePayment:nil
      updatedDownloads:nil];
  [queue addTransactionObserver:self.plugin.paymentQueueHandler];
  [self.plugin handleMethodCall:call
                         result:^(id r){
                         }];
  [self waitForExpectations:@[ expectation ] timeout:5];
  XCTAssertTrue(callbackInvoked);
}

- (void)testRetrieveReceiptDataSuccess {
  XCTestExpectation* expectation = [self expectationWithDescription:@"receipt data retrieved"];
  FlutterMethodCall* call = [FlutterMethodCall
      methodCallWithMethodName:@"-[InAppPurchasePlugin retrieveReceiptData:result:]"
                     arguments:nil];
  __block NSDictionary* result;
  [self.plugin handleMethodCall:call
                         result:^(id r) {
                           result = r;
                           [expectation fulfill];
                         }];
  [self waitForExpectations:@[ expectation ] timeout:5];
  XCTAssertNotNil(result);
  XCTAssert([result isKindOfClass:[NSString class]]);
}

- (void)testRetrieveReceiptDataError {
  XCTestExpectation* expectation = [self expectationWithDescription:@"receipt data retrieved"];
  FlutterMethodCall* call = [FlutterMethodCall
      methodCallWithMethodName:@"-[InAppPurchasePlugin retrieveReceiptData:result:]"
                     arguments:nil];
  __block NSDictionary* result;
  self.receiptManagerStub.returnError = YES;
  [self.plugin handleMethodCall:call
                         result:^(id r) {
                           result = r;
                           [expectation fulfill];
                         }];
  [self waitForExpectations:@[ expectation ] timeout:5];
  XCTAssertNotNil(result);
  XCTAssert([result isKindOfClass:[FlutterError class]]);
  NSDictionary* details = ((FlutterError*)result).details;
  XCTAssertNotNil(details[@"error"]);
  NSNumber* errorCode = (NSNumber*)details[@"error"][@"code"];
  XCTAssertEqual(errorCode, [NSNumber numberWithInteger:99]);
}

- (void)testRefreshReceiptRequest {
  XCTestExpectation* expectation = [self expectationWithDescription:@"expect success"];
  FlutterMethodCall* call =
      [FlutterMethodCall methodCallWithMethodName:@"-[InAppPurchasePlugin refreshReceipt:result:]"
                                        arguments:nil];
  __block BOOL result = NO;
  [self.plugin handleMethodCall:call
                         result:^(id r) {
                           result = YES;
                           [expectation fulfill];
                         }];
  [self waitForExpectations:@[ expectation ] timeout:5];
  XCTAssertTrue(result);
}

- (void)testPresentCodeRedemptionSheet {
  XCTestExpectation* expectation =
      [self expectationWithDescription:@"expect successfully present Code Redemption Sheet"];
  FlutterMethodCall* call = [FlutterMethodCall
      methodCallWithMethodName:@"-[InAppPurchasePlugin presentCodeRedemptionSheet:result:]"
                     arguments:nil];
  __block BOOL callbackInvoked = NO;
  [self.plugin handleMethodCall:call
                         result:^(id r) {
                           callbackInvoked = YES;
                           [expectation fulfill];
                         }];
  [self waitForExpectations:@[ expectation ] timeout:5];
  XCTAssertTrue(callbackInvoked);
}

- (void)testGetPendingTransactions {
  XCTestExpectation* expectation = [self expectationWithDescription:@"expect success"];
  FlutterMethodCall* call =
      [FlutterMethodCall methodCallWithMethodName:@"-[SKPaymentQueue transactions]" arguments:nil];
  SKPaymentQueue* mockQueue = OCMClassMock(SKPaymentQueue.class);
  NSDictionary* transactionMap = @{
    @"transactionIdentifier" : [NSNull null],
    @"transactionState" : @(SKPaymentTransactionStatePurchasing),
    @"payment" : [NSNull null],
    @"error" : [FIAObjectTranslator getMapFromNSError:[NSError errorWithDomain:@"test_stub"
                                                                          code:123
                                                                      userInfo:@{}]],
    @"transactionTimeStamp" : @([NSDate date].timeIntervalSince1970),
    @"originalTransaction" : [NSNull null],
  };
  OCMStub(mockQueue.transactions).andReturn(@[ [[SKPaymentTransactionStub alloc]
      initWithMap:transactionMap] ]);

  __block NSArray* resultArray;
  self.plugin.paymentQueueHandler = [[FIAPaymentQueueHandler alloc] initWithQueue:mockQueue
                                                              transactionsUpdated:nil
                                                               transactionRemoved:nil
                                                         restoreTransactionFailed:nil
                                             restoreCompletedTransactionsFinished:nil
                                                            shouldAddStorePayment:nil
                                                                 updatedDownloads:nil];
  [self.plugin handleMethodCall:call
                         result:^(id r) {
                           resultArray = r;
                           [expectation fulfill];
                         }];
  [self waitForExpectations:@[ expectation ] timeout:5];
  XCTAssertEqualObjects(resultArray, @[ transactionMap ]);
}

- (void)testStartAndStopObservingPaymentQueue {
  FlutterMethodCall* startCall = [FlutterMethodCall
      methodCallWithMethodName:@"-[SKPaymentQueue startObservingTransactionQueue]"
                     arguments:nil];
  FlutterMethodCall* stopCall =
      [FlutterMethodCall methodCallWithMethodName:@"-[SKPaymentQueue stopObservingTransactionQueue]"
                                        arguments:nil];

  SKPaymentQueueStub* queue = [SKPaymentQueueStub new];

  self.plugin.paymentQueueHandler =
      [[FIAPaymentQueueHandler alloc] initWithQueue:queue
                                transactionsUpdated:nil
                                 transactionRemoved:nil
                           restoreTransactionFailed:nil
               restoreCompletedTransactionsFinished:nil
                              shouldAddStorePayment:^BOOL(SKPayment* _Nonnull payment,
                                                          SKProduct* _Nonnull product) {
                                return YES;
                              }
                                   updatedDownloads:nil];

  // Check that there is no observer to start with.
  XCTAssertNil(queue.observer);

  // Start observing
  [self.plugin handleMethodCall:startCall
                         result:^(id r){
                         }];

  // Observer should be set
  XCTAssertNotNil(queue.observer);

  // Stop observing
  [self.plugin handleMethodCall:stopCall
                         result:^(id r){
                         }];

  // No observer should be set
  XCTAssertNil(queue.observer);
}

- (void)testRegisterPaymentQueueDelegate {
  if (@available(iOS 13, *)) {
    FlutterMethodCall* call =
        [FlutterMethodCall methodCallWithMethodName:@"-[SKPaymentQueue registerDelegate]"
                                          arguments:nil];

    self.plugin.paymentQueueHandler =
        [[FIAPaymentQueueHandler alloc] initWithQueue:[SKPaymentQueueStub new]
                                  transactionsUpdated:nil
                                   transactionRemoved:nil
                             restoreTransactionFailed:nil
                 restoreCompletedTransactionsFinished:nil
                                shouldAddStorePayment:nil
                                     updatedDownloads:nil];

    // Verify the delegate is nil before we register one.
    XCTAssertNil(self.plugin.paymentQueueHandler.delegate);

    [self.plugin handleMethodCall:call
                           result:^(id r){
                           }];

    // Verify the delegate is not nil after we registered one.
    XCTAssertNotNil(self.plugin.paymentQueueHandler.delegate);
  }
}

- (void)testRemovePaymentQueueDelegate {
  if (@available(iOS 13, *)) {
    FlutterMethodCall* call =
        [FlutterMethodCall methodCallWithMethodName:@"-[SKPaymentQueue removeDelegate]"
                                          arguments:nil];

    self.plugin.paymentQueueHandler =
        [[FIAPaymentQueueHandler alloc] initWithQueue:[SKPaymentQueueStub new]
                                  transactionsUpdated:nil
                                   transactionRemoved:nil
                             restoreTransactionFailed:nil
                 restoreCompletedTransactionsFinished:nil
                                shouldAddStorePayment:nil
                                     updatedDownloads:nil];
    self.plugin.paymentQueueHandler.delegate = OCMProtocolMock(@protocol(SKPaymentQueueDelegate));

    // Verify the delegate is not nil before removing it.
    XCTAssertNotNil(self.plugin.paymentQueueHandler.delegate);

    [self.plugin handleMethodCall:call
                           result:^(id r){
                           }];

    // Verify the delegate is nill after removing it.
    XCTAssertNil(self.plugin.paymentQueueHandler.delegate);
  }
}

- (void)testShowPriceConsentIfNeeded {
  FlutterMethodCall* call =
      [FlutterMethodCall methodCallWithMethodName:@"-[SKPaymentQueue showPriceConsentIfNeeded]"
                                        arguments:nil];

  FIAPaymentQueueHandler* mockQueueHandler = OCMClassMock(FIAPaymentQueueHandler.class);
  self.plugin.paymentQueueHandler = mockQueueHandler;

  [self.plugin handleMethodCall:call
                         result:^(id r){
                         }];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpartial-availability"
  if (@available(iOS 13.4, *)) {
    OCMVerify(times(1), [mockQueueHandler showPriceConsentIfNeeded]);
  } else {
    OCMVerify(never(), [mockQueueHandler showPriceConsentIfNeeded]);
  }
#pragma clang diagnostic pop
}

@end
