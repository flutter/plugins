//
//  Created by TruongSinh Tran-Nguyen on 2019-01-05.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import XCTest

class device_infoUnitTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testIsPhysicalDevice() {
        let r = FLTDeviceInfoPlugin()
        XCTAssertEqual(r.isDevicePhysical(), "false")
    }

}
