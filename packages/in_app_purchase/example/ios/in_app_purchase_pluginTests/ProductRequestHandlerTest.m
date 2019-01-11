//
//  ProductRequestHandlerTest.m
//  in_app_purchase_pluginTests
//
//  Created by Chris Yang on 1/11/19.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FLTSKProductRequestHandler.h"

@interface ProductRequestHandlerTest : XCTestCase

@property (strong, nonatomic) FLTSKProductRequestHandler *handler;

@end

@implementation ProductRequestHandlerTest

- (void)setUp {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.handler = [[FLTSKProductRequestHandler alloc] init];
    });

}

//- (void)testStartWithNoProducts {
//    self.handler = [[FLTSKProductRequestHandler alloc] initWithProductIdentifiers:[NSSet setWithObjects:@"", @"1", nil]];
//    [self.handler startWithCompletionHandler:^(SKProductsResponse * _Nullable response) {
//        XCTAssertNotNil(response);
//        XCTAssertTrue(response.products.count == 0);
//    }];
//    // This is an example of a functional test case.
//    // Use XCTAssert and related functions to verify your tests produce the correct results.
//}
//
//- (void)testEmptySet {
//    self.handler = [[FLTSKProductRequestHandler alloc] initWithProductIdentifiers:[NSSet new]];
//    [self.handler startWithCompletionHandler:^(SKProductsResponse * _Nullable response) {
//        XCTAssertNotNil(response);
//        XCTAssertTrue(response.products.count == 0);
//    }];
//    // This is an example of a functional test case.
//    // Use XCTAssert and related functions to verify your tests produce the correct results.
//}

- (void)testSingleItemConsumable {
    [self.handler startWithProductIdentifiers:[NSSet setWithObjects:@"consumable", nil] completionHandler:^(SKProductsResponse *response) {
        XCTAssertNil(response);
    }];
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}


@end
