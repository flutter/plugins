//
//  Created by TruongSinh Tran-Nguyen on 2019-01-05.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import XCTest

class device_infoUnitTests: XCTestCase {
    let r = FLTDeviceInfoPlugin()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testIsPhysicalDevice() {
        XCTAssertEqual(r.isDevicePhysical(), "false")
    }
    
    func testSuccessCall(){
        let mCall = FlutterMethodCall.init(methodName: "getIosDeviceInfo", arguments: nil)
        
        r.handle(mCall)  { (result) -> () in
            var jsonResult = result as! Dictionary<String, AnyObject>
            print(jsonResult)
            XCTAssertNotNil(jsonResult["utsname"])
        }
    }

    func testFlutterMethodNotImplemented(){
        let mCall = FlutterMethodCall.init(methodName: "some weird method", arguments: nil)
        
        r.handle(mCall)  { (result) -> () in
            XCTAssertEqual(result as! NSObject, FlutterMethodNotImplemented)
        }
    }

}
