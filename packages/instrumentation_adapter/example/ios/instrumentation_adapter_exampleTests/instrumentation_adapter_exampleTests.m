//
//  instrumentation_adapter_exampleTests.m
//  instrumentation_adapter_exampleTests
//
//  Created by Tong Wu on 9/26/19.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <instrumentation_adapter/InstrumentationAdapterPlugin.h>

@interface instrumentation_adapter_exampleTests : XCTestCase
@end

@implementation instrumentation_adapter_exampleTests

- (void)testMirrorChannelTests {
  InstrumentationAdapterPlugin* plugin = InstrumentationAdapterPlugin.sharedInstance;

  [self keyValueObservingExpectationForObject:plugin
                                      keyPath:@"testResultsByDescription"
                                      handler:^BOOL(InstrumentationAdapterPlugin* plugin, NSDictionary* change) {
    id newValue = change[NSKeyValueChangeNewKey];
    if (newValue != nil && newValue != [NSNull null]) {
      NSDictionary<NSString*, IAPTestResult>* testResultsByDescription = newValue;
      [testResultsByDescription enumerateKeysAndObjectsUsingBlock:^(NSString *description, IAPTestResult result, BOOL * _Nonnull stop) {
        XCTAssertEqualObjects(result, IAPTestResultSuccess, @"Failed channel test: %@", description);
      }];
      return YES;
    }
    return NO;
  }];
  [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

@end
