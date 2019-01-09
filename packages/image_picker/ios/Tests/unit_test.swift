// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

class image_pickerUnitTests: XCTestCase {
    let r = FLTImagePickerPlugin()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFlutterMethodNotImplemented(){
        let mCall = FlutterMethodCall.init(methodName: "some weird method", arguments: nil)
        
        r.handle(mCall)  { (result) -> () in
            XCTAssertEqual(result as! NSObject, FlutterMethodNotImplemented)
        }
    }
    
}
