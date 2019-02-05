// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <XCTest/XCTest.h>
#import "FIAObjectTranslator.h"
#import "Stubs.h"

@interface TranslatorTest : XCTestCase

@property(strong, nonatomic) NSDictionary *periodMap;
@property(strong, nonatomic) NSDictionary *discountMap;
@property(strong, nonatomic) NSDictionary *productMap;
@property(strong, nonatomic) NSDictionary *productResponseMap;

@end

@implementation TranslatorTest

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
    @"downloadable" : @YES,
    @"downloadContentLengths" : @1,
    @"downloadContentVersion" : [NSNull null],  // not mockable
    @"subscriptionPeriod" : self.periodMap,
    @"introductoryPrice" : self.discountMap,
    @"subscriptionGroupIdentifier" : @"com.group"
  };
  self.productResponseMap =
      @{@"products" : @[ self.productMap ], @"invalidProductIdentifiers" : @[]};
}

- (void)testSKProductSubscriptionPeriodStubToMap {
  SKProductSubscriptionPeriodStub *period =
      [[SKProductSubscriptionPeriodStub alloc] initWithMap:self.periodMap];
  NSDictionary *map = [period toMap];
  XCTAssertEqualObjects(map, self.periodMap);
}

- (void)testSKProductDiscountStubToMap {
  SKProductDiscountStub *discount = [[SKProductDiscountStub alloc] initWithMap:self.discountMap];
  NSDictionary *map = [discount toMap];
  XCTAssertEqualObjects(map, self.discountMap);
}

- (void)testProductToMap {
  SKProductStub *product = [[SKProductStub alloc] initWithMap:self.productMap];
  NSDictionary *map = [product toMap];
  XCTAssertEqualObjects(map, self.productMap);
}

- (void)testProductResponseToMap {
  SKProductsResponseStub *response =
      [[SKProductsResponseStub alloc] initWithMap:self.productResponseMap];
  NSDictionary *map = [response toMap];
  XCTAssertEqualObjects(map, self.productResponseMap);
}

@end
