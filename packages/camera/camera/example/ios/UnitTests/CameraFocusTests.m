//
//  camera_exampleTests.m
//  camera_exampleTests
//
//  Created by Rene Floor on 31/05/2021.
//  Copyright © 2021 The Flutter Authors. All rights reserved.
//

@import camera;
@import XCTest;

@interface CameraFocusTests : XCTestCase

@end

@implementation CameraFocusTests

- (void)setUp {
    FLTCamera camera = [[FLTCam alloc] init]
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
