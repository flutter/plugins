// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import Foundation
import XCTest

@testable import url_launcher_ios

class URLLauncherTests: XCTestCase {
  override func setUp() {
    self.continueAfterFailure = false
  }

  func testCreatePlugin() {
    let plugin = FLTURLLauncherPlugin()
    XCTAssertNotNil(plugin)
  }

  func testHandleMethodCall_canLaunch() {
    let plugin = FLTURLLauncherPlugin()

    let testCases = [
      [
        "url": "https://www.flutter.dev",
        "expected": true,
      ],
      [
        "url": "invalidURL",
        "expected": false,
      ],
    ]

    for testCase in testCases {
      let call = FlutterMethodCall(methodName: "canLaunch", arguments: ["url": testCase["url"]])
      let resultExpectation = expectation(description: "result block must be called.")

      plugin.handle(call) { result in
        XCTAssertEqual(
          result as? Bool, Optional(testCase["expected"]! as! Bool),
          "result of canLaunch was not as expected")
        resultExpectation.fulfill()
      }

      waitForExpectations(timeout: 30)
    }
  }

  func testHandleMethodCall_launch() {
    let plugin = FLTURLLauncherPlugin()
    let call = FlutterMethodCall(methodName: "launch", arguments: ["url": "https://flutter.dev"])
    let resultExpectation = expectation(description: "result block must be called.")

    plugin.handle(call) { result in
      XCTAssertEqual(
        result as? Bool, Optional(true),
        "result block should be called with true on successful launch")
      resultExpectation.fulfill()
    }

    waitForExpectations(timeout: 30)
  }

  func testHandleMethodCall_launchInVC() {
    let plugin = FLTURLLauncherPlugin()
    let call = FlutterMethodCall(
      methodName: "launch", arguments: ["url": "https://flutter.dev", "useSafariVC": true])
    let resultExpectation = expectation(description: "result block must be called.")

    plugin.handle(call) { result in
      XCTAssertEqual(
        result as? Bool, Optional(true),
        "result block should be called with true on successful launch")
      resultExpectation.fulfill()
    }

    waitForExpectations(timeout: 30)
  }

  func testHandleMethodCall_closeWebView() {
    let plugin = FLTURLLauncherPlugin()

    // launch webview in separate VC
    var call = FlutterMethodCall(
      methodName: "launch", arguments: ["url": "https://flutter.dev", "useSafariVC": true])
    var resultExpectation = expectation(description: "result block must be called.")

    plugin.handle(call) { result in
      XCTAssertEqual(
        result as? Bool, Optional(true),
        "result block should be called with true on successful launch")
      resultExpectation.fulfill()
    }

    waitForExpectations(timeout: 30)

    // close webview
    call = FlutterMethodCall(methodName: "close", arguments: nil)
    resultExpectation = expectation(description: "result block must be called.")

    plugin.handle(call) { result in
      XCTAssertEqual(
        result as? Bool, nil,
        "result block should be called with nil on close")
      resultExpectation.fulfill()
    }

    waitForExpectations(timeout: 30)
  }

  func testHandleMethodCall_nonExistentMethod() {
    let plugin = FLTURLLauncherPlugin()
    let call = FlutterMethodCall(methodName: "nonExistent", arguments: nil)
    let resultExpectation = expectation(description: "result block must be called.")

    plugin.handle(call) { result in
      XCTAssertEqual(
        result as? NSObject, FlutterMethodNotImplemented,
        "result block must be called with FlutterMethodNotImplemented")
      resultExpectation.fulfill()
    }

    waitForExpectations(timeout: 30)
  }
}
