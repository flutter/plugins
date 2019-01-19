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

- (void)testRequestHandler {
  SKProductRequestStub *request =
      [[SKProductRequestStub alloc] initWithProductIdentifiers:[NSSet setWithArray:@[ @"123" ]]];
  FIAPProductRequestHandler *handler =
      [[FIAPProductRequestHandler alloc] initWithProductRequest:request];
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
