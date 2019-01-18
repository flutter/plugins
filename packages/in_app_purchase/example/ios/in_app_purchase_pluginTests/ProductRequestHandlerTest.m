// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <XCTest/XCTest.h>
#import "FIAPProductRequestHandler.h"
#import "Stubs.h"

#pragma tests start here

@interface ProductRequestHandlerTest : XCTestCase

@end

@implementation ProductRequestHandlerTest

- (void)testSKProductSubscriptionPeriodStubToMap {
  SKProductSubscriptionPeriodStub *period = [[SKProductSubscriptionPeriodStub alloc] init];
  NSDictionary *map = [period toMap];
  NSDictionary *match = @{@"numberOfUnits" : @(period.numberOfUnits), @"unit" : @(period.unit)};
  XCTAssertEqualObjects(map, match);

  NSDictionary *notMatch =
      @{@"numberOfUnits" : @(period.numberOfUnits + 1), @"unit" : @(period.unit)};
  XCTAssertNotEqualObjects(map, notMatch);
}

- (void)testSKProductDiscountStubToMap {
  SKProductDiscountStub *discount = [[SKProductDiscountStub alloc] init];
  NSDictionary *map = [discount toMap];
  NSDictionary *match = @{
    @"price" : discount.price,
    @"currencyCode" : discount.priceLocale.currencyCode,
    @"numberOfPeriods" : @(discount.numberOfPeriods),
    @"subscriptionPeriod" : [discount.subscriptionPeriod toMap],
    @"paymentMode" : @(discount.paymentMode)
  };
  XCTAssertEqualObjects(map, match);

  NSDictionary *notMatch = @{
    @"price" : discount.price,
    @"currencyCode" : discount.priceLocale.currencyCode,
    @"numberOfPeriods" : @(discount.numberOfPeriods + 1),
    @"subscriptionPeriod" : [discount.subscriptionPeriod toMap],
    @"paymentMode" : @(discount.paymentMode)
  };
  XCTAssertNotEqualObjects(map, notMatch);
}

- (void)testProductToMap {
  SKProductStub *product = [[SKProductStub alloc] initWithIdentifier:@"11"];
  NSDictionary *map = [product toMap];
  NSDictionary *match = @{
    @"price" : product.price,
    @"currencyCode" : product.priceLocale.currencyCode,
    @"productIdentifier" : product.productIdentifier,
    @"localizedTitle" : product.localizedTitle,
    @"localizedDescription" : product.localizedDescription,
    @"downloadable" : @(product.downloadable),
    @"downloadContentLengths" : product.downloadContentLengths,
    @"downloadContentVersion" : [NSNull null],  // not mockable
    @"subscriptionPeriod" : [product.subscriptionPeriod toMap],
    @"introductoryPrice" : [product.introductoryPrice toMap],
    @"subscriptionGroupIdentifier" : product.subscriptionGroupIdentifier
  };
  XCTAssertEqualObjects(map, match);

  NSDictionary *notMatch = @{
    @"price" : product.price,
    @"currencyCode" : product.priceLocale.currencyCode,
    @"productIdentifier" : product.productIdentifier,
    @"localizedTitle" : product.localizedTitle,
    @"localizedDescription" : product.localizedDescription,
    @"downloadable" : @(!product.downloadable),
    @"downloadContentLengths" : product.downloadContentLengths,
    @"downloadContentVersion" : [NSNull null],  // not mockable
    @"subscriptionPeriod" : [product.subscriptionPeriod toMap],
    @"introductoryPrice" : [product.introductoryPrice toMap],
    @"subscriptionGroupIdentifier" : product.subscriptionGroupIdentifier
  };
  XCTAssertNotEqualObjects(map, notMatch);
}

- (void)testProductResponseToMap {
  SKProductsResponseStub *response =
      [[SKProductsResponseStub alloc] initWithIdentifiers:[NSSet setWithArray:@[ @"123", @"456" ]]];
  NSDictionary *map = [response toMap];
  NSDictionary *match = @{
    @"products" : @[
      [[[SKProductStub alloc] initWithIdentifier:@"123"] toMap],
      [[[SKProductStub alloc] initWithIdentifier:@"456"] toMap]
    ],
    @"invalidProductIdentifiers" : @[ @"1" ]
  };
  XCTAssertEqualObjects(map, match);

  NSDictionary *notMatch = @{
    @"products" : @[
      [[[SKProductStub alloc] initWithIdentifier:@"123"] toMap],
      [[[SKProductStub alloc] initWithIdentifier:@"456"] toMap],
      [[[SKProductStub alloc] initWithIdentifier:@"666"] toMap]
    ],
    @"invalidProductIdentifiers" : @[ @"1" ]
  };
  XCTAssertNotEqualObjects(map, notMatch);
}

- (void)testRequestHandler {
  SKProductRequestStub *request =
      [[SKProductRequestStub alloc] initWithProductIdentifiers:[NSSet setWithArray:@[ @"123" ]]];
  FIAPProductRequestHandler *handler =
      [[FIAPProductRequestHandler alloc] initWithRequestRequest:request];
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"expect to get response with 1 product"];
  __block SKProductsResponse *response;
  [handler startWithCompletionHandler:^(SKProductsResponse *_Nullable r) {
    response = r;
    [expectation fulfill];
  }];
  [self waitForExpectations:@[ expectation ] timeout:5];
  XCTAssertNotNil(response);
  XCTAssertEqual(response.products.count, 1);
  SKProduct *product = response.products.firstObject;
  XCTAssertTrue([product.productIdentifier isEqualToString:@"123"]);
}

@end
