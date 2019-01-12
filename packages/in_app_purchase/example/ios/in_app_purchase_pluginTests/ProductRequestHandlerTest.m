//
//  ProductRequestHandlerTest.m
//  in_app_purchase_pluginTests
//
//  Created by Chris Yang on 1/11/19.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FLTSKProductRequestHandler.h"

#pragma stubs

@interface SKProductSubscriptionPeriodStub : SKProductSubscriptionPeriod
@end

@implementation SKProductSubscriptionPeriodStub

- (instancetype)init {
  self = [super init];
  if (self) {
    [self setValue:@(0) forKey:@"numberOfUnits"];
    [self setValue:@(0) forKey:@"unit"];
  }
  return self;
}

@end

@interface SKProductDiscountStub : SKProductDiscount
@end

@implementation SKProductDiscountStub

- (instancetype)init {
  self = [super init];
  if (self) {
    [self setValue:@(1.0) forKey:@"price"];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [self setValue:locale forKey:@"priceLocale"];
    [self setValue:@(1) forKey:@"numberOfPeriods"];
    SKProductSubscriptionPeriodStub *subscriptionPeriodSub =
        [[SKProductSubscriptionPeriodStub alloc] init];
    [self setValue:subscriptionPeriodSub forKey:@"subscriptionPeriod"];
    [self setValue:@(1) forKey:@"paymentMode"];
  }
  return self;
}

@end

@interface SKProductStub : SKProduct
@end

@implementation SKProductStub

- (instancetype)init {
  self = [super init];
  if (self) {
    [self setValue:@"consumable" forKey:@"productIdentifier"];
    [self setValue:@"description" forKey:@"localizedDescription"];
    [self setValue:@"title" forKey:@"localizedTitle"];
    [self setValue:@YES forKey:@"downloadable"];
    [self setValue:@(1.0) forKey:@"price"];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [self setValue:locale forKey:@"priceLocale"];
    [self setValue:@[ @1, @2 ] forKey:@"downloadContentLengths"];
    SKProductSubscriptionPeriodStub *period = [[SKProductSubscriptionPeriodStub alloc] init];
    [self setValue:period forKey:@"subscriptionPeriod"];
    SKProductDiscountStub *discount = [[SKProductDiscountStub alloc] init];
    [self setValue:discount forKey:@"introductoryPrice"];
    [self setValue:@"com.group" forKey:@"subscriptionGroupIdentifier"];
  }
  return self;
}

@end

#pragma tests start here

@interface ProductRequestHandlerTest : XCTestCase

@end

@implementation ProductRequestHandlerTest

- (void)setUp {
}

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

@end
