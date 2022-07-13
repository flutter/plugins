// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "FIAObjectTranslator.h"
#import "FIAPaymentQueueHandler.h"
#import "Stubs.h"

@import in_app_purchase_storekit;

API_AVAILABLE(ios(13.0))
@interface FIAPPaymentQueueDelegateTests : XCTestCase

@property(strong, nonatomic) FlutterMethodChannel *channel;
@property(strong, nonatomic) SKPaymentTransaction *transaction;
@property(strong, nonatomic) SKStorefront *storefront;

@end

@implementation FIAPPaymentQueueDelegateTests

- (void)setUp {
  self.channel = OCMClassMock(FlutterMethodChannel.class);

  NSDictionary *transactionMap = @{
    @"transactionIdentifier" : [NSNull null],
    @"transactionState" : @(SKPaymentTransactionStatePurchasing),
    @"payment" : [NSNull null],
    @"error" : [FIAObjectTranslator getMapFromNSError:[NSError errorWithDomain:@"test_stub"
                                                                          code:123
                                                                      userInfo:@{}]],
    @"transactionTimeStamp" : @([NSDate date].timeIntervalSince1970),
    @"originalTransaction" : [NSNull null],
  };
  self.transaction = [[SKPaymentTransactionStub alloc] initWithMap:transactionMap];

  NSDictionary *storefrontMap = @{
    @"countryCode" : @"USA",
    @"identifier" : @"unique_identifier",
  };
  self.storefront = [[SKStorefrontStub alloc] initWithMap:storefrontMap];
}

- (void)tearDown {
  self.channel = nil;
}

- (void)testShouldContinueTransaction {
  if (@available(iOS 13.0, *)) {
    FIAPPaymentQueueDelegate *delegate =
        [[FIAPPaymentQueueDelegate alloc] initWithMethodChannel:self.channel];

    OCMStub([self.channel
        invokeMethod:@"shouldContinueTransaction"
           arguments:[FIAObjectTranslator getMapFromSKStorefront:self.storefront
                                         andSKPaymentTransaction:self.transaction]
              result:([OCMArg invokeBlockWithArgs:[NSNumber numberWithBool:NO], nil])]);

    BOOL shouldContinue = [delegate paymentQueue:OCMClassMock(SKPaymentQueue.class)
                       shouldContinueTransaction:self.transaction
                                    inStorefront:self.storefront];

    XCTAssertFalse(shouldContinue);
  }
}

- (void)testShouldContinueTransaction_should_default_to_yes {
  if (@available(iOS 13.0, *)) {
    FIAPPaymentQueueDelegate *delegate =
        [[FIAPPaymentQueueDelegate alloc] initWithMethodChannel:self.channel];

    OCMStub([self.channel invokeMethod:@"shouldContinueTransaction"
                             arguments:[FIAObjectTranslator getMapFromSKStorefront:self.storefront
                                                           andSKPaymentTransaction:self.transaction]
                                result:[OCMArg any]]);

    BOOL shouldContinue = [delegate paymentQueue:OCMClassMock(SKPaymentQueue.class)
                       shouldContinueTransaction:self.transaction
                                    inStorefront:self.storefront];

    XCTAssertTrue(shouldContinue);
  }
}

- (void)testShouldShowPriceConsentIfNeeded {
  if (@available(iOS 13.4, *)) {
    FIAPPaymentQueueDelegate *delegate =
        [[FIAPPaymentQueueDelegate alloc] initWithMethodChannel:self.channel];

    OCMStub([self.channel
        invokeMethod:@"shouldShowPriceConsent"
           arguments:nil
              result:([OCMArg invokeBlockWithArgs:[NSNumber numberWithBool:NO], nil])]);

    BOOL shouldShow =
        [delegate paymentQueueShouldShowPriceConsent:OCMClassMock(SKPaymentQueue.class)];

    XCTAssertFalse(shouldShow);
  }
}

- (void)testShouldShowPriceConsentIfNeeded_should_default_to_yes {
  if (@available(iOS 13.4, *)) {
    FIAPPaymentQueueDelegate *delegate =
        [[FIAPPaymentQueueDelegate alloc] initWithMethodChannel:self.channel];

    OCMStub([self.channel invokeMethod:@"shouldShowPriceConsent"
                             arguments:nil
                                result:[OCMArg any]]);

    BOOL shouldShow =
        [delegate paymentQueueShouldShowPriceConsent:OCMClassMock(SKPaymentQueue.class)];

    XCTAssertTrue(shouldShow);
  }
}

@end
