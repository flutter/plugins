// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <XCTest/XCTest.h>
#import "InAppPurchasePlugin.h"
#import "Stubs.h"

@interface InAppPurchasePluginTest : XCTestCase

@end

@implementation InAppPurchasePluginTest
InAppPurchasePlugin* plugin;

- (void)setUp {
  plugin = [[InAppPurchasePluginStub alloc] init];
}

- (void)tearDown {
}

- (void)testInvalidMethodCall {
  XCTestExpectation* expectation =
      [self expectationWithDescription:@"expect result to be not implemented"];
  FlutterMethodCall* call = [FlutterMethodCall methodCallWithMethodName:@"invalid" arguments:NULL];
  __block id result;
  [plugin handleMethodCall:call
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
  [plugin handleMethodCall:call
                    result:^(id r) {
                      [expectation fulfill];
                      result = r;
                    }];
  [self waitForExpectations:@[ expectation ] timeout:5];
  XCTAssertEqual(result, [NSNumber numberWithBool:YES]);
}

- (void)testGetProductResponse {
  XCTestExpectation* expectation =
      [self expectationWithDescription:@"expect response contains 1 item"];
  FlutterMethodCall* call = [FlutterMethodCall
      methodCallWithMethodName:@"-[InAppPurchasePlugin startProductRequest:result:]"
                     arguments:@[ @"123" ]];
  __block id result;
  [plugin handleMethodCall:call
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

@end
