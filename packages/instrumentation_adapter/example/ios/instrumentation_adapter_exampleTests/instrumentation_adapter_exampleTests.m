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

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    [NSThread sleepForTimeInterval:5.0f];
    NSLog(@"==== Begin Test Results ====");
    NSLog(@"%@", [[InstrumentationAdapterPlugin sharedInstance] getTestResults]);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
