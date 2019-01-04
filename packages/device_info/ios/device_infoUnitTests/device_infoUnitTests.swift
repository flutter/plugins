//
//  device_infoUnitTests.swift
//  device_infoUnitTests
//
//  Created by TruongSinh Tran-Nguyen on 1/5/19.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import XCTest
@testable import device_info

class device_infoUnitTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExampleFail() {
        let r = FLTDeviceInfoPlugin()
        XCTAssertEqual(r.isDevicePhysical(), "false")
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    func testExamplePass() {
        XCTAssertEqual(2, 2)
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

}
