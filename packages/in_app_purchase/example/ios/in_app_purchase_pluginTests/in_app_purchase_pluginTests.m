#import <XCTest/XCTest.h>
#import "InAppPurchasePlugin.h"

@interface in_app_purchase_pluginTests : XCTestCase

@end

@implementation in_app_purchase_pluginTests
InAppPurchasePlugin* plugin;

- (void)setUp {
  plugin = [[InAppPurchasePlugin alloc] init];
}

- (void)tearDown {
}

- (void)testInvalidMethodCall {
  FlutterMethodCall* call = [FlutterMethodCall methodCallWithMethodName:@"invalid" arguments:NULL];
  [plugin handleMethodCall:call
                    result:^(id result) {
                      XCTAssert(result == FlutterMethodNotImplemented);
                    }];
}

- (void)testCanMakePayments {
  FlutterMethodCall* call =
      [FlutterMethodCall methodCallWithMethodName:@"-[SKPaymentQueue canMakePayments:]"
                                        arguments:NULL];
  [plugin handleMethodCall:call
                    result:^(id result) {
                      XCTAssert(result == [NSNumber numberWithBool:YES]);
                    }];
}

@end
