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
  SKProductStub *product = [[SKProductStub alloc] init];
  NSDictionary *map = [product toMap];
  NSDictionary *match = @{
    @"price" : @(1.0),
    @"currencyCode" : @"USD",
    @"productIdentifier" : @"consumable",
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

- (void)testRequestDelegateSetup {
  FIAPProductRequestHandler *handler = [FIAPProductRequestHandler new];
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"expect delegate set to be empty after complition"];
   __block SKProductsResponse *response;
  [handler startWithProductIdentifiers:[NSSet new]
                     completionHandler:^(SKProductsResponse *_Nullable r) {
                         response = r;
                       [expectation fulfill];
                     }];
  [self waitForExpectations:@[ expectation ] timeout:5];
    XCTAssertNotNil(response);
    XCTAssertEqual(response.products.count, 0);
    XCTAssertNotEqual(response.products.count, 1);
}

@end
