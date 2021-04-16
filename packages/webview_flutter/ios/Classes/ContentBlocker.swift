//
//  Adblocker.swift
//  webview_flutter
//
//  Created by Joecks, Simon on 07.04.21.
//

import Foundation


@objc public class HelperFunctions : NSObject  {
    private static var sharedSecret = 0

    @objc public class func accessSecret() -> String {
        sharedSecret = sharedSecret + 1
        print("accessed shared \(sharedSecret)")
        return "accessed shared \(sharedSecret)"
    }

    // use @objc or @objcMembers annotation if necessary
    class Foo {
        //..
    }
}

@objc public class HelloWorld : NSObject {
    @objc static public func hello() {
        print("hello world")
    }
}
