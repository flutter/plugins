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

@interface SKProductStub : SKProduct
@end

@implementation SKProductStub

- (instancetype)init {
  self = [super init];
  if (self) {
    [self setValue:@"consumable" forKey:@"productIdentifier"];
  }
  return self;
}

@end

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

//@implementation SKProductSubscriptionPeriod(Coder)
//
//- (NSDictionary *)toMap {
//    return @{
//             @"numberOfUnits":@(self.numberOfUnits),
//             @"unit":@(self.unit)
//             };
//}
//
//@end
//
//@implementation SKProductDiscount(Coder)
//
//- (NSDictionary *)toMap {
//    return @{
//             @"price": self.price,
//             @"priceLocale": self.priceLocale,
//             @"numberOfPeriods": @(self.numberOfPeriods),
//             @"subscriptionPeriod": [self.subscriptionPeriod toMap],
//             @"paymentMode": @(self.paymentMode)
//             };
//}

#pragma tests

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
}

//- (void)testProductToMap {
//    SKProductStub *product = [[SKProductStub alloc] init];
//
//}

@end
