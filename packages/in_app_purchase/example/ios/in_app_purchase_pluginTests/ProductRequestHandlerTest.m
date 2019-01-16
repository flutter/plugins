//
//  ProductRequestHandlerTest.m
//  in_app_purchase_pluginTests
//
//  Created by Chris Yang on 1/11/19.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

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
  NSDictionary *match = @{@"numberOfUnits" : @(0), @"unit" : @(0)};
  XCTAssertEqualObjects(map, match);

  NSDictionary *notMatch = @{@"numberOfUnits" : @(0), @"unit" : @(1)};
  XCTAssertNotEqualObjects(map, notMatch);
}

- (void)testSKProductDiscountStubToMap {
  SKProductDiscountStub *discount = [[SKProductDiscountStub alloc] init];
  NSDictionary *map = [discount toMap];
  NSDictionary *match = @{
    @"price" : @(1.0),
    @"currencyCode" : @"USD",
    @"numberOfPeriods" : @(1),
    @"subscriptionPeriod" : @{@"numberOfUnits" : @(0), @"unit" : @(0)},
    @"paymentMode" : @(1)
  };
  XCTAssertEqualObjects(map, match);

  NSDictionary *notMatch = @{
    @"price" : @(1.0),
    @"currencyCode" : @"USD",
    @"numberOfPeriods" : @(1),
    @"subscriptionPeriod" : @{@"numberOfUnits" : @(0), @"unit" : @(0)},
    @"paymentMode" : @(0)
  };
  XCTAssertNotEqualObjects(map, notMatch);
}

- (void)testProductToMap {
  SKProductStub *product = [[SKProductStub alloc] initWithIdentifier:@"11"];
  NSDictionary *map = [product toMap];
  NSDictionary *match = @{
    @"price" : @(1.0),
    @"currencyCode" : @"USD",
    @"productIdentifier" : @"11",
    @"localizedTitle" : @"title",
    @"localizedDescription" : @"description",
    @"downloadable" : @YES,
    @"downloadContentLengths" : @[ @1, @2 ],
    @"downloadContentVersion" : [NSNull null],
    @"subscriptionPeriod" : @{@"numberOfUnits" : @(0), @"unit" : @(0)},
    @"introductoryPrice" : @{
      @"price" : @(1.0),
      @"currencyCode" : @"USD",
      @"numberOfPeriods" : @(1),
      @"subscriptionPeriod" : @{@"numberOfUnits" : @(0), @"unit" : @(0)},
      @"paymentMode" : @(1)
    },
    @"subscriptionGroupIdentifier" : @"com.group"
  };
  XCTAssertEqualObjects(map, match);

  NSDictionary *notMatch = @{
    @"price" : @(1.0),
    @"currencyCode" : @"USD",
    @"productIdentifier" : @"consumable",
    @"localizedTitle" : @"title",
    @"downloadable" : @YES,
    @"downloadContentLengths" : @[ @1, @2 ],
    @"subscriptionPeriod" : @{@"numberOfUnits" : @(0), @"unit" : @(0)},
    @"introductoryPrice" : @{
      @"price" : @(1.0),
      @"currencyCode" : @"USD",
      @"numberOfPeriods" : @(1),
      @"subscriptionPeriod" : @{@"numberOfUnits" : @(0), @"unit" : @(0)},
      @"paymentMode" : @(1)
    },
    @"subscriptionGroupIdentifier" : @"com.group"
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
