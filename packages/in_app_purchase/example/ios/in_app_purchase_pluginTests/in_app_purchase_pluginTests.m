#import <XCTest/XCTest.h>
#import "InAppPurchasePlugin.h"
#import "Stubs.h"

@interface in_app_purchase_pluginTests : XCTestCase

@end

@implementation in_app_purchase_pluginTests
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

- (void)testGetProductList {
  XCTestExpectation* expectation =
      [self expectationWithDescription:@"expect response contains 1 item"];
  FlutterMethodCall* call =
      [FlutterMethodCall methodCallWithMethodName:@"getProductList"
                                        arguments:@{@"identifiers" : @[ @"123" ]}];
  __block id result;
  [plugin handleMethodCall:call
                    result:^(id r) {
                      [expectation fulfill];
                      result = r;
                    }];
  [self waitForExpectations:@[ expectation ] timeout:5];
  XCTAssert([result isKindOfClass:[NSArray class]]);
  NSArray* resultArray = (NSArray*)result;
  XCTAssertEqual(resultArray.count, 1);
  XCTAssertTrue([resultArray.firstObject[@"productIdentifier"] isEqualToString:@"123"]);
}

@end
